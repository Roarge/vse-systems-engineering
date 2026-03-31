---
name: verification-validation
description: Plan and execute verification and validation with trace links. Use when creating test cases, running V&V, or working in SR.5.
user-invocable: true
---

# Verification and Validation

You guide the engineer through ISO 29110 SR.5 (System Integration, Verification
and Validation). This skill implements R3 (machine-readable traceability) by
ensuring every requirement has a verification case and every stakeholder need
has a validation case.

## When This Skill Triggers

- The user asks to plan or execute V&V activities
- The user is in phase SR.5 and asks for guidance
- The user wants to create verification or validation cases
- The user asks about test planning or IVV procedures

## Key Definitions

- **Verification**: confirms the product is built right (system satisfies
  requirements). Answers: "Did we build it correctly?"
- **Validation**: confirms the right product is built (system satisfies
  stakeholder needs). Answers: "Did we build the right thing?"

Both are necessary. Verification without validation means a correct system that
nobody wants. Validation without verification means an untested system that
might fail.

## Continuous Verification Approach (AMBSE)

When using the agile MBSE lifecycle, V&V is not confined to SR.5. Three
verification timeframes operate throughout the project:

- **Nanocycle** (30 min to 1 day): SySiDE validation, trace checking, peer review.
  Runs during SR.2 and SR.3 as models are created.
- **Microcycle** (1-4 weeks): iteration-level V&V, stakeholder walkthrough,
  retrospective. Runs at the end of each iteration.
- **Macrocycle** (project length): full system V&V, formal acceptance. This is
  the traditional SR.5 activity described below.

See `${CLAUDE_PLUGIN_ROOT}/knowledge/ambse-agile-process.md` Section 3 and `${CLAUDE_PLUGIN_ROOT}/knowledge/vv-guide.md`
(Continuous Verification Timeframes section) for details.

## Process Flow

### Step 1: Review IVV Plan (SR.5.1)

The IVV Plan should have been established during SR.2.9 and updated during
SR.3.6. Verify that it:
- [ ] Lists all system requirements to be verified
- [ ] Lists all stakeholder needs to be validated
- [ ] Assigns a verification method to each requirement
- [ ] Defines pass/fail criteria for each test
- [ ] Specifies the integration sequence

### Step 2: Define Verification Cases

For each system requirement, create a verification case with the appropriate
method:

| Method | When to Use | VSE Applicability |
|--------|------------|-------------------|
| **Test** | Quantitative requirements (performance, accuracy) | High, primary method |
| **Analysis** | Mathematical/computational verification | High for performance |
| **Inspection** | Documentation, labelling, physical attributes | High, low cost |
| **Demonstration** | Functional operation without measurement | Medium |

```sysml
package Verification {
    import SystemRequirements::*;

    verification def VerifyTempAccuracy {
        doc /* Test: Apply known reference temperatures at -20, 0, 20, 40,
               60 degrees C. Verify readings are within +/- 0.5 C. */
        attribute id : String = "VER-001";
        attribute method : String = "test";
        attribute passCriteria : String = "All readings within +/- 0.5 C";
        verify requirement MeasureTemperature;
    }

    verification def VerifyResponseTime {
        doc /* Test: Apply step change in temperature. Measure time from
               change to display update. Must be under 2 seconds. */
        attribute id : String = "VER-002";
        attribute method : String = "test";
        attribute passCriteria : String = "Response under 2 seconds";
        verify requirement ResponseTimeReq;
    }

    verification def InspectUserInterface {
        doc /* Inspection: Review the display layout against the
               human factors requirements in REQ-005. */
        attribute id : String = "VER-003";
        attribute method : String = "inspection";
        verify requirement DisplayReadability;
    }
}
```

### Step 3: Define Validation Cases

For each stakeholder need, create a validation case:

```sysml
package Validation {
    import StakeholderNeeds::*;

    verification def ValidateMonitoring {
        doc /* Demonstration: Install the system in a representative
               facility environment. Ask the operator to perform
               typical monitoring tasks. Confirm the system meets
               the operator's stated needs for temperature monitoring. */
        attribute id : String = "VAL-001";
        attribute method : String = "demonstration";
        verify requirement MonitorTemperature;
    }
}
```

### Step 4: Trace Completeness Check

Invoke `@traceability-guard` to verify:
- Every system requirement has at least one verification case (verify link)
- Every stakeholder need has at least one validation case
- No orphan verification cases (cases not linked to any requirement)

### Step 5: System Integration (SR.5.2)

Guide the integration sequence:

1. **Bottom-up** (recommended for VSEs): integrate lowest-level elements first,
   test each interface as elements are combined
2. **Incremental**: add one element at a time, test after each addition

For each integration step:
- Identify the elements being integrated
- List the interfaces to be tested
- Define the expected behaviour
- Document results in the Integration Report

**Avoid big-bang integration.** It provides poor fault isolation and is the
highest-risk approach.

If system elements were provided by external suppliers (SUP), verify that
each delivered element meets the specifications in the Purchase Order and
System Elements Requirements before integrating.

### Step 6: System Verification (SR.5.3)

Execute verification cases against the integrated system:

1. Run each verification case per the IVV Procedures
2. Record results: pass, fail, or blocked
3. For failures: document the defect, assign for correction
4. For blocked cases: document the reason, plan resolution
5. Generate the Verification Report

### Step 7: System Validation (SR.5.4)

Execute validation cases with stakeholder participation:

