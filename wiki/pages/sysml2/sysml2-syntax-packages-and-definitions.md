---
title: "SysML 2.0 Syntax: Packages, Definitions, and Common Relationships"
slug: sysml2-syntax-packages-and-definitions
type: reference
layer: sysml2
tags: [syntax, packages, imports, def, usage, comments, metadata, relationships]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Sections 7.5, 7.6, 7.2, 7.3, 7.4."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-syntax-features-and-attributes
  - sysml2-syntax-structure
  - sysml2-syntax-behaviour
  - sysml2-syntax-requirements-and-cases
  - sysml2-self-and-that
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Syntax: Packages, Definitions, and Common Relationships

Cheat sheet for top-level model organisation, the `def`/usage
pattern, and the common relationship operators. Every example is
verified against the OMG SysML v2.0 specification
(formal/2025-01-01).

## Packages and imports (7.5)

```sysml
package Vehicles {
    part def Vehicle;
}

// Namespace import (all direct members)
import Vehicles::*;

// Recursive namespace import (all members at all depths)
import Vehicles::**;

// Private import (not visible to importers of this package)
private import Vehicles::*;

// Alias
alias CarDef for Vehicles::Vehicle;

// Filtered import (metadata-based)
package FilteredView {
    import Vehicles::**;
    filter @Approved and status == "released";
}
```

## Definitions and usages (7.6)

Every element follows the **definition/usage** pattern: `def`
declares a reusable type, plain keyword instantiates it.

```sysml
// Definition
part def Vehicle;

// Usage (instantiation)
part myVehicle : Vehicle;

// Long-form usage
part myVehicle defined by Vehicle;

// Specialisation (subclassification)
part def Truck :> Vehicle;
part def Truck specializes Vehicle;   // equivalent long form

// Abstract definition (cannot be instantiated directly)
abstract part def Vehicle;

// Variation and variants
variation part def TransmissionChoices :> Transmission {
    variant part manual : ManualTransmission;
    variant part automatic : AutomaticTransmission;
}
```

## Comments and documentation (7.2, 7.3)

```sysml
// Line comment

/* Block comment */

// Documentation (attached to owning element)
part def Vehicle {
    doc /* A self-propelled road vehicle. */
}

// Short name (requirement ID)
requirement def <'REQ-001'> SafetyRequirement;
```

## Metadata and annotations (7.4)

```sysml
// Metadata definition
metadata def Approval {
    attribute approved : Boolean;
    attribute approver : String;
}

// Annotating an element
@Approval {
    approved = true;
    approver = "Chief Engineer";
}
part def Vehicle;
```

## Common relationship keywords

| Keyword | Meaning |
|---|---|
| `:>` | Specialises (subclassification) |
| `specializes` | Long form of `:>` |
| `:>>` | Redefines (replaces inherited feature) |
| `redefines` | Long form of `:>>` |
| `subsets` | Subsets (usage is a subset of another collection) |
| `references` | References an externally defined element |
| `defined by` | Long form of `:` (typing) |

## Contextual references

`self` and `that` provide navigation up and out of a feature
chain. See [[sysml2-self-and-that]] for the full semantics.

## See also

- [[sysml2-syntax-features-and-attributes]] for multiplicity,
  attributes, and enums.
- [[sysml2-syntax-structure]] for parts, ports, connections,
  interfaces, allocations.
- [[sysml2-syntax-behaviour]] for actions and states.
- [[sysml2-syntax-requirements-and-cases]] for calc, constraint,
  requirement, verification, use case, analysis, view syntax.
