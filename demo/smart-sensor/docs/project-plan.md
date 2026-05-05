# Project Plan — Smart Sensor

Per methodology §10.3.

## Identification

- **Project:** Smart Sensor
- **Acquirer:** dogfood (internal demo)
- **Date created:** 2026-05-05
- **Plan baseline:** `plan-baseline-v0.1` (initial)
- **Plan owner:** Project Manager (PJM)

## Scope and product description

The Smart Sensor is a small Wi-Fi-connected environmental sensor delivered to a deployment-site operator through a cloud dashboard. The system reports temperature and humidity, raises threshold alerts, and lets the operator acknowledge alerts in batches. A maintenance technician calibrates the device against a portable reference probe in the field.

The Base Architecture (the parent product line's reference platform) is the ESP32-WROOM-32E MCU and a managed-cloud MQTT 5.0 broker. Both are recorded in `model/core/base-architecture/` and are not within the scope of this project's trade studies.

## Stakeholders and roles

For the demo, one contributor fills every ISO 29110 role. In a real project, this section enumerates the Work Team members and lists which person holds which role. Roles per §10.11.

## Methodology reference

This project applies the story-driven AMBSE methodology shipped at `methodology/`. The project-local copy is authoritative for this project. Where the methodology reference disagrees with §10 of the SEMP, the methodology wins.

## Schedule

The schedule is the story register. Releases group `done` stories under `release-vN.M` tags. The current release plan lives in `docs/releases/`.

## Risk management

See `docs/risk-register.md`. Risks are reviewed at every release boundary and at any §6 trade-study disposition.

## Configuration management

See `docs/cm-strategy.md`. Baselined paths are listed in `.iso-config.yaml`. Edits require an open Change Request.

## Verification and validation

The §10.3.2 SEMP section is rendered from `model/core/verification-validation/` by the IVV Plan renderer (`tools/render/ivv-plan.py`). Stub renderer until first real release.

## Closure

Closure follows §10.5 / §10.6. Product Acceptance Record is generated on the final release.
