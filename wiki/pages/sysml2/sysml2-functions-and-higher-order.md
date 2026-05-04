---
title: "SysML 2.0 Functions, Invocations, and Higher-Order Operations"
slug: sysml2-functions-and-higher-order
type: reference
layer: sysml2
tags: [calculations, invocations, higher-order, lambda, classification]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 30, pages 198 to 206."
    raw: sysmlv2.pdf
related:
  - sysml2-expressions-overview
  - sysml2-sequences-and-structures
  - sysml2-expressions-constraints
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-expressions]
---

# SysML 2.0 Functions, Invocations, and Higher-Order Operations

This page covers calling functions and calculations, the
higher-order function library, and the classification expressions
for runtime type tests. For literal and operator expressions see
[[sysml2-expressions-overview]]. For sequences and structures see
[[sysml2-sequences-and-structures]].

## Invocation expressions

An invocation expression calls a function or calculation usage by
name and passes arguments in parentheses. Arguments are positional
or explicitly named (Ch 30, p 198).

```sysml
calc def Distance(a : Point, b : Point) : LengthValue;

// Positional invocation
attribute d1 = Distance(origin, target);

// Named binding
attribute d2 = Distance(a = origin, b = target);
```

### Function reference vs invocation

A calculation usage referenced **without** parentheses is a feature
reference, not an invocation. This is load-bearing for higher-order
use: the name alone refers to the calculation object itself, which
can be stored in a variable or passed as an argument (Ch 30, p 198).

```sysml
attribute calcFn = Distance;          // reference
attribute result = Distance(a, b);    // invocation
```

Add empty parentheses to invoke a no-argument calc.

### Function operation expressions

The `>>` notation chains the result of one expression into the
first operand of a function, reading left to right (Ch 30, p 199):

```sysml
attribute filtered = parts >> select { in p : Part => p.mass > 100 };
```

This is equivalent to calling `select(parts, lambda)` but reads
more naturally when chains are long.

## Higher-order functions

SysML 2.0 supports first-class functions: calculations and
function-typed features can be stored and passed as arguments.
**Function literals** are lambda-like bodies with no name, declaring
parameters in curly braces and returning an expression (Ch 30,
pp 200 to 204).

### Core higher-order functions (Control library)

Each of the following takes a sequence and a function parameter.

| Function | Behaviour | Mainstream analogue |
|---|---|---|
| `collect` | Maps a sequence through a single-input function and concatenates the results. | `map` or `flatMap`. |
| `select` | Filters a sequence by a Boolean predicate, retaining elements where the predicate returns `true`. | `filter`. |
| `selectOne` | Returns the first element that matches, or `null` if nothing matches. | `findFirst`. |
| `reject` | Complement of `select`: retains elements where the predicate is `false`. | `filterNot`. |
| `reduce` | Takes a two-input reducer function and accumulates a result over the sequence. | `fold` or `reduce`. |
| `forAll`, `allTrue` | Return `true` if the predicate holds for every element. | `all`. |
| `exists`, `anyTrue` | Return `true` if the predicate holds for any element. | `any`. |

### Operator notation for collect and select

Simplified syntax exists for `collect` (curly braces only) and
`select` (period plus curly braces), which reads more compactly in
common cases:

```sysml
// Collect: map each part to its mass
attribute masses = parts { in p : Part => p.mass };

// Select: filter parts by mass
attribute heavyParts = parts.{ in p : Part => p.mass > 100 };
```

## Classification expressions

Classification expressions test or cast the runtime type of a value
(Ch 30, pp 205 to 206).

| Expression | Meaning |
|---|---|
| `istype T` | Returns `true` if all values in the operand sequence are instances of `T` or a subtype of `T`. |
| `hastype T` | Returns `true` if all values are instances of **exactly** `T`, not a subtype. Violates Liskov substitution. Avoid unless intent is to exclude subtypes. |
| `@ T` (at) | Returns `true` if at least one value is an instance of `T`. |
| `as T` | Casts the sequence, retaining only values that are instances of `T`. Never raises a runtime error: non-matching values become `null`. |

```sysml
attribute isEngine = component istype Engine;
attribute engines = components as Engine;
```

The book warns that `hastype` violates the Liskov substitution
principle and should be avoided unless the intent is explicitly to
exclude subtypes (Ch 30, p 206).

## See also

- [[sysml2-expressions-overview]] for scalars and operators.
- [[sysml2-sequences-and-structures]] for the sequence operators
  that higher-order functions consume.
- [[sysml2-expressions-constraints]] for using expressions inside
  constraints and calculations.
- [[sysml2-expression-patterns]] for VSE-scale patterns.
