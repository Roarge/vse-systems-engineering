---
project: "Smart Temperature Sensor"
version: "0.1"
date: "2026-02-28"
author: "Roar Georgsen"
status: draft
work_product: "System Elements Requirements Specification"
iso_ref: "SR.2"
---

# System Elements Requirements Specification

## Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 0.1 | 2026-02-28 | Roar Georgsen | Initial draft |

<!-- VSE-TASK: SR.2.5 -->

## 1. Introduction

### 1.1 Purpose

This document specifies requirements allocated to individual system elements
of the Smart Temperature Sensor. Each element requirement traces upward to a
system requirement in the SyRS and downward to a verification case. The
element requirements refine system-level requirements by adding
implementation-specific constraints appropriate to each element in the
physical architecture.

### 1.2 Scope

The system comprises five elements as defined in the System Design Document:

1. **SensingUnit** — reads ambient temperature from a physical sensor
2. **ProcessingUnit** — applies calibration, threshold comparison, and alert logic
3. **AlertUnit** — produces audible and visual alerts when thresholds are exceeded
4. **DisplayUnit** — shows current temperature and alert status to the operator
5. **ConfigInterface** — allows the operator to set temperature thresholds

### 1.3 Applicable Documents

- System Requirements Specification (SyRS), version 0.1
- System Design Document, version 0.1
- Traceability Matrix (`docs/sr/traceability-matrix.md`)
- SysML 2.0 architecture model (`models/architecture.sysml`)

## 2. Element Requirements

### 2.1 SensingUnit

The SensingUnit is responsible for reading ambient temperature from the
physical sensor probe and providing raw temperature data to the
ProcessingUnit via the TemperaturePort interface.

#### ELE-001: Temperature Measurement Accuracy

- **Description:** The SensingUnit shall measure ambient temperature with an accuracy of +/-0.3 degrees Celsius over the operating range of -20 to +60 degrees Celsius.
- **Rationale:** The element-level accuracy budget of +/-0.3 degrees Celsius leaves margin for calibration and processing error to meet the system-level requirement of +/-0.5 degrees Celsius (REQ-001).
- **Satisfies:** REQ-001 (MeasureTemperature)
- **Priority:** Essential
- **Acceptance criteria:** All readings at five reference points (-20, 0, 20, 40, 60 degrees Celsius) fall within +/-0.3 degrees Celsius of the calibrated reference value.
- **Verification method:** Test

#### ELE-002: Sampling Rate

- **Description:** The SensingUnit shall sample temperature at a rate of at least 2 samples per second.
- **Rationale:** Sampling at 2 Hz provides headroom above the system-level requirement of 1 sample per second (REQ-002), allowing the ProcessingUnit to apply filtering or averaging without reducing the effective output rate.
- **Satisfies:** REQ-002 (SamplingRate)
- **Priority:** Essential
- **Acceptance criteria:** Over a 60-second collection window, at least 120 samples are recorded with timestamps confirming a sustained rate of 2 Hz or greater.
- **Verification method:** Test

### 2.2 ProcessingUnit

The ProcessingUnit receives raw temperature data from the SensingUnit,
applies calibration corrections and threshold comparison logic, and drives
the AlertUnit and DisplayUnit outputs.

#### ELE-003: Threshold Breach Detection Latency

- **Description:** The ProcessingUnit shall detect a threshold breach and raise an alert flag within 1 second of receiving a raw temperature sample that exceeds the configured threshold.
- **Rationale:** A 1-second detection latency at the element level leaves a further 1 second of budget for alert propagation, ensuring the system-level 2-second alert requirement (REQ-003) is met.
- **Satisfies:** REQ-003 (ThresholdAlert)
- **Priority:** Essential
- **Acceptance criteria:** In a bench test with threshold set to 25 degrees Celsius and a step input from 24 to 26 degrees Celsius, the alert flag on the AlertPort transitions to true within 1 second of the sample crossing the threshold.
- **Verification method:** Test

#### ELE-004: Alert State Clearing

