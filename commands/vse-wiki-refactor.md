---
description: Run a full-wiki editorial sweep with merges, splits, and cross-link repair
argument-hint: "[optional: focus string, for example 'SysML 2.0 cross-linking']"
---

Invoke the `vse-systems-engineering:vse-wiki-refactor` skill to run the
"occasionally go over everything" operation on the VSE wiki. The skill
re-reads raw sources under `sources/` where available, proposes merges,
splits, new cross-links, confidence revisions, stale pages, and
coverage gaps, then applies only the changes the contributor approves.

Pass the user-supplied arguments through as additional context for the
skill (for example, a focus string that narrows the sweep):

$ARGUMENTS

The skill dispatches the `vse-wiki-curator` subagent in an isolated
context for the walk and proposal work, then surfaces each proposed
change to the contributor for approval. After approved changes are
applied, the skill regenerates every bundle via `/vse-wiki-bundle`,
appends a `refactor` entry to `wiki/LOG.md`, and produces a commit
plan. Heavy operation, not routine; use lint for day-to-day health
checks.
