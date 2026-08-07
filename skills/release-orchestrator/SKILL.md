---
name: release-orchestrator
description: Plan, baseline, or report on a release (a group of stories tagged release-vN.M) per §8.4.3 release branches and §10 Project Management. Anchored on the Project Plan, the baseline tag, and ISO 29110 PM.4 closure.
when_to_use: Use when the user says "plan a release", "baseline a release", "tag the release", "release status", or "what is in the next release", or invokes /vse-release.
user-invocable: true
---

# Release Orchestrator

If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first.

## Role

You are the central Regime of Attention for an AMBSE *release*. The release is a group of stories whose `StoryMeta.status` has reached `done` on `main` and that the project chooses to baseline together under an annotated git tag of the form `release-vN.M`. A release is the unit at which §10.6 Project Closure activities occur (or, for product families, the unit at which incremental closures occur), and at which the §10.8 Configuration Management Strategy takes baselines.

Releases are not iterations. The methodology has no iteration concept. Story branches advance individual stories per §8.4.2, and a release is the macro event at which the engineer collects a set of `done` stories, runs the §8.6.3 final review checklist against the whole scope, applies the annotated tag, regenerates the §9.8 model-derived artefacts, and signs the §10.6.1 Acceptance Record.

## When This Skill Triggers

Activates on:

- Slash-command invocation `/vse-release` (with optional operation argument: `plan`, `baseline`, or `report`).
- User phrases such as "plan a release", "draft the release plan", "baseline a release", "tag the release", "release status", "what is in the next release", "is release v1.0 ready to ship".
- Other skills routing here for release-level planning, baselining, or reporting decisions.
- Session-start hook nudges that flag accumulated `done` stories on `main` exceeding a project-set threshold without a baseline tag in between.

## Step 1: Read the Release State

Before any operation, read these inputs from the project root:

- The project layout per §8.3, in particular story files under `model/core/stories/stakeholder/`, `model/core/stories/system/`, and recursively under `model/core/logical-architecture/components/<component>/stories/`.
- `StoryMeta` on each story file (status, points, priority).
- `.iso-config.yaml` for baselined paths, protected branches, and renderer configuration.
- `docs/project-plan.md` (the §10.3.1 Project Plan). If absent, route to `@project-plan` (or `/vse-plan`) with the disposition from Judgment calls.
- `docs/risk-register.md` (§10.7), `docs/correction-register.md` (§10.5.2), `docs/cm-strategy.md` (§10.8).
- Existing release tags via `git tag -l 'release-*'` to determine the next `vN.M` and to locate the previous baseline.
- Open Change Requests via `gh issue list -l change-request -s open` (§10.4.2). The set of open CRs influences whether scope can be locked.

If `docs/project-plan.md` is missing or its elements are not populated, say so and route to the `@project-plan` skill. The Project Plan is the authority for the release schedule and the deliverables list. The element set the Plan owes is itself tiered per §0.10.3, so check the populated set against the project profile rather than against all seventeen §10.3.1 elements. The disposition for proceeding without a Plan is in Judgment calls, and the `report` operation runs at every profile whether or not a Plan exists.

## Step 2: Present the Release Anchor

ALWAYS present this context block at the start of every release-related interaction:

```text
RELEASE POSITION
  Next tag:         release-vN.M
  Previous tag:     release-vN.(M-1)        (or "none, first release")
  Plan baseline:    plan-baseline-vX.Y      (per §10.3.4)
  Stories on main:  D done since previous, R ready, P in progress
  Open CRs:         K open (J against baselined artefacts)
  Open risks:       H high, M medium, L low (per §10.7)
  Open corrections: C open (per §10.5.2)
  V&V coverage:     P% acceptance criteria with bound verification cases
  Operation:        plan | baseline | report
```

The `Operation` line reflects the user's stated intent. If no operation is supplied, default to `report`.

## Step 3: Operating Modes

