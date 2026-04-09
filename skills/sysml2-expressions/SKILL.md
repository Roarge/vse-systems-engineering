---
name: sysml2-expressions
description: Author and evaluate SysML 2.0 expressions, calc definitions, and constraint bodies. Use when adding formulas, value bindings, derived attributes, parametric calculations, or constraint checks.
user-invocable: true
---

# SysML 2.0 Expressions, Calculations, and Constraints

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

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
`select`, `collect`, `includes`, and set-like operations. See
`sysml2-expressions-ref.md` Sections 5-6 for the full list and their
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
   the values carry physical units. See `sysml2-libraries-ref.md` Section 7.
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

## Reference: SysML 2.0 Expressions

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/sysml2-expressions-ref.md`
