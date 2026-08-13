---
title: "Complexity, dynamics, and the context of the new engineering game"
slug: sysmod-neg-complexity-and-dynamics
type: concept
layer: sysmod
summary: "Why complex and dynamic markets break process-first engineering: two complexity definitions, Conway's Law, and CPS"
tags: [neg, complexity, dynamics, conways-law, cyber-physical-systems, interdisciplinary, industry-4-0]
sources:
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §3.2 (Complexity and Dynamic)"
    raw: new-engineering-game.pdf
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §3.3 (Conway's Law)"
    raw: new-engineering-game.pdf
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §3.4 (Cyber-physical Systems)"
    raw: new-engineering-game.pdf
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §3.5 (Interdisciplinary Engineering)"
    raw: new-engineering-game.pdf
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §2.4 (The Fourth Industrial Revolution) and §3.1 (Globalization)"
    raw: new-engineering-game.pdf
related:
  - sysmod-neg-organisational-tools
  - sysmod-neg-human-dimension
  - sysmod-neg-why-mbe
  - phas-eai-overview
  - sysmod-base-architecture-source
confidence: medium
created: 2026-08-13
updated: 2026-08-13
referenced_by: [project-setup]
---

# Complexity, dynamics, and the context of the new engineering game

## Contents

- Orientation: a predicted revolution
- Two definitions of complexity
- Complexity conservation
- Inherent and self-made complexity
- Dynamics as the frequency of surprises
- Why strong process orientation fails
- Conway's Law
- Cyber-physical systems
- Interdisciplinary engineering
- Where the plugin stands
- See also

Confidence note: this page is `medium` rather than `high` because part
of what it carries is prediction rather than established practice. The
two complexity definitions, Conway's Law, and the cyber-physical
systems material are stable and widely corroborated. The framing that
holds them together, a fourth industrial revolution and the Industry
4.0 programme, was written in 2018 as a forecast. Read the framing as
the source's argument for urgency and the definitions as the reusable
content.

## Orientation: a predicted revolution

The source opens on an argument about markets rather than about
engineering. Mass production and heavily optimised processes produced
organisations that are effective but inflexible, which is no problem
while the environment stays stable. The claim is that it has stopped
being stable, and that the fourth industrial revolution is unusual in
being predicted rather than recognised afterwards, which the source
treats as an opportunity to act deliberately. Two consequences follow.
Connected machines and data-driven decision making shift production
towards mass customisation, where batch sizes stay high but each
product is adapted to specific needs, and the craftsmanship that three
revolutions of automation removed from people returns, because the
engineering environment itself now demands it. Globalisation supplies
the pressure behind both. It appears to widen the market and in fact
narrows it, because any producer can sell anywhere and the competitors
can therefore be anywhere too.

## Two definitions of complexity

The source gives two definitions, deliberately, because they answer
different questions.

- **Internal view.** A characteristic of a complex entity is a large
  number of different elements and different kinds of relationships
  between the elements.
- **External view.** Complexity of an entity is a measure for the
  number of surprises from the perspective of an observer of the
  entity.

Neither is easy to quantify. A surprise cannot be defined
unambiguously, so the exact number of surprises at which an entity
turns from simple to complex is a subjective valuation.

The internal view is nonetheless operational, and that is the practical
part of the section. Element types and relationship kinds can be
counted. The threshold at which the count means "complex" cannot be
derived, so a project defines its own categories and attaches
consequences to them. The worked example is a rule that an entity in
the category Complex receives an additional verification and validation
step while an entity in the category Simple does not.

## Complexity conservation

The source cites the First Law of Systems Engineering, attributed to
Olivier de Weck. Stated in the source's words: given a fixed set of
functional requirements and a fixed human organisational architecture,
the total complexity of a system is conserved. Complexity can be traded
between the components of the system and its interfaces and topology,
but it cannot be decreased beyond a minimum level.

The source decomposes the conserved quantity into three contributions:
the number and heterogeneity of the components, the number and
heterogeneity of the interactions between the components, and a scaling
factor for the dependency structure.

**Source-quality note.** The equation that expresses the law does not
survive text extraction from the source in a form this page can trust,
so the law is carried here in prose only. A reader who needs the
algebraic form should return to the printed figure in the source rather
than reconstruct it from this page.

The law is stated for technical systems, and the source immediately
applies the same reasoning to organisations.

## Inherent and self-made complexity

Two kinds of complexity behave differently under redesign.

- **Self-made complexity** arises from poorly designed structures and
  processes. A redesign can reduce it.
- **Inherent complexity** cannot be reduced. It mirrors the essential
  structure and processes needed to perform the requested functions.

What can be done with inherent complexity is to move it between
abstraction levels. The source's example is outsourcing. Moving some
functions into separate entities reduces the complexity of the
originating unit while increasing the complexity of the whole
organisation. The total does not change, and the claim is only that the
complexity becomes more manageable. The same manoeuvre is observable in
technical systems.

## Dynamics as the frequency of surprises

Dynamics is treated as one parameter for the frequency of surprises in
a complex system. High dynamics produce more surprises.

The consequence is the sharpest statement in the chapter. A simple
system in a stable environment can turn into a complex system in a
dynamic environment. The system does not change. The environment does.
Read against the two definitions above, the number of elements and
relationships needed before an observer calls something complex is
higher in a stable environment than in a dynamic one.

## Why strong process orientation fails

Strongly process-oriented organisations get into trouble in a dynamic
environment, because processes cover known workflows and a surprise is
by construction not a known workflow. The prescription the source takes
from Wohland is that the first question when a surprise occurs is not
how to handle it but who should handle it, so the instruction is to
find the right person instead of the right process. Otherwise the
surprise becomes an exception in one process, is deferred to another
process where it is also an exception, and so on.

The source anticipates the obvious objection. Finding the right person
can itself be described as a process, and the reply is that this is a
different level of acting rather than a refutation.
[[sysmod-neg-human-dimension]] carries the argument through to the
organisational side, including the tension it opens with the plugin's
own design rationale.

## Conway's Law

Conway published the law in 1968: any organisation that designs a
system, defined broadly, will produce a design whose structure is a
copy of the organisation's communication structure.

The source is careful about one word. Conway wrote communication
structure, not organisation structure. The organisation structure is
visible and usually documented in organigrams, while the communication
structure is seldom documented and not well known. The overlap is
typically large, and the source proceeds on that overlap while asking
the reader to keep the distinction in mind.

The law runs in both directions. A product mirrors the structure of the
developing organisation, because that structure constrains the solution
space, and the organisation mirrors the product structure, because it
optimises its work units by aligning them with the product. Coplien and
Harrison are cited as recommending that the two stay compatible. The
source insists that the law is neither good nor bad but simply a fact
with three consequences.

1. If the structure of the organisation does not reflect the structure
   of the product, the project gets into trouble.
2. It is hard for an organisation to create innovations that do not
   reflect the existing structures.
3. A disruptive innovation requires organisational changes and must
   overcome organisational resistance.

A product with a different base architecture would require a different
organisational structure and can make existing departments, roles, and
people superfluous, which is where the resistance comes from. See
[[sysmod-base-architecture-source]] for the concept itself and
[[sysmod-neg-organisational-tools]] for the pattern the source proposes
for living with consequence 3.

## Cyber-physical systems

Cyber-physical systems are presented as the technical enabler of the
predicted revolution, and as an evolutionary step rather than an
invention. They combine embedded systems, with their sensors and
actuators, with digital networks, and act as glue between the physical
and the virtual world.

The source quotes Lee's 2008 definition: cyber-physical systems are
integrations of computation with physical processes, where embedded
computers and networks monitor and control the physical processes,
usually with feedback loops in which physical processes affect
computations and the reverse. It then names what the definition misses
after a decade, the connection to open networks such as the internet.
Openness is the load-bearing property, because it allows a system to be
extended with functionality nobody considered when it was developed.

The digital twin is described as a special kind of cyber-physical
system in which one part is the physical product and the other a
virtual representation, interconnected so that the two synchronise
their values and states. Virtual coverage of the physical part runs
from a few properties upwards, and full coverage is impossible, because
a complete copy would simply be the thing itself.

## Interdisciplinary engineering

The source argues that the specific engineering disciplines are not the
weak spot. The weak spot is the seam between them. There was a time
when each discipline built its artefact and the artefacts were assembled
at the end across manageable interfaces, and increased product and
market complexity no longer fits that separation. The slogan offered for
the effect is that one plus one is no longer two but three, that the
best solution is not the sum of the best parts but a set of
well-balanced parts, and that the engineers of the individual parts
cannot produce such a set on their own.

Two observations from this section matter more to a very small entity
than the general argument does.

- **Size is not complexity.** Bigness does not imply complexity, and
  being small does not prevent it. The source names hearing aids,
  control units, and pumps as physically small and genuinely complex
  systems.
- **Systems engineering can become another silo.** Although systems
  engineering is defined as an interdisciplinary approach, it is often
  implemented in the spirit of traditional silo thinking and becomes
  one more silo, which is multidisciplinary rather than
  interdisciplinary work. The source records that INCOSE has discussed
  replacing "interdisciplinary" with "transdisciplinary" for exactly
  this reason, and that the real tasks of systems engineering lie in
  the gaps between the disciplines. A large part of the systems
  engineer's role is therefore moderation, which makes soft skills a
  mandatory capability rather than a bonus.

The source scores collaboration between disciplines on four levels and
maps those levels onto the Cynefin domains. Both are carried on
[[sysmod-neg-organisational-tools]], because they are decision aids
rather than context.

## Where the plugin stands

The plugin's own case for model-based working is thesis-derived. It runs
through the PHAS-EAI design principles R1 to R4, and
[[phas-eai-overview]] states the constructs behind them. This page adds
the industry-side account of the same pressures, written independently
and from a practitioner's viewpoint, which is worth having when the
discipline has to be justified to somebody outside the project.
[[sysmod-neg-why-mbe]] carries the source's own answer.

Two bridging observations, offered as commentary rather than as source
content.

- **The complexity formalisations are complementary, not rival.** The
  source counts elements and relationships, or counts surprises.
  PHAS-EAI counts feasible distinct options in a configuration space,
  written `C = |O^Delta|`. Each measures something real and none
  reduces to another, so a project that wants a number should pick the
  one that matches the decision in front of it rather than attempt a
  unification.
- **The external view and prediction error rhyme.** Defining complexity
  as a count of surprises from an observer's perspective puts the
  observer's expectations inside the definition, which is the same move
  PHAS-EAI makes when it frames dependability work around prediction
  error and observation precision. The resemblance is structural rather
  than a shared derivation.

## See also

- [[sysmod-neg-organisational-tools]] for the Turtles and Rabbits
  pattern, the Cynefin domains, and the four collaboration levels.
- [[sysmod-neg-human-dimension]] for the organisational and human
  consequences of the same pressures.
- [[sysmod-neg-why-mbe]] for the source's argument that models are the
  answer to them.
- [[sysmod-base-architecture-source]] for the base architecture that
  Conway's Law propagates into the organisation.
- [[phas-eai-overview]] for the plugin's own design rationale.
