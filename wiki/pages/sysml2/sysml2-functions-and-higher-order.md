---
title: "SysML 2.0 Functions, Invocations, and Higher-Order Operations"
slug: sysml2-functions-and-higher-order
type: reference
layer: sysml2
summary: Calling functions and calculations, the higher-order function library, and runtime type tests
tags: [calculations, invocations, higher-order, lambda, classification]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-06 release. MBSE4U. Chapter 30, pages 243 to 252."
    raw: sysmlv2.pdf
related:
  - sysml2-expressions-overview
  - sysml2-sequences-and-structures
  - sysml2-expressions-constraints
confidence: high
created: 2026-05-04
updated: 2026-08-10
referenced_by: [sysml2-expressions]
---

# SysML 2.0 Functions, Invocations, and Higher-Order Operations

## Contents

- Invocation expressions
- Higher-order functions
- Classification expressions
- See also

This page covers calling functions and calculations, the
higher-order function library, and the classification expressions
for runtime type tests. For literal and operator expressions see
[[sysml2-expressions-overview]]. For sequences and structures see
[[sysml2-sequences-and-structures]].

## Invocation expressions

An invocation expression calls a function or calculation usage by
name and passes arguments in parentheses. Arguments are positional
or explicitly named (Ch 30, p 243).

```sysml
calc def Distance {
    in a : Point;
    in b : Point;
    return : LengthValue;
}

// Positional invocation
attribute d1 = Distance(origin, target);

// Named binding
attribute d2 = Distance(a = origin, b = target);
```

### Function reference vs invocation

A calculation usage referenced **without** parentheses is a feature
reference, not an invocation. This is load-bearing for higher-order
use: the name alone refers to the calculation object itself, which
can be stored in a variable or passed as an argument (Ch 30, p 243).

```sysml
attribute calcFn = Distance;          // reference
attribute result = Distance(a, b);    // invocation
```

Add empty parentheses to invoke a no-argument calc.

### Function operation expressions

The first parameter of a function often represents a subject on which
the operation is performed. A **function operation expression** puts
that first operand before the arrow symbol `->`, which precedes the
name of the invoked function, so results chain left to right
(Ch 30, p 244).

```sysml
calc def SelectLeader {
    private import SequenceFunctions::excluding;
    in part activeDrones [*];
    in part damagedDrones [*];
    activeDrones->excluding(damagedDrones)->NominateLeader()
}
```

Here `activeDrones` feeds into `excluding`, which takes its second
argument between parentheses. The result is the set of active,
undamaged drones, which feeds into `NominateLeader` as its first and
only argument, so nothing sits between the mandatory parentheses
(Ch 30, pp 244 to 245, Figure 30.9).

`->` is the only chaining symbol in the expression language. There is
no `>>` operator.

## Higher-order functions

SysML 2.0 supports first-class functions: calculations and
function-typed features can be stored and passed as arguments. A
**function literal** is declared like a calculation body with no
name, between curly braces, declaring all the parameters and then the
return expression. Each parameter declaration ends in a semicolon and
the body expression follows them (Ch 30, p 245).

```sysml
part def LeaderSelector {
    private import SequenceFunctions::*;

    attribute preferFirst : ScalarValues::Boolean;
    calc nominateFirst = { in part drones; drones->head() };
    calc nominateLast = { in part drones; drones->tail() };
    calc nominate = if preferFirst ? nominateFirst else nominateLast;
}
```

The pairing of the name `nominateLast` with `tail` is the book's own:
`tail` returns the trailing subsequence, not a single element. A model
that needs exactly one leader from the end of the sequence uses
`last(drones)` instead.

A function literal evaluates to a calculation instance that can be
passed into a higher-order function or assigned to a calculation
usage. At the time of writing it cannot be invoked directly
(Ch 30, pp 245 to 246, Figure 30.10). The language has no arrow-style
lambda form, so a parameter list followed by an arrow and a body is
not valid syntax.

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

### Notations for collect and select

Every higher-order function with the collect signature (a sequence
and an expression) allows two shorthands on the function operation
form (Ch 30, p 246).

- The parentheses may be omitted when the second parameter is a
  function literal and there are no other parameters, giving
  `drones->collect{...}`.
- When the second parameter would simply be an invocation of a
  function or calculation definition, referring to it by name is
  enough, giving `drones->collect GetAbortedTargets`.

`collect` and `select` additionally have an **operator notation**. For
`collect` the first operand is given before a dot and the second
operand must be a function literal, so the curly braces are what
distinguish it from a feature chain expression. For `select` the
symbol is `.?`, read as "collect if", and the second operand must be
a Boolean function literal (Ch 30, pp 246 to 247).

```sysml
out item current [*] = collect(drones, {in drone [1] : Drone; drone.currentTarget});
out item past [*] = drones->collect({in drone [1] : Drone; drone.pastTargets});
out item succeeded = drones->collect{in drone [1] : Drone; drone.successfulTargets};
out item failed = drones.{in drone [1] : Drone; drone.failedTargets};
out item aborted = drones->collect GetAbortedTargets;
out part damaged [*] = drones.?{in drone [1] : Drone; drone.isDamaged};
```

The book recommends the function operation expression with
parentheses, or the operator notation, to balance compactness against
clarity (Ch 30, p 247).

## Classification expressions

Classification expressions test or cast the runtime type of a value
(Ch 30, pp 250 to 252).

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
exclude subtypes (Ch 30, p 251).

## See also

- [[sysml2-expressions-overview]] for scalars and operators.
- [[sysml2-sequences-and-structures]] for the sequence operators
  that higher-order functions consume.
- [[sysml2-expressions-constraints]] for using expressions inside
  constraints and calculations.
- [[sysml2-expression-patterns]] for VSE-scale patterns.
