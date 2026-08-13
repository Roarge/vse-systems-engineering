---
title: "Base Architecture in SYSMOD: the source perspective"
slug: sysmod-base-architecture-source
type: concept
layer: sysmod
summary: "SYSMOD's Base Architecture: the abstraction dial, reuse, innovation prompts, and coupling into the architecture chain"
tags: [sysmod, base-architecture, abstraction, reuse, innovation, coupling, constraint-requirement]
sources:
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §4.7 (Describe the Base Architecture)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §5.7 (Base Architecture)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §7.5 (How to model the Base Architecture)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §11.6 (Zigzag Pattern)"
    raw: sysmod.pdf
related:
  - base-architecture-corollaries
  - sysmod-zigzag-pattern
  - sysmod-architecture-kinds-and-coupling
  - sysmod-system-context-source
  - sysmod-problem-statement-and-objectives
  - sysml2-base-architecture-and-federation
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [project-setup, architecture-design]
---

# Base Architecture in SYSMOD: the source perspective

## Contents

- Orientation and the plugin's repositioning
- The source definition
- The abstraction dial
- Reuse across similar projects
- The disruptive-innovation prompt
- How the source represents it
- Coupling forward into the architecture chain
- The zigzag closing point
- Where the plugin diverges
- See also

## Orientation and the plugin's repositioning

The plugin's authoritative account of the Base Architecture is
methodology §2, summarised at [[base-architecture-corollaries]].
Read that first. This page records where the concept came from and
what the source says about it, because the plugin adopted the term
but changed its position in the process, and the difference matters
when a reader meets SYSMOD material in the wild.

The repositioning, stated up front:

| Aspect | SYSMOD | The plugin (§2) |
|---|---|---|
| What it is | A product the System Architect describes, taking System Idea and System Objectives as inputs | Exogenous constraint the project acknowledges and references, never justifies (§2.1 corollary 1) |
| Who authors it | The System Architect, as project work | The parent organisation, customer, parent product, or regulator, outside the project |
| Story posture | Not applicable, SYSMOD is use-case driven | Stories move forward from it (§2.1 corollary 2), and agents shall not reverse-engineer justifications for it (§2.6 rule 7) |
| Expression | Structural blocks, optionally covered by a constraint requirement | A `library package` of `part def`s with `require constraint` clauses (§2.2) |

The SysML v2 expression is a genuine translation rather than a
restatement. Guidance §7.5 is written against SysML v1 stereotypes
and block diagrams, and none of that syntax carries over.

## The source definition

The Base Architecture is defined as the given Physical Architecture
at the project start that constrains the solution space. Its stated
purpose is to define the level of abstraction of the Requirements
and to provide the scope for innovation and for architectural and
technical decisions.

The reasoning behind it is an observation about requirements. Most
requirements already include some technical decisions, and the
author records having rarely seen absolutely solution-free
requirements. The Base Architecture is the name for those technical
decisions that are already fixed at the beginning of a project, and
the source treats them as constraint requirements of the system.

The worked illustration is deliberately plain. A car has four
wheels, an aircraft two wings. That is typically already settled
when the project starts, the engineers are not asked to think of
different solutions, and the system requirements are written on top
of those architectural decisions. Developing a car or an aircraft
with a different architecture remains possible, and in that case
the project needs a different Base Architecture.

## The abstraction dial

The single most portable idea on this page is that the Base
Architecture has a dial, and that the dial sets how much room the
project has.

- A **more abstract** Base Architecture opens the solution space of
  the system.
- A **more concrete** Base Architecture leaves little space for
  innovation.

The source pins both ends to a recognisable project shape. A
manufacturer releasing a new version of its product every year has
a concrete Base Architecture, namely the predecessor architecture
with some abstractions added to open the solution space for minor
improvements. A company developing an entirely new product never
seen before needs a very abstract Base Architecture.

## Reuse across similar projects

The Base Architecture description can be reused for projects of
similar systems. In a very small entity that runs a sequence of
related projects, this is the cheapest reuse available, because it
is a description of decisions already made rather than a body of
design work.

## The disruptive-innovation prompt

The source treats the Base Architecture as an excellent source for
spotting the potential for disruptive innovation. The argument is
that it records concepts of the form "we have always done it that
way", which makes them visible, and that asking "what if we change
our common architectural approaches?" can open up previously
untouchable innovation potential.

The prompt only works because the givens have been written down.
An unwritten Base Architecture cannot be questioned, because nobody
can see it.

## How the source represents it

The representation runs across a spectrum rather than sitting at
one point.

1. As a simple input, a sketch together with a brief textual
   description. The source calls this the napkin architecture or
   the beermat architecture.
2. As a more formal input, part of the system model as structure,
   with a described part for each element of the Base Architecture
   and a brief textual description attached to each.
3. Optionally, with its own Base Architecture Context, because the
   context of the system is typically relevant to the Base
   Architecture as well. That context holds the Base Architecture
   system element together with the actors. See
   [[sysmod-system-context-source]].
4. Optionally, covered by a constraint requirement named for the
   Base Architecture, with a refine relationship from the Base
   Architecture element to that constraint requirement.

The steps above are the notation-neutral reading of guidance §7.5
and of the constraint-requirement step in the requirements
guidance. The diagram kinds and stereotypes those guidances name
are SysML v1 mechanics and are omitted deliberately.

## Coupling forward into the architecture chain

The Logical Architecture must conform to the Base Architecture. The
source gives exactly two ways to make that conformance hold in the
model:

- **strongly coupled**, where the Logical Architecture is a
  specialisation of the Base Architecture, or
- **loosely coupled**, where only allocate relationships run
  between the two architectures.

The trade-off between the two, and the rest of the architecture
chain that hangs off this choice, is on
[[sysmod-architecture-kinds-and-coupling]]. The plugin makes the
same binary choice at §2.3.3 and hardens it at §2.6 rule 3, which
requires exactly one relationship and never both.

## The zigzag closing point

The Base Architecture is where the zigzag pattern lands. Because
requirements in practice always carry some solution aspects, and
because implicit solution aspects are one of the causes of
requirements trouble, the source's instruction is to always
describe the architecture that lies behind the requirements. That
architecture is the Base Architecture. See
[[sysmod-zigzag-pattern]].

## Where the plugin diverges

Beyond the repositioning table above, three specific points.

- **The System Idea and System Objectives are not plugin inputs.**
  SYSMOD feeds them into the method that describes the Base
  Architecture. The plugin has no such artefacts in the model, and
  the Base Architecture arrives from outside the project entirely.
  See [[sysmod-problem-statement-and-objectives]].
- **The innovation prompt is bounded.** In the plugin the Base
  Architecture is updated only by deliberate change events under
  §2.7, of which replacement is externally driven. Asking what if
  the common architectural approaches changed is legitimate input
  to such an event. It is not licence for the project to redesign
  its own givens, and it never authorises fabricating stakeholders
  or stories to justify a given (§2.6 rule 7).
- **The expression is SysML v2 native.** A `library package` of
  `part def`s with `require constraint` clauses, per §2.2, not the
  stereotype-and-block form of the source's guidance.

## See also

- [[base-architecture-corollaries]] for the plugin's own position,
  the two corollaries, and the reverse-engineering guard.
- [[sysmod-zigzag-pattern]] for the mechanism that ties the Base
  Architecture to the abstraction level of the requirements.
- [[sysmod-architecture-kinds-and-coupling]] for the architecture
  taxonomy and the coupling trade-off.
- [[sysml2-base-architecture-and-federation]] for reusing and
  federating a Base Architecture in a SysML v2 model.
