---
title: "SysML 2.0 Successions and Control Nodes"
slug: sysml2-successions
type: reference
layer: sysml2
tags: [successions, control-flow, decision, fork, join, merge]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 26, pages 145 to 152."
    raw: sysmlv2.pdf
related:
  - sysml2-actions
  - sysml2-special-action-usages
  - sysml2-behaviour-patterns
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-behaviour]
---

# SysML 2.0 Successions and Control Nodes

Successions are a special kind of connection usage defined by the
KerML library type `HappensBefore`. They model the partial ordering
of steps in a behaviour. A succession asserts that one action is
always executed after another (Ch 26, p 145). Successions can be
declared using the `then` shorthand inside action bodies.

```sysml
action def MissionFlow {
    first start then takeOff;
    then flyToPosition;
    then done;
}
```

The `first` keyword references the start snapshot of an action
performance, and `done` marks its end. A `then` chain makes the
source the action that was declared immediately before, not an
earlier reference (Ch 26, p 146).

## End multiplicities

Default succession end multiplicities are `[0..*]` on both ends,
which means a succession does **not** enforce ordering by default.
Authors must set explicit multiplicities to express enforced
ordering. The recommended multiplicities are (Ch 26, pp 147 to 148):

| Multiplicity | Meaning | Typical use |
|---|---|---|
| `[1]`-to-`[1]` | The second action must follow the first, exactly once. | Most common. Strict sequential execution. |
| `[0..1]`-to-`[1]` | The second action must follow the first, but the first may happen without triggering the second. | Merging paths. |
| `[1]`-to-`[0..1]` | If the second action performs, it must follow the first. The first may execute without the second. | Optional successors. |
| `[1]`-to-`[*]` | The second action must follow the first exactly *n* times. | Rarely used. |

## Control nodes

The semantic library defines four control action definitions:
`DecisionAction`, `MergeAction`, `ForkAction`, and `JoinAction`. The
language includes dedicated keywords `decide`, `merge`, `fork`, and
`join` so that parsers can add the rest of the pattern automatically
(Ch 26, p 148).

### Forks and joins are largely aesthetic

More than one `[1]`-to-`[1]` succession leaving an action is
effectively a fork, and more than one such succession arriving at an
action is effectively a join. The keywords improve clarity but do
not add semantics (Ch 26, p 150). Use `fork` and `join` for
readability, not because semantics require them.

### Decision and merge nodes carry novelty

Decision nodes constrain that exactly one of the outgoing
successions is present in an execution trace. When more than one is
available, the choice is non-deterministic. When none is available,
the decision node is unsatisfiable and no legal execution exists
(Ch 26, p 150).

Merge nodes constrain that exactly one incoming succession is
present for each execution of the merge (Ch 26, p 150).

## Conditional successions

Inside action bodies, successions may carry guard conditions written
as Boolean expressions after the `if` keyword. A guarded succession
is effective only when the guard evaluates to true (Ch 26, p 150).

```sysml
then confirm if targetIdentified;
else observe;
```

The `else` keyword is a guard that fires only when all earlier
conditions in the same group evaluate to false (Ch 26, p 152).

### Behaviour without a decision node

Conditional successions do not require a decision node. Without a
decision node, multiple guarded successions evaluate independently.
If more than one guard evaluates to true, every matching action
performs in parallel. If none evaluate to true, only actions reached
by earlier unconditional successions perform (Ch 26, p 152).

Joining such threads is awkward. A plain join causes deadlock when
any guard is false, and a merge fires twice when both guards are
true. When exclusive choice is required, use a decision node
explicitly. See [[sysml2-behaviour-patterns]] for the
conditional-successions-without-decision-node pattern and its
caveats.

## See also

- [[sysml2-actions]] for action definitions and parameters.
- [[sysml2-special-action-usages]] for built-in if and loop syntax.
- [[sysml2-behaviour-patterns]] for VSE-scale patterns.
