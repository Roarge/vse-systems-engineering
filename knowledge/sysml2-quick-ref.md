# SysML v2 Textual Notation Quick Reference

Source: OMG Systems Modeling Language v2.0, March 2023 (formal/2025-01-01).
Covers .sysml textual syntax only. Every example is taken from or verified against the
specification. Items marked *syntax to be verified* require further checking.

---

## 1. Packages and Imports (7.5)

```sysml
package Vehicles {
    part def Vehicle;
}

// Namespace import (all direct members)
import Vehicles::*;

// Recursive namespace import (all members at all depths)
import Vehicles::**;

// Private import (not visible to importers of this package)
private import Vehicles::*;

// Alias
alias CarDef for Vehicles::Vehicle;

// Filtered import (metadata-based)
package FilteredView {
    import Vehicles::**;
    filter @Approved and status == "released";
}
```

## 2. Definitions and Usages (7.6)

Every element follows the **definition/usage** pattern: `def` declares a reusable type,
plain keyword instantiates it.

```sysml
// Definition
part def Vehicle;

// Usage (instantiation)
part myVehicle : Vehicle;

// Long-form usage
part myVehicle defined by Vehicle;

// Specialisation (subclassification)
part def Truck :> Vehicle;
part def Truck specializes Vehicle;   // equivalent long form

// Abstract definition (cannot be instantiated directly)
abstract part def Vehicle;

// Variation and variants
variation part def TransmissionChoices :> Transmission {
    variant part manual : ManualTransmission;
    variant part automatic : AutomaticTransmission;
}
```

## 3. Multiplicity and Feature Values (7.6, 7.13)

```sysml
// Multiplicity
part wheels[4] : Wheel;
part passengers[0..4] : Person;
part sensors[1..*] : Sensor;

// Bound value (fixed, never changes)
attribute monthsInYear : Natural = 12;

// Initial value (can change after initialisation)
attribute count[1] : Natural := 0;

// Default value (overridable by specialisation)
attribute mass : Real default 1500.0;

// Referential (non-composite) usage
ref part driver[0..1] : Person;
```

## 4. Attributes (7.7)

```sysml
attribute def SensorRecord {
    ref part sensor : Sensor;
    attribute reading : Real;
    attribute timestamp : TimeInstantValue;
}

attribute currentReading : SensorRecord;
```

## 5. Enumerations (7.8)

```sysml
enum def ConditionColor {
    red;
    green;
    yellow;
}

enum def RiskLevel :> ConditionColor {
    enum low {
        :>> color = ConditionColor::green;
    }
    enum medium {
        :>> color = ConditionColor::yellow;
    }
    enum high {
        :>> color = ConditionColor::red;
    }
}
```

## 6. Items (7.10)

Items model things that are not necessarily parts of a structure (e.g., flowing
material, signals, data).

```sysml
item def Fuel;
item def ControlSignal;
```

## 7. Parts (7.11)

```sysml
part def Vehicle {
    ref part driver[0..1] : Person;
    part engine : Engine;
    part wheels[4] : Wheel;
    part transmission : Transmission;
}

part vehicle1 : Vehicle;
```

## 8. Ports (7.12)

```sysml
port def FuelingPort {
    attribute flowRate : Real;
    out item fuelOut : Fuel;
    in item fuelReturn : Fuel;
}

part def Vehicle {
    port fuelPort : FuelingPort;
}

// Conjugated port (directions reversed)
port def FuelSupplyPort :> FuelingPort;
port conjugatedPort : ~FuelSupplyPort;
```

Directed features on ports: `in`, `out`, `inout`.

## 9. Connections (7.13)

```sysml
// Connection definition with typed ends
connection def DeviceConnection {
    end part hub : Hub[1];
    end part devices : Device[0..*];
    attribute bandwidth : Real;
}

// Connection usage
connection c : DeviceConnection
    connect hub ::> mainSwitch to device ::> sensorFeed;

// Shorthand (anonymous, untyped)
connect leftWheel to leftHalfAxle;
```

### Binding Connectors

```sysml
// Bind (asserts two features always have the same value)
bind fuelTank.fuelFlowOut = engine.fuelFlowIn;
```

### Flows

