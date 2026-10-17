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
