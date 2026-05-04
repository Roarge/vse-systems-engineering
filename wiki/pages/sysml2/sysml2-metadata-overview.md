---
title: "SysML 2.0 Metadata, Reflection, and Annotations Overview"
slug: sysml2-metadata-overview
type: concept
layer: sysml2
tags: [metadata, reflection, annotations, m1, m2]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 36, pages 252 to 254."
    raw: sysmlv2.pdf
related:
  - sysml2-metadata-definitions
  - sysml2-reflection-and-classification
  - sysml2-filter-conditions
  - sysml2-language-extension
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-metadata]
---

# SysML 2.0 Metadata, Reflection, and Annotations Overview

Reflection in programming and modelling languages is the ability of
the language to refer to its own structure. KerML and SysML 2.0
support reflection in several ways. Models can be extended with
metadata annotations, which store information about the model
elements rather than about the modelled instances. Reflective
expressions can access these annotations together with built-in
ones that describe the model element itself. Reflection and
metadata can be used in filters to implement smart packages and to
specify view contents declaratively (Ch 36, p 252).

## Where metadata sits

Metadata and reflection sit at the boundary between language use
and language extension. Chapter 41 of the SysML v2 book builds
directly on them to define user-defined keywords and
domain-specific extensions. See [[sysml2-language-extension]] for
the extension mechanisms.

## What metadata annotates

This is the load-bearing distinction:

- **Metadata annotates models, not instances.** Metadata usages sit
  on the model element at metalayer **M1**, not on instances at
  **M0**. Metadata is always about the model, never about the
  system being modelled (Ch 36, p 254).
- Misreading this leads authors to attempt tag-based runtime
  state, which does not work. For state that varies during
  execution, use variable features (see
  [[sysml2-occurrence-context-and-variables]]).

## What reflection does

Reflective expressions access both explicit and implicit metadata
annotations associated with an element. The result lets the model
reason about properties of the element itself, for example to
filter all abstract types. Three operators sit at the heart of
reflection:

- `<element>.metadata` returns all metadata associated with the
  element, including the implicit metadata describing the element
  itself.
- `<element> @@ <metadata-def>` checks whether the element carries
  at least one metadata annotation defined by the metadata
  definition. Operates one meta-layer below the ordinary `@`
  classification operator.
- `<element> meta <metadata-def>` returns all metadata of the
  specified type. Useful for navigating into M2.

See [[sysml2-reflection-and-classification]] for the syntax.

## Where filters and views build on this

Imports and views can be restricted with filter conditions that
are Boolean expressions about model elements. A common pattern uses
metaclassification to filter by element kind (`@SysML::PartUsage`)
combined with project metadata (`@MBSEMethodology::Status::status
== StatusKind::approved`). See [[sysml2-filter-conditions]].

## See also

- [[sysml2-metadata-definitions]] for metadata declaration syntax.
- [[sysml2-reflection-and-classification]] for `@@` and `meta`
  operators with examples.
- [[sysml2-filter-conditions]] for filters in imports and views.
- [[sysml2-language-extension]] for user-defined keywords and the
  `SemanticMetadata` mechanism.
