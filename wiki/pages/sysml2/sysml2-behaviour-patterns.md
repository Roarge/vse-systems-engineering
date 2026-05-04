---
title: "SysML 2.0 Behaviour Patterns and Gotchas"
slug: sysml2-behaviour-patterns
type: pattern
layer: sysml2
tags: [behaviour, patterns, gotchas, vse]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 26, pages 140 to 166; Chapter 28, pages 170 to 176; Chapter 29, pages 179 to 187."
    raw: sysmlv2.pdf
related:
  - sysml2-actions
  - sysml2-successions
  - sysml2-special-action-usages
  - sysml2-state-machines
  - sysml2-flows-and-messages
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-behaviour]
---

# SysML 2.0 Behaviour Patterns and Gotchas

This page collects practical patterns for VSE-scale authors who
model behaviour in SysML 2.0, plus the recurring mistakes that show
up in review. For declaration syntax see [[sysml2-actions]],
[[sysml2-successions]], [[sysml2-special-action-usages]],
[[sysml2-state-machines]], and [[sysml2-flows-and-messages]].

## VSE authoring patterns

### Sequential action chain

Use `first`, `then`, and `done` to order actions linearly. This is
the foundational pattern for any step-by-step process (Ch 26, p 146).

### Parallel execution with fork and join

Use fork nodes to split into parallel paths and join nodes to
synchronise. The textual notation allows multiple `[1]`-to-`[1]`
successions to leave or arrive at an action naturally, and the
`fork`/`join` keywords make the pattern explicit (Ch 26, pp 148
to 150).

### Conditional branching without decision nodes

Use multiple conditional successions with guard conditions after
`if`. Each can fire independently when its condition is true,
avoiding the forced use of a decision node when the semantics
permit independent branches (Ch 26, p 152). Watch the parallel
branches gotcha below.

### Looping with while or until

Wrap an action body with `while not targetConfirmed { ... }` or
`loop { ... } until targetConfirmed` for adaptive repetition. More
concise than control nodes for simple repetition (Ch 26, p 162).

### For-each iteration

Use `for target in targetCandidates { ... }` to iterate through a
sequence. The loop variable is freshly bound in each iteration, and
the sequence is evaluated only once at loop start
(Ch 26, pp 163 to 164).

### Send and accept pattern for inter-component communication

Use send actions to initiate message exchange and accept actions
to receive. Specify sender and receiver ports to bind the action to
actual interfaces (Ch 26, pp 155 to 157).

### State machine with entry, do, and exit actions

Define a state, attach entry, do, and exit actions, and connect
states with transitions triggered by messages or time events
(Ch 28, pp 172 to 173). This is the bread and butter of any
control-system model.

### Perform action for behaviour reuse

Use `perform action someAction` to invoke a previously defined
action. Cleaner than inlining the same behaviour multiple times
(Ch 26, p 165).

## Gotchas and red flags

### Parameter redeclaration on inheritance

When redefining parameters in a specialised action, redeclare them
in order. To override only the second parameter, redeclare the
first as well. Omitting earlier parameters causes a parsing error
(Ch 26, p 145).

### Default succession multiplicities do not enforce ordering

The default `[0..*]`-to-`[0..*]` does not enforce any ordering. Set
`[1]`-to-`[1]` explicitly when strict sequential execution is
required (Ch 26, p 147).

### Black circle and bullseye are snapshots, not initial or final nodes

In SysML 2.0, the black circle at the start of a succession chain
and the bullseye at the end are snapshots, not Activity Diagram
initial and final nodes. They do not terminate the parent action
(Ch 26, p 146).

### `this` inherited as Occurrence

In assignment and send actions, the target of `this` points to the
nearest structural element up the composition hierarchy, which may
not be the immediate parent. The inherited type is `Occurrence`, so
the correct type may need to be set manually (Ch 26, p 154).

### Assignment is atomic but not transactional

For a feature with upper bound greater than 1, assignment writes
the entire new set of values in one atomic operation. There is no
rollback, and the result is undefined if the action is interrupted
(Ch 26, p 155).

### Control nodes are primarily for clarity

Fork, join, decision, and merge nodes are largely aesthetic. Most
of their logic is derivable from succession multiplicities. Use
them for readability, not because semantics require them
(Ch 26, p 150).

### Multiple true guards cause parallel branches

Without a decision node, conditional successions evaluate
independently. If several guards are true, every matching branch
executes in parallel, which may surprise authors expecting
exclusive choice (Ch 26, p 152). When exclusive choice is required,
use a `decide` node explicitly.

### Accept payloads need the special syntax

Redefining the payload in an accept action is not automatic. The
`accept` keyword must be followed by a usage declaration without a
body to bind the payload correctly (Ch 26, p 157).

### Send and accept receivers depend on port connections

When the sender is a port, the receiver is inferred from interfaces
connected to that port. If the interface is not properly defined,
the receiver is indeterminate (Ch 26, p 155).

### Loop variable is fresh in each iteration

The for loop variable takes a fresh value on each iteration.
Modifying the sequence during iteration has no effect, because the
sequence is evaluated only once at loop start (Ch 26, p 163).

### Termination semantics are not formally specified

The terminate action ends an occurrence, but the precise semantics
are not formally specified in the 2026-04 release (Ch 26, p 159).

## Pending material in the source

The 2026-04 release publishes Chapter 25 (Occurrences and 4D
Modelling) and Chapter 39 (Model Execution), which the previous
release left pending. New pages capture this material:
[[sysml2-occurrences-4d]] and [[sysml2-model-execution]].
Behaviour-patterns guidance may evolve once those chapters have
been studied in depth and feedback collected from VSE projects.
