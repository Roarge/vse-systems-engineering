# Needs and Requirements Guide (VSE-Scaled)

## Source

INCOSE-TP-2021-003-01, Guide for Writing Requirements (Needs and Requirements), Version 1.0, May 2022. Scaled for Very Small Entities (VSEs) per ISO/IEC 29110.

## Core Distinction: Needs vs Requirements

A **need** expresses what stakeholders expect from the System of Interest (SOI). A **requirement** expresses what the SOI must do or be to satisfy those needs. Needs are stakeholder-perspective statements; requirements are SOI-perspective statements.

- Need statement form: "The stakeholders need the system to [verb phrase]."
- Requirement statement form: "The [System] shall [verb phrase]."

Needs exist at the problem/solution boundary. Requirements exist within the solution space. Every requirement must trace to at least one need. A single need may generate multiple requirements.

## Stakeholder Identification

For a VSE, stakeholder identification must be thorough but lightweight. Use these guiding questions to ensure coverage:

| Question | Typical Stakeholder |
|----------|-------------------|
| Who pays for the SOI? | Customer, Sponsor |
| Who profits from the SOI? | Owner, Operator |
| Who produces the SOI? | Developer, Manufacturer |
| Who tests or verifies the SOI? | Tester, V&V team |
| Who uses the SOI? | End user, Operator |
| Who maintains the SOI? | Maintainer, Support |
| Who regulates the SOI? | Regulatory body, Certifier |
| Who is affected by the SOI without using it? | Neighbours, Public |
| Who disposes of the SOI? | Disposal authority |
| Who trains users of the SOI? | Trainer |

Classify each stakeholder as **V** (Vested, direct authority), **I** (Influence, can affect decisions), or **P** (Participate, provides input). For a VSE, a simple register with columns (Stakeholder, Internal/External, VIP Classification, Desired Outcome) is sufficient.

## Needs Elicitation Techniques

The guide describes eight techniques. For VSE contexts, prioritise those marked with an asterisk.

**Brainstorming\\*.** Generate needs rapidly without filtering. A single SE can run this with 2 to 5 stakeholders in 30 to 60 minutes. Record all ideas, then cluster and prioritise. Effective for early-phase exploration.

**Interviews\\*.** One-on-one structured conversations with key stakeholders. Prepare questions in advance using the elicitation checklist (see below). Most practical technique for a VSE where stakeholders are few and accessible.

**Document/Feedback Analysis\\*.** Review existing documentation: previous project reports, user manuals, complaint logs, regulations, standards, competitor products. Essential when the SOI replaces or extends an existing system. Low effort, high yield.

**Interface Analysis\\*.** Identify all external systems, users, and environments the SOI must interact with. For each interface, capture what crosses the boundary (data, energy, material) and any constraints. Critical for embedded systems.

**Observation/Contextual Inquiry.** Watch users perform tasks in their actual environment. Reveals tacit needs that stakeholders cannot articulate. Time-intensive but valuable for human-machine interaction design.

**Prototyping.** Build low-fidelity models (paper, digital mockups, 3D prints) to elicit feedback. Effective when stakeholders struggle to express needs abstractly. Can be combined with interviews.

**Workshop/Focus Group.** Facilitated group session with multiple stakeholders. More resource-intensive than interviews. Use when stakeholder conflicts must be surfaced and resolved. For a VSE, a focused 2-hour session with 3 to 6 participants is practical.

**Survey/Questionnaire.** Useful when stakeholders are numerous or geographically dispersed. Less interactive than interviews. Best for validating needs already identified by other methods.

### Elicitation Question Checklist (from Appendix C)

Ask these questions during needs elicitation to ensure completeness:

- What is the problem, threat, or opportunity that creates the need for the SOI?
- What mission, goals, and objectives (MGOs) must the SOI support?
- What does success look like for each stakeholder?
- What are the operational scenarios or use cases?
- What external systems must the SOI interface with?
- What environmental conditions must the SOI operate in (temperature, vibration, humidity, electromagnetic)?
- What are the lifecycle considerations (manufacturing, transport, storage, maintenance, disposal)?
- What regulations, standards, or certifications apply?
- What are the constraints (budget, schedule, technology, legacy compatibility)?
- What risks or failure modes are unacceptable?
- What trade-offs between cost, performance, and schedule are acceptable?

## Organising Needs

Group identified needs into five categories:

| Category | Description | Example |
|----------|-------------|---------|
| **Function** | What the SOI must do (actions, behaviours, transformations) | "Measure temperature every 5 seconds" |
| **Fit** | How the SOI fits its operational context (interfaces, environment, users) | "Operate in ambient temperatures from -20 to +55 degrees C" |
| **Form** | Physical characteristics (size, weight, shape, colour, materials) | "Weigh no more than 500 g" |
| **Quality** | Non-functional attributes (reliability, availability, safety, security, usability) | "Mean time between failures exceeding 10 000 hours" |
| **Compliance** | Regulatory, legal, and standards obligations | "Comply with IEC 61508 SIL 2" |

