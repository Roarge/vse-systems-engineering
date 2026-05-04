---
name: vse-wiki-lint
description: >-
  Health-check the VSE wiki. Reports orphan pages, broken wikilinks,
  frontmatter violations, stale pages, contradiction candidates, and
  schema drift. Read-only. Use when the contributor asks to lint, audit,
  or validate the wiki, or after an ingest or refactor as a sanity check.
user-invocable: true
---

# VSE Wiki Lint

This skill performs a read-only health check across `wiki/pages/` and
`wiki/bundles/`. It produces a report at `wiki/LINT_REPORT.md` (gitignored
scratch, never committed) for the contributor to apply by hand.

**This skill never writes to `pages/`, `bundles/`, `INDEX.md`, or
`LOG.md`.** The only file it writes is `LINT_REPORT.md`.

Before any action on `wiki/`, read `wiki/CLAUDE.md`. The schema document
is the contract this skill validates against.

## When This Skill Triggers

- The contributor invokes `/vse-wiki-lint`.
- After an `ingest` operation completes, as a final sanity check.
- After a `refactor` sweep, to confirm no new issues were introduced.
- The contributor asks to audit, check, verify, or lint the wiki.

## Step 0: Confirm Contributor Context

Check that the current working directory is the plugin repo root and the
wiki exists:

```bash
test -f .claude-plugin/plugin.json && test -f wiki/CLAUDE.md
```

If either check fails, report that this skill only runs inside the
`vse-systems-engineering` plugin repo with an initialised wiki.

## Step 1: Enumerate Pages

```bash
find wiki/pages -type f -name '*.md' | sort
```

For each page, parse the YAML frontmatter into fields. Record the slug,
type, layer, sources, related, confidence, created, updated, bundled_by.

## Step 2: Frontmatter Checks

For each page, record a finding with severity `ERROR`, `WARN`, or `INFO`:

- **ERROR**: Missing required field (`title`, `slug`, `type`, `layer`,
  `confidence`, `created`, `updated`). Missing `sources` on non-glossary
  pages. Malformed YAML.
- **ERROR**: `slug` does not match the filename (without extension).
- **ERROR**: `layer` does not match the page's parent directory.
- **WARN**: `confidence: medium` or `low` without a body paragraph
  starting "Confidence note:" or equivalent explanation.
- **WARN**: `updated` is earlier than `created`.
- **INFO**: `tags` is empty (suggests a page a reader will struggle to
  find by keyword).

## Step 3: Wikilink Resolution

For each page, extract all `[[slug]]` occurrences in the body. For each:

- **ERROR** if the slug does not correspond to a page under
  `wiki/pages/**`.
- **WARN** if the wikilink's slug is not also listed in the page's
  `related:` frontmatter array (suggests stale metadata).

## Step 4: Bundle Consistency

For each `wiki/bundles/<skill>.md` that exists:

- Confirm a skill directory `skills/<skill>/` exists. **ERROR** otherwise
  (bundle without consumer).
- Parse the bundle's source-pages comment (`<!-- Source pages: ... -->`).
  For each listed page slug:
  - Confirm the page exists. **ERROR** if missing.
  - Confirm the page's `bundled_by:` list includes this skill name.
    **ERROR** if missing.
- Confirm that every page whose `bundled_by:` includes this skill is
  present in the bundle's source-pages comment. **WARN** on mismatch
  (bundle needs regeneration).

For each skill under `skills/`:

- **WARN** if the skill's `SKILL.md` references the legacy reference
  directory (a path beginning with the legacy directory name, in either
  a `!cat` block or a prose pointer). The legacy directory was deleted
  in plugin version 1.0.0 and any remaining reference is stale.

## Step 5: Orphan Detection

An orphan page satisfies all of:

- `bundled_by:` is empty.
- No other page lists it in `related:`.
- No bundle sources it.

Report each orphan as **WARN** with the page path.

## Step 6: Source Freshness

For each page, for each entry in `sources:`:

- If the `raw:` file exists under `sources/`, compare its mtime to the
  page's `updated:` date. If the raw file is newer by more than 14 days,
  report **INFO** ("source file has been modified since last page
  update, candidate for re-ingestion").
- If the `raw:` file does not exist, report **INFO** ("raw source not
  present locally; re-ingestion would require fetching the original"). 

## Step 7: Contradiction Candidates

For each pair of pages that satisfy all of:

- Both have `confidence: high`.
- They share at least two tags.
- They cite at least one common source (by `citation` string match).

Run a simple heuristic comparison: any paragraph in page A that starts
with a definitional phrase ("is defined as", "refers to", "means")
and any paragraph in page B starting similarly. Report these as **INFO**
contradiction candidates (contributor inspects; the lint skill does not
arbitrate).

## Step 8: Schema Drift

For each page, confirm the body contains the section headings implied by
its `type` per the corresponding `wiki/schema/<type>.md` template.

- `reference`: expect at least one H2 heading after the orientation
  paragraph.
- `concept`: expect H2 headings covering definition, components, and
  boundary.
- `process`: expect H2 headings for preconditions, steps, postconditions,
  failure modes.
- `pattern`: expect H2 headings for problem, context, forces, solution,
  consequences.
- `glossary`: expect a list of term definitions.

Missing expected headings produce **WARN** (pages may evolve away from the
template deliberately; lint flags, does not block).

## Step 9: Write the Report

Write `wiki/LINT_REPORT.md`:

```markdown
# Wiki Lint Report

Generated: <ISO-8601-timestamp>
Pages scanned: <n>
Bundles scanned: <n>

## Summary

- ERROR: <n>
- WARN: <n>
- INFO: <n>

## Findings

### ERROR

<bulleted list, each item: page or bundle path, field, description>

### WARN

<bulleted list>

### INFO

<bulleted list>
```

If there are no findings at any severity, write a short "all clear" note
rather than deleting the file.

## Step 10: Summarise to the Contributor

Report a one-paragraph summary of totals and point the contributor at
`wiki/LINT_REPORT.md` for details. Do not paste the full report into the
conversation unless the contributor asks for it.

## Cross-References

- `vse-wiki-ingest`: triggers this skill as a post-ingest sanity check.
- `vse-wiki-refactor`: runs this skill first to seed the refactor
  priorities.
- `wiki/CLAUDE.md`: the schema this skill validates against.

## Reference: Wiki Schema

!`cat ${CLAUDE_PLUGIN_ROOT}/wiki/CLAUDE.md`
