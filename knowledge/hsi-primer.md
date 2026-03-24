# Human-System Integration Primer (VSE-scaled)

Source: INCOSE HSI Primer Volume 1 v1.2 (2023). Boy & Kennedy (Eds.).
ISBN 978-1-937076-12-2.

This reference distils the INCOSE HSI Primer for use by Very Small Entities
(VSEs, fewer than 25 people) performing systems engineering under ISO/IEC 29110.
Large-programme HSI practices (dedicated HSI teams, HITL simulation facilities,
formal manpower modelling) are omitted or reduced to lightweight equivalents.

---

## What is HSI

Human Systems Integration (HSI) is a transdisciplinary sociotechnical and
management approach within systems engineering. It ensures that a system's
technical, organisational, and human elements are appropriately addressed across
the whole system lifecycle, from early design to disposal.

### Core model: TOP in Environment

HSI operates on four interacting entities:

- **Technology** (hardware, software, algorithms)
- **Organisation** (processes, roles, governance)
- **People** (operators, maintainers, customers, the public)
- **Environment** (physical and cultural context of use)

All four must be jointly optimised. A system that is technically correct but
ignores the humans who operate, maintain, or are affected by it will fail on
performance, safety, cost, or schedule.

### Why HSI matters

HSI delivers value across four dimensions:

1. **Performance.** Optimises total system performance by considering both human
   and machine elements together, not in isolation.
2. **Risk.** Identifies human-related risks early (human error, safety incidents,
   health hazards). Fixing these early costs far less than late discovery.
3. **Cost.** Reduces whole-lifecycle cost by avoiding rework, redesign, and
   post-deployment corrective action driven by poor human fit.
4. **Time.** Reduces schedule overruns by improving efficiency and reducing
   rework during development.

### HSI is not an add-on

HSI must be coordinated with other SE activities during the whole lifecycle. It
is not a separate evaluation performed after design is complete. System concepts
must be tailored to HSI requirements at any time, following up the discovery and
validation of emergent properties.

### The "human" in HSI

The term covers all individuals and groups interacting within the System of
Interest (SoI): system owners, operators, maintainers, trainers, customers,
support personnel, and the public. It also includes adversaries and those who
may misuse the system.

---

## HSI Domains (Perspectives)

The primer identifies 13 HSI perspectives. Each represents a lens through which
human considerations enter requirements, design, evaluation, and risk
management. Not all apply equally to every project. A VSE must select the
perspectives relevant to its system.

### 2.1 Human Factors Engineering (HFE)

Understanding human capabilities (cognitive, physical, sensory, team dynamics)
to create effective, efficient, and safe human-hardware-software interfaces.

Key interface types to consider:

- **Functional interfaces.** Allocation of functions to human or automation.
- **Informational interfaces.** What information the human needs, how it is
  presented, situation awareness support.
- **Environmental interfaces.** Natural and artificial environments, facility
  design.
- **Operational interfaces.** Procedures, documentation, workloads, job aids.
- **Cognitive interfaces.** Decision support, mental models, knowledge
  generation, memory aids.
- **Physical interfaces.** Controls, displays, workstations, labels, markings,
  maintenance provisions.

### 2.2 Social, Cultural and Organisational Factors

Considers the organisational aspects of sociotechnical systems, including the
organisations that will use, support, and maintain the system across its
lifecycle.

Challenges include:

- Team performance, cohesion, collaboration, and communication provisions.
- Job design, management structure, authority, policies.
- Intra- and inter-organisational interactions and boundaries.

### 2.3 HSI Planning

Addresses the planning and prioritising of human-centred studies and design
activities within a project. HSI priorities must be set up front upon mission
definition and carried throughout resource allocation. Especially important is
the formulation and consideration of human capabilities and limitations as part
of function allocation and alternatives analysis.

### 2.4 Integrated Logistics Support (ILS) and Maintenance

Covers human performance during operations and support. ILS ensures the product
stakeholders can derive the required benefit from the outset, and prevents
unexpected performance decrease. Includes: updated know-how, skill-set
definition, training, training aids, simulators, serviceable spare parts,
failure data collection, tools, test and support equipment.

### 2.5 Workforce Planning (Manpower)

Addresses the number, type, and mix of personnel required to carry out tasks,
operate, maintain, support, and provide training for a system. Workforce factors
include job tasks, operation and maintenance rates, associated workload, and
operational conditions.

### 2.6 Competences and Professionalism (Personnel)

Considers the knowledge, skills, experience levels, and aptitudes (cognitive,
physical, sensory) required to operate, maintain, and support a system, and the
means to provide such people (selection, recruitment, training). Abilities can
evolve individually and collectively.

### 2.7 Training

The instruction and resources required to provide personnel with requisite
Knowledge, Skills, and Attitudes (KSA) to properly operate, maintain, and
support systems. Includes computer-based courseware, simulators, actual
equipment, job performance aids, and electronic technical manuals.

### 2.8 Safety

