# Agile Model-Based Architecture Design (VSE-Scaled)

Source: Douglass, B.P. (2016) *Agile Systems Engineering*, Chapters 2, 6-8;
Douglass, B.P. (2021) *Agile MBSE Cookbook*, Chapters 3-5.
Methodology extracted and scaled for Very Small Entities. SysML v1 notation replaced
with SysML v2 textual syntax. Tool references replaced with Sensmetry SySiDE.

---

## 1. Architecture in Agile MBSE

Architecture in AMBSE has two distinct activities:

- **Architectural analysis**: evaluate candidate architectures and select the best fit
  through trade studies (ISO 29110 SR.3, early)
- **Architectural design**: implement the selected architecture by identifying
  subsystems, allocating requirements, and defining interfaces (ISO 29110 SR.3)

Both activities are performed incrementally, per iteration. Each iteration refines and
extends the architecture as new use cases are specified.

---

## 2. Architectural Analysis

The architectural analysis workflow selects among candidate architectures:

### 2.1 Workflow steps

1. **Identify key system functions** from the requirements specified so far
2. **Define candidate solutions** (at least two architectural alternatives)
3. **Perform trade study** (see Section 3)
4. **Merge selected solutions** into the evolving system architecture
5. **Perform review**

### 2.2 Architecture views

Douglass identifies five views of the system architecture. Each addresses a different
concern and uses different SysML v2 constructs.

| View | Concern | SysML v2 Constructs |
|------|---------|-------------------|
| Subsystem | Decomposition into major parts | `part def`, nested `part` usages |
| Deployment | Allocation of functions to physical elements | `allocation def`, `allocate` |
| Dependability | Safety, reliability, security overlay | `requirement def` with constraints |
| Distribution | Geographic/network distribution | `part def` with `connect` statements |
| Concurrency | Concurrent execution and synchronisation | `state def`, `action def` with forks |

VSE guidance: not all views are needed for every project. The subsystem view is
always required. Add deployment when hardware is involved. Add dependability
for safety-critical systems. Distribution and concurrency views are optional for
most VSE projects.

---

## 3. Trade Study Methodology

Trade studies are the primary mechanism for making defensible architectural
decisions. The method ensures decisions are traceable, reproducible, and based
on stakeholder-weighted criteria rather than personal preference.

### 3.1 Workflow steps

1. **Define assessment criteria** (measures of effectiveness, MOEs) derived from
   system requirements. Typical criteria: performance, cost, risk, schedule,
   weight, power consumption, maintainability, safety
2. **Assign weights to criteria** reflecting stakeholder priorities (sum to 1.0)
3. **Define utility curves** for non-linear criteria (optional for VSEs, but important
   when a criterion has a threshold effect, such as "good enough" vs "unacceptable")
4. **Score each candidate** against each criterion (0.0 to 1.0)
5. **Compute weighted scores** and rank candidates
6. **Perform sensitivity analysis**: vary the weights by +/- 10-20% and check whether
   the ranking changes. If the top candidate is sensitive to small weight changes,
   the decision needs more analysis.
7. **Document the rationale** in a Justification Document (or as a doc comment on
   the selected architecture element in SysML v2)

### 3.2 VSE trade study guidance

- A simple weighted matrix in a markdown table or spreadsheet suffices
- Always consider at least two alternatives (even "do nothing" counts)
- The process matters more than the precision: the discipline of explicitly stating
  criteria and weights surfaces hidden assumptions
- Record the trade study rationale in the model or in a lightweight decision record
  (see `@architecture-design` skill for ADR templates)

### 3.3 SysML v2 trade study documentation

```sysml
package TradeStudy_MotorControl {
    doc /* Trade study for motor control architecture.
           Candidates: (A) Direct PWM control, (B) FOC with encoder.
           Criteria: performance (0.4), cost (0.3), risk (0.2), schedule (0.1).
           Result: Candidate B selected (weighted score 0.78 vs 0.65).
           Sensitivity: Robust to +/- 15% weight variation. */

    // Selected architecture
    part def MotorControlSubsystem {
        doc /* FOC with encoder, selected per trade study above. */
        part controller : FOCController;
        part encoder : RotaryEncoder;
        part driver : MotorDriver;
    }
}
```

---

## 4. Architectural Design

Once an architecture is selected, the design activity implements it by decomposing
the system into subsystems, allocating requirements, and defining interfaces.

### 4.1 Workflow steps

1. **Identify subsystems**: a subsystem is a large-scale piece of the system that
   provides a coherent set of functionality and is typically implemented with a
   combination of engineering disciplines (mechanical, electronic, software)
2. **Allocate system requirements to subsystems**: some requirements map directly,
   others must be decomposed into derived subsystem requirements
