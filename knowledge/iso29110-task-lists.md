# ISO/IEC 29110 Task Checklists

Actionable task checklists for every ISO 29110 activity. Each task links to
the relevant work products (created and consumed). Use these checklists to
generate project-specific TASKS.md files and to track progress through the
lifecycle.

Abbreviations: PJM (Project Manager), SYS (Systems Engineer), DES (Designer),
DEV (Developer), IVV (IVV Engineer), ACQ (Acquirer), STK (Stakeholder),
WT (Work Team), SUP (Supplier).

---

## PM.1 Project Planning

**Objective:** Establish the Project Plan, assign resources, and obtain
acquirer acceptance.

### Task Checklist

- [ ] PM.1.1: Review the Statement of Work (PJM, SYS)
- [ ] PM.1.2: Define Delivery Instructions for each SOW deliverable (PJM, ACQ)
- [ ] PM.1.3: Define the System Breakdown Structure (SBS) (PJM, DES)
- [ ] PM.1.4: Select product lifecycle and define milestones (PJM, WT)
- [ ] PM.1.5: Identify tasks to produce deliverables, including V&V and review tasks (PJM, SYS)
- [ ] PM.1.6: Establish estimated duration for each task (PJM)
- [ ] PM.1.7: Identify and document resources (human, material, equipment, tools, training) (PJM)
- [ ] PM.1.8: Establish Work Team composition, assign roles and responsibilities (PJM)
- [ ] PM.1.9: Assign start and completion dates, define schedule and milestones (PJM)
- [ ] PM.1.10: Calculate and document estimated effort and cost (PJM)
- [ ] PM.1.11: Identify and document Risk Management Approach (PJM)
- [ ] PM.1.12: Identify and document Disposal Management Approach (PJM)
- [ ] PM.1.13: Document Configuration Management Strategy (PJM)
- [ ] PM.1.14: Include System Description, Scope, Objectives, Deliverables, SOW reference (PJM)
- [ ] PM.1.15: Generate the integrated Project Plan (PJM)
- [ ] PM.1.16: Verify and obtain internal approval of the Project Plan (PJM, WT)
- [ ] PM.1.17: Review and accept the Project Plan with Acquirer and Stakeholders (PJM, ACQ, STK)
- [ ] PM.1.18: Establish the Project Repository using the CM Strategy (PJM)
- [ ] PM.1.19: Assign tasks to work team members per the accepted Project Plan (PJM, WT)

### Work Products Created
- Project Plan [accepted]
- Project Repository [established]
- Verification Report (Project Plan) [published]
- Meeting Record [published]

### Work Products Used
- Statement of Work [reviewed] → `docs/pm/statement-of-work.md`
- System Design Document (for SBS, if available)

---

## PM.2 Project Plan Execution

**Objective:** Monitor progress, manage changes, conduct reviews, and maintain
the repository.

### Task Checklist

- [ ] PM.2.1: Monitor Project Plan execution, record actual data in Progress Status Record (PJM, WT)
- [ ] PM.2.2: Analyse and evaluate Change Requests for cost, schedule, and technical impact (ACQ, PJM, STK)
- [ ] PM.2.3: Conduct revision meetings with Work Team, identify problems, review risk status (PJM, WT)
- [ ] PM.2.4: Conduct revision meetings with Acquirer and Stakeholders, record agreements (PJM, ACQ, STK, WT)
- [ ] PM.2.5: Perform configuration management, generate product, initiate CRs on baselined artefacts (PJM, WT)
- [ ] PM.2.6: Manage Project Repository, perform backup and recovery testing (PJM)
- [ ] PM.2.7: Perform Project Repository recovery if necessary (PJM)

### Work Products Created
- Progress Status Record [evaluated]
- Change Request [evaluated, agreed]
- Meeting Record [updated]
- Project Plan [updated]
- Project Repository [updated, backup]

### Work Products Used
- Project Plan [accepted]
- Change Request [submitted]
- Meeting Record
- Progress Status Record

---

## PM.3 Project Assessment and Control

**Objective:** Evaluate progress against the plan, take corrective actions,
and maintain the Justification Document.

### Task Checklist

- [ ] PM.3.1: Evaluate project progress against the Project Plan (tasks, results, resources, cost, time, risk) (PJM, WT)
- [ ] PM.3.2: Establish and execute corrective actions, document in Correction Register, track to closure (PJM, WT)
- [ ] PM.3.3: Elaborate or update the Justification Document (reasons, trade-offs, decisions, V&V reports, traceability) (PJM, WT)

### Work Products Created
- Progress Status Record [evaluated]
- Correction Register [published]
- Justification Document [published] → `docs/pm/justification-document.md`

### Work Products Used
- Project Plan [updated]
- Progress Status Record
- Correction Register

---

## PM.4 Project Closure

**Objective:** Formalise completion, baseline the repository, and execute
disposal.

### Task Checklist

