# INCOSE Best Practices Scaled for VSE Systems Engineering

Sources: INCOSE Systems Engineering Handbook 4e (2015), Galinier et al.
"Systems Engineering Practices for Small and Medium Enterprises"
(INCOSE-TP-2021-005-01). Filtered for organisations with fewer than 25 people.

---

## 1 SE Lifecycle Models

### Lifecycle stages (ISO/IEC/IEEE 15288)

Six generic stages apply regardless of organisation size: Concept, Development,
Production, Utilisation, Support, Retirement. A VSE rarely executes all six in
a single project. Typical VSE scope covers Concept through Development, with
Production and Support handled operationally.

### Lifecycle approaches

| Approach | VSE fit | When to choose |
|----------|---------|----------------|
| Vee model | High | Well-understood requirements, hardware-dominant systems |
| Incremental | High | Reduce risk by delivering capability in planned increments |
| Iterative | High | Requirements evolve, software-intensive systems |
| Spiral (ICSM) | Medium | High technical risk, novel technology (TRL below 6) |
| Agile SE | Medium | Software-intensive, stakeholders available for frequent feedback |
| Hybrid (agile MBSE) | High | Mixed hardware/software, model-based specification with iterative delivery |

The **hybrid lifecycle** (Douglass, 2016) combines V-model rigour with agile iteration.
Three overlapping cycles run in pipeline: system specification (SR.2-SR.3),
downstream engineering (SR.4), and system verification (SR.5). System engineers
specify iteration N+1 while downstream engineers implement N and testers verify
N-1. For a one-person VSE, the same person cycles through roles at iteration
boundaries. This approach is recommended when the project benefits from model-based
SE and incremental delivery. See `knowledge/ambse-agile-process.md` for details.

### Iteration planning as a complement to milestone planning

When using the hybrid lifecycle, iteration planning complements traditional
milestone-based gates. The project backlog (prioritised work items) is allocated to
iterations, each with a mission statement. Backlog management, velocity tracking,
and iteration retrospectives provide ongoing feedback that traditional gate reviews
alone cannot. See `knowledge/ambse-agile-process.md` Sections 4-8 for the
complete iteration planning framework.

A VSE should select its lifecycle early and record the choice in the SEMP. The
Vee model remains the default for hardware-dominant systems because it maps
directly to the decision gates below.

### Decision gates

Standard gate sequence: MCR (Mission Concept Review), SRR (System Requirements
Review), PDR (Preliminary Design Review), CDR (Critical Design Review), TRR
(Test Readiness Review). Each gate has defined entry and exit criteria. A VSE
may merge MCR and SRR into a single milestone when the concept phase is brief.

Gate principle: never proceed to the next stage until the current stage outputs
are verified and baselined. Cost of defect correction grows up to 100 times
from definition to operation phase (Galinier et al., citing NASA data).

### Cost commitment rule

At the end of the design phase, only 15 percent of the budget has been spent,
yet 85 percent of total lifecycle cost is already committed by the design
decisions made. This makes upstream SE investment critical for VSEs with tight
budgets.

---

## 2 Stakeholder Needs Definition

### Purpose

Transform stakeholder concerns into a structured set of stakeholder
requirements that can be validated. The output is the Stakeholder Requirements
Specification (StRS).

### Activities

1. Identify stakeholders and their concerns across the full lifecycle
   (acquirer, users, maintainers, regulators, disposal authorities).
2. Elicit needs through interviews, workshops, observation, and operational
   scenario analysis.
3. Define operational scenarios (CONOPS) describing system behaviour in its
   intended environment. Use exchange sequences showing actors, system
   services, and environmental hypotheses.
4. Analyse and reconcile conflicting needs. Prioritise using MoSCoW or similar
   scheme.
5. Express needs as stakeholder requirements in the StRS. Each requirement must
   be traceable to its source stakeholder and concern.

### VSE guidance

In a VSE the acquirer and end users are often the same person. Do not skip
stakeholder analysis. Identify at least: the paying customer, the end user (if
different), the maintainer, and any regulatory body. Even a two-person project
benefits from writing down operational scenarios before jumping to requirements.

---

## 3 Requirements Engineering

### Transformation chain

Stakeholder needs (StRS) are transformed into system requirements (SyRS), which
are then allocated to system element requirements. Each transformation must
maintain bidirectional traceability.

### Individual requirement quality (INCOSE)

Every requirement shall be: necessary, implementation-independent, unambiguous,
complete, singular (one thought per requirement), achievable, verifiable, and
conforming to an agreed style. The MUST mnemonic (Measurable, Useful, Simple,
Traceable) provides a quick check during reviews.

### Set-of-requirements quality

The complete SyRS shall be: complete (no missing requirements), consistent (no
contradictions), feasible within budget and schedule, and bounded (clear system
boundary separating what is inside from what is outside).

### Requirement attributes

