# Agile Model-Based Requirements Engineering (VSE-Scaled)

Source: Douglass, B.P. (2016) *Agile Systems Engineering*, Chapters 2, 4-5;
Douglass, B.P. (2021) *Agile MBSE Cookbook*, Chapter 2.
Methodology extracted and scaled for Very Small Entities. SysML v1 notation replaced
with SysML v2 textual syntax. Tool references replaced with Sensmetry SySiDE.

---

## 1. Requirements in Agile MBSE

In agile model-based SE, requirements are not standalone text documents. They exist
as model elements within a SysML v2 repository, linked to the behavioural and
structural models that specify the system. This dual representation (text + model)
combines the expressiveness of natural language with the precision of formal models.

Key principles:

- **Text explains why, models specify what.** Natural language is excellent for
  rationale, context, and stakeholder communication. SysML v2 models are
  precise enough for verification through testing and formal analysis.
- **Requirements are grouped by use case.** Each use case has its own set of
  requirements, its own behavioural model (state machine or action sequence),
  and its own verification cases.
- **Requirements are developed incrementally.** One use case (or a small group)
  is fully specified and verified before moving to the next.
- **Verification is planned when requirements are written.** For each requirement,
  identify the verification method (analysis, inspection, demonstration, test)
  at the time of creation. See `knowledge/vv-guide.md` for the VCRM approach.

---

## 2. Stakeholder Identification

Douglass identifies 16 stakeholder types. For a VSE, many of these roles collapse
to 2 or 3 actual people, but the checklist ensures no perspective is missed.

| Stakeholder Type | Concern | VSE Note |
|-----------------|---------|----------|
| Purchaser | Budget, ROI, schedule | Often the same as User |
| User | Usability, functionality, performance | Primary stakeholder |
| Evaluator | Testability, acceptance criteria | Often the developer |
| Marketer | Market fit, competitive position | May be the purchaser |
| Seller | Sales enablement, pricing | May not exist for internal systems |
| Trainer | Learnability, documentation | Often the developer |
| Manufacturer | Producibility, yield, cost | Relevant for hardware |
| Acquirer | Compliance, standards | Regulatory or contractual |
| Installer | Installation ease, compatibility | Often the user |
| Maintenance staff | Maintainability, diagnostics | Often the developer |
| Support services | Supportability, logging | Often the developer |
| Operations management | Reliability, uptime | Often the purchaser |
| Certification agencies | Safety, compliance, evidence | Domain-specific |
| Customer support | Issue resolution, documentation | Often the developer |
| Disposal services | End-of-life, environmental | Often overlooked |

VSE guidance: map each type to a named person. If a type has no named person,
either the concern is not relevant or you have a stakeholder gap to investigate.

---

## 3. Use Case Driven Elicitation

Use cases are the primary structuring mechanism for stakeholder requirements in
AMBSE. A use case captures a coherent set of actor-system interactions that deliver
value to a stakeholder.

### 3.1 Use case mission statement

Before detailing requirements, create a mission statement for each use case:

- **Name**: short descriptive name
- **Purpose**: what value does this deliver to the stakeholder(s)?
- **Description**: what input-output data and control transformations are needed?
- **Preconditions**: what must be true before these behaviours run?
- **Postconditions**: what must be true after these behaviours have run?
- **Invariants**: what assumptions are we making throughout?

### 3.2 Use case prioritisation

Use cases are prioritised for iteration ordering. Factors to consider:

| Factor | Question |
|--------|----------|
| Stakeholder benefit | Is this useful, important, or critical? |
| Architectural impact | Does it extend, reorganise, or leave the architecture unchanged? |
| Risk mitigation | Does this use case address a known project risk? |
| Information availability | Is the subject matter expert available to specify it? |

General rule: critical, high-impact, high-risk use cases with available information
should be specified first.

### 3.3 From use cases to stakeholder needs

Each use case generates stakeholder needs through scenario analysis:

1. **Define the system context**: identify actors and their relationships to the system
2. **Define use case scenarios**: normal flow, alternate flows, exception flows
3. **Extract needs from scenario steps**: each step where the system must respond
   generates a candidate stakeholder need (STK-nnn)
4. **Review with stakeholders**: walk through scenarios to validate needs

### 3.4 SysML v2 use case modelling

```sysml
package StakeholderNeeds {
    // Actor definitions
    part def Rider;
    part def TrainingApp;

    // Use case definitions
    use case def ManuallyAdjustBikeFit {
        doc /* Enable rider to adjust bike fit prior to ride. */
        subject part bikeTrainer : BikeTrainer;
        actor part rider : Rider;
    }

    use case def ControlResistance {
        doc /* Control resistance to pedalling in a steady
               and well-controlled fashion. */
        subject part bikeTrainer : BikeTrainer;
        actor part rider : Rider;
        actor part trainingApp : TrainingApp;

        include use case provideBasicResistance;
        include use case setResistanceUnderUserControl;
        include use case setResistanceUnderExternalControl;
    }
}
```

