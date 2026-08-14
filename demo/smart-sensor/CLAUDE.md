<!-- BEGIN VSE COMPANION (managed by project-setup) -->
# Smart Sensor

A Very Small Entity systems engineering project run under the
story-driven agile MBSE methodology, ISO/IEC 29110 aligned.

## Project facts

- **Project:** Smart Sensor
- **Short code:** SmartSensor
- **Acquirer:** dogfood (internal)
- **Author:** vse-systems-engineering plugin contributor
- **Date created:** 2026-05-05
- **Engineering root:** .
- **Profile:** standard (rigour profile per methodology §0.10)

## Methodology

The project-local `methodology/` folder is authoritative for this
project. The plugin-shipped copy at
`${CLAUDE_PLUGIN_ROOT}/methodology/` is the fallback when a section
file is absent locally.

Consult it before answering any methodology question, and cite the
section number in the answer. If the VSE plugin is not installed,
follow `methodology/` directly.

## Lens

Invoke the `vse-companion-overview` skill at the start of VSE work. It
sets the methodology lens, routes the request to the right specialist
skill, and carries the conventions this file does not restate.

## Pointers, not restatements

- Branch model, pull request workflow, and review checklists: §8.
- Which artefacts and which gates this project owes at its profile:
  §0.10.
- Hook surface and configuration keys:
  `methodology/iso-29110-hooks-guide.md`.
- Project management artefacts and the Change Request lifecycle: §10.

## Writing style

- UK English throughout (organisation, behaviour, modelling).
- No em-dashes. Restructure with commas, parentheses, or "that is".
- No semicolons in body text. Split into two sentences.
- No contractions (do not, cannot, will not, it is).
- Plain language first, specialist terms introduced with explanation.
<!-- END VSE COMPANION -->

## Demo role

This project is the dogfood demo for the `vse-systems-engineering`
plugin. It exercises the installed plugin in a realistic story-driven
AMBSE workflow against a small IoT sensor product: a Wi-Fi-connected
environmental sensor reporting temperature and humidity to a cloud
dashboard, with threshold alerts and in-field calibration. For the
demo, one contributor fills every ISO 29110 role.

## Project structure (per §8.3)

```text
methodology/                Project-local methodology spec
model/
  core/
    stakeholders/           Operator, MaintenanceTechnician, Regulator
    concerns/               StableMonitoring, AlertResponseTime, ...
    base-architecture/      ESP32 MCU, MQTT broker (library package)
    context/                System Context composite
    domain/                 Reading, Alert, AcknowledgementCommand
    stories/
      stakeholder/          US_001..US_004
      system/               SYS_001, SYS_002 (derive from stakeholder)
    use-cases/              §1.4.5 elaborations
    logical-architecture/
      interface-types/      Reusable interface defs
    verification-validation/
      verification-cases/   VC_001, VC_002
      validation-cases/     VAL_001..VAL_004
    core.sysml              top-level package declaration
  variations/               §6 trade-study mechanism
    decision-points/        AlertHistoryStorageStrategy
    trade-studies/          AlertHistoryStorageTrade
    resolved/               Selected variant
  library/                  vse-library.sysml (UserStory, etc.)
docs/
  project-plan.md           §10.3 Project Plan
  semp.md                   SR.1 Systems Engineering Management Plan
  risk-register.md          §10.7
  cm-strategy.md            §10.8
  correction-register.md    PM.3 Correction Register
  progress-status-record.md PM.2 Progress Status Record
  decisions/                ADRs
  meetings/                 Meeting Records
  releases/                 Release plans
.iso-config.yaml            ISO 29110 hook configuration
```

## SysML 2.0 naming conventions

- Package names: `PascalCase` with `SmartSensor_` prefix.
- User Story IDs: `US_<n>_<ShortName>` per §1.6.
- System story IDs: `SYS_<n>_<ShortName>`.
- Verification case IDs: `VC_<n>_<ShortName>`.
- Validation case IDs: `VAL_<n>_<ShortName>`.
