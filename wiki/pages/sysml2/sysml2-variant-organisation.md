---
title: "Variant Modelling Organisation in AMBSE Models (VAMOS adapted)"
slug: sysml2-variant-organisation
type: pattern
layer: sysml2
tags: [variants, vamos, configurations, pleml, organisation, ambse]
sources:
  - citation: "Weilkiens, T. (2016). Variant Modeling with SysML. MBSE4U. Chapters 2 and 3 (VAMOS)."
    raw: null
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 35."
    raw: sysmlv2.pdf
  - citation: "ISO/IEC 26580:2021. Software and systems engineering — Methods and tools for the feature-based approach to software and systems product line engineering."
    raw: null
related:
  - sysml2-canonical-model-layout
  - sysml2-variations-overview
  - sysml2-variation-definitions
  - sysml2-variant-configuration
  - sysml2-variant-patterns
confidence: high
created: 2026-05-04
updated: 2026-05-06
bundled_by: [sysml2-model-structure]
---

# Variant Modelling Organisation in AMBSE Models

> **Canonical for this plugin: methodology §8.3.3.** Templated
> package names (`{{sc}}_Variations`, and similar) used below
> describe the AMBSE convention at the SysML 2.0 language
> level. The plugin's canonical project directory for variation
> material is `model/variations/` (with `trade-studies/`,
> `decision-points/`, `candidate-variants/`, and `resolved/`
> subdirectories) per `methodology/08-project-structure.md`
> §8.3.3, which is what `project-setup` scaffolds.

The variant **syntax** authority is Chapter 35 of *The SysML v2
Book*, covered in [[sysml2-variations-overview]],
[[sysml2-variation-definitions]], [[sysml2-variant-configuration]],
and [[sysml2-variant-patterns]]. This page adds the
**organisation** that surrounds that syntax, drawn from Weilkiens
(2016) *Variant Modeling with SysML*, Chapters 2 and 3 (VAMOS).
VAMOS was written against SysML v1 and its stereotype syntax is
not reproduced. What transfers is the method and the
organisation.

## Core, Variations, Configurations

VAMOS Ch 3.2 separates variant models into three orthogonal
concerns:

- **Core** is the unchanging system model (VAMOS Ch 3.3 calls it
  "a normal system model").
- **Variations** are the decision points.
- **Configurations** are the concrete selections that materialise
  a product.

The plugin maps this onto the AMBSE layout:

| VAMOS concern | Plugin location | Authority |
|---|---|---|
| Core | The whole AMBSE canonical layout | ASE 2016 Fig 3.13, Cookbook 2021 Fig 1.35 |
| Variations | Inline inside the owning AMBSE package (usually `{{sc}}_ArchDesign`, sometimes `{{sc}}_Requirements` or `{{sc}}_Interfaces`) | SysML v2 Book Ch 35 |
| Configurations | Optional top-level package `{{sc}}_Configurations` | VAMOS 2016 Ch 3.7 adapted |

This is a **hybrid**. VAMOS 2016 put variations in a dedicated
top-level package alongside the core. SysML 2.0 Chapter 35 puts
them inline inside the owning part def. The plugin uses the
Chapter 35 rule for inline variation definitions because Chapter
35 is the SysML 2.0 syntax authority, and uses the VAMOS rule for
a dedicated `{{sc}}_Configurations` package because VAMOS is the
organisation authority for concrete configurations.

## Variation point discipline

A variation point is the single element that a variation refines.
VAMOS Ch 3.4 lays down a discipline: **do not make children of
variation points into variation points themselves**. A variation
declared on a child of another variation is a smell, because the
child's variation space is ambiguous with the parent's.

The sibling skill `sysml2-model-structure` lifts this into a
validation check: nested variations are flagged.

## Feature tree reading

When variation elements are nested hierarchically, the hierarchy
reads as a **feature tree** (VAMOS Ch 3.5). VAMOS offers this as
a lightweight alternative to a full feature model. In SysML 2.0
the equivalent reading is the nesting of variation definitions
inside their owning part defs. PLEML is the formal feature-model
extension (see below).

## Cross-variation constraints

VAMOS used `«XOR»` and `«REQUIRES»` stereotypes. SysML 2.0 uses
`assert constraint { ... implies ... }` bodies inside the owning
part def. The worked example lives in
[[sysml2-variant-configuration]].

## Minimum viable variant organisation for a VSE

A VSE project with one or two variants does not need the full
VAMOS apparatus. The minimum viable pattern is:

1. Declare variations inline in `{{sc}}_ArchDesign` (or
   `{{sc}}_Requirements` for requirement variations) per
   Chapter 35.
2. Add `{{sc}}_Configurations` only when concrete product
   instances need to be materialised.
3. Write cross-variation rules with `assert constraint` inside
   the owning part def.

The Minimal AMBSE subset tier in `project-setup` does not
scaffold `{{sc}}_Configurations`. The Canonical AMBSE tier
scaffolds it on opt-in.

## The PLEML extension

SysML 2.0 has an optional Product Line Engineering Modelling
Library (PLEML) for full feature models aligned with ISO/IEC
26580 (SysML v2 Book Ch 35). The plugin does not scaffold PLEML
in this release. Adopt it when the inline-variation pattern is
outgrown.

## Red flags

- Variation definitions declared in a separate top-level package
  instead of inline in the owning part def (VAMOS v1 pattern).
- Variants declared as composite parts of the variation (Ch 35
  treats variants as members through the variant membership
  relationship).
- VAMOS v1 stereotypes (`«variation»`, `«variant»`,
  `«variantConfiguration»`, `«variationPoint»`, `«XOR»`,
  `«REQUIRES»`) used in SysML 2.0. The Chapter 35 syntax
  supersedes them.

## See also

- [[sysml2-canonical-model-layout]] for where
  `{{sc}}_Configurations` fits in the package set.
- [[sysml2-variations-overview]],
  [[sysml2-variation-definitions]],
  [[sysml2-variant-configuration]], and
  [[sysml2-variant-patterns]] for the SysML 2.0 syntax authority.