---

## 4. System Requirements Derivation

System requirements are derived from stakeholder needs by identifying what the
system must do or be to satisfy each need. The derivation workflow proceeds
per use case:

### 4.1 Derivation workflow

For each stakeholder need within the current iteration:

1. **Identify system functions**: what must the system do to satisfy this need?
2. **Derive functional requirements**: for each function, write a measurable
   requirement (REQ-nnn) with a `satisfy` link to the stakeholder need
3. **Derive performance requirements**: for each functional requirement, identify
   quality of service constraints (timing, accuracy, capacity, throughput)
4. **Derive interface requirements**: for each external interaction, specify the
   interface protocol, data format, and physical characteristics
5. **Derive constraint requirements**: identify regulatory, environmental,
   or design constraints that apply
6. **Add verification method**: for each requirement, record the planned
   verification method (analysis, inspection, demonstration, test)

### 4.2 Requirement quality criteria

Every system requirement should be:

- **Singular**: one requirement per statement (no "and" joining distinct obligations)
- **Measurable**: quantified with acceptance criteria (not "fast" but "within 50 ms")
- **Traceable**: linked upward to a stakeholder need and downward to a verification case
- **Necessary**: removes something the system truly needs, not a "nice to have"
- **Feasible**: achievable within known technology and budget constraints
- **Unambiguous**: one reasonable interpretation only

See `knowledge/needs-and-reqs-guide.md` for the full SMART criteria and writing rules.

### 4.3 SysML v2 requirements modelling

```sysml
package SystemRequirements {
    import StakeholderNeeds::*;

    // Functional requirement with satisfy link
    requirement def MeasureTemperature {
        doc /* The system shall measure ambient temperature
               with an accuracy of +/- 0.5 degrees C. */
        attribute id = "REQ-001";
        attribute verificationMethod = "test";
        satisfy requirement StakeholderNeeds::MonitorTemperature;
    }

    // Performance requirement constraining a functional requirement
    requirement def TemperatureResponseTime {
        doc /* The system shall report temperature readings
               within 100 ms of measurement. */
        attribute id = "REQ-002";
        attribute verificationMethod = "test";
        satisfy requirement StakeholderNeeds::MonitorTemperature;
    }

    // Interface requirement
    requirement def SensorInterface {
        doc /* The system shall communicate with the temperature
               sensor via I2C at 400 kHz. */
        attribute id = "REQ-003";
        attribute verificationMethod = "inspection";
        satisfy requirement StakeholderNeeds::MonitorTemperature;
    }
}
```

---

## 5. The Nanocycle Requirements Workflow

The nanocycle (20 to 60 minutes) is the inner loop of requirements development.
It ensures continuous verification as requirements are created. The workflow for
each use case:

1. **Define the use case system context**: identify actors, the system under
   specification, and their relationships (SysML v2 part defs and connections)
2. **Define use case scenarios**: write the normal flow as a sequence of
   actor-system interactions
3. **Derive the functional flow**: create an action definition that models
   the system behaviour for this use case
4. **Define ports and interfaces**: specify the data and control flows
   between the system and its actors
5. **Derive state-based behaviour** (if event-driven): create a state definition
   that captures the system states and transitions for this use case
6. **Verify and validate**: run SySiDE validation, check traceability links,
   review with a colleague
7. **Add traceability links**: ensure every requirement has a `satisfy` link
   upward and a `verify` link downward
8. **Perform review**: if more requirements remain, return to step 2

This cycle is repeated every 20 to 60 minutes. The model is the primary work
product. Textual requirements are linked to (not separate from) the model elements.

---

## 6. Three Approaches to Use Case Analysis

Douglass describes three approaches for analysing use cases. Choose based on the
nature of the system behaviour.

### 6.1 Flow-based analysis

Best for: systems with deterministic, sequential data transformations.

Model the use case as an **action definition** with sequential actions connected by
data flows. Each action transforms inputs to outputs.

```sysml
action def ProcessSensorData {
    in sensorReading : Real;
    out processedValue : Real;

    action filter : FilterNoise {
        in raw = ProcessSensorData::sensorReading;
        out filtered;
    }
    action calibrate : ApplyCalibration {
        in filtered = filter.filtered;
        out calibrated;
    }
    action validate : CheckRange {
        in value = calibrate.calibrated;
        out validated = ProcessSensorData::processedValue;
    }

    first start then filter;
    then calibrate;
    then validate;
    then done;
}
```

### 6.2 Scenario-based analysis

Best for: systems with multiple interaction paths between actors and the system.

