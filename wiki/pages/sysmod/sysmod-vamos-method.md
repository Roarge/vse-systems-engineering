---
title: "The VAMOS method: one model for the whole configuration space"
slug: sysmod-vamos-method
type: concept
layer: sysmod
summary: "VAMOS's core, variations, and configurations packages, their dependency rules, and the superset-model idea"
tags: [vamos, method, core, variations, configurations, packages, tooling, vse]
sources:
  - citation: "Weilkiens, T. (2016). Variant Modeling with SysML. MBSE4U. Chapter 3 (Variant Modeling with SysML (VAMOS))"
    raw: vamos.pdf
related:
  - sysml2-variant-organisation
  - sysml2-canonical-model-layout
  - sysmod-toolbox-anatomy
  - sysmod-vamos-concepts
  - sysmod-vamos-configurations
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [sysml2-variants, sysml2-model-structure]
---

# The VAMOS method: one model for the whole configuration space

## Contents

- Orientation
- Method, language, and tool
- The value argument for a small team
- Three concerns as three packages
- The dependency rules
- The core is a normal system model
- One model for the whole configuration space
- The core as a toolbox
- Not every specialisation is a variant
- Where this sits beside the plugin's organisation
- See also

## Orientation

[[sysml2-variant-organisation]] is authoritative for how this
plugin organises variant material, and a reader who needs to know
what the plugin actually scaffolds should start there. This page
states the source method that page adapts. VAMOS, which stands for
VAriant MOdeling with SysML, was written by Weilkiens (2016)
against SysML v1, where the language had no built-in constructs for
variants and the method extended it through a profile. The profile
notation is not reproduced here. What transfers is the method: the
separation of concerns, the dependency rules between them, and the
reading of the model as a superset of every product it can
describe. The concept vocabulary the method assumes is on
[[sysmod-vamos-concepts]].

## Method, language, and tool

The source frames modelling as three separate concerns: the method,
the language, and the tool. Mapped onto itself, VAMOS is the
method, the VAMOS stereotypes are the language layer, and the tool
may be any modelling tool that supports standard SysML (Ch 3).

That separation is what makes the source usable in a SysML 2.0
project at all. In this plugin the language layer is the native
SysML 2.0 variation syntax covered by the sysml2 pages, so the
language third of the source lapses and only the method third
transfers. This page is that third.

## The value argument for a small team

The source argues for keeping variant modelling inside the standard
modelling tool, and the argument is worth reading in a very small
entity because it is an argument about cost rather than about
capability (Ch 3).

A tool with specialised handling of variants does have benefits.
The price named is a second tool, and with it licence costs,
training, yet another modelling language to learn, a tool chain
between the SysML tool and the variant tool, and a more cumbersome
engineering environment. Which approach carries the higher value
depends on how ambitious the requirements on variant modelling are.
For very ambitious requirements a highly specialised variant tool
can make sense. Otherwise the value of variant modelling inside a
standard SysML tool is higher.

The source adds one honest qualification. Customising the modelling
tool with specific variant functionality raises the value again,
but the result is no longer a standard SysML tool. It has become a
variant modelling tool as well, with the maintenance that implies.

## Three concerns as three packages

The source separates a variant model into three top-level packages,
one per concern (Ch 3.2).

| Package | Contents in the source |
|---|---|
| Core | All core elements. Its sub-package structure follows the source's system model structure, but any package structure may be used, because the structure is independent of the variant modelling approach |
| Variations | All variations with their variants. Each variation holds the variants that its discriminator distinguishes |
| Configurations | Concrete variant configurations, that is, valid sets of core and variant elements combined into a system or system assembly |

The Configurations package has a shape that follows from the
vocabulary rather than from convenience. Because a variant
configuration is itself a special variant, the first level inside
the package holds variations and the configurations sit on the next
level as the variants of those variations.

**Divergence flag.** A dedicated top-level variations package is
the source's organisation, not the plugin's. In a SysML 2.0 model
it is a red flag, because [[sysml2-variant-organisation]] places
variations inline in the owning definition per Chapter 35 of the
SysML v2 book, and keeps only the configurations package from
VAMOS. Read the source layout here as provenance, and the plugin
layout there as the rule.

## The dependency rules

The dependency directions between the three concerns transfer
intact, because they are statements about coupling rather than
about notation (Ch 3.2).

- Variant configurations depend on the variant assets and on the
  core assets.
- Variation assets depend only on the core assets.
- Core assets are independent of both the variation assets and the
  configuration aspects, with one exception: the information about
  variation points.

The exception is the whole seam. Marking a variation point is the
only trace a variant model leaves in the core, which is what keeps
the core reusable and what makes the orthogonality claim on
[[sysmod-vamos-concepts]] more than a diagram convention.

## The core is a normal system model

The core is described as a normal system model, independent of the
variant aspects apart from the assignment of variation points. Any
methodology may be used to create it. The source used its own,
SYSMOD, and its package structure inside the core follows that
methodology as a best practice rather than as a requirement of
VAMOS (Ch 3.3).

For a project running this plugin, that means variant modelling
does not compete with the methodology. The core is authored the way
every other model is authored, and the variant apparatus is added
around it. See [[sysmod-toolbox-anatomy]] for the SYSMOD structure
the source used, and [[sysml2-canonical-model-layout]] for the
layout this plugin uses instead.

## One model for the whole configuration space

The model in the source represents the whole configuration space as
well as the concrete variant configurations drawn from it (Ch 3.2).
One model therefore carries more than any single product needs, and
each configuration is a selection out of it rather than a copy of
it.

**Wording note.** The product line engineering community commonly
calls a model of this kind a 150 percent model, a model that
deliberately contains more than any one product. The source extract
does not use that name, so it is offered here as the common name
for the idea rather than as the source's term.

## The core as a toolbox

The core does not specify a specific system. The source calls it a
toolbox that allows many different kinds of system, and draws the
consequence directly: more specification work remains to be done in
the variant configurations before a concrete product is defined
(Ch 3.3).

This is the single most useful sentence in the chapter for a small
team, because it sets the expectation for where effort lands. A
finished core is not a finished product specification, and the work
that completes it belongs in the configuration. See
[[sysmod-vamos-configurations]] for what that completion work
looks like.

## Not every specialisation is a variant

Making variability explicit is a modelling decision, not an
automatism. The source makes the point with juice. Its product
architecture holds several kinds of juice, all of them part of the
core, and the general element Juice is deliberately not a variation
point. Specialisation of a core classifier does not by itself
require variant modelling, and it is up to the modeller to decide
which variability to make explicit (Ch 3.3).

The practical reading is that every variation point is a commitment
to maintain a variation, so mark one only where the model has to
carry the choice.

## Where this sits beside the plugin's organisation

[[sysml2-variant-organisation]] already carries the plugin's
adapted organisation, including its mapping table, the inline
variation rule, the optional configurations package, and the
canonical project directory declared by methodology §8.3.3. None of
that is restated here.

What this page supplies is what the adaptation compressed: the
dependency rules between the three concerns, the reading of the
core as a toolbox rather than as a product, the superset-model
idea, and the tool-economics argument that explains why the source
kept everything inside one standard tool in the first place.

## See also

- [[sysml2-variant-organisation]] for what the plugin scaffolds and
  the mapping from these three concerns onto it.
- [[sysml2-canonical-model-layout]] for the plugin's package layout.
- [[sysmod-vamos-concepts]] for the vocabulary this method assumes.
- [[sysmod-vamos-configurations]] for the configuration discipline
  the toolbox reading sets up.
- [[sysmod-toolbox-anatomy]] for the SYSMOD package structure the
  source used inside its core.
