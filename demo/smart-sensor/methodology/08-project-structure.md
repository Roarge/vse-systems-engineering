# 8. Project Structure and Git Workflow

## 8.1 Purpose

This section specifies how the methodology is operationalised in a git
repository. It defines the repository layout, the model package structure,
the branch model, the pull-request workflow, and the review checkpoints.

The package-structure pattern is adapted from SYSMOD §7.1 (Weilkiens, 2020).
Adaptations from the source are:

- The notation is SysML v2 textual, so packages are folders/files rather
  than tool-specific containers.
- `Stakeholders` and `Concerns` are promoted to first-class top-level
  packages within `Core`, reflecting the methodology's user-story-first
  treatment of stakeholder needs (§1.4.6).
- `Requirements` is renamed `Stories` and substructured by level
  (stakeholder / system / subsystem), reflecting the inversion in §0.1.
- `UseCases` is preserved but treated as elaborations of stories'
  capabilities (per §1.4.5), not as primary requirement carriers.
- Variations get a top-level package because the trade-study mechanism in
  §6 is variation-based.

## 8.2 Repository Layout

A project repository shall use the following layout:

```text
project-root/
├── README.md
├── CONTRIBUTING.md                 # branch/PR workflow rules
├── .github/
│   ├── pull_request_template.md    # PR template embedding §8.6 checklists
│   └── CODEOWNERS                  # ownership per package (optional)
├── methodology/                    # this specification + amendments
│   ├── 00-methodology-overview.md
│   ├── 01-user-stories.md
│   ├── …                           # 02 … 07 sections, drafted iteratively
│   └── 08-project-structure.md
├── model/
│   ├── core/                       # mirrors <Project>_Core (§8.3.1)
│   ├── variations/                 # mirrors <Project>_Variations
│   ├── library/                    # MBSEMethodology library (§0.8)
│   └── sandbox/                    # experimental work, not part of spec
├── sketches/                       # diagrams, hand sketches, images
├── tools/                          # scripts: lints, build, validation
└── docs/                           # rendered/derived artefacts
```

**Notes on the layout:**

- `methodology/` carries the spec documents (this file, §1, §2 … §7). The
  spec is part of the repo because the methodology can evolve; changes to
  the methodology shall use the same PR workflow as model changes.
- `model/` is the SysML v2 model proper. Each package corresponds to a
  folder; each package member that warrants its own file is a `.sysml`
  file in that folder.
- `sandbox/` is for experimentation. Sandbox content shall not be
  imported by `model/core/` or `model/variations/`. Sandbox files may
  break the well-formedness rules elsewhere required.
- `library/` is reserved for the methodology's eventual SysML v2 library
  (per §0.8). Until then it contains stubs for `UserStory`, `StoryMeta`,
  and the methodology's other reusable elements.
- `tools/` is for repository-side automation (linters, validators,
  diagram generators). It is not part of the model.

## 8.3 Model Package Structure

### 8.3.1 The `Core` package — system level

`Core` contains the project's modelled artefacts. At the *system level*
the structure is:

```text
model/core/
├── stakeholders/                   # part defs: stakeholder role types
├── concerns/                       # concern defs (per §1.4.6, sysmlv2 §32.5)
├── base-architecture/              # §2 — pre-existing platform decisions
├── context/                        # §3 — System Context (actors + interfaces)
├── domain/                         # glossary, item defs, common value types
├── stories/
│   ├── stakeholder/                # §4 stories (UserStory specialisations)
│   └── system/                     # §5 stories (derive from stakeholder)
├── use-cases/                      # §1.4.5 elaborations of system stories
├── functional-architecture/        # §6 functions and their properties
├── logical-architecture/           # §6 selected logical architecture
│   ├── interface-types/            # interface defs across components
│   ├── allocations/                # function-to-component allocations
│   ├── architecture-context.sysml  # the LA's own context view
│   └── components/                 # one folder per identified component
│       ├── <component-a>/          # ← recursive structure (see §8.3.2)
│       └── <component-b>/
├── product-architecture/           # §7 physical decomposition
├── parametrics/                    # constraint defs, analysis cases
├── processes/                      # system-level workflows / behaviours
├── verification-validation/
│   ├── verification-cases/         # exercise the system model
│   └── validation-cases/           # exercise stakeholder intent
└── core.sysml                      # top-level package declaration + imports
```

