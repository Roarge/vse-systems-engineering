---
title: "SysML 2.0 Calculations and Constraints"
slug: sysml2-expressions-constraints
type: reference
layer: sysml2
tags: [calculations, constraints, assert-constraint, calc-def]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 27, page 168; Chapter 31, pages 208 to 210."
    raw: sysmlv2.pdf
related:
  - sysml2-expressions-overview
  - sysml2-functions-and-higher-order
  - sysml2-expression-patterns
  - sysml2-cases-overview
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-expressions]
---

# SysML 2.0 Calculations and Constraints

Calculations and constraints are the two main expression-bearing
constructs in SysML 2.0. Calculations evaluate to a value;
constraints evaluate to a Boolean and govern model validity.

## Calculations (Chapter 27)

Chapter 27 of the SysML v2 book is **stubbed in the 2026-04
release**. The chapter is named in the table of contents but the
body has not yet been published. Until it lands, practical
calculation authoring draws on the quick-reference syntax and on
the invocation semantics covered in
[[sysml2-functions-and-higher-order]].

Key things to remember when authoring calculations now:

- A `calc def` declares a parametric calculation with named input
  parameters and a result expression.
- A `calc` usage applies a calculation in a context, typically
  binding parameters to features of the containing part.
- Calculations specialise the library type
  `Calculations::Calculation`.
- A `calc` has a body expression that evaluates when the
  calculation is invoked.

```sysml
calc def CostPerformanceRatio(cost : MonetaryValue, performance : Real) : Real {
    cost / performance
}

calc def MassRollup(parts : Part[*]) : MassValue {
    parts >> collect { in p : Part => p.mass } >> reduce { in a, b => a + b }
}
```

Confidence on calculation authoring may need revision when Chapter
27 publishes its full treatment.

## Constraints

A constraint is a logical predicate that evaluates to a Boolean. A
`constraint def` establishes the predicate and its parameters. A
`constraint` usage applies the predicate within a context. If the
predicate evaluates to `false` for a well-formed model, the model
or the real-world system fails to conform to the constraint
(Ch 31, pp 208 to 210).

### Constraint definitions

A constraint definition may declare input parameters and attributes
that store intermediate values. The body expression is a Boolean
formula over the parameters and any in-scope features.

```sysml
constraint def PowerBudget {
    in consumers : PowerConsumer[*];
    attribute totalPowerUsage : PowerValue =
        consumers >> collect { in c : PowerConsumer => c.powerDraw }
                  >> reduce { in a, b => a + b };
    totalPowerUsage <= maxBudget
}
```

The body of a constraint is the final expression, which must
evaluate to Boolean. Attributes defined inside the constraint are
intermediate values, not results.

### assert constraint

An `assert constraint` usage applies a constraint directly in its
containing context and marks the model as invalid if the constraint
evaluates to `false`. The containing context is available inside
the constraint through reference subsetting with the `>>` operator
(Ch 31, p 209).

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
happen" rather than "this must always hold" (Ch 31, p 210).

## Where constraints meet other surfaces

- **Cases**: analysis cases bind results through constraints, and
  verification cases verify requirements that may carry
  constraints. See [[sysml2-cases-overview]].
- **Variants**: cross-variation constraints expressed via `assert
  constraint` enforce valid variant combinations.
- **State machines**: guard conditions on transitions are
  constraint-style Boolean expressions.

## Pending material in the source

Two upstream chapters remain pending in the 2026-04 release:

- **Chapter 27 Calculations**: authoring patterns, parametric
  modelling, binding to parts.
- **Chapter 86 Kernel Function Library**: function catalogue with
  signatures.

When these publish, expect new pages or updates that add full
calculation semantics and a function catalogue.

## See also

- [[sysml2-expressions-overview]] for the expression language used
  inside constraint and calc bodies.
- [[sysml2-functions-and-higher-order]] for invoking calcs from
  expressions.
- [[sysml2-expression-patterns]] for VSE-scale patterns.
