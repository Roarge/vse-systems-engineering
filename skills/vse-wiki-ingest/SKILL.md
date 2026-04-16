---
name: vse-wiki-ingest
description: >-
  Process a new source file into atomic wiki pages. Use when a PDF or
  markdown source has been dropped into the contributor's sources/ folder
  and the wiki needs to absorb it, or when the user asks to ingest,
  process, or distil a source into the wiki. Contributor-facing only;
  end-user projects have no sources/ folder to ingest.
user-invocable: true
---

# VSE Wiki Ingest

This skill processes a single new source into atomic pages under
`wiki/pages/<layer>/`. It is the primary contributor operation for
growing the wiki.

Before any action on `wiki/`, read `wiki/CLAUDE.md`. The schema document
governs frontmatter contracts, directory layout, and operation boundaries.
If there is any conflict between this skill and the schema document, the
schema document wins.

**This skill writes files.** It writes atomic pages, updates cross-links
on related pages, regenerates affected bundles, updates `INDEX.md`, and
appends to `LOG.md`. It never touches anything outside `wiki/` except to
hand the raw source to `markitdown` for conversion.

## When This Skill Triggers

- The contributor invokes `/vse-wiki-ingest <path>` with a path to a
  source file.
- A `source-added` stub appears in `wiki/LOG.md` (left by the
  `source-added-reminder` hook) and the contributor asks to resolve it.
- The contributor asks in plain language to "ingest this paper" or
  "distil this source into the wiki".

If the user is operating inside an end-user VSE project (a project with
`.vse-iteration.yml` but no `sources/` folder containing PDFs), this
skill does not apply. Route to `vse-companion-overview` instead.

## Step 0: Confirm Contributor Context

Check that the current working directory is the plugin repo root:

```bash
git rev-parse --show-toplevel
ls .claude-plugin/plugin.json
ls wiki/CLAUDE.md
```

If either file is missing, stop and report that this skill only runs
inside the `vse-systems-engineering` plugin repo.

Confirm the argument path resolves to a file under `sources/` or a path
the contributor explicitly provides. Do not ingest files from arbitrary
locations without explicit contributor confirmation.

## Step 1: Convert the Source

If the source is a `.pdf`, check whether the `markitdown` skill from the
`claude-scientific-writer` plugin is available. Invoke it with the source
path and a scratch output path under `sources/.scratch/<basename>.md`
(which is gitignored implicitly via the parent `sources/` entry).

If `markitdown` is not available, stop and ask the contributor to
pre-convert the source. Give the contributor a concrete command
suggestion:

> "The markitdown skill is not available in this session. Pre-convert the
> PDF with a tool of your choice and drop the resulting markdown into
> `sources/.scratch/<basename>.md`, then re-run this skill."

If the source is already `.md`, skip conversion and point the ingest at
the source path directly.

## Step 2: Dispatch the Subagent

Dispatch the `vse-wiki-ingestor` subagent with the following input:

- Path to the converted or native markdown source.
- The full content of `wiki/CLAUDE.md` (for schema grounding).
- The full content of `wiki/INDEX.md` (so the subagent knows what
  already exists and avoids duplicating slugs).
- The contributor's intended layer, if supplied. Otherwise leave blank
  and let the subagent propose one.

The subagent returns a suggestion-shaped markdown report with:

- Proposed layer and rationale.
- Proposed atomic page decomposition, one block per page: title, slug,
  type, tags, one-paragraph draft, and a list of related slugs.
- Candidate cross-links into existing pages (wikilinks the new pages
  should emit and backlinks existing pages should add).
- Any contradictions the subagent detected with existing pages.

## Step 3: Present the Proposal for Contributor Review

Present the subagent's report to the contributor verbatim. Ask explicitly:

1. Is the layer assignment correct?
2. Are the proposed page slugs acceptable?
3. Should any proposed page be merged with, or split from, another?
4. Are any cross-links missing or wrong?
5. Is the suggested confidence level (default `high`) appropriate for each
   page?

Do not proceed to writing until the contributor approves or amends the
proposal.

## Step 4: Write the Pages

For each approved page:

1. Create the file at `wiki/pages/<layer>/<slug>.md`. Fail if a file
   with that slug already exists; ask the contributor whether the intent
   is to update that page instead (in which case switch to Step 4b).
2. Populate the full frontmatter per `wiki/CLAUDE.md`. Set `created` and
   `updated` to today's date. Set `bundled_by` based on the contributor's
   decision on which skills should consume this page (often the same
   skill that consumed the predecessor knowledge file).
3. Write the body with all wikilinks in `[[slug]]` form.

### Step 4b: Update Existing Pages

For each existing page that needs a new backlink (per the subagent's
cross-link proposal):

1. Read the page.
2. Add the new slug to the `related:` frontmatter list if not already
   present.
3. Add a prose wikilink to the body where appropriate (contributor
   confirms placement).
4. Bump the `updated:` date.

## Step 5: Regenerate Bundles

For every unique skill named across all affected pages' `bundled_by:`
lists, dispatch the `vse-wiki-bundle` skill to regenerate that skill's
bundle. This writes `wiki/bundles/<skill>.md` with the standard
generated-file header.

## Step 6: Update Index and Log

Invoke `vse-wiki-bundle` with no argument to rebuild `INDEX.md` as a
side effect (the bundle skill regenerates the index whenever it runs).

Append a `LOG.md` entry using the `ingest` prefix:

```markdown
## [YYYY-MM-DD] ingest | <source-filename>
Layer: <layer>. Pages authored:
- <slug> (new)
- <slug> (new)
- <slug> (updated, cross-link added)
Bundles regenerated: <skill-1>, <skill-2>.
```

If the source matched a pre-existing `source-added` stub, update the
stub's heading to `ingested` and link to this new entry.

## Step 7: Present a Commit Plan

This skill does not commit. Summarise the changes for the contributor:

- Files added (paths).
- Files modified (paths and nature of change).
- Files regenerated (bundle paths).
- A suggested conventional-commit message starting with `feat(wiki):` or
  `docs(wiki):`.

The contributor stages, commits, and pushes following the repo's git
workflow in `CLAUDE.local.md`.

## Failure Modes

- **Duplicate slug.** Stop and ask whether to update or rename.
- **Schema violation.** Refuse to write and surface the specific
  frontmatter field that is missing or malformed.
- **Source file unreadable.** Report the path and underlying error.
  Do not silently skip.
- **Subagent returns empty proposal.** Do not write anything. Report to
  the contributor and ask for more context about the source.

## Cross-References

- `vse-wiki-bundle`: regenerates bundles and the wiki index.
- `vse-wiki-lint`: run after ingestion to confirm no new orphans or
  broken wikilinks were introduced.
- `vse-wiki-refactor`: used periodically, not per-source.
- Subagent: `agents/vse-wiki-ingestor.md`.

## Reference: Wiki Schema

!`cat ${CLAUDE_PLUGIN_ROOT}/wiki/CLAUDE.md`
