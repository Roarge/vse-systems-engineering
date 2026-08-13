---
title: "System Context in SYSMOD: actors, Planet Environment, and the Death of the Actor"
slug: sysmod-system-context-source
type: concept
layer: sysmod
summary: "SYSMOD's system context: actor rules, the mandatory Planet Environment actor, and why actors are blocks not Actors"
tags: [sysmod, system-context, actors, planet-environment, item-flows, problem-space, death-of-the-actor]
sources:
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §4.11 (Identify the System Context)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §5.11 (System Context)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §7.9 (How to model the System Context)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §11.1 (The Death of the Actor)"
    raw: sysmod.pdf
related:
  - system-context-completeness
  - role-actor-coupling
  - sysmod-stakeholder-identification
  - sysmod-base-architecture-source
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [needs-and-requirements, architecture-design]
---

# System Context in SYSMOD: actors, Planet Environment, and the Death of the Actor

## Contents

- Orientation
- What the source's context holds
- The actor rule
- The Planet Environment actor
- Problem space against solution space
- The context specialisation chain
- The Death of the Actor
- Where the plugin diverges
- See also

## Orientation

The plugin's System Context is specified in methodology §3 and
summarised at [[system-context-completeness]], which carries the
four actor categories, the interface and item-flow obligations, and
the completeness checks. That page is authoritative and this one
does not repeat its table or its rules. What follows is the source
SYSMOD position, which the methodology adapted, so that a reader
can tell adopted material from plugin process.

## What the source's context holds

The System Context is described as the list of external entities
that interact with the system, together with the relevant item
flows between the system and those entities. The entities are
called system actors. Where it is relevant to the system of
interest, the context also describes structures of the system
actors, links between the actors, and interfaces.

The obvious actors are the users of the system and external systems
with communication interfaces. The source insists that the less
obvious ones are equally important, and names environmental effects
such as temperature, and mechanical systems such as the
installation surface of the system.

At least four categories of actors are to be considered: human
actors, external systems, environmental effects, and environmental
impact. More categories may be defined as part of tailoring the
methodology.

## The actor rule

One sentence in the source does most of the work: an actor always
interacts with the system.

Two consequences follow, and both are about the boundary between
the actor list and the stakeholder list.

- Stakeholders that do not directly interact with the system are
  not part of the actor list.
- Human actors are also stakeholders of the system. For non-human
  actors, the stakeholder is the responsible person or organisation
  behind the actor, and the source traces from the actor to that
  stakeholder.

See [[sysmod-stakeholder-identification]] for the stakeholder side
of the same boundary.

## The Planet Environment actor

The source treats one external entity as special. A systems
engineer must consider the impact of the system of interest on the
planet, so the actor Planet Environment is provided in the SYSMOD
model library under the environmental-impact actor category, and
the modelling guidance adds it as an additional mandatory actor,
with the reason stated plainly: every system has an impact on the
planet.

The guidance also asks for an item flow on the connector between
the system and that actor, typed by a Planet Impact item from the
same library or by a project-defined specialisation of it. The
mandatory actor and the mandatory flow travel together, because an
actor with no flow across the boundary records nothing.

## Problem space against solution space

The architecture methods refine the System Context and add
architecture-specific elements such as interfaces. The source
requires that this refined part be managed independently of the
requirements-specific parts of the System Context, and gives the
reason directly: to keep the problem space separate from the
solution space.

This is a housekeeping rule with a conceptual purpose. One context
artefact serving both stages quietly imports solution decisions
into the problem statement.

## The context specialisation chain

The source builds a small chain of contexts rather than a single
one.

1. A **Base Architecture Context**, created when the context of the
   system is relevant to the Base Architecture as well. See
   [[sysmod-base-architecture-source]].
2. The **System Context**, which specialises the Base Architecture
   Context when the project has chosen strong coupling. Inherited
   properties are then checked for redefinition, and the guidance
   flags the part property representing the system as the likely
   case.
3. A **per-architecture context**, for example a Logical
   Architecture Context, which specialises the System Context and
   owns a property that redefines the system property so that its
   type becomes the architecture in question.

*Mapping note.* In SysML v2 the redefinition step at levels 2 and 3
is the `:>>` operator applied to the system part, and specialisation
is `:>`. That is a mapping offered for orientation, not a claim
about the source, which is written against SysML v1.

## The Death of the Actor

The source recommends not using the SysML Actor model element, and
recommends keeping the actor *concept* exactly as the System Context
method describes it. The actor concept belongs to the methodology,
the Actor element belongs to the language, and the source insists
on distinguishing the language, the methodology, and the modelling
tool.

Two arguments are given.

- **System-ness is a role, not an inherent characteristic.** The
  term system is relative and depends on the viewpoint. From one
  viewpoint an entity is a system, from another it is a subsystem
  or an external system. Modelling an actor with the Actor element
  loses the ability to change viewpoint, because that element is
  defined as an external entity by construction and cannot be a
  system in another viewpoint. Using a block instead lets the same
  element be re-marked as a system or a subsystem without creating
  a second model element.
- **Actors need ports and internal structure.** The Actor element
  is a black-box element in SysML v1, so it permits neither
  internal structure nor ports. A block permits both, which allows
  a more detailed description of how the actor connects to the
  system of interest, and allows links between actors.

*Mapping note.* SysML v2 resolves this argument by construction.
The plugin's §3 types every actor as a `part def`, which is exactly
the practice this section argued for, so the guidance survives as
history rather than as a choice a plugin project still has to make.

## Where the plugin diverges

- **Planet Environment is not mandatory.** The plugin keeps
  environmental impact as one of the four actor categories, and
  leaves the population of that category project-determined. No
  actor is mandated by name.
- **Stakeholder and actor identity is fixed by a rule.** The plugin
  requires the same `part def` wherever an entity appears as a
  stakeholder and as an actor, and prohibits distinct part defs for
  the same entity (§3.6 rule 5). See [[role-actor-coupling]]. The
  source reaches a comparable outcome by applying two stereotypes
  to one element, which is a SysML v1 mechanism with no v2
  counterpart.
- **Actor categories serve different purposes.** In SYSMOD
  additional categories arrive through tailoring. In the plugin the
  four categories are a completeness discipline used when checking
  that nothing crossing the boundary has been missed, not a
  taxonomy a project is expected to extend.

## See also

- [[system-context-completeness]] for the plugin's actor
  categories, interface rules, and completeness checks.
- [[role-actor-coupling]] for the one-part-def rule and the
  story-role to use-case-actor coupling.
- [[sysmod-stakeholder-identification]] for the stakeholder side of
  the actor boundary.
- [[sysmod-base-architecture-source]] for the Base Architecture
  Context that opens the specialisation chain.
