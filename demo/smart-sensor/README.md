# Smart Sensor (demo project)

A worked example of the story-driven AMBSE methodology applied to a small connected-sensor product. The project is fictitious. The artefacts in this directory exercise the methodology end to end so a reader can see how the pieces fit together: stakeholders, concerns, stakeholder stories, system stories, base architecture, system context, a trade study, verification cases, the Project Plan, and the supporting governance artefacts (Risk Register, CM Strategy, ADRs).

## What the smart sensor is

The Smart Sensor is a small embedded device that streams temperature and humidity readings from a single deployment site (a greenhouse, a cold-store, or a server room) to a cloud-hosted dashboard. The device is wired-powered, mounted on a wall or rail, and uses Wi-Fi for connectivity. The system of interest is the device firmware plus the cloud ingest path, treated as one product. The customer-facing operator monitors readings and acknowledges alerts. A maintenance technician installs and calibrates the device.

This scope is small enough to fit on one page yet exercises all the methodology's foundational artefacts and at least one architectural trade study.

## Where to start

If you have read the methodology specification at `methodology/`, start with the stakeholder stories under `model/core/stories/stakeholder/`. They name the operators and maintainers of the device and frame the concerns the project addresses.

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
      stakeholder/          US_001..003 (operator and maintainer needs)
      system/               SYS_001..002 (derived system stories)
    use-cases/              AcknowledgeAlertBatch (elaborates US_002)
    functional-architecture/
    logical-architecture/
      interface-types/      OperatorDashboardInterface, DeviceToCloudInterface
      allocations/
      components/           (decomposition deferred to a later release)
    product-architecture/
    verification-validation/
      verification-cases/   VC_001 (P95 latency), VC_002 (batch ack)
      validation-cases/     VAL_001, VAL_002
    core.sysml              top-level package
  variations/
    decision-points/        AlertHistoryStorageStrategy
    trade-studies/          AlertHistoryStorageTrade
    resolved/               cloudTimeSeries selected
  library/                  vse-library.sysml (UserStory, StoryMeta, etc.)
  sandbox/                  (empty)
docs/
  project-plan.md           Project Plan (§10.3)
  risk-register.md          Risk Register (§10.7)
  cm-strategy.md            CM Strategy (§10.8)
  decisions/                ADRs (e.g. 2026-04-15-alert-history.md)
  releases/                 release-v0.1-plan.md
  meetings/                 (empty placeholder)
  audit-reports/            (empty placeholder)
sketches/
tools/
.github/
  pull_request_template.md
  CODEOWNERS
.iso-config.yaml
CLAUDE.md
CONTRIBUTING.md
.gitignore
syside.toml
```

## What this demo does NOT do

- It does not exercise a full subsystem decomposition. The §7 work is intentionally shallow so the reader can follow the trace from a stakeholder concern to a verification case without losing the thread.
- It does not run the renderer pipeline. The `docs/generated/` directory is empty. A real project's CI would populate it from the model on merge to `main`.
- It does not exercise SR.4 (Construction) or SR.6 (Product Delivery). Those activities are out of scope for the methodology per §9.2.

## Validating the demo

Inside Claude Code, with the plugin installed:

```text
/vse-audit
```

The audit reports any gaps in story well-formedness, trace integrity, ISO 29110 artefact presence, and version drift. The demo is intended to pass the audit with a few warnings (concerns coverage and StoryMeta on a couple of mid-state stories), surfaced for the reader to inspect.

## Methodology version

The methodology copy in this directory matches the plugin version this demo ships with. To upgrade the demo to a newer methodology version, follow the upgrade flow in `methodology/README.md`.
