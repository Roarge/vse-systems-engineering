---
title: "SysML 2.0 Domain Libraries: Causation, Derivation, Geometry"
slug: sysml2-domain-libraries-causation-geometry
type: reference
layer: sysml2
tags: [cause-and-effect, derivation, geometry, fault-tree, traceability, shapes]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Sections 9.5, 9.6, 9.7."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-libraries-architecture
  - sysml2-domain-libraries-metadata-analysis
  - sysml2-occurrences-4d
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Domain Libraries: Causation, Derivation, Geometry

This page covers three less commonly used but valuable domain
libraries: Cause and Effect, Requirement Derivation, and Geometry.
For Metadata and Analysis libraries see
[[sysml2-domain-libraries-metadata-analysis]].

## Cause and Effect library (9.5)

| Type | Base | Features |
|---|---|---|
| `Multicausation` | ConnectionDefinition | `causes[1..*]`, `effects[1..*]`, `disjointCauseEffect` constraint |
| `Causation` | Multicausation | Binary variant (single cause to single effect) |

Metadata annotations:

- `CausationMetadata` (annotates a connection as causal)
- `CauseMetadata` (short name: `cause`, annotates the cause end)
- `EffectMetadata` (short name: `effect`, annotates the effect end)

Use this library for fault tree analysis and FMEA modelling. It
enforces the constraint that causes and effects must be disjoint
(an element cannot be both cause and effect within the same
relationship).

**VSE guidance**: Valuable during SR.5 for structured safety
analysis. Even a simple fault tree in the model provides
traceability from hazards to mitigations.

## Requirement Derivation library (9.6)

| Type | Base | Features |
|---|---|---|
| `Derivation` | ConnectionDefinition | `originalRequirement`, `derivedRequirements[1..*]` |

Constraints:

- `originalImpliesDerived`: satisfying the original implies
  satisfying all derived requirements.
- `originalNotDerived`: the original must not itself be a derived
  requirement in the same derivation chain.

Metadata annotations:

- `DerivationMetadata` (short name: `derivation`)
- `DerivedRequirementMetadata` (short name: `derive`)
- `OriginalRequirementMetadata` (short name: `original`)

### Derivation example

```sysml
import RequirementDerivation::*;

requirement def <'STK-001'> StakeholderSafety {
    doc /* The system shall not cause harm to operators. */
}

requirement def <'SYS-001'> EmergencyShutdown {
    doc /* The system shall enter a safe state within 500 ms of a fault. */
}

requirement def <'SYS-002'> FaultDetection {
    doc /* The system shall detect critical faults within 100 ms. */
}

connection safetyDerivation : Derivation {
    end :>> originalRequirement = stakeholderSafety;
    end :>> derivedRequirements = (emergencyShutdown, faultDetection);
}
```

**VSE guidance**: Use derivation connections to maintain the
traceability chain from stakeholder needs to system requirements.
This directly supports the R3 traceability principle and the
`@traceability-guard` skill.

## Geometry library (9.7)

### Spatial Items (9.7.2)

`SpatialItem` specialises `ItemDefinition` and adds
`coordinateFrame`, `localClock`, and `originPoint`. Position and
displacement calculations are provided for coordinate
transformations.

The 4D-modelling worldview adopted in the 2026-04 release of the
SysML v2 book interacts with the Geometry library: spatial extent
is one of the two axes (alongside temporal) along which an
occurrence is decomposed. See [[sysml2-occurrences-4d]] for the
conceptual frame.

### Shape Items (9.7.3)

The library provides an extensive catalogue of 2D and 3D shape
definitions.

**Key 2D shapes**: `Circle`, `Ellipse`, `Rectangle`, `Polygon`,
`Triangle`, `ClosedCurve`.

**Key 3D shapes**: `Sphere`, `Cuboid`, `Cylinder`, `Cone`,
`Pyramid`, `Torus`, `Shell`.

Each shape definition includes dimensional attributes (for
example, `radius` for `Sphere`, `length`/`width`/`height` for
`Cuboid`) and surface area and volume calculations where
applicable.

**VSE guidance**: Most VSE projects will not need the geometry
library unless modelling physical layouts, sensor placement, or
spatial constraints. If your project involves physical design,
consider importing only the specific shape types you need rather
than the entire library.

## See also

- [[sysml2-libraries-architecture]] for the library layering.
- [[sysml2-domain-libraries-metadata-analysis]] for the more
  commonly imported domain libraries.
- [[sysml2-occurrences-4d]] for the 4D worldview that frames
  spatial relations.
