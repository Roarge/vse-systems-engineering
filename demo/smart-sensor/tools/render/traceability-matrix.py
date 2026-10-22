#!/usr/bin/env python3
"""Render the Traceability Matrix from the SysML 2.0 model.

Writes docs/generated/traceability-matrix.md. Takes no arguments and runs
from the engineering root (the directory holding `.iso-config.yaml`, the
project root in a greenfield layout), which is the contract the post-merge
git hook and the Contract 3 freshness check in CI both rely on (see
methodology/iso-29110-hooks-guide.md sections 4.4 and 4.5).

The matrix is ISO/IEC TR 29110-5-6-2 product description 27. Under this
methodology it is queried from the model rather than authored, per
methodology section 9.8.
"""

import os
import sys

# The renderer runs once per merge, so a bytecode cache buys nothing and
# would leave an untracked __pycache__ directory in the project tree.
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import sysml_model  # noqa: E402  (path set above so the module resolves)

SCRIPT = "traceability-matrix.py"
OUTPUT = "docs/generated/traceability-matrix.md"
EMPTY = "none"

COLUMNS = (
    "Stakeholder Story",
    "System Story",
    "Verification Case",
    "Validation Case",
    "System Element",
    "Status",
)


def cell(values):
    """Render a list of identifiers as one table cell."""
    if not values:
        return EMPTY
    return ", ".join(value.replace("|", "\\|") for value in values)


def verification_cases_for(model, story):
    """Verification cases traced to a stakeholder story, direct or derived.

    A verification case targets a system-side requirement (methodology
    section 5.4.6), so it is usually traced to a stakeholder story through
    the system story derived from it. A case naming the stakeholder story
    directly is recorded as well rather than being discarded. The list
    fills the row's Verification Case cell only. A case on a derived
    system story reaches none of the stakeholder story's own criteria, so
    it does not make the row complete (stakeholder_story_is_covered).
    """
    cases = []
    for case in model.cases_verifying(story.identifier, kind="verification"):
        if case not in cases:
            cases.append(case)
    for derived in model.derived_from(story.identifier):
        for case in model.cases_verifying(derived, kind="verification"):
            if case not in cases:
                cases.append(case)
    return cases


def unreached_criteria(model, story, kind=""):
    """The names of the story's criteria that no case reaches, in
    declaration order, counting only cases of `kind` when one is given.

    A case reaches a criterion under the coverage rule of methodology
    section 11.3.3, the rule the story lint's finding S8 applies, so the
    matrix and the commit gate judge a criterion alike.
    """
    cases = model.cases_of_kind(kind) if kind else model.cases
    return [
        acceptance.label
        for acceptance in story.acceptances
        if not any(case.reaches(story.identifier, acceptance.label)
                   for case in cases)
    ]


def system_story_is_verified(model, story):
    """True when verification cases reach every criterion of the story."""
    if not story.acceptances:
        return False
    return not unreached_criteria(model, story, kind="verification")


def stakeholder_story_is_covered(model, story):
    """True when cases reach every criterion of the story.

    The story is judged on its own criteria, by verification and
    validation cases alike, as the story lint's finding S8 judges it
    before the story may move to inProgress (methodology sections 11.3.3
    and 11.4). A verified system story derived from it does not stand in
    for a criterion that no case reaches. A story with no acceptance
    criterion has nothing to cover and is therefore never complete, per
    section 1.9.
    """
    if not story.acceptances:
        return False
    return not unreached_criteria(model, story)


def matrix_rows(model):
    rows = []
    for story in model.stories_of_kind("stakeholder"):
        derived = model.derived_from(story.identifier)
        verification = [
            case.identifier for case in verification_cases_for(model, story)
        ]
        validation = [
            case.identifier
            for case in model.cases_verifying(story.identifier, kind="validation")
        ]
        elements = list(model.elements_satisfying(story.identifier))
        for derived_story in derived:
            for element in model.elements_satisfying(derived_story):
                if element not in elements:
                    elements.append(element)
        status = (
            "Complete" if stakeholder_story_is_covered(model, story) else "Gap"
        )
        rows.append(
            (
                story.identifier,
                cell(derived),
                cell(verification),
                cell(validation),
                cell(elements),
                status,
            )
        )
    return rows


