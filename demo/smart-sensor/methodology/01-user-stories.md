# 1. User Stories

## 1.1 Purpose

This section defines the **User Story** as the elementary unit of stakeholder
intent within this methodology. A User Story captures, in the canonical agile
triad, a stakeholder's desired capability and the benefit that capability is
intended to deliver.

User Stories are the principal artifact through which stakeholders engage with
the model. Every requirement chain in the system specification shall ultimately
trace upward to one or more User Stories. The User Story is therefore both an
agile artifact (readable as a sentence on a card) and a model element (typed,
queryable, and linkable to behavior, structure, and verification).

## 1.2 Definition

A User Story is a specialization of `requirement def` that:

- declares exactly one primary stakeholder — the *role* — from whose
  perspective the story is written;
- describes a desired *capability* in narrative form;
- articulates a *benefit* attributable to that capability;
- carries one or more *acceptance criteria* sufficient to determine when the
  story is satisfied;
- may *frame* one or more stakeholder concerns (`concern def`) that the story
  addresses;
- may be progressively elaborated with typed references into the behavioral,
  structural, or analytical model without losing its agile-canonical form.

A User Story is not a Use Case, an Action, a Function, or a Feature in the
SAFe sense. It is a stakeholder need expressed in the agile form.

User Stories complement, rather than replace, the SysML v2 `concern def`
construct. A concern captures *what* a stakeholder cares about; a User Story
captures a *specific actionable expression* of that care, written from the
stakeholder's perspective. The two are linked through `frame concern` (see
§1.4.6).

## 1.3 Type Hierarchy

`stakeholder`, `actor`, and `subject` are SysML v2 language keywords and are
not redefined by this methodology. User Stories are introduced as a
specialization of a base stakeholder need:

```sysml
requirement def StakeholderNeed abstract;

requirement def UserStory :> StakeholderNeed {
    stakeholder role;
    attribute   capability : String;
    attribute   benefit    : String;
    requirement acceptance[0..*];
}
```

The `role` feature is left untyped in the base definition. Concrete User
Stories shall redefine it with a project-specific part definition (see
§1.4.1). The same part definition shall type any `actor` usage that
represents this party in a bound use case (see §1.4.5).

Coarser-grained specializations may be introduced where a scaled context
requires them:

```sysml
requirement def Feature :> StakeholderNeed;
requirement def Epic    :> StakeholderNeed;
```

`derive` relationships shall be used to connect coarser-grained intent down
to User Stories. Tasks (work-management items) are out of scope of this
methodology and shall not be modeled as requirements.

## 1.4 Members

### 1.4.1 `role` — mandatory, exactly one

`role` is a `stakeholder` feature whose type is supplied by the concrete User
Story via redefinition. It identifies the single primary party from whose
perspective the story is written, corresponding to the canonical "As a …"
clause.

`role` shall be redefined with a project-specific part definition before the
story transitions out of `backlog` status. The same part definition shall be
used wherever this party appears as an `actor` in any use case that
declares this story as its `objective` (see §1.4.5). Untyped roles are
permitted during ideation but render the story incomplete for planning
purposes.

Additional interested parties (beneficiaries, observers, regulators) may be
expressed by introducing further `stakeholder` features alongside `role`.
`role` itself shall remain singular and shall correspond to the "As a …"
party.

### 1.4.2 `capability` — mandatory

`capability` is a string describing the "I want …" clause: what the role
wants to do, see, or experience.

Where the capability has been elaborated in the behavioral model, a
separate `use case def` may declare this story as its `objective`. The
`capability` string is retained in all cases; it is the story's identity
for human readers.

### 1.4.3 `benefit` — mandatory

`benefit` is a string describing the "so that …" clause: the value the role
gains from the capability.

Where the benefit has been formalized as a measurable outcome, the User Story
should additionally `require` a requirement definition that constrains the
relevant value properties. A benefit that cannot be reduced to a constraint
over a model element is permitted but flagged as informal.

### 1.4.4 `acceptance` — mandatory, at least one before `ready`

`acceptance` is a multiplicity of nested requirement definitions, each
expressing one acceptance criterion in Given/When/Then form (or an equivalent
declarative form).

