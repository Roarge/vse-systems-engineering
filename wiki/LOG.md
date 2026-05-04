# Wiki Activity Log

Append-only record of wiki operations. Prefix tags are `source-added`,
`ingest`, `refactor`, `lint`, `bundle`. See `CLAUDE.md` for the full
convention.

## [2026-04-16] bundle | scaffolding

Wiki subsystem scaffolded. `CLAUDE.md`, `INDEX.md`, and this log created.
Schema templates installed under `schema/`. Layer directories created
under `pages/` (all empty). `bundles/` directory created (empty). No
content ingested yet. Migration from the legacy `knowledge/` directory
starts in a subsequent PR with the four oversized files as the first
slice.

## [2026-05-04] source-added | sysmlv2.pdf

Raw file replaced with the 2026-04 release of "The SysML v2 Book"
(Weilkiens and Molnár, MBSE4U). Stub appended manually because the
file was modified outside Claude, so the source-added-reminder hook
did not fire. Release notes record new material in Part II Chapter 17
(self and that), Chapter 21 (binding connectors), Section 24.3
(advanced quantities and units), Chapter 25 (occurrences and 4D
modelling), and Chapter 39 (model execution).

## [2026-05-04] ingest | sysmlv2.pdf 2026-04 (new chapters)

Layer: sysml2. Pages authored from the 2026-04 release deltas:

- sysml2-self-and-that (new, Section 17.3)
- sysml2-binding-connectors (new, Chapter 21)
- sysml2-advanced-quantities-units (new, Section 24.3)
- sysml2-occurrences-4d (new, Sections 25.1 to 25.2)
- sysml2-portions-and-individuals (new, Sections 25.3 to 25.4)
- sysml2-temporal-spatial-relations (new, Sections 25.5 to 25.7)
- sysml2-occurrence-context-and-variables (new, Sections 25.8 to 25.10)
- sysml2-model-execution (new, Chapter 39)

Bundles regenerated: sysml2-allocations, sysml2-behaviour,
sysml2-expressions. Stub for sysmlv2.pdf marked ingested by this entry.

## [2026-05-04] ingest | knowledge/sysml2-variants-ref.md

Layer: sysml2. Pages authored from atomisation of legacy reference:

- sysml2-variations-overview (new, concept)
- sysml2-variation-definitions (new, reference)
- sysml2-variant-configuration (new, reference)
- sysml2-variant-patterns (new, pattern)

Bundles regenerated: sysml2-variants. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-views-ref.md

Layer: sysml2. Pages authored:

- sysml2-viewpoints-and-concerns (new, concept)
- sysml2-view-definitions (new, reference)
- sysml2-standard-views (new, reference)
- sysml2-view-patterns (new, pattern)

Bundles regenerated: sysml2-views. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-allocations-ref.md

Layer: sysml2. Pages authored:

- sysml2-allocations-overview (new, concept)
- sysml2-allocation-definitions (new, reference)
- sysml2-allocation-patterns (new, pattern)

Bundles regenerated: sysml2-allocations. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-cases-ref.md

Layer: sysml2. Pages authored:

- sysml2-cases-overview (new, concept)
- sysml2-case-kinds (new, reference)
- sysml2-case-patterns (new, pattern)

Bundles regenerated: sysml2-cases. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-behaviour-ref.md

Layer: sysml2. Pages authored:

- sysml2-actions (new, reference)
- sysml2-successions (new, reference)
- sysml2-special-action-usages (new, reference)
- sysml2-state-machines (new, reference)
- sysml2-flows-and-messages (new, reference)
- sysml2-behaviour-patterns (new, pattern)

Bundles regenerated: sysml2-behaviour. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-expressions-ref.md

Layer: sysml2. Pages authored:

- sysml2-expressions-overview (new, reference)
- sysml2-sequences-and-structures (new, reference)
- sysml2-functions-and-higher-order (new, reference)
- sysml2-expressions-constraints (new, reference)
- sysml2-expression-patterns (new, pattern)

Bundles regenerated: sysml2-expressions. Legacy file removed.

## [2026-05-04] bundle | phase-1a migration

Bundles regenerated: sysml2-allocations (4 pages), sysml2-behaviour
(12 pages), sysml2-cases (3 pages), sysml2-expressions (6 pages),
sysml2-variants (4 pages), sysml2-views (4 pages). INDEX.md rebuilt
with 33 atomic pages across the sysml2 layer.

## [2026-05-04] lint | post-ingest

Pages scanned: 33. Bundles scanned: 6. ERROR: 0. WARN: 0. INFO: 0.
Wiki state clean after Phase 1a migration.
