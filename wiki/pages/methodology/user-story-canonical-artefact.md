---
title: "User Story as Canonical Artefact (§1)"
slug: user-story-canonical-artefact
type: concept
layer: methodology
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
updated: 2026-05-05
bundled_by: [vse-companion-overview, story-orchestrator, needs-and-requirements]
---

# User Story as Canonical Artefact (§1)

The User Story is the elementary unit of stakeholder intent in the VSE methodology. It is both an agile artefact, readable as a sentence on a card, and a model element, typed and queryable inside the SysML 2.0 model. Every requirement chain in the system specification ultimately traces upward to one or more User Stories. See [[methodology-overview]] for the surrounding artefact taxonomy.

## Definition

A User Story is a specialisation of `requirement def`. As a kind of requirement, it inherits the SysML 2.0 requirement-kind taxonomy, which means it can be subject to `derive`, `satisfy`, and `verify` relationships, and it can carry subrequirements. A User Story is not a Use Case, an Action, a Function, or a Feature in the SAFe sense. It is a stakeholder need expressed in the agile triad of role, capability, and benefit, with acceptance criteria that determine when the story is satisfied.

## Type hierarchy

User Stories sit beneath an abstract `StakeholderNeed` requirement definition. The base type declares the four mandatory members and leaves `role` untyped, so concrete stories redefine it with a project-specific part definition.

```sysml
requirement def StakeholderNeed abstract;

requirement def UserStory :> StakeholderNeed {
    stakeholder role;
    attribute   capability : String;
    attribute   benefit    : String;
    requirement acceptance[0..*];
}
```

Coarser-grained intent (`Feature`, `Epic`) also specialises `StakeholderNeed` and connects down to User Stories via `derive`.

## The five members

A well-formed User Story carries four mandatory members and one optional framing member.

1. **`role`**, mandatory, exactly one. A `stakeholder` feature corresponding to the canonical "As a ..." clause. The role shall be redefined with a concrete project part definition before the story leaves `backlog` status. The same part definition types any `actor` that represents this party in a bound use case. See [[role-actor-coupling]].
2. **`capability`**, mandatory. A string describing the "I want ..." clause: what the role wants to do, see, or experience.
3. **`benefit`**, mandatory. A string describing the "so that ..." clause: the value the role gains. Where the benefit has been formalised as a measurable outcome, the story should additionally `require` a requirement definition that constrains the relevant value properties. See [[benefit-as-criterion]].
4. **`acceptance`**, mandatory, at least one before `ready`. A multiplicity of nested requirement definitions, each expressing one acceptance criterion in Given/When/Then form or an equivalent declarative form.
5. **`frame concern`**, optional, multiplicity `[0..*]`. The story may declare that it addresses one or more `concern def` instances via the SysML 2.0 framing mechanism. See [[frame-concern-pattern]].

## Connective mechanism: formalised benefit

When the benefit is reduced to a constraint over a model element, the story carries a subrequirement that formalises it. This formalised benefit becomes the connective tissue between stakeholder intent and analytical work: the same constraint feeds trade-study criteria in analysis cases that take the story as their objective. A benefit that cannot be reduced to such a constraint is permitted but flagged as informal. See [[benefit-as-criterion]] for the trade-study coupling.

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

`status` is mandatory. The remaining attributes (`points`, `priority`, `invest`) are optional and project-determined. See [[storymeta-lifecycle]] for the status transitions.

## Identifier convention

User Stories are identified by the pattern `US_<n>_<ShortName>`, where `<n>` is a zero-padded numeric identifier unique within the project and `<ShortName>` is a concise CamelCase descriptor.

Example: `US_042_AckFromDashboard`.

## Authoring patterns

### Minimal form (text only)

A story authored at backlog entry includes the agile-canonical members and at least one acceptance criterion. Typed bindings into the behavioural or analytical model are not yet required. This form is sufficient for backlog management and human-facing planning conversations.

```sysml
requirement def US_042_AckFromDashboard :> UserStory {
    @StoryMeta { points = 5; priority = high; status = ready; }

    stakeholder :>> role : Operator;
    capability = "acknowledge alarms from the dashboard";
    benefit    = "the queue clears without opening each device";

    subject system : Aiwell_OnlineSentral;

    requirement acceptance[1] {
        doc /* Given N unacknowledged alarms shown,
               when the operator selects "Ack all",
               then all N transition to acknowledged within 1 s. */
    }
}
```

### Elaborated form

As the story progresses, model bindings are added: a `use case def` that takes the story as its `objective`, a `verification def` that verifies its acceptance criteria, framed concerns, and subrequirements that formalise the benefit. The narrative `role`, `capability`, and `benefit` are retained throughout. See [[stakeholder-stories-workflow]] and [[system-stories-workflow]] for the lifecycle workflows, and [[story-branch-pr-workflow]] for the branch-and-PR cadence used to land elaborations.

## Well-formedness rules

The following seven rules apply to every User Story.

1. A User Story shall declare exactly one `role`.
2. A User Story shall declare exactly one `subject`.
3. A User Story shall declare at least one `acceptance` criterion before transitioning to `ready` status.
4. A User Story's `role` shall be redefined with a concrete part definition before transitioning out of `backlog` status.
5. Where a `use case def` declares a User Story as its `objective`, the use case's `subject` type shall conform to the story's `subject` type, and the use case's `actor` representing the story's role shall be typed by the same part definition as the story's `role`.
6. The narrative `capability` and `benefit` strings shall be retained throughout the story's lifecycle, even when typed bindings are introduced.
7. A User Story shall not specialise a Use Case, Action, Case, or any non-Requirement definition. Requirements specialise from the requirement-kind taxonomy only.
