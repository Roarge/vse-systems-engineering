---
title: "Architectural Design workflow (§7)"
slug: architectural-design-workflow
type: process
layer: methodology
tags: [subsystem-decomposition, allocation, control-law, dependability, recursive, sr-3]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §7 (Architectural Design)."
    raw: methodology/07-architectural-design.md
related:
  - methodology-overview
  - architectural-analysis-workflow
  - system-stories-workflow
  - user-story-canonical-artefact
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, architecture-design, story-orchestrator]
---

# Architectural Design workflow (§7)

The §7 stage decomposes the resolved logical architecture into subsystems, allocates the system-level specification down to those subsystems, and propagates the user-story-driven specification recursively to the subsystem scope. The stage adapts Harmony aMBSE Chapter 7 (Douglass, 2016), with three substantive shifts: subsystem requirements are authored as recursive subsystem user stories, allocations use SysML v2 native `allocation` rather than stereotypes, and subsystem stories live inside the component folder per [[methodology-overview]] §8.3.2.

## Inputs

- Resolved architecture from [[architectural-analysis-workflow]] (§6), that is, the system `part def` with all variation points selected.
- System story register from [[system-stories-workflow]] (§5).
- Logical data schema from §5.
- System Context (§3), the boundary at which inter-subsystem interfaces emerge.

## Activities

### 7.3.1 Identify subsystems

Decompose the resolved architecture into subsystems whose responsibilities are coherent and whose internal coupling exceeds inter-subsystem coupling. Each subsystem is declared as a `part def` and composed under the system part def via `part` usages. The decomposition is informed by:

- **Function grouping**, that is, actions and use cases sharing state and data should sit in the same subsystem.
- **Coupling**, minimising inter-subsystem communication and maximising intra-subsystem cohesion.
- **Technology boundaries**, where different runtime characteristics (real-time versus soft, software versus hardware) imply distinct subsystems.
- **Organisational boundaries**, where different teams, vendors, or certification authorities argue for separation.

### 7.3.2 Allocate system requirements to subsystems

For each `require constraint` in the system story register, allocate it to the subsystem or subsystems that bear it. Three cases apply:

- **Single allocation**, where the constraint is the responsibility of one subsystem, declared as `allocation <name> allocate <SysReq> to <Subsystem>`.
- **Joint allocation**, where the constraint is jointly held (typical for end-to-end latency budgets), declared as multiple `allocation` instances against the same source constraint.
- **Decomposition**, where the constraint is split into new subsystem-level constraints whose conjunction implies the system constraint. Decomposition introduces fresh subsystem stories that derive from the system constraint, and the calling sibling subsystem becomes the `role` (stakeholder) of the derived story.

### 7.3.3 Allocate stories and capabilities

Two approaches are valid and often combined:

- **Top-down**, where system stories are decomposed via `derive` connections (using the `RequirementDerivation` metadata library) into subsystem-internal stories, each allocated to one subsystem. The subsystem stories satisfy the system story when conjoined.
- **Bottom-up**, where action defs and use cases that elaborate system stories are first allocated to subsystems, after which subsystem-level stories are extracted from the allocated behaviour.

A system-level story is typically not allocated to a single subsystem. It is realised by collaboration. The set of subsystem stories that derive from it together cover the system story.

### 7.3.4 Update logical data schema and define inter-subsystem interfaces

Items that previously crossed the system boundary may now also cross inter-subsystem boundaries. Declare `interface def` blocks between subsystems analogously to §3.3.3, with `end` ports and typed `flow` declarations. Wire interfaces with `interface <name> : InterfaceDef connect <part>.<port> to <part>.<port>` clauses inside the system part def. Extend the logical data schema where subsystem-internal items emerge that the system-level schema did not require.

### 7.3.5 Create or update subsystem user stories

For each subsystem, apply the §1 specification recursively (see [[user-story-canonical-artefact]]). The subsystem becomes the new system in this scope:

