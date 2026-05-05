---
name: architecture-design
description: Author Base Architecture (§2), run trade studies (§6) with benefit-as-criterion, and decompose into subsystems (§7). Use when modelling Base Architecture, opening a trade study with variation/variant candidates, allocating capability to subsystems, or working on an architecture branch.
user-invocable: true
---

# Architecture Design

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

This skill owns three methodology stages that share a single discipline. You guide the engineer through:

- **§2 Base Architecture** authoring, treating the platform as exogenous reference rather than project specification.
- **§6 Architectural Analysis and Trade Studies**, in which candidate solutions are SysML v2 `variation`/`variant` and the trade-study criteria are sourced directly from the `benefit` constraints of the story register.
- **§7 Architectural Design**, in which the resolved architecture is decomposed into subsystems and the system's stories, requirements, and capabilities are allocated downward.

The skill implements the methodology's connective mechanism (§0.3). The `require constraint` clauses authored inside story benefits are the *same* model elements that supply trade-study assessment criteria. No separate criterion-authoring step exists, and architectural decisions remain anchored to stakeholder intent by construction.

## When This Skill Triggers

The skill activates when the engineer says, in any of these forms:

- "model the Base Architecture", "capture the platform", "we run on the AC5000", "what library package does the platform live in"
- "open a trade study", "evaluate architecture options", "compare variants", "what variant won", "resolve the variations"
- "decompose into subsystems", "identify subsystems", "allocate to subsystem", "split this requirement across subsystems"
- "open an architecture branch", "I am working on an `arch/...` branch"
- "run the as-is survey", "we skipped the as-is survey at setup", "what is locked in vs. what can change", or any project where `docs/as-is-classification.md` carries the `<!-- as-is-survey: skipped at ... -->` marker

Routing partners:

- `@story-orchestrator` routes here once a story's `benefit` has been formalised as a `require constraint` (the precondition for §6).
- `@vse-companion-overview` routes here for any §2, §6, or §7 work.

## Inputs

Before starting, verify that the project layout matches §8.3 and that the inputs the methodology requires are present.

- Project layout per §8.3, including:
  - `model/core/base-architecture/` for §2 work.
  - `model/core/functional-architecture/`, `model/core/logical-architecture/`, `model/core/product-architecture/` for §6 and §7.
  - `model/variations/` with `decision-points/`, `candidate-variants/`, `trade-studies/`, and `resolved/` per §8.3.3.
- The story register, especially `model/core/stories/system/` with formalised `require constraint` clauses inside story benefits. Stories whose benefits are still informal text strings cannot defend an architectural decision.
- Methodology copy at `<project>/methodology/`, in particular `02-base-architecture.md`, `06-architectural-analysis.md`, and `07-architectural-design.md`.
- Base Architecture (§2) and System Context (§3), if a downstream stage is being entered.

## Workflow A: Base Architecture (§2)

Use this workflow when the project is starting, when a previously missed architectural given surfaces, or when the platform is being refined or replaced.

### Brownfield as-is re-entry

Before starting Step 1, check whether the project carries a brownfield as-is survey artefact:

- `<ENG_ROOT>/docs/as-is-classification.md` exists, and
- the file contains the marker `<!-- as-is-survey: skipped at ... -->`.

If both hold, the project was bootstrapped under `@project-setup` Step 6.5 with the as-is survey declined, and the user has now reached `@architecture-design` to model the platform. Offer to run the survey before continuing with §2.3.1, since the survey produces the candidate set that would otherwise be reconstructed manually here. The survey workflow lives in `@project-setup` Step 6.5; route the user there with the same opt-in posture and the same §2.6 rule 7 guard rails. On completion, remove the skipped marker and resume Workflow A from Step 1 against the populated `model/core/base-architecture/` and `model/core/as-is/` packages.

If the user declines a second time, proceed directly to Step 1 against an empty Base Architecture and capture the givens from user-supplied input only. Do not infer the as-is architecture from the host project's source tree at this point. The reverse-engineering guard (§2.6 rule 7) applies to architectural inference as well as to story synthesis: discovery is permitted only under the explicit opt-in survey, never as an implicit side effect of Workflow A.

