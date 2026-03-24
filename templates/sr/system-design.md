---
project: "{{PROJECT_NAME}}"
version: "0.1"
date: "{{DATE}}"
author: "{{AUTHOR}}"
status: draft
work_product: "System Design Document"
iso_ref: "SR.3"
---

# System Design Document

## Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 0.1 | {{DATE}} | {{AUTHOR}} | Initial draft |

<!-- VSE-TASK: SR.3.1 -->

## 1. Introduction

### 1.1 Purpose

> This document describes the functional and physical architecture of
> {{PROJECT_NAME}}. It shows how the system is decomposed, how functions
> are allocated to physical elements, and how elements interact.

### 1.2 Design Approach

> Describe the overall design philosophy and any key constraints that shaped
> the architecture.

### 1.3 Applicable Documents

- System Requirements Specification (SyRS)
- Stakeholder Requirements Specification (StRS)
- Traceability Matrix

## 2. Functional Architecture

<!-- VSE-TASK: SR.3.1 -->

### 2.1 Functional Decomposition

> Describe the internal functions of the system and how they relate to each
> other. Reference the SysML 2.0 model in `models/architecture.sysml`.

```
System Function
├── Function 1
│   ├── Sub-function 1.1
│   └── Sub-function 1.2
└── Function 2
    └── Sub-function 2.1
```

### 2.2 External Interfaces

> Describe how the system functions interact with external systems, users,
> and the environment.

| Interface | External Entity | Data/Signal | Direction |
|-----------|----------------|-------------|-----------|
| | | | In / Out / Bidirectional |

### 2.3 Internal Interfaces

> Describe how internal functions interact with each other.

### 2.4 Functional Architecture Trade-offs

<!-- VSE-TASK: SR.3.2 -->

| Decision | Options Considered | Selected | Rationale |
|----------|-------------------|----------|-----------|
| | | | |

## 3. Physical Architecture

<!-- VSE-TASK: SR.3.3 -->

### 3.1 System Elements

> Describe each physical system element (hardware, software, hardware with
> embedded software). Reference the SysML 2.0 model.

| Element | Type | Description | Build/Buy/Reuse |
|---------|------|-------------|-----------------|
| | HW / SW / HW+SW | | |

### 3.2 Function-to-Element Allocation

> Show how functions from Section 2 are allocated to physical elements.

| Function | Allocated To | Notes |
|----------|-------------|-------|
| | | |

### 3.3 Physical Interfaces

> Describe interfaces between physical elements.

| Interface | Element A | Element B | Protocol/Medium | Constraints |
|-----------|-----------|-----------|-----------------|-------------|
| | | | | |

### 3.4 Physical Architecture Trade-offs

<!-- VSE-TASK: SR.3.4 -->

| Decision | Options Considered | Selected | Rationale |
|----------|-------------------|----------|-----------|
| | | | |

## 4. Reuse and Procurement

<!-- VSE-TASK: SR.3.3 -->

> Identify elements to be reused from existing systems or procured from
> suppliers. Reference Purchase Orders where applicable.

| Element | Source | Status | Notes |
|---------|--------|--------|-------|
| | Reuse / Buy / Build | | |

## 5. System User Manual (Preliminary)

<!-- VSE-TASK: SR.3.7 -->

> If applicable, provide a preliminary outline of the user manual. This is
> optional per ISO 29110 but recommended.

## 6. Verification Record

<!-- VSE-TASK: SR.3.5 -->

- **Verified by:** (SYS, DES, DEV)
- **Date:** YYYY-MM-DD
- **Criteria:** Correctness, feasibility, traceability to requirements
- **Result:** (pass/fail with notes)

## Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Systems Engineer | | | |
| Designer | | | |
| Project Manager | | | |
