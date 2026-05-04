---
title: "SysML 2.0 Expression Patterns and Gotchas"
slug: sysml2-expression-patterns
type: pattern
layer: sysml2
tags: [expressions, patterns, gotchas, vse]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 30, pages 189 to 206; Chapter 31, pages 208 to 210."
    raw: sysmlv2.pdf
related:
  - sysml2-expressions-overview
  - sysml2-sequences-and-structures
  - sysml2-functions-and-higher-order
  - sysml2-expressions-constraints
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-expressions]
---

# SysML 2.0 Expression Patterns and Gotchas

This page collects practical patterns and recurring mistakes for
expressions, calculations, and constraints. For declaration syntax
see [[sysml2-expressions-overview]],
[[sysml2-sequences-and-structures]],
[[sysml2-functions-and-higher-order]], and
[[sysml2-expressions-constraints]].

## VSE authoring patterns

### Aggregate a quantity across parts

Use `collect` to project each part to its quantity, then `reduce`
to sum:

```sysml
part def Vehicle {
    part components : Component[*];
    attribute totalMass : MassValue =
        components >> collect { in c : Component => c.mass }
                   >> reduce { in a, b => a + b };
}
```

### Constraint over all instances

Use `forAll` inside a constraint body to assert a predicate across
every element of a sequence:

```sysml
constraint def AllRequirementsSatisfied {
    in requirements : Requirement[*];
    requirements >> forAll { in r : Requirement => r.isSatisfied }
}
```

### Filter parts by condition

Use `select` with operator notation for concise filtering:

```sysml
attribute heavyComponents = components.{ in c : Component => c.mass > 100[kg] };
```

### Parametric trade study input

Define a calc with trade-space parameters and invoke it inside an
assert constraint to enforce the trade bound:

```sysml
calc def CostPerformanceRatio(cost : MonetaryValue, performance : Real) : Real
    = cost / performance;

assert constraint CostPerformanceRatio(totalCost, measuredPerformance) < targetRatio;
```

### Chain navigation and operation

Combine feature chains and higher-order functions to avoid
intermediate attributes:

```sysml
attribute criticalWheelRadii = vehicle.wheels.{ in w : Wheel => w.isCritical }.radius;
```

## Gotchas and red flags

### Logical operators evaluate all operands

Use the control operators `and`, `or`, `implies` if short-circuit
evaluation matters (Ch 30, p 191).

### Indexing is 1-based

`primes#1` is the first element, not the second. Out-of-range
indexing returns `null`, not an error (Ch 30, p 195). This is the
most common stumble for authors arriving from a programming
background.

### There are no negative literals

A value like `-5` is the operator `-` applied to the literal `5`.
This shows up in error messages and grammar diagnostics
(Ch 30, p 191).

### `hastype` breaks Liskov substitution

Prefer `istype` unless the intent is to explicitly exclude subtypes
(Ch 30, p 206).

### A calc name without parentheses is a reference, not an invocation

This matters when passing calcs to higher-order functions. Add
empty parentheses to invoke a no-argument calc (Ch 30, p 198).

### Feature chain flattening can explode multiplicity

Navigating `vehicle.wheels.bolts` concatenates all bolts of all
wheels into one flat sequence, which may surprise authors expecting
a nested structure (Ch 30, p 197).

### Null is a value, not an error

Setting a feature with minimum multiplicity 1 to `null` produces a
runtime error in simulators, not a compile-time rejection
(Ch 30, p 194).

### `all TypeName` returns unreachable instances

Extent expressions are semantically global and include instances
not visible from the current context. Use with care in large models
(Ch 30, p 194).

## Pending chapters

The 2026-04 release leaves the following upstream material pending:

- **Chapter 27 Calculations**: authoring patterns, parametric
  modelling, binding to parts.
- **Chapter 59 KerML Expressions**: formal layer semantics, the
  delta between SysML surface and KerML metamodel foundation.
- **Chapter 86 Kernel Function Library**: full function catalogue
  with signatures and one-line purposes covering 17 subsections
  (base, Boolean, collection, complex, control, data, integer,
  natural, numerical, occurrence, rational, real, scalar, sequence,
  string, trigonometry, vector).

Until then, authors should consult the SySiDE editor's completion
and the OMG Systems Modeling Language v2.0 specification (March
2023, formal/2025-01-01) for the library function surface. When
these chapters publish, the relevant pages will be updated and
`confidence` revisited.
