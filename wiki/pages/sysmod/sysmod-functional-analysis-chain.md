---
title: "The SYSMOD functional analysis chain: use cases to domain knowledge"
slug: sysmod-functional-analysis-chain
type: process
layer: sysmod
summary: System Use Cases, System Processes, Use Case Activities, and Domain Knowledge as the SYSMOD functional chain
tags: [sysmod, use-cases, system-processes, use-case-activities, domain-knowledge, functional-decomposition]
sources:
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §4.12 to §4.15 (Identify System Use Cases through Model the Domain Knowledge)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §5.12 to §5.15 (System Use Cases, System Processes, Use Case Activities, Domain Knowledge)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §7.10 to §7.13 (How to model use cases, processes, activities, and domain knowledge)"
    raw: sysmod.pdf
related:
  - user-story-canonical-artefact
  - role-actor-coupling
  - ambse-use-case-driven-elicitation
  - sysmod-system-context-source
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [needs-and-requirements]
---

# The SYSMOD functional analysis chain: use cases to domain knowledge

## Contents

- Divergence banner
- System Use Cases
- Use case anatomy
- The function bucket
- System Processes
- Use Case Activities
- Domain Knowledge
- Where the plugin diverges
- See also

## Divergence banner

**Read this page for elaboration technique, not for requirements
structure.** This chain is where the plugin departs furthest from
SYSMOD. In the plugin the user story is the canonical artefact
(methodology §1, see [[user-story-canonical-artefact]]), and a use
case is one optional mode of behavioural elaboration of a story,
bound to it through the shared objective (see
[[role-actor-coupling]]). SYSMOD is use-case driven, so its use
cases carry the requirements structure that the plugin's stories
carry. Nothing on this page describes plugin process.

## System Use Cases

A System Use Case is a service the system provides to its actors,
seen from outside in. The source's argument for the outside-in view
is a usability one: an inside-out treatment of functional
requirements can produce a system that satisfies all of them while
missing what the users need. Its illustration is the projector
remote control, which provides every required function while
burying the primary use cases among too many buttons.

Three properties define one.

- **It is triggered by a system actor** and returns a result that
  is of value to actors or stakeholders of the system.
- **Its behaviour is timely cohesive**, meaning the system supports
  no timely interruption of it, such as storing the behaviour's
  state to resume later. The source's example is buying a ticket at
  a ticket machine: once a ticket is selected the customer cannot
  leave for a coffee and return to pay. The use case runs to its
  intended end or is cancelled entirely and started again from the
  beginning.
- **Its value may land elsewhere than with the trigger.** In an
  alarm system, the actor Thief triggers the use case that reports
  an alarm, and the stakeholder who is interested in the result is
  the owner of the property.

## Use case anatomy

A System Use Case description carries at least the associated
system actors, the trigger that starts it, the result, a brief
textual description of two to five sentences, pre- and
postconditions, and its Use Case Activity. The method adds
traceable paths to the functional requirements the use case covers
and to the non-functional requirements relevant to it.

The set of use cases is a flat list with no hierarchy of super- and
sub-use-cases. Functional decomposition happens in the Use Case
Activities, not in the use case list.

The **Continuous Use Case** is a special kind. It represents
continuous behaviour, its trigger can be an internal event such as
a system state switch rather than an external actor action, and its
result is typically a continuous output such as compliance with a
condition.

## The function bucket

The source's metaphor for the relationship between the two concepts
is a bucket filled with all the functions the system must perform.
The functions are linked where one calls another, the functions are
Use Case Activities, and the System Use Cases are the ones that
swim on the surface, that is, the list of functions the system
offers to its actors.

## System Processes

A System Process specifies a valid logical order of execution of
the System Use Cases, and describes the uses of the system at a
level above them. The source's example runs from installation and
initial setup, through operational functions, to shutdown and
deinstallation.

The dependency it makes explicit is that some use cases can only
run after another has run, or when the system is in a particular
state, which the pre- and postconditions of the use cases already
encode: the postcondition of one use case can satisfy the
precondition of another.

A System Process is typically flow-oriented, describing the logical
order of the use cases. It can alternatively be event-oriented and
described as a state machine.

## Use Case Activities

The Use Case Activity specifies the behaviour of a System Use Case,
where the use case itself is only the abstract and the purpose. It
defines the single functions of the use case, their order of
execution, and the flow of objects between them.

- The activity directly owned by the System Use Case is the
  **primary** Use Case Activity. Functions decomposed below it are
  **secondary** Use Case Activities.
- Each step is itself specified by a Use Case Activity. Steps
  needing no further refinement have no included steps. A use case
  step may also be called a system function.
- The **activity tree** gives the structural view. Its hierarchy is
  a call hierarchy, so a function is a sub-function of another when
  that function calls it. The source is careful that this is
  ownership of executions and not ownership of the specifications
  of the functions.
- The relationship between the output object of one step and the
  input of another is an object flow.
- Pre- and postconditions may be specified: the precondition must
  be true to trigger the use case, and the postcondition is true
  after it has executed.

One piece of good practice is worth carrying across languages.
Separate the steps responsible for input and output of objects to
and from the system actors from all the other steps. The stated
reason is that input and output steps depend on interface
technologies, which are typically less stable than the core steps
and less dependent on the specific domain.

## Domain Knowledge

Domain Knowledge defines the terms of the domain from the
perspective of the system: the semantics and structure of the
domain objects the system uses, together with the related value
types and units.

The source's elicitation device is to imagine the system as a
person and ask it what it knows. Asked whether it knows the concept
of an operator, the system answers that an operator is one of its
users and has an identifier, a name, and a list of active tasks.
Asked about fire, it answers that a fire has a severity value, a
position, and a size.

Domain objects are derived from the object flows of the Use Case
Activities: if an object is the input or output of a system
function, the system must know the concept of that object. The
source warns that modelled activities and their object flows are
typically incomplete, so only part of the Domain Knowledge can be
derived that way.

Separating the input and output steps yields two kinds of object.

- **Context objects** are entities exchanged between the system and
  the system actors.
- **System objects** are domain objects used only inside the
  system.

Domain Knowledge is also known as a concept model or a data model
of the system. Modelling it and modelling the Use Case Activities
cannot be performed in a strict order, because the two are mutually
dependent.

## Where the plugin diverges

- **The canonical artefact is the story.** Use cases in the plugin
  elaborate stories behaviourally and are bound to them through the
  shared objective. They do not carry the requirements structure.
- **The input and output separation survives.** It maps cleanly
  onto SysML v2 action modelling and is worth keeping as a habit,
  independently of the use-case framing it arrives in.
- **Domain Knowledge has a home.** It corresponds to the plugin's
  domain library packages under `core/domain/`, which hold the
  glossary, item definitions, and common value types.
- **The v1 mechanics are omitted.** The activity, stereotype, and
  diagram instructions of the source's modelling guidances are
  SysML v1 and are not translated here.

## See also

- [[user-story-canonical-artefact]] for the plugin's canonical
  artefact.
- [[role-actor-coupling]] for how a use case binds to a story.
- [[ambse-use-case-driven-elicitation]] for the sibling
  use-case-driven source and the same divergence.
- [[sysmod-system-context-source]] for the actors these use cases
  are seen from.
