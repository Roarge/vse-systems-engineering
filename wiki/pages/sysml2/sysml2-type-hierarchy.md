---
title: "SysML 2.0 Type Hierarchy: DataValue and Occurrence Branches"
slug: sysml2-type-hierarchy
type: reference
layer: sysml2
tags: [type-hierarchy, datavalue, occurrence, library-types]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Chapter 6."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-language-architecture
  - sysml2-specialisation-and-typing
  - sysml2-systems-model-library
  - sysml2-occurrences-4d
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Type Hierarchy: DataValue and Occurrence Branches

## The two disjoint branches

The SysML 2.0 type system has two fundamental branches that
**cannot overlap**:

- **DataValue branch** (attributes, enumerations): things that
  have no independent existence, no lifecycle, and no spatial
  extent.
- **Occurrence branch** (parts, ports, actions, states, etc.):
  things that exist in time and space, have lifecycles, and can
  participate in interactions.

**Key rule**: DataValue and Occurrence are **disjoint**. You
cannot define something that is both an attribute and a part. An
attribute cannot own composite features. This rule is the single
most common source of validation errors for new modellers.

For the 4D worldview that frames the Occurrence branch, see
[[sysml2-occurrences-4d]].

## Hierarchy tree

```
Base::Anything
 +-- Base::DataValue
 |    +-- AttributeDefinition
 |    +-- EnumerationDefinition (always isVariation=true)
 |
 +-- Occurrences::Occurrence
      +-- OccurrenceDefinition
           +-- Items::Item (specialises Objects::Object)
           |    +-- ItemDefinition
           |    +-- Parts::Part (specialises Items::Item)
           |         +-- PartDefinition
           |         +-- Connections::Connection (also Links::LinkObject)
           |         |    +-- ConnectionDefinition
           |         |    +-- Interfaces::Interface (ends must be PortUsages)
           |         |    |    +-- InterfaceDefinition
           |         |    +-- Allocations::Allocation (binary)
           |         |         +-- AllocationDefinition
           |         +-- Views::View
           |         |    +-- ViewDefinition
           |         +-- Views::Rendering
           |              +-- RenderingDefinition
           |
           +-- Objects::Object
           |    +-- Ports::Port
           |         +-- PortDefinition
           |
           +-- Performances::Performance
                +-- Actions::Action
                     +-- ActionDefinition
                     +-- States::StateAction
                     |    +-- StateDefinition
                     +-- Calculations::Calculation (also Evaluations::Evaluation)
                          +-- CalculationDefinition
                          +-- Constraints::ConstraintCheck (BooleanEvaluation)
                          |    +-- ConstraintDefinition
                          |    +-- Requirements::RequirementCheck
                          |         +-- RequirementDefinition
                          |         +-- Requirements::ConcernCheck
                          |         |    +-- ConcernDefinition
                          |         +-- Views::ViewpointCheck
                          |              +-- ViewpointDefinition
                          +-- Cases::Case
                               +-- CaseDefinition
                               +-- AnalysisCases::AnalysisCase
                               |    +-- AnalysisCaseDefinition
                               +-- VerificationCases::VerificationCase
                               |    +-- VerificationCaseDefinition
                               +-- UseCases::UseCase
                                    +-- UseCaseDefinition
```

## Summary table

| Definition keyword | Implicit base type | Branch | Key constraint |
|---|---|---|---|
| `attribute def` | `Base::DataValue` | DataValue | Always referential, no composite features |
| `enum def` | variation `AttributeDefinition` | DataValue | `isVariation=true` always |
| `occurrence def` | `Occurrences::Occurrence` | Occurrence | General occurrence |
| `item def` | `Items::Item` | Occurrence | Specialises `Objects::Object` |
| `part def` | `Parts::Part` | Occurrence | Composite by default |
| `port def` | `Ports::Port` | Occurrence | Boundary feature, supports conjugation |
| `connection def` | `Connections::Connection` | Occurrence | At least 2 ends (unless abstract) |
| `interface def` | `Interfaces::Interface` | Occurrence | Ends must be PortUsages |
| `allocation def` | `Allocations::Allocation` | Occurrence | Binary connection |
| `action def` | `Actions::Action` | Occurrence | Owns subactions, successions, control nodes |
| `state def` | `States::StateAction` | Occurrence | Exclusive substates unless parallel |
| `calc def` | `Calculations::Calculation` | Occurrence | Has result parameter |
| `constraint def` | `Constraints::ConstraintCheck` | Occurrence | Boolean evaluation |
| `requirement def` | `Requirements::RequirementCheck` | Occurrence | Has subject, assume/require structure |
| `concern def` | `Requirements::ConcernCheck` | Occurrence | Specialises RequirementCheck |
| `case def` | `Cases::Case` | Occurrence | Specialises Calculation |
| `analysis def` | `AnalysisCases::AnalysisCase` | Occurrence | Specialises Case |
| `verification def` | `VerificationCases::VerificationCase` | Occurrence | Specialises Case, verify link |
| `use case def` | `UseCases::UseCase` | Occurrence | Specialises Case |
| `view def` | `Views::View` | Occurrence | Specialises Part |
| `viewpoint def` | `Views::ViewpointCheck` | Occurrence | Specialises RequirementCheck |
| `rendering def` | `Views::Rendering` | Occurrence | Specialises Part |

## See also

- [[sysml2-language-architecture]] for the KerML/SysML layering.
- [[sysml2-specialisation-and-typing]] for `:>`, `:>>`, `subsets`,
  `ref`.
- [[sysml2-systems-model-library]] for the keyword-to-base-type
  mapping with key features per type.
- [[sysml2-occurrences-4d]] for the 4D worldview behind the
  Occurrence branch.
