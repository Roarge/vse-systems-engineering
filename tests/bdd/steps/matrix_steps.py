r"""Step definitions for tests/features/traceability-matrix.feature.

The scenarios build their project with the helpers of lint_steps and
render_steps: the shipped tools/lint/ and tools/render/ directories
under tools/, the story file the Given step names, copied from
tests/fixtures/lint/scenarios/, and a validation case written by the
step that names its verify target. A system story derived from the
stakeholder story is copied from the same directory into the system
stories directory, and a verification case is written by the step that
names its verify target, beside the validation cases.

The When step runs the traceability matrix renderer as a subprocess
from the project root, the way the post-merge hook and CI run it, and
keeps the document it writes. The Then steps read the Status cell of
the story's row and the bullet lines under the Gaps heading.
"""

import os
import subprocess
import sys

from lint_steps import copy_piece, project
from steps import step

MATRIX = os.path.join("docs", "generated", "traceability-matrix.md")
SYSTEM_STORIES = os.path.join("model", "core", "stories", "system",
                              "stories.sysml")
VERIFICATION_CASES = os.path.join("model", "core", "verification-validation",
                                  "verification-cases",
                                  "verification-cases.sysml")


def section(document, heading):
    """The lines under a `## ` heading, up to the next one."""
    lines = document.split("\n")
    start = lines.index("## " + heading) + 1
    end = next((index for index in range(start, len(lines))
                if lines[index].startswith("## ")), len(lines))
    return lines[start:end]


@step(r"a system story (\w+) derived from (\w+) with the acceptance "
      r"criterion (\w+)")
def derived_system_story(ctx, story, original, criterion):
    copy_piece(ctx, "system-story-derived.sysml", SYSTEM_STORIES,
               ["requirement {} : UserStory".format(story),
                "end #original ::> {};".format(original),
                "end #derive   ::> {};".format(story),
                "requirement {} {{".format(criterion)])


@step(r"a verification case that verifies ([\w.]+)")
def verification_case_verifying(ctx, target):
    path = os.path.join(project(ctx), VERIFICATION_CASES)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        handle.write((
            "package ExampleVerificationCases {{\n"
            "    verification def VC_901_Example {{\n"
            "        subject s : ExampleSystem;\n"
            "        objective {{\n"
            "            verify {};\n"
            "        }}\n"
            "    }}\n"
            "}}\n").format(target))


@step(r"the engineer renders the traceability matrix")
def render_matrix(ctx):
    completed = subprocess.run(
        [sys.executable, os.path.join("tools", "render",
                                      "traceability-matrix.py")],
        cwd=project(ctx), stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        universal_newlines=True, check=False)
    if completed.returncode != 0:
        raise AssertionError("the renderer exited {}: {}".format(
            completed.returncode, completed.stderr.strip()))
    with open(os.path.join(project(ctx), MATRIX), encoding="utf-8") as handle:
        ctx.matrix = handle.read()


@step(r"the matrix marks (\w+) as (Complete|Gap)")
def marks_status(ctx, story, status):
    rows = [line for line in section(ctx.matrix, "Matrix")
            if line.startswith("| {} |".format(story))]
    if len(rows) != 1:
        raise AssertionError("expected one row for {}, found {}:\n{}".format(
            story, len(rows), ctx.matrix))
    found = rows[0].strip("| ").split(" | ")[-1]
    if found != status:
        raise AssertionError("{} is marked {}, not {}:\n{}".format(
            story, found, status, ctx.matrix))


@step(r"the matrix lists the criterion (\w+) of (\w+) under Gaps")
def lists_gap(ctx, criterion, story):
    gaps = [line for line in section(ctx.matrix, "Gaps")
            if line.startswith("- ")]
    if not any("`{}`".format(story) in line
               and "`{}`".format(criterion) in line for line in gaps):
        raise AssertionError(
            "no gap names the criterion {} of {}: {}".format(
                criterion, story, gaps))