### Step 1: Capture the architectural givens (§2.3.1)

Enumerate elements the project must build on rather than choose, in four common categories:

- platforms (hardware controllers, OS distributions, runtime environments),
- protocols and standards (communication protocols, data formats, industry standards the project must conform to),
- reused subsystems (components inherited from a parent product),
- regulatory frameworks (certifying authorities, mandated standards).

Each given becomes a candidate `part def` in Step 2.

### Step 2: Model givens as part definitions (§2.3.2)

Declare a `library package` per §8.3.1 and place each given inside it as a `part def`. Capture attributes, value properties, ports, and immutable `require constraint` clauses. Route to `@sysml2-model-structure` for the package layout and to `@sysml2-expressions` for constraint bodies.

### Step 3: Establish the system relationship (§2.3.3)

Choose exactly one of:

- **Specialisation** (`:>`) when the project produces an instance of the platform (typed inheritance from the platform `part def`).
- **Allocation** (`allocate ... to ...`) when the project's system runs *on* the platform without specialising it.

Both relationships at once are forbidden by §2.6 rule 3. Where the system genuinely is both an instance of one platform and hosted on another, introduce intermediate `part def`s and route to `@sysml2-allocations` for the allocation syntax.

### Step 4: Apply the §2.6 well-formedness checklist

Before proposing the change is ready for review:

1. The Base Architecture resides in a `library package` and imports only from `library/`, `model/core/domain/`, or external libraries.
2. No specialising part redefines an inherited `require constraint` with a weaker one. Refuse to author such a redefinition.
3. The system has exactly one relationship to the Base Architecture (specialisation or allocation, not both).
4. Base Architecture changes are flagged for elevated final review per §8.6.3.
5. Forward-going stories declare their `subject` as a *specialisation* of a Base Architecture `part def`, not the Base Architecture part def itself. CI emits an informational warning when a story's `subject` resolves to a `library package` part def, which marks the story as optional context rather than required output.
6. Concerns informed by Base Architecture limitations are legitimate when their subject is the project's system. Concerns whose subject is the Base Architecture itself are optional context-recording.
7. **Agent-collaboration discipline.** Do not synthesise context stories and do not reverse-engineer Base Architecture justifications. The default agent posture is forward-going work. Context stories may be authored only on explicit human request, with explicit confirmation of intent.

## Workflow B: Architectural Analysis and Trade Studies (§6)

Use this workflow once at least one system story has a formalised `benefit` constraint and the engineer is ready to choose between candidate architectures.

### Step 1: Identify key functions and properties (§6.3.1)

From the §5 work products (`action def`, `use case def`, `state def`), extract:

- **functions** the architecture must perform (alarm acknowledgement, weather data ingestion, fault recovery),
- **properties** the architecture must exhibit (latency, throughput, mass, power consumption, cost).

A function whose realisation is unambiguous is *not* a decision point and shall not enter the next step.

### Step 2: Define candidate solutions as variations (§6.3.2)

For each architectural decision, declare a `variation part def` and its candidate `variant part`s in `model/variations/decision-points/` and `model/variations/candidate-variants/`. Variants implicitly subset the variation, so any variant is substitutable for it.

Route to `@sysml2-variants` for the variation/variant syntax.

### Step 3: Express cross-decision constraints (§6.3.3)

Cross-decision constraints (rules of the form "if A then B") are expressed as `assert constraint` clauses on the configurable system part def. They encode feasibility rules across multiple decisions, for example "if engine = diesel then tank capacity ≥ 80 L".

Route to `@sysml2-expressions` for `assert constraint` bodies.

### Step 4: Source assessment criteria from story benefits (§6.3.4)

This is the methodology's connective mechanism in operation. Extract the `require constraint` clauses already present in the system story register. The constraints *are* the criteria. Do not author criteria as a separate artefact.

