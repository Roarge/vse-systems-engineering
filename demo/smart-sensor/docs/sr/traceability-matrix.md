---
project: "Smart Temperature Sensor"
version: "0.1"
date: "2026-02-28"
author: "Roar Georgsen"
status: draft
work_product: "Traceability Matrix"
iso_ref: "SR.2"
---

# Traceability Matrix

## Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 0.1 | 2026-02-28 | Roar Georgsen | Initial draft |

<!-- VSE-TASK: SR.2.8 -->

## Purpose

This matrix provides bidirectional traceability between stakeholder needs,
system requirements, system element requirements, and verification/validation
cases.

The authoritative source of traceability is the SysML 2.0 model files in
`models/`. This markdown document provides a human-readable summary. Use the
`@traceability-guard` skill to verify that this matrix is consistent with the
SysML 2.0 models.

## Needs to Requirements (satisfy)

| Stakeholder Need | System Requirements | Coverage |
|-----------------|-------------------|----------|
| STK-001 MonitorTemperature | REQ-001, REQ-002 | Complete |
| STK-002 ReceiveAlerts | REQ-003, REQ-004 | Complete |
| STK-003 ConfigureThresholds | REQ-005 | Complete |
| STK-004 EasyToRead | REQ-006 | Complete |
| STK-005 ReliableOperation | REQ-007, REQ-008 | Complete |

## Requirements to Element Requirements (allocate)

| System Requirement | Element Requirements | Target Element |
|-------------------|---------------------|----------------|
| REQ-001 MeasureTemperature | ELE-001 | SensingUnit |
| REQ-002 SamplingRate | ELE-002 | SensingUnit |
| REQ-003 ThresholdAlert | ELE-003 | ProcessingUnit |
| REQ-004 AlertClear | ELE-004 | ProcessingUnit |
| REQ-005 ThresholdConfiguration | ELE-005 | ConfigInterface |
| REQ-006 DisplayReadability | ELE-006 | DisplayUnit |
| REQ-007 OperatingLife | ELE-007 | ProcessingUnit |
| REQ-008 SelfDiagnostic | ELE-008 | ProcessingUnit |

## Requirements to Verification (verify)

| System Requirement | Verification Case | Method |
|-------------------|------------------|--------|
| REQ-001 | VER-001 VerifyTempAccuracy | Test |
| REQ-002 | VER-002 VerifySamplingRate | Test |
| REQ-003 | VER-003 VerifyAlertActivation | Test |
| REQ-004 | VER-004 VerifyAlertClear | Test |
| REQ-005 | VER-005 VerifyThresholdConfig | Demonstration |
| REQ-006 | VER-006 VerifyDisplayReadability | Inspection |
| REQ-007 | VER-007 VerifyOperatingLife | Analysis |
| REQ-008 | VER-008 VerifySelfDiagnostic | Test |

## Needs to Validation (validate)

| Stakeholder Need | Validation Case | Method |
|-----------------|----------------|--------|
| STK-001 | VAL-001 ValidateMonitoring | Demonstration |
| STK-002 | VAL-002 ValidateAlerts | Demonstration |
| STK-003 | VAL-003 ValidateConfiguration | Demonstration |
| STK-004 | VAL-004 ValidateReadability | Demonstration |
| STK-005 | VAL-005 ValidateReliability | Inspection |

## Trace Gap Summary

All traces are complete. No gaps found.

| Direction | Total Items | Traced | Gaps | Coverage % |
|-----------|------------|--------|------|------------|
| Needs to Requirements | 5 | 5 | 0 | 100 |
| Requirements to Element Requirements | 8 | 8 | 0 | 100 |
| Requirements to Verification | 8 | 8 | 0 | 100 |
| Needs to Validation | 5 | 5 | 0 | 100 |

## Change History

| Date | Change | Affected Items | Reason |
|------|--------|---------------|--------|
| 2026-02-28 | Initial creation | All | Project setup |
