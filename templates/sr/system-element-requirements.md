---
project: "{{PROJECT_NAME}}"
version: "0.1"
date: "{{DATE}}"
author: "{{AUTHOR}}"
status: initiated
work_product: "System Elements Requirements Specification"
iso_ref: "SR.2"
---

# System Elements Requirements Specification

## Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 0.1 | {{DATE}} | {{AUTHOR}} | Initial draft |

<!-- VSE-TASK: SR.2.5 -->

## 1. Introduction

### 1.1 Purpose

> This document specifies requirements allocated to individual system
> elements. Each requirement traces upward to a system requirement in the
> SyRS and downward to the element that implements it.

### 1.2 Applicable Documents

- System Requirements Specification (SyRS)
- System Design Document
- Traceability Matrix

## 2. Element Requirements

### 2.1 (Element Name)

> Requirements for this system element, derived from and traceable to
> system-level requirements.

#### SER-001: (requirement title)

- **Description:** (what this element shall do, SMART criteria)
- **Rationale:** (why this element requirement exists)
- **Satisfies:** REQ-xxx
- **Priority:** Essential / Desirable / Optional
- **Acceptance criteria:** (measurable condition for verification)
- **Verification method:** Test / Analysis / Inspection / Demonstration

#### SER-002: (requirement title)

- **Description:**
- **Rationale:**
- **Satisfies:** REQ-xxx
- **Priority:**
- **Acceptance criteria:**
- **Verification method:**

### 2.2 (Element Name)

#### SER-003: (requirement title)

- **Description:**
- **Rationale:**
- **Satisfies:** REQ-xxx
- **Priority:**
- **Acceptance criteria:**
- **Verification method:**

## 3. Interface Requirements

<!-- VSE-TASK: SR.2.5 -->

> Requirements for interfaces between system elements.

| Interface | Between | Requirement | Protocol/Medium |
|-----------|---------|-------------|-----------------|
| IF-001 | Element A <-> Element B | (what the interface shall do) | |

## 4. Traceability

> Summary of element requirement to system requirement traceability.
> The full matrix is maintained in `docs/sr/traceability-matrix.md`.

| Element Req | System Req | Element | Status |
|-------------|-----------|---------|--------|
| SER-001 | REQ-xxx | | |
| SER-002 | REQ-xxx | | |
| SER-003 | REQ-xxx | | |

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
