---
name: release-orchestrator
description: Plan, baseline, or report on a release (a group of stories tagged release-vN.M) per §8.4.3 release branches and §10 Project Management. Anchored on the Project Plan, the baseline tag, and ISO/IEC 29110 PM.4 closure. The baseline needs every Gherkin scenario reached by a case and, where test first applies, a green test and scenario run.
when_to_use: Use when the user says "plan a release", "baseline a release", "tag the release", "release status", "what is in the next release", "is every scenario covered", or "are the tests green for the release", or invokes /vse-release.
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
- The feature file `<ID>.feature` beside each story file. Its scenarios, each tagged `@AC_<name>`, state the story's acceptance criteria in Gherkin, the plain-text Given/When/Then format that Cucumber-family test tools read and run (§11.2, §11.3). Each scenario is mirrored by a criterion of the same name nested in the story's `requirement :>> acceptance`.
- `StoryMeta` on each story file (status, points, priority).
- `.iso-config.yaml` for baselined paths, protected branches, and renderer configuration.
- The `test_first` block of `.iso-config.yaml` (§11.5.2). Test first means a failing automated test is written before the code that makes it pass. The block records whether it applies and names `test_command` and, optionally, `scenario_command`, the command that runs the feature files on a scenario runner. Route any question about the record to `@test-first`.
- `docs/project-plan.md` (the §10.3.1 Project Plan). If absent, route to `@project-plan` (or `/vse-plan`) with the disposition from Judgement calls.
- `docs/risk-register.md` (§10.7), `docs/correction-register.md` (§10.5.2), `docs/cm-strategy.md` (§10.8).
- Existing release tags via `git tag -l 'release-*'` to determine the next `vN.M` and to locate the previous baseline.
- Open Change Requests via `gh issue list -l change-request -s open` (§10.4.2). The set of open CRs influences whether scope can be locked.

If `docs/project-plan.md` is missing or its elements are not populated, say so and route to the `@project-plan` skill. The Project Plan is the authority for the release schedule and the deliverables list. The element set the Plan owes is itself tiered per §0.10.3, so check the populated set against the project profile rather than against all seventeen §10.3.1 elements. The disposition for proceeding without a Plan is in Judgement calls, and the `report` operation runs at every profile whether or not a Plan exists.

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
  V&V coverage:     P of Q acceptance criteria reached by a case (§11.3.3)
  Story lint:       clean | N findings (--only gherkin, §11.9.1)
  Test-first:       applies, green at <commit> | applies, not run | not applicable | not recorded
  Operation:        plan | baseline | report
