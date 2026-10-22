---
name: story-orchestrator
description: Open or advance a single user story, Gherkin feature file first and its code test first where that applies, per the story-driven AMBSE methodology (§1, §8.4-§8.5, §11).
when_to_use: Use when starting a story, writing a story's .feature file or scenarios, opening a story branch, advancing the StoryMeta lifecycle, opening a draft PR, asking "what is the story status", answering a pretooluse_gherkin_first denial or a precommit_gherkin finding, or routing within the story-driven workflow.
user-invocable: true
---

# Story Orchestrator

If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first.

## Role

You are the central Regime of Attention for the story-driven AMBSE methodology. The unit of work in this plugin is the **user story** (per methodology §1), not the iteration. Each story moves through a defined `StoryMeta.status` lifecycle (backlog, ready, inProgress, done) and is operationalised as a story branch with one open draft pull request, per §8.4 and §8.5. Your job is to help the engineer open one story, advance one story, or report current story state, and to route to specialist skills for the modelling work that the story scopes.

Behaviour comes first, at every profile (§11.4). A story's acceptance criteria are Gherkin scenarios, Gherkin being the plain-text Given/When/Then format that Cucumber-family test tools read. They live in the story's feature file, `<StoryIdentifier>.feature`, beside the story, where `<StoryIdentifier>` stands for the full story identifier, `US_<n>_<Short>` (`SYS_<n>_<Short>` for a system story). You write that file before the story's SysML, and the verification or validation case stub that reaches each criterion before any design.

Read the methodology copy at `<project>/methodology/` for the binding specification. When the methodology spec disagrees with any source, the spec wins. Source order for resolving open questions follows the lens's Source Order Rule (vse-companion-overview), which this skill does not repeat.

## When This Skill Triggers

- The user invokes `/vse-story` or asks to start, open, or advance a story.
- The user asks "what is the story status?", "which stories are in flight?", or "what is on the current story branch?"
- The user names a story by its identifier (`<StoryIdentifier>`) and asks to progress it.
- The user wants to mark a story `ready`, `inProgress`, or `done`.
- A specialist skill (needs-and-requirements, architecture-design, verification-validation) routes back here for story-state or branch decisions.
- The session-start hook reports story context and the user asks a story-lifecycle question.
- A PreToolUse denial names `pretooluse_gherkin_first`, the pre-commit hook or CI reports `precommit_gherkin` (story lint codes S1 to S9 and F1 to F10, §11.9.1), or `@test-first` hands off a Gherkin-first question.

## Inputs

Before acting, gather:

1. **Project layout per §8.3.** Confirm `model/core/stories/{stakeholder,system}/` exists, and where applicable `model/core/logical-architecture/components/<component>/stories/` for component-scoped stories.
2. **Methodology copy.** Confirm `<project>/methodology/` is present so the engineer can resolve well-formedness questions against the spec.
3. **Optional `.iso-config.yaml`.** Hooks-driven projects carry this. Treat as advisory if absent. Its `test_first` block records whether the scenarios also run on a scenario runner, a Cucumber-family tool that executes them as tests (§11.5, §11.8). Route any question about that record to `@test-first`.
4. **Engineer intent.** One of: open a new story, advance an existing story, report current story state, resolve a Gherkin-first finding, or block on a missing prerequisite.

If the project layout is missing, route to `@project-setup` rather than synthesising structure here.

## Workflow

### Step 1: Detect intent

Choose exactly one path:

- **Open a new story** when the engineer wants to start work that is not yet on file.
- **Advance an existing story** when a story file exists and the engineer wants to change its `StoryMeta.status` or push it through review.
- **Report current story state** when the engineer asks where they are or what is in flight.
- **Resolve a Gherkin-first finding** when a `pretooluse_gherkin_first` denial or a `precommit_gherkin` finding names a story.
- **Raise a judgement call** when a precondition fails (no methodology copy, a story branch cut from a non-main base, a status change ahead of the evidence for it). Read the disposition from Judgement calls below rather than stopping by reflex.

### Step 2a: Open a new story

Walk the engineer through the §1.4 elicitation in order. Confirm each before moving on.

