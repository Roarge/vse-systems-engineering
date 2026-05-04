---
title: "Iteration Boundary and Macrocycle Closure"
slug: iteration-boundary-and-macrocycle-closure
type: process
layer: project-structure
tags: [iteration, closure, brownfield, macrocycle, traceability, gate]
sources:
  - citation: "Plugin-internal model, derived from ISO/IEC TR 29110-5-6-2:2014 and the Douglass AMBSE cycle definitions."
    raw: null
related:
  - iteration-centred-operation
  - iso29110-sr-process
  - iso29110-phase-gates
  - vse-canonical-project-layout
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator, project-setup]
---

# Iteration Boundary and Macrocycle Closure

This page describes how the plugin enters projects at non-PM.1/SR.1
starting points, how the iteration-boundary closure check works,
and how the macrocycle gate guards the release tag. For the
underlying iteration model, see [[iteration-centred-operation]].

## Brownfield entry at arbitrary centre of gravity

The plugin does not assume every project starts at PM.1 and SR.1.
Most real projects reaching the plugin are brownfield, with
existing requirements, existing design, or existing code. The
`@project-setup` skill detects the host project's state and
proposes an initial centre of gravity accordingly.

Three typical entry modes:

- **Greenfield**. Empty or near-empty directory, no inherited
  artefacts. Initial iteration enters at PM.1 plus SR.1
  (Initiation). First-iteration mission is typically "Architecture
  Zero": establish the SEMP, the implementation environment, and
  the initial data model.
- **Brownfield with existing requirements**. Host project already
  carries `docs/sr/system-requirements*` or equivalent. Initial
  iteration enters at SR.3 (Architecture) with an SR.2.4
  (Elaborate System Requirements and Interfaces) baseline step as
  the first nanocycle. Inherited requirements must be baselined
  into the project's StRS and SyRS before they can be declared
  centre-of-gravity inputs.
- **Brownfield with existing design**. Host project already
  carries `docs/sr/system-design*`, a substantial source tree, or
  both. Initial iteration enters at SR.4 (Construction) with an
  SR.3.3 (Document or update the Physical System Design) baseline
  step and an SR.4.2 (Construct or update Hardware System
  Elements, including buy/build/reuse identification) scan as the
  first nanocycles.

### The baselining principle

Before any inherited artefact can anchor a new iteration's work,
the first iteration must **baseline** it. Baselining an inherited
artefact means bringing it into the project's traceability chain
with a satisfy link upward and a verify link downward. Once
baselined, it is fair game as a centre-of-gravity input for the
next iteration.

## Iteration-boundary closure

The iteration-boundary closure check runs when the engineer asks
to close the current iteration. It verifies two things:

1. **Traceability is complete for the threads the iteration
   touched.** Every new or modified requirement has a satisfy link
   upward, a verify link downward, and a verification case in the
   catalogue.
2. **The specialist skill's own closure items are satisfied.** For
   SR.2 centres of gravity, this means the SyRS threads declared
   in the iteration mission are accepted. For SR.3, it means the
   architecture design section for the touched functional chain is
   complete. For SR.5, it means the verification cases ran and
   their results are recorded.

### Reports, does not block

The check **reports**, it does not block. Items that remain open
become explicit iteration-boundary closure debt, carried forward
on the next iteration's backlog as `closure_debt[]` entries in
`.vse-iteration.yml` (see [[vse-canonical-project-layout]] for
the schema).

This is by design: real AMBSE work routinely closes an iteration
with some open threads that move forward to the next sprint, and
a hook that blocks the close would be fighting the process it is
supposed to support.

The discipline lives in two places:

- The backlog makes debt visible every time an iteration opens.
- The macrocycle closure check refuses to let the release tag
  land while debt is still accumulated.

## Macrocycle closure

The macrocycle closure check runs when the engineer asks to tag a
release on `main`. It is the **only hard gate in the plugin**. It
verifies:

- Every StRS entry traces to at least one validation case.
- Every SyRS entry traces upward (satisfy a StRS entry) and
  downward (verify via at least one verification case).
- Every verification case in the catalogue has run and its result
  is recorded.
- SR.5 (Integration, Verification and Validation) reports are
  complete for the release scope.
- SR.6 (Delivery) artefacts (documentation, training material,
  acceptance record) are ready.

Failure at the macrocycle gate halts the release tag. The
engineer must resolve the gap or explicitly defer it with a
documented Change Request before the tag can be pushed.

## See also

- [[iteration-centred-operation]] for the cycle definitions and
  centre-of-gravity model.
- [[iso29110-sr-process]] for the SR.5 and SR.6 activity
  definitions referenced by the macrocycle gate.
- [[iso29110-phase-gates]] for the per-phase transition
  checklists used by iteration-boundary checks.
- [[vse-canonical-project-layout]] for the `.vse-iteration.yml`
  schema that holds `closure_debt`, `centre_of_gravity`, and
  related fields.
