---
name: release-orchestrator
description: Plan, baseline, or report on a release (a group of stories tagged release-vN.M) per §8.4.3 release branches and §10 Project Management. Use when the user says "plan a release", "baseline a release", "tag the release", "release status", "what is in the next release", or invokes /vse-release. Anchored on Project Plan, baseline tag, and ISO 29110 PM.4 closure.
user-invocable: true
---

# Release Orchestrator

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

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
- `docs/project-plan.md` (the §10.3.1 Project Plan). If absent, refuse and route to `@project-plan` (or `/vse-plan`).
- `docs/risk-register.md` (§10.7), `docs/correction-register.md` (§10.5.2), `docs/cm-strategy.md` (§10.8).
- Existing release tags via `git tag -l 'release-*'` to determine the next `vN.M` and to locate the previous baseline.
- Open Change Requests via `gh issue list -l change-request -s open` (§10.4.2). The set of open CRs influences whether scope can be locked.

If `docs/project-plan.md` is missing or the §10.3.1 elements are not populated, refuse to proceed and route to the `@project-plan` skill. The Project Plan is the authority for the release schedule and the deliverables list, and a release without a Plan is not an ISO 29110 PM.O1 artefact.

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
   Report gaps as a checklist. Do not allow scope lock until every in-scope story has at least one bound verification case for each acceptance.

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

2. **Run the §8.6.3 final review checklist** across the full release scope. Verify:
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

## Refusals

Refuse to proceed and surface the reason if any of the following holds:

- **Story not done.** Refuse to baseline if any story in the release scope has `StoryMeta.status` other than `done`. Stories must have completed their final-review merge per §8.5.4 before they can be in a baseline.

- **Acceptance without verification.** Refuse to baseline if any acceptance criterion in any in-scope story lacks a `verification def` bound to it. Per §8.6.3 item 6, verification-case stubs are mandatory at final review, and at release the bodies must be populated.

- **Force-push detected.** Refuse to baseline if `git reflog` evidence shows a force-push on `main` since the previous baseline tag, or if the §10.8 access-control rule (`force_push: disabled on protected branches`) has been bypassed. Per §10.8 access control and §9.11 audit trail, the integrity of the protected-branch history is a baseline prerequisite.

- **Baselined-artefact edit without a CR.** Refuse to overwrite, retire, or otherwise change a baselined Plan element, baselined story, or baselined architecture without an open Change Request that the Acquirer has agreed to per §10.4.2. The hook guide enforces this in CI, and the skill enforces it at the release gate.

- **Cross-decision constraint violation.** Refuse to propose a release scope that violates an `assert constraint` from §6 trade-study cross-decision rules. If two in-scope stories require incompatible variants of a variation point, the scope is not feasible and must be rebalanced.

In all refusals, name the offending element by ID and route the engineer to the skill that owns the remediation.

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

- **Baseline integrity break.** Force-push on `main`, deletion of a previous `release-*` tag, or retroactive edit of a `plan-baseline-*` tag. The audit trail of §9.11 cannot be reconstructed silently.

- **Silent baseline edit.** Modification of a baselined Plan element, baselined story, or baselined architecture inside a release branch without a referenced Change Request Issue.

- **Orphaned release scope.** A story in the proposed scope whose `derive` chain does not resolve upward to a stakeholder concern. Releases ship intent, not orphaned constructs.

## Reference

The bundle below concatenates atomic pages on §8 project structure and git workflow, the §8.4.3 release-branch rules, the §8.6.3 final review checklist, the §10.3 Project Plan element list, the §10.4.2 Change Request lifecycle, the §10.5.3 Justification Document aggregation, the §10.6 closure activities, the §10.7 risk register schema, the §10.8 CM Strategy template, and the ISO 29110 PM.O1–PM.O8 objective coverage matrix. The bundle is regenerated by the wiki pipeline. If it is missing, run `/vse-wiki-bundle release-orchestrator` to rebuild it.

`!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/release-orchestrator.md`
