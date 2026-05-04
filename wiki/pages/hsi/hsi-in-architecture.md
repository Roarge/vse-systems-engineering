---
title: "HSI in Architecture"
slug: hsi-in-architecture
type: process
layer: hsi
tags: [hsi, architecture, function-allocation, vhcd, lifecycle]
sources:
  - citation: "INCOSE (2023). Human Systems Integration Primer Volume 1, v1.2, Section on HSI in Architecture."
    raw: HSI_Primer_Vol1.pdf
related:
  - hsi-foundations
  - hsi-domains
  - hsi-in-requirements
  - sysml2-canonical-model-layout
  - sysml2-allocations-overview
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [needs-and-requirements]
---

# HSI in Architecture

Architecture is not only about technical component breakdown.
It must also reflect how humans interact with, operate, and
maintain the system. For the HSI conceptual frame see
[[hsi-foundations]]. For the requirements that flow into
architecture, see [[hsi-in-requirements]].

## Key architectural considerations

1. **Function allocation drives architecture.** The decision to
   automate a function versus leaving it to a human operator
   directly shapes which components exist, how they communicate,
   and what interfaces are required. Architecture must
   accommodate the chosen human-machine task split. In a SysML
   2.0 model, function-to-element allocation is captured via
   the allocation mechanism (see
   [[sysml2-allocations-overview]]).

2. **Interface design follows from human needs.** The
   architecture must provide the information channels, displays,
   controls, and feedback mechanisms that humans need for
   situation awareness. This includes functional, informational,
   cognitive, and physical interfaces identified during HFE
   analysis.

3. **Maintainability shapes physical architecture.** If a
   component requires human maintenance, the architecture must
   provide physical access, diagnostic interfaces, and clear
   labelling. The maintenance concept (who maintains, how often,
   what skills) constrains physical layout.

4. **Training infrastructure is architectural.** If the system
   requires operator training, the architecture may need to
   support simulation modes, practice environments, or embedded
   training capabilities.

5. **Safety constraints shape redundancy and isolation.** Where
   human safety is at risk, the architecture must include
   protective barriers, fail-safe modes, or redundant paths. The
   degree of safety criticality (determined through HSI safety
   analysis) drives architectural complexity.

6. **Environmental constraints shape packaging.** The physical
   environment (temperature, vibration, lighting) in which
   humans operate the system constrains enclosure design,
   display readability, control placement, and protective
   measures.

## The concept phase sets the HSI architecture baseline

During the concept phase, the following HSI activities directly
inform architecture:

- Identify user groups (operators, maintainers) and their
  characteristics.
- Understand user goals, needs, and organisational context.
- Extract baseline performance data and key learnings from
  similar systems.
- Define human factors requirements and performance measures
  using Virtual Human-Centred Design (VHCD) where feasible.
- Perform human-component cost analysis to inform option
  down-selection.

## The development phase refines HSI in architecture

- Conduct task analysis, modelling, and iterative
  human-in-the-loop evaluation.
- Perform complexity and activity analysis to validate function
  allocation.
- Identify and mitigate human-related risks.
- Apply human and organisational factors analysis to design
  decisions.
- Optimise future working processes and practices.
- Progress toward tangibility (physical and cognitive) of the
  design.

## Where this lands in the AMBSE model

In the canonical AMBSE layout (see
[[sysml2-canonical-model-layout]]), HSI architectural decisions
land in the architecture-design packages: `{{sc}}_ArchDesign` for
the chosen architecture, `{{sc}}_ArchAnalysis` for the trade
studies that compared human-machine allocations,
`{{sc}}_FunctionalAnalysis` for the function definitions that
the allocations operate on, and `{{sc}}_Interfaces` for the
human-system interface definitions.

## See also

- [[hsi-foundations]] for the TOP-in-Environment frame.
- [[hsi-domains]] for the 13 HSI perspectives that inform
  architectural decisions.
- [[hsi-in-requirements]] for the requirements upstream of these
  architecture decisions.
- [[hsi-vse-tiered-approach]] for VSE-scaled HSI selection.
