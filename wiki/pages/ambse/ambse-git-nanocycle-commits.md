---
title: "AMBSE Git Workflow: Nanocycle = Commit"
slug: ambse-git-nanocycle-commits
type: process
layer: ambse
tags: [git, nanocycle, commit, conventional-commits, pre-commit-hook]
sources:
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Pages 40-41."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-git-three-way-mapping
  - ambse-git-microcycle-prs
  - ambse-git-vse-guidance-and-anti-patterns
  - ambse-nanocycle-and-use-case-analysis
  - ambse-vee-three-timeframes
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator]
---

# AMBSE Git Workflow: Nanocycle = Commit

A nanocycle is the 30-minute to 1-day inner loop of model
writing. Each nanocycle ends with the model being slightly
more complete or slightly more correct, and a verification
step that confirms the change did not break anything. For the
broader AMBSE timeframe context see
[[ambse-vee-three-timeframes]] and
[[ambse-git-three-way-mapping]]. For the nanocycle workflow
content (the steps inside the loop), see
[[ambse-nanocycle-and-use-case-analysis]].

## Mapping

- **One commit per nanocycle** is the typical case. A single
  commit captures one focused unit of work: a new requirement
  and its `satisfy` link, a new verification case and its
  `verify` link, a refactored package structure, a corrected
  trace, a clarified doc string.
- Several small commits per nanocycle are also fine. The
  important property is that each commit leaves the model in
  a verifiable state.
- The commit happens on a feature branch, never directly on
  `main`. See [[ambse-git-microcycle-prs]] for branch naming.

## Vee inside the nanocycle

Mapped onto the Vee verification pattern:

- **Left side (specification)**: write the model element, the
  trace link, the doc string, the constraint.
- **Right side (verification)**: run the local checks
  immediately. The pre-commit traceability hook
  (`hooks/pre-commit-traceability.sh`) blocks the commit if a
  requirement was added without a `satisfy` or `verify` link.
  SySiDE's syntax validation runs continuously in the IDE. If
  you have the SySiDE CLI on your PATH,
  `syside check --warnings-as-errors --stats` is the
  equivalent command-line gate.

## Commit message convention

The plugin's git history uses **conventional commits with a
scope**, for example:

```text
feat(requirements): add REQ-014 ambient pressure threshold
fix(architecture): correct allocate from REQ-007 to ProcessingSubsystem
refactor(model): split sensors package into sensing and acquisition
docs(use-cases): clarify abnormal-flow precondition for UC-MonitorTemp
```

Free-form messages are acceptable, but each commit body
should answer two questions: which work product or use case
did the change touch, and why was the change needed. The
pre-commit hook is the mechanical gate. The commit message is
the human-readable trace.

## Anti-pattern at the nanocycle scale

**Bypassing the trace check with `git commit --no-verify`.**
This breaks the niche-construction guard (PHAS-EAI R4) that
the plugin's attention regime depends on. If a trace
genuinely cannot be added yet (for example because the parent
requirement does not exist), add a placeholder requirement
with a doc comment explaining the gap, then file the gap as a
backlog item to resolve in the same iteration.

For the full anti-pattern catalogue, see
[[ambse-git-vse-guidance-and-anti-patterns]].

## See also

- [[ambse-git-three-way-mapping]] for the three-way mapping.
- [[ambse-git-microcycle-prs]] for the microcycle row (commits
  accumulate on a feature branch).
- [[ambse-nanocycle-and-use-case-analysis]] for the nanocycle
  workflow content.
- [[ambse-vee-three-timeframes]] for the timeframe
  definitions.