Acceptance criteria may be authored as text initially. Once test models
exist, a separate `verification def` (spec §8.2.2.23) declares an
`objective { verify <acceptance> }` clause naming the criterion to be
verified. The acceptance criterion remains a subrequirement of the story;
the verification case is a peer.

A User Story shall declare at least one acceptance criterion before being
marked `ready`.

### 1.4.5 Coupling `role` to an `actor` via use case `objective`

A User Story is a *requirement* (a kind of `requirement def`). A Use Case
is a *case* (a kind of `case def`, ultimately a kind of action). They are
different kinds and cannot be embedded in each other directly. The
SysML-v2-compliant way to connect a story to a use case that elaborates
its capability is via the use case's `objective` clause (spec §7.21.2):
the use case declares the story as the requirement its performance is
intended to satisfy.

```sysml
part def Operator;

requirement def US_042_AckFromDashboard :> UserStory {
    subject sys : Aiwell_OnlineSentral;
    stakeholder role : Operator;

    capability = "acknowledge alarms from the dashboard";
    benefit    = "the queue clears quickly";
}

use case def AcknowledgeAlarms {
    subject sys : Aiwell_OnlineSentral;
    actor performer : Operator;

    objective realisesUS042 : US_042_AckFromDashboard;
}
```

The `objective realisesUS042 : US_042_AckFromDashboard` clause makes the
story the requirement that the use case's performance is intended to
satisfy.

Two consequences follow:

- **Role-actor link by shared typing.** The use case's `actor performer`
  and the story's `stakeholder role` reference the same `part def`
  (`Operator`). This typing identity is what couples the actor to the
  stakeholder. Renaming or refining `Operator` propagates to both sides
  automatically.
- **Subject conformance.** The `subject` of the use case shall be the
  same type (or a specialization) as the `subject` of the story. This is
  the well-formedness rule that makes the link checkable.

Where the role does not perform a use case (informational stakeholders,
regulators), no use case is declared. Type-level coincidence between
roles and actors is sufficient where it occurs; additional traceability,
if required, is expressed via metadata rather than by inventing
non-conformant SysML constructs.

### 1.4.6 `frame concern` — optional, multiplicity [0..*]

A User Story may declare that it addresses one or more stakeholder concerns
through the SysML v2 `frame concern` mechanism (sysmlv2 §32.5). A
`concern def` is a specialised requirement that captures a stakeholder need
in its own right — independent of any specific story that happens to address
it. Concerns persist across the model; stories come and go.

```sysml
concern def FastIncidentResponse {
    subject system    : Aiwell_OnlineSentral;
    stakeholder ops   : OperationsTeam;
    require constraint {
        doc /* Operations need short time-to-acknowledge to meet
               SLA targets for incident response. */
    }
}

requirement def US_042_AckFromDashboard :> UserStory {
    stakeholder role : Operator;
    capability = "acknowledge alarms from the dashboard";
    benefit    = "the queue clears quickly";

    subject system : Aiwell_OnlineSentral;

    frame concern : OpsConcerns::FastIncidentResponse;

    requirement acceptance[1] { /* … */ }
}
```

Three consequences follow:

- **Concerns and stories are n:m.** A single concern (e.g., maintainability)
  can be addressed by multiple stories; a single story can address multiple
  concerns. Framings make this explicit.
- **Concerns outlive stories.** A concern modelled once in a stakeholder
  needs package is referenced from any story that addresses it. When stories
  are reworked or superseded, the concern remains stable.
- **Coverage is queryable.** A concern with no framing stories is an unmet
  stakeholder need; a story with no framed concerns is an unrooted backlog
  item.

The narrative `benefit` attribute is retained even when a concern is framed.
The benefit articulates *what value the role gains*; the concern articulates
*what the stakeholder fears, hopes for, or requires* at a more abstract
level. Both are useful, and they answer different questions.

## 1.5 Story Metadata

User Stories carry agile lifecycle and planning information via the
`StoryMeta` metadata definition:

```sysml
metadata def StoryMeta {
    attribute points   : Integer[0..1];
    attribute priority : Priority[0..1];
    attribute status   : StoryStatus;        // backlog | ready | inProgress | done
    attribute invest   : InvestFlags[0..1];
}
```

`StoryMeta` shall be applied to every User Story instance via the
`@StoryMeta { … }` invocation. `status` is mandatory; the remaining attributes
are optional and project-determined.

## 1.6 Identifier Convention

