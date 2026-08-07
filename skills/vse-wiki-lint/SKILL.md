---
name: vse-wiki-lint
description: Health-check the VSE wiki. Reports frontmatter violations, routing table drift, broken wikilinks, missing contents blocks, unresolvable raw source paths, stale pages, contradiction candidates, and schema drift. Read-only. Use when the contributor asks to lint, audit, or validate the wiki, or after an ingest or refactor as a sanity check.
user-invocable: true
disable-model-invocation: true
context: fork
agent: general-purpose
---

# VSE Wiki Lint

This skill performs a read-only health check across `wiki/pages/`, the
derived surfaces (`wiki/INDEX.md` and the `wiki-routing` marker blocks
inside consuming skills), and the page-to-source links. It produces a
report at `wiki/LINT_REPORT.md` (gitignored scratch, never committed)
for the contributor to apply by hand.

**This skill never writes to `pages/`, `INDEX.md`, `LOG.md`, or any
skill body.** The only file it writes is `LINT_REPORT.md`.

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
title, type, layer, summary, sources, related, confidence, created,
updated, and referenced_by. Record the page's line count and its H2
headings in document order, both of which the contents-block rule needs.

## Step 2: Frontmatter Checks

For each page, record a finding with severity `ERROR`, `WARN`, or `INFO`:

- **ERROR**: Missing required field (`title`, `slug`, `type`, `layer`,
  `summary`, `confidence`, `created`, `updated`, `referenced_by`).
  Missing `sources` on non-glossary pages. Malformed YAML.
- **ERROR**: `slug` does not match the filename (without extension).
- **ERROR**: `layer` does not match the page's parent directory.
- **ERROR**: `summary` is longer than 120 characters or spans more than
  one line. It is rendered into two generated tables and a multi-line
  value breaks both.
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

## Step 4: Routing Table Consistency

Parse every `wiki-routing` marker block under `skills/*/SKILL.md`. A
block is the text between `<!-- wiki-routing:begin -->` and
`<!-- wiki-routing:end -->`, and its rows carry a page title, a path
relative to the wiki root, and a "Read when" cell.

Ignore any marker that sits inside a fenced code block or an inline code
span. The wiki skills document the marker format, so those occurrences
are examples, not blocks. Treating them as blocks produces phantom
findings against skills that carry no routing at all.

The block is generated from page frontmatter by `/vse-wiki-index`, so
every check below asks the same question: does the generated surface
still agree with the pages it was generated from?

- **ERROR** (page to skill): a row names a page whose `referenced_by:`
  does not list the skill carrying the block.
- **ERROR** (skill to page): a page's `referenced_by:` names a skill
  whose block carries no row for that page.
- **ERROR**: a row's `pages/...` path does not resolve to a file on
  disk.
- **ERROR**: a row's "Read when" cell is not the page's `summary:`
  verbatim. A divergence means the block was hand-edited, which the
  schema forbids, because the page is the source of truth.
- **WARN**: rows inside a block are not sorted by layer, then by slug.
  The block needs regenerating.
- **INFO**: a skill is named in some page's `referenced_by:` but carries
  no marker block at all. During the 3.0.0 transition this is the
  expected state for every consumer skill until the runtime flip lands,
  so it is an observation and not a defect.

For each skill under `skills/`:

- **WARN** if the skill's `SKILL.md` references a retired reference
  surface, that is a path under `wiki/bundles/` or a path beginning with
  the legacy `knowledge/` directory name, in either a `!cat` block or a
  prose pointer. The `knowledge/` directory was deleted and
  `wiki/bundles/` is retired at the runtime flip, so any remaining
  reference is stale. Exempt only this skill (`vse-wiki-lint`) from the
  check. It names the retired surfaces in order to detect them, so
  matching on its own text produces a finding against the detector
  rather than against a consumer.

## Step 5: Orphan Detection

An orphan page satisfies both of:

- `referenced_by:` is empty.
- No other page lists it in `related:`.

Report each orphan as **INFO** with the page path. An orphan is no
longer a runtime defect, because every page is reachable through
`INDEX.md` regardless of which skills route to it. It is a curation
observation: nothing points at this page except a full-index scan.

## Step 6: Contents Blocks

For each page, apply the schema rule: a page over 100 lines with three
or more H2 headings carries a `## Contents` bullet list of its H2
headings, immediately after the H1.

- **WARN**: the page qualifies and carries no block.
- **WARN**: the block exists but its bullets do not match the page's H2
  headings, in document order.
- **WARN**: the block exists on a page that does not qualify.

## Step 7: Source Integrity and Freshness

For each page, for each entry in `sources:`:

- `raw:` is optional. When it is absent, check nothing here.
- **ERROR** when a present `raw:` value matches none of the three legal
  forms: an exact filename under `sources/`, a repo-relative path that
  resolves inside the plugin tree, or `null`. A value that merely labels
  the source belongs in `citation:` instead.
- **INFO** when a resolvable `raw:` file is newer than the page's
  `updated:` date by more than 14 days ("source file has been modified
  since the last page update, candidate for re-ingestion").
- **INFO** when `raw:` is `null`. The citation has to carry a URL or
  enough bibliographic detail to re-find the source, because there is no
  local file to re-open.

## Step 8: Contradiction Candidates

For each pair of pages that satisfy all of:

- Both have `confidence: high`.
- They share at least two tags.
- They cite at least one common source (by `citation` string match).

Run a simple heuristic comparison: any paragraph in page A that starts
with a definitional phrase ("is defined as", "refers to", "means")
and any paragraph in page B starting similarly. Report these as **INFO**
contradiction candidates (contributor inspects; the lint skill does not
arbitrate).

## Step 9: Schema Drift

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

## Step 10: Write the Report

Write `wiki/LINT_REPORT.md`:

```markdown
# Wiki Lint Report

Generated: <ISO-8601-timestamp>
Pages scanned: <n>
Routing blocks scanned: <n>

## Summary

- ERROR: <n>
- WARN: <n>
- INFO: <n>

## Findings

### ERROR

<bulleted list, each item: page or skill path, field, description>

### WARN

<bulleted list>

### INFO

<bulleted list>
```

If there are no findings at any severity, write a short "all clear" note
rather than deleting the file.

## Step 11: Summarise to the Contributor

Report a one-paragraph summary of totals and point the contributor at
`wiki/LINT_REPORT.md` for details. Do not paste the full report into the
conversation unless the contributor asks for it.

## Cross-References

- `vse-wiki-ingest`: triggers this skill as a post-ingest sanity check.
- `vse-wiki-refactor`: runs this skill first to seed the refactor
  priorities.
- `vse-wiki-index`: regenerates the surfaces this skill validates. Most
  routing findings are cleared by running it rather than by editing a
  table.
- `wiki/CLAUDE.md`: the schema this skill validates against.
