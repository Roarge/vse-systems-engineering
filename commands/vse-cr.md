---
description: Open a Change Request issue with the §10.4.2 impact analysis template. Required before editing baselined artefacts (Plan, baselined stories, baselined architecture).
argument-hint: "[optional CR title or one-line intent]"
---

Invoke the `vse-systems-engineering:change-request` skill to open or
process a Change Request per §10.4.2 of the methodology
specification at `<project>/methodology/10-project-management.md`.

Pass the user-supplied arguments through as additional context for the skill:

$ARGUMENTS

The skill will:

- Confirm the artefact under change is on the baselined-paths list
  in `.iso-config.yaml` (or warn that a CR is unnecessary for
  unbaselined work).
- Elicit the proposed change in the §10.4.2 lifecycle vocabulary:
  what is being changed, who proposed it, the rationale.
- Draft an impact analysis covering cost, schedule, technical, and
  risk impact. Each section may be flagged as "negligible" with
  justification rather than left blank.
- Open a GitHub Issue with the `change-request` label, the
  rendered impact analysis as the issue body, and the lifecycle
  state set to `submitted`.
- Optionally route to `/vse-story` to open the story branch that
  implements the agreed change once the Issue lifecycle reaches
  `agreed`.
- Track the Issue → PR linkage so the audit trail (§10.4.2: "the
  Issue thread *is* the Change Request artefact; the PR thread is
  the implementation record") stays intact.

The skill refuses to bypass the CR workflow with `--no-verify` or
similar shortcuts. CR-required edits to baselined artefacts must
reference an open CR Issue in the commit message
(`feat: ... (CR #<n>)` per §4.2 of the hooks guide).
