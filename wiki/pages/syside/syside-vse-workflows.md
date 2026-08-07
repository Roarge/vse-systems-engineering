---
title: "Syside VSE Workflows and Report Generation"
slug: syside-vse-workflows
type: pattern
layer: syside
summary: Syside workflows for requirement round-trips, grid views, hierarchy walks, trace checks, CI, and reports
tags: [syside, automator, vse, workflows, report-generation, traceability, excel, reqif, ci]
sources:
  - citation: "Sensmetry. Syside Automator Python API: examples and report generation. https://docs.sensmetry.com/examples/index.html, https://docs.sensmetry.com/examples/report_generation.html (accessed 2026-08)."
    raw: null
  - citation: "Sensmetry. Syside CLI reference and Modeler grid views, release 0.10.3. https://docs.sensmetry.com/modeler/cli/ (accessed 2026-08)."
    raw: null
related:
  - syside-core-api
  - syside-expression-evaluation
  - syside-model-modification
  - syside-project-configuration
  - sysml2-syntax-requirements-and-cases
  - sysml2-allocations-overview
  - ambse-dependability-and-traceability
  - vse-model-tiers-and-templates
confidence: high
created: 2026-05-04
updated: 2026-08-07
referenced_by: [sysml2-modelling, sysml2-metadata, project-setup]
---

# Syside VSE Workflows and Report Generation

## Contents

- Validation in CI
- Standard library version
- Interactive mode
- Grid views for tables and matrices
- Extract requirements to Excel
- Import requirements from Excel
- ReqIF round-trip
- Walk part hierarchy
- Check trace links programmatically
- Value rollup with unit conversion
- Extract documentation
- Report generation pipeline
- API reference

## Validation in CI

The `syside check` CLI is the gate a VSE puts in front of every merge.
It loads the files the project's `syside.toml` selects (see
[[syside-project-configuration]]) and reports diagnostics at the
severities that file sets.

```bash
# Fail the build on any diagnostic, not only errors
syside check --warnings-as-errors

# Report run statistics alongside the diagnostics
syside check --warnings-as-errors --stats

# Check formatting without rewriting files
syside format --check
```

`--stats` prints element and diagnostic counts for the run. Log it in
CI, because a sudden change in element count between two commits is
usually a model file that stopped being matched by the inclusion globs
rather than genuine modelling work.

CI needs a Deployment Licence Key (prefix `CI-`) in the provider's
secret store, exposed as `SYSIDE_LICENSE_KEY`.

## Standard library version

Releases from 0.9.0 ship the SysML v2 standard library at the 2026-03
specification release, so a model authored against an older library may
report new diagnostics after an upgrade, usually around quantities and
units. Pin the Syside version, and point `std` in `syside.toml` at a
different library if the project needs one.

## Interactive mode

Launch an interactive Python REPL with a loaded model:

```bash
python -m syside interactive models/system-requirements.sysml
```

The REPL validates the model on load, reporting errors with their
location, then exposes the full Python API through a `model` object.
It accepts single-line and multi-line queries, so an ad hoc question
needs no script.

```python
>>> len(list(model.nodes(syside.RequirementDefinition)))
12
```

Exit with `exit`.

## Grid views for tables and matrices

The Modeler renders editable grid views over the model. A table view
lists elements of a chosen kind with their attributes in columns, and a
matrix view crosses two element sets and shows the relationship at each
intersection, which is the interactive form of the traceability matrix
that [[ambse-dependability-and-traceability]] describes.

Grid views are editable, with the textual model remaining the master
representation. Verify the write-back behaviour for your Syside version
against the release notes before relying on it in a review workflow.

## Extract requirements to Excel

```python
import pandas as pd
import syside

model, diag = syside.load_model(paths=["models/system-requirements.sysml"])
assert not diag.contains_errors(warnings_as_errors=True)

data = []
for req in model.nodes(syside.RequirementDefinition):
    for doc in req.documentation.collect():
        data.append({"ID": req.declared_name, "Requirement": doc.body})
df = pd.DataFrame(data)
df.to_excel("build/requirements.xlsx", index=False)
```

This is the surface the `document-export` skill uses when
generating a stakeholder-facing requirements spreadsheet from
the model.

## Import requirements from Excel

```python
import pandas as pd
import syside

df = pd.read_excel("requirements.xlsx")
doc = syside.Document.create_st(url="memory://imported.sysml")
with doc.lock() as locked:
    mem, pkg = locked.root_node.children.append(
        syside.OwningMembership, syside.Package
    )
    for _, row in df.iterrows():
        mem, req = pkg.children.append(
            syside.OwningMembership, syside.RequirementDefinition
        )
        # Set requirement name, add documentation
print(syside.pprint(locked.root_node))
```