- Sibling subsystems, the parent system, and external actors local to the subsystem boundary form the candidate stakeholder set.
- The subsystem's `part def` is the `subject` of its stories.
- Subsystem concerns, stories, behavioural elaborations, and verification cases follow the full §1 to §5 recursion.

Subsystem stories live in `core/logical-architecture/components/<component>/stories/`, not in a flat subsystem-stories bucket. The recursion of §1 to §5 applies in its full generality at every depth.

### 7.3.6 Develop control laws

For control behaviour spanning multiple subsystems, declare `constraint def` instances capturing the law and allocate to the responsible subsystems. Single-subsystem control laws are deferred to detailed design. Control laws differ from acceptance criteria in scope: an acceptance criterion verifies that a story is satisfied, whereas a control law constrains ongoing behaviour across subsystems regardless of any single story's invocation. A control law that spans subsystems must be allocated to all subsystems whose behaviour it constrains. Partial allocation is incorrect.

### 7.3.7 Re-analyse dependability

Architectural decomposition introduces new failure modes (subsystem boundaries are failure surfaces) and may eliminate others. Re-run the §5.4.5 dependability activity at subsystem granularity:

- New concerns, including subsystem-boundary failures, inter-subsystem message loss, and partial-failure modes.
- New stories, addressing how the responsible subsystem or subsystems handle these concerns.
- New constraints, expressed as assertions on inter-subsystem interfaces.

### 7.3.8 Perform review

Where SysML v2 model execution is available, exercise the verification cases against the elaborated model. Manual review remains valuable, with reviewers asking:

- Does every system story have at least one subsystem-story or subsystem-allocation derivation?
- Do the subsystem stories collectively cover the system story?
- Are inter-subsystem interfaces minimal? Each interface is a cost.
- Does the decomposition match the team and procurement structure?

## Outputs

- Subsystem `part def` set, that is, the decomposition itself.
- Allocation relationships from system stories, requirements, and use cases to subsystems.
- Subsystem story register per component, residing under `core/logical-architecture/components/<component>/stories/`.
- Inter-subsystem `interface def` set, extending §3.
- Control law `constraint def` set for cross-subsystem control.
- Updated dependability concerns and stories at subsystem scope.
- Subsystem-scope verification cases.

## Recursion termination

A subsystem is *terminal* when no further decomposition is warranted in the current iteration. Terminal subsystems carry stories and verification cases but no nested `logical-architecture/components/<sub>/`. A subsystem is *handed off* to detailed design when the project's remit ends at that boundary. The handoff package contains the subsystem specification (stories, interfaces, constraints), and the receiving discipline takes the design forward. The methodology recurses as deep as decomposition warrants and stops at terminal or handoff boundaries.

## Well-formedness

1. Every system-level `require constraint` shall be either allocated to one or more subsystems, or decomposed into subsystem-level constraints whose conjunction implies it.
2. Every subsystem story shall declare its `subject` as a subsystem `part def`, not the system part def.
3. The recursive application of §1 well-formedness applies at subsystem scope, enforced by CI at every depth.
4. Every inter-subsystem `interface def` shall declare item types for all flows.
5. A subsystem with no stories and no allocations is not part of the architecture and shall be removed.
6. A control law spanning subsystems shall be allocated to all subsystems whose behaviour is constrained by it.

## Out of scope

Detailed design beyond subsystem boundaries (handed off to engineering disciplines per §0.9), physical or product decomposition (a downstream concern that may consume this methodology's outputs), implementation language and tooling within subsystems, and integration testing strategy beyond the verification cases captured at system and subsystem scope.

## See also

- [[methodology-overview]] for the full §0 to §8 staging.
- [[architectural-analysis-workflow]] for the §6 inputs to this stage.
- [[system-stories-workflow]] for the §5 story register that drives allocation.
- [[user-story-canonical-artefact]] for the §1 specification applied recursively at subsystem scope.
