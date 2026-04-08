---
name: sysml2-behaviour
description: Model SysML 2.0 behaviour: actions, successions, flows, messages, state machines, and model execution. Use when adding behavioural elements, succession graphs, or state machines to a model.
user-invocable: true
---

# SysML 2.0 Behaviour

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You guide the engineer through behavioural modelling in SysML 2.0.
This skill covers actions, parameters, successions and control nodes,
state machines and transitions, flows and messages, and the basics of
model execution. For project layout, tooling, and the full syntax
quick reference, route back to `@sysml2-modelling`. For case bodies
that orchestrate behaviour inside a use case, analysis case, or
verification case, route to `@sysml2-cases`.

## When This Skill Triggers

- The user asks to add an action, state, transition, or flow
- The user wants to compose behaviour with successions or control nodes
- The user asks about entry, do, or exit activities on a state
- The user asks about streaming flows, message passing, or action
  invocation inside a behavioural body
- The user asks how behaviour will execute at run time

## Core Vocabulary

| Element | Keyword | Purpose |
| --- | --- | --- |
| Action | `action def`, `action` | Specifies a behaviour as a unit of work |
| Parameter | `in item`, `out item`, `inout item` | Typed input and output of an action |
| Succession | `succession`, `then` | Ordering between actions |
| Control node | `decide`, `merge`, `fork`, `join` | Succession branching and synchronisation |
| State | `state def`, `state` | A condition of the subject that persists over time |
| Transition | `transition`, `first ... then ...` | Trigger-guarded change between states |
| Flow | `flow`, `stream` | Continuous item transfer between actions or parts |
| Message | `send`, `accept` | Discrete asynchronous interaction between parts |

## Authoring Patterns

### Action Definition with Typed Parameters

```sysml
action def MeasureTemperature {
    in item rawReading : Real;
    out item calibratedTemp : Real;

    action read : ReadSensor { in item = rawReading; }
    action calibrate : ApplyCalibration { out item = calibratedTemp; }

    succession read then calibrate;
}
```

Parameters use `in item` or `out item`. Successions order nested
actions. A `then` arrow reads "first this, then that".

### Control Nodes for Branching

```sysml
action def HandleAlert {
    action assess;
    decide alertLevel {
        if level > 80 then action emergency;
        else action warning;
    }
    action log;
    succession assess then alertLevel;
    succession (emergency, warning) then log;
}
```

Use `decide` for exclusive branches, `merge` to rejoin, `fork` to split
into concurrent flows, and `join` to synchronise. Parallel actions run
concurrently after a `fork` and resume sequential execution at the
matching `join`.

### State Machine with Transitions

```sysml
state def SensorStates {
    entry state idle;
    state measuring {
        entry action powerUp;
        do action sample;
        exit action powerDown;
    }
    state alerting;

    transition idle_to_measuring
        first idle then measuring
        if startMeasurement;

    transition measuring_to_alerting
        first measuring then alerting
        if thresholdExceeded;
}
```

`entry`, `do`, and `exit` attach activities to a state's lifecycle.
Transitions reference two states with `first ... then ...` and optionally
carry a guard after `if`.

### Flow Between Parts

```sysml
part def SensorSubsystem {
    part adc : ADC;
    part processor : Processor;
    flow of Real from adc.rawOut to processor.rawIn;
}
```

A plain `flow` is discrete. Use `stream flow` for continuous streaming
data. Flow endpoints are port features on the connected parts.

### Message Between Parts

```sysml
part def Controller {
    part sensor : Sensor;
    part actuator : Actuator;
    action reactToReading {
        accept reading : Reading from sensor;
        send command : Command to actuator;
    }
}
```

`accept` blocks until a matching message arrives. `send` dispatches a
typed payload to a receiver part. Message semantics are asynchronous by
default.

## Validation Checklist

1. **Action parameters are typed.** Untyped `item` parameters fail at
   model check time.
2. **Successions reference named steps.** A succession from an unnamed
   nested action is invalid.
3. **Transitions reference two states in the same owning state machine.**
   Cross-machine transitions require explicit specialisation.
4. **Entry and exit activities do not emit messages** unless the owning
   state explicitly allows them.
5. **Flows carry type-compatible items** at both ends.

## Red Flags

WARN the engineer if:

- An action body has steps without any succession ordering
- A state machine has an entry state but no transitions leaving it
- A transition has no trigger and no guard (always fires, usually a bug)
- A `stream flow` connects endpoints of mismatched item types
- A `send` action has no matching `accept` anywhere in the model

## Reference: SysML 2.0 Behaviour

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/sysml2-behaviour-ref.md`
