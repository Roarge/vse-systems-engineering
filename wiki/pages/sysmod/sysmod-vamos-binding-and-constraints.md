---
title: "Binding times and variant constraints"
slug: sysmod-vamos-binding-and-constraints
type: reference
layer: sysmod
summary: "Binding times, REQUIRES and XOR semantics, configuration validity rules, and their SysML 2.0 mappings"
tags: [vamos, binding-time, constraints, requires, xor, validation, variant-configuration]
sources:
  - citation: "Weilkiens, T. (2016). Variant Modeling with SysML. MBSE4U. Chapter 5 (Variant Stereotypes for SysML)"
    raw: vamos.pdf
  - citation: "Weilkiens, T. (2016). Variant Modeling with SysML. MBSE4U. Chapter 3 (Variant Modeling with SysML (VAMOS))"
    raw: vamos.pdf
related:
  - sysml2-variant-configuration
  - sysml2-expressions-constraints
  - sysmod-vamos-feature-trees
  - sysml2-vse-library-metadata
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [sysml2-variants]
---

# Binding times and variant constraints

## Contents

- Orientation
- Binding time
- Why binding time matters to a very small entity
- REQUIRES
- XOR
- Beyond the two predefined constraints
- When a configuration is valid
- Naming constraints so a matrix stays legible
- Mapping to SysML 2.0
- See also

## Orientation

[[sysml2-variant-configuration]] owns the SysML 2.0 constraint
mechanics, including the worked assertion example, and this page
does not repeat them. What it adds is the semantic contract those
constraints implement, taken from Weilkiens (2016): the arity and
direction of each predefined constraint, the rules that decide
whether a configuration is valid, and the binding-time vocabulary,
which has no counterpart elsewhere in this wiki. The source
expresses its rules formally in a constraint language. They are
carried here in words, and no formal notation from the source is
reproduced. See [[sysmod-vamos-feature-trees]] for the tree these
constraints are drawn on.

## Binding time

Binding time is recorded on a variation point and states when a
variant is bound to it. The source defines it as the latest point
at which the decision for the variant must be made (Ch 5.1), which
is what makes it a commitment rather than a description.

| Binding time | Meaning in the source |
|---|---|
| Design phase | The variant is bound during design, and the design can still be adapted to the selected variant, for example to optimise the system for strong performance requirements |
| Manufacturing phase | The variant is bound while the system is manufactured |
| Operation phase | The variant is bound during operation, for example by a software update or by replacing a system component |
| Undefined | The binding time is not stated |

The method chapter supplies the worked anchor. An apple variant in
the fruit salad model binds at cooking time, which is the
manufacturing phase (Ch 3.4).

## Why binding time matters to a very small entity

This section is a plugin reading rather than source content, and it
follows from the definitions above.

A binding time is a statement about the product, not only about the
model. An operation-phase binding says the delivered system must
support being reconfigured in the field, by software update or by
component replacement, and that capability has to be designed,
verified, and supported. A design-phase binding says the opposite,
that the choice closes before the design freezes and the design may
be optimised around it.

The practical consequence is that a variation point marked for
operation-phase binding should generate requirements. Recording the
binding time early is therefore cheap, and discovering it late is
not.

## REQUIRES

REQUIRES is a predefined binary constraint between two variants
(Ch 5.2). Its semantics are as follows.

- It relates exactly two variants. The source enforces the arity
  and the type of both operands as a rule on the constraint itself.
- If the first variant is selected, the second must also be
  selected for the configuration to be valid.
- The direction is fixed by the order of the operands, which the
  source keeps in an ordered set. A requires B does not imply that
  B requires A.
- Its validation is not performed by the constraint. It is
  performed against each variant configuration, as described below.

The source's worked pair is a variant apple, Granny Smith, that
requires a variant pepper, Bell Pepper (Ch 3.5).

## XOR

XOR is the other predefined binary constraint between two variants
(Ch 5.7). It states that the two related variants cannot be part of
the same valid variant configuration, and like REQUIRES it relates
exactly two variants of the appropriate type. Unlike REQUIRES it is
symmetric, so operand order carries no meaning.

The source's worked pair excludes Granny Smith and Blood Orange
from appearing in one salad, and it notes candidly that the
exclusion is the cookbook's editorial choice rather than a law of
fruit (Ch 3.5).

## Beyond the two predefined constraints

The two predefined constraints are a floor rather than a ceiling.
The source describes them as the most common constraints for
feature trees and states that further rules may be expressed with
the ordinary constraint element of the language (Ch 3.5). A rule
that does not fit a binary relation between two variants is
therefore still expressible, just not predefined.

## When a configuration is valid

Validity is not a property of a constraint. It is checked per
variant configuration, against the set of variants that
configuration selects. The source states three rules formally, and
they say the following (Ch 5.4).

1. **Selection counts.** For every variation represented in the
   selection, the number of selected variants of that variation is
   at least its minimum and at most its maximum. The two bounds are
   the selection multiplicities described on
   [[sysmod-vamos-feature-trees]].
2. **REQUIRES.** Every variant that a selected variant requires is
   itself a member of the selected set.
3. **XOR.** No variant excluded by a XOR with a selected variant is
   a member of the selected set.

One warning comes with the rules. Automated validation depends on
the tool. Where the modelling environment can evaluate the rules,
it can check automatically whether a configuration selects a valid
set of variants. Where it cannot, the constraints are information
only (Ch 3.5). A constraint nobody evaluates does not constrain
anything.

## Naming constraints so a matrix stays legible

The source keeps its constraints in a matrix that lists every
constraint against the elements it constrains, and draws a small
practice from the exercise: give each constraint a name that reads
as a sentence (Ch 3.5). Its own examples are Granny Smith REQUIRES
Bell Pepper and Granny Smith XOR Blood Orange. The names are what
make the matrix readable at a glance, and the effort of writing
them is paid back the first time somebody reviews the set.

## Mapping to SysML 2.0

The mappings below are commentary written here, not source content.
The SysML 2.0 forms themselves are on
[[sysml2-variant-configuration]] and, for the expression language
underneath them, on [[sysml2-expressions-constraints]].

- **REQUIRES** becomes an asserted constraint whose body is an
  implication from the first selection to the second. Implication
  preserves the directionality that the ordered operands carried in
  the source, so the mapping is faithful rather than approximate.
- **XOR** becomes an asserted constraint stating that the two
  selections are not combined.
- **Validation per configuration** corresponds to SysML 2.0
  constraints being evaluated when a configuration is materialised,
  which is the same rule seen from the other side: the constraint
  travels with the model, and the verdict belongs to the
  configuration.
- **Binding time** has no counterpart in core SysML 2.0. The
  natural home for it is an attribute or a metadata annotation on
  the variation, next to the variant-aware metadata definitions
  described on [[sysml2-vse-library-metadata]]. That is a
  suggestion for a project that needs the vocabulary, not a
  construct either source prescribes.

## See also

- [[sysml2-variant-configuration]] for the SysML 2.0 constraint and
  configuration mechanics.
- [[sysml2-expressions-constraints]] for the general expression and
  constraint language.
- [[sysmod-vamos-feature-trees]] for the selection multiplicities
  the first validity rule tests.
- [[sysml2-vse-library-metadata]] for the plugin's variant-aware
  metadata definitions.
