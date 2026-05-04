---
title: "SysML 2.0 Quantities and Units (ISQ and SI)"
slug: sysml2-quantities-and-units
type: reference
layer: sysml2
tags: [quantities, units, isq, si, iso80000, dimensional-analysis]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 24, pages 135 to 143."
    raw: sysmlv2.pdf
  - citation: "ISO 80000-1:2009. Quantities and units — Part 1: General."
    raw: null
related:
  - sysml2-advanced-quantities-units
  - sysml2-libraries-architecture
  - sysml2-library-import-patterns
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Quantities and Units (ISQ and SI)

A quantity is an attribute whose value carries physical meaning.
Rather than defining a quantity type from scratch, use the
predefined SysML 2.0 domain libraries that ship ISO/IEC 80000
quantities. For the underlying machinery (custom unit definition,
power factors, conversion-by-prefix), see
[[sysml2-advanced-quantities-units]].

## Quantity library positioning (Ch 24.1)

The most commonly needed quantities live in `ISQBase`, covering
length, mass, and time. The overarching `ISQ` library publicly
imports all quantity-specific libraries. A practical pattern is
to qualify the name at the point of use rather than import the
whole namespace:

```sysml
part def Vehicle {
    attribute mass : ISQ::MassValue;
    attribute length : ISQ::LengthValue;
    attribute cruiseSpeed : ISQ::SpeedValue;
}
```

The library exposes both **definition elements** (for example
`LengthValue`) and **usage elements** (for example `length`,
`width`, `height`, `altitude`). The SysML v2 book recommends using
usage elements because they carry richer semantics and read as
the physical role, not the underlying type (Ch 24, p 136).

## Units attach to values, not types (Ch 24.2)

In SysML 2.0 a unit (kilogram, metre, second) is bound to the
**value expression**, not to the attribute declaration. This is a
deliberate change from SysML v1 where both the quantity and the
unit were fixed on the value type. The 2.0 approach allows a
single quantity attribute to accept values in different units,
with automatic conversion during evaluation (Ch 24, p 136).

```sysml
part vehicle : Vehicle {
    mass = 1200 [kg];
    length = 4500 [mm];     // accepted and converted internally
    cruiseSpeed = 100 [km/h];
}
```

The consequence for VSEs: declare attributes with the quantity
type only, and write values with the unit that makes sense at the
measurement or specification point. The library handles
conversion during constraint checks.

## ISQ library catalogue (Ch 113)

Chapter 113 of the SysML v2 book lists the full ISQ catalogue
across roughly 23 subsections:

- Base
- Acoustics
- Atomic and Nuclear Physics
- Chemistry and Molecular Physics
- Condensed Matter Physics
- Electromagnetism
- Information Science and Technology
- Light and Radiation
- Mechanics
- Space and Time
- Thermodynamics
- Plus measurement calculations, SI prefixes, US Customary units,
  and vector calculations

The detailed subsection content was marked as pending in the
2026-03 release. Until those chapter sections publish, consult the
OMG specification or the library sources in the SysML v2 release
repository for the exact quantity and unit names in each
subsection.

## VSE selection guidance

Always use ISQ quantities for any numeric attribute that has a
physical unit. Treat untyped numerical attributes as a smell. The
library handles dimensional consistency at evaluation time, which
removes an entire class of SME modelling errors.

For the most common imports:

```sysml
import ISQ::*;
import SI::*;
```

Once these are in scope, every numeric attribute should be typed
with a `ISQ::*Value` type and given a value with the appropriate
SI unit suffix.

## See also

- [[sysml2-advanced-quantities-units]] for the underlying
  SimpleUnit, DerivedUnit, and ConversionByPrefix mechanism (new
  in the 2026-04 release).
- [[sysml2-libraries-architecture]] for the library layering.
- [[sysml2-library-import-patterns]] for VSE-scale import
  patterns.
