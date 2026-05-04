---
title: "SysML 2.0 Syntax: Multiplicity, Attributes, and Enumerations"
slug: sysml2-syntax-features-and-attributes
type: reference
layer: sysml2
tags: [syntax, multiplicity, attribute, enum, feature-values]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Sections 7.6, 7.7, 7.8, 7.13."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-syntax-packages-and-definitions
  - sysml2-syntax-structure
  - sysml2-expressions-overview
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Syntax: Multiplicity, Attributes, and Enumerations

Cheat sheet for feature multiplicity, attribute values, and
enumeration declarations.

## Multiplicity and feature values (7.6, 7.13)

```sysml
// Multiplicity
part wheels[4] : Wheel;
part passengers[0..4] : Person;
part sensors[1..*] : Sensor;

// Bound value (fixed, never changes)
attribute monthsInYear : Natural = 12;

// Initial value (can change after initialisation)
attribute count[1] : Natural := 0;

// Default value (overridable by specialisation)
attribute mass : Real default 1500.0;

// Referential (non-composite) usage
ref part driver[0..1] : Person;
```

The `[lower..upper]` form supports `*` as the unbounded upper
limit. A bare `[n]` means exactly `n`. Default multiplicity for
features inside a definition is `[1]`. Default multiplicity for
package-level usages is `[0..*]`, which is rarely the intended
meaning, so explicit multiplicity is recommended.

### Feature value forms summarised

| Operator | Meaning | When to use |
|---|---|---|
| `=` | Fixed binding (cannot be overridden) | Constants and derived expressions |
| `:=` | Initial value (variable) | Mutable feature with starting value |
| `default` | Overridable default | Type-level default that subclasses may change |

## Attributes (7.7)

```sysml
attribute def SensorRecord {
    ref part sensor : Sensor;
    attribute reading : Real;
    attribute timestamp : TimeInstantValue;
}

attribute currentReading : SensorRecord;
```

Attributes carry **DataValue** semantics (referential, no
composite features). For mutable values that change over time
during execution, see the variable-feature mechanism in the
4D-modelling family.

## Enumerations (7.8)

```sysml
enum def ConditionColor {
    red;
    green;
    yellow;
}

enum def RiskLevel :> ConditionColor {
    enum low {
        :>> color = ConditionColor::green;
    }
    enum medium {
        :>> color = ConditionColor::yellow;
    }
    enum high {
        :>> color = ConditionColor::red;
    }
}
```

An `enum def` is an attribute definition with `isVariation = true`
and a fixed set of variants declared with the `enum` keyword.
Enum values can carry attributes that are redefined per variant,
as `RiskLevel` shows.

## See also

- [[sysml2-syntax-packages-and-definitions]] for the surrounding
  package and `def` syntax.
- [[sysml2-syntax-structure]] for parts, ports, and connections
  that consume these features.
- [[sysml2-expressions-overview]] for using attributes and
  multiplicity-bearing features in expressions.
