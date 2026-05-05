# 7. Architectural Design

## 7.1 Purpose

This section specifies the workflow for decomposing the resolved
architecture (§6) into subsystems, allocating system-level
specification to those subsystems, and propagating the
user-story-driven specification recursively to the subsystem scope.

The stage adapts the activities of Harmony aMBSE Chapter 7 (Douglass,
2016). The substantive shifts from the source:

- **Subsystem requirements are subsystem user stories**, authored
  recursively with §1's `UserStory` specialisation. Subsystem-level
  use cases, where used, declare subsystem stories as their
  `objective`.
- **Allocations use SysML v2 native `allocation`** (spec §7.15),
  not stereotype-based annotation.
- **Subsystem stories live inside the component folder** per §8.3.2,
  not in a flat subsystem-stories bucket.

## 7.2 Inputs and outputs

**Inputs:**

- Resolved architecture (§6) — a system part def with all variations
  resolved.
- System story register (§5).
- Logical data schema (§5).
- System Context (§3) — the boundary at which inter-subsystem
  interfaces emerge.

**Outputs:**

- Subsystem `part def` set (the decomposition).
- Allocation relationships from system stories / requirements / use
  cases to subsystems.
- Subsystem story register per component, residing in
  `core/logical-architecture/components/<component>/stories/`.
- Inter-subsystem `interface def` set, extending §3.
- Control law `constraint def` set for cross-subsystem control.
- Updated dependability concerns and stories at subsystem scope.
- Subsystem-scope verification cases.

## 7.3 Workflow

### 7.3.1 Identify subsystems

Decompose the resolved architecture into subsystems whose
responsibilities are coherent and whose internal coupling exceeds
their inter-subsystem coupling.

```sysml
package <LA> Aiwell_LogicalArchitecture {
    private import Aiwell_OnlineSentralContext::*;

    part def AlarmManagementSubsystem;
    part def DeviceFieldGatewaySubsystem;
    part def OperatorUISubsystem;
    part def DataPersistenceSubsystem;
    part def WeatherIngestionSubsystem;

    part def Aiwell_OnlineSentral_LogicalArchitecture
        :> Aiwell_OnlineSentral_v1 {
        part alarms     : AlarmManagementSubsystem;
        part fieldGw    : DeviceFieldGatewaySubsystem;
        part operatorUI : OperatorUISubsystem;
        part persistence : DataPersistenceSubsystem;
        part weatherIn  : WeatherIngestionSubsystem;

        // Inter-subsystem connections established in §7.3.4
    }
}
```

The decomposition is informed by:

- **Function grouping** — actions and use cases that share state and
  data should be allocated to the same subsystem.
- **Coupling considerations** — minimise inter-subsystem
  communication; maximise intra-subsystem cohesion.
- **Technology boundaries** — different runtime characteristics
  (real-time vs. soft, software vs. hardware) often imply subsystem
  boundaries.
- **Organisational boundaries** — different teams, vendors, or
  certification authorities argue for distinct subsystems.

### 7.3.2 Allocate system requirements to subsystems

For each `require constraint` in the system story register, allocate
it to the subsystem (or subsystems) that bears it. Three cases:

- **Single allocation** — the constraint is the responsibility of one
  subsystem.
- **Joint allocation** — the constraint is jointly the responsibility
  of multiple subsystems (e.g., end-to-end latency constraints).
- **Decomposition** — the constraint must be split into
  subsystem-level constraints whose conjunction implies the system
  constraint.

```sysml
package <ALLOC> Aiwell_RequirementAllocations {
    private import Aiwell_LogicalArchitecture::*;
    private import Aiwell_SystemStories::*;

    // Single allocation
    allocation alarmsBatchOwner
        allocate SYS_142_BatchAcknowledgement::sla
        to       Aiwell_OnlineSentral_LogicalArchitecture::alarms;

    // Joint allocation (latency budget shared)
    allocation latencyBudget1
        allocate SYS_142_BatchAcknowledgement::sla
        to       Aiwell_OnlineSentral_LogicalArchitecture::alarms;
    allocation latencyBudget2
        allocate SYS_142_BatchAcknowledgement::sla
        to       Aiwell_OnlineSentral_LogicalArchitecture::operatorUI;
}
```

Decomposition typically introduces *new* subsystem-level constraints
that derive from the system constraint:

