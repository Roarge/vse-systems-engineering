# SysML v2 Model Libraries Reference

Source: OMG Systems Modeling Language v2.0, March 2023 (formal/2025-01-01).
Covers the Systems Model Library and Domain Libraries from Chapter 9.
Items marked *syntax to be verified* require further checking.

---

## 1. Library Architecture

SysML v2 organises its predefined types into two layers.

**Systems Model Library** contains the base types that every model implicitly
uses. When you write `part def MyPart`, the language automatically specialises
`Parts::Part` through a `specializeFromLibrary()` constraint. You never need to
import these types explicitly. They provide the structural and behavioural
foundations for all SysML keywords.

**Domain Libraries** are optional packages that you import explicitly when a
project needs specific capabilities such as metadata tracking, trade studies, or
geometric modelling. Each domain library builds on the Systems Model Library
base types.

Library types use qualified names following the pattern `PackageName::TypeName`.
For example, `Parts::Part`, `Requirements::RequirementCheck`, and
`AnalysisCases::AnalysisCase`. These qualified names appear in tool diagnostics
and are useful when you need to reference a base type directly.

**VSE guidance:** Most small projects will only ever need the implicit base
types plus one or two domain library imports (typically metadata and quantities).
Do not import libraries speculatively. Import only what the current lifecycle
phase requires.

---

## 2. Systems Model Library Base Types

The following table maps each SysML keyword to the library definition and usage
types that the language implicitly specialises.

| SysML Keyword | Definition Base Type | Usage Base Type | Key Features |
|---------------|---------------------|-----------------|--------------|
| `attribute` | Base::DataValue | attributeValues | Referential only, no composite features |
| `enum` | (variation of AttributeDefinition) | attributeValues | Always `isVariation=true` |
| `occurrence` | Occurrences::Occurrence | occurrences | Base for all temporal things |
| `item` | Items::Item | items | Specialises Objects::Object |
| `part` | Parts::Part | parts | Specialises Item, composite ownership |
| `port` | Ports::Port | ports | Specialises Object, boundary features |
| `connection` | Connections::Connection | connections | Specialises Part and LinkObject |
| `interface` | Interfaces::Interface | interfaces | Connection with PortUsage ends |
| `allocation` | Allocations::Allocation | allocations | Binary connection for cross-concern mapping |
| `action` | Actions::Action | actions | Features: start, done, subactions, controls |
| `state` | States::StateAction | stateActions | Features: entryAction, doAction, exitAction, substates |
| `calc` | Calculations::Calculation | calculations | Features: subcalculations, result |
| `constraint` | Constraints::ConstraintCheck | constraintChecks | Also: assertedConstraintChecks, negatedConstraintChecks |
| `requirement` | Requirements::RequirementCheck | requirementChecks | Features: actors, assumptions, concerns, constraints, stakeholders, subj |
| `concern` | Requirements::ConcernCheck | concernChecks | Specialises RequirementCheck |
| `verification` | VerificationCases::VerificationCase | verificationCases | Features: verdict (VerdictKind), requirementVerifications |
| `use case` | UseCases::UseCase | useCases | Features: includedUseCases, subUseCases |
| `analysis` | AnalysisCases::AnalysisCase | analysisCases | Features: analysisSteps, result, resultEvaluation |
| `case` | Cases::Case | cases | Features: actors, obj (objective), subcases, subj |
| `view` | Views::View | (no dedicated usage) | Features: subviews, viewRendering, viewpointSatisfactions |
| `viewpoint` | Views::ViewpointCheck | viewpointChecks | Specialises RequirementCheck, subject is a View |
| `rendering` | Views::Rendering | renderings | Specialises Part |
| `metadata` | Metadata::MetadataItem | metadataItems | Specialises Metaobject and Item |

### Specialised Requirement Types

The Systems Model Library provides several requirement specialisations with
pre-bound subject types. These save boilerplate when writing common requirement
categories.

| Requirement Type | Subject Type | Typical Use |
|-----------------|-------------|-------------|
| `DesignConstraintCheck` | Part | Physical or structural constraints on a part |
| `FunctionalRequirementCheck` | Action | What the system must do (behavioural) |
| `InterfaceRequirementCheck` | BinaryInterface | Constraints on connections between elements |
| `PerformanceRequirementCheck` | AttributeValue | Measurable performance thresholds |
| `PhysicalRequirementCheck` | Part | Size, weight, material, environmental constraints |

