---
description: Query the current ISO 29110 phase, check phase gates, or plan a phase transition
argument-hint: "[optional question or transition request]"
---

Invoke the `vse-systems-engineering:lifecycle-orchestrator` skill to navigate
ISO/IEC 29110 lifecycle phases and enforce phase gates.

Pass the user-supplied arguments through as additional context for the skill:

$ARGUMENTS

If the user has not asked a specific question, default to reporting the
current phase recorded in `.vse-phase`, the status of the active phase gate,
and the next recommended activity. If the user has asked about a transition,
check the gate prerequisites for the target phase before recommending the
move.
