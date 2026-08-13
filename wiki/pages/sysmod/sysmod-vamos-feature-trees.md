---
title: "Variation points and feature trees in VAMOS"
slug: sysmod-vamos-feature-trees
type: concept
layer: sysmod
summary: Variation-point granularity, selection multiplicities on variations, and reading the package tree as a feature tree
tags: [vamos, variation-point, feature-tree, granularity, multiplicity, model-query, views]
sources:
  - citation: "Weilkiens, T. (2016). Variant Modeling with SysML. MBSE4U. Chapter 3 (Variant Modeling with SysML (VAMOS))"
    raw: vamos.pdf
  - citation: "Weilkiens, T. (2016). Variant Modeling with SysML. MBSE4U. Chapter 5 (Variant Stereotypes for SysML)"
    raw: vamos.pdf
related:
  - sysml2-variation-definitions
  - sysml2-variant-organisation
  - sysmod-vamos-method
  - sysmod-vamos-binding-and-constraints
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [sysml2-variants]
---

# Variation points and feature trees in VAMOS

## Contents

- Orientation
- What a variation point marks
- Granularity: children are covered by their owner
- Prefer a generated table to a drawn diagram
- The package tree read as a feature tree
- How many variants a configuration may select
- Constraints drawn on the tree
- Mapping to SysML 2.0
- See also

## Orientation

The plugin's declaration syntax for variations is
[[sysml2-variation-definitions]], and the organisational rule that
follows from the granularity discipline below is already stated on
[[sysml2-variant-organisation]]. This page carries the source
reasoning underneath both: what a variation point is allowed to be,
why its children are deliberately left unmarked, how the package
tree reads as a feature tree, and how many variants one
configuration may take from a variation. The source is Weilkiens
(2016), and its profile notation is not reproduced. See
[[sysmod-vamos-method]] for the method these elements sit inside.

## What a variation point marks

A variation point is an element in the core that variant elements
refine (Ch 3.4). The source's worked example is an apple in the
core of a fruit salad model, refined by variants that specify
different varieties of apple, with the discriminating variation
also named Apple.

Two properties of the concept matter more than the example.

First, a variation point may be any model element that has a name
(Ch 5.6). It is not restricted to structural classifiers, so a
requirement, an interface, or a behaviour may carry the mark as
readily as a part. Where the variation point is a classifier, the
relationship between a variant element and the variation point is
typically specialisation.

Second, one variation point may serve more than one variation. The
source defines the mark as carrying a set of at least one variation
whose variant elements may dock at that point (Ch 5.6). A single
core element can therefore be varied along two independent axes
without being duplicated.

## Granularity: children are covered by their owner

The source's apple has a peel and a pulp, and the specific apple
variants have specific peels and pulps. Both could therefore be
marked as variation points of the variation Apple. The source
deliberately does not mark them, because their owner is already a
variation point, and marking them again would add modelling effort
without adding information. They remain specialised by variant
elements either way (Ch 3.4).

The rule the source draws from this is stated as a best practice:
do not model the children of a variation point as variation points
as well when they belong to the same variation, because if a node
is a variation point, all its child nodes are implicitly covered.
How granular to be is explicitly left to the modeller.

[[sysml2-variant-organisation]] states the resulting rule for this
plugin, and `sysml2-model-structure` lifts it into a validation
check. The reasoning behind the rule is the paragraph above: the
implicit coverage is what makes the extra marks redundant rather
than merely verbose.

## Prefer a generated table to a drawn diagram

The source keeps its overview of all variation points as a table
produced automatically by a model query rather than as a
hand-drawn diagram, and it generalises the practice into a best
practice (Ch 3.4).

The reason given is a property of the two kinds of view. A table or
matrix view is based on a model query and shows the complete set of
information the query covers. A standard diagram shows only the
elements the modeller placed on it, so it is typically incomplete.
The source recommends a table view for a list of things and a
matrix view for the relationships between two element types, and it
applies the same practice again to the constraint matrix and the
configuration matrix.

One detail of its variation-point table is worth carrying over. The
column listing specialisations only makes sense for variation
points applied to a classifier, because any other kind of element
cannot be the target of a specialisation relationship.

The closing note of the same chapter states the reason the practice
matters at all. Even a system model without variants can be a
challenge, and with variants the model becomes a multi-dimensional
configuration space, so special views, reports, and model
transformations are needed to manage the complexity.

## The package tree read as a feature tree

Feature trees are a common representation of variant options, and
the source names OVM and FODA as other approaches that use them.
The package structure of the method produces one directly
(Ch 3.5):

- the top-level variations package is the root of the tree,
- the variations are the next level,
- the variant packages are the leaves.

A variant also represents a feature of the system, which is what
makes the reading a feature tree rather than a package diagram that
happens to be tree-shaped.

## How many variants a configuration may select

Each variation carries two properties, minVariants and maxVariants,
that constrain how many of its variants a single valid variant
configuration may select (Ch 3.5, defined at Ch 5.5).

- The default for both is one, that is, exactly one variant must be
  selected. The source's example is a car that must have exactly
  one gear kind, either manual or automatic.
- A minimum of zero makes the variation optional. The source's
  pepper variation is optional in exactly this way, and permits at
  most one kind of pepper.
- A maximum above one permits several variants of the same
  variation in one configuration. Raising the pepper maximum to two
  would allow two different kinds of pepper. The apple and orange
  variations carry an unlimited maximum, so a salad may contain
  several kinds of each, or none.
- The maximum is always greater than or equal to the minimum. The
  source enforces this as a rule on the variation itself.

## Constraints drawn on the tree

The feature tree also carries the rules between variants. XOR and
REQUIRES are drawn on it as constraints between variants of the
same or of different variations (Ch 3.5). Their semantics, the
validity rules a configuration has to satisfy, and the naming
practice that keeps a constraint matrix legible are on
[[sysmod-vamos-binding-and-constraints]].

## Mapping to SysML 2.0

Two mappings are worth stating, and both are commentary written
here rather than source content.

**The feature tree.** The SysML 2.0 counterpart of the feature-tree
reading is the nesting of variation definitions inside their owning
definitions, per [[sysml2-variation-definitions]] and the
feature-tree section of [[sysml2-variant-organisation]]. The
nesting syntax is not repeated here.

**Selection multiplicity.** This is the genuinely new material on
this page, and it maps only in part. A SysML 2.0 variation is a
placeholder that binds to exactly one variant per variation usage
when a configuration is materialised, which matches the VAMOS
default of exactly one. The VAMOS generalisation to zero, or to
several selected variants of one variation, has no direct
counterpart in the SysML 2.0 variation mechanism. The nearest
expressions available are multiplicity on the variation usage, or
several usages each bound to a variant. Both are workarounds
suggested here, not constructs either source prescribes, so treat
an unlimited maximum as a design question before treating it as a
notation question.

## See also

- [[sysml2-variation-definitions]] for the SysML 2.0 declaration
  forms.
- [[sysml2-variant-organisation]] for the plugin's variation-point
  rule and the feature-tree reading in SysML 2.0.
- [[sysmod-vamos-method]] for the package structure this tree reads
  from.
- [[sysmod-vamos-binding-and-constraints]] for the semantics of the
  constraints drawn on the tree.
