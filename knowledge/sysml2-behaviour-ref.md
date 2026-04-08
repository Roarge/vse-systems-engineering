# SysML v2 Behaviour Reference

Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U, 2026-03 release.
Chapter and page citations appear inline. This file paraphrases the source, which is
a copyrighted commercial reference and is not reproduced verbatim. Chapter 25
(Occurrences and 4D Modelling) and parts of Chapter 39 (Model Execution) are marked
as pending in the 2026-03 release. This file will be extended when those chapters
are published.

---

## 1. Overview (Ch 26, p 140)

SysML v2 draws a sharp line between structure, that is what the system has, and
behaviour, that is what the system does. The language models behaviour through
actions, which are a special kind of occurrence that happens in time. Every behaviour
in SysML v2 is fundamentally a special kind of action, whether expressed as a process,
a calculation, or a state change (Ch 26, p 140).

Behaviour models capture the temporal arrangement of action substeps together with
their prerequisites and consequences. Calculations (Ch 27) and state machines (Ch 28)
are specialised behaviour formalisms built on the action foundation.

---

## 2. Actions (Ch 26, pp 140-143)

An action definition is a blueprint for an action performance. The distinction
between the definition and the performance is load-bearing. If the action
`Read a book` is a model element, the actual performance is the real-world reading
event occurring at a specific time (Ch 26, p 140). Action definitions are analogous
to programming function or method definitions.

An action usage represents an action performed in a context. By default, when the
context is another occurrence (which can be a part, action, use case, or state), the
usage is regarded as an invocation of the behaviour from the owning occurrence.
Exceptions exist when the usage is only related to an abstract concept without
execution constraints (Ch 26, p 142). Action usages are composite by default, meaning
they must be performed during the lifetime of their owner.

An abstract action usage declares that an action is not supposed to be performed
unless it is redefined or subsetted (Ch 26, p 143).

---

## 3. Action Parameters (Ch 26, pp 143-145)

Actions carry parameters that model inputs and outputs, configuration values, and
continuous (streaming) exchange with other processes (Ch 26, p 143). Every directed
feature of an action is a parameter. The directions are `in`, `out`, and `inout`.

Parameters are variables by default, that is, their value can change over time
through both internal and external actions. Add the `constant` modifier to lock a
parameter to a single value for the duration of the action performance (Ch 26, p 144).

Parameters are ordered. When a specialised action redefines parameters of an
inherited action, the redeclaration must follow the original order. To redefine only
the second parameter, the first must still be redeclared before the second is
overridden (Ch 26, p 145).

---

## 4. Successions (Ch 26, pp 145-148)

Successions are a special kind of connection usage defined by the KerML library
type `HappensBefore`. They model the partial ordering of steps in a behaviour. A
succession asserts that one action is always executed after another (Ch 26, p 145).
Successions can be declared using the `then` shorthand inside action bodies.

```sysml
first start then takeOff;
then flyToPosition;
then done;
```

The `first` keyword references the start snapshot of an action performance, and
`done` marks its end. A `then` chain makes the source the action that was declared
immediately before, not an earlier reference (Ch 26, p 146).

### 4.1 End Multiplicities

Default succession end multiplicities are `[0..*]` on both ends, that is, a
succession does not enforce ordering by default. The recommended multiplicities are
(Ch 26, pp 147-148):

- `[1]`-to-`[1]`: most common. The second action must follow the first, exactly once.
- `[0..1]`-to-`[1]`: the second action must follow the first, but the first may
  happen without triggering the second. Useful for merging paths.
- `[1]`-to-`[0..1]`: if the second action performs, it must follow the first.
  The first may execute without the second. Useful for optional successors.
- `[1]`-to-`[*]`: the second action must follow the first exactly `n` times.
  Rarely used.

---

## 5. Control Nodes (Ch 26, pp 148-150)

The semantic library defines four control action definitions: `DecisionAction`,
`MergeAction`, `ForkAction`, and `JoinAction`. The language includes dedicated
keywords `decide`, `merge`, `fork`, and `join` so that parsers can add the rest of
the pattern automatically (Ch 26, p 148).

Forks and joins are largely aesthetic. More than one `[1]`-to-`[1]` succession
leaving an action is effectively a fork, and more than one such succession
arriving at an action is effectively a join. The keywords improve clarity but do
not add semantics (Ch 26, p 150).

Decision nodes carry fundamental semantic novelty. They constrain that exactly one
of the outgoing successions is present in an execution trace. When more than one is
available, the choice is non-deterministic. When none is available, the decision
node is unsatisfiable and no legal execution exists (Ch 26, p 150).

Merge nodes constrain that exactly one incoming succession is present for each
execution of the merge (Ch 26, p 150).

