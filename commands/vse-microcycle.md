---
description: Open a new AMBSE microcycle (iteration). Guides the engineer through mission, centre of gravity, branch, backlog, and optional first-nanocycle handoff.
argument-hint: "[optional mission string or centre-of-gravity hint]"
---

Invoke the `vse-systems-engineering:iteration-orchestrator` skill with
intent "open microcycle" to walk the engineer through opening a new
AMBSE iteration inside the current VSE project.

Pass the user-supplied arguments through as additional context for the skill:

$ARGUMENTS

The skill will:

- Close the currently open iteration first if one exists, carrying any
  unresolved items into the new iteration as closure debt.
- Elicit the iteration mission (one sentence, action-first).
- Elicit the centre-of-gravity activities as ISO/IEC 29110 task IDs. One
  or more is valid. Structurally contradictory combinations (for example
  PM.4 with SR.2) are refused.
- Propose a branch name in the `vse/iter-NN-<slug>` format and confirm
  with the engineer before creating it.
- Seed the iteration backlog with three to seven items.
- Write `.vse-iteration.yml` and optionally route to the first specialist
  skill for a nanocycle start.

This command is the normal way to advance AMBSE work. Do not edit
`.vse-iteration.yml` by hand.
