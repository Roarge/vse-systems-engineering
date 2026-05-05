---
title: "Coupling story role to use-case actor via objective"
slug: role-actor-coupling
type: pattern
layer: methodology
tags: [user-stories, use-cases, sysml2, traceability, well-formedness]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §1.4.5 (Coupling role to actor via use case objective)."
    raw: methodology/01-user-stories.md
related:
  - methodology-overview
  - user-story-canonical-artefact
  - system-context-completeness
  - stakeholder-stories-workflow
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, story-orchestrator, needs-and-requirements]
---

# Coupling story role to use-case actor via objective

## Why a pattern is needed

A User Story is a `requirement def` (specifically a specialisation of `StakeholderNeed`, see [[user-story-canonical-artefact]]). A Use Case is a `case def`, ultimately a kind of action. These are different kinds of SysML 2.0 element, and the language does not allow one to be embedded in the other. The narrative wish to "attach a use case to a story", or conversely to nest a story inside a use case, has no direct SysML 2.0 construct.

The pattern below is the methodology's compliant resolution: the use case names the story as its `objective`, and the type identity of the participating part definition couples the actor to the role.

## The compliant coupling

Per SysML 2.0 specification §7.21.2, a `case def` may declare an `objective` clause naming the requirement that performance of the case is intended to satisfy. The methodology binds a use case to a story by setting that objective to the story.

```sysml
part def Operator;

requirement def US_042_AckFromDashboard :> UserStory {
    subject sys : Aiwell_OnlineSentral;
    stakeholder :>> role : Operator;

    capability = "acknowledge alarms from the dashboard";
    benefit    = "the queue clears quickly";
}

use case def AcknowledgeAlarms {
    subject sys : Aiwell_OnlineSentral;
    actor performer : Operator;

    objective realisesUS042 : US_042_AckFromDashboard;
}
```

The `objective realisesUS042 : US_042_AckFromDashboard` clause makes the story the requirement that the use case is intended to satisfy. No non-conformant nesting, no surrogate trace link, no metadata-only workaround.

## Two consequences

**Role-actor link by shared typing.** The use case's `actor performer` and the story's `stakeholder role` reference the same `part def`, in this example `Operator`. This typing identity is what couples the actor to the stakeholder. Renaming `Operator` or refining it through specialisation propagates to both sides automatically, because both sides are typed by the same definition. There is no second link to keep in sync.

**Subject conformance.** The `subject` of the use case shall be the same type as the `subject` of the story, or a specialisation of it. This is the well-formedness rule that makes the link checkable. It is codified in §1.9 rule 5 of the methodology specification: where a `use case def` declares a User Story as its `objective`, the use case's `subject` type shall conform to the story's `subject` type, and the use case's `actor` representing the story's role shall be typed by the same part def as the story's `role`. A `traceability-guard` style check can verify rule 5 by reading frontmatter alone.

## Where no use case is declared

Not every stakeholder role drives a use case. Informational stakeholders, regulators, sponsors, and other parties with an interest in the system but no participation in its behaviour appear as `stakeholder` features on stories without any corresponding `actor performer` in a use case.

In that situation, no use case is declared and no `objective` clause applies. Type-level coincidence between roles and actors is sufficient where it occurs, and is the only required coupling. Additional traceability, where the project requires it, is expressed via metadata (see [[stakeholder-stories-workflow]]) rather than by inventing non-conformant SysML constructs to force an actor into existence.

## When to apply

Apply the pattern whenever a story's capability has been elaborated to the point that a behavioural specification is warranted, that is, when the story moves from `ready` toward `inProgress` and a use case enters the model. The pattern is not required at backlog entry. The agile-canonical text form of the story (role, capability, benefit, acceptance) stands on its own through the `backlog` and `ready` states, see [[user-story-canonical-artefact]].

The pattern is also the gateway from a story to downstream behavioural modelling: action flows, succession graphs, and state machines hang off the use case once the `objective` link is in place.

## Cross-cutting checks

- The full set of typed roles in the system context shall match the union of `stakeholder role` declarations across stories of all granularities, see [[system-context-completeness]].
- The methodology's overall structure for stories, use cases, and verification cases as peer artefacts is summarised in [[methodology-overview]].
- The workflow that elicits stories from stakeholder concerns and routes them to bound use cases lives in [[stakeholder-stories-workflow]].
