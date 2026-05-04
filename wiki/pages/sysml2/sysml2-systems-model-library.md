---
title: "SysML 2.0 Systems Model Library: Base Types and Specialisations"
slug: sysml2-systems-model-library
type: reference
layer: sysml2
tags: [systems-model-library, base-types, requirements, verification, verdict]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Chapter 9.2."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-libraries-architecture
  - sysml2-domain-libraries-metadata-analysis
  - sysml2-cases-overview
  - sysml2-case-kinds
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Systems Model Library: Base Types and Specialisations

The Systems Model Library provides the base types that every
SysML 2.0 keyword implicitly specialises. For the architecture
behind these libraries, see [[sysml2-libraries-architecture]].

## Keyword to library type mapping

The following table maps each SysML 2.0 keyword to the library
definition and usage types that the language implicitly
specialises.

| Keyword | Definition base type | Usage base type | Key features |
|---|---|---|---|
| `attribute` | `Base::DataValue` | `attributeValues` | Referential only, no composite features |
| `enum` | (variation of AttributeDefinition) | `attributeValues` | Always `isVariation=true` |
| `occurrence` | `Occurrences::Occurrence` | `occurrences` | Base for all temporal things |
| `item` | `Items::Item` | `items` | Specialises `Objects::Object` |
| `part` | `Parts::Part` | `parts` | Specialises Item, composite ownership |
| `port` | `Ports::Port` | `ports` | Specialises Object, boundary features |
| `connection` | `Connections::Connection` | `connections` | Specialises Part and LinkObject |
| `interface` | `Interfaces::Interface` | `interfaces` | Connection with PortUsage ends |
| `allocation` | `Allocations::Allocation` | `allocations` | Binary connection for cross-concern mapping |
| `action` | `Actions::Action` | `actions` | Features: start, done, subactions, controls |
| `state` | `States::StateAction` | `stateActions` | Features: entryAction, doAction, exitAction, substates |
| `calc` | `Calculations::Calculation` | `calculations` | Features: subcalculations, result |
| `constraint` | `Constraints::ConstraintCheck` | `constraintChecks` | Also: assertedConstraintChecks, negatedConstraintChecks |
| `requirement` | `Requirements::RequirementCheck` | `requirementChecks` | Features: actors, assumptions, concerns, constraints, stakeholders, subj |
| `concern` | `Requirements::ConcernCheck` | `concernChecks` | Specialises RequirementCheck |
| `verification` | `VerificationCases::VerificationCase` | `verificationCases` | Features: verdict (VerdictKind), requirementVerifications |
| `use case` | `UseCases::UseCase` | `useCases` | Features: includedUseCases, subUseCases |
| `analysis` | `AnalysisCases::AnalysisCase` | `analysisCases` | Features: analysisSteps, result, resultEvaluation |
| `case` | `Cases::Case` | `cases` | Features: actors, obj (objective), subcases, subj |
| `view` | `Views::View` | (no dedicated usage) | Features: subviews, viewRendering, viewpointSatisfactions |
| `viewpoint` | `Views::ViewpointCheck` | `viewpointChecks` | Specialises RequirementCheck, subject is a View |
| `rendering` | `Views::Rendering` | `renderings` | Specialises Part |
| `metadata` | `Metadata::MetadataItem` | `metadataItems` | Specialises Metaobject and Item |

## Specialised requirement types

The Systems Model Library provides several requirement
specialisations with pre-bound subject types. These save
boilerplate when writing common requirement categories.

| Requirement type | Subject type | Typical use |
|---|---|---|
| `DesignConstraintCheck` | Part | Physical or structural constraints on a part |
| `FunctionalRequirementCheck` | Action | What the system must do (behavioural) |
| `InterfaceRequirementCheck` | BinaryInterface | Constraints on connections between elements |
| `PerformanceRequirementCheck` | AttributeValue | Measurable performance thresholds |
| `PhysicalRequirementCheck` | Part | Size, weight, material, environmental constraints |

**VSE guidance**: Using these specialised types from the start
reduces rework during SR.5 (IVV), because each type pre-configures
the subject binding. For a small project,
`FunctionalRequirementCheck` and `PerformanceRequirementCheck`
cover most needs.

## Verification types

The verification library defines a verdict taxonomy and method
annotation.

### VerdictKind enumeration

- `pass`: the verification case confirms the requirement is
  satisfied.
- `fail`: the verification case confirms the requirement is not
  satisfied.
- `inconclusive`: the verification case could not determine
  satisfaction.
- `error`: the verification case itself failed to execute
  correctly.

See [[sysml2-case-kinds]] for the verification case construct that
uses this verdict taxonomy.

### VerificationMethod metadata

`VerificationMethod` carries a `kind` feature typed by
`VerificationMethodKind`. Standard verification methods include
*analysis*, *demonstration*, *inspection*, *test*, and
*similarity*.

## See also

- [[sysml2-libraries-architecture]] for the library layering.
- [[sysml2-cases-overview]] for the case family.
- [[sysml2-case-kinds]] for use, analysis, and verification cases.