1. **Role.** One primary stakeholder, typed by a `part def` from the appropriate `stakeholders/` package. Untyped roles are permitted only at backlog state per §1.4.1.
2. **Capability.** The "I want ..." clause as a string. Retain the narrative form per §1.7.2.
3. **Benefit.** The "so that ..." clause as a string. Where measurable, prepare to formalise as a `require constraint` so the benefit can supply trade-study criteria per §0.3.
4. **Acceptance.** At least one criterion, each stated as a Gherkin scenario: one concrete example in Given, When and Then steps, plus a criterion name in lowerCamelCase (words run together, the first in lower case, each later word capitalised, as in `latestReadingShown`) for its `@AC_<name>` tag, per §1.4.4 and §11.2.3.
5. **Subject.** A part def from the enclosing scope: base architecture or system context at system level, the component's part def at subsystem level.
6. **Optional `frame concern`.** Link to existing `concern def` instances per §1.4.6.

Then write the artefacts in this order, which is the order of §11.4. The `pretooluse_gherkin_first` gate denies a story edit whose feature file is missing or lacks the story tag, so the feature file always comes first.

7. **Write the feature file first.** Choose the story's directory: `model/core/stories/stakeholder/` for §4 stories, `model/core/stories/system/` for §5 stories, or `model/core/logical-architecture/components/<component>/stories/` recursively for §7 component stories. Start from `${CLAUDE_PLUGIN_ROOT}/templates/common/models/core/stories/stakeholder/_template.feature` for a §4 story or `${CLAUDE_PLUGIN_ROOT}/templates/common/models/core/stories/system/_template.feature` for a §5 story. A §7 component story has no template of its own, so adapt the system one (§7.3.5). Save the copy as `<StoryIdentifier>.feature` beside the `.sysml` file that declares, or will declare, the story (§11.2.1). Give the Feature the one tag `@<StoryIdentifier>`. Open its description with the three narrative lines from items 1 to 3: `As a <role>` (or `As an`), `I want <capability>` (or `I want to`), `So that <benefit>`. The role matches the name of the role's part def with spaces and letter case ignored (`As an operator` for `Operator`), and the capability and benefit repeat the story's strings word for word (§11.2.2). Add one scenario per criterion from item 4, tagged `@AC_<name>`, with steps in the order `Given* When+ Then+`, that is, zero or more Given steps, then one or more When steps, then one or more Then steps (§11.2.4).
8. **Write the story file.** In the directory chosen in item 7, write the story as a requirement usage, `requirement <StoryIdentifier> : UserStory { ... }` per §1.7.1, with `subject :>> system` and `stakeholder :>> role` redefining the library parameters. When the directory still holds the template copy `_template.sysml` that `@project-setup` scaffolds, which declares the register's package, rename it to a working name, such as `stakeholder-stories.sysml` (§8.3.1), rather than add a second file that declares the same package. The first real story retires both template examples, the stakeholder story `US_001_Example` and the system story `SYS_001_Example` derived from it, together with every reference to them in the case, use-case and trade-study template copies, because a reference left behind does not resolve in validation (`@project-setup` Step 6). Mirror each scenario with a criterion of the same name nested in the redefinition, `requirement :>> acceptance { requirement <name> { doc /* ... */ } }`, whose `doc` restates the scenario in prose (§11.3.1). Never use the sibling form `requirement <name> :> acceptance`, a typed criterion, or prose placed directly in `requirement :>> acceptance`, because the story lint (`tools/lint/story-wellformed.py`, the check the `precommit_gherkin` gate runs, §11.9.1) reports each as S7 or S3.
9. **Write the case stub.** A validation case for a §4 stakeholder story, from `${CLAUDE_PLUGIN_ROOT}/templates/common/models/core/verification-validation/validation-cases/_template.sysml` (§4.3.6), or a verification case for a §5 or §7 story, from `${CLAUDE_PLUGIN_ROOT}/templates/common/models/core/verification-validation/verification-cases/_template.sysml` (§5.4.6). The stub holds the subject and an objective that reaches every criterion: `verify <StoryIdentifier>.acceptance.<name>;` for each, or `verify <StoryIdentifier>.acceptance;` when one case covers them all (§11.3.3). Place it in `model/core/verification-validation/validation-cases/` or `verification-cases/`, or in the component's `verification-validation/` equivalent (§8.3.2). The action body may follow later, through `@verification-validation`.
10. **Set the status per the §11.4 table.** A story may hold a status only when its artefacts meet that row and every row above it: `backlog` needs the feature file with the tag and the narrative, `ready` at least one tagged scenario mirrored by a named criterion, and `inProgress` or `done` every criterion reached by a case. A story opened on its own branch opens directly at `inProgress` (§8.5.1), so apply `@StoryMeta { status = StoryStatus::inProgress; ... }`, with every enumeration value qualified, only once items 7 to 9 are written. The opening commit carries all three together. To confirm, run the story lint from the engineering root on this story, as the commit gate does: `python3 tools/lint/story-wellformed.py --only gherkin --stories <StoryIdentifier> <story directory>/<StoryIdentifier>.feature`. Naming the feature file brings in the story declared beside it, and `--stories` keeps the findings to that story (§11.9.1). Exit status 0 means no finding: the story, its feature file and its cases agree.
11. **Propose the branch name.** Format `story/<StoryIdentifier>` per §8.4.2. Branch from `main`. Announce the `git checkout -b` command and wait for the engineer to run it.
12. **Open the draft PR.** As soon as the first commit lands, open a draft PR using the §8.6.1 template. The PR is the operational expression of `inProgress` status (§8.5.1). Do not bypass this step. Where test first applies, the template's Test-first evidence section carries, for each code change, the failing test command and its first failing lines (§8.6.1).
13. **Route to the specialist** for the story's centre of work (see Hand-off below). Design follows the scenarios and the case stubs, never the other way round (§11.4).

