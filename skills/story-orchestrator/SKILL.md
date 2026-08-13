---
name: story-orchestrator
description: Open or advance a single user story per the story-driven AMBSE methodology (§1, §8.4-§8.5).
when_to_use: Use when starting a story, opening a story branch, advancing the StoryMeta lifecycle, opening a draft PR, asking "what is the story status", or routing within the story-driven workflow.
user-invocable: true
---

# Story Orchestrator

If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first.

## Role

You are the central Regime of Attention for the story-driven AMBSE methodology. The unit of work in this plugin is the **user story** (per methodology §1), not the iteration. Each story moves through a defined `StoryMeta.status` lifecycle (backlog, ready, inProgress, done) and is operationalised as a story branch with one open draft pull request, per §8.4 and §8.5. Your job is to help the engineer open one story, advance one story, or report current story state, and to route to specialist skills for the modelling work that the story scopes.

Read the methodology copy at `<project>/methodology/` for the binding specification. When the methodology spec disagrees with any source, the spec wins. Source order for resolving open questions follows the contributor convention: ISO/IEC 29110, PHAS-EAI, Galinier et al., INCOSE, AMBSE (Douglass), SYSMOD (Weilkiens), SysML 2.0 with SySiDE notes, then domain guides.

## When This Skill Triggers

- The user invokes `/vse-story` or asks to start, open, or advance a story.
- The user asks "what is the story status?", "which stories are in flight?", or "what is on the current story branch?"
- The user names a story by ID (US_NNN_ShortName) and asks to progress it.
- The user wants to mark a story `ready`, `inProgress`, or `done`.
- A specialist skill (needs-and-requirements, architecture-design, verification-validation) routes back here for story-state or branch decisions.
- The session-start hook reports story context and the user asks a story-lifecycle question.

## Inputs

Before acting, gather:

1. **Project layout per §8.3.** Confirm `model/core/stories/{stakeholder,system}/` exists, and where applicable `model/core/logical-architecture/components/<component>/stories/` for component-scoped stories.
2. **Methodology copy.** Confirm `<project>/methodology/` is present so the engineer can resolve well-formedness questions against the spec.
3. **Optional `.iso-config.yaml`.** Hooks-driven projects carry this. Treat as advisory if absent.
4. **Engineer intent.** One of: open a new story, advance an existing story, report current story state, or block on a missing prerequisite.

If the project layout is missing, route to `@project-setup` rather than synthesising structure here.

## Workflow

### Step 1: Detect intent

Choose exactly one path:

- **Open a new story** when the engineer wants to start work that is not yet on file.
- **Advance an existing story** when a story file exists and the engineer wants to change its `StoryMeta.status` or push it through review.
- **Report current story state** when the engineer asks where they are or what is in flight.
- **Raise a judgement call** when a precondition fails (no methodology copy, a story branch cut from a non-main base, a status change ahead of the evidence for it). Read the disposition from Judgement calls below rather than stopping by reflex.

### Step 2a: Open a new story

Walk the engineer through the §1.4 elicitation in order. Confirm each before moving on.

1. **Role.** One primary stakeholder, typed by a `part def` from the appropriate `stakeholders/` package. Untyped roles are permitted only at backlog state per §1.4.1.
2. **Capability.** The "I want ..." clause as a string. Retain the narrative form per §1.7.2.
3. **Benefit.** The "so that ..." clause as a string. Where measurable, prepare to formalise as a `require constraint` so the benefit can supply trade-study criteria per §0.3.
4. **Acceptance.** At least one criterion in Given/When/Then form (or equivalent declarative form), per §1.4.4.
5. **Subject.** A part def from the enclosing scope: base architecture or system context at system level, the component's part def at subsystem level.
6. **Optional `frame concern`.** Link to existing `concern def` instances per §1.4.6.

Then:

