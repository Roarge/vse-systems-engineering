---
project: "{{PROJECT_NAME}}"
version: "0.1"
date: "{{DATE}}"
author: "{{AUTHOR}}"
status: draft
work_product: "Traceability Matrix"
iso_ref: "SR.2"
---

# Traceability Matrix

## Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 0.1 | {{DATE}} | {{AUTHOR}} | Initial draft |

<!-- VSE-TASK: SR.2.8 -->

## Purpose

This matrix provides bidirectional traceability between stakeholder needs,
system requirements, system elements, and verification/validation cases.

The authoritative source of traceability is the SysML 2.0 model files in
`models/`. This markdown document provides a human-readable summary. Use the
`@traceability-guard` skill to verify that this matrix is consistent with the
SysML 2.0 models.

## Needs to Requirements (satisfy)

| Stakeholder Need | System Requirements | Coverage |
|-----------------|--------------------|-----------|
| STK-001 | REQ-001, REQ-002 | Full / Partial / None |
| STK-002 | | |

## Requirements to Verification (verify)

| System Requirement | Verification Cases | Method | Status |
|-------------------|-------------------|--------|--------|
| REQ-001 | VER-001 | Test / Analysis / Inspection / Demonstration | Not started / In progress / Passed / Failed |
| REQ-002 | | | |

## Needs to Validation (validate)

| Stakeholder Need | Validation Cases | Method | Status |
|-----------------|-----------------|--------|--------|
| STK-001 | VAL-001 | | |
| STK-002 | | | |

## Requirements to System Elements (allocate)

| System Requirement | Allocated To | Element Type |
|-------------------|-------------|--------------|
| REQ-001 | | HW / SW / HW+SW |
| REQ-002 | | |

## Trace Gap Summary

> Run the `@traceability-guard` skill to generate this summary automatically.

| Direction | Total Items | Traced | Gaps | Coverage % |
|-----------|------------|--------|------|------------|
| Needs to Requirements | | | | |
| Requirements to Verification | | | | |
| Needs to Validation | | | | |
| Requirements to Elements | | | | |

## Change History

| Date | Change | Affected Items | Reason |
|------|--------|---------------|--------|
| {{DATE}} | Initial creation | All | Project setup |
