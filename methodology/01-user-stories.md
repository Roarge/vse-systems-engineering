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

A User Story is a requirement usage typed by the `UserStory` requirement
definition of the shipped `VSE_Library`
(`requirement US_042_AckFromDashboard : UserStory { ... }`) that:

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
not redefined by this methodology. The `UserStory` requirement definition is
introduced as a specialisation of a base stakeholder need:

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

The `subject` and `role` features are left untyped in the base definition.
Concrete User Stories shall redefine both with project part definitions
(`subject :>> system : ...;`, `stakeholder :>> role : ...;`), subject first
(see §1.4.1). The same part definition shall type any `actor` usage that
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

A concrete story writes the redefinition as `stakeholder :>> role : Operator;`.

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
wants to do, see, or experience. The story writes it as
`attribute :>> capability = "...";`.

Where the capability has been elaborated in the behavioral model, a
separate `use case def` may declare this story as its `objective`. The
`capability` string is retained in all cases; it is the story's identity
for human readers.

### 1.4.3 `benefit` — mandatory

`benefit` is a string describing the "so that …" clause: the value the role
gains from the capability. The story writes it as
`attribute :>> benefit = "...";`.

Where the benefit has been formalised as a measurable outcome, the story
should additionally carry a nested requirement usage with a
`require constraint` over value properties (§5.4.2), which a verification
case can target by name. A benefit that cannot be reduced to a constraint
over a model element is permitted but flagged as informal.

### 1.4.4 `acceptance` — mandatory, at least one before `ready`

`acceptance` is a nested requirement usage inherited from `UserStory` and
redefined by the story: `requirement :>> acceptance { doc /* Given ... */ }`.
Several separately verifiable criteria nest inside the redefinition as named
requirement usages, each expressing one acceptance criterion in Given/When/Then
form (or an equivalent declarative form).

Acceptance criteria may be authored as text initially. Once test models
exist, a separate `verification def` (spec §8.2.2.23) declares an
`objective { verify <story>.acceptance; }` clause (or
`verify <story>.acceptance.<criterion>;`) naming what is to be verified. The
acceptance criterion remains a subrequirement of the story. The verification
case is a peer.

A User Story shall declare at least one acceptance criterion before being
marked `ready`.

### 1.4.5 Coupling `role` to an `actor` via use case `objective`

A User Story is a *requirement* (a requirement usage). A Use Case
is a *case* (a kind of `case def`, ultimately a kind of action). They are
different kinds and cannot be embedded in each other directly. The
SysML-v2-compliant way to connect a story to a use case that elaborates
its capability is via the use case's `objective` clause (spec §7.21.2):
the use case declares the story as the requirement its performance is
intended to satisfy.

```sysml
part def Operator;

requirement US_042_AckFromDashboard : UserStory {
    subject :>> system : Aiwell_OnlineSentral;
    stakeholder :>> role : Operator;

    attribute :>> capability = "acknowledge alarms from the dashboard";
    attribute :>> benefit    = "the queue clears quickly";
}

use case def AcknowledgeAlarms {
    subject sys : Aiwell_OnlineSentral;
    actor performer : Operator;

    objective realisesUS042 :> US_042_AckFromDashboard {
        subject :>> system = sys;
    }
}
```

The objective clause
`objective realisesUS042 :> US_042_AckFromDashboard { subject :>> system = sys; }`
subsets the story and binds the story's subject to the case subject. The
redefinition is required: a case already carries an objective subject, so an
objective that subsets a story without redefining `system` is refused by the
pilot (`Only one subject is allowed`). A case subject that does not conform
to the story's subject type is reported as
`Bound features should have conforming types`.

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

