---
title: "AMBSE Git Workflow: VSE Guidance and Anti-Pattern Catalogue"
slug: ambse-git-vse-guidance-and-anti-patterns
type: pattern
layer: ambse
tags: [git, vse, guidance, anti-patterns, solo, peer-review, iteration-cadence]
sources:
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Sections 1.4-1.5 (Iteration 0 / Architecture 0)."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-git-three-way-mapping
  - ambse-git-nanocycle-commits
  - ambse-git-microcycle-prs
  - ambse-git-ci-gates-and-macrocycle
  - ambse-iteration-planning
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator]
---

# AMBSE Git Workflow: VSE Guidance and Anti-Pattern Catalogue

For the underlying git-flow mechanics see
[[ambse-git-three-way-mapping]],
[[ambse-git-nanocycle-commits]],
[[ambse-git-microcycle-prs]], and
[[ambse-git-ci-gates-and-macrocycle]].

## VSE-specific guidance

### Solo developer

Open the PR against `main`, self-review, and merge. The PR
mechanism runs the CI gates one more time and creates the
iteration record in git history. A solo VSE should still
resist the temptation to commit straight to `main`, because
the CI gate is the only thing that will catch a trace gap that
the local hook missed.

### Two-to-five person team

PR review is peer review. One other team member reads the
iteration PR before merging. This satisfies the intent of
Douglass's handoff workflow without adding ceremony.

### Larger teams

Outside the scope of this plugin. ISO 29110 Basic Profile
targets single-team projects of fewer than 25 people, and the
plugin is tuned for that population. Larger organisations
should consult INCOSE guidance directly.

### Iteration cadence

Two-week iterations are a reasonable default for VSEs.
Shorter (one week) is appropriate when stakeholders are
highly available and the work is fine-grained. Longer (three
or four weeks) is appropriate for hardware-heavy iterations
with longer lead times. Record the iteration cadence in the
project plan (`docs/pm/project-plan.md`, Section 4).

### Naming the first iteration

`vse/iter-00-architecture-zero` by convention. This matches
Douglass's "Iteration 0" and "Architecture 0" terminology
(Cookbook, Sections 1.4-1.5; see
[[ambse-iteration-planning]]): the first iteration sets up
the modelling environment, the project backlog, and the
skeleton architecture before any use case is specified in
detail.

## Anti-pattern catalogue

The same anti-patterns appear across many AMBSE adoptions.
Each one breaks one of the gates that AMBSE depends on.

| Anti-pattern | What it breaks | Why it happens | Recovery |
|---|---|---|---|
| Direct commit to `main` | Microcycle handoff gate | Habit, "this is just a tiny fix" | Revert and redo on a `vse/iter-NN` branch as a PR |
| `git commit --no-verify` | Nanocycle trace gate | Trace check feels "in the way" | Investigate why the trace was missing, then add the missing link or file a backlog item |
| Long branch bundling many iterations | Iteration discipline, PR-as-handoff | Iteration ran long, reluctance to split | Merge the finished part now and open a fresh branch for the rest |
| Empty PR description | Handoff workflow record | PR template went unused | Fill the template before merging. Ten minutes now saves an hour later |
| Tagging `main` with broken traces | Macrocycle V&V gate | Schedule pressure | Untag, fix, retag with a new version |
| Reopening settled requirements during construction (`SR.4`) | Phase discipline | Stakeholder feedback arrived late | File a Change Request (`@iteration-orchestrator` PM.2.2) and update the baseline through that route |

## See also

- [[ambse-git-three-way-mapping]] for the three-way mapping.
- [[ambse-git-nanocycle-commits]] for the nanocycle row.
- [[ambse-git-microcycle-prs]] for the microcycle row.
- [[ambse-git-ci-gates-and-macrocycle]] for CI gates and the
  macrocycle release tag.
- [[ambse-iteration-planning]] for Iteration 0 and
  Architecture 0 background.
