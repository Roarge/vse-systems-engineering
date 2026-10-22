# Smart Sensor (demo project)

A worked example of the story-driven AMBSE methodology applied to a small connected-sensor product. The project is fictitious. The artefacts in this directory exercise the methodology end to end so a reader can see how the pieces fit together: stakeholders, concerns, stakeholder stories, system stories, base architecture, system context, a trade study, verification cases, the Project Plan, and the supporting governance artefacts (Risk Register, CM Strategy, ADRs).

## What the smart sensor is

The Smart Sensor is a small embedded device that streams temperature and humidity readings from a single deployment site (a greenhouse, a cold-store, or a server room) to a cloud-hosted dashboard. The device is wired-powered, mounted on a wall or rail, and uses Wi-Fi for connectivity. The system of interest is the device firmware plus the cloud ingest path, treated as one product. The customer-facing operator monitors readings and acknowledges alerts. A maintenance technician installs and calibrates the device.

This scope is small enough to fit on one page yet exercises all the methodology's foundational artefacts and at least one architectural trade study.

## Where to start

If you have read the methodology specification at `methodology/`, start with the stakeholder stories under `model/core/stories/stakeholder/`. They name the operators and maintainers of the device and frame the concerns the project addresses. Each story's acceptance criteria are the Gherkin scenarios (concrete Given/When/Then examples) in its feature file beside it, for example `US_001_SeeReadingsOnDashboard.feature`, and the story mirrors each scenario with a named criterion (methodology §11.3). The cases under `model/core/verification-validation/` verify each criterion by its full path, as in `verify US_001_SeeReadingsOnDashboard.acceptance.latestReadingShown`.

If you have not read the methodology yet, read `methodology/00-methodology-overview.md` first. The four-section structure (foundational artefacts §1–§3, workflow stages §4–§7) maps directly onto the directory layout under `model/core/`.

## Layout

```text
methodology/                Project-local methodology copy
model/
  core/
    stakeholders/           Operator, MaintenanceTechnician, Regulator
    concerns/               StableMonitoring, AlertResponseTime, DeviceServiceability, DataRetentionCompliance
    base-architecture/      ESP32 MCU platform, MQTT 5.0 broker
    context/                System Context with operator, maintainer, dashboard, ambient climate
    domain/                 Reading, Alert, AcknowledgementCommand item defs
    stories/
      stakeholder/          US_001..004 (operator, maintainer, regulator needs)
        stakeholder-stories.sysml
        US_001_SeeReadingsOnDashboard.feature
        US_002_AcknowledgeAlertsBatched.feature
        US_003_CalibrateInField.feature
        US_004_RetainAlertHistory.feature
      system/               SYS_001..004 (derived system stories)
        system-stories.sysml
        SYS_001_DashboardLatency.feature
        SYS_002_BatchAcknowledgement.feature
        SYS_003_CalibrationOffsetCommit.feature
        SYS_004_AlertRetentionWindow.feature
    use-cases/              AcknowledgeAlertBatch (elaborates US_002)
    logical-architecture/
      interface-types/      OperatorDashboardInterface, DeviceToCloudInterface
    verification-validation/
      verification-cases/   VC_001..004 (latency, batch ack, calibration, retention)
      validation-cases/     VAL_001..004
    core.sysml              top-level package
  variations/
    decision-points/        AlertHistoryStorageStrategy
    trade-studies/          AlertHistoryStorageTrade
    resolved/               System_Configurable + System_v1
  library/                  vse-library.sysml (UserStory, StoryMeta, etc.)
tools/
  render/                   Renderers that write docs/generated/ (§9.8)
  lint/                     Story lint, stories against their feature files (§11.9.1)
docs/
  generated/                Renderer output (two specifications, one matrix)
  project-plan.md           Project Plan (§10.3)
  risk-register.md          Risk Register (§10.7)
  cm-strategy.md            CM Strategy (§10.8)
  decisions/                ADRs (e.g. 2026-04-15-alert-history.md)
  releases/                 release-v0.1-plan.md
  meetings/                 (placeholder, .gitkeep)
  audit-reports/            (placeholder, .gitkeep)
.github/
  pull_request_template.md
  CODEOWNERS
.iso-config.yaml
CLAUDE.md
CONTRIBUTING.md
.gitignore
syside.toml
```