requirement US_042_AckFromDashboard : UserStory {
    subject :>> system : Aiwell_OnlineSentral;
    stakeholder :>> role : Operator;

    attribute :>> capability = "acknowledge alarms from the dashboard";
    attribute :>> benefit    = "the queue clears quickly";

    frame concern : OpsConcerns::FastIncidentResponse;

    requirement :>> acceptance { doc /* … */ }
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

Enumeration values are written qualified, as `priority = Priority::high;`
and `status = StoryStatus::ready;`.

## 1.6 Identifier Convention

User Stories shall be identified using the pattern
`US_<n>_<ShortName>`, where `<n>` is a zero-padded numeric identifier unique
within the project and `<ShortName>` is a concise CamelCase descriptor.

> Example: `US_042_AckFromDashboard`

The identifier is the usage name. An optional short name
(`requirement <'US-42'> US_042_AckFromDashboard : UserStory`) is display only
and is ignored by the tooling.

## 1.7 Authoring Patterns

### 1.7.1 Minimal form (text-only)

A User Story authored at backlog entry shall include the agile-canonical
members and at least one acceptance criterion. Typed bindings into the
behavioral or analytical model are not required at this stage.

```sysml
package <SS> Aiwell_StakeholderStories {
    private import Aiwell_Stakeholders::*;
    private import Aiwell_Concerns::*;
    private import Aiwell_OnlineSentralContext::*;
    private import VSE_Library::*;

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
requirement US_042_AckFromDashboard : UserStory {
    @StoryMeta { points = 5; status = StoryStatus::inProgress; }

    subject :>> system : Aiwell_OnlineSentral;
    stakeholder :>> role : Operator;

    attribute :>> capability = "acknowledge alarms from the dashboard";
    attribute :>> benefit    = "the queue clears quickly";

    frame concern : OpsConcerns::FastIncidentResponse;

    attribute maxAckLatency : Rational = 1.0;

    requirement sla {                             // subrequirement (§7.20.2)
        doc /* Acknowledgement completes within maxAckLatency seconds. */
        require constraint { maxAckLatency <= 1.0 }
    }

    requirement :>> acceptance {
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

    objective realisesUS042 :> US_042_AckFromDashboard {
        subject :>> system = sys;
    }
}
```

**The verification case verifying the acceptance criterion:**

```sysml
verification def VC_AckBatchTiming {
    subject sys : Aiwell_OnlineSentral;

    objective {
        verify US_042_AckFromDashboard.acceptance;
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

- is typed by (`:`) `UserStory`;
- redefines `subject` (`subject :>> system : ...;`) with the system or
  subsystem under specification;
- redefines `role` (`stakeholder :>> role : ...;`) with a project-specific
  part definition, alongside any additional `stakeholder` declarations;
- may `frame` one or more `concern def` instances representing the
  stakeholder needs the story addresses (spec §7.20.3);
- may declare nested requirement usages that formalise benefit constraints
  (spec §7.20.2);
- may be named as the `objective` of one or more `use case def` or
  `analysis def` by subsetting
  (`objective <n> :> <story> { subject :>> system = <caseSubject>; }`),
  whose performance is intended to satisfy the story (spec §7.21.2);
- may have its acceptance verified by a `verify <story>.acceptance` clause
  in the `objective` of one or more `verification def` (spec §8.2.2.23);
- may be the `#original` or `#derive` end of a `#derivation connection`
  (§5.4.1).

## 1.9 Well-Formedness Rules

The following rules apply to every User Story:

1. A User Story is a requirement usage typed by `UserStory`
   (`requirement <ID> : UserStory`), never a `requirement def`.
2. A User Story shall redefine exactly one `subject`
   (`subject :>> system : <PartDef>;`), declared before `role`.
3. A User Story shall redefine exactly one `role`
   (`stakeholder :>> role : <PartDef>;`) with a concrete part definition
   before transitioning out of `backlog` status.
4. A User Story shall declare at least one acceptance criterion, in
   `requirement :>> acceptance`, before transitioning to `ready` status.
5. Where a `use case def` declares a User Story as its `objective`, the
   objective subsets the story and binds the story's subject to the case
   subject:
   `objective <n> :> <story> { subject :>> system = <caseSubject>; }`.
   The case subject type shall conform to the story's subject type, and the
   actor representing the role shall be typed by the same part def as
   `role`.
6. The narrative `capability` and `benefit`
   (`attribute :>> capability = ...`) shall be retained throughout the
   story's lifecycle.
7. `verify` targets a member of the story usage by dot notation
   (`verify <story>.acceptance`), inside a `verification def` objective
   only.
8. A system story records its derivation with the `#derive` prefix on the
   usage and a `#derivation connection` whose ends are tagged `#original`
   and `#derive` (§5.4.1).
9. `StoryMeta` is applied with `@StoryMeta { ... }` and qualified
   enumeration values.
10. `satisfy <story> by <element>` names an element typed by the story's
    subject type or a specialisation of it.
11. A User Story shall not be typed by a Use Case, Action, Case, or any
    non-Requirement definition (spec §7.20, requirements specialise from the
    requirement-kind taxonomy only).

---

*End of Section 1.*