```sysml
// Subsystem story decomposes the system constraint
package <ALARM_STORIES> AlarmManagementSubsystem_Stories {
    private import MBSEMethodology::UserStory;
    private import Aiwell_LogicalArchitecture::*;

    requirement def ALM_001_BatchCommit :> UserStory {
        subject sub : AlarmManagementSubsystem;
        stakeholder :>> role : OperatorUISubsystem;

        capability = "commit a batch of alarm acknowledgements
                      atomically and notify the persistence layer";
        benefit    = "the operator UI can report success within
                      its latency budget";

        attribute commitLatency : DurationValue;
        require constraint commitBudget {
            commitLatency <= 200 [ms]
        }
    }
}
```

The `OperatorUISubsystem` is the *role* in the subsystem story
because, at the subsystem boundary, it is the entity calling the
alarm-management subsystem.

### 7.3.3 Allocate stories and use cases to subsystems

Two approaches are valid:

**Top-down.** System stories are decomposed via `derive` into
subsystem-internal stories, each allocated to one subsystem. The
subsystem stories satisfy the system story when conjoined.

**Bottom-up.** The action defs and use cases that elaborate system
stories are allocated to subsystems first. Subsystem-level stories are
then *extracted* from the allocated behaviour.

```sysml
// Top-down example
#RequirementDerivation::derivation connection {
    end #RequirementDerivation::original
        ::> SYS_142_BatchAcknowledgement;
    end #RequirementDerivation::derive
        ::> ALM_001_BatchCommit;
    end #RequirementDerivation::derive
        ::> UI_017_BatchSelectionUX;
}
```

In general, a *system-level story is not allocated to a single
subsystem*. It is realised by collaboration. The subsystem stories
that derive from it together cover the system story.

### 7.3.4 Update logical data schema and define inter-subsystem interfaces

Items that previously crossed the system boundary may now also cross
*inter-subsystem* boundaries. Declare interfaces between subsystems
analogously to §3.3.3:

```sysml
package <IF> Aiwell_InterSubsystemInterfaces {
    private import Aiwell_LogicalDataSchema::*;

    interface def AlarmEventStream {
        end producer : AlarmProducerPort;
        end consumer : AlarmConsumerPort;
        flow events from producer to consumer : AlarmEvent[*];
    }

    interface def AcknowledgementCommands {
        end requester : AckRequesterPort;
        end committer : AckCommitterPort;
        flow requests  from requester to committer : AcknowledgementCommand[*];
        flow responses from committer to requester : AcknowledgementResult[*];
    }
}
```

The subsystem decomposition's `connect` clauses wire the interfaces:

```sysml
part def Aiwell_OnlineSentral_LogicalArchitecture
    :> Aiwell_OnlineSentral_v1 {
    /* parts as above */

    interface alarmFlow : AlarmEventStream
        connect alarms.outbound to operatorUI.alarmIngest;

    interface ackCommand : AcknowledgementCommands
        connect operatorUI.ackRequester to alarms.ackCommitter;
}
```

The logical data schema may need extension where subsystem-internal
items emerge that the system-level schema did not require.

### 7.3.5 Create or update subsystem user stories

For each subsystem, apply §1 recursively. The subsystem becomes the
new *system*; its sibling subsystems, the parent system, and external
actors local to the subsystem boundary become the candidate
stakeholder set; the subsystem's `part def` is the `subject` of its
stories.

```sysml
package <ALM_CON> AlarmManagementSubsystem_Concerns {
    private import Aiwell_LogicalArchitecture::*;
    private import Aiwell_Stakeholders::*;

    concern def AlarmDataIntegrity {
        subject sub : AlarmManagementSubsystem;
        stakeholder maint : Maintainer;
        require constraint {
            doc /* Acknowledged-state transitions shall be atomic and
                   durable. */
        }
    }
}

package <ALM_STR> AlarmManagementSubsystem_Stories {
    requirement def ALM_002_DurableAcknowledgement :> UserStory {
        subject sub : AlarmManagementSubsystem;
        stakeholder :>> role : OperatorUISubsystem;

        capability = "ensure acknowledged state survives subsystem
                      restart without loss or duplication";
        benefit    = "the operator does not see re-emerging
                      already-cleared alarms after restart";

        frame concern : AlarmDataIntegrity;

        requirement acceptance[1] {
            doc /* After kill -9 mid-commit, on restart, no alarm
                   shall be in an indeterminate state. */
        }
    }
}
```

Each subsystem is a system in its own right. The recursion of §1–§5
applies in its full generality: subsystem stakeholders, concerns,
stories, behavioural elaborations, verification cases.

### 7.3.6 Develop control laws

