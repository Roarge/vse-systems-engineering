---
title: "SySiDE Expression Evaluation and Compiler"
slug: syside-expression-evaluation
type: reference
layer: syside
tags: [syside, automator, compiler, expressions, units, filters]
sources:
  - citation: "Sensmetry. SySiDE Automator Python API: expression evaluation. https://docs.sensmetry.com/python/latest/evaluation.html (accessed 2026-04)."
    raw: sensmetry_docs_2026-04
related:
  - syside-core-api
  - syside-model-modification
  - sysml2-expressions-overview
  - sysml2-advanced-quantities-units
  - sysml2-metadata-overview
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling, sysml2-metadata]
---

# SySiDE Expression Evaluation and Compiler

The `Compiler` class evaluates SysML expressions, attribute
values, and metadata filters. This is the surface a VSE script
uses to roll up calculated values (mass budgets, cost
estimates), evaluate constraints, and select elements by
metadata predicate.

```python
STDLIB = syside.Environment.get_default().lib
compiler = syside.Compiler()
```

The standard library reference is shared across all evaluations
in a session. Loading it once at script start avoids repeated
parsing.

## Evaluate expressions

```python
# Evaluate an attribute's value expression
expr = attribute.feature_value_expression
result, report = compiler.evaluate(expr)
if not report.fatal:
    print(f"Value: {result}")
```

Use this form when the expression is already isolated as an
AST node, for example in a constraint body or a default value
expression on an `AttributeUsage`.

## Evaluate features (value rollup with units)

```python
# Evaluate a feature in scope (handles redefinitions, unit conversion)
value, report = compiler.evaluate_feature(
    feature=mass_attribute,
    scope=owning_part,
    stdlib=STDLIB,
    experimental_quantities=True,   # enables 10 [kg] expressions
)
if not report.fatal:
    print(f"Mass: {value}")  # value in SI base units
```

The feature evaluator resolves redefinitions along the
specialisation chain and applies unit conversion using the
quantities and units library
(see sysml2-advanced-quantities-units for the underlying SysML
2.0 mechanism). Set `experimental_quantities=True` to enable
the `10 [kg]` literal form introduced in the 2026 SysML 2.0
specification update.

## Evaluate filters (metadata-based)

```python
# Check if an element matches a filter expression
result, report = compiler.evaluate_filter(
    target=element,
    filter=filter_expression,
    stdlib=STDLIB,
)
# result is boolean
```

Filter evaluation drives the metadata-based queries that the
sysml2-metadata-overview page describes. A typical VSE use is:
"give me every requirement whose `priority` metadata is
`Essential` and whose `verification_method` is `Test`". Each
filter is compiled once and applied across the model.

## Supported operations

All SysML operators except `all` and `~`. Standard library
functions:

- **Fully supported**: BaseFunctions, BooleanFunctions,
  DataFunctions, IntegerFunctions, NaturalFunctions,
  RealFunctions, ScalarFunctions, StringFunctions,
  TrigFunctions, SequenceFunctions
- **Partially supported**: ComplexFunctions (excluding `rect`,
  `polar`), RationalFunctions (excluding `numer`, `denom`,
  `gcd`)
- **Experimental**: Quantity expressions via
  `experimental_quantities=True`

Any expression that uses unsupported operations returns a
non-fatal report with an explanatory message rather than
raising. The sysml2-expressions-overview page describes the
language-level expression model that the Automator implements.
