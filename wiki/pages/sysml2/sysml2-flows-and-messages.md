---
title: "SysML 2.0 Flows and Messages"
slug: sysml2-flows-and-messages
type: reference
layer: sysml2
summary: Transferring items, signals, and values between behavioural elements with flows and messages
tags: [flows, messages, ports, streaming-flow, succession-flow, event-occurrence]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-06 release. MBSE4U. Chapter 29, pages 220 to 232."
    raw: sysmlv2.pdf
related:
  - sysml2-actions
  - sysml2-special-action-usages
  - sysml2-state-machines
  - sysml2-event-occurrences
confidence: high
created: 2026-05-04
updated: 2026-05-04
referenced_by: [sysml2-behaviour]
---

# SysML 2.0 Flows and Messages

## Contents

- Flow definitions and the three flow usage kinds
- Messages
- Streaming flows
- Succession flows
- Choosing between flows and send/accept
- See also

A flow specifies a transfer of a payload between occurrences, for
example between parts or between actions. The same flow model element
serves structural and behavioural modelling, which is one of the ways
SysML 2.0 keeps structure and behaviour integrated
(Ch 29, p 220).

## Flow definitions and the three flow usage kinds

The flow model element is both a relationship and an action. It is a
behaviour that receives the value from the source end of the flow,
transfers it, and delivers it at the target end. The payload can be
anything, but in most cases it is an item, because items represent
the entities a system operates on (Ch 29, p 220).

A **flow definition** specifies exactly one source occurrence and one
target occurrence. An **abstract** flow definition may skip the
definition of a source or a target, which a specialised flow supplies
later. The payload is defined by `Anything` with multiplicity `[1..*]`
and can be constrained further, for example by giving it a specific
definition or a different multiplicity. The payload is referenced,
because it is independent of the existence of the flow
(Ch 29, pp 220 to 221).

```sysml
abstract flow def HeatFlow {
    ref item heat : Heat :>> payload;
}
flow def HeatInterfaceFlow :> HeatFlow {
    end heatPortSource : HeatPort;
    end heatPortTarget : HeatPort;
}
port def HeatPort {
    out item heat : Heat;
}
item def Heat {
    attribute heatEnergy :> ISQ::heat;
}
```

The item `heat` redefines the `payload` item that the standard
library implicitly adds to the flow definition. Only the definitions
of the ends are given here. The first end is the source and the
second is the target, and the specific features that serve as source
and destination are determined when a flow usage is modelled
(Ch 29, p 221).

There are exactly three kinds of flow usage for a flow definition
(Ch 29, p 221).

| Kind | Abstract? | What it specifies |
|---|---|---|
| `message` | Always abstract, because it is incomplete | The interaction of the connected ends by exchanging payloads, but not how the payload is transferred |
| `flow` (streaming flow) | Concrete | The actual source and target features of the transfer |
| `succession flow` | Concrete | A streaming flow combined with a succession |

## Messages

The ends of a message are **event occurrences** representing the send
and receive events. The source event initiates the payload transfer
and the target event represents the reception, and each happens at a
specific point in space and time (Ch 29, p 221). See
[[sysml2-event-occurrences]].

```sysml
part def DroneSystem :> CommonUAVSystem {
    event occurrence msgHeatReceive;
    event occurrence msgLightReceive;
    event occurrence msgHumidityReceive;
}
```

A message can be declared three ways (Ch 29, p 223, Figure 29.3).

```sysml
part def DroneSystemContext :> CommonUAVSystemContext {
    part droneSystem : DroneSystem :>> uavSystem;
    part environment : Actors::Environment :>> environment;

    message lightExchange of Light
      from environment.msgLightSend
      to droneSystem.msgLightReceive;
    message humidityExchange
      from environment.msgHumiditySend
      to droneSystem.msgHumidityReceive;
    message heatExchange : HeatFlow
      from environment.msgHeatSend
      to droneSystem.msgHeatReceive;
}
```

- `of` names the payload type.
- Omitting `of` leaves the payload as anything, informally defined by
  the message's name.
- Typing the message by a flow definition takes the payload from that
  definition. A flow definition used to define a message **must be
  abstract and have no flow ends**.

