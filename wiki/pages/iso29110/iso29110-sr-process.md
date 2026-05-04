---
title: "ISO/IEC 29110 System Definition and Realization Process (SR.1 to SR.6)"
slug: iso29110-sr-process
type: reference
layer: iso29110
tags: [iso29110, sr, system-definition, realization, requirements, architecture, ivv, delivery]
sources:
  - citation: "ISO/IEC TR 29110-5-6-2:2014, Chapter on System Definition and Realization Process."
    raw: ISO_IEC_TR_29110-5-6-2_2014.pdf
related:
  - iso29110-overview
  - iso29110-pm-process
  - iso29110-sr-task-checklists
  - iso29110-roles-and-work-products
  - iso29110-phase-gates
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [project-setup, iteration-orchestrator]
---

# ISO/IEC 29110 System Definition and Realization Process (SR.1 to SR.6)

**Purpose.** Systematic performance of the specification, analysis,
design, construction, integration, and verification/validation
activities for new or modified systems according to specified
requirements.

## Process objectives

| ID | Objective |
|---|---|
| **SR.O1** | Tasks performed through accomplishment of the current Project Plan. |
| **SR.O2** | System requirements defined, analysed for correctness and testability, approved by Acquirer, baselined, and communicated. See [[sysml2-syntax-requirements-and-cases]] and [[sysml2-requirements-semantics]] for the SysML 2.0 syntax and semantics that operationalise the verifiable-requirement model in this plugin. |
| **SR.O3** | System architectural design developed and baselined, describing system elements and their interfaces. Consistency and traceability to system requirements established. |
| **SR.O4** | System elements produced or acquired from the design. Acceptance tests defined. Traceability to requirements and design established. |
| **SR.O5** | System elements integrated. Defects corrected and consistency/traceability to System Architecture established. |
| **SR.O6** | System Configuration baselined and stored in Project Repository. Needs for changes detected and Change Requests initiated. See [[sysml2-vse-library-metadata]] for the model-level `Baseline` and `ConfigItem` metadata used by the plugin. |
| **SR.O7** | Verification and Validation tasks of all required work products performed using defined criteria. Defects identified and corrected, records stored in Verification/Validation Reports. See [[sysml2-cases-overview]] and [[sysml2-case-kinds]] for the verification-case construct that embeds these reports in the model. |

## SR.1 Initiation

**Objective**: SR.O1.

**Inputs**: Project Plan.

**Outputs**: Project Plan [reviewed], SEMP, Data Model,
Implementation Environment.

| Task | Description | Key Roles |
|---|---|---|
| SR.1.1 | Revise the Project Plan with the Work Team, achieve common understanding and engagement | PJM, WT |
| SR.1.2 | Define technical activities in cooperation with PJM and generate the SEMP | PJM, SYS |
| SR.1.3 | Define the data model of the project (entities, properties, relations) | PJM, WT |
| SR.1.4 | Set or update the implementation environment | PJM, WT |

## SR.2 System Requirements Engineering

**Objectives**: SR.O2, SR.O6, SR.O7.

**Inputs**: Project Plan, Tasks [assigned], Statement of Work
[reviewed], SEMP.

**Outputs**: Stakeholders Requirements Specifications [validated],
System Requirements Specifications [verified/validated], System
Elements Requirements Specifications, Traceability Matrix
[updated], IVV Plan [published], IVV Procedures [published],
Verification Report, Validation Report, Change Request (if needed).

| Task | Description | Key Roles |
|---|---|---|
| SR.2.1 | Elicit acquirer and stakeholder requirements, analyse system context, generate Stakeholders Requirements Specifications | SYS, ACQ, STK |
| SR.2.2 | Verify Stakeholders Requirements Specifications with PJM, obtain Work Team agreement | PJM, WT |
| SR.2.3 | Validate Stakeholders Requirements Specifications with Acquirer and stakeholders | PJM, SYS, ACQ, STK |
| SR.2.4 | Elaborate System Requirements and Interfaces (boundary, design constraints, SMART criteria, external functions, reuse constraints) | SYS, DES |
| SR.2.5 | Elaborate System Elements Requirements Specifications and System Interfaces Specifications | DES, SYS |
| SR.2.6 | Verify and obtain Work Team agreement on System and System Elements Requirements (SMART check) | PJM, WT |
| SR.2.7 | Validate that System Requirements Specifications satisfy Stakeholders Requirements Specifications | ACQ, STK, SYS |
| SR.2.8 | Define or update traceability between stakeholder, system, and system element requirements | SYS, DES |
| SR.2.9 | Establish or update the IVV Plan and IVV Procedures for system verification and validation | SYS, IVV |

## SR.3 System Architectural Design

**Objectives**: SR.O3, SR.O6, SR.O7.

**Inputs**: Project Plan, Tasks [assigned], System Requirements
Specifications [validated], Traceability Matrix [updated].

