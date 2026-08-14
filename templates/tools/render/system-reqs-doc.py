#!/usr/bin/env python3
"""Render the System Requirements Specification from the model.

Writes docs/generated/system-requirements.md. Takes no arguments and runs
from the project root, which is the contract the post-merge git hook and
the Contract 3 freshness check in CI both rely on (see
methodology/iso-29110-hooks-guide.md sections 4.4 and 4.5).

The source is the system story register, that is every
`requirement def <ID> :> UserStory` under `stories/system/`, per the
methodology section 9.5 artefact mapping. System stories carry the
`require constraint` clauses that formalise the sharpened benefit and
feed the section 6 trade studies.
"""

import os
import sys

# The renderer runs once per merge, so a bytecode cache buys nothing and
# would leave an untracked __pycache__ directory in the project tree.
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import sysml_model  # noqa: E402  (path set above so the module resolves)

SCRIPT = "system-reqs-doc.py"
OUTPUT = "docs/generated/system-requirements.md"
EMPTY = "none"


def field_line(label, value):
    return f"- **{label}:** {value if value else EMPTY}"


def acceptance_lines(story):
    """Render the acceptance criteria as an ordered list.

    A criterion that runs to several paragraphs forces a blank line
    between every item, because a tight list and an indented continuation
    paragraph do not read as one list in Markdown.
    """
    lines = []
    if not story.acceptances:
        lines.append(
            "No acceptance criterion is declared. The story is not yet "
            "well-formed under methodology section 1.9."
        )
        return lines
    loose = any(
        len(acceptance.doc.paragraphs) > 1 for acceptance in story.acceptances
    )
    for position, acceptance in enumerate(story.acceptances, start=1):
        if loose and position > 1:
            lines.append("")
        paragraphs = acceptance.doc.paragraphs
        if not paragraphs:
            lines.append(f"{position}. (no criterion text recorded)")
            continue
        lines.append(f"{position}. {paragraphs[0]}")
        for extra in paragraphs[1:]:
            lines.append("")
            lines.append(f"   {extra}")
    return lines


def story_section(story):
    lines = [f"## {story.identifier}", ""]
    lines.append(field_line("Stakeholder role", story.role))
    lines.append(field_line("Capability", story.capability))
    lines.append(field_line("Benefit", story.benefit))
    lines.append(field_line("Framed concerns", ", ".join(story.concerns)))
    lines.append(
        field_line("Required constraints", ", ".join(story.constraint_names))
    )
    lines.append("")
    lines.append("**Acceptance criteria**")
    lines.append("")
    lines.extend(acceptance_lines(story))
    lines.append("")
    return lines


def render(model):
    stories = model.stories_of_kind("system")
    lines = [sysml_model.header(SCRIPT), ""]
    lines.append("# System Requirements Specification")
    lines.append("")
    lines.append(
        "This specification is rendered from the system story register in "
        f"the SysML 2.0 model under `{model.model_root}/` by "
        f"`tools/render/{SCRIPT}`. Edit the model, then regenerate. "
        "Editing this file directly is lost work, because the next merge "
        "on `main` overwrites it."
    )
    lines.append("")
    lines.append(
        "Each section below is one system story, that is one "
        "`requirement def` specialising `UserStory` and derived from a "
        "stakeholder story under methodology section 5.4.1. The required "
        "constraints are the `require constraint` clauses that formalise "
        "the sharpened benefit under section 5.4.2, and they are the "
        "criteria a section 6 trade study scores against. The derivation "
        "itself is tabulated in the Traceability Matrix."
    )
    lines.append("")
    if not stories:
        lines.append("No system story is declared in the model.")
        return OUTPUT, "\n".join(lines)
    for story in stories:
        lines.extend(story_section(story))
    while lines and not lines[-1]:
        lines.pop()
    return OUTPUT, "\n".join(lines)


if __name__ == "__main__":
    sys.exit(sysml_model.run(render))
