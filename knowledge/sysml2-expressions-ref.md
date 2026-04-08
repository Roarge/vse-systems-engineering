# SysML v2 Expressions and Constraints Reference

Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U, 2026-03 release.
Chapter and page citations appear inline. This file paraphrases the source, which is
a copyrighted commercial reference and is not reproduced verbatim. The kernel function
library (Ch 86), the KerML expressions reference (Ch 59), and the Calculations chapter
(Ch 27) are marked as pending in the 2026-03 release. This file will be extended when
those chapters are published.

---

## 1. Expression Language Overview (Ch 30, p 189)

SysML v2 introduces a native expression language usable inside feature values, constraints,
calculations, guard conditions, and any context where a value is needed. Expressions parse
into expression trees whose internal nodes are operators and whose leaf nodes are literals
and references. Each node in the tree maps to a concrete modelling element, so an
expression is itself a model object, not an opaque string.

An expression belongs to one of the following categories:

- **Literal expressions** return a primitive value such as an integer, rational, Boolean,
  or string.
- **Feature reference expressions** look up the value of a named feature through a
  qualified or unqualified name.
- **Operator expressions** combine operands with a built-in operator such as `+`, `and`,
  or `<`.
- **Invocation expressions** call a function or calculation and evaluate to its result.
- **Body expressions** contain the actual formula of a calc definition, constraint, or
  lambda.

Operators fall into four groups: numerical (addition, subtraction, multiplication,
division, remainder, exponentiation), logical (`and`, `or`, `xor`, `not`), comparison
(`==`, `!=`, `<`, `>`, `<=`, `>=`), and control (conditional test, short-circuit logical
operators, null-coalescing). The unary `+` is syntactically legal but has no effect. The
unary `-` constructs a negation operator expression whose operand is a positive literal,
because there are no negative-number literals in the grammar (Ch 30, p 191).

---

## 2. Scalar Values (Ch 30.1, pp 190-193)

Scalar values encompass Boolean, numerical (integer, natural, rational, real, complex),
and string primitives. These sit in the `ScalarValues` library. A literal expression
returns a single literal from one of these primitive datatypes. Boolean literals are
`true` and `false`. String literals use double quotes with backslash escaping. Rational
literals include an optional decimal point and optional exponent, for example
`6.626E-34`.

### 2.1 Numerical Operators

The numerical operators are listed in Ch 30.1 with standard precedence:

```sysml
attribute totalMass : MassValue = m1 + m2 + m3;
attribute efficiency = outputPower / inputPower;
attribute area = width * height;
attribute remainder = count % 10;
attribute energy = mass * velocity ** 2 / 2;
```

The `^` and `**` operators both mean exponentiation. The unary `+` is a no-op. The unary
`-` takes a positive literal or expression and negates it (Ch 30, p 191).

### 2.2 Logical Operators

`and`, `or`, `xor`, and `not` return Boolean results. **All operands are always
evaluated**, unlike in many programming languages. If short-circuit evaluation is needed,
use the dedicated control operators `a and b`, `a or b`, `a implies b`, which are listed
in Ch 30 as a separate category (Ch 30, p 191).

### 2.3 Comparison Operators

Comparison operators work on numerical operands, with the exception of equality `==` and
inequality `!=` which work on any value. All comparison operators return Boolean.

### 2.4 String Operations

String concatenation uses the `+` operator. Library functions provide `Length` and
`SubString` (with start and end indices). Conversion functions include `ToString`,
`ToComplex`, `ToReal`, `ToRational`, `ToInteger`, `ToNatural` (Ch 30, p 193).

---

## 3. Sequences (Ch 30.2, pp 193-195)

When a feature has multiplicity other than `[1]`, it holds a **sequence** of values. SysML
v2 treats every value as a sequence, so a scalar is a sequence of length one. The scalar
operators only apply to sequences of length one. Longer sequences use dedicated sequence
operators.

### 3.1 Sequence Terms

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

The `all TypeName` form returns every instance of `TypeName`, including instances that
are not reachable from the current context. The book notes that this is difficult to
implement in real systems and should be used with care (Ch 30, p 194).

