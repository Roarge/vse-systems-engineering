---
title: "Requirements Elicitation Techniques and Writing Rules"
slug: requirements-elicitation-and-writing
type: process
layer: needs-and-reqs
tags: [elicitation, writing-rules, smart, defects, tolerances, verification-methods]
sources:
  - citation: "INCOSE (2022). Guide for Writing Requirements, v1.0. Sections on elicitation and writing, Appendices C and D."
    raw: INCOSE_NeedsAndReqs_v1.pdf
related:
  - needs-vs-requirements
  - requirements-traceability-and-attributes
  - sysml2-syntax-requirements-and-cases
  - sysml2-requirements-semantics
  - sysml2-cases-overview
  - sysml2-case-kinds
  - vv-methods
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [needs-and-requirements]
---

# Requirements Elicitation Techniques and Writing Rules

For the underlying core distinction, see
[[needs-vs-requirements]]. For traceability, attributes, and
the AMBSE model-based requirements view, see
[[requirements-traceability-and-attributes]].

## Elicitation techniques

The Guide describes eight techniques. For VSE contexts,
prioritise those marked with an asterisk.

- **Brainstorming\\***. Generate needs rapidly without
  filtering. A single SE can run this with 2 to 5 stakeholders
  in 30 to 60 minutes. Record all ideas, then cluster and
  prioritise. Effective for early-phase exploration.
- **Interviews\\***. One-on-one structured conversations with
  key stakeholders. Prepare questions in advance using the
  elicitation checklist (below). Most practical technique for a
  VSE where stakeholders are few and accessible.
- **Document/feedback analysis\\***. Review existing
  documentation: previous project reports, user manuals,
  complaint logs, regulations, standards, competitor products.
  Essential when the SOI replaces or extends an existing
  system. Low effort, high yield.
- **Interface analysis\\***. Identify all external systems,
  users, and environments the SOI must interact with. For each
  interface, capture what crosses the boundary (data, energy,
  material) and any constraints. Critical for embedded systems.
- **Observation/contextual inquiry**. Watch users perform tasks
  in their actual environment. Reveals tacit needs that
  stakeholders cannot articulate. Time-intensive but valuable
  for human-machine interaction design.
- **Prototyping**. Build low-fidelity models (paper, digital
  mockups, 3D prints) to elicit feedback. Effective when
  stakeholders struggle to express needs abstractly. Can be
  combined with interviews.
- **Workshop/focus group**. Facilitated group session with
  multiple stakeholders. More resource-intensive than
  interviews. Use when stakeholder conflicts must be surfaced
  and resolved. For a VSE, a focused 2-hour session with 3 to
  6 participants is practical.
- **Survey/questionnaire**. Useful when stakeholders are
  numerous or geographically dispersed. Less interactive than
  interviews. Best for validating needs already identified by
  other methods.

### Use case driven elicitation (SysML 2.0)

In an AMBSE workflow, use cases provide an additional
elicitation technique that complements the eight above. Each
use case captures a coherent set of actor-system interactions
that deliver value to a stakeholder. Scenarios within use cases
(normal flow, alternate flows, exception flows) systematically
generate stakeholder needs by examining each step where the
system must respond. See [[sysml2-cases-overview]] for the
case family and [[sysml2-case-kinds]] for use-case syntax.

## Elicitation question checklist (Appendix C)

Ask these questions during needs elicitation to ensure
completeness:

- What is the problem, threat, or opportunity that creates the
  need for the SOI?
- What mission, goals, and objectives (MGOs) must the SOI
  support?
- What does success look like for each stakeholder?
- What are the operational scenarios or use cases?
- What external systems must the SOI interface with?
- What environmental conditions must the SOI operate in
  (temperature, vibration, humidity, electromagnetic)?
- What are the lifecycle considerations (manufacturing,
  transport, storage, maintenance, disposal)?
- What regulations, standards, or certifications apply?
- What are the constraints (budget, schedule, technology,
  legacy compatibility)?
- What risks or failure modes are unacceptable?
- What trade-offs between cost, performance, and schedule are
  acceptable?

## Writing good requirements: characteristics

A well-written requirement exhibits these characteristics:

