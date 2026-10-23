r"""Step definitions for the commit-time scenarios.

They cover the commit-time Rule of profile-gates.feature, the
scenarios of ci-range.feature, commit-scope.feature and
traceability-gate.feature, and the commit-time scenario of
test-first.feature. Each scenario builds a git
repository with the project-side hooks installed (world.py), commits
the way an engineer does, with the hooks running, and reads what git
and the hooks said.

The story Given steps are the ones story-lint.feature uses, defined in
lint_steps.py. world.py builds its repository in the same project
directory, so the story those steps write is the story committed here.
"""

import os
import re
import shlex
import shutil
import stat
import tempfile

import world
from lint_steps import (STORIES, copy_piece, feature_file, project,
                        story_without_feature)
from steps import step

PROFILES = r"(light|standard|full)"
DISPOSITIONS = r"(block|warn|info|off)"


def _shows_code(output, code):
    """True when `output` names the finding `code` as a whole word."""
    return re.search(r"\b{}\b".format(re.escape(code)), output) is not None


def _context(ctx):
    return "exit {}:\n{}".format(ctx.result.returncode, ctx.output)


REGISTER = os.path.join(STORIES, "stories.sysml")


def _change_story(ctx, story, register=REGISTER):
    """Alter the block of `story` in the register, and no other block:
    its points value changes."""
    path = os.path.join(project(ctx), register)
    with open(path, encoding="utf-8") as handle:
        text = handle.read()
    start = text.find("requirement {} : UserStory".format(story))
    points = text.find("points = ", start)
    if start < 0 or points < 0:
        raise AssertionError("{} holds no story {} with points".format(
            register, story))
    end = text.find(";", points)
    text = text[:points] + "points = 8" + text[end:]
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(text)


# ----------------------------------------------------------------- Given


@step(r"a VSE project at the {} profile".format(PROFILES))
def project_at_profile(ctx, profile):
    world.repo(ctx)
    ctx.profile = profile
    world.write_config(ctx)


@step(r"the gate (\w+) is overridden to {}".format(DISPOSITIONS))
def gate_overridden(ctx, gate, disposition):
    world.repo(ctx)
    ctx.overrides.append((gate, disposition))
    world.write_config(ctx)


@step(r"test first applies to code under ([\w./-]+)/ with tests under ([\w./-]+)/")
def test_first_applies(ctx, code_dir, test_dir):
    world.repo(ctx)
    ctx.test_dir = test_dir
    ctx.test_first = [
        "test_first:",
        "  applies: true",
        '  rationale: "A test suite runs the code under {}/."'.format(code_dir),
        '  test_command: "make test"',
        "  code_paths: [{}/*]".format(code_dir),
        "  test_paths: [{}/*]".format(test_dir),
    ]
    world.write_config(ctx)


@step(r"test first is not recorded")
def test_first_not_recorded(ctx):
    world.repo(ctx)
    ctx.test_first = []
    world.write_config(ctx)


@step(r"no test file has changed")
def no_test_change(ctx):
    test_dir = getattr(ctx, "test_dir", "tests")
    changed = world.git(ctx, "status", "--porcelain=v1", "-uall", "--",
                        test_dir)
    if changed.strip():
        raise AssertionError("test files have changed:\n" + changed)


@step(r"the project holds no code and no test tooling")
def no_code_or_tooling(ctx):
    # The shipped detector decides what counts as test tooling, so the
    # step asks it rather than keeping a list of its own.
    detected = world.run(ctx, [
        "bash", "-c",
        ". .githooks/lib/iso-profile.sh && . .githooks/lib/test-first.sh "
        "&& vse_tf_detect ."])
    if detected.returncode != 1 or detected.stdout.strip():
        raise AssertionError("test tooling detected (exit {}): {}{}".format(
            detected.returncode, detected.stdout, detected.stderr))
    # Beyond the scaffold (hooks, tools, configuration) the project
    # holds no file at all, so it holds no code.
    files = world.git(ctx, "ls-files", "--cached", "--others").splitlines()
    extra = [path for path in files
             if not any(path == part or path.startswith(part + "/")
                        for part in world.SCAFFOLD)]
    if extra:
        raise AssertionError("the project holds files: {}".format(extra))


@step(r"a committed story file holding (\w+) with its feature file and (\w+) "
      r"whose acceptance is legacy prose")