### 3.2 Sequence Functions

Key sequence functions are grouped by purpose:

- **Comparison**: `equals`, `same`, `includesOnly`, `includes`, `excludes`.
- **Size**: `size`, `isEmpty`, `notEmpty`.
- **Combination**: `union`, `intersection`, `including`, `includingAt`, `excluding`,
  `excludingAt`.
- **Indexing**: the `#` operator accesses the element at a 1-based index, for example
  `primes#3` evaluates to `5`. Out-of-range indexing returns `null`.
- **Subsequencing**: `subsequence`, `head`, `tail`, `last`.

**Indexing is 1-based, not 0-based** (Ch 30, p 195). This is the most common stumble for
SysML authors arriving from a programming background.

---

## 4. Complex Structures (Ch 30.3, pp 196-197)

### 4.1 Constructor Expressions

Constructor expressions create a new instance of a type. They use the `new` keyword,
followed by the type name and a comma-separated argument list. Arguments bind to public
features in order, or explicitly by name using `featureName = expression`. Partial
binding is allowed, and unspecified features without defaults remain unconstrained
(Ch 30, p 196).

```sysml
attribute origin = new Point3D(x = 0, y = 0, z = 0);
attribute shifted = new Point3D(1, 2, 3);
```

### 4.2 Feature Chain Expressions

Feature chain expressions navigate structured data using dot notation. A chain is an
expression, a dot, and a feature name, optionally continued. Chains flatten sequences at
each step, concatenating values from every intermediate result into a single flat
sequence (Ch 30, p 197).

```sysml
attribute allWheelRadii = vehicle.wheels.radius;
```

Feature chain flattening can cause unexpected multiplicity explosion in deep navigation,
which is flagged as a gotcha in Section 13.

### 4.3 Occurrence Equality Operators

For occurrences with spatial and temporal portions, `===` and `!==` check whether two
values belong to the **same whole** (the same life or instance), which is stronger than
value equality. The book cross-references occurrence-specific comparison functions in
Ch 86.10 (not yet published).

---

## 5. Invoking Functions and Calculations (Ch 30.4, pp 198-199)

An invocation expression calls a function or calculation usage by name and passes
arguments in parentheses. Arguments are positional or explicitly named.

```sysml
calc def Distance(a : Point, b : Point) : LengthValue;

// Positional invocation
attribute d1 = Distance(origin, target);

// Named binding
attribute d2 = Distance(a = origin, b = target);
```

### 5.1 Function vs Feature Reference to a Calc

A calculation usage referenced **without** parentheses is a feature reference, not an
invocation. This is load-bearing for higher-order use: the name alone refers to the
calculation object itself, which can be stored in a variable or passed as an argument
(Ch 30, p 198).

### 5.2 Function Operation Expressions

The `>>` notation chains the result of one expression into the first operand of a
function, reading left to right:

```sysml
attribute filtered = parts >> select { in p : Part => p.mass > 100 };
```

This is equivalent to calling `select(parts, lambda)` but reads more naturally when
chains are long (Ch 30, p 199).

---

## 6. Higher-Order Functions (Ch 30.5, pp 200-204)

SysML v2 supports first-class functions: calculations and function-typed features can be
stored and passed as arguments. **Function literals** are lambda-like bodies with no
name, declaring parameters in curly braces and returning an expression.

### 6.1 Core Higher-Order Functions (Control Library)

Each of the following takes a sequence and a function parameter.

- **`collect`** maps a sequence through a single-input function and concatenates the
  results. Equivalent to `map` or `flatMap` in mainstream languages.
- **`select`** filters a sequence by a Boolean predicate, retaining elements where the
  predicate returns `true`.
- **`selectOne`** returns the first element that matches, or `null` if nothing matches.
- **`reject`** is the complement of `select`: retains elements where the predicate is
  `false`.
- **`reduce`** takes a two-input reducer function and accumulates a result over the
  sequence. Useful for sums, products, and other aggregations.