If a candidate-bearing function or property has no relevant story, either the decision needs no trade study, or a story is missing from §5. In the second case, hand off to `@needs-and-requirements` to add the story retroactively before continuing.

### Step 5: Perform the trade study (§6.3.5)

Walk through the four sub-steps of §6.3.5:

1. **Assign weights** that normalise to 1.0 across criteria. Weights may be informed by `StoryMeta.priority` (per §1.5) or by concern severity (per §4).
2. **Define utility curves per criterion** as calculations mapping value-property values to a normalised utility score. Curves may be discrete (lookup tables) or continuous (linear, exponential, sigmoid). Declare upper and lower bounds.
3. **Score MOEs** by dispatching the `vse-trade-study-runner` subagent. The agent evaluates each (variant, criterion) pair in an isolated context and returns a markdown matrix with score rationale, sensitivity analysis, and any missing alternatives it surfaces. Pass the decision statement, the variant set, the weighted criteria, and the paths to relevant SysML files. Present the returned matrix verbatim to the engineer and invite edits before recording any decision.
4. **Determine the solution** as the variant with the best weighted total. The trade study is itself an `analysis def` placed in `model/variations/trade-studies/`. Route to `@sysml2-cases` for the analysis-case body.

### Step 6: Resolve variations (§6.3.6)

The selected architecture is a *specialisation* of the configurable system `part def` that redefines every `variation` to its chosen `variant`. Place the resolution in `model/variations/resolved/`. Refuse to ship a resolution that leaves any variation unresolved or that violates an `assert constraint`.

### Step 7: Merge across decisions (§6.3.7)

If the integration of multiple decisions surfaces conflicts the `assert constraint` clauses did not anticipate, run a meta-trade-study over the conflict by adding a new decision point whose variants are the conflicting combinations.

## Workflow C: Architectural Design (§7)

Use this workflow once a resolved architecture exists and the engineer is ready to decompose into subsystems.

### Step 1: Identify subsystems (§7.3.1)

Decompose the resolved architecture into `part def` subsystems with coherent responsibility groupings. Inform the decomposition by:

- function grouping (actions and use cases that share state and data belong in the same subsystem),
- coupling (minimise inter-subsystem communication, maximise intra-subsystem cohesion),
- technology boundaries (real-time versus soft, software versus hardware),
- organisational boundaries (different teams, vendors, certification authorities).

Place the subsystem set in `model/core/logical-architecture/`.

### Step 2: Allocate system requirements (§7.3.2)

For each `require constraint` in the system story register, choose one of three cases:

- **Direct allocation** to a single subsystem.
- **Joint allocation** to multiple subsystems (typically end-to-end latency or budget constraints).
- **Decomposition** into derived subsystem-level constraints whose conjunction implies the system constraint.

Place allocations in `model/core/logical-architecture/allocations/`. Route to `@sysml2-allocations` for the SysML v2 `allocation` syntax.

### Step 3: Allocate stories and capabilities (§7.3.3)

Two valid approaches:

- **Top-down.** Decompose system stories using `derive` into subsystem-internal stories, each allocated to one subsystem.
- **Bottom-up.** Allocate the action defs / use cases that elaborate the stories first, then extract subsystem-level stories from the allocated behaviour.

A system-level story is *not* allocated to a single subsystem when its realisation requires subsystem collaboration. The default is collaboration. Refuse to force a system-level collaborative story onto one subsystem.

### Step 4: Update the logical data schema (§7.3.4)

Extend the schema with subsystem-internal `item def`s and inter-subsystem interface flows. Place inter-subsystem interfaces in `model/core/logical-architecture/interface-types/`. Wire interfaces with `connect` clauses inside the decomposition `part def`.

### Step 5: Create or update subsystem user stories (§7.3.5)

The full §1 specification applies recursively at subsystem level (per §8.3.2). The subsystem becomes the new "system", its `part def` is the `subject` of its stories, and its sibling subsystems, the parent system, or external actors local to the subsystem boundary are the candidate stakeholder set. Place subsystem stories inside `model/core/logical-architecture/components/<component>/stories/`. Hand off the recursion entry point to `@story-orchestrator` and `@needs-and-requirements`.

