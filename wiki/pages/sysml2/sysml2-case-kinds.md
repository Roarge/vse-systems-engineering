---
title: "SysML 2.0 Case Kinds: Use, Analysis, Verification"
slug: sysml2-case-kinds
type: reference
layer: sysml2
summary: Syntax for the three standard case kinds, that is use case, analysis case, and verification case
tags: [cases, use-cases, analysis-cases, verification-cases, syntax]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-06 release. MBSE4U. Chapter 33, pages 279 to 290."
    raw: sysmlv2.pdf
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. VerdictKind enumeration."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-cases-overview
  - sysml2-case-patterns
  - sysml2-expressions-constraints
confidence: high
created: 2026-05-04
updated: 2026-08-07
referenced_by: [sysml2-cases]
---

# SysML 2.0 Case Kinds: Use, Analysis, Verification

## Contents

- Use cases
- Analysis cases
- Verification cases
- Verdict semantics
- Include relationships
- See also

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
analysis def MaxSpeedAnalysis {
    subject vehicle {
        attribute maxAcceleration :> ISQ::acceleration;
    }
    objective {
        doc /* The objective of this analysis case is to calculate
             * maximum speed (vmax) a vehicle can achieve over a given
             * distance (d) starting at an initial speed (v0).
             */
        assume constraint { vmax < 100 [SI::'km/h'] }
        assume constraint { vehicle.maxAcceleration > 0 }
    }
    in attribute v0 :> ISQ::speed;
    in attribute d :> ISQ::distance;
    attribute t :> ISQ::duration;
    return vmax :> ISQ::speed;

    assert constraint maxSpeed { vmax == v0 + vehicle.maxAcceleration * t }
    assert constraint distance { d == v0 * t + vehicle.maxAcceleration * t^2 / 2 }
}
```

The subject declares only `maxAcceleration`, so the analysis case
suits many different subjects as long as they can supply one. The
objective carries two `assume` constraints that state the validity of
the analysis. The attribute `t` is a helper variable, neither an
input nor an output parameter, which a solver can treat as a free
variable and set so that the constraints are satisfied. The two
`assert` constraints formalise the relationship between the
parameters, and a solver can compute `vmax` from them
(Ch 33, pp 285 to 286, Figure 33.10).

If the primary goal is to evaluate the satisfaction of requirements
rather than to calculate a value that satisfies one, use a
verification case instead (Ch 33, p 285).

### Trade studies

The standard libraries include the `TradeStudies` library, which
contains the specialised analysis case `TradeStudy`. The concepts
that `TradeStudy` defines and uses include a calculation
`EvaluationFunction`, a requirement `TradeStudyObjective`, and two
specialised requirements, `MinimizedObjective` and
`MaximizedObjective` (Ch 33, p 288).

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

Verification cases always return a **verdict**, which signals whether
the requirement was found to be satisfied in that specific case. The
verdict is not a Boolean but an enumeration (Ch 33, p 289).

| Value | Meaning |
|---|---|
| `VerdictKind::pass` | The requirement was satisfied. |
| `VerdictKind::fail` | The requirement was violated. |
| `VerdictKind::inconclusive` | The requirement could not be evaluated. This may be used to show that an assumption was violated. |
| `VerdictKind::error` | The verification case could not finish because of an unexpected error. |

The verdict is typically bound from a library helper.

```sysml
verification def PowerUpTest {
    subject drone : Drone;
    objective checkPowerUp {
        verify requirement : DronePowerUpRequirement;
    }

    perform drone.powerUp;
    then perform action selftest references drone.selfTest;

    return verdict = VerificationCases::PassIf(selftest.allNominal);
}
```

The chapter enumerates the four values and shows `PassIf` in use, but
it carries no dedicated section on how verdicts combine across nested
cases (Ch 33, pp 289 to 290, Figure 33.14). For that specific
question the OMG Systems Modeling Language v2.0 formal specification
(March 2023, formal/2025-01-01) remains the reference.

## Include relationships

Cases can reuse other cases through `include` relationships. An
include use case is a kind of perform action usage, so it is a
referential event usage that must happen during the including case
(Ch 33, p 280).

Keyword combinations matter, and some of them have unexpected
meanings (Ch 33, pp 282 to 283, Figure 33.7).

```sysml
use case uc2 {
    // CORRECT: parses into an unnamed include use case usage
    // referring to 'uc1'
    include uc1;
    include use case references uc1;
    // CORRECT: parses into an include use case usage called
    // 'include_uc1' referring to 'uc1'
    include use case include_uc1 references uc1;
    // INCORRECT: parses into a use case usage named 'uc1' that is
    // NOT referring to 'uc1' in the outer scope
    include use case uc1;
}
```

The book suggests modelling the behaviour of use cases with event
occurrences, perform actions, exhibit states, and include use cases.
All are referential event usages that a later design can realise by
specialising the use case, redefining the events, and adding a
reference subsetting to the realising behaviour (Ch 33, pp 282 to
284). For those composition patterns see [[sysml2-case-patterns]].

## See also

- [[sysml2-cases-overview]] for the conceptual frame and shared
  features.
- [[sysml2-case-patterns]] for VSE-scale patterns and gotchas.
- [[sysml2-actions]] for the action and succession base machinery.
