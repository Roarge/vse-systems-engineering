---
title: "Project Management workflow (§10)"
slug: project-management-workflow
type: process
layer: methodology
tags: [project-management, plan, change-request, risk-register, cm-strategy, disposal, pm-objectives]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §10 (Project Management)."
    raw: methodology/10-project-management.md
related:
  - methodology-overview
  - story-branch-pr-workflow
  - iso-29110-compliance-mapping
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, project-plan, release-orchestrator, change-request, project-setup]
---

# Project Management workflow (§10)

The Project Management (PM) process is the ISO/IEC TR 29110-5-6-2:2014 §7 backbone of the methodology, adapted so that the Project Plan is a living artefact under git version control, the Progress Status Record advances at iteration cadence rather than at fixed phase gates, and Change Requests take the shape of pull requests. The activities themselves match ISO 29110 PM.1 to PM.4 in name and purpose, and produce the artefact set required by PM.O1 to PM.O8. See [[methodology-overview]] for how PM sits alongside the technical activities, [[story-branch-pr-workflow]] for the git-execution discipline that PM.2 rides on, and [[iso-29110-compliance-mapping]] for the per-task evidence trail.

## Process structure (§10.2)

PM has four activities, in compliance with ISO 29110 §7.7.

- **PM.1 Project Planning** produces the Project Plan and the initial Project Repository.
- **PM.2 Project Plan Execution** implements the Plan, monitors progress, processes Change Requests, and maintains Meeting Records.
- **PM.3 Project Assessment and Control** evaluates performance against the Plan, producing the Progress Status Record and the Justification Document.
- **PM.4 Project Closure** is formal delivery and acceptance, with execution of the Disposal Management Approach.

The activities are not strictly sequential. PM.1 establishes the baseline. PM.2 and PM.3 run continuously through the project, with PM.3 evaluating PM.2 outputs and feeding revisions back into PM.2. PM.4 occurs at project closure, which may itself be iterative for product families.

## PM.1 Planning (§10.3)

The Project Plan is a Markdown document committed to the repository at `docs/project-plan.md`. It is the canonical reference for scope, schedule, resources, and engineering discipline. Its structure follows the ISO 29110 PM.1 task list (Table 6) item by item, with the seventeen elements below.

| Element | ISO 29110 task |
|---|---|
| Reference to the SOW | PM.1.14 |
| Objectives | PM.1.14 |
| System Description | PM.1.14 |
| Scope | PM.1.14 |
| System Breakdown Structure (SBS) | PM.1.3 |
| Deliverables | PM.1.14 |
| Tasks | PM.1.5 |
| Estimated Duration | PM.1.6 |
| Resources | PM.1.7 |
| Composition of Work Team | PM.1.8 |
| Milestones | PM.1.4, PM.1.9 |
| Schedule of Project Tasks | PM.1.9 |
| Estimated Effort and Cost | PM.1.10 |
| Risk Management Approach | PM.1.11 |
| Disposal Management Approach | PM.1.12 |
| Configuration Management Strategy | PM.1.13 |
| Delivery Instructions | PM.1.2 |

The Systems Engineering Management Plan (SEMP, ISO 29110 product 21) is either a top-level section of the Project Plan or a separate document at `docs/semp.md`. A minimal SEMP states the methodology and version, the engineering tools, the engineering interfaces with adjacent projects and certifying authorities, the mission assurance and review cadence, and the Technical Performance Management measure set.

Plan acceptance (§10.3.4) reuses the same review and merge discipline as any other artefact. The Plan is authored on a feature branch, opened as a pull request that includes a completeness checklist derived from the seventeen elements, reviewed by Acquirer and Stakeholders, passed through CI lint, squash-merged to `main`, and tagged on the merge commit as `plan-baseline-vN.M`. Subsequent revisions follow the Change Request workflow with a new tag on each acceptance.

## PM.2 Execution (§10.4)

**Progress monitoring (§10.4.1).** The Progress Status Record at `docs/progress-status-record.md` is appended to at every iteration boundary. Each entry records planned versus actual stories, planned versus actual hours, blockers and resolutions, risk-status changes, and schedule adherence. Entries are immutable once committed. Corrections go in a subsequent entry.

**Change Request lifecycle (§10.4.2).** The Change Request artefact has six lifecycle states, mapped onto the git workflow:

- **submitted**: Issue opened with the `change-request` label, describing the proposed change and impact.
- **evaluated**: PJM, or a designated reviewer, adds cost, schedule, and technical-impact assessment in an Issue comment.
- **agreed**: Issue accepted. A story branch (or Plan-revision branch) is opened.
- **in implementation**: PR open against the agreed scope.
- **done**: PR merged and the Issue closed with reference to the merge commit.
- **rejected**: Issue closed with rationale comment.
- **postponed**: Issue labelled `postponed` and revisited at the next iteration boundary.

