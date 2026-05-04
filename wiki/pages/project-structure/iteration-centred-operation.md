---
title: "Iteration-Centred Operation: Cycles and Centre of Gravity"
slug: iteration-centred-operation
type: concept
layer: project-structure
tags: [iteration, nanocycle, microcycle, macrocycle, centre-of-gravity, ambse]
sources:
  - citation: "Plugin-internal model, derived from ISO/IEC TR 29110-5-6-2:2014 lifecycle-neutrality and Douglass (2016) Agile Systems Engineering AMBSE cycle definitions."
    raw: null
related:
  - iteration-boundary-and-macrocycle-closure
  - iso29110-overview
  - iso29110-pm-process
  - iso29110-sr-process
  - vse-canonical-project-layout
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator, project-setup]
---

# Iteration-Centred Operation: Cycles and Centre of Gravity

This page describes how the plugin enters, runs, and closes the
three AMBSE cycles in practice, and how the ISO/IEC 29110 task
catalogue maps onto them. For closure-check mechanics see
[[iteration-boundary-and-macrocycle-closure]]. The full AMBSE
process definition (including the Vee pattern at three scales)
lives in the AMBSE knowledge layer (pending Phase 4 migration).

## Why iteration, not phase

The unit of work in this plugin is the **iteration**, not the
ISO/IEC 29110 phase. Douglass frames the traditional Vee process
as AMBSE "done once", naming the `[more reqs]` loop that returns
from the right side of the Vee back to the left whenever more
requirements appear. Every real project takes that loop many
times. Treating the phase as the temporal unit forces the
engineer to pretend the loop does not exist.

ISO/IEC 29110 itself is lifecycle-neutral. ISO/IEC TR
29110-5-6-2:2014 states explicitly that the series can be applied
at any phase of system or software development within a lifecycle
(see [[iso29110-overview]]). The standard catalogues **what**
activities happen in a VSE systems engineering project. It does
not prescribe **when** those activities run relative to each
other. This plugin takes that freedom seriously: the ISO/IEC
29110 activities are a catalogue accessed through the iteration,
not a schedule the engineer walks end to end.

## The three cycles

The plugin operates at three nested timescales:

- **Nanocycle** (30 minutes to one day, one commit). The smallest
  unit of tracked work. Anchored to a single requirement, design
  element, verification case, or backlog item. Verification at the
  nanocycle runs against the thread being touched, using fast
  tools (`syside check`, a targeted test, a trace rebuild on one
  requirement).
- **Microcycle** (one to four weeks, one feature branch and one
  pull request). The central unit of planning. Has a one-sentence
  mission, one or more centre-of-gravity activities, a backlog,
  and a closure check. Closes into `main` via a reviewed PR.
- **Macrocycle** (project length, one release tag on `main`). The
  outer unit of closure. Verifies the full StRS-to-SyRS-to-
  architecture-to-verification trace, checks that SR.5 has run
  cleanly across the release, and confirms SR.6 artefacts are
  ready.

## Centre of gravity

Every open iteration has one or more ISO/IEC 29110 tasks as its
**centre of gravity**. The centre of gravity is the answer to
"what is this iteration mostly about?" and is the field the
iteration-orchestrator uses to route the engineer to the right
specialist skill.

A routing table from centre-of-gravity activity to specialist
skill lives in the iteration-orchestrator. The activity catalogue
that populates its left column lives in
[[iso29110-pm-task-checklists]] and
[[iso29110-sr-task-checklists]].

### Concurrent centres are normal

Douglass describes the AMBSE hybrid lifecycle as having three
overlapping cycles (specification, downstream engineering,
verification) that run in parallel once a project is past its
first iteration. In ISO/IEC 29110 terms, it is entirely legitimate
for a single iteration to carry SR.2 (Requirements) and SR.3
(Architecture) as joint centres of gravity, or SR.3 and SR.4
(Construction), or SR.4 and SR.5 (IVV). The plugin does not treat
concurrency as a Red Flag.

### Contradictory centres are refused

A single iteration cannot legitimately claim PM.4 (Closure) and
SR.2 (Requirements) as joint centres of gravity, because closure
reports on the whole project and requirements elicitation opens
new threads. The iteration-orchestrator refuses such combinations
when they are proposed.

## See also

- [[iteration-boundary-and-macrocycle-closure]] for closure-check
  mechanics, brownfield entry, and the macrocycle gate.
- [[iso29110-overview]] for the lifecycle-neutrality clause this
  model relies on.
- [[iso29110-pm-task-checklists]] and [[iso29110-sr-task-checklists]]
  for the activity catalogue that populates centre-of-gravity
  fields.
- [[vse-canonical-project-layout]] for the .vse-iteration.yml
  schema where centre-of-gravity is recorded.
