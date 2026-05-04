---
title: "AMBSE Architecture-Level V&V and ISO 29110 Mapping"
slug: ambse-architecture-vv-and-iso29110
type: reference
layer: ambse
tags: [verification, validation, definition-of-done, iso29110, mapping]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapter 8."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
related:
  - ambse-architecture-analysis
  - ambse-trade-studies
  - ambse-architectural-design
  - ambse-interfaces-and-handoff
  - vv-definitions
  - vv-methods
  - sysml2-case-kinds
  - iso29110-sr-process
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [architecture-design]
---

# AMBSE Architecture-Level V&V and ISO 29110 Mapping

V&V in AMBSE operates at all three verification timeframes
(see [[ambse-vee-three-timeframes]] and [[vv-definitions]])
and uses the model as the primary verification artefact. For
the architecture activities upstream see
[[ambse-architecture-analysis]],
[[ambse-architectural-design]], and
[[ambse-interfaces-and-handoff]].

## Continuous verification at architecture level

| Timeframe | Activity | Plugin mapping |
|---|---|---|
| Nanocycle | SySiDE syntax validation, constraint checking, trace completeness | Pre-commit hook, SySiDE on save |
| Microcycle | Peer model review, use case walkthrough, iteration acceptance | Phase gate check, iteration review |
| Macrocycle | System-level V&V, formal acceptance | SR.5 activities, PM.4 |

For the V&V layer's perspective on these timeframes (with full
methods, VCRM, SVCM coverage), see [[vv-methods]].

## Use case driven validation

Validation ensures the system meets stakeholder needs (not
just requirements). The AMBSE approach to validation:

1. For each stakeholder use case, walk through the
   architecture model.
2. For each scenario in the use case, trace the data and
   control flow through the subsystem decomposition.
3. Verify that every step in the scenario is supported by a
   subsystem service.
4. Identify gaps where the architecture cannot support a
   scenario step.
5. Report gaps as either missing requirements or architectural
   defects.

## SysML 2.0 verification modelling

For the verification-case syntax see [[sysml2-case-kinds]].

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

## Definition of done for SE velocity

A use case is "done" (counted in SE velocity) when all of the
following are satisfied:

- A full description identifying purpose, preconditions,
  postconditions, and invariants.
- A normative behavioural model (state machine or action
  sequence) in which all requirements are traced to and from
  the use case.
- A minimal spanning set of scenarios covering all paths in
  the normative model.
- Trace links to all related functional and quality of service
  requirements.
- Architecture allocation showing which subsystems implement
  the use case.
- System interfaces with a physical data schema supporting the
  use case interactions.
- Logical verification cases to verify the use case
  requirements.
- Logical validation cases to ensure the use case satisfies
  stakeholder needs.

## Mapping AMBSE architecture to ISO 29110

For the underlying ISO 29110 SR.3 catalogue see
[[iso29110-sr-process]].

| AMBSE activity | ISO 29110 activity | Notes |
|---|---|---|
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

## See also

- [[ambse-architecture-analysis]],
  [[ambse-trade-studies]],
  [[ambse-architectural-design]],
  [[ambse-interfaces-and-handoff]] for the architecture
  activities upstream.
- [[vv-definitions]] and [[vv-methods]] for the V&V layer's
  full coverage of methods, VCRM, SVCM.
- [[sysml2-case-kinds]] for the SysML 2.0 verification-case
  syntax.
- [[iso29110-sr-process]] for the SR.3 activity catalogue.
