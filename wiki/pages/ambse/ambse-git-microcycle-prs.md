---
title: "AMBSE Git Workflow: Microcycle = Feature Branch with Pull Request"
slug: ambse-git-microcycle-prs
type: process
layer: ambse
tags: [git, microcycle, feature-branch, pull-request, handoff, vse-prefix]
sources:
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Page 61 (handoff workflow), pp. 53-54 (iteration verification)."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-git-three-way-mapping
  - ambse-git-nanocycle-commits
  - ambse-git-ci-gates-and-macrocycle
  - ambse-git-vse-guidance-and-anti-patterns
  - ambse-interfaces-and-handoff
  - ambse-vee-three-timeframes
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator]
---

# AMBSE Git Workflow: Microcycle = Feature Branch with Pull Request

A microcycle is one AMBSE iteration: 1 to 4 weeks of work
that delivers a verified slice of system specification. Every
microcycle has an iteration mission stated up front (one or
two use cases specified, a trade study completed, an
interface baselined). For the broader timeframe frame see
[[ambse-vee-three-timeframes]] and
[[ambse-git-three-way-mapping]].

## Branch naming

```text
vse/iter-NN[-short-desc]
```

- `vse/` prefix marks the branch as a VSE iteration branch
  and separates it visually from `feat/`, `fix/`, `docs/` and
  other conventional-commit branch prefixes that may exist in
  the same repo.
- `iter-NN` is the iteration number (zero-padded). Iteration
  numbers are sequential across the project's history, never
  reset.
- `-short-desc` is optional but recommended. It identifies
  the iteration mission in a few words.

Examples:

```text
vse/iter-00-architecture-zero
vse/iter-01-monitor-temperature
vse/iter-02-temperature-control
vse/iter-12-acquirer-acceptance-prep
```

## Branching off main

The branch is created from the latest `main` at the start of
the iteration:

```bash
git checkout main
git pull
git checkout -b vse/iter-03-temperature-control
```

The branch lives for the duration of the microcycle (1 to 4
weeks). All nanocycles for the iteration mission happen on
this branch. Keep the branch off `main` mid-iteration. Rebase
only when the team explicitly decides a synchronisation point
is needed. Douglass's "avoid bundling multiple iterations"
guidance applies here too.

## Worked example: a small microcycle history

```text
* (HEAD -> vse/iter-03-temperature-control) refactor(model): rename SetpointPort to TemperatureSetpointPort
* docs(use-cases): add abnormal flow for setpoint out of range
* feat(verification): add VER-018 setpoint accuracy test
* feat(architecture): allocate REQ-021 to TemperatureControlSubsystem
* feat(requirements): derive REQ-021 setpoint accuracy
* feat(requirements): add UC-ControlTemperature mission and STK-014
| (main)
```

Six commits, all focused, each commit leaves the model
verifiable. The first commit opens the use case, the next
four trace the use case into requirements, architecture, and
verification, and the last commit is a refactor caught at
peer review time. This is one microcycle.

## Pull request as the handoff gate

When the iteration mission is complete and all the nanocycles
are in, the branch is pushed and a pull request is opened
against `main`. The pull request is the operational form of
Douglass's handoff workflow (Cookbook, p. 61, see
[[ambse-interfaces-and-handoff]]): the diff is the
**converted** engineering data, the PR description is the
**organisation** of that data, and the review event is the
formal handoff.

PR title convention:

```text
Iteration NN: <iteration mission>
```

For example:

```text
Iteration 03: Temperature control use case specified and verified
```

PR body template (the plugin ships this in
`templates/github/pull-request-template.md`):

```markdown
## Iteration mission

<one or two sentences stating what this iteration set out to deliver>

## Work products created or updated

- [ ] Stakeholder needs (STK-NNN, ...)
- [ ] System requirements (REQ-NNN, ...)
- [ ] Architecture (parts, allocations, interfaces)
- [ ] Verification cases (VER-NNN, ...)
- [ ] Validation cases (VAL-NNN, ...)
- [ ] Documentation updates (project plan, traceability matrix, ...)

## Trace status

- All new requirements have `satisfy` links upward.
- All new requirements have `verify` links downward.
- All new stakeholder needs have at least one validation case.

## Phase gate status

- Current phase: <SR.x>
- Phase gate criteria: <met / not yet / N/A>

## Open issues for the next iteration

<bulleted list of items intentionally deferred to the next iteration>
```

## PR review

PR review is the formal handoff event. For a single-developer
VSE, self-review is acceptable but the PR mechanism is still
load-bearing because it triggers the CI gates (see
[[ambse-git-ci-gates-and-macrocycle]]) and creates a
reviewable diff that future-you can use to understand what
changed and why.

For a two-to-five person VSE, peer review on the PR satisfies
the intent of Douglass's handoff workflow without ceremony.
The reviewer is checking three things, in order:

1. Does the iteration mission match what the PR delivers?
2. Are the trace links closed (the CI workflow will catch
   this mechanically, but the reviewer should confirm the
   **meaning** is right, not just the form)?
3. Is the phase gate still satisfied (or does this iteration
   legitimately advance the phase)?

## Vee inside the microcycle

- **Left side (specification)**: the specification work that
  happens on the branch over the iteration window. New
  requirements, architectural elements, interface
  definitions, trade studies.
- **Right side (verification)**: the iteration verification
  that happens at PR time. The CI gates run, the reviewer
  walks the diff, and the trace matrix is regenerated.
  Defects found during PR review produce additional commits
  on the same branch.

## Anti-patterns at the microcycle scale

- Direct commits to `main`. Skips the microcycle gate
  entirely. The pre-commit hook still catches local trace
  gaps, but no PR review ever happens, so the iteration
  handoff is invisible.
- Long-running branches that bundle multiple iterations.
  Loses the one-handoff-per-iteration discipline. If an
  iteration runs long, the right move is usually to split it:
  merge what is finished, open a new branch for the rest.
- Skipping the PR description. The PR body is the iteration's
  record. An empty body is the same as no handoff workflow.

For the full anti-pattern catalogue, see
[[ambse-git-vse-guidance-and-anti-patterns]].

## See also

- [[ambse-git-three-way-mapping]] for the three-way mapping.
- [[ambse-git-nanocycle-commits]] for the nanocycle row that
  feeds this branch.
- [[ambse-git-ci-gates-and-macrocycle]] for the CI gates that
  guard the PR and the macrocycle release tag.
- [[ambse-interfaces-and-handoff]] for the handoff workflow
  this PR operationalises.
