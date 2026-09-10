---
title: "User Story as Canonical Artefact (§1)"
slug: user-story-canonical-artefact
type: concept
layer: methodology
summary: The User Story is the elementary unit of stakeholder intent in the VSE methodology
tags: [user-story, requirement, stakeholder-need, agile, sysml2]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §1 (User Stories)."
    raw: methodology/01-user-stories.md
related:
  - methodology-overview
  - frame-concern-pattern
  - role-actor-coupling
  - benefit-as-criterion
  - storymeta-lifecycle
  - stakeholder-stories-workflow
  - system-stories-workflow
  - story-branch-pr-workflow
confidence: high
created: 2026-05-05
updated: 2026-09-10
referenced_by: [story-orchestrator, needs-and-requirements]
---

# User Story as Canonical Artefact (§1)

## Contents

- Definition
- Type hierarchy
- The five members
- Connective mechanism: formalised benefit
- StoryMeta metadata
- Identifier convention
- Authoring patterns
- Well-formedness rules

The User Story is the elementary unit of stakeholder intent in the VSE methodology. It is both an agile artefact, readable as a sentence on a card, and a model element, typed and queryable inside the SysML 2.0 model. Every requirement chain in the system specification ultimately traces upward to one or more User Stories. See [[methodology-overview]] for the surrounding artefact taxonomy.

## Definition

A User Story is a requirement usage typed by the `UserStory` requirement definition of the shipped `VSE_Library`, written `requirement US_042_AckFromDashboard : UserStory { ... }`. It is never a `requirement def`. As a kind of requirement it inherits the SysML 2.0 requirement-kind taxonomy, which means it can be subject to `derive`, `satisfy`, and `verify` relationships, and it can carry nested requirement usages. A User Story is not a Use Case, an Action, a Function, or a Feature in the SAFe sense. It is a stakeholder need expressed in the agile triad of role, capability, and benefit, with acceptance criteria that determine when the story is satisfied.

## Type hierarchy

User Stories sit beneath an abstract `StakeholderNeed` requirement definition. The base type declares the members every story carries and leaves `subject` and `role` untyped, so each concrete story redefines both with project part definitions, subject first.

```sysml
abstract requirement def StakeholderNeed;

requirement def UserStory :> StakeholderNeed {
    subject system;
    stakeholder role;
    attribute   capability : String[0..1];
    attribute   benefit    : String[0..1];
    requirement acceptance[0..*];
}
```

Coarser-grained intent (`Feature`, `Epic`) also specialises `StakeholderNeed` and connects down to User Stories via `derive`.

## The five members

A well-formed User Story carries four mandatory members and one optional framing member, all declared after the subject redefinition (`subject :>> system : <PartDef>;`) that every story writes first.

1. **`role`**, mandatory, exactly one. A `stakeholder` feature corresponding to the canonical "As a ..." clause, redefined by the story as `stakeholder :>> role : Operator;` and declared after the subject redefinition. The role shall carry a concrete project part definition before the story leaves `backlog` status. The same part definition types any `actor` that represents this party in a bound use case. See [[role-actor-coupling]].
2. **`capability`**, mandatory. A string describing the "I want ..." clause: what the role wants to do, see, or experience, written `attribute :>> capability = "...";`.
3. **`benefit`**, mandatory. A string describing the "so that ..." clause: the value the role gains, written `attribute :>> benefit = "...";`. Where the benefit has been formalised as a measurable outcome, the story should additionally carry a nested requirement usage whose `require constraint` bounds the relevant value properties, so that a verification case can target it by name. See [[benefit-as-criterion]].
4. **`acceptance`**, mandatory, at least one before `ready`. A nested requirement usage inherited from `UserStory` and redefined by the story as `requirement :>> acceptance { doc /* Given ... */ }`. Several separately verifiable criteria nest inside that redefinition as named requirement usages, each expressing one criterion in Given/When/Then form or an equivalent declarative form.
5. **`frame concern`**, optional, multiplicity `[0..*]`. The story may declare that it addresses one or more `concern def` instances via the SysML 2.0 framing mechanism. See [[frame-concern-pattern]].

## Connective mechanism: formalised benefit