### Step 6: Develop control laws (§7.3.6)

For control behaviour spanning multiple subsystems, declare `constraint def` instances and allocate them to the responsible subsystems. Single-subsystem control laws are deferred to detailed design. Route to `@sysml2-expressions` for constraint bodies.

### Step 7: Re-run dependability analysis (§7.3.7)

Architectural decomposition introduces new failure modes (subsystem boundaries are failure surfaces) and may eliminate others. Re-run §5.5 at subsystem granularity, surfacing new concerns, new stories, and new inter-subsystem interface assertions.

### Step 8: Review (§7.3.8)

Exercise the verification cases against the elaborated model where SysML v2 model execution is available. Supplement with manual review against the well-formedness rules and ask:

- Does every system story have at least one subsystem-story or subsystem-allocation derivation?
- Do the subsystem stories collectively cover the system story?
- Are inter-subsystem interfaces minimal? Each interface is a cost.
- Does the decomposition match the team and procurement structure?

## Refusals

Refuse and explain when the engineer attempts any of the following:

- Authoring trade-study criteria as a separate artefact when story `benefit` constraints exist. Per §0.3, criteria *are* the benefit constraints. If a criterion is needed but no story expresses the underlying concern, hand off to `@needs-and-requirements` to add a story retroactively (§6.3.3 step 1).
- Redefining an immutable Base Architecture `require constraint` with a weaker one in a specialising part (§2.6 rule 2).
- Declaring more than one Base Architecture relationship per system (§2.6 rule 3, specialisation OR allocation, not both, except via intermediate part defs).
- Synthesising a context story that justifies a Base Architecture decision (§2.6 rule 7). Forward-going stories only, unless the engineer explicitly confirms intent.
- Shipping a resolved architecture that leaves any variation unresolved (§6.3.4).
- Allocating a system-level story whose realisation requires subsystem collaboration to a single subsystem (§7.3.3, collaboration is the default).

## Hand-offs

| Topic | Route to |
|---|---|
| Branch and PR management for the architecture branch | `@story-orchestrator` |
| Missing concern surfaced during a trade study | `@needs-and-requirements` |
| Verification cases that exercise the architectural model | `@verification-validation` |
| `variation` / `variant` authoring | `@sysml2-variants` |
| `allocation` relationship authoring | `@sysml2-allocations` |
| `analysis def` body for a trade study | `@sysml2-cases` |
| Utility-curve and weighted-total expressions, `assert constraint` clauses | `@sysml2-expressions` |
| Recursive component nesting under §8.3.2 | `@sysml2-model-structure` |
| Editing a baselined Base Architecture or baselined architectural decision | `@change-request` |

## Outputs

The skill produces or updates the following artefacts. File names are project-determined.

- `model/core/base-architecture/<part>.sysml`. Base Architecture `part def` set in a `library package`.
- `model/core/functional-architecture/<...>.sysml`. `action def` and function decomposition.
- `model/core/logical-architecture/<...>.sysml`. Selected logical architecture, including the decomposition `part def`.
- `model/core/logical-architecture/components/<comp>/...`. Recursive component scope per §8.3.2 (stakeholders, concerns, stories, use-cases, verification-validation, optional further nesting).
- `model/core/logical-architecture/allocations/<name>.sysml`. Function-to-component allocations.
- `model/core/logical-architecture/interface-types/<name>.sysml`. Inter-subsystem `interface def`s.
- `model/core/product-architecture/<...>.sysml`. Physical decomposition at system level.
- `model/variations/decision-points/<name>.sysml`. `variation` defs.
- `model/variations/candidate-variants/<name>.sysml`. `variant` defs.
- `model/variations/trade-studies/<name>.sysml`. `analysis def` per decision point.
- `model/variations/resolved/<name>.sysml`. Specialisations that redefine variations.

The wiki bundle below provides the supporting reference material on trade-study mechanics, AMBSE architecture analysis, and recursive component nesting.

`!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/architecture-design.md`
