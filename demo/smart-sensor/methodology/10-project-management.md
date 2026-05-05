# 10. Project Management

## 10.1 Purpose

This section specifies the Project Management (PM) process compliant
with ISO/IEC TR 29110‑5‑6‑2:2014 §7. It produces and maintains the
artefact set required by ISO 29110 PM objectives PM.O1–PM.O8, and
integrates with the git-based execution discipline of §8.

The methodology's PM process is *iteration-aware*: the Project Plan
is a living artefact under version control, the Progress Status
Record is updated at the cadence of iterations rather than at fixed
phase gates, and Change Requests are PR-shaped. The activities
themselves match ISO 29110 PM.1–PM.4 in name and purpose.

## 10.2 Process structure

The PM process has four activities, in compliance with ISO 29110 §7.7:

- **PM.1 Project Planning** (§10.3) — produces the Project Plan and
  initial Project Repository.
- **PM.2 Project Plan Execution** (§10.4) — implements the Plan;
  monitors progress; processes Change Requests; manages Meeting
  Records.
- **PM.3 Project Assessment and Control** (§10.5) — evaluates
  performance against the Plan; produces the Progress Status Record
  and Justification Document.
- **PM.4 Project Closure** (§10.6) — formal delivery and acceptance;
  Disposal Management Approach execution.

The activities are not strictly sequential. PM.1 establishes the
baseline; PM.2 and PM.3 run continuously through the project, with
PM.3 evaluating PM.2's outputs and feeding revisions back into PM.2;
PM.4 occurs at project closure (which may be iterative for product
families).

```text
        ┌──────────────┐
   SOW ─►   PM.1 Plan  │──► Project Plan ──┐
        └──────────────┘                   │
              ▲                            ▼
              │                ┌─────────────────────┐
        Change Request ──────► │   PM.2 Execution    │ ◄── §0–§8 work
              │                └─────────────────────┘
              │                            │
              │                            ▼
              │              ┌─────────────────────────┐
              └────  Justify ── │ PM.3 Assess & Control │
                              └─────────────────────────┘
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │  PM.4 Close │ ──► Acceptance Record
                                    └─────────────┘
```

## 10.3 PM.1 Project Planning

**Inputs:** Statement of Work (SOW); project initiation conditions
(team assigned, infrastructure available — ISO 29110 §6 entry
conditions).

**Outputs:** Project Plan; Systems Engineering Management Plan (SEMP);
Project Repository.

### 10.3.1 The Project Plan artefact

The Project Plan is a Markdown document committed to the repository at
`docs/project-plan.md`. It is the canonical reference for the project's
scope, schedule, resources, and discipline. Its structure follows
ISO 29110 PM.1 task list (Table 6) item-by-item:

| Element | ISO 29110 task | Notes |
|---|---|---|
| Reference to the SOW | PM.1.14 | Link or appendix reference |
| Objectives | PM.1.14 | What the project shall achieve |
| System Description | PM.1.14 | One paragraph: what the system is |
| Scope | PM.1.14 | What is in and out |
| System Breakdown Structure (SBS) | PM.1.3 | Generated from `core/logical-architecture/` recursively (see §7); rendered as a tree |
| Deliverables | PM.1.14 | List of deliverables to acquirer with acceptance criteria reference |
| Tasks | PM.1.5 | Decomposition of work; tasks reference §0–§8 activities |
| Estimated Duration | PM.1.6 | Per task |
| Resources | PM.1.7 | People, tools, training |
| Composition of Work Team | PM.1.8 | CODEOWNERS for each role; mapping in §9.6 |
| Milestones | PM.1.4, PM.1.9 | Iteration boundaries, baselined releases, delivery dates |
| Schedule of Project Tasks | PM.1.9 | Linked to milestones |
| Estimated Effort and Cost | PM.1.10 | Calculated from tasks × resources |
| Risk Management Approach | PM.1.11 | See §10.7 |
| Disposal Management Approach | PM.1.12 | See §10.9 |
| Configuration Management Strategy | PM.1.13 | See §10.8 |
| Delivery Instructions | PM.1.2 | What is delivered, how, when |

The Project Plan is *baselined* on initial acceptance (PM.1.17) by
tagging the commit and pushing the tag. Subsequent revisions follow
the Change Request workflow (§10.4.2) with full PR review and a new
tag on acceptance.

### 10.3.2 The Systems Engineering Management Plan (SEMP)

The SEMP (ISO 29110 product 21) is either a top-level section of the
Project Plan or a separate document at `docs/semp.md`, project-
determined. It describes the engineering management approach and is
where this methodology spec is *referenced* — i.e., the SEMP cites
§0–§8 and §10 of this methodology as the engineering process to be
followed.

