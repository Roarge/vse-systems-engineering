---
project: "Smart Temperature Sensor"
version: "0.1"
date: "2026-02-28"
author: "Roar Georgsen"
status: draft
work_product: "Data Model"
iso_ref: "SR.1"
---

# Data Model

<!-- VSE-TASK: SR.1.3 -->

## 1. Purpose

> This document defines the data model for Smart Temperature Sensor: the entities,
> their properties, and the relationships between them. It establishes the
> information architecture that underpins the SysML 2.0 models and work
> products.

## 2. Entities

### 2.1 Stakeholder Need

- **ID format:** STK-nnn
- **Properties:** name, description, stakeholder, priority, acceptance criteria
- **Defined in:** `models/stakeholder-needs.sysml`, `docs/sr/stakeholder-requirements.md`

### 2.2 System Requirement

- **ID format:** REQ-nnn
- **Properties:** name, description, rationale, priority, acceptance criteria, verification method
- **Defined in:** `models/system-requirements.sysml`, `docs/sr/system-requirements.md`

### 2.3 System Element Requirement

- **ID format:** SER-nnn
- **Properties:** name, description, allocated element, parent requirement
- **Defined in:** `docs/sr/system-element-requirements.md`

### 2.4 System Element

- **ID format:** (element name in PascalCase)
- **Properties:** name, type (HW/SW/HW+SW), description, build/buy/reuse
- **Defined in:** `models/architecture.sysml`, `docs/sr/system-design.md`

### 2.5 Verification Case

- **ID format:** VER-nnn
- **Properties:** name, description, method, setup, steps, expected result, pass criteria
- **Defined in:** `models/verification.sysml`, `docs/sr/ivv-plan.md`

### 2.6 Validation Case

- **ID format:** VAL-nnn
- **Properties:** name, description, method, participants, acceptance criteria
- **Defined in:** `models/validation.sysml`, `docs/sr/ivv-plan.md`

### 2.7 Project-Specific Entities

> Add any entities specific to this project (for example: sensors, protocols,
> test fixtures, user roles).

| Entity | ID Format | Properties | Defined In |
|--------|-----------|------------|------------|
| | | | |

## 3. Relationships

> The following relationships form the traceability chain. They are
> implemented as SysML 2.0 dependency links in the model files.

| Relationship | From | To | SysML 2.0 Keyword | Meaning |
|-------------|------|-----|-------------------|---------|
| satisfy | System Requirement | Stakeholder Need | `satisfy` | Requirement addresses need |
| verify | Verification Case | System Requirement | `verify` | Test proves requirement met |
| validate | Validation Case | Stakeholder Need | `verify` | Acceptance proves need met |
| allocate | System Element | System Requirement | `allocate` | Element implements requirement |
| derive | System Element Req | System Requirement | (traceability) | Element req flows from system req |

## 4. Entity-Relationship Diagram

> Replace this placeholder with an entity-relationship diagram showing the
> entities and their connections. Use SysML 2.0 package diagram or a simple
> box-and-line diagram.

```
[Stakeholder Need] <--satisfy-- [System Requirement] <--verify-- [Verification Case]
        ^                              |
        |                         allocate
   validate                            |
        |                              v
[Validation Case]              [System Element] <--derive-- [System Element Req]
```
