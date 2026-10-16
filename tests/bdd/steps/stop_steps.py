r"""Step definitions for tests/features/stop-hook.feature.

Each scenario builds the repository the commit-time scenarios use
(world.py), then feeds the Stop or SubagentStop hook the JSON payload
Claude Code sends when the agent or a subagent ends its turn, the way
the harness runs it, and reads the one JSON object the hook prints.

The project, configuration and working-tree Given steps are the ones
the other scenarios use (precommit_steps.py and session_steps.py), so
one step text means one thing in every scenario. The hook keeps its
once-per-state marker under TMPDIR, which each scenario points at a
scratch directory of its own, with one session identifier for the
whole scenario.
"""

import json
import os
import shutil
import subprocess
import tempfile

import world
from steps import step

HOOKS = r"(Stop|SubagentStop)"
SCRIPTS = {"Stop": "stop.sh", "SubagentStop": "subagent-stop.sh"}


def run_stop_hook(ctx, hook, active=False):
    """Run the `hook` hook with `stop_hook_active` set to `active`. The
    parsed object lands on ctx.hook_output, or {} when the hook printed
    nothing."""
    world.start(ctx)
    root = world.repo(ctx)
    if getattr(ctx, "stop_tmp", None) is None:
        ctx.stop_tmp = tempfile.mkdtemp(prefix="vse-stop-scenario-")
        ctx.cleanup(lambda: shutil.rmtree(ctx.stop_tmp, ignore_errors=True))
    payload = {"session_id": "scenario", "transcript_path": os.devnull,
               "cwd": root, "hook_event_name": hook,
               "stop_hook_active": active}
    env = world.environment(ctx)
    env["CLAUDE_PLUGIN_ROOT"] = world.PLUGIN
    env["TMPDIR"] = ctx.stop_tmp
    completed = subprocess.run([os.path.join(world.HOOKS, SCRIPTS[hook])],
                               input=json.dumps(payload), cwd=root, env=env,
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               universal_newlines=True, check=False)
    ctx.hook = completed
    if completed.returncode != 0:
        raise AssertionError("the {} hook exited {}: {}".format(
            hook, completed.returncode, completed.stderr.strip()))
    # json.loads refuses a second value, so two objects fail here.
    ctx.hook_output = (json.loads(completed.stdout)
                       if completed.stdout.strip() else {})


def _context(ctx):
    return ctx.hook_output.get("hookSpecificOutput", {}).get(
        "additionalContext", "")


def _shown(ctx):
    return "stdout: {}\nstderr: {}".format(ctx.hook.stdout.strip(),
                                           ctx.hook.stderr.strip())


# ----------------------------------------------------------------- Given


@step(r"the Stop hook has sent the test-first reminder for the current state")
def reminder_already_sent(ctx):
    run_stop_hook(ctx, "Stop")
    agent_receives_reminder(ctx)


# ------------------------------------------------------------------ When


@step(r"the {} hook runs with stop_hook_active set to (true|false)".format(HOOKS))
def hook_runs_with_flag(ctx, hook, flag):
    run_stop_hook(ctx, hook, active=flag == "true")


@step(r"the {} hook runs".format(HOOKS))
def hook_runs(ctx, hook):
    run_stop_hook(ctx, hook)


# ------------------------------------------------------------------ Then


@step(r"the {} hook stays silent".format(HOOKS))
def hook_silent(ctx, hook):
    if ctx.hook.stdout.strip():
        raise AssertionError("the {} hook spoke, {}".format(hook, _shown(ctx)))


@step(r"the agent receives the test-first reminder")
def agent_receives_reminder(ctx):
    if "Test first" not in _context(ctx):
        raise AssertionError("no test-first reminder, " + _shown(ctx))


@step(r"the agent receives no test-first reminder")
def agent_receives_no_reminder(ctx):
    if _context(ctx):
        raise AssertionError("the agent received context, " + _shown(ctx))