**Outputs**: System Design Document (Functional Architecture,
Physical Architecture), Justification Document (trade-offs), IVV
Plan, IVV Procedures, Traceability Matrix [updated], System User
Manual [preliminary], Verification Report, Validation Report,
Change Request (if needed), Purchase Order [initiated].

| Task | Description | Key Roles |
|---|---|---|
| SR.3.1 | Document or update the Functional System Design (internal functions, interfaces, external functions) | DES |
| SR.3.2 | Make trade-offs of System Functional Architecture, update Justification Document | SYS, DES |
| SR.3.3 | Document or update the Physical System Design (allocate functions to physical elements, identify reuse, elaborate PO) | DES |
| SR.3.4 | Make trade-offs of System Physical Architecture, update Traceability Matrix | SYS, DES |
| SR.3.5 | Verify and obtain approval of the System Design (correctness, feasibility, traceability) | SYS, DES, DEV |
| SR.3.6 | Establish or update the Integration Plan and IVV Procedures for system integration | DES, SYS |
| SR.3.7 | Document the System User Manual (optional, preliminary version) | SYS |
| SR.3.8 | Verify and obtain approval of the System User Manual (optional) | SYS, ACQ, STK |

## SR.4 System Construction

**Objectives**: SR.O4, SR.O6, SR.O7.

**Inputs**: Project Plan, Tasks [assigned], System Design Document
[validated], System Elements Requirements Specifications
[validated], Software System Elements.

**Outputs**: Software System Elements, System Elements data (HW,
HW+SW), Bought/built/re-used System Elements [verified/accepted].

| Task | Description | Key Roles |
|---|---|---|
| SR.4.1 | Construct or update Software System Elements (may follow ISO/IEC TR 29110-5-1-2) | DEV |
| SR.4.2 | Construct or update Hardware System Elements (buy, build, or re-use per System Design and Project Plan) | DEV |
| SR.4.3 | Verify that System Elements satisfy their System Elements Specifications (in-coming acceptance verification) | DEV, DES, SYS |
| SR.4.4 | Correct defects found until successful verification (reaching exit criteria) | DEV |

## SR.5 System Integration, Verification and Validation

**Objectives**: SR.O5, SR.O6, SR.O7.

**Inputs**: Project Plan, Tasks [assigned], IVV Plan, IVV
Procedures, System Requirements Specifications [validated], System
Design Document [validated], Traceability Matrix [updated], System
Elements [accepted].

**Outputs**: Verification Report (IVV plans, procedures, system),
Integration Report, System
[integrated/verified/validated/corrected], Validation Report,
Product Acceptance Record, System Operation Guide [preliminary],
System [approved].

| Task | Description | Key Roles |
|---|---|---|
| SR.5.1 | Verify IVV Plan and IVV Procedures, check consistency with requirements and design | DES, SYS, DEV, IVV |
| SR.5.2 | Integrate the System using System Elements (HW, HW+SW), verify interfaces per IVV Procedures | IVV, DES, SUP |
| SR.5.3 | Verify the System against its requirements, document in Verification Report | IVV, SYS |
| SR.5.4 | Validate the System against Stakeholders Requirements, obtain ACQ acceptance | IVV, SYS, ACQ |
| SR.5.5 | Correct defects found and retest to detect faults introduced by modifications | WT |
| SR.5.6 | Document the System Operation Guide (optional) | SYS, DES |
| SR.5.7 | Verify and obtain approval of the System Operation Guide (optional) | SYS, ACQ, STK |

## SR.6 Product Delivery

**Objectives**: SR.O6, SR.O7.

**Inputs**: System Elements, Project Plan, Delivery Instructions,
System Configuration, System Requirements Specifications
[validated], System User Manual [verified], System [validated].

**Outputs**: System Maintenance Document [validated], System
Training Specifications [validated], Product Acceptance Record,
Product [delivered], Product Acceptance Record [published].

| Task | Description | Key Roles |
|---|---|---|
| SR.6.1 | Review Product (system elements against Delivery Instructions) | PJM, WT |
| SR.6.2 | Document the System Maintenance Document | SYS, DES |
| SR.6.3 | Identify training needs and develop System Training Specifications | SYS, DES |
| SR.6.4 | Verify and obtain approval of Maintenance Document and Training Specifications | PJM, SYS, DES, STK, ACQ |
| SR.6.5 | Perform delivery (training, transition support, legacy data conversion, disposal of replaced systems) | PJM, ACQ |
| SR.6.6 | Transition to manufacturing and in-service/after-sales support | PJM |

## See also

- [[iso29110-overview]] for the profile context.
- [[iso29110-pm-process]] for the PM process that runs alongside SR.
- [[iso29110-sr-task-checklists]] for actionable SR checklists with
  work-product mappings.
- [[iso29110-roles-and-work-products]] for role abbreviations and
  the work-product catalogue.
- [[iso29110-phase-gates]] for SR phase-transition checklists.
