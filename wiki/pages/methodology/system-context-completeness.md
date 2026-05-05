---
title: "System Context: actor categories, interfaces, and completeness checks"
slug: system-context-completeness
type: process
layer: methodology
tags: [system-context, actors, interfaces, item-flows, boundary, completeness]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §3 (System Context)."
    raw: methodology/03-system-context.md
related:
  - methodology-overview
  - base-architecture-corollaries
  - role-actor-coupling
  - stakeholder-stories-workflow
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, needs-and-requirements, architecture-design]
---

# System Context: actor categories, interfaces, and completeness checks

## Purpose

The System Context establishes the system boundary, identifies the external entities the system interacts with, and types the item flows that cross the boundary. It is the shared reference for every story's `subject`, for any `actor` typing in elaborated use cases, and for the interface set that downstream architectural work refines. The concept adapts SYSMOD §5.11 (Weilkiens, 2020) to native SysML 2.0 constructs: `part def` for the system and its actors, `interface def` for the connections, and `item def` together with item flows for what crosses the boundary. See [[methodology-overview]] for how System Context sits between Base Architecture and stakeholder stories.

## What the artefact owns

The System Context is a single `part def` (or `occurrence def`) that owns:

- the system part, typed by the project's system part def, possibly a Base Architecture specialisation per [[base-architecture-corollaries]],
- one part per external actor, classified into one of four categories,
- interface usages connecting actors to the system,
- item flows typing what is exchanged through each interface.

When a stakeholder asks "what does the system see, and what sees the system," the answer is rendered from this part.

## Actor categories

External actors are classified into one of four categories. The classification is a discipline that aids completeness checking, not a modelling constraint. Actors that resist clean categorisation are still actors.

| Category | Examples | Notes |
|---|---|---|
| Human actors | Operators, maintainers, supervisors, end users | Often overlap with stakeholders, see [[role-actor-coupling]] |
| External systems | Peer devices, IT infrastructure, upstream and downstream equipment | Modelled as their own `part def` even when not under project control |
| Environmental effects | Temperature, weather, vibration, electromagnetic fields | The system must respond to these but does not control them |
| Environmental impact | Atmosphere, neighbours, terrain | Entities the system affects beyond its functional purpose, relevant for sustainability and safety concerns |

## Workflow

Inputs are the Base Architecture and an initial stakeholder identification (see [[stakeholder-stories-workflow]]). Outputs are a System Context `part def`, an actor `part def` set, an `interface def` set, and an `item def` set for items that cross the boundary.

### Step 1: define the system part

Declare a `part def` for the system of interest. Where the project's system specialises a Base Architecture part def, the system part def specialises the Base Architecture part def. Where the system is allocated to a platform, the system part def is independent and the allocation is recorded separately.

### Step 2: identify external actors

For each of the four categories, enumerate the entities that interact with or affect the system. Declare a `part def` per actor. Actors used as stakeholders elsewhere shall reuse the same `part def`. There is one `Operator` type, used as a stakeholder in concerns and stories and as an actor in use cases and the System Context.

### Step 3: define interfaces and item flows

For each actor connected to the system, declare:

- the items that flow across the connection, as `item def` instances,
- the interface that carries those items, as an `interface def` whose ends are port usages,
- the flows themselves as `flow connection def` instances or as untyped `flow` connections inside the System Context where the interface ends are connected.

Where the item is rich enough to be modelled in its own right, declare an `item def`. Where it is a primitive value, the declared type may be a value type from the Base Architecture or a domain library.

### Step 4: compose the System Context part

Declare a single `part def` that owns the system and all actors as parts, with their interfaces wired up via `connect` clauses and item flows declared between the connected ports.

### Step 5: validate completeness

Before transitioning out of `inProgress`, the System Context shall satisfy three checks:

1. Every stakeholder that interacts with the system appears as an actor in the System Context.
2. Every interface declared at the system part has a connection to at least one actor, or is justified as a deferred interface in a documenting comment.
3. Every item flow has a declared item type. Untyped flows are prohibited.

Items and interfaces discovered later during System Requirements analysis extend the schema. The System Context is updated in place through a deliberate change event.

## SysML 2.0 example

```sysml
package <CTX> Aiwell_Context {
    private import Aiwell_BaseArchitecture::*;

    // System part, specialising a Base Architecture part def
    part def Aiwell_OnlineSentral :> AC5000_Platform {
        port operatorUI : OperatorUIPort;
        port deviceField : DeviceFieldPort;
        port weatherFeed : WeatherFeedPort;
    }

    // Actors, grouped by category in source comments
    // Human actors
    part def Operator;
    part def Maintainer;

    // External systems
    part def WeatherService;
    part def CentralSCADA;

    // Environmental effects
    part def AmbientWeather {
        attribute temperature : TemperatureValue;
        attribute precipitation : PrecipitationValue;
    }

    // Environmental impact
    part def DownstreamWatercourse;

    // Items that cross the boundary
    item def AlarmEvent {
        attribute id : AlarmId;
        attribute severity : Severity;
    }
    item def AcknowledgmentCommand;

    // Interface typing
    interface def OperatorUIInterface {
        end systemSide   : OperatorUIPort;
        end operatorSide : OperatorPort;
    }

    // Composite System Context part
    part def Aiwell_OnlineSentralContext {
        part system   : Aiwell_OnlineSentral;
        part operator : Operator;
        part weather  : WeatherService;
        part ambient  : AmbientWeather;

        interface uiLink : OperatorUIInterface
            connect system.operatorUI to operator.systemPort;

        flow of AlarmEvent
            from system.operatorUI.alarmsOut
            to   operator.systemPort.alarmsIn;
        flow of AcknowledgmentCommand
            from operator.systemPort.commandsOut
            to   system.operatorUI.commandsIn;
    }
}
```

## Well-formedness rules

1. The System Context shall declare exactly one system part. Multiple systems in scope require a System-of-Systems treatment, which is outside this methodology.
2. Every actor part def shall be classified into one of the four categories. The classification is recorded as metadata or in the part's documentation, as the project determines.
3. Every interface declared on the system part shall be connected to at least one actor in the System Context, or be marked as deferred with a documenting comment.
4. Every item flow shall declare an item type (an `item def` or a value type). Untyped flows are prohibited.
5. The same `part def` shall be used wherever an entity appears as a stakeholder (in concerns and stories) and as an actor (in use cases and the System Context). Distinct part defs for the same entity are prohibited. See [[role-actor-coupling]] for the rationale.

## Out of scope

The methodology assumes a single system of interest, so peer-system authority sharing is not addressed here. Internal behaviour of actors is the concern of those who own them, not of this artefact, so actors remain typed parts with ports and attributes only. Cybersecurity threat modelling at the boundary is introduced as concerns addressed by stories rather than as a System Context activity.