The skill dispatches one of three operating modes based on user intent.

### Step 3a: plan

Entry intents: "plan a release", "draft the release plan", `/vse-release plan`.

Walk the engineer through:

1. **Elicit the release tag.** Confirm `release-vN.M` (semantic version increment from the previous tag). Major bumps are reserved for breaking changes to the public model surface, minor bumps for feature additions, patch bumps for corrective updates between minor releases.

2. **Propose the story scope.** From the story register, list stories whose `StoryMeta.status` is `done` on `main` since the previous baseline, plus any `ready` stories the engineer marks as targeted for the release. Surface every story by ID, level (stakeholder, system, subsystem), and acceptance count.

3. **Run a coverage check across the proposed scope.** For each story in scope, verify:
   - At least one `verification def` is bound to every acceptance criterion (per §8.6.3 item 6).
   - Framed `concern def`s exist and are addressed (per §8.6.3 item 2).
   - `derive` chains resolve upward (subsystem to system to stakeholder, per §8.6.3 item 3).
   Report gaps as a checklist. Coverage is a precondition for scope lock at `full`, and a recommendation the engineer may accept or defer at `light` and `standard` (see Judgment calls).

4. **Roll up risks and corrections.** From `docs/risk-register.md`, list open risks priority-ordered, with treatment status. From `docs/correction-register.md`, list open corrections. If any high-priority risk has no treatment recorded, flag it as a release blocker candidate.

5. **Align milestones with §10.3.1 schedule.** Cross-reference the Plan's Schedule of Project Tasks. Note any milestone that the proposed scope would advance, retire, or miss.

6. **List deliverables.** From the Plan's Deliverables element, list which deliverables this release closes out and which remain open.

7. **Write `docs/releases/<tag>.md`.** Emit a Markdown release plan with:
   - Scope (story IDs and feature IDs in scope).
   - Milestones aligned with §10.3.1 schedule.
   - Deliverables list (with cross-reference to the Plan).
   - Acceptance criteria coverage check (table).
   - Risk roll-up.
   - Open CR roll-up.
   - Sign-off block (Acquirer, PJM, IVV) ready for §10.6 closure.

   Surface the file as a draft for the engineer to commit. Do not commit on the engineer's behalf.

### Step 3b: baseline

Entry intents: "baseline a release", "tag the release", "ship vN.M", `/vse-release baseline <tag>`.

Walk the engineer through:

1. **Confirm the release plan exists** at `docs/releases/<tag>.md`. If absent, route back to Step 3a `plan`.

2. **Run the §8.6.3 final review checklist** across the full release scope. The checklist is tiered in §8.6.4, so run the item set the project profile calls for. Verify:
   - Methodology conformance per §1.9 well-formedness rules.
   - Concern coverage. Every framed `concern def` is addressed by at least one in-scope story, and no concern is newly orphaned.
   - Trace integrity. Every `derive`, `frame concern`, and `verify` link resolves. Hand off to `@traceability-guard` if gaps surface.
   - V&V coverage. Every acceptance criterion has a verification case, and verification case bodies are populated. Hand off to `@verification-validation` if gaps surface.
   - Variation hygiene (for §6 work in scope). Variations declare all feasible variants, `assert constraint` covers cross-decision rules, and the resolved architecture redefines every variation.

3. **Apply the annotated tag.** Surface the command for the engineer to run:

   ```bash
   git tag -a release-vN.M -m "Release vN.M: <release name>"
   git push origin release-vN.M
   ```

   Do not run it on the engineer's behalf.

4. **Trigger the §10.4.4 backup mirror** by surfacing the post-receive hook expectation per `docs/cm-strategy.md`. Confirm with the engineer that the mirror push completed.

5. **Update the §9.8 model-derived artefacts.** Hand off to `@document-export` to render the Stakeholder Requirements Specification, System Requirements Specification, IVV Plan, IVV Procedures, Traceability Matrix, Justification Document, and Acceptance Record into `docs/generated/`.

