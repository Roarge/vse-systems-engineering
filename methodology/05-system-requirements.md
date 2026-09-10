# 5. System Requirements Definition and Analysis

## 5.1 Purpose

This section specifies the workflow for translating stakeholder intent
into a *system-level* specification with verifiable behaviour. It
produces the system story register, the formalised system requirements
(constraints over value properties), the behavioural elaborations
necessary to make stories analysable, and the verification plan.

The stage adapts the activities of Harmony aMBSE Chapter 5 (Douglass,
2016) to a user-story-first approach. Where the source methodology
generates *system use cases* 1:1 from stakeholder use cases, this
methodology derives *system user stories* from stakeholder user
stories using SysML v2's `derive` relationship, and elaborates use
cases only where useful.

## 5.2 Inputs and outputs

**Inputs:**

- Stakeholder story register (§4)
- Concern register (§4)
- System Context (§3)
- Base Architecture (§2)

**Outputs:**

- System story register: story usages typed by `UserStory`, residing in
  `core/stories/system/`, each with `derive` links to one or more
  stakeholder stories.
- Behavioural elaborations per chosen analysis path:
  flow-based (`action def` with item flows), scenario-based
  (sequence-style analyses), or state-based (`state def`).
- Logical data schema — `item def` and flow types covering everything
  exchanged across the system boundary or appearing in story analyses.
- Dependability concerns and stories — safety, reliability, and
  security concerns introduced as additional `concern def` instances,
  each addressed by one or more new or extended stories.
- Verification plan — `verification def` instances (in
  `core/verification-validation/verification-cases/`) verifying system
  acceptance criteria.

## 5.3 The structure of system stories

A system story has the *same* `role` as the stakeholder story (or
stories) it derives from — the stakeholder is unchanged in the
transition from §4 to §5. What changes is:

- the `capability` is restated in *system-internal* vocabulary (the
  user's "I want to acknowledge alarms" becomes the system's "the
  system supports batch acknowledgement of unacknowledged alarms via
  the operator UI");
- the `benefit` is sharpened from narrative toward a `require
  constraint` over value properties of the system;
- additional system stories may emerge that no stakeholder story
  generated — particularly for fault management, self-test, regulatory
  reporting, and architectural maintenance.

The relationship to the stakeholder story is expressed via SysML v2's
`derive` (spec §9.6 — Requirement Derivation Domain Library). A
system story typically derives from exactly one stakeholder story, but
1:N (one stakeholder story spawning multiple system stories) and N:1
(multiple stakeholder stories converging on one system story) are
both legitimate.

What does *not* change in the transition from §4 to §5 is the
forward-going posture established in §2.1. The required output of
system requirements analysis is system stories that specify the
project's contribution layered onto the Base Architecture. A "system
story" that only restates a Base Architecture constraint already
captured in §2 (e.g., "the system shall use Modbus TCP") is not a
forward-going story — it is the Base Architecture restated in story
form. Such restatements are optional context, not required output:
the user may add them deliberately, but AI agents shall not auto-
generate them (per §2.6 rule 7). The system story register's
required content addresses what the project's system shall do
*given* the Base Architecture.

## 5.4 Workflow

### 5.4.1 Identify system stories

For each stakeholder story in scope for the iteration, derive one or
more system stories. The derivation is recorded using the
`RequirementDerivation` standard library (spec §9.6), with the
`DerivedRequirementMetadata` (short name `derive`) prefix on the derived
story usage (its base type is a usage, so it cannot annotate a
requirement definition) and a `#derivation connection` between the
original and the derived story, ends tagged `#original` and `#derive`.

```sysml
package <SYS> Aiwell_SystemStories {
    private import VSE_Library::*;
    private import Aiwell_StakeholderStories::*;
    private import Aiwell_Stakeholders::*;
    private import Aiwell_OnlineSentralContext::*;
    private import Aiwell_Concerns::*;
    private import ScalarValues::*;
    private import RequirementDerivation::*;

    #derive
    requirement SYS_142_BatchAcknowledgement : UserStory {
        @StoryMeta { points = 5; priority = Priority::high; status = StoryStatus::inProgress; }

        subject :>> system : Aiwell_OnlineSentral;
        stakeholder :>> role : Operator;

        attribute :>> capability = "process batch acknowledgement requests against a filtered alarm set, transitioning all matching alarms to acknowledged within a bounded time";
        attribute :>> benefit    = "operator queue clears within service-level time";

        frame concern : FastIncidentResponse;

        attribute maxBatchAckLatency : Rational = 1.0;

        // The connective mechanism (§0.3): a nested requirement usage
        // carrying the constraint, so a verification case can target it.
        requirement sla {
            doc /* Batch acknowledgement completes within maxBatchAckLatency seconds. */
            require constraint { maxBatchAckLatency <= 1.0 }
        }

        requirement :>> acceptance {
            doc /* p99 latency for batch acknowledgement
                   shall be at most 1 s for batch sizes up to N=200. */
        }
    }

    // Explicit derivation (spec §9.6.2). `#derivation` tags the connection
    // with DerivationMetadata; the ends are tagged `#original` and `#derive`.
    #derivation connection sys142Derives {
        end #original ::> US_042_AckFromDashboard;
        end #derive   ::> SYS_142_BatchAcknowledgement;
    }
}
```

The `#derive` prefix tags the derived story. The `#derivation connection`
records which original it derives from and shall be present, because the
prefix alone is not a trace.

