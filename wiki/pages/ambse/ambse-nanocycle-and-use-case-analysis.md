---
title: "AMBSE Nanocycle Workflow and Three Approaches to Use Case Analysis"
slug: ambse-nanocycle-and-use-case-analysis
type: process
layer: ambse
tags: [nanocycle, flow-based, scenario-based, state-based, ambse]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapters 4-5."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
related:
  - ambse-requirements-as-models
  - ambse-use-case-driven-elicitation
  - ambse-system-requirements-derivation
  - ambse-vee-three-timeframes
  - ambse-git-nanocycle-commits
  - sysml2-actions
  - sysml2-state-machines
  - sysml2-special-action-usages
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [needs-and-requirements]
---

# AMBSE Nanocycle Workflow and Three Approaches to Use Case Analysis

For the underlying nanocycle definition see
[[ambse-vee-three-timeframes]]. For the git operationalisation
(nanocycle = commit) see [[ambse-git-nanocycle-commits]].

## The nanocycle requirements workflow

The nanocycle (20 to 60 minutes) is the **inner loop** of
requirements development. It ensures continuous verification as
requirements are created. The workflow for each use case:

1. **Define the use case system context**: identify actors, the
   system under specification, and their relationships (SysML
   2.0 part defs and connections).
2. **Define use case scenarios**: write the normal flow as a
   sequence of actor-system interactions.
3. **Derive the functional flow**: create an action definition
   that models the system behaviour for this use case (see
   [[sysml2-actions]]).
4. **Define ports and interfaces**: specify the data and
   control flows between the system and its actors.
5. **Derive state-based behaviour** (if event-driven): create a
   state definition that captures the system states and
   transitions for this use case (see [[sysml2-state-machines]]).
6. **Verify and validate**: run SySiDE validation, check
   traceability links, review with a colleague.
7. **Add traceability links**: ensure every requirement has a
   `satisfy` link upward and a `verify` link downward.
8. **Perform review**: if more requirements remain, return to
   step 2.

This cycle is repeated every 20 to 60 minutes. The model is
the primary work product. Textual requirements are linked to
(not separate from) the model elements.

**The nanocycle is the Vee in miniature.** Steps 1 to 5 are
the left-side specification work (define the context, write
scenarios, derive flows, declare interfaces, capture
state-based behaviour). Step 6 is the right-side verification
(validate the model, check traces). Step 7 connects the two
sides by adding the trace links that make the verification
meaningful. Step 8 closes the loop and returns to specification
for the next requirement. Each commit on the iteration's
`vse/iter-NN` branch typically captures one pass through this
loop. See [[ambse-git-nanocycle-commits]] for the git mapping.

**Iteration boundary**: when the use case is fully specified,
verified, and trace-complete, the iteration's branch is opened
as a pull request against `main`. The PR review is the formal
handoff event (per Douglass, Cookbook, p. 61). For VSE
projects with one or two engineers, self-review is acceptable.
The PR mechanism remains load-bearing because it triggers the
CI gates and records the iteration boundary in git history.

## Three approaches to use case analysis

Douglass describes three approaches for analysing use cases.
Choose based on the nature of the system behaviour.

### Flow-based analysis

Best for: systems with deterministic, sequential data
transformations.

Model the use case as an **action definition** with sequential
actions connected by data flows. Each action transforms inputs
to outputs. See [[sysml2-actions]] for the action-definition
syntax.

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

### Scenario-based analysis

Best for: systems with multiple interaction paths between
actors and the system.

Model the use case as a set of **scenarios** (sequences of
messages between actors and system). Each scenario represents
one path through the use case. A "minimal spanning set" of
scenarios covers all paths in the normative state machine at
least once. See [[sysml2-special-action-usages]] for the
send/accept syntax used in scenario flows.

### State-based analysis

Best for: systems that respond to asynchronous events and must
manage concurrent states.

Model the use case as a **state definition** where inputs are
events, transitions capture the system response, and actions
on states/transitions specify the input-output transformations.
See [[sysml2-state-machines]].

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

VSE guidance: most VSE systems benefit from a **combination**.
Use flow-based analysis for the normal data path and
state-based analysis for mode management and error handling.

## See also

- [[ambse-requirements-as-models]] for the dual-representation
  principle.
- [[ambse-use-case-driven-elicitation]] for the upstream use
  case workflow.
- [[ambse-system-requirements-derivation]] for the requirement
  derivation that runs alongside the nanocycle.
- [[ambse-vee-three-timeframes]] for nanocycle/microcycle/macrocycle.
- [[ambse-git-nanocycle-commits]] for the git operational form.
- [[sysml2-actions]], [[sysml2-state-machines]],
  [[sysml2-special-action-usages]] for the SysML 2.0
  behavioural constructs the three analysis approaches use.
