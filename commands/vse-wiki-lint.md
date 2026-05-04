---
description: Run a read-only health check on the VSE wiki and produce a lint report
argument-hint: "(no arguments)"
---

Invoke the `vse-systems-engineering:vse-wiki-lint` skill to perform a
read-only health check across `wiki/pages/` and `wiki/bundles/`. The
skill writes a report to `wiki/LINT_REPORT.md` (gitignored scratch) for
the contributor to apply by hand. It never writes to pages, bundles,
`INDEX.md`, or `LOG.md`.

Pass any user-supplied arguments through as additional context for the
skill:

$ARGUMENTS

Findings are graded `ERROR`, `WARN`, or `INFO`. The skill checks
frontmatter contracts, wikilink resolution, bundle consistency, orphan
pages, source freshness, contradiction candidates between high-confidence
pages, and schema drift against the templates under `wiki/schema/`. The
skill runs only inside the `vse-systems-engineering` plugin repo with
an initialised wiki.
