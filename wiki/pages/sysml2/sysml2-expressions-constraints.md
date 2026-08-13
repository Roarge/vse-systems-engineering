---
title: "SysML 2.0 Calculations and Constraints"
slug: sysml2-expressions-constraints
type: reference
layer: sysml2
summary: Calculations and constraints are the two main expression-bearing constructs in SysML 2.0
tags: [calculations, constraints, assert-constraint, calc-def]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-07 release. MBSE4U. Chapter 27, pages 203 to 206; Chapter 31, pages 253 to 255."
    raw: sysmlv2.pdf
related:
  - sysml2-expressions-overview
  - sysml2-functions-and-higher-order
  - sysml2-expression-patterns
  - sysml2-cases-overview
  - sysml2-actions
confidence: high
created: 2026-05-04
updated: 2026-08-13
referenced_by: [sysml2-expressions]
---

# SysML 2.0 Calculations and Constraints

## Contents

- Calculations
- Calculation usages
- Constraints
- Where constraints meet other surfaces
- Pending material in the source
- See also

Calculations and constraints are the two main expression-bearing
constructs in SysML 2.0. Calculations evaluate to a value, and
constraints evaluate to a Boolean and govern model validity.

## Calculations

A **calculation is an action with a dedicated return parameter**. The
reason for the construct is composability: because a calculation has
a designated result, it can be treated as that value, nested inside
another calculation or used wherever a value is expected, without
explicit parameter wiring. Cases are specialised calculations, and
constraints are calculations that return a Boolean (Ch 27, p 203).

A calculation definition is declared with `calc def`. Its body is an
action body, so everything that applies to action definitions applies
here unchanged: parameters, successions, control nodes, send and
accept actions, assignments, and any other action substep. The only
thing a calculation adds is the return parameter (Ch 27, p 203). See
[[sysml2-actions]].

```sysml
calc def ChargingTime {
    in capacity : ScalarValues::Real;
    capacity / 10.0
}

calc def FlightTime {
    in capacity : ScalarValues::Real;
    return time : ScalarValues::Real = capacity / 5.0;
}
```

`ChargingTime` uses the **implicit return** form, where the body ends
with an expression. `FlightTime` uses the **explicit return** form,
where the keyword `return` introduces a regular feature declaration
with a name, a type, and a bound value (Ch 27, pp 203 to 204,
Figure 27.1).

> **The semicolon asymmetry.** The implicit return expression at the
> end of the body does **not** take a semicolon, but the explicit
> return parameter does. This is a frequent mistake. A semicolon on
> the implicit form would terminate it as a regular statement and
> lead to an error (Ch 27, p 204).

Further rules (Ch 27, pp 203 to 204):

- There can be only **one** return parameter, and it always
  implicitly redefines the inherited `result` feature from
  `Evaluation` in the Performances library.
- The return parameter must have a name, a type, or both, even when
  it is bound to a value. A bare `return` with no name and no type is
  not allowed. Where neither a name nor a type is wanted, the
  implicit form is the cleaner choice.
- Parameters and the return value can be any kind of feature, not
  only attribute values. A calculation might receive a part as input,
  or return one, for example by selecting an element of a sequence
  according to some criterion.
- Calculations may also carry additional output parameters alongside
  the return parameter, but mixing the two is typically confusing.
  Use a calculation when there is a dedicated return value, and an
  action definition when there are multiple outputs.

Although a calculation body can technically contain anything an
action body can contain, the book strongly recommends keeping
calculations **side-effect-free**. Use them to compute values, not to
do things. Behaviour with side effects or multiple outputs belongs in
an action definition (Ch 27, p 204).

## Calculation usages

A calculation usage is introduced with the `calc` keyword and is
declared inside other types like any other usage (Ch 27, p 205).