A minimal SEMP states:

- Methodology (this spec) and version;
- Engineering tools (SysML v2 implementation, IDE, linter,
  CI/renderer);
- Engineering interfaces (between this project and adjacent projects,
  contractors, certifying authorities);
- Mission assurance and review cadence (linked to iteration cadence);
- TPM (Technical Performance Management) — the system
  property/measure set tracked during execution.

For projects where the methodology is sufficient SEMP detail, a
Project Plan section is preferred over a separate document.

### 10.3.3 The Project Repository

The Project Repository is the git repository structured per §8.3.
Initial population at PM.1.18 includes:

- The Project Plan (`docs/project-plan.md`);
- This methodology specification (referenced or copied to
  `methodology/`);
- The repository structure scaffolding (`model/core/`,
  `model/library/`, `tools/`, etc., per §8.3);
- The CI/hook configuration (`.github/workflows/`,
  `.git/hooks/` or `core.hooksPath`-managed equivalents,
  `.claude/settings.json` for Claude Code hooks).

The Project Repository Backup (ISO 29110 product 15) is a mirror of
the git repository on a second remote, with a backup verification
schedule documented in the CM Strategy (§10.8).

### 10.3.4 Plan acceptance

PM.1.16 (verify and obtain approval of the Project Plan) is satisfied
by:

1. Authoring the Project Plan in a feature branch.
2. Opening a PR with the Project Plan as its content, including a
   completeness checklist derived from §10.3.1 elements.
3. Review by Acquirer and Stakeholders (PM.1.17) via PR review.
4. CI lint pass (Project Plan completeness check; see hooks guide).
5. Merge to `main` with squash-and-merge per §8.5.
6. Tag the merge commit as `plan-baseline-v1.0`.

This process is the same as for any other artefact (§8) and reuses the
same review/merge discipline.

## 10.4 PM.2 Project Plan Execution

### 10.4.1 Progress monitoring

PM.2.1 (monitor execution and record actual data in Progress Status
Record). Implementation:

- The Progress Status Record (`docs/progress-status-record.md`) is
  appended to at each iteration boundary.
- Each iteration's entry records: planned vs. actual stories
  completed, planned vs. actual hours, blockers and resolutions, risk
  status changes, schedule adherence.
- The entry is a section in the Progress Status Record; it is
  immutable once committed (corrections go in a subsequent entry).

### 10.4.2 Change Request lifecycle

PM.2.2 (analyse and evaluate Change Requests for cost, schedule,
technical impact). The Change Request artefact has the following
lifecycle, mapped onto the git workflow:

```
submitted       → Issue opened with `change-request` label,
                  describing the proposed change and impact
evaluated       → PJM (or designated reviewer) adds
                  cost/schedule/technical impact assessment
                  in an Issue comment
agreed          → Issue accepted; story branch opened per §8.4
                  (or Plan-revision branch if the change is to the Plan)
in implementation → PR open against the agreed scope
done            → PR merged; Issue closed with reference to merge
                  commit
rejected        → Issue closed with rationale comment
postponed       → Issue labelled `postponed`; revisited at next
                  iteration boundary
```

The Issue thread *is* the Change Request artefact. The PR thread is
the implementation record. Both are preserved indefinitely as audit
trail.

Change Requests against *baselined* artefacts (Plan, baselined
stories, baselined architecture) require explicit Acquirer agreement
recorded in the Issue before the implementing PR is merged. The hook
guide (§10 in `iso-29110-hooks-guide.md`) specifies the automation
that enforces this.

### 10.4.3 Meeting Records

PM.2.3, PM.2.4 (review meetings with Work Team and Acquirer/
Stakeholders). The Meeting Record (ISO 29110 product 10) is committed
to `docs/meetings/<YYYY-MM-DD>-<topic>.md`. The minimal content per
ISO 29110 §10 product 10 is:

- Purpose;
- Attendees;
- Date and place;
- Reference to previous minutes;
- What was accomplished;
- Issues raised;
- Open issues;
- Agreements;
- Next meeting (if scheduled).

Asynchronous reviews on PRs are *also* Meeting Records when they
involve substantive Acquirer or Stakeholder agreement; the PR URL
plus a brief summary is sufficient.

### 10.4.4 Configuration Management execution

PM.2.5 (perform configuration management) implements §10.8 Strategy.
Items under configuration are listed in the CM Strategy with their
states; transitions are events visible in git history (commits,
tags, branch creation/merge).

