# Agile Model-Based Systems Engineering Process (VSE-Scaled)

Source: Douglass, B.P. (2016) *Agile Systems Engineering*, Elsevier, Chapters 1-2;
Douglass, B.P. (2021) *Agile MBSE Cookbook*, Packt, Chapter 1.
Methodology extracted and scaled for Very Small Entities. SysML v1 notation replaced
with SysML v2. Tool references (IBM Rhapsody) replaced with Sensmetry SySiDE.

---

## 1. Core Agile SE Principles

The fundamental distinction between systems engineering and software development
drives how agile methods apply:

> The outcome of systems engineering is **specification**.
> The outcome of software development is **implementation**.

This means SE work products are requirements, architecture, interfaces, trade studies,
and verification plans, not running code. Agile SE focuses on incrementally producing
and verifying these specification artefacts.

### Five principles for agile model-based SE

1. **Models are essential for agile SE.** Verifiable models are required because
   continuous verification is a core agile practice, and natural language specifications
   cannot be verified by testing or formal methods. Only high-precision models
   (expressible in SysML v2 textual notation) enable test-driven specification.
2. **Incremental development with continuous verification.** Develop a narrow slice
   of specification through all activities (requirements, architecture, V&V) before
   starting the next slice. Verify at every step, not at the end.
3. **Avoid big design up front, but do not skip design.** Develop and verify the
   specification work needed right now, and defer work that will not be needed until
   later. This reduces rework when requirements change.
4. **Work with stakeholders as active participants.** There is an "air gap" between
   what requirements say and what stakeholders actually need. Frequent
   demonstrations of the evolving specification (walkthroughs, model reviews) close
   this gap.
5. **Agile methods change the order, not the activities.** Traditional projects do
   integration and testing at the end. Agile methods mix these activities into the
   development work so that defects are avoided rather than discovered late.

### The modelling advantage for VSEs

MBSE provides benefits that are particularly valuable when a small team must manage
all SE activities:

- **Precision**: SysML v2 models are less ambiguous than natural language statements
- **Consistency**: traceability links within the model ensure data coherence across
  requirements, architecture, and V&V
- **Single source of truth**: one model repository eliminates the "dual maintenance"
  problem of keeping multiple documents synchronised
- **Early verification**: models can be verified as they are created, catching defects
  before they propagate downstream
- **Impact analysis**: when a requirement changes, trace links identify all affected
  architectural elements, interface specifications, and test cases

### Drawing is not modelling

A critical distinction: drawing diagrams in a presentation tool is not modelling. True
modelling means specifying deep semantics in a formal language (SysML v2) such
that the content can be verified through testing or formal analysis. Diagrams are views
of the model, not the model itself. The model lives in the repository (.sysml files
managed by SySiDE).

VSE guideline: every model element should have purpose, intent, scope, language,
accuracy, fidelity, and completeness appropriate to its role. Use a core subset of
SysML v2 (the 80/20 rule: 80% of work uses 20% of the language) and extend only
when necessary. See `knowledge/sysml2-quick-ref.md` for the recommended subset.

---

## 2. Three Lifecycle Models

SE projects can follow one of three lifecycle approaches, each applicable depending on
the nature of the system and the degree of requirements stability.

### 2.1 V-Model (breadth-first)

The traditional approach where each activity produces a complete work product before
the next activity begins. Each specification on the left side of the V has a corresponding
verification activity on the right side.

**VSE fit**: High for well-understood requirements and hardware-dominant systems.
Maps directly to ISO 29110 SR.1 through SR.6 as a single pass.

**Limitation**: Assumes infinite depth, breadth, and stability of knowledge when
plans are created. Defects are discovered late and are expensive to correct.

### 2.2 Incremental (depth-first, agile)

A narrow slice of functionality passes through all activities (requirements, architecture,
construction, verification) before the next slice begins. This is a "depth-first" approach
that takes coherent sets of requirements (use cases or user stories) one at a time.

**VSE fit**: High for software-intensive systems with available stakeholders.

**Assumptions**: (1) use cases implemented in one iteration are independent of those in
other iterations, (2) refactoring effort to accommodate new functionality is much less
than implementing it. The second assumption holds well for software but less so for
hardware with long lead times.

### 2.3 Hybrid (recommended for most VSE projects)

Three interconnected cycles with handoffs between them:

1. **System specification cycle**: Stakeholder requirements, system requirements,
   functional analysis, architectural design (SR.2, SR.3)
2. **Downstream engineering cycle**: Software, electronics, and mechanical
   development (SR.4)
3. **System verification cycle**: Integration, system verification, validation (SR.5)

The key innovation: these cycles **overlap in time**. System engineers work on iteration
N+1 while downstream engineers implement iteration N, and test engineers verify
iteration N-1. This maintains pipeline parallelism even for small teams.

**VSE adaptation**: In a one- or two-person team, the same person cycles through
specification, construction, and verification for each iteration. The hybrid model
still applies because the *work products* are organised by iteration, allowing
incremental baselining even when parallelism is not possible.

