---
name: sysml2-modelling
description: Author and validate SysML 2.0 textual models. Provides the machine-readable backbone for traceability (R3).
user-invocable: true
---

# SysML 2.0 Modelling

You are the modelling workbench for SysML 2.0 textual notation. You guide
authoring of .sysml files, validate syntax against the OMG specification, and
provide templates for common model elements. Reference:
`knowledge/sysml2-quick-ref.md`.

## When This Skill Triggers

- The user asks to create or edit a SysML 2.0 model
- The user asks about SysML 2.0 syntax
- The user wants to navigate or query existing models
- Any other skill needs to create model elements

## Project Template

When initialising a new project, create this structure:

```sysml
// models/package.sysml
package ProjectName {
    import StakeholderNeeds::*;
    import SystemRequirements::*;
    import Architecture::*;
    import Verification::*;
    import Validation::*;
}
```

```sysml
// models/stakeholder-needs.sysml
package StakeholderNeeds {
    // Stakeholder requirements go here
    // Each need uses: requirement def Name { ... }
    // Attributes: id, priority, source
}
```

```sysml
// models/system-requirements.sysml
package SystemRequirements {
    import StakeholderNeeds::*;

    // System requirements go here
    // Each requirement uses: requirement def Name { ... satisfy ... }
    // Attributes: id, verificationMethod, priority
}
```

```sysml
// models/architecture.sysml
package Architecture {
    import SystemRequirements::*;

    // Part definitions, ports, connections go here
}
```

```sysml
// models/verification.sysml
package Verification {
    import SystemRequirements::*;

    // Verification cases go here
    // Each case uses: verification def Name { ... verify ... }
}
```

```sysml
// models/validation.sysml
package Validation {
    import StakeholderNeeds::*;

    // Validation cases go here
}
```

## Syntax Reference (Key Patterns)

### Requirements

```sysml
requirement def RequirementName {
    doc /* The system shall [do something measurable]. */
    attribute id : String = "REQ-001";
    attribute priority : String = "essential";
    attribute verificationMethod : String = "test";
    satisfy requirement StakeholderNeeds::NeedName;
}
```

### Part Definitions (Architecture)

```sysml
part def SystemName {
    part subsystemA : SubsystemAType;
    part subsystemB : SubsystemBType;

    port externalInput : InputPort;
    port externalOutput : OutputPort;

    connect subsystemA.outPort to subsystemB.inPort;
}
```

### Port Definitions

```sysml
port def DataPort {
    attribute dataRate : Real;
    attribute protocol : String;
}

// Conjugated port (receiver side)
port def ~DataPort;
```

### Verification Cases

```sysml
verification def VerificationName {
    doc /* Description of how to verify the requirement. */
    attribute id : String = "VER-001";
    attribute method : String = "test";
    attribute passCriteria : String = "...";
    verify requirement SystemRequirements::RequirementName;
}
```

### Actions (Behaviour)

```sysml
action def MeasureTemperature {
    in item rawReading : Real;
    out item calibratedTemp : Real;

    action read : ReadSensor { in item = rawReading; }
    action calibrate : ApplyCalibration { out item = calibratedTemp; }

    succession read then calibrate;
}
```

### States

```sysml
state def SensorStates {
    entry state idle;
    state measuring;
    state alerting;

    transition idle_to_measuring
        first idle then measuring
        if startMeasurement;

    transition measuring_to_alerting
        first measuring then alerting
        if thresholdExceeded;
}
```

### Traceability Links

```sysml
// Satisfaction (requirement satisfies a need)
satisfy requirement StakeholderNeeds::NeedName;

// Verification (case verifies a requirement)
verify requirement SystemRequirements::ReqName;

// Allocation (function allocated to physical element)
allocate FunctionalArch::FunctionName to PhysicalArch::ElementName;
```

## Model Validation

When reviewing a .sysml file, check:

1. **Package structure**: every file starts with a `package` declaration
2. **Imports**: all cross-package references use proper imports
3. **Naming conventions**: PascalCase for definitions, camelCase for usages
4. **ID attributes**: all requirements and verification cases have unique IDs
5. **Traceability links**: every requirement has satisfy, every verification
   has verify
6. **Documentation**: every definition has a `doc` comment

## Model Navigation

When the user asks to find something in the model:

- **Find all requirements**: `Grep for "requirement def" in models/**/*.sysml`
- **Find all parts**: `Grep for "part def" in models/**/*.sysml`
- **Find all verification cases**: `Grep for "verification def" in models/**/*.sysml`
- **Find trace links**: `Grep for "satisfy requirement\|verify requirement" in models/**/*.sysml`
- **Find a specific element**: `Grep for the element name in models/**/*.sysml`

## Tooling Integration

### Sensmetry SySiDE

The recommended toolchain for editing .sysml files in VS Code:

- **Syside Editor** (free): install from VS Code marketplace. Provides syntax
  highlighting, validation, auto-completion, and go-to-definition for .sysml
  and .kerml files.
- **Syside Modeler** (paid): adds diagram visualisation. You MUST disable the
  Editor extension when Modeler is active to avoid conflicts.
- **Sysand**: package manager for reusable SysML v2 libraries. Install via npm.

### Configuration

Create `syside.toml` in the project root:

```toml
[project]
name = "ProjectName"

[build]
source = ["models"]
```

## Red Flags

WARN the engineer if:
- A .sysml file has no package declaration
- Requirements are defined without ID attributes
- Cross-package references are used without imports
- Verification cases exist without verify links
- The model structure does not follow the project template