- [ ] PM.4.1: Formalise project completion per Delivery Instructions, obtain Product Acceptance Record (PJM, ACQ)
- [ ] PM.4.2: Update and baseline Project Repository (PJM, WT)
- [ ] PM.4.3: Execute the Disposal Management Approach (PJM, WT)

### Work Products Created
- Product Acceptance Record [approved, published]
- Project Repository [baselined]
- Disposed System

### Work Products Used
- Project Plan
- Product [delivered, accepted]
- Project Repository [updated]

---

## SR.1 Initiation

**Objective:** Review the Project Plan with the Work Team, generate the SEMP,
define the data model, and set up the implementation environment.

### Task Checklist

- [ ] SR.1.1: Revise the Project Plan with the Work Team, achieve common understanding and engagement (PJM, WT)
- [ ] SR.1.2: Define technical activities in cooperation with PJM and generate the SEMP (PJM, SYS)
- [ ] SR.1.3: Define the data model (entities, properties, relations) (PJM, WT)
- [ ] SR.1.4: Set or update the implementation environment (PJM, WT)

### Work Products Created
- Project Plan [reviewed]
- SEMP [verified, accepted]
- Data Model → `docs/sr/data-model.md`
- Implementation Environment

### Work Products Used
- Project Plan

---

## SR.2 System Requirements Engineering

**Objective:** Elicit stakeholder needs, derive and validate system
requirements, establish traceability, and create the IVV Plan.

### Task Checklist

- [ ] SR.2.1: Elicit acquirer and stakeholder requirements, analyse system context, generate StRS (SYS, ACQ, STK)
- [ ] SR.2.2: Verify StRS with PJM, obtain Work Team agreement (PJM, WT)
- [ ] SR.2.3: Validate StRS with Acquirer and Stakeholders (PJM, SYS, ACQ, STK)
- [ ] SR.2.4: Elaborate System Requirements and Interfaces (boundary, design constraints, SMART criteria) (SYS, DES)
- [ ] SR.2.5: Elaborate System Elements Requirements and System Interfaces Specifications (DES, SYS)
- [ ] SR.2.6: Verify and obtain Work Team agreement on System and System Elements Requirements (PJM, WT)
- [ ] SR.2.7: Validate that SyRS satisfies StRS (ACQ, STK, SYS)
- [ ] SR.2.8: Define or update traceability between stakeholder, system, and element requirements (SYS, DES)
- [ ] SR.2.9: Establish or update the IVV Plan and IVV Procedures (SYS, IVV)

### Work Products Created
- Stakeholder Requirements Specification [validated]
- System Requirements Specification [verified, validated]
- System Elements Requirements Specification → `docs/sr/system-element-requirements.md`
- Traceability Matrix [updated]
- IVV Plan [published]
- IVV Procedures [published]
- Verification Report [published]
- Validation Report [published]

### Work Products Used
- Project Plan
- Tasks [assigned]
- Statement of Work [reviewed]
- SEMP

---

## SR.3 System Architectural Design

**Objective:** Design the functional and physical architecture, make
trade-offs, and verify the design.

### Task Checklist

- [ ] SR.3.1: Document or update the Functional System Design (internal functions, interfaces, external functions) (DES)
- [ ] SR.3.2: Make trade-offs of System Functional Architecture, update Justification Document (SYS, DES)
- [ ] SR.3.3: Document or update the Physical System Design (allocate functions to physical elements, identify reuse) (DES)
- [ ] SR.3.4: Make trade-offs of System Physical Architecture, update Traceability Matrix (SYS, DES)
- [ ] SR.3.5: Verify and obtain approval of the System Design (correctness, feasibility, traceability) (SYS, DES, DEV)
- [ ] SR.3.6: Establish or update the Integration Plan and IVV Procedures for system integration (DES, SYS)
- [ ] SR.3.7: Document the System User Manual (optional, preliminary) (SYS)
- [ ] SR.3.8: Verify and obtain approval of the System User Manual (optional) (SYS, ACQ, STK)

### Work Products Created
- System Design Document [verified, validated]
- Justification Document [published] → `docs/pm/justification-document.md`
- IVV Plan [updated]
- IVV Procedures [updated]
- Traceability Matrix [updated]
- System User Manual [preliminary] (optional) → `docs/sr/system-user-manual.md`
- Verification Report [published]
- Purchase Order [initiated] (if applicable) → `docs/pm/purchase-order.md`

### Work Products Used
- Project Plan
- Tasks [assigned]
- System Requirements Specification [validated]
- Traceability Matrix [updated]

---

## SR.4 System Construction

**Objective:** Build, buy, or reuse system elements and verify them against
their specifications.

### Task Checklist

- [ ] SR.4.1: Construct or update Software System Elements (may follow ISO/IEC TR 29110-5-1-2) (DEV)
- [ ] SR.4.2: Construct or update Hardware System Elements (buy, build, or reuse per System Design) (DEV)
- [ ] SR.4.3: Verify that System Elements satisfy their System Elements Specifications (DEV, DES, SYS)
- [ ] SR.4.4: Correct defects found until successful verification (reaching exit criteria) (DEV)

