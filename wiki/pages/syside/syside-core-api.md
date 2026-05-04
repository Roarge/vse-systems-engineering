---
title: "SySiDE Automator Core API"
slug: syside-core-api
type: reference
layer: syside
tags: [syside, automator, api, python, model-loading, traversal]
sources:
  - citation: "Sensmetry. SySiDE Automator Python API: model structure. https://docs.sensmetry.com/python/latest/structure.html (accessed 2026-04)."
    raw: sensmetry_docs_2026-04
related:
  - syside-tooling-overview
  - syside-expression-evaluation
  - syside-model-modification
  - syside-vse-workflows
  - sysml2-syntax-packages-and-definitions
  - sysml2-canonical-model-layout
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling, sysml2-metadata]
---

# SySiDE Automator Core API

The Automator is a Python library for programmatic analysis of
SysML 2.0 models. The functions below are the minimum surface a
VSE workflow needs for trace checks, report generation, and
model-driven scripting.

## Loading models

```python
import syside

# Load from files (primary entry point)
model, diagnostics = syside.load_model(paths=["models/system-requirements.sysml"])

# Load multiple files
model, diagnostics = syside.load_model(
    paths=syside.collect_files_recursively("models/")
)

# Load from string (useful for testing)
model, diagnostics = syside.load_model(
    sysml_source='package P { requirement def R1 { doc /* test */ } }'
)

# Tolerant loading (does not raise on errors)
model, diagnostics = syside.try_load_model(paths=["models/draft.sysml"])

# Check for issues
assert not diagnostics.contains_errors(warnings_as_errors=True)
```

The recursive collector matches the canonical project model
directory described in sysml2-canonical-model-layout, so a
typical VSE script can load the entire model with a single line.

## Querying elements

```python
# Iterate all elements of a specific type
for req in model.nodes(syside.RequirementDefinition):
    print(req.declared_name, req.qualified_name)

# Include subtypes
for element in model.elements(syside.Element, include_subtypes=True):
    print(element.name)

# Access user documents only (excludes standard library)
for doc_resource in model.user_docs:
    with doc_resource.lock() as doc:
        # work with doc.root_node
        pass

# Filter by document tier (exclude standard library elements)
for part in model.nodes(syside.PartUsage):
    if part.document.document_tier is syside.DocumentTier.Project:
        print(part.name)
```

The `DocumentTier` enumeration mirrors the model tier separation
described in vse-model-tiers-and-templates: project elements,
standard library elements, and external (third-party) library
elements live in different tiers and are filtered separately
when walking the model.

## Element properties

```python
element.name                # Basic name
element.qualified_name      # Full hierarchy path
element.declared_name       # Explicitly declared name
element.short_name          # SysML v2 short name (between < >)
element.owner               # Parent element
element.document            # Owning document
element.parent              # Parent AST node
```

These properties cover the common access patterns. The
sysml2-syntax-packages-and-definitions page describes how the same
distinctions appear at the language level (definition versus
usage, declared name versus short name).

## Traversing relationships

```python
# Children (owned elements)
for child in element.owned_elements.collect():
    print(child.name)

# Navigate upward
if element.owner is not None:
    print(element.owner.name)

# Features and usages
for usage in element.usages.collect():
    print(type(usage).__name__, usage.name)

# Heritage (specialisation, conjugation)
for rel in element.heritage.relationships:
    if isinstance(rel, syside.Redefinition):
        print("Redefines:", rel.first_target.name)

# Type checking
part_def = element.try_cast(syside.PartDefinition)
if part_def is not None:
    print("Is a PartDefinition")

# Alternative type check
if isinstance(element, syside.ActionUsage.STD):
    print("Is an ActionUsage")
```

## Document locking (thread safety)

Automator scripts that walk multiple documents must take the
document lock to be safe against concurrent edits from the
language server.

```python
# Single document
for doc_resource in model.user_docs:
    with doc_resource.lock() as doc:
        for child in doc.root_node.owned_elements.collect():
            print(child.name)

# Multiple documents
from contextlib import ExitStack
with ExitStack() as stack:
    documents = [stack.enter_context(m.lock()) for m in model.user_docs]
    # work with all documents
```