1. Invite the Acquirer and relevant stakeholders
2. Demonstrate the system in its intended operational context
3. Walk through each validation case
4. **Use case driven validation** (from `${CLAUDE_PLUGIN_ROOT}/knowledge/ambse-architecture.md`
   Section 7.2): for each stakeholder use case, trace the data and control flow
   through the architecture. Verify that every scenario step is supported by a
   subsystem service. Identify gaps as missing requirements or design defects.
5. Record stakeholder feedback
6. Obtain formal acceptance or document required changes
7. Generate the Validation Report

### Step 8: Defect Correction (SR.5.5)

For each defect found during V&V:
1. Classify severity (critical, major, minor)
2. Assign to the responsible developer
3. After correction, retest to verify the fix
4. Regression test to confirm no new defects introduced

Repeat the correction-retest cycle until all defects are resolved or
formally deferred. Pay particular attention to faults introduced by
modifications (regression defects). Define a regression test scope
proportional to the change:
- Minor fix: retest the affected verification case plus immediate neighbours
- Major fix: retest all verification cases in the affected subsystem
- Architectural change: full regression of all system-level verification cases

### Step 9: System Operation Guide (SR.5.6, optional)

If the system requires operational documentation beyond the User Manual:

1. Document operational procedures, maintenance schedules, and troubleshooting
   guides in `docs/sr/system-operation-guide.md`
2. Include: startup/shutdown procedures, monitoring points, common fault
   responses, and escalation contacts
3. Target audience: operations staff who maintain and operate the system

### Step 10: Verify Operation Guide (SR.5.7, optional)

If an Operation Guide was created:

1. Review for completeness and accuracy (SYS, ACQ, STK)
2. Verify consistency with the System Design Document and V&V results
3. Record approval in the document revision history

## V&V Reporting

### Verification Report Structure
- Summary of verification activities
- List of verification cases executed
- Results (pass/fail/blocked) for each case
- Defects found and their resolution status
- Overall verification conclusion

### Validation Report Structure
- Summary of validation activities
- List of validation cases executed
- Stakeholder participation record
- Results and stakeholder feedback
- Overall validation conclusion and acceptance status

## Test Case Design Guidance

When deriving test cases from requirements:

1. **Boundary value analysis**: test at the edges of specified ranges
2. **Equivalence partitioning**: test one value from each valid/invalid class
3. **Error guessing**: test conditions likely to cause failures
4. **Requirements-based**: one or more test cases per requirement

## Automated V&V Support (Automator)

When the Syside Automator Python library is available, use it for programmatic
verification coverage analysis, constraint checking, and state machine
simulation.

### Verification Coverage Analysis

Programmatically check which requirements have verification cases and which
do not:

```python
import syside

model, diagnostics = syside.load_model(
    paths=syside.collect_files_recursively("models/")
)
assert not diagnostics.contains_errors(warnings_as_errors=True)

# Collect all verification case definitions
ver_cases = {
    ver.declared_name: ver
    for ver in model.nodes(syside.VerificationCaseDefinition)
    if ver.document.document_tier is syside.DocumentTier.Project
}

# Check each requirement for verification coverage
uncovered = []
for req in model.nodes(syside.RequirementDefinition):
    if req.document.document_tier is not syside.DocumentTier.Project:
        continue
    has_verify = False
    for child in req.owned_elements.collect():
        if child.try_cast(syside.VerificationCaseUsage) is not None:
            has_verify = True
    if not has_verify:
        uncovered.append(req.declared_name or req.name)

print(f"Requirements: {len(list(model.nodes(syside.RequirementDefinition)))}")
print(f"Verification cases: {len(ver_cases)}")
print(f"Uncovered requirements: {len(uncovered)}")
for name in uncovered:
    print(f"  {name}: no verification case")
```

### Expression-Based Constraint Checking

Evaluate requirement constraints (mass limits, performance bounds) against
model values using the Compiler:

```python
STDLIB = syside.Environment.get_default().lib
compiler = syside.Compiler()

# Find constraint attributes and evaluate them
for attr in model.nodes(syside.AttributeUsage):
    if attr.name in ("MassActual", "MassLimit", "PowerBudget"):
        value, report = compiler.evaluate_feature(
            feature=attr,
            scope=attr.owner,
            stdlib=STDLIB,
            experimental_quantities=True,
        )
        if not report.fatal:
            print(f"{attr.name} = {value}")
        else:
            print(f"{attr.name}: evaluation failed")
```

This enables automated checks like "total mass does not exceed the mass
budget" or "power consumption is within the allocated envelope" without
manual calculation.

### State Machine Simulation

The Automator can simulate state machines defined in SysML models using
the `python-statemachine` library:

```bash
pip install python-statemachine
```

The workflow:

1. Load the SysML model containing state definitions
2. Extract the state machine definition by qualified name
3. Convert SysML states and transitions to Python `python-statemachine` format
4. Use `syside.Compiler()` to evaluate transition guard expressions
5. Simulate state transitions against a sequence of input values
6. Verify that the state machine behaves as specified

This is particularly useful for verifying behavioural requirements that define
state-dependent system responses (e.g., alarm systems, mode controllers,
protocol handlers).

Reference: https://docs.sensmetry.com/examples/state_machine_simulation.html

## Red Flags

WARN the engineer if:
- V&V is being planned without baselined requirements
- Verification cases exist without verify links to requirements
- Big-bang integration is planned
- Stakeholders are not involved in validation
- Defects are being deferred without documented rationale
- The Verification or Validation Report is incomplete

## Reference: V&V Guide

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/vv-guide.md`

## Reference: AMBSE Agile Process (Verification Timeframes)

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/ambse-agile-process.md`
