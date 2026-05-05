---
title: "AMBSE System Requirements Derivation"
slug: ambse-system-requirements-derivation
type: process
layer: ambse
tags: [requirements, derivation, satisfy, verify, smart, sysml2]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapter 4."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
related:
  - ambse-requirements-as-models
  - ambse-use-case-driven-elicitation
  - ambse-dependability-and-traceability
  - sysml2-syntax-requirements-and-cases
  - sysml2-requirements-semantics
  - needs-vs-requirements
  - requirements-elicitation-and-writing
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [needs-and-requirements]
---

# AMBSE System Requirements Derivation

System requirements are derived from stakeholder needs by
identifying what the system must do or be to satisfy each
need. The derivation workflow proceeds **per use case**. For
the use cases that drive this derivation, see
[[ambse-use-case-driven-elicitation]]. For the underlying
needs-vs-requirements distinction see [[needs-vs-requirements]].

## Derivation workflow

For each stakeholder need within the current iteration:

1. **Identify system functions**: what must the system do to
   satisfy this need?
2. **Derive functional requirements**: for each function, write
   a measurable requirement (REQ-nnn) with a `satisfy` link to
   the stakeholder need.
3. **Derive performance requirements**: for each functional
   requirement, identify quality of service constraints
   (timing, accuracy, capacity, throughput).
4. **Derive interface requirements**: for each external
   interaction, specify the interface protocol, data format,
   and physical characteristics.
5. **Derive constraint requirements**: identify regulatory,
   environmental, or design constraints that apply.
6. **Add verification method**: for each requirement, record
   the planned verification method (analysis, inspection,
   demonstration, test).

## Requirement quality criteria

Every system requirement should be:

- **Singular**: one requirement per statement (no "and" joining
  distinct obligations).
- **Measurable**: quantified with acceptance criteria (not
  "fast" but "within 50 ms").
- **Traceable**: linked upward to a stakeholder need and
  downward to a verification case.
- **Necessary**: removes something the system truly needs, not
  a "nice to have".
- **Feasible**: achievable within known technology and budget
  constraints.
- **Unambiguous**: one reasonable interpretation only.

For the full SMART criteria and writing rules, see
[[requirements-elicitation-and-writing]] (including the C1-C14
characteristic checklist and the common defects to avoid). For
the SysML 2.0 syntax that captures the satisfy and verify links,
see [[sysml2-syntax-requirements-and-cases]] and
[[sysml2-requirements-semantics]].

## SysML 2.0 requirements modelling

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

Each requirement carries:

- A `doc` comment with the natural-language statement (the
  text-explains-why side of the dual representation).
- An `id` attribute for trace IDs.
- A `verificationMethod` attribute recording the planned V&V
  approach (test, analysis, inspection, demonstration).
- A `satisfy` relationship pointing at the stakeholder need it
  derives from.

The downstream `verify` link is added when the corresponding
verification case is written; see
[[ambse-dependability-and-traceability]].

## See also

- [[ambse-requirements-as-models]] for the dual-representation
  principle.
- [[ambse-use-case-driven-elicitation]] for the upstream
  workflow.
- [[methodology-overview]] for the inner-loop
  steps that incorporate this derivation.
- [[ambse-dependability-and-traceability]] for the trace matrix
  and downstream verify link patterns.
- [[sysml2-syntax-requirements-and-cases]] and
  [[sysml2-requirements-semantics]] for SysML 2.0 requirement
  syntax and semantics.
