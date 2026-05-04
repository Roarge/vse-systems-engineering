---
title: "SysML 2.0 Portions and Individuals"
slug: sysml2-portions-and-individuals
type: reference
layer: sysml2
tags: [portions, snapshots, time-slice, space-slice, individuals, life]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Sections 25.3 and 25.4, pages 147 to 152."
    raw: sysmlv2.pdf
related:
  - sysml2-occurrences-4d
  - sysml2-temporal-spatial-relations
  - sysml2-occurrence-context-and-variables
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-behaviour]
---

# SysML 2.0 Portions and Individuals

This page captures the portion vocabulary (snapshots, time slices,
space slices, space shots, spacetime-enclosed points) and the
`individual` keyword, both new in the 2026-04 release of the SysML
v2 book (Chapter 25, pages 147 to 152). For the conceptual frame
of 4D modelling, see [[sysml2-occurrences-4d]].

## What a portion is

How can we model things that exist in space-time? What
distinguishes occurrences from data types? SysML 2.0's answer is
**portions**: slices, snapshots, and points that are themselves
occurrences. We can divide a thing's full extent along the spatial
or temporal axes (or both) into portions of the whole, then speak
about where they are compared to each other or other things.

The complete 4D extent of an occurrence (every point in space it
occupies, at every moment it exists) is itself an occurrence: the
**maximal portion** of itself, the occurrence "as a whole". The
KerML library calls this complete extent a **Life**. Two
occurrences that are different portions of the same complete life
are different views of the same entity in 4D.

## A cinema analogy

The complete life of an occurrence is like the entire reel of a
movie:

- A **snapshot** is a single frame, the full picture at one instant.
- A **time slice** is a clip, any continuous run of frames, again
  the full picture.
- A **space slice** is a sub-region of the screen that persists
  across all frames, a corner, the area where a character appears,
  or even a single pixel followed throughout.
- A **spacetime-enclosed point** is a single pixel at a single
  frame.

The reel as a whole, every clip you can extract from it, every
region of the screen, and every pixel-instant are all "portions"
of the same film. A SysML 2.0 occurrence works the same way.

## The portion kinds

Each portion kind has the same vocabulary applied in time and
space:

| Portion kind | Time | Space | KerML feature |
|---|---|---|---|
| **Snapshots** | Zero duration | Full spatial extent at that instant | `start`, `done`, `snapshots` |
| **Time slices** | Sub-interval of the temporal extent | Full spatial extent across the chosen interval | `middleTimeSlice`, custom `timeslice` |
| **Space slices** | Persisting through full temporal extent | Sub-region of the spatial extent | (subset `spaceSlices`) |
| **Space shots** | Persisting through time | Strictly lower spatial dimension | (subset `spaceBoundary`, `spaceInterior`) |
| **Spacetime-enclosed points** | Zero duration | Zero space | `spaceTimeEnclosedPoints` |

The names `start` and `done` come from the SysML library, which
redefines the underlying KerML features `startShot` and `endShot`
with shorter names.

A 1D occurrence may have 0D space shots (points persisting
through time). A 3D occurrence may have 2D space shots (its
surfaces). The `spaceBoundary` and `spaceInterior` features
capture the topological structure of the occurrence's spatial
extent (see Chapter 40 of the SysML v2 book).

## Spacetime-enclosed points

These are 4D points: zero duration **and** zero space. Every
occurrence has a feature `spaceTimeEnclosedPoints` containing all
such points within it. They are the finest grain at which the 4D
extent can be examined: indivisible units of the portion
vocabulary.

A note on "zero duration" and "zero spatial extent": the claim is
mathematical, not physical. In topology, a point has no width,
length, or height. An instant has no duration. A segment has
length but no width or height. The portion vocabulary uses these
conventions throughout. Snapshots are instants in this sense,
space shots are regions of strictly lower dimension, not claims
about minimal spacetime granularity.

## Key invariant: portions share the same Life

A subtle but useful fact: every portion of an occurrence shares
the **same complete life** as the original. The start of a
drone's existence and the drone itself are different 4D views of
the same individual, not separate things. This is consistent with
the 4D worldview: an occurrence is its complete extent, and any
sub-region of that extent is the same entity, viewed differently.

## Declaring portions in a model

Two ways to declare a portion:

```sysml
part def MyDrone {
    timeslice missionPhase;
    snapshot launchInstant;
    occurrence leftHalf subsets spaceSlices;
}
```

The `timeslice` keyword introduces `missionPhase` as a sub-interval
of the drone's life. The `snapshot` keyword introduces
`launchInstant` as an instant. Both keywords automatically subset
the inherited features of `MyDrone` (`timeSlices` and `snapshots`),
so no explicit type is needed. For portion kinds without a
dedicated keyword (space slices, space shots, spacetime-enclosed
points), declare them by subsetting the corresponding library
feature directly.

**Notice that portions are not typed by a definition.** They are
implicitly Occurrences. Typing a portion by the same type as its
owner would be a mistake: every `MyDrone` has its own start, done,
snapshots, and time slices, so a portion typed as `Drone` would
inherit all of that recursively, with all the constraints.

## When to declare custom portions

In everyday modelling, you will rarely declare custom portions.
The portion vocabulary exists primarily as a semantic tool, for the
semantic library to describe semantics in terms of traces, for
execution to refer to specific moments, and to express some KerML
constraints. When you want to model a phase of an occurrence
(cruise mode, mission active, idle), prefer a state (see
[[sysml2-state-machines]]). Time slices will be automatically
generated by a simulator coinciding with the activation of states.

Time slices are appropriate when the phase boundaries are
**externally fixed**, for instance, the named segments of a
scheduled mission like Artemis II, where the launch, transit, and
lunar phases are pinned in advance. This kind of "the specific X"
modelling is exactly where the `individual` keyword shines.

## Individuals

A definition declared with `individual` introduces one particular
individual whose complete life is classified by that definition.
Two constraints follow from the keyword:

- The definition implicitly specialises the library type
  `Occurrences::Life`. By construction, instances of `Life` are
  only portions of themselves, meaning an individual is the
  maximal extent of itself, never a portion of anything larger.
- The definition's multiplicity is constrained to at most one.

Together, these constraints capture a precise modelling intent:
"this represents one specific individual, and there is exactly one
of it". The terms `individual` and `complete life` are closely
related: an `individual` **is** a complete life when it is
declared as a specific, unique entity in the model.

```sysml
part def Capsule;
occurrence def Mission {
    part capsule : Capsule;
}

individual part def OrionII :> Capsule;

individual occurrence def ArtemisII :> Mission {
    individual part orion :>> capsule : OrionII;
}
```

An `individual usage` references the unique instance of an
individual definition reached through its type chain, and there
must be such a definition in the chain. The usage `orion` does
not introduce a new entity. It points to the one and only
`OrionII`.

The `individual` keyword is best used **sparingly**. SysML 2.0
has no global execution context. When a model is executed, the
user selects a definition as the entry point (often a case, see
Section 39.4), and any valid interpretation must still
instantiate every individual declared anywhere in the reachable
model, whether relevant to that entry point or not. Where the
modelling intent is simply "exactly one of this exists in this
context," a usage with multiplicity 1 inside the context
definition is usually a cleaner choice.

## See also

- [[sysml2-occurrences-4d]] for the 4D worldview that motivates
  portions.
- [[sysml2-temporal-spatial-relations]] for the equality operators
  on individuals (`==` and `===`).
- [[sysml2-occurrence-context-and-variables]] for suboccurrence
  versus portion and the `this` feature.