| ID | Characteristic | Test |
|---|---|---|
| C1 | Necessary | Would removing it leave a gap in the SOI capability? |
| C3 | Singular | Does it address exactly one thing? |
| C4 | Complete | Is the statement self-contained with all conditions and constraints? |
| C5 | Achievable | Can it be realised within known constraints? |
| C6 | Feasible | Can it be implemented with available technology and resources? |
| C7 | Verifiable | Can compliance be demonstrated through test, analysis, inspection, or demonstration? |
| C8 | Correct | Does it accurately represent the stakeholder need? |
| C9 | Conforming | Does it follow the agreed template and style rules? |

For a **set** of requirements, additionally check:

| ID | Characteristic | Test |
|---|---|---|
| C10 | Complete set | Are there gaps in coverage of the needs? |
| C11 | Consistent | Are there contradictions between requirements? |
| C12 | Feasible set | Can all requirements be satisfied simultaneously? |
| C13 | Comprehensible | Can the intended audience understand them? |
| C14 | Able to be validated | Can the set be shown to satisfy the stakeholder needs? |

## Common defects to avoid

- **Ambiguity.** Words like "fast", "easy", "sufficient",
  "adequate", "user-friendly" without quantification.
- **Compound statements.** Using "and" or "or" to combine
  multiple requirements in one statement. Split them.
- **Implementation bias.** Specifying the solution ("use a
  database") instead of the need ("store and retrieve
  records").
- **Untestable statements.** Requirements that cannot be
  verified by any method.
- **Missing tolerances.** Numeric values without acceptable
  ranges or precision.
- **Passive voice without agent.** "The data shall be
  transmitted" (by what?). Use active constructs identifying
  the SOI element.
- **Escape words.** "Should", "may", "might", "can" weaken
  obligation. Use "shall" for mandatory requirements.

## Tolerances and precision

Every numeric requirement must specify:

- The nominal value.
- The tolerance or acceptable range (e.g., "plus or minus 2%").
- The conditions under which the value applies (e.g., "at 25
  degrees C ambient").
- The measurement method or reference standard where
  applicable.

Distinguish accuracy (closeness to true value) from precision
(repeatability of measurement).

## Verification methods

Four standard methods exist for verifying requirements:

| Method | Description | When to use |
|---|---|---|
| **Test** | Exercise the SOI under controlled conditions and measure results | Quantitative performance requirements |
| **Analysis** | Use mathematical models, simulations, or calculations | When testing is impractical or too costly |
| **Inspection** | Visual or dimensional examination of the SOI | Physical characteristics, labelling, workmanship |
| **Demonstration** | Operate the SOI to show functional performance without formal measurement | Functional requirements where pass/fail is sufficient |

For a VSE, plan the verification method when writing each
requirement. Record the planned method as a requirement
attribute. This avoids discovering late in the project that a
requirement cannot be verified. For the V&V planning that
turns this attribute into a VCRM, see [[vv-methods]].

## Requirement verification checklist (Appendix D3)

For each requirement, verify that it:

1. Is necessary (C1): removal would leave a capability gap.
2. Is singular (C3): addresses exactly one condition or
   capability.
3. Is complete (C4): contains all needed information, no TBDs
   remain.
4. Is achievable (C5): can be met within project constraints.
5. Is feasible (C6): technology and resources exist.
6. Is verifiable (C7): a verification method can be identified.
7. Is correct (C8): accurately represents the intended need.
8. Conforms to standards (C9): follows agreed template and
   rules.

## Requirement validation checklist (Appendix D4)

For each requirement, validate that it:

1. Traces to at least one stakeholder need.
2. Correctly transforms the intent of the source need.
3. Does not introduce unintended scope beyond the source need.
4. Is consistent with all other requirements in the set.
5. Contributes to at least one MGO.
6. Has an identified stakeholder who can confirm its
   correctness.

## See also

- [[needs-vs-requirements]] for the core distinction and the
  Function/Fit/Form/Quality/Compliance categorisation.
- [[requirements-traceability-and-attributes]] for trace
  links, attributes, TBX management, and the AMBSE model-based
  view.
- [[sysml2-syntax-requirements-and-cases]] for the SysML 2.0
  syntax that operationalises these rules.
- [[sysml2-requirements-semantics]] for the
  assume/require/satisfy/verify semantics.
- [[vv-methods]] for the VCRM-driven planning that consumes the
  verification-method attribute.
