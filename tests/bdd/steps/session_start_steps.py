r"""Step definitions for tests/features/session-start.feature.

Each scenario builds the repository the commit-time scenarios use
(world.py), then runs the SessionStart hook in a directory of it, the
way Claude Code runs it when a session starts there, and reads the
plain text the hook prints. That text is what the agent is told.

The project and configuration Given steps are the ones the other
scenarios use (precommit_steps.py), so one step text means one thing in
every scenario.
"""

import os
import subprocess

import world
from steps import step

HOOK = os.path.join(world.HOOKS, "session-start.sh")


def run_session_start(ctx, directory):
    """Run the SessionStart hook in `directory` (relative to the
    repository). The text it printed lands on ctx.session_output."""
    root = world.repo(ctx)
    cwd = os.path.join(root, directory)
    os.makedirs(cwd, exist_ok=True)
    env = world.environment(ctx)
    env["CLAUDE_PLUGIN_ROOT"] = world.PLUGIN
    completed = subprocess.run(["bash", HOOK], cwd=cwd, env=env,
                               stdin=subprocess.DEVNULL,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE,
                               universal_newlines=True, check=False)
    if completed.returncode != 0:
        raise AssertionError("the hook exited {}: {}".format(
            completed.returncode, completed.stderr.strip()))
    ctx.session_output = completed.stdout


def _lines(ctx):
    return ctx.session_output.splitlines()


def _shown(ctx):
    return "the session was told:\n" + ctx.session_output


def _line(ctx, prefix):
    """The first line that starts with `prefix`, or an empty string."""
    for line in _lines(ctx):
        if line.startswith(prefix):
            return line
    return ""


SKILL = "superpowers:test-driven-development"

# ----------------------------------------------------------------- Given


@step(r"test first is recorded as not applying")
def test_first_not_applying(ctx):
    world.repo(ctx)
    ctx.test_first = [
        "test_first:",
        "  applies: false",
        '  rationale: "The project holds no implementation code."',
    ]
    world.write_config(ctx)


@step(r"the project holds the file (\S+)")
def project_holds_file(ctx, path):
    world.write(ctx, path, "")


# ------------------------------------------------------------------ When


@step(r"a session starts in the project directory")
def session_starts_in_project(ctx):
    run_session_start(ctx, ".")


@step(r"a session starts in the directory (\S+)")
def session_starts_in(ctx, directory):
    run_session_start(ctx, directory)


# ------------------------------------------------------------------ Then


@step(r"the session is told the project runs at the (light|standard|full) profile")
def told_profile(ctx, profile):
    if not any(line.startswith("Profile:") and line.split()[1] == profile
               for line in _lines(ctx)):
        raise AssertionError("no {} profile, {}".format(profile, _shown(ctx)))



@step(r"the session is told that test first applies")
def told_test_first_applies(ctx):
    if not _line(ctx, "Test-first: test_first.applies is true."):
        raise AssertionError("test first is not said to apply, " + _shown(ctx))


@step(r"the session is told that test first is not required here")
def told_test_first_not_required(ctx):
    line = _line(ctx, "Test-first: test_first.applies is false.")
    if "not required here" not in line:
        raise AssertionError("test first is not said to be not required, "
                             + _shown(ctx))


@step(r"the session is pointed at the superpowers test-driven-development skill")
def pointed_at_skill(ctx):
    if SKILL not in _line(ctx, "Test-first:"):
        raise AssertionError("no pointer to {}, {}".format(SKILL, _shown(ctx)))


@step(r"the session is not pointed at the superpowers test-driven-development skill")
def not_pointed_at_skill(ctx):
    if SKILL in ctx.session_output:
        raise AssertionError("a pointer to {}, {}".format(SKILL, _shown(ctx)))


@step(r"the session is told to work Gherkin first")
def told_gherkin_first(ctx):
    line = _line(ctx, "Behaviour-first:")
    if "Gherkin feature" not in line or "before design or code" not in line:
        raise AssertionError("no Gherkin-first line, " + _shown(ctx))


@step(r"the session is asked to record test first with (/[\w-]+)")
def asked_to_record(ctx, command):
    line = _line(ctx, "Test-first: test_first.applies is not recorded")
    if command not in line:
        raise AssertionError("{} is not asked for, {}".format(command,
                                                              _shown(ctx)))


@step(r"the session is told that test tooling was found")
def told_tooling_found(ctx):
    if "test tooling found" not in _line(ctx, "Test-first nudge:"):
        raise AssertionError("no nudge about test tooling, " + _shown(ctx))
