---
description: Plan, baseline, or report on a release. Groups stories and features into a release scope, drafts the release plan markdown, and manages the baseline tag per the methodology.
argument-hint: "[optional release tag, scope hint, or operation: plan | baseline | report]"
---

Invoke the `vse-systems-engineering:release-orchestrator` skill to
manage a release per §10 (Project Management) of the methodology
specification at `<project>/methodology/10-project-management.md`.

Pass the user-supplied arguments through as additional context for the skill:

$ARGUMENTS

The skill will:

- Default to reporting the current release scope (open release plan,
  story IDs in scope by `StoryMeta.status`, outstanding Change
  Requests, baseline tag history) when no operation is specified.
- For *plan*: elicit the release tag (e.g., `release-v1.0`), draft
  the release plan markdown under `docs/releases/<tag>.md`, propose
  a story set drawn from `done` stories on `main` and any `ready`
  stories targeted for the release, and propose a milestone
  schedule consistent with §10.3.1 milestones.
- For *baseline*: run the §8.6.3 final review checks against the
  release scope (concern coverage, trace integrity, V&V coverage),
  apply the annotated tag, and trigger the §10.4 backup mirror
  (per the CM Strategy at `docs/cm-strategy.md`).
- For *report*: render the current release dashboard from the
  story register, the Risk Register, the Correction Register, and
  the Justification Document.
- Refuse to baseline a release if any story in scope has
  `StoryMeta.status` other than `done`, or if any acceptance
  criterion lacks a verification case.

This command is the normal way to manage release boundaries. It
operates over the artefacts produced by `/vse-story` and `/vse-cr`
and consumed by the §9 ISO 29110 compliance documents.