User Stories shall be identified using the pattern
`US_<n>_<ShortName>`, where `<n>` is a zero-padded numeric identifier unique
within the project and `<ShortName>` is a concise CamelCase descriptor.

> Example: `US_042_AckFromDashboard`

## 1.7 Authoring Patterns

### 1.7.1 Minimal form (text-only)

A User Story authored at backlog entry shall include the agile-canonical
members and at least one acceptance criterion. Typed bindings into the
behavioral or analytical model are not required at this stage.

```sysml
requirement def US_042_AckFromDashboard :> UserStory {
    @StoryMeta { points = 5; priority = high; status = ready; }

    stakeholder role : Operator;
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

This form is sufficient for backlog management and human-facing planning
conversations.

### 1.7.2 Elaborated form

As the story progresses through the lifecycle, model bindings are added —
both inside the story (subrequirements, framed concerns) and outside it
(the use case that takes the story as its objective, the verification
case that verifies its acceptance):

**The story:**

```sysml
requirement def US_042_AckFromDashboard :> UserStory {
    @StoryMeta { points = 5; status = inProgress; }

    subject sys : Aiwell_OnlineSentral;
    stakeholder role : Operator;

    capability = "acknowledge alarms from the dashboard";
    benefit    = "the queue clears quickly";

    frame concern : OpsConcerns::FastIncidentResponse;

    requirement sla : IncidentResponseSLA;        // subrequirement (§7.20.2)

    requirement acceptance[1] {
        doc /* Given N unacknowledged alarms, when operator selects
               "Ack all", then all N transition within 1 s. */
    }
}
```

**The use case taking the story as its objective:**

```sysml
use case def AcknowledgeAlarms {
    subject sys : Aiwell_OnlineSentral;
    actor performer : Operator;

    objective realisesUS042 : US_042_AckFromDashboard;
}
```

**The verification case verifying the acceptance criterion:**

```sysml
verification def VC_AckBatchTiming {
    subject sys : Aiwell_OnlineSentral;

    objective {
        verify US_042_AckFromDashboard::acceptance;
    }
}
```

The narrative `role`, `capability`, and `benefit` shall be retained
throughout the lifecycle. They constitute the story's identity for human
readers and shall not be removed when typed bindings are introduced.

The use case and the verification case are *peers* of the story, not
nested inside it. The package layout in §8.3 reflects this — they live
in `core/use-cases/` and `core/verification-validation/verification-cases/`
respectively, while the story lives in `core/stories/<level>/`.

## 1.8 Relationships

A User Story participates in the model via the following relationships:

- specializes (`:>`) `UserStory`;
- declares a `subject` referencing the system or subsystem under specification;
- declares a `stakeholder` reference (`role`, plus any additional
  declarations) typed by a project-specific part definition;
- may `frame` one or more `concern def` instances representing the
  stakeholder needs the story addresses (spec §7.20.3);
- may declare *subrequirements* (composite requirement usages) — including
  references to externally-defined requirement defs by name — that
  formalise benefit constraints (spec §7.20.2);
- may be the requirement *named as the `objective`* of one or more
  `use case def` or `analysis def` whose performance is intended to
  satisfy the story (spec §7.21.2);
- each `acceptance` subrequirement may be the target of a `verify` clause
  in the `objective` of one or more `verification def` (spec §8.2.2.23);
- may be the target of `derive` relationships from `Feature` or `Epic`
  specializations.

## 1.9 Well-Formedness Rules

The following rules apply to every User Story:

1. A User Story shall declare exactly one `role`.
2. A User Story shall declare exactly one `subject`.
3. A User Story shall declare at least one `acceptance` criterion before
   transitioning to `ready` status.
4. A User Story's `role` shall be redefined with a concrete part definition
   before transitioning out of `backlog` status.
5. Where a `use case def` declares a User Story as its `objective`, the
   use case's `subject` type shall conform to the story's `subject` type,
   and the use case's `actor` representing the story's role shall be
   typed by the same part def as the story's `role`.
6. The narrative `capability` and `benefit` strings shall be retained
   throughout the story's lifecycle.
7. A User Story shall not specialize a Use Case, Action, Case, or any
   non-Requirement definition (spec §7.20 — requirements specialise from
   the requirement-kind taxonomy only).

---

*End of Section 1.*
