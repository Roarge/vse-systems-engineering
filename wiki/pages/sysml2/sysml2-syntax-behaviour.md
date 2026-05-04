---
title: "SysML 2.0 Syntax: Actions and States"
slug: sysml2-syntax-behaviour
type: reference
layer: sysml2
tags: [syntax, action, state, control-node, transition, perform, send, accept, loop]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Sections 7.16, 7.17."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-syntax-packages-and-definitions
  - sysml2-syntax-structure
  - sysml2-actions
  - sysml2-state-machines
  - sysml2-special-action-usages
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Syntax: Actions and States

Cheat sheet for behavioural modelling syntax. For the conceptual
material, see [[sysml2-actions]], [[sysml2-state-machines]], and
[[sysml2-special-action-usages]].

## Actions (7.16)

```sysml
action def TakePicture {
    in scene : Scene;
    out picture : Picture;

    action focus : Focus {
        in scene = TakePicture::scene;
        out image;
    }
    action shoot : Shoot {
        in image = focus.image;
        out picture;
    }

    // Succession (ordering)
    first start then focus;
    then shoot;
    then done;

    // Flow
    flow focus.image to shoot.image;
}
```

## Control nodes

```sysml
action def ProcessFlow {
    action prepare;
    action taskA;
    action taskB;
    action finalise;

    first start then prepare;

    // Fork (parallel split)
    fork afterPrepare;
    first prepare then afterPrepare;
    then taskA;
    then taskB;

    // Join (synchronise)
    join beforeFinalise;
    first taskA then beforeFinalise;
    first taskB then beforeFinalise;
    then finalise;

    // Decide (conditional branch)
    decide decision1;
    if isReady then taskA;
    if not isReady then taskB;

    // Merge (rejoin branches)
    merge merge1;
}
```

## Send, accept, perform

```sysml
// Perform (reference an externally defined action)
perform action powerVehicle references VehicleActions::providePower;

// Send (transmit a value)
send reading via monitor to destination;

// Accept (receive a value)
accept sensorReading : SensorReading via controller;

// Accept triggers
accept when level > threshold;     // change trigger
accept at scheduledTime;           // time trigger
accept after 30 [s];               // relative time trigger
```

## Assignment

```sysml
assign vehicle.position :=
    vehicle.position + vehicle.velocity * deltaT;
```

## Conditional and loop actions

```sysml
// If/else
if speed < lowerLimit
    action increase : IncreaseSpeed;
else
    action maintain : MaintainSpeed;

// While loop
while not ready {
    assign ready := poll(device);
}

// Do-until loop
loop {
    action charge : ChargeBattery;
} until charge >= 100;

// For loop
for power : PowerValue in powerProfile {
    action regulate : RegulatePower;
}
```

## States (7.17)

```sysml
state def VehicleStates {
    entry action startup : StartUp;
    do action monitor : Monitor;
    exit action shutdown : ShutDown;

    state off;
    state starting;
    state on;

    // Transition (long form)
    transition off_to_starting
        first off
        accept TurnOnSignal
        if batteryOk
        do action powerUp : PowerUp
        then starting;

    // Transition (shorthand within state body)
    state starting {
        then on;
    }
}
```

### Parallel states

```sysml
state def VehicleStates parallel {
    state operationalStates : OperationalStates;
    state healthStates : HealthStates;
}
```

### Exhibit states

```sysml
part def Vehicle {
    exhibit state vehicleStates : VehicleStates;
}
```

## See also

- [[sysml2-actions]] for action semantics.
- [[sysml2-state-machines]] for state and transition semantics.
- [[sysml2-special-action-usages]] for the standard library
  actions (assignment, send, accept, terminate, if, loop).
- [[sysml2-syntax-requirements-and-cases]] for calc and constraint
  syntax that often appears in action bodies.
