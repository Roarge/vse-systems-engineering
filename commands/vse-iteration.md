---
description: Report AMBSE iteration position, run the iteration-boundary closure check, close the current iteration, or handle a Change Request
argument-hint: "[optional question or iteration operation]"
---

Invoke the `vse-systems-engineering:iteration-orchestrator` skill to manage
AMBSE iterations inside the current VSE project.

Pass the user-supplied arguments through as additional context for the skill:

$ARGUMENTS

If the user has not asked a specific question, default to reporting the
current iteration recorded in `.vse-iteration.yml` (number, mission, branch,
centre of gravity, backlog, closure debt) and the status of the active
iteration-boundary closure check.

To open a new iteration (microcycle), use `/vse-microcycle`. To plan a
single commit (nanocycle), use `/vse-nanocycle`. This command is for
reporting state, closing the current iteration, or routing a Change Request.