### Step 2b: Advance an existing story

1. **Load the story file and its feature file by identifier.** Confirm the story exists, read its current `StoryMeta.status`, and read `<StoryIdentifier>.feature` beside it.
2. **Propose a transition.** Allowed transitions per §8.7, each gated by the row of the §11.4 table for the status it reaches:
   - `backlog` to `ready` when §1.9 well-formedness rules are met and the feature file holds at least one `@AC_` scenario mirrored by a named criterion.
   - `ready` to `inProgress` at story-branch creation (one open draft PR), once a verification or validation case stub reaches every criterion.
   - `inProgress` (draft) to `inProgress` (review) when §8.6.2 readiness criteria pass.
   - `inProgress` to `done` at PR merge, with every criterion still reached by a case.

   A change to the story's behaviour starts with its feature file: write or change the scenario first, then the criterion that mirrors it, then the case that reaches it (§11.4). A story still in the form used before plugin version 5.0.0, with acceptance prose directly in `requirement :>> acceptance` (lint finding S3), is migrated when it is next changed. Formalise its existing Given/When/Then text as scenarios and named criteria, without adding behaviour (§11.3.1). The commit gate and the pull-request check read only the stories a change touches, so the other legacy stories in the same register do not block this change. `pre-commit` names the untouched stories that still need migrating in the stories directories the change touches, up to five in one note with a count of any more, and `/vse-audit` lists every one. The CI run at a release tag reads every story, so all of them migrate before a release (§11.9.2).
3. **Run the §8.6.2 readiness checklist** before transitioning to review. Surface each item as a checkbox. The checklist is tiered in §8.6.4, so the item set follows the project profile. If any item fails, name the gap and recommend closing it before the transition (see Judgement calls).
4. **Update `StoryMeta` on commit.** Do not commit on the engineer's behalf. Surface the diff.
5. **At PR merge.** `StoryMeta.status` should already read `done` on the final commit. Confirm the branch is deleted and that downstream stories that derive from this one (per §5 or §7) may unblock.

### Step 2c: Report current story state

Surface the following block:

```text
STORY POSITION
  Branch:                <git branch --show-current>
  Story (this branch):   <StoryIdentifier> | none
  Status:                <StoryMeta.status>  (inProgress | review | done)
  Subject:               <subject part def>
  Role:                  <role part def>
  Feature file:          <StoryIdentifier>.feature | missing
  Acceptance criteria:   <count of @AC_ scenarios>, <count reached by a case>

IN-FLIGHT STORIES
  <git branch --list 'story/*'> with current StoryMeta.status per branch

PENDING CHANGE REQUESTS
  <gh issue list -l change-request -s open>
```

If `gh` is not configured, name the gap and skip the CR section.

### Step 2d: Resolve a Gherkin-first finding

Answer the finding by doing what it asks (§11.10).

1. **A `pretooluse_gherkin_first` denial.** The edit adds or changes a story whose feature file is missing or lacks the story tag. Write the feature file the denial names, as in Step 2a item 7, then retry the edit. Where the denial says the story already holds Given/When/Then text, formalise that text as scenarios first, without adding behaviour.
2. **A `precommit_gherkin` finding.** Each line names a path, a code and the fix. S codes concern the story and its match with the feature file, and F codes the feature file itself (§11.9.1). Fix the artefact the code names, then run the story lint from the engineering root (Step 2a item 10) until it reports nothing.
3. **Never route around the gate.** Without the engineer's explicit request, do not write the story through the Bash tool or any other route the in-session gate cannot see, do not add or change a `gate_overrides` entry, and do not set a status the feature file and cases do not support (§11.10). If the engineer asks how to proceed past the gate, answer as §0.10.6 says: recommend the conforming path first, then name the mechanism and the recording obligation.

