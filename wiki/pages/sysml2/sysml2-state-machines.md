---
title: "SysML 2.0 State Machines: States, Transitions, and Behaviours"
slug: sysml2-state-machines
type: reference
layer: sysml2
tags: [states, transitions, state-machine, entry, do, exit, parallel-state, exhibit-state]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 28, pages 170 to 176."
    raw: sysmlv2.pdf
related:
  - sysml2-actions
  - sysml2-successions
  - sysml2-flows-and-messages
  - sysml2-behaviour-patterns
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-behaviour]
---

# SysML 2.0 State Machines

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
both states and actions; the state describes the condition the
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

Complex state machines can include parallel regions, where multiple
states are active simultaneously. This is modelled with a parallel
state definition (Ch 28, p 174). Parallel states are useful for
modelling components that have orthogonal concerns, for example, a
vehicle that is in `Driving` and also in `RadioOn` simultaneously.

```sysml
state def VehicleState {
    parallel {
        state drivingState : DrivingMode;
        state infotainmentState : InfotainmentMode;
    }
}
```

Each parallel region transitions independently. Joining them
requires explicit coordination, typically through guards on
transitions in the consuming state.

## Exhibit states

An **exhibit state** is a state that is exhibited by a part or
system at a particular point in its lifecycle. Exhibit states are
declared using the `exhibit` keyword and model the visible state of
a component (Ch 28, p 176).

The exhibit-state mechanism distinguishes the part's intrinsic
state from the publicly observable state. A part may transition
through several internal states while exhibiting only one of them
to its environment.

## See also

- [[sysml2-actions]] for the action machinery that entry, do, and
  exit behaviours rely on.
- [[sysml2-flows-and-messages]] for the messages that typically
  trigger transitions.
- [[sysml2-behaviour-patterns]] for VSE-scale patterns and gotchas.
