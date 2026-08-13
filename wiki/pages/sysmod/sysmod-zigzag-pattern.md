---
title: "The zigzag pattern between requirements and architecture"
slug: sysmod-zigzag-pattern
type: pattern
layer: sysmod
summary: Why requirements always carry solution aspects, and the what-how alternation that descends the abstraction levels
tags: [sysmod, zigzag, requirements, architecture, abstraction-level, base-architecture, solution-free]
sources:
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §11.6 (Zigzag Pattern)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §5.7 (Base Architecture)"
    raw: sysmod.pdf
related:
  - sysmod-base-architecture-source
  - system-stories-workflow
  - architectural-analysis-workflow
  - ambse-system-requirements-derivation
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [needs-and-requirements, architecture-design]
---

# The zigzag pattern between requirements and architecture

## Contents

- Problem
- Context
- Forces
- Solution
- Consequences
- Where the plugin diverges
- See also

## Problem

Requirements are supposed not to anticipate the solution.
Requirements describe the what, and the system architecture
describes the how. The source poses the awkward question directly:
are your requirements really free of any solution? Its answer is
that requirements are solution-free and contain solution aspects at
the same time.

## Context

The pattern applies whenever requirements are written at more than
one level of abstraction, which is every project that decomposes a
system. It also applies to a project that believes its top-level
requirements are solution-free, because that belief is exactly what
the pattern tests.

## Forces

- A requirement that names a solution constrains the designer who
  has to satisfy it.
- A requirement that names nothing cannot be written at all, since
  every requirement below the topmost level is written about
  something already chosen.
- Solution aspects that are present but unwritten cannot be
  reviewed, argued with, or changed deliberately.

## Solution

Follow the descent the source walks, and accept the alternation
rather than trying to escape it.

1. Start from requirements assumed to be absolutely solution-free,
   for example requirements about a transportation system for
   people.
2. Derive an architecture that satisfies them, for example one that
   specifies a car. This is the typical what and how pair.
3. Observe that the solution now generates new requirements about
   aspects of itself, for example requirements about the features
   of the engine of the car. Those requirements would not exist if
   the technical solution were a ship or an aircraft.
4. Observe that the engine requirements are solution-free from the
   viewpoint of their own level while carrying the solution aspects
   of the level above.
5. Derive a solution from them in turn, for example a hybrid
   engine, which generates further requirements, and so on.

The alternation of what and how down the abstraction levels is the
zigzag.

The pattern's operative instruction follows from step 4. Because
requirements in practice always contain some solution aspects, and
because those aspects are often implicit, the source names implicit
solution aspects as one of the causes of requirements being a sore
spot in many projects. The remedy it prescribes is to always
describe the architecture that lies behind the requirements, and it
names that architecture: it is the Base Architecture. See
[[sysmod-base-architecture-source]].

## Consequences

- The abstraction level of a requirement set becomes a stated
  property rather than an assumption, because the architecture
  behind it is written down. The source states the same
  relationship from the other side: the Base Architecture sets the
  abstraction level for the system requirements.
- The project accepts that it cannot achieve solution-free
  requirements, and spends its effort on making the solution
  content explicit instead of on removing it.
- One artefact has to be maintained that would otherwise not exist.
  In a very small entity that artefact may be a sketch and a
  paragraph, which the source explicitly permits.

## Where the plugin diverges

The plugin walks the same zigzag, with a different canonical
artefact at each turn.

| Turn | SYSMOD | The plugin |
|---|---|---|
| The what | Requirements at one abstraction level | Stakeholder stories above the boundary, system stories below it |
| The how | An architecture level derived from them | The architecture resolved by a §6 trade study |
| The descent | The next requirement level derived from the chosen architecture | §5 derivation of system stories, then §7 decomposition into subsystems, recursively |

SYSMOD zigzags between requirement levels and architecture levels.
The plugin zigzags between story granularities and subsystem
decompositions, and institutionalises the two turns as the §5
derivation and the §6 trade-study loop. The mechanism is the same,
the artefact that carries it is not. See
[[system-stories-workflow]] and [[architectural-analysis-workflow]].

## See also

- [[sysmod-base-architecture-source]] for the architecture that
  sits behind the requirements.
- [[system-stories-workflow]] for the plugin's §5 derivation.
- [[architectural-analysis-workflow]] for the plugin's §6 trade
  studies.
- [[ambse-system-requirements-derivation]] for the AMBSE account of
  the same descent.
