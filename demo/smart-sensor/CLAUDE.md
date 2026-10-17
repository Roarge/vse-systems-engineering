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
- **Toolchain:** omg-pilot (SysML v2 validator per `.iso-config.yaml`
  `sysml_toolchain`)
- **Test-first:** not applicable, no implementation code (whether test
  first applies and the test command, per `.iso-config.yaml`
  `test_first`, methodology §11.5)

## Methodology

The project-local `methodology/` folder is authoritative for this
project. The plugin-shipped copy at
`${CLAUDE_PLUGIN_ROOT}/methodology/` is the fallback when a section
file is absent locally.

Consult it before answering any methodology question, and cite the
section number in the answer. If the VSE plugin is not installed,
follow `methodology/` directly.

## Lens

Invoke the `vse-companion-overview` skill at the start of engineering
work. It sets the methodology lens, routes the request to the right
specialist skill, and carries the conventions this file does not
restate.

## Pointers, not restatements

- Behaviour first: a story's Gherkin feature file and its scenarios
  come before its SysML, its cases and any design: §11.2 to §11.4.
- Test first: where it applies, the failing test comes before the
  code, and an installed test-driven development skill governs the
  cycle: §11.5 to §11.7.
- Gates that block at every profile, and the self-bypass rule: §11.9
  and §11.10.
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
demo, one contributor fills every ISO/IEC 29110 role.

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
      stakeholder/          US_001..US_004, one <ID>.feature per story
      system/               SYS_001..SYS_004 (derive from stakeholder),
                            one <ID>.feature per story
    use-cases/              §1.4.5 elaborations
    logical-architecture/
      interface-types/      Reusable interface defs
    verification-validation/
      verification-cases/   VC_001..VC_004
      validation-cases/     VAL_001..VAL_004
    core.sysml              top-level package declaration
  variations/               §6 trade-study mechanism
    decision-points/        AlertHistoryStorageStrategy
    trade-studies/          AlertHistoryStorageTrade
    resolved/               Selected variant
  library/                  vse-library.sysml (UserStory, etc.)
tools/
  render/                   Renderers for docs/generated/ (§9.8)
  lint/                     Story lint (§11.9.1)
docs/
  generated/                Renderer output (two specifications, one matrix)
  project-plan.md           §10.3 Project Plan
  semp.md                   SR.1 Systems Engineering Management Plan
  risk-register.md          §10.7
  cm-strategy.md            §10.8
  correction-register.md    PM.3 Correction Register
  progress-status-record.md PM.2 Progress Status Record
  decisions/                ADRs
  meetings/                 Meeting Records
  releases/                 Release plans
.iso-config.yaml            ISO/IEC 29110 hook configuration
```

## SysML 2.0 naming conventions

- Package names: `PascalCase` with `SmartSensor_` prefix.
- User Story IDs: `US_<n>_<ShortName>` per §1.6.
- System story IDs: `SYS_<n>_<ShortName>`.
- Verification case IDs: `VC_<n>_<ShortName>`.
- Validation case IDs: `VAL_<n>_<ShortName>`.
- Stories are requirement usages: `requirement US_<n>_<ShortName> :
  UserStory { ... }`. Verify targets use dot notation, as in
  `verify US_<n>_<ShortName>.acceptance.<criterion>`.
- Feature files: `<ID>.feature` beside the register that declares the
  story, tagged `@<ID>`, one `@AC_<criterion>` scenario per named
  criterion, with criterion names in lowerCamelCase (words run
  together, each after the first capitalised, as in
  `latestReadingShown`) (§11.2, §11.3).