Each subfolder corresponds to a SysML v2 package nested under
`<Project>_Core`. The folder/file split is for git diff hygiene; the model
itself is one logical namespace.

Subsystem-level artefacts do not appear at this level. They live inside
the components that own them, scoped under
`logical-architecture/components/<component>/`. The recursive structure
that applies inside each component folder is specified in §8.3.2.

### 8.3.2 Recursive component nesting

A component identified during §7 is itself a system at its own scope.
Its specification artefacts therefore mirror the system-level Core
package, with the recursive structure living inside
`logical-architecture/components/<component-name>/`. This is the
operational expression of §0.6.7 step 5: the full §1 specification
applies at every level of decomposition.

A component folder contains those Core sub-packages that are
component-specific:

```text
logical-architecture/components/<component-a>/
├── stakeholders/                   # component's stakeholder views (often a subset
│                                   #   of system-level stakeholders, plus sibling
│                                   #   components and the parent system)
├── concerns/                       # component-specific concerns
├── context/                        # component's view of its environment
├── stories/                        # component's stories — at this depth these
│                                   #   are the subsystem stories of §0.6.7
├── use-cases/                      # component-specific elaborations
├── functional-architecture/        # component's functions (if needed at scope)
├── logical-architecture/           # ← recurses if the component decomposes further
│   ├── interface-types/
│   ├── allocations/
│   ├── architecture-context.sysml
│   └── components/                 # ← recursion continues here
│       └── <sub-component>/
└── verification-validation/
    ├── verification-cases/
    └── validation-cases/
```

**What is *not* replicated at component scope.** Some foundational
packages are inherited from the enclosing scope rather than redefined:

- `base-architecture/` — the platform applies system-wide; components
  reference the system's base architecture without redefining it.
- `domain/` — the project glossary, item defs, and common value types
  are shared. Component-specific items belong in the component's own
  scope, but they extend the system domain rather than replace it.
- `product-architecture/` — physical decomposition is typically
  aggregated at the system level only.

**SysML v2 package mirroring.** Folder paths and SysML v2 qualified
names mirror each other:

```sysml
package <PROJ_Core> Aiwell_Core {
    package <PROJ_LA> Aiwell_LogicalArchitecture {
        package <CompA_LA> SnowMeltController_LogicalArchitecture {
            package <CompA_Reqs> SnowMeltController_Stories { /* … */ }
            package <CompA_Sub_LA> SnowMeltController_LogicalArchitecture {
                package <Pump_LA> Pump_LogicalArchitecture {
                    package <Pump_Reqs> Pump_Stories { /* … */ }
                }
            }
        }
    }
}
```

A subsystem story at depth *n* lives in the package qualified by all
the component names from the system root downward. The depth of
nesting is bounded only by the depth of decomposition.

**When recursion stops.** Recursion terminates at one of two conditions:

1. The component is *terminal* — no further decomposition is warranted
   for the current iteration. The component folder will lack a
   `logical-architecture/` sub-folder; `stories/` and
   `verification-validation/` may still be populated.
2. The component is *handed off* to detailed design (§0.9 — out of
   scope for this methodology). The handoff package contains the
   subsystem specification; further decomposition is the receiving
   discipline's responsibility.

**Variations at component scope.** A component may also have its own
`variations/` folder if the component is itself the subject of a trade
study. Component-scope variations are independent of the system-level
`model/variations/` package and reside inside the component folder.
The §6 trade-study mechanism applies recursively along with everything
else.

### 8.3.3 The `Variations` package

```text
model/variations/
├── trade-studies/                  # §6 analysis defs per decision point
├── decision-points/                # variation defs (one file per decision)
├── candidate-variants/             # variant defs grouped by decision point
└── resolved/                       # specialisations that redefine variations
```

Trade-study analysis cases reside here rather than in `parametrics/` so
that the architectural decision history is a discoverable, browsable
artefact distinct from general analyses. Component-scope trade studies
follow the same internal structure but reside inside the component
folder per §8.3.2.

### 8.3.4 Naming conventions

- **Folder and file names:** lowercase kebab-case (`base-architecture`,
  `system-stories.sysml`). Git-friendly across platforms.
- **SysML v2 package names:** PascalCase with project-name prefix and
  underscore separator, matching SYSMOD convention
  (`FFDS_BaseArchitecture`, `Aiwell_SystemContext`). The textual short
  name (e.g., `<DSBA>`) may be used in cross-references.
