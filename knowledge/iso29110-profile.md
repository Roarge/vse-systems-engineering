# ISO/IEC 29110 VSE Systems Engineering Profile

## Overview

ISO/IEC TR 29110-5-6-2:2014 provides a Management and Engineering Guide for the Basic Profile of the Generic Profile Group for Systems Engineering. It targets Very Small Entities (VSEs), defined as enterprises, organisations, departments, or projects having up to 25 people. The standard applies to non-critical systems development projects and is lifecycle-neutral, meaning it can be used with waterfall, iterative, incremental, evolutionary, agile, or test-driven approaches.

The guide is structured around two interrelated processes: Project Management (PM) and System Definition and Realization (SR). PM uses the Acquirer's Statement of Work (SOW) to elaborate a Project Plan, monitor progress, handle change requests, and close the project. SR is driven by the Systems Engineering Management Plan (SEMP) and covers requirements elicitation, architectural design, construction, integration, verification, validation, and product delivery.

Entry conditions require that project needs and expectations are documented, feasibility has been assessed, a project team (including project manager and systems engineer) is assigned and trained, and goods, services, and infrastructure are available. The standard is based on ISO/IEC 15288 (system life cycle processes) and ISO/IEC/IEEE 15289 (life cycle information products).

## Project Management (PM) Process

**Purpose.** Establish and carry out in a systematic way the tasks of the system development project, allowing compliance with project objectives in the expected quality, time, and cost.

**Objectives:**
- **PM.O1.** Project Plan and SOW reviewed and accepted by both Acquirer and PJM. Tasks and resources sized and estimated.
- **PM.O2.** Progress monitored against the Project Plan, recorded in the Progress Status Record. Corrections taken when targets are not achieved. Closure performed to obtain Acquirer acceptance.
- **PM.O3.** Change Requests addressed through reception and analysis. Changes evaluated for cost, schedule, risk, and technical impact.
- **PM.O4.** Review meetings with Work Team, Acquirer, and suppliers held. Agreements registered and tracked.
- **PM.O5.** Risk Management Approach developed. Risks identified, analysed, prioritised, and monitored.
- **PM.O6.** Product Management Strategy developed. Configuration items identified, defined, baselined, and controlled.
- **PM.O7.** Quality Assurance performed to provide assurance that work products and processes comply with the Project Plan and System Requirements Specifications.
- **PM.O8.** Disposal Management Approach developed.

### PM.1 Project Planning

**Objectives: PM.O1, PM.O5, PM.O6, PM.O7**

**Inputs:** Statement of Work (from Acquirer), System Design Document (for SBS), Project Plan (iterative).

**Outputs:** Project Plan [accepted], Project Repository, Verification Report (Project Plan), Meeting Record.

| Task | Description | Key Roles |
|------|-------------|-----------|
| PM.1.1 | Review the Statement of Work | PJM, SYS |
| PM.1.2 | Define Delivery Instructions for each deliverable in the SOW | PJM, ACQ |
| PM.1.3 | Define the System Breakdown Structure (SBS) | PJM, DES |
| PM.1.4 | Select product lifecycle and define milestones | PJM, WT |
| PM.1.5 | Identify specific tasks to produce deliverables, including V&V and review tasks | PJM, SYS |
| PM.1.6 | Establish estimated duration for each task | PJM |
| PM.1.7 | Identify and document resources (human, material, equipment, tools, training) | PJM |
| PM.1.8 | Establish composition of Work Team, assign roles and responsibilities | PJM |
| PM.1.9 | Assign estimated start and completion dates, define schedule and milestones | PJM |
| PM.1.10 | Calculate and document estimated effort and cost | PJM |
| PM.1.11 | Identify and document Risk Management Approach | PJM |
| PM.1.12 | Identify and document Disposal Management Approach | PJM |
| PM.1.13 | Document Configuration Management Strategy in the Project Plan | PJM |
| PM.1.14 | Include System Description, Scope, Objectives, Deliverables, and SOW reference | PJM |
| PM.1.15 | Generate the integrated Project Plan | PJM |
| PM.1.16 | Verify and obtain internal approval of the Project Plan | PJM, WT |
| PM.1.17 | Review and accept the Project Plan with Acquirer and Stakeholders | PJM, ACQ, STK |
| PM.1.18 | Establish the Project Repository using the Configuration Management Strategy | PJM |
| PM.1.19 | Assign tasks to work team members according to the accepted Project Plan | PJM, WT |

### PM.2 Project Plan Execution