**VSE guidance:** Using these specialised types from the start reduces rework
during SR.5 (IVV), because each type pre-configures the subject binding. For a
small project, `FunctionalRequirementCheck` and `PerformanceRequirementCheck`
cover most needs.

### Verification Types

The verification library defines a verdict taxonomy and method annotation.

**VerdictKind** enumeration:
- `pass` : the verification case confirms the requirement is satisfied
- `fail` : the verification case confirms the requirement is not satisfied
- `inconclusive` : the verification case could not determine satisfaction
- `error` : the verification case itself failed to execute correctly

**VerificationMethod** metadata definition carries a `kind` feature typed by
`VerificationMethodKind`. Standard verification methods include: *analysis*,
*demonstration*, *inspection*, *test*, and *similarity* (*syntax to be verified*).

---

## 3. Standard View Definitions (9.2.19)

SysML v2 defines eight standard view definitions that tools are expected to
support. Each specifies a rendering strategy.

| View Definition | Short Name | Purpose | Rendering |
|----------------|------------|---------|-----------|
| `ActionFlowView` | `afv` | Action decomposition and flows | GraphicalRendering |
| `CaseView` | `cv` | Use cases, analysis cases, verification cases | GraphicalRendering |
| `GeneralView` | `gv` | Any model element (most general) | Graph of nodes and edges |
| `GeometryView` | `gev` | 2D/3D spatial items visualisation | 2D/3D rendering |
| `GridView` | `grv` | Tabular and matrix layouts | Tabular, data value, relationship matrix |
| `InterconnectionView` | `iv` | Parts, ports, connections between them | Nested nodes with boundary ports |
| `SequenceView` | `sv` | Time-ordered event occurrences on lifelines | Vertical lifelines, horizontal messages |
| `StateTransitionView` | `stv` | States and transitions | Specialises InterconnectionView |

### Standard Renderings

Four built-in renderings cover the common presentation formats:

| Rendering | Type | Use |
|-----------|------|-----|
| `asTreeDiagram` | GraphicalRendering | Hierarchical decomposition trees |
| `asInterconnectionDiagram` | GraphicalRendering | Block-and-port diagrams |
| `asTextualNotation` | TextualRendering | SysML v2 textual syntax output |
| `asElementTable` | TabularRendering | Tables with a `columnView` feature |

### View Usage Example

```sysml
// Define a project-specific view for requirement traceability
view def RequirementTraceView {
    satisfy viewpoint 'Traceability Perspective';
    render asElementTable;
}

// Instantiate the view, exposing specific model content
view reqTrace : RequirementTraceView {
    expose systemRequirements::**;
    filter @StatusInfo and status == StatusKind::done;
}
```

**VSE guidance:** `GeneralView` and `InterconnectionView` will cover most
small-project needs. `GridView` is valuable for generating traceability matrices
from the model. Tool support for standard views varies, so check your tooling
(for example, SySiDE Modeler) for which view types are currently implemented.

---

## 4. Domain Libraries Catalogue

### 4.1 Metadata Domain Library (9.3)

The metadata library is the most immediately useful domain library for VSE
projects. It provides lightweight tracking of status, risk, issues, and
rationale directly within model elements.

#### Modelling Metadata (9.3.2)

| Type | Base | Features |
|------|------|----------|
| `Issue` | MetadataItem | `text : String` |
| `Rationale` | MetadataItem | `explanation : Anything[0..1]`, `text : String` |
| `Refinement` | MetadataItem | `annotatedElement : Dependency` |
| `StatusInfo` | MetadataItem | `originator : String[0..1]`, `owner : String[0..1]`, `risk : Risk[0..1]`, `status : StatusKind` |

**StatusKind** enumeration: `open`, `tbd` (to be determined), `tbc` (to be
confirmed), `tbr` (to be reviewed), `done`, `closed`.

#### Risk Metadata (9.3.3)

| Type | Base | Features |
|------|------|----------|
| `Level` | Real | Constrained to range [0.0, 1.0] |
| `LevelEnum` | | `low` (0.25), `medium` (0.50), `high` (0.75) |
| `Risk` | MetadataItem | `costRisk`, `scheduleRisk`, `technicalRisk`, `totalRisk` (all `RiskLevel[0..1]`) |
| `RiskLevel` | | `probability : Level`, `impact : Level[0..1]` |
| `RiskLevelEnum` | | `low`, `medium`, `high` |

#### Parameters of Interest (9.3.4)

