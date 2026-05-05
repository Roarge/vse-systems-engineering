---
title: "Stakeholder Requirements Engineering workflow (§4)"
slug: stakeholder-stories-workflow
type: process
layer: methodology
tags: [stakeholder, concern, user-story, validation, workflow, elicitation, methodology, sr-2]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §4 (Stakeholder Requirements Engineering)."
    raw: methodology/04-stakeholder-requirements.md
related:
  - methodology-overview
  - user-story-canonical-artefact
  - frame-concern-pattern
  - base-architecture-corollaries
  - system-context-completeness
  - system-stories-workflow
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, needs-and-requirements, story-orchestrator]
---

# Stakeholder Requirements Engineering workflow (§4)

Section 4 of the methodology is the first user-story-driven workflow stage. It captures stakeholder intent and produces the *stakeholder story register*, the set of `UserStory` specialisations that anchors every downstream requirement chain, together with the supporting concern and validation artefacts. The stage adapts the activities of Harmony aMBSE Chapter 4 (Douglass, 2016) to a user-story-first approach in which stakeholder use cases are demoted to optional elaborations introduced via the `objective` link of [[user-story-canonical-artefact]]. See [[methodology-overview]] for how §4 sits inside the overall arc.

## Inputs and outputs

The stage consumes two foundational artefacts and one project-level input that stays outside the formal model.

- Base Architecture, per [[base-architecture-corollaries]]. Pre-existing architectural and technical decisions constrain the candidate stakeholders and concerns.
- System Context, per [[system-context-completeness]]. The set of human actors and external systems already framed at the system boundary seeds the stakeholder taxonomy.
- The project charter or problem statement, treated as project-determined input that the methodology does not formalise.

The stage produces five artefacts, all SysML 2.0 native:

- A stakeholder taxonomy of `part def` instances under `core/stakeholders/`.
- A stakeholder concern register of `concern def` instances under `core/concerns/`.
- A stakeholder story register of `UserStory` specialisations under `core/stories/stakeholder/`.
- An optional use case set of `use case def` instances under `core/use-cases/`, each declaring a stakeholder story as its `objective`.
- A validation case set of `verification def` instances under `core/verification-validation/validation-cases/`, exercising stakeholder intent rather than system internals.

## Workflow steps

### Step 1: Identify stakeholders

Enumerate the entities, human, organisational, or regulatory, that have concerns about the system. Sources include the project charter, comparable historical projects, applicable regulations, and the human-actor and external-system categories already framed in [[system-context-completeness]]. For each stakeholder declare a `part def` in `core/stakeholders/`. The methodology deliberately avoids an abstract `Stakeholder` parent: each role stands on its own to keep the model honest about who the stakeholder actually is. The same `part def` shall be reused wherever the stakeholder appears as an actor in §3 System Context and §5 system stories, which preserves the role-actor coupling described elsewhere.

Stakeholders may be active, that is interacting with the system through System Context (Operator, Maintainer), or passive, that is holding concerns without interaction (Regulator, Procurement, Sponsor).

### Step 2: Capture stakeholder concerns

For each stakeholder declare one or more `concern def` instances expressing what the stakeholder cares about, fears, or requires. A concern is a kind of requirement (sysmlv2 §7.20.3) that captures stakeholder need at an abstract level, persists across iterations, and may be addressed by multiple stories. Each `concern def` carries three load-bearing members:

- `subject` referencing the system part def from §2 or §3,
- `stakeholder` referencing the relevant stakeholder part def from step 1,
- `require constraint` documenting the underlying need.

Concerns are declared *first* and updated *last*. They outlive individual stories. A concern register that grows during a project is healthy. A register that churns suggests stakeholder elicitation is incomplete. See [[frame-concern-pattern]] for the framing semantics by which stories link back to concerns.

### Step 3: Identify and prioritise capability themes

For each concern, identify the capability themes through which the concern can be addressed. A capability theme is a candidate cluster of stories, not yet a story but the seed for one or more. Themes are *not* modelled as their own SysML elements. They are working notes captured in PR descriptions or sandbox files, and the prioritisation outcome surfaces later as `StoryMeta.priority` on the resulting stories.

Themes are prioritised against four factors, all inputs to human judgement rather than to any formula:

- **Importance.** How strongly the addressed concern matters to its stakeholder.
- **Urgency.** Whether the capability is needed early in the project.
- **Project risk.** Whether the capability touches uncertain technology or domain knowledge.
- **Information availability.** Whether the team can author the story now, or must wait for stakeholder access.

### Step 4: Generate stakeholder user stories