3. **Allocate use cases to subsystems** (see Section 4.2)
4. **Create/update logical data schema**: define the data types, ranges, accuracy,
   and units for data flows between subsystems
5. **Create/update subsystem requirements**: derived requirements that specify
   what each subsystem must do
6. **Develop control laws** (if applicable): for systems with continuous control
   behaviour crossing subsystem boundaries
7. **Analyse dependability**: assess safety, reliability, and security implications
   of the architectural design decisions
8. **Perform review**

### 4.2 Two approaches to use case allocation

When allocating system-level use cases to subsystems, there are two approaches:

**Bottom-up (action allocation)**:
- Examine each message in the system-level scenarios
- Identify which subsystem(s) play a role in each message
- Derive "white box scenarios" showing subsystem-to-subsystem interactions
- Group subsystem services into subsystem-level use cases

**Top-down (use case decomposition)**:
- Think at a high level about what each subsystem must provide
- Decompose system-level use cases into collaborating subsystem-level use cases
- Then elaborate the white-box scenarios

Both approaches produce the same result: subsystem-level use cases and white-box
scenarios. The bottom-up approach is more systematic. The top-down approach is
faster when the decomposition is obvious.

VSE guidance: use whichever feels more natural. For a first project, bottom-up
is safer because it forces you to trace every system behaviour to a subsystem.

### 4.3 SysML v2 architecture modelling

```sysml
package SystemArchitecture {
    import SystemRequirements::*;

    // Subsystem definitions
    part def SensingSubsystem {
        doc /* Acquires environmental data from sensors. */
        port sensorDataOut : SensorDataPort;
        part tempSensor : TemperatureSensor;
        part pressureSensor : PressureSensor;
    }

    part def ProcessingSubsystem {
        doc /* Processes sensor data and executes control logic. */
        port sensorDataIn : ~SensorDataPort;
        port commandOut : CommandPort;
        part processor : Microcontroller;
    }

    part def ActuationSubsystem {
        doc /* Executes physical actions based on commands. */
        port commandIn : ~CommandPort;
        part motor : StepperMotor;
    }

    // System composition
    part def SmartSensorSystem {
        part sensing : SensingSubsystem;
        part processing : ProcessingSubsystem;
        part actuation : ActuationSubsystem;

        // Internal connections
        connect sensing.sensorDataOut to processing.sensorDataIn;
        connect processing.commandOut to actuation.commandIn;
    }

    // Requirement allocation
    allocate MeasureTemperature to sensing;
    allocate TemperatureResponseTime to processing;
}
```

---

## 5. Interface Specification

Interfaces are the most critical architectural artefact for system integration.
Douglass emphasises that interface defects are among the most expensive to fix
because they affect multiple subsystems.

### 5.1 Logical vs physical interfaces

During architectural design, interfaces are **logical**: they specify the essential
properties of data and control flows without committing to a physical
implementation. Logical interfaces capture:

- Data type, range, accuracy, and units
- Direction of flow (in, out, inout)
- Timing constraints (update rate, latency)
- Protocol semantics (request-response, publish-subscribe, streaming)

Physical interfaces (wire protocol, connector type, voltage levels) are defined
during the handoff to downstream engineering.

### 5.2 SysML v2 interface modelling

```sysml
// Port definition with typed features
port def SensorDataPort {
    out item temperatureReading : TemperatureValue;
    out item pressureReading : PressureValue;
    attribute updateRate : Real = 10.0; // Hz
}

// Interface definition connecting two subsystems
interface def SensingToProcessing {
    end port supplier : SensorDataPort;
    end port receiver : ~SensorDataPort;
}

// Interface usage
interface sensingLink : SensingToProcessing
    connect sensing.sensorDataOut to processing.sensorDataIn;
```

### 5.3 VSE interface guidance

- Define interfaces early and baseline them before downstream engineering begins
- Interfaces are configuration-managed: changes require a Change Request
- For each interface, document the owner (which subsystem team controls it)
- Test interface assumptions in the first iteration (integration risk reduction)

---

## 6. Handoff to Downstream Engineering

The handoff is not an event but a **workflow** that transforms system engineering
data into the data needed by implementation disciplines. This is a critical activity
that is often done poorly.

### 6.1 Handoff workflow (two parallel flows)

**Shared model flow** (for data shared by two or more subsystems):
1. Gather subsystem specification data (SRS, architecture, logical ICD, scenarios)
2. Create the shared model (interfaces, shared data definitions, shared resources)
3. Define physical interfaces (transform logical to physical specifications)

**Subsystem model flow** (repeated for each subsystem):
1. Create the subsystem model (import requirements from the system model)
2. Define interdisciplinary interfaces (software-electronic, electro-mechanical)
3. Allocate requirements to engineering disciplines
4. Output: subsystem SRS, physical ICD, discipline-specific requirements

### 6.2 Handoff package contents

