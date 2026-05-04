---
title: "SysML 2.0 Actions, Parameters, and Perform Actions"
slug: sysml2-actions
type: reference
layer: sysml2
tags: [actions, behaviour, parameters, perform-action]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 26, pages 140 to 145; pages 165 to 166."
    raw: sysmlv2.pdf
related:
  - sysml2-successions
  - sysml2-special-action-usages
  - sysml2-state-machines
  - sysml2-cases-overview
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-behaviour]
---

# SysML 2.0 Actions, Parameters, and Perform Actions

SysML 2.0 draws a sharp line between **structure** (what the system
has) and **behaviour** (what the system does). The language models
behaviour through actions, which are a special kind of occurrence
that happens in time. Every behaviour in SysML 2.0 is fundamentally
a special kind of action, whether expressed as a process, a
calculation, or a state change (Ch 26, p 140).

## Action definitions and usages

An **action definition** is a blueprint for an action performance.
The distinction between the definition and the performance is
load-bearing. If the action `Read a book` is a model element, the
actual performance is the real-world reading event occurring at a
specific time (Ch 26, p 140). Action definitions are analogous to
function or method definitions in programming.

An **action usage** represents an action performed in a context. By
default, when the context is another occurrence (a part, action,
use case, or state), the usage is regarded as an invocation of the
behaviour from the owning occurrence. Exceptions exist when the
usage is only related to an abstract concept without execution
constraints (Ch 26, p 142). Action usages are composite by default,
meaning they must be performed during the lifetime of their owner.

An **abstract action usage** declares that an action is not supposed
to be performed unless it is redefined or subsetted (Ch 26, p 143).

## Action parameters

Actions carry parameters that model inputs and outputs, configuration
values, and continuous (streaming) exchange with other processes
(Ch 26, p 143). Every directed feature of an action is a parameter.
The directions are `in`, `out`, and `inout`.

```sysml
action def CalculateTrajectory {
    in  startPoint : Position;
    in  endPoint   : Position;
    in  constraints : MissionConstraints;
    out path : Trajectory;
    out durationSec : Real;
}
```

Parameters are **variables by default**, meaning their value can
change over time through both internal and external actions. Add
the `constant` modifier to lock a parameter to a single value for
the duration of the action performance (Ch 26, p 144).

Parameters are **ordered**. When a specialised action redefines
parameters of an inherited action, the redeclaration must follow
the original order. To redefine only the second parameter, the first
must still be redeclared before the second is overridden
(Ch 26, p 145).

## Perform actions

A **perform action usage** is a referential action usage with the
additional constraint that it must happen during the lifetime of
its owner. It models calling actions from other behaviours or
specifying that a part is the performer of an action. The called
action is identified via reference subsetting (Ch 26, p 165).

```sysml
part def Vehicle {
    perform action drive : Drive;
    perform action park  : Park;
}
```

Without a reference, the perform action usage itself is the
performed action. This default enables simulation before the actual
performer is known. If the owning type is not an occurrence, the
used action is only related to that abstract concept
(Ch 26, p 165).

A perform action in an abstract definition can be refined in a
concrete definition by adding the reference subsetting to a
specific action usage. This is common when the performing part is
not known at the definition level but is fixed in the design
(Ch 26, p 166).

## See also

- [[sysml2-successions]] for ordering action substeps with `then`,
  `first`, `done`, and end-multiplicity rules.
- [[sysml2-special-action-usages]] for the standard library actions
  (assignment, send, accept, terminate, if, loop).
- [[sysml2-state-machines]] for state-based behaviour modelling.
- [[sysml2-cases-overview]] for the case family, which specialises
  actions for use, analysis, and verification.
- [[sysml2-behaviour-patterns]] for VSE-scale patterns and gotchas.
