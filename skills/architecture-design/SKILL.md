---
name: architecture-design
description: Develop functional and physical architecture with trade-off analysis. Acts as designed cognitive reserve (R2) for architecture decisions.
user-invocable: true
---

# Architecture Design

You guide the engineer through ISO 29110 SR.3 (System Architectural Design).
This skill implements R2 (designed cognitive reserve) by generating architecture
options with trade-offs that the engineer may not have considered. You actively
expand the decision space, then help narrow it through structured evaluation.

## When This Skill Triggers

- The user asks to design system architecture
- The user is in phase SR.3 and asks for guidance
- The user wants to create a System Design Document
- The user asks about functional or physical decomposition

## Prerequisites Check

Before starting architecture work, verify:
- [ ] System Requirements Specifications are baselined (SR.2 complete)
- [ ] Traceability Matrix exists and is current
- [ ] IVV Plan has been established

If prerequisites are not met, route back to `@lifecycle-orchestrator`.

## Process Flow

### Step 1: Identify Architecture Drivers

From the baselined SyRS, identify:
1. **Key functional requirements** that define what the system must do
2. **Performance requirements** that constrain how well it must do it
3. **Interface requirements** that define external connections
4. **Constraints** (budget, schedule, regulations, technology)
5. **Quality attributes** (reliability, maintainability, safety)

**Architecture views** (from `knowledge/ambse-architecture.md` Section 2.2):
structure the analysis using five views: subsystem (decomposition), deployment
(function-to-physical allocation), dependability (safety/reliability overlay),
distribution (geographic/network), and concurrency (parallel execution). Not all
views are needed for every project. The subsystem view is always required.

### Step 2: Functional Architecture (SR.3.1)

Decompose the system into logical functions:

1. Identify top-level system functions from the SyRS
2. Decompose each function into sub-functions
3. Define functional interfaces between sub-functions
4. Use N-squared analysis to identify interface complexity

```sysml
package FunctionalArchitecture {
    import SystemRequirements::*;

    part def SensorSystem {
        part sensing : SensingFunction;
        part processing : ProcessingFunction;
        part alerting : AlertingFunction;

        interface sensingToProcessing connect
            sensing.dataOut to processing.dataIn;
        interface processingToAlerting connect
            processing.alertOut to alerting.alertIn;
    }

    part def SensingFunction {
        port dataOut : DataPort;
    }

    part def ProcessingFunction {
        port dataIn : DataPort;
        port alertOut : AlertPort;
    }

    part def AlertingFunction {
        port alertIn : AlertPort;
    }
}
```

### Step 3: Functional Trade-offs (SR.3.2)

For the functional architecture, generate at least two alternative
decompositions. For each alternative, evaluate using the AMBSE trade study
methodology (see `knowledge/ambse-architecture.md` Section 3):

1. **Define assessment criteria** (MOEs) derived from system requirements
2. **Assign weights** to criteria reflecting stakeholder priorities (sum to 1.0)
3. **Score each candidate** against each criterion (0.0 to 1.0)
4. **Compute weighted scores** and rank candidates
5. **Sensitivity analysis**: vary weights by +/- 10-20% and check ranking stability

| Criterion | Weight | Alternative A | Alternative B |
|-----------|--------|--------------|--------------|
| Requirement coverage | [0.0-1.0] | [score] | [score] |
| Interface complexity | [0.0-1.0] | [score] | [score] |
| Reuse potential | [0.0-1.0] | [score] | [score] |
| Risk (technical) | [0.0-1.0] | [score] | [score] |
| Cost estimate | [0.0-1.0] | [score] | [score] |

**R2 cognitive reserve role:** Generate alternatives the engineer may not have
considered. For example:
- A centralised vs. distributed processing architecture
- A push vs. pull data flow model
- Existing component reuse vs. custom development
- Hardware vs. software allocation of functions

Document the trade-off rationale in the Justification Document. If the top
candidate is sensitive to small weight changes, flag this and recommend
further analysis before committing.

### Step 4: Physical Architecture (SR.3.3)

Allocate logical functions to physical system elements:

1. Identify physical elements (hardware, software, firmware)
2. Allocate functions to elements (one function may span multiple elements)
3. Define physical interfaces (connectors, protocols, data formats)
4. Identify buy, build, or reuse decisions for each element

