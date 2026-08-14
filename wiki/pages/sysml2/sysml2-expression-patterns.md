---
title: "SysML 2.0 Expression Patterns and Gotchas"
slug: sysml2-expression-patterns
type: pattern
layer: sysml2
summary: Practical patterns and recurring mistakes for expressions, calculations, and constraints
tags: [expressions, patterns, gotchas, vse]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-07 release. MBSE4U. Chapter 30, pages 233 to 252; Chapter 31, pages 253 to 255."
    raw: sysmlv2.pdf
related:
  - sysml2-expressions-overview
  - sysml2-sequences-and-structures
  - sysml2-functions-and-higher-order
  - sysml2-expressions-constraints
confidence: high
created: 2026-05-04
updated: 2026-08-14
referenced_by: [sysml2-expressions]
---

# SysML 2.0 Expression Patterns and Gotchas

## Contents

- VSE authoring patterns
- Gotchas and red flags
- Pending chapters

This page collects practical patterns and recurring mistakes for
expressions, calculations, and constraints. For declaration syntax
see [[sysml2-expressions-overview]],
[[sysml2-sequences-and-structures]],
[[sysml2-functions-and-higher-order]], and
[[sysml2-expressions-constraints]].

## VSE authoring patterns

### Aggregate a quantity across parts

Use `collect` to project each part to its quantity, then `reduce`
to sum. The chaining symbol is `->`, and each function literal
declares its parameters before the body expression:

```sysml
part def Vehicle {
    part components [*] : Component;
    attribute totalMass : MassValue =
        components->collect({in c [1] : Component; c.mass})
                  ->reduce({in a [1] : MassValue; in b [1] : MassValue; a + b});
}
```

### Constraint over all instances

Use `forAll` inside a constraint body to assert a predicate across
every element of a sequence:

```sysml
constraint def AllRequirementsSatisfied {
    in requirements [*] : Requirement;
    requirements->forAll({in r [1] : Requirement; r.isSatisfied})
}
```

### Filter parts by condition

Use `select` with its operator notation `.?`, read as "collect if",
for concise filtering. The plain `.{...}` form is the operator
notation for `collect`, so it would collect the Booleans rather than
filter on them:

```sysml
attribute heavyComponents = components.?{in c [1] : Component; c.mass > 100[kg]};
```

### Parametric trade study input

Define a calc with trade-space parameters and invoke it inside an
assert constraint to enforce the trade bound:

```sysml
calc def CostPerformanceRatio {
    in cost : MonetaryValue;
    in performance : Real;
    return : Real = cost / performance;
}

assert constraint {
    CostPerformanceRatio(totalCost, measuredPerformance) < targetRatio
}
```

### Chain navigation and operation

Combine feature chains and higher-order functions to avoid
intermediate attributes:

```sysml
attribute criticalWheelRadii = vehicle.wheels.?{in w [1] : Wheel; w.isCritical}.radius;
```

## Gotchas and red flags

### Logical operators evaluate all operands

Use the control operators `and`, `or`, `implies` if short-circuit
evaluation matters (Ch 30, p 236).

### Indexing is 1-based and takes parentheses

`primes#(1)` is the first element, not the second, and the index
operand must be enclosed in parentheses. Out-of-range indexing
returns `null`, not an error (Ch 30, p 240). This is the most common
stumble for authors arriving from a programming background.

### The chaining symbol is `->`, not `>>`

Function operation expressions put the first operand before `->`,
which precedes the invoked function's name. `>>` is not an operator
in the expression language (Ch 30, p 244).

### A function literal declares parameters, it does not use an arrow

A function literal is a calculation body with no name between curly
braces: parameter declarations first, then the body expression, as in
`{in drone [1] : Drone; drone.currentTarget}`. The language has no
arrow-style lambda form, so a parameter list followed by an arrow and
a body is not valid syntax (Ch 30, p 245).

### There are no negative literals

A value like `-5` is the operator `-` applied to the literal `5`.
This shows up in error messages and grammar diagnostics
(Ch 30, p 235).

### `hastype` breaks Liskov substitution

Prefer `istype` unless the intent is to explicitly exclude subtypes
(Ch 30, p 251).

### A calc name without parentheses is a reference, not an invocation

This matters when passing calcs to higher-order functions. Add
empty parentheses to invoke a no-argument calc (Ch 30, p 243).

### Feature chain flattening can explode multiplicity

Navigating `vehicle.wheels.bolts` concatenates all bolts of all
wheels into one flat sequence, which may surprise authors expecting
a nested structure (Ch 30, p 242).

### Null is a value, not an error

Setting a feature with minimum multiplicity 1 to `null` produces a
runtime error in simulators, not a compile-time rejection
(Ch 30, p 238).

### `all TypeName` returns unreachable instances

Extent expressions are semantically global and include instances
not visible from the current context. Use with care in large models
(Ch 30, p 239).

## Pending chapters

The 2026-07 release leaves the following upstream material pending:

- **Chapter 59 KerML Expressions**: formal layer semantics, the
  delta between SysML surface and KerML metamodel foundation.
- **Chapter 86 Kernel Function Library**: full function catalogue
  with signatures and one-line purposes covering 17 subsections
  (base, Boolean, collection, complex, control, data, integer,
  natural, numerical, occurrence, rational, real, scalar, sequence,
  string, trigonometry, vector).

Until then, authors should consult the Syside editor's completion
and the OMG Systems Modeling Language v2.0 specification (March
2023, formal/2025-01-01) for the library function surface. When
these chapters publish, the relevant pages will be updated and
`confidence` revisited.