```

The `Operation` line reflects the user's stated intent. If no operation is supplied, default to `report`.

## Step 3: Operating Modes

The skill dispatches one of three operating modes based on user intent.

### Step 3a: plan

Entry intents: "plan a release", "draft the release plan", `/vse-release plan`.

Walk the engineer through:

1. **Elicit the release tag.** Confirm `release-vN.M` (semantic version increment from the previous tag). Major bumps are reserved for breaking changes to the public model surface, minor bumps for feature additions, patch bumps for corrective updates between minor releases.

2. **Propose the story scope.** From the story register, list stories whose `StoryMeta.status` is `done` on `main` since the previous baseline, plus any `ready` stories the engineer marks as targeted for the release. Surface every story by ID, level (stakeholder, system, subsystem), and the names of its acceptance criteria, that is, the `@AC_<name>` tags of its feature file.

3. **Run a coverage check across the proposed scope, per criterion.** For each story in scope, verify:
   - The story has its feature file, and each scenario is mirrored by a named criterion (§11.3.1, §8.6.2 item 4).
   - Every acceptance criterion is reached by at least one verification or validation case, through `verify <story>`, `verify <story>.acceptance`, or `verify <story>.acceptance.<name>` (§11.3.3, §8.6.3 item 6). Scenarios no machine can exercise, tagged for example `@manual`, are reached by validation cases like any other (§11.8).
   - Framed `concern def`s exist and are addressed (per §8.6.3 item 2).
   - `derive` chains resolve upward (subsystem to system to stakeholder, per §8.6.3 item 3).

   The story lint checks the first two items mechanically. Run it from the engineering root, `python3 tools/lint/story-wellformed.py --only gherkin model`, and read S1 (no feature file), S4 and S5 (a criterion and a scenario that do not match), and S8 (a criterion no case reaches on an `inProgress` or `done` story). Report gaps as a checklist, by story ID and criterion name. A finding on a story in scope is read at the disposition the project records for `precommit_gherkin`, which is block at every profile unless a recorded override lowers it (§11.9). At block it stops scope lock at every profile, because the gate would refuse the commit that put the story on `main`. S3 is the exception: it marks a story whose acceptance is still prose in the form used before 5.0.0. Name it as migration debt, read its coverage at story level, and recommend migrating it through `@story-orchestrator` (§11.3.1). The concern and `derive` items are a precondition for scope lock at `full`, and a recommendation the engineer may accept or defer at `light` and `standard` (see Judgement calls).

4. **Roll up risks and corrections.** From `docs/risk-register.md`, list open risks priority-ordered, with treatment status. From `docs/correction-register.md`, list open corrections. If any high-priority risk has no treatment recorded, flag it as a release blocker candidate.

5. **Align milestones with §10.3.1 schedule.** Cross-reference the Plan's Schedule of Project Tasks. Note any milestone that the proposed scope would advance, retire, or miss.

6. **List deliverables.** From the Plan's Deliverables element, list which deliverables this release closes out and which remain open.

7. **Write `docs/releases/<tag>.md`.** Emit a Markdown release plan with:
   - Scope (story IDs and feature IDs in scope).
   - Milestones aligned with §10.3.1 schedule.
   - Deliverables list (with cross-reference to the Plan).
   - Acceptance criteria coverage check (table, one row per criterion, with its scenario tag and the cases that reach it).
   - Test-first record. Whether test first applies, and once Step 3b has run, the `test_command` and `scenario_command` runs with their exit status and the commit they ran on.
   - Risk roll-up.
   - Open CR roll-up.
   - Sign-off block (Acquirer, PJM, IVV) ready for §10.6 closure.

   Surface the file as a draft for the engineer to commit. Do not commit on the engineer's behalf.

### Step 3b: baseline

Entry intents: "baseline a release", "tag the release", "ship vN.M", `/vse-release baseline <tag>`.

Walk the engineer through:

1. **Confirm the release plan exists** at `docs/releases/<tag>.md`. If absent, route back to Step 3a `plan`.

2. **Run the §8.6.3 final review checklist** across the full release scope. The checklist is tiered in §8.6.4, so run the item set the project profile calls for. Verify:
   - Methodology conformance per the §1.9 and §11.12 well-formedness rules.
   - Concern coverage. Every framed `concern def` is addressed by at least one in-scope story, and no concern is newly orphaned.
   - Trace integrity. Every `derive`, `frame concern`, and `verify` link resolves. Hand off to `@traceability-guard` if gaps surface.
   - Behaviour first (§8.6.3 item 6, §11.4), at every profile, because the §11 gates block at every profile. Every story in scope has its feature file, every criterion its scenario, and every criterion a case that reaches it. Run the story lint as in Step 3a item 3. Hand off to `@story-orchestrator` for a missing feature file or scenario.
   - V&V coverage. Verification case bodies are populated, because a body is the procedure the IVV Procedures come from (§9.5, §9.8) and SR.O7 asks for V&V tasks performed (§9.4). Hand off to `@verification-validation` if gaps surface.
   - Test first, where it applies (§11.7, §11.8), at every profile. Read the `test_first` block. With `applies: true`, run `test_command` and, where it is recorded, `scenario_command` from the top-level directory of the repository on the commit to be tagged, or read the `Run the recorded tests` and `Run the recorded scenarios` steps of the CI workflow for that commit. Both must exit 0. Record each command, its exit status and the commit in the release plan. With `applies: false`, write `Test-first: not applicable` there, because the scenarios are then verified by the cases that reach them. With no record, route to `@test-first` (see Judgement calls).
   - Variation hygiene (for §6 work in scope). Variations declare all feasible variants, `assert constraint` covers cross-decision rules, and the resolved architecture redefines every variation.

3. **Apply the annotated tag.** Surface the command for the engineer to run:

   ```bash
   git tag -a release-vN.M -m "Release vN.M: <release name>"
   git push origin release-vN.M
   ```

   Do not run it on the engineer's behalf.

4. **Trigger the §10.4.4 backup mirror** by surfacing the post-receive hook expectation per `docs/cm-strategy.md`. Confirm with the engineer that the mirror push completed.

5. **Update the §9.8 model-derived artefacts.** Run each renderer configured in the `renderers:` block of `.iso-config.yaml` from the engineering root, for example `python3 tools/render/traceability-matrix.py`, and surface the regenerated files in `docs/generated/` for the engineer to commit. The plugin ships three: the Traceability Matrix and the Stakeholder and System Requirements Specifications, which print each criterion as its Gherkin scenario. At `full` the post-merge hook also regenerates them on `main` (hooks guide §4.5). No renderer ships for the IVV Plan, the IVV Procedures or the Justification Document, so their keys stay commented out until the project authors those scripts. Until then the IVV Plan is the hand-prepared `docs/ivv-plan.md` (`@verification-validation` Workflow E). `@document-export` only converts finished documents to docx, pptx or pdf.

6. **Update the Justification Document.** Until the project has its own renderer, update `docs/justification-document.md` with the engineer as the index §10.5.3 describes, from the trade studies in `model/variations/trade-studies/`, the ADRs in `docs/decisions/`, and the V&V Reports. Start it from `${CLAUDE_PLUGIN_ROOT}/templates/pm/justification-document.md` when the project has none.

7. **Sign the §10.6.1 Acceptance Record.** Surface `docs/product-acceptance-record.md` in the form of ISO/IEC 29110 product 11. The Acquirer's git identity (or an authorised proxy) commits the signed record. Tie this to the PM.4 closure event.

8. **Append a Progress Status Record entry** at the release boundary per §10.4.1, summarising release scope, deviations from Plan, and any closure debt carried.

### Step 3c: report

Entry intents: "release status", "what is in the next release", "show me release health", or any invocation of `/vse-release` without an explicit operation.

Render a release dashboard with:

- **Story register summary.** Counts by status (`backlog`, `ready`, `inProgress`, `done`) since the previous baseline, with totals.
- **Open risks.** From `docs/risk-register.md`, by priority, with owner and treatment.
- **Open corrections.** From `docs/correction-register.md`, by status.
- **Justification Document delta.** Count of trade studies and ADRs added since the previous baseline.
- **V&V coverage.** In-scope acceptance criteria reached by a case, counted per criterion (§11.3.3), the stories without a feature file, and the percentage of verification cases with populated bodies.
- **Test-first status.** Whether test first applies, and the result of the most recent `test_command` and `scenario_command` run on `main` that CI or the engineer recorded, with its commit. The report does not run them.
- **Open Change Requests.** From `gh issue list -l change-request -s open`, with the subset that target baselined artefacts called out.
- **Plan adherence.** Variance against the §10.3.1 Schedule on the dimensions of tasks, results, time, and risk.

The report is read-only. It does not write to disk unless the engineer asks for a snapshot, in which case the snapshot is committed as a Progress Status Record entry per §10.4.1.

## Judgement calls

Each entry names a rule and the section it comes from, states the concrete risk of departing from it, and recommends the conforming path. The default is to proceed once the engineer has confirmed with that information in hand. Several entries become hard stops at the `full` profile and say so, because a `full` project is claiming ISO/IEC 29110 conformance and a baseline is the artefact an assessor reads.

Obligations scale with the project profile, methodology §0.10. Read `project_profile` per the lens convention before deciding how firmly to press. Two entries do not scale, because they follow §11, whose gates block at every profile by default: a criterion no case reaches, and a red test or scenario run where test first applies. The `report` operation runs at every profile regardless of what follows.

- **No Project Plan.** The Plan is the ISO/IEC 29110 PM.O1 artefact and the authority for schedule and deliverables. At `light` the Plan is recommended rather than required (§0.10.3), so offer the one-page element set (Objectives, Scope, Deliverables, Milestones, known risks), then proceed on confirmation. At `standard`, recommend the core set and wait for explicit confirmation before baselining without it. At `full` this is a hard stop: a baseline with no PM.O1 artefact behind it is not auditable, so route to `@project-plan` and stop the `baseline` operation there.

- **Story not `done`.** A story reaches a baseline through its final-review merge per §8.5.4. A baseline containing a story that never passed review misrepresents what was reviewed. Name every offending story by ID. At `light`, report and proceed. At `standard`, wait for explicit confirmation. At `full` this is a hard stop, because baseline integrity is what the conformance claim rests on.

- **Acceptance criterion with no case reaching it.** A story at `inProgress` or `done` needs a case reaching every criterion, a stub being enough (§11.4, §8.6.3 item 6). This does not scale with the profile. The `precommit_gherkin` gate reports the gap as S8 and blocks at every profile unless a recorded override lowers it, so a gap on a `done` story means the story reached `main` past the gate or before it existed. Name every unreached criterion by story ID and criterion name, route to `@verification-validation`, and stop the `baseline` operation at every profile while the gate's disposition is block. Where an override has lowered it, follow the recorded disposition and name the override in the release plan.

- **Verification case with an empty body.** The stub is enough at final review, and the body is expected by release, because it is the procedure the IVV Procedures come from (§9.5, §9.8). Name every case with an empty body and route to `@verification-validation`. At `light`, report and proceed. At `standard`, wait for explicit confirmation. At `full` this is a hard stop, because SR.O7, "V&V tasks performed" (§9.4), rests on the coverage being real.

- **Red or missing test and scenario run, where test first applies.** With `test_first.applies: true`, the baseline commit needs a green `test_command` run, and a green `scenario_command` run where one is recorded (§11.7, §11.8). A failing run fails the CI workflow at every profile, so a tag over it would baseline a state the project's own checks reject. This is a hard stop at every profile. Name the failing command and the commit. A fix goes through a story branch and starts with a failing test that reproduces the failure (§11.7), through `@test-first`. Never weaken or delete a test so that the run passes (§11.10). Where `scenario_command` is not recorded, the scenarios have no runner yet, so run `test_command` alone and offer the wiring through `@test-first`.

- **`test_first` not recorded.** Without the record the release plan cannot say whether a green run is owed (§11.5, §11.12 rule 7). Route to `@test-first` (`/vse-test-first`) first, because recording it is one short question. At `light` and `standard`, proceed on explicit confirmation and write `Test-first: not recorded` in the release plan, so the gap stays visible. At `full` this is a hard stop, because the partial SR.4 coverage that §9.2 claims, test-first discipline where code exists, rests on the record.

- **Baseline history integrity.** Before applying a tag at `full`, check that the previous baseline tag is still reachable from `main`:

  ```bash
  git merge-base --is-ancestor <previous-release-tag> main
