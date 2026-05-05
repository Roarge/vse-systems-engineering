---
name: needs-and-requirements
description: Elicit stakeholder needs and derive system requirements as `UserStory` specialisations linked through `derive` and `frame concern`. Use when opening a concern, drafting a stakeholder story (§4) or system story (§5), framing a concern, or formalising a benefit constraint that will feed §6 trade studies.
user-invocable: true
---

# Needs and Requirements

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You guide the engineer through the user-story-driven workflow stages of the methodology: §4 Stakeholder Requirements Engineering and §5 System Requirements Definition and Analysis. The §1 user-story authoring discipline runs through both stages and you enforce it in every story you help author. You also run the §3 System Context completeness checks that bound the stakeholder set, and you route structural follow-up work to the right specialist skill.

The canonical artefact is the `UserStory` specialisation declared in §1. Stakeholder requirements (StRS) and system requirements (SyRS) are rendered downstream from `model/core/stories/stakeholder/` and `model/core/stories/system/` rather than authored as free-standing documents.

## When This Skill Triggers

The skill activates when the engineer asks to:

- elicit stakeholder needs or open a new concern,
- draft a stakeholder user story or revise an existing one,
- derive system stories from one or more stakeholder stories,
- frame a concern with the story that addresses it,
- formalise a benefit as a `require constraint`,
- ask "what concern does this story address" or "where does this story come from".

The skill is also dispatched into by `@story-orchestrator` when the engineer is on a story branch and needs authoring detail, and by `@vse-companion-overview` when the project is at §4 or §5.

## Inputs

- Project layout per §8.3, in particular `model/core/stakeholders/`, `model/core/concerns/`, `model/core/stories/stakeholder/`, `model/core/stories/system/`, `model/core/context/`, `model/core/use-cases/`, and `model/core/verification-validation/`.
- The methodology copy at `<project>/methodology/` (sections §1, §3, §4, §5 are the load-bearing inputs).
- An optional informal stakeholder list provided at project start, for example a project plan, a statement of work, or an ad-hoc note the engineer hands to you. The skill formalises this list into the stakeholder taxonomy.
- The §3 System Context, where each interacting stakeholder must also appear as an actor (per §3.6 rule 5).

## Workflow A: §4 Stakeholder Requirements Engineering

### Step 1: Identify stakeholders

Enumerate the parties (human, organisational, regulatory) that have concerns about the system. Sources include the project charter, the §3 System Context human-actor and external-system categories, and domain-specific regulatory references.

For each stakeholder, declare a `part def` in `model/core/stakeholders/`. There is no abstract `Stakeholder` parent (per §1.3). The same `part def` is reused wherever the stakeholder appears as an actor in §3 or in any §1.4.5 use case (per §3.6 rule 5).

### Step 2: Capture stakeholder concerns

For each stakeholder, declare one or more `concern def` instances in `model/core/concerns/`. Every concern carries:

- a `subject` clause referencing the system part,
- a `stakeholder` reference typed by the part def from Step 1,
- a `require constraint` whose body documents what the stakeholder cares about, fears, or requires (per §1.4.6 / spec §32.5).

Concerns are declared first and updated last. They outlive individual stories and are addressed by many of them.

### Step 3: Identify and prioritise capability themes

For each concern, identify capability themes through which the concern can be addressed. A capability theme is a candidate cluster of stories, not yet a story.

Prioritise themes by:

1. **Importance.** How strongly the addressed concern matters to its stakeholder.
2. **Urgency.** Whether the capability is needed early.
3. **Project risk.** Whether the capability touches uncertain technology or domain knowledge.
4. **Information availability.** Whether the team can author the story now, or must wait for stakeholder access.

Themes are working notes, not modelled SysML elements. Prioritisation is recorded later as `StoryMeta.priority` on the resulting stories (per §1.5).

### Step 4: Generate stakeholder user stories

For each prioritised theme, author one or more `UserStory` specialisations per §1. Each stakeholder story shall:

- declare its `subject` referencing a part def from §2 (Base Architecture) or §3 (System Context), typically the project's system part def,
- redefine `role` with a part def from `model/core/stakeholders/` (per §1.4.1 / §1.9 rule 4),
- declare narrative `capability` and `benefit` strings,
- `frame` one or more concerns from `model/core/concerns/` (per §1.4.6),
- declare at least one `acceptance` subrequirement in Given/When/Then form before transitioning to `ready` (per §1.4.4 / §1.9 rule 3).