| Type | Short Name | Base | Purpose |
|------|-----------|------|---------|
| `MeasureOfEffectiveness` | `moe` | SemanticMetadata | Tag attributes as effectiveness measures |
| `MeasureOfPerformance` | `mop` | SemanticMetadata | Tag attributes as performance measures |

Base features `measuresOfEffectiveness` and `measuresOfPerformance` provide
collections of tagged attributes on any element.

#### Image Metadata (9.3.5)

| Type | Base | Features |
|------|------|----------|
| `Icon` | MetadataItem | `fullImage : Image[0..1]`, `smallImage : Image[0..1]` |
| `Image` | AttributeValue | `content`, `encoding`, `location`, `type` (all `String[0..1]`) |

#### Metadata Usage Example

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

**VSE guidance:** `StatusInfo` and `Risk` together give a small team
lightweight requirements-maturity tracking without a separate tool. Tag every
requirement with `@StatusInfo` from the start. Update the `status` field as the
requirement matures through `tbd` to `tbc` to `done`.

### 4.2 Analysis Domain Library (9.4)

#### Analysis Tooling (9.4.2)

| Type | Base | Features |
|------|------|----------|
| `ToolExecution` | MetadataItem | `toolName : String`, `uri : String` |
| `ToolVariable` | MetadataItem | `name : String` |

Use `ToolExecution` to annotate actions that execute in external tools (for
example, a MATLAB simulation or Python script). `ToolVariable` maps model
attributes to tool-specific variable names.

#### Sampled Functions (9.4.3)

| Type | Purpose |
|------|---------|
| `SampledFunction` | OrderedMap of SamplePair elements (domainValue to rangeValue) |
| `Domain`, `Range` | Extract domain or range from a sampled function |
| `Sample` | Look up a value in the sampled function |
| `Interpolate`, `interpolateLinear` | Interpolate between sample points |

Sampled functions must be monotonic (strictly increasing or decreasing in the
domain). Use these for lookup tables, calibration curves, and empirical data.

#### State Space Representation (9.4.4)