---

## 6. Conditional Successions (Ch 26, pp 150-152)

Inside action bodies, successions may carry guard conditions written as Boolean
expressions after the `if` keyword. A guarded succession is effective only when
the guard evaluates to true (Ch 26, p 150).

```sysml
then confirm if targetIdentified;
else observe;
```

The `else` keyword is a guard that fires only when all earlier conditions in the
same group evaluate to false (Ch 26, p 152).

Conditional successions do not require a decision node. Without a decision node,
multiple guarded successions evaluate independently. If more than one guard
evaluates to true, every matching action performs in parallel. If none evaluate
to true, only actions reached by earlier unconditional successions perform
(Ch 26, p 152). Joining such threads is awkward. A plain join causes deadlock
when any guard is false, and a merge fires twice when both guards are true.

---

## 7. Special Action Usages (Ch 26, pp 153-164)

The standard library defines built-in action usages with specific semantics for
typical patterns. They are primitives for defining custom behaviour or capturing
control patterns such as decisions and loops (Ch 26, p 153).

### 7.1 Assignment Action

An assignment action assigns a new value to a variable feature of some action
occurrence. The syntax has three slots, that is the target on the left of `:=`,
the expression evaluating to the new value, and the feature chain identifying the
target feature. If there is no dot, the target is the parent action in which the
assignment is nested. Attribute features cannot change their value (Ch 26, p 153).

```sysml
assign vehicle.position := vehicle.position + velocity * dt;
```

Assignments are implicitly defined by `AssignmentAction` from the standard library.
Most of the time, use them plain, without adding further details. When the upper
bound of the assigned feature is greater than 1, the assignment writes a completely
new set of values atomically at the end of the assignment action. If the action
takes time, values in between are unconstrained (Ch 26, p 155).

### 7.2 Send and Accept Actions

Send and accept actions exchange items. They work independently from flows and
directed features, and are tightly coupled with ports (Ch 26, p 155).

A send action has three input parameters. The payload is the set of values to be
sent, which may have any multiplicity. The sender occurrence is where the resulting
transfer originates, typically the component sending the payload or one of its
ports, and defaults to the value of the `this` feature. The receiver occurrence is
where the transfer ends. When the sender is a port, the receiver is determined
from ports connected to that port via interfaces (Ch 26, p 155).

Accept actions are the counterpart. They have an input parameter for the receiver
and an output parameter for the payload. The payload declaration uses a special
syntax. The part after the `accept` keyword contains a usage declaration without a
body, which redefines the payload. This names the payload and constrains the set
of values the action can accept. Type constraints apply, and if a feature value is
specified, only that value is accepted (Ch 26, p 157).

Three special accept kinds have dedicated notation (Ch 26, p 157):

- A change trigger generates and accepts a `ChangeSignal` when the Boolean
  expression after `when` becomes true. Fires immediately if the expression is
  already true at the point of evaluation.
- An absolute time trigger generates and accepts a `TimeSignal` when the current
  time (per `localClock`, Ch 87.2) reaches the expression after `at`.
- A relative time trigger works the same way but fires when the duration after
  `after` has elapsed from the point of evaluation.

### 7.3 Terminate Action

A terminate action forces an occurrence to end. Its only parameter specifies the
occurrence to terminate, which defaults to the action immediately containing the
terminate action. The target may also be set via a flow to the
`terminatedOccurrence` parameter. The semantics of termination are not yet formally
specified in this release (Ch 26, pp 158-159).

### 7.4 If and Loop Actions

SysML v2 provides built-in syntax for typical control patterns so action bodies
can read in a script-like manner, without control nodes (Ch 26, p 159).

An `if` action usage has a mandatory `then` clause and an optional `else` clause,
which may itself be another `if` action to chain more than two branches. Each
clause is a single action usage with a mandatory body. These branch actions are
usually unnamed and the body opens immediately after the condition (Ch 26, p 159).

There are two loop action kinds, the while loop and the for loop (Ch 26, p 161).

The while loop is a hybrid of `while` and `do-until`. The body reads like a `then`
or `else` clause, with an unnamed action represented only by its body. An optional
`while` expression precedes the body and an optional `until` expression follows
it. If the `while` expression is simply `true`, the keyword `loop` can be used
instead (Ch 26, p 162).

```sysml
loop {
    action charge : ChargeBattery;
} until batteryLevel >= 100;
```

The body repeats as long as the `while` expression is true at the beginning of
each iteration and the `until` expression is false at the end. Use only one of
the two expressions at a time to implement either a pre-test loop or a post-test
loop (Ch 26, p 162).