```sysml
calc def MissionCycle {
    in capacity : ScalarValues::Real;

    calc charging : ChargingTime {
        in capacity = capacity;
    }
    calc flight : FlightTime {
        in capacity = capacity;
    }

    charging.result + flight.time
    // Alternatively:
    // ChargingTime(capacity) + FlightTime(capacity)
}
```

The final expression refers to `charging.result` and `flight.time` to
compute the total cycle time. The implicit return of `ChargingTime`
is reached through the inherited `result` name, and the explicit
return of `FlightTime` through the name it was given. **No succession
is needed**, because the dependencies between the calculation usages
are expressed by the expression itself (Ch 27, p 205, Figure 27.3).

In practice calculations are most often used in expressions, where
they are treated as their own return value, and there the definition
is usually invoked directly rather than declared as a usage. Because
a calculation usage is also an action usage, it can additionally
appear as a step in an action's flow, participating in successions
and control nodes like any other action usage. That is occasionally
useful but should not be the default pattern (Ch 27, pp 205 to 206).
See [[sysml2-functions-and-higher-order]] for the invocation forms.

## Constraints

A constraint is a logical predicate that evaluates to a Boolean. A
`constraint def` establishes the predicate and its parameters. A
`constraint` usage applies the predicate within a context. If the
predicate evaluates to `false` for a well-formed model, the model
or the real-world system fails to conform to the constraint
(Ch 31, pp 253 to 255).

### Constraint definitions

A constraint definition may declare input parameters and attributes
that store intermediate values. The body expression is a Boolean
formula over the parameters and any in-scope features.

```sysml
constraint def PowerBudget {
    in consumers [*] : PowerConsumer;
    in maxBudget : PowerValue;
    attribute totalPowerUsage : PowerValue =
        consumers->collect({in c [1] : PowerConsumer; c.powerDraw})
                 ->reduce({in a [1] : PowerValue; in b [1] : PowerValue; a + b});
    totalPowerUsage <= maxBudget
}
```

The body of a constraint is the final expression, which must
evaluate to Boolean. Attributes defined inside the constraint are
intermediate values, not results.

### assert constraint

An `assert constraint` usage applies a constraint directly in its
containing context and marks the model as invalid if the constraint
evaluates to `false`. The constraint reaches the containing context
through its parameters, which the usage binds to features of that
context, as the example below binds `consumers` to `powerConsumers`
(Ch 31, p 254). Reference subsetting, written `::>` or `references`,
is a different mechanism and is not what binds a constraint to its
context. There is no `>>` operator in SysML 2.0.

```sysml
part def Vehicle {
    attribute maxBudget : PowerValue;
    part powerConsumers : PowerConsumer[*];

    assert constraint PowerBudget {
        consumers = powerConsumers;
        maxBudget = this.maxBudget;
    }
}
```

### Negated assertions

A constraint can be inverted with the `not` keyword, which
specifies that the constraint should **never** be true:

```sysml
assert constraint not ForbiddenConfiguration;
```

The inverted form is useful for explicit safety-invariant
statements where the model author wants to say "this must never
happen" rather than "this must always hold" (Ch 31, p 254).

## Where constraints meet other surfaces

- **Cases**: analysis cases bind results through constraints, and
  verification cases verify requirements that may carry
  constraints. See [[sysml2-cases-overview]].
- **Variants**: cross-variation constraints expressed via `assert
  constraint` enforce valid variant combinations.
- **State machines**: guard conditions on transitions are
  constraint-style Boolean expressions.

## Pending material in the source

One upstream chapter remains pending in the 2026-07 release:

- **Chapter 86 Kernel Function Library**: function catalogue with
  signatures.

When it publishes, expect new pages or updates that add a full
function catalogue.

## See also

- [[sysml2-expressions-overview]] for the expression language used
  inside constraint and calc bodies.
- [[sysml2-actions]] for the action body a calculation body is.
- [[sysml2-functions-and-higher-order]] for invoking calcs from
  expressions.
- [[sysml2-expression-patterns]] for VSE-scale patterns.
