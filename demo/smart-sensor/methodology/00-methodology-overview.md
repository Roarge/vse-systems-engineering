# 0. Methodology Overview

## 0.1 Purpose

This document specifies an agile model-based systems engineering (MBSE)
methodology in SysML v2. It adapts the process arc established by Harmony
aMBSE (Douglass, 2016, Chapters 4–7) and integrates supporting concepts from
the SysML v2 standard library (Weilkiens & Molnár, 2025) and from SYSMOD
(Weilkiens, 2020). It makes three substantive changes from the source arc:

1. **User stories are the primary requirement artifact at every stage.**
   Where the source methodology treats stakeholder use cases as primary and
   user stories as informal companions, this methodology inverts that
   relationship: the user story is canonical; the use case is one mode of
   behavioral elaboration of a story's capability.
2. **The notation is SysML v2 throughout.** All artifacts — stories, use
   cases, item flows, action definitions, analysis cases, verification cases,
   subsystem decompositions — are expressed using SysML v2 textual notation.
   Stereotypes and profile mechanisms from SysML v1 are not used. SysML v2
   native constructs are preferred: `concern def` for stakeholder needs
   (sysmlv2 §32.5), `variation`/`variant` for trade-study candidates
   (sysmlv2 Ch 35), and `metadata def` with semantic metadata for
   methodology library packaging (sysmlv2 Ch 41).
3. **Project context is modelled explicitly.** Two foundational artefacts
   adopted from SYSMOD precede stakeholder work: the *Base Architecture*
   (§2) captures architectural and technical decisions preset before the
   project starts, and the *System Context* (§3) captures the system's
   environment and external actors.

The methodology retains the agile cadence of the source: each workflow stage
is performed iteratively over a small set of stories at a time, not
exhaustively before the next stage begins.

## 0.2 Methodology Structure

The methodology distinguishes **foundational sections**, which define
artefact types and modelling concepts, from **workflow stages**, which
prescribe activities. Foundational sections are referenced from multiple
stages; workflow stages are executed iteratively.

**Foundational sections (§1–§3):**

| Section | Title | Role |
|---|---|---|
| §1 | User Stories | The canonical stakeholder-intent artefact, propagated through every workflow stage |
| §2 | Base Architecture | Pre-existing architectural and technical decisions that constrain the project from the start (adopted from SYSMOD §5.7) |
| §3 | System Context | The system's environment: external actors, interfaces, item flows (adopted from SYSMOD §5.11) |

**Workflow stages (§4–§7):**

| Stage | Section | Purpose | Primary input | Primary output |
|---|---|---|---|---|
| Stakeholder Requirements Engineering | §4 | Capture stakeholder intent | Stakeholder identification; concerns; Base Architecture; System Context | Stakeholder User Story set |
| System Requirements Definition and Analysis | §5 | Translate stakeholder intent into system-level specification with verifiable behaviour | Stakeholder User Story set | System User Story set + behavioural elaborations |
| Architectural Analysis and Trade Studies | §6 | Select an architecture against story-derived criteria | System User Story set; candidate solution variants | Selected architecture (resolved variant set) |
| Architectural Design | §7 | Decompose into subsystems and propagate stories downward | Selected architecture | Subsystem User Story sets + allocations |

User stories propagate through all four workflow stages. Each transition
produces a new story set whose elements `derive` from stories at the level
above, so the trace from any subsystem-level capability back to a
stakeholder concern is a chain of `derive` and `frame concern` relationships
through the model — not a manual matrix.

## 0.3 The Connective Mechanism — `benefit` as Trade-Study Criterion

The most important structural property of this methodology is that the
`benefit` slot of a user story is the *same model element* that supplies
assessment criteria during architectural trade studies (§6). When a story's
benefit is expressed as a `require constraint` over value properties of the
system (per §1.4.3), that constraint can be invoked directly as a criterion
in the trade-study analysis case. No separate criterion-authoring step is
required, and there is no risk of architectural decisions drifting from
stakeholder intent — the criteria *are* the stakeholder intent.

Stories whose benefits remain as informal text strings (the §1 minimal form)
do not contribute to trade studies; they may still pass through the
methodology, but architectural decisions cannot be defended against them.
This creates a natural pressure to formalise benefit constraints before
entering §6.

## 0.4 Key Adaptations from the Source Methodology

