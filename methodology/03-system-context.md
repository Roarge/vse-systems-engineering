# 3. System Context

## 3.1 Purpose

This section specifies the *System Context* — the artefact that
establishes the system boundary, identifies the external entities the
system interacts with, and types the item flows that cross the
boundary. The System Context is the shared reference for every story's
`subject`, for any `actor` typing in elaborated use cases, and for the
interface set that downstream architectural work refines.

The concept is adopted from SYSMOD §5.11 (Weilkiens, 2020). The
SysML v2 expression is built from native constructs: `part def` for the
system and its actors, `interface def` for the connections (spec §7.14),
and `item def` / item flows for what crosses the boundary (spec §7.12).

## 3.2 Definition

The System Context is a SysML v2 `part def` (or `occurrence def`) that
owns:

- the system part (typed by the project's system part def, possibly a
  Base Architecture specialisation per §2);
- one part per external actor, classified into one of four categories
  (§3.2.1);
- interface usages connecting actors to the system;
- item flows typing what is exchanged through each interface.

The System Context part def is the canonical "context view" of the
project: when a stakeholder asks "what does the system see, and what
sees the system," the answer is rendered from this part.

### 3.2.1 Actor categories

External actors shall be classified into one of four categories
(adopted from SYSMOD §5.11):

| Category | Examples | Notes |
|---|---|---|
| Human actors | Operators, maintainers, supervisors, end users | Often overlap with stakeholders (§4) |
| External systems | Peer devices, IT infrastructure, upstream/downstream equipment | Modelled as their own `part def` even when not under project control |
| Environmental effects | Temperature, weather, vibration, electromagnetic fields | The system must respond to these but does not control them |
| Environmental impact | Atmosphere, neighbours, terrain | Entities the system affects beyond its functional purpose; relevant for sustainability and safety concerns |

The classification is a discipline, not a constraint. Actors that resist
clean categorisation are still actors; the categorisation aids
completeness checking rather than modelling validity.

## 3.3 Workflow

**Inputs:** Base Architecture (§2), initial stakeholder identification.

**Outputs:** a System Context `part def`, an actor `part def` set, an
`interface def` set, and an `item def` set for items that cross the
boundary.

### 3.3.1 Define the system part

Declare a `part def` for the system of interest. Where the project's
system specialises a Base Architecture part def, the system part def
specialises the Base Architecture part def per §2.3.3. Where the system
is allocated to a platform, the system part def is independent and the
allocation is recorded separately.

```sysml
package <CTX> Aiwell_Context {
    private import Aiwell_BaseArchitecture::*;

    part def Aiwell_OnlineSentral :> AC5000_Platform {
        port operatorUI : OperatorUIPort;
        port deviceField : DeviceFieldPort;
        port weatherFeed : WeatherFeedPort;
        /* … */
    }
}
```

### 3.3.2 Identify external actors

For each of the four categories (§3.2.1), enumerate the entities that
interact with or affect the system. Declare a `part def` per actor.
Actors used as stakeholders elsewhere (§4) shall reuse the same
`part def` — there is one `Operator` type, used as a stakeholder in
concerns and stories and as an actor in use cases and the System
Context.

```sysml
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
```

### 3.3.3 Define interfaces and item flows

For each actor connected to the system, declare:

- the items that flow across the connection, as `item def` instances;
- the interface that carries those items, as an `interface def` (spec
  §7.14) — the interface declares its ends as port usages;
- the flows themselves as `flow connection def` instances (spec §7.12)
  or as untyped `flow` connections inside the System Context where
  the interface ends are connected.

```sysml
item def AlarmEvent {
    attribute id : AlarmId;
    attribute severity : Severity;
    attribute timestamp : DateTime;
}
item def AcknowledgmentCommand;

interface def OperatorUIInterface {
    end systemSide   : OperatorUIPort;
    end operatorSide : OperatorPort;
}

// Flows are declared at the connection site (§3.3.4) using the item
// types declared above. Where multiple flows share a fixture, a
// flow connection def can be declared and reused:
flow connection def OperatorAlarmFlow {
    end producer : OperatorUIPort;
    end consumer : OperatorPort;
    item alarms  : AlarmEvent[*];
}
```