Each requirement must carry: unique identifier, trace to parent requirement,
trace to source stakeholder, priority (essential, desirable, optional),
verification method (inspection, analysis, demonstration, test), rationale, and
owner. In a VSE, maintain these attributes in a simple traceability matrix
(spreadsheet or lightweight tool) rather than a full PLM system.

### Requirements volatility

Track the number of new, modified, and cancelled requirements over time. Rising
volatility after the planned specification freeze signals risk of cost and
schedule overrun. Use the volatility indicator to decide when to hold the
specification review.

---

## 4 Architecture Definition

### Architecture versus design

Architecture defines "what" the system does and how it is organised (abstract,
conceptualisation-oriented). Design defines "how" each element is built
(technology-oriented, implementation-specific). Maintain this separation to
avoid premature commitment to implementation details.

### Logical architecture models

- **Functional model**: captures system functions and their functional interfaces.
- **Behavioural model**: captures dynamic behaviour (state machines, activity
  flows, sequence diagrams).
- **Temporal model**: captures timing constraints and sequencing between
  functions.

### Physical architecture models

- **Structural model**: captures system elements and their physical interfaces.
- **Layout model**: captures spatial placement and physical packaging.

### Architecture process (scaled for VSE)

1. Define architecture drivers and viewpoints relevant to stakeholders.
2. Build candidate functional architectures. Use Functional Flow Block
   Diagrams (FFBDs) or SysML activity diagrams.
3. Analyse functional interfaces using N-squared (coupling) matrices. Minimise
   cross-boundary interfaces to reduce integration risk.
4. Allocate logical functions to physical elements. Record the allocation in a
   traceability matrix.
5. Evaluate candidates against selection criteria (cost, risk, performance,
   reuse potential). Document the trade-off rationale in a Justification
   Document.
6. Select and baseline the architecture at PDR.

### Emergent properties

Properties that arise from the interaction of system elements (reliability,
performance, safety) and cannot be attributed to any single element. A VSE must
explicitly identify and verify emergent properties, as they are the most common
source of integration surprises.

### Interface management

"The devil is in the interfaces" (Galinier et al.). Interface errors detected
late in IVV can consume up to 50 percent of total project effort in rework.
Define interfaces early using three categories: physical connections, energy
flows, and information flows. Use N-squared charts or Design Structure Matrices
(DSM) to visualise and optimise interface complexity.

---

## 5 Verification and Validation

### Definitions

- **Verification**: confirms the product is built right (design satisfies
  requirements). Answers: "Did we build it correctly?"
- **Validation**: confirms the right product is built (system satisfies
  stakeholder needs). Answers: "Did we build the right thing?"

### Verification techniques

| Technique | Description | VSE applicability |
|-----------|-------------|-------------------|
| Inspection | Visual examination of product or documentation | High, low cost |
| Analysis | Mathematical or analytical assessment | High for performance |
| Demonstration | Functional operation without measurement | Medium |
| Test | Operation with data collection and measurement | High, primary method |
| Simulation | Use of models to verify behaviour | Medium, when physical test is costly |
| Sampling | Statistical verification of production items | Low for VSE (small batches) |

### Vee model verification strategy

Verification proceeds level by level up the right-hand side of the Vee. Each
level verifies against the corresponding left-hand specification:
- Component verification against component specifications
- Subsystem verification against subsystem requirements
- System verification against SyRS
- System validation against StRS and operational scenarios

### Two nested loops (Galinier et al.)

The inner loop is verification (requirements to design to build, then verify
back against requirements). The outer loop is validation (stakeholder needs to
system requirements to validated system, then validate back against needs).
Both loops must close before delivery.

### Integration approaches for VSEs

| Approach | Description | Risk level |
|----------|-------------|------------|
| Bottom-up | Integrate lowest elements first, build upward | Low risk, recommended for VSE |
| Incremental | Add one element at a time, test after each | Low risk, excellent fault isolation |
| Big-bang | Integrate everything at once | High risk, poor fault isolation, avoid |
| Top-down | Start with top-level skeleton, add elements | Medium, requires stubs |

### SE ROI in IVV

Optimum SE effort is 14.4 percent of programme cost (Honour study, 51 projects,
16 organisations). When starting from zero SE, the return on investment is
approximately 7:1. A common benefit is reduction of IVV rework from 50 percent
to 30 percent of project cost.

---

## 6 Configuration Management

### Purpose

Manage and control system elements and their configurations across the
lifecycle so that the integrity of the product baseline is maintained at all
times.

### Three baselines

| Baseline | Established at | Contains |
|----------|---------------|----------|
| Functional baseline | SRR | Validated stakeholder and system requirements |
| Allocated baseline | PDR/CDR | Architecture, allocated requirements, interface specs |
| Product baseline | TRR/delivery | Verified and validated system, test results, manuals |

### CM activities (scaled for VSE)

1. **Plan**: define the CM strategy in the SEMP. Identify what will be
   controlled, naming conventions, versioning scheme, and change authority.
