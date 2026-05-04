---
title: "Needs vs Requirements: Core Distinction and Categorisation"
slug: needs-vs-requirements
type: concept
layer: needs-and-reqs
tags: [needs, requirements, stakeholders, categorisation, ffq-c, vested-influence-participate]
sources:
  - citation: "INCOSE (2022). Guide for Writing Requirements (Needs and Requirements), v1.0. INCOSE-TP-2021-003-01."
    raw: INCOSE_NeedsAndReqs_v1.pdf
related:
  - requirements-elicitation-and-writing
  - requirements-traceability-and-attributes
  - sysml2-syntax-requirements-and-cases
  - sysml2-requirements-semantics
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [needs-and-requirements]
---

# Needs vs Requirements: Core Distinction and Categorisation

## Core distinction

A **need** expresses what stakeholders expect from the System
of Interest (SOI). A **requirement** expresses what the SOI
must do or be to satisfy those needs. Needs are
stakeholder-perspective statements; requirements are
SOI-perspective statements.

| Form | Pattern |
|---|---|
| Need statement | "The stakeholders need the system to [verb phrase]." |
| Requirement statement | "The [System] shall [verb phrase]." |

Needs exist at the problem/solution boundary. Requirements
exist within the solution space. Every requirement must trace
to at least one need. A single need may generate multiple
requirements.

For the SysML 2.0 syntax that captures requirements as model
elements with `subject`, `assume`, `require`, satisfy, and
verify links, see [[sysml2-syntax-requirements-and-cases]].
For the underlying semantics (the
`allTrue(assumptions) implies allTrue(constraints)` rule), see
[[sysml2-requirements-semantics]].

## Stakeholder identification

For a VSE, stakeholder identification must be thorough but
lightweight. Use these guiding questions to ensure coverage:

| Question | Typical Stakeholder |
|---|---|
| Who pays for the SOI? | Customer, Sponsor |
| Who profits from the SOI? | Owner, Operator |
| Who produces the SOI? | Developer, Manufacturer |
| Who tests or verifies the SOI? | Tester, V&V team |
| Who uses the SOI? | End user, Operator |
| Who maintains the SOI? | Maintainer, Support |
| Who regulates the SOI? | Regulatory body, Certifier |
| Who is affected by the SOI without using it? | Neighbours, Public |
| Who disposes of the SOI? | Disposal authority |
| Who trains users of the SOI? | Trainer |

Classify each stakeholder as **V** (Vested, direct authority),
**I** (Influence, can affect decisions), or **P**
(Participate, provides input). For a VSE, a simple register
with columns (Stakeholder, Internal/External, VIP
Classification, Desired Outcome) is sufficient.

## Organising needs: the F-F-F-Q-C framework

Group identified needs into five categories:

| Category | Description | Example |
|---|---|---|
| **Function** | What the SOI must do (actions, behaviours, transformations) | "Measure temperature every 5 seconds" |
| **Fit** | How the SOI fits its operational context (interfaces, environment, users) | "Operate in ambient temperatures from -20 to +55 degrees C" |
| **Form** | Physical characteristics (size, weight, shape, colour, materials) | "Weigh no more than 500 g" |
| **Quality** | Non-functional attributes (reliability, availability, safety, security, usability) | "Mean time between failures exceeding 10 000 hours" |
| **Compliance** | Regulatory, legal, and standards obligations | "Comply with IEC 61508 SIL 2" |

Use this five-category framework as a coverage check during
needs elicitation: any system with users typically generates
needs across all five.

## Requirement types

Requirements derived from needs fall into corresponding types:

- **Functional / performance requirements** specify what the
  SOI must do and how well. Always include measurable
  performance criteria. Example: "The system shall measure
  temperature with an accuracy of plus or minus 0.5 degrees C."
- **Fit / operational requirements** specify how the SOI
  integrates with its operational environment, including
  interfaces, human factors, and deployment conditions.
- **Form requirements** specify physical attributes. Use these
  sparingly as they constrain design freedom. Prefer
  performance-based requirements where possible.
- **Quality requirements** specify non-functional attributes:
  reliability (MTBF, failure rate), availability (uptime
  percentage), maintainability (MTTR), safety (SIL, ASIL),
  security (access control, encryption), and usability (task
  completion time, error rate).
- **Compliance requirements** reference specific standards,
  regulations, or certifications the SOI must meet.

The SysML 2.0 Systems Model Library provides specialised
`RequirementCheck` subtypes that pre-bind subject types
(`FunctionalRequirementCheck` over Action,
`PerformanceRequirementCheck` over AttributeValue,
`PhysicalRequirementCheck` over Part, and so on). See
[[sysml2-systems-model-library]].

## Needs-to-requirements transformation

The transformation follows five steps:

1. **Analyse each need.** Determine whether the need is clear,
   singular, and testable. Split compound needs.
2. **Identify requirement type.** Map the need to one or more
   requirement types (functional, fit, form, quality,
   compliance).
3. **Derive requirement statements.** Rewrite each need as a
   "shall" statement from the SOI perspective. Add measurable
   criteria, tolerances, and conditions.
4. **Allocate requirements.** Assign each requirement to a
   system element (subsystem, component) in the System
   Breakdown Structure. See [[sysml2-allocations-overview]] for
   the SysML 2.0 allocation mechanism.
5. **Establish traceability.** Link each requirement back to
   its source need(s) and forward to design elements and
   verification activities. See
   [[requirements-traceability-and-attributes]].

The transformation matrix (one row per need, columns for
derived requirements) provides a lightweight tool for a VSE to
track this mapping without specialised tooling.

## See also

- [[requirements-elicitation-and-writing]] for elicitation
  techniques and the rules for writing good requirements.
- [[requirements-traceability-and-attributes]] for traceability,
  attributes, TBX management, and AMBSE model-based
  requirements.
- [[sysml2-syntax-requirements-and-cases]] for SysML 2.0
  requirement syntax.
- [[sysml2-requirements-semantics]] for requirement semantics.
- [[hsi-in-requirements]] for capturing HSI as system
  requirements within this framework.