Stories enter the model in §1.7.1 minimal form and progress through the lifecycle as detail emerges. The narrative `capability` and `benefit` strings are retained throughout (per §1.7.2 / §1.9 rule 6).

#### Dispatch to `vse-stakeholder-elicitor`

When Step 1 has produced a register with two or more named personas, each carrying a role, key concerns, and a priority, dispatch the `vse-stakeholder-elicitor` subagent rather than drafting interviews and candidate needs inline. Each persona is analysed in its own isolated context, so the personas can be processed in parallel and the parent skill's context stays free for the engineer's review.

**What to pass.** A short message containing the system concept (one or two sentences), the persona list with role, concerns, and priority for each, and the paths to any prior specifications, regulatory references, or competitor documents the agent should consult.

**Return contract.** The subagent returns a suggestion-shaped markdown package: per-persona interview script, candidate need statements in stakeholder language attributed to each persona, and a cross-persona conflict summary. Present this verbatim to the engineer and explicitly invite editing. Only candidates that survive engineer review become stakeholder stories through Step 4. The subagent never writes files.

### Step 5: Optional use-case elaboration

Where a stakeholder story's capability is non-trivial (a capability that spans several actor-system interactions), declare a `use case def` per §1.4.5 in `model/core/use-cases/`. The use case names the story as its `objective`, which couples the story's `role` and the use case's `actor` by shared part-def typing (per §1.9 rule 5).

Use-case elaboration is permitted at the stakeholder level but not required. Many stakeholder stories never warrant a use case. Their `capability` and `acceptance` are sufficient.

Hand off the use-case body authoring to `@sysml2-cases`.

### Step 6: Validation plan

For each acceptance criterion, declare a `verification def` in `model/core/verification-validation/validation-cases/` whose `objective` includes a `verify` clause naming the acceptance subrequirement. Validation cases at this level exercise stakeholder intent, not system internals. The split between validation cases (§4) and verification cases (§5) is methodology discipline, not syntax.

Hand off the verification-case body detail to `@verification-validation`.

## Workflow B: §5 System Requirements Definition and Analysis

### Step 1: Derive system stories

For each stakeholder story in scope, derive one or more system stories in `model/core/stories/system/`. The derivation is recorded with both the `#derive` annotation on the derived requirement and an explicit `Derivation` connection to the original story (per §5.4.1 / spec §9.6).

A system story shall keep the **same** `role` as the stakeholder story (per §5.3). What changes is:

- the `capability` is restated in system-internal vocabulary,
- the `benefit` is sharpened from narrative toward a constraint over value properties,
- additional system stories may emerge from regulatory, fault-management, or self-test concerns that no stakeholder story generated.

Framed concerns propagate from the stakeholder story to the system story.

### Step 2: Formalise benefit and capability detail

Within each system story, formalise benefit and capability detail as `require constraint` clauses over value properties declared as attributes on the story (per §5.4.2). This step is critical. Per §0.3, the `benefit` constraint is the same model element that supplies assessment criteria during §6 trade studies. A story whose benefit cannot be formalised is permitted, but it cannot supply trade-study criteria.

State the formalisation pressure to the engineer when a benefit remains an informal string and the story is candidate input to a §6 trade study.

### Step 3: Story analysis

For each system story whose capability warrants behavioural detail, choose one of three analysis approaches per §5.4.3. The approaches are equivalent in outcome and complementary in practice:

| Capability character | Approach | Construct |
|---|---|---|
| Input-output transformation, batch processing | Flow-based | `action def` with item flows |
| Multi-step actor-system dialogue | Scenario-based | sequence-style action body |
| Mode-dependent behaviour, fault handling | State-based | `state def` |

Hand off the modelling detail to `@sysml2-behaviour` for `action def` and `state def` authoring, and to `@sysml2-cases` for `use case def` elaboration of a story.

### Step 4: Extend the logical data schema

Items discovered during analysis (a new flow needed by a derived behaviour) extend the `item def` set declared in §3 and may require the System Context to be updated in turn (per §5.4.4).

Hand off `item def` and flow-type authoring to `@sysml2-modelling`.

### Step 5: Dependability analysis

Safety, reliability, and security concerns are introduced as additional `concern def` instances with appropriate stakeholders (often a `Regulator` or a dedicated `SafetyOfficer` part def). Each concern is addressed by one or more new or extended system stories, following the §4 concern-and-story pattern (per §5.4.5).