# example: git merge-base --is-ancestor release-v0.1 main
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
- To `@story-orchestrator` when a story in scope lacks its feature file or a scenario, or a criterion and a scenario do not match (story lint S1, S4, S5), or a story still carries acceptance prose in the form used before 5.0.0 (S3).
- To `@test-first` (`/vse-test-first`) when `test_first` is not recorded, when no scenario runner is wired, or when a recorded test or scenario run fails.
- To `@document-export` when finished release documents (Stakeholder Requirements Specification, System Requirements Specification, IVV Plan, IVV Procedures, Traceability Matrix, Justification Document, Product Acceptance Record) are needed as docx, pptx or pdf. Regenerating the rendered ones is Step 3b item 5.

## Outputs

The skill produces:

- `docs/releases/<tag>.md`, the release plan, authored in `plan` mode, with the per-criterion coverage table and the test-first record of the baseline commit.
- Annotated git tag `release-vN.M`, applied in `baseline` mode by the engineer on the skill's instruction.
- Updated `docs/generated/`, the rendered ISO/IEC 29110 documents, regenerated in `baseline` mode by the renderers configured in `.iso-config.yaml`.
- Updated `docs/justification-document.md`, aggregated from trade studies, ADRs, and V&V Reports per §10.5.3.
- Updated `docs/product-acceptance-record.md`, signed at PM.4 closure per §10.6.1.
- Appended `docs/progress-status-record.md` entry at the release boundary per §10.4.1.