When the benefit is reduced to a constraint over a model element, the story carries a nested requirement usage that formalises it. This formalised benefit becomes the connective tissue between stakeholder intent and analytical work: the same constraint feeds trade-study criteria in analysis cases that take the story as their objective. A benefit that cannot be reduced to such a constraint is permitted but flagged as informal. See [[benefit-as-criterion]] for the trade-study coupling.

## StoryMeta metadata

User Stories carry agile lifecycle and planning information through the `StoryMeta` metadata definition, applied via `@StoryMeta { ... }`.

```sysml
metadata def StoryMeta {
    attribute points   : Integer[0..1];
    attribute priority : Priority[0..1];
    attribute status   : StoryStatus;        // backlog | ready | inProgress | done
    attribute invest   : InvestFlags[0..1];
}
```

`status` is mandatory. The remaining attributes (`points`, `priority`, `invest`) are optional and project-determined. Enumeration values are written qualified, as `priority = Priority::high;` and `status = StoryStatus::ready;`. See [[storymeta-lifecycle]] for the status transitions.

## Identifier convention

User Stories are identified by the pattern `US_<n>_<ShortName>`, where `<n>` is a zero-padded numeric identifier unique within the project and `<ShortName>` is a concise CamelCase descriptor.

Example: `US_042_AckFromDashboard`.

The identifier is the usage name. An optional short name (`requirement <'US-42'> US_042_AckFromDashboard : UserStory`) is display only and is ignored by the tooling.

## Authoring patterns

### Minimal form (text only)

A story authored at backlog entry includes the agile-canonical members and at least one acceptance criterion. Typed bindings into the behavioural or analytical model are not yet required. This form is sufficient for backlog management and human-facing planning conversations.

```sysml
requirement US_042_AckFromDashboard : UserStory {
    @StoryMeta { points = 5; priority = Priority::high; status = StoryStatus::ready; }

    subject :>> system : Aiwell_OnlineSentral;
    stakeholder :>> role : Operator;

    attribute :>> capability = "acknowledge alarms from the dashboard";
    attribute :>> benefit    = "the queue clears without opening each device";

    frame concern : FastIncidentResponse;

    requirement :>> acceptance {
        doc /* Given N unacknowledged alarms shown,
               when the operator selects "Ack all",
               then all N transition to acknowledged within 1 s. */
    }
}
```

### Elaborated form

As the story progresses, model bindings are added: a `use case def` that takes the story as its `objective`, a `verification def` whose objective writes `verify <story>.acceptance`, framed concerns, and nested requirement usages that formalise the benefit. The narrative `role`, `capability`, and `benefit` are retained throughout. See [[stakeholder-stories-workflow]] and [[system-stories-workflow]] for the lifecycle workflows, and [[story-branch-pr-workflow]] for the branch-and-PR cadence used to land elaborations.

## Well-formedness rules

The following eleven rules apply to every User Story.

1. A User Story is a requirement usage typed by `UserStory` (`requirement <ID> : UserStory`), never a `requirement def`.
2. A User Story shall redefine exactly one `subject` (`subject :>> system : <PartDef>;`), declared before `role`.
3. A User Story shall redefine exactly one `role` (`stakeholder :>> role : <PartDef>;`) with a concrete part definition before transitioning out of `backlog` status.
4. A User Story shall declare at least one acceptance criterion, in `requirement :>> acceptance`, before transitioning to `ready` status.
5. Where a `use case def` declares a User Story as its `objective`, the objective subsets the story and binds the story's subject to the case subject (`objective <n> :> <story> { subject :>> system = <caseSubject>; }`). The case subject type shall conform to the story's subject type, and the actor representing the role shall be typed by the same part definition as `role`.
6. The narrative `capability` and `benefit` (`attribute :>> capability = ...`) shall be retained throughout the story's lifecycle.
7. `verify` targets a member of the story usage by dot notation (`verify <story>.acceptance`), inside a `verification def` objective only.
8. A system story records its derivation with the `#derive` prefix on the usage and a `#derivation connection` whose ends are tagged `#original` and `#derive`.
9. `StoryMeta` is applied with `@StoryMeta { ... }` and qualified enumeration values.
10. `satisfy <story> by <element>` names an element typed by the story's subject type or a specialisation of it.
11. A User Story shall not be typed by a Use Case, Action, Case, or any non-Requirement definition. Requirements specialise from the requirement-kind taxonomy only.