| Source methodology (Harmony aMBSE) | This methodology |
|---|---|
| Stakeholder use cases are primary; stakeholder requirements are allocated to them | Stakeholder user stories are primary; their `capability` may be elaborated by a use case (§1.4.5) |
| Stakeholder requirements text is the deliverable | User Story specializations with typed `role`, `capability`, `benefit`, `acceptance`, optional `frame concern` (§1.4.6) |
| Stakeholder needs implicit in requirement text | Stakeholder needs modelled as `concern def` (sysmlv2 §32.5); stories `frame` the concerns they address |
| System use cases generated 1:1 from stakeholder use cases | System user stories `derive` from stakeholder user stories (typically 1:N), retaining role-actor binding |
| Three alternative use case analysis approaches (flow-based, scenario-based, state-based) | Same three approaches, applied to the *capability* of a system story rather than to a use case directly |
| Trade-study candidates described as separate artefacts | Candidates modelled as `variation`/`variant` (sysmlv2 Ch 35); selection is redefinition; valid combinations expressed as `assert constraint` |
| Trade-study criteria authored as a separate artifact | Criteria sourced from `benefit` constraints of stories under consideration (§0.3) |
| Subsystem requirements derived by allocating system requirements | Subsystem user stories derived where the subsystem itself becomes the "system" of a recursively applied §4–§5 workflow |
| Project context implicit | Base Architecture (§2) and System Context (§3) modelled as explicit foundational artefacts (adopted from SYSMOD) |
| SysML v1 with stereotypes and profile customisation | SysML v2 with `metadata def`, requirement specialisation, language keywords, and methodology library packaging via semantic metadata (sysmlv2 Ch 41) |

## 0.5 Document Map

| Section | Title | Status |
|---|---|---|
| §0 | Methodology Overview | this document |
| §1 | User Stories | drafted (`01-user-stories.md`) |
| §2 | Base Architecture | drafted (`02-base-architecture.md`) |
| §3 | System Context | drafted (`03-system-context.md`) |
| §4 | Stakeholder Requirements Engineering | drafted (`04-stakeholder-requirements.md`) |
| §5 | System Requirements Definition and Analysis | drafted (`05-system-requirements.md`) |
| §6 | Architectural Analysis and Trade Studies | drafted (`06-architectural-analysis.md`) |
| §7 | Architectural Design | drafted (`07-architectural-design.md`) |
| §8 | Project Structure and Git Workflow | drafted (`08-project-structure.md`) |
| §9 | ISO/IEC TR 29110‑5‑6‑2 Compliance | drafted (`09-iso-29110-compliance.md`) |
| §10 | Project Management | drafted (`10-project-management.md`) |
| — | Compliance hooks guide | drafted (`iso-29110-hooks-guide.md`) — companion document |
| §A | Worked example — stakeholder stories | open |
| §B | Worked example — system stories and analyses | open |
| §C | Worked example — architecture and subsystem stories | open |

Appendix examples are deferred until the project example domain is fixed.

## 0.6 Section Previews

### 0.6.1 §1 — User Stories (foundation, drafted)

The canonical artefact specification. Drafted in `01-user-stories.md`. Defines
the `UserStory` requirement specialisation with `role`, `capability`,
`benefit`, `acceptance`, and optional `frame concern`. All workflow stages
(§4–§7) consume and produce User Story specialisations.

### 0.6.2 §2 — Base Architecture

**Purpose:** capture architectural and technical decisions that
pre-exist the project and constrain its work from outside it. The
Base Architecture is exogenous reference, not project specification.
The methodology's required output is forward-going stories that build
on top of it (§4–§7); the user may optionally add context stories for
organisational memory, but AI agents shall not reverse-engineer or
auto-generate them. See §2.1 for the principle and §2.6 rules 5–7
for the CI-checkable form and the agent-collaboration rule.

**Workflow:**

1. **Identify the architectural givens.** Enumerate the products, platforms,
   protocols, and standards the project must build on. These may come from
   the parent product line, the customer's existing infrastructure, or
   regulatory mandate.
2. **Model the Base Architecture as a `part def` package.** For each
   architectural given, declare a `part def` with relevant attributes,
   ports, and value properties. Constraints that the project cannot violate
   are expressed as `require constraint` clauses on these part defs.
3. **Establish the relationship to the project system.** The project's
   system part def either specialises (`:>`) the Base Architecture, or is
   `allocate`d to it, depending on coupling. Specialisation is appropriate
   when the project produces an instance of the platform; allocation is
   appropriate when the project's system runs *on* the platform.
4. **Publish the Base Architecture package.** The package is imported by
   §4–§7 work products. Stories' `subject` clauses reference Base
   Architecture part defs.

**Artefacts produced:**

- `part def` set representing the architectural givens, organised in a
  `library package`
