---
title: "SysML 2.0 Occurrences and 4D Modelling"
slug: sysml2-occurrences-4d
type: concept
layer: sysml2
tags: [occurrences, 4d-modelling, perdurantism, spacetime, kerml]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Sections 25.1 and 25.2, pages 144 to 146. New chapter in the 2026-04 release."
    raw: sysmlv2.pdf
  - citation: "McTaggart, J. M. E. (1908). The Unreality of Time. Mind, 17(68): 457-484."
    raw: null
  - citation: "Bock, C. and Galey, J. (2019). Four-dimensional ontology in systems requirements modeling."
    raw: null
related:
  - sysml2-portions-and-individuals
  - sysml2-temporal-spatial-relations
  - sysml2-occurrence-context-and-variables
  - sysml2-actions
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-behaviour]
---

# SysML 2.0 Occurrences and 4D Modelling

Most engineers think about systems the way they think about
everyday objects: a part is a thing, it has a position, and the
properties may change over time. The drone has a position, a
battery level, a flight status. You point at it and ask "what is
its mass right now?", expecting a single number.

SysML 2.0 takes a different view. The entities modelled by the
language (parts, items, ports, connections, actions, states) are
not **things with changing properties**. They are **4D extents**:
complete spatiotemporal volumes that include the entire history of
the modelled entity, from the moment it comes into existence until
the moment it ceases to exist. Properties that "change over time"
are not values being reassigned. They are functions over the
entity's temporal extent. This is what 4D modelling means, and it
is the foundation of how SysML 2.0 talks about occurrences. This
material was added as Chapter 25 in the 2026-04 release of the
SysML v2 book.

## A concrete payoff

Consider collision avoidance for two drones flying near each
other. In 4D terms, the question "will they collide?" is just
whether their spacetime extents intersect over the planning
horizon. A single geometric check, rather than a sequence of
moment-by-moment position comparisons. The 4D worldview
generalises this kind of reasoning to every property that has a
temporal aspect.

## Endurantism versus perdurantism

The way we describe a system is shaped, often unconsciously, by
what we believe a "thing" fundamentally **is**. Philosophy has two
competing answers (Sections 25.1 and 25.2):

- **Endurantism** says that an object is wholly present at every
  moment of its existence. Its history is a sequence of states it
  passes through, but the object itself is the same
  three-dimensional thing throughout.
- **Perdurantism**, or **four-dimensionalism**, treats an object
  as a four-dimensional whole, extending through time the way it
  extends through space. Its state at any moment is a temporal
  part of that whole, what KerML and SysML call a **portion**.

The difference rarely surfaces in everyday reasoning, but it makes
a real difference for modelling languages, which have to commit to
one of them in their formal semantics.

**SysML 2.0 commits to four-dimensionalism.** The roots of this
view go back to McTaggart (1908), who distinguished two ways of
thinking about time: one with a privileged moving present, the
other a fixed earlier-than ordering of events with no privileged
"now". Quine (1960) and later four-dimensionalists developed this
into a metaphysics in which ordinary objects are **spacetime
worms**, extended in time the way they are extended in space. The
translation of these ideas into engineering modelling was carried
out by Conrad Bock and collaborators across a series of papers,
applying the 4D framework first to behaviour modelling
(Bock and Odell 2011) and later to systems requirements modelling
(Bock and Galey 2019).

## What an occurrence is

In SysML 2.0's taxonomy, an **occurrence** is the most general
type that exists in space and time. Every item, part, port, and
connection is an occurrence because we can determine where and
when they exist. Behaviours (actions, states, and so on) are also
occurrences because they happen somewhere in time, and sometimes
also somewhere in space.

This is in contrast with **attributes**, which classify abstract
mathematical concepts. The number "5" does not exist in our
four-dimensional reality. You cannot point at it or determine when
it exists. It is an abstract concept that can be **represented**
in the physical world (in a data package, for example) or
**characterise** something (the number of things or a physical
property of a component). For programmers: occurrence is to
attribute as memory location is to value.

The distinction is essential because the concept of space and time
(referred to as "4D semantics") is modelled in the standard
library rather than in the built-in mathematical semantics of
KerML.

## Occurrence definition and usage

Like every other modelling element in SysML 2.0, an occurrence has
a definition form and a usage form. An **occurrence definition** is
declared with `occurrence def`, and an **occurrence usage** with
`occurrence`.

```sysml
occurrence def DroneProject {
    occurrence engineSubproject : EngineProject;
    part systemContext;
}
occurrence def EngineProject;
```

In practice, you will rarely declare these directly. Most of the
time you will use the more specific kinds (part, item, action,
state, case, and so on), which are all special kinds of
occurrences. Declaring a general occurrence is useful in rare
cases when you need an entity at the most abstract 4D level: a
project root, an ambient context, or a custom 4D structure that
does not fit any of the more specific kinds.

## See also

- [[sysml2-portions-and-individuals]] for the portion vocabulary
  (snapshots, time slices, space slices) and the `individual`
  keyword.
- [[sysml2-temporal-spatial-relations]] for `==` versus `===`,
  Allen's interval algebra, and the spatial relations.
- [[sysml2-occurrence-context-and-variables]] for the `this`
  feature, suboccurrence versus portion, and time-functions.
- [[sysml2-actions]] for actions as occurrences.
