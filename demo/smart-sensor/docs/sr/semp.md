---
project: "Smart Temperature Sensor"
version: "0.1"
date: "2026-02-28"
author: "Roar Georgsen"
status: draft
work_product: "Systems Engineering Management Plan"
iso_ref: "SR.1"
---

# Systems Engineering Management Plan (SEMP)

<!-- VSE-TASK: SR.1.2 -->

## 1. Purpose and Scope

> Define the purpose of this SEMP and the scope of the systems engineering
> effort. Reference the Project Plan for overall project scope.

## 2. Technical Activities

<!-- VSE-TASK: SR.1.2 -->

### 2.1 Requirements Engineering

> Describe the approach to requirements elicitation, analysis, specification,
> and validation. Reference techniques from the Needs and Requirements Guide.

- **Elicitation methods:** (interviews, workshops, document analysis)
- **Specification format:** SysML 2.0 textual notation (.sysml files)
- **Validation approach:** (stakeholder review, prototyping)

### 2.2 Architectural Design

> Describe the approach to functional and physical architecture design.
> Reference the INCOSE SE Handbook (VSE-scaled) for applicable methods.

- **Functional decomposition method:** (functional flow, use case analysis)
- **Physical allocation method:** (trade study, morphological analysis)
- **Modelling tool:** Sensmetry SySiDE (SysML 2.0)

### 2.3 Construction

> Describe the build/buy/reuse strategy for system elements.

### 2.4 Integration, Verification, and Validation

> Describe the IVV approach. Reference the IVV Plan for detailed procedures.

- **Integration strategy:** (incremental, big-bang)
- **Verification methods:** (inspection, analysis, demonstration, test)
- **Validation approach:** (acceptance testing, operational scenarios)

## 3. Data Model

<!-- VSE-TASK: SR.1.3 -->

> Define the key entities, their properties, and relationships that the project
> will manage. This forms the basis for the SysML 2.0 model structure.

### 3.1 Key Entities

| Entity | Description | Managed In |
|--------|-------------|------------|
| Stakeholder Need | High-level need from acquirer or stakeholder | models/stakeholder-needs.sysml |
| System Requirement | Derived requirement with SMART criteria | models/system-requirements.sysml |
| System Element | Physical or logical component | models/architecture.sysml |
| Verification Case | Test or analysis to verify a requirement | models/verification.sysml |
| Validation Case | Scenario to validate a stakeholder need | models/validation.sysml |

### 3.2 Relationships

> Stakeholder Needs are satisfied by System Requirements.
> System Requirements are allocated to System Elements.
> System Requirements are verified by Verification Cases.
> Stakeholder Needs are validated by Validation Cases.

## 4. Implementation Environment

<!-- VSE-TASK: SR.1.4 -->

### 4.1 Development Tools

| Tool | Purpose | Version |
|------|---------|---------|
| Sensmetry SySiDE | SysML 2.0 modelling | |
| Git | Version control | |
| Claude Code | SE companion (designed cognitive reserve) | |

### 4.2 Repository Structure

```
models/           SysML 2.0 source files
docs/pm/          PM work products
docs/sr/          SR work products
build/            Generated outputs (gitignored)
```

### 4.3 Configuration Management

> Reference the CM Strategy section of the Project Plan.

## 5. Technical Reviews

| Review | Phase Gate | Participants | Inputs |
|--------|-----------|--------------|--------|
| Requirements Review | SR.2 to SR.3 | PJM, SYS, ACQ, STK | StRS, SyRS, Traceability Matrix |
| Design Review | SR.3 to SR.4 | PJM, SYS, DES, DEV | System Design Document |
| Test Readiness Review | SR.4 to SR.5 | PJM, SYS, IVV | IVV Plan, System Elements |
| Product Acceptance Review | SR.5 to SR.6 | PJM, SYS, ACQ | Verification/Validation Reports |

## 6. Technical Performance Measures

> Define any key technical metrics to be tracked during development.

| Measure | Target | Measurement Method | Review Frequency |
|---------|--------|-------------------|------------------|
| | | | |

## Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Project Manager | | | |
| Systems Engineer | | | |
