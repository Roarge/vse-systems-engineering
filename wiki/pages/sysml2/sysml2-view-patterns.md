---
title: "SysML 2.0 View Patterns and Gotchas"
slug: sysml2-view-patterns
type: pattern
layer: sysml2
summary: Practical view patterns and the recurring mistakes that show up in review
tags: [views, patterns, gotchas, vse]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-07 release. MBSE4U. Chapter 37, pages 306 to 308."
    raw: sysmlv2.pdf
related:
  - sysml2-viewpoints-and-concerns
  - sysml2-view-definitions
  - sysml2-standard-views
confidence: high
created: 2026-05-04
updated: 2026-08-14
referenced_by: [sysml2-views]
---

# SysML 2.0 View Patterns and Gotchas

## Contents

- Pattern: basic viewpoint and view pair
- Pattern: stakeholder-driven view
- Pattern: concern-based filtering
- Pattern: rendering selection
- Pattern: view composition
- Pattern: standard view reuse
- Pattern: view library integration
- Gotchas and red flags
- Pending material in the source

This page collects practical patterns for VSE-scale authors who use
SysML 2.0 views, plus the recurring mistakes that show up in review.
For the syntactic and conceptual surface, see
[[sysml2-view-definitions]] and [[sysml2-viewpoints-and-concerns]].

## Pattern: basic viewpoint and view pair

Define a viewpoint that frames one or more concerns, then define a
view that satisfies the viewpoint either by an explicit `satisfy`
clause or by owning a usage of the viewpoint (Ch 37, pp 306 to 307).
This is the simplest form and the right starting point for most
VSE-scale view work.

## Pattern: stakeholder-driven view

Model the stakeholder as a part with declared concerns, wrap those
concerns in a viewpoint, and define a view that satisfies the
viewpoint and exposes the relevant model elements. The chain
stakeholder, concern, viewpoint, view aligns the architecture
description with ISO/IEC/IEEE 42010 (Ch 37, p 306). Use this pattern
when stakeholders are first-class in the project (regulated domains,
formal architecture description requirements).

## Pattern: concern-based filtering

Customise view content with `expose` relationships constrained by
`filter` clauses. Boolean filters let a single underlying model be
viewed from multiple perspectives without duplication (Ch 37, p 307).
The pattern shines when several stakeholders share a concern but
need different element subsets.

## Pattern: rendering selection

Assign different render usages (such as `asElementTable` or
`asTreeDiagram`) to different views to control how model elements
are displayed. The same elements can be rendered in different
formats for different audiences without altering the underlying
model (Ch 37, p 307).

## Pattern: view composition

Compose multiple specialised views into a higher-level view so
stakeholders can see both detailed and abstract perspectives. Works
through the standard specialisation mechanism, which is all the
book itself documents for views (Ch 37, p 307). Use this pattern
for executive summaries that draw from several detail views.

## Pattern: standard view reuse

Use one of the eight standard views from the
`StandardViewDefinitions` package rather than defining a new view
from scratch. This ensures consistency across projects and eases
the SysML v1 to v2 transition (Ch 13, p 56). See
[[sysml2-standard-views]].

## Pattern: view library integration

Organise view and viewpoint definitions into a library package and
reuse them across projects, so teams establish consistent
definitions as an organisational standard. The book documents
library packages in general terms (Ch 16, p 87) without
view-specific guidance, so this is VSE practice built on that
mechanism. For VSE projects, a small in-house view library reduces
review time and keeps deliverable formatting consistent.

## Gotchas and red flags

The following mistakes recur across reviews of SysML 2.0 view
models.

### Expose has protected visibility

The elements brought in by an `expose` relationship are only visible
in the view itself and in specialisations of the view. This is not
obvious from casual inspection and can cause confusion about which
elements are actually public in the containing package (Ch 37, p 307).
Authors who expect `expose` to behave like `import` will be
surprised.

### View concept is still evolving

Work is underway to extend the view concept with layout information
so that views can be exchanged between tools. The extension is
planned for SysML v2.1. Current view definitions may require
migration when the layout extension lands (Ch 37, p 308).

### Satisfy versus owned usage is subtle

The distinction between an explicit `satisfy` relationship and a
view that owns a usage of a viewpoint is subtle. Both satisfy the
viewpoint, but ownership provides implicit satisfaction, which may
have unexpected effects on model composition (Ch 37, p 307). Choose
one form per project and stick to it for consistency.

### Filter conditions in square brackets

A filter condition placed in square brackets after an import
statement, without the `filter` keyword, applies only to that
import. The bare `filter` keyword form applies to every import in
the containing package (Ch 36, pp 304 to 305). Confusing the two
scopes has unintended consequences for what is actually imported.
When in doubt, use the explicit `filter` statement scoped to the
view body.

### Graphical notation is thin

The SysML v2 book does not extensively cover the graphical notation
for viewpoints and views, relying instead on textual examples. Tool
support for graphical viewpoint notation varies across
implementations (Ch 37, p 307). Authors should validate output in
their chosen tool rather than assume portable rendering.

### Concerns are only half-defined in Chapter 37

Concerns are mentioned in Chapter 37 but fully specified in
Chapters 32.1 and 32.5 of the SysML v2 book. Readers relying solely
on Chapter 37 will miss the full semantics of concerns and their
relationships to requirements (Ch 37, p 306).

## Pending material in the source

The 2026-07 release of the SysML v2 book leaves the following topics
pending:

- Chapter 108 `StandardViewDefinitions` library chapter, with full
  render style catalogue and per-view rendering conventions.
- Layout semantics and tool-exchange format planned for SysML v2.1.
- Detailed graphical notation for viewpoints and views.
- Extended concern and stakeholder modelling from Chapter 32.1 and
  32.5 when those sections are expanded.

When these become available, the relevant pages should be updated
and `confidence` revisited.