For control behaviour spanning multiple subsystems, declare
`constraint def` instances capturing the law and allocate to the
responsible subsystems. Single-subsystem control laws are deferred to
detailed design.

```sysml
package <CTRL> Aiwell_ControlLaws {
    constraint def AlarmIngestRateLimiting {
        attribute observedRate : RatePerSecond;
        attribute threshold    : RatePerSecond;
        observedRate < threshold * 1.2
    }

    allocation rateLimitOwner
        allocate AlarmIngestRateLimiting
        to       Aiwell_OnlineSentral_LogicalArchitecture::fieldGw,
                 Aiwell_OnlineSentral_LogicalArchitecture::alarms;
}
```

Control laws differ from acceptance criteria in scope: an acceptance
criterion verifies that a story is satisfied; a control law constrains
*ongoing behaviour* across subsystems regardless of any single
story's invocation.

### 7.3.7 Re-analyse dependability

Architectural decomposition introduces new failure modes (subsystem
boundaries are failure surfaces) and may eliminate others. Re-run §5.4.5
at subsystem granularity:

- new concerns: subsystem-boundary failures, inter-subsystem
  message loss, partial-failure modes;
- new stories: handling of these concerns by the responsible
  subsystem(s);
- new constraints: assertions on inter-subsystem interfaces.

### 7.3.8 Perform review

The §7 stage produces a model that should be reviewable against the
methodology's well-formedness rules (§7.5) and against the model's own
constraints (assertions, satisfy clauses). Where SysML v2 model
execution is available, exercise the verification cases against the
elaborated model.

Manual review remains valuable. The questions reviewers ask:

- Does every system story have at least one subsystem-story or
  subsystem-allocation derivation?
- Do the subsystem stories collectively cover the system story?
- Are inter-subsystem interfaces minimal? (Each interface is a cost.)
- Does the decomposition match the team and procurement structure?

## 7.4 SysML v2 syntactic patterns

| Pattern | Form | Spec ref |
|---|---|---|
| Subsystem part | `part def SubsystemName;` | §7.11 |
| Decomposition | `part def System :> Resolved { part sub1 : SubsystemA; … }` | §7.11 |
| Allocation | `allocation <name> allocate <source> to <target>;` | §7.15 |
| Inter-subsystem interface | `interface def Name { end … ; flow … ; }` | §7.14 |
| Connection wiring | `interface <name> : InterfaceDef connect <part>.<port> to <part>.<port>;` | §7.13 |
| Subsystem story | `requirement def NNN :> UserStory { subject sub : Subsystem; … }` | §1, §7.20 |
| Control law | `constraint def Name { attribute … ; <expr> }` allocated via `allocation` | §7.19 |

## 7.5 Well-formedness rules

1. Every system-level `require constraint` shall be either allocated
   to one or more subsystems, or decomposed into subsystem-level
   constraints whose conjunction implies it.
2. Every subsystem story shall declare its `subject` as a subsystem
   `part def`, not the system part def.
3. The recursive application of §1's well-formedness (§1.9) applies at
   subsystem scope. CI shall enforce it at every depth.
4. Every inter-subsystem `interface def` shall declare item types for
   all flows (per §3.6 rule 4, applied recursively).
5. A subsystem with no stories and no allocations is not part of the
   architecture and shall be removed. CI may flag orphan subsystems.
6. Where a control law spans subsystems, it shall be allocated to all
   subsystems whose behaviour is constrained by it; partial allocation
   is incorrect.

## 7.6 Recursion termination

A subsystem is *terminal* when no further decomposition is warranted
in the current iteration. Terminal subsystems have stories and
verification cases but no nested
`logical-architecture/components/<sub>/`.

A subsystem is *handed off* to detailed design when the project's
remit ends at the subsystem boundary. The handoff package contains
the subsystem specification (stories, interfaces, constraints); the
receiving discipline is responsible for further design. Handoff
boundaries are recorded as metadata or in CONTRIBUTING.md.

The methodology recurses as deep as decomposition warrants and stops
at terminal or handoff boundaries.

## 7.7 Out of scope

- Detailed design beyond subsystem boundaries (handed off to
  engineering disciplines per §0.9).
- Physical decomposition (`product-architecture/` per §8.3.1) — the
  methodology specifies *logical* decomposition; physical/product
  architecture is a downstream concern that may use this methodology's
  outputs as input.
- Implementation language and tooling within subsystems.
- Integration testing strategy (referenced from §5.4.6 verification
  cases at system level; subsystem-internal integration is handled
  recursively).

---

*End of Section 7.*
