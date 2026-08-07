---
name: sysml2-cases
description: Author SysML 2.0 use cases, analysis cases, and verification cases. Use when defining test cases, trade studies, what-if analyses, or use-case flows.
user-invocable: true
---

# SysML 2.0 Cases

A `methodology/` folder at the project root, or under `engineering/`, marks a VSE project. If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first. In a SysML-only repository with no `methodology/` folder, skip the lens and proceed directly with this skill.

You guide the engineer through the SysML 2.0 case family. Cases
generalise SysML v1 use cases and cover three kinds: use cases,
analysis cases, and verification cases. All three specialise
`Calculation`, so a case may publish a result via a `return`
feature. Analysis cases almost always declare one (the computed
value). Verification cases declare one when the verdict is passed
to a downstream case or view. Use cases usually leave the result
implicit in the flow. For project layout and tooling, route back
to `@sysml2-modelling`. For the step bodies inside a case, route
to `@sysml2-behaviour`.

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
the `sysml2-case-kinds` atomic page for verdict semantics. Until the
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
5. **Cases may return a result.** Cases are calculations, so a
   `return` feature is available when the case needs to publish a
   value. Analysis cases should almost always declare one. Use
   cases typically do not.

## Red Flags

WARN the engineer if:

- A case is declared with no subject
- A verification case has no `verify` clause and no equivalent trace
- A use case lists an actor whose type is the same as the subject (the
  actor should be external)
- An analysis case has no `return` feature
- Verdict handling is missing in a verification body that expects one

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| SysML 2.0 Case Kinds: Use, Analysis, Verification | pages/sysml2/sysml2-case-kinds.md | Syntax for the three standard case kinds, that is use case, analysis case, and verification case |
| SysML 2.0 Case Patterns and Gotchas | pages/sysml2/sysml2-case-patterns.md | Practical case patterns and the recurring mistakes that show up in review |
| SysML 2.0 Cases Overview | pages/sysml2/sysml2-cases-overview.md | The case construct family: use, analysis, verification, and validation cases share one structure |
<!-- wiki-routing:end -->