- **`forAll`**, **`allTrue`**: return `true` if the predicate holds for every element.
- **`exists`**, **`anyTrue`**: return `true` if the predicate holds for any element.

### 6.2 Operator Notation for collect and select

Simplified syntax exists for `collect` (curly braces only) and `select` (period plus
curly braces), which reads more compactly in common cases:

```sysml
// Collect: map each part to its mass
attribute masses = parts { in p : Part => p.mass };

// Select: filter parts by mass
attribute heavyParts = parts.{ in p : Part => p.mass > 100 };
```

---

## 7. Classification Expressions (Ch 30.6, pp 205-206)

Classification expressions test or cast the runtime type of a value.

- **`istype T`** returns `true` if all values in the operand sequence are instances of `T`
  or a subtype of `T`.
- **`hastype T`** returns `true` if all values are instances of **exactly** `T`, not a
  subtype. The book warns that `hastype` violates the Liskov substitution principle and
  should be avoided unless the intent is explicitly to exclude subtypes (Ch 30, p 206).
- **`@` (at)** returns `true` if at least one value is an instance of `T`.
- **`as T`** casts the sequence, retaining only values that are instances of `T`. Never
  raises a runtime error: non-matching values become `null`.

```sysml
attribute isEngine = component istype Engine;
attribute engines = components as Engine;
```

---

## 8. Calculations (Ch 27, p 168)

**Ch 27 is not yet published in the 2026-03 release of the book.** The book structure
lists calculations as a first-class modelling construct, but the chapter body is marked
for a later release.

Until Ch 27 is published, practical calculation authoring draws on the quick-reference
syntax in `sysml2-quick-ref.md` and on the invocation semantics in Ch 30.4 above. Key
things to remember:

- A `calc def` declares a parametric calculation with named input parameters and a
  result expression.
- A `calc` usage applies a calculation in a context, typically binding parameters to
  features of the containing part.
- Calculations specialise the library type `Calculations::Calculation`.
- A `calc` has a body expression that evaluates when the calculation is invoked.

---

## 9. Constraints (Ch 31, pp 208-210)

A constraint is a logical predicate that evaluates to a Boolean. A `constraint def`
establishes the predicate and its parameters. A `constraint` usage applies the predicate
within a context. If the predicate evaluates to `false` for a well-formed model, the model
or the real-world system fails to conform to the constraint.

### 9.1 Constraint Definitions

A constraint definition may declare input parameters and attributes that store
intermediate values. The body expression is a Boolean formula over the parameters and
any in-scope features.

```sysml
constraint def PowerBudget {
    in consumers : PowerConsumer[*];
    attribute totalPowerUsage : PowerValue =
        consumers >> collect { in c : PowerConsumer => c.powerDraw } >> reduce { in a, b => a + b };
    totalPowerUsage <= maxBudget
}
```

The body of a constraint is the final expression, which must evaluate to Boolean.
Attributes defined inside the constraint are intermediate values, not results.

### 9.2 assert constraint

An `assert constraint` usage applies a constraint directly in its containing context and
marks the model as invalid if the constraint evaluates to `false`. The containing context
is available inside the constraint through reference subsetting with the `>>` operator
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

### 9.3 Negated Assertions

A constraint can be inverted with the `not` keyword, which specifies that the constraint
should **never** be true:

```sysml
assert constraint not ForbiddenConfiguration;
```

The inverted form is useful for explicit safety-invariant style statements where the
model author wants to say "this must never happen" rather than "this must always hold"
(Ch 31, p 210).

---

## 10. KerML Expressions Layer (Ch 59, p 291)

**Ch 59 is not yet published in the 2026-03 release.** Part IV KerML Reference is
entirely stubbed in the current edition. When KerML expression semantics are published,
this file will grow a section on the formal delta between the SysML surface in Ch 30 and
the KerML metamodel foundation.

---

## 11. Kernel Function Library (Ch 86, p 333)

**Ch 86 is not yet published in the 2026-03 release.** The table of contents lists
17 subsections covering base, Boolean, collection, complex, control, data, integer,
natural, numerical, occurrence, rational, real, scalar, sequence, string, trigonometry,
and vector functions. When these subsections are published, this file will grow a
function catalogue with signatures and one-line purposes.

