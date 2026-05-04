---
title: "INCOSE Architecture and V&V for VSEs"
slug: incose-vse-architecture-and-vv
type: concept
layer: incose-vse
tags: [incose, architecture, verification, validation, interfaces, vee, vse]
sources:
  - citation: "INCOSE (2015). Systems Engineering Handbook, 4th edition. Wiley. Chapters 4.4 and 4.5."
    raw: incose_handbook_4e.pdf
  - citation: "Galinier, M., et al. (2021). Systems Engineering Practices for Small and Medium Enterprises. INCOSE-TP-2021-005-01."
    raw: galinier_sme_practices.pdf
related:
  - ambse-architecture-analysis
  - ambse-trade-studies
  - ambse-architectural-design
  - ambse-architecture-vv-and-iso29110
  - vv-methods
  - sysml2-canonical-model-layout
  - sysml2-allocations-overview
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator]
---

# INCOSE Architecture and V&V for VSEs

## Architecture versus design

Architecture defines what the system does and how it is organised
(abstract, conceptualisation-oriented). Design defines how each
element is built (technology-oriented, implementation-specific).
Maintain this separation to avoid premature commitment to
implementation details.

## Logical and physical architecture models

Logical architecture captures three views:

- **Functional model**: system functions and their functional
  interfaces
- **Behavioural model**: dynamic behaviour (state machines,
  activity flows, sequence diagrams)
- **Temporal model**: timing constraints and sequencing between
  functions

Physical architecture captures two views:

- **Structural model**: system elements and their physical
  interfaces
- **Layout model**: spatial placement and physical packaging

In an AMBSE workflow these views are realised as distinct
package sets in a single SysML 2.0 model
(see sysml2-canonical-model-layout) rather than as separate
documents. The ambse-architecture-analysis page describes the
five-view structure used at SR.3.

## Architecture process scaled for VSEs

1. Define architecture drivers and viewpoints relevant to
   stakeholders.
2. Build candidate functional architectures. Use Functional Flow
   Block Diagrams (FFBDs) or SysML activity diagrams.
3. Analyse functional interfaces using N-squared (coupling)
   matrices. Minimise cross-boundary interfaces to reduce
   integration risk.
4. Allocate logical functions to physical elements. Record the
   allocation in a traceability matrix
   (see sysml2-allocations-overview for the SysML 2.0 mechanism).
5. Evaluate candidates against selection criteria (cost, risk,
   performance, reuse potential). Document the trade-off
   rationale in a Justification Document. The ambse-trade-studies
   page describes the AMBSE-specific weighted-criteria method.
6. Select and baseline the architecture at PDR.

## Emergent properties

Properties that arise from the interaction of system elements
(reliability, performance, safety) and cannot be attributed to
any single element. A VSE must explicitly identify and verify
emergent properties, as they are the most common source of
integration surprises.

## Interface management

The devil is in the interfaces (Galinier et al.). Interface
errors detected late in IVV can consume up to 50 percent of
total project effort in rework. Define interfaces early using
three categories: physical connections, energy flows, and
information flows. Use N-squared charts or Design Structure
Matrices (DSM) to visualise and optimise interface complexity.

## Verification versus validation

- **Verification**: confirms the product is built right (design
  satisfies requirements). Answers: did we build it correctly?
- **Validation**: confirms the right product is built (system
  satisfies stakeholder needs). Answers: did we build the right
  thing?

The vv-methods page describes the canonical verification
techniques (inspection, analysis, demonstration, test, simulation,
sampling) and how they map to ISO/IEC 29110 SR.5 task outputs.

## Vee model verification strategy

Verification proceeds level by level up the right-hand side of
the Vee. Each level verifies against the corresponding left-hand
specification:

- Component verification against component specifications
- Subsystem verification against subsystem requirements
- System verification against SyRS
- System validation against StRS and operational scenarios

## Two nested loops (Galinier et al.)

The inner loop is verification (requirements to design to build,
then verify back against requirements). The outer loop is
validation (stakeholder needs to system requirements to validated
system, then validate back against needs). Both loops must close
before delivery.

## Integration approaches for VSEs

| Approach | Description | Risk level |
|----------|-------------|------------|
| Bottom-up | Integrate lowest elements first, build upward | Low risk, recommended for VSE |
| Incremental | Add one element at a time, test after each | Low risk, excellent fault isolation |
| Big-bang | Integrate everything at once | High risk, poor fault isolation, avoid |
| Top-down | Start with top-level skeleton, add elements | Medium, requires stubs |

The ambse-architecture-vv-and-iso29110 page describes how each
integration approach maps onto the AMBSE three-timeframe Vee
and ISO/IEC 29110 SR.4 and SR.5 tasks.

## SE return on investment in IVV

Optimum SE effort is 14.4 percent of programme cost (Honour study,
51 projects, 16 organisations). When starting from zero SE, the
return on investment is approximately 7:1. A common benefit is
reduction of IVV rework from 50 percent to 30 percent of project
cost.
