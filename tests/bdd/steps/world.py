r"""A scratch git repository for the scenarios that commit.

The repository is the project directory that `lint_steps.project(ctx)`
creates, with the shipped story lint and renderers already under
tools/. The story and feature Given steps of story-lint.feature write
into that same directory, so one step text means one thing in every
scenario, and the runner never finds two definitions for it.

On first use the helper turns the directory into a git repository on
main and installs the project-side hooks under .githooks/ the way the
attention-regime skill does, with core.hooksPath pointing at them. The
configuration is rewritten from the scenario's state whenever a Given
step changes it.

Two gates are off in every scenario here, because no scenario
describes them: the SysML lint, which would need a SysML toolchain on
the machine, and the traceability gate, which reports every story that
has no verification case yet. Each scenario therefore observes only
the gates it names.

Git runs with a scratch HOME and without the system configuration, so
no setting on the machine (a signing requirement, a global hooks
directory) changes what a scenario sees. Variables an outer run might
carry, such as VSE_ISO_CONFIG, the GITHUB_HEAD_REF of a CI job, or a
GIT_INDEX_FILE set by a git hook that runs the suite, are removed.
"""

import os
import shutil
import stat
import subprocess
import tempfile

from lint_steps import project

HERE = os.path.dirname(os.path.abspath(__file__))
PLUGIN = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
HOOKS = os.path.join(PLUGIN, "hooks")

# Installed path under the project, source path under hooks/.
INSTALL = (
    (".githooks/pre-commit", "pre-commit.sh"),
    (".githooks/pre-commit-traceability.sh", "pre-commit-traceability.sh"),
    (".githooks/lib/iso-profile.sh", "lib/iso-profile.sh"),
    (".githooks/lib/sysml-toolchain.sh", "lib/sysml-toolchain.sh"),
    (".githooks/lib/test-first.sh", "lib/test-first.sh"),
)

# The gates no scenario here describes, off so that they stay quiet.
QUIET_GATES = (("precommit_lint", "off"), ("precommit_traceability", "off"))

# What the first commit holds: the installed hooks, the tools and the
# configuration, never the files a scenario is about.
SCAFFOLD = (".githooks", "tools", ".iso-config.yaml")

DROPPED = ("VSE_ISO_CONFIG", "VSE_PRECOMMIT_RANGE", "CLAUDE_PLUGIN_ROOT",
           "XDG_CONFIG_HOME", "GITHUB_HEAD_REF")


def environment(ctx):
    """The environment for git and the hooks: the caller's, with a
    scratch HOME, no system git configuration, and nothing an outer run
    could use to steer the code under test."""
    if getattr(ctx, "home", None) is None:
        ctx.home = tempfile.mkdtemp(prefix="vse-world-home-")
        ctx.cleanup(lambda: shutil.rmtree(ctx.home, ignore_errors=True))
    env = {name: value for name, value in os.environ.items()
           if not name.startswith("GIT_") and name not in DROPPED}
    env["HOME"] = ctx.home
    env["GIT_CONFIG_NOSYSTEM"] = "1"
    return env


def run(ctx, args, cwd=None, extra=None):
    """Run a command in the repository (or `cwd`) and return the
    completed process, with stdout and stderr as text."""
    env = environment(ctx)
    env.update(extra or {})
    return subprocess.run(args, cwd=cwd or repo(ctx), env=env,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                          universal_newlines=True, check=False)


def git(ctx, *args, cwd=None):
    """Run git and return its stdout. A failure fails the step."""
    completed = run(ctx, ["git"] + list(args), cwd=cwd)
    if completed.returncode != 0:
        raise AssertionError("git {} exited {}: {}".format(
            " ".join(args), completed.returncode, completed.stderr.strip()))
    return completed.stdout


