---
title: "SysML 2.0 Syntax: Multiplicity, Attributes, and Enumerations"
slug: sysml2-syntax-features-and-attributes
type: reference
layer: sysml2
summary: Cheat sheet for feature multiplicity, attribute values, and enumeration declarations
tags: [syntax, multiplicity, attribute, enum, feature-values]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Sections 7.6, 7.7, 7.8, 7.13."
    raw: 2-OMG_Systems_Modeling_Language.pdf
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-07 release. MBSE4U. Pages 105, 115, 180, and 235."
    raw: sysmlv2.pdf
related:
  - sysml2-syntax-packages-and-definitions
  - sysml2-syntax-structure
  - sysml2-expressions-overview
  - sysml2-occurrence-context-and-variables
confidence: high
created: 2026-05-04
updated: 2026-08-10
referenced_by: [sysml2-modelling]
---

# SysML 2.0 Syntax: Multiplicity, Attributes, and Enumerations

## Contents

- Multiplicity and feature values (7.6, 7.13)
- Attributes (7.7)
- Enumerations (7.8)
- See also

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

### Package-level features are not global variables

A package-level feature behaves like an inherited feature of every
type, so it can be redefined in any type. Redefining one is a good
way to bring a floating feature into a concrete context, because the
redefinition restricts the feature's domain from `Anything` to the
owning type and adds its name to that type's namespace
(Ch 18, p 115).

Three consequences follow for reading such a feature and for the
values it can carry.

- **Reading.** Referring to `ISQ::mass` inside `Drone` returns the
  mass associated with the drone instance the expression is evaluated
  on, not a single global value (Ch 30, p 235).
- **Writing.** An assignment to a package-level usage is always an
  error. Package-level usages are features of the type `Anything`,
  which is not an occurrence, and only occurrences can have variables
  because only they exist in time. Package-level usages are therefore
  never variables and cannot be given a new value, so the tool reports
  that the referent feature of the assignment must be time varying
  (Ch 26, p 180). See [[sysml2-occurrence-context-and-variables]] for
  the underlying rule about where variable features may appear.
- **Value kind.** A bound feature value on a package-level feature
  constrains every instance in the universe, so the same value is
  seen everywhere (Ch 30, p 235). An initial value gives every
  instance that value to start with, and instances may hold different
  values from one another, because the values of a package-level
  feature are always associated with a domain instance rather than
  kept in one global slot. The book's example is `ISQ::mass`, whose
  value may differ for every drone (Ch 17, p 105). Such a per-instance
  value never arrives through an assignment to the package-level
  usage itself.

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
- [[sysml2-occurrence-context-and-variables]] for why package-level
  usages are always non-variable.