## Requirement Types

Requirements derived from needs fall into corresponding types:

**Functional/Performance requirements** specify what the SOI must do and how well. Always include measurable performance criteria. Example: "The system shall measure temperature with an accuracy of plus or minus 0.5 degrees C."

**Fit/Operational requirements** specify how the SOI integrates with its operational environment, including interfaces, human factors, and deployment conditions.

**Form requirements** specify physical attributes. Use these sparingly as they constrain design freedom. Prefer performance-based requirements where possible.

**Quality requirements** specify non-functional attributes: reliability (MTBF, failure rate), availability (uptime percentage), maintainability (MTTR), safety (SIL, ASIL), security (access control, encryption), and usability (task completion time, error rate).

**Compliance requirements** reference specific standards, regulations, or certifications the SOI must meet.

## Needs-to-Requirements Transformation

The transformation follows five steps:

1. **Analyse each need.** Determine whether the need is clear, singular, and testable. Split compound needs.
2. **Identify requirement type.** Map the need to one or more requirement types (functional, fit, form, quality, compliance).
3. **Derive requirement statements.** Rewrite each need as a "shall" statement from the SOI perspective. Add measurable criteria, tolerances, and conditions.
4. **Allocate requirements.** Assign each requirement to a system element (subsystem, component) in the System Breakdown Structure.
5. **Establish traceability.** Link each requirement back to its source need(s) and forward to design elements and verification activities.

The transformation matrix (one row per need, columns for derived requirements) provides a lightweight tool for a VSE to track this mapping without specialised tooling.

## Writing Good Requirements

A well-written requirement exhibits these characteristics (from the Guide to Writing Requirements):

| ID | Characteristic | Test |
|----|---------------|------|
| C1 | Necessary | Would removing it leave a gap in the SOI capability? |
| C3 | Singular | Does it address exactly one thing? |
| C4 | Complete | Is the statement self-contained with all conditions and constraints? |
| C5 | Achievable | Can it be realised within known constraints? |
| C6 | Feasible | Can it be implemented with available technology and resources? |
| C7 | Verifiable | Can compliance be demonstrated through test, analysis, inspection, or demonstration? |
| C8 | Correct | Does it accurately represent the stakeholder need? |
| C9 | Conforming | Does it follow the agreed template and style rules? |

For a set of requirements, additionally check:

| ID | Characteristic | Test |
|----|---------------|------|
| C10 | Complete set | Are there gaps in coverage of the needs? |
| C11 | Consistent | Are there contradictions between requirements? |
| C12 | Feasible set | Can all requirements be satisfied simultaneously? |
| C13 | Comprehensible | Can the intended audience understand them? |
| C14 | Able to be validated | Can the set be shown to satisfy the stakeholder needs? |

### Common Defects to Avoid

- **Ambiguity.** Words like "fast," "easy," "sufficient," "adequate," "user-friendly" without quantification.
- **Compound statements.** Using "and" or "or" to combine multiple requirements in one statement. Split them.
- **Implementation bias.** Specifying the solution ("use a database") instead of the need ("store and retrieve records").
- **Untestable statements.** Requirements that cannot be verified by any method.
- **Missing tolerances.** Numeric values without acceptable ranges or precision.
- **Passive voice without agent.** "The data shall be transmitted" (by what?). Use active constructs identifying the SOI element.
- **Escape words.** "Should," "may," "might," "can" weaken obligation. Use "shall" for mandatory requirements.

### Tolerances and Precision

Every numeric requirement must specify:
- The nominal value
- The tolerance or acceptable range (e.g., "plus or minus 2%")
- The conditions under which the value applies (e.g., "at 25 degrees C ambient")
- The measurement method or reference standard where applicable

Distinguish accuracy (closeness to true value) from precision (repeatability of measurement).

## Verification Methods

Four standard methods exist for verifying requirements:

| Method | Description | When to Use |
|--------|-------------|-------------|
| **Test** | Exercise the SOI under controlled conditions and measure results | Quantitative performance requirements |
| **Analysis** | Use mathematical models, simulations, or calculations | When testing is impractical or too costly |
| **Inspection** | Visual or dimensional examination of the SOI | Physical characteristics, labelling, workmanship |
| **Demonstration** | Operate the SOI to show functional performance without formal measurement | Functional requirements where pass/fail is sufficient |

For a VSE, plan the verification method when writing each requirement. Record the planned method as a requirement attribute. This avoids discovering late in the project that a requirement cannot be verified.

### Requirement Verification Checklist (from Appendix D3)

For each requirement, verify that it:

1. Is necessary (C1): removal would leave a capability gap
2. Is singular (C3): addresses exactly one condition or capability
3. Is complete (C4): contains all needed information, no TBDs remain
4. Is achievable (C5): can be met within project constraints
5. Is feasible (C6): technology and resources exist
6. Is verifiable (C7): a verification method can be identified
7. Is correct (C8): accurately represents the intended need
8. Conforms to standards (C9): follows agreed template and rules