Promotes system design characteristics and procedures to minimise the risk of
accidents or mishaps that could cause death or injury to operators, maintenance
and support personnel, or threaten system operation, or cause cascading failures
in other systems. Seeks to minimise the potential for human or machine errors
that cause injurious accidents.

### 2.9 Occupational Health

Promotes system design features that minimise health hazards (injury, acute or
chronic illness, disability) and enhance job performance and wellbeing.
Prevalent issues: noise, lighting, chemical safety, atmospheric hazards,
vibration, radiation, biological threats, repetitive motion diseases.

### 2.10 Sustainability (Environment)

Covers environmental considerations that affect operations and human-system
performance. Environment includes temperature, humidity, noise, lighting,
vibration, radiation, shock, air quality. This "environment" affects the human
ability to function and experience as part of the system.

### 2.11 Habitability

Living and working conditions necessary to sustain morale, safety, health, and
comfort of operational people. Includes workspace, lighting, ventilation,
sanitation, noise and temperature control. Directly contributes to personnel
effectiveness and mission accomplishment.

### 2.12 Usability

Uses objective evaluation methods to address effectiveness, efficiency,
self-description, conformity to human expectation, tolerance towards human
errors, ease of individualisation, and learning suitability. HSI extends classic
usability beyond end-users to include maintainers, safety personnel, and all
roles across the lifecycle.

### 2.13 Comfort and User Experience (UX)

Personal internal human aspects (joy, frustration, opinions, unconscious
preferences) that apply to all humans involved in the SE process, not only
end-users. Comfort aspects strongly influence both the human experience of the
product and the quality of the SE processes themselves.

---

## HSI in Requirements

### Capture HSI needs as system requirements

HSI requirements are not a separate category bolted on after technical
requirements are written. They emerge from understanding who the users are, what
tasks they perform, in what environment, and with what capabilities and
limitations.

**Practical steps for a VSE:**

1. **Identify user groups early.** Operators, maintainers, trainers, customers,
   the public. For each group, document relevant characteristics: cognitive
   load capacity, physical capabilities, experience level, environmental
   constraints.

2. **Define human activity and usage requirements.** These should be defined
   both longitudinally (along the lifecycle) and transversally (from subsystem
   to system of systems) at relevant levels of granularity.

3. **Develop human-in-the-loop measures of performance.** Requirements should
   specify not just what the system does, but how well the human-system
   combination performs the intended function.

4. **Include HSI in trade-off criteria.** When making requirements and design
   trade-offs, ensure that human impacts (safety, usability, training burden,
   error likelihood) are understood and considered within project
   decision-making.

5. **Address function allocation.** For each system function, decide whether it
   is best performed by human, machine, or a combination. Use the Fitts list
   (MABA-MABA) as a starting heuristic, then refine through prototyping and
   user feedback. Functions must be reallocated incrementally based on
   formative evaluations.

6. **Capture safety and health requirements explicitly.** Identify risks to
   successful delivery from the human element: human error, safety hazards,
   health hazards. Express these as verifiable requirements.

### Requirement types with HSI content

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

---

## HSI in Architecture

### How HSI influences architectural decisions

Architecture is not only about technical component breakdown. It must also
reflect how humans interact with, operate, and maintain the system.

**Key architectural considerations:**

1. **Function allocation drives architecture.** The decision to automate a
   function versus leaving it to a human operator directly shapes which
   components exist, how they communicate, and what interfaces are required.
   Architecture must accommodate the chosen human-machine task split.

2. **Interface design follows from human needs.** The architecture must provide
   the information channels, displays, controls, and feedback mechanisms that
   humans need for situation awareness. This includes functional, informational,
   cognitive, and physical interfaces identified during HFE analysis.

3. **Maintainability shapes physical architecture.** If a component requires
   human maintenance, the architecture must provide physical access, diagnostic
   interfaces, and clear labelling. The maintenance concept (who maintains,
   how often, what skills) constrains physical layout.

4. **Training infrastructure is architectural.** If the system requires
   operator training, the architecture may need to support simulation modes,
   practice environments, or embedded training capabilities.

5. **Safety constraints shape redundancy and isolation.** Where human safety
   is at risk, the architecture must include protective barriers, fail-safe
   modes, or redundant paths. The degree of safety criticality (determined
   through HSI safety analysis) drives architectural complexity.

6. **Environmental constraints shape packaging.** The physical environment
   (temperature, vibration, lighting) in which humans operate the system
   constrains enclosure design, display readability, control placement, and
   protective measures.

### The concept phase sets the HSI architecture baseline

During the concept phase, the following HSI activities directly inform
architecture:

- Identify user groups (operators, maintainers) and their characteristics.
- Understand user goals, needs, and organisational context.
- Extract baseline performance data and key learnings from similar systems.
- Define human factors requirements and performance measures using Virtual
  Human-Centred Design (VHCD) where feasible.
- Perform human-component cost analysis to inform option down-selection.