- **Description:** The ProcessingUnit shall clear the alert state within 2 seconds of the measured temperature returning within the configured thresholds.
- **Rationale:** A 2-second clearing latency at the element level leaves a further 3 seconds of budget for the full system response, ensuring the system-level 5-second clear requirement (REQ-004) is met.
- **Satisfies:** REQ-004 (AlertClear)
- **Priority:** Essential
- **Acceptance criteria:** With alert active due to upper threshold breach, a step reduction in temperature to 1 degree Celsius below threshold results in the alert flag returning to false within 2 seconds.
- **Verification method:** Test

#### ELE-007: Reliability (MTBF)

- **Description:** The ProcessingUnit shall have a mean time between failures (MTBF) of greater than 12,000 hours under continuous operation at an ambient temperature of 25 degrees Celsius.
- **Rationale:** The ProcessingUnit is the central element with the highest duty cycle. Its reliability dominates the system-level MTBF calculation required to achieve 12 months of continuous operation (REQ-007).
- **Satisfies:** REQ-007 (OperatingLife)
- **Priority:** Essential
- **Acceptance criteria:** Component-level MTBF analysis using manufacturer datasheet values yields a calculated MTBF exceeding 12,000 hours for the ProcessingUnit assembly.
- **Verification method:** Analysis

#### ELE-008: Power-On Self-Diagnostic

- **Description:** The ProcessingUnit shall complete a self-diagnostic sequence within 5 seconds of power-on, checking sensor connectivity, memory integrity, and processing capability.
- **Rationale:** A 5-second self-diagnostic window leaves 5 seconds for fault reporting to the operator, meeting the 10-second system-level requirement (REQ-008). The diagnostic covers the three most common failure modes identified in the risk assessment.
- **Satisfies:** REQ-008 (SelfDiagnostic)
- **Priority:** Desirable
- **Acceptance criteria:** From the moment power is applied, the diagnostic-complete flag is asserted within 5 seconds. With a simulated sensor disconnect, a fault code is generated within the same 5-second window.
- **Verification method:** Test

### 2.3 AlertUnit

The AlertUnit receives alert state information from the ProcessingUnit and
produces audible and visual alert signals to attract the operator's
attention.

> Note: The AlertUnit has no dedicated element requirement in this version.
> Its behaviour is driven by the alert interface (IF-002) and the system-level
> requirements REQ-003 and REQ-004. Element requirements for the AlertUnit
> (for example, sound pressure level and flash rate) will be added during
> detailed design if the risk assessment identifies the need.

### 2.4 DisplayUnit

The DisplayUnit receives formatted display data from the ProcessingUnit and
renders the current temperature reading and alert status for the operator.

#### ELE-006: Display Legibility

- **Description:** The DisplayUnit shall display temperature readings and alert status with a minimum character height of 12 mm, legible at a distance of 2 metres under standard indoor lighting conditions (300 to 500 lux).
- **Rationale:** The 12 mm character height is derived from ergonomic standards for display readability at 2 metres, directly supporting the system-level readability requirement (REQ-006).
- **Satisfies:** REQ-006 (DisplayReadability)
- **Priority:** Desirable
- **Acceptance criteria:** Three independent observers positioned 2 metres from the display under 300 to 500 lux lighting can correctly read the temperature value and alert status without aids.
- **Verification method:** Inspection

### 2.5 ConfigInterface

The ConfigInterface allows the operator to set upper and lower temperature
thresholds that govern the alert behaviour of the system.

#### ELE-005: Threshold Parameter Entry

- **Description:** The ConfigInterface shall accept upper and lower threshold parameters independently over the range -20 to +60 degrees Celsius with a resolution of 0.1 degrees Celsius.
- **Rationale:** The full operating range and 0.1-degree resolution are specified at system level (REQ-005). Allocating this requirement to the ConfigInterface ensures the input mechanism supports the required precision without rounding or truncation.
- **Satisfies:** REQ-005 (ThresholdConfiguration)
- **Priority:** Essential
- **Acceptance criteria:** The operator can set the upper threshold to any value from -20.0 to +60.0 degrees Celsius and the lower threshold independently over the same range, in 0.1-degree increments. The system accepts and stores these values without error.
- **Verification method:** Demonstration

## 3. Interface Requirements

<!-- VSE-TASK: SR.2.5 -->