`flow` declares direction and item type at the point of connection (see
§3.3.4). Where the item is rich enough to be modelled in its own right,
declare an `item def`; where it is a primitive value, the declared type
may be a value type from the Base Architecture or domain library.

### 3.3.4 Compose the System Context part

Declare a single `part def` that owns the system and all actors as
parts, with their interfaces wired up via `connect` clauses (spec
§7.13).

```sysml
part def Aiwell_OnlineSentralContext {
    part system    : Aiwell_OnlineSentral;
    part operator  : Operator;
    part weather   : WeatherService;
    part scada     : CentralSCADA;
    part ambient   : AmbientWeather;

    interface uiLink : OperatorUIInterface
        connect system.operatorUI to operator.systemPort;

    interface weatherLink : WeatherFeedInterface
        connect system.weatherFeed to weather.outputPort;

    interface scadaLink : SCADAInterface
        connect system.scadaUplink to scada.northbound;

    // Item flows declared between the connected ports
    flow of AlarmEvent
        from system.operatorUI.alarmsOut
        to   operator.systemPort.alarmsIn;
    flow of AcknowledgmentCommand
        from operator.systemPort.commandsOut
        to   system.operatorUI.commandsIn;
}
```

The System Context part is what reviewers consult to answer "what is
inside the system, what is outside, and what crosses the boundary."

### 3.3.5 Validate completeness

Before transitioning out of `inProgress`, the System Context shall
satisfy:

- every actor in §4's stakeholder set that interacts with the system
  appears as an actor in the System Context;
- every interface declared at the system part has a connection to at
  least one actor (or is justified as a deferred interface in a doc
  comment);
- every item flow has a declared item type (no untyped flows).

Items and interfaces discovered later during §5 (System Requirements
analysis) extend the schema; the System Context is updated in place
with a deliberate change event (§2.7 lifecycle pattern applies).

## 3.4 Artefacts produced

- The system `part def` (or its declaration if specialising a Base
  Architecture part def).
- An actor `part def` set, classified by category.
- An `interface def` set with item flow typing.
- An `item def` set for items crossing the boundary.
- The System Context composite `part def`.

## 3.5 SysML v2 syntactic patterns

| Pattern | Form |
|---|---|
| System part | `part def SystemName :> BasePart { port … ; }` |
| Actor part | `part def ActorName { port … ; }` |
| Interface | `interface def Name { end <portName> : PortDef; … }` |
| Item | `item def Name { attribute … ; }` |
| Flow connection def (reusable) | `flow connection def Name { end … ; item … : ItemDef[<mult>]; }` |
| Flow at connection site | `flow of <ItemDef> from <part>.<port>.<feature> to <part>.<port>.<feature>;` |
| Context composition | `part def Context { part system : … ; part actor : … ; interface … connect … to … ; flow of … from … to …; }` |

## 3.6 Well-formedness rules

1. The System Context shall declare exactly one system part. Multiple
   systems in scope require a System-of-Systems treatment (out of
   scope for this methodology).
2. Every actor part def shall be classified into one of the four
   categories of §3.2.1. The classification is recorded as metadata or
   in the part's documentation (project-determined).
3. Every interface declared on the system part shall be connected to
   at least one actor in the System Context, or be marked as deferred
   with a documenting comment.
4. Every item flow shall declare an item type (item def or value
   type). Untyped flows are prohibited.
5. The same `part def` shall be used wherever an entity appears as a
   stakeholder (in concerns/stories) and as an actor (in use
   cases/System Context). Distinct part defs for the same entity are
   prohibited.

## 3.7 Out of scope

- System-of-systems contexts where multiple peer systems share
  authority. The methodology assumes a single system of interest.
- Detailed behaviour of actors. Actors are typed parts with ports and
  attributes; their internal behaviour is the concern of those who own
  them, not of this methodology.
- Cybersecurity threat modelling at the boundary. Threats are
  introduced as concerns (§4) addressed by stories (§4 / §5);
  enumerating them as a System Context activity is out of scope here.

---

*End of Section 3.*
