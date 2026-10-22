r"""Step definitions for tests/features/story-lint.feature.

Each scenario builds a small project in a temporary directory: the
shipped tools/lint/ and tools/render/ directories, copied from
templates/tools/, and the story and feature files the Given steps name,
copied from tests/fixtures/lint/scenarios/. The When step runs the
story lint there as a subprocess, the way the pre-commit hook and CI
run it, and the Then steps read its JSON output.

A Given step checks that the fixture it copies holds the story
identifier and criterion name the step text names, so a step cannot
pass against a fixture that says something else.
"""

import json
import os
import shutil
import subprocess
import sys
import tempfile

from steps import step

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
TOOLS = os.path.join(REPO, "templates", "tools")
PIECES = os.path.join(REPO, "tests", "fixtures", "lint", "scenarios")
STORIES = os.path.join("model", "core", "stories", "stakeholder")


def project(ctx):
    """The scenario's project directory, created on first use with the
    shipped lint and renderers under tools/."""
    if getattr(ctx, "project", None) is None:
        ctx.project = tempfile.mkdtemp(prefix="vse-story-lint-")
        ctx.cleanup(lambda: shutil.rmtree(ctx.project, ignore_errors=True))
        for name in ("lint", "render"):
            shutil.copytree(os.path.join(TOOLS, name),
                            os.path.join(ctx.project, "tools", name),
                            ignore=shutil.ignore_patterns("__pycache__"))
    return ctx.project


def copy_piece(ctx, piece, target, must_hold):
    """Copy a fixture piece to `target` under the project, after checking
    that it holds every string in `must_hold`."""
    source = os.path.join(PIECES, piece)
    with open(source, encoding="utf-8") as handle:
        text = handle.read()
    for needle in must_hold:
        if needle not in text:
            raise AssertionError("fixture {} does not hold {!r}".format(
                source, needle))
    path = os.path.join(project(ctx), target)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    shutil.copyfile(source, path)


def story_file(ctx, piece, story, *more):
    copy_piece(ctx, piece, os.path.join(STORIES, "stories.sysml"),
               ["requirement {} : UserStory".format(story)] + list(more))


def feature_file(ctx, piece, story, *more):
    copy_piece(ctx, piece, os.path.join(STORIES, story + ".feature"),
               ["@" + story] + list(more))


@step(r"a story file (\w+) without a feature file")
def story_without_feature(ctx, story):
    story_file(ctx, "story-criterion.sysml", story)
    feature = os.path.join(project(ctx), STORIES, story + ".feature")
    if os.path.exists(feature):
        os.remove(feature)


@step(r"a story file (\w+) with the acceptance criterion (\w+)")
def story_with_criterion(ctx, story, criterion):
    story_file(ctx, "story-criterion.sysml", story,
               "requirement {} {{".format(criterion))


@step(r"a story file (\w+) with the acceptance criterion (\w+) and no status")
def story_with_criterion_without_status(ctx, story, criterion):
    copy_piece(ctx, "story-no-status.sysml",
               os.path.join(STORIES, "stories.sysml"),
               ["requirement {} : UserStory".format(story),
                "requirement {} {{".format(criterion)])
    with open(os.path.join(project(ctx), STORIES, "stories.sysml"),
              encoding="utf-8") as handle:
        if "status =" in handle.read():
            raise AssertionError("story-no-status.sysml declares a status")


@step(r"a story file (\w+) whose acceptance is legacy prose")
def story_with_legacy_prose(ctx, story):
    story_file(ctx, "story-legacy.sysml", story,
               "requirement :>> acceptance {\n            doc /*")


@step(r"a feature file for (\w+)")
def feature_for(ctx, story):
    feature_file(ctx, "feature-no-scenarios.feature", story)


@step(r"an empty feature file for (\w+)")
def empty_feature(ctx, story):
    path = os.path.join(project(ctx), STORIES, story + ".feature")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8"):
        pass


@step(r"a feature file for (\w+) with no scenarios")
def feature_without_scenarios(ctx, story):
    feature_file(ctx, "feature-no-scenarios.feature", story)


@step(r"a feature file for (\w+) with a scenario tagged @AC_(\w+)")
def feature_with_scenario(ctx, story, criterion):
    feature_file(ctx, "feature-tagged.feature", story,
                 "@AC_{}\n  Scenario:".format(criterion))


@step(r"the engineer runs the story lint")
def run_story_lint(ctx):
    completed = subprocess.run(
        [sys.executable, os.path.join("tools", "lint", "story-wellformed.py"),
         "--format", "json", "model"],
        cwd=project(ctx), stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        universal_newlines=True, check=False)
    if completed.returncode not in (0, 1):
        raise AssertionError("the lint exited {}: {}".format(
            completed.returncode, completed.stderr.strip()))
    ctx.exit_code = completed.returncode
    ctx.findings = json.loads(completed.stdout)


@step(r"the lint reports finding (\w+) for (\w+)")
def reports_finding(ctx, code, story):
    if ctx.exit_code != 1 or not any(
            finding["code"] == code and story in finding["message"]
            for finding in ctx.findings):
        raise AssertionError("no {} finding for {} (exit {}): {}".format(
            code, story, ctx.exit_code, ctx.findings))


@step(r"the lint reports no findings")
def reports_nothing(ctx):
    if ctx.exit_code != 0 or ctx.findings:
        raise AssertionError("expected no findings, exit {}: {}".format(
            ctx.exit_code, ctx.findings))
