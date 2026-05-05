---
title: "ISO/IEC 29110 Phase Gate Checklists"
slug: iso29110-phase-gates
type: process
layer: iso29110
tags: [iso29110, phase-gate, transition, checklist, pm, sr]
sources:
  - citation: "ISO/IEC TR 29110-5-6-2:2014, Phase Gate transition criteria."
    raw: ISO_IEC_TR_29110-5-6-2_2014.pdf
related:
  - iso29110-overview
  - iso29110-pm-process
  - iso29110-sr-process
  - iso29110-pm-task-checklists
  - iso29110-sr-task-checklists
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [project-setup, release-orchestrator]
---

# ISO/IEC 29110 Phase Gate Checklists

This page collects the phase-to-phase transition checklists. Use
each checklist as a verification gate before declaring the next
phase open.

## PM.1 to PM.2 (Planning to Execution)

- [ ] Statement of Work reviewed (PM.1.1)
- [ ] Delivery Instructions defined for each deliverable (PM.1.2)
- [ ] System Breakdown Structure defined (PM.1.3)
- [ ] Product lifecycle selected and milestones defined (PM.1.4)
- [ ] Tasks identified including V&V and review tasks (PM.1.5)
- [ ] Estimated duration, resources, effort, and cost documented
      (PM.1.6, PM.1.7, PM.1.10)
- [ ] Work Team composition established, roles assigned (PM.1.8)
- [ ] Schedule of project tasks and milestones defined (PM.1.9)
- [ ] Risk Management Approach documented (PM.1.11)
- [ ] Disposal Management Approach documented (PM.1.12)
- [ ] Configuration Management Strategy documented (PM.1.13)
- [ ] Project Plan generated, verified, and approved internally
      (PM.1.15, PM.1.16)
- [ ] Project Plan reviewed and accepted by Acquirer and
      Stakeholders (PM.1.17)
- [ ] Project Repository established (PM.1.18)
- [ ] Tasks assigned to work team members (PM.1.19)

## SR.1 to SR.2 (Initiation to Requirements)

- [ ] Project Plan reviewed and commitment obtained from Work Team
      (SR.1.1)
- [ ] SEMP generated defining technical activities (SR.1.2)
- [ ] Data model defined (entities, properties, relations) (SR.1.3)
- [ ] Implementation environment set up or updated (SR.1.4)

## SR.2 to SR.3 (Requirements to Architecture)

- [ ] Stakeholders Requirements Specifications initiated, verified,
      and validated (SR.2.1, SR.2.2, SR.2.3)
- [ ] System Requirements and Interfaces elaborated using SMART
      criteria (SR.2.4)
- [ ] System Elements Requirements Specifications elaborated
      (SR.2.5)
- [ ] System and System Elements Requirements verified by Work
      Team (SR.2.6)
- [ ] System Requirements validated against Stakeholders
      Requirements (SR.2.7)
- [ ] Traceability matrix defined or updated between requirement
      levels (SR.2.8)
- [ ] IVV Plan and IVV Procedures established (SR.2.9)

## SR.3 to SR.4 (Architecture to Construction)

- [ ] Functional System Design documented (SR.3.1)
- [ ] Functional Architecture trade-offs made and recorded in
      Justification Document (SR.3.2)
- [ ] Physical System Design documented (SR.3.3)
- [ ] Physical Architecture trade-offs made, Traceability Matrix
      updated (SR.3.4)
- [ ] System Design verified and approved (correctness,
      feasibility, traceability) (SR.3.5)
- [ ] Integration Plan and IVV Procedures updated for system
      integration (SR.3.6)
- [ ] System User Manual documented (optional) (SR.3.7)
- [ ] Purchase Orders elaborated for artefacts to be purchased
      (SR.3.1, SR.3.3)

## SR.4 to SR.5 (Construction to IVV)

- [ ] Software System Elements constructed or updated (SR.4.1)
- [ ] Hardware System Elements constructed or acquired (SR.4.2)
- [ ] System Elements verified against System Elements
      Specifications (SR.4.3)
- [ ] Defects corrected and exit criteria achieved (SR.4.4)

## SR.5 to SR.6 (IVV to Delivery)

- [ ] IVV Plan and Procedures verified for consistency with
      requirements and design (SR.5.1)
- [ ] System integrated from System Elements, interfaces verified
      (SR.5.2)
- [ ] System verified against System Requirements (SR.5.3)
- [ ] System validated against Stakeholders Requirements, Acquirer
      acceptance obtained (SR.5.4)
- [ ] Defects corrected and retested (SR.5.5)
- [ ] System Operation Guide documented and approved (optional)
      (SR.5.6, SR.5.7)
- [ ] Product Acceptance Record completed

## See also

- [[iso29110-pm-process]] and [[iso29110-sr-process]] for the
  underlying task definitions.
- [[iso29110-pm-task-checklists]] and [[iso29110-sr-task-checklists]]
  for fully expanded task lists with work-product mappings.
- [[story-branch-pr-workflow]] for the
  iteration-centred reading of these gates: phases run as
  centres-of-gravity within iterations rather than as a strict
  sequence.
