---
title: "SysML 2.0 Requirements Semantics: Subject, Assume/Require, Satisfaction, Verification"
slug: sysml2-requirements-semantics
type: reference
layer: sysml2
tags: [requirements, subject, assume, require, satisfy, verify, verdict, variations]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Chapter 8.4."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-structural-and-behavioural-semantics
  - sysml2-cases-overview
  - sysml2-case-kinds
  - sysml2-syntax-requirements-and-cases
  - sysml2-variations-overview
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Requirements Semantics

This page captures the formal semantic rules for the requirement
family. For syntax see
[[sysml2-syntax-requirements-and-cases]]. For the case family
that verifies requirements see [[sysml2-cases-overview]] and
[[sysml2-case-kinds]].

## Structure

`RequirementDefinition` specialises `ConstraintCheck`. The
fundamental semantic rule of a requirement is:

```
allTrue(assumptions) implies allTrue(constraints)
```

That is, if all assumed constraints hold, then all required
constraints must hold. This formalises the natural language
pattern "given that [assumptions], the system shall
[requirements]."

## Subject

The `subjectParameter` must be the **first parameter** of a
requirement. It identifies what the requirement is about
(typically the System of Interest or one of its elements). Always
declare the subject explicitly, as this makes satisfaction
bindings unambiguous.

## Actors and stakeholders

- **Actors** are parts that interact with the subject (a user or
  an external system).
- **Stakeholders** are concerned parties who have an interest in
  the requirement being satisfied but do not directly interact
  with the subject.

The two roles are different: an actor is part of the modelled
interaction; a stakeholder is part of the social context that the
modelled requirement serves.

## Assume vs require

- `assume constraint` defines **preconditions** that must hold
  for the requirement to be applicable.
- `require constraint` defines the **actual obligation** that the
  system must satisfy.

The requirement is considered satisfied when the implication
holds: if the assumptions are true, then the required constraints
are true. If the assumptions are false, the requirement is
**vacuously satisfied** (this is standard logical implication).

## Satisfaction

`SatisfyRequirementUsage` creates a `BindingConnector` between the
`subjectParameter` and the `satisfyingFeature`. The statement
`satisfy requirement R by part P` binds P as the subject of R.

For VSE traceability, every system requirement should have at
least one satisfaction link. The traceability-guard skill enforces
this rule across iteration boundaries.

## Verification

`VerificationCaseDefinition` specialises `CaseDefinition`. A
verification case has an objective that must contain a `verify`
link to one or more requirements. The verification case
determines whether the requirement is met.

Verdicts use the `VerdictKind` enumeration:

| Verdict | Meaning |
|---|---|
| `pass` | The requirement is verified as satisfied |
| `fail` | The requirement is verified as not satisfied |
| `inconclusive` | The verification could not determine the result |
| `error` | The verification process itself encountered an error |

For the case-family declaration syntax see
[[sysml2-case-kinds]]. For the verdict semantics in context see
[[sysml2-cases-overview]].

## Variations

`EnumerationDefinition` is always `isVariation=true`. All owned
members of a variation must be variant usages. Each variant must
specialise its owning variation.

Variations are also used outside enumerations. A `variation part
def` declares a set of alternative configurations. Each `variant`
member represents one alternative. Variations are useful for
trade studies in SR.3 (Architecture). See
[[sysml2-variations-overview]] for the full variant family.

## See also

- [[sysml2-syntax-requirements-and-cases]] for declaration syntax.
- [[sysml2-structural-and-behavioural-semantics]] for the broader
  semantic frame.
- [[sysml2-cases-overview]] and [[sysml2-case-kinds]] for the
  verification and analysis case constructs.
- [[sysml2-variations-overview]] for the variant family.
