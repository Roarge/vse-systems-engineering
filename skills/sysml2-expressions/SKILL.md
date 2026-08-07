---
name: sysml2-expressions
description: Author and evaluate SysML 2.0 expressions, calculation definitions, and constraint bodies.
when_to_use: Use for `calc def`, `constraint def`, `assert constraint`, derived attributes, value bindings, parametric calculations, sequence and classification operators. Not for state or action bodies (`@sysml2-behaviour`).
paths: ["**/*.sysml"]
user-invocable: true
---

# SysML 2.0 Expressions, Calculations, and Constraints

A `methodology/` folder at the project root, or under `engineering/`, marks a VSE project. If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first. In a SysML-only repository with no `methodology/` folder, skip the lens and proceed directly with this skill.

You guide the engineer through the expression language of SysML 2.0.
This skill covers scalar and sequence expressions, calculation definitions,
constraint bodies, and the standard kernel function library. For project
layout, tooling, and the full syntax quick reference, route back to
`@sysml2-modelling`.

## When This Skill Triggers

- The user asks to add a formula, derived attribute, or value binding
- The user wants a parametric calculation such as mass or power budget
- The user wants a constraint that must be evaluated at model check time
- The user asks about operator precedence, sequence operations, or the
  kernel function library

## Core Vocabulary

SysML 2.0 expressions specialise KerML expressions. Every expression is
a feature whose value is computed by evaluating the expression body.
Expressions may appear inside attribute bindings, constraint bodies,
calculation bodies, and anywhere a feature value is expected.

| Element | Keyword | Purpose |
| --- | --- | --- |
| Calculation | `calc def`, `calc` | Reusable named expression, returns a value |
| Constraint | `constraint def`, `constraint`, `assert constraint` | Boolean expression, optionally asserted |
| Literal | `true`, `42`, `"text"` | Scalar values |
| Feature reference | `this.name`, `owner.attr` | Read a feature value in scope |

## Authoring Patterns

### Calculation Definition with Inputs and Result

```sysml
calc def PowerBudget {
    in attribute batteryCapacity : Real;
    in attribute loadCurrent : Real;
    return attribute runtimeHours : Real = batteryCapacity / loadCurrent;
}
```

Use `in` parameters for inputs and `return` for the computed result.
The right-hand side of the `return` binding is the expression body.

### Constraint Body

```sysml
constraint def MassWithinBudget {
    in attribute actualMass : Real;
    in attribute budgetMass : Real;
    actualMass <= budgetMass
}
```

The last expression in the body is the constraint's Boolean value. No
explicit `return` keyword is used inside a constraint.

### Asserting a Constraint

```sysml
part def Drone {
    attribute dryMass : Real = 12.4;
    attribute maxMass : Real = 15.0;
    assert constraint massOk : MassWithinBudget {
        in actualMass = dryMass;
        in budgetMass = maxMass;
    }
}
```

`assert constraint` requires the constraint to evaluate to `true` when
the model is checked. An unasserted constraint is informational only.

### Derived Attribute via Expression

```sysml
part def Battery {
    attribute capacity : Real;
    attribute voltage : Real;
    attribute energyJoules : Real = capacity * voltage * 3600;
}
```

A binding `=` on an attribute usage makes it derived. Readers obtain the
value by evaluating the right-hand expression, not by storing it.

### Sequence Expressions and Higher-Order Functions

```sysml
attribute allMasses : Real[*] = (1.2, 3.4, 2.8, 0.9);
attribute totalMass : Real = sum(allMasses);
attribute heavy : Real[*] = allMasses->select{ in v : Real; v > 2.0 };
```

Kernel sequence functions include `sum`, `size`, `first`, `last`,
`select`, `collect`, `includes`, and set-like operations. See the
`sysml2-sequences-and-structures` and
`sysml2-functions-and-higher-order` atomic pages
(under `wiki/pages/sysml2/`) for the full list and their
signatures.

### Classification Expression

```sysml
attribute isHeavy : Boolean = battery@HeavyBattery;
```

The `@` operator tests whether a value is classified by the named type.
`@@` tests meta-classification. See the metadata skill for details on
metaclass queries.

## Validation Checklist

Before handing a calculation or constraint back to the engineer, confirm:

1. **Parameter types match** the expression usage. A `Real` parameter cannot
   be silently coerced from a sequence.
2. **Constraint bodies return Boolean.** A stray `return` or a non-Boolean
   final expression makes the constraint ill-formed.
3. **Asserted constraints have all their inputs bound** at the call site.
   Unbound inputs mean the assertion cannot be evaluated.
4. **Unit-aware expressions** use quantity kinds from the ISQ library when
   the values carry physical units. See the `sysml2-quantities-and-units`
   atomic page for ISQ guidance and `sysml2-advanced-quantities-units`
   for SimpleUnit/DerivedUnit/ConversionByPrefix.
5. **Recursion is avoided** in calculations unless the base case is explicit.
   The evaluator does not detect infinite recursion.

## Red Flags

WARN the engineer if:

- A `calc def` is declared without a `return` clause
- A `constraint def` ends on a non-Boolean expression
- A sequence operation is applied to a scalar feature
- A classification expression uses `@` where `@@` was meant (metaclass
  versus classifier confusion)
- An `assert constraint` binding leaves an `in` parameter unset

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| SysML 2.0 Advanced Quantities and Units Concepts | pages/sysml2/sysml2-advanced-quantities-units.md | Unit definitions, derived units, conversions, and scalar and vector quantity values |
| SysML 2.0 Expression Patterns and Gotchas | pages/sysml2/sysml2-expression-patterns.md | Practical patterns and recurring mistakes for expressions, calculations, and constraints |
| SysML 2.0 Calculations and Constraints | pages/sysml2/sysml2-expressions-constraints.md | Calculations and constraints are the two main expression-bearing constructs in SysML 2.0 |
| SysML 2.0 Expressions Overview and Scalar Values | pages/sysml2/sysml2-expressions-overview.md | The native expression language and scalar values, usable in feature values, constraints, and guards |
| SysML 2.0 Functions, Invocations, and Higher-Order Operations | pages/sysml2/sysml2-functions-and-higher-order.md | Calling functions and calculations, the higher-order function library, and runtime type tests |
| SysML 2.0 Sequences and Complex Structures | pages/sysml2/sysml2-sequences-and-structures.md | Multiplicity as sequences, ordering and uniqueness, and modelling complex structured values |
<!-- wiki-routing:end -->