Imports route the new package into the project tier, not the
library tier (see [[vse-model-tiers-and-templates]]).

## ReqIF round-trip

Syside exchanges requirements with requirements-management tools
through ReqIF, the OMG requirements interchange format. Requirements
export from the model to a ReqIF file and import back, so an acquirer
who works in a requirements tool can review and annotate outside the
model without the VSE abandoning SysML v2 as the master.

Treat the model as the master in both directions. Import creates or
updates requirement elements in the project tier, and the reviewer's
edits arrive as an ordinary diff, which keeps the §8 branch and
pull-request workflow in charge of what enters the baseline.

## Walk part hierarchy

```python
import syside

model, _ = syside.load_model(paths=["models/architecture.sysml"])

def walk(element, level=0):
    if element.try_cast(syside.PartUsage):
        print("  " * level, element.name)
    for child in element.owned_elements.collect():
        if child.document.document_tier is syside.DocumentTier.Project:
            walk(child, level + 1)

for doc_res in model.user_docs:
    with doc_res.lock() as doc:
        walk(doc.root_node)
```

The tier filter on `document.document_tier` keeps the walk
inside the project's own model. This is the basis for the
architecture diagram generation that the `document-export`
skill triggers at iteration boundaries.

## Check trace links programmatically

```python
import syside

model, diag = syside.load_model(
    paths=syside.collect_files_recursively("models/")
)

gaps = []
for req in model.nodes(syside.RequirementDefinition):
    # A satisfy link appears as an owned RequirementUsage.
    has_satisfy = any(
        child.try_cast(syside.RequirementUsage) is not None
        for child in req.owned_elements.collect()
    )
    if not has_satisfy:
        gaps.append(f"{req.declared_name}: missing satisfy link")

for gap in gaps:
    print(gap)
```

This pattern is the core of the `traceability-guard` skill.
[[ambse-dependability-and-traceability]] describes the four
trace rules the guard enforces, and
[[sysml2-syntax-requirements-and-cases]] and
[[sysml2-allocations-overview]] describe the SysML 2.0
semantics behind `satisfy` and `verify` links.

## Value rollup with unit conversion

```python
import syside

model, _ = syside.load_model(paths=["models/architecture.sysml"])
STDLIB = syside.Environment.get_default().lib
compiler = syside.Compiler()

for attr in model.nodes(syside.AttributeUsage):
    if attr.name == "TotalMass":
        value, report = compiler.evaluate_feature(
            feature=attr,
            scope=attr.owner,
            stdlib=STDLIB,
            experimental_quantities=True,
        )
        if not report.fatal:
            print(f"Total mass: {value}")
```

Mass and energy budgets are the most common rollup target in a
VSE. The same pattern works for cost estimates and for
performance budgets.

## Extract documentation

```python
import syside

model, _ = syside.load_model(paths=["models/system-requirements.sysml"])

for doc_elem in model.nodes(syside.Documentation):
    if doc_elem.owner and doc_elem.owner.qualified_name:
        about = str(doc_elem.owner.qualified_name)
        print(f"Documentation about {about}: {doc_elem.body}")
```

## Report generation pipeline

For generating professional documents from SysML models, the
Automator supports a Jinja2-based report generation pipeline.

Project structure: `.sysml` model files and Jinja2 templates under
`models/`, the generation script under `scripts/`, styling assets
(`styles.css`, a DOCX reference template, a logo) under `assets/`, and
`versions.json` for revision history under `metadata/`.

Template functions cover element extraction
(`get_children_with_attributes`), tabular layout (`generic_table`),
allocation matrices (`traceability_matrix`), repetition over a data
source (`repeat_for_each_item`), and document furniture (`title`,
`toc`, `page_break`, `revision_history`, `changelog`).

Attribute extraction types name what to pull from each element:
`ElementName`, `Documentation`, `AttributeUsage`, `OwningNamespace`,
and the requirement-specific `Req_Parents`, `Req_Derivations`,
`Req_Implemented`, `Req_Verified`, and `Req_DependencyGraph` (an SVG
derivation tree).

Running the generator:

```bash
python scripts/generate_docs.py --output ./build
python scripts/generate_docs.py --output ./build --update-version
```

Reference: https://docs.sensmetry.com/examples/report_generation.html

## API reference

Full API documentation sits at
https://docs.sensmetry.com/python/latest/index.html, with the model
structure, evaluation, textual-notation, and JSON pages under that
root, and worked examples at
https://docs.sensmetry.com/examples/index.html