**Mapping to ISO 29110**: The hybrid lifecycle maps to ISO 29110 as multiple
sub-passes within SR.2 through SR.5, with each iteration producing a verified
increment. SR.1 (Initiation) and SR.6 (Delivery) remain single-pass.

---

## 3. Verification Timeframes

Continuous verification operates at three timeframes, each serving a different
quality assurance purpose. This replaces the traditional approach of verifying only
at the end of each phase.

### 3.1 Nanocycle (30 minutes to 1 day)

Model-level checks performed as engineering data is created:

- **Syntactic verification**: SySiDE editor validates .sysml file syntax in real time
- **Constraint checking**: verify that parametric constraints evaluate correctly
- **Trace completeness**: the `@traceability-guard` hook checks for missing links
- **Peer review**: brief model walkthrough with a colleague (or LLM review)
- **Unit model verification**: verify that a single model element (one requirement,
  one action, one part) is internally consistent

VSE plugin mapping: SySiDE validation on save, traceability-guard pre-commit hook.

### 3.2 Microcycle (1 to 4 weeks, one iteration)

Iteration-level verification performed at the end of each iteration:

- **Integration verification**: combine work from multiple model files and verify
  consistency across packages
- **Iteration acceptance**: verify that the iteration mission (use cases specified,
  defects repaired, risks reduced) has been achieved
- **Stakeholder review**: walkthrough of the iteration deliverables with stakeholders
- **Iteration retrospective**: assess metrics, update velocity, adjust the plan

VSE plugin mapping: phase gate checks, iteration retrospective prompt.

### 3.3 Macrocycle (project length)

System-level verification and validation performed at the end of the project:

- **System verification**: run all verification cases against the complete system
- **System validation**: demonstrate that the system meets stakeholder needs in its
  intended operational environment
- **Acceptance testing**: formal acceptance by the acquirer

VSE plugin mapping: SR.5 activities, PM.4 closure.

---

## 4. Iteration Planning for VSEs

### 4.1 Planning hierarchy

Agile planning uses a hierarchy of planning artefacts at different granularity levels:

| Artefact | Scope | Granularity | Updated |
|----------|-------|-------------|---------|
| Product roadmap | 12-24 months | Epics and releases | Each iteration |
| Release plan | 2-6 iterations | Use cases per release | Each iteration |
| Iteration plan | 1-4 weeks | User stories and scenarios | Start of iteration |

**Epic**: A coherent set of features, use cases, and user stories at a strategic level.
Epics typically require 2 to 6 iterations to complete. Business epics provide visible
stakeholder value. Technical (enabler) epics provide behind-the-scenes infrastructure.

**Use case**: A set of scenarios describing actor-system interactions. A use case
corresponds to a few to many scenarios, roughly corresponding to up to 100
requirements. A use case is typically completed within a single iteration.

**User story**: A single interaction of one or more actors with the system to achieve a
goal. A user story is implemented in a few days.

**Scenario**: A single path through a use case, equivalent in scope to a user story.

### 4.2 Work item management

A **work item** is a unit of work to be done. Work items are the building blocks of
backlogs and are managed through two workflows.

**Work item properties:**

| Property | Description |
|----------|------------|
| Name | Short descriptive name |
| Description | What work is to be done, or the work product to be created |
| Acceptance criteria | How adequacy of the work will be determined |
| Classification | Epic, use case, user story, scenario, defect, risk (spike), work product |
| Priority | Urgency and importance (determines iteration allocation) |
| Estimated effort | Story points or half-days |
| Related information | Standards, source material, dependencies |

**Workflow 1: Adding a work item to the backlog**
Create work item, approve, prioritise, estimate effort, place in project backlog,
allocate to an iteration backlog.

**Workflow 2: Completing a work item**
Perform work, review against acceptance criteria. If accepted: remove from
iteration backlog, review and reorganise remaining backlog. If rejected: rework.

### 4.3 Iteration 0 (project initiation)

Iteration 0 maps to ISO 29110 PM.1 (Project Planning) and SR.1 (Initiation). It
establishes the project infrastructure before the first specification iteration:

- Set up the modelling environment (SySiDE, syside.toml, Git repository)
- Create the initial project backlog from stakeholder needs
- Define the product roadmap and release plan
- Establish the SEMP (Systems Engineering Management Plan)
- Identify initial risks and create spike work items

### 4.4 Architecture 0

The first iteration typically focuses on establishing the initial system architecture
(a "skeleton" design) before detailed specification work begins. This is done to:

- Identify the major subsystems and their interfaces
- Establish the model package structure
- Define the initial data model and naming conventions
- Reduce technical risk through early architectural prototyping

Architecture 0 maps to early SR.3 activities in ISO 29110.

---

## 5. Effort Estimation for SE

### 5.1 Story points for specification work

In agile SE, effort is estimated in **story points**, which are relative measures of
complexity, not absolute time units. Use planning poker or similar techniques.

Typical complexity factors for SE specification work:

| Factor | Low complexity | Medium complexity | High complexity |
|--------|---------------|-------------------|-----------------|
| Interface count | 0-2 external | 3-5 external | 6+ external |
| Constraint density | Few QoS requirements | Some QoS constraints | Many coupled constraints |
| Novelty | Well-understood domain | Some new technology | Novel, unproven approach |
| Dependability | Non-critical | Moderate safety concern | Safety/reliability critical |

