---
title: "AMBSE Git Workflow: CI Gates and Macrocycle = Release Tag"
slug: ambse-git-ci-gates-and-macrocycle
type: process
layer: ambse
tags: [git, ci-gates, traceability, iteration-boundary, macrocycle, release-tag]
sources:
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-git-three-way-mapping
  - ambse-git-microcycle-prs
  - ambse-git-vse-guidance-and-anti-patterns
  - iteration-boundary-and-macrocycle-closure
  - iso29110-phase-gates
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator]
---

# AMBSE Git Workflow: CI Gates and Macrocycle = Release Tag

The plugin enforces two CI gates at the microcycle boundary
and a hard gate at the macrocycle. For the broader git mapping
see [[ambse-git-three-way-mapping]] and
[[ambse-git-microcycle-prs]]. For the iteration-centred
closure model see [[iteration-boundary-and-macrocycle-closure]].

## PR enforcement gates

The plugin ships two GitHub Actions workflow templates in
`templates/github/` that turn the trace and phase-gate checks
into blocking PR checks. They wrap the same scripts that run
as local hooks.

### `traceability-check.yml`

This workflow runs `hooks/pre-commit-traceability.sh` against
the head of every PR. The AMBSE recommendation is to run the
trace check on every PR, because every iteration handoff
should be verified. The workflow fails the PR if any
requirement is missing a `satisfy` or `verify` link.

### `iteration-boundary.yml`

This workflow runs `hooks/iteration-boundary-check.sh` against
the `centre_of_gravity` list in `.vse-iteration.yml`. It
detects whether the PR closes an iteration (compares the
iteration number on the PR head to the value on `main`) and
accumulates closure findings across every active centre of
gravity. The workflow is **advisory**: missing items are
reported as iteration-boundary closure debt in the PR log but
the job exits 0 and does not block merging. Closing an
iteration with debt carried forward onto the next
iteration's backlog is normal AMBSE behaviour. The hard
closure gate lives at the macrocycle (release tag), not at
the iteration boundary. See
[[iteration-boundary-and-macrocycle-closure]] for the
report-not-block design rationale.

Both workflows are intentionally thin wrappers around the
bash scripts in `hooks/`. Translating to GitLab CI is
mechanical: invoke the same scripts in a `.gitlab-ci.yml`
job. Translating to Forgejo Actions or Gitea Actions follows
the same shape as the GitHub workflows. The plugin does not
currently ship these templates, but the underlying scripts
are host-agnostic.

### Why CI gates matter even for single-developer VSEs

A single developer working alone on `main` will have a clean
local hook history but no record of which iteration any given
commit belonged to. The PR mechanism is the cheapest way to
recover that record. Even in solo mode, opening a PR against
`main` and merging it yourself preserves the iteration
boundary in git history, runs the CI gates one more time on a
known-good base, and leaves a reviewable diff behind.

## Macrocycle = release tag on main

A macrocycle is the project length, or one major release.
After a sequence of merged iteration PRs has accumulated on
`main`, and after system-level V&V is complete (the Vee
right-side at the macrocycle scale), the project tags `main`
with a semantic version:

```bash
git checkout main
git pull
git tag -a v1.0.0 -m "First production release"
git push --tags
```

The tag is the macrocycle delivery event. It is the input to
whatever release artefact pipeline the project uses: the
`@document-export` skill generates docx/pptx/pdf renderings of
the work products at the tagged commit, and the
`templates/github/document-export.yml` workflow can be wired
to run on tag push.

## Vee inside the macrocycle

- **Left side (specification)**: the cumulative specification
  work done across all the merged iterations leading up to the
  tag.
- **Right side (verification)**: the formal system V&V that
  happens before the tag is created. System verification
  cases are executed, validation cases are walked through with
  the acquirer, the acceptance procedure is run.

## Pre-tag checklist

Before tagging:

1. The current `.vse-phase` is `SR.6`.
2. The phase gate checklist for SR.5 to SR.6 is satisfied
   (see [[iso29110-phase-gates]]).
3. All verification cases pass (the trace matrix should show
   green for every `verify` link).
4. All validation cases pass (every `STK-` need has a passing
   `VAL-` case).
5. The acquirer has signed the Product Acceptance Record.
6. The release artefacts are generated and stored.

This matches the existing SR.6 phase-gate checklist. The tag
is the point at which the checklist is enforced.

## See also

- [[ambse-git-three-way-mapping]] for the three-way mapping.
- [[ambse-git-microcycle-prs]] for the microcycle row whose
  CI gates this page documents.
- [[ambse-git-vse-guidance-and-anti-patterns]] for VSE-scale
  guidance and the anti-pattern catalogue.
- [[iteration-boundary-and-macrocycle-closure]] for the
  closure-check model that accumulates against this gate.
- [[iso29110-phase-gates]] for the SR.5 to SR.6 phase gate
  checklist.
