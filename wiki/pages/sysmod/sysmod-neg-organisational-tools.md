---
title: "Turtles, rabbits, and Cynefin: organisational decision aids"
slug: sysmod-neg-organisational-tools
type: pattern
layer: sysmod
summary: Sizing work styles with Conway's Turtles and Rabbits, the Cynefin domains, and the four collaboration levels
tags: [neg, turtles-and-rabbits, cynefin, conways-law, collaboration-levels, disruption, work-styles]
sources:
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §4.1 (Conway's Turtles and Rabbits)"
    raw: new-engineering-game.pdf
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §4.2 (Cynefin Framework)"
    raw: new-engineering-game.pdf
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §3.5 (Interdisciplinary Engineering)"
    raw: new-engineering-game.pdf
related:
  - sysmod-neg-complexity-and-dynamics
  - sysmod-base-architecture-source
  - methodology-overview
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [project-setup]
---

# Turtles, rabbits, and Cynefin: organisational decision aids

## Contents

- Problem
- Context
- Forces
- Solution
- The five Cynefin domains
- The four collaboration levels
- Consequences
- Where the plugin stands
- See also

## Problem

Conway's Law states that an organisation which designs a system
produces a design whose structure copies the organisation's
communication structure. [[sysmod-neg-complexity-and-dynamics]] carries
the law itself and its three consequences, and this page needs only the
third of them: a disruptive innovation requires organisational change
and must overcome organisational resistance.

The source names the mechanism precisely. A disruptive product idea is
a fundamental change of the base architecture, and parts of the
organisation become superfluous for developing or producing the new
product, so they resist. Overcoming that resistance costs effort and,
in particular, time, with the additional risk that the development of
the new product turns out neither effective nor powerful.

The source's worked case is the BMW i3 and i8. Norbert Reithofer, at
the time chief executive of BMW, said in a 2014 interview that for big
innovation leaps you have to leave the usual paths, that the
development of the i3 would otherwise not have been possible, and that
the development team was therefore allowed to work outside the typical
corporate structures. The source reads this as a strike against a base
architecture, in this case an organisation with a strong focus on
combustion engines, and against the organisation structure that the
base architecture had settled into.

## Context

The pattern separates two work styles, and the source's account of each
is short enough to reproduce whole.

| | Turtle | Rabbit |
|---|---|---|
| Character | Consistent, stable, slow | Fast, able to change direction continuously |
| Work | Well known tasks, describable by processes, daily business | Explorative, new problems, prototypes and experiments |
| Defining property | Predictability | Uncertainty |
| Cynefin domain | Mostly complicated | Mostly complex |

The turtle is useful precisely because the established business has to
continue, and the source is explicit that a turtle organisation is not
therefore uninnovative. What it resists is fundamental change to the
basic architecture.

The separation may be drawn at any scale: different roles, different
teams, different departments, or different legal entities. The source
uses "organisation" to cover all of them.

Two framing notes travel with the pattern.

- **Other names.** The same distinction appears as greenfield versus
  brownfield, legacy versus emergent, or simply old versus new
  engineering.
- **Bimodal IT is not the recommendation.** Gartner's Bimodal IT
  approach is built on the same pattern, and the source records that it
  is controversial. One criticism is that the old organisation should
  be enabled to work more exploratively rather than have a second
  organisation built in parallel, because the old organisation also has
  to adapt and change. The source's own position is narrower than
  Gartner's: the pattern is an observation that the two forms exist and
  a recommendation to address the difference explicitly. Bimodal is one
  possible solution among several.

## Forces

- The two work styles typically suit different kinds of people. Not
  everyone can work with uncertainty, and people who like uncertainty
  and exploration are easily bored by predictable work. Some people
  can work in both styles.
- The disruptive product attracts more attention than the standard
  parts, so the rabbits are easily seen as the stars of the
  organisation, which makes an unfair culture the default outcome
  rather than an accident.
- A disruptive product stops being disruptive. At some point it is
  established in the organisation and in the market and fits the turtle
  better than the rabbit, and the transition has to be handled.
- The resources needed to keep a rabbit group running are not always
  available, and this is where the pattern bites hardest at small
  scale.

## Solution

1. **Check whether both styles are present**, then address the
   difference explicitly rather than leaving it implicit.
2. **Keep the distance between rabbits and turtles as low as
   possible**, whatever organisational separation is chosen.
3. **Decide in advance when the rabbit phase ends.** The trigger can be
   a specific moment such as the start of production, the start of
   sales, or one year on the market. The source's requirement is that
   the moment is planned rather than a reaction to an unpleasant
   surprise.
4. **Choose the exit for the rabbits before the transfer happens.**
   Three options are named.

   1. Close the rabbit organisation and discharge the rabbits.
   2. Close the rabbit organisation and transfer the rabbits into the
      turtle organisation.
   3. Find a new project for the rabbits.

   Option 3 looks best and is frequently unavailable. The source's own
   counter-example is a company of twenty people that has just placed
   its first product on the market and needs all its resources to
   produce, sell, and maintain that product. BMW chose option 2, and
   the source notes that it appears not to have worked well, because
   reports at the time described top experts from the electric-vehicle
   team being recruited by Chinese competitors and leaving the company.
5. **Promote a fair culture.** Rabbits and turtles are worth the same,
   and the source frames the risk as ending up with a welcome and an
   unwelcome work area.

## The five Cynefin domains

Cynefin, by Dave Snowden, is offered as a decision aid for seeing a
situation from different viewpoints. The source presents five domains.

| Domain | What it holds | How to act |
|---|---|---|
| Simple | The known knowns | Sense the facts, categorise them, then act on the rules or best practices of that category |
| Complicated | The known unknowns | Analysis is needed, because a rule cannot be applied directly. There are usually several right answers and an expert decides which is best |
| Complex | Cause and effect are understandable only afterwards, if at all | Probe, then sense, then respond |
| Chaotic | No cause-and-effect relationship at all | Act first to stabilise, then sense and respond, which moves the situation from chaotic to complex |
| Disorder | No clarity about which domain applies | Not the same as chaotic. In the chaotic domain you at least know the situation is chaotic. Being able to categorise the situation proves it is not disorder |

Two of the source's remarks are worth keeping. The complicated domain
is the primary domain of engineers, and most technical systems live
there, an aircraft being sophisticated rather than unpredictable. The
complex domain is where cyber-physical systems can land, because their
openness makes them partly unpredictable.

## The four collaboration levels

The same chapter of the source scores interdisciplinary collaboration
on four levels, which give a second axis for the same decision.

- **Level 0, boxed.** No collaboration between the disciplines. A
  superior organisational unit coordinates their work.
- **Level 1, channelled.** The disciplines collaborate through
  predefined communication channels, for example by exchanging
  requirements and architecture specification documents.
- **Level 2, grouped.** Interdisciplinary temporary working groups work
  on features of the product or service and break up when the task is
  finished.
- **Level 3, organised.** The organisation structure contains permanent
  interdisciplinary units responsible for holistic tasks.

The source is emphatic that these are not a maturity model. They are
neutral, level 0 can be as appropriate as level 3, and their purpose is
orientation. The orientation it offers is a mapping onto Cynefin: level
0 is probably fine for a simple context, level 1 is appropriate for a
complicated context, and levels 2 and 3 are for a complex or chaotic
context.

## Consequences

- The two work styles become discussable, which is the whole of what
  the pattern claims. Naming a piece of work as rabbit work sets
  expectations about uncertainty, prototypes, and the absence of a
  process to follow.
- The handover is planned rather than improvised, which removes one
  predictable crisis from the calendar.
- The organisation has to answer a question it would otherwise avoid,
  namely what happens to the people when the rabbit phase closes.
- Choosing a Cynefin domain for a piece of work commits the team to an
  action sequence, and choosing wrongly is visible. Treating a complex
  situation as complicated produces analysis that cannot converge, and
  treating a complicated situation as complex wastes probes on a
  problem an expert could have decided.

## Where the plugin stands

A very small entity is usually one team, so the organisational reading
of the pattern does not transfer directly. What transfers is the
sizing.

- **Apply the pattern to work packages rather than to departments.**
  The useful question is which stories are rabbit work and which are
  turtle work. A story that explores an unfamiliar technology, needs a
  prototype, and cannot state its acceptance criteria in advance is
  rabbit work. A story that repeats a known shape with new parameters
  is turtle work. The same team does both, on different days.
- **Use Cynefin as vocabulary for how much rigour a piece of work
  needs.** The plugin's methodology sets the process backbone, and
  [[methodology-overview]] is authoritative for it. Cynefin does not
  compete with that backbone. It gives a team a defensible way to say
  why one story warrants a trade study and a second reviewer while
  another does not.
- **Watch the base architecture, because that is where the pattern
  starts.** The source's disruption trigger is a strike against the
  base architecture, and the plugin treats the base architecture as an
  exogenous constraint that only deliberate change events replace. See
  [[sysmod-base-architecture-source]].

## See also

- [[sysmod-neg-complexity-and-dynamics]] for Conway's Law, the
  complexity definitions, and the dynamics argument these aids answer.
- [[sysmod-base-architecture-source]] for the base architecture whose
  disruption triggers the pattern.
- [[methodology-overview]] for the plugin's own process backbone.
