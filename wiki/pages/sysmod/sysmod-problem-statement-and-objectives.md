---
title: "Problem Statement, System Idea, and System Objectives"
slug: sysmod-problem-statement-and-objectives
type: process
layer: sysmod
summary: Framing the real problem, the elevator-pitch System Idea, two kinds of System Objectives, and the workshop tools
tags: [sysmod, problem-statement, system-idea, system-objectives, design-thinking, workshop-tools, elicitation]
sources:
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §4.5 and §4.6 (Analyze the Problem, Describe the System Idea and System Objectives)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §5.4 to §5.6 (Problem Statement, System Idea, System Objectives)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §7.2 to §7.4 (How to analyse the problem and model the idea and objectives)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §11.8 to §11.12 (Workshop tools)"
    raw: sysmod.pdf
related:
  - project-bootstrap-prerequisites
  - benefit-as-criterion
  - stakeholder-stories-workflow
  - sysmod-stakeholder-identification
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [project-setup, needs-and-requirements]
---

# Problem Statement, System Idea, and System Objectives

## Contents

- Orientation
- Analyse the problem before the solution
- The Problem Statement
- The System Idea
- The System Objectives
- The workshop toolbox
- Where the plugin diverges
- See also

## Orientation

The plugin has no formal Problem Statement artefact and no System
Idea artefact. What a project must have in place before
stakeholder requirements engineering opens is listed at
[[project-bootstrap-prerequisites]], and the charter or problem
framing sits outside the model, referenced by the Project Plan.
This page therefore supplies elicitation and framing technique that
the plugin's specification deliberately left informal. It does not
describe a missing artefact a project has to add.

## Analyse the problem before the solution

The method's purpose is to find the real problem the system should
resolve, on the ground that the initial problem statement is
sometimes not it, and that the real problem has to be identified by
a profound analysis. The source's illustration is the Henry Ford
line about customers asking for a faster horse, offered with the
caveat that the attribution is doubted and the point stands anyway.

Two approaches are named.

- **Design Thinking**, whose relevant part is the redefinition of
  the initial problem statement in order to find the real challenge
  that satisfies stakeholder needs. The formulation the source
  gives is that Design Thinking does not ask what the users want,
  but what the users need. The problem statement is co-developed
  with a prototype in an iterative loop, a first statement leads to
  first solution attempts which clarify the statement again, and
  the user stays at the centre throughout. Invisible emotional
  needs are addressed alongside the visible problem.
- **The problem-solving process of Haberfellner and colleagues**,
  which traces back to the five steps of problem solving published
  by John Dews in 1910. It starts with analysis of the problem
  before it proceeds to the development of solutions. The source is
  careful to note that the depicted sequence is logical rather than
  temporal, and that execution includes many feedback cycles.

## The Problem Statement

The Problem Statement is defined as a clear and concise statement
of an unwelcome situation that the system of interest should
resolve. Its stated purpose is a corrective one: engineering spends
much of its focus and effort on the solution, so it is essential
not to forget the original problem and to assure that the right
problem is being solved.

Its anatomy is fixed by four questions, who, what, where, and why.

1. It is user-centric and starts with who is having the problem.
2. It then describes the problem itself and the context of the
   problem.
3. It closes with why the problem matters.
4. Across all of that it describes the gap between the current
   state and the desired state.

The order may be changed if it reads better. The source's worked
example is a single sentence: engineers must communicate a lot with
other people in distributed teams, but would like to reduce the
amount of travelling to save time and minimise the impact on the
planet environment.

## The System Idea

The System Idea is the elevator pitch of the system: the core idea
and the leading features, short, precise, concise, and unique
enough to be told during a lift ride. It is the short answer to
"what are you building and why are you doing this?" and to "what is
the value for the customer of the system?".

The reason the source insists on it is that this basic knowledge is
easily lost in the details of a complex development project. It is
not to be taken for granted that every project member knows the
idea and the objectives, so both must be actively communicated.

Sources for the idea vary and are treated as unimportant: a genius
thought, a given contract, an output of product management work, or
anything else. Design Thinking or Value Proposition Design may
precede it. In practice the method often only works up a notion
that already exists somewhere, for communication inside the
development teams, and the outcome is then stored or referenced in
the system model as a proxy for the product-management source.

## The System Objectives

The System Objectives represent the main objectives of the vendor
or the owner of the system. They are used to understand the
rationale of the requirements and to communicate that rationale to
the people building the system model. Like the System Idea they are
typically documented outside the development project in management
documents, and the SYSMOD product is a rework of those objectives
specifically for the system development.