**Objectives: PM.O2, PM.O3, PM.O4, PM.O5, PM.O7**

**Inputs:** Project Plan [accepted], Change Request [submitted], Meeting Record, Progress Status Record.

**Outputs:** Progress Status Record, Change Request [evaluated/agreed], Meeting Record [updated], Project Plan [updated], Product, Project Repository [updated/backup].

| Task | Description | Key Roles |
|------|-------------|-----------|
| PM.2.1 | Monitor Project Plan execution, record actual data in Progress Status Record | PJM, WT |
| PM.2.2 | Analyse and evaluate Change Requests for cost, schedule, and technical impact | ACQ, PJM, STK |
| PM.2.3 | Conduct revision meetings with Work Team, identify problems, review risk status | PJM, WT |
| PM.2.4 | Conduct revision meetings with Acquirer and Stakeholders, record agreements | PJM, ACQ, STK, WT |
| PM.2.5 | Perform configuration management, generate product as planned, initiate Change Requests on baselined artefacts | PJM, WT |
| PM.2.6 | Manage Project Repository, perform backup and recovery testing | PJM |
| PM.2.7 | Perform Project Repository recovery if necessary | PJM |

### PM.3 Project Assessment and Control

**Objective: PM.O2**

**Inputs:** Project Plan [updated], Progress Status Record, Correction Register.

**Outputs:** Progress Status Record [evaluated], Correction Register, Justification Document.

| Task | Description | Key Roles |
|------|-------------|-----------|
| PM.3.1 | Evaluate project progress against the Project Plan (tasks, results, resources, cost, time, risk) | PJM, WT |
| PM.3.2 | Establish and execute corrective actions, document in Correction Register, track to closure | PJM, WT |
| PM.3.3 | Elaborate or update the Justification Document (record reasons, trade-offs, decisions, V&V reports, traceability) | PJM, WT |

### PM.4 Project Closure

**Objectives: PM.O2, PM.O8**

**Inputs:** Project Plan, Product [delivered/accepted], Project Repository [updated].

**Outputs:** Product Acceptance Record, Project Repository [baselined], Disposed System.

| Task | Description | Key Roles |
|------|-------------|-----------|
| PM.4.1 | Formalise project completion per Delivery Instructions, obtain Product Acceptance Record | PJM, ACQ |
| PM.4.2 | Update Project Repository | PJM, WT |
| PM.4.3 | Execute the Disposal Management Approach | PJM, WT |

## System Definition and Realization (SR) Process

**Purpose.** Systematic performance of the specification, analysis, design, construction, integration, and verification/validation activities for new or modified systems according to specified requirements.

**Objectives:**
- **SR.O1.** Tasks performed through accomplishment of the current Project Plan.
- **SR.O2.** System requirements defined, analysed for correctness and testability, approved by Acquirer, baselined, and communicated.
- **SR.O3.** System architectural design developed and baselined, describing system elements and their interfaces. Consistency and traceability to system requirements established.
- **SR.O4.** System elements produced or acquired from the design. Acceptance tests defined. Traceability to requirements and design established.
- **SR.O5.** System elements integrated. Defects corrected and consistency/traceability to System Architecture established.
- **SR.O6.** System Configuration baselined and stored in Project Repository. Needs for changes detected and Change Requests initiated.
- **SR.O7.** Verification and Validation tasks of all required work products performed using defined criteria. Defects identified and corrected, records stored in Verification/Validation Reports.

### SR.1 Initiation

**Objective: SR.O1**

**Inputs:** Project Plan.

**Outputs:** Project Plan [reviewed], SEMP, Data Model, Implementation Environment.

| Task | Description | Key Roles |
|------|-------------|-----------|
| SR.1.1 | Revise the Project Plan with the Work Team, achieve common understanding and engagement | PJM, WT |
| SR.1.2 | Define technical activities in cooperation with PJM and generate the SEMP | PJM, SYS |
| SR.1.3 | Define the data model of the project (entities, properties, relations) | PJM, WT |
| SR.1.4 | Set or update the implementation environment | PJM, WT |

### SR.2 System Requirements Engineering

**Objectives: SR.O2, SR.O6, SR.O7**

**Inputs:** Project Plan, Tasks [assigned], Statement of Work [reviewed], SEMP.

**Outputs:** Stakeholders Requirements Specifications [validated], System Requirements Specifications [verified/validated], System Elements Requirements Specifications, Traceability Matrix [updated], IVV Plan [published], IVV Procedures [published], Verification Report, Validation Report, Change Request (if needed).