Model the use case as a set of **scenarios** (sequences of messages between actors
and system). Each scenario represents one path through the use case. A "minimal
spanning set" of scenarios covers all paths in the normative state machine at
least once.

### 6.3 State-based analysis

Best for: systems that respond to asynchronous events and must manage concurrent
states.

Model the use case as a **state definition** where inputs are events, transitions
capture the system response, and actions on states/transitions specify the
input-output transformations.

```sysml
state def BrakeManagement {
    entry state absOff;
    state absOn {
        state monitoring;
        state wheelLock;
        state wheelSlippage;

        transition monitoring_to_wheelLock
            first monitoring then wheelLock
            if isWheelLock;

        transition monitoring_to_wheelSlippage
            first monitoring then wheelSlippage
            if isWheelSlippage;
    }

    transition off_to_on
        first absOff then absOn
        if absEnabled;

    transition on_to_off
        first absOn then absOff
        if absDisabled;
}
```

VSE guidance: most VSE systems benefit from a combination. Use flow-based
analysis for the normal data path and state-based analysis for mode management
and error handling.

---

## 7. Executable Requirements Models

A central AMBSE principle is that requirements models should be *executable*,
meaning precise enough to verify through testing or formal analysis, not just
semantic review.

Requirements expressed as state machines or action sequences in SysML v2 can be:

- **Syntax-checked** by SySiDE in real time (nanocycle)
- **Trace-checked** by the `@traceability-guard` hook (nanocycle)
- **Walked through** with stakeholders using scenario traces (microcycle)
- **Formally verified** against constraints and invariants (microcycle)

The behavioural model represents the *requirements*, not the *implementation*.
It specifies what the system must do, not how it does it internally. The advantage
is that defects in requirements are caught early, when the cost of repair is low.

---

## 8. Dependability Requirements

Dependability assessment runs in parallel with all requirements activities.
Three aspects must be addressed:

| Aspect | Concern | Requirement Type |
|--------|---------|-----------------|
| Safety | Harm to people, property, or environment | Safety requirements, hazard mitigations |
| Reliability | Probability of failure-free operation | MTBF, failure rate requirements |
| Security | Protection against unauthorised access | Access control, encryption requirements |

For each dependability concern:

1. Identify hazards, failure modes, or threat vectors relevant to the current use case
2. Derive dependability requirements that mitigate each concern
3. Link dependability requirements to the affected functional requirements
4. Plan verification methods appropriate to the dependability level

VSE guidance: do not defer dependability analysis until a separate phase. Address
it during requirements derivation for each use case, when the functional context
is fresh. High-level design decisions (in architecture) must also be assessed for
their impact on dependability.

---

## 9. SE Engineering Data Trace Recommendations

The trace matrix defines which pairs of engineering data should have trace links.
Adapted from Douglass (2016) Table 1.1, filtered for VSE relevance.

| From \ To | StRS | SyRS | Arch | IVV Plan | Safety |
|-----------|------|------|------|----------|--------|
| **StRS** | - | R | o | R | R |
| **SyRS** | R | - | R | R | S |
| **Architecture** | o | R | - | R | S |
| **IVV Plan** | R | R | R | - | S |
| **Safety Analysis** | R | S | S | S | - |

Key: **R** = Recommended, **S** = Required for safety-critical systems, **o** = Optional

VSE guidance: at minimum, maintain StRS-to-SyRS and SyRS-to-IVV traces for
all projects. Add architecture and safety traces when the system has dependability
concerns. The `@traceability-guard` hook enforces the minimum trace set.

---

## 10. VSE Requirements Modelling Workflow

Step-by-step procedure combining AMBSE with ISO 29110 SR.2:

1. **Identify stakeholders** using the 16-type checklist (Section 2), map to named people
2. **Identify use cases** from stakeholder interviews and document review
3. **Write use case mission statements** (Section 3.1) and add to the project backlog
4. **Prioritise use cases** (Section 3.2) and allocate to iterations
5. **For each use case in the current iteration**:
   a. Define the system context (actors, connections) in SysML v2
   b. Write scenarios (normal, alternate, exception flows)
   c. Extract stakeholder needs (STK-nnn) from scenario steps
   d. Derive system requirements (REQ-nnn) with `satisfy` links
   e. Model the use case behaviour (flow, scenario, or state-based)
   f. Add verification method to each requirement
   g. Run the nanocycle workflow (Section 5): validate, trace-check, review
   h. Create verification cases (VER-nnn) with `verify` links
6. **Update the Traceability Matrix** and run `@traceability-guard`
7. **Conduct iteration review** with stakeholders (microcycle verification)
8. **Update the project backlog** based on what was learned

See also: `knowledge/needs-and-reqs-guide.md` for SMART criteria,
`knowledge/ambse-agile-process.md` for iteration planning context.
