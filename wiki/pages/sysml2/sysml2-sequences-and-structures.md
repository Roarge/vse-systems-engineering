---
title: "SysML 2.0 Sequences and Complex Structures"
slug: sysml2-sequences-and-structures
type: reference
layer: sysml2
tags: [sequences, structures, indexing, feature-chains, constructor]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 30, pages 193 to 197."
    raw: sysmlv2.pdf
related:
  - sysml2-expressions-overview
  - sysml2-functions-and-higher-order
  - sysml2-occurrences-4d
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-expressions]
---

# SysML 2.0 Sequences and Complex Structures

When a feature has multiplicity other than `[1]`, it holds a
**sequence** of values. SysML 2.0 treats every value as a sequence,
so a scalar is a sequence of length one. The scalar operators
covered in [[sysml2-expressions-overview]] only apply to sequences
of length one. Longer sequences use dedicated sequence operators
(Ch 30, p 193).

## Sequence terms

```sysml
// Empty sequence
attribute emptyList = null;      // or ()

// Comma-separated sequence
attribute primes = (2, 3, 5, 7, 11);

// Integer range (inclusive on both ends)
attribute week = 1..7;

// Extent expression (all instances of a type visible in context)
attribute allVehicles = all Vehicle;
```

The `all TypeName` form returns every instance of `TypeName`,
including instances that are not reachable from the current
context. The book notes that this is difficult to implement in real
systems and should be used with care (Ch 30, p 194).

## Sequence functions

Key sequence functions are grouped by purpose:

- **Comparison**: `equals`, `same`, `includesOnly`, `includes`,
  `excludes`.
- **Size**: `size`, `isEmpty`, `notEmpty`.
- **Combination**: `union`, `intersection`, `including`,
  `includingAt`, `excluding`, `excludingAt`.
- **Indexing**: the `#` operator accesses the element at a 1-based
  index, for example `primes#3` evaluates to `5`. Out-of-range
  indexing returns `null`.
- **Subsequencing**: `subsequence`, `head`, `tail`, `last`.

**Indexing is 1-based, not 0-based** (Ch 30, p 195). This is the
most common stumble for SysML authors arriving from a programming
background.

## Constructor expressions

Constructor expressions create a new instance of a type. They use
the `new` keyword, followed by the type name and a comma-separated
argument list. Arguments bind to public features in order, or
explicitly by name using `featureName = expression`. Partial
binding is allowed, and unspecified features without defaults
remain unconstrained (Ch 30, p 196).

```sysml
attribute origin = new Point3D(x = 0, y = 0, z = 0);
attribute shifted = new Point3D(1, 2, 3);
```

## Feature chain expressions

Feature chain expressions navigate structured data using dot
notation. A chain is an expression, a dot, and a feature name,
optionally continued. Chains **flatten sequences** at each step,
concatenating values from every intermediate result into a single
flat sequence (Ch 30, p 197).

```sysml
attribute allWheelRadii = vehicle.wheels.radius;
```

Feature chain flattening can cause unexpected multiplicity
explosion in deep navigation. Navigating `vehicle.wheels.bolts`
concatenates all bolts of all wheels into one flat sequence, which
may surprise authors expecting a nested structure. See
[[sysml2-expression-patterns]] for the gotcha.

## Occurrence equality operators

For occurrences with spatial and temporal portions, `===` and `!==`
check whether two values belong to the **same whole** (the same
life or instance), which is stronger than value equality. Standard
`==` checks value equality. `===` checks identity across time.

For full semantics of occurrences and lifelines, see
[[sysml2-occurrences-4d]] (new in the 2026-04 release of the SysML
v2 book).

## See also

- [[sysml2-expressions-overview]] for scalar values and operators.
- [[sysml2-functions-and-higher-order]] for `collect`, `select`,
  and other sequence-consuming functions.
- [[sysml2-expression-patterns]] for VSE-scale patterns.
