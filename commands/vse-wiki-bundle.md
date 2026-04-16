---
description: Regenerate one or all VSE wiki bundles and rebuild the wiki INDEX
argument-hint: "[optional: skill name to rebuild a single bundle]"
---

Invoke the `vse-systems-engineering:vse-wiki-bundle` skill to
regenerate `wiki/bundles/<skill>.md` files and the `wiki/INDEX.md`
catalogue. Bundles are deterministic concatenations of the pages whose
`bundled_by:` frontmatter lists the target skill, with `[[wikilink]]`
brackets stripped so consuming skills read clean reference prose.

Pass the user-supplied arguments through as additional context for the
skill:

$ARGUMENTS

With no argument, the skill regenerates every bundle and rebuilds
`INDEX.md`. With a skill name, it regenerates only that bundle plus
the index. The skill writes `wiki/bundles/` and `wiki/INDEX.md` and
never touches `wiki/pages/` or `wiki/LOG.md` (the log is owned by the
invoking skill, typically `vse-wiki-ingest` or `vse-wiki-refactor`).
Mechanical operation; no dialogue needed when arguments are explicit.
