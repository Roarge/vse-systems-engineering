---
title: "AMBSE Workflow Mapping to ISO/IEC 29110"
slug: ambse-iso29110-mapping
type: reference
layer: ambse
tags: [iso29110, mapping, workflow, lifecycle]
sources:
  - citation: "Douglass, B.P. (2016) and Douglass, B.P. (2021), AMBSE workflow against ISO/IEC TR 29110-5-6-2:2014 process activities."
    raw: ISO_IEC_TR_29110-5-6-2_2014.pdf
related:
  - ambse-principles
  - ambse-vee-three-timeframes
  - ambse-iteration-planning
  - iso29110-pm-process
  - iso29110-sr-process
  - ambse-git-three-way-mapping
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator]
---

# AMBSE Workflow Mapping to ISO/IEC 29110

This page is the cross-reference table from AMBSE activities
(see [[ambse-principles]] and [[ambse-vee-three-timeframes]])
to ISO 29110 process activities. For the underlying ISO 29110
catalogue, see [[iso29110-pm-process]] and
[[iso29110-sr-process]]. For the git operationalisation that
runs alongside this mapping, see
[[ambse-git-three-way-mapping]].

## AMBSE-to-ISO 29110 activity mapping

| AMBSE activity | ISO 29110 activity | Notes |
|---|---|---|
| Iteration 0 (project setup) | PM.1 + SR.1 | SEMP, environment, initial backlog |
| Stakeholder requirements elicitation | SR.2.1-SR.2.3 | Use case driven, per iteration |
| System requirements derivation | SR.2.4-SR.2.6 | Model-based, per iteration |
| Architecture 0 (initial design) | SR.3 (early) | Skeleton architecture, first iteration |
| Functional analysis and architecture | SR.3 | Per iteration, incremental |
| Handoff to downstream engineering | SR.3 to SR.4 | Iteration boundary |
| Construction | SR.4 | Per iteration, discipline-specific |
| Continuous verification (nanocycle) | SR.5 (ongoing) | Model syntax, trace checks |
| Iteration V&V (microcycle) | SR.5 | End of each iteration |
| System V&V (macrocycle) | SR.5 | End of project |
| Iteration retrospective | PM.2, PM.3 | Metrics review, plan adjustment |
| Product delivery | SR.6, PM.4 | Single pass at project end |

## Mapping AMBSE to a git workflow

The three timeframes from [[ambse-vee-three-timeframes]] each
map onto one unit of git collaboration: the commit (nanocycle),
the feature branch with a pull request (microcycle), and the
release tag on `main` (macrocycle). This mapping is the
operational form the plugin enforces. See
[[ambse-git-three-way-mapping]] for the full breakdown,
[[ambse-git-nanocycle-commits]] for the nanocycle row,
[[ambse-git-microcycle-prs]] for the microcycle row, and
[[ambse-git-ci-gates-and-macrocycle]] for the macrocycle row.

## Reading note

ISO 29110 says **what** activities a project must perform. The
AMBSE mapping above says **when** and **at what cadence** those
activities happen, when AMBSE is the chosen lifecycle. SR.1 and
SR.6 remain single-pass per project. PM and the SR.2-SR.5 core
run multiple sub-passes, one per iteration. The hard gates
(macrocycle release tag, PM.4 product acceptance) remain
unchanged. The soft gates (iteration boundaries, nanocycle
trace checks) are added by AMBSE and operationalised by the
plugin's hooks and CI.

## See also

- [[ambse-principles]] and [[ambse-vee-three-timeframes]] for
  AMBSE methodology.
- [[iso29110-pm-process]], [[iso29110-sr-process]],
  [[iso29110-pm-task-checklists]], [[iso29110-sr-task-checklists]]
  for the ISO 29110 activity catalogue.
- [[ambse-git-three-way-mapping]] for the git-flow mapping that
  runs the iteration cadence.
- [[iteration-centred-operation]] for the
  centre-of-gravity-driven iteration routing built on top of
  this mapping.
