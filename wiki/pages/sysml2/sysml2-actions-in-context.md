---
title: "SysML 2.0 Actions in a Context"
slug: sysml2-actions-in-context
type: reference
layer: sysml2
summary: "How an action reaches its surrounding part: inline access, explicit context, redefining this, individual features"
tags: [actions, context, this, ports, reuse, behaviour]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-07 release. MBSE4U. Sections 26.9 to 26.9.4, pages 195 to 202."
    raw: sysmlv2.pdf
related:
  - sysml2-occurrence-context-and-variables
  - sysml2-actions
  - sysml2-special-action-usages
  - sysml2-abstract-actions
  - sysml2-state-machines
confidence: high
created: 2026-08-10
updated: 2026-08-14
referenced_by: [sysml2-behaviour]
---

# SysML 2.0 Actions in a Context

## Contents

- Why the context matters
- Pattern 1: inline access
- Pattern 2: passing the context explicitly
- Pattern 3: carrying the context in this
- Pattern 4: referencing individual features
- Choosing among the patterns
- See also

An action rarely operates in isolation. To be useful it must reach
the world around it, that is, read an attribute of the component it
runs in, push something out through a port, or hand a message to
another part. This page covers the four ways it does so and the
trade-offs among them (Ch 26, pp 195 to 202).

## Why the context matters

The organising idea is the **context** of an action. Every occurrence
has a `this` feature pointing at its context occurrence, the
innermost structural occurrence (a part or an item) in its
composition chain. For an action nested in a part, `this` is that
part, and for a sub-action of that action, `this` is still that part
(Ch 26, p 195). See [[sysml2-occurrence-context-and-variables]].

Two situations follow (Ch 26, pp 195 to 196). An action written
**inline**, nested directly in the part it belongs to, shares that
part's context and names the part's attributes, ports, and references
directly by lexical scope. An action written as a reusable
**definition** (an `action def`) has no context of its own, so it
cannot name any particular part, and referring to a sibling part by
its bare name from inside a definition is an error. The context must
instead be passed in explicitly.

The patterns below move from the first situation to the second, and
within the second, from the most tightly coupled to the loosest. All
four use one example: a `Drone` that reports its status, reading its
own `windSpeed` and sending it to a `groundStation` either directly
or via its `commPort`.

## Pattern 1: inline access

The action's context is the drone, so it names `windSpeed` and
`commPort` directly, and it reaches the ground station by name
through the enclosing scope with no reference declared
(Ch 26, pp 196 to 197, Figure 26.30).

```sysml
part def DroneSystem {
    part drone : Drone {
        action reportStatus {
            attribute attempts : ScalarValues::Integer := 0;
            first start;
            then assign attempts := attempts + 1;
            then send new StatusReport(windSpeed) via commPort;
            then send new StatusReport(windSpeed) to groundStation;
        }
    }
    part groundStation : GroundStation;
    interface connect drone.commPort to groundStation.commPort;
}
```

An inline action can also carry data of its own. The attribute
`attempts` is local working state used while the action runs, not
part of any surrounding component (Ch 26, p 197).

The send reaches a peer two ways, a choice that recurs in every
pattern here. Sending **via** a port leaves the receiver to the
connected interface, so the behaviour names no peer at all. Sending
**to** a part addresses it directly by name. These are two routes and
not a pair to use together, so a real model picks one (Ch 26, p 197).
See [[sysml2-special-action-usages]].

## Pattern 2: passing the context explicitly

Extracting the behaviour into an action definition removes the free
access. The most explicit remedy gives the definition a dedicated
reference for its context (Ch 26, pp 197 to 198, Figure 26.32).

```sysml
part def Communicator {
    attribute windSpeed :> ISQSpaceTime::speed;
    port commPort;
    ref part groundStation : GroundStation;
}
action def ReportStatus {
    ref part context : Communicator;
    first start;
    then send new StatusReport(context.windSpeed) via context.commPort;
    then send new StatusReport(context.windSpeed) to context.groundStation;
}
part def Drone :> Communicator {
    action report : ReportStatus {
        :>> context = this;
    }
}
```

