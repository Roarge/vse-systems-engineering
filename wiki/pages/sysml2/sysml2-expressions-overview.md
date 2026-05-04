---
title: "SysML 2.0 Expressions Overview and Scalar Values"
slug: sysml2-expressions-overview
type: reference
layer: sysml2
tags: [expressions, operators, scalars, literals]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 30, pages 189 to 193."
    raw: sysmlv2.pdf
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Chapter 30."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-sequences-and-structures
  - sysml2-functions-and-higher-order
  - sysml2-expressions-constraints
  - sysml2-expression-patterns
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-expressions]
---

# SysML 2.0 Expressions Overview and Scalar Values

SysML 2.0 introduces a native expression language usable inside
feature values, constraints, calculations, guard conditions, and
any context where a value is needed. Expressions parse into
expression trees whose internal nodes are operators and whose leaf
nodes are literals and references. Each node in the tree maps to a
concrete modelling element, so an expression is itself a model
object, not an opaque string (Ch 30, p 189).

## Expression categories

An expression belongs to one of the following categories:

- **Literal expressions** return a primitive value such as an
  integer, rational, Boolean, or string.
- **Feature reference expressions** look up the value of a named
  feature through a qualified or unqualified name.
- **Operator expressions** combine operands with a built-in
  operator such as `+`, `and`, or `<`.
- **Invocation expressions** call a function or calculation and
  evaluate to its result. See [[sysml2-functions-and-higher-order]].
- **Body expressions** contain the actual formula of a calc
  definition, constraint, or lambda.

## Operator groups

Operators fall into four groups:

- **Numerical**: addition, subtraction, multiplication, division,
  remainder, exponentiation.
- **Logical**: `and`, `or`, `xor`, `not`.
- **Comparison**: `==`, `!=`, `<`, `>`, `<=`, `>=`.
- **Control**: conditional test, short-circuit logical operators,
  null-coalescing.

The unary `+` is syntactically legal but has no effect. The unary
`-` constructs a negation operator expression whose operand is a
positive literal, because there are no negative-number literals in
the grammar (Ch 30, p 191).

## Scalar values

Scalar values encompass Boolean, numerical (integer, natural,
rational, real, complex), and string primitives. These sit in the
`ScalarValues` library. A literal expression returns a single
literal from one of these primitive datatypes. Boolean literals
are `true` and `false`. String literals use double quotes with
backslash escaping. Rational literals include an optional decimal
point and optional exponent, for example `6.626E-34`.

### Numerical operators

The numerical operators have standard precedence:

```sysml
attribute totalMass : MassValue = m1 + m2 + m3;
attribute efficiency = outputPower / inputPower;
attribute area = width * height;
attribute remainder = count % 10;
attribute energy = mass * velocity ** 2 / 2;
```

The `^` and `**` operators both mean exponentiation. The unary `+`
is a no-op. The unary `-` takes a positive literal or expression
and negates it (Ch 30, p 191).

### Logical operators

SysML 2.0 distinguishes two families of logical operators.

The **standard logical operators** `&`, `|`, `xor`, and `not`
always evaluate both operands and return a Boolean result.

The **control operators** `and`, `or`, and `implies` are
short-circuit: the right-hand operand is only evaluated if the
left-hand operand does not already determine the result. Use the
control operators when the right-hand side has side effects or is
only well-defined under a condition checked by the left-hand side
(Ch 30, p 191).

### Comparison operators

Comparison operators work on numerical operands, with the exception
of equality `==` and inequality `!=` which work on any value. All
comparison operators return Boolean.

### String operations

String concatenation uses the `+` operator. Library functions
provide `Length` and `SubString` (with start and end indices).
Conversion functions include `ToString`, `ToComplex`, `ToReal`,
`ToRational`, `ToInteger`, `ToNatural` (Ch 30, p 193).

## See also

- [[sysml2-sequences-and-structures]] for non-scalar values.
- [[sysml2-functions-and-higher-order]] for invocations and
  higher-order functions.
- [[sysml2-expressions-constraints]] for the constraint and
  calculation surfaces that use expressions.
- [[sysml2-expression-patterns]] for VSE-scale patterns and gotchas.
