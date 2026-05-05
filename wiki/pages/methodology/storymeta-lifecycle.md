---
title: "StoryMeta status lifecycle and branch alignment"
slug: storymeta-lifecycle
type: process
layer: methodology
tags: [user-stories, lifecycle, story-meta, branch-workflow, ci]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §1.5 (Story Metadata)."
    raw: methodology/01-user-stories.md
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §8.7 (Story Lifecycle Alignment)."
    raw: methodology/08-project-structure.md
related:
  - methodology-overview
  - user-story-canonical-artefact
  - story-branch-pr-workflow
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, story-orchestrator, release-orchestrator]
---

# StoryMeta status lifecycle and branch alignment

## Purpose

A User Story is the elementary unit of stakeholder intent in the VSE methodology (see [[user-story-canonical-artefact]]). Its lifecycle is not a free-form workflow attached to the modeller's preference. The status carried by the story is bound, by specification, to the state of the git repository that hosts the story file. This page records the binding so that authoring tools, CI checks, and human reviewers share a single understanding of what each status means.

## StoryMeta metadata definition

Every User Story carries planning and lifecycle information through the `StoryMeta` metadata definition (§1.5):

```sysml
metadata def StoryMeta {
    attribute points   : Integer[0..1];
    attribute priority : Priority[0..1];
    attribute status   : StoryStatus;
    attribute invest   : InvestFlags[0..1];
}
```

`StoryMeta` is applied to every User Story instance through the `@StoryMeta { ... }` invocation. Of the four attributes, only `status` is mandatory. The remaining three (`points`, `priority`, `invest`) are optional and project-determined. Their absence does not invalidate a story, although the §8.6.2 readiness checklist requires `points`, `priority`, and `status` before a story can move from draft to ready review.

## The four valid statuses

`StoryStatus` admits exactly four values:

1. **backlog**, the story is a candidate theme that has not yet been committed to specification.
2. **ready**, the story has been authored and meets the well-formedness gates for planning, but no implementation work is in flight.
3. **inProgress**, the story is being worked on. This status has two sub-states (draft and review) distinguished by PR state, not by the value of `status` itself.
4. **done**, the story has been merged to `main` and is accepted.

There are no other values. A status outside this set is a model defect that the lint pass shall reject.

## Lifecycle alignment with repository state

§8.7 binds each status to a specific repository condition. The following table is the normative mapping:

| StoryMeta.status | Repository state |
|---|---|
| backlog | story does not yet exist as a file |
| ready | story file exists on `main`, no open branch |
| inProgress (draft) | story branch exists, draft PR open |
| inProgress (review) | story branch exists, PR marked ready |
| done | merged to `main`, branch deleted |

The two sub-states of `inProgress` share the same enumeration value. The distinction is read off the PR. A draft PR signals iterative work in flight. A PR marked ready signals that the §8.6.2 readiness checklist passes and the change awaits final approval.

The branch and pull-request mechanics that produce these states are specified in [[story-branch-pr-workflow]]. This page is concerned with the status mapping itself, not with the workflow that drives it.

## Transition rules

The status transitions are constrained as follows:

- **backlog to ready** when §1.9 well-formedness rules 3 and 4 are satisfied. Rule 3 requires at least one acceptance criterion. Rule 4 requires that `role` has been redefined with a concrete part definition. Until both hold, the story remains in backlog.
- **ready to inProgress** at the moment a story branch is created and a draft PR is opened against it. There shall be exactly one open draft PR per story branch.
- **inProgress (draft) to inProgress (review)** when the §8.6.2 story-readiness checklist passes for the story and the author marks the draft PR ready for review. The `status` value does not change at this transition. The PR state changes.
- **inProgress (review) to done** at PR merge. The branch is then deleted. The story file lands on `main` with `status = done`.

## CI enforcement

The mapping is enforced by repository tooling. A CI check shall flag any story where `StoryMeta.status` is inconsistent with the branch and PR state. For example, a story file present on `main` whose `status` reads `inProgress` is a defect: either the story is on a branch (and the file should not yet be on `main`) or the work is finished (and the status should be `done`).

The CI check is part of the story-readiness gate, not a separate audit. Inconsistencies surface at PR review and block merge until the author either updates the status or moves the file.

## Returning from done to inProgress

A story whose `status` has reached `done` shall not be moved back to `inProgress` by reopening the merged PR. When later validation (verification, integration, stakeholder review) surfaces an issue that requires the story to be reworked, the rework is performed on a new branch and through a new PR. The merged PR is left immutable as a record of the original acceptance.

This rule preserves the integrity of the merge history and keeps each PR scoped to a single review cycle. It also means that the story file on `main` may carry `status = inProgress` for short periods, namely while the rework branch is in flight, and that the CI check tolerates this when an open story branch and PR exist for the story.

## Implications for tooling and the engineer

Three implications follow:

- A status set by the engineer is a claim about repository state that the CI check verifies. Status is not a wish.
- The engineer cannot transition `ready` to `inProgress` by editing the story file alone. The branch and the draft PR are load-bearing. Without them, the status update is rejected.
- Done is durable. A story marked done remains marked done unless a new branch and a new PR carry it back through the lifecycle.

For the cross-cutting view of how stories sit in the broader methodology, see [[methodology-overview]].
