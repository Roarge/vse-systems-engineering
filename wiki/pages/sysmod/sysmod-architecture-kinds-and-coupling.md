---
title: "SYSMOD architecture kinds, coupling, and FAS"
slug: sysmod-architecture-kinds-and-coupling
type: concept
layer: sysmod
summary: The six architecture kinds, strong versus loose coupling, and the FAS functional-architecture bridge
tags: [sysmod, architecture-kinds, logical-architecture, product-architecture, coupling, allocation, fas]
sources:
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §5.17 to §5.21 (System, Functional, Physical, Logical, and Product Architecture)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §4.17 to §4.19 (Model the Functional, Logical, and Product Architecture)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §7.15 and §7.16 (How to model the Logical and Product Architecture)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §11.2 and §11.7 (FAS, Coupling of System Architectures)"
    raw: sysmod.pdf
related:
  - sysmod-base-architecture-source
  - sysmod-functional-analysis-chain
  - architectural-design-workflow
  - ambse-trade-studies
  - sysml2-base-architecture-and-federation
  - sysml2-allocations-overview
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [architecture-design]
---

# SYSMOD architecture kinds, coupling, and FAS

## Contents

- Orientation
- The taxonomy of architecture kinds
- Logical against Product, and the abstraction discriminator
- Strong and loose coupling
- FAS in a nutshell
- Mapping the coupling constructs to SysML v2
- Where the plugin diverges
- See also

## Orientation

The plugin's architecture stages are methodology §6 (analysis and
trade studies) and §7 (design and decomposition), summarised at
[[architectural-design-workflow]]. Architecture in the plugin
emerges from stories through trade studies. This page states
SYSMOD's architecture vocabulary and its coupling mechanics on
their own terms, because the coupling choice is one the plugin
adopted verbatim for the Base Architecture, and because the
vocabulary shows up in any conversation about layered
architectures.

## The taxonomy of architecture kinds

System Architecture in SYSMOD is the generic term for every
architecture kind of the system. It is an abstract product, that
is, it does not exist in reality, and only its specialisations do.

```text
System Architecture (abstract)
├── Functional Architecture
└── Physical Architecture (abstract)
    ├── Base Architecture
    ├── Logical Architecture
    ├── Product Architecture
    └── Test Architecture
```

Physical Architecture is likewise a general term rather than a
thing, covering the Logical, Product, Base, and Test
Architectures. Two clarifications the source attaches to it are
worth keeping.

- **Software is a physical element.** A physical element represents
  a real-world element, and software is one, so software belongs to
  the Physical Architecture.
- **The author does not insist on his own definitions.** What the
  source calls crucial is that a project has its own clear
  definition of the architecture kinds it uses, whether or not
  those definitions match SYSMOD's or ISO's.

## Logical against Product, and the abstraction discriminator

**Logical Architecture.** The technical concepts and principles of
the system, for example an electric motor, a valve, a display, or a
control unit. It is an abstract Physical Architecture, the first
version of one in a top-down reading, and it is reusable across
similar systems such as product families or generations.

**Product Architecture.** The concretisation of those concepts and
the most detailed architecture specification present in the system
model. The source's example is an electric motor in the Logical
Architecture specialised by an electric motor type 42X in the
Product Architecture, carrying vendor, size, power consumption, and
the mechanical, electrical, and software interfaces. The next level
of detail below it belongs to discipline-specific models such as a
software model or a CAD model, and is out of scope for the system
model.

The discriminator between the two is abstraction, and the source is
candid about what that costs: abstraction cannot be measured, so
the border between Logical and Product cannot be defined cleanly.
Separating them explicitly costs effort, so it should be done only
where it offers an advantage and adds value. Where it does not, the
project models one Physical Architecture that mixes technical
concepts and concrete specifications, and calls it the Physical or
Product Architecture.

## Strong and loose coupling

The architectures are related to each other, and the source offers
exactly two ways of implementing any of those relationships in the
model. One relationship is fixed rather than chosen: Functional to
Logical is always loose.