`Communicator` captures exactly what the behaviour needs. The context
is a reference (`ref part`), not an input (`in`), because it is a
persistent partner rather than a value that flows in and out. Two
things connect the definition to a concrete drone: `Drone` specialises
`Communicator`, so a drone qualifies as a context, and the usage
redefines the reference and binds it, where `this` inside the action
is the drone (Ch 26, pp 198 to 199).

The `groundStation` reference is in the contract only to support the
direct `to` route. Reaching the station `via` the port instead means
the contract need not name a peer at all. Direct addressing reads more
immediately, but it turns the partner into an explicit dependency
(Ch 26, p 199).

## Pattern 3: carrying the context in this

That hand-off is slightly redundant, because the context occurrence
is already available as `this`. The obstacle is that `this` is
inherited with the general type `Occurrence`, so a drone's features
cannot be navigated through it until it is typed. The remedy is to
redefine `this` once, with both a type and a name (Ch 26, p 199,
Figure 26.33).

```sysml
action def ReportStatus {
    ref part context : Communicator :>> this;
    first start;
    then send new StatusReport(context.windSpeed) via context.commPort;
    then send new StatusReport(context.windSpeed) to context.groundStation;
}

part def Drone :> Communicator {
    action report : ReportStatus;
}
```

The body is identical to the previous pattern, but the usage needs no
hand-off, because `this` is filled in automatically. Name the
redefinition rather than redefining `this` in place, because `this`
is a feature of every behaviour and each sub-action has its own.
Naming it once at the top lets every nested step reach the context by
that name through ordinary lexical scope (Ch 26, p 200).

This expresses the same idea as pattern 2, implicitly rather than
explicitly. The explicit reference is more self-documenting and, for
now, the more widely used form, while the `this` form is terser and
removes a binding an author might forget. The book notes that
redefining `this` by hand may become unnecessary in a future version
of the language (Ch 26, p 200).

## Pattern 4: referencing individual features

Both previous patterns hand over an entire context object and require
the using part to conform to its type. The loosest alternative
declares references to exactly the elements the behaviour touches,
and nothing else (Ch 26, pp 200 to 201, Figure 26.35).

```sysml
action def ReportStatus {
    in attribute reportedWind :> ISQSpaceTime::speed;
    ref port outPort;
    ref part station : GroundStation;
    first start;
    then send new StatusReport(reportedWind) via outPort;
    then send new StatusReport(reportedWind) to station;
}
part def Drone {
    attribute windSpeed :> ISQSpaceTime::speed;
    port commPort;
    ref part groundStation : GroundStation;

    action report : ReportStatus {
        in attribute :>> reportedWind = windSpeed;
        port :>> outPort = commPort;
        ref part :>> station = groundStation;
    }
}
```

The definition depends on no context type at all, and the using part
binds each element to one of its own features. The book names the
parameter and references differently from the drone's own features so
that each binding reads unambiguously (Ch 26, p 201).

## Choosing among the patterns

| Approach | Gains | Costs |
|---|---|---|
| Whole-context handle (patterns 2 and 3) | One readable requirement, free navigation inside the behaviour | Forces the context into a type hierarchy |
| Individual references (pattern 4) | No demand on the context's type, explicit dependencies | One binding per element, longer parameter list |

Neither is universally better. Prefer a whole-context handle when the
behaviour genuinely belongs to a kind of part, and individual
references when any part should be able to wire the behaviour up,
whatever it is (Ch 26, p 202).

Everything here carries over to state machines, because a state is an
action (Ch 28, p 218). See [[sysml2-state-machines]] for the
communicating-machine arrangement that relies on it.

## See also

- [[sysml2-occurrence-context-and-variables]] for `this` semantics.
- [[sysml2-actions]] for action definitions, usages, and parameters.
- [[sysml2-special-action-usages]] for send and accept.
- [[sysml2-abstract-actions]] for deferring a step's realisation.
- [[sysml2-state-machines]] for machines that bind the same way.
