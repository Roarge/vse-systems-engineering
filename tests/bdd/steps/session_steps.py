r"""Step definitions for the in-session scenarios.

They cover gherkin-first.feature, the in-session Rule of
test-first.feature and the in-session Rule of profile-gates.feature.
Each scenario builds the repository the commit-time scenarios use
(world.py), then feeds the PreToolUse hook the JSON payload Claude Code
sends before an Edit or Write call, the way the harness runs it, and
reads the one JSON object the hook prints.

The project and configuration Given steps are the ones the commit-time
scenarios use, defined in precommit_steps.py, and "a feature file for
<ID>" and "a story file <ID> without a feature file" are the story lint
steps of lint_steps.py. They all write into the same project directory,
so one step text means one thing in every scenario.
"""

import json
import os
import subprocess

import world
from lint_steps import STORIES, project
from steps import step

HOOK = os.path.join(world.HOOKS, "pre-tool-use.sh")
STORY_FILE = os.path.join(STORIES, "stories.sysml")


def story(identifier):
    """One story block, with a capability unique to the identifier, so
    that an edit to one story never matches another."""
    return (
        "    requirement {0} : UserStory {{\n"
        "        @StoryMeta {{ points = 3; priority = Priority::high;"
        " status = StoryStatus::ready; }}\n"
        "\n"
        "        subject :>> system : ExampleSystem;\n"
        "        stakeholder :>> role : Operator;\n"
        "\n"
        "        attribute :>> capability = \"use {0}\";\n"
        "        attribute :>> benefit    = \"the device is known to work\";\n"
        "    }}\n"
    ).format(identifier)


def register(*identifiers):
    """A story file holding the named stories."""
    body = "\n".join(story(identifier) for identifier in identifiers)
    return ("package ExampleStories {\n"
            "    private import VSE_Library::*;\n\n"
            + body + "}\n")


def run_hook(ctx, tool, path, **given):
    """Run the PreToolUse hook for a `tool` call on `path` (relative to
    the repository) with the tool input `given`. The parsed object
    lands on ctx.hook_output, or {} when the hook printed nothing."""
    root = world.repo(ctx)
    given["file_path"] = os.path.join(root, path)
    payload = {"session_id": "scenario", "cwd": root,
               "hook_event_name": "PreToolUse", "tool_name": tool,
               "tool_input": given}
    env = world.environment(ctx)
    env["CLAUDE_PLUGIN_ROOT"] = world.PLUGIN
    completed = subprocess.run([HOOK], input=json.dumps(payload), cwd=root,
                               env=env, stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE,
                               universal_newlines=True, check=False)
    ctx.hook = completed
    if completed.returncode != 0:
        raise AssertionError("the hook exited {}: {}".format(
            completed.returncode, completed.stderr.strip()))
    # json.loads refuses a second value, so two objects fail here.
    ctx.hook_output = (json.loads(completed.stdout)
                       if completed.stdout.strip() else {})


def _specific(ctx):
    return ctx.hook_output.get("hookSpecificOutput", {})


def _decision(ctx):
    return _specific(ctx).get("permissionDecision")


def _reason(ctx):
    return _specific(ctx).get("permissionDecisionReason", "")


def _context(ctx):
    return _specific(ctx).get("additionalContext", "")


def _shown(ctx):
    return "stdout: {}\nstderr: {}".format(ctx.hook.stdout.strip(),
                                           ctx.hook.stderr.strip())


# ----------------------------------------------------------------- Given


@step(r"no feature file for (\w+)")
def no_feature_for(ctx, identifier):
    path = os.path.join(project(ctx), STORIES, identifier + ".feature")
    if os.path.exists(path):
        os.remove(path)


@step(r"a story file holding (\w+) and (\w+)")
def story_file_holding(ctx, first, second):
    world.write(ctx, STORY_FILE, register(first, second))


@step(r"the file (\S+) has changed in the working tree")
def file_changed(ctx, path):
    world.write(ctx, path, "# A change to {}\n".format(path))


