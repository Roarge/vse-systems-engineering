---
name: vse-wiki-refactor
description: >-
  Run a full-wiki editorial sweep: re-read sources, propose merges and
  splits, repair cross-links, revise confidence, regenerate all bundles.
  Use when the contributor asks to go over everything, fact-check the
  wiki, or perform a periodic audit. Heavy operation, not routine.
user-invocable: true
---

# VSE Wiki Refactor

This skill runs the "occasionally go over everything" operation. It
re-reads raw sources where available, proposes structural changes, and
produces a commit plan the contributor reviews before anything lands.

**This skill writes files only after contributor approval.** The heavy
reading and proposal work happens inside the `vse-wiki-curator`
subagent, which runs in an isolated context and returns a suggestion-
shaped report.

Before any action on `wiki/`, read `wiki/CLAUDE.md`.

## When This Skill Triggers

- The contributor invokes `/vse-wiki-refactor`.
- The contributor asks to fact-check, audit deeply, or re-link the
  wiki.
- An editorial sweep is scheduled before a plugin macrocycle release.
- Lint has repeatedly flagged the same class of finding and the
  contributor wants a systemic fix.

This skill should not be triggered reflexively after every ingest; the
`lint` skill handles routine sanity checks. Run `refactor` when the
cumulative cost of stale cross-links, outdated confidence, or
uncaptured source material warrants a focused sweep.

## Step 0: Confirm Contributor Context

Same preconditions as `vse-wiki-ingest` and `vse-wiki-lint`. Fail fast if
not inside the plugin repo with an initialised wiki.

## Step 1: Pre-Refactor Lint

Dispatch the `vse-wiki-lint` skill. Read the resulting
`wiki/LINT_REPORT.md` to seed the refactor priorities. Surface the top
findings to the contributor before proceeding to confirm the refactor
scope.

If lint reports zero ERROR and fewer than five WARN findings, ask the
contributor whether the refactor is still warranted. A clean lint often
means a refactor is not yet needed.

## Step 2: Dispatch the Curator Subagent

Dispatch the `vse-wiki-curator` subagent with:

- The full lint report.
- A list of every page path under `wiki/pages/**`.
- The current `INDEX.md`.
- A list of sources currently present under `sources/` with their
  mtimes (so the subagent knows what can be re-read).
- Any contributor-supplied focus (for example, "focus on SysML 2.0
  cross-linking" or "review all pages with confidence: medium").

The subagent walks the wiki, re-reads sources where they can strengthen
confidence or flag drift, and returns a structured proposal covering:

- **Merges**: pairs or triplets of pages that should become one, with
  rationale.
- **Splits**: pages that have grown beyond atomic size, with a proposed
  decomposition.
- **New cross-links**: pairs of pages that should reference each other
  but currently do not.
- **Confidence revisions**: pages whose confidence should move up or
  down, with justification.
- **Stale pages**: pages whose content is superseded by a newer source
  revision.
- **Coverage gaps**: topics where a source's content is under-captured.

## Step 3: Present the Proposal

Present the subagent's report to the contributor, grouped by change
type. For each proposed change, ask explicitly whether to apply, skip,
or modify.

Do not bundle the review into a single yes/no. The contributor must
decide change by change, because a refactor sweeps a lot of ground and
individual decisions matter.

## Step 4: Apply Approved Changes

For each approved change:

1. **Merges**: concatenate the source pages' bodies (resolving any
   frontmatter conflicts with contributor input), write the merged
   page, update `related:` lists across the wiki, and schedule the
   source pages for deletion only after all references are repointed.
2. **Splits**: create the new pages (Step 4 of `vse-wiki-ingest`
   applies), update the old page to point at them (or retire the old
   page if the split was exhaustive), and update every referencing
   `related:` list.
3. **New cross-links**: add the wikilink in the body and the slug in
   `related:` on both sides of the link.
4. **Confidence revisions**: edit the frontmatter. If lowering to
   `medium` or `low`, add a "Confidence note:" paragraph to the body
   stating the reason.
5. **Stale pages**: re-ingest from the current source using the
   `vse-wiki-ingest` skill. The stale page's slug is preserved if the
   new content still fits under it; otherwise the stale slug is
   retired and the new slug inherits the backlink repair work.
6. **Coverage gaps**: ask the contributor whether to author new pages
   now or log the gap for a future ingest.

Every page touched during Step 4 has its `updated:` date bumped.

## Step 5: Regenerate All Bundles

After all page changes have landed, dispatch `vse-wiki-bundle` with no
argument to regenerate every bundle. This also rebuilds `INDEX.md`.

## Step 6: Append to the Log

Append a `LOG.md` entry using the `refactor` prefix:

```markdown
## [YYYY-MM-DD] refactor | <short-focus>
Pages merged: <n>. Pages split: <n>. New cross-links: <n>.
Confidence lowered on: <slug-list>.
Confidence raised on: <slug-list>.
Retired pages: <slug-list>.
Bundles regenerated: all.
```

## Step 7: Post-Refactor Lint

Dispatch `vse-wiki-lint` again. The report should show zero ERROR
findings. Any remaining WARN findings are noted in the refactor log
entry so the contributor can decide whether to address them in this PR
or defer.

## Step 8: Present Commit Plan

Produce a commit plan. Refactor PRs tend to touch many files; group
commits by change type where practical:

1. `refactor(wiki): merge <pages>` for merges.
2. `refactor(wiki): split <page>` for splits.
3. `refactor(wiki): repair cross-links` for the link pass.
4. `refactor(wiki): revise confidence` for the confidence pass.
5. `chore(wiki): regenerate bundles` for the final bundle rebuild.

The contributor reviews and stages manually following the repo's git
workflow.

## Failure Modes

- **Subagent times out or returns empty.** Do not apply anything. Ask
  the contributor to narrow the focus and re-run.
- **A proposed merge conflicts with active consumer skills.** Skip the
  merge and flag it for contributor decision in a follow-up.
- **Lint still reports ERRORs after Step 7.** Do not present the
  commit plan. Return to Step 4 and address the specific findings.

## Cross-References

- `vse-wiki-lint`: runs before and after the refactor.
- `vse-wiki-bundle`: regenerates all bundles in Step 5.
- Subagent: `agents/vse-wiki-curator.md`.

## Reference: Wiki Schema

!`cat ${CLAUDE_PLUGIN_ROOT}/wiki/CLAUDE.md`