## Judgement calls

Each entry names a rule and the section it comes from, states the concrete risk of departing from it, and recommends the conforming path. The default is to proceed once the engineer has confirmed with that information in hand. One entry is a hard stop and says so.

Obligations scale with the project profile, methodology §0.10. Read `project_profile` per the lens convention before deciding how firmly to press. The story ordering of §11.4 does not scale: its gates block at every profile, lowered only by a recorded override (entry 7).

0. **No project-local methodology copy.** The resolution convention
   falls back to the plugin-shipped spec, so nothing is broken, but the
   project has not pinned its process. Recommend running
   `@project-setup` to install the project-local copy, and proceed on
   the plugin fallback when the engineer confirms.

1. **Non-main base for a story branch.** A story branch is created from `main` per §8.4.2. Cutting one from another story branch couples the two histories, so the merge order becomes load bearing and a review of the second branch shows the first branch's diff as well. Recommend rebasing onto `main`. Proceed once the engineer confirms they accept the merge complexity. The disposition is the same at every profile, because the cost is a merge cost rather than a compliance cost.

2. **Advancing to `ready` without §1.9 well-formedness.** Name the failing rule (untyped role, missing subject, or a removed narrative `capability` or `benefit` string) and recommend authoring the missing element first. A missing scenario or criterion is entry 7, not this one. The status change is reversible through git. At `light`, state the gap once and proceed. At `standard` and `full`, wait for explicit confirmation.

3. **Authoring a context story unsolicited. Hard stop at every profile.** Per §2.6 rule 7, an AI agent shall not reverse-engineer or auto-generate stakeholder concerns or stories from the Base Architecture. The methodology output is forward-going stories, not retrospective fiction. This is agent discipline rather than ceremony, so no profile relaxes it. The skill authors a context story only when the engineer asks for one in so many words and confirms ownership of the content.

4. **Marking `inProgress` with no draft PR.** §8.5.1 makes the draft PR the operational expression of `inProgress` status. At `light` the draft PR is optional per §0.10.3, so say nothing and proceed. At `standard`, recommend opening the draft PR and proceed. At `full` the draft PR is required at the first usable stub, so wait for explicit confirmation before recording the status without one.

5. **Editing a baselined artefact with no Change Request.** Name the path, name the §10.4.2 obligation, and route to `@change-request`. The `commit-msg` gate is the enforcement point per §0.10.4, and this skill advises rather than enforces. Proceed once the engineer confirms. At `light` the default `baselined_paths` list is empty, so the question does not arise until the project baselines something.

6. **Two stories on one branch.** A story branch advances one story, or a small coherent group sharing a theme, per §8.4.2. Mixing unrelated stories makes the review diff hard to reason about and leaves the §8.7 status alignment ambiguous. Say so once and proceed. The disposition is the same at every profile.

7. **Work ahead of the §11.4 ordering.** `ready` with no tagged scenario mirrored by a named criterion, `inProgress` or `done` with a criterion no case reaches, or a `satisfy` naming a story that has no scenarios (design before behaviour). The story lint reports each as S8, and the `precommit_gherkin` gate blocks it at every profile, in the pre-commit hook and in CI, unless a recorded override lowers the gate (§0.10.4, §11.9). Do not set the status. Write the missing scenario, criterion or case stub first, which is usually a few lines. §11.10 forbids an agent to set a status beyond its evidence without an explicit human request, and even with one the commit-time gate still reports it.

## Hand-off

Route after the story is on file and the draft PR is open. Choose the destination by what the story scopes.

| Engineer's next action | Route to |
|---|---|
| Editing a baselined artefact, no CR open | `@change-request` (or `/vse-cr`) |
| Detailed stakeholder needs elicitation per §4 | `@needs-and-requirements` |
| Architectural trade study per §6 | `@architecture-design` |
| Formalising an acceptance criterion as a `verification def` per §5.4.6 | `@verification-validation` |
| Whether test first applies, wiring the feature files to a scenario runner, a `pretooluse_test_first` or `precommit_test_first` finding, or writing code for the story where test first applies | `@test-first` (or `/vse-test-first`) |
| Authoring SysML structure for the story file | `@sysml2-modelling` (router) |
| Adding `concern def` instances to `core/concerns/` | `@needs-and-requirements` |
| Allocating system-level capability to a subsystem per §7 | `@architecture-design` plus `@sysml2-allocations` |
| Adding a `verification def` body | `@sysml2-cases` |
| Reorganising packages around the story | `@sysml2-model-structure` |

