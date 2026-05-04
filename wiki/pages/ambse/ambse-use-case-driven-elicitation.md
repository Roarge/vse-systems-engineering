---
title: "AMBSE Use Case Driven Elicitation"
slug: ambse-use-case-driven-elicitation
type: process
layer: ambse
tags: [use-case, elicitation, mission-statement, prioritisation, scenarios, executable-models]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapter 4."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Chapter 2."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-requirements-as-models
  - ambse-system-requirements-derivation
  - ambse-nanocycle-and-use-case-analysis
  - sysml2-cases-overview
  - sysml2-case-kinds
  - sysml2-case-patterns
  - requirements-elicitation-and-writing
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [needs-and-requirements]
---

# AMBSE Use Case Driven Elicitation

Use cases are the **primary structuring mechanism** for
stakeholder requirements in AMBSE. A use case captures a
coherent set of actor-system interactions that deliver value to
a stakeholder. For the underlying conceptual frame see
[[ambse-requirements-as-models]]. For the SysML 2.0 case-family
syntax see [[sysml2-cases-overview]] and
[[sysml2-case-kinds]].

## Use case mission statement

Before detailing requirements, create a mission statement for
each use case:

- **Name**: short descriptive name.
- **Purpose**: what value does this deliver to the
  stakeholder(s)?
- **Description**: what input-output data and control
  transformations are needed?
- **Preconditions**: what must be true before these behaviours
  run?
- **Postconditions**: what must be true after these behaviours
  have run?
- **Invariants**: what assumptions are we making throughout?

## Use case prioritisation

Use cases are prioritised for iteration ordering. Factors to
consider:

| Factor | Question |
|---|---|
| Stakeholder benefit | Is this useful, important, or critical? |
| Architectural impact | Does it extend, reorganise, or leave the architecture unchanged? |
| Risk mitigation | Does this use case address a known project risk? |
| Information availability | Is the subject matter expert available to specify it? |

General rule: critical, high-impact, high-risk use cases with
available information should be specified first.

## From use cases to stakeholder needs

Each use case generates stakeholder needs through scenario
analysis:

1. **Define the system context**: identify actors and their
   relationships to the system.
2. **Define use case scenarios**: normal flow, alternate flows,
   exception flows.
3. **Extract needs from scenario steps**: each step where the
   system must respond generates a candidate stakeholder need
   (STK-nnn).
4. **Review with stakeholders**: walk through scenarios to
   validate needs.

This is the AMBSE-specific extension of the eight elicitation
techniques in [[requirements-elicitation-and-writing]]:
brainstorming, interviews, document analysis, interface
analysis, observation, prototyping, workshops, surveys all
generate input that is then organised by use case.

## SysML 2.0 use case modelling

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

For the full case-family syntax, see [[sysml2-case-kinds]]. For
authoring patterns, see [[sysml2-case-patterns]].

## Executable requirements models

A central AMBSE principle is that requirements models should
be **executable**, meaning precise enough to verify through
testing or formal analysis, not just semantic review.

Requirements expressed as state machines or action sequences in
SysML 2.0 can be:

- **Syntax-checked** by SySiDE in real time (nanocycle).
- **Trace-checked** by the `@traceability-guard` hook
  (nanocycle).
- **Walked through** with stakeholders using scenario traces
  (microcycle).
- **Formally verified** against constraints and invariants
  (microcycle).

The behavioural model represents the **requirements**, not the
**implementation**. It specifies what the system must do, not
how it does it internally. The advantage is that defects in
requirements are caught early, when the cost of repair is low.

## See also

- [[ambse-requirements-as-models]] for the conceptual frame.
- [[ambse-system-requirements-derivation]] for the next step
  (deriving system requirements from use cases).
- [[ambse-nanocycle-and-use-case-analysis]] for the
  inner-loop workflow and the three analysis approaches (flow,
  scenario, state).
- [[sysml2-cases-overview]], [[sysml2-case-kinds]],
  [[sysml2-case-patterns]] for the SysML 2.0 case syntax.
- [[requirements-elicitation-and-writing]] for the
  general-purpose elicitation techniques and writing rules.
