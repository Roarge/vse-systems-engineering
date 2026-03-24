# Smart Sensor Demo Project

A minimal VSE systems engineering project demonstrating the full ISO/IEC 29110
lifecycle using the `vse-systems-engineering` plugin.

## System description

A smart temperature sensor system for indoor climate monitoring. The system
reads ambient temperature, applies threshold logic, and sends alerts when
temperature exceeds configurable bounds.

## Project structure

```
smart-sensor/
├── .vse-phase              Phase tracker (currently SR.5)
├── .gitignore              Ignores build/ and generated files
├── syside.toml             SySiDE configuration
├── TASKS.md                ISO 29110 task checklist
├── README.md               This file
├── models/
│   ├── package.sysml       Root package (imports all domains)
│   ├── stakeholder-needs.sysml  5 stakeholder needs (STK-001 to STK-005)
│   ├── system-requirements.sysml  8 system requirements (REQ-001 to REQ-008)
│   ├── architecture.sysml  Part definitions, ports, connections, behaviour
│   ├── verification.sysml  8 verification cases (VER-001 to VER-008)
│   └── validation.sysml    5 validation cases (VAL-001 to VAL-005)
├── docs/
│   ├── pm/                 PM work product templates (6 files)
│   │   ├── project-plan.md
│   │   ├── progress-status.md
│   │   ├── meeting-record.md
│   │   ├── change-request.md
│   │   ├── correction-register.md
│   │   └── product-acceptance.md
│   └── sr/                 SR work product templates (9 files)
│       ├── semp.md
│       ├── stakeholder-requirements.md
│       ├── system-requirements.md
│       ├── traceability-matrix.md
│       ├── system-design.md
│       ├── ivv-plan.md
│       ├── verification-report.md
│       ├── validation-report.md
│       └── maintenance-guide.md
└── build/                  Generated outputs (gitignored)
```

## Traceability chain

Every requirement traces upward to a stakeholder need via `satisfy` links
and downward to a verification case via `verify` links. Every stakeholder
need has a validation case.

```
STK-001 MonitorTemperature
  ├── REQ-001 MeasureTemperature    -> VER-001 VerifyTempAccuracy
  └── REQ-002 SamplingRate          -> VER-002 VerifySamplingRate
  └── VAL-001 ValidateMonitoring

STK-002 ReceiveAlerts
  ├── REQ-003 ThresholdAlert        -> VER-003 VerifyAlertActivation
  └── REQ-004 AlertClear            -> VER-004 VerifyAlertClear
  └── VAL-002 ValidateAlerts

STK-003 ConfigureThresholds
  └── REQ-005 ThresholdConfiguration -> VER-005 VerifyThresholdConfig
  └── VAL-003 ValidateConfiguration

STK-004 EasyToRead
  └── REQ-006 DisplayReadability    -> VER-006 VerifyDisplayReadability
  └── VAL-004 ValidateReadability

STK-005 ReliableOperation
  ├── REQ-007 OperatingLife         -> VER-007 VerifyOperatingLife
  └── REQ-008 SelfDiagnostic       -> VER-008 VerifySelfDiagnostic
  └── VAL-005 ValidateReliability
```

## How to use with the plugin

1. **Navigate lifecycle**: invoke `@lifecycle-orchestrator` to see current phase and next actions
2. **Capture needs**: invoke `@needs-and-requirements` to review stakeholder needs and derive system requirements
3. **Design architecture**: invoke `@architecture-design` to develop the system design
4. **Plan V&V**: invoke `@verification-validation` to create verification and validation cases
5. **Check traces**: invoke `@traceability-guard` to verify all trace links
6. **Model syntax**: invoke `@sysml2-modelling` for SysML 2.0 authoring help
7. **Environment health**: invoke `@attention-regime` for a project health check
8. **Export documents**: invoke `@document-export` to generate docx/pptx from work products
9. **Bootstrap new projects**: invoke `@project-setup` to create a project with this structure from scratch

## Purpose

This demo walks through every ISO 29110 phase using all nine plugin skills,
producing SysML 2.0 models with full bidirectional traceability and ISO 29110
work product templates ready for population.