- Coupling relationship to the project's system (`:>` or `allocate`)
- `require constraint` set capturing immutable architectural constraints

**Notes:**

- The Base Architecture may be sketched informally at project start
  ("napkin architecture", per SYSMOD) and formalised as the project
  matures.
- For multi-product organisations, the Base Architecture is typically a
  product-line asset rather than a project-specific artefact.

### 0.6.3 §3 — System Context

**Purpose:** define the system's environment. The System Context
establishes the system boundary, the external entities the system
interacts with, and the item flows that cross the boundary. It is the
shared reference for all stories' `subject` declarations and for any
`actor` typing in elaborated use cases.

**Workflow:**

1. **Define the system part.** Declare a `part def` for the system of
   interest. This part is the `subject` of every stakeholder and system
   story, and is typically a specialisation of a Base Architecture part
   def.
2. **Identify external actors in four categories** (per SYSMOD §5.11):
   - **Human actors** — operators, maintainers, end users, supervisors;
   - **External systems** — interfacing IT systems, peer devices,
     upstream/downstream equipment;
   - **Environmental effects** — physical phenomena the system must
     respond to (temperature, weather, vibration);
   - **Environmental impact** — entities the system affects beyond its
     functional scope (atmosphere, neighbours, terrain).
   Each actor is a `part def`. The same part def may serve as both a
   stakeholder type (in concerns and stories) and an actor type (in use
   cases), per §1.4.5.
3. **Define interfaces and item flows.** For each actor connected to the
   system, declare ports on both sides and `interface def` for the
   connection. Item flows specify what crosses each interface.
4. **Compose the System Context part.** Declare a single `part def` (or
   `occurrence def`) that owns the system and all actors as parts, with
   their interfaces wired up. This is the canonical context view.

**Artefacts produced:**

- System `part def`
- Actor `part def` set, classified by category
- `interface def` set with item flow typing
- System Context composite `part def`

**Notes:**

- The four-category classification is a discipline, not a constraint.
  Actors that don't fit cleanly are still actors; categorisation aids
  completeness checking, not modelling validity.
- The System Context typically expands during §5 (System Requirements)
  as deeper analysis surfaces actors that were not initially obvious.

### 0.6.4 §4 — Stakeholder Requirements Engineering

**Inputs:** Base Architecture (§2), System Context (§3).

**Workflow:**

1. **Identify stakeholders.** Declare a `part def` per stakeholder role
   (Operator, Maintainer, Regulator, etc.). No abstract `Stakeholder` parent
   is introduced (per §1.3). Produce an initial stakeholder taxonomy.
   Stakeholders may overlap with System Context human actors but include
   parties who do not interact with the system directly (regulators,
   purchasers, sponsors).
2. **Capture stakeholder concerns.** For each stakeholder, declare
   `concern def` instances expressing the things the stakeholder cares
   about, fears, or requires. Concerns carry their own `subject` and
   `require constraint` (per sysmlv2 §32.5). Concerns persist across
   iterations and may be addressed by multiple stories.
3. **Identify and prioritise capability themes.** For each concern (or
   stakeholder), enumerate the high-level capabilities through which the
   concern can be addressed. Prioritise by importance, urgency, project
   risk, and information availability.
4. **Generate stakeholder user stories.** Apply §1 to author one or more
   `UserStory` specializations per capability theme. Each story `frame`s
   the concern(s) it addresses (per §1.4.6). Stories enter the model in
   §1.7.1 minimal form and progress as detail emerges.
5. **Elaborate story scenarios (optional).** Where a story's capability is
   non-trivial, declare a `use case def` that names the story as its
   `objective` per §1.4.5. The use case carries scenario detail; the
   story remains the carrier of stakeholder intent.
6. **Create/update validation plan.** Each story's acceptance criteria
   is linked to a `verification def`. Verification cases that
   exercise stakeholder intent (rather than system internals) constitute
   the validation plan.

**Artefacts produced:**

- `part def` set for stakeholder types
- `concern def` set (the stakeholder needs register)
- `UserStory` specialisation set with `frame concern` links
- `use case def` set (where capabilities have been elaborated)
- `verification def` set scoped to validation

### 0.6.5 §5 — System Requirements Definition and Analysis

**Inputs:** Stakeholder User Story set (§4), System Context (§3).

**Workflow:**

1. **Identify system user stories.** For each stakeholder story in scope
   for the iteration, derive one or more system stories using `derive`.
   System stories have the *same* `role` (the stakeholder is unchanged),
   but the `capability` is restated in system-internal vocabulary, and
   `benefit` is sharpened toward measurable constraints. Framed concerns
   propagate.
