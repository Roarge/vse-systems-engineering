# Wiki Schema (vse-systems-engineering)

This file is the single source of truth for authoring and maintaining the
VSE knowledge wiki. Every skill, subagent, and command that touches `wiki/`
reads this file first. If there is a conflict between this file and any
other document, this file wins.

The wiki implements Andrej Karpathy's LLM Wiki pattern (April 2026) adapted
for a distributed Claude Code plugin. Atomic markdown pages are authored
from raw sources in `sources/` (gitignored), then concatenated into
per-skill bundles under `bundles/` which skills embed at load time. The
authoring surface is atomic and cross-linked. The runtime surface is
deterministic and front-loaded.

## Directory Layout

```text
wiki/
  CLAUDE.md                 This file. Schema and operation contracts.
  INDEX.md                  Auto-maintained page catalogue, grouped by layer.
  LOG.md                    Append-only activity record.
  schema/                   Page-type templates. One file per type.
  pages/                    Atomic concept pages, grouped by VSE source layer.
    iso29110/
    phas-eai/
    incose-vse/
    ambse/
    sysml2/
    syside/
    needs-and-reqs/
    vv/
    hsi/
    project-structure/
  bundles/                  One bundle per consuming skill. Generated files.
```

Never store source files in `wiki/`. Raw PDFs live in the gitignored
`sources/` directory. Scratch markdown produced by `markitdown` during
ingest is temporary and gitignored.

## VSE Source Layers

Pages are grouped by the source-processing order documented in
`CLAUDE.local.md`. This ordering reflects the VSE-first editorial stance:
ISO 29110 is the process backbone, PHAS-EAI supplies design rationale,
INCOSE is scaled for VSE scope, AMBSE governs the agile process, SysML 2.0
is the modelling language, and domain guides cover specific concerns.

| Layer | Directory | Source material |
|---|---|---|
| ISO/IEC 29110 | `pages/iso29110/` | ISO/IEC TR 29110-5-6-2:2014 and successors. |
| PHAS-EAI | `pages/phas-eai/` | kappe.pdf, PHAS-EAI framework papers. |
| INCOSE (VSE-scaled) | `pages/incose-vse/` | INCOSE SE Handbook 4e, filtered for VSE scope. |
| AMBSE | `pages/ambse/` | Douglass 2016 (Agile Systems Engineering), Douglass 2021 (Agile MBSE Cookbook). |
| SysML 2.0 | `pages/sysml2/` | OMG SysML 2.0 specification and derived notes. |
| SySiDE tooling | `pages/syside/` | Sensmetry SySiDE documentation and Python API. |
| Needs and Requirements | `pages/needs-and-reqs/` | INCOSE Guide to Needs and Requirements. |
| Verification and Validation | `pages/vv/` | INCOSE Guide to V&V. |
| Human-Systems Integration | `pages/hsi/` | HSI Primer Vol. 1. |
| Project structure | `pages/project-structure/` | Cross-cutting canonical layout guidance. |

When a new source does not fit an existing layer, do not invent a new layer
without updating this file first. Propose the layer to the contributor and
revise this schema in the same PR that introduces the page.

## Page Frontmatter Contract

Every page under `pages/` carries YAML frontmatter. Missing required fields
cause `/vse-wiki-lint` to fail the page.

```yaml
---
title: "SysML 2.0 Succession Semantics"
slug: sysml2-succession-semantics
type: reference
layer: sysml2
tags: [behaviour, execution-semantics]
sources:
  - citation: "OMG (2025). OMG Systems Modeling Language 2.0, §8.4"
    raw: sysmlv2.pdf
related:
  - sysml2-action-definitions
  - sysml2-state-machines
confidence: high
created: 2026-04-16
updated: 2026-04-16
bundled_by: [sysml2-behaviour]
---
```

### Field definitions

- **title** (string, required). Human-readable page title. Sentence case.
- **slug** (string, required). Lowercase kebab-case. Matches the filename
  without the `.md` extension. Unique across the wiki.
- **type** (enum, required). One of `reference`, `concept`, `process`,
  `pattern`, `glossary`. See `schema/` for templates.
- **layer** (enum, required). Matches the directory name under `pages/`.
- **tags** (list, optional). Short keywords for search. Lowercase, kebab-case.
- **sources** (list, required for non-glossary types). Each entry carries a
  `citation` (bibliographic, readable by end users) and a `raw` (filename
  under `sources/`, contributor-only, not runtime-resolvable). A page may
  cite multiple sources.
- **related** (list, optional). List of slugs. Becomes wikilinks in the
  body. See the wikilink section below.
- **confidence** (enum, required). One of `high`, `medium`, `low`. A page
  lowered to `medium` or `low` must state the reason in the body.
- **created** (ISO date, required). Set once, never changed.
- **updated** (ISO date, required). Bumped on every material edit.
- **bundled_by** (list, required). Names of skills that embed this page via
  a bundle. Empty list means the page is orphaned at the runtime surface
  (authoring reference only).

### Wikilinks in the body

Cross-references inside the body use Obsidian-style wikilinks:
`[[sysml2-action-definitions]]`. The slug between the brackets matches the
target page's `slug`. `/vse-wiki-lint` resolves every wikilink and fails
on unresolved ones. `/vse-wiki-bundle` strips wikilink brackets during
bundle generation so skills see a clean reference without dangling
`[[slug]]` decorations.

### Source citations vs raw paths