| Task | Description | Key Roles |
|------|-------------|-----------|
| SR.2.1 | Elicit acquirer and stakeholder requirements, analyse system context, generate Stakeholders Requirements Specifications | SYS, ACQ, STK |
| SR.2.2 | Verify Stakeholders Requirements Specifications with PJM, obtain Work Team agreement | PJM, WT |
| SR.2.3 | Validate Stakeholders Requirements Specifications with Acquirer and stakeholders | PJM, SYS, ACQ, STK |
| SR.2.4 | Elaborate System Requirements and Interfaces (boundary, design constraints, SMART criteria, external functions, reuse constraints) | SYS, DES |
| SR.2.5 | Elaborate System Elements Requirements Specifications and System Interfaces Specifications | DES, SYS |
| SR.2.6 | Verify and obtain Work Team agreement on System and System Elements Requirements (SMART check) | PJM, WT |
| SR.2.7 | Validate that System Requirements Specifications satisfy Stakeholders Requirements Specifications | ACQ, STK, SYS |
| SR.2.8 | Define or update traceability between stakeholder, system, and system element requirements | SYS, DES |
| SR.2.9 | Establish or update the IVV Plan and IVV Procedures for system verification and validation | SYS, IVV |

### SR.3 System Architectural Design

**Objectives: SR.O3, SR.O6, SR.O7**

**Inputs:** Project Plan, Tasks [assigned], System Requirements Specifications [validated], Traceability Matrix [updated].

**Outputs:** System Design Document (Functional Architecture, Physical Architecture), Justification Document (trade-offs), IVV Plan, IVV Procedures, Traceability Matrix [updated], System User Manual [preliminary], Verification Report, Validation Report, Change Request (if needed), Purchase Order [initiated].

| Task | Description | Key Roles |
|------|-------------|-----------|
| SR.3.1 | Document or update the Functional System Design (internal functions, interfaces, external functions) | DES |
| SR.3.2 | Make trade-offs of System Functional Architecture, update Justification Document | SYS, DES |
| SR.3.3 | Document or update the Physical System Design (allocate functions to physical elements, identify reuse, elaborate PO) | DES |
| SR.3.4 | Make trade-offs of System Physical Architecture, update Traceability Matrix | SYS, DES |
| SR.3.5 | Verify and obtain approval of the System Design (correctness, feasibility, traceability) | SYS, DES, DEV |
| SR.3.6 | Establish or update the Integration Plan and IVV Procedures for system integration | DES, SYS |
| SR.3.7 | Document the System User Manual (optional, preliminary version) | SYS |
| SR.3.8 | Verify and obtain approval of the System User Manual (optional) | SYS, ACQ, STK |

### SR.4 System Construction

**Objectives: SR.O4, SR.O6, SR.O7**

**Inputs:** Project Plan, Tasks [assigned], System Design Document [validated], System Elements Requirements Specifications [validated], Software System Elements.

**Outputs:** Software System Elements, System Elements data (HW, HW+SW), Bought/built/re-used System Elements [verified/accepted].

| Task | Description | Key Roles |
|------|-------------|-----------|
| SR.4.1 | Construct or update Software System Elements (may follow ISO/IEC TR 29110-5-1-2) | DEV |
| SR.4.2 | Construct or update Hardware System Elements (buy, build, or re-use per System Design and Project Plan) | DEV |
| SR.4.3 | Verify that System Elements satisfy their System Elements Specifications (in-coming acceptance verification) | DEV, DES, SYS |
| SR.4.4 | Correct defects found until successful verification (reaching exit criteria) | DEV |

### SR.5 System Integration, Verification and Validation

**Objectives: SR.O5, SR.O6, SR.O7**

**Inputs:** Project Plan, Tasks [assigned], IVV Plan, IVV Procedures, System Requirements Specifications [validated], System Design Document [validated], Traceability Matrix [updated], System Elements [accepted].

**Outputs:** Verification Report (IVV plans, procedures, system), Integration Report, System [integrated/verified/validated/corrected], Validation Report, Product Acceptance Record, System Operation Guide [preliminary], System [approved].

