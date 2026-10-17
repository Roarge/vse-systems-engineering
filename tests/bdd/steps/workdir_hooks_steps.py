r"""Step definitions for tests/features/workdir-hooks.feature.

Each scenario builds the repository the commit-time scenarios use
(world.py), a project that holds its .iso-config.yaml and no
methodology/ folder. It then runs the UserPromptSubmit, PreCompact or
Notification hook in a directory of it, the way Claude Code runs them,
and reads the plain text the hook prints.

The GitHub command-line tool is replaced by a stub on PATH for every
run, so no scenario reaches the network. The stub lists the open Change
Requests a Given step records (none by default). The PreCompact hook
writes its snapshot under TMPDIR, which each scenario points at a
scratch directory of its own.
"""

import datetime
import json
import os
import re
import shutil
import stat
import subprocess
import tempfile

import world
from steps import step

SCRIPTS = {"UserPromptSubmit": "user-prompt-submit.sh",
           "PreCompact": "pre-compact.sh",
           "Notification": "notification.sh"}


def _scratch(ctx):
    """The scenario's scratch directory for the gh stub and TMPDIR."""
    if getattr(ctx, "workdir_tmp", None) is None:
        ctx.workdir_tmp = tempfile.mkdtemp(prefix="vse-workdir-scenario-")
        ctx.cleanup(lambda: shutil.rmtree(ctx.workdir_tmp, ignore_errors=True))
        os.makedirs(os.path.join(ctx.workdir_tmp, "bin"))
        os.makedirs(os.path.join(ctx.workdir_tmp, "tmp"))
        ctx.open_change_requests = []
    return ctx.workdir_tmp


def _write_gh_stub(ctx):
    """A gh that prints the recorded open Change Requests as JSON."""
    path = os.path.join(_scratch(ctx), "bin", "gh")
    listing = json.dumps(ctx.open_change_requests)
    with open(path, "w", encoding="utf-8") as handle:
        handle.write("#!/bin/sh\ncat <<'EOF'\n{}\nEOF\n".format(listing))
    os.chmod(path, os.stat(path).st_mode | stat.S_IXUSR | stat.S_IXGRP
             | stat.S_IXOTH)


def run_workdir_hook(ctx, hook, directory, payload):
    """Run the `hook` hook in `directory` (relative to the repository)
    with `payload` on stdin. The text it printed lands on
    ctx.hook_text."""
    root = world.repo(ctx)
    cwd = os.path.join(root, directory)
    os.makedirs(cwd, exist_ok=True)
    scratch = _scratch(ctx)
    _write_gh_stub(ctx)
    env = world.environment(ctx)
    env["CLAUDE_PLUGIN_ROOT"] = world.PLUGIN
    env["PATH"] = os.path.join(scratch, "bin") + os.pathsep + env.get("PATH", "")
    env["TMPDIR"] = os.path.join(scratch, "tmp")
    payload = dict(payload, cwd=cwd, hook_event_name=hook,
                   session_id="scenario", transcript_path=os.devnull)
    completed = subprocess.run([os.path.join(world.HOOKS, SCRIPTS[hook])],
                               input=json.dumps(payload), cwd=cwd, env=env,
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               universal_newlines=True, check=False)
    if completed.returncode != 0:
        raise AssertionError("the {} hook exited {}: {}".format(
            hook, completed.returncode, completed.stderr.strip()))
    ctx.hook_text = completed.stdout


def _shown(ctx):
    return "the hook printed:\n" + ctx.hook_text


# ----------------------------------------------------------------- Given


@step(r"a Change Request has been open for (\d+) days")
def change_request_open(ctx, days):
    _scratch(ctx)
    opened = (datetime.datetime.now(datetime.timezone.utc)
              - datetime.timedelta(days=int(days)))
    ctx.open_change_requests.append(
        {"number": len(ctx.open_change_requests) + 1,
         "createdAt": opened.strftime("%Y-%m-%dT%H:%M:%SZ")})


# ------------------------------------------------------------------ When


@step(r'the engineer submits the prompt "([^"]+)" in the project directory')
def prompt_in_project(ctx, prompt):
    run_workdir_hook(ctx, "UserPromptSubmit", ".", {"prompt": prompt})


@step(r'the engineer submits the prompt "([^"]+)" in the directory (\S+)')
def prompt_in_directory(ctx, prompt, directory):
    run_workdir_hook(ctx, "UserPromptSubmit", directory, {"prompt": prompt})


@step(r"the context is compacted in the directory (\S+)")
def compacted_in(ctx, directory):
    run_workdir_hook(ctx, "PreCompact", directory, {"trigger": "auto"})


@step(r"a notification arrives in the directory (\S+)")
def notification_in(ctx, directory):
    run_workdir_hook(ctx, "Notification", directory,
                     {"message": "Claude is waiting for your input"})


# ------------------------------------------------------------------ Then


@step(r"the agent is reminded to raise a Change Request")
def reminded_change_request(ctx):
    if "[methodology reminder, PM.O3]" not in ctx.hook_text:
        raise AssertionError("no Change Request reminder, " + _shown(ctx))


@step(r"a state snapshot of the project is saved")
def snapshot_saved(ctx):
    found = re.search(r"^\[VSE state snapshot saved to (.+)\]$",
                      ctx.hook_text, re.MULTILINE)
    if not found:
        raise AssertionError("no snapshot saved, " + _shown(ctx))
    with open(found.group(1), encoding="utf-8") as handle:
        snapshot = handle.read()
    root = os.path.realpath(world.repo(ctx))
    expected = "Engineering root: {}/".format(root)
    if expected not in snapshot.splitlines():
        raise AssertionError("the snapshot does not name {}, it reads:\n{}"
                             .format(root, snapshot))


@step(r"the engineer is told that (\d+) Change Requests? (?:has|have) been open more than 14 days")
def told_stale_change_requests(ctx, count):
    expected = "[VSE notification] {} Change Request(s) open >14 days.".format(
        count)
    if expected not in ctx.hook_text:
        raise AssertionError("no stale Change Request notice, " + _shown(ctx))
