---
title: "SysML 2.0 Special Action Usages: Assign, Send, Accept, Terminate, If, Loop"
slug: sysml2-special-action-usages
type: reference
layer: sysml2
tags: [actions, assignment, send, accept, if, loop, time-trigger]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 26, pages 153 to 164."
    raw: sysmlv2.pdf
related:
  - sysml2-actions
  - sysml2-successions
  - sysml2-flows-and-messages
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-behaviour]
---

# SysML 2.0 Special Action Usages

The standard library defines built-in action usages with specific
semantics for typical patterns. They are primitives for defining
custom behaviour or capturing control patterns such as decisions and
loops (Ch 26, p 153).

## Assignment action

An assignment action assigns a new value to a variable feature of
some action occurrence. The syntax has three slots: the target on
the left of `:=`, the expression evaluating to the new value, and
the feature chain identifying the target feature. If there is no
dot, the target is the parent action in which the assignment is
nested. Attribute features cannot change their value (Ch 26, p 153).

```sysml
assign vehicle.position := vehicle.position + velocity * dt;
```

Assignments are implicitly defined by `AssignmentAction` from the
standard library. Most of the time, use them plain, without adding
further details. When the upper bound of the assigned feature is
greater than 1, the assignment writes a completely new set of values
**atomically** at the end of the assignment action. If the action
takes time, values in between are unconstrained (Ch 26, p 155).

The atomicity is not transactional. There is no rollback, and the
result is undefined if the action is interrupted.

## Send and accept actions

Send and accept actions exchange items. They work independently
from flows and directed features, and are tightly coupled with
ports (Ch 26, p 155). See [[sysml2-flows-and-messages]] for the
related flow mechanism.

### Send action

A send action has three input parameters. The **payload** is the
set of values to be sent, which may have any multiplicity. The
**sender occurrence** is where the resulting transfer originates,
typically the component sending the payload or one of its ports,
and defaults to the value of the `this` feature. The **receiver
occurrence** is where the transfer ends. When the sender is a port,
the receiver is determined from ports connected to that port via
interfaces (Ch 26, p 155).

```sysml
send statusUpdate to operatorPort;
```

### Accept action

Accept actions are the counterpart. They have an input parameter
for the receiver and an output parameter for the payload. The
payload declaration uses a special syntax. The part after the
`accept` keyword contains a usage declaration without a body, which
redefines the payload. This names the payload and constrains the
set of values the action can accept. Type constraints apply, and if
a feature value is specified, only that value is accepted
(Ch 26, p 157).

```sysml
accept signal : MissionCommand;
```

### Three special accept kinds

These have dedicated notation (Ch 26, p 157):

- **Change trigger** generates and accepts a `ChangeSignal` when the
  Boolean expression after `when` becomes true. Fires immediately if
  the expression is already true at the point of evaluation.
- **Absolute time trigger** generates and accepts a `TimeSignal`
  when the current time (per `localClock`, Chapter 87.2) reaches the
  expression after `at`.
- **Relative time trigger** works the same way but fires when the
  duration after `after` has elapsed from the point of evaluation.

```sysml
accept when batteryLow;
accept at missionStartTime;
accept after 30 [s];
```

## Terminate action

A terminate action forces an occurrence to end. Its only parameter
specifies the occurrence to terminate, which defaults to the action
immediately containing the terminate action. The target may also be
set via a flow to the `terminatedOccurrence` parameter. The
semantics of termination are not yet formally specified in the
2026-04 release (Ch 26, pp 158 to 159).

## If and loop actions

SysML 2.0 provides built-in syntax for typical control patterns so
action bodies can read in a script-like manner, without control
nodes (Ch 26, p 159).

### If actions

An `if` action usage has a mandatory `then` clause and an optional
`else` clause, which may itself be another `if` action to chain
more than two branches. Each clause is a single action usage with a
mandatory body. These branch actions are usually unnamed and the
body opens immediately after the condition (Ch 26, p 159).

```sysml
if batteryLow then {
    action chargeBattery;
} else {
    action continueMission;
}
```

### While loop

The while loop is a hybrid of `while` and `do-until`. The body
reads like a `then` or `else` clause, with an unnamed action
represented only by its body. An optional `while` expression
precedes the body and an optional `until` expression follows it. If
the `while` expression is simply `true`, the keyword `loop` can be
used instead (Ch 26, p 162).

```sysml
loop {
    action charge : ChargeBattery;
} until batteryLevel >= 100;
```

The body repeats as long as the `while` expression is true at the
beginning of each iteration and the `until` expression is false at
the end. Use only one of the two expressions at a time to implement
either a pre-test loop or a post-test loop (Ch 26, p 162).

### For loop

The for loop is really a for-each loop. It iterates through the
values of a feature, which is a sequence. A loop variable takes the
next value on each iteration. The sequence is **evaluated only
once** at the start of the loop. Inserting or removing an element
during iteration has no effect on execution (Ch 26, p 163).

```sysml
for target in targetCandidates {
    action examine : ExamineTarget;
}
```

## See also

- [[sysml2-actions]] for action definitions and parameters.
- [[sysml2-successions]] for explicit succession ordering.
- [[sysml2-flows-and-messages]] for the flow mechanism that
  complements send/accept.
- [[sysml2-behaviour-patterns]] for VSE-scale patterns and gotchas.
