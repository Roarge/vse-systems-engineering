---
title: "AMBSE Requirements as Model Elements; Stakeholder Identification"
slug: ambse-requirements-as-models
type: concept
layer: ambse
tags: [ambse, requirements, model-elements, stakeholders, sixteen-types]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapters 2, 4-5."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Chapter 2."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-use-case-driven-elicitation
  - ambse-system-requirements-derivation
  - ambse-dependability-and-traceability
  - sysml2-syntax-requirements-and-cases
  - sysml2-requirements-semantics
  - needs-vs-requirements
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [needs-and-requirements]
---

# AMBSE Requirements as Model Elements; Stakeholder Identification

## Requirements in agile MBSE

In agile model-based SE, requirements are not standalone text
documents. They exist as **model elements** within a SysML 2.0
repository, linked to the behavioural and structural models
that specify the system. This dual representation (text +
model) combines the expressiveness of natural language with the
precision of formal models.

Key principles:

- **Text explains why, models specify what.** Natural language
  is excellent for rationale, context, and stakeholder
  communication. SysML 2.0 models are precise enough for
  verification through testing and formal analysis.
- **Requirements are grouped by use case.** Each use case has
  its own set of requirements, its own behavioural model
  (state machine or action sequence), and its own verification
  cases.
- **Requirements are developed incrementally.** One use case
  (or a small group) is fully specified and verified before
  moving to the next.
- **Verification is planned when requirements are written.**
  For each requirement, identify the verification method
  (analysis, inspection, demonstration, test) at the time of
  creation.

For the SysML 2.0 syntax that captures these requirements as
model elements, see [[sysml2-syntax-requirements-and-cases]].
For the formal semantics (assume/require, satisfy, verify), see
[[sysml2-requirements-semantics]]. For the INCOSE writing rules
the AMBSE workflow inherits, see [[needs-vs-requirements]] and
[[requirements-elicitation-and-writing]].

## Stakeholder identification

Douglass identifies 16 stakeholder types. For a VSE, many of
these roles collapse to 2 or 3 actual people, but the checklist
ensures no perspective is missed.

| Stakeholder type | Concern | VSE note |
|---|---|---|
| Purchaser | Budget, ROI, schedule | Often the same as User |
| User | Usability, functionality, performance | Primary stakeholder |
| Evaluator | Testability, acceptance criteria | Often the developer |
| Marketer | Market fit, competitive position | May be the purchaser |
| Seller | Sales enablement, pricing | May not exist for internal systems |
| Trainer | Learnability, documentation | Often the developer |
| Manufacturer | Producibility, yield, cost | Relevant for hardware |
| Acquirer | Compliance, standards | Regulatory or contractual |
| Installer | Installation ease, compatibility | Often the user |
| Maintenance staff | Maintainability, diagnostics | Often the developer |
| Support services | Supportability, logging | Often the developer |
| Operations management | Reliability, uptime | Often the purchaser |
| Certification agencies | Safety, compliance, evidence | Domain-specific |
| Customer support | Issue resolution, documentation | Often the developer |
| Disposal services | End-of-life, environmental | Often overlooked |

VSE guidance: map each type to a named person. If a type has
no named person, either the concern is not relevant or you have
a stakeholder gap to investigate. The shorter VIP-classification
checklist in [[needs-vs-requirements]] is a fast first pass; the
16-type catalogue here is the completeness check.

## See also

- [[ambse-use-case-driven-elicitation]] for use cases as the
  primary structuring mechanism.
- [[ambse-system-requirements-derivation]] for the per-iteration
  derivation workflow.
- [[methodology-overview]] for the inner-loop
  workflow and the three approaches (flow, scenario, state).
- [[ambse-dependability-and-traceability]] for safety,
  reliability, security, and the trace recommendations.
- [[needs-vs-requirements]] for the underlying core distinction.