The for loop is really a for-each loop. It iterates through the values of a
feature, which is a sequence. A loop variable takes the next value on each
iteration. The sequence is evaluated only once at the start of the loop.
Inserting or removing an element during iteration has no effect on execution
(Ch 26, p 163).

---

## 8. Perform Actions (Ch 26, pp 165-166)

A perform action usage is a referential action usage with the additional
constraint that it must happen during the lifetime of its owner. It models
calling actions from other behaviours or specifying that a part is the performer
of an action. The called action is identified via reference subsetting
(Ch 26, p 165).

Without a reference, the perform action usage itself is the performed action. This
default enables simulation before the actual performer is known. If the owning
type is not an occurrence, the used action is only related to that abstract concept
(Ch 26, p 165).

A perform action in an abstract definition can be refined in a concrete definition
by adding the reference subsetting to a specific action usage. This is common when
the performing part is not known at the definition level but is fixed in the
design (Ch 26, p 166).

---

## 9. States and State Definitions (Ch 28, p 170)

States are occurrences that may be active throughout the lifetime of their owner
or a subset of it. Unlike actions, which are transient, states represent persistent
conditions. Every state definition specialises `State` from the standard library.
State definitions may own features, constraints, and other model elements
(Ch 28, p 170).

---

## 10. Transitions (Ch 28, p 172)

Transitions connect states and declare the conditions under which one state is
exited and another is entered. The long form declares the source state, a trigger,
a guard condition, and an effect action. The short form, inside a state body, is
more concise (Ch 28, p 172).

A transition is triggered by an event such as a message reception, a timeout, or
a change in a condition. The trigger is declared after the `accept` keyword. A
guard condition is a Boolean expression that must be true for the transition to
be taken. An effect action specifies what happens as a result, and is an action
usage or a reference to one (Ch 28, p 172).

```sysml
transition off_to_starting
    first off
    accept TurnOnSignal
    if batteryOk
    do action powerUp : PowerUp
    then starting;
```

---

## 11. Entry, Do, and Exit Behaviours (Ch 28, pp 172-173)

A state may own entry actions, executed when the state is entered, do actions,
executed while the state is active, and exit actions, executed when the state is
exited. The corresponding keywords are `entry`, `do`, and `exit` (Ch 28, pp 172-173).

---

## 12. Parallel States and Exhibit States (Ch 28, pp 174-176)

Complex state machines can include parallel regions, where multiple states are
active simultaneously. This is modelled with a parallel state definition
(Ch 28, p 174).

An exhibit state is a state that is exhibited by a part or system at a particular
point in its lifecycle. Exhibit states are declared using the `exhibit` keyword
and model the visible state of a component (Ch 28, p 176).

---

## 13. Flows (Ch 29, pp 179-187)

SysML v2 distinguishes between several kinds of flows (Ch 29, p 179).

Item flows represent the transfer of items (data, energy, or material) between
action occurrences or parts. An item flow is bound to a connector or other
relationship that carries the logical path of exchange (Ch 29, p 185).

Succession flows are flows that happen as a result of action successions. When one
action finishes, items flow to the next action along a succession edge
(Ch 29, p 187).

A streaming flow indicates that items flow continuously during the performance of
an action, rather than at discrete handoff points. Flows can be typed to declare
what kind of item flows through them, and they can carry multiplicities and other
constraints (Ch 29, p 187).

---

## 14. Messages (Ch 29, p 180)

Messages are elements that can be sent and received through ports. A message type
defines the structure of a message. Messages flow between ports of different parts
or between a system and its environment (Ch 29, p 180). In SysML v2, messages are
defined as data types or item types exchanged via send and accept actions. The
`from`/`to` specification names the ports involved. A message flowing `from A to B`
originates at port A and is received at port B (Ch 29, p 180).

---

## 15. Model Execution Semantics (Ch 39, p 263)

Chapter 39 on Model Execution appears in the table of contents on page 263 of the
2026-03 release, but the chapter body is marked for a later release. Detailed
execution semantics (simulator conformance, event loop, timing, and trace
generation) are therefore not covered in this file. When Ch 39 is published, this
file will grow a section summarising the formal execution semantics.

---

## 16. Practical Patterns for VSE Authors

### 16.1 Sequential Action Chain

Use `first`, `then`, and `done` to order actions linearly. This is the foundational
pattern for any step-by-step process (Ch 26, p 146).

### 16.2 Parallel Execution with Fork and Join

Use fork nodes to split into parallel paths and join nodes to synchronise. The
textual notation allows multiple `[1]`-to-`[1]` successions to leave or arrive at
an action naturally, and the `fork`/`join` keywords make the pattern explicit
(Ch 26, pp 148-150).

### 16.3 Conditional Branching without Decision Nodes