def committed_register(ctx, migrated, legacy):
    # The register is committed with the hooks bypassed, as a project
    # upgraded from 4.x holds it before its first commit under 5.0.0.
    world.start(ctx)
    copy_piece(ctx, "register-migrated-and-legacy.sysml", REGISTER,
               ["requirement {} : UserStory".format(migrated),
                "requirement {} : UserStory".format(legacy),
                "requirement :>> acceptance {\n            doc /*"])
    feature_file(ctx, "feature-tagged.feature", migrated)
    world.commit_unchecked(ctx, "feat: add the register", "model")


@step(r"the committed feature file of (\w+) holds a step line that does "
      r"not parse")
def committed_unparsed_feature(ctx, story):
    # The line is committed with the hooks bypassed, as a feature file
    # that reached the branch before its gate blocked would hold it.
    path = os.path.join(STORIES, story + ".feature")
    with open(os.path.join(project(ctx), path), "a",
              encoding="utf-8") as handle:
        handle.write("    Banana y\n")
    world.commit_unchecked(ctx, "test: break the feature file of " + story,
                           path)


@step(r"a branch whose commits change only the story (\w+)")
def branch_changes_story(ctx, story):
    world.git(ctx, "checkout", "-q", "-b", "feature/" + story)
    _change_story(ctx, story)
    world.commit_unchecked(ctx, "feat: change {}".format(story), "model")
    ctx.branch = "feature/" + story


@step(r"a branch whose commits add a story file (\w+) without a feature file")
def branch_adds_story(ctx, story):
    world.start(ctx)
    world.git(ctx, "checkout", "-q", "-b", "feature/" + story)
    story_without_feature(ctx, story)
    world.commit_unchecked(ctx, "feat: add {}".format(story), "model")
    ctx.branch = "feature/" + story


@step(r"a branch (\S+) whose commits add the test file (\S+)")
def branch_adds_test(ctx, branch, path):
    world.start(ctx)
    world.git(ctx, "checkout", "-q", "-b", branch)
    world.write(ctx, path, "def test_reading():\n    assert True\n")
    world.commit_unchecked(ctx, "test: add {}".format(path), path)
    ctx.branch = branch


@step(r"a later push to the branch that adds only the code file (\S+)")
def later_push_adds_code(ctx, path):
    # The push runs from the branch tip the earlier push left to the
    # commit that adds the code, as GitHub's before and after name it.
    ctx.push_before = world.head(ctx)
    world.write(ctx, path, "def reading():\n    return 0\n")
    world.commit_unchecked(ctx, "feat: add {}".format(path), path)
    ctx.push_after = world.head(ctx)


@step(r"a fresh checkout of the branch with nothing staged")
def fresh_checkout(ctx):
    ctx.checkout = world.checkout(ctx, ctx.branch)


@step(r"a commit that adds a story file (\w+) without a feature file")
def commit_adds_story(ctx, story):
    world.start(ctx)
    story_without_feature(ctx, story)
    world.commit_unchecked(ctx, "feat: add {}".format(story), "model")


@step(r"a later commit tagged (\S+) that changes only (\S+)")
def tagged_commit(ctx, tag, path):
    world.write(ctx, path, "# Release {}\n".format(tag))
    world.commit_unchecked(ctx, "docs: prepare {}".format(tag), path)
    world.git(ctx, "tag", tag)


# The reads of the traceability gate a scenario can make fail. Each
# names the tool that makes the read and a shell test that holds for
# the gate's call alone. The name read is the only grep -oE. The gate
# picks the model files with a lone '\.sysml$' (the SysML lint's call
# adds -E). The awk that reads the staged diff runs the only program
# whose function feed takes one argument. The diff itself comes from
# git, which no stub can stand in for here, because git puts its own
# directory of programs, which holds a git, first on the PATH of the
# hooks it runs.
FAILING_READS = {
    "reads the requirement names":
        ("grep", "case \" $* \" in *\" -oE \"*) true ;; *) false ;; esac"),
    "picks the model files out of the changed files":
        ("grep", "[ \"$#\" -eq 1 ] && [ \"$1\" = '\\.sysml$' ]"),
    "reads the staged change":
        ("awk", "case \"$*\" in *\"function feed(tok)\"*) true ;; *) false ;; esac"),
}


