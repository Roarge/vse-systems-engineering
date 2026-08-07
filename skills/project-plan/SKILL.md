---
name: project-plan
description: 'Author or revise the Project Plan and its companion artefacts: SEMP, Risk Register, CM Strategy, and Disposal Approach (§10.3).'
when_to_use: Use on /vse-plan, "draft project plan", "update SEMP", "revise risk register", "CM strategy", "disposal approach", "PM.O1", or "plan-baseline-vN.M".
user-invocable: true
---

# project-plan

Author or revise the Project Plan and its companion artefacts (SEMP, Risk Register, CM Strategy, Disposal Management Approach) per §10.3 of the methodology specification at `<project>/methodology/10-project-management.md`. The Plan is the ISO 29110 PM.O1 artefact and is baselined by an annotated git tag `plan-baseline-vN.M`.

## When this skill triggers

- The user invokes `/vse-plan` (with or without a section argument).
- The user says "draft the project plan", "revise the Plan", "update the SEMP", "update the risk register", "update CM strategy", "update disposal approach", or equivalent phrasings.
- The `@release-orchestrator` hands off because a release demands a Plan revision (Schedule, Milestones, Risks, or CM items have drifted from the last `plan-baseline-*` tag).
- A coverage check against §10.3.1 has been requested with no operation named.

If invoked outside a VSE project (no `methodology/` directory and no `docs/project-plan.md`), say so and route the engineer to `@project-setup` (`/vse-setup`). This is routing rather than a refusal: the Plan has no project to describe yet, and setup is the step that gives it one.

## Inputs

Read, in order, before proposing any edit:

1. The existing `docs/project-plan.md` if present.
2. The existing `docs/semp.md`, `docs/risk-register.md`, `docs/cm-strategy.md` if present.
3. The most recent `plan-baseline-*` tag (`git tag --list 'plan-baseline-*' --sort=-v:refname | head -n1`) and the diff between that tag and `HEAD` for any of the four Plan-bearing files.
4. The methodology copy at `<project>/methodology/`, especially §10.3, §10.7, §10.8, §10.9, §10.3.4, and §8.4.3.
5. Any Change Request issue referenced by the user. Plan revisions against a baselined element require an open CR per §10.4.2.

## Workflow

### Default (no operation specified)

Produce a §10.3.1 element coverage report. For each of the seventeen elements (SOW reference, Objectives, System Description, Scope, SBS, Deliverables, Tasks, Estimated Duration, Resources, Composition of Work Team, Milestones, Schedule of Project Tasks, Estimated Effort and Cost, Risk Management Approach, Disposal Management Approach, Configuration Management Strategy, Delivery Instructions) report: present and populated, present but empty, or missing. Mark which of them the project actually owes at its profile, using the scaled plan sets in §10.3.1 and the obligation table in §0.10.3, so a `light` project is not shown fourteen findings it does not owe. Report the last `plan-baseline-*` tag, the date of that tag, and any uncommitted local edits to Plan-bearing files. Recommend the next action and stop.

### Initial authoring (no Plan exists)

1. Confirm with the engineer that this is a greenfield Plan.
2. Open a methodology branch named `methodology/project-plan-initial` per §8.4.3 (or hand off to `@story-orchestrator` to open it if the engineer prefers that route).
3. Copy `${CLAUDE_PLUGIN_ROOT}/templates/pm/project-plan.md` to `docs/project-plan.md` and substitute `{{PROJECT_NAME}}`, `{{DATE}}`, `{{AUTHOR}}` from project metadata.
4. Walk the §10.3.1 element list with the engineer, populating one element at a time. Pull the SBS from `core/logical-architecture/` recursively per §10.3.1. Pull Tasks from §0 to §8 activity structure. Resolve Resources and Work Team from CODEOWNERS.
5. Generate the SEMP content (§10.3.2) inline as a Plan section unless the engineer asks for a separate `docs/semp.md`. If separate, copy `${CLAUDE_PLUGIN_ROOT}/templates/sr/semp.md` and cross-reference from the Plan.
6. Scaffold `docs/risk-register.md` (per §10.7) and the Approach prose in §7 of the Plan.
7. Scaffold `docs/cm-strategy.md` from the YAML excerpt in §10.8 and cross-reference from Plan §9.
8. Populate the Disposal section (§10.9) inline with trigger, schedule, actions, resources, design constraints, and acceptable end-state.
9. Surface the §10.3.4 acceptance flow to the engineer: PR opening, Acquirer review, CI lint pass, squash-and-merge, annotated tag `plan-baseline-v1.0` on the merge commit.

### Section-targeted revision (`/vse-plan <section>`)

Recognised section keywords map as follows:

- `scope`, `objectives`, `description` to Plan §1.
- `sbs` to Plan §3.
- `tasks`, `schedule` to Plan §5.
- `resources`, `team`, `effort` to Plan §6.
- `risks` to Plan §7 plus `docs/risk-register.md`.
- `disposal` to Plan §8.
- `cm` to Plan §9 plus `docs/cm-strategy.md`.
- `semp` to the SEMP section or `docs/semp.md`.
- `delivery` to Plan §2.
- `all` to a guided full-Plan walkthrough.

