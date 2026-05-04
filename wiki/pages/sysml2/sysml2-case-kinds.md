---
title: "SysML 2.0 Case Kinds: Use, Analysis, Verification"
slug: sysml2-case-kinds
type: reference
layer: sysml2
tags: [cases, use-cases, analysis-cases, verification-cases, syntax]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 33, pages 233 to 242."
    raw: sysmlv2.pdf
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. VerdictKind enumeration."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-cases-overview
  - sysml2-case-patterns
  - sysml2-expressions-constraints
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-cases]
---

# SysML 2.0 Case Kinds: Use, Analysis, Verification

This page captures the syntax for the three standard case kinds. For
the conceptual frame and shared features, see
[[sysml2-cases-overview]].

## Use cases

Use cases describe the behaviour of a system from an outside
perspective. The use case concept is older than SysML, but became
more formally defined in SysML 2.0 (Ch 33, p 233).

A use case definition models interactions between one or more actors
and the system or component. The case definition may carry a
specific arrangement around the system, such as a test configuration
or a sample environment, to illustrate the use case (Ch 33, p 230).

```sysml
use case def 'Provide Transportation' {
    subject vehicle : Vehicle;
    actor driver : Person;
    actor passengers : Person[0..4];

    objective {
        doc /* Transport passengers safely from origin to destination. */
    }
}
```

Case definitions fit nicely with part definitions. A part definition
can model a specific arrangement of the subject and its environment
that frames a use case (Ch 33, p 230, Figure 33.1).

## Analysis cases

Analysis cases capture parametric analysis. They enable computation
over system properties to evaluate outcomes such as energy
consumption, cost, or performance metrics under defined conditions
(Ch 33, p 238).

An analysis case invokes behaviour of its subject and binds results
through parametric relationships to analyse system performance or
properties. The analysis case body uses calculations and constraint
bindings to compute the result that the case returns
(Ch 33, p 238). See [[sysml2-expressions-constraints]] for the
constraint binding mechanism.

```sysml
analysis def MassRollupAnalysis {
    subject vehicle : Vehicle;

    in totalMass = vehicle.parts.totalMass.sum();
    return totalMass;
}
```

The analysis case returns a result that the calling context can
bind to a target requirement or objective.

## Verification cases

Verification cases model the verification of requirements. They
specify how a requirement is to be verified (Ch 33, p 242).

A verification case includes a verification definition that
specifies the verification task. The verification definition binds
the subject to the element being verified. A verification case may
include a `verify` clause that explicitly declares which requirement
is being verified. The subject of the verification case is bound to
the subject of the requirement being verified (Ch 33, p 242).

```sysml
verification def VehicleMassTest {
    subject testVehicle : Vehicle;

    objective {
        verify vehicleMaxMass;
    }
}
```

A verification case may declare `verify` against a requirement only
when the case subject matches the requirement subject. Mismatched
subjects produce an invalid verification model (Ch 33, p 242).

## Verdict semantics

Verification cases return a verdict, typically drawn from the
standard `VerdictKind` enumeration with values such as `pass`,
`fail`, `inconclusive`, and `error`. The 2026-04 release of the SysML
v2 book does not provide a dedicated section on verdict semantics.
The verdict kind definitions live in the standard domain library and
are referenced from Chapter 33 without full elaboration.

Until the book's treatment of verdict semantics is published, authors
should consult the OMG Systems Modeling Language v2.0 formal
specification (March 2023, formal/2025-01-01) for the `VerdictKind`
enumeration and its intended use in verification workflows.
Confidence on this page may need revision when Chapter 33's verdict
section publishes.

## Include relationships

Cases can reuse other cases through `include` relationships. When a
case includes another case, the behaviour of the included case is
composed into the including case (Ch 33, p 230).

The chapter introduces include relationships but defers detailed
coverage of `extend` relationships and more complex case composition
patterns to a later release. For known composition patterns, see
[[sysml2-case-patterns]].

## See also

- [[sysml2-cases-overview]] for the conceptual frame and shared
  features.
- [[sysml2-case-patterns]] for VSE-scale patterns and gotchas.
- [[sysml2-actions]] for the action and succession base machinery.