Quantity-typed attributes (`ISQ::DurationValue` with `[s]`) need
`private import ISQ::*;` and `private import SI::*;`. The standard library
declares no `ms` or `us` unit, so a package that needs them declares them
(see the candidate-variants template).

### 5.4.2 Generate system requirements

Within each system story, formalise benefit and capability detail as
nested requirement usages, each carrying a `require constraint` over
value properties, so that a verification case can `verify <story>.<name>`
and a trade study can reference `<story>.<name>`. The story's attributes
declare the value properties. The constraints declare the relationships
those properties must satisfy. This is what makes the story usable as a
§6 trade-study criterion (§0.3).

```sysml
requirement SYS_143_AlarmFiltering : UserStory {
    subject :>> system : Aiwell_OnlineSentral;
    stakeholder :>> role : Operator;

    attribute :>> capability = "filter active alarm set by severity, source, acknowledgement state, and free-text match";
    attribute :>> benefit    = "operator finds the alarm of interest within bounded interaction count";

    frame concern : FastIncidentResponse;

    attribute maxClicksToTarget : Integer = 3;

    requirement findability {
        doc /* The operator shall reach any alarm within
               maxClicksToTarget interactions. */
        require constraint { maxClicksToTarget <= 3 }
    }

    requirement :>> acceptance {
        doc /* For any operator-described alarm in a 5000-alarm set,
               operator shall reach it in at most 3 UI interactions. */
    }
}
```

Stories whose benefit cannot reduce to a `require constraint` over
value properties remain valid but do not contribute to §6 trade
studies (per §0.3). This is a methodology pressure to formalise where
the architecture decision will need it.

System stories that emerge from regulatory, fault-management, or
self-test concerns are added at this stage. They typically derive from
*system-side* concerns (introduced in §5.4.5) rather than from
stakeholder stories.

### 5.4.3 Perform story analysis

For each system story whose capability warrants behavioural detail,
choose one of three analysis approaches. The approaches are
equivalent in outcome — each yields the action/event/state structure
and the item flows necessary to make the capability analysable. The
choice depends on the capability's character.

#### 5.4.3.1 Flow-based analysis

Used when the capability is *data-driven* — input items flow through
transformations to output items.

```sysml
action def AcknowledgeAlarmsAction {
    in alarmSet : AlarmEvent[*];
    in scope : AcknowledgementScope;
    out acknowledged : AlarmEvent[*];
    out rejected : AlarmEvent[*];

    action filterByScope : FilterAlarmsByScope {
        in :>> alarmSet;
        in :>> scope;
        out filtered : AlarmEvent[*];
    }

    action commit : CommitAcknowledgement {
        in alarms : AlarmEvent[*] = filterByScope.filtered;
        out :>> acknowledged;
        out :>> rejected;
    }
}
```

