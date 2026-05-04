---
title: "SySiDE VSE Workflows and Report Generation"
slug: syside-vse-workflows
type: pattern
layer: syside
tags: [syside, automator, vse, workflows, report-generation, traceability, excel]
sources:
  - citation: "Sensmetry. SySiDE Automator Python API: examples and report generation. https://docs.sensmetry.com/examples/index.html, https://docs.sensmetry.com/examples/report_generation.html (accessed 2026-04)."
    raw: sensmetry_docs_2026-04
related:
  - syside-core-api
  - syside-expression-evaluation
  - syside-model-modification
  - sysml2-syntax-requirements-and-cases
  - sysml2-allocations-overview
  - ambse-dependability-and-traceability
  - vse-model-tiers-and-templates
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling, sysml2-metadata, project-setup]
---

# SySiDE VSE Workflows and Report Generation

## Interactive mode

Launch an interactive Python REPL with a loaded model:

```bash
python -m syside interactive models/system-requirements.sysml
```

Features:

- Validates the model on load (displays errors with location)
- Full Python API access via the `model` object
- Single-line and multi-line queries
- Quick inspection without creating scripts

```python
>>> len(list(model.nodes(syside.RequirementDefinition)))
12

>>> for req in model.nodes(syside.RequirementDefinition):
...     print(req.declared_name)
...
```

Exit with `exit`.

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
library tier (see vse-model-tiers-and-templates).

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
    has_satisfy = False
    has_verify = False
    for rel in req.owned_elements.collect():
        if isinstance(rel, syside.Subsetting):
            # Check for satisfy/verify relationships
            pass
    # Alternatively, check heritage relationships
    for child in req.owned_elements.collect():
        if child.try_cast(syside.RequirementUsage):
            # This is a satisfy link
            has_satisfy = True
    if not has_satisfy:
        gaps.append(f"{req.declared_name}: missing satisfy link")

for gap in gaps:
    print(gap)
```

This pattern is the core of the `traceability-guard` skill. The
ambse-dependability-and-traceability page describes the four
trace rules the guard enforces, and the
sysml2-syntax-requirements-and-cases and
sysml2-allocations-overview pages describe the SysML 2.0
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

Project structure:

```
project/
  models/
    *.sysml                     # SysML model files
    requirements-spec.md        # Jinja2 template
  scripts/
    generate_docs.py            # Generation script
  assets/
    styles.css                  # PDF/HTML styling
    template.docx               # DOCX reference template
    logo.png                    # Company logo
  metadata/
    versions.json               # Revision history
```

Template functions available:

- `get_children_with_attributes(root_package, metatype, attributes)`:
  extract elements with specified attributes
- `generic_table(columns, rows, flipRowsAndCols, widths)`: format
  data as HTML table
- `traceability_matrix(row_package, col_package)`: build
  allocation matrix with X marks
- `repeat_for_each_item(data_source, sections)`: iterate over
  data, render sections per item
- `title()`, `toc()`, `page_break()`, `revision_history()`,
  `changelog()`

Attribute extraction types:

- `"ElementName"`: element name
- `"Documentation"`: doc blocks (use `""` for unnamed, or named
  like `"Description"`)
- `"AttributeUsage"`: named attribute values
- `"OwningNamespace"`: parent namespace qualified name
- `"Req_Parents"`: parent requirements via derivation
- `"Req_Derivations"`: child requirements via derivation
- `"Req_Implemented"`: allocated components
- `"Req_Verified"`: verification elements
- `"Req_DependencyGraph"`: SVG derivation tree

Running the generator:

```bash
python scripts/generate_docs.py --output ./build
python scripts/generate_docs.py --output ./build --update-version
```

Reference: https://docs.sensmetry.com/examples/report_generation.html

## API reference

Full API documentation:
https://docs.sensmetry.com/python/latest/index.html

Key pages:

- Model structure: https://docs.sensmetry.com/python/latest/structure.html
- Expression evaluation: https://docs.sensmetry.com/python/latest/evaluation.html
- Textual notation: https://docs.sensmetry.com/python/latest/textual.html
- JSON import/export: https://docs.sensmetry.com/python/latest/json.html
- Examples: https://docs.sensmetry.com/examples/index.html