| Task | Description | Key Roles |
|------|-------------|-----------|
| SR.5.1 | Verify IVV Plan and IVV Procedures, check consistency with requirements and design | DES, SYS, DEV, IVV |
| SR.5.2 | Integrate the System using System Elements (HW, HW+SW), verify interfaces per IVV Procedures | IVV, DES, SUP |
| SR.5.3 | Verify the System against its requirements, document in Verification Report | IVV, SYS |
| SR.5.4 | Validate the System against Stakeholders Requirements, obtain ACQ acceptance | IVV, SYS, ACQ |
| SR.5.5 | Correct defects found and retest to detect faults introduced by modifications | WT |
| SR.5.6 | Document the System Operation Guide (optional) | SYS, DES |
| SR.5.7 | Verify and obtain approval of the System Operation Guide (optional) | SYS, ACQ, STK |

### SR.6 Product Delivery

**Objectives: SR.O6, SR.O7**

**Inputs:** System Elements, Project Plan, Delivery Instructions, System Configuration, System Requirements Specifications [validated], System User Manual [verified], System [validated].

**Outputs:** System Maintenance Document [validated], System Training Specifications [validated], Product Acceptance Record, Product [delivered], Product Acceptance Record [published].

| Task | Description | Key Roles |
|------|-------------|-----------|
| SR.6.1 | Review Product (system elements against Delivery Instructions) | PJM, WT |
| SR.6.2 | Document the System Maintenance Document | SYS, DES |
| SR.6.3 | Identify training needs and develop System Training Specifications | SYS, DES |
| SR.6.4 | Verify and obtain approval of Maintenance Document and Training Specifications | PJM, SYS, DES, STK, ACQ |
| SR.6.5 | Perform delivery (training, transition support, legacy data conversion, disposal of replaced systems) | PJM, ACQ |
| SR.6.6 | Transition to manufacturing and in-service/after-sales support | PJM |

## Roles

| Role | Abbreviation | Key Responsibilities |
|------|-------------|----------------------|
| Acquirer | ACQ | Stakeholders representative responsible for acquisition. Authority to approve requirements and changes. |
| Designer | DES | Architecture design, revision techniques, integration test planning, editing, system development and maintenance. |
| Developer | DEV | Fabrication and development (HW, SW). Application domain knowledge. |
| IVV Engineer | IVV | Requirements and design knowledge. Inspection, peer review, simulation, review, and testing techniques. |
| Project Manager | PJM | Leadership, decision making, planning, delegation, supervision, finances, and system development. |
| Stakeholder | STK | Actors with interest in the system throughout its life cycle (users, maintainers, trainers, regulators, suppliers). Authority to approve requirements. |
| Supplier | SUP | Supplier of a system element (hardware, software, or hardware with software). |
| Systems Engineer | SYS | Requirements elicitation, specification, and analysis. User interface design, revision techniques, requirements authoring, business domain, system development and integration. |
| Work Team | WT | Knowledge and experience according to project roles (SYS, DES, DEV, IVV). Knowledge of applicable standards. |

**PM roles:** ACQ, STK, PJM, WT, DES, SYS.
**SR roles:** ACQ, SYS, DES, DEV, IVV, PJM, STK, SUP, WT.

## Work Products

### PM Work Products

| Product | Type | Statuses |
|---------|------|----------|
| Statement of Work (SOW) | Input | reviewed |
| Project Plan | Input/Output/Internal | verified, accepted, updated, reviewed |
| Product Acceptance Record | Output/Internal | approved, published |
| Project Repository | Output/Internal | established, recovered, updated, baselined |
| Project Repository Backup | Internal | (no status) |
| Meeting Record | Output/Internal | published, updated |
| Change Request | Input/Internal | submitted, evaluated, agreed, approved, rejected, postponed |
| Correction Register | Internal | initial, published |
| Justification Document | Internal | initial, published |
| Progress Status Record | Internal | evaluated |
| Verification Report | Internal | published |
| Purchase Order | Output | initiated, approved |
| Product | Output | delivered, accepted |
| Disposed System | Output | (no status) |

### SR Work Products

| Product | Type | Statuses |
|---------|------|----------|
| Implementation Environment | Internal | (no status) |
| Data Model | Internal | (no status) |
| Systems Engineering Management Plan (SEMP) | Internal | verified, accepted, reviewed |
| Stakeholders Requirements Specifications | Internal | initiated, verified, validated, approved, baselined |
| System Requirements Specifications | Internal | initiated, verified, validated, baselined |
| System Elements Requirements Specifications | Internal | initiated, verified, validated, baselined |
| System Design Document (Functional and Physical Architecture) | Internal | verified, validated, baselined |
| Justification Document (architecture trade-offs) | Internal | initial, published |
| IVV Plan | Internal | verified, published |
| IVV Procedures | Internal | verified, accepted, updated, reviewed |
| Traceability Matrix | Internal | verified, baselined, updated |
| Bought/built/re-used System Elements (HW, HW+SW) | Internal | verified, accepted, rejected |
| System | Internal | integrated, verified, validated, corrected, approved |
| Integration Report | Internal | published |
| Verification Report | Internal | published |
| Validation Report | Internal | published |
| System User Manual | Internal | preliminary, verified, baselined |
| System Operation Guide | Internal | preliminary, verified, baselined |
| System Maintenance Document | Internal | preliminary, verified, validated |
| System Training Specifications | Internal | initiated, verified, validated, baselined |
| System Configuration | Internal | (no status) |
| Product Acceptance Record | Internal | approved, published |

