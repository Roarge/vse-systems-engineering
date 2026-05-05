---
title: "ISO/IEC 29110 Project Management Process (PM.1 to PM.4)"
slug: iso29110-pm-process
type: reference
layer: iso29110
tags: [iso29110, pm, project-management, planning, execution, closure]
sources:
  - citation: "ISO/IEC TR 29110-5-6-2:2014, Chapter on Project Management Process."
    raw: ISO_IEC_TR_29110-5-6-2_2014.pdf
related:
  - iso29110-overview
  - iso29110-sr-process
  - iso29110-pm-task-checklists
  - iso29110-roles-and-work-products
  - iso29110-phase-gates
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [project-setup, release-orchestrator]
---

# ISO/IEC 29110 Project Management Process (PM.1 to PM.4)

**Purpose.** Establish and carry out in a systematic way the tasks
of the system development project, allowing compliance with
project objectives in the expected quality, time, and cost.

## Process objectives

| ID | Objective |
|---|---|
| **PM.O1** | Project Plan and SOW reviewed and accepted by both Acquirer and PJM. Tasks and resources sized and estimated. |
| **PM.O2** | Progress monitored against the Project Plan, recorded in the Progress Status Record. Corrections taken when targets are not achieved. Closure performed to obtain Acquirer acceptance. |
| **PM.O3** | Change Requests addressed through reception and analysis. Changes evaluated for cost, schedule, risk, and technical impact. |
| **PM.O4** | Review meetings with Work Team, Acquirer, and suppliers held. Agreements registered and tracked. |
| **PM.O5** | Risk Management Approach developed. Risks identified, analysed, prioritised, and monitored. |
| **PM.O6** | Product Management Strategy developed. Configuration items identified, defined, baselined, and controlled. See [[sysml2-vse-library-metadata]] for the model-level `ConfigItem` and `Baseline` metadata that complements the PM-level strategy. |
| **PM.O7** | Quality Assurance performed to provide assurance that work products and processes comply with the Project Plan and System Requirements Specifications. |
| **PM.O8** | Disposal Management Approach developed. |

## PM.1 Project Planning

**Objectives**: PM.O1, PM.O5, PM.O6, PM.O7.

**Inputs**: Statement of Work (from Acquirer), System Design
Document (for SBS), Project Plan (iterative).

**Outputs**: Project Plan [accepted], Project Repository,
Verification Report (Project Plan), Meeting Record.

| Task | Description | Key Roles |
|---|---|---|
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

## PM.2 Project Plan Execution

**Objectives**: PM.O2, PM.O3, PM.O4, PM.O5, PM.O7.

**Inputs**: Project Plan [accepted], Change Request [submitted],
Meeting Record, Progress Status Record.

**Outputs**: Progress Status Record, Change Request
[evaluated/agreed], Meeting Record [updated], Project Plan
[updated], Product, Project Repository [updated/backup].

| Task | Description | Key Roles |
|---|---|---|
| PM.2.1 | Monitor Project Plan execution, record actual data in Progress Status Record | PJM, WT |
| PM.2.2 | Analyse and evaluate Change Requests for cost, schedule, and technical impact | ACQ, PJM, STK |
| PM.2.3 | Conduct revision meetings with Work Team, identify problems, review risk status | PJM, WT |
| PM.2.4 | Conduct revision meetings with Acquirer and Stakeholders, record agreements | PJM, ACQ, STK, WT |
| PM.2.5 | Perform configuration management, generate product as planned, initiate Change Requests on baselined artefacts | PJM, WT |
| PM.2.6 | Manage Project Repository, perform backup and recovery testing | PJM |
| PM.2.7 | Perform Project Repository recovery if necessary | PJM |

## PM.3 Project Assessment and Control

**Objective**: PM.O2.

**Inputs**: Project Plan [updated], Progress Status Record,
Correction Register.

**Outputs**: Progress Status Record [evaluated], Correction
Register, Justification Document.

| Task | Description | Key Roles |
|---|---|---|
| PM.3.1 | Evaluate project progress against the Project Plan (tasks, results, resources, cost, time, risk) | PJM, WT |
| PM.3.2 | Establish and execute corrective actions, document in Correction Register, track to closure | PJM, WT |
| PM.3.3 | Elaborate or update the Justification Document (record reasons, trade-offs, decisions, V&V reports, traceability) | PJM, WT |

## PM.4 Project Closure

**Objectives**: PM.O2, PM.O8.

**Inputs**: Project Plan, Product [delivered/accepted], Project
Repository [updated].

**Outputs**: Product Acceptance Record, Project Repository
[baselined], Disposed System.

| Task | Description | Key Roles |
|---|---|---|
| PM.4.1 | Formalise project completion per Delivery Instructions, obtain Product Acceptance Record | PJM, ACQ |
| PM.4.2 | Update Project Repository | PJM, WT |
| PM.4.3 | Execute the Disposal Management Approach | PJM, WT |

## See also

- [[iso29110-overview]] for the profile context.
- [[iso29110-sr-process]] for the SR process that runs alongside PM.
- [[iso29110-pm-task-checklists]] for actionable PM checklists with
  work-product mappings.
- [[iso29110-roles-and-work-products]] for role abbreviations and
  work-product catalogue.
- [[iso29110-phase-gates]] for PM-to-SR transition checklists.
