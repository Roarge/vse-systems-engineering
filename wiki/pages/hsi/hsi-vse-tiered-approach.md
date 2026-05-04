---
title: "Lightweight HSI for VSEs: Tiered Approach"
slug: hsi-vse-tiered-approach
type: pattern
layer: hsi
tags: [hsi, vse, tiered, lightweight, lifecycle-integration]
sources:
  - citation: "INCOSE (2023). Human Systems Integration Primer Volume 1, v1.2, scaled per ISO/IEC 29110."
    raw: HSI_Primer_Vol1.pdf
related:
  - hsi-foundations
  - hsi-domains
  - hsi-in-requirements
  - hsi-in-architecture
  - iso29110-sr-process
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [needs-and-requirements]
---

# Lightweight HSI for VSEs: Tiered Approach

A VSE (fewer than 25 people) will not have a dedicated HSI team,
formal HITL simulation facilities, or the budget for full-scale
human factors evaluation programmes. This page scales the 13
HSI perspectives (see [[hsi-domains]]) down to what a small team
can realistically do.

## Tier 1: always do (every VSE project with human users)

These perspectives apply to virtually all systems that humans
interact with.

### 1. Human Factors Engineering (lightweight)

- Identify who the users are and what tasks they perform.
- For each human-system interface, ask: what information does
  the user need, what actions can they take, what errors are
  likely?
- Use low-fidelity prototypes (paper, wireframes, 3D-printed
  mockups) for early feedback. This replaces formal HITL
  simulation.
- Conduct at least one round of formative usability evaluation
  with real or representative users before design freeze.

### 2. Safety

- Perform a lightweight hazard analysis for human-related risks.
- For each identified hazard: what is the consequence, what is
  the likelihood, what design feature mitigates it?
- Document safety requirements as verifiable statements.
- This is mandatory for any system where human error could
  cause injury, property damage, or data loss.

### 3. Usability

- Set explicit usability targets (task completion rate, error
  rate, time on task, subjective satisfaction).
- Test with representative users. Even 3 to 5 users reveal most
  usability problems.
- Iterate the design based on findings.

### 4. Function allocation

- For each system function, explicitly decide: human,
  automated, or shared. Document the rationale.
- Revisit allocation after prototyping and user feedback.

## Tier 2: do when relevant (depends on system type)

### 5. Training

- If the system requires users to learn new skills, define what
  training is needed and how it will be delivered.
- Consider embedded help, progressive disclosure, or job aids
  as low-cost alternatives to formal training programmes.

### 6. Maintenance and ILS (lightweight)

- If the system requires physical maintenance, ensure the
  design supports it: access panels, diagnostic indicators,
  clear labelling.
- Document maintenance procedures, required tools, and skill
  levels.

### 7. Occupational health

- If the system exposes humans to physical hazards (noise,
  vibration, chemicals, repetitive motion), identify and
  mitigate.
- Most relevant for hardware-intensive systems, manufacturing
  equipment, or systems used in harsh environments.

### 8. Environmental factors

- If the system operates in a challenging environment (outdoor,
  industrial, mobile), specify environmental constraints and
  their effect on human performance (display readability in
  sunlight, control operation with gloves, noise interference
  with communication).

## Tier 3: consider if resources allow

9. **Workforce planning.** Relevant if the system requires
   specific staffing levels for operation or support. For most
   VSE products, this reduces to documenting the assumed
   operator profile.
10. **Competences and personnel.** Relevant if the system
    requires specialised skills. Document the assumed skill
    level of the target user.
11. **Social, cultural, and organisational factors.** Relevant
    for systems deployed in diverse cultural contexts or that
    change organisational workflows. A VSE should at minimum
    note any known cultural or organisational assumptions baked
    into the design.
12. **Habitability.** Relevant only for systems that define
    living or working spaces (vehicles, workstations, control
    rooms).
13. **Comfort and UX.** Beyond basic usability, consider
    subjective experience only when the product competes on user
    experience or when user adoption is a risk.

## Embed HSI into existing SE activities

Rather than running HSI as a separate workstream, a VSE should
embed HSI thinking into existing SE activities. For the ISO
29110 SR-process activity definitions, see
[[iso29110-sr-process]].

| SE activity (ISO 29110) | HSI action |
|---|---|
| Stakeholder requirements (SR.2.1) | Identify user groups. Capture HSI needs. Specify usability targets. |
| System requirements (SR.2.4 to SR.2.5) | Include function allocation, safety, and human performance requirements. |
| Architecture design (SR.3) | Ensure interfaces support human needs. Apply maintainability constraints. |
| Detailed design (SR.4.1) | Prototype human-facing interfaces. Conduct formative usability evaluation. |
| Integration and verification (SR.5.2 to SR.5.3) | Verify HSI requirements (usability tests, safety checks). |
| Validation (SR.5.4) | Validate that the system meets user needs in operational context. |
| Operations and support | Collect user feedback. Monitor safety incidents. Update training. |

## HSI activities across lifecycle phases

**Concept phase:**

- Identify user groups (operators, maintainers).
- Understand user characteristics, goals, needs, organisational
  context.
- Extract baseline performance and key learnings from similar
  systems.
- Define HF requirements and performance measures.
- Human-component cost analysis informs option down-selection.

**Development phase:**

- Task analysis, modelling, iterative prototyping.
- Complexity and activity analysis for function allocation.
- Identify and mitigate human-related risks.
- Apply human and organisational factors to design decisions.

**Manufacturing/production phase:**

- Conduct usability and acceptance testing.
- Plan for service introduction.
- Develop training materials.
- Prepare for any organisational change.

**Operations phase:**

- Manage service introduction.
- Optimise working practices and processes.
- Identify and manage emergent system properties.
- Monitor safety, human error, and system performance.

**Support phase:**

- Identify emergent user needs and support requirements.
- Apply HF analysis to continuous improvement.
- Support system updates, upgrades, and organisational changes.

## Key principle for VSEs

The final objective of HSI is to design and operate systems
that allow humans to be humans. Every project should follow
this guiding principle. The role of HSI, even in a small team
without dedicated specialists, is to ensure this principle is
not lost in the pressure of technical delivery.

A VSE achieves this by asking, at every design decision: "How
does this affect the person who will use, operate, maintain, or
be affected by this system?"

## See also

- [[hsi-foundations]] for the TOP-in-Environment frame.
- [[hsi-domains]] for the full 13-perspective catalogue.
- [[hsi-in-requirements]] and [[hsi-in-architecture]] for how
  HSI enters specific SE activities.
- [[iso29110-sr-process]] for the ISO 29110 SR-process activity
  catalogue this section integrates with.