### Work Products Created
- Software System Elements
- Hardware System Elements (HW, HW+SW)
- System Elements [verified, accepted]

### Work Products Used
- Project Plan
- Tasks [assigned]
- System Design Document [validated]
- System Elements Requirements Specification [validated]

---

## SR.5 System Integration, Verification and Validation

**Objective:** Integrate system elements, verify the system against
requirements, validate against stakeholder needs, and obtain acceptance.

### Task Checklist

- [ ] SR.5.1: Verify IVV Plan and Procedures, check consistency with requirements and design (DES, SYS, DEV, IVV)
- [ ] SR.5.2: Integrate the System using System Elements, verify interfaces per IVV Procedures (IVV, DES, SUP)
- [ ] SR.5.3: Verify the System against its requirements, document in Verification Report (IVV, SYS)
- [ ] SR.5.4: Validate the System against Stakeholder Requirements, obtain ACQ acceptance (IVV, SYS, ACQ)
- [ ] SR.5.5: Correct defects found and retest to detect faults introduced by modifications (WT)
- [ ] SR.5.6: Document the System Operation Guide (optional) (SYS, DES)
- [ ] SR.5.7: Verify and obtain approval of the System Operation Guide (optional) (SYS, ACQ, STK)

### Work Products Created
- Verification Report [published]
- Integration Report [published] → `docs/sr/integration-report.md`
- System [integrated, verified, validated, corrected]
- Validation Report [published]
- Product Acceptance Record
- System Operation Guide [preliminary] (optional) → `docs/sr/system-operation-guide.md`
- System [approved]

### Work Products Used
- Project Plan
- Tasks [assigned]
- IVV Plan
- IVV Procedures
- System Requirements Specification [validated]
- System Design Document [validated]
- Traceability Matrix [updated]
- System Elements [accepted]

---

## SR.6 Product Delivery

**Objective:** Review the product, prepare maintenance and training
documentation, and deliver the system.

### Task Checklist

- [ ] SR.6.1: Review Product (system elements against Delivery Instructions) (PJM, WT)
- [ ] SR.6.2: Document the System Maintenance Document (SYS, DES)
- [ ] SR.6.3: Identify training needs and develop System Training Specifications (SYS, DES)
- [ ] SR.6.4: Verify and obtain approval of Maintenance Document and Training Specifications (PJM, SYS, DES, STK, ACQ)
- [ ] SR.6.5: Perform delivery (training, transition support, legacy data conversion, disposal) (PJM, ACQ)
- [ ] SR.6.6: Transition to manufacturing and in-service/after-sales support (PJM)

### Work Products Created
- System Maintenance Document [validated]
- System Training Specifications [validated] → `docs/sr/training-specifications.md`
- Product Acceptance Record [published]
- Product [delivered]

### Work Products Used
- System Elements
- Project Plan
- Delivery Instructions
- System Configuration
- System Requirements Specification [validated]
- System User Manual [verified]
- System [validated]

---

## Quick Reference: Phase to Template Mapping

| Phase | Template File | Work Product |
|-------|--------------|-------------|
| PM.1 | docs/pm/statement-of-work.md | Statement of Work |
| PM.1 | docs/pm/project-plan.md | Project Plan |
| PM.1-PM.4 | docs/pm/meeting-record.md | Meeting Record |
| PM.2 | docs/pm/progress-status.md | Progress Status Record |
| PM.2 | docs/pm/change-request.md | Change Request |
| PM.3 | docs/pm/correction-register.md | Correction Register |
| PM.3 / SR.3 | docs/pm/justification-document.md | Justification Document |
| PM.4 | docs/pm/product-acceptance.md | Product Acceptance Record |
| SR.1 | docs/sr/semp.md | SEMP |
| SR.1 | docs/sr/data-model.md | Data Model |
| SR.2 | docs/sr/stakeholder-requirements.md | StRS |
| SR.2 | docs/sr/system-requirements.md | SyRS |
| SR.2 | docs/sr/system-element-requirements.md | System Elements Requirements |
| SR.2+ | docs/sr/traceability-matrix.md | Traceability Matrix |
| SR.2/SR.5 | docs/sr/ivv-plan.md | IVV Plan |
| SR.3 | docs/sr/system-design.md | System Design Document |
| SR.3 | docs/pm/purchase-order.md | Purchase Order |
| SR.3 (optional) | docs/sr/system-user-manual.md | System User Manual |
| SR.5 | docs/sr/integration-report.md | Integration Report |
| SR.5 | docs/sr/verification-report.md | Verification Report |
| SR.5 | docs/sr/validation-report.md | Validation Report |
| SR.5 (optional) | docs/sr/system-operation-guide.md | System Operation Guide |
| SR.6 | docs/sr/maintenance-guide.md | Maintenance Documentation |
| SR.6 | docs/sr/training-specifications.md | System Training Specifications |