@step(r"(grep|awk) fails with status (\d+) when the gate ({})".format(
    "|".join(re.escape(read) for read in FAILING_READS)))
def tool_fails(ctx, tool, status, read):
    expected, test = FAILING_READS[read]
    if tool != expected:
        raise AssertionError("the gate {} with {}, not {}".format(
            read, expected, tool))
    real = shutil.which(tool)
    if real is None:
        raise AssertionError("{} is not on PATH".format(tool))
    if getattr(ctx, "stub_dir", None) is None:
        ctx.stub_dir = tempfile.mkdtemp(prefix="vse-world-stubs-")
        ctx.cleanup(lambda: shutil.rmtree(ctx.stub_dir, ignore_errors=True))
    path = os.path.join(ctx.stub_dir, tool)
    with open(path, "w", encoding="utf-8") as handle:
        handle.write("#!/bin/sh\n"
                     "if {}; then\n"
                     "    echo '{}: the read failed (a scenario stub)' >&2\n"
                     "    exit {}\n"
                     "fi\n"
                     "exec {} \"$@\"\n".format(test, tool, int(status),
                                               shlex.quote(real)))
    os.chmod(path, os.stat(path).st_mode | stat.S_IXUSR | stat.S_IXGRP
             | stat.S_IXOTH)


# ------------------------------------------------------------------ When


@step(r"the engineer commits the story")
def commit_story(ctx):
    world.start(ctx)
    world.commit(ctx, "feat: add the story", "model")


@step(r"the engineer commits a change to (\S+)")
def commit_change(ctx, path):
    world.start(ctx)
    world.write(ctx, path, "# A change to {}\n".format(path))
    world.commit(ctx, "feat: change {}".format(path), path)


@step(r"the engineer commits a change to the story (\w+) only")
def commit_story_change(ctx, story):
    _change_story(ctx, story)
    world.commit(ctx, "feat: change {}".format(story), "model")


@step(r"the engineer renames the story file to (\S+) and changes the story "
      r"(\w+)")
def commit_renamed_register(ctx, name, story):
    # git mv stages the rename, and the change to the one story is
    # staged with it, so git pairs the two names as a rename.
    target = os.path.join(STORIES, name)
    world.git(ctx, "mv", REGISTER, target)
    _change_story(ctx, story, target)
    world.commit(ctx, "refactor: rename the register", "model")


@step(r"the engineer moves the story file alone to the stories directory "
      r"(\w+)")
def commit_moved_register(ctx, name):
    # The feature files stay in the old directory, which still holds
    # them, so the moved stories are parted from their feature files.
    target = os.path.join(os.path.dirname(STORIES), name)
    os.makedirs(os.path.join(project(ctx), target), exist_ok=True)
    world.git(ctx, "mv", REGISTER, os.path.join(target, "stories.sysml"))
    world.commit(ctx, "refactor: move the register", "model")


@step(r"the engineer commits a new feature file for (\w+) only")
def commit_new_feature(ctx, story):
    # The narrative lines repeat the role, capability and benefit of
    # US_902_Legacy in register-migrated-and-legacy.sysml.
    path = os.path.join(STORIES, story + ".feature")
    world.write(ctx, path, (
        "@{}\n"
        "Feature: See the battery level\n"
        "  As an operator\n"
        "  I want to see the battery level\n"
        "  So that the battery is replaced in time\n"
        "\n"
        "  @AC_lowBatteryWarned\n"
        "  Scenario: A low battery is warned of\n"
        "    Given a low battery\n"
        "    When the operator looks at the display\n"
        "    Then a warning is shown\n").format(story))
    world.commit(ctx, "feat: describe {}".format(story), path)


@step(r"CI checks the range from main to the branch head")
def ci_checks_range(ctx):
    world.ci_check(ctx, ctx.checkout, "origin/main...HEAD")


@step(r"CI checks the later push")
def ci_checks_push(ctx):
    # A push to a branch: the checkout holds the branch, and the range
    # runs from the previous tip to the new one (before..after).
    world.ci_check(ctx, ctx.checkout,
                   "{}..{}".format(ctx.push_before, ctx.push_after))


@step(r"CI checks the push of the tag (\S+)")
def ci_checks_tag(ctx, tag):
    # A tag has no earlier commit to compare with, so CI checks every
    # tracked file (full-tree mode).
    world.ci_check(ctx, world.checkout(ctx, tag), "all")


