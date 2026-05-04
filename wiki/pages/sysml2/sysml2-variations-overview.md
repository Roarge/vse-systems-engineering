---
title: "SysML 2.0 Variations and Variants Overview"
slug: sysml2-variations-overview
type: concept
layer: sysml2
tags: [variants, product-line-engineering, configuration]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 35, pages 246 to 250."
    raw: sysmlv2.pdf
  - citation: "ISO/IEC 26580:2021. Software and systems engineering — Methods and tools for the feature-based approach to software and systems product line engineering."
    raw: null
related:
  - sysml2-variation-definitions
  - sysml2-variant-configuration
  - sysml2-variant-patterns
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-variants]
---

# SysML 2.0 Variations and Variants Overview

SysML 2.0 treats product variation as a first-class language feature.
A variation is a decision point in a model. At a variation point, one
of several declared variant options must be chosen to materialise a
concrete configuration. This stands in contrast with most engineering
modelling languages, which leave variant management to external tools
or naming conventions (Ch 35, p 246).

## What a variation is

Every definition or usage element in SysML 2.0 carries a Boolean
property `isVariation`. Setting it to `true` marks the element as a
variation. The variation is sometimes called a variation point. Its
variants are members of the variation's namespace, and the variation
itself acts as a placeholder for whichever variant is selected when
the model is configured.

A variation may only own variants and annotations such as comments.
It cannot own ordinary structural members. To give a variation
structural detail, use a variation definition that subclassifies a
concrete part definition (Ch 35, p 247). See
[[sysml2-variation-definitions]] for the two declaration forms.

## Where variations fit in product line engineering

Product Line Engineering (PLE) is governed by ISO/IEC 26580. SysML
2.0 variations sit within the shared assets superset framework of
PLE. Product line features are not directly supported by SysML 2.0
and require a language extension (typically PLEML, the Product Line
Extension Modelling Language).

The SysML 2.0 specification covers:

- Variation definition and variant declaration syntax. See
  [[sysml2-variation-definitions]].
- Cross-variation configuration constraints via `assert constraint`
  bodies. See [[sysml2-variant-configuration]].
- Concrete product specification through specialisation and variant
  binding. See [[sysml2-variant-configuration]].

The SysML 2.0 specification does not cover:

- Formal feature models or feature constraints in the PLE sense.
  These belong in an external feature model, integrated via the
  PLEML extension.
- Trade-off analysis to support variant selection. The 2026-04
  release marks Section 33.2.1 as pending for trade-off coverage.

For deeper coverage of Model-Based Product Line Engineering (MBPLE),
the SysML v2 book points to Forlingieri et al. (2025).

## Boundary with feature modelling

A SysML 2.0 model captures the variation space and the consistency
constraints between variations. A feature model captures the
mission-level or capability-level abstractions that drive variant
selection. The two surfaces communicate through feature bindings
introduced by the PLEML extension. A long-range mission feature in
the external model can drive the engine variation in the SysML model,
which in turn drives the battery variation through an `assert
constraint` (Ch 35, p 250).

For VSE-scale projects, this separation is often unnecessary in
early phases. A pure SysML 2.0 variation model with internal
constraints suffices until the variation space grows beyond a few
crosscutting decisions. See [[sysml2-variant-patterns]] for VSE-scale
authoring guidance.
