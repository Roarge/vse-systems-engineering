---
title: "SysML 2.0 Temporal and Spatial Relations"
slug: sysml2-temporal-spatial-relations
type: reference
layer: sysml2
tags: [identity, equality, allen-interval-algebra, temporal-relations, spatial-relations, kerml]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Sections 25.5, 25.6, and 25.7, pages 152 to 155."
    raw: sysmlv2.pdf
  - citation: "Allen, J. F. (1983). Maintaining knowledge about temporal intervals. Communications of the ACM 26(11): 832-843."
    raw: null
  - citation: "Randell, D. A., Cui, Z., and Cohn, A. G. (1992). A spatial logic based on regions and connection."
    raw: null
related:
  - sysml2-occurrences-4d
  - sysml2-portions-and-individuals
  - sysml2-occurrence-context-and-variables
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-behaviour]
---

# SysML 2.0 Temporal and Spatial Relations

This page captures the equality operators for occurrences, Allen's
interval algebra in the KerML library, and the spatial relation
vocabulary. All material is new in the 2026-04 release of the
SysML v2 book (Chapter 25, pages 152 to 155). For background on
the 4D worldview, see [[sysml2-occurrences-4d]].

## 4D Identity: == and ===

Now that occurrences have portions, we can define equality for
them. SysML 2.0 provides two equality operators with subtly
different meanings (Section 25.5).

### The `==` operator: 4D coincidence

The familiar operator `==` compares two occurrences as 4D extents.
Two occurrences are `==` if and only if they are exactly the same
portion of the same life: precise 4D equality. For ordinary
usages, this is what you expect. If `engine == otherEngine`, they
are the same engine, in the same place, at the same time. In a
photo analogy, `==` is like asking whether two photographs show
exactly the same picture.

### The `===` operator: same individual

The triple-equals operator `===` is **weaker**: it asks whether
two occurrences are **portions of the same life**. Two snapshots
taken at different moments during a drone's mission are not `==`
(they cover different instants), but they are `===` (they are
portions of the same drone). Two completely separate drones are
not the same individual, so they are not `===`. In the photo
analogy, `===` is like asking whether two photographs are of the
same person, regardless of when and from what angle each was
taken.

Most "is this the same thing?" questions in modelling are like
this. **`===` is almost always what you want**, unless the
question is about precise spatiotemporal coincidence.

### Behaviour for data values

For data values (attributes), the two operators behave the same
way: data values have no portions, so 4D coincidence and "same
individual" collapse into ordinary value equality. The distinction
matters only for occurrences.

## Allen's interval algebra

Reasoning about **when** things happen, and in particular how one
event relates to another in time, is a classical topic in
artificial intelligence and knowledge representation. James Allen's
seminal 1983 paper showed that any two time intervals stand in
**exactly one** of thirteen relations: six base relations
(*before*, *meets*, *overlaps*, *starts*, *during*, *finishes*)
together with their inverses, plus *equals*, which is its own
inverse. These relations have become the de facto reference
vocabulary for interval-based temporal reasoning in planning,
scheduling, natural-language understanding, and temporal
databases.

A similar algebra is built into the KerML semantic library. The
library defines an abstract association `HappensLink` with several
specialisations that capture different temporal relationships
between occurrences:

| Allen relation | KerML library type | Notes |
|---|---|---|
| A equals B | `HappensWhile` | Both occurrences happen during each other |
| A during B | `HappensDuring` | Reflexive in KerML, see below |
| A meets B | `HappensJustBefore` | A's end coincides with B's start |
| A before B | `HappensBefore` | A's end is strictly before B's start, with a gap allowed |
| A starts B | composable | `HappensWhile` on start shots, `HappensBefore` on done shots |
| A finishes B | composable | `HappensWhile` on done shots, `HappensBefore` on start shots |
| A overlaps B | composable | `HappensBefore` between successive start and done shots |

Each base relation has an inverse (e.g., *contains* is the inverse
of *during*, *after* of *before*). The KerML library uses a single
type to express both directions, so only the base name is shown in
the table.

### Note on the reflexive convention

Allen's *during* relation is **strict**: A is *during* B only if
A's interval is entirely inside B's, **and** the two do not share
their start or end. KerML's `HappensDuring`, by contrast, is
**reflexive** (every occurrence happens during itself) and
**transitive**. The reflexive convention is mathematically more
convenient: it interacts cleanly with subsetting and
specialisation, so the same association can serve both as a
constraint between distinct occurrences and as a self-applying
property of any single occurrence. The same reflexive convention
applies to `HappensWhile`, `InsideOf`, and the other "happens"
and "inside" relations in the library. If you end up comparing
SysML 2.0 constraints with the classical temporal-logic
literature, or with off-the-shelf temporal reasoners, keep this
difference in mind.

### Day-to-day usage

In day-to-day modelling, you will rarely write `HappensBefore` or
`HappensWhile` connectors directly. You will write higher-level
constructs:

- A **succession** between two action steps is defined as a
  `HappensBefore` link (see Section 26.3 and
  [[sysml2-successions]]).
- The **source-target pair of a transition** in a state machine
  (see [[sysml2-state-machines]]) carries the same
  `HappensBefore` semantics inside the transitions.

Each of these is a flavour of the Allen vocabulary applied in a
different language construct. Recognising the connection helps
with three things: reading the library when you need to look
something up, expressing constraints that mix succession with
occurrence-level reasoning, and relating SysML 2.0 models to the
broader research literature on scheduling, verification, and
temporal planning.

## Spatial and combined relations

The KerML library complements its temporal vocabulary with a
parallel calculus of spatial relations between occurrences. The
principal types are:

- **`InsideOf`**: the smaller occurrence is spatially within the
  larger.
- **`OutsideOf`**: no spatial overlap.
- **`JustOutsideOf`**: separate, with some part of their
  boundaries touching.
- **`MatesWith`**: the strict case of `JustOutsideOf` where there
  is no space anywhere between the two boundaries.
- **`SurroundedBy`**: one occurrence enclosed by another's inner
  space.

This vocabulary closely resembles the Region Connection Calculus
(RCC, Randell, Cui and Cohn 1992), a foundational framework in
qualitative spatial reasoning. RCC formalises binary topological
relations between regions: disconnected, externally connected,
partial overlap, equal, tangential proper part, non-tangential
proper part, and their inverses. The KerML library uses a slightly
different decomposition, friendlier to engineering use, with
comparable expressive power.

Most modellers will not use these spatial relations directly.
Chapter 40 of the SysML v2 book covers geometry modelling in
depth. Everyday MBSE typically expresses spatial structure
through decomposition into parts and connections.

## Composable temporal-spatial relations

Temporal and spatial relations are composable. The library
defines two convenient combinations:

- **`Within`** is both `HappensDuring` and `InsideOf`. The
  smaller occurrence is enclosed by the larger in **both** time
  and space.
- **`WithinBoth`** is both `Within` and `HappensWhile`. The two
  occurrences cover the same 4D region exactly ("both are within
  each other").

These are mostly used inside the library to assert different
feature semantics. You will rarely write them by hand.

## See also

- [[sysml2-occurrences-4d]] for the 4D worldview.
- [[sysml2-portions-and-individuals]] for the portion vocabulary
  used by these relations.
- [[sysml2-occurrence-context-and-variables]] for the `this`
  context and variable features as time-functions.