- **One artefact per file** when the artefact is a top-level definition
  likely to be modified independently (a stakeholder story, a concern, a
  use case, a major part def). Group small related elements (item defs,
  enumerations) in one file per category.

## 8.4 Branch Model

### 8.4.1 `main`

`main` is the project's accepted state. Every commit on `main` shall:

- pass all repository-side validation (lints, model well-formedness
  checks);
- represent a methodology-conformant model;
- be the result of a merged pull request that has passed final review.

Direct commits to `main` are prohibited. Hot-fixes are not exempt; they
follow the same PR workflow with elevated priority.

### 8.4.2 Story branches

The standard branch is a **story branch**, dedicated to advancing one
story or a small coherent group of stories through a workflow stage.
Branch name pattern:

```text
story/<US_id>_<short-name>          # single story
story/<theme-name>                  # small group sharing a theme
```

Examples: `story/US_042_AckFromDashboard`,
`story/incident-response-stories`.

A story branch:

- is created from `main` at the moment the story transitions to
  `inProgress`;
- shall touch only the packages relevant to the story being advanced;
- carries one open pull request from creation onward (draft initially);
- is deleted on merge.

### 8.4.3 Other branch kinds

- **Methodology branches** (`methodology/<topic>`) — for changes to the
  spec documents in `methodology/`. Same PR workflow, but reviewed by
  methodology owners rather than story owners.
- **Architectural branches** (`arch/<decision-name>`) — for §6 trade
  studies. Typically longer-lived because variation modelling, candidate
  authoring, and resolution span several iterations. Final-review
  criteria are correspondingly stricter (§8.6.3).
- **Release branches** (`release/<tag>`) — used only if the project
  produces tagged releases of the model. Optional.

## 8.5 Pull Request Workflow

A story branch always carries an open pull request. The PR is the unit of
review and the operational expression of the story's `inProgress` status.

### 8.5.1 Draft PR opening

A draft PR shall be opened **as soon as the branch contains a usable
stub** — typically within the first commit. The intent is visibility,
not completeness. The opening commit minimum is:

- the story file exists in the package appropriate to its level —
  `model/core/stories/stakeholder/` for §4 stories,
  `model/core/stories/system/` for §5 stories, or
  `model/core/logical-architecture/components/<component>/stories/`
  (recursively) for §7 component stories;
- the story declares `role`, `capability`, `benefit`, and at least one
  `acceptance` criterion (even if textual);
- `StoryMeta.status` is set to `inProgress`.

Opening the draft PR triggers:

- assignment of reviewers from the relevant CODEOWNERS;
- the PR template (§8.6.1) is populated;
- CI runs the lint and well-formedness checks; failures surface as PR
  comments rather than blocking work.

### 8.5.2 Iterative review on the draft PR

While the PR is in draft state, reviewers comment iteratively. Authors
push commits in response. There is no expectation of completeness or
final-review readiness during draft. Comments are advisory and may be
deferred or contested. The draft state communicates "this is in flight."

CI checks run on every push but are advisory in draft state. Failing
checks shall be visible but shall not block additional commits.

### 8.5.3 Marking ready for review

The author marks the PR ready for review when:

- all §8.6.2 story-readiness criteria are met;
- the author believes the story has reached its `done` state pending
  approval.

Marking ready is the formal handoff from authoring to final review.

### 8.5.4 Final review and merge

Final review applies the §8.6.3 checklist. At least one approval from a
designated reviewer is required. CI checks shall be passing.

On approval, the PR is merged using **squash-and-merge**. The squashed
commit message includes the story ID and a one-line summary; the merge
commit body lists the acceptance criteria addressed.

On merge:

- the branch is deleted automatically;
- `StoryMeta.status` is set to `done` in the merged content (this should
  already be set on the final commit);
- downstream stories that derive from this one (per §5 / §7) may proceed
  to `inProgress` if previously blocked.

If final review surfaces issues, the PR is converted back to draft. The
status of the underlying story returns to `inProgress`.

## 8.6 Review Checklists

### 8.6.1 PR template (`.github/pull_request_template.md`)

The PR template shall include the following sections:

- **Story or change summary** — one paragraph; the story's narrative form
  for stories, or the change rationale for methodology/architectural
  branches.