def repo(ctx):
    """The scenario's repository, created and set up on first use."""
    root = project(ctx)
    if getattr(ctx, "world_ready", False):
        return root
    ctx.world_ready = True
    ctx.profile = "standard"
    ctx.overrides = list(QUIET_GATES)
    ctx.test_first = []
    git(ctx, "init", "-q", cwd=root)
    git(ctx, "symbolic-ref", "HEAD", "refs/heads/main", cwd=root)
    for key, value in (("user.name", "VSE scenario"),
                       ("user.email", "scenario@example.invalid"),
                       ("commit.gpgsign", "false"),
                       ("tag.gpgsign", "false"),
                       ("core.hooksPath", ".githooks")):
        git(ctx, "config", key, value, cwd=root)
    for target, source in INSTALL:
        path = os.path.join(root, target)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        shutil.copyfile(os.path.join(HOOKS, source), path)
        os.chmod(path, os.stat(path).st_mode | stat.S_IXUSR | stat.S_IXGRP
                 | stat.S_IXOTH)
    write_config(ctx)
    return root


def write_config(ctx):
    """Write .iso-config.yaml from the scenario's profile, its gate
    overrides (later entries win) and its test_first record."""
    overrides = []  # type: list
    for gate, disposition in ctx.overrides:
        overrides = [(g, d) for g, d in overrides if g != gate]
        overrides.append((gate, disposition))
    lines = ["project_profile: " + ctx.profile, "gate_overrides:"]
    lines.extend("  {}: {}".format(gate, disposition)
                 for gate, disposition in overrides)
    lines.extend(ctx.test_first)
    write(ctx, ".iso-config.yaml", "\n".join(lines) + "\n")


def write(ctx, path, text):
    """Write `text` to `path` under the repository."""
    full = os.path.join(repo(ctx), path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf-8") as handle:
        handle.write(text)


def head(ctx, cwd=None):
    """The commit HEAD names, or None on an unborn branch."""
    completed = run(ctx, ["git", "rev-parse", "-q", "--verify", "HEAD"],
                    cwd=cwd)
    return completed.stdout.strip() or None


def start(ctx):
    """Commit the scaffold on main, once, without running the hooks, so
    that a scenario's own commit has a parent and a base to compare
    with."""
    if head(ctx) is None:
        git(ctx, "add", "--", *SCAFFOLD)
        git(ctx, "commit", "-q", "--no-verify", "-m", "chore: start the project")


def commit_unchecked(ctx, message, *paths):
    """Stage `paths` and commit them without running the hooks, the way
    a commit that bypassed them would land."""
    git(ctx, "add", "--", *paths)
    git(ctx, "commit", "-q", "--no-verify", "-m", message)


def commit(ctx, message, *paths):
    """Stage `paths` and commit them with the hooks running, as the
    engineer would. The result lands on ctx.result, with the combined
    output on ctx.output and whether HEAD moved on ctx.landed."""
    git(ctx, "add", "--", *paths)
    before = head(ctx)
    ctx.result = run(ctx, ["git", "commit", "-q", "-m", message])
    ctx.output = ctx.result.stdout + ctx.result.stderr
    ctx.landed = head(ctx) != before


def checkout(ctx, ref):
    """A fresh clone of the repository with `ref` checked out and
    nothing staged, as a CI runner sees it. Returns its directory."""
    target = tempfile.mkdtemp(prefix="vse-world-ci-")
    ctx.cleanup(lambda: shutil.rmtree(target, ignore_errors=True))
    git(ctx, "clone", "-q", repo(ctx), target)
    git(ctx, "checkout", "-q", ref, cwd=target)
    if git(ctx, "diff", "--cached", "--name-only", cwd=target).strip():
        raise AssertionError("the fresh checkout has staged changes")
    return target


def ci_check(ctx, checkout_dir, file_range):
    """Run the committed pre-commit hook in `checkout_dir` in range
    mode, the way the CI workflow does. The result lands on ctx.result
    and its combined output on ctx.output."""
    ctx.result = run(ctx, [os.path.join(".githooks", "pre-commit")],
                     cwd=checkout_dir,
                     extra={"VSE_PRECOMMIT_RANGE": file_range})
    ctx.output = ctx.result.stdout + ctx.result.stderr
