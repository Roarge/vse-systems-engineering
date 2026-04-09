---
description: Audit a VSE project for structural completeness and version drift
argument-hint: "[optional: remediate to include a remediation plan]"
---

Invoke the `vse-systems-engineering:project-audit` skill to audit the
current VSE project against the canonical structure defined by the
current plugin version.

Pass the user-supplied arguments through as additional context for the skill:

$ARGUMENTS

The skill is strictly read-only. It checks root files, model structure and
tier, document templates, hooks, SySiDE configuration, GitHub Actions, and
gitignore entries. It produces a structured report with severity levels
(CRITICAL, OUTDATED, NON-CANONICAL, OPTIONAL).

If `remediate` is passed as an argument, the skill additionally produces
an actionable remediation plan with exact commands for each finding.