### 5.2 VSE estimation guidance

- Estimate in **half-days** for small teams where absolute planning is needed
- Review and recalibrate estimates after each iteration using measured velocity
- **SE velocity**: specified use cases per iteration
- **SE fine-grained velocity**: story points per iteration
- Track both planned and actual velocity on a velocity chart to improve accuracy

---

## 6. Risk Management in Agile SE

Risk is the product of an event's likelihood of occurrence and its severity. In agile SE,
risks are managed as backlog items alongside functional work.

### 6.1 Risk types

| Type | Example |
|------|---------|
| Technical | Selected bus architecture may lack sufficient bandwidth |
| Resource | Key team members unavailable for 6 months |
| Schedule | Customer schedule is optimistic |
| Business | Market conditions may change before delivery |

### 6.2 Risk management workflow

1. **Identify** potential sources of risk (at project start and each iteration retrospective)
2. **Characterise** the risk: describe the negative outcome, estimate likelihood and severity
3. **Prioritise**: risk magnitude = likelihood x severity; maintain a priority-ordered risk list
4. **Create a spike**: a work item to reduce either the likelihood or severity of the risk
5. **Allocate** the spike to an iteration plan
6. **Perform** the spike and assess the outcome
7. **Update** the risk list (mark as mitigated, escalate, or replan)

### 6.3 VSE risk guidance

- Maintain the risk list as a view of the project backlog, not a separate artefact
- Address highest-risk items in the earliest iterations
- Featurecide (removing low-value features) is a valid strategy for schedule risk
- Review the risk list at every iteration retrospective

---

## 7. Modelling Rules (Condensed)

Douglass identifies 20 rules of modelling. The most important for VSEs:

1. Every model should have clear purpose, intent, scope, and language
2. Follow a modelling standards guideline (naming conventions, package structure)
3. Use a core subset of SysML v2 and extend only when necessary (80/20 rule)
4. Each view (diagram) should answer a single question or show a single concept
5. Create as many views as you have questions
6. Document your models (model elements need descriptions of use, purpose, scope)
7. Organise like you want to find things (crucial for long-term model management)
8. Drawing is not modelling (diagrams are views, the repository is truth)
9. Be precise (each functional requirement should be constrained by QoS requirements)
10. Be correct first, then optimise later
11. Be semantically complete (include preconditions, postconditions, invariants, QoS)
12. Verify your models early and often (nanocycle verification every hour or less)
13. Incrementally adopt modelling in small, verifiable steps
14. Configuration manage your models (baseline at stable points, use Git)

---

## 8. Agile SE Metrics

Metrics should be used for guidance, not as goals for strict compliance. Good metrics
are easy to measure, easy to automate, and accurately capture the property of interest.

### 8.1 Recommended SE metrics

| Metric | Measures | Category |
|--------|----------|----------|
| SE velocity | Use cases specified per iteration | Productivity |
| SE fine-grained velocity | Story points per iteration | Productivity |
| Burn down rate | Work items remaining over time | Completeness |
| Requirements churn | Rate of change of requirements over time | Stability |
| Defect density | Defects per model element | Quality |
| Escaped defects | Defects found by stakeholders | Quality |
| Running tested features | Verified system features | Completeness |
| Open defect age | Average time from defect discovery to resolution | Responsiveness |
| Remaining risk | Sum of risk exposure values on the risk list | Risk |

### 8.2 VSE metrics guidance

- Measure frequently (every iteration) and keep measurements low-effort
- Use retrospectives (not post-mortems) to review metrics and adjust
- Start with SE velocity and defect density; add others as needed
- Automate metric collection where possible (SySiDE validation counts, Git statistics)

---

## 9. Mapping AMBSE Workflow to ISO 29110

| AMBSE Activity | ISO 29110 Activity | Notes |
|----------------|-------------------|-------|
| Iteration 0 (project setup) | PM.1 + SR.1 | SEMP, environment, initial backlog |
| Stakeholder requirements elicitation | SR.2.1-SR.2.3 | Use case driven, per iteration |
| System requirements derivation | SR.2.4-SR.2.6 | Model-based, per iteration |
| Architecture 0 (initial design) | SR.3 (early) | Skeleton architecture, first iteration |
| Functional analysis and architecture | SR.3 | Per iteration, incremental |
| Handoff to downstream engineering | SR.3 to SR.4 | Iteration boundary |
| Construction | SR.4 | Per iteration, discipline-specific |
| Continuous verification (nanocycle) | SR.5 (ongoing) | Model syntax, trace checks |
| Iteration V&V (microcycle) | SR.5 | End of each iteration |
| System V&V (macrocycle) | SR.5 | End of project |
| Iteration retrospective | PM.2, PM.3 | Metrics review, plan adjustment |
| Product delivery | SR.6, PM.4 | Single pass at project end |

See also: `knowledge/iso29110-profile.md`, `knowledge/iso29110-task-lists.md`.
