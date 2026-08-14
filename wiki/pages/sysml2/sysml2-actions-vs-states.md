---
title: "Actions or States? Choosing the Behaviour Construct"
slug: sysml2-actions-vs-states
type: pattern
layer: sysml2
summary: Deciding between state machines and action models, with the waiting-versus-working test and misuse symptoms
tags: [behaviour, states, actions, patterns, vse]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-07 release. MBSE4U. Section 28.6, page 219."
    raw: sysmlv2.pdf
related:
  - sysml2-state-machines
  - sysml2-actions
  - sysml2-successions
  - sysml2-special-action-usages
  - sysml2-behaviour-patterns
confidence: high
created: 2026-08-10
updated: 2026-08-14
referenced_by: [sysml2-behaviour]
---

# Actions or States? Choosing the Behaviour Construct

Because states in SysML 2.0 are special kinds of actions, it is not
always obvious which construct to reach for. This page records the
book's test for the choice and the two symptoms that show the wrong
one was taken (Ch 28, p 219).

## Being versus doing

The distinction is about what is being described. A **state** is a
situation the component rests in, that is, a mode or condition it can
remain in indefinitely, waiting for something to happen. An
**action** is something the component does, that is, a step or
process that progresses and completes. State machines are reactive
and about being, and action models are about doing (Ch 28, p 219).

| State (being) | Action (doing) |
|---|---|
| The drone is flying. | The drone performs takeoff. |
| Rests until an event moves it on. | Runs to completion, then proceeds. |

## Doing inside being

Ongoing behaviour that runs while a component is in a state belongs
in that state's `do` action. That is where doing lives inside being
(Ch 28, p 219). See [[sysml2-state-machines]] for the entry, do, and
exit slots.

## Two symptoms of the wrong choice

- A "state machine" whose every transition fires on completion, with
  no triggers and nothing to wait for, is really a sequence of steps.
  Model it as actions with successions instead. See
  [[sysml2-successions]].
- An "action" that stops and waits indefinitely for an external event
  before it can continue is really resting in a state. Model it as a
  state, or, for a single wait, an accept action. See
  [[sysml2-special-action-usages]].

## The heuristic

When in doubt, ask whether the component is **waiting** or
**working**. Waiting is typically a state, working is typically an
action (Ch 28, p 219).

## See also

- [[sysml2-state-machines]] for state definitions, transitions, and
  the communicating-machine arrangement.
- [[sysml2-actions]] for action definitions, usages, and parameters.
- [[sysml2-behaviour-patterns]] for the wider set of VSE-scale
  patterns and gotchas.