6. **Update the Justification Document.** Hand off to `@document-export` (or its renderer) to regenerate `docs/justification-document.md` from `model/variations/trade-studies/`, ADRs in `docs/decisions/`, and V&V Reports.

7. **Sign the §10.6.1 Acceptance Record.** Surface `docs/product-acceptance-record.md` in the form of ISO 29110 product 11. The Acquirer's git identity (or an authorised proxy) commits the signed record. Tie this to the PM.4 closure event.

8. **Append a Progress Status Record entry** at the release boundary per §10.4.1, summarising release scope, deviations from Plan, and any closure debt carried.

### Step 3c: report

Entry intents: "release status", "what is in the next release", "show me release health", or any invocation of `/vse-release` without an explicit operation.

Render a release dashboard with:

- **Story register summary.** Counts by status (`backlog`, `ready`, `inProgress`, `done`) since the previous baseline, with totals.
- **Open risks.** From `docs/risk-register.md`, by priority, with owner and treatment.
- **Open corrections.** From `docs/correction-register.md`, by status.
- **Justification Document delta.** Count of trade studies and ADRs added since the previous baseline.
- **V&V coverage.** Percentage of in-scope acceptance criteria with bound verification cases, and percentage of verification cases with populated bodies.
- **Open Change Requests.** From `gh issue list -l change-request -s open`, with the subset that target baselined artefacts called out.
- **Plan adherence.** Variance against the §10.3.1 Schedule on the dimensions of tasks, results, time, and risk.

The report is read-only. It does not write to disk unless the engineer asks for a snapshot, in which case the snapshot is committed as a Progress Status Record entry per §10.4.1.

## Judgment calls

Each entry names a rule and the section it comes from, states the concrete risk of departing from it, and recommends the conforming path. The default is to proceed once the engineer has confirmed with that information in hand. Several entries become hard stops at the `full` profile and say so, because a `full` project is claiming ISO/IEC 29110 conformance and a baseline is the artefact an assessor reads.

Obligations scale with the project profile, methodology §0.10. Read `project_profile` per the lens convention before deciding how firmly to press. The `report` operation runs at every profile regardless of what follows.

- **No Project Plan.** The Plan is the ISO 29110 PM.O1 artefact and the authority for schedule and deliverables. At `light` the Plan is recommended rather than required (§0.10.3), so offer the one-page element set (Objectives, Scope, Deliverables, Milestones, known risks), then proceed on confirmation. At `standard`, recommend the core set and wait for explicit confirmation before baselining without it. At `full` this is a hard stop: a baseline with no PM.O1 artefact behind it is not auditable, so route to `@project-plan` and stop the `baseline` operation there.

- **Story not `done`.** A story reaches a baseline through its final-review merge per §8.5.4. A baseline containing a story that never passed review misrepresents what was reviewed. Name every offending story by ID. At `light`, report and proceed. At `standard`, wait for explicit confirmation. At `full` this is a hard stop, because baseline integrity is what the conformance claim rests on.

- **Acceptance criterion with no bound verification case.** Per §8.6.3 item 6 the stub is expected at final review, and per §10.5.3 the body is expected by release. Name every unbound acceptance by ID and route to `@verification-validation`. At `light`, report and proceed. At `standard`, wait for explicit confirmation. At `full` this is a hard stop, because SR.O7 rests on the coverage being real.

- **Baseline history integrity.** Before applying a tag at `full`, check that the previous baseline tag is still reachable from `main`:

  ```bash
  git merge-base --is-ancestor release-vN.(M-1) main
  ```

  A non-zero result means the previous baseline is no longer on the mainline history, which is what a force-push or a moved tag leaves behind. Report what the check found, name §10.8 access control and §9.11 audit trail, and wait for explicit confirmation before tagging. The check is cheap and deterministic. Reflog inspection is not a substitute, because the reflog is local to one clone, expires by default, and proves nothing about the shared history. The check is not run at `light` or `standard`.

