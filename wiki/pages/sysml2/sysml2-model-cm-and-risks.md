---
title: "Model-Level Configuration Management and Risks in AMBSE Models"
slug: sysml2-model-cm-and-risks
type: pattern
layer: sysml2
tags: [configuration-management, baselines, configitem, risks, riskinfo, iso29110]
sources:
  - citation: "ISO/IEC TR 29110-5-6-2:2014. PM.1.11, PM.1.13, PM.1.18, PM.2.3, PM.2.5, PM.O5, PM.O6, SR.O6."
    raw: ISO_IEC_29110_System_Software_Engineering.pdf
  - citation: "Galinier, A. et al. (2024). Systems Engineering Practices for Small and Medium Enterprises."
    raw: Galinier_SME_Practices_2023.pdf
related:
  - sysml2-canonical-model-layout
  - sysml2-vse-library-metadata
  - sysml2-metadata-definitions
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-model-structure]
---

# Model-Level Configuration Management and Risks in AMBSE Models

This page introduces **model-level** configuration management and
**model-level** risk modelling as first-class patterns in the
canonical layout. Both complement (rather than replace)
process-level artefacts in the Project Plan and SEMP. For the
underlying metadata mechanism see
[[sysml2-vse-library-metadata]] and [[sysml2-metadata-definitions]].

## Model-level configuration management

The process-level **Configuration Management Strategy** lives in
`templates/pm/project-plan.md` Section 9 (PM.1.13 output) and
`templates/sr/semp.md` Section 4.3. The model-level pattern
introduced here does not replace those artefacts. It complements
them with a machine-readable surface that the Automator can
query, that `traceability-guard` can check, and that a release
tag on `main` can cross-reference.

### Scope split

| Layer | Artefact | Owns |
|---|---|---|
| Process | Project Plan Section 9, SEMP Section 4.3 | Baseline naming conventions, retention rules, repository structure, change-request authority, backup strategy |
| Model | `{{sc}}_CM` package, `ConfigItem` and `Baseline` metadata | Which elements are CIs, their CI state, which baseline they belong to, the baseline scope |

Neither layer is complete without the other. The Project Plan
tells the team **when** and **how** to baseline. The model-level
pattern tells the tools **what** is in each baseline.

### `ConfigItem` as metadata

SysML 2.0 has no built-in CI keyword. The plugin models CI state
with a user-defined `metadata def` called `ConfigItem` from the
`VSE_Library`. Attributes: `ciId`, `baselineId`, `state` (Draft,
Baselined, UnderChange, Superseded, Retired), `owner`. Applied
with the `@` syntax to any element under configuration control.

### `Baseline` as an item def

Baselines are first-class elements. Declare them as `item def`
instances inside `{{sc}}_CM`, one per baseline. Each carries:

- a unique `id` (`BL-SRS-0.3`)
- `date`
- `description`
- a `scope` reference list naming the CIs it freezes
- a `supersedes` reference to the previous baseline (empty for
  the initial one)

A release tag on `main` names a baseline, the baseline names its
CIs, and each CI names the element frozen.

### Authority boundary

Project Plan Section 9.2 owns **when** baselines are taken and
**who** authorises them. The `{{sc}}_CM` package owns **what**
each baseline contains. A Change Request initiated under PM.2.5
references model-level CIs rather than naming them in prose.

### Optional `{{sc}}_CM` package

Scaffolded only in the Canonical AMBSE tier and only when the
engineer opts in. Contains a `doc` comment citing Project Plan
Section 9, an initial `BL-INIT` baseline item def, and a
placeholder scope list.

### ISO 29110 activity mapping