The skill never commits on the engineer's behalf. All file writes are surfaced as drafts for the engineer to review and commit.

## Red Flags

WARN the engineer immediately if you observe:

- **Closure debt accumulation.** Stories carried into the release without their `derive` upstream resolving, or with V&V coverage gaps that have lingered across review cycles. Closure debt that grows through the release window is a release-readiness defect.

- **Baseline integrity break.** A previous `release-*` tag no longer reachable from `main` (the reachability check in Judgement calls is what detects this), a deleted `release-*` tag, or a retroactive edit of a `plan-baseline-*` tag. The audit trail of §9.11 cannot be reconstructed silently.

- **Silent baseline edit.** Modification of a baselined Plan element, baselined story, or baselined architecture inside a release branch without a referenced Change Request Issue.

- **Weakened tests or scenarios.** A test or a scenario deleted, skipped, or loosened inside the release window with no change to the behaviour it describes, so that a run or a coverage check passes. An agent never does this without an explicit human request (§11.10).

- **Orphaned release scope.** A story in the proposed scope whose `derive` chain does not resolve upward to a stakeholder concern. Releases ship intent, not orphaned constructs.

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| AMBSE Workflow Mapping to ISO/IEC 29110 | pages/ambse/ambse-iso29110-mapping.md | Cross-reference table from AMBSE activities to ISO/IEC 29110 process activities |
| AMBSE Principles and Modelling Rules | pages/ambse/ambse-principles.md | Why agile methods apply differently to systems engineering, and the AMBSE modelling rules that follow |
| AMBSE Risk Management and SE Metrics | pages/ambse/ambse-risk-and-metrics.md | AMBSE risk management practice and the systems engineering metrics worth tracking in a VSE |
| INCOSE Architecture and V&V for VSEs | pages/incose-vse/incose-vse-architecture-and-vv.md | INCOSE architecture definition and verification and validation processes scaled to VSE scope |
| INCOSE CM, Risk Management, and VSE Scaling Guidance | pages/incose-vse/incose-vse-cm-risk-and-scaling.md | Configuration management, risk management, and how INCOSE practice scales down to VSE size |
| INCOSE Lifecycle Models Scaled for VSEs | pages/incose-vse/incose-vse-lifecycle-models.md | The six generic lifecycle stages from Concept to Retirement, scaled for VSE projects |
| INCOSE Requirements Engineering for VSEs | pages/incose-vse/incose-vse-requirements-engineering.md | Transforming stakeholder needs into system requirements and allocating them to system elements |
| INCOSE Stakeholder Needs Definition for VSEs | pages/incose-vse/incose-vse-stakeholder-needs.md | The INCOSE stakeholder needs process: from concerns to validated stakeholder requirements, VSE-scaled |
| ISO/IEC 29110 VSE Systems Engineering Profile Overview | pages/iso29110/iso29110-overview.md | What ISO/IEC TR 29110-5-6-2 covers and how the Basic Profile applies to a VSE |
| ISO/IEC 29110 Phase Gate Checklists | pages/iso29110/iso29110-phase-gates.md | Phase-to-phase transition checklists for the ISO/IEC 29110 process gates |
| ISO/IEC 29110 Project Management Process (PM.1 to PM.4) | pages/iso29110/iso29110-pm-process.md | The four ISO/IEC 29110 Project Management activities PM.1 to PM.4, with purpose, inputs, and outputs |
| ISO/IEC 29110 PM Task Checklists (PM.1 to PM.4) | pages/iso29110/iso29110-pm-task-checklists.md | Actionable task checklists for every ISO/IEC 29110 Project Management activity |
| ISO/IEC 29110 Roles and Work Products | pages/iso29110/iso29110-roles-and-work-products.md | The ISO/IEC 29110 roles and the PM and SR work products each role produces |
| ISO/IEC 29110 System Definition and Realization Process (SR.1 to SR.6) | pages/iso29110/iso29110-sr-process.md | The six ISO/IEC 29110 System Definition and Realization activities SR.1 to SR.6 |
| ISO/IEC 29110 SR Task Checklists (SR.1 to SR.6) | pages/iso29110/iso29110-sr-task-checklists.md | Actionable task checklists for every ISO/IEC 29110 System Definition and Realization activity |
| ISO/IEC 29110 Phase to Template Mapping | pages/iso29110/iso29110-template-mapping.md | Quick reference linking each ISO/IEC 29110 phase to the markdown template file it produces |
| ISO/IEC TR 29110-5-6-2 compliance mapping | pages/methodology/iso-29110-compliance-mapping.md | The VSE methodology declares partial compliance with the Basic Profile of ISO/IEC TR 29110-5-6-2:2014 |
| Story-driven AMBSE Methodology Overview | pages/methodology/methodology-overview.md | The plugin's methodology specifies an agile model-based systems engineering process expressed natively in SysML v2 |
| Project Management workflow (§10) | pages/methodology/project-management-workflow.md | The §10 workflow with a living Project Plan, iteration-cadence status, and change requests as pull requests |
| Story branch, draft PR, and final review workflow | pages/methodology/story-branch-pr-workflow.md | The methodology operationalises every model change through a single git pattern |
| StoryMeta status lifecycle and branch alignment | pages/methodology/storymeta-lifecycle.md | The four StoryMeta statuses, their transition rules, and how CI enforces the story lifecycle |
<!-- wiki-routing:end -->
