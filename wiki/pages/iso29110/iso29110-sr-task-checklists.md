---
title: "ISO/IEC 29110 SR Task Checklists (SR.1 to SR.6)"
slug: iso29110-sr-task-checklists
type: process
layer: iso29110
tags: [iso29110, sr, task-checklist, work-products]
sources:
  - citation: "ISO/IEC TR 29110-5-6-2:2014, System Definition and Realization task tables."
    raw: ISO_IEC_TR_29110-5-6-2_2014.pdf
related:
  - iso29110-sr-process
  - iso29110-pm-task-checklists
  - iso29110-template-mapping
  - iso29110-phase-gates
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [project-setup, iteration-orchestrator]
---

# ISO/IEC 29110 SR Task Checklists (SR.1 to SR.6)

Actionable task checklists for every ISO 29110 System Definition
and Realization activity. Each task lists its responsible roles,
and each phase declares the work products created and used. For
role abbreviations and work-product catalogue, see
[[iso29110-roles-and-work-products]].

## SR.1 Initiation

**Objective**: Review the Project Plan with the Work Team,
generate the SEMP, define the data model, and set up the
implementation environment.

### Task checklist

- [ ] SR.1.1: Revise the Project Plan with the Work Team, achieve common understanding and engagement (PJM, WT)
- [ ] SR.1.2: Define technical activities in cooperation with PJM and generate the SEMP (PJM, SYS)
- [ ] SR.1.3: Define the data model (entities, properties, relations) (PJM, WT)
- [ ] SR.1.4: Set or update the implementation environment (PJM, WT)

### Work products created

- Project Plan [reviewed]
- SEMP [verified, accepted]
- Data Model → `docs/sr/data-model.md`
- Implementation Environment

### Work products used

- Project Plan

## SR.2 System Requirements Engineering

**Objective**: Elicit stakeholder needs, derive and validate system
requirements, establish traceability, and create the IVV Plan. See
[[sysml2-syntax-requirements-and-cases]] for the SysML 2.0 syntax
that operationalises SMART, satisfy, and verify links.

### Task checklist

- [ ] SR.2.1: Elicit acquirer and stakeholder requirements, analyse system context, generate StRS (SYS, ACQ, STK)
- [ ] SR.2.2: Verify StRS with PJM, obtain Work Team agreement (PJM, WT)
- [ ] SR.2.3: Validate StRS with Acquirer and Stakeholders (PJM, SYS, ACQ, STK)
- [ ] SR.2.4: Elaborate System Requirements and Interfaces (boundary, design constraints, SMART criteria) (SYS, DES)
- [ ] SR.2.5: Elaborate System Elements Requirements and System Interfaces Specifications (DES, SYS)
- [ ] SR.2.6: Verify and obtain Work Team agreement on System and System Elements Requirements (PJM, WT)
- [ ] SR.2.7: Validate that SyRS satisfies StRS (ACQ, STK, SYS)
- [ ] SR.2.8: Define or update traceability between stakeholder, system, and element requirements (SYS, DES)
- [ ] SR.2.9: Establish or update the IVV Plan and IVV Procedures (SYS, IVV)

### Work products created

- Stakeholder Requirements Specification [validated]
- System Requirements Specification [verified, validated]
- System Elements Requirements Specification → `docs/sr/system-element-requirements.md`
- Traceability Matrix [updated]
- IVV Plan [published]
- IVV Procedures [published]
- Verification Report [published]
- Validation Report [published]

### Work products used

- Project Plan
- Tasks [assigned]
- Statement of Work [reviewed]
- SEMP

## SR.3 System Architectural Design

**Objective**: Design the functional and physical architecture,
make trade-offs, and verify the design. See
[[sysml2-canonical-model-layout]] for the AMBSE package layout the
plugin uses, and [[sysml2-allocations-overview]] for the allocation
mechanism that maps functional to physical elements.

### Task checklist

- [ ] SR.3.1: Document or update the Functional System Design (internal functions, interfaces, external functions) (DES)
- [ ] SR.3.2: Make trade-offs of System Functional Architecture, update Justification Document (SYS, DES)
- [ ] SR.3.3: Document or update the Physical System Design (allocate functions to physical elements, identify reuse) (DES)
- [ ] SR.3.4: Make trade-offs of System Physical Architecture, update Traceability Matrix (SYS, DES)
- [ ] SR.3.5: Verify and obtain approval of the System Design (correctness, feasibility, traceability) (SYS, DES, DEV)
- [ ] SR.3.6: Establish or update the Integration Plan and IVV Procedures for system integration (DES, SYS)
- [ ] SR.3.7: Document the System User Manual (optional, preliminary) (SYS)
- [ ] SR.3.8: Verify and obtain approval of the System User Manual (optional) (SYS, ACQ, STK)

