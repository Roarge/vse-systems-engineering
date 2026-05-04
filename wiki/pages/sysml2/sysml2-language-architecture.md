---
title: "SysML 2.0 Language Architecture: KerML, Definition/Usage, Implicit Specialisation"
slug: sysml2-language-architecture
type: concept
layer: sysml2
tags: [kerml, language-architecture, definition-usage, implicit-specialisation, conformance]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Chapter 6."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-type-hierarchy
  - sysml2-specialisation-and-typing
  - sysml2-libraries-architecture
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Language Architecture

SysML 2.0 is a two-layer language. The **Kernel Modeling Language
(KerML)** provides the core metamodel: types, features,
classifiers, and relationships. **SysML 2.0** extends KerML with
systems engineering constructs such as parts, ports, actions,
requirements, and verification cases. A VSE engineer authors
`.sysml` files, but the underlying semantics are defined by KerML.

## The definition/usage pattern

This is the central organising principle of SysML 2.0. Definitions
(KerML Classifiers) declare reusable types. Usages (KerML
Features) create instances of those types within a context.

- `part def Vehicle` is a **definition**. It declares a reusable
  type.
- `part myVehicle : Vehicle` is a **usage**. It instantiates that
  type.

Definitions own features that describe the structure and
behaviour of the type. Usages own features that describe the
specific instance. Every usage must be typed by at least one
definition (or by an implicit library type if none is given).

For the navigation features that arise from this pattern (`self`,
`that`, `this`), see [[sysml2-self-and-that]] and
[[sysml2-occurrence-context-and-variables]].

## Implicit library specialisation

Every user-defined SysML 2.0 type implicitly specialises a base
type from the Systems Model Library (Chapter 9 of the OMG
specification) via `specializeFromLibrary()` constraints. This
means that even a bare `part def Sensor;` automatically
specialises `Parts::Part`, which in turn specialises
`Items::Item`, `Objects::Object`, and `Occurrences::Occurrence`.
The engineer does not need to write these specialisations: they
are applied automatically by the language.

This matters for validation: a tool can check whether a model
element conforms to the semantic rules of its implicit base type
without any explicit annotation from the engineer. See
[[sysml2-libraries-architecture]] for the library structure and
[[sysml2-systems-model-library]] for the keyword-to-base-type
table.

## Conformance levels

The OMG SysML 2.0 specification defines five conformance levels:

- **Abstract Syntax** (metamodel structure)
- **Concrete Syntax** in two forms: **Textual** and **Graphical**
- **Semantic** (meaning and well-formedness rules)
- **Model Interchange** (JSON-based API)

For a VSE, the most relevant levels are:

- **Textual Concrete Syntax** is what you write. See
  [[sysml2-syntax-packages-and-definitions]] for the cheat sheet.
- **Semantic** is what the rules enforce. See
  [[sysml2-type-hierarchy]] for the type system and
  [[sysml2-grammar-and-validation]] for well-formedness.

## See also

- [[sysml2-type-hierarchy]] for the DataValue / Occurrence
  branches and the implicit base types.
- [[sysml2-specialisation-and-typing]] for `:>`, `:>>`, `subsets`,
  `ref`, and feature value operators.
- [[sysml2-structural-and-behavioural-semantics]] for parts,
  ports, actions, states, and constraints.
- [[sysml2-requirements-semantics]] for the requirement family.
- [[sysml2-grammar-and-validation]] for the EBNF excerpts and
  validation checklist.
