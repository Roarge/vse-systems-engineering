---
paths:
  - "wiki/**"
  - "sources/**"
---

# Wiki Rules

Before touching anything under `wiki/`, read `wiki/CLAUDE.md`. It is
the binding schema for pages, frontmatter, routing tables, INDEX, and
LOG, and it wins over any conflict with other documents, including this
one.

**The runtime model.** Atomic pages under `wiki/pages/<layer>/` are the
only content artefact. Skills carry generated routing marker blocks
(between `<!-- wiki-routing:begin -->` and `<!-- wiki-routing:end -->`)
and read pages on demand. `INDEX.md` is the generated catalogue and the
authority for page, layer, and routing totals. Nothing concatenates
pages and nothing front-loads them. Bundles were retired at 3.0.0 and
the `bundle` LOG tag is historical.

**Operations.** `/vse-wiki-ingest <path>` processes one source through
a suggestion-shaped proposal and interactive approval before anything is
written. `/vse-wiki-lint` is a read-only health check writing to the
gitignored `wiki/LINT_REPORT.md`. `/vse-wiki-refactor` is the periodic
editorial sweep. `/vse-wiki-index` regenerates `INDEX.md` and every
routing marker block from page frontmatter. Never hand-edit inside the
markers or in `INDEX.md`.

**LOG.md** is append-only. Headings use the parseable prefixes
`source-added`, `ingest`, `refactor`, `lint`, `index`, and
`restructure`. New tags are added to `wiki/CLAUDE.md` before use.

**Source-processing order.** When sources disagree while authoring
wiki or skill content, resolve in this order, highest authority first:
the plugin's `methodology/` (project-local copy first), ISO/IEC 29110,
PHAS-EAI (kappe and Papers IV and V), Galinier et al., the INCOSE SE
Handbook scaled for VSEs, Douglass 2016 and 2021, SYSMOD (Weilkiens),
the OMG SysML 2.0 specification with Syside notes, then the domain
guides (Needs and Requirements, V&V, HSI).

**Sources and citations.** `sources/` stays gitignored, so every
`sources[].citation` must stand alone as a bibliographic reference. The
`raw:` field is contributor metadata, optional per source entry, and
when present takes exactly one of three forms: an exact filename under
`sources/` (quoted when it contains spaces), a repo-relative path
inside the plugin tree, or `null` for web-only sources. The
`source-added-reminder` hook appends an unresolved stub to `LOG.md`
whenever a file under `sources/` is written or edited through the
harness. Resolve stubs by running `/vse-wiki-ingest` on the referenced
file.
Session start emits wiki-freshness lines (days since the last LOG
entry, unresolved stubs, lint findings) inside this repo. Read them as
a nudge towards ingest, lint, or refactor.
