---
title: "SysML 2.0 Reflection: Metaclassification and Meta Operators"
slug: sysml2-reflection-and-classification
type: reference
layer: sysml2
tags: [reflection, metaclassification, meta-operator, m2]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 36, pages 254 to 255."
    raw: sysmlv2.pdf
related:
  - sysml2-metadata-overview
  - sysml2-metadata-definitions
  - sysml2-functions-and-higher-order
  - sysml2-filter-conditions
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-metadata]
---

# SysML 2.0 Reflection: Metaclassification and Meta Operators

Metaclassification expressions form the foundation of the SysML
2.0 reflection mechanism. They enable access to both explicit and
implicit metadata annotations associated with an element. The
resulting expression can reason about properties of the element
itself, for example to filter all abstract types (Ch 36, p 254).

## The three reflection mechanisms

A metadata access expression returns all the metadata associated
with a model element, including the implicit metadata describing
the element itself. The access expression is written as the
element name, a dot, and the `metadata` keyword. Metadata access
is already enough for full reflection, but two operators make it
easier to work with specific metadata (Ch 36, p 254).

| Mechanism | Syntax | Behaviour |
|---|---|---|
| Metadata access | `Element.metadata` | Returns all metadata associated with `Element`, including implicit meta-type metadata. |
| `@@` (metaclassification) | `Element @@ MetadataDef` | Returns `true` if `Element` carries at least one metadata annotation defined by `MetadataDef`. Similar to `@` but operates one meta-layer below. |
| `meta` | `Element meta MetadataDef` | Returns all metadata of the specified type attached to `Element`. Used for navigating into M2 features. |

## Worked example

```sysml
metadata def DesignPart;

abstract part def UAV {
    @DesignPart;
}

attribute isDesign = UAV.metadata @ DesignPart;
attribute isPartDef = (UAV @@ SysML::PartDefinition);
attribute isAbstract = (UAV meta SysML::PartDefinition).isAbstract;
```

- Line 7 fetches all metadata annotations attached to `UAV` and
  uses the `@` operator (see
  [[sysml2-functions-and-higher-order]]) to check whether at least
  one is an instance of `DesignPart`.
- Line 8 uses `@@` to do the same for `PartDefinition` from the
  SysML library, leveraging the implicit meta-type metadata that
  every element carries.
- Line 9 uses `meta` to fetch all attached metadata instances of
  `SysML::PartDefinition` and navigate into them via a feature
  chain to read the `isAbstract` flag (Ch 36, p 255).

## `@` versus `@@`

The two operators operate at different meta-layers:

- `@` checks explicit metadata annotations or classification at
  the same meta-layer. See
  [[sysml2-functions-and-higher-order]].
- `@@` checks metadata annotations one meta-layer below. Most
  often used with the metadata definitions in the KerML and SysML
  reflective libraries to create reflective checks
  (Ch 36, p 254).

## `meta` returns null on type mismatch

When the base type of a semantic metadata definition is a
definition, but the element queried is a usage, the `meta`
operator returns null. Silent null results can mask bugs. Redefine
the `annotatedElement` feature of the semantic metadata to trigger
a meaningful error (see [[sysml2-language-extension]]).

## Common reflective patterns

### Test if an element is a part definition

```sysml
attribute isPart = e @@ SysML::PartDefinition;
```

### Test if an element is abstract

```sysml
attribute isAbstract = (e meta SysML::Type).isAbstract;
```

### Filter by element kind in a smart package

```sysml
filter @SysML::PartUsage;
```

The reflective check `@SysML::PartUsage` lifts each candidate to
its meta-type and tests whether it is a `PartUsage`. See
[[sysml2-filter-conditions]] for filter syntax.

## See also

- [[sysml2-metadata-overview]] for the conceptual frame.
- [[sysml2-metadata-definitions]] for declaration syntax.
- [[sysml2-functions-and-higher-order]] for the `@` classification
  operator at M0/M1.
- [[sysml2-filter-conditions]] for using reflective expressions in
  imports and views.
