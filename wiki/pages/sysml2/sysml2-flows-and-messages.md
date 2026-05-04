---
title: "SysML 2.0 Flows and Messages"
slug: sysml2-flows-and-messages
type: reference
layer: sysml2
tags: [flows, messages, ports, item-flow, succession-flow, streaming-flow]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 29, pages 179 to 187."
    raw: sysmlv2.pdf
related:
  - sysml2-actions
  - sysml2-special-action-usages
  - sysml2-state-machines
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-behaviour]
---

# SysML 2.0 Flows and Messages

Flows and messages are the SysML 2.0 mechanisms for transferring
items, signals, and values between behavioural elements. Flows
attach to actions, parts, and ports. Messages flow through ports
between parts.

## Flow kinds

SysML 2.0 distinguishes between several kinds of flows
(Ch 29, p 179):

### Item flow

Item flows represent the transfer of items (data, energy, or
material) between action occurrences or parts. An item flow is
bound to a connector or other relationship that carries the
logical path of exchange (Ch 29, p 185).

```sysml
flow signalRoute from sensor to controller;
```

### Succession flow

Succession flows are flows that happen as a result of action
successions. When one action finishes, items flow to the next
action along a succession edge (Ch 29, p 187). This couples
behavioural ordering with item transfer.

### Streaming flow

A streaming flow indicates that items flow continuously during the
performance of an action, rather than at discrete handoff points.
Flows can be typed to declare what kind of item flows through them,
and they can carry multiplicities and other constraints
(Ch 29, p 187).

Streaming flows are important for modelling continuous control
loops, video pipelines, and other systems where the
"items-per-second" behaviour matters more than the discrete event
of transfer.

## Messages

Messages are elements that can be sent and received through ports.
A message type defines the structure of a message. Messages flow
between ports of different parts or between a system and its
environment (Ch 29, p 180).

In SysML 2.0, messages are defined as data types or item types
exchanged via send and accept actions (see
[[sysml2-special-action-usages]]). The `from`/`to` specification
names the ports involved. A message flowing `from A to B`
originates at port A and is received at port B (Ch 29, p 180).

```sysml
message statusReport from telemetryPort to operatorPort;
```

## Choosing between flows and send/accept

Both mechanisms transfer items. The distinction:

- **Flows** declare a continuous or routinely-active transfer path.
  They live in structure and persist regardless of what action is
  currently performing.
- **Send and accept actions** are discrete events. Each send is one
  transfer, triggered by the action's performance. Send and accept
  are tightly coupled with ports.

For systems with stable transfer paths (sensor data continuously
flowing to a controller), prefer flows. For systems with episodic
exchanges (a button press triggering a status update), prefer send
and accept.

## See also

- [[sysml2-special-action-usages]] for send and accept action
  syntax.
- [[sysml2-actions]] for the action machinery that flows attach to.
- [[sysml2-state-machines]] for transition triggers driven by
  message reception.
