---
title: "SysML 2.0 Syntax: Items, Parts, Ports, Connections, Interfaces, Allocations"
slug: sysml2-syntax-structure
type: reference
layer: sysml2
tags: [syntax, items, parts, ports, connections, interfaces, allocations, flows, messages]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Sections 7.10 to 7.15."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-syntax-packages-and-definitions
  - sysml2-syntax-features-and-attributes
  - sysml2-allocations-overview
  - sysml2-binding-connectors
  - sysml2-flows-and-messages
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Syntax: Items, Parts, Ports, Connections, Interfaces, Allocations

Cheat sheet for the structural modelling vocabulary.

## Items (7.10)

Items model things that are not necessarily parts of a structure
(flowing material, signals, data).

```sysml
item def Fuel;
item def ControlSignal;
```

## Parts (7.11)

```sysml
part def Vehicle {
    ref part driver[0..1] : Person;
    part engine : Engine;
    part wheels[4] : Wheel;
    part transmission : Transmission;
}

part vehicle1 : Vehicle;
```

## Ports (7.12)

```sysml
port def FuelingPort {
    attribute flowRate : Real;
    out item fuelOut : Fuel;
    in item fuelReturn : Fuel;
}

part def Vehicle {
    port fuelPort : FuelingPort;
}

// Conjugated port (directions reversed)
port def FuelSupplyPort :> FuelingPort;
port conjugatedPort : ~FuelSupplyPort;
```

Directed features on ports: `in`, `out`, `inout`.

## Connections (7.13)

```sysml
// Connection definition with typed ends
connection def DeviceConnection {
    end part hub : Hub[1];
    end part devices : Device[0..*];
    attribute bandwidth : Real;
}

// Connection usage
connection c : DeviceConnection
    connect hub ::> mainSwitch to device ::> sensorFeed;

// Shorthand (anonymous, untyped)
connect leftWheel to leftHalfAxle;
```

### Binding connectors

```sysml
// Bind (asserts two features always have the same value)
bind fuelTank.fuelFlowOut = engine.fuelFlowIn;
```

For full binding-connector semantics, see
[[sysml2-binding-connectors]] (new in the 2026-04 release).

### Flows

```sysml
// Item flow
flow fuelFlow of Fuel from fuelTank.fuelOut to engine.fuelIn;

// Succession flow (ordered in time)
succession flow focus.image to shoot.image;
```

### Messages

```sysml
// Message (item transferred between ports/parts)
message of ControlSignal from controller.cmdPort to engine.ctrlPort;
```

For the conceptual frame on flows and messages, see
[[sysml2-flows-and-messages]].

## Interfaces (7.14)

```sysml
interface def FuelingInterface {
    end port supplier : FuelSupplyPort;
    end port receiver : FuelingPort;
}

interface fuelLine : FuelingInterface
    connect fuelTank.fuelingPort to engine.fuelingPort;
```

## Allocations (7.15)

```sysml
allocation def LogicalToPhysical {
    end part logical : LogicalComponent;
    end part physical : PhysicalDevice;
}

allocate logicUnit to processorBoard;
```

For full allocation semantics, definitions, and patterns, see
[[sysml2-allocations-overview]].

## See also

- [[sysml2-syntax-packages-and-definitions]] for top-level
  packaging and `def` syntax.
- [[sysml2-syntax-behaviour]] for action and state syntax.
- [[sysml2-allocations-overview]] for allocation semantics.
- [[sysml2-binding-connectors]] for the new 2026-04 binding
  connector chapter.