For each prioritised capability theme, author one or more `UserStory` specialisations per [[user-story-canonical-artefact]]. Stories enter the model in the §1.7.1 minimal form, that is `subject`, redefined `role`, `capability`, `benefit`, and at least one `acceptance` subrequirement before the story may transition to `ready`. They progress through the story lifecycle as detail emerges across later iterations.

A stakeholder story:

- declares its `subject` referencing a part def from §2 Base Architecture or §3 System Context, typically the project's system part def,
- redefines `role` with a part def from `core/stakeholders/`,
- declares `capability` and `benefit` as narrative strings,
- frames one or more concerns from `core/concerns/` per [[frame-concern-pattern]],
- declares at least one `acceptance` subrequirement before transitioning beyond `backlog`.

The `frame concern` link is the bridge that ties the new story back to the persistent concern register, which is what allows concerns and stories to remain in an n:m relationship across iterations.

### Step 5: Elaborate story scenarios via use cases (optional)

Where a story's capability is non-trivial, declare a `use case def` that names the story as its `objective`. The use case carries scenario detail (action body, sub-actions, exception flows). The story remains the carrier of stakeholder intent. Use case elaboration is permitted at the stakeholder level but not required. Many stakeholder stories never warrant a use case: the `capability` string and `acceptance` criteria are sufficient. Use cases pay their cost when a capability spans many actor interactions, for example "configure system" or "respond to incident", and the acceptance criteria alone cannot capture the flow.

### Step 6: Create or update the validation plan

For each acceptance criterion in scope declare a `verification def` (sysmlv2 §7.23) whose `objective` includes a `verify` clause naming the acceptance subrequirement. Validation cases, those that exercise stakeholder intent rather than system internals, reside in `core/verification-validation/validation-cases/`. The validation plan is the union of these verification defs. Where multiple acceptance criteria require the same fixture, a single verification def may verify several criteria. The methodology discipline that separates *validation* of stakeholder intent from *verification* of system internals is editorial rather than syntactic. The SysML construct is the same `verification def`, and it is the directory placement plus the framed concern lineage that mark a case as validation.

## Well-formedness rules

Six rules govern the output of the stage.

1. Every stakeholder story shall frame at least one concern, or carry a documenting comment explaining why no concern is yet modelled. Stories that never frame a concern are unrooted.
2. Every concern shall have at least one framing story before [[system-stories-workflow]] begins, or be marked `informational-only` via metadata. A concern with no framing story is an unmet stakeholder need.
3. The same `part def` shall type a stakeholder in `core/stakeholders/` and the corresponding human actor in §3 System Context.
4. Where a use case declares a stakeholder story as its `objective`, the use case's `subject` shall conform to the story's `subject` type, and the actor representing the story's role shall be typed by the same part def as the story's `role`.
5. Validation cases shall verify acceptance criteria that exercise stakeholder intent, not system internals. Verification of system internals belongs to §5.
6. The required output is forward-going stories, that is stories describing what the project shall *add* to the existing technical context. Context stories that record narrative around pre-existing decisions are an optional human addition per [[base-architecture-corollaries]]. AI agents shall not synthesise such context stories. A stakeholder concern *informed by* a Base Architecture constraint is legitimate and addressed by forward-going stories. The Base Architecture is the constraint, not the subject.

## Iteration discipline

Section 4 is performed on a *prioritised subset* of stakeholders, concerns, and capability themes per iteration. The iteration's scope is recorded in the PR description. Stakeholders not yet engaged remain on the backlog without `concern def` instances. Capability themes not yet authored remain as planning notes. A useful pattern interleaves §4 and §5 across iterations: capture stakeholder *X*'s primary concerns and two or three highest-priority stories per concern, derive system stories from those in the next iteration via [[system-stories-workflow]], and capture stakeholder *Y* in parallel with the system-level work on stakeholder *X*'s stories. The story register is the cross-iteration index, and stale stories whose `StoryMeta.status` has not changed in N iterations are candidates for review or culling.

## Recursive application at subsystem level

When the methodology is applied recursively at subsystem level, §4 applies as written with substitutions: "system" reads as "subsystem", "stakeholders" includes sibling subsystems and the parent system together with external actors local to the subsystem boundary, "Base Architecture" inherits from the system level (optionally refined for subsystem-specific platform concerns), and "System Context" becomes the subsystem's view of its environment. The packages live inside the component folder of the subsystem.

## Out of scope

Section 4 deliberately excludes the human-side mechanics of elicitation. Stakeholder identification methodology (interviews, workshops, ethnography) is project-determined. The methodology captures *the result* of identification rather than the identification process. The same separation applies to concern elicitation. The four prioritisation factors are inputs to human judgement, not a scoring formula. Validation case execution and reporting are project-determined: the verification defs declare *what* shall be validated, while *how* and *when* are decided per project.