All three are abstract. They specify that something is flowing but
not how, and the payloads are picked up somewhere in the environment
without the exact location being specified (Ch 29, p 223).

### Message pitfall

A message can be modelled directly between parts, with no event
occurrences (Ch 29, p 224).

```sysml
part def DroneSystemContext {
    part droneSystem;
    part environment;
    message of HeatEnergy from environment to droneSystem;
}
item def HeatEnergy;
```

The syntax is valid, but the semantics likely diverge from the
intended behaviour. Parts are occurrences too, and the start and end
of their existence are events. This model therefore specifies that
the payload transfer occurs when the source part **ends**, and that
the message is received when the target element is **created**.
Neither is usually what the author meant (Ch 29, p 224).

### Grouping messages

Messages can be grouped to model a specific scenario, for example in
a use case, where successions specify their order (Ch 29, p 225,
Figure 29.5).

```sysml
first msgObsArea then msgFlightConfig;
first msgFlightConfig then msgObsData;
first msgObsData then msgReturnHome;
```

If a group of messages needs a context of its own rather than a use
case or a part, an occurrence definition is a good choice. An
`occurrence def` such as `InitiateCharging` can specify the exchange
of several messages between a control unit and a charger, with the
order partly defined by the order of the event occurrences
(Ch 29, pp 226 to 227).

An alternative pattern reverses the direction of the reference. Instead
of the message ends referring to event occurrences, the event
occurrences refer to the message ends. Both event occurrence notations
apply, the full form and the short form (Ch 29, p 227,
Figure 29.8).

```sysml
occurrence def DroneCommandSequence {
    part groundStation {
        event command_message.sourceEvent;
        // event occurrence evCommandSource ::> command_message.sourceEvent;
    }
    message command_message of Command;
    part relayHub {
        event command_message.targetEvent;
        then event forward_message.sourceEvent;
    }
    message forward_message of Command;
    part drone {
        event forward_message.targetEvent;
    }
}
item def Command;
```

## Streaming flows

A streaming flow usage is not abstract like a message. It specifies
the source feature from which the payload is obtained and the target
feature where it is delivered (Ch 29, p 228).

The ends of the flow definition are ports, and the ends of the
streaming flow usage give a feature chain pointing at the feature
where the payload is obtained or delivered. If a streaming flow has
no name and no specific payload, the `from` keyword can be skipped
(Ch 29, p 229).

```sysml
flow heatExchangeFlow : HeatInterfaceFlow
     from envHeatPort.heatEnergy
     to droneSystemHeatPort.heatEnergy;

flow environment.humidityPort.humidity
    to droneSystem.humidityPort.humidity;
```

It is called a streaming flow because the payload can literally
stream from source to target. A transfer does not have to wait until
another one is complete (Ch 29, p 231).

## Succession flows

A succession flow is a combination of a streaming flow and a
succession. The succession adds the rule that the transfer can take
place only after reception at the source is complete, and that
delivery at the destination can begin only after the transfer is
complete. **Only one payload can be transferred at a time**, and the
next transfer starts only after the previous one completes
(Ch 29, p 231).

A succession flow between action parameters also implies a sequence
in the execution of the actions. The textual notation mixes both
notations with the combined keyword `succession flow`
(Ch 29, pp 231 to 232, Figure 29.13).

```sysml
succession flow specifyArea.obsArea to flyToPosition.obsArea;
```

## Choosing between flows and send/accept

Both mechanisms transfer items. The distinction:

- **Flows** declare a transfer path between features. They live in
  structure as well as behaviour and persist regardless of which
  action is currently performing.
- **Send and accept actions** are discrete events. Each send is one
  transfer, triggered by the action's performance. They work
  independently from flows and directed features, and are tightly
  coupled with ports.

For systems with stable transfer paths (sensor data continuously
flowing to a controller), prefer flows. For systems with episodic
exchanges (a button press triggering a status update), prefer send
and accept.

## See also

- [[sysml2-event-occurrences]] for the message ends and their two
  declaration forms.
- [[sysml2-special-action-usages]] for send and accept action syntax.
- [[sysml2-actions]] for the action machinery that flows attach to.
- [[sysml2-state-machines]] for transition triggers driven by
  message reception.