PM.2.6 (manage Project Repository), PM.2.7 (recovery testing) are
git-native: pushes mirror to backup remote; periodic restore test
pulls from backup remote into a scratch clone.

## 10.5 PM.3 Project Assessment and Control

### 10.5.1 Progress evaluation

PM.3.1 (evaluate progress against Plan). Implementation:

- At each iteration boundary, the Progress Status Record entry from
  §10.4.1 is augmented with an *evaluation* section: variance against
  Plan on each axis (tasks, results, resources, cost, time, risk).
- Significant deviations (project-determined threshold; recommended
  >10% on any axis) trigger the corrective-action workflow of §10.5.2.

### 10.5.2 Correction Register

PM.3.2 (document deviations in Correction Register, track to
closure). The Correction Register is a Markdown log at
`docs/correction-register.md` with one section per correction,
each containing:

- Initial problem (what deviated);
- Solution (planned correction);
- Corrective actions taken;
- Owner;
- Open date and target closure date;
- Status (initial, in-progress, closed);
- Follow-up actions;
- Rationale for the correction (linked to Justification Document).

Each correction is implemented through normal PR workflow if it
involves model changes; through a Plan-revision PR if it involves
Plan changes.

### 10.5.3 Justification Document

PM.3.3 (elaborate or update Justification Document). The Justification
Document is *aggregated* rather than authored:

- Each `analysis def` in `model/variations/trade-studies/` (§6) is
  a justification entry — it records the alternatives, the criteria
  sourced from story constraints, and the decision.
- Each PR introduces an Architecture Decision Record (ADR) in
  `docs/decisions/<NNNN>-<short-title>.md` for non-trivial design
  decisions that don't warrant a full trade study.
- Each Verification Report and Validation Report cross-references the
  story or constraint it covers.

The Justification Document at any moment is the union of:

- All trade-study `analysis def` instances on `main`;
- All ADRs in `docs/decisions/`;
- All V&V Reports referenced by acceptance criteria.

Generation: a renderer (in `tools/`) walks these sources and produces
`docs/justification-document.md` as a navigable index. CI regenerates
on merge.

The renderer also establishes traceability between the rationale and
the related SE artefacts (per ISO 29110 PM.3.3) by following
`derive`, `frame concern`, `verify`, and `allocation` relations.

## 10.6 PM.4 Project Closure

### 10.6.1 Delivery and acceptance

PM.4.1 (formalise project completion). Implementation:

1. The Acquirer reviews the deliverables listed in the Plan against
   the Delivery Instructions.
2. The Product Acceptance Record is authored at
   `docs/product-acceptance-record.md` with the structure of ISO 29110
   §10 product 11, signed (committed by Acquirer's git identity or
   recorded by an authorised proxy).
3. The closing tag `release-vN.M` is pushed.
4. The repository is set to read-only mode if the project is closed
   (project-set-determined); active product families remain writable
   for subsequent iterations.

### 10.6.2 Repository finalisation

PM.4.2 (update Project Repository) is complete on closure tag push.
The repository at the closure tag is the project's permanent record.

### 10.6.3 Disposal execution

PM.4.3 (execute Disposal Management Approach) follows §10.9. For
projects whose disposal is contracted forward (operational and
end-of-life events occur after the engineering project closes), the
Disposal Management Approach is *delivered* at closure as part of the
Plan; execution is a separate subsequent activity.

## 10.7 Risk Management Approach

ISO 29110 PM.O5 requires a Risk Management Approach within the Plan.
Minimum content:

| Element | Form |
|---|---|
| Risk identification approach | Frequency (per iteration), participants, sources (technical, schedule, cost, organisational) |
| Risk register location | `docs/risk-register.md` |
| Risk evaluation criteria | Likelihood × impact → priority; project-determined scale |
| Risk treatment options | Avoid, mitigate, transfer, accept (record per risk) |
| Monitoring cadence | Per iteration in the Progress Status Record |

Each entry in the risk register has: ID, description, likelihood,
impact, priority, owner, treatment, status, date opened, date last
reviewed.

Where a risk's mitigation action becomes part of the engineering work,
it is captured as a story (§5.4.5 dependability concerns are the
direct equivalent for safety/reliability/security risks). Programmatic
risks (cost, schedule) remain in the register and are treated through
PM.2 / PM.3.

## 10.8 Configuration Management Strategy

ISO 29110 PM.O6 requires a Product Management Strategy. Implementation:

