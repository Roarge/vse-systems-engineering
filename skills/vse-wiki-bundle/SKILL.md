---
name: vse-wiki-bundle
description: >-
  Regenerate per-skill wiki bundles and the wiki INDEX. Use after a page
  is added, updated, or retired, or when a contributor wants to ensure
  bundles are in sync with pages. Mechanical operation; no dialogue
  needed when arguments are explicit.
user-invocable: true
---

# VSE Wiki Bundle

This skill regenerates `wiki/bundles/<skill>.md` files and the
`wiki/INDEX.md` catalogue. Bundles are deterministic concatenations of
the pages whose `bundled_by:` frontmatter lists the target skill.
Skills embed their bundle via `!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/<skill>.md`
at the end of their body.

**This skill writes to `wiki/bundles/` and `wiki/INDEX.md`.** It does
not touch `wiki/pages/` or `wiki/LOG.md` (the log is updated by the
skill that invoked this one, typically `vse-wiki-ingest` or
`vse-wiki-refactor`).

Before any action on `wiki/`, read `wiki/CLAUDE.md`.

## When This Skill Triggers

- The contributor invokes `/vse-wiki-bundle` with no argument (rebuild
  all bundles) or `/vse-wiki-bundle <skill>` (rebuild one).
- Invoked programmatically by `vse-wiki-ingest` after pages are written.
- Invoked programmatically by `vse-wiki-refactor` after refactor
  changes land.

## Step 0: Confirm Contributor Context

Same preconditions as the other wiki skills. Fail fast if not inside the
plugin repo with an initialised wiki.

## Step 1: Enumerate Pages and Their Bundle Assignments

```bash
find wiki/pages -type f -name '*.md' | sort
```

For each page, parse frontmatter. Build a map: skill-name → list of
page paths (in layer order, then slug order within a layer).

```
sysml2-modelling:
  - wiki/pages/sysml2/notation/sysml2-part-notation.md
  - wiki/pages/sysml2/notation/sysml2-attribute-notation.md
  - wiki/pages/sysml2/semantics/sysml2-semantics-layering.md
  ...
```

## Step 2: Determine Target Bundles

If the contributor specified a skill name, regenerate only that one
bundle. Otherwise, regenerate every entry in the map from Step 1.

## Step 3: Regenerate Each Target Bundle

For each target skill:

1. Compute the bundle path: `wiki/bundles/<skill>.md`.
2. Compose the file contents:
   - Generated-file header comment (see `wiki/CLAUDE.md` for the exact
     format).
   - Source-pages comment listing every slug concatenated, in order.
   - For each page in order:
     - An H2 heading with the page's `title:`.
     - The page's body (everything after the closing `---` of the
       frontmatter), with `[[wikilink]]` brackets stripped to leave
       just the slug as a plain term (so the bundle reads as continuous
       reference prose rather than a wiki document).
     - A blank line separator.
3. Write the bundle file atomically (temp file, rename).

The stripping rule for wikilinks in bundles: `[[sysml2-action-definitions]]`
becomes `sysml2-action-definitions`. The wikilink is a navigation aid at
the authoring surface only; the runtime surface gets plain slug text that
a skill can reference in plain prose.

Alternative stripping, if a wikilink appears with an explicit display
text (`[[slug|display]]`), use the display text and drop the slug. This
form is reserved for cases where the slug is not grammatical in context.

## Step 4: Regenerate INDEX.md

Walk `wiki/pages/**` again and rewrite `wiki/INDEX.md`:

1. Group pages by layer.
2. Within each layer, list pages alphabetically by slug with a table
   row per page: slug, title, type, confidence, bundled_by.
3. Regenerate the totals block at the top.
4. Rebuild the "Bundles" section listing every bundle under
   `wiki/bundles/` with its source-page count.

The INDEX is a generated file. Include a header comment naming this
skill and the timestamp.

## Step 5: Report

Report to the caller (another skill or the contributor):

- Number of bundles regenerated.
- Number of pages indexed.
- For each regenerated bundle, the source-page count and the total line
  count.
- Any pages that have `bundled_by: []` (orphans; these never reach a
  bundle).

Do not commit. The caller (or the contributor, if invoked directly)
decides when to stage and commit.

## Determinism

This skill is deterministic: the same input (set of pages and their
frontmatter) always produces the same bundle and index content modulo
the generated-file timestamp. The timestamp is the only non-deterministic
element and is confined to the header comment, not the bundle body.

## Cross-References

- `vse-wiki-ingest`: invokes this skill after writing new pages.
- `vse-wiki-refactor`: invokes this skill after applying refactor
  changes.
- `vse-wiki-lint`: validates that the bundle content matches the
  pages' `bundled_by:` claims.

## Reference: Wiki Schema

!`cat ${CLAUDE_PLUGIN_ROOT}/wiki/CLAUDE.md`