### Requirement Validation Checklist (from Appendix D4)

For each requirement, validate that it:

1. Traces to at least one stakeholder need
2. Correctly transforms the intent of the source need
3. Does not introduce unintended scope beyond the source need
4. Is consistent with all other requirements in the set
5. Contributes to at least one MGO
6. Has an identified stakeholder who can confirm its correctness

## Traceability

Traceability links provide the evidence chain from stakeholder needs through requirements to design, verification, and validation. The guide identifies ten traceability types:

| Type | Links |
|------|-------|
| Source | Requirement to its origin (stakeholder, regulation, standard) |
| Parent/Child | Higher-level requirement to derived lower-level requirements |
| Allocation | Requirement to the system element responsible for satisfying it |
| Peer | Requirement to related requirements at the same level |
| Interface | Requirement to the interface definition it constrains |
| Dependency | Requirement to other requirements it depends on |
| Design | Requirement to the design element that implements it |
| Verification | Requirement to the verification activity that confirms compliance |
| Validation | Need to the validation activity that confirms stakeholder satisfaction |
| Model entity | Requirement to the model element that represents it (e.g., SysML block) |

For a VSE, maintain at minimum: Source, Parent/Child, Allocation, and Verification traceability. A spreadsheet-based trace matrix is acceptable for projects with fewer than 200 requirements.

## Requirement Attributes

Each requirement should carry metadata attributes. For a VSE, the following subset (from NRM Table 11) is recommended:

| Attribute | Purpose |
|-----------|---------|
| Unique ID | Unambiguous identification (e.g., REQ-SEN-001) |
| Statement | The "shall" text |
| Rationale | Why this requirement exists |
| Source | Origin (stakeholder, standard, derived) |
| Priority | Must-have, Should-have, Nice-to-have (MoSCoW or similar) |
| Status | Draft, Approved, Verified, Validated |
| Verification method | Test, Analysis, Inspection, or Demonstration |
| Allocation | System element responsible |
| Parent need | Link to the need this requirement satisfies |
| TBX flag | TBD, TBR, TBS, or TBC if any value is not yet finalised |

## TBX Management

Unresolved items in requirements must be tracked and resolved before design proceeds:

- **TBD (To Be Determined).** The value or information is not yet known. Requires investigation or stakeholder input.
- **TBR (To Be Resolved).** A conflict or ambiguity exists that must be resolved through negotiation or analysis.
- **TBS (To Be Specified).** The requirement exists but its detailed specification is deferred to a later phase.
- **TBC (To Be Computed).** The value requires calculation, simulation, or modelling to establish.

Maintain a TBX register with columns: ID, TBX Type, Description, Owner, Due Date, Status. For a VSE, resolve all TBDs and TBRs before the System Requirements Review (SRR) milestone. TBS and TBC items may carry forward with a resolution plan.

## Model-Based Requirements (AMBSE)

When using agile model-based SE, requirements exist as model elements within the
SysML v2 repository alongside the behavioural and structural models that specify
the system. This dual representation (text + model) combines the expressiveness of
natural language with the precision of formal models.

### Use case driven elicitation

Use cases provide an additional elicitation technique that complements the eight
techniques above. Each use case captures a coherent set of actor-system interactions
that deliver value to a stakeholder. Scenarios within use cases (normal flow,
alternate flows, exception flows) systematically generate stakeholder needs by
examining each step where the system must respond.

For the complete use case driven workflow, the three approaches to use case analysis
(flow-based, scenario-based, state-based), and SysML v2 requirements modelling
patterns, see `knowledge/ambse-requirements.md`.

### Models as the primary medium

In AMBSE, the model is the primary work product. Textual requirements are linked
to (not separate from) model elements. This enables nanocycle verification (20 to
60 minutes): validate syntax, check traceability, review with a colleague, and
repeat. See `knowledge/ambse-agile-process.md` Section 3 for verification
timeframes.

---

## VSE Practical Guidance

For a VSE applying this guide:

1. **Start with stakeholder interviews.** Two to three focused interviews with key stakeholders (customer, user, regulator) will capture 80% of needs.
2. **Use the five-category framework** (Function, Fit, Form, Quality, Compliance) to check for gaps in your needs set.
3. **Write requirements early and iterate.** Do not wait for a perfect needs set. Transform needs to requirements progressively as understanding deepens.
4. **Plan verification when writing.** Assign a verification method to each requirement immediately. If you cannot identify a method, the requirement is not verifiable and must be rewritten.
5. **Keep traceability simple.** A single spreadsheet with columns for Need ID, Need Text, Requirement ID, Requirement Text, Allocation, and Verification Method provides sufficient traceability for most VSE projects.
6. **Manage scope actively.** Every new requirement after baseline requires a change request assessing impact on cost, schedule, and risk. This discipline prevents scope creep even in informal VSE environments.
7. **Review requirements with stakeholders.** Even a brief 30-minute walkthrough of requirements with the customer catches misunderstandings early. Use the verification checklist (D3) as a structured review guide.