```sysml
package PhysicalArchitecture {
    import FunctionalArchitecture::*;

    part def SmartSensorUnit {
        part tempProbe : TemperatureProbe {
            doc /* Commercial off-the-shelf PT100 sensor */
        }
        part microcontroller : MCU {
            doc /* Handles processing and alerting functions */
        }
        part display : AlertDisplay;

        allocate SensingFunction to tempProbe;
        allocate ProcessingFunction to microcontroller;
        allocate AlertingFunction to display;
    }
}
```

### Step 5: Physical Trade-offs (SR.3.4)

Evaluate physical architecture alternatives using the same trade-off matrix.
Additionally consider:
- Make vs. buy vs. reuse for each element
- Supplier availability and lead times
- Integration complexity
- Maintenance and lifecycle costs

Update the Traceability Matrix to link physical elements to functional
architecture and to system requirements.

#### Purchase Orders

If any system elements are to be purchased (buy decision in the make/buy/reuse
analysis), initiate a Purchase Order for each:

1. Use the template at `docs/pm/purchase-order.md`
2. Specify the element, supplier, specifications, acceptance criteria
3. Link the Purchase Order to the relevant system element requirement
4. Obtain PJM approval before placing the order

> VSE note: For commercial off-the-shelf (COTS) components, the Purchase Order
> may be simplified to a procurement record documenting what was bought, from
> whom, at what specification, and at what cost.

### Step 6: Verify Architecture (SR.3.5)

Verify the System Design Document:
- [ ] Every system requirement is allocated to at least one system element
- [ ] All functional interfaces are defined
- [ ] All physical interfaces are specified
- [ ] Trade-off rationale is documented
- [ ] The design is feasible within budget and schedule constraints
- [ ] Traceability Matrix is updated

Invoke `@traceability-guard` to verify trace completeness.

After the technical verification passes, obtain formal approval:

- **Approvers**: SYS, DES, DEV (or their VSE equivalents)
- **Record**: Document approval in a Meeting Record or as sign-off in the
  System Design Document revision history
- **Baseline**: Upon approval, the System Design Document is baselined. Further
  changes require a Change Request.

### Step 7: Handoff to Downstream Engineering

When using the hybrid lifecycle, the handoff occurs at iteration boundaries. The
handoff is a workflow, not an event. See `knowledge/ambse-architecture.md` Section 6
for the complete handoff procedure. A complete handoff package includes:

- Subsystem requirements (allocated and derived)
- Interface specification (logical, becoming physical at handoff)
- Verification criteria for each element
- Behavioural model (state machines or action sequences)
- Design constraints and rationale (trade study results)

VSE guidance: the handoff can be as simple as a Git tag with a summary of changes,
combined with a brief walkthrough. The key is an unambiguous, baselined specification.

### Step 8: Integration Planning (SR.3.6)

Define how system elements will be integrated:
- Integration sequence (bottom-up or incremental recommended for VSEs)
- Integration test procedures for each interface
- Update the IVV Plan with integration test cases

Update the existing IVV Procedures (from SR.2.9) to include integration-level
test procedures. For each integration step, define:
- Interface verification procedure
- Expected results and pass/fail criteria
- Regression scope (which previously verified interfaces to recheck)

### Step 8: System User Manual (SR.3.7, optional)

Create a preliminary System User Manual if required by the Project Plan.

### Step 9: Verify System User Manual (SR.3.8, optional)

If a System User Manual was created in Step 8:

1. Review for completeness and accuracy (SYS, ACQ, STK)
2. Verify consistency with the System Design Document
3. Record approval in the document revision history
4. Baseline the manual alongside the System Design Document

## Interface Analysis

Use an N-squared matrix to visualise interface complexity:

```
         To:  A    B    C
From: A  --   I1   --
      B  --   --   I2
      C  I3   --   --
```

Where I1, I2, I3 are interface specifications. Minimise the number of
interfaces to reduce integration risk. The "devil is in the interfaces"
(Galinier et al.): interface errors detected late consume up to 50% of rework.

## Red Flags

WARN the engineer if:
- Architecture work starts before requirements are baselined
- Only one alternative is considered (no trade-off analysis)
- Functions are allocated to physical elements without documented rationale
- Interfaces are undefined or underspecified
- The Traceability Matrix is not updated after architecture decisions
- The engineer is making premature technology commitments without trade-off
  analysis