| | Loose coupling | Strong coupling |
|---|---|---|
| Relationship | Allocation, depicted as a matrix | Generalisation, that is, specialisation of architecture elements |
| What it establishes | A mapping only, with no further impact in the model | The dependent architecture inherits all features, may add new ones, and may redefine existing ones |
| Change propagation | The dependent architecture does not recognise a change in the leading one. The System Architect tracks it manually | A change in the leading architecture is forwarded automatically |
| Cost | Manual tracking discipline | The model can become very complex and hard to manage, depending on the tool and the modellers |

The source's assessment is even-handed: strong coupling is
straightforward in theory and demanding in practice, loose coupling
is cheap in the model and expensive in attention.

Strong coupling between a Logical Architecture and a Base
Architecture only makes sense when the Base Architecture is the
more abstract of the two. See [[sysmod-base-architecture-source]].

## FAS in a nutshell

Functional Architectures for Systems is an independent method that
SYSMOD treats as a supplement rather than as one of its own
products. Its declared position is between the analysis methods and
the architecture methods: it takes Use Case Activities as input,
and its output is an optional input to the Architecture Process.

The problem it solves is a difference of viewpoint. The
Requirements Engineer looks for user-oriented behaviours and groups
functions by use case. The System Architect looks for functional
cohesion and needs a grouping the technical components can be
derived from. The Functional Architecture is the bridge between the
functional requirements and the Physical Architecture.

The steps, in outline:

1. Start from the Use Case Activities, which are the set of
   required system functions clustered by use case. That clustering
   suits the Requirements Engineer.
2. The System Architect regroups the same functions by functional
   cohesion, so that functions doing similar things become members
   of one functional group. The method supplies heuristics for the
   grouping, and the source is clear that the decision remains the
   System Architect's.
3. Each group becomes a functional element. Groups are connected
   where functions in one group produce outputs that are inputs of
   functions in another, and the interfaces on those connections
   specify the inputs and outputs.
4. The functional elements are allocated onto a Physical
   Architecture, recorded as an allocation and depicted as a
   matrix.

The Functional Architecture is independent of the technology that
implements the functions, and independent of the technical
components of the Logical and Product Architectures. It is not
independent of the Base Architecture, on which it does depend.

See [[sysmod-functional-analysis-chain]] for the Use Case
Activities that feed it.

## Mapping the coupling constructs to SysML v2

Offered for orientation. The source is written against SysML v1,
and none of its stereotype or diagram mechanics carry over.

| SYSMOD construct | SysML v2 |
|---|---|
| Generalisation between architecture roots | Specialisation, `:>` |
| Allocate relationship between architectures | An allocation, see [[sysml2-allocations-overview]] |
| Functional block with ports | A `part def` with ports |

## Where the plugin diverges

- **The coupling choice is adopted, and hardened.** Methodology
  §2.3.3 offers exactly the same two options for the relationship
  between the project's system and the Base Architecture, and
  §2.6 rule 3 requires exactly one of them, never both. That is
  stricter than the source, which leaves the pairing open.
- **There is no Logical-to-Product ladder.** The plugin does not
  prescribe a descent through named architecture kinds.
  Architecture emerges from stories through trade studies (§6) and
  is then decomposed into subsystems (§7). See
  [[ambse-trade-studies]]. A project that wants the SYSMOD ladder
  can express it as successive specialisations, without plugin
  support for the stages.
- **FAS is not a plugin stage.** It is offered here as an optional
  technique, useful when functional cohesion is the decomposition
  criterion a trade study ought to be scoring.

## See also

- [[sysmod-base-architecture-source]] for the architecture kind the
  plugin did adopt.
- [[sysmod-functional-analysis-chain]] for the analysis chain that
  produces the FAS input.
- [[architectural-design-workflow]] for the plugin's §7 stage.
- [[ambse-trade-studies]] for how the plugin selects an
  architecture.
- [[sysml2-base-architecture-and-federation]] for reuse and
  federation in a SysML v2 model.
- [[sysml2-allocations-overview]] for the v2 allocation construct.
