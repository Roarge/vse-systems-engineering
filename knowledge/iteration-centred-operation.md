# Iteration-Centred Operation

This file is the operational companion to `ambse-agile-process.md`. Where
`ambse-agile-process.md` describes the AMBSE process, this file describes how
the plugin enters, runs, and closes the three cycles in practice, and how the
ISO/IEC 29110 task catalogue maps onto them.

## 1. Why iteration, not phase

The unit of work in this plugin is the iteration, not the ISO/IEC 29110 phase.
Douglass frames the traditional Vee process as AMBSE "done once", naming the
`[more reqs]` loop that returns from the right side of the Vee back to the left
whenever more requirements appear (see `ambse-agile-process.md` lines 91-97).
Every real project takes that loop many times. Treating the phase as the
temporal unit forces the engineer to pretend the loop does not exist.

ISO/IEC 29110 itself is lifecycle-neutral. ISO/IEC TR 29110-5-6-2:2014 states
explicitly that the series can be applied at any phase of system or software
development within a lifecycle (`iso29110-profile.md:5`). The standard catalogues
*what* activities happen in a VSE systems engineering project. It does not
prescribe *when* those activities run relative to each other. This plugin takes
that freedom seriously: the ISO/IEC 29110 activities are a catalogue accessed
through the iteration, not a schedule the engineer walks end to end.

## 2. The three cycles

- **Nanocycle** (30 minutes to one day, one commit). The smallest unit of
  tracked work. Anchored to a single requirement, design element, verification
  case, or backlog item. Verification at the nanocycle runs against the thread
  being touched, using fast tools (`syside check`, a targeted test, a trace
  rebuild on one requirement).
- **Microcycle** (one to four weeks, one feature branch and one pull request).
  The central unit of planning. Has a one-sentence mission, one or more
  centre-of-gravity activities, a backlog, and a closure check. Closes into
  `main` via a reviewed PR.
- **Macrocycle** (project length, one release tag on `main`). The outer unit
  of closure. Verifies the full StRS-to-SyRS-to-architecture-to-verification
  trace, checks that SR.5 (Integration, Verification and Validation) has run
  cleanly across the release, and confirms SR.6 (Delivery) artefacts are ready.

See `ambse-agile-process.md` Section 3 for the full AMBSE definition of each
cycle and the Vee pattern applied at each scale.

## 3. Centre of gravity

Every open iteration has one or more ISO/IEC 29110 tasks as its centre of
gravity. The centre of gravity is the answer to "what is this iteration mostly
about?" and is the field the iteration-orchestrator uses to route the engineer
to the right specialist skill. A routing table from centre-of-gravity activity
to specialist skill lives in the iteration-orchestrator; the activity catalogue
that populates its left column lives in `iso29110-task-lists.md`.

Concurrent centres of gravity are normal. Douglass describes the AMBSE hybrid
lifecycle as having three overlapping cycles (specification, downstream
engineering, verification) that run in parallel once a project is past its
first iteration. In ISO/IEC 29110 terms, it is entirely legitimate for a single
iteration to carry SR.2 (Requirements) and SR.3 (Architecture) as joint centres
of gravity, or SR.3 and SR.4 (Construction), or SR.4 and SR.5 (IVV). The
plugin does not treat concurrency as a Red Flag.

Contradictory centres are refused. A single iteration cannot legitimately claim
PM.4 (Closure) and SR.2 (Requirements) as joint centres of gravity, because
closure reports on the whole project and requirements elicitation opens new
threads. The iteration-orchestrator refuses such combinations when they are
proposed.

## 4. Brownfield entry at arbitrary centre of gravity

The plugin does not assume every project starts at PM.1 and SR.1. Most real
projects reaching the plugin are brownfield, with existing requirements,
existing design, or existing code. The `project-setup` skill detects the host
project's state and proposes an initial centre of gravity accordingly.

Three typical entry modes:

- **Greenfield**. Empty or near-empty directory, no inherited artefacts.
  Initial iteration enters at PM.1 plus SR.1 (Initiation). First-iteration
  mission is typically "Architecture Zero": establish the SEMP, the
  implementation environment, and the initial data model.
- **Brownfield with existing requirements**. Host project already carries
  `docs/sr/system-requirements*` or equivalent. Initial iteration enters at
  SR.3 (Architecture) with an SR.2.4 (Elaborate System Requirements and
  Interfaces) baseline step as the first nanocycle. Inherited requirements
  must be baselined into the project's StRS and SyRS before they can be
  declared centre-of-gravity inputs.
- **Brownfield with existing design**. Host project already carries
  `docs/sr/system-design*`, a substantial source tree, or both. Initial
  iteration enters at SR.4 (Construction) with an SR.3.3 (Document or update
  the Physical System Design) baseline step and an SR.4.2 (Construct or update
  Hardware System Elements, including buy/build/reuse identification) scan as
  the first nanocycles.

The principle: before any inherited artefact can anchor a new iteration's work,
the first iteration must baseline it. Baselining an inherited artefact means
bringing it into the project's traceability chain with a satisfy link upward
and a verify link downward. Once baselined, it is fair game as a centre-of-
gravity input for the next iteration.

## 5. Iteration-boundary closure

The iteration-boundary closure check runs when the engineer asks to close the
current iteration. It verifies two things:

1. Traceability is complete for the threads the iteration touched. Every new
   or modified requirement has a satisfy link upward, a verify link downward,
   and a verification case in the catalogue.
2. The specialist skill's own closure items are satisfied. For SR.2 centres
   of gravity, this means the SyRS threads declared in the iteration mission
   are accepted. For SR.3, it means the architecture design section for the
   touched functional chain is complete. For SR.5, it means the verification
   cases ran and their results are recorded.

The check reports, it does not block. Items that remain open become explicit
iteration-boundary closure debt, carried forward on the next iteration's
backlog as `closure_debt[]` entries in `.vse-iteration.yml`. This is by design:
real AMBSE work routinely closes an iteration with some open threads that move
forward to the next sprint, and a hook that blocks the close would be fighting
the process it is supposed to support.

The discipline lives in two places. The backlog makes debt visible every time
an iteration opens. The macrocycle closure check refuses to let the release
tag land while debt is still accumulated.

## 6. Macrocycle closure

The macrocycle closure check runs when the engineer asks to tag a release on
`main`. It is the only hard gate in the plugin. It verifies:

- Every StRS entry traces to at least one validation case.
- Every SyRS entry traces upward (satisfy a StRS entry) and downward (verify
  via at least one verification case).
- Every verification case in the catalogue has run and its result is recorded.
- SR.5 (Integration, Verification and Validation) reports are complete for the
  release scope.
- SR.6 (Delivery) artefacts (documentation, training material, acceptance
  record) are ready.

Failure at the macrocycle gate halts the release tag. The engineer must
resolve the gap or explicitly defer it with a documented Change Request before
the tag can be pushed.

## 7. Pointers

- `ambse-agile-process.md` — the AMBSE process definition, including the three
  cycles and the Vee-at-three-scales pattern.
- `ambse-git-workflow.md` — branch naming and PR flow used by the microcycle.
- `iso29110-profile.md` — the ISO/IEC 29110 Basic Profile summary, including
  the lifecycle-neutrality clause.
- `iso29110-task-lists.md` — the full task catalogue populating the
  centre-of-gravity field.