A use case may declare the system story as its `objective` and use
this action def as its body:

```sysml
use case def AcknowledgeAlarmsBatch {
    subject sys : Aiwell_OnlineSentral;
    actor performer : Operator;

    objective realisesSYS142 :> SYS_142_BatchAcknowledgement {
        subject :>> system = sys;
    }

    perform action acknowledgeAlarms : AcknowledgeAlarmsAction;
}
```

Scenarios are derived as paths through the action graph: a "happy
path" path includes all alarms in the scope being acknowledged; a
"rainy day" path includes some alarms rejected by the commit action.

#### 5.4.3.2 Scenario-based analysis

Used when the capability is *interaction-driven* — actor and system
exchange a sequence of stimuli and responses.

Scenarios are modelled as use cases whose body sequences the
interactions as performed actions:

```sysml
use case def AckScenario_Nominal {
    subject sys : Aiwell_OnlineSentral;
    actor opr : Operator;

    first start;
    then perform action act1 : OpFiltersAlarms;        // operator to system: filter
    then perform action act2 : SysShowsFilteredSet;    // system to operator: render
    then perform action act3 : OpSelectsAckAll;
    then perform action act4 : SysCommitsAcknowledgement;
    then perform action act5 : SysShowsClearedQueue;
    then done;
}
```

Scenarios are not exhaustive. Cover the nominal case and at least one
exception per stakeholder concern affected.

#### 5.4.3.3 State-based analysis

Used when the capability is *mode-driven* — the system's behaviour
depends on which state it is in, and stories cross state boundaries.

```sysml
state def OnlineSentralOperatingState {
    entry action onEntry;
    exit  action onExit;

    state nominal;
    state degraded;
    state offline;

    // Transitions are declared as TransitionUsages inside the state def.
    // The full SysML v2 transition form (spec §8.2.2.17) supports
    // accept-trigger, guard, and effect; the simplest form is shown:
    transition first nominal
        accept WatchdogFailureEvent
        then degraded;

    transition first degraded
        accept FieldBusFailureEvent
        then offline;

    transition first degraded
        accept RecoveryCompleteEvent
        then nominal;
}
```