Until then, authors should consult the SySiDE editor's completion and the OMG
Systems Modeling Language v2.0 specification (March 2023, formal/2025-01-01) for the
library function surface.

---

## 12. Practical Patterns for VSE Authors

### 12.1 Aggregate a Quantity Across Parts

Use `collect` to project each part to its quantity, then `reduce` to sum:

```sysml
part def Vehicle {
    part components : Component[*];
    attribute totalMass : MassValue =
        components >> collect { in c : Component => c.mass } >> reduce { in a, b => a + b };
}
```

### 12.2 Constraint Over All Instances

Use `forAll` inside a constraint body to assert a predicate across every element of a
sequence:

```sysml
constraint def AllRequirementsSatisfied {
    in requirements : Requirement[*];
    requirements >> forAll { in r : Requirement => r.isSatisfied }
}
```

### 12.3 Filter Parts by Condition

Use `select` with operator notation for concise filtering:

```sysml
attribute heavyComponents = components.{ in c : Component => c.mass > 100[kg] };
```

### 12.4 Parametric Trade Study Input

Define a calc with trade-space parameters and invoke it inside an assert constraint to
enforce the trade bound:

```sysml
calc def CostPerformanceRatio(cost : MonetaryValue, performance : Real) : Real = cost / performance;

assert constraint CostPerformanceRatio(totalCost, measuredPerformance) < targetRatio;
```

### 12.5 Chain Navigation and Operation

Combine feature chains and higher-order functions to avoid intermediate attributes:

```sysml
attribute criticalWheelRadii = vehicle.wheels.{ in w : Wheel => w.isCritical }.radius;
```

---

## 13. Gotchas and Red Flags (distilled from Ch 30, 31)

1. **Logical operators evaluate all operands.** Use the control operators `and`, `or`,
   `implies` if short-circuit evaluation matters (Ch 30, p 191).
2. **Indexing is 1-based.** `primes#1` is the first element, not the second. Out-of-range
   indexing returns `null`, not an error (Ch 30, p 195).
3. **There are no negative literals.** A value like `-5` is the operator `-` applied to
   the literal `5`. This shows up in error messages and grammar diagnostics
   (Ch 30, p 191).
4. **`hastype` breaks Liskov substitution.** Prefer `istype` unless the intent is to
   explicitly exclude subtypes (Ch 30, p 206).
5. **A calc name without parentheses is a reference, not an invocation.** This matters
   when passing calcs to higher-order functions. Add empty parentheses to invoke a
   no-argument calc (Ch 30, p 198).
6. **Feature chain flattening can explode multiplicity.** Navigating `vehicle.wheels.bolts`
   concatenates all bolts of all wheels into one flat sequence, which may surprise
   authors expecting a nested structure (Ch 30, p 197).
7. **Null is a value, not an error.** Setting a feature with minimum multiplicity 1 to
   `null` produces a runtime error in simulators, not a compile-time rejection
   (Ch 30, p 194).
8. **`all TypeName` returns unreachable instances.** Extent expressions are semantically
   global and include instances not visible from the current context. Use with care in
   large models (Ch 30, p 194).

---

## 14. Cross References

- `sysml2-quick-ref.md` Sections 13-15 for calc, constraint, expr textual syntax.
- `sysml2-semantics-ref.md` Section on type hierarchy for scalar value branches.
- `sysml2-libraries-ref.md` Section 2 for `Calculations::Calculation` and
  `Constraints::ConstraintCheck` base types.
- `syside-automator-ref.md` for evaluating expressions programmatically from Python.

---

## 15. Pending Extensions

This file will grow once the following chapters are published in a future release of
the book:

- Ch 27 Calculations (authoring patterns, parametric modelling, binding to parts)
- Ch 59 KerML Expressions (formal layer semantics)
- Ch 86 Kernel Function Library (function catalogue with signatures)

Attribution: Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U, 2026. All
claims cite chapter and page. Paraphrased for reference use. Do not reproduce verbatim.
