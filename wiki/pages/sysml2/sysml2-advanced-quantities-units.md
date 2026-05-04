---
title: "SysML 2.0 Advanced Quantities and Units Concepts"
slug: sysml2-advanced-quantities-units
type: reference
layer: sysml2
tags: [quantities, units, iso80000, simpleunit, derivedunit, mref]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Section 24.3, pages 140 to 143. New section in the 2026-04 release."
    raw: sysmlv2.pdf
  - citation: "ISO 80000-1:2009. Quantities and units — Part 1: General."
    raw: null
related:
  - sysml2-expressions-overview
  - sysml2-expressions-constraints
  - sysml2-libraries-systems
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-expressions]
---

# SysML 2.0 Advanced Quantities and Units Concepts

This page captures the concepts behind quantities and units in
SysML 2.0. Applying quantities and units in everyday models is
simple: declare an attribute, give it a quantity type, attach a
unit. The advanced concepts cover what is happening behind the
scenes in the domain libraries and how quantities and units are
defined and related. The 2026-04 release of the SysML v2 book added
this material as a new Section 24.3 (pages 140 to 143).

## When advanced concepts matter

For most VSE projects, the standard libraries covering the ISO/IEC
80000 series fulfil almost all needs. Defining custom quantities
and units is rarely necessary. The concepts on this page matter
when:

- A domain has quantities not covered by ISO/IEC 80000 (specialist
  measurements, derived properties unique to a domain).
- Custom units are needed that compose other units in non-standard
  ways.
- A modelling tool's library completion is incomplete, and the
  author must read the library to find the right type.

## Quantities and units are attributes

Quantities and units are not standalone model elements. They are
**attributes defined in SysML 2.0 standard libraries**. Declaring
an attribute with a quantity type binds the attribute to a
quantity (which corresponds to a physical concept like length or
duration) and a unit (which corresponds to a measurement reference
like metres or seconds).

```sysml
attribute speed :> ISQ::speed = 42 [SI::'km/h'];
attribute altitude :> ISQ::altitude = 500 [SI::m];
```

The qualifier `ISQ::` references the International System of
Quantities (ISO 80000-1:2009). The qualifier `SI::` references
the International System of Units. Both are organised as SysML 2.0
standard libraries.

## Unit definitions: SimpleUnit

Units derive from `LengthUnit`, `TimeUnit`, and so on, all of which
specialise the library type `SimpleUnit`. A simple unit is a
measurement unit that does not depend on any other unit. It has an
ordered set of **power factors**.

```sysml
attribute def LengthUnit :> SimpleUnit {
    private attribute lengthPF: QuantityPowerFactor[1] {
        :>> quantity = isq.L;
        :>> exponent = 1;
    }
    attribute :>> quantityDimension {
        :>> quantityPowerFactors = lengthPF;
    }
}
```

The length unit has one power factor, based on the quantity `isq.L`
(length, in the ISQ library) with exponent 1. The `isq` attribute
represents the international system of quantities as specified in
ISO 80000-1:2009.

## Derived units: SpeedUnit example

A `DerivedUnit` is composed from multiple power factors. The unit
`km/h` is a `SpeedUnit`, defined by length (exponent 1) and
duration (exponent -1):

```sysml
attribute def SpeedUnit :> DerivedUnit {
    private attribute lengthPF: QuantityPowerFactor[1] {
        :>> quantity = isq.L;
        :>> exponent = 1;
    }
    private attribute durationPF: QuantityPowerFactor[1] {
        :>> quantity = isq.T;
        :>> exponent = -1;
    }
    attribute :>> quantityDimension {
        :>> quantityPowerFactors = (lengthPF, durationPF);
    }
}
```

The unit `mile per hour` is also a `SpeedUnit`. The fact that
`km/h` is kilometres and hours is specified directly in the unit
definition through the unit short-name binding.

## Unit conversion: ConversionByPrefix

Part of the unit concept involves unit conversion. Standard
prefixes such as `kilo` are defined in the library:

```sysml
attribute <km> kilometre : LengthUnit {
    :>> unitConversion: ConversionByPrefix {
        :>> prefix = kilo;
        :>> referenceUnit = m;
    }
}
```

The kilometre redefines `unitConversion` and specifies a
`kilo-prefix-relationship` to the meter unit. `kilo` is also
defined in the library and sets the factor 1000.

This pattern lets every prefixed unit reuse the conversion rule
without redefining the arithmetic per unit.

## Quantity values: ScalarQuantityValue and VectorQuantityValue

Quantities are defined as attributes in the ISQ libraries:

```sysml
attribute speed: SpeedValue[*] nonunique :> scalarQuantities;
attribute height: LengthValue :> scalarQuantities;
alias altitude for height;
```

Each quantity references an attribute definition such as
`SpeedValue` or `LengthValue`, which is a special
`ScalarQuantityValue`. Another quantity-value kind is
`VectorQuantityValue`. The measurement reference attribute `mRef`
points to the appropriate unit type and thus establishes the
connection between the quantity (`LengthValue`) and the unit
(`LengthUnit`):

```sysml
attribute def LengthValue :> ScalarQuantityValue {
    doc /* source: item 3-1.1 length, symbol(s): l, L,
        application domain: generic, name: Length,
        quantity dimension: L^1, measurement unit(s): m,
        tensor order: 0,
        definition: linear extent in space between any two points,
        remarks: Length does not need to be measured along a
        straight line. Length is one of the seven base quantities
        in the International System of Units (ISO 80000-1).
    */
    attribute :>> num: Real;
    attribute :>> mRef: LengthUnit[1];
}
```

## Where to find more

Full library coverage of quantities and units is in Chapter 113 of
the SysML v2 book (Quantities and Units Libraries), which catalogues
the ISQ branches (acoustics, atomic nuclear, base, characteristic
numbers, chemistry molecular, condensed matter, electromagnetism,
information, light, mechanics, space and time, thermodynamics) plus
SI units, SI prefixes, US Customary units, and the calculation
helpers for measurements, quantities, and quantity calculations.

## See also

- [[sysml2-expressions-overview]] for scalar values and the
  expression language.
- [[sysml2-expressions-constraints]] for using quantities inside
  constraints.
- [[sysml2-libraries-systems]] for general guidance on SysML 2.0
  standard libraries (will be authored when the libraries
  reference is migrated).