The following interface requirements define the data exchange contracts
between system elements. Each interface corresponds to a connection in the
physical architecture model (`models/architecture.sysml`).

| Interface | Between | Requirement | Protocol/Medium |
|-----------|---------|-------------|-----------------|
| IF-001 | SensingUnit to ProcessingUnit | Transfer raw temperature as a 16-bit signed integer at a rate of at least 2 Hz | SPI bus, 1 MHz clock |
| IF-002 | ProcessingUnit to AlertUnit | Transfer alert state as a boolean flag within 100 ms of detection | GPIO, active-high signal |
| IF-003 | ProcessingUnit to DisplayUnit | Transfer formatted display data (temperature and alert status) at a rate of at least 1 Hz | I2C bus, 400 kHz clock |

### IF-001: SensingUnit to ProcessingUnit

- **Description:** The interface between the SensingUnit and ProcessingUnit shall transfer the raw temperature reading as a 16-bit signed integer (representing temperature in units of 0.01 degrees Celsius) at a rate of at least 2 Hz.
- **Rationale:** The 16-bit signed integer format provides a resolution of 0.01 degrees Celsius over the range -327.68 to +327.67 degrees Celsius, which comfortably covers the operating range. The 2 Hz rate matches the SensingUnit sampling rate (ELE-002).
- **Satisfies:** ELE-001, ELE-002
- **Verification method:** Test

### IF-002: ProcessingUnit to AlertUnit

- **Description:** The interface between the ProcessingUnit and AlertUnit shall transfer the alert state as a boolean flag. The flag shall transition within 100 ms of the ProcessingUnit detecting a threshold breach or clearance.
- **Rationale:** A 100 ms interface latency is small relative to the 1-second detection budget (ELE-003), ensuring the interface does not become the bottleneck in the alert chain.
- **Satisfies:** ELE-003, ELE-004
- **Verification method:** Test

### IF-003: ProcessingUnit to DisplayUnit

- **Description:** The interface between the ProcessingUnit and DisplayUnit shall transfer the current temperature value and alert status at a refresh rate of at least 1 Hz.
- **Rationale:** A 1 Hz refresh rate provides the operator with a display update at least once per second, which is sufficient for the monitoring use case and avoids flicker or excessive bus traffic.
- **Satisfies:** ELE-006
- **Verification method:** Test

## 4. Traceability

The table below summarises the traceability from element requirements to
system requirements and target verification cases. The full matrix is
maintained in `docs/sr/traceability-matrix.md`.

| Element Req | System Req | Element | Verification Case | Status |
|-------------|-----------|---------|-------------------|--------|
| ELE-001 | REQ-001 | SensingUnit | VER-001 | Draft |
| ELE-002 | REQ-002 | SensingUnit | VER-002 | Draft |
| ELE-003 | REQ-003 | ProcessingUnit | VER-003 | Draft |
| ELE-004 | REQ-004 | ProcessingUnit | VER-004 | Draft |
| ELE-005 | REQ-005 | ConfigInterface | VER-005 | Draft |
| ELE-006 | REQ-006 | DisplayUnit | VER-006 | Draft |
| ELE-007 | REQ-007 | ProcessingUnit | VER-007 | Draft |
| ELE-008 | REQ-008 | ProcessingUnit | VER-008 | Draft |

### Interface Traceability

| Interface Req | Related Element Reqs | Between | Verification Case | Status |
|---------------|---------------------|---------|-------------------|--------|
| IF-001 | ELE-001, ELE-002 | SensingUnit to ProcessingUnit | VER-001, VER-002 | Draft |
| IF-002 | ELE-003, ELE-004 | ProcessingUnit to AlertUnit | VER-003, VER-004 | Draft |
| IF-003 | ELE-006 | ProcessingUnit to DisplayUnit | VER-006 | Draft |

## 5. Verification Record

<!-- VSE-TASK: SR.2.6 -->

- **Verified by:** (PJM, WT)
- **Date:** YYYY-MM-DD
- **Method:** SMART criteria check, traceability review
- **Result:** (pass/fail with notes)

## Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Systems Engineer | | | |
| Designer | | | |
| Project Manager | | | |