```sysml
// Item flow
flow fuelFlow of Fuel from fuelTank.fuelOut to engine.fuelIn;

// Succession flow (ordered in time)
succession flow focus.image to shoot.image;
```

### Messages

```sysml
// Message (item transferred between ports/parts)
message of ControlSignal from controller.cmdPort to engine.ctrlPort;
```

## 10. Interfaces (7.14)

```sysml
interface def FuelingInterface {
    end port supplier : FuelSupplyPort;
    end port receiver : FuelingPort;
}

interface fuelLine : FuelingInterface
    connect fuelTank.fuelingPort to engine.fuelingPort;
```

## 11. Allocations (7.15)

```sysml
allocation def LogicalToPhysical {
    end part logical : LogicalComponent;
    end part physical : PhysicalDevice;
}

allocate logicUnit to processorBoard;
```

## 12. Actions (7.16)

```sysml
action def TakePicture {
    in scene : Scene;
    out picture : Picture;

    action focus : Focus {
        in scene = TakePicture::scene;
        out image;
    }
    action shoot : Shoot {
        in image = focus.image;
        out picture;
    }

    // Succession (ordering)
    first start then focus;
    then shoot;
    then done;

    // Flow
    flow focus.image to shoot.image;
}
```

### Control Nodes

```sysml
action def ProcessFlow {
    action prepare;
    action taskA;
    action taskB;
    action finalise;

    first start then prepare;

    // Fork (parallel split)
    fork afterPrepare;
    first prepare then afterPrepare;
    then taskA;
    then taskB;

    // Join (synchronise)
    join beforeFinalise;
    first taskA then beforeFinalise;
    first taskB then beforeFinalise;
    then finalise;

    // Decide (conditional branch)
    decide decision1;
    if isReady then taskA;
    if not isReady then taskB;

    // Merge (rejoin branches)
    merge merge1;
}
```

### Send, Accept, Perform

```sysml
// Perform (reference an externally defined action)
perform action powerVehicle references VehicleActions::providePower;

// Send (transmit a value)
send reading via monitor to destination;

// Accept (receive a value)
accept sensorReading : SensorReading via controller;

// Accept triggers
accept when level > threshold;     // change trigger
accept at scheduledTime;           // time trigger
accept after 30 [s];               // relative time trigger
```

### Assignment

```sysml
assign vehicle.position :=
    vehicle.position + vehicle.velocity * deltaT;
```

### Conditional and Loop Actions

```sysml
// If/else
if speed < lowerLimit
    action increase : IncreaseSpeed;
else
    action maintain : MaintainSpeed;

// While loop
while not ready {
    assign ready := poll(device);
}

// Do-until loop
loop {
    action charge : ChargeBattery;
} until charge >= 100;

// For loop
for power : PowerValue in powerProfile {
    action regulate : RegulatePower;
}
```

## 13. States (7.17)

```sysml
state def VehicleStates {
    entry action startup : StartUp;
    do action monitor : Monitor;
    exit action shutdown : ShutDown;

    state off;
    state starting;
    state on;

    // Transition (long form)
    transition off_to_starting
        first off
        accept TurnOnSignal
        if batteryOk
        do action powerUp : PowerUp
        then starting;

    // Transition (shorthand within state body)
    state starting {
        then on;
    }
}
```

### Parallel States

```sysml
state def VehicleStates parallel {
    state operationalStates : OperationalStates;
    state healthStates : HealthStates;
}
```

### Exhibit States

```sysml
part def Vehicle {
    exhibit state vehicleStates : VehicleStates;
}
```

## 14. Calculations (7.18)

```sysml
calc def Velocity {
    in v_i : VelocityValue;
    in a : AccelerationValue;
    in dt : TimeValue;
    return v_f : VelocityValue;

    v_i + a * dt
}

// Alternative: result bound in return declaration
calc def Average {
    in scores[1..*] : Rational;
    return : Rational = sum(scores) / size(scores);
}
```

Note: the result expression is written *without* a trailing semicolon.

## 15. Constraints (7.19)

```sysml
constraint def IsFull {
    in tank : FuelTank;
    tank.fuelLevel == tank.maxFuelLevel
}

part def Vehicle {
    part fuelTank : FuelTank;
    constraint isFull : IsFull {
        in tank = fuelTank;
    }
}

// Assert constraint (must hold at all times)
part testObject {
    attribute computedMass : MassValue;
    assert constraint { computedMass >= 0 [kg] }
}

// Negated assert (must be false at all times)
assert not constraint { computedMass < 0 [kg] }
```