def gap_findings(model):
    """Every uncovered item, in model declaration order."""
    findings = []
    known = [story.identifier for story in model.stories]

    for story in model.stories_of_kind("stakeholder"):
        if not story.acceptances:
            findings.append(
                f"`{story.identifier}` declares no acceptance criterion, so "
                "no case can cover it (methodology section 1.9)."
            )
        else:
            for label in unreached_criteria(model, story):
                findings.append(
                    f"`{story.identifier}` has no case that reaches its "
                    f"criterion `{label}` (methodology section 11.3.3)."
                )

    for story in model.stories_of_kind("system"):
        if not story.acceptances:
            findings.append(
                f"`{story.identifier}` declares no acceptance criterion, so "
                "no verification case can cover it (methodology section 1.9)."
            )
        elif not system_story_is_verified(model, story):
            for label in unreached_criteria(model, story, kind="verification"):
                findings.append(
                    f"`{story.identifier}` has no verification case that "
                    f"reaches its criterion `{label}` (methodology section "
                    "5.4.6)."
                )
        if not model.originals_of(story.identifier):
            findings.append(
                f"`{story.identifier}` derives from no stakeholder story "
                "(methodology section 5.4.1)."
            )

    for case in model.cases:
        for target in case.targets():
            if target not in known:
                findings.append(
                    f"`{case.identifier}` verifies `{target}`, which is not a "
                    "story declared in the model."
                )

    return findings


def summary_rows(model):
    stakeholder = model.stories_of_kind("stakeholder")
    system = model.stories_of_kind("system")
    covered = [
        story for story in stakeholder if stakeholder_story_is_covered(model, story)
    ]
    verified = [story for story in system if system_story_is_verified(model, story)]
    return [
        ("Model files read", str(len(model.files))),
        ("Stakeholder stories", str(len(stakeholder))),
        ("System stories", str(len(system))),
        ("Derivation connections", str(len(model.derivations))),
        ("Verification cases", str(len(model.cases_of_kind("verification")))),
        ("Validation cases", str(len(model.cases_of_kind("validation")))),
        ("Satisfy relations", str(len(model.satisfactions))),
        (
            "Stakeholder stories with acceptance coverage",
            f"{len(covered)} of {len(stakeholder)}",
        ),
        (
            "System stories with every criterion verified",
            f"{len(verified)} of {len(system)}",
        ),
    ]


def render(model):
    lines = [sysml_model.header(SCRIPT), ""]
    lines.append("# Traceability Matrix")
    lines.append("")
    lines.append(
        "This matrix is queried from the SysML 2.0 model under "
        f"`{model.model_root}/` and rewritten by "
        f"`tools/render/{SCRIPT}`. Edit the model, then regenerate. "
        "Editing this file directly is lost work, because the next merge "
        "on `main` overwrites it."
    )
    lines.append("")
    lines.append(
        "The relations read are `derive` (stakeholder story to system "
        "story, methodology section 5.4.1), `verify` (verification and "
        "validation cases to story acceptance, sections 5.4.6 and 4.3.6), "
        "and `satisfy` (story to system element). A cell reads "
        f"`{EMPTY}` when the model declares no such relation."
    )
    lines.append("")

    lines.append("## Matrix")
    lines.append("")
    lines.append("| " + " | ".join(COLUMNS) + " |")
    lines.append("|" + "---|" * len(COLUMNS))
    rows = matrix_rows(model)
    for row in rows:
        lines.append("| " + " | ".join(row) + " |")
    if not rows:
        lines.append("| " + " | ".join([EMPTY] * len(COLUMNS)) + " |")
    lines.append("")

    lines.append("## Gaps")
    lines.append("")
    lines.append(
        "A stakeholder story is complete when verification or validation "
        "cases reach every one of its acceptance criteria, by the "
        "coverage rule of methodology section 11.3.3, the rule the story "
        "lint applies before a story may move to `inProgress`. A system "
        "story derived from it does not stand in for a criterion that no "
        "case reaches. A system story is verified when verification "
        "cases reach every one of its criteria. A case whose targets are "
        "all nested constraint requirements, such as `<story>.sla`, "
        "verifies those constraints rather than the acceptance criteria, "
        "so it reaches no criterion."
    )
    lines.append("")
    findings = gap_findings(model)
    if findings:
        for finding in findings:
            lines.append(f"- {finding}")
    else:
        lines.append("No gaps detected.")
    lines.append("")

    lines.append("## Coverage summary")
    lines.append("")
    lines.append("| Measure | Count |")
    lines.append("|---|---|")
    for measure, count in summary_rows(model):
        lines.append(f"| {measure} | {count} |")

    return OUTPUT, "\n".join(lines)


if __name__ == "__main__":
    sys.exit(sysml_model.run(render))
