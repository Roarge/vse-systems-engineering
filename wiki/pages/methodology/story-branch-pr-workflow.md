---
title: "Story branch, draft PR, and final review workflow"
slug: story-branch-pr-workflow
type: process
layer: methodology
tags: [git-workflow, pull-request, branch-model, review-checklist, iso-29110]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §8.4-§8.6 (Branch Model, PR Workflow, Review Checklists)."
    raw: methodology/08-project-structure.md
related:
  - methodology-overview
  - user-story-canonical-artefact
  - storymeta-lifecycle
  - iso-29110-compliance-mapping
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, story-orchestrator, release-orchestrator, change-request, project-audit]
---

# Story branch, draft PR, and final review workflow

The methodology operationalises every model change through a single git pattern. A story branch is opened from `main`, a draft pull request is opened on the first commit, iterative review proceeds on the draft, and a squash-and-merge follows final review against a fixed checklist. This page summarises the binding rules from §8.4 to §8.6 of the methodology specification. See [[methodology-overview]] for the broader context, [[user-story-canonical-artefact]] for the story file these branches advance, and [[storymeta-lifecycle]] for how branch state maps to `StoryMeta.status`.

## Branch model (§8.4)

`main` is the project's accepted state. Direct commits are prohibited. Every commit on `main` shall pass repository-side validation, represent a methodology-conformant model, and be the result of a merged pull request that has passed final review. Hot-fixes follow the same workflow, simply at elevated priority.

Four kinds of feature branch are recognised, each with a fixed naming pattern:

- **Story branches** are the standard case. They advance one story or a small coherent group of stories through a workflow stage. The pattern is `story/<US_id>_<short-name>` for a single story (for example `story/US_042_AckFromDashboard`) or `story/<theme-name>` for a small group sharing a theme (for example `story/incident-response-stories`). A story branch is created from `main` at the moment the story transitions to `inProgress`, touches only the packages relevant to the story being advanced, carries one open pull request from creation onward (draft initially), and is deleted on merge.
- **Methodology branches** (`methodology/<topic>`) carry changes to the spec documents under `methodology/`. The PR workflow is identical, but methodology owners review rather than story owners.
- **Architectural branches** (`arch/<decision-name>`) carry §6 trade studies. These are typically longer-lived because variation modelling, candidate authoring, and resolution span several iterations. Final-review criteria are correspondingly stricter, as noted in §8.6.3.
- **Release branches** (`release/<tag>`) are optional and used only if the project produces tagged model releases.

## Draft PR opening (§8.5.1)

A draft pull request is opened as soon as the branch contains a usable stub, typically within the first commit. The intent is visibility, not completeness. The opening commit minimum is:

- the story file exists in the package appropriate to its level, meaning `model/core/stories/stakeholder/` for §4 stories, `model/core/stories/system/` for §5 stories, or `model/core/logical-architecture/components/<component>/stories/` (recursively) for §7 component stories,
- the story declares `role`, `capability`, `benefit`, and at least one `acceptance` criterion, even if textual,
- `StoryMeta.status` is set to `inProgress`.

Opening the draft PR triggers reviewer assignment from the relevant CODEOWNERS, populates the §8.6.1 PR template, and runs CI lint and well-formedness checks. CI failures surface as PR comments rather than blocking work.

## Iterative review on the draft (§8.5.2)

While the PR is in draft state, reviewers comment iteratively and authors push commits in response. There is no expectation of completeness or final-review readiness during draft. Comments are advisory and may be deferred or contested. The draft state communicates "this is in flight." CI checks run on every push but remain advisory in draft. Failing checks shall be visible but shall not block additional commits.

## Marking ready for review (§8.5.3)

The author marks the PR ready for review when all §8.6.2 story-readiness criteria are met and the author believes the story has reached its `done` state pending approval. Marking ready is the formal handoff from authoring to final review.

## Final review and merge (§8.5.4)

Final review applies the §8.6.3 reviewer checklist. At least one approval from a designated reviewer is required, and CI checks shall be passing. On approval, the PR is merged using **squash-and-merge**. The squashed commit message includes the story ID and a one-line summary, and the merge commit body lists the acceptance criteria addressed.

On merge:

- the branch is deleted automatically,
- `StoryMeta.status` is set to `done` in the merged content (this should already be set on the final commit),
- downstream stories that derive from this one (per §5 or §7) may proceed to `inProgress` if previously blocked.

If final review surfaces issues, the PR is converted back to draft. The status of the underlying story returns to `inProgress`.

## PR template (§8.6.1)

The repository's `.github/pull_request_template.md` shall include six sections: a story or change summary in narrative form for stories or rationale form for methodology and architectural branches, a list of stories advanced with status transitions, a list of `concern def` references for which framing is added or strengthened, an automated section showing files changed by Core package, the §8.6.2 author checklist, and the §8.6.3 reviewer checklist.

## Author readiness checklist (§8.6.2)

Before marking ready, the author confirms each item below for every story advanced by the PR:

1. The story declares `role`, typed by a `part def` from the appropriate stakeholders package (`core/stakeholders/` at system scope, the enclosing component's `stakeholders/` at component scope).
2. The story declares `capability` and `benefit` strings in the narrative form retained per §1.7.2.
3. The story declares `subject` referencing a part def from the enclosing scope (`core/base-architecture/` or `core/context/` for system stories, the component's part def for subsystem stories).
4. The story declares at least one `acceptance` criterion in Given/When/Then form or as a `verification def` reference.
5. If the story frames concerns, the corresponding `concern def`s exist in the appropriate concerns package.
6. If a use case declares this story as its `objective`, the use case exists with conformant `subject` and `actor` types per §1.4.5.
7. `StoryMeta.points`, `priority`, and `status` are set.
8. CI lint and well-formedness checks pass on the latest commit.
9. Cross-references resolve, with no dangling type names and no orphan stories.

## Reviewer checklist (§8.6.3)

In addition to confirming the §8.6.2 items, the reviewer checks:

1. **Methodology conformance.** The story conforms to §1 well-formedness rules (§1.9) and to the level-specific rules of §4, §5, and §7.
2. **Concern coverage.** No concern in the affected stakeholders' set is newly orphaned by the change.
3. **Trace integrity.** `derive` relationships are present where required: system stories derive from stakeholder stories per §5, and subsystem stories derive from system stories per §7. See [[iso-29110-compliance-mapping]] for how this satisfies the 29110 traceability tasks.
4. **No methodology drift.** Changes that imply methodology amendment shall be split into a separate methodology PR rather than smuggled through a story PR.
5. **Variation hygiene** (§6 stages only). Variations declare all feasible variants, `assert constraint` expresses cross-decision rules, and the resolved architecture redefines every variation.
6. **Verification-case stubs exist** for each acceptance criterion, even if the verification case body is deferred.
7. **The change is self-contained.** Story branches do not introduce half-finished work in unrelated packages. Unrelated improvements shall be raised as separate PRs.

For architectural branches, the reviewer additionally confirms that the trade-study `analysis def` is reproducible and that the selected variant's score advantage is documented in the PR description.