For any section-targeted edit:

1. Check whether the Plan is baselined by inspecting tags and the element's content history. If baselined and the engineer has not referenced an open Change Request, name the §10.4.2 obligation and hand off to `@change-request` (`/vse-cr`), with the per-profile disposition in Judgment calls.
2. If the change is permitted, ask `@story-orchestrator` to open a methodology branch named `methodology/project-plan-<section>` per §8.4.3.
3. Load only the named section, propose changes, and wait for approval before writing.
4. After write, surface the §10.3.4 acceptance flow with the next tag incremented (patch for fixes, minor for new content, major for structural rework).

### SEMP revision

Generate or update: methodology reference (cite this plugin's methodology spec and version), engineering tools list (SysML v2 implementation, IDE, linter, CI/renderer), engineering interfaces (adjacent projects, contractors, certifying authorities), mission assurance and review cadence (linked to the project's story-and-release cadence), and TPM set (the system property/measure set tracked during execution). Place under Plan §1 if short, else as `docs/semp.md`.

### Risk Management Approach revision

Update Plan §7 prose (frequency, participants, sources, evaluation criteria, treatment options, monitoring cadence) and the table columns of `docs/risk-register.md` (ID, description, likelihood, impact, priority, owner, treatment, status, date opened, date last reviewed).

### CM Strategy revision

Populate `docs/cm-strategy.md` from the YAML template in §10.8. Items under CM, baseline strategy, backup configuration, access control. Cross-reference from Plan §9.

### Disposal Management Approach revision

Populate Plan §8 with: trigger, schedule, actions (hardware, data, software licence, IP handover, environmental), resources, constraints on design (propagated to stakeholder concerns per §4.3.2 if non-trivial), acceptable end-state.

## Judgment calls

Each entry names a rule and the section it comes from, states the concrete risk of departing from it, and recommends the conforming path. The default is to proceed once the engineer has confirmed with that information in hand. One entry becomes a hard stop at the `full` profile and says so.

Obligations scale with the project profile, methodology §0.10. Read `project_profile` per the lens convention before deciding how firmly to press.

- **A baselined Plan element changed with no Change Request.** §10.4.2. Changing a baselined element outside the Change Request lifecycle breaks the audit trail between the `plan-baseline-*` tag and the content it certifies, and the break is invisible afterwards. Name the element and route to `@change-request` (`/vse-cr`). At `standard`, wait for explicit confirmation. At `full` this is a hard stop, because the Plan is the PM.O1 artefact an assessor reads. At `light` the default `baselined_paths` list is empty, so the Plan is not under Change Request protection until the project puts it there.

- **Committing a Plan with elements left empty.** The element set the Plan owes is tiered per §0.10.3, so check the populated set against the project profile rather than against all seventeen §10.3.1 elements. `light` owes the one-page set (Objectives, Scope, Deliverables, Milestones, known risks), `standard` adds System Description, Tasks, Resources, Risk Management Approach, and a one-paragraph Configuration Management section, and `full` owes all seventeen. Name the elements that are empty at the project's own profile, recommend populating them, and proceed on confirmation. An empty element is a gap the engineer can see, whereas a Plan that never gets written is a gap nobody sees.

- **Working directly on `main`.** §8.4.1 as scaled by §0.10.3. At `light` a direct commit is permitted with a warning, so say it once and proceed. At `standard` it is discouraged, so recommend a `methodology/project-plan-<section>` branch per §8.4.3 and proceed on confirmation. At `full` it is prohibited and enforced by branch protection, so the push will be rejected regardless. Open the branch first.

## Hand-offs

- To `@change-request` (`/vse-cr`) when the proposed edit affects a baselined Plan element.
- To `@release-orchestrator` once the Plan revision unblocks a pending release.
- To `@story-orchestrator` to open the methodology branch for the Plan revision per §8.4.3.
- To `@project-setup` (`/vse-setup`) if the project is not yet scaffolded.

## Outputs

- `docs/project-plan.md`, populated initial draft or scoped revision.
- `docs/semp.md`, when the SEMP is a separate document.
- `docs/risk-register.md`, scaffolded register with the columns required by §10.7.
- `docs/cm-strategy.md`, scaffolded from the §10.8 YAML.
- An annotated tag `plan-baseline-vN.M` placed on the merge commit after Acquirer acceptance per §10.3.4. The skill surfaces the tag command for the engineer to run, the skill itself does not push tags.

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| ISO/IEC TR 29110-5-6-2 compliance mapping | pages/methodology/iso-29110-compliance-mapping.md | The VSE methodology declares partial compliance with the Basic Profile of ISO/IEC TR 29110-5-6-2:2014 |
| Project Management workflow (§10) | pages/methodology/project-management-workflow.md | The §10 workflow with a living Project Plan, iteration-cadence status, and change requests as pull requests |
<!-- wiki-routing:end -->
