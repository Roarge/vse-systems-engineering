---
title: "SysML 2.0 Domain Libraries: Metadata and Analysis"
slug: sysml2-domain-libraries-metadata-analysis
type: reference
layer: sysml2
tags: [metadata-library, analysis-library, status, risk, trade-study, moe, mop]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Sections 9.3 and 9.4."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-libraries-architecture
  - sysml2-metadata-overview
  - sysml2-vse-library-metadata
  - sysml2-domain-libraries-causation-geometry
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Domain Libraries: Metadata and Analysis

This page covers the two most-used domain libraries: the Metadata
library (status, risk, parameters of interest, image metadata) and
the Analysis library (tool execution, sampled functions, state
space dynamics, trade studies).

## Metadata domain library (9.3)

The metadata library is the most immediately useful domain library
for VSE projects. It provides lightweight tracking of status,
risk, issues, and rationale directly within model elements. For
the underlying metadata mechanism see
[[sysml2-metadata-overview]].

### Modelling metadata (9.3.2)

| Type | Base | Features |
|---|---|---|
| `Issue` | MetadataItem | `text : String` |
| `Rationale` | MetadataItem | `explanation : Anything[0..1]`, `text : String` |
| `Refinement` | MetadataItem | `annotatedElement : Dependency` |
| `StatusInfo` | MetadataItem | `originator : String[0..1]`, `owner : String[0..1]`, `risk : Risk[0..1]`, `status : StatusKind` |

`StatusKind` enumeration: `open`, `tbd` (to be determined), `tbc`
(to be confirmed), `tbr` (to be reviewed), `done`, `closed`.

### Risk metadata (9.3.3)

| Type | Base | Features |
|---|---|---|
| `Level` | Real | Constrained to range [0.0, 1.0] |
| `LevelEnum` | (enum) | `low` (0.25), `medium` (0.50), `high` (0.75) |
| `Risk` | MetadataItem | `costRisk`, `scheduleRisk`, `technicalRisk`, `totalRisk` (all `RiskLevel[0..1]`) |
| `RiskLevel` | | `probability : Level`, `impact : Level[0..1]` |
| `RiskLevelEnum` | (enum) | `low`, `medium`, `high` |

For the VSE-specific risk and configuration library that ships
with the plugin, see [[sysml2-vse-library-metadata]].

### Parameters of interest (9.3.4)

| Type | Short name | Base | Purpose |
|---|---|---|---|
| `MeasureOfEffectiveness` | `moe` | SemanticMetadata | Tag attributes as effectiveness measures |
| `MeasureOfPerformance` | `mop` | SemanticMetadata | Tag attributes as performance measures |

Base features `measuresOfEffectiveness` and `measuresOfPerformance`
provide collections of tagged attributes on any element.

### Image metadata (9.3.5)

| Type | Base | Features |
|---|---|---|
| `Icon` | MetadataItem | `fullImage : Image[0..1]`, `smallImage : Image[0..1]` |
| `Image` | AttributeValue | `content`, `encoding`, `location`, `type` (all `String[0..1]`) |

### Worked example: requirement with status and risk

```sysml
import Metadata::StatusInfo::*;
import Metadata::Risk::*;

requirement def <'REQ-001'> MaxOperatingTemperature {
    doc /* The sensor shall operate within -20 to +85 degrees Celsius. */

    @StatusInfo {
        status = StatusKind::tbc;
        owner = "Systems Engineer";
        risk = Risk {
            technicalRisk = RiskLevel {
                probability = LevelEnum::low;
                impact = LevelEnum::medium;
            };
        };
    }

    subject sensor : TemperatureSensor;
    attribute tempMin : TemperatureValue;
    attribute tempMax : TemperatureValue;
    require constraint { tempMin >= -20 [°C] and tempMax <= 85 [°C] }
}
```

**VSE guidance**: `StatusInfo` and `Risk` together give a small
team lightweight requirements-maturity tracking without a separate
tool. Tag every requirement with `@StatusInfo` from the start.
Update the `status` field as the requirement matures through
`tbd` to `tbc` to `done`.

## Analysis domain library (9.4)

### Analysis tooling (9.4.2)

| Type | Base | Features |
|---|---|---|
| `ToolExecution` | MetadataItem | `toolName : String`, `uri : String` |
| `ToolVariable` | MetadataItem | `name : String` |

Use `ToolExecution` to annotate actions that execute in external
tools (a MATLAB simulation or Python script). `ToolVariable` maps
model attributes to tool-specific variable names.

### Sampled functions (9.4.3)

| Type | Purpose |
|---|---|
| `SampledFunction` | OrderedMap of SamplePair elements (domainValue to rangeValue) |
| `Domain`, `Range` | Extract domain or range from a sampled function |
| `Sample` | Look up a value in the sampled function |
| `Interpolate`, `interpolateLinear` | Interpolate between sample points |

Sampled functions must be monotonic (strictly increasing or
decreasing in the domain). Use these for lookup tables,
calibration curves, and empirical data.

### State space representation (9.4.4)

| Type | Purpose |
|---|---|
| `StateSpaceDynamics` | Abstract base with `getNextState`, `getOutput` |
| `ContinuousStateSpaceDynamics` | Adds `getDerivative` (x' = f(x, u)) |
| `DiscreteStateSpaceDynamics` | Adds `getDifference` (delta x) |
| `Integrate` | Numerical integration calculation |

**VSE guidance**: State space dynamics are specialised. Most VSE
projects will not need them unless modelling control systems or
continuous physical processes.

### Trade studies (9.4.5)

| Type | Base | Features |
|---|---|---|
| `TradeStudy` | AnalysisCase | `studyAlternatives[1..*]`, `evaluationFunction`, `selectedAlternative`, `tradeStudyObjective` |
| `TradeStudyObjective` | RequirementCheck | Constraint: `fn(selectedAlternative) == best` |
| `MaximizeObjective` | TradeStudyObjective | Select the alternative with the highest score |
| `MinimizeObjective` | TradeStudyObjective | Select the alternative with the lowest score |
| `EvaluationFunction` | Calculation | Takes alternative, returns ScalarValue |

**VSE guidance**: Trade studies are one of the highest-value
modelling activities for a small team. Encoding the decision
criteria and weights in the model provides an auditable record
for SR.3 architecture decisions.

## See also

- [[sysml2-libraries-architecture]] for the library layering.
- [[sysml2-metadata-overview]] for the metadata mechanism.
- [[sysml2-vse-library-metadata]] for the plugin-shipped risk and
  configuration library.
- [[sysml2-domain-libraries-causation-geometry]] for the remaining
  domain libraries (Cause/Effect, Derivation, Geometry).
