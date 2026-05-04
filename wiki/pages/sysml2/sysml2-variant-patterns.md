---
title: "SysML 2.0 Variant Patterns and Gotchas"
slug: sysml2-variant-patterns
type: pattern
layer: sysml2
tags: [variants, patterns, gotchas, vse]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 35, pages 247 to 250."
    raw: sysmlv2.pdf
related:
  - sysml2-variations-overview
  - sysml2-variation-definitions
  - sysml2-variant-configuration
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-variants]
---

# SysML 2.0 Variant Patterns and Gotchas

This page collects practical patterns for VSE-scale authors who use
SysML 2.0 variations, plus the recurring mistakes that show up in
review. For declaration syntax and configuration mechanics, see
[[sysml2-variation-definitions]] and [[sysml2-variant-configuration]].

## Pattern: part variation with two variants

Declare a `variation part` with named variants for each concrete
option. The variants specialise the variation and carry their
distinguishing attributes (Ch 35, p 247). This is the simplest form
and the right starting point for most VSE-scale variation work.

## Pattern: variation as definition

When the same variation structure is reused across contexts or
appears in a parts catalogue alongside non-variation definitions,
declare it as a variation definition that subclassifies the base
part definition. Variant usages live inside the definition body
(Ch 35, p 248). See [[sysml2-variation-definitions]] for the syntax.

## Pattern: cross-variation constraint

Use an `assert constraint` with an `implies` expression to enforce
valid combinations across multiple variations (Ch 35, p 249). Keep
constraints local to the smallest part definition that owns all
variations involved. Constraints scattered across parent contexts
become hard to audit during review.

## Pattern: configured product from specialisation

To materialise a product from the variation space, specialise the
variation owner and redefine each variation with a concrete variant.
The result is a concrete part definition with no remaining variation
points. Roll-ups, allocations, and downstream V&V cases bind cleanly
against the configured product. See [[sysml2-variant-configuration]].

## Pattern: feature-driven variation selection

When variation selection should follow mission-level or capability-
level features, integrate with an external feature model via the
PLEML extension. Feature bindings connect features to internal
variations, and `assert constraints` handle dependent selections
automatically (Ch 35, p 250).

VSE projects should adopt this pattern only when the variation space
exceeds three or four crosscutting decisions. Below that threshold,
internal constraints in SysML 2.0 are sufficient and avoid the
tooling overhead of an external feature model.

## Gotchas and red flags

The following mistakes recur across reviews of SysML 2.0 variation
models.

### Variants are not owned parts

Variant usages are related to their variation through a variant
membership relationship, drawn as a solid line with a plus sign in a
circle at the owner's end. They are not composite parts of the
variation. Mass, cost, and other roll-ups must skip the variation
and pick exactly one variant per configuration (Ch 35, p 247).

### Variation is a placeholder

The variation acts as a placeholder. Anywhere the variation is used,
one variant must be insertable in its place. Variants must therefore
be specialisations of the variation (Ch 35, p 247). A variant that
fails to specialise its variation is invalid.

### A variation can only own variants and annotations

A variation is not a normal definition body. It may only own
variants and annotations such as comments. To give a variation
structural detail, use a variation definition that subclassifies a
concrete part definition (Ch 35, p 247). Attempting to add
attributes or ports directly to a variation produces a malformed
model.

### Cross-variation constraints live in `assert constraint`

Valid variant combinations are expressed as `assert constraint`
bodies, not through the variation syntax alone. The relationship to
PLE feature constraints is out of scope for the SysML v2 book
(Ch 35, p 249).

### Setting a variant requires specialisation

To fix a concrete configuration, specialise the variation owner and
redefine each variation by binding it to a specific variant.
Attempting to set variants directly on the base variation does not
materialise a concrete product (Ch 35, p 249).

### Feature model integration needs an extension

Full PLE feature models are not part of core SysML 2.0. The PLEML
language extension and tool support from vendors are required for a
complete MBPLE workflow (Ch 35, p 250). Plan for this dependency
before adopting feature-driven selection.

## Pending material in the source

The 2026-04 release of the SysML v2 book leaves the following topics
pending:

- Formal treatment of feature constraints and their relationship to
  SysML 2.0 variation constraints. Forlingieri et al. (2025) is
  cited as the planned reference.
- Trade-off analysis to support variation selection. Section 33.2.1
  is marked as pending in the 2026-04 release.

When these become available, the relevant pages should be updated
and `confidence` revisited.
