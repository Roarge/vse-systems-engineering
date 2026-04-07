---
description: Start a new AMBSE nanocycle (commit-scoped work unit). Guides the engineer through anchor thread, planned change, verification hook, and optional implementation handoff, ending with a suggested commit message.
argument-hint: "[optional anchor ID or one-line intent]"
---

Invoke the `vse-systems-engineering:iteration-orchestrator` skill with
intent "start nanocycle" to plan a single commit inside the current
AMBSE iteration.

Pass the user-supplied arguments through as additional context for the skill:

$ARGUMENTS

The skill will:

- Confirm an iteration is open. A nanocycle outside an open iteration is
  orphaned work and will be refused.
- Elicit the anchor thread (requirement ID, design element, verification
  case, or backlog item). Unanchored nanocycles are refused unless the
  engineer explicitly declares scaffolding work.
- Elicit the one-sentence intent (becomes the commit body rationale).
- Ask which verification action (syside check, format check, targeted
  test, trace rebuild) will run before the commit lands.
- Offer optional implementation handoff to the specialist skill that
  owns the artefact type. If the engineer prefers to edit by hand, the
  skill stops after suggesting the commit message.
- Surface a conventional-commit message for the engineer to run manually.
  The skill does not commit on the engineer's behalf.

This command is the normal way to plan a commit on an iteration branch.
Use it before every material change to baselined artefacts.
