---
title: "SysML 2.0 Library Architecture: Systems Model Library and Domain Libraries"
slug: sysml2-libraries-architecture
type: concept
layer: sysml2
tags: [libraries, architecture, systems-model-library, domain-libraries]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Chapter 9."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-systems-model-library
  - sysml2-domain-libraries-metadata-analysis
  - sysml2-domain-libraries-causation-geometry
  - sysml2-library-import-patterns
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Library Architecture

SysML 2.0 organises its predefined types into two layers: a
**Systems Model Library** that every model implicitly uses, and
**Domain Libraries** that are imported explicitly when a project
needs specific capabilities.

## Systems Model Library

The Systems Model Library contains the base types that every model
implicitly uses. When you write `part def MyPart`, the language
automatically specialises `Parts::Part` through a
`specializeFromLibrary()` constraint. You never need to import
these types explicitly. They provide the structural and
behavioural foundations for all SysML 2.0 keywords.

See [[sysml2-systems-model-library]] for the keyword-to-base-type
mapping and the specialised requirement and verification types.

## Domain Libraries

Domain Libraries are optional packages that you import explicitly
when a project needs specific capabilities such as metadata
tracking, trade studies, or geometric modelling. Each domain
library builds on the Systems Model Library base types.

The principal domain libraries:

- **Metadata Library** ([[sysml2-domain-libraries-metadata-analysis]]):
  status tracking, risk, parameters of interest, image metadata.
- **Analysis Library** ([[sysml2-domain-libraries-metadata-analysis]]):
  tool execution, sampled functions, state space dynamics, trade
  studies.
- **Cause and Effect Library**
  ([[sysml2-domain-libraries-causation-geometry]]): multicausation,
  causation, fault tree and FMEA modelling.
- **Requirement Derivation Library**
  ([[sysml2-domain-libraries-causation-geometry]]): derivation
  connections that maintain traceability from stakeholder to
  system requirements.
- **Geometry Library**
  ([[sysml2-domain-libraries-causation-geometry]]): spatial items
  and the catalogue of 2D and 3D shapes.
- **Quantities and Units** ([[sysml2-quantities-and-units]]): ISQ
  and SI from the KerML standard library.

## Qualified names

Library types use qualified names following the pattern
`PackageName::TypeName`. For example, `Parts::Part`,
`Requirements::RequirementCheck`, and
`AnalysisCases::AnalysisCase`. These qualified names appear in
tool diagnostics and are useful when you need to reference a base
type directly.

## VSE guidance

Most small projects will only ever need the implicit base types
plus one or two domain library imports (typically metadata and
quantities). Do not import libraries speculatively. Import only
what the current lifecycle phase requires. See
[[sysml2-library-import-patterns]] for the phase-by-phase
selection guide.

## See also

- [[sysml2-systems-model-library]] for keyword-to-library-type
  mappings.
- [[sysml2-quantities-and-units]] for ISQ/SI library coverage.
- [[sysml2-library-import-patterns]] for VSE selection guidance.