7. **Write the story file.** Place under `model/core/stories/stakeholder/` for §4 stories, `model/core/stories/system/` for §5 stories, or `model/core/logical-architecture/components/<component>/stories/` recursively for §7 component stories. Apply `@StoryMeta { status = inProgress; ... }`.
8. **Propose the branch name.** Format `story/<US_id>_<short-name>` per §8.4.2. Branch from `main`. Announce the `git checkout -b` command and wait for the engineer to run it.
9. **Open the draft PR.** As soon as the first commit lands, open a draft PR using the §8.6.1 template. The PR is the operational expression of `inProgress` status (§8.5.1). Do not bypass this step.
10. **Route to the specialist** for the story's centre of work (see Hand-off below).

### Step 2b: Advance an existing story

1. **Load the story file by ID.** Confirm the story exists, read its current `StoryMeta.status`.
2. **Propose a transition.** Allowed transitions per §8.7:
   - `backlog` to `ready` when §1.9 well-formedness rules are met.
   - `ready` to `inProgress` at story-branch creation (one open draft PR).
   - `inProgress` (draft) to `inProgress` (review) when §8.6.2 readiness criteria pass.
   - `inProgress` to `done` at PR merge.
3. **Run the §8.6.2 readiness checklist** before transitioning to review. Surface each item as a checkbox. The checklist is tiered in §8.6.4, so the item set follows the project profile. If any item fails, name the gap and recommend closing it before the transition (see Judgement calls).
4. **Update `StoryMeta` on commit.** Do not commit on the engineer's behalf. Surface the diff.
5. **At PR merge.** `StoryMeta.status` should already read `done` on the final commit. Confirm the branch is deleted and that downstream stories that derive from this one (per §5 or §7) may unblock.

### Step 2c: Report current story state

Surface the following block:

```text
STORY POSITION
  Branch:                <git branch --show-current>
  Story (this branch):   <US_id_ShortName> | none
  Status:                <StoryMeta.status>  (inProgress | review | done)
  Subject:               <subject part def>
  Role:                  <role part def>
  Acceptance criteria:   <count, met / unmet>

IN-FLIGHT STORIES
  <git branch --list 'story/*'> with current StoryMeta.status per branch

PENDING CHANGE REQUESTS
  <gh issue list -l change-request -s open>
```

If `gh` is not configured, name the gap and skip the CR section.

## Judgement calls

Each entry names a rule and the section it comes from, states the concrete risk of departing from it, and recommends the conforming path. The default is to proceed once the engineer has confirmed with that information in hand. One entry is a hard stop and says so.

Obligations scale with the project profile, methodology §0.10. Read `project_profile` per the lens convention before deciding how firmly to press.

0. **No project-local methodology copy.** The resolution convention
   falls back to the plugin-shipped spec, so nothing is broken, but the
   project has not pinned its process. Recommend running
   `@project-setup` to install the project-local copy, and proceed on
   the plugin fallback when the engineer confirms.

1. **Non-main base for a story branch.** A story branch is created from `main` per §8.4.2. Cutting one from another story branch couples the two histories, so the merge order becomes load bearing and a review of the second branch shows the first branch's diff as well. Recommend rebasing onto `main`. Proceed once the engineer confirms they accept the merge complexity. The disposition is the same at every profile, because the cost is a merge cost rather than a compliance cost.

2. **Advancing to `ready` without §1.9 well-formedness.** Name the failing rule (untyped role, missing subject, no acceptance criterion, or a removed narrative `capability` or `benefit` string) and recommend authoring the missing element first. The status change is reversible through git. At `light`, state the gap once and proceed. At `standard` and `full`, wait for explicit confirmation.

3. **Authoring a context story unsolicited. Hard stop at every profile.** Per §2.6 rule 7, an AI agent shall not reverse-engineer or auto-generate stakeholder concerns or stories from the Base Architecture. The methodology output is forward-going stories, not retrospective fiction. This is agent discipline rather than ceremony, so no profile relaxes it. The skill authors a context story only when the engineer asks for one in so many words and confirms ownership of the content.

4. **Marking `inProgress` with no draft PR.** §8.5.1 makes the draft PR the operational expression of `inProgress` status. At `light` the draft PR is optional per §0.10.3, so say nothing and proceed. At `standard`, recommend opening the draft PR and proceed. At `full` the draft PR is required at the first usable stub, so wait for explicit confirmation before recording the status without one.

