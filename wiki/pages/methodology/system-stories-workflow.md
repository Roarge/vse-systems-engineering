---
title: "System Requirements Definition and Analysis workflow (§5)"
slug: system-stories-workflow
type: process
layer: methodology
tags: [system-stories, derive, require-constraint, behavioural-analysis, dependability, verification, sr-2]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §5 (System Requirements Definition and Analysis)."
    raw: methodology/05-system-requirements.md
related:
  - methodology-overview
  - user-story-canonical-artefact
  - stakeholder-stories-workflow
  - benefit-as-criterion
  - architectural-analysis-workflow
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, needs-and-requirements, story-orchestrator, architecture-design]
---

# System Requirements Definition and Analysis workflow (§5)

The System Requirements stage translates stakeholder intent into a system-level specification with verifiable behaviour. It produces the system story register, the formalised system requirements as constraints over value properties, the behavioural elaborations that make stories analysable, and the verification plan. The stage adapts Harmony aMBSE Chapter 5 (Douglass, 2016) to the user-story-first posture of [[methodology-overview]], replacing the 1:1 generation of system use cases from stakeholder use cases with derivation of system *user stories* from stakeholder user stories using SysML v2's `derive` relationship.

## Inputs

- Stakeholder story register from [[stakeholder-stories-workflow]] (§4), including the concern register populated alongside it.
- System Context from §3, defining the system boundary, external actors, and the items crossing that boundary.
- Base Architecture from §2, providing the technological substrate the project layers its contribution onto.

## Step 1: Derive system stories (§5.4.1)

For each stakeholder story in scope for the iteration, derive one or more system stories. The derivation preserves the stakeholder `role` (the stakeholder is unchanged in the §4-to-§5 transition), restates the `capability` in system-internal vocabulary, and sharpens the `benefit` from narrative toward a measurable constraint. The operator's "I want to acknowledge alarms" becomes the system's "the system supports batch acknowledgement of unacknowledged alarms via the operator UI", and the loose benefit becomes a bounded latency target.

The relationship is recorded with SysML v2's `RequirementDerivation` standard library (spec §9.6). The canonical form combines the `#derive` annotation prefix on the derived requirement with an explicit `Derivation` connection between original and derived ends. A system story typically derives from one stakeholder story, but 1:N (one stakeholder story spawning several system stories) and N:1 (several stakeholder stories converging on one system story) are both legitimate.

System stories that emerge with no upstream stakeholder story (architectural maintenance, regulatory reporting, self-test) are deferred to Step 2 or Step 5, where they attach to system-side concerns rather than to stakeholder stories.

## Step 2: Generate system requirements (§5.4.2)

Within each system story, formalise benefit and capability detail as `require constraint` clauses over value properties of the system. The story's attributes declare the value properties (for example `maxBatchAckLatency : DurationValue`), and the constraints declare the relationships those properties must satisfy. This is the connective mechanism specified in §0.3 of [[methodology-overview]]. The same `require constraint` clauses become the trade-study criteria consumed in [[architectural-analysis-workflow]] (§6). A story whose `benefit` remains narrative does not contribute to §6 and applies a methodology pressure to formalise where the architecture decision will need it. See [[benefit-as-criterion]] for the rationale.

Additional system stories appearing at this step typically derive from system-side concerns (introduced in Step 5) rather than from stakeholder stories. They are added to the register here so the verification plan in Step 6 can reach them.

## Step 3: Story analysis (§5.4.3)

For each system story whose capability warrants behavioural detail, choose one of three analysis approaches. The approaches are equivalent in outcome, in that each yields the action, event, and state structure plus the item flows necessary to make the capability analysable. The choice depends on the capability's character.

- **Flow-based analysis** uses an `action def` with typed `in` and `out` parameters and nested `action` usages. It is preferred when the capability is data-driven, that is, when input items flow through transformations to output items. A use case may declare the system story as its `objective` and use the action def as its body. Scenarios are derived as paths through the action graph.
- **Scenario-based analysis** models scenarios as actions whose body sequences interactions between actor and system using `then`. It is preferred when the capability is interaction-driven, that is, when actor and system exchange a sequence of stimuli and responses. Coverage extends to the nominal case and at least one exception per stakeholder concern affected.
- **State-based analysis** uses a `state def` with `state` members and `transition` declarations carrying `accept`, `then`, and optional guards. It is preferred when the capability is mode-driven, that is, when system behaviour depends on which state it is in and stories cross state boundaries. Acceptance criteria that depend on state gain explicit state references in their constraints.

The three approaches are complementary, not exclusive. A complex capability may combine all three.

## Step 4: Extend the logical data schema (§5.4.4)

The logical data schema is the set of `item def` declarations and flow types that everything in §5 references. It extends the items already declared in the System Context (§3) with anything discovered during story analysis. Each item declares the attributes its consumers need (identifiers, severity, timestamps, state). Enumerated literals are captured as `enum def`. The schema is shared across all stories in scope for the iteration, so an item discovered in one story analysis is immediately available to the others. A new flow needed by a derived behaviour may require the System Context (§3) to be updated in turn.

## Step 5: Dependability analysis (§5.4.5)

Safety, reliability, and security are introduced as new `concern def` instances with appropriate stakeholders. Typical stakeholders include `Regulator`, `OperationsManager`, or a dedicated `SafetyOfficer` part def. Each concern is addressed by one or more new or extended system stories framed against it through `frame concern`. The methodology specifies *where* dependability outputs land, that is, as concerns and stories in the model traceable through `derive` and `frame concern`. The analysis itself (hazard identification, fault tree analysis, security threat modelling, reliability calculation) is a sub-method out of scope here.

## Step 6: Verification plan (§5.4.6)

For each acceptance criterion in scope, declare a `verification def` (spec §7.23) whose `objective` includes a `verify` clause naming the acceptance subrequirement. Verification cases at this level exercise *system internals*, distinct from §4 validation cases that exercise stakeholder intent. A verification case typically declares `setup`, `measure`, and `evaluate` actions documenting fixture, observation, and pass criterion. A verification case may verify multiple acceptance criteria where they share a fixture, and an acceptance criterion may be verified by multiple cases when different conditions warrant it.

## Output artefacts

- System story register as `UserStory` specialisations residing in `core/stories/system/`, each with `derive` links to one or more stakeholder stories.
- Behavioural elaborations per chosen analysis path: `action def` with item flows, scenario actions, or `state def`.
- Logical data schema covering everything exchanged across the system boundary or appearing in story analyses.
- Dependability concerns and stories addressing safety, reliability, and security.
- Verification plan as `verification def` instances under `core/verification-validation/verification-cases/`.

§5 applies recursively at subsystem level inside each component folder, with "system" reading as "subsystem" and the stakeholder set extended to include sibling subsystems and the parent system.
