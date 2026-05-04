---
title: "SysML 2.0 Library Import Patterns and VSE Selection Guide"
slug: sysml2-library-import-patterns
type: pattern
layer: sysml2
tags: [imports, vse, selection-guide, patterns, lifecycle-phase]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Chapter 9."
    raw: 2-OMG_Systems_Modeling_Language.pdf
  - citation: "ISO/IEC TR 29110-5-6-2:2014. Lifecycle profiles for Very Small Entities."
    raw: null
related:
  - sysml2-libraries-architecture
  - sysml2-domain-libraries-metadata-analysis
  - sysml2-domain-libraries-causation-geometry
  - sysml2-quantities-and-units
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Library Import Patterns and VSE Selection Guide

This page collects practical import patterns for the SysML 2.0
domain libraries, organised by use case and ISO 29110 phase.

## Common import patterns

### Minimal (most projects)

```sysml
// No explicit imports needed for basic modelling.
// part, item, action, requirement, etc. implicitly specialise
// their Systems Model Library base types.
```

### Status tracking

```sysml
import Metadata::StatusInfo::*;
import Metadata::Risk::*;
```

### Trade studies

```sysml
import TradeStudies::*;
```

### Requirement derivation

```sysml
import DerivationConnections::*;
import RequirementDerivation::*;
```

### Cause and effect analysis

```sysml
import CauseAndEffect::*;
```

### Quantities and units (from KerML standard library)

```sysml
import ISQ::*;
import SI::*;

// Then use typed attributes:
// attribute mass : ISQ::MassValue;
// attribute length : ISQ::LengthValue;
// attribute temperature : ISQ::ThermodynamicTemperatureValue;
```

ISQ (International System of Quantities) and SI (International
System of Units) are defined in the KerML standard library, not
the SysML domain libraries. They are essential for any project
dealing with physical quantities and should be imported in nearly
every VSE project that models hardware. See
[[sysml2-quantities-and-units]].

### Verification methods

```sysml
import VerificationCases::*;
```

### Performance note

Prefer **selective imports** (`import Package::SpecificType`) over
**recursive imports** (`import Package::**`) to reduce model
loading time. This matters when using SySiDE or other tools that
resolve imports at edit time.

## VSE library selection by lifecycle phase

Not every project needs every library. Use this decision guide to
select only what the current ISO 29110 phase requires.

| Phase | Recommended libraries | Rationale |
|---|---|---|
| SR.1 Initiation | None (implicit base types only) | Keep the model skeleton minimal |
| SR.2 Requirements | StatusInfo, Risk, ISQ/SI | Track requirement maturity, tag measurable attributes |
| SR.3 Architecture | StatusInfo, TradeStudies, ISQ/SI | Evaluate design alternatives with auditable criteria |
| SR.4 Construction | ISQ/SI, ToolExecution | Map model attributes to build and analysis tools |
| SR.5 IVV | VerificationCases, CauseAndEffect, RequirementDerivation | Structure test cases, trace derivations, model fault trees |
| SR.6 Delivery | Views (standard view definitions) | Generate deliverable views and tables from the model |

**Principle**: Import a domain library at the point of need, not
at project start. This keeps early models fast to parse and easy
to understand. A small team benefits from a model that stays
readable throughout the lifecycle.

## See also

- [[sysml2-libraries-architecture]] for the library layering.
- [[sysml2-domain-libraries-metadata-analysis]] for Metadata and
  Analysis library catalogues.
- [[sysml2-domain-libraries-causation-geometry]] for the remaining
  domain libraries.
- [[sysml2-quantities-and-units]] for ISQ and SI guidance.
