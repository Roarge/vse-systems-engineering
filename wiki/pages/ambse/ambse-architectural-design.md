---
title: "AMBSE Architectural Design and Use Case Allocation"
slug: ambse-architectural-design
type: process
layer: ambse
tags: [architectural-design, subsystems, allocation, bottom-up, top-down]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapters 6-7."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Chapters 3-4."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-architecture-analysis
  - ambse-trade-studies
  - ambse-interfaces-and-handoff
  - ambse-architecture-vv-and-iso29110
  - sysml2-allocations-overview
  - sysml2-canonical-model-layout
  - sysml2-base-architecture-and-federation
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [architecture-design]
---

# AMBSE Architectural Design and Use Case Allocation

Once an architecture is selected (via
[[ambse-trade-studies]]), the design activity implements it by
decomposing the system into subsystems, allocating
requirements, and defining interfaces. For the upstream
analysis activity see [[ambse-architecture-analysis]]. For
interface specification and the handoff that follows, see
[[ambse-interfaces-and-handoff]].

## Workflow steps

1. **Identify subsystems**: a subsystem is a large-scale piece
   of the system that provides a coherent set of functionality
   and is typically implemented with a combination of
   engineering disciplines (mechanical, electronic, software).
2. **Allocate system requirements to subsystems**: some
   requirements map directly, others must be decomposed into
   derived subsystem requirements.
3. **Allocate use cases to subsystems** (see Two approaches
   below).
4. **Create/update logical data schema**: define the data
   types, ranges, accuracy, and units for data flows between
   subsystems.
5. **Create/update subsystem requirements**: derived
   requirements that specify what each subsystem must do.
6. **Develop control laws** (if applicable): for systems with
   continuous control behaviour crossing subsystem boundaries.
7. **Analyse dependability**: assess safety, reliability, and
   security implications of the architectural design
   decisions.
8. **Perform review**.

## Two approaches to use case allocation

When allocating system-level use cases to subsystems, there
are two approaches:

### Bottom-up (action allocation)

- Examine each message in the system-level scenarios.
- Identify which subsystem(s) play a role in each message.
- Derive "white box scenarios" showing subsystem-to-subsystem
  interactions.
- Group subsystem services into subsystem-level use cases.

### Top-down (use case decomposition)

- Think at a high level about what each subsystem must
  provide.
- Decompose system-level use cases into collaborating
  subsystem-level use cases.
- Then elaborate the white-box scenarios.

Both approaches produce the same result: subsystem-level use
cases and white-box scenarios. The bottom-up approach is more
systematic. The top-down approach is faster when the
decomposition is obvious.

VSE guidance: use whichever feels more natural. For a first
project, **bottom-up is safer** because it forces you to trace
every system behaviour to a subsystem.

## SysML 2.0 architecture modelling

Allocations between functional and physical elements use the
SysML 2.0 allocation mechanism (see
[[sysml2-allocations-overview]]). The package layout follows
[[sysml2-canonical-model-layout]]. When inheriting from a
base architecture, see
[[sysml2-base-architecture-and-federation]].

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

## See also

- [[ambse-architecture-analysis]] for the upstream view
  catalogue.
- [[ambse-trade-studies]] for the methodology that selects the
  architecture this design implements.
- [[ambse-interfaces-and-handoff]] for interface specification
  and the handoff that follows.
- [[ambse-architecture-vv-and-iso29110]] for V&V and the ISO
  29110 mapping.
- [[sysml2-allocations-overview]] for the SysML 2.0 allocation
  mechanism.
- [[sysml2-canonical-model-layout]] for the AMBSE package
  layout.
- [[sysml2-base-architecture-and-federation]] for inheriting
  base architectures.