End users who install the plugin never have access to `sources/`, because
`sources/` is gitignored. Every `sources[].citation` must stand on its own
as a bibliographic reference. The `raw:` field is contributor metadata that
lets `/vse-wiki-refactor` re-open the PDF for fact-checking. Never
reference a raw path in the body text of a page.

## Operations

Four operations govern the wiki. Each is implemented as a named skill with
a slash-command wrapper.

### ingest

**Skill**: `vse-wiki-ingest`. **Command**: `/vse-wiki-ingest <path>`.

Processes a single new source.

1. Detect the source format. PDF sources are converted to scratch markdown
   via the `markitdown` skill if the `claude-scientific-writer` plugin is
   available. If not, the skill asks the contributor to pre-convert.
2. Propose a layer and a set of atomic pages in dialogue with the
   contributor. Pages should be small (ideally under 200 lines). One page,
   one concept.
3. Dispatch the `vse-wiki-ingestor` subagent to read the scratch markdown
   in isolation and return a suggestion-shaped decomposition proposal.
4. Present the proposal to the contributor for editing.
5. On approval, write pages with full frontmatter, update any related
   pages' `related:` lists, regenerate affected bundles via
   `/vse-wiki-bundle`, update `INDEX.md`, and append to `LOG.md`.
6. Resolve any matching `source-added` stub in `LOG.md` by marking it
   `ingested`.

### lint

**Skill**: `vse-wiki-lint`. **Command**: `/vse-wiki-lint`.

Read-only health check. Writes a report to `wiki/LINT_REPORT.md`
(gitignored scratch) for the contributor to apply by hand.

Checks:

- Every page has all required frontmatter fields.
- Every `[[wikilink]]` resolves to a page in `pages/`.
- Every page listed under a `bundled_by` entry is present in the
  corresponding `bundles/<skill>.md`.
- Every `bundles/<skill>.md` corresponds to a real skill under `skills/`.
- No orphan pages (pages with `bundled_by: []` that also have no backlinks
  from another page's `related:` list).
- Pages whose `updated:` date predates any cited source's raw-file mtime
  are flagged as candidates for re-ingestion.
- Contradiction candidates: pages with `confidence: high` that share tags
  and cite the same source but differ in key claims (detected by simple
  heuristics; contributor decides).
- Schema drift: any page that does not match its `type`'s template shape
  (per `schema/<type>.md`).

The lint skill never writes to `pages/`, `bundles/`, `INDEX.md`, or
`LOG.md`. Only `LINT_REPORT.md`.

### refactor

**Skill**: `vse-wiki-refactor`. **Command**: `/vse-wiki-refactor`.

The "occasionally go over everything" operation. Runs periodically (not on
every ingest). Dispatches the `vse-wiki-curator` subagent to walk the full
wiki, re-read raw sources where available, propose merges, splits, new
cross-links, and confidence revisions. Produces a commit plan. The
contributor reviews and the skill applies approved changes.

Typical refactor triggers:

- Several new sources have been ingested since the last refactor and cross-linking has fallen behind.
- A source has been superseded (for example, a new OMG SysML 2.0 revision).
- Lint repeatedly surfaces the same class of gap.
- Scheduled editorial sweep before a macrocycle release tag on the plugin.

### bundle

**Skill**: `vse-wiki-bundle`. **Command**: `/vse-wiki-bundle [<skill>]`.

Regenerates one or all bundles. Reads every page's `bundled_by`
frontmatter, groups pages per consuming skill, concatenates their bodies
(minus frontmatter, minus wikilink brackets) into
`bundles/<skill>.md`, and prefixes the file with a generated-file header:

```markdown
<!-- Generated by /vse-wiki-bundle on <ISO-8601-timestamp>. Do not hand-edit. -->
<!-- Source pages: <slug-1>, <slug-2>, ... -->
```

Bundles are committed. They ship with the plugin. Skills embed them via
`!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/<skill>.md` at the end of the
skill body.

## LOG.md conventions

`LOG.md` is append-only. Each entry is a level-2 heading with a parseable
prefix:

```markdown
## [2026-04-16] source-added | HSI Primer Vol. 2 v1.pdf
Raw file dropped by the source-added-reminder hook. Awaiting
/vse-wiki-ingest.

## [2026-04-16] ingest | HSI Primer Vol. 2 v1.pdf
Layer: hsi. Pages authored:
- hsi-manning-analysis (new)
- hsi-training-development (new)
- hsi-personnel-capabilities (updated)
Bundles regenerated: hsi-integration.

## [2026-04-16] refactor | editorial sweep
Pages merged: 2. Pages split: 1. New cross-links: 14.
Confidence lowered on: sysml2-quick-ref-connections (medium, reason: OMG
specification §12 clarified connector binding).

## [2026-04-16] lint | post-refactor
Orphans: 0. Broken wikilinks: 0. Stale pages: 2 flagged.
```

The prefix tags are `source-added`, `ingest`, `refactor`, `lint`, and
`bundle`. New tags must be added to this schema file before use.

## Page sizing

Atomic means one concept per file. A page typically runs 50 to 200 lines.
Pages over 300 lines are candidates for splitting. When a page grows past
300 lines during authoring, stop and propose a split before continuing.

The full reference base (120 atomic pages across 11 layers, consumed by
16 skill bundles) has been atomised as of plugin version 1.0.0. New
material lands directly under `pages/<layer>/` via `/vse-wiki-ingest`,
not in any other directory.

## Writing style

UK English throughout. No em-dashes, no semicolons in body text, no
contractions. Plain language first, specialist terms introduced with a
one-line gloss on first use. See `CLAUDE.local.md` for the full style
guide; this file does not duplicate it.