2. **Generate system requirements.** Within each system story, formalise
   benefit and capability detail as `require constraint` clauses over
   value properties. Add stories or constraints that emerged from
   regulatory, fault-management, or self-test concerns (these are
   typically discovered during system analysis, not in §4).
3. **Perform story analysis.** Three alternative approaches, equivalent
   in outcome:
   - **Flow-based:** model the capability as `action def` with item flows;
     derive scenarios as paths.
   - **Scenario-based:** enumerate concrete scenarios as sequence-style
     analyses, derive interactions and item flows.
   - **State-based:** model the system as `state def` exercised by the
     story; derive transitions and events.
   The choice depends on the capability's character (data-driven,
   interaction-driven, or mode-driven) and team preference.
4. **Create/update logical data schema.** Define `item def` and flow
   typing for everything that crosses the system boundary or appears in
   story analyses. Extends the System Context interfaces from §3. The
   schema is shared across all stories in scope.
5. **Dependability analysis.** Safety, reliability, and security
   concerns are introduced as additional `concern def` instances (with
   appropriate stakeholders) and addressed by new or extended stories.
   Hazard identification follows a separate sub-workflow not specified
   here.
6. **Create/update verification plan.** Each acceptance criterion is
   bound to a `verification def` that exercises the system model.
   These cases verify (rather than validate) and complement the
   validation plan from §4.

**Artefacts produced:**

- System `UserStory` set with `derive` links to stakeholder stories
- `action def` / `use case def` / `state def` set per chosen analysis path
- Extended logical data schema (`item def`, flow types)
- Dependability concerns and stories
- Verification case set

### 0.6.6 §6 — Architectural Analysis and Trade Studies

**Inputs:** System User Story set with formalised `benefit` constraints (§5).

**Workflow:**

1. **Identify key system functions and properties.** Extract from the
   `action def` and `use case def` set produced in §5. These are the
   behaviours and qualities that an architecture must realise.