# ------------------------------------------------------------------ Then


@step(r"the commit is refused with finding (\w+)")
def refused_with_finding(ctx, code):
    if ctx.result.returncode == 0 or ctx.landed:
        raise AssertionError("the commit was not refused, " + _context(ctx))
    if not _shows_code(ctx.output, code):
        raise AssertionError("no finding {}, {}".format(code, _context(ctx)))


@step(r"the commit is refused with finding (\w+) for (\w+)")
def refused_with_finding_for(ctx, code, story):
    refused_with_finding(ctx, code)
    if not re.search(r"\b{} {}\b".format(re.escape(code), re.escape(story)),
                     ctx.output):
        raise AssertionError("no finding {} for {}, {}".format(
            code, story, _context(ctx)))


@step(r"the commit is refused by the gate (\w+)")
def refused_by_gate(ctx, gate):
    if ctx.result.returncode == 0 or ctx.landed:
        raise AssertionError("the commit was not refused, " + _context(ctx))
    if gate not in ctx.output:
        raise AssertionError("the gate {} is not named, {}".format(
            gate, _context(ctx)))


@step(r"the commit is refused")
def refused(ctx):
    if ctx.result.returncode == 0 or ctx.landed:
        raise AssertionError("the commit was not refused, " + _context(ctx))


@step(r"the commit goes through")
def commit_goes_through(ctx):
    if ctx.result.returncode != 0 or not ctx.landed:
        raise AssertionError("the commit did not land, " + _context(ctx))


@step(r"the engineer is warned of finding (\w+)")
def warned_of_finding(ctx, code):
    if "warning:" not in ctx.output or not _shows_code(ctx.output, code):
        raise AssertionError("no warning of {}, {}".format(
            code, _context(ctx)))


@step(r"the engineer is told to record test first with (/[\w-]+)")
def told_to_record(ctx, command):
    if command not in ctx.output:
        raise AssertionError("{} is not suggested, {}".format(
            command, _context(ctx)))


@step(r"the engineer is told that (\w+) still needs migrating")
def told_still_needs_migrating(ctx, story):
    lines = [line for line in ctx.output.splitlines()
             if re.search(r"\b{}\b".format(re.escape(story)), line)
             and "migrat" in line]
    if not lines:
        raise AssertionError("no line names {} as still to migrate, {}"
                             .format(story, _context(ctx)))


@step(r"the engineer is told that (\w+) has no verification case")
def told_no_verification_case(ctx, name):
    if "requirement '{}' has no verification case".format(name) \
            not in ctx.output:
        raise AssertionError("{} is not named as unverified, {}".format(
            name, _context(ctx)))


@step(r"the engineer is told that (\w+) exited with status (\d+) while "
      r"reading (the story file|the list of changed files)")
def told_tool_failed(ctx, tool, status, what):
    if what == "the story file":
        what = REGISTER
    expected = "{} exited with status {} while reading {}".format(
        tool, status, what)
    if expected not in ctx.output:
        raise AssertionError("no line says that {}, {}".format(
            expected, _context(ctx)))


@step(r"the check fails with finding (\w+)")
def check_fails(ctx, code):
    if ctx.result.returncode == 0:
        raise AssertionError("the check passed, " + _context(ctx))
    if not _shows_code(ctx.output, code):
        raise AssertionError("no finding {}, {}".format(code, _context(ctx)))


@step(r"the check passes")
def check_passes(ctx):
    if ctx.result.returncode != 0:
        raise AssertionError("the check failed, " + _context(ctx))
    # The test-first gate must have run and reported nothing. A gate
    # the scenario turns off, or one that reports it could not check
    # (a partial install at a disposition that lets the change through),
    # would otherwise pass here unseen.
    if dict(ctx.overrides).get("precommit_test_first") == "off":
        raise AssertionError("precommit_test_first is off in this "
                             "scenario, so it did not run")
    if "precommit_test_first" in ctx.output:
        raise AssertionError("precommit_test_first reported, "
                             + _context(ctx))
    if not re.search(r"^\[pre-commit\] (All checks passed\.|Checks complete)",
                     ctx.output, re.MULTILINE):
        raise AssertionError("the hook did not reach its summary, "
                             + _context(ctx))