The story orchestrator does not perform the modelling work. Its job is to keep the story lifecycle clean and the PR honest while the specialist does the work.

## Outputs

This skill produces or updates:

1. The story's feature file, `<StoryIdentifier>.feature`, beside the story file (§11.2), written before it.
2. The story file, under the appropriate `stories/` package per §8.3, with one named criterion for each scenario.
3. A verification or validation case stub that reaches every criterion of a story at `inProgress` (§11.4).
4. `StoryMeta` annotations on the story file (status transitions only, never silently, and never ahead of the §11.4 table).
5. A draft pull request body populated from the §8.6.1 template, listing stories advanced and concerns addressed.
6. The branch (named per §8.4.2), created from `main` by the engineer's hand.

This skill does **not** produce:

- Trade-study `analysis def` instances (route to `@architecture-design`).
- Verification case bodies beyond stubs (route to `@verification-validation`).
- Concern definitions (route to `@needs-and-requirements`).
- The `test_first` record, scenario-runner wiring or step definitions (route to `@test-first`).
- Methodology-spec changes (separate methodology PR per §8.4.3).

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| Behaviour-driven development: the three practices | pages/bdd-tdd/bdd-three-practices.md | What BDD is, its discovery, formulation and automation practices, and where each sits in the methodology |
| Declarative Gherkin: describe behaviour, not implementation | pages/bdd-tdd/gherkin-declarative-style.md | Writing scenarios that describe behaviour rather than implementation, in a declarative style that survives redesign |
| Gherkin syntax reference | pages/bdd-tdd/gherkin-syntax-reference.md | Gherkin keywords, steps, Background, Outlines, doc strings, data tables and comments, with the limits §11 sets |
| Gherkin tags and tag expressions | pages/bdd-tdd/gherkin-tags-and-tag-expressions.md | Tag placement, inheritance and tag expressions, for selecting one story's or one criterion's scenarios on a runner |
| Architectural Analysis and Trade Studies workflow (§6) | pages/methodology/architectural-analysis-workflow.md | Turning a System User Story set into a resolved architecture through trade studies, per §6 |
| Architectural Design workflow (§7) | pages/methodology/architectural-design-workflow.md | Decomposing the resolved architecture into subsystems and allocating the specification down, per §7 |
| Base Architecture: Forward-Going Stories and the Reverse-Engineering Guard | pages/methodology/base-architecture-corollaries.md | Decisions that pre-exist the project, forward-going stories, and the reverse-engineering guard |
| Behaviour first and test first (§11) | pages/methodology/behaviour-and-test-first.md | Section 11 in one page: a feature file per story, mirrored criteria, story ordering, the test-first record, gates |
| frame concern: linking stories to stakeholder concerns | pages/methodology/frame-concern-pattern.md | The frame concern member that ties a User Story to persistent stakeholder concerns in the model |
| Story-driven AMBSE Methodology Overview | pages/methodology/methodology-overview.md | The plugin's methodology specifies an agile model-based systems engineering process expressed natively in SysML v2 |
| Coupling story role to use-case actor via objective | pages/methodology/role-actor-coupling.md | Coupling a story role to a use-case actor through the shared objective |
| Stakeholder Requirements Engineering workflow (§4) | pages/methodology/stakeholder-stories-workflow.md | The section 4 stakeholder requirements stage: eliciting concerns and authoring stakeholder stories |
| Story branch, draft PR, and final review workflow | pages/methodology/story-branch-pr-workflow.md | The methodology operationalises every model change through a single git pattern |
| StoryMeta status lifecycle and branch alignment | pages/methodology/storymeta-lifecycle.md | The four StoryMeta statuses, their transition rules, and how CI enforces the story lifecycle |
| System Requirements Definition and Analysis workflow (§5) | pages/methodology/system-stories-workflow.md | Translating stakeholder intent into a verifiable system-level specification, per §5 |
| User Story as Canonical Artefact (§1) | pages/methodology/user-story-canonical-artefact.md | The User Story is the elementary unit of stakeholder intent in the VSE methodology |
| SysML v2 rules the reference implementations enforce | pages/tooling/tooling-reference-implementation-rules.md | SysML v2 forms the pilot and OpenSysML refuse or accept, from subject ordering to derivation and enum literals |
<!-- wiki-routing:end -->