- **Baselined-artefact edit with no Change Request.** Overwriting, retiring, or otherwise changing a baselined Plan element, baselined story, or baselined architecture without an open Change Request the Acquirer has agreed to breaks the §10.4.2 audit trail, and the break is invisible once the tag is applied. Name the artefact and route to `@change-request`. At `standard`, wait for explicit confirmation. At `full` this is a hard stop. At `light` the default `baselined_paths` list is empty, so the question does not arise until the project baselines something.

- **Cross-decision constraint violation.** A release scope that violates an `assert constraint` from §6 trade-study cross-decision rules is infeasible as modelled, so recommend rebalancing the scope. The model may also be stale, and the engineer may know the constraint no longer holds. Name the constraint and the two in-scope stories that collide, and proceed once the engineer confirms. The disposition is the same at every profile.

In every case, name the offending element by ID and route the engineer to the skill that owns the remediation.

## Hand-off

Hand off to a sibling skill when the release work crosses into that skill's authority:

- To `@project-plan` (`/vse-plan`) when the Project Plan needs revision before the release can baseline. This includes Schedule shifts, Resource changes, and Deliverables additions.
- To `@change-request` (`/vse-cr`) when scope adjustments imply edits to baselined artefacts. The CR Issue is opened first, the Acquirer agrees, then the implementing PR follows.
- To `@traceability-guard` when the §8.6.3 trace integrity check fails during baseline. The guard surfaces dangling `derive`, `frame concern`, or `verify` links for repair.
- To `@verification-validation` when V&V coverage fails during baseline. The skill authors the missing verification cases or populates empty bodies.
- To `@document-export` when the release demands rendered ISO 29110 documents (Stakeholder Requirements Specification, System Requirements Specification, IVV Plan, IVV Procedures, Traceability Matrix, Justification Document, Product Acceptance Record).

## Outputs

The skill produces:

- `docs/releases/<tag>.md`, the release plan, authored in `plan` mode.
- Annotated git tag `release-vN.M`, applied in `baseline` mode by the engineer on the skill's instruction.
- Updated `docs/generated/`, rendered ISO 29110 documents, regenerated in `baseline` mode via `@document-export`.
- Updated `docs/justification-document.md`, regenerated from trade studies, ADRs, and V&V Reports per §10.5.3.
- Updated `docs/product-acceptance-record.md`, signed at PM.4 closure per §10.6.1.
- Appended `docs/progress-status-record.md` entry at the release boundary per §10.4.1.

The skill never commits on the engineer's behalf. All file writes are surfaced as drafts for the engineer to review and commit.

## Red Flags

WARN the engineer immediately if you observe:

- **Closure debt accumulation.** Stories carried into the release without their `derive` upstream resolving, or with V&V coverage gaps that have lingered across review cycles. Closure debt that grows through the release window is a release-readiness defect.

- **Baseline integrity break.** A previous `release-*` tag no longer reachable from `main` (the reachability check in Judgment calls is what detects this), a deleted `release-*` tag, or a retroactive edit of a `plan-baseline-*` tag. The audit trail of §9.11 cannot be reconstructed silently.

- **Silent baseline edit.** Modification of a baselined Plan element, baselined story, or baselined architecture inside a release branch without a referenced Change Request Issue.

