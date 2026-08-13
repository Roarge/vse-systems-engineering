---
title: "Variant modelling concepts: core, variants, and variations"
slug: sysmod-vamos-concepts
type: concept
layer: sysmod
summary: The variant vocabulary, the abstraction-distance bound, and deciding whether variants belong in one model
tags: [vamos, variants, variation-point, variant-configuration, feature-tree, foda, ovm, cvl, scoping]
sources:
  - citation: "Weilkiens, T. (2016). Variant Modeling with SysML. MBSE4U. Chapter 1 (Introduction)"
    raw: vamos.pdf
  - citation: "Weilkiens, T. (2016). Variant Modeling with SysML. MBSE4U. Chapter 2 (Variant Modeling Concepts)"
    raw: vamos.pdf
  - citation: "Weilkiens, T. (2016). Variant Modeling with SysML. MBSE4U. Chapter 4 (Other Variant Modeling Concepts)"
    raw: vamos.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §11.5 (Variant Modeling)"
    raw: sysmod.pdf
related:
  - sysml2-variations-overview
  - sysml2-variant-patterns
  - sysmod-vamos-method
  - ambse-trade-studies
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [sysml2-variants, architecture-design]
---

# Variant modelling concepts: core, variants, and variations

## Contents

- Orientation
- Why variants are managed in a model
- The abstraction-distance bound
- Every variation adds a dimension
- The vocabulary
- Orthogonality and the recursive structure
- The wider variability landscape
- Where this sits beside the SysML 2.0 pages
- See also

## Orientation

The plugin's authoritative account of variation as a modelling
construct is the SysML 2.0 family, beginning with
[[sysml2-variations-overview]]. This page states the source
position that sits underneath that syntax. It carries the
vocabulary the language feature implements, and the scoping test
that comes before any syntax is written, namely whether the things
in front of you are variants of one system at all. The source is
Weilkiens (2016), *Variant Modeling with SysML*, written against
SysML v1. Its stereotype notation is not reproduced anywhere on
this page or on its siblings. What transfers is the concept set.

## Why variants are managed in a model

The source opens from the market side. Products have always existed
in different variants, organisations increasingly face the challenge
of providing a large set of product variants, and the industry is
moving from the phase of mass production to a phase of mass
customisation, that is, mass production of customised products
(Ch 1, and SYSMOD §11.5 in the same words).

Three reasons to manage variants inside a model are named, and all
three are within reach of a very small entity:

- a product line,
- a customised product,
- different designs for trade studies.

The third reason is the one that connects this page to
[[ambse-trade-studies]]. Candidate architectures compared in a
trade study are variants of one system in exactly the sense used
here, so the decision of whether to model them as variants is an
architecture decision rather than a bookkeeping one.

## The abstraction-distance bound

A single variant of a system typically varies only a few parts of
the system, and is a slight derivation from the initial system. The
source is candid that no rule turns this into a test. It is not
possible to quantify the number of elements, or the level of
detail, that may vary before the result stops being a variant and
becomes a new system. Abstraction cannot be measured and no
objective metric can be given for the deviation of variants (Ch 1).

The worked bound is the transportation example. A car and an
aircraft could both be variants of a transportation system, but in
most cases it makes no sense in practice to handle them as variants
of one transportation system with all the appropriate relationships
in a single system model, because the common parts are too abstract
(Ch 1, restated at SYSMOD §11.5).

What replaces the missing metric is a decision the project has to
take and record. The SYSMOD restatement puts it as an instruction:
you must decide whether the abstraction levels of the common parts
and the abstraction level of the variant parts are close enough to
be valuable for your project to be part of the same model. The
governing rule in both sources is the same. The benefit must be
larger than the effort of managing a complex model.

## Every variation adds a dimension

Describing variants is a sophisticated task, and describing a
single system well is already challenging. Every variation adds
another dimension to a multi-dimensional system model. The source
walks the growth with a car. The engine could be a variation with
three variants, diesel, electric, or hybrid. The next variation
could be the chassis, with the variants small, deluxe, and
cabriolet. The variants then combine, for example a car with a
diesel engine and a small chassis, or a car with a hybrid engine
and a deluxe chassis. Any additional variation increases the
dimension and the number of potential combinations (Ch 1, and
SYSMOD §11.5).

## The vocabulary

Chapter 2 defines the terms as one coherent conceptual model. The
definitions below are the source's, restated in the plugin's
wording and without its notation.

