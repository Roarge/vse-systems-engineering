---
project: "Smart Sensor"
version: "0.1"
date: "2026-08-13"
author: "vse-systems-engineering plugin contributor"
status: draft
work_product: "Systems Engineering Management Plan"
iso_ref: "SR.1"
---

# Systems Engineering Management Plan (SEMP)

## Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 0.1 | 2026-08-13 | vse-systems-engineering plugin contributor | Initial draft |

<!-- VSE-TASK: SR.1.2 -->

## 1. Purpose and Scope

This SEMP defines how the systems engineering effort for the Smart
Sensor is planned and conducted. Project scope, schedule, roles, and
management artefacts are owned by `docs/project-plan.md` (§10.3).
Where this SEMP and the methodology specification at `methodology/`
disagree, the methodology wins.

## 2. Technical Activities

<!-- VSE-TASK: SR.1.2 -->

### 2.1 Requirements Engineering

- **Elicitation methods:** persona-driven stakeholder elicitation
  per §4, using the stakeholder register
  (`model/core/stakeholders/`) and concerns
  (`model/core/concerns/`).
- **Specification format:** SysML 2.0 textual notation (`.sysml`
  files). Stakeholder stories US_001 to US_004 and system stories
  SYS_001 and SYS_002 with `require constraint` benefits per §5.
- **Validation approach:** stakeholder review of the story register
  plus validation cases VAL_001 to VAL_004 for stakeholder-side
  checks.

### 2.2 Architectural Design

- **Functional decomposition method:** story-driven decomposition
  per §7, with use-case elaborations per §1.4.5.
- **Physical allocation method:** trade studies per §6, with
  criteria sourced from story benefit constraints (the §0.3
  connective mechanism). Worked instance:
  `model/variations/trade-studies/` (AlertHistoryStorageTrade).
- **Modelling tool:** Sensmetry Syside (SysML 2.0), configured by
  `syside.toml`.
- **Constraints:** the Base Architecture (§2) fixes the
  ESP32-WROOM-32E MCU and the managed-cloud MQTT 5.0 broker
  (`model/core/base-architecture/`). Both sit outside trade-study
  scope.

### 2.3 Construction

Build on the Base Architecture platform. Firmware and dashboard
construction reuse the parent product line's toolchains. No
build-versus-buy decisions are open in the current release scope.

### 2.4 Integration, Verification, and Validation

- **Integration strategy:** incremental, following the story order
  of the release plan (`docs/releases/`).
- **Verification methods:** verification cases VC_001 and VC_002
  (`model/core/verification-validation/verification-cases/`), one
  per acceptance criterion, methods per §9 scale mapping.
- **Validation approach:** validation cases VAL_001 to VAL_004
  against stakeholder stories, exercised at release boundaries.

## 3. Data Model

<!-- VSE-TASK: SR.1.3 -->

### 3.1 Key Entities

| Entity | Description | Managed In |
|--------|-------------|------------|
| Stakeholder story | Canonical stakeholder-intent artefact (§1) | `model/core/stories/stakeholder/` |
| System story | Derived story with formalised benefit constraint (§5) | `model/core/stories/system/` |
| Concern | Stakeholder concern framed by stories | `model/core/concerns/` |
| System element | Logical architecture and interface types (§7) | `model/core/logical-architecture/` |
| Decision point | Variation with trade-study criteria (§6) | `model/variations/` |
| Verification case | Verifies a system-story acceptance criterion | `model/core/verification-validation/verification-cases/` |
| Validation case | Validates a stakeholder story | `model/core/verification-validation/validation-cases/` |

### 3.2 Relationships

Stakeholder stories are refined by system stories through `derive`.
System stories are allocated to system elements. Acceptance criteria
are verified by verification cases, and stakeholder stories are
validated by validation cases. Trace integrity per the §9 mapping is
checked by the traceability guard and the project-side `pre-commit`
hook.

## 4. Implementation Environment

<!-- VSE-TASK: SR.1.4 -->

### 4.1 Development Tools

| Tool | Purpose | Version |
|------|---------|---------|
| Sensmetry Syside | SysML 2.0 modelling | per `syside.toml` |
| Git | Version control, story branches per §8 | system |
| Claude Code | SE companion (designed cognitive reserve) | with the vse-systems-engineering plugin |

### 4.2 Repository Structure

```
model/            SysML 2.0 source (core, variations, library)
docs/             PM and SR work products, ADRs, releases
methodology/      Project-local methodology specification
.iso-config.yaml  ISO 29110 hook configuration
```

The authoritative tree is documented in `CLAUDE.md` (per §8.3).

### 4.3 Configuration Management

See `docs/cm-strategy.md` (§10.8). Baselined paths are listed in
`.iso-config.yaml` and edits to them require an open Change Request.

## 5. Technical Reviews

| Review | Phase Gate | Participants | Inputs |
|--------|-----------|--------------|--------|
| Requirements Review | SR.2 to SR.3 | PJM, SYS, ACQ, STK | Story register, traceability matrix |
| Design Review | SR.3 to SR.4 | PJM, SYS, DES, DEV | Trade-study record, logical architecture |
| Test Readiness Review | SR.4 to SR.5 | PJM, SYS, IVV | Verification and validation cases |
| Product Acceptance Review | SR.5 to SR.6 | PJM, SYS, ACQ | Verification and validation reports |

For the demo, one contributor fills every role (see the Project
Plan).

## 6. Technical Performance Measures

| Measure | Target | Measurement Method | Review Frequency |
|---------|--------|-------------------|------------------|
| Dashboard alert latency | per SYS_001 benefit constraint | VC_001 verification | each release |
| Batch acknowledgement round-trip | per SYS_002 benefit constraint | VC_002 verification | each release |

## Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Project Manager | vse-systems-engineering plugin contributor | 2026-08-13 | (demo, unsigned) |
| Systems Engineer | vse-systems-engineering plugin contributor | 2026-08-13 | (demo, unsigned) |