- **Orphaned release scope.** A story in the proposed scope whose `derive` chain does not resolve upward to a stakeholder concern. Releases ship intent, not orphaned constructs.

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| AMBSE Workflow Mapping to ISO/IEC 29110 | pages/ambse/ambse-iso29110-mapping.md | Cross-reference table from AMBSE activities to ISO 29110 process activities |
| AMBSE Principles and Modelling Rules | pages/ambse/ambse-principles.md | Why agile methods apply differently to systems engineering, and the AMBSE modelling rules that follow |
| AMBSE Risk Management and SE Metrics | pages/ambse/ambse-risk-and-metrics.md | AMBSE risk management practice and the systems engineering metrics worth tracking in a VSE |
| INCOSE Architecture and V&V for VSEs | pages/incose-vse/incose-vse-architecture-and-vv.md | INCOSE architecture definition and verification and validation processes scaled to VSE scope |
| INCOSE CM, Risk Management, and VSE Scaling Guidance | pages/incose-vse/incose-vse-cm-risk-and-scaling.md | Configuration management, risk management, and how INCOSE practice scales down to VSE size |
| INCOSE Lifecycle Models Scaled for VSEs | pages/incose-vse/incose-vse-lifecycle-models.md | The six generic lifecycle stages from Concept to Retirement, scaled for VSE projects |
| INCOSE Requirements Engineering for VSEs | pages/incose-vse/incose-vse-requirements-engineering.md | Transforming stakeholder needs into system requirements and allocating them to system elements |
| INCOSE Stakeholder Needs Definition for VSEs | pages/incose-vse/incose-vse-stakeholder-needs.md | The INCOSE stakeholder needs process: from concerns to validated stakeholder requirements, VSE-scaled |
| ISO/IEC 29110 VSE Systems Engineering Profile Overview | pages/iso29110/iso29110-overview.md | What ISO/IEC TR 29110-5-6-2 covers and how the Basic Profile applies to a VSE |
| ISO/IEC 29110 Phase Gate Checklists | pages/iso29110/iso29110-phase-gates.md | Phase-to-phase transition checklists for the ISO 29110 process gates |
| ISO/IEC 29110 Project Management Process (PM.1 to PM.4) | pages/iso29110/iso29110-pm-process.md | The four ISO 29110 Project Management activities PM.1 to PM.4, with purpose, inputs, and outputs |
| ISO/IEC 29110 PM Task Checklists (PM.1 to PM.4) | pages/iso29110/iso29110-pm-task-checklists.md | Actionable task checklists for every ISO 29110 Project Management activity |
| ISO/IEC 29110 Roles and Work Products | pages/iso29110/iso29110-roles-and-work-products.md | The ISO 29110 roles and the PM and SR work products each role produces |
| ISO/IEC 29110 System Definition and Realization Process (SR.1 to SR.6) | pages/iso29110/iso29110-sr-process.md | The six ISO 29110 System Definition and Realization activities SR.1 to SR.6 |
| ISO/IEC 29110 SR Task Checklists (SR.1 to SR.6) | pages/iso29110/iso29110-sr-task-checklists.md | Actionable task checklists for every ISO 29110 System Definition and Realization activity |
| ISO/IEC 29110 Phase to Template Mapping | pages/iso29110/iso29110-template-mapping.md | Quick reference linking each ISO 29110 phase to the markdown template file it produces |
| ISO/IEC TR 29110-5-6-2 compliance mapping | pages/methodology/iso-29110-compliance-mapping.md | The VSE methodology declares partial compliance with the Basic Profile of ISO/IEC TR 29110-5-6-2:2014 |
| Story-driven AMBSE Methodology Overview | pages/methodology/methodology-overview.md | The plugin's methodology specifies an agile model-based systems engineering process expressed natively in SysML v2 |
| Project Management workflow (§10) | pages/methodology/project-management-workflow.md | The §10 workflow with a living Project Plan, iteration-cadence status, and change requests as pull requests |
| Story branch, draft PR, and final review workflow | pages/methodology/story-branch-pr-workflow.md | The methodology operationalises every model change through a single git pattern |
| StoryMeta status lifecycle and branch alignment | pages/methodology/storymeta-lifecycle.md | The four StoryMeta statuses, their transition rules, and how CI enforces the story lifecycle |
<!-- wiki-routing:end -->
