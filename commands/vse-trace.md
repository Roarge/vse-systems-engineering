---
description: Run a traceability check against the current SysML models and report gaps
argument-hint: "[optional scope, for example a model file or requirement id]"
---

Invoke the `vse-systems-engineering:traceability-guard` skill to check SysML
requirement traceability (satisfy and verify links) against the current
project models.

Pass the user-supplied arguments through as additional scoping context for
the skill:

$ARGUMENTS

If no scope is provided, run the check across the full SysML model directory
declared in `syside.toml` (or the brownfield equivalent under
`engineering/`). Report each requirement that lacks a satisfy link, each
requirement that lacks a verify link, and any broken or dangling trace
references. Surface the gaps as an actionable list, not as a free-form
narrative.