```yaml
# Configuration Management Strategy (excerpt — full version in Plan)

substrate: git (origin + backup remote)

items_under_cm:
  - Project Plan                      # baselined per release
  - Methodology specification         # this document
  - Stakeholder Story Register        # core/stories/stakeholder/
  - System Story Register             # core/stories/system/
  - Subsystem Story Registers         # core/logical-architecture/components/.../stories/
  - Concern Register                  # core/concerns/
  - Base Architecture                 # core/base-architecture/
  - System Context                    # core/context/
  - Logical Architecture              # core/logical-architecture/
  - Trade Studies                     # model/variations/trade-studies/
  - Verification Cases                # core/verification-validation/verification-cases/
  - Validation Cases                  # core/verification-validation/validation-cases/
  - IVV Plan + Procedures             # rendered from cases
  - Risk Register                     # docs/risk-register.md
  - Justification Document            # rendered

states:
  - draft        # In a feature branch only
  - inProgress   # PR open
  - readyForReview  # Marked ready
  - baselined    # Merged to main and tagged

baseline_strategy:
  cadence: per release
  mechanism: annotated git tag (release-vN.M)
  retention: indefinite

backup:
  primary: <github org>/<repo>
  mirror:  <gitlab org>/<repo>
  schedule: continuous (post-receive hook)
  recovery_test: monthly, automated

access_control:
  protected_branches: main, release/*
  force_push: disabled on protected branches
  required_reviews: 1 (CODEOWNERS-driven)
```

The Strategy is a section of the Project Plan or a referenced file at
`docs/cm-strategy.md`.

## 10.9 Disposal Management Approach

ISO 29110 PM.O8 requires a Disposal Management Approach. Minimum
content:

| Element | Notes |
|---|---|
| Trigger | What event ends the system entity's existence (decommission, replacement, end of contract) |
| Schedule | When disposal occurs relative to project closure |
| Actions | Hardware retirement, data archival/destruction, software licence release, intellectual property handover, environmental obligations |
| Resources | Who performs disposal; budget if applicable |
| Constraints on design | Disposal-driven requirements that must be reflected in the system stories (e.g., "shall expose a factory-reset capability that wipes operator data") |
| Acceptable end-state | Definition of when the disposal is complete |

The Disposal Management Approach is a section of the Project Plan
(`docs/project-plan.md` § Disposal). For systems with non-trivial
disposal (data sensitivity, safety, environmental), the constraints
are propagated into stakeholder concerns (§4.3.2) and addressed by
stories (§4.3.4 / §5.4.1).

## 10.10 Document templates produced as out-of-scope deliverables

Projects requiring the Basic Profile beyond §9.2 scope (notably
Construction and Delivery) shall produce additional ISO 29110
artefacts. Templates for these are kept in `docs/templates/`:

- `system-operation-guide.md` — ISO 29110 product 26
- `system-user-manual.md` — ISO 29110 product 29
- `system-maintenance-document.md` — ISO 29110 product 25
- `system-training-specifications.md` — ISO 29110 product 28
- `integration-report.md` — ISO 29110 product 6
- `purchase-order.md` — ISO 29110 product 17

These are *templates* — their production is a downstream activity
governed by the construction/delivery process selected by the project
set. The methodology declares them out of scope (per §9.2) but
provides the templates so adoption is mechanical when needed.

## 10.11 Roles in the PM process

| Role | PM responsibility |
|---|---|
| Project Manager (PJM) | Owns Plan, Progress Status Record, Correction Register, Risk Register; chairs review meetings; approves Change Requests; signs Acceptance Record |
| Acquirer (ACQ) | Reviews and accepts Plan; reviews and signs Change Requests against baselined artefacts; reviews and signs Acceptance Record |
| Stakeholder (STK) | Participates in Plan review; raises Change Requests; reviews Meeting Records for accuracy |
| Systems Engineer (SYS), Designer (DES), IVV Engineer (IVV) | Author Plan content within their scope; participate in Assessment and Control; raise Change Requests for technical needs |
| Work Team (WT) | Performs Plan tasks; updates Progress Status Record entries; participates in iteration retrospectives that feed the Justification Document |

CODEOWNERS in the repository assigns each role to git identities;
multiple roles per identity are permitted and expected at VSE scale.

## 10.12 Out of scope

- Specific cost estimation method (parametric, analogous, bottom-up).
  The Plan requires Estimated Effort and Cost; the *method* is
  project-set-determined.
- Specific risk scoring scheme. The Risk Management Approach requires
  likelihood × impact priority; the *scale* is project-set-determined.
- Acquirer / contractual frameworks. The methodology assumes a SOW
  exists; constructing one is a procurement-process concern.
- Procurement (Purchase Orders and Supplier management). Templates
  are provided in §10.10; the procurement process itself is
  project-set-determined.

---

*End of Section 10.*