| Type | Purpose |
|------|---------|
| `StateSpaceDynamics` | Abstract base with `getNextState`, `getOutput` |
| `ContinuousStateSpaceDynamics` | Adds `getDerivative` (x' = f(x, u)) |
| `DiscreteStateSpaceDynamics` | Adds `getDifference` (delta x) |
| `Integrate` | Numerical integration calculation |

**VSE guidance:** State space dynamics are specialised. Most VSE projects will
not need them unless modelling control systems or continuous physical processes.

#### Trade Studies (9.4.5)

| Type | Base | Features |
|------|------|----------|
| `TradeStudy` | AnalysisCase | `studyAlternatives[1..*]`, `evaluationFunction`, `selectedAlternative`, `tradeStudyObjective` |
| `TradeStudyObjective` | RequirementCheck | Constraint: `fn(selectedAlternative) == best` |
| `MaximizeObjective` | TradeStudyObjective | Select the alternative with the highest score |
| `MinimizeObjective` | TradeStudyObjective | Select the alternative with the lowest score |
| `EvaluationFunction` | Calculation | Takes alternative, returns ScalarValue |

#### Trade Study Example

```sysml
import TradeStudies::*;

part def SensorOption {
    attribute cost : Real;
    attribute accuracy : Real;
    attribute powerConsumption : Real;
}

part optionA : SensorOption {
    attribute :>> cost = 50.0;
    attribute :>> accuracy = 0.95;
    attribute :>> powerConsumption = 2.5;
}

part optionB : SensorOption {
    attribute :>> cost = 30.0;
    attribute :>> accuracy = 0.88;
    attribute :>> powerConsumption = 1.2;
}

// Weighted scoring function
calc def SensorScore {
    in alternative : SensorOption;
    return : Real;
    0.4 * alternative.accuracy + 0.35 * (1.0 / alternative.cost)
        + 0.25 * (1.0 / alternative.powerConsumption)
}

analysis sensorTradeStudy : TradeStudy {
    subject sensorChoice : SensorOption;
    objective : MaximizeObjective;
    calc :>> evaluationFunction : SensorScore;
    part :>> studyAlternatives = (optionA, optionB);
    return :>> selectedAlternative;
}
```

*Syntax to be verified: the inline assignment of studyAlternatives using
tuple notation.*

**VSE guidance:** Trade studies are one of the highest-value modelling
activities for a small team. Encoding the decision criteria and weights in the
model provides an auditable record for SR.3 architecture decisions.

### 4.3 Cause and Effect Domain Library (9.5)

| Type | Base | Features |
|------|------|---------|
| `Multicausation` | ConnectionDefinition | `causes[1..*]`, `effects[1..*]`, `disjointCauseEffect` constraint |
| `Causation` | Multicausation | Binary variant (single cause to single effect) |

Metadata annotations:
- `CausationMetadata` (annotates a connection as causal)
- `CauseMetadata` (short name: `cause`, annotates the cause end)
- `EffectMetadata` (short name: `effect`, annotates the effect end)

Use this library for fault tree analysis and FMEA modelling. It enforces the
constraint that causes and effects must be disjoint (an element cannot be both
cause and effect within the same relationship).

**VSE guidance:** Valuable during SR.5 for structured safety analysis. Even a
simple fault tree in the model provides traceability from hazards to mitigations.

### 4.4 Requirement Derivation Domain Library (9.6)

| Type | Base | Features |
|------|------|---------|
| `Derivation` | ConnectionDefinition | `originalRequirement`, `derivedRequirements[1..*]` |

Constraints:
- `originalImpliesDerived`: satisfying the original implies satisfying all
  derived requirements
- `originalNotDerived`: the original must not itself be a derived requirement
  in the same derivation chain

Metadata annotations:
- `DerivationMetadata` (short name: `derivation`)
- `DerivedRequirementMetadata` (short name: `derive`)
- `OriginalRequirementMetadata` (short name: `original`)

#### Derivation Example

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

*Syntax to be verified: the tuple form for derivedRequirements end binding.*

**VSE guidance:** Use derivation connections to maintain the traceability chain
from stakeholder needs to system requirements. This directly supports the R3
traceability principle and the `@traceability-guard` skill.

### 4.5 Geometry Domain Library (9.7)

**Spatial Items (9.7.2):** `SpatialItem` specialises `ItemDefinition` and adds
`coordinateFrame`, `localClock`, and `originPoint`. Position and displacement
calculations are provided for coordinate transformations.

**Shape Items (9.7.3):** The library provides an extensive catalogue of 2D and
3D shape definitions.

Key 2D shapes: `Circle`, `Ellipse`, `Rectangle`, `Polygon`, `Triangle`,
`ClosedCurve`.

Key 3D shapes: `Sphere`, `Cuboid`, `Cylinder`, `Cone`, `Pyramid`, `Torus`,
`Shell`.

Each shape definition includes dimensional attributes (for example, `radius`
for `Sphere`, `length`/`width`/`height` for `Cuboid`) and surface area and
volume calculations where applicable.

**VSE guidance:** Most VSE projects will not need the geometry library unless
modelling physical layouts, sensor placement, or spatial constraints. If your
project involves physical design, consider importing only the specific shape
types you need rather than the entire library.

---

## 5. Common Import Patterns for VSE Projects

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

Note: ISQ (International System of Quantities) and SI (International System of
Units) are defined in the KerML standard library, not the SysML domain
libraries. They are essential for any project dealing with physical quantities
and should be imported in nearly every VSE project that models hardware.

### Verification methods

```sysml
import VerificationCases::*;
```

### Performance note

Prefer selective imports (`import Package::SpecificType`) over recursive
imports (`import Package::**`) to reduce model loading time. This matters when
using SySiDE or other tools that resolve imports at edit time.

---

## 6. VSE Library Selection Guide

Not every project needs every library. Use this decision guide to select only
what the current phase requires.

| Phase | Recommended Libraries | Rationale |
|-------|----------------------|-----------|
| SR.1 Initiation | None (implicit base types only) | Keep the model skeleton minimal |
| SR.2 Requirements | StatusInfo, Risk, ISQ/SI | Track requirement maturity, tag measurable attributes |
| SR.3 Architecture | StatusInfo, TradeStudies, ISQ/SI | Evaluate design alternatives with auditable criteria |
| SR.4 Construction | ISQ/SI, ToolExecution | Map model attributes to build and analysis tools |
| SR.5 IVV | VerificationCases, CauseAndEffect, RequirementDerivation | Structure test cases, trace derivations, model fault trees |
| SR.6 Delivery | Views (standard view definitions) | Generate deliverable views and tables from the model |

**Principle:** Import a domain library at the point of need, not at project
start. This keeps early models fast to parse and easy to understand. A small
team benefits from a model that stays readable throughout the lifecycle.

---

*Generated from OMG SysML v2.0 specification Chapter 9 for use with the VSE Systems Engineering plugin.*