### The development phase refines HSI in architecture

- Conduct task analysis, modelling, and iterative human-in-the-loop evaluation.
- Perform complexity and activity analysis to validate function allocation.
- Identify and mitigate human-related risks.
- Apply human and organisational factors analysis to design decisions.
- Optimise future working processes and practices.
- Progress toward tangibility (physical and cognitive) of the design.

---

## Lightweight HSI for VSEs

A VSE (fewer than 25 people) will not have a dedicated HSI team, formal HITL
simulation facilities, or the budget for full-scale human factors evaluation
programmes. The following guidance scales the primer's 13 perspectives down to
what a small team can realistically do.

### Tier 1: Always do (every VSE project with human users)

These perspectives apply to virtually all systems that humans interact with.

1. **Human Factors Engineering (lightweight).**
   - Identify who the users are and what tasks they perform.
   - For each human-system interface, ask: what information does the user
     need, what actions can they take, what errors are likely?
   - Use low-fidelity prototypes (paper, wireframes, 3D-printed mockups) for
     early feedback. This replaces formal HITL simulation.
   - Conduct at least one round of formative usability evaluation with real
     or representative users before design freeze.

2. **Safety.**
   - Perform a lightweight hazard analysis for human-related risks.
   - For each identified hazard: what is the consequence, what is the
     likelihood, what design feature mitigates it?
   - Document safety requirements as verifiable statements.
   - This is mandatory for any system where human error could cause injury,
     property damage, or data loss.

3. **Usability.**
   - Set explicit usability targets (task completion rate, error rate, time
     on task, subjective satisfaction).
   - Test with representative users. Even 3 to 5 users reveal most usability
     problems.
   - Iterate the design based on findings.

4. **Function allocation.**
   - For each system function, explicitly decide: human, automated, or
     shared. Document the rationale.
   - Revisit allocation after prototyping and user feedback.

### Tier 2: Do when relevant (depends on system type)

5. **Training.**
   - If the system requires users to learn new skills, define what training
     is needed and how it will be delivered.
   - Consider embedded help, progressive disclosure, or job aids as
     low-cost alternatives to formal training programmes.

6. **Maintenance and ILS (lightweight).**
   - If the system requires physical maintenance, ensure the design supports
     it: access panels, diagnostic indicators, clear labelling.
   - Document maintenance procedures, required tools, and skill levels.

7. **Occupational health.**
   - If the system exposes humans to physical hazards (noise, vibration,
     chemicals, repetitive motion), identify and mitigate.
   - Most relevant for hardware-intensive systems, manufacturing equipment,
     or systems used in harsh environments.

8. **Environmental factors.**
   - If the system operates in a challenging environment (outdoor, industrial,
     mobile), specify environmental constraints and their effect on human
     performance (display readability in sunlight, control operation with
     gloves, noise interference with communication).

### Tier 3: Consider if resources allow

9. **Workforce planning.** Relevant if the system requires specific staffing
   levels for operation or support. For most VSE products, this reduces to
   documenting the assumed operator profile.

10. **Competences and personnel.** Relevant if the system requires specialised
    skills. Document the assumed skill level of the target user.

11. **Social, cultural, and organisational factors.** Relevant for systems
    deployed in diverse cultural contexts or that change organisational
    workflows. A VSE should at minimum note any known cultural or
    organisational assumptions baked into the design.

12. **Habitability.** Relevant only for systems that define living or working
    spaces (vehicles, workstations, control rooms).

13. **Comfort and UX.** Beyond basic usability, consider subjective experience
    only when the product competes on user experience or when user adoption
    is a risk.

### VSE HSI process integration

Rather than running HSI as a separate workstream, a VSE should embed HSI
thinking into existing SE activities:

| SE activity (ISO 29110) | HSI action |
|---|---|
| Stakeholder requirements | Identify user groups. Capture HSI needs. Specify usability targets. |
| System requirements | Include function allocation, safety, and human performance requirements. |
| Architecture design | Ensure interfaces support human needs. Apply maintainability constraints. |
| Detailed design | Prototype human-facing interfaces. Conduct formative usability evaluation. |
| Integration and verification | Verify HSI requirements (usability tests, safety checks). |
| Validation | Validate that the system meets user needs in operational context. |
| Operations and support | Collect user feedback. Monitor safety incidents. Update training. |

### HSI activities across lifecycle phases (from primer Figure 3)

**Concept phase:**
- Identify user groups (operators, maintainers).
- Understand user characteristics, goals, needs, organisational context.
- Extract baseline performance and key learnings from similar systems.
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

### Key HSI principle for VSEs

The final objective of HSI is to design and operate systems that allow humans
to be humans. Every project should follow this guiding principle. The role of
HSI, even in a small team without dedicated specialists, is to ensure this
principle is not lost in the pressure of technical delivery.

A VSE achieves this by asking, at every design decision: "How does this affect
the person who will use, operate, maintain, or be affected by this system?"