Use multiple conditional successions with guard conditions after `if`. Each can
fire independently when its condition is true, avoiding the forced use of a
decision node when the semantics permit independent branches (Ch 26, p 152).

### 16.4 Looping with While or Until

Wrap an action body with `while not targetConfirmed { ... }` or
`loop { ... } until targetConfirmed` for adaptive repetition. More concise than
control nodes for simple repetition (Ch 26, p 162).

### 16.5 For-Each Iteration

Use `for target in targetCandidates { ... }` to iterate through a sequence. The
loop variable is freshly bound in each iteration, and the sequence is evaluated
only once at loop start (Ch 26, pp 163-164).

### 16.6 Send and Accept Pattern for Inter-Component Communication

Use send actions to initiate message exchange and accept actions to receive.
Specify sender and receiver ports to bind the action to actual interfaces
(Ch 26, pp 155-157).

### 16.7 State Machine with Entry, Do, and Exit Actions

Define a state, attach entry, do, and exit actions, and connect states with
transitions triggered by messages or time events (Ch 28, pp 172-173).

### 16.8 Perform Action for Behaviour Reuse

Use `perform action someAction` to invoke a previously defined action. Cleaner
than inlining the same behaviour multiple times (Ch 26, p 165).

---

## 17. Gotchas and Red Flags

1. **Parameter redeclaration on inheritance.** When redefining parameters in a
   specialised action, redeclare them in order. To override only the second
   parameter, redeclare the first as well. Omitting earlier parameters causes a
   parsing error (Ch 26, p 145).
2. **Default succession multiplicities do not enforce ordering.** The default
   `[0..*]`-to-`[0..*]` does not enforce any ordering. Set `[1]`-to-`[1]`
   explicitly when strict sequential execution is required (Ch 26, p 147).
3. **Black circle and bullseye are snapshots, not initial or final nodes.** In
   SysML v2, the black circle at the start of a succession chain and the bullseye
   at the end are snapshots, not Activity Diagram initial and final nodes. They
   do not terminate the parent action (Ch 26, p 146).
4. **`this` inherited as Occurrence.** In assignment and send actions, the target
   of `this` points to the nearest structural element up the composition
   hierarchy, which may not be the immediate parent. The inherited type is
   `Occurrence`, so the correct type may need to be set manually (Ch 26, p 154).
5. **Assignment is atomic but not transactional.** For a feature with upper
   bound greater than 1, assignment writes the entire new set of values in one
   atomic operation. There is no rollback, and the result is undefined if the
   action is interrupted (Ch 26, p 155).
6. **Control nodes are primarily for clarity.** Fork, join, decision, and merge
   nodes are largely aesthetic. Most of their logic is derivable from succession
   multiplicities. Use them for readability, not because semantics require them
   (Ch 26, p 150).
7. **Multiple true guards cause parallel branches.** Without a decision node,
   conditional successions evaluate independently. If several guards are true,
   every matching branch executes in parallel, which may surprise authors
   expecting exclusive choice (Ch 26, p 152).
8. **Accept payloads need the special syntax.** Redefining the payload in an
   accept action is not automatic. The `accept` keyword must be followed by a
   usage declaration without a body to bind the payload correctly
   (Ch 26, p 157).
9. **Send and accept receivers depend on port connections.** When the sender is
   a port, the receiver is inferred from interfaces connected to that port. If
   the interface is not properly defined, the receiver is indeterminate
   (Ch 26, p 155).
10. **Loop variable is fresh in each iteration.** The for loop variable takes a
    fresh value on each iteration. Modifying the sequence during iteration has
    no effect, because the sequence is evaluated only once at loop start
    (Ch 26, p 163).
11. **Termination semantics are not formally specified.** The terminate action
    ends an occurrence, but the precise semantics are not formally specified in
    this release (Ch 26, p 159).

---

## 18. Cross References

- `sysml2-quick-ref.md` Sections 12, 13 for action and state textual syntax.
- `sysml2-expressions-ref.md` for guards, assignment right-hand sides, and loop
  range expressions.
- `sysml2-semantics-ref.md` for the Occurrence type hierarchy behind actions
  and states.
- `sysml2-cases-ref.md` for the case family, which specialises action.

---

## 19. Pending Extensions

This file will grow once the following chapters are published in a future release
of the book:

- Ch 25 Occurrences and 4D Modelling (snapshots, timelines, lifetimes)
- Ch 27 Calculations (currently stubbed, cross-linked from `sysml2-expressions-ref.md`)
- Ch 39 Model Execution (simulator semantics, trace generation)

Attribution: Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U, 2026.
All claims cite chapter and page. Paraphrased for reference use. Do not reproduce
verbatim.
