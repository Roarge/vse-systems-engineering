---
title: "Human-Systems Integration Foundations: TOP in Environment"
slug: hsi-foundations
type: concept
layer: hsi
tags: [hsi, top-environment, sociotechnical, lifecycle, vse]
sources:
  - citation: "INCOSE (2023). Human Systems Integration Primer Volume 1, v1.2. Boy and Kennedy (Eds.). ISBN 978-1-937076-12-2."
    raw: HSI_Primer_Vol1.pdf
related:
  - hsi-domains
  - hsi-in-requirements
  - hsi-in-architecture
  - hsi-vse-tiered-approach
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [needs-and-requirements]
---

# Human-Systems Integration Foundations: TOP in Environment

Human Systems Integration (HSI) is a transdisciplinary
sociotechnical and management approach within systems
engineering. It ensures that a system's technical,
organisational, and human elements are appropriately addressed
across the whole system lifecycle, from early design to
disposal.

## Core model: TOP in Environment

HSI operates on four interacting entities:

- **Technology** (hardware, software, algorithms)
- **Organisation** (processes, roles, governance)
- **People** (operators, maintainers, customers, the public)
- **Environment** (physical and cultural context of use)

All four must be **jointly optimised**. A system that is
technically correct but ignores the humans who operate, maintain,
or are affected by it will fail on performance, safety, cost, or
schedule.

## Why HSI matters

HSI delivers value across four dimensions:

1. **Performance.** Optimises total system performance by
   considering both human and machine elements together, not in
   isolation.
2. **Risk.** Identifies human-related risks early (human error,
   safety incidents, health hazards). Fixing these early costs
   far less than late discovery.
3. **Cost.** Reduces whole-lifecycle cost by avoiding rework,
   redesign, and post-deployment corrective action driven by
   poor human fit.
4. **Time.** Reduces schedule overruns by improving efficiency
   and reducing rework during development.

## HSI is not an add-on

HSI must be coordinated with other SE activities during the
whole lifecycle. It is not a separate evaluation performed after
design is complete. System concepts must be tailored to HSI
requirements at any time, following up the discovery and
validation of emergent properties.

## The "human" in HSI

The term covers all individuals and groups interacting within
the System of Interest (SoI):

- System owners, operators, maintainers, trainers, customers,
  support personnel, and the public.
- Adversaries and those who may misuse the system.

This breadth is essential for VSE projects: a small team is
unlikely to have a dedicated user-research role, so the systems
engineer must enumerate all human-touching boundaries when
deriving needs.

## Where this fits in the plugin

For VSE projects, HSI material is consumed by the
`needs-and-requirements` skill: HSI considerations enter at the
elicitation stage and shape both stakeholder needs and system
requirements. Use case driven elicitation
([[sysml2-cases-overview]] and [[sysml2-case-kinds]]) is the
natural mechanism for capturing scenarios in which humans
interact with the system.

## See also

- [[hsi-domains]] for the 13 HSI perspectives (HFE, social and
  cultural factors, planning, ILS, manpower, personnel,
  training, safety, occupational health, sustainability,
  habitability, usability, comfort and UX).
- [[hsi-in-requirements]] for capturing HSI as system
  requirements.
- [[hsi-in-architecture]] for how HSI shapes architectural
  decisions.
- [[hsi-vse-tiered-approach]] for the tiered approach a small
  team can realistically apply.
