---
title: "SysML 2.0 State Machines: States, Transitions, and Behaviours"
slug: sysml2-state-machines
type: reference
layer: sysml2
summary: State machines model behaviour through persistent conditions (states)
tags: [states, transitions, state-machine, entry, do, exit, parallel-state, exhibit-state, communicating]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-06 release. MBSE4U. Chapter 28, pages 207 to 219."
    raw: sysmlv2.pdf
related:
  - sysml2-actions
  - sysml2-successions
  - sysml2-flows-and-messages
  - sysml2-behaviour-patterns
  - sysml2-actions-in-context
  - sysml2-actions-vs-states
confidence: high
created: 2026-05-04
updated: 2026-05-04
referenced_by: [sysml2-behaviour]
---

# SysML 2.0 State Machines

## Contents

- States and state definitions
- Transitions
- Entry, do, and exit behaviours
- Parallel states
- Exhibit states
- Communicating state machines
- See also

State machines model behaviour through persistent conditions
(states) and the rules that move the system from one state to
another (transitions). Unlike actions, which are transient events,
states represent conditions that may be active throughout the
lifetime of their owner or a subset of it.

## States and state definitions

States are occurrences that may be active throughout the lifetime
of their owner or a subset of it. Every state definition specialises
`State` from the standard library. State definitions may own
features, constraints, and other model elements (Ch 28, p 170).

```sysml
state def Idle {
    attribute statusCode : Integer;
}
```

States are persistent (they hold while active), whereas actions are
transient (they execute and complete). A single component can have
both states and actions. The state describes the condition the
component is in, and the action describes what the component is
doing right now.

## Transitions

Transitions connect states and declare the conditions under which
one state is exited and another is entered. The long form declares
the source state, a trigger, a guard condition, and an effect
action. The short form, inside a state body, is more concise
(Ch 28, p 172).

A transition is triggered by an event such as a message reception,
a timeout, or a change in a condition. The trigger is declared
after the `accept` keyword. A guard condition is a Boolean
expression that must be true for the transition to be taken. An
effect action specifies what happens as a result, and is an action
usage or a reference to one.

```sysml
transition off_to_starting
    first off
    accept TurnOnSignal
    if batteryOk
    do action powerUp : PowerUp
    then starting;
```

## Entry, do, and exit behaviours

A state may own three kinds of action sequences:

- **Entry actions** execute when the state is entered.
- **Do actions** execute while the state is active.
- **Exit actions** execute when the state is exited.

The corresponding keywords are `entry`, `do`, and `exit`
(Ch 28, pp 172 to 173).

```sysml
state def Charging {
    entry action openContactor;
    do    action monitorChargeRate;
    exit  action closeContactor;
}
```

Entry and exit actions complete before the state is fully active or
fully exited. Do actions run for as long as the state is active and
are interrupted (terminated) when the state is exited.

## Parallel states

A complex state can be marked with the keyword `parallel`. The
keyword marks the complex state itself, and it means that the
sub-states are not exclusive but characterise the component together,
like orthogonal aspects. Typically these parallel states are complex
themselves, elaborating on those aspects (Ch 28, p 213).

Because the sub-states hold at the same time, **it is forbidden to
model transitions between the sub-states of a parallel state**
(Ch 28, p 213).

```sysml
state flying parallel {
    entry action : TakeOff;
    do action {
        first start;
        then action performMission;
    }
    exit action : Land;

    state positioning {
        first start then stabilizing;
        state stabilizing;
            transition stabilizing then moving;
        state moving;
            transition moving then stabilizing;
    }
    state observing {
        first start then idle;
        state idle;
            transition idle then observing;
        state observing;
            transition observing then idle;
    }
}
```

The state `flying` is expanded into a parallel state with two complex
states, `positioning` and `observing`, which are orthogonal aspects
(Ch 28, pp 213 to 215, Figure 28.6).

## Exhibit states

Exhibit states are referential usages in the same way as perform
action usages, and their purpose is the same: to establish links
between the part tree of the system and its main state machine
(Ch 28, p 215).

Typically the root of the part tree exhibits (or owns) the root
state, and subparts then declare that they exhibit a certain
sub-state of that machine. Depending on how the modelled system
works, these may be parallel states, when every subpart operates in
parallel, or simple states, when parts are activated one by one
(Ch 28, p 215).

Exhibit states work exactly like perform actions, with the same
shorthand. The full form carries a name and a reference subsetting.
The short form gives the exhibited state immediately after the
`exhibit` keyword, and the exhibit state usage is then unnamed
(Ch 28, pp 215 to 216, Figure 28.8).

```sysml
part def Drone {
    port commPort;
    state droneStates : DroneStates;
    part navigationSystem {
        exhibit state navigation ::> droneStates.on.flying.positioning;
    }
    part observationSystem {
        exhibit droneStates.on.flying.observing;
    }
}
```

## Communicating state machines

The alternative to one exhibited machine is to assign a dedicated
state machine to each relevant part and handle their interactions
implicitly by sending items between components. No exhibit state
usage is needed (Ch 28, p 217).

```sysml
part def GroundStation {
    port commPort;
    state stationStates {
        ref part context :>> this : GroundStation;
        first start then standby;
        state standby;
            accept MissionStarted via context.commPort
            then tracking;
        state tracking;
            accept MissionTimeout via context.commPort
            then standby;
    }
}
part def DroneSystem {
    part drone : Drone;
    part groundStation : GroundStation;
    interface connect drone.commPort to groundStation.commPort;
}
```

`GroundStation` waits in `standby`, moves to `tracking` when it
accepts `MissionStarted` through its port, and returns on
`MissionTimeout`. These are the signals the drone's own machine
emits, and the interface in `DroneSystem` carries them to the ground
station's port. The two machines are independent and coordinate
entirely by messages, which is a typical pattern in distributed
systems (Ch 28, p 217).

Because a state is an action, everything about actions in a context
carries over. Each machine binds to its component by redefining
`this`, which is how it reaches that component's ports and features,
and the same two routes to a peer apply, so a trigger or effect can
travel through a port or directly to a named part. Routing through a
port is what lets each machine stay ignorant of who is on the other
end (Ch 28, p 218). See [[sysml2-actions-in-context]].

Which arrangement to choose? One exhibited machine suits parts that
move in lockstep, when the whole system's state should be visible in
a single view. Communicating machines suit genuinely autonomous
parts, designed and often operated independently, that coordinate
through well-defined signals. The communication style scales across
component and team boundaries, and the exhibited style is simpler to
read for a tightly coupled system (Ch 28, p 218).

## See also

- [[sysml2-actions]] for the action machinery that entry, do, and
  exit behaviours rely on.
- [[sysml2-actions-vs-states]] for deciding between a state machine
  and an action model in the first place.
- [[sysml2-actions-in-context]] for the context-access patterns a
  communicating machine relies on.
- [[sysml2-flows-and-messages]] for the messages that typically
  trigger transitions.
- [[sysml2-behaviour-patterns]] for VSE-scale patterns and gotchas.
