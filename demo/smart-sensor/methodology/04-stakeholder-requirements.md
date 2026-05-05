# 4. Stakeholder Requirements Engineering

## 4.1 Purpose

This section specifies the workflow for capturing stakeholder intent as
the methodology's first user-story-driven workflow stage. It produces
the *stakeholder story register* — the set of `UserStory`
specialisations that anchors every downstream requirement chain — along
with the supporting concern and validation artefacts.

The stage adapts the activities of Harmony aMBSE Chapter 4 (Douglass,
2016) to a user-story-first approach. Stakeholder use cases are
demoted from primary requirement carriers to *optional* elaborations
introduced via §1.4.5 (use case as the story's enabling case, with the
story as the use case's `objective`).

## 4.2 Inputs and outputs

**Inputs:**

- Base Architecture (§2)
- System Context (§3)
- Project charter / problem statement (project-determined; outside the
  formal model)

**Outputs:**

- Stakeholder taxonomy — `part def` instances representing stakeholder
  roles, residing in `core/stakeholders/`.
- Stakeholder concern register — `concern def` instances residing in
  `core/concerns/`.
- Stakeholder story register — `UserStory` specialisations residing in
  `core/stories/stakeholder/`.
- Use case set (optional) — `use case def` instances elaborating
  capability where useful, residing in `core/use-cases/`. Each such use
  case declares a stakeholder story as its `objective`.
- Validation case set — `verification def` instances exercising
  stakeholder intent (rather than system internals), residing in
  `core/verification-validation/validation-cases/`.

## 4.3 Workflow

### 4.3.1 Identify stakeholders

Enumerate the entities — human, organisational, regulatory — that have
concerns about the system. Sources include the project charter,
historical projects in the same domain, applicable regulations, and
the §3 System Context's human-actor and external-system categories.

For each stakeholder, declare a `part def` in `core/stakeholders/`. The
same part def shall be used wherever the stakeholder appears as an
actor in §3 and §5 (per §3.6 rule 5).

```sysml
package <SH> Aiwell_Stakeholders {
    part def Operator;
    part def Maintainer;
    part def OperationsManager;
    part def Regulator;
    part def Procurement;
    part def InstallationContractor;
}
```

Stakeholders may be active (interact with the system, e.g., Operator)
or passive (do not interact but have concerns, e.g., Regulator).

### 4.3.2 Capture stakeholder concerns

For each stakeholder, declare one or more `concern def` instances
expressing what the stakeholder cares about, fears, or requires
(spec §7.20.3). A concern is a kind of requirement that captures
stakeholder need at an abstract level, persists across iterations, and
may be addressed by multiple stories.

```sysml
package <CN> Aiwell_Concerns {
    private import Aiwell_Stakeholders::*;
    private import Aiwell_OnlineSentralContext::*;

    concern def FastIncidentResponse {
        subject sys : Aiwell_OnlineSentral;
        stakeholder ops : OperationsManager;
        require constraint {
            doc /* Operations require time-to-acknowledge below
                   contractual SLA. */
        }
    }

    concern def MaintainabilityOfFieldDevices {
        subject sys : Aiwell_OnlineSentral;
        stakeholder maint : Maintainer;
        require constraint {
            doc /* Field maintenance shall be performable
                   without specialised diagnostic equipment. */
        }
    }

    concern def RegulatoryReportability {
        subject sys : Aiwell_OnlineSentral;
        stakeholder reg : Regulator;
        require constraint {
            doc /* Operational events shall be logged in an
                   auditor-readable form for at least 5 years. */
        }
    }
}
```

Concerns are declared *first* and updated *last* — they outlive
individual stories. A concern register that grows during a project is
healthy; a register that churns suggests stakeholder elicitation is
incomplete.

### 4.3.3 Identify and prioritise capability themes

For each concern, identify the capability themes through which the
concern can be addressed. A capability theme is a candidate cluster of
stories — not yet a story, but the seed for one or more.

Capability themes are prioritised by:

- **Importance** — how strongly the addressed concern matters to its
  stakeholder.
- **Urgency** — whether the capability is needed early in the project.
- **Project risk** — whether the capability touches uncertain
  technology or domain knowledge.
- **Information availability** — whether the team can author the
  story now, or must wait for stakeholder access.

Prioritisation is recorded as `StoryMeta.priority` on the resulting
stories (§1.5). Themes are not modelled as their own SysML elements;
they are working notes captured in PR descriptions or sandbox files.

### 4.3.4 Generate stakeholder user stories

For each prioritised capability theme, author one or more `UserStory`
specialisations per §1. Stories enter the model in §1.7.1 minimal form
and progress through the lifecycle as detail emerges.

A stakeholder story:

- declares its `subject` referencing a part def from §2 (Base
  Architecture) or §3 (System Context), typically the project's system
  part def;
- redefines `role` with a part def from `core/stakeholders/`;
- declares `capability` and `benefit` as narrative strings;
- frames one or more concerns from `core/concerns/` (§1.4.6);
- declares at least one `acceptance` subrequirement before transitioning
  to `ready` (§1.9 rule 3).

```sysml
package <SS> Aiwell_StakeholderStories {
    private import Aiwell_Stakeholders::*;
    private import Aiwell_Concerns::*;
    private import Aiwell_OnlineSentralContext::*;
    private import MBSEMethodology::UserStory;

    requirement def US_042_AckFromDashboard :> UserStory {
        @StoryMeta { points = 5; priority = high; status = ready; }

        subject sys : Aiwell_OnlineSentral;
        stakeholder :>> role : Operator;

        capability = "acknowledge alarms from the dashboard";
        benefit    = "the queue clears without opening each device";

        frame concern : FastIncidentResponse;

        requirement acceptance[1] {
            doc /* Given N unacknowledged alarms shown,
                   when the operator selects "Ack all",
                   then all N transition to acknowledged within 1 s. */
        }
    }
}
```

### 4.3.5 Elaborate story scenarios via use cases (optional)

Where a story's capability is non-trivial, declare a `use case def`
that names the story as its `objective` per §1.4.5. The use case
carries scenario detail (action body, sub-actions, exception flows);
the story remains the carrier of stakeholder intent.

```sysml
package <UC> Aiwell_UseCases {
    use case def AcknowledgeAlarms {
        subject sys : Aiwell_OnlineSentral;
        actor performer : Operator;

        objective realisesUS042 : Aiwell_StakeholderStories::US_042_AckFromDashboard;

        // Action body: detail the steps of the use case
        first start;
        action filter alarms;
        action select scope;
        action confirm acknowledgement;
        then done;
    }
}
```

Use case elaboration is permitted at the stakeholder level but not
required. Many stakeholder stories never warrant a use case; their
`capability` strings and `acceptance` criteria are sufficient. Use
cases are most useful when a capability spans many actor interactions
(e.g., "configure system" or "respond to incident") and the
acceptance criteria alone cannot capture the flow.

### 4.3.6 Create or update the validation plan

For each acceptance criterion in scope, declare a `verification def`
(spec §7.23) whose `objective` includes a `verify` clause naming the
acceptance subrequirement. Validation cases — those that exercise
stakeholder intent rather than system internals — reside in
`core/verification-validation/validation-cases/`.

```sysml
package <VAL> Aiwell_ValidationCases {
    private import Aiwell_StakeholderStories::*;
    private import Aiwell_OnlineSentralContext::*;

    verification def VAL_AckFromDashboard {
        subject sys : Aiwell_OnlineSentral;

        objective {
            verify US_042_AckFromDashboard::acceptance;
        }

        // Verification action body
        action collectData {
            doc /* Capture acknowledgement latencies under realistic
                   alarm load on representative hardware. */
        }
        action evaluate {
            doc /* Pass iff p99 latency < 1 s for the captured
                   sample. */
        }
    }
}
```

The validation plan is the union of these verification defs. Where
multiple acceptance criteria require the same fixture, a single
verification def may verify several criteria.

## 4.4 Recursive application at subsystem level

When the methodology is applied recursively at subsystem level (per
§0.6.7 step 5), §4 applies as written with substitutions:

- "system" reads as "subsystem";
- "stakeholders" includes sibling subsystems, the parent system, and
  external actors local to the subsystem boundary;
- "Base Architecture" inherits from the system level, optionally
  refined for subsystem-specific platform concerns;
- "System Context" becomes the subsystem's view of its environment.

The packages live inside the component folder per §8.3.2.

## 4.5 SysML v2 syntactic patterns

| Pattern | Form | Spec ref |
|---|---|---|
| Stakeholder part | `part def StakeholderName;` | §7.11 |
| Concern | `concern def Name { subject … ; stakeholder … ; require constraint … }` | §7.20.3 |
| Story (per §1) | `requirement def US_NNN :> UserStory { … }` | §1, §7.20.2 |
| Frame concern | `frame concern : ConcernPath::ConcernName;` | §7.20.3 |
| Use case with story as objective | `use case def Name { … objective <name> : StoryName; }` | §7.21, §7.24 |
| Validation case | `verification def VAL_Name { subject … ; objective { verify <accept>; } }` | §7.23 |

## 4.6 Well-formedness rules

1. Every stakeholder story shall frame at least one concern, or
   carry a documenting comment explaining why no concern is yet
   modelled. (Stories that never frame a concern are unrooted.)
2. Every concern shall have at least one framing story before §6
   (Architectural Analysis) begins, or be marked as
   `informational-only` via metadata. A concern with no framing story
   is an unmet stakeholder need.
3. The same `part def` shall be used to type a stakeholder in
   `core/stakeholders/` and as the corresponding human actor in §3
   System Context.
4. Where a use case declares a stakeholder story as its `objective`,
   the use case's `subject` shall conform to the story's `subject`
   type and the use case's `actor` representing the story's role
   shall be typed by the same part def as the story's `role`
   (§1.9 rule 5).
5. Validation cases (those in `validation-cases/`) shall verify
   acceptance criteria that exercise stakeholder intent, not system
   internals. Verification of system internals belongs to §5's
   verification cases. The boundary is methodology discipline rather
   than syntactic.
6. The required output of stakeholder requirements engineering is
   forward-going stories — those describing what the project shall
   *add* to the existing technical context (Base Architecture, parent
   products, customer infrastructure). Context stories that record
   narrative around pre-existing decisions are optional human
   additions per §2.1 corollary 2; the methodology neither requires
   nor forbids them when added by deliberate human choice, and AI
   agents shall not synthesise them (per §2.6 rule 7). A stakeholder
   concern *informed by* a Base Architecture constraint is legitimate
   and addressed by forward-going stories; the Base Architecture is
   the constraint, not the subject.

## 4.7 Iteration discipline

§4 is performed on a *prioritised subset* of stakeholders, concerns,
and capability themes per iteration. The iteration's scope is recorded
in the PR description (§8.6.1). Stakeholders not yet engaged remain on
the backlog without `concern def` instances; capability themes not
yet authored remain as planning notes.

A useful iteration pattern is:

- iteration *n*: capture stakeholder *X*'s primary concerns;
  generate two or three highest-priority stories per concern;
- iteration *n+1*: derive system stories from those stakeholder
  stories (§5);
- iteration *n+2*: capture stakeholder *Y* in parallel with §5 work
  on stakeholder *X*'s stories.

The story register is the cross-iteration index; stale stories
(those whose `StoryMeta.status` has not changed in N iterations) are
candidates for review or culling.

## 4.8 Out of scope

- Stakeholder identification methodology (interviews, workshops,
  ethnography). Modelling captures *the result* of identification, not
  the identification process.
- Concern elicitation methodology. Same separation applies.
- Prioritisation algorithm. The four factors of §4.3.3 are inputs to
  human judgement, not a formula.
- Validation case execution and reporting. The verification defs
  declare *what* shall be validated; *how* and *when* is project-
  determined.

---

*End of Section 4.*
