# Smart Temperature Sensor

This project follows ISO/IEC 29110 (Basic Profile) for Very Small Entity (VSE)
systems engineering. All work is governed by the VSE Systems Engineering plugin.

## VSE-First Rule

When answering any question about this project:

1. Consult the VSE Systems Engineering plugin skills first
2. Check the current lifecycle phase in `.vse-phase`
3. Apply phase-appropriate guidance (see the plugin CLAUDE.md)
4. Warn if the requested action is out of phase

If the VSE plugin is not installed, follow the ISO 29110 process map below.

## Current Phase

Read the `.vse-phase` file in the project root to determine the active phase.
At the start of every SE-related interaction, state:

- **Current phase**: which ISO 29110 activity is active
- **Phase inputs**: what work products should already exist
- **Next action**: what the engineer should work on next

Read the `.vse-journal.yml` file to understand what was done in the previous
session and what the engineer should work on next. If the file exists and has
entries, present a SESSION CONTINUITY block after the phase information:

- **Last session**: when the previous session occurred
- **Summary**: what was accomplished
- **Pending**: next steps from the previous session
- **Open issues**: unresolved items needing attention

### Phase-Based Filtering

| Current Phase | Focus on | Defer |
|---------------|----------|-------|
| SR.1 Initiation | SEMP, data model, environment setup | Requirements methods, architecture |
| SR.2 Requirements | Stakeholder needs, SMART criteria, elicitation | Architecture trade-offs, V&V methods |
| SR.3 Architecture | Decomposition, interfaces, trade-offs | Requirements elicitation, test design |
| SR.4 Construction | Build/buy/reuse, component specs | Requirements changes, architecture alternatives |
| SR.5 IVV | Verification methods, test derivation, trace checking | Requirements changes, architecture redesign |
| SR.6 Delivery | Acceptance, documentation, training, maintenance | All upstream activities |

If the engineer asks about a topic outside the current phase, provide the
information but flag it: "Note: this relates to [phase], not the current
phase [current]. Consider whether a Change Request is needed."

## Source Processing Order

1. **ISO/IEC 29110** (process backbone): what activities to perform
2. **PHAS-EAI framework** (design rationale): why those activities work
3. **INCOSE SE Handbook** (best practices): how to execute, scaled for VSEs
4. **SysML 2.0 specification** (modelling language): machine-readable models

## Project Information

- **Project:** Smart Temperature Sensor
- **Acquirer:** Facility Management AS
- **Date created:** 2026-02-28
- **Author:** Roar Georgsen

## Project Structure

```
models/           SysML 2.0 model files (.sysml)
docs/pm/          Project Management work products
docs/sr/          System Definition and Realisation work products
TASKS.md          ISO 29110 task checklist
```

## Traceability Chain

```
Stakeholder Needs (STK-)
    | satisfy
System Requirements (REQ-)
    | satisfy
System Element Requirements (ELE-)
    | verify
Verification Cases (VER-)

Validation Cases (VAL-)
    | verify (back to stakeholder needs)
```

Every system requirement MUST trace upward to at least one stakeholder need
via a `satisfy` link. Every system requirement MUST trace downward to at least
one verification case via a `verify` link. Every stakeholder need MUST have at
least one validation case. Phase transitions MUST NOT proceed if trace gaps
exist.

## SysML 2.0 Conventions

- Package names: `PascalCase` (e.g., `SmartSensor`)
- Definition names: `PascalCase` (e.g., `part def TemperatureSensor`)
- Usage names: `camelCase` (e.g., `part tempSensor : TemperatureSensor`)
- Requirement IDs: `REQ-` prefix (e.g., `REQ-001`)
- Stakeholder need IDs: `STK-` prefix (e.g., `STK-001`)
- Element requirement IDs: `ELE-` prefix (e.g., `ELE-001`)
- Verification case IDs: `VER-` prefix (e.g., `VER-001`)
- Validation case IDs: `VAL-` prefix (e.g., `VAL-001`)
- All trace links use `satisfy` and `verify` keywords in SysML 2.0

### Trace Link Syntax

```sysml
// Upward: system requirement satisfies stakeholder need
requirement def MeasureTemperature :> SystemRequirement {
    doc /* The system shall measure temperature within +/- 0.5 C. */
    satisfy requirement StakeholderNeeds::MonitorTemperature;
}

// Downward: verification case verifies system requirement
verification def VerifyTempAccuracy {
    doc /* Verify temperature measurement accuracy. */
    verify requirement SystemRequirements::MeasureTemperature;
}
```

## Roles

This is a VSE project. One person may fill multiple roles. Document which
person holds which role in `docs/pm/project-plan.md`.

| Role | Abbr | Responsibility |
|------|------|----------------|
| Project Manager | PJM | Planning, monitoring, control, repository management |
| Systems Engineer | SYS | Requirements, architecture, V&V coordination |
| Designer | DES | Functional and physical design, interface definitions |
| Developer | DEV | Construction of software and hardware elements |
| IVV Engineer | IVV | Integration, verification, validation execution |
| Acquirer | ACQ | Customer acceptance, needs provision |
| Stakeholder | STK | Needs and concerns provision across lifecycle |
| Work Team | WT | All internal team members collectively |
| Supplier | SUP | External provider of system elements |

## ISO 29110 Process Map

### Project Management (PM)

| Activity | Objective |
|----------|-----------|
| PM.1 Project Planning | Establish plan, assign resources, obtain acquirer acceptance |
| PM.2 Plan Execution | Monitor progress, manage changes, conduct reviews |
| PM.3 Assessment and Control | Evaluate against plan, take corrective actions |
| PM.4 Closure | Formalise completion, baseline repository, execute disposal |

### System Definition and Realisation (SR)

| Activity | Objective |
|----------|-----------|
| SR.1 Initiation | Set up SEMP, data model, implementation environment |
| SR.2 Requirements | Elicit needs, derive system and element requirements |
| SR.3 Architecture | Design functional and physical architecture |
| SR.4 Construction | Build, buy, or reuse system elements |
| SR.5 IVV | Integrate, verify against requirements, validate against needs |
| SR.6 Delivery | Review product, prepare maintenance and training, deliver |

## Phase Gate Checklist

Before advancing the phase in `.vse-phase`, verify:

- All required work products for the current phase exist in `docs/`
- All SysML trace links are complete (the pre-commit hook checks this)
- The phase gate criteria in `TASKS.md` are satisfied
- The Traceability Matrix in `docs/sr/traceability-matrix.md` is current

## Writing Style

- UK English throughout (organisation, behaviour, modelling)
- Clear, precise, evidence-grounded language
- Plain language first, specialist terms introduced with explanation
- Cross-disciplinary audience assumed
