---
title: "SysML 2.0 Structural and Behavioural Semantics"
slug: sysml2-structural-and-behavioural-semantics
type: reference
layer: sysml2
tags: [semantics, parts, ports, connections, actions, states, calculations, constraints]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Chapter 8."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-type-hierarchy
  - sysml2-specialisation-and-typing
  - sysml2-actions
  - sysml2-state-machines
  - sysml2-expressions-constraints
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Structural and Behavioural Semantics

This page captures the formal semantic rules for the structural
and behavioural element families. Code-level cheat sheets live in
[[sysml2-syntax-structure]] and [[sysml2-syntax-behaviour]].

## Structural semantics

### Parts

Parts model composite ownership with **lifecycle coupling**. A
part's lifecycle is bounded by its owner's lifecycle. If a `part
def Vehicle` owns a `part engine : Engine`, then every Vehicle
instance has its own Engine instance that cannot outlive the
owning Vehicle. For shared resources (a sensor used by multiple
subsystems), model the reference as `ref part` in each subsystem
and place composite ownership in the system that physically
contains the sensor.

### Ports

Ports are boundary features defining interaction points. Semantic
rules:

- Nested usages that are not PortUsages must be referential
  (non-composite).
- Conjugated ports (`~PortType`) reverse all `in`/`out`
  directions. A `ConjugatedPortDefinition` is generated
  automatically for every `PortDefinition`.
- Directed features (`in`, `out`, `inout`) specify flow direction
  through the port.

### Connections

Connections must have at least two `connectionEnd` features unless
marked `abstract`. Binary connections redefine `source` and
`target` from `Links::BinaryLink`.

### Binding connectors

Binding connectors assert that two features always have the same
value. Based on `Links::selfLink`. Use them for identity
constraints. For full coverage of binding-connector semantics see
[[sysml2-binding-connectors]] (new in the 2026-04 release).

### Interfaces

Interfaces are `ConnectionDefinitions` whose ends must be
`PortUsages`. Use them when connecting ports specifically.

### Allocations

Allocations are binary `ConnectionDefinitions` for cross-concern
mapping (logical function to physical element). They have exactly
two ends. See [[sysml2-allocations-overview]].

### Successions

Successions express temporal ordering via
`Occurrences::happensBeforeLinks`. `first A then B` means A must
complete before B starts. See [[sysml2-successions]].

## Behavioural semantics

### Actions

Actions model behaviour that transforms inputs to outputs over
time:

- Parameters of a specialising action must redefine corresponding
  parameters of the specialised Behaviour.
- Actions own subactions, successions, and control nodes (fork,
  join, decide, merge).
- The `start` and `done` features mark lifecycle boundaries.
  `first start then X` means X begins when the action starts.
  `first Y then done` means the action completes when Y completes.

See [[sysml2-actions]] for the full conceptual frame.

### States

States model behaviour that persists over time and transitions
based on events or conditions:

- **Exclusive substates**: in a non-parallel state definition,
  only one substate can be active at any time.
- **Parallel states**: substates represent concurrent regions, all
  active simultaneously.
- **Entry/do/exit actions** redefine features of `StateAction`.
- Transitions may include triggers (`accept`), guards (`if`), and
  effects (`do action`).

See [[sysml2-state-machines]].

### Calculations

Calculations specialise both Actions and Evaluations. The `result`
parameter must redefine the result parameter of the specialised
Function. The result expression is the last expression in the body
and does not require trailing punctuation. Calculations can be
used as expressions within other calculations or constraints. See
[[sysml2-expressions-constraints]].

### Constraints

Constraints evaluate to a Boolean value. An **assert constraint**
subsets `trueEvaluations` (must always hold true). A **negated
assert constraint** (`assert not constraint`) subsets
`falseEvaluations` (must never hold true). Constraints are the
foundation for requirements, as `RequirementCheck` specialises
`ConstraintCheck`.

## See also

- [[sysml2-type-hierarchy]] for where each kind sits in the type
  tree.
- [[sysml2-specialisation-and-typing]] for `:>`, `:>>`, `ref`.
- [[sysml2-actions]], [[sysml2-state-machines]],
  [[sysml2-expressions-constraints]] for conceptual coverage of
  the behavioural elements.
- [[sysml2-allocations-overview]], [[sysml2-binding-connectors]]
  for the connection-based families.