| Activity | Model-level action |
|---|---|
| PM.1.13 Document Configuration Management Strategy | Write Project Plan Section 9 prose. Optionally scaffold `{{sc}}_CM` on opt-in. |
| PM.1.18 Establish the Project Repository | Initialise the repository and the first `BL-INIT` baseline item def. |
| PM.2.5 Perform configuration management | Update `ConfigItem` metadata on each CM event. Create a new `Baseline` item def on each baseline event. |
| PM.O6 Product Management Strategy developed | Satisfied when CIs are identified, defined, baselined, and controlled via the model surface. |
| SR.O6 System Configuration baselined | Satisfied when the release-tag baseline exists and every SR-produced CI is in the `Baselined` state. |

## Model-level risk modelling

Risks are mandatory engineering artefacts under ISO/IEC 29110
PM.O5, PM.1.11, PM.2.3, and PM.3.1. In a VSE context they are
often tracked in a spreadsheet that sits outside the engineering
workspace, where they fall out of date. The canonical layout
moves them into the model so the engineer encounters them
structurally.

### Risks as a dedicated package

`{{sc}}_Risks` is a **mandatory** top-level package (see
[[sysml2-canonical-model-layout]]). Keeping risks in their own
package gives them a home that can be imported selectively,
versioned alongside the model, and queried via the Automator
without touching the requirements namespace.

### `RiskInfo` metadata and risk item defs

SysML 2.0 has no built-in Risk keyword. The plugin models risk
with a `metadata def` called `RiskInfo` (severity, likelihood,
status, owner, `mitigatedBy` reference). Applied with the `@`
syntax on any element carrying a risk (requirement body, use case
step, architecture element, or standalone risk item def inside
`{{sc}}_Risks`).

Standalone risks not yet attached to a specific element are `item
def` instances inside `{{sc}}_Risks` with a unique identifier, a
description, and `RiskInfo` applied. When the risk is mitigated,
the register entry gains references to the responsible
requirement and the verification case.

### Risk assessment scales

A five-level severity-by-likelihood matrix is the default: `Low`,
`Moderate`, `High`, `VeryHigh`, `Critical`. Encode the scale as
an enumeration inside `{{sc}}_Risks` so it cannot drift between
projects. Galinier et al. argue that VSE risk registers are
typically under-used because they sit outside the engineering
workspace. Moving them into the model removes the handoff
friction.

### Traceability chain including risk

The plugin extends its existing trace chain with advisory risk
links:

```text
Stakeholder Needs
    -> (concern drives)
Risks
    -> (mitigated by)
System Requirements
    -> (verified by)
Verification Cases
```

`traceability-guard` already enforces the satisfy and verify
backbone. Risk links are advisory in this release. Full
enforcement lands with the follow-up `risk-management` workflow
skill.

### ISO 29110 activity mapping

| Activity | Model-level action |
|---|---|
| PM.1.11 Document Risk Management Approach | Write Project Plan Risk section and scaffold `{{sc}}_Risks` with the initial scale. |
| PM.2.3 Review risk status in revision meetings | Update `RiskInfo.status` on affected entries. |
| PM.3.1 Evaluate project progress including risk | Query the register by severity and status. |
| PM.O5 Risk Management Approach developed | Satisfied when risks are identified, analysed, prioritised, and monitored inside the model. |

## Red flags

- Baselines declared in the Project Plan only, with no
  `{{sc}}_CM` package.
- `ConfigItem` metadata whose `baselineId` does not resolve to a
  `Baseline` item def (orphan CI).
- A `Baseline` scope that names elements not in `Baselined`
  state.
- Every risk must have an owner and a status. An unowned risk is
  silent debt.

## Pending material

- `risk-management` workflow skill (full
  identify-assess-mitigate-monitor loop).
- `cm-workflow` skill (full identify-baseline-change-retire
  loop).

## See also

- [[sysml2-canonical-model-layout]] for the canonical package
  set, including `{{sc}}_Risks` and optional `{{sc}}_CM`.
- [[sysml2-vse-library-metadata]] for the centralised metadata
  definitions used by these patterns.
- [[sysml2-metadata-definitions]] for the ordinary metadata
  syntax.