The source distinguishes two kinds.

| Kind | Relates to | Example from the source | Identifier prefix |
|---|---|---|---|
| System-related | The system itself | "Best system on the Market" | `OBJ-S` |
| Organisation-related | The owner, operator, or vendor | "To be the Market Leader (by offering this new system)" | `OBJ-O` |

Two trace directions carry the value.

- Requirements should support the objectives, and the relationship
  recorded in the model is a trace from the requirements to the
  System Objectives. This is how rationale reaches a requirement.
- Each System Objective traces to the stakeholder who is the source
  of it. The source calls this pre-traceability. See
  [[sysmod-stakeholder-identification]].

The modelling guidance also asks for a root objective element that
owns all the others by containment, and for a table carrying
identifier, name, text, and the related stakeholder. The guidance
prefers a table over a diagram for managing objectives.

## The workshop toolbox

Five tools are offered for working the problem and the idea out
with people in a room.

**Product Box.** An unmarked cardboard box is turned into
eye-catching packaging for the system: logo, product name, the
objectives for the customer, and the main features. The mechanism
that makes it work is the constraint: the limited space on the box
forces a focus on the essential aspects. It is customer-facing by
construction, so internal objectives of the "beat all competitors"
kind are typically not written on a product box.

**Product Vision Board.** A canvas proposed by Roman Pichler that
gives an overview of the main pillars of a product vision. Its
sections cover the System Idea and the System Objectives, and also
other aspects such as the stakeholders.

**SAMS method.** Storyboard Activity Modeling for Systems, built on
the storyboards Walt Disney Productions developed in the 1930s to
pre-visualise motion pictures. A storyboard designer with
sufficient drawing talent visualises in real time while the
relevant stakeholders watch, and the visualisation itself
provokes new ideas and refinements. The output is a set of
storyboards of usage scenarios, comparable to a concept of
operations, from which System Use Cases are derived, with
traceability established between storyboard snippets and use cases.
The storyboards can also clarify or derive the System Idea.

**6M method.** A cause and effect analysis used to work out the
Problem Statement, drawn on an Ishikawa or fishbone diagram. The
six categories are manpower (the pains of the people doing their
jobs), machinery (the pains of current products in the scenarios
considered), materials (whether materials are used well and whether
supply and disposal are easy), methods (the pains of workflows),
mother-nature (causes coming from the environment), and measurement
(causes arising from measurement issues such as imprecise data).
The source stresses that the categories are not a form sheet but a
prompt to think broadly about causes across different areas.

**Five Whys.** Taiichi Ohno described asking why five times as the
basis of Toyota's scientific approach, on the grounds that the root
cause of any problem is the key to a lasting solution. The source's
worked chain starts from a fire detected too late: the local sensor
network did not work, an antenna in the forest was broken, the
attachment of the antenna at the pole was broken, the attachment
was too old, and the antenna was not maintained according to the
required service schedule. Branches are allowed, and the source
offers an alternative fourth answer (the service sensor did not
report the defect) leading to a different fifth. A completed chain
can become one entry in the methods category of the 6M diagram.

## Where the plugin diverges

- **No Problem Statement or System Idea artefact.** Neither exists
  in the plugin's model. The project charter or problem statement
  is project-determined, lives outside the model, and is referenced
  from the Project Plan.
- **Objectives-style rationale enters through stories.** What
  SYSMOD carries as a requirement-to-objective trace, the plugin
  carries in the story benefit clause and in concerns (§1 and §4).
  See [[benefit-as-criterion]] and [[stakeholder-stories-workflow]].
- **The storage detail is dropped.** The source stores the Problem
  Statement and the System Idea as stereotype properties on the
  system element. That is a SysML v1 and tool-specific mechanism
  with no plugin counterpart, and it is omitted here rather than
  translated.

The framing technique above is the part worth taking. A very small
entity that never writes a Problem Statement still benefits from
the who, what, where, why discipline, and from Five Whys before the
first story is written.

## See also

- [[project-bootstrap-prerequisites]] for what the plugin actually
  requires before stakeholder requirements engineering opens.
- [[benefit-as-criterion]] for the plugin's rationale carrier.
- [[stakeholder-stories-workflow]] for where elicitation output
  lands in the plugin.
- [[sysmod-stakeholder-identification]] for the stakeholder list
  these objectives trace back to.