The hazard-identification sub-workflow (FMEA, FTA, STPA, security threat models) is out of scope for this skill (per §5.7). Hand off to a dedicated hazard-analysis skill where one exists, otherwise flag the gap to the engineer and proceed with the concerns and stories the engineer supplies.

### Step 6: Verification plan

For each system-story acceptance criterion, declare a `verification def` in `model/core/verification-validation/verification-cases/` whose `objective` verifies the acceptance subrequirement (per §5.4.6). Verification cases at this level exercise system internals, distinct from §4 validation cases.

Hand off verification-case detail to `@verification-validation`.

## Workflow C: §3 System Context Completeness Check

Run on entry to §4 and again before transitioning a system story out of `inProgress`:

- **Stakeholder coverage.** Every stakeholder declared in `model/core/stakeholders/` that interacts with the system shall appear as an actor in the §3 System Context (per §3.6 rule 5). A stakeholder that does not interact (regulator, sponsor) need not appear, but flag any mismatch for the engineer to resolve.
- **Interface completeness.** Every interface declared on the system part shall be connected to at least one actor or carry a documenting comment justifying it as deferred (per §3.6 rule 3).
- **Item typing.** Every item flow shall declare an item type. No untyped flows are permitted (per §3.6 rule 4).

Hand off structural changes to `@sysml2-modelling` (interface and item authoring) and `@sysml2-model-structure` (package layout adjustment).

## Refusals

The skill refuses, by default and without exception, to:

1. **Reverse-engineer the Base Architecture.** Forward-going stories only. The skill shall not author "context stories" that record narrative around pre-existing decisions (per §2.1 corollary 2 and §2.6 rule 7). Context stories are permitted only on explicit human request with explicit confirmation of intent. The skill states this constraint when the engineer's prompt drifts toward justifying an existing architectural choice.
2. **Change the role on derivation.** A system story shall keep the same `role` as the stakeholder story it derives from (per §5.3). The skill refuses a derivation that swaps roles and asks the engineer either to add a fresh stakeholder story or to revise the stakeholder story whose role has changed.
3. **Drop narrative attributes.** The narrative `capability` and `benefit` strings shall be retained throughout the story's lifecycle (per §1.7.2 / §1.9 rule 6). The skill refuses any edit that removes them, even when typed bindings are added.
4. **Mark a story `ready` without acceptance.** A story shall declare at least one `acceptance` subrequirement in Given/When/Then form before transitioning out of `backlog` (per §1.4.4 / §1.9 rule 3). The skill refuses a status change that violates this rule and asks the engineer to author the missing acceptance criterion first.

## Hand-offs

| Topic | Route to |
|---|---|
| Branch and PR management for the story under edit | `@story-orchestrator` |
| Trade study against a formalised benefit constraint | `@architecture-design` |
| Verification or validation case body detail | `@verification-validation` |
| Action def, state def, sequence-style action body | `@sysml2-behaviour` |
| Use case elaboration of a story | `@sysml2-cases` |
| Item def, flow type, logical data schema | `@sysml2-modelling` |
| Package layout for new stakeholder set or concern register | `@sysml2-model-structure` |
| Edit to a baselined story | `@change-request` |

## Outputs

- `model/core/stakeholders/<role>.sysml`. One `part def` per stakeholder role.
- `model/core/concerns/<concern>.sysml`. One `concern def` per concern, with `subject`, `stakeholder`, and `require constraint`.
- `model/core/stories/stakeholder/<US_id>_<short>.sysml`. Stakeholder stories per §1, with `frame concern` to the concern register.
- `model/core/stories/system/<US_id>_<short>.sysml`. System stories with `#derive` annotation and explicit `Derivation` connection back to the originating stakeholder story.
- `model/core/use-cases/<name>.sysml`. Optional use-case elaborations whose `objective` names the story.
- `model/core/verification-validation/validation-cases/<name>.sysml`. Validation cases (§4) that verify acceptance criteria exercising stakeholder intent.
- `model/core/verification-validation/verification-cases/<name>.sysml`. Verification cases (§5) that verify acceptance criteria exercising system internals.
- Updated `model/core/context/architecture-context.sysml` where the stakeholder set extends the System Context with a previously unmodelled actor.

## Reference Bundle

`!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/needs-and-requirements.md`