A complete handoff package for each subsystem includes:

| Artefact | Description |
|----------|------------|
| Subsystem requirements | Allocated and derived requirements |
| Interface specification | Physical ICD with protocols and data formats |
| Verification criteria | Test cases and acceptance criteria per requirement |
| Behavioural model | State machines or action sequences for subsystem use cases |
| Design constraints | Technology, environmental, and regulatory constraints |
| Rationale | Trade study results and architectural decisions |

### 6.3 Handoff as iteration boundary

In the hybrid lifecycle, the handoff occurs at iteration boundaries:
- System engineers hand off iteration N to downstream engineers
- System engineers proceed to specify iteration N+1
- This creates pipeline parallelism even in small teams (the same person
  switches roles at the iteration boundary)

VSE guidance: the handoff can be as simple as a Git tag with a summary of what
changed, combined with a brief walkthrough of the new subsystem requirements.
Do not over-formalise the handoff for small teams. The key is that downstream
engineering has an unambiguous, baselined specification to work from.

---

## 7. Model-Based Verification and Validation

V&V in AMBSE operates at all three verification timeframes and uses the model
as the primary verification artefact.

### 7.1 Continuous verification at architecture level

| Timeframe | Activity | Plugin Mapping |
|-----------|----------|---------------|
| Nanocycle | SySiDE syntax validation, constraint checking, trace completeness | Pre-commit hook, SySiDE on save |
| Microcycle | Peer model review, use case walkthrough, iteration acceptance | Phase gate check, iteration review |
| Macrocycle | System-level V&V, formal acceptance | SR.5 activities, PM.4 |

### 7.2 Use case driven validation

Validation ensures the system meets stakeholder needs (not just requirements).
The AMBSE approach to validation:

1. For each stakeholder use case, walk through the architecture model
2. For each scenario in the use case, trace the data and control flow through
   the subsystem decomposition
3. Verify that every step in the scenario is supported by a subsystem service
4. Identify gaps where the architecture cannot support a scenario step
5. Report gaps as either missing requirements or architectural defects

### 7.3 SysML v2 verification modelling

```sysml
package VerificationCases {
    import SystemRequirements::*;

    verification def VerifyTempAccuracy {
        doc /* Verify temperature measurement accuracy.
               Method: Test.
               Procedure: Apply known temperature sources at -20, 0, 25, 50,
               and 85 degrees C. Record system readings. Verify all readings
               are within +/- 0.5 degrees C of the source. */
        attribute method = "test";
        verify requirement SystemRequirements::MeasureTemperature;
    }

    verification def VerifyTempResponseTime {
        doc /* Verify temperature response time.
               Method: Test.
               Procedure: Apply a step change in temperature. Measure time
               from stimulus to reported reading. Verify less than 100 ms. */
        attribute method = "test";
        verify requirement SystemRequirements::TemperatureResponseTime;
    }
}
```

### 7.4 Definition of done for SE velocity

A use case is "done" (counted in SE velocity) when all of the following are satisfied:

- A full description identifying purpose, preconditions, postconditions, and invariants
- A normative behavioural model (state machine or action sequence) in which all
  requirements are traced to and from the use case
- A minimal spanning set of scenarios covering all paths in the normative model
- Trace links to all related functional and quality of service requirements
- Architecture allocation showing which subsystems implement the use case
- System interfaces with a physical data schema supporting the use case interactions
- Logical verification cases to verify the use case requirements
- Logical validation cases to ensure the use case satisfies stakeholder needs

---

## 8. Mapping AMBSE Architecture to ISO 29110

| AMBSE Activity | ISO 29110 Activity | Notes |
|----------------|-------------------|-------|
| Identify key system functions | SR.3.1 | From requirements specified so far |
| Define candidate solutions | SR.3.2 | At least two alternatives |
| Perform trade study | SR.3.3 | Weighted criteria, sensitivity analysis |
| Merge into system architecture | SR.3.4 | Incremental, per iteration |
| Identify subsystems | SR.3.5 | Decomposition into major parts |
| Allocate requirements to subsystems | SR.3.6 | Direct and derived allocations |
| Allocate use cases to subsystems | SR.3.7 | Bottom-up or top-down approach |
| Define subsystem interfaces | SR.3.8 | Logical, then physical at handoff |
| Develop control laws | SR.3.9 | Only for continuous control systems |
| Analyse dependability | SR.3.10 | Safety, reliability, security |
| Handoff to downstream engineering | SR.3 to SR.4 | Iteration boundary workflow |
| Architecture-level V&V | SR.5 (ongoing) | Nanocycle, microcycle, macrocycle |

See also: `knowledge/ambse-agile-process.md` for lifecycle context,
`knowledge/ambse-requirements.md` for requirements modelling patterns,
`knowledge/vv-guide.md` for V&V methods.
