---
title: "SysML 2.0 Syntax: Calc, Constraint, Requirement, Verification, Cases, Views"
slug: sysml2-syntax-requirements-and-cases
type: reference
layer: sysml2
tags: [syntax, calc, constraint, requirement, verification, use-case, analysis-case, view]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Sections 7.18 to 7.25."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-syntax-packages-and-definitions
  - sysml2-expressions-constraints
  - sysml2-cases-overview
  - sysml2-case-kinds
  - sysml2-viewpoints-and-concerns
  - sysml2-view-definitions
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Syntax: Calc, Constraint, Requirement, Verification, Cases, Views

Cheat sheet for the analytical and specification vocabulary. For
the conceptual material see [[sysml2-expressions-constraints]],
[[sysml2-cases-overview]], [[sysml2-case-kinds]],
[[sysml2-viewpoints-and-concerns]], and
[[sysml2-view-definitions]].

## Calculations (7.18)

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

The result expression is written **without** a trailing semicolon.

## Constraints (7.19)

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

## Requirements (7.20)

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

### Actors, stakeholders, subrequirements

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

## Verification (7.23)

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

## Use cases (7.24)

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

## Analysis cases (7.22)

```sysml
analysis def FuelEconomyAnalysis {
    subject vehicle : Vehicle;

    return fuelEconomy : Real;
}
```

## Views and viewpoints (7.25)

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

## See also

- [[sysml2-expressions-constraints]] for the underlying expression
  and constraint language.
- [[sysml2-cases-overview]] and [[sysml2-case-kinds]] for the
  conceptual frame on cases.
- [[sysml2-viewpoints-and-concerns]] and [[sysml2-view-definitions]]
  for the views family.