## 16. Requirements (7.20)

```sysml
requirement def <'1.1'> MaximumMass {
    doc /* The actual mass shall be no greater than the required mass. */

    attribute massActual : MassValue;
    attribute massRequired : MassValue;

    assume constraint { massRequired > 0 [kg] }
    require constraint { massActual <= massRequired }
}

// Requirement usage with subject binding
requirement <'v1.1'> vehicleMaxMass : MaximumMass {
    subject vehicle : Vehicle;
    attribute :>> massActual = vehicle.totalMass;
    attribute :>> massRequired = 2000 [kg];
}
```

### Actors, Stakeholders, Subrequirements

```sysml
requirement def BrakingRequirement {
    subject vehicle : Vehicle;
    actor environment : 'Driving Environment';
    stakeholder driver : Person;

    assume constraint {
        doc /* The vehicle speed is less than the speed limit. */
    }
    require constraint {
        doc /* The vehicle shall brake to zero within maxBrakingDistance. */
    }
}

// Subrequirements (nested, automatically required constraints)
requirement def VehicleRequirementsGroup {
    subject vehicle : Vehicle;
    requirement driving : DrivingRequirement;
    requirement braking : BrakingRequirement;
}
```

### Satisfaction

```sysml
part vehicle1 : Vehicle {
    satisfy requirement vehicleMaxMass;
}

// Or equivalently
satisfy vehicleMaxMass by vehicle1;
```

## 17. Verification (7.23)

```sysml
verification def VehicleMassTest {
    subject testVehicle : Vehicle;

    objective {
        verify vehicleMaxMass;
    }

    // Verification method metadata
    metadata VerificationMethod {
        kind = VerificationKind::test;
    }
}
```

## 18. Use Cases (7.24)

```sysml
use case def 'Provide Transportation' {
    subject vehicle : Vehicle;
    actor driver : Person;
    actor passengers : Person[0..4];

    objective {
        doc /* Transport passengers safely from origin to destination. */
    }

    include 'enter vehicle';
    include 'drive to destination';
    include 'exit vehicle';
}
```

## 19. Analysis Cases (7.22)

```sysml
analysis def FuelEconomyAnalysis {
    subject vehicle : Vehicle;

    return fuelEconomy : Real;
}
```

## 20. Views and Viewpoints (7.25)

```sysml
viewpoint def 'System Structure Perspective' {
    frame concern 'system breakdown';
    require constraint {
        doc /* All physical parts shall be shown to depth 2. */
    }
}

concern 'system breakdown' {
    stakeholder se : 'Systems Engineer';
    doc /* What is the physical decomposition of the system? */
}

view def StructureView {
    satisfy viewpoint 'System Structure Perspective';
    render asTreeDiagram;
}

view systemOverview : StructureView {
    expose vehicle::**;
    filter @ApprovedBaseline;
}
```

## 21. Comments and Documentation (7.2, 7.3)

```sysml
// Line comment

/* Block comment */

// Documentation (attached to owning element)
part def Vehicle {
    doc /* A self-propelled road vehicle. */
}

// Short name (requirement ID)
requirement def <'REQ-001'> SafetyRequirement;
```

## 22. Metadata and Annotations (7.4)

```sysml
// Metadata definition
metadata def Approval {
    attribute approved : Boolean;
    attribute approver : String;
}

// Annotating an element
@Approval {
    approved = true;
    approver = "Chief Engineer";
}
part def Vehicle;
```

## 23. Common Relationship Keywords

| Keyword      | Meaning                                           |
|--------------|---------------------------------------------------|
| `:>`         | Specialises (subclassification)                   |
| `specializes`| Long form of `:>`                                 |
| `:>>`        | Redefines (replaces inherited feature)            |
| `redefines`  | Long form of `:>>`                                |
| `subsets`    | Subsets (usage is a subset of another collection) |
| `references` | References an externally defined element          |
| `defined by` | Long form of `:` (typing)                         |

---

*Generated from OMG SysML v2.0 specification for use with the VSE Systems Engineering plugin.*
