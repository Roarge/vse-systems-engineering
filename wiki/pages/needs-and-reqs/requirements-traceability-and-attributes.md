---
title: "Requirements Traceability, Attributes, TBX, and AMBSE Model-Based Requirements"
slug: requirements-traceability-and-attributes
type: reference
layer: needs-and-reqs
tags: [traceability, attributes, tbx, ambse, model-based-requirements, vse]
sources:
  - citation: "INCOSE (2022). Guide for Writing Requirements, v1.0. Sections on Traceability, Attributes, TBX, and Model-Based Requirements."
    raw: INCOSE_NeedsAndReqs_v1.pdf
related:
  - needs-vs-requirements
  - requirements-elicitation-and-writing
  - sysml2-syntax-requirements-and-cases
  - sysml2-requirements-semantics
  - sysml2-vse-library-metadata
  - sysml2-domain-libraries-metadata-analysis
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [needs-and-requirements]
---

# Requirements Traceability, Attributes, TBX, and AMBSE Model-Based Requirements

For the core distinction and categorisation, see
[[needs-vs-requirements]]. For elicitation and writing rules,
see [[requirements-elicitation-and-writing]].

## Traceability

Traceability links provide the evidence chain from stakeholder
needs through requirements to design, verification, and
validation. The Guide identifies ten traceability types:

| Type | Links |
|---|---|
| Source | Requirement to its origin (stakeholder, regulation, standard) |
| Parent/Child | Higher-level requirement to derived lower-level requirements |
| Allocation | Requirement to the system element responsible for satisfying it |
| Peer | Requirement to related requirements at the same level |
| Interface | Requirement to the interface definition it constrains |
| Dependency | Requirement to other requirements it depends on |
| Design | Requirement to the design element that implements it |
| Verification | Requirement to the verification activity that confirms compliance |
| Validation | Need to the validation activity that confirms stakeholder satisfaction |
| Model entity | Requirement to the model element that represents it (e.g., SysML block) |

For a VSE, maintain at minimum: Source, Parent/Child,
Allocation, and Verification traceability. A spreadsheet-based
trace matrix is acceptable for projects with fewer than 200
requirements.

In SysML 2.0, the satisfy and verify links operationalise
several of these trace types directly: see
[[sysml2-requirements-semantics]] for the satisfy/verify
semantics and [[sysml2-syntax-requirements-and-cases]] for the
syntax.

## Requirement attributes

Each requirement should carry metadata attributes. For a VSE,
the following subset (from NRM Table 11) is recommended:

| Attribute | Purpose |
|---|---|
| Unique ID | Unambiguous identification (e.g., REQ-SEN-001) |
| Statement | The "shall" text |
| Rationale | Why this requirement exists |
| Source | Origin (stakeholder, standard, derived) |
| Priority | Must-have, Should-have, Nice-to-have (MoSCoW or similar) |
| Status | Draft, Approved, Verified, Validated |
| Verification method | Test, Analysis, Inspection, or Demonstration |
| Allocation | System element responsible |
| Parent need | Link to the need this requirement satisfies |
| TBX flag | TBD, TBR, TBS, or TBC if any value is not yet finalised |

In a SysML 2.0 model, these attributes are typically applied as
metadata. The plugin's `VSE_Library` provides
`StatusInfo`-style and `RiskInfo` definitions that work for
status, owner, and priority annotations. For variant-aware
requirements (one requirement that applies only to some product
configurations), use `VariantScope` from the same library. See
[[sysml2-vse-library-metadata]] for these definitions and
[[sysml2-domain-libraries-metadata-analysis]] for the broader
SysML metadata catalogue (`StatusInfo`, `Risk`,
`MeasureOfPerformance`, `MeasureOfEffectiveness`).

## TBX management

Unresolved items in requirements must be tracked and resolved
before design proceeds:

- **TBD (To Be Determined).** The value or information is not
  yet known. Requires investigation or stakeholder input.
- **TBR (To Be Resolved).** A conflict or ambiguity exists
  that must be resolved through negotiation or analysis.
- **TBS (To Be Specified).** The requirement exists but its
  detailed specification is deferred to a later phase.
- **TBC (To Be Computed).** The value requires calculation,
  simulation, or modelling to establish.

Maintain a TBX register with columns: ID, TBX Type,
Description, Owner, Due Date, Status. For a VSE, resolve all
TBDs and TBRs before the System Requirements Review (SRR)
milestone. TBS and TBC items may carry forward with a
resolution plan.

## Model-based requirements (AMBSE)

When using agile model-based SE, requirements exist as model
elements within the SysML v2 repository alongside the
behavioural and structural models that specify the system. This
**dual representation** (text + model) combines the
expressiveness of natural language with the precision of formal
models.

### Use case driven elicitation in AMBSE

Use cases provide an additional elicitation technique that
complements the eight techniques in
[[requirements-elicitation-and-writing]]. Each use case
captures a coherent set of actor-system interactions that
deliver value to a stakeholder. Scenarios within use cases
(normal flow, alternate flows, exception flows) systematically
generate stakeholder needs by examining each step where the
system must respond.

For the SysML 2.0 case family that captures these scenarios,
see [[sysml2-cases-overview]] and [[sysml2-case-kinds]].

### Models as the primary medium

In AMBSE, the model is the **primary** work product. Textual
requirements are linked to (not separate from) model elements.
This enables nanocycle verification (20 to 60 minutes):
validate syntax, check traceability, review with a colleague,
and repeat. The full continuous-verification model lives in the
AMBSE knowledge layer (pending Phase 4 migration).

## VSE practical guidance

For a VSE applying this guide:

1. **Start with stakeholder interviews.** Two to three focused
   interviews with key stakeholders (customer, user, regulator)
   will capture 80% of needs.
2. **Use the five-category framework** (Function, Fit, Form,
   Quality, Compliance, see [[needs-vs-requirements]]) to check
   for gaps in your needs set.
3. **Write requirements early and iterate.** Do not wait for a
   perfect needs set. Transform needs to requirements
   progressively as understanding deepens.
4. **Plan verification when writing.** Assign a verification
   method to each requirement immediately. If you cannot
   identify a method, the requirement is not verifiable and
   must be rewritten. See
   [[requirements-elicitation-and-writing]] for the verification
   methods catalogue.
5. **Keep traceability simple.** A single spreadsheet with
   columns for Need ID, Need Text, Requirement ID, Requirement
   Text, Allocation, and Verification Method provides
   sufficient traceability for most VSE projects.
6. **Manage scope actively.** Every new requirement after
   baseline requires a change request assessing impact on
   cost, schedule, and risk. This discipline prevents scope
   creep even in informal VSE environments.
7. **Review requirements with stakeholders.** Even a brief
   30-minute walkthrough of requirements with the customer
   catches misunderstandings early. Use the verification
   checklist (D3 in [[requirements-elicitation-and-writing]])
   as a structured review guide.

## See also

- [[needs-vs-requirements]] for the core distinction and
  five-category framework.
- [[requirements-elicitation-and-writing]] for elicitation
  techniques, writing rules, and verification methods.
- [[sysml2-syntax-requirements-and-cases]] for the SysML 2.0
  syntax that captures these requirements and their links.
- [[sysml2-requirements-semantics]] for the formal semantics.
- [[sysml2-vse-library-metadata]] for the plugin's
  `VSE_Library` (RiskInfo, ConfigItem, VariantScope).
- [[sysml2-domain-libraries-metadata-analysis]] for the SysML
  domain library `StatusInfo` and related metadata.
