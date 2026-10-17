r"""Step definitions for tests/features/renderer-scenarios.feature.

The scenarios build their project with the helpers of lint_steps: the
shipped tools/lint/ and tools/render/ directories under tools/, and the
story and feature files the Given steps name, copied from
tests/fixtures/lint/scenarios/. The step "a story file ... with the
acceptance criterion ..." is defined there, and "no feature file for
..." in session_steps.py. Both write into the same project directory,
so one step text means one thing in every scenario.

The When step runs the stakeholder renderer as a subprocess from the
project root, the way the post-merge hook and CI run it, and keeps the
document it writes. The Then steps derive what they expect from the
fixture files themselves, not from the renderer's own model reader, so
a reader fault cannot hide behind an expectation built by the same
code.
"""

import os
import re
import subprocess
import sys
import textwrap

from lint_steps import PIECES, STORIES, copy_piece, feature_file, project
from steps import step

STORY_PIECE = "story-two-criteria.sysml"
FEATURE_PIECE = "feature-two-scenarios.feature"
DOCUMENT = os.path.join("docs", "generated", "stakeholder-requirements.md")

# A fenced block: an opening line of three or more backticks followed by
# its language, then the body, then a closing line of the same backticks.
# The block may sit indented inside a list item.
_RE_FENCE = re.compile(
    r"^(?P<indent>[ ]*)(?P<fence>`{3,})(?P<info>[^`\n]*)\n"
    r"(?P<body>.*?)\n(?P=indent)(?P=fence)[ ]*$",
    re.MULTILINE | re.DOTALL)


def fenced_blocks(document, language):
    """The bodies of the fenced blocks of `language`, with the indent of
    their fence removed."""
    blocks = []
    for match in _RE_FENCE.finditer(document):
        if match.group("info").strip() != language:
            continue
        indent = match.group("indent")
        lines = [line[len(indent):] if line.startswith(indent) else line
                 for line in match.group("body").split("\n")]
        blocks.append("\n".join(lines))
    return blocks


def fixture_scenario(tag):
    """The lines of the fixture feature from the line holding `tag` to
    the next blank line, dedented. The fixture separates its scenarios
    with one blank line, so this is the tagged scenario as written."""
    with open(os.path.join(PIECES, FEATURE_PIECE), encoding="utf-8") as handle:
        text = handle.read()
    lines = text.split("\n")
    for index, line in enumerate(lines):
        if line.strip() == tag:
            end = index
            while end < len(lines) and lines[end].strip():
                end += 1
            return textwrap.dedent("\n".join(lines[index:end]))
    raise AssertionError("fixture {} has no line {!r}".format(
        FEATURE_PIECE, tag))


@step(r"a story file (\w+) with the acceptance criteria (\w+) and (\w+)")
def story_with_two_criteria(ctx, story, first, second):
    copy_piece(ctx, STORY_PIECE, os.path.join(STORIES, "stories.sysml"),
               ["requirement {} : UserStory".format(story),
                "requirement {} {{".format(first),
                "requirement {} {{".format(second)])


@step(r"a feature file for (\w+) with scenarios tagged @AC_(\w+) and @AC_(\w+)")
def feature_with_two_scenarios(ctx, story, first, second):
    feature_file(ctx, FEATURE_PIECE, story,
                 "@AC_{}\n  Scenario:".format(first),
                 "@AC_{}\n  Scenario:".format(second))


@step(r"the engineer renders the stakeholder requirements document")
def render_stakeholder_document(ctx):
    completed = subprocess.run(
        [sys.executable, os.path.join("tools", "render",
                                      "stakeholder-reqs-doc.py")],
        cwd=project(ctx), stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        universal_newlines=True, check=False)
    if completed.returncode != 0:
        raise AssertionError("the renderer exited {}: {}".format(
            completed.returncode, completed.stderr.strip()))
    with open(os.path.join(project(ctx), DOCUMENT), encoding="utf-8") as handle:
        ctx.document = handle.read()


@step(r"the document shows the scenario tagged (@AC_\w+) in a fenced gherkin block")
def shows_scenario_block(ctx, tag):
    expected = fixture_scenario(tag)
    blocks = fenced_blocks(ctx.document, "gherkin")
    if expected not in blocks:
        raise AssertionError(
            "no gherkin block holds the scenario tagged {}:\n{}\n"
            "blocks found: {!r}\ndocument:\n{}".format(
                tag, expected, blocks, ctx.document))


@step(r"the document shows the doc text of the criterion (\w+)")
def shows_doc_text(ctx, criterion):
    with open(os.path.join(project(ctx), STORIES, "stories.sysml"),
              encoding="utf-8") as handle:
        story = handle.read()
    match = re.search(r"requirement {} \{{\s*doc /\*(.*?)\*/".format(
        re.escape(criterion)), story, re.DOTALL)
    if match is None:
        raise AssertionError("the story file has no doc for " + criterion)
    text = " ".join(match.group(1).split())
    if not re.search(r"^\d+\. " + re.escape(text) + "$", ctx.document,
                     re.MULTILINE):
        raise AssertionError("no list item reads {!r}:\n{}".format(
            text, ctx.document))
    if fenced_blocks(ctx.document, "gherkin"):
        raise AssertionError("the document holds a gherkin block:\n"
                             + ctx.document)