2. **Identification**: assign unique identifiers to all configuration items
   (CIs). A CI is any artefact that must be managed independently (requirement
   spec, design document, source code module, test procedure, hardware
   drawing).
3. **Change control**: all changes to baselined CIs go through a formal change
   process. Use a Change Request (CR) form. In a VSE the Configuration Control
   Board (CCB) may be as small as the project manager and technical lead.
   Classify changes as Class I (major, affects form/fit/function, requires
   customer approval) or Class II (minor, internal approval sufficient).
4. **Status accounting**: maintain a log of all CIs, their current version, and
   the status of all CRs. A version-controlled repository (Git or equivalent)
   combined with a simple change log satisfies this requirement for most VSE
   projects.
5. **Configuration audit**: verify that the as-built product matches the
   as-designed documentation before delivery. Perform a functional
   configuration audit (does the product meet its requirements?) and a physical
   configuration audit (does the documentation match the product?).
6. **Release control**: control the packaging and delivery of baselined products
   to the acquirer.

### Risk management (companion process)

Four risk categories: technical, cost, schedule, programmatic. For each
identified risk, assign probability (0 to 1) and consequence, then calculate
criticality as probability times consequence. Treatment options: avoid, accept,
mitigate (control), or transfer. In a VSE, maintain a simple risk register
(spreadsheet) reviewed at each project meeting. Also track opportunities (reuse
of components, supplier cost reductions) that can offset risk costs.

---

## 7 Scaling Guidance for VSEs

### INCOSE Section 8.6 guidance

ISO/IEC 29110 defines four progressive profiles for VSEs. Each smaller profile
is a subset of the next larger one.

| Profile | Target | Scope |
|---------|--------|-------|
| Entry | Start-ups, projects under 6 person-months | Minimal PM and engineering discipline |
| Basic | Single project team, no special risk | PM + System Definition and Realisation (full) |
| Intermediate | Multiple concurrent projects | Adds acquisition management, business management |
| Advanced | Growing system development business | Adds system transition and disposal |

For non-critical systems, the Basic profile provides sufficient rigour. The
tailoring must be risk-driven: increase formality for safety-critical or
mission-critical systems regardless of organisation size.

### Maturity levels (Galinier et al.)

| Level | Characteristic | Key processes |
|-------|---------------|---------------|
| 1 | SE process not defined, hero culture, unpredictable | None formalised |
| 2 | Each project performs an SE process, structured, reactive | PM planning, PM monitoring, supplier management, requirements management, quality assurance, CM |
| 3 | SE processes are corporate-managed, proactive | Add: requirements engineering, architecture, IVV, risk management, interface management, measurement |
| 4 | Quantitative indicators drive SE processes, performance-driven | Add: quantitative process control via indicators |

Progress from level 1 to level 2 typically requires 10 to 18 months.
Improvement plans should target 2 to 3 action plans of 10 to 18 months each.
One improvement per project at a time to avoid overloading the team.

### Practical scaling rules for VSEs

- **Roles, not people**: in a VSE one person fills multiple roles (project
  manager and systems engineer, designer and developer). Document which person
  holds which role. The role separation remains important even when one person
  executes both.
- **Lightweight artefacts**: use spreadsheets for traceability matrices, risk
  registers, and CM logs. Upgrade to specialised tools only when project
  complexity demands it.
- **SEMP as the anchor**: the Systems Engineering Management Plan defines
  the lifecycle, processes, reviews, deliverables, and tools for the project.
  Reuse the SEMP across projects with domain-specific add-ons.
- **Process baseline with add-ons**: build a common SE process baseline for
  the organisation (based on ISO/IEC 29110), then add domain-specific
  customisations per business area. This reduces training overhead and enables
  staff mobility between projects.
- **MBSE readiness**: do not adopt MBSE without experienced coaching, an
  adapted tool, and stakeholder buy-in. The ROI of MBSE is primarily in
  upstream phases and reuse. Start with textual requirements and functional
  architecture diagrams before moving to full MBSE.
- **Agile integration**: agile approaches complement SE when the system is
  software-intensive, stakeholders are available for frequent validation, and
  development is model-driven. The key difference from agile software is that
  SE agility produces specifications, not executable increments. Use agile
  for the exploratory phase and harden into baselined specifications before
  hardware commitment.
- **Measure to improve**: track a small set of indicators (requirements
  volatility, IVV rework cost, cost-time variance, risk criticality trend).
  Indicators should arise naturally from project activities and not require
  additional overhead. The first indicator to set up is cost of defect
  correction measured in working time.

### Common VSE pitfalls

- Skipping stakeholder analysis because "we know the customer."
- Writing implementation-dependent requirements that constrain the solution
  space prematurely.
- Performing big-bang integration instead of incremental builds.
- Treating configuration management as optional until a defect is lost.
- Allowing excessive management margin to accumulate through the approval
  hierarchy, making proposals uncompetitive.
- Imposing too many process changes simultaneously. One improvement per project
  is the recommended pace.
