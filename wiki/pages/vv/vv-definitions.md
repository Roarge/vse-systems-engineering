---
title: "Verification and Validation Definitions"
slug: vv-definitions
type: concept
layer: vv
tags: [verification, validation, soi, success-criteria, levels-of-application]
sources:
  - citation: "INCOSE (2022). Guide to Verification and Validation, v1.0. INCOSE-TP-2021-004-01."
    raw: INCOSE_VV_Guide_v1.pdf
related:
  - vv-planning
  - vv-methods
  - vv-reporting-and-vse-guidance
  - sysml2-cases-overview
  - sysml2-case-kinds
  - sysml2-requirements-semantics
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [verification-validation]
---

# Verification and Validation Definitions

## Verification

Confirmation and provision of objective evidence that an
engineering element:

1. Has been produced by an acceptable transformation.
2. Meets its requirements (context dependent).
3. Meets the rules and characteristics defined for the
   organisation's best practices and guidelines.

**Core question**: "Are we designing and building the product
right?"

Verification checks two things at every lifecycle stage:

- Artifacts against their success criteria (needs against
  writing standards, design against requirements, built system
  against design output specifications).
- Each stage of development against organisational guidelines,
  best practices, procedures, and work instructions.

## Validation

Confirmation and provision of objective evidence that an
engineering element will result or has resulted in a system
that meets its intended use in its intended operational
environment.

**Core question**: "Have we designed and built the right
product?"

Validation compares requirements, design, system elements,
subsystems, and the integrated system against stakeholder needs
at the applicable architecture level. The "stakeholder" for
lower-level parts may be the higher-level system entity within
the same organisation.

## Key distinction

- **Verification** addresses the risk of building the wrong
  thing technically (not meeting stated requirements).
- **Validation** addresses the risk that a perfectly verified
  system still fails to deliver value to the customer. A system
  can pass all verification yet fail validation (the "perfectly
  square wheel" problem).

In SysML 2.0 modelling terms, verification cases formalise the
verification side; the verdict that comes back from a
verification case (`pass`, `fail`, `inconclusive`, `error`) is
captured in the `VerdictKind` enumeration. See
[[sysml2-case-kinds]] for the verification-case construct and
[[sysml2-requirements-semantics]] for how the `verify`
relationship binds verification cases to requirements.

## Levels of application

Verification and validation apply at four levels across the
lifecycle:

| Level | Verification | Validation |
|---|---|---|
| **Needs** | Checks well-formedness | Checks whether needs capture stakeholder intent |
| **Requirements** | Checks quality rules | Checks whether requirements correctly address needs |
| **Design (output specifications)** | Checks the design against requirements | Checks the design will yield a system meeting needs in the operational environment |
| **System (realised product)** | Checks the built system against requirements | Confirms it works for intended users in the intended environment |

## Terminology for VSE context

- **System of Interest (SOI)**: The product, system, or element
  being developed, verified, validated, and delivered.
- **Design input requirements**: What are commonly called
  "system requirements". Conditions the realised system must
  satisfy.
- **Design output specifications**: Drawings, manufacturing
  specs, production guides. The "build-to" package.
- **Success criteria**: The measurable threshold for pass/fail
  of each verification or validation instance.

## See also

- [[vv-planning]] for VCRM, success criteria definition,
  risk-driven prioritisation.
- [[vv-methods]] for inspection, demonstration, test, and
  analysis methods.
- [[vv-reporting-and-vse-guidance]] for execution records,
  SVCM, AMBSE continuous-verification timeframes.
- [[sysml2-cases-overview]] and [[sysml2-case-kinds]] for the
  SysML 2.0 verification-case construct that formalises
  verification activities.
