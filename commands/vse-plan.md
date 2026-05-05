---
description: Author or revise the Project Plan (docs/project-plan.md) per §10.3 of the methodology, including SEMP, Risk Register, CM Strategy, and Disposal Approach.
argument-hint: "[optional Plan section to revise: scope | sbs | risks | cm | disposal | semp | all]"
---

Invoke the `vse-systems-engineering:project-plan` skill to author or
revise the Project Plan per §10.3 of the methodology specification
at `<project>/methodology/10-project-management.md`.

Pass the user-supplied arguments through as additional context for the skill:

$ARGUMENTS

The skill will:

- Default to reporting the current Plan baseline (last
  `plan-baseline-*` tag per §10.3.4) and the §10.3.1 element
  coverage when no section is specified.
- For initial authoring: walk the engineer through the §10.3.1
  element list (SOW reference, Objectives, System Description,
  Scope, SBS, Deliverables, Tasks, Estimated Duration, Resources,
  Work Team composition, Milestones, Schedule, Estimated Effort
  and Cost, Risk Approach §10.7, Disposal Approach §10.9, CM
  Strategy §10.8, Delivery Instructions). Render to
  `docs/project-plan.md`.
- For section-targeted revision: load the existing Plan, scope the
  edit to the named section, and propose changes in a
  Plan-revision branch (per §8.4.3 methodology branches) with the
  Change Request workflow.
- For the SEMP (§10.3.2): generate the methodology reference, the
  engineering tools list, the engineering interfaces, the mission
  assurance and review cadence, and the TPM set. Place under a
  Plan section or as a separate `docs/semp.md`.
- For the Risk Management Approach (§10.7): scaffold
  `docs/risk-register.md` and the Approach prose under the Plan.
- For the CM Strategy (§10.8): scaffold `docs/cm-strategy.md` from
  the YAML template if not already present, populate the items
  under CM, the baseline strategy, and the backup configuration.
- For the Disposal Management Approach (§10.9): scaffold the
  Disposal section under the Plan with trigger, schedule, actions,
  resources, design constraints, and acceptable end-state.

The Plan is *baselined* on initial acceptance (PM.1.17) by tagging
the merge commit `plan-baseline-vN.M`. Subsequent revisions follow
the Change Request workflow (§10.4.2). This command refuses to
overwrite a baselined Plan section without an open CR.
