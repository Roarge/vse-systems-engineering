---
title: "SySiDE Model Modification and Element Reference"
slug: syside-model-modification
type: reference
layer: syside
tags: [syside, automator, model-modification, element-types, pretty-print]
sources:
  - citation: "Sensmetry. SySiDE Automator Python API: textual notation and JSON. https://docs.sensmetry.com/python/latest/textual.html, https://docs.sensmetry.com/python/latest/json.html (accessed 2026-04)."
    raw: sensmetry_docs_2026-04
related:
  - syside-core-api
  - syside-expression-evaluation
  - syside-vse-workflows
  - sysml2-syntax-packages-and-definitions
  - sysml2-canonical-model-layout
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling, sysml2-metadata]
---

# SySiDE Model Modification and Element Reference

## Adding elements

```python
# Add a new package to a namespace
mem, new_pkg = namespace.children.append(
    syside.OwningMembership, syside.Package
)

# Add a reference (non-owning membership)
_, _ = namespace.children.append(syside.Membership, existing_element)
```

The two-tuple return is `(membership, child)`. The membership
captures the relationship (owning versus non-owning), the child
captures the new element itself.

## Removing elements

```python
namespace.children.remove_element(element)
```

Removal cascades through owning memberships only. Non-owning
references must be cleaned up explicitly.

## Creating documents in memory

```python
# Create a new SysML document in memory
doc = syside.Document.create_st(url="memory://generated.sysml")
with doc.lock() as locked:
    # Add elements to the document
    mem, pkg = locked.root_node.children.append(
        syside.OwningMembership, syside.Package
    )
```

In-memory documents are the right surface for scripts that
generate model fragments from external data (Excel imports,
sensor catalogues) before merging them into the canonical model
on disk.

## Exporting to text

```python
# Pretty-print an element to SysML textual notation
text = syside.pprint(element)

# With custom formatting
options = syside.FormatOptions()
printer = syside.ModelPrinter.sysml(format=options)
text = syside.pprint(element, printer=printer)
```

The pretty-printer respects the format settings declared in
`syside.toml` so that generated text round-trips through
`syside format` without diff churn.

## Debugging model structure

```python
# S-expression representation
print(syside.sexp(element, print_references=True))
```

The S-expression form is read by `syside check` diagnostics and
is the most compact textual form for debugging walker or
filter scripts.

## Constraints

- An element can have only one owner (multiple references are
  allowed).
- Moving elements between documents raises `ValueError`.
- Adding elements that violate type constraints raises
  `TypeError`.

## Element types quick reference

### Definitions (type declarations)

`PartDefinition`, `RequirementDefinition`,
`VerificationCaseDefinition`, `ActionDefinition`,
`StateDefinition`, `PortDefinition`, `InterfaceDefinition`,
`UseCaseDefinition`, `EnumerationDefinition`, `ViewDefinition`,
`AttributeDefinition`, `ConnectionDefinition`,
`ConstraintDefinition`, `CalculationDefinition`,
`AllocationDefinition`, `AnalysisCaseDefinition`,
`FlowDefinition`, `ItemDefinition`, `RenderingDefinition`,
`ViewpointDefinition`, `DataType`, `Structure`

### Usages (instances)

`PartUsage`, `RequirementUsage`, `VerificationCaseUsage`,
`ActionUsage`, `StateUsage`, `PortUsage`, `AttributeUsage`,
`ConnectionUsage`, `FlowUsage`, `TransitionUsage`, `ItemUsage`,
`ReferenceUsage`, `ConstraintUsage`, `AllocationUsage`,
`AnalysisCaseUsage`, `CalculationUsage`, `CaseUsage`,
`InterfaceUsage`, `PerformActionUsage`, `RenderingUsage`,
`SendActionUsage`, `UseCaseUsage`, `ViewUsage`

The sysml2-syntax-packages-and-definitions page describes the
language-level distinction between a `*Definition` and a
`*Usage` and how the Automator API mirrors it.

### Relationships

`Redefinition`, `Subsetting`, `ReferenceSubsetting`,
`Specialization`, `Conjugation`, `Dependency`,
`OwningMembership`, `Membership`, `FeatureTyping`,
`FeatureChaining`, `Binding`, `Succession`, `Association`,
`Differencing`, `Disjoining`, `Intersecting`, `Unioning`

### Support types

`Documentation`, `Element`, `Namespace`, `Type`, `Classifier`,
`Feature`, `Relationship`, `AstNode`, `Package`

### Document tiers

- `DocumentTier.Project`: user-defined elements
- `DocumentTier.StandardLibrary`: built-in SysML/KerML elements
- `DocumentTier.External`: third-party library elements

The model-tier separation in `sysml2-canonical-model-layout` and
`vse-model-tiers-and-templates` is enforced at this API level:
filtering by `document_tier` is the canonical way to walk only
the project's own elements.