Empty `model/core/{functional-architecture,parametrics,product-architecture,processes,logical-architecture/{allocations,components}}/` directories created by `/vse-setup` are not committed. Git does not track empty directories; running `/vse-setup` against this project recreates them.

## What this demo does NOT do

- It does not exercise a full subsystem decomposition. The §7 work is intentionally shallow so the reader can follow the trace from a stakeholder concern to a verification case without losing the thread.
- The `docs/generated/` directory holds the three renderer outputs (Stakeholders Requirements Specification, System Requirements Specification, Traceability Matrix), and CI regenerates them from the model and fails if they differ.
- It does not exercise SR.4 (Construction) or SR.6 (Product Delivery). Those activities are out of scope for the methodology per §9.2.
- It does not run its scenarios. The demo holds no implementation code, so test first does not apply (§11.5) and no scenario runner is wired. The scenarios stay the acceptance criteria that the verification and validation cases verify (§11.8).

## Validating the demo

`.iso-config.yaml` records `sysml_toolchain: omg-pilot`, so the OMG SysML v2 Pilot Implementation is the toolchain the hooks and the audit expect for this project. OpenSysML validates the same tree as a second opinion. Run both from this directory.

Pilot command (the pilot has no batch mode, so the model is fed to the interactive kernel as one `%`-delimited block):

```bash
PILOT=$HOME/.local/share/sysml-pilot/sysml
{ printf '%%\n'; cat $(find model -name '*.sysml' | sort); printf '\n%%\n%%exit\n'; } \
  | java -cp "$PILOT/jupyter-sysml-kernel-0.61.0-all.jar" \
         org.omg.sysml.interactive.SysMLInteractive "$PILOT/sysml.library"
```

The model is accepted when the output carries one root `Package` or `LibraryPackage` line per file and no `ERROR` or `WARNING` line. The Base Architecture is a `library package`, so the pilot prints `LibraryPackage` for it.

OpenSysML command:

```bash
sysml -validate $(find model -name '*.sysml' | sort)
```

The model is accepted when every file reports `✓ package` and the run ends in `no errors` with exit code 0.

Sensmetry Syside is an optional third toolchain. `syside.toml` is retained in the project for readers who use it, and nothing in the demo depends on Syside being installed.

The story lint checks every story against its feature file (methodology §11.9.1):

```bash
python3 tools/lint/story-wellformed.py model
```

The stories pass when the lint prints nothing and exits with code 0.

### Validation record

| Date | Tool | Versions | Command | Result |
|------|------|----------|---------|--------|
| 2026-09-10 | OMG SysML v2 Pilot Implementation | release 2026-07, kernel 0.61.0, `openjdk version "21.0.12" 2026-07-21` | the pilot command above, over the sixteen model files | Accepted. Sixteen root lines, fifteen `Package` and one `LibraryPackage`, no `ERROR` or `WARNING` line. |
| 2026-09-10 | OpenSysML | v0.6.0 | the OpenSysML command above, over the sixteen model files | Exit code 0. Sixteen `✓ package` lines, then `no errors`. |
| 2026-10-17 | OMG SysML v2 Pilot Implementation | release 2026-07, kernel 0.61.0, `openjdk version "21.0.12.1" 2026-08-18` | the pilot command above, over the sixteen model files, after every story's acceptance became named criteria verified by their full paths | Accepted. Sixteen root lines, fifteen `Package` and one `LibraryPackage`, no `ERROR` or `WARNING` line. |
| 2026-10-17 | OpenSysML | v0.6.0 | the OpenSysML command above, over the same sixteen files | Exit code 0. Sixteen `✓ package` lines, then `no errors`. |
| 2026-10-17 | Story lint | `tools/lint/` as vendored, Python 3.13.16 | the story lint command above, over the eight stories and their eight feature files | Exit code 0, no finding. |

Inside Claude Code, with the plugin installed:

```text
/vse-audit
```

The audit reports any gaps in story well-formedness, trace integrity, ISO/IEC 29110 artefact presence, and version drift. The demo is intended to pass the audit with a few warnings (concerns coverage and StoryMeta on a couple of mid-state stories), surfaced for the reader to inspect.

## Methodology version

The methodology copy in this directory matches the plugin version this demo ships with. To upgrade the demo to a newer methodology version, follow the upgrade flow in `methodology/README.md`.
