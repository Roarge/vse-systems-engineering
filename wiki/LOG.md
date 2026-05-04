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
modelling), and Chapter 39 (model execution). Awaiting /vse-wiki-ingest.
