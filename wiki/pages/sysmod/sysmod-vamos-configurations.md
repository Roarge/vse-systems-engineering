---
title: "Variants and variant configurations: the configuration discipline"
slug: sysmod-vamos-configurations
type: pattern
layer: sysmod
summary: What belongs in a variant, what a configuration adds, interface management, and behaviour variants
tags: [vamos, variants, variant-configuration, redefinition, interfaces, behaviour, glue-logic]
sources:
  - citation: "Weilkiens, T. (2016). Variant Modeling with SysML. MBSE4U. Chapter 3 (Variant Modeling with SysML (VAMOS))"
    raw: vamos.pdf
  - citation: "Weilkiens, T. (2016). Variant Modeling with SysML. MBSE4U. Chapter 5 (Variant Stereotypes for SysML)"
    raw: vamos.pdf
related:
  - sysml2-variant-configuration
  - sysml2-variant-patterns
  - sysmod-vamos-method
  - sysmod-vamos-feature-trees
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [sysml2-variants]
---

# Variants and variant configurations: the configuration discipline

## Contents

- Orientation
- A variant is a complete sub-model
- Managing the variant-to-core seam
- What a variant configuration is
- Where the completion work belongs
- Views over a configuration
- Selecting variants, and the SysML 2.0 form
- Behaviour variants
- See also

## Orientation

[[sysml2-variant-configuration]] owns the SysML 2.0 mechanics of
materialising a configuration, and [[sysml2-variant-patterns]] owns
the mistakes that recur in review. This page carries the discipline
that surrounds both, taken from Weilkiens (2016) and reproducing
none of its profile notation: what a variant package has to contain
before it is complete, how the seam between variant and core is
managed as an explicit surface, what a configuration may add beyond
its selections, and where the remaining specification work belongs.
It continues the toolbox reading of the core from
[[sysmod-vamos-method]].

## A variant is a complete sub-model

A variant is the root for all elements of a single variant, and its
elements are organised with the same recursive package structure
used for system models. The source is explicit that a variant may
be handled like a system or a subsystem in its own right, with its
own context, requirements, and architectures, and that it may again
contain configurations, variations, and variants of its own
(Ch 3.6, Ch 5.3).

Every variant belongs to exactly one variation, which the source
enforces as a rule on the variant itself (Ch 5.3). A variant not
owned by a variation has no discriminator, and therefore no answer
to the question of what it is a variant of.

## Managing the variant-to-core seam

Variant elements specialise core elements, and that seam is where
the source spends most of its attention (Ch 3.6).

**Redefine whatever you change.** The source's Aurora Golden Gala is a
special kind of apple with a special peel and a special pulp. The
special pulp inherits a taste property from the core pulp, and the
initial value it sets must redefine the inherited property.
Otherwise the variant element carries two properties of the same
name, the inherited one and the newly defined one. The same applies
to the colour of the special peel, and to the peel and pulp
properties of the variant apple itself, where each core property is
typed by a core element and each variant property by a variant
element.

**Keep the seam visible.** The source maintains a Variant Interface
Matrix showing all relationships from variant elements to core
elements, and describes it as a helpful view for managing the
interfaces between variant and core. Like the other matrices in the
method it is generated from a model query rather than drawn, so it
stays complete. See [[sysmod-vamos-feature-trees]] for that
practice.

**The core is not the only supplier.** Variant elements may also
draw on model libraries. The source's sweet mayonnaise dressing
specialises the dressing variation point, and its parts are typed
partly by a core element, lemon juice, and partly by library
elements, sugar and mayonnaise (Ch 3.6).

## What a variant configuration is

A variant configuration is a special kind of variant that defines a
system or system component out of four ingredients (Ch 5.4):

1. a set of selected variants,
2. the core,
3. glue logic elements that connect the components,
4. own system elements, where applicable.

The third and fourth ingredients are the ones teams forget. A
configuration is not only a selection, and may add material that
exists nowhere else. The source works the case deliberately: a
banana appears in one recipe only, is not part of the core, and is
added in the configuration. That is recorded as the modeller's
decision rather than an oversight, and the source notes the banana
could equally have come from a variant or a model library (Ch 3.7).

## Where the completion work belongs

Because the core is a toolbox rather than a product, the work that
turns it into one specific product lands in the configuration
(Ch 3.3, Ch 3.7). The source's juicy fruit salad configuration
specialises core elements and redefines their properties in order
to do three things:

- remove options, for example by setting zero vegetables,
- pin exact amounts, for example sixteen grapes,
- fix specific kinds, for example a green grape rather than a
  grape, and a named apple variety rather than an apple.

A configuration that only lists selections has not finished the
job, because the redefinitions are what make the product concrete.
Instance specifications of the configured product, which the
modelling tool can create automatically, are the cheap check that
the work holds together, and the source names verifying that the
structural definitions are correct as their use (Ch 3.7).

## Views over a configuration

The configuration tree is a special version of the feature tree,
which follows from a configuration being a special variant inside a
variation (Ch 3.7). A configuration package therefore has the same
package structure as a variant package or the core package, and the
source's example holds use cases, product architecture elements,
and instance specifications.

Alongside it the source keeps a configuration matrix, generated by
a model query, showing which variants each configuration selects.
The argument is the one made throughout the method: matrix data is
always complete, while a diagram shows only what the modeller
placed on it.

## Selecting variants, and the SysML 2.0 form

**Source mechanics, given as provenance.** In VAMOS the selection
relationship between a configuration and the core or a variant is
the standard SysML v1 package import. Beyond the VAMOS meaning that
the relationship selects the variant, the import carries its
ordinary namespace meaning, so the selected variants become members
of the configuration's namespace (Ch 3.7, Ch 5.4).

**The form this plugin uses.** SysML 2.0 materialises a
configuration by specialising the owner of the variations and
redefining each variation to a concrete variant, as described on
[[sysml2-variant-configuration]]. That is the only form the plugin
uses. The import-based selection above is recorded so a reader
meeting it in older material can place it, and never as an option.

## Behaviour variants

Behaviour was the sore spot of the source's language.
Generalisation between behaviour elements such as activities or
state machines was legal in SysML v1, but the specification did not
define how inherited elements appear in a diagram, so no tool
showed them. That made variants of behaviour extremely difficult to
model, on top of behaviour generalisation being an inherently
sophisticated task (Ch 3.7).

The guideline the source proposes is a judgement about effort, and
it survives the notation problem that prompted it:

- when the specialisation differs only slightly from the general
  behaviour, model the details of the general behaviour and
  describe the specialisation textually,
- when the specialisation differs strongly, describe the general
  behaviour textually and model the details of the specialised
  behaviour.

**Mapping note.** SysML 2.0 marks variation with a property carried
by every definition and usage element, actions included, as the
SysML 2.0 variations overview in this wiki records, so the
structural obstacle behind the guideline dissolves. The effort
judgement in it remains sound method advice, because it is about
where detail earns its maintenance, not about what a tool can draw.

## See also

- [[sysml2-variant-configuration]] for the SysML 2.0 configuration
  mechanics.
- [[sysml2-variant-patterns]] for the review gotchas.
- [[sysmod-vamos-method]] for the toolbox reading of the core.
- [[sysmod-vamos-feature-trees]] for the query-generated view
  practice and the selection multiplicities.