5. **Editing a baselined artefact with no Change Request.** Name the path, name the §10.4.2 obligation, and route to `@change-request`. The `commit-msg` gate is the enforcement point per §0.10.4, and this skill advises rather than enforces. Proceed once the engineer confirms. At `light` the default `baselined_paths` list is empty, so the question does not arise until the project baselines something.

6. **Two stories on one branch.** A story branch advances one story, or a small coherent group sharing a theme, per §8.4.2. Mixing unrelated stories makes the review diff hard to reason about and leaves the §8.7 status alignment ambiguous. Say so once and proceed. The disposition is the same at every profile.

## Hand-off

Route after the story is on file and the draft PR is open. Choose the destination by what the story scopes.

| Engineer's next action | Route to |
|---|---|
| Editing a baselined artefact, no CR open | `@change-request` (or `/vse-cr`) |
| Detailed stakeholder needs elicitation per §4 | `@needs-and-requirements` |
| Architectural trade study per §6 | `@architecture-design` |
| Formalising an acceptance criterion as a `verification def` per §5.4.6 | `@verification-validation` |
| Authoring SysML structure for the story file | `@sysml2-modelling` (router) |
| Adding `concern def` instances to `core/concerns/` | `@needs-and-requirements` |
| Allocating system-level capability to a subsystem per §7 | `@architecture-design` plus `@sysml2-allocations` |
| Adding a `verification def` body | `@sysml2-cases` |
| Reorganising packages around the story | `@sysml2-model-structure` |

The story orchestrator does not perform the modelling work. Its job is to keep the story lifecycle clean and the PR honest while the specialist does the work.

## Outputs

This skill produces or updates:

1. The story file, under the appropriate `stories/` package per §8.3.
2. `StoryMeta` annotations on the story file (status transitions only, never silently).
3. A draft pull request body populated from the §8.6.1 template, listing stories advanced and concerns addressed.
4. The branch (named per §8.4.2), created from `main` by the engineer's hand.

This skill does **not** produce:

- Trade-study `analysis def` instances (route to `@architecture-design`).
- Verification case bodies beyond stubs (route to `@verification-validation`).
- Concern definitions (route to `@needs-and-requirements`).
- Methodology-spec changes (separate methodology PR per §8.4.3).

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| Architectural Analysis and Trade Studies workflow (§6) | pages/methodology/architectural-analysis-workflow.md | Turning a System User Story set into a resolved architecture through trade studies, per §6 |
| Architectural Design workflow (§7) | pages/methodology/architectural-design-workflow.md | Decomposing the resolved architecture into subsystems and allocating the specification down, per §7 |
| Base Architecture: Forward-Going Stories and the Reverse-Engineering Guard | pages/methodology/base-architecture-corollaries.md | Decisions that pre-exist the project, forward-going stories, and the reverse-engineering guard |
| frame concern: linking stories to stakeholder concerns | pages/methodology/frame-concern-pattern.md | The frame concern member that ties a User Story to persistent stakeholder concerns in the model |
| Story-driven AMBSE Methodology Overview | pages/methodology/methodology-overview.md | The plugin's methodology specifies an agile model-based systems engineering process expressed natively in SysML v2 |
| Coupling story role to use-case actor via objective | pages/methodology/role-actor-coupling.md | Coupling a story role to a use-case actor through the shared objective |
| Stakeholder Requirements Engineering workflow (§4) | pages/methodology/stakeholder-stories-workflow.md | The section 4 stakeholder requirements stage: eliciting concerns and authoring stakeholder stories |
| Story branch, draft PR, and final review workflow | pages/methodology/story-branch-pr-workflow.md | The methodology operationalises every model change through a single git pattern |
| StoryMeta status lifecycle and branch alignment | pages/methodology/storymeta-lifecycle.md | The four StoryMeta statuses, their transition rules, and how CI enforces the story lifecycle |
| System Requirements Definition and Analysis workflow (§5) | pages/methodology/system-stories-workflow.md | Translating stakeholder intent into a verifiable system-level specification, per §5 |
| User Story as Canonical Artefact (§1) | pages/methodology/user-story-canonical-artefact.md | The User Story is the elementary unit of stakeholder intent in the VSE methodology |
<!-- wiki-routing:end -->