@step(r"the branch (\S+) is checked out")
def branch_checked_out(ctx, branch):
    world.start(ctx)
    world.git(ctx, "checkout", "-q", "-b", branch)


# ------------------------------------------------------------------ When


@step(r"the agent adds the story (\w+) to a story file")
def agent_adds_story(ctx, identifier):
    run_hook(ctx, "Write", STORY_FILE, content=register(identifier))


@step(r"the agent changes the story (\w+)")
def agent_changes_story(ctx, identifier):
    old = 'capability = "use {}"'.format(identifier)
    with open(os.path.join(world.repo(ctx), STORY_FILE),
              encoding="utf-8") as handle:
        if handle.read().count(old) != 1:
            raise AssertionError("the story file does not hold {} once".format(
                old))
    run_hook(ctx, "Edit", STORY_FILE, old_string=old,
             new_string='capability = "use {} daily"'.format(identifier))


@step(r"the agent deletes the story (\w+)")
def agent_deletes_story(ctx, identifier):
    with open(os.path.join(world.repo(ctx), STORY_FILE),
              encoding="utf-8") as handle:
        if "requirement {} : UserStory".format(identifier) not in handle.read():
            raise AssertionError("the story file does not hold " + identifier)
    run_hook(ctx, "Write", STORY_FILE, content=register())


@step(r"the agent changes gate_overrides in \.iso-config\.yaml")
def agent_changes_overrides(ctx):
    run_hook(ctx, "Edit", ".iso-config.yaml", old_string="gate_overrides:\n",
             new_string="gate_overrides:\n  pretooluse_gherkin_first: off\n")


@step(r"the agent writes a new (\S+/\.iso-config\.yaml) that leaves out gate_overrides")
def agent_writes_nested_config(ctx, path):
    """A configuration below the project's governs the files in its
    directory and below, so leaving gate_overrides out of it would lower
    every overridden gate there."""
    if os.path.exists(os.path.join(world.repo(ctx), path)):
        raise AssertionError(path + " already exists")
    run_hook(ctx, "Write", path,
             content="project_profile: {}\n".format(ctx.profile))


@step(r"the agent edits (\S+)")
def agent_edits(ctx, path):
    world.start(ctx)
    run_hook(ctx, "Write", path, content="# An edit to {}\n".format(path))


# ------------------------------------------------------------------ Then


@step(r"the edit is denied")
def edit_denied(ctx):
    if _decision(ctx) != "deny":
        raise AssertionError("the edit was not denied, " + _shown(ctx))


@step(r"the edit goes ahead")
def edit_goes_ahead(ctx):
    if _decision(ctx) is not None:
        raise AssertionError("the hook decided {}, {}".format(
            _decision(ctx), _shown(ctx)))


@step(r"the denial names the feature file (\S+)")
def denial_names_feature(ctx, name):
    edit_denied(ctx)
    if os.sep + name not in _reason(ctx):
        raise AssertionError("{} is not named, {}".format(name, _shown(ctx)))


@step(r"the denial asks for a failing test first")
def denial_asks_for_test(ctx):
    edit_denied(ctx)
    if "failing test" not in _reason(ctx):
        raise AssertionError("no failing test is asked for, " + _shown(ctx))


@step(r"the agent is warned that (\w+) has no feature file")
def warned_no_feature(ctx, identifier):
    edit_goes_ahead(ctx)
    if identifier + ".feature" not in _context(ctx):
        raise AssertionError("no warning about {}, {}".format(
            identifier, _shown(ctx)))


@step(r"the agent is reminded that no test file has changed")
def reminded_no_test(ctx):
    edit_goes_ahead(ctx)
    if "no test file has changed" not in _context(ctx):
        raise AssertionError("no reminder, " + _shown(ctx))


@step(r"the engineer is asked to confirm the edit")
def asked_to_confirm(ctx):
    if _decision(ctx) != "ask":
        raise AssertionError("the engineer was not asked, " + _shown(ctx))
