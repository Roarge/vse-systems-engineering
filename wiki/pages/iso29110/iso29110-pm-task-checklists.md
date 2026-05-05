---
title: "ISO/IEC 29110 PM Task Checklists (PM.1 to PM.4)"
slug: iso29110-pm-task-checklists
type: process
layer: iso29110
tags: [iso29110, pm, task-checklist, work-products]
sources:
  - citation: "ISO/IEC TR 29110-5-6-2:2014, Project Management task tables."
    raw: ISO_IEC_TR_29110-5-6-2_2014.pdf
related:
  - iso29110-pm-process
  - iso29110-sr-task-checklists
  - iso29110-template-mapping
  - iso29110-phase-gates
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [project-setup, release-orchestrator]
---

# ISO/IEC 29110 PM Task Checklists (PM.1 to PM.4)

Actionable task checklists for every ISO 29110 Project Management
activity. Each task lists its responsible roles, and each phase
declares the work products created and used. Use these checklists
to generate project-specific TASKS.md files and to track progress
through the lifecycle. For role abbreviations and work-product
catalogue, see [[iso29110-roles-and-work-products]].

## PM.1 Project Planning

**Objective**: Establish the Project Plan, assign resources, and
obtain acquirer acceptance.

### Task checklist

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

### Work products created

- Project Plan [accepted]
- Project Repository [established]
- Verification Report (Project Plan) [published]
- Meeting Record [published]

### Work products used

- Statement of Work [reviewed] → `docs/pm/statement-of-work.md`
- System Design Document (for SBS, if available)

## PM.2 Project Plan Execution

**Objective**: Monitor progress, manage changes, conduct reviews,
and maintain the repository.

### Task checklist

- [ ] PM.2.1: Monitor Project Plan execution, record actual data in Progress Status Record (PJM, WT)
- [ ] PM.2.2: Analyse and evaluate Change Requests for cost, schedule, and technical impact (ACQ, PJM, STK)
- [ ] PM.2.3: Conduct revision meetings with Work Team, identify problems, review risk status (PJM, WT)
- [ ] PM.2.4: Conduct revision meetings with Acquirer and Stakeholders, record agreements (PJM, ACQ, STK, WT)
- [ ] PM.2.5: Perform configuration management, generate product, initiate CRs on baselined artefacts (PJM, WT)
- [ ] PM.2.6: Manage Project Repository, perform backup and recovery testing (PJM)
- [ ] PM.2.7: Perform Project Repository recovery if necessary (PJM)

### Work products created

- Progress Status Record [evaluated]
- Change Request [evaluated, agreed]
- Meeting Record [updated]
- Project Plan [updated]
- Project Repository [updated, backup]

### Work products used

- Project Plan [accepted]
- Change Request [submitted]
- Meeting Record
- Progress Status Record

## PM.3 Project Assessment and Control

**Objective**: Evaluate progress against the plan, take corrective
actions, and maintain the Justification Document.

### Task checklist

- [ ] PM.3.1: Evaluate project progress against the Project Plan (tasks, results, resources, cost, time, risk) (PJM, WT)
- [ ] PM.3.2: Establish and execute corrective actions, document in Correction Register, track to closure (PJM, WT)
- [ ] PM.3.3: Elaborate or update the Justification Document (reasons, trade-offs, decisions, V&V reports, traceability) (PJM, WT)

### Work products created

- Progress Status Record [evaluated]
- Correction Register [published]
- Justification Document [published] → `docs/pm/justification-document.md`

### Work products used

- Project Plan [updated]
- Progress Status Record
- Correction Register

## PM.4 Project Closure

**Objective**: Formalise completion, baseline the repository, and
execute disposal.

### Task checklist

- [ ] PM.4.1: Formalise project completion per Delivery Instructions, obtain Product Acceptance Record (PJM, ACQ)
- [ ] PM.4.2: Update and baseline Project Repository (PJM, WT)
- [ ] PM.4.3: Execute the Disposal Management Approach (PJM, WT)

### Work products created

- Product Acceptance Record [approved, published]
- Project Repository [baselined]
- Disposed System

### Work products used

- Project Plan
- Product [delivered, accepted]
- Project Repository [updated]

## See also

- [[iso29110-pm-process]] for the underlying activity definitions.
- [[iso29110-sr-task-checklists]] for SR-process task checklists.
- [[iso29110-template-mapping]] for phase-to-template-file
  mappings used by `@project-setup` to scaffold work-product
  templates.
- [[iso29110-phase-gates]] for gate transition checklists.
