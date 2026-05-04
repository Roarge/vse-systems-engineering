---
title: "HSI in Requirements"
slug: hsi-in-requirements
type: process
layer: hsi
tags: [hsi, requirements, function-allocation, fitts-list, smart, mabamabamaba]
sources:
  - citation: "INCOSE (2023). Human Systems Integration Primer Volume 1, v1.2, Section on HSI in Requirements."
    raw: HSI_Primer_Vol1.pdf
related:
  - hsi-foundations
  - hsi-domains
  - hsi-in-architecture
  - sysml2-syntax-requirements-and-cases
  - sysml2-requirements-semantics
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [needs-and-requirements]
---

# HSI in Requirements

HSI requirements are not a separate category bolted on after
technical requirements are written. They emerge from
understanding who the users are, what tasks they perform, in
what environment, and with what capabilities and limitations.
For HSI background see [[hsi-foundations]] and [[hsi-domains]].
For how HSI then shapes architecture, see
[[hsi-in-architecture]].

## Practical steps for a VSE

1. **Identify user groups early.** Operators, maintainers,
   trainers, customers, the public. For each group, document
   relevant characteristics: cognitive load capacity, physical
   capabilities, experience level, environmental constraints.

2. **Define human activity and usage requirements.** These
   should be defined both **longitudinally** (along the
   lifecycle) and **transversally** (from subsystem to system of
   systems) at relevant levels of granularity.

3. **Develop human-in-the-loop measures of performance.**
   Requirements should specify not just what the system does,
   but how well the human-system combination performs the
   intended function.

4. **Include HSI in trade-off criteria.** When making
   requirements and design trade-offs, ensure that human impacts
   (safety, usability, training burden, error likelihood) are
   understood and considered within project decision-making.

5. **Address function allocation.** For each system function,
   decide whether it is best performed by human, machine, or a
   combination. Use the Fitts list (MABA-MABA) as a starting
   heuristic, then refine through prototyping and user feedback.
   Functions must be reallocated incrementally based on
   formative evaluations.

6. **Capture safety and health requirements explicitly.**
   Identify risks to successful delivery from the human element:
   human error, safety hazards, health hazards. Express these
   as verifiable requirements.

## Requirement types with HSI content

| Requirement area | HSI questions to ask |
|---|---|
| Functional | Which functions are allocated to the human? What information does the human need? |
| Performance | What is the acceptable human-system error rate? Response time? Workload? |
| Interface | What displays, controls, alerts does the human need? How accessible must they be? |
| Environmental | In what physical conditions will humans operate? Temperature, noise, lighting? |
| Safety | What are the consequences of human error? How is error prevented or mitigated? |
| Training | What KSA does the user need? How will training be delivered and maintained? |
| Maintenance | Can a single maintainer perform tasks safely? What tools and access are needed? |
| Usability | What effectiveness, efficiency, and satisfaction targets must be met? |

## Connecting HSI requirements to the SysML 2.0 model

In the AMBSE workflow, HSI requirements live in
`{{sc}}_Requirements` alongside other system requirements. They
use the same SysML 2.0 syntax as any other requirement (see
[[sysml2-syntax-requirements-and-cases]]), and the same
semantic frame (assume/require, satisfy, verify; see
[[sysml2-requirements-semantics]]). The function allocation
question (step 5 above) is then represented as an allocation
relationship between functional and physical architecture
elements; for the SysML 2.0 mechanism see
[[sysml2-allocations-overview]].

For elicitation, the use case driven workflow described in
[[sysml2-cases-overview]] and [[sysml2-case-kinds]] gives a
natural place to capture human-system scenarios: each scenario
step where a human acts is a candidate requirement.

## See also

- [[hsi-foundations]] for the TOP-in-Environment frame.
- [[hsi-domains]] for the 13 HSI perspectives.
- [[hsi-in-architecture]] for how requirements then shape
  architecture.
- [[hsi-vse-tiered-approach]] for tiered selection of which
  perspectives to apply.