| Term | Definition in the source |
|---|---|
| Core | All elements that are used in all system configurations |
| Core element | An element of the core, independent of any variant element |
| Variation point | A core element marked as a docking point for a variant element |
| Variant element | An element that occurs only in some configurations, and is part of exactly one variant |
| Variant | A complete set of variant elements that varies the system according to a variation, also known as a feature of the system |
| Variation | The discriminator for variants, for example the variation engine kind discriminating diesel, electric, and hybrid |
| Variant configuration | A valid set of variants and the core, for example a car with a hybrid engine and a deluxe chassis |
| Variant constraint | A rule for a valid set of variants, with XOR and REQUIRES predefined |

Two entries in that table repay a second reading.

A variant configuration is itself a special variant and part of a
variation. In the source's example, the variant configuration
Hybrid engine with Deluxe chassis is part of the variation eco
editions. This is what lets a configuration be organised with the
same structure as any other variant.

A variant constraint carries only two predefined forms in the
source. XOR excludes a variant when a specific variant is selected,
and REQUIRES states that other variants are required when a
specific variant is selected. The method pages reached from
[[sysmod-vamos-method]] carry their semantics and the validity
rules a configuration has to satisfy.

## Orthogonality and the recursive structure

The variants and the core are orthogonal concepts. The core is
independent of the variants, and the source notes that the variants
could even be stored in a separate physical model (Ch 2). That
independence is what makes the core reusable across every
configuration built from it.

The concept set is also recursive. A variant may itself include
variations, and the structure of those variations is the same as
for the top-level variations. The source names this recursion as
the reason the approach scales to a system of any size.

The recursion carries one subtlety worth stating plainly, because
it is where readers usually stumble. Core is a concept relative to
the variations on the same level. A variant that includes
variations of its own therefore contains core elements relative to
those variations, while those same elements remain variant elements
relative to the variations of the level above (Ch 2).

## The wider variability landscape

Chapter 4 sketches three other variability approaches. The source
describes them briefly by its own admission and defers a broader
analysis to future editions, so what follows is orientation rather
than a comparison. It is useful mainly for recognising these
notations when they arrive from outside the model, for example
alongside an external feature model.

- **FODA (Feature Oriented Domain Analysis)**, by Kang et al.
  (1990), models variability from the perspective of the
  stakeholders, showing the features of the system, their
  variability, and the constraints between variants. In its
  notation a line ending in a small circle marks an optional
  feature, a line without the circle marks a mandatory one, and an
  arc between two lines marks features that are exclusive and
  cannot be part of the same product at the same time. The source
  calls the FODA feature tree the mother of the feature trees, and
  records that Kang later extended FODA to the Feature-Oriented
  Reuse Method (FORM), which adds a marketing perspective to the
  requirements and architecture perspectives.
- **CVL (Common Variability Language)** was planned as an adopted
  OMG standard, but the adoption process stopped and the source
  judges that CVL will not become a standard. It specifies the
  variability aspects of any model defined on the Meta Object
  Facility. Three models are involved: a base model describing the
  system of interest, a variability model describing its
  variability aspects, and a resolution model describing how to
  resolve that variability. A model-to-model transformation then
  produces the resolved model in the language of the base model.
  CVL offers a user-centric layer for high-level variability
  modelling based on features, similar to the FODA feature tree,
  and a product-realisation layer for the details.
- **OVM (Orthogonal Variability Model)**, described by Pohl et al.,
  captures the variability of software artefacts in a separate
  model. Its roots are in software engineering, and the source
  notes it can also be applied to systems engineering models. Its
  feature tree marks variation points with a VP symbol and variants
  with a V symbol, with dashed lines for optional variants and
  solid lines for mandatory ones.

OVM matters more than the other two for reading the rest of this
family, because the source states that the VAMOS terms conform with
common variant concepts in the literature and names OVM as its
example (Ch 2).

## Where this sits beside the SysML 2.0 pages

[[sysml2-variations-overview]] is the language frame. SysML 2.0
treats variation as a first-class language feature and places it
inside the shared-assets superset framework of product line
engineering governed by ISO/IEC 26580. That page also owns the
boundary with feature modelling, where formal feature models live
in an external model and communicate through the PLEML extension.
None of that is repeated here.

What this page adds below the syntax is the vocabulary the language
feature implements, and one question the SysML 2.0 pages never
pose, because a language cannot pose it: whether the candidates in
front of you are variants of one system at all. Answer that first.
The FODA and OVM sketches serve the same seam from the other side,
by giving a reader the vocabulary to recognise an external
feature-model notation when a PLEML-style integration is proposed.

## See also

- [[sysml2-variations-overview]] for the SysML 2.0 language frame
  and the feature-model boundary.
- [[sysml2-variant-patterns]] for VSE-scale authoring patterns and
  the mistakes that recur in review.
- [[sysmod-vamos-method]] for the method that organises a model
  around these concepts.
- [[ambse-trade-studies]] for the trade-study machinery behind the
  third reason to manage variants in a model.