- **Stories advanced** — list of story IDs and status transitions.
- **Concerns addressed** — list of `concern def` references for which
  framing is added or strengthened.
- **Files changed by package** — automated section showing which Core
  packages are touched.
- **Draft PR checklist** (§8.6.2) — author confirms each item before
  marking ready.
- **Final review checklist** (§8.6.3) — reviewer confirms each item
  before approving.

### 8.6.2 Story-readiness checklist (author, before marking ready)

A story is ready for final review when, for each story advanced by the
PR:

1. Story declares `role`, typed by a `part def` from the appropriate
   stakeholders package — `core/stakeholders/` at system scope, or
   the enclosing component's `stakeholders/` at component scope.
2. Story declares `capability` and `benefit` strings (narrative form
   retained per §1.7.2).
3. Story declares `subject` referencing a part def from the enclosing
   scope — `core/base-architecture/` or `core/context/` for system
   stories, the component's part def from
   `core/logical-architecture/components/<component>/` for subsystem
   stories.
4. Story declares at least one `acceptance` criterion in Given/When/Then
   form or as a `verification def` reference.
5. If the story frames concerns, the `concern def`s exist in the
   appropriate concerns package — `core/concerns/` at system scope, or
   the enclosing component's `concerns/` at component scope.
6. If a use case declares this story as its `objective`, the use case
   exists and its `subject` and `actor` types conform to the story's
   `subject` and `role` types per §1.4.5.
7. `StoryMeta.points`, `priority`, and `status` are set.
8. CI lint and well-formedness checks pass on the latest commit.
9. Cross-references resolve (no dangling type names, no orphan stories).

### 8.6.3 Final review checklist (reviewer, before approving)

In addition to confirming the §8.6.2 items:

1. **Methodology conformance.** The story conforms to §1 well-formedness
   rules (§1.9) and to the level-specific rules of §4 / §5 / §7.
2. **Concern coverage.** No concern in the affected stakeholders' set is
   newly orphaned by this change.
3. **Trace integrity.** `derive` relationships are present where
   required: system stories derive from stakeholder stories (§5);
   subsystem stories derive from system stories (§7).
4. **No methodology drift.** Changes that imply methodology amendment
   shall be split into a separate methodology PR rather than smuggled
   through a story PR.
5. **Variation hygiene** (§6 stages only). Variations declare all
   feasible variants; `assert constraint` expresses cross-decision
   rules; the resolved architecture redefines every variation.
6. **Verification-case stubs exist** for each acceptance criterion, even
   if the verification case body is deferred.
7. **The change is self-contained.** Story branches do not introduce
   half-finished work in unrelated packages. Unrelated improvements
   shall be raised as separate PRs.

For architectural branches (§8.4.3), the reviewer additionally confirms
that the trade-study `analysis def` is reproducible and that the
selected variant's score advantage is documented in the PR description.

## 8.7 Story Lifecycle Alignment

The story lifecycle (per `StoryMeta.status`) maps onto the branch/PR
state as follows:

| `StoryMeta.status` | Repository state | Notes |
|---|---|---|
| `backlog` | story does not yet exist as a file | candidate themes only |
| `ready` | story file exists on `main`; no open branch | story is queued; no work in flight |
| `inProgress` | story branch exists; draft PR open | work in flight; iterative review |
| `inProgress` (review) | branch exists; PR marked ready | awaiting final approval |
| `done` | merged to `main`; branch deleted | story is accepted |

The mapping is enforced by repository tooling: a CI check shall flag any
story where `StoryMeta.status` is inconsistent with branch/PR state. For
example, a story on `main` with `status = inProgress` is a defect.

Stories whose `status` returns from `done` to `inProgress` (because
later validation surfaced an issue) shall do so via a new branch and a
new PR, not by reopening a merged one.

## 8.8 Out of Scope

The following operational topics are not specified by this section and
are project-determined:

- Specific CI tooling (the methodology assumes a CI capable of running
  SysML v2 validation; choice of platform is project-determined).
- Specific code-owner assignments and reviewer-pool composition.
- Iteration length and ceremonies (sprints, stand-ups, retrospectives).
  The story lifecycle is iteration-agnostic.
- Issue tracker integration. If issues are tracked outside the repo
  (Jira, Linear, GitHub Issues), the story file's metadata may carry an
  external ID; the form of that integration is project-determined.

---

*End of Section 8.*