Stories whose acceptance criteria depend on state (e.g., "in
degraded mode, alarms shall queue without loss") gain explicit
state references in their constraints.

Project-determined: where the project's tooling is known to support
the full transition syntax (`if <guard> ... do <effect> ...`), use it;
otherwise the simpler `first ... accept ... then ...` form above is
sufficient for behavioural specification at this stage.

#### 5.4.3.4 Choosing among approaches

| Capability character | Approach |
|---|---|
| Input-output transformation, batch processing | Flow-based |
| Multi-step actor-system dialogue | Scenario-based |
| Mode-dependent behaviour, fault handling | State-based |
| Combination of above | Multiple, kept consistent |

The three approaches are complementary, not exclusive. A complex
capability may benefit from all three — flow-based for the steady-
state transformation, scenario-based for the operator dialogue,
state-based for fault response. The story's `subject` and `acceptance`
remain the integration point; each analysis path elaborates a different
facet.

### 5.4.4 Create or update the logical data schema

The logical data schema is the set of `item def` declarations and
flow types that everything in §5 references. It extends the items
already declared in §3 (System Context).

```sysml
package <DOM> Aiwell_LogicalDataSchema {
    item def AlarmEvent {
        attribute id : AlarmId;
        attribute severity : Severity;
        attribute source : DeviceId;
        attribute timestamp : DateTime;
        attribute state : AlarmState;
    }

    enum def Severity { critical; high; medium; low; info; }
    enum def AlarmState { active; acknowledged; cleared; }

    item def AcknowledgementScope {
        attribute filter : AlarmFilter;
        attribute mode : ScopeMode;
    }
}
```

The schema is shared across all stories in scope for the iteration.
Items discovered during analysis (a new flow needed by a derived
behaviour) extend the schema and may require the System Context (§3)
to be updated in turn.

### 5.4.5 Dependability analysis

Safety, reliability, and security concerns are introduced as new
`concern def` instances with appropriate stakeholders (often
`Regulator`, `OperationsManager`, or a dedicated `SafetyOfficer` part
def). Each concern is addressed by one or more new or extended system
stories.

```sysml
concern def OperatorSafety {
    subject sys : Aiwell_OnlineSentral;
    stakeholder safety : SafetyOfficer;
    require constraint {
        doc /* No control surface shall actuate during maintenance
               mode without explicit acknowledgement. */
    }
}

requirement SYS_198_MaintenanceLockout : UserStory {
    subject :>> system : Aiwell_OnlineSentral;
    stakeholder :>> role : SafetyOfficer;

    attribute :>> capability = "lock out actuators while maintenance mode active, releasing only on positive acknowledgement";
    attribute :>> benefit    = "no inadvertent actuation during maintenance";

    frame concern : OperatorSafety;

    requirement :>> acceptance { doc /* … */ }
}
```

Hazard identification, fault tree analysis, and security threat
modelling are *sub-methodologies* with their own structure (out of
scope, §5.7). What this methodology specifies is *where their results
land*: as concerns and stories in the model, traceable through `derive`
and `frame concern`.

### 5.4.6 Create or update the verification plan

For each acceptance criterion in scope, declare a `verification def`
(spec §7.23) whose `objective` includes a `verify` clause naming the
member of the story usage by dot notation. Verification cases at this
level exercise *system internals*, distinct from §4 validation cases that
exercise stakeholder intent.

The `::` namespace form (`verify SYS_142_BatchAcknowledgement::sla`)
addresses a definition member, and both reference implementations refuse it
(`Must be an accessible feature (use dot notation for nesting)`).

```sysml
verification def VC_BatchAckLatency {
    subject sys : Aiwell_OnlineSentral;

    objective {
        verify SYS_142_BatchAcknowledgement.sla;
        verify SYS_142_BatchAcknowledgement.acceptance;
    }

    action setup {
        doc /* Load N=200 alarms with realistic distribution. */
    }
    action measure {
        doc /* Measure batch ack latency over 1000 trials. */
    }
    action evaluate {
        doc /* Pass iff p99 latency ≤ 1 s and zero alarms lost. */
    }
}
```

A verification case may verify multiple acceptance criteria where they
share a fixture; conversely, an acceptance criterion may be verified
by multiple cases when different conditions warrant it.

## 5.5 Recursive application at subsystem level

§5 applies recursively at subsystem level (§0.6.7 step 5). At
subsystem scope:

- "system" reads as "subsystem";
- the `subject` is the subsystem part def;
- the stakeholder set may include sibling subsystems and the parent
  system as well as external actors;
- the logical data schema extends the system-level schema with
  subsystem-internal items;
- verification cases are scoped to the subsystem.

The packages live inside the component folder per §8.3.2.

## 5.6 SysML v2 syntactic patterns

| Pattern | Form | Spec ref |
|---|---|---|
| System story | `requirement SYS_NNN_Short : UserStory { … }` | §1, §7.20 |
| Derive (annotation) | `#derive` prefix on the derived story usage | §9.6.3 |
| Derive (connection) | `#derivation connection <name> { end #original ::> Original; end #derive ::> Derived; }` | §9.6.2 |
| Story constraint | `requirement <name> { require constraint { <expr> } }` | §7.20.2 |
| Action def | `action def Name { in … ; out … ; action sub : … ; }` | §7.16 |
| State def | `state def Name { state … ; transition … then … accept … ; }` | §7.17 |
| Item def | `item def Name { attribute … ; }` | §7.12 |
| Verification case | `verification def Name { subject … ; objective { verify <story>.<member>; } action … ; }` | §7.23 |

## 5.7 Out of scope

- Hazard analysis sub-methodology (FMEA, FTA, STPA, etc.). The
  methodology specifies where outputs land; the analysis itself is
  separate.
- Security threat modelling (STRIDE, attack trees, etc.). Same.
- Reliability calculation (MTBF, availability budgets). Same.
- Verification case execution and reporting tooling.
- Choice of analysis approach. The §5.4.3.4 table is guidance, not a
  decision procedure.

---

*End of Section 5.*