The Issue thread is the Change Request artefact. The PR thread is the implementation record. Both are preserved indefinitely as audit trail. Change Requests against baselined artefacts require explicit Acquirer agreement recorded in the Issue before the implementing PR is merged.

**Meeting Records (§10.4.3).** Meeting Records (ISO 29110 product 10) land at `docs/meetings/<YYYY-MM-DD>-<topic>.md` with purpose, attendees, date and place, reference to previous minutes, what was accomplished, issues raised, open issues, agreements, and next meeting. Asynchronous PR reviews count as Meeting Records when they involve substantive Acquirer or Stakeholder agreement, in which case the PR URL plus a brief summary is sufficient.

**Configuration Management execution (§10.4.4).** PM.2.5 implements the CM Strategy of §10.8. State transitions of items under configuration are events visible in git history. Repository management and recovery testing (PM.2.6 and PM.2.7) are git-native, with continuous mirroring to a backup remote and a periodic restore test from that mirror into a scratch clone.

## PM.3 Assessment and Control (§10.5)

Progress evaluation augments each iteration-boundary Progress Status Record entry with a variance section against Plan on tasks, results, resources, cost, time, and risk. Significant deviations, recommended at above ten per cent on any axis, trigger the corrective-action workflow.

The Correction Register at `docs/correction-register.md` records, per correction: initial problem, planned solution, corrective actions taken, owner, open and target-closure dates, status, follow-up actions, and rationale linked to the Justification Document.

The Justification Document is aggregated rather than authored. At any moment it is the union of all trade-study `analysis def` instances on `main`, all Architecture Decision Records under `docs/decisions/`, and all V&V Reports referenced by acceptance criteria. A renderer in `tools/` walks these sources and produces `docs/justification-document.md` as a navigable index, regenerated by CI on merge. The renderer also establishes traceability between the rationale and the related SE artefacts by following `derive`, `frame concern`, `verify`, and `allocation` relations.

## PM.4 Closure (§10.6)

Delivery and acceptance produce the Product Acceptance Record at `docs/product-acceptance-record.md`, signed (committed by the Acquirer git identity or recorded by an authorised proxy). The closing tag `release-vN.M` is pushed and the repository at that tag becomes the project's permanent record. The repository is set to read-only mode for fully closed projects. Active product families remain writable for subsequent iterations. Disposal execution follows §10.9. Where disposal is contracted forward, the Disposal Management Approach is delivered at closure and executed as a separate subsequent activity.

## Risk Management Approach (§10.7)

The Risk Management Approach states the identification approach (frequency, participants, sources), the risk register location at `docs/risk-register.md`, the evaluation criteria (likelihood times impact, project-determined scale), the treatment options (avoid, mitigate, transfer, accept), and the per-iteration monitoring cadence. Each register entry has ID, description, likelihood, impact, priority, owner, treatment, status, date opened, and date last reviewed. Where a risk's mitigation becomes engineering work, it is captured as a story. Programmatic risks (cost, schedule) remain in the register and are treated through PM.2 and PM.3.

## Configuration Management Strategy (§10.8)

The CM Strategy lists the items under configuration (Project Plan, methodology specification, story registers, concern register, base architecture, system context, logical architecture, trade studies, verification and validation cases, IVV plan and procedures, risk register, justification document), the four states (`draft`, `inProgress`, `readyForReview`, `baselined`), the baseline strategy (annotated git tag `release-vN.M` per release, indefinite retention), the backup arrangement (primary and mirror remotes, continuous via post-receive hook, monthly automated recovery test), and the access-control policy (protected branches, force push disabled, CODEOWNERS-driven required reviews).

## Disposal Management Approach (§10.9)

The Disposal Management Approach states the trigger event (decommission, replacement, end of contract), the schedule relative to project closure, the actions (hardware retirement, data archival or destruction, software licence release, intellectual-property handover, environmental obligations), the resources (who performs disposal, with budget where applicable), the design constraints that must be reflected in system stories (such as a factory-reset capability that wipes operator data), and the acceptable end-state. For systems with non-trivial disposal, the constraints are propagated into stakeholder concerns and addressed by stories.

## Roles in the PM process (§10.11)

| Role | PM responsibility |
|---|---|
| Project Manager (PJM) | Owns Plan, Progress Status Record, Correction Register, Risk Register, chairs review meetings, approves Change Requests, signs Acceptance Record |
| Acquirer (ACQ) | Reviews and accepts Plan, reviews and signs Change Requests against baselined artefacts, reviews and signs Acceptance Record |
| Stakeholder (STK) | Participates in Plan review, raises Change Requests, reviews Meeting Records for accuracy |
| Systems Engineer (SYS), Designer (DES), IVV Engineer (IVV) | Author Plan content within their scope, participate in Assessment and Control, raise Change Requests for technical needs |
| Work Team (WT) | Performs Plan tasks, updates Progress Status Record entries, participates in retrospectives that feed the Justification Document |

CODEOWNERS in the repository assigns each role to git identities. Multiple roles per identity are permitted and expected at VSE scale.