2. **Define candidate solutions as variants.** For each architectural
   decision point, declare a `variation` (per sysmlv2 Ch 35) and a set
   of `variant`s representing candidate solutions. Variants implicitly
   subset the variation, so any variant is substitutable for the
   variation. Cross-decision constraints (e.g., "if engine = diesel then
   tank ≥ 80 L") are expressed as `assert constraint`.
3. **Perform architectural trade study** — sub-workflow:
   1. **Source assessment criteria from story benefits.** Per §0.3,
      criteria are the `require constraint` clauses already present in
      the story set. No new criteria are authored unless a concern
      surfaces that no story expresses, in which case a new story is
      added retroactively.
   2. **Assign weights.** Weights normalize to 1.0 across criteria.
      Weighting may be informed by story `priority` from `StoryMeta` or
      by concern severity.
   3. **Define utility curves per criterion.** Continuous or discrete,
      mapping value-property values to a normalized utility score
      (typically 0–10).
   4. **Assign MOEs to candidates.** For each (variant, criterion) pair,
      evaluate the utility curve at the variant's predicted value.
      Tabulate.
   5. **Determine the solution.** Compute weighted total per variant;
      select the highest. The trade study is itself an
      `analysis def` so that it is reproducible and the selection
      is traceable.
4. **Resolve variations.** The selected architecture is expressed as a
   specialisation of the system part def that redefines each variation
   to a chosen variant (sysmlv2 §35, Figure 35.6 pattern). The
   resolution is itself a model element, not a checklist.

**Artefacts produced:**

- Set of key functions/properties under architectural decision
- `variation` decision points with `variant` candidates
- Trade-study `analysis def` (reproducible)
- Resolved architecture (specialisation with all variations redefined)

### 0.6.7 §7 — Architectural Design

**Inputs:** Resolved architecture (§6), System User Story set (§5).

**Workflow:**

1. **Identify subsystems.** Decompose the resolved architecture into
   `part def` subsystems with coherent responsibility groupings.
2. **Allocate system requirements to subsystems.** For each
   `require constraint` in the system story set, allocate to the
   subsystem that bears it. Three cases: directly allocated; jointly
   allocated to multiple subsystems; or decomposed into derived
   subsystem-level constraints.
3. **Allocate stories and capabilities to subsystems.** Two approaches:
   - **Top-down:** decompose system stories using `derive` into
     subsystem-internal stories; each derived story is allocated to one
     subsystem.
   - **Bottom-up:** allocate the action defs / use case defs that
     elaborate stories to subsystems; group allocated behaviour into
     subsystem-level stories.
   In general, a system-level story is *not* allocated to a single
   subsystem — it is realised by collaboration.
4. **Update logical data schema.** Extend with subsystem-internal item
   defs and inter-subsystem interface flows.
5. **Create/update subsystem user stories.** At the subsystem level, the
   `subject` becomes the subsystem; the `role` becomes a sibling
   subsystem, an external actor, or the system itself. The full §1
   specification applies recursively at this level. Subsystem stakeholder
   concerns may be inherited from parent stories or introduced afresh
   where the subsystem has its own dependability or interface
   responsibilities.
6. **Develop control laws.** For control behaviour spanning subsystems,
   define `constraint def` capturing the law and allocate to the
   responsible subsystems. Single-subsystem control laws are deferred
   to detailed design.
7. **Analyse dependability.** Re-run the §5.5 analysis at subsystem
   granularity, including new hazards introduced by the chosen
   architecture's technology choices.
8. **Perform review.** Verify completeness and correctness via model
   execution where possible, supplemented by syntactic and semantic
   review.

**Artefacts produced:**

- Subsystem `part def` set (decomposition)
- Allocation relationships (requirements, stories, capabilities → subsystems)
- Subsystem `UserStory` sets (with their own framed concerns)
- Inter-subsystem `interface def` set
- Control law `constraint def` set
- Updated dependability analysis at subsystem level

## 0.7 Iteration Discipline

Every workflow stage operates over a *subset* of the artefacts at its input
level — typically the stories selected for the current iteration. The
methodology is not waterfall-by-stage; the four stages compose in iteration
cycles where:

- A stakeholder story may be created in §4 in iteration *n*, derived to
  system stories in §5 in iteration *n*, allocated to subsystems in §7 in
  iteration *n+1*, and revisited in §4 in iteration *n+2* if validation
  surfaces a missed concern.
- The story register is the authoritative cross-iteration index. The
  `StoryMeta.status` attribute (per §1.5) records position in the workflow
  per story. The mapping between status values and the repository's branch
  and pull-request state is specified in §8.7.
- Foundational artefacts (Base Architecture in §2, System Context in §3) are
  treated as *evolving but stable*: they are updated when a discovery
  warrants it, but the update is a deliberate event rather than a routine
  per-iteration activity.

## 0.8 Forthcoming Work — Methodology Library Packaging

The constructs introduced by this methodology (`UserStory`, `StoryMeta`,
`StakeholderNeed`, the role/actor coupling pattern, the `frame concern`
discipline, the variation-based trade-study pattern) shall ultimately be
packaged as a SysML v2 `library package` named `MBSEMethodology` (working
title), so that downstream projects can adopt the methodology by `import`
rather than by re-declaration.

Two SysML v2 mechanisms support this packaging (sysmlv2 Ch 41):

1. **Model libraries.** Methodology elements are declared once in a
   `library package` and imported by project models.
2. **Semantic metadata for user-defined keywords.** Keywords such as
   `#userStory`, `#stakeholderStory`, `#systemStory`, `#subsystemStory`
   may be declared as `Metaobjects::SemanticMetadata` specialisations,
   each redefining `baseType` to point at the corresponding methodology
   element. Projects then write `#userStory requirement def US_042 { … }`
   without explicit `:> UserStory`.

Library packaging is deferred until the foundational sections (§1–§3) and
at least one workflow stage are stable. The methodology specification
itself is the design input for the library; the library is its
machine-readable counterpart.

## 0.9 Out of Scope

The following topics are not covered by this methodology specification and
shall be addressed by separate documents:

- Detailed design beyond subsystem boundaries (handed off to the
  engineering disciplines)
- Iteration length, ceremonies (sprints, stand-ups, retrospectives), and
  team composition. §8 specifies the *artefact* lifecycle (branch and PR
  state); calendar and team practice remain project-determined.
- CI tooling and validator implementation (§8 specifies what the CI must
  enforce, not how)
- Hazard analysis sub-methodology (referenced from §5.5, §7.7)
- Process tailoring for regulated domains (DO-178C, IEC 61508, etc.)
- Product-line engineering with feature models (the variation/variant
  mechanism in §6 is the mechanical foundation; full PLE feature
  modelling is a separate methodology layer)

---

*End of overview. All process-description sections are drafted:
§1 (`01-user-stories.md`) through §10 (`10-project-management.md`),
plus the ISO/IEC TR 29110‑5‑6‑2 compliance mapping (`§9`) and the
companion `iso-29110-hooks-guide.md`. Worked-example appendices
(§A–§C) remain open for elaboration with project-specific cases.*