### Work products created

- System Design Document [verified, validated]
- Justification Document [published] → `docs/pm/justification-document.md`
- IVV Plan [updated]
- IVV Procedures [updated]
- Traceability Matrix [updated]
- System User Manual [preliminary] (optional) → `docs/sr/system-user-manual.md`
- Verification Report [published]
- Purchase Order [initiated] (if applicable) → `docs/pm/purchase-order.md`

### Work products used

- Project Plan
- Tasks [assigned]
- System Requirements Specification [validated]
- Traceability Matrix [updated]

## SR.4 System Construction

**Objective**: Build, buy, or reuse system elements and verify
them against their specifications.

### Task checklist

- [ ] SR.4.1: Construct or update Software System Elements (may follow ISO/IEC TR 29110-5-1-2) (DEV)
- [ ] SR.4.2: Construct or update Hardware System Elements (buy, build, or reuse per System Design) (DEV)
- [ ] SR.4.3: Verify that System Elements satisfy their System Elements Specifications (DEV, DES, SYS)
- [ ] SR.4.4: Correct defects found until successful verification (reaching exit criteria) (DEV)

### Work products created

- Software System Elements
- Hardware System Elements (HW, HW+SW)
- System Elements [verified, accepted]

### Work products used

- Project Plan
- Tasks [assigned]
- System Design Document [validated]
- System Elements Requirements Specification [validated]

## SR.5 System Integration, Verification and Validation

**Objective**: Integrate system elements, verify the system
against requirements, validate against stakeholder needs, and
obtain acceptance. See [[sysml2-cases-overview]] and
[[sysml2-case-kinds]] for the verification-case construct that
embeds these reports in the model.

### Task checklist

- [ ] SR.5.1: Verify IVV Plan and Procedures, check consistency with requirements and design (DES, SYS, DEV, IVV)
- [ ] SR.5.2: Integrate the System using System Elements, verify interfaces per IVV Procedures (IVV, DES, SUP)
- [ ] SR.5.3: Verify the System against its requirements, document in Verification Report (IVV, SYS)
- [ ] SR.5.4: Validate the System against Stakeholder Requirements, obtain ACQ acceptance (IVV, SYS, ACQ)
- [ ] SR.5.5: Correct defects found and retest to detect faults introduced by modifications (WT)
- [ ] SR.5.6: Document the System Operation Guide (optional) (SYS, DES)
- [ ] SR.5.7: Verify and obtain approval of the System Operation Guide (optional) (SYS, ACQ, STK)

### Work products created

- Verification Report [published]
- Integration Report [published] → `docs/sr/integration-report.md`
- System [integrated, verified, validated, corrected]
- Validation Report [published]
- Product Acceptance Record
- System Operation Guide [preliminary] (optional) → `docs/sr/system-operation-guide.md`
- System [approved]

### Work products used

- Project Plan
- Tasks [assigned]
- IVV Plan
- IVV Procedures
- System Requirements Specification [validated]
- System Design Document [validated]
- Traceability Matrix [updated]
- System Elements [accepted]

## SR.6 Product Delivery

**Objective**: Review the product, prepare maintenance and
training documentation, and deliver the system.

### Task checklist

- [ ] SR.6.1: Review Product (system elements against Delivery Instructions) (PJM, WT)
- [ ] SR.6.2: Document the System Maintenance Document (SYS, DES)
- [ ] SR.6.3: Identify training needs and develop System Training Specifications (SYS, DES)
- [ ] SR.6.4: Verify and obtain approval of Maintenance Document and Training Specifications (PJM, SYS, DES, STK, ACQ)
- [ ] SR.6.5: Perform delivery (training, transition support, legacy data conversion, disposal) (PJM, ACQ)
- [ ] SR.6.6: Transition to manufacturing and in-service/after-sales support (PJM)

### Work products created

- System Maintenance Document [validated]
- System Training Specifications [validated] → `docs/sr/training-specifications.md`
- Product Acceptance Record [published]
- Product [delivered]

### Work products used

- System Elements
- Project Plan
- Delivery Instructions
- System Configuration
- System Requirements Specification [validated]
- System User Manual [verified]
- System [validated]

## See also

- [[iso29110-sr-process]] for the underlying activity definitions.
- [[iso29110-pm-task-checklists]] for PM-process task checklists.
- [[iso29110-template-mapping]] for phase-to-template-file
  mappings used by `@project-setup` to scaffold work-product
  templates.
- [[iso29110-phase-gates]] for gate transition checklists.
