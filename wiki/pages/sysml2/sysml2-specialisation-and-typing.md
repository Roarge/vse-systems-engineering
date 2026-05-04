---
title: "SysML 2.0 Specialisation, Typing, Composition, and Feature Values"
slug: sysml2-specialisation-and-typing
type: reference
layer: sysml2
tags: [specialisation, typing, ref, composition, feature-values, redefines, subsets]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Chapter 8.4."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-language-architecture
  - sysml2-type-hierarchy
  - sysml2-syntax-packages-and-definitions
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Specialisation, Typing, Composition, and Feature Values

This page captures the core semantic rules that govern how types
relate to each other and how usages bind values.

## Specialisation

Specialisation creates subtype relationships. SysML 2.0 enforces a
strict rule: **definitions specialise definitions, and usages
specialise usages**. You cannot have a usage specialise a
definition or vice versa.

| Operator | Long form | Behaviour |
|---|---|---|
| `:>` | `specializes` | Subtype relationship. The specialising type inherits all features of the general type. |
| `:>>` | `redefines` | Replaces an inherited feature with a more specific one. The redefined feature must be type-compatible with the original. |
| `subsets` | `subsets` | Declares that a usage is a subset of another collection. The subsetting usage's values are always a subset of the subsetted usage's values. |

**Practical rule**: use `:>` to create subtypes of definitions.
Use `:>>` inside a specialisation to override an inherited feature
with a more specific type or value.

## Ownership and composition

Parts are **composite** (owned) by default. Destroying the owner
destroys the part. This models physical containment: a vehicle
owns its engine. If the vehicle ceases to exist, its engine (as a
part of that vehicle) also ceases to exist.

The `ref` keyword makes a usage **referential** (non-composite).
The referenced element exists independently of the referencing
context. Use `ref` for associations such as "the driver of the
vehicle", where the person exists independently.

**Critical rule**: Attributes are **always referential**. The
`validateAttributeUsageIsReference` constraint enforces this. An
attribute definition cannot contain composite parts. If you need
a structured element that owns other composite elements, use a
`part def` instead of an `attribute def`.

## Typing

A usage can be typed by one or more definitions. Multiple typing
is written as `part x : TypeA, TypeB`. The usage then conforms to
the **intersection** of all typing constraints.

**Port conjugation** (`~PortType`) reverses all `in`/`out`
directions on a port type. When two parts communicate, one
typically has the original port type and the other has the
conjugated port type. The conjugated port definition is generated
automatically by the language.

## Feature values

Three kinds of value binding exist in SysML 2.0:

| Operator | Name | Semantics |
|---|---|---|
| `=` | Bound value | Fixed at definition time. Can never change. |
| `:=` | Initial value | Set at creation time. Can change afterwards. |
| `default` | Default value | Applied if no more specific value is given. Can be overridden by specialisation. |

Choosing the right operator matters for verification:

- A **bound value** (`=`) is a design constraint that the system
  must always satisfy.
- An **initial value** (`:=`) is a starting condition.
- A **default value** provides a fallback that downstream
  specialisations may override.

For the variable-feature semantics that govern how values change
over time during execution, see
[[sysml2-occurrence-context-and-variables]].

## See also

- [[sysml2-language-architecture]] for the KerML/SysML layering.
- [[sysml2-type-hierarchy]] for the type tree.
- [[sysml2-syntax-packages-and-definitions]] for the relationship
  keyword cheat sheet.
- [[sysml2-occurrence-context-and-variables]] for variable
  features and the `constant` modifier.
