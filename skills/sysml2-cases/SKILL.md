---
name: sysml2-cases
description: Author SysML 2.0 use cases, analysis cases, and verification cases. Use when defining test cases, trade studies, what-if analyses, or use-case flows.
user-invocable: true
---

# SysML 2.0 Cases

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You guide the engineer through the SysML 2.0 case family. Cases
generalise SysML v1 use cases and cover three kinds: use cases,
analysis cases, and verification cases. All three are specialisations
of `Calculation` and therefore always return a result. For project
layout and tooling, route back to `@sysml2-modelling`. For the step
bodies inside a case, route to `@sysml2-behaviour`.

## When This Skill Triggers

- The user asks to add a use case, analysis case, or verification case
- The user wants a trade study or what-if analysis
- The user wants to verify a requirement with a dedicated case
- The user asks how actors, subjects, or objectives fit together

## Core Vocabulary

| Element | Keyword | Purpose |
| --- | --- | --- |
| Use case | `use case def`, `use case` | Actor-driven interaction with a subject |
| Analysis case | `analysis def`, `analysis` | Parametric computation over the subject |
| Verification case | `verification def`, `verification` | Verifies one or more requirements |
| Subject | `subject` | The system or component under consideration |
| Actor | `actor` | An external role interacting with the subject |
| Objective | `objective` | A goal statement, declared as a requirement |
| Verify link | `verify` | Binds a verification case to a requirement |

## Authoring Patterns

### Use Case Definition with Actors

```sysml
use case def 'Provide Transportation' {
    subject vehicle : Vehicle;
    actor driver : Person;
    actor passengers : Person[0..4];

    objective {
        doc /* Transport passengers safely from origin to destination. */
    }
}
```

The subject is always the first `in` parameter. Actors are roles, not
entities. The same physical person may appear as more than one actor.

### Analysis Case with Parametric Result

```sysml
analysis def PowerBudgetAnalysis {
    subject drone : Drone;
    in attribute payloadMass : Real;
    return attribute enduranceMinutes : Real;

    calc endurance = drone.batteryCapacity * 60
        / (drone.baseLoad + payloadMass * 0.8);
    enduranceMinutes = endurance;
}
```

An analysis case invokes behaviour of its subject and binds results
through calculations or constraints. The `return` feature is the
published result that downstream cases can chain onto.

### Verification Case with Verify Clause

```sysml
verification def VehicleMassTest {
    subject testVehicle : Vehicle;

    objective {
        verify vehicleMaxMass;
    }

    action measure : MeasureMass { in item = testVehicle; }
    action compare : CompareToLimit {
        in actual = measure.result;
        in limit = vehicleMaxMass.maxMass;
    }
    succession measure then compare;
    return attribute verdict : VerdictKind = compare.verdict;
}
```

`verify` inside the objective names the requirement being verified. The
verification case body orchestrates steps that produce a verdict. See
`sysml2-cases-ref.md` Section 5 for verdict semantics. Until the
`VerdictKind` rules are published in a later book release, consult the
OMG Systems Modeling Language v2.0 specification for the enumeration.

### Case with an External Part Context

```sysml
part def TestRig {
    part dut : Vehicle;
    part scales : MassSensor;
}

verification def MassTestOnRig {
    subject dut : TestRig::dut;
    actor rig : TestRig;
    objective {
        verify vehicleMaxMass;
    }
}
```

When a case reuses a shared environment, declare it as a part
definition and reference it from the case subject or actors.

## Validation Checklist

1. **Subject is the first `in` parameter.** Placing actors before the
   subject is a semantic error.
2. **Actors are bound at the usage site.** Unbound actors make the case
   impossible to interpret or execute.
3. **Verify clauses match subjects.** A verification case may verify a
   requirement only when the case subject is compatible with the
   requirement subject.
4. **Objectives use `objective`, not `satisfy`.** An objective is a goal,
   not an achieved requirement.
5. **Cases return a result.** Cases are calculations. A case without a
   result is either incomplete or authored against the wrong base.

## Red Flags

WARN the engineer if:

- A case is declared with no subject
- A verification case has no `verify` clause and no equivalent trace
- A use case lists an actor whose type is the same as the subject (the
  actor should be external)
- An analysis case has no `return` feature
- Verdict handling is missing in a verification body that expects one

## Reference: SysML 2.0 Cases

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/sysml2-cases-ref.md`