## Phase Gates

### PM.1 to PM.2 (Planning to Execution)

- [ ] Statement of Work reviewed (PM.1.1)
- [ ] Delivery Instructions defined for each deliverable (PM.1.2)
- [ ] System Breakdown Structure defined (PM.1.3)
- [ ] Product lifecycle selected and milestones defined (PM.1.4)
- [ ] Tasks identified including V&V and review tasks (PM.1.5)
- [ ] Estimated duration, resources, effort, and cost documented (PM.1.6, PM.1.7, PM.1.10)
- [ ] Work Team composition established, roles assigned (PM.1.8)
- [ ] Schedule of project tasks and milestones defined (PM.1.9)
- [ ] Risk Management Approach documented (PM.1.11)
- [ ] Disposal Management Approach documented (PM.1.12)
- [ ] Configuration Management Strategy documented (PM.1.13)
- [ ] Project Plan generated, verified, and approved internally (PM.1.15, PM.1.16)
- [ ] Project Plan reviewed and accepted by Acquirer and Stakeholders (PM.1.17)
- [ ] Project Repository established (PM.1.18)
- [ ] Tasks assigned to work team members (PM.1.19)

### SR.1 to SR.2 (Initiation to Requirements)

- [ ] Project Plan reviewed and commitment obtained from Work Team (SR.1.1)
- [ ] SEMP generated defining technical activities (SR.1.2)
- [ ] Data model defined (entities, properties, relations) (SR.1.3)
- [ ] Implementation environment set up or updated (SR.1.4)

### SR.2 to SR.3 (Requirements to Architecture)

- [ ] Stakeholders Requirements Specifications initiated, verified, and validated (SR.2.1, SR.2.2, SR.2.3)
- [ ] System Requirements and Interfaces elaborated using SMART criteria (SR.2.4)
- [ ] System Elements Requirements Specifications elaborated (SR.2.5)
- [ ] System and System Elements Requirements verified by Work Team (SR.2.6)
- [ ] System Requirements validated against Stakeholders Requirements (SR.2.7)
- [ ] Traceability matrix defined or updated between requirement levels (SR.2.8)
- [ ] IVV Plan and IVV Procedures established (SR.2.9)

### SR.3 to SR.4 (Architecture to Construction)

- [ ] Functional System Design documented (SR.3.1)
- [ ] Functional Architecture trade-offs made and recorded in Justification Document (SR.3.2)
- [ ] Physical System Design documented (SR.3.3)
- [ ] Physical Architecture trade-offs made, Traceability Matrix updated (SR.3.4)
- [ ] System Design verified and approved (correctness, feasibility, traceability) (SR.3.5)
- [ ] Integration Plan and IVV Procedures updated for system integration (SR.3.6)
- [ ] System User Manual documented (optional) (SR.3.7)
- [ ] Purchase Orders elaborated for artefacts to be purchased (SR.3.1, SR.3.3)

### SR.4 to SR.5 (Construction to IVV)

- [ ] Software System Elements constructed or updated (SR.4.1)
- [ ] Hardware System Elements constructed or acquired (SR.4.2)
- [ ] System Elements verified against System Elements Specifications (SR.4.3)
- [ ] Defects corrected and exit criteria achieved (SR.4.4)

### SR.5 to SR.6 (IVV to Delivery)

- [ ] IVV Plan and Procedures verified for consistency with requirements and design (SR.5.1)
- [ ] System integrated from System Elements, interfaces verified (SR.5.2)
- [ ] System verified against System Requirements (SR.5.3)
- [ ] System validated against Stakeholders Requirements, Acquirer acceptance obtained (SR.5.4)
- [ ] Defects corrected and retested (SR.5.5)
- [ ] System Operation Guide documented and approved (optional) (SR.5.6, SR.5.7)
- [ ] Product Acceptance Record completed
