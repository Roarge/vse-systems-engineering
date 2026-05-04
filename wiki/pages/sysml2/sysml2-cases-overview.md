---
title: "SysML 2.0 Cases Overview"
slug: sysml2-cases-overview
type: concept
layer: sysml2
tags: [cases, use-cases, analysis-cases, verification-cases]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 33, pages 230 to 233."
    raw: sysmlv2.pdf
related:
  - sysml2-case-kinds
  - sysml2-case-patterns
  - sysml2-actions
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-cases]
---

# SysML 2.0 Cases Overview

Cases are one of the most important new concepts in SysML 2.0. They
generalise the use cases of SysML v1 and capture the abstract notion
of considering a system or a component, called the **subject** of
the case, in a specific situation for a specific purpose
(Ch 33, p 230).

## What a case is

Cases are behaviour models, but they do not represent system
behaviours. Instead, they model what happens **to** the subject in
different situations, such as during a use case or a verification
task. Cases may invoke behaviours of their subject as substeps, but
the subject's own internal behaviour lives elsewhere (Ch 33, p 230).

Cases are a special kind of calculation, and therefore a special
kind of action (see Chapter 27 of the SysML v2 book and
[[sysml2-actions]]). Two consequences follow:

- A case always has a result representing the outcome of performing
  the case, if any.
- A case carries dedicated input parameters, including the subject
  and any actors.

Treating a case as a void action misses the point. Even use cases
return a result, even if that result is implicit in the absence of a
declared verdict.

## The three standard kinds

SysML 2.0 defines three standard case kinds (Ch 33, p 233):

- **Use cases** describe the behaviour of a system from an outside
  perspective.
- **Analysis cases** capture parametric analysis, computing
  properties such as energy consumption, cost, or performance.
- **Verification cases** model the verification of requirements,
  returning a verdict.

A plain case may be useful in itself, but authors should prefer one
of the three standard kinds. The book's examples apply to all three
kinds equally. See [[sysml2-case-kinds]] for the syntax of each.

## Shared case features

Every case carries the same set of structural features.

### Subject

The subject of a case is the system or component considered in the
modelled case. It is declared with the `subject` keyword and is
always the **first `in` parameter** of the case (Ch 33, p 230).
Placing actors or other parameters before the subject violates case
semantics.

### Actors

A case may involve actors, which are parts interacting with the
subject. Actors are declared with the `actor` keyword and are
automatically input parameters of the case (Ch 33, p 230).

Actors represent **roles**, not entities. Different actors may refer
to the same physical entity in different roles. Confusing the role
with the entity leads to models that bind actors incorrectly at the
usage level. Because cases are calculations, they can be evaluated
with different arguments, and a case usage provides the values for
the subject and any actors declared in the case definition.

### Objective

A case may have an objective, which captures why the case is being
considered. Typical examples include testing the subject's
behaviour or verifying a requirement. Objectives are requirements
but are declared with the `objective` keyword (Ch 33, p 233).

The `requirement` element in SysML 2.0 is not necessarily a system
requirement. It is a neutral statement about a property of a
subject. A requirement applied through a satisfy relationship (see
Chapter 32.4 of the SysML v2 book) becomes an actual system
requirement. Declared as an objective, it becomes a goal to achieve,
without the assertion that it can or will be achieved. Mixing the
two leads to misleading trace links.

### Case body

The body of a case contains the steps or interactions that describe
what happens during the case. These steps may model how actors
interact with the subject, how the subject is exercised to verify a
requirement, how a property of it is measured, and so on
(Ch 33, p 230).

Steps inside a case body can be ordered with successions in the
usual way (see [[sysml2-actions]]). Successions inside cases work
identically to successions inside any other action body.

## Where cases sit in VSE practice

For VSE-scale projects, the case family is the natural home for:

- Stakeholder-facing scenario descriptions (use cases).
- Trade study computations (analysis cases).
- Verification matrices and test specifications (verification cases).

See [[sysml2-case-patterns]] for VSE authoring guidance.
