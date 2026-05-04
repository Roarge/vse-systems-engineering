# Knowledge File Index

The `knowledge/` directory is empty as of plugin version 0.21.0.
All reference content has migrated to `wiki/pages/<layer>/` and is
embedded into skills via
`!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/<skill>.md` at skill load
time. See `wiki/INDEX.md` for the page catalogue.

Phases 1 to 5 of the migration are complete:

- **Phase 1**: SysML 2.0 reference set (61 pages across the
  `wiki/pages/sysml2/` layer, consumed by 9 SysML 2.0 skills).
- **Phase 2**: ISO/IEC 29110 process backbone (8 pages in
  `wiki/pages/iso29110/`) and project structure (4 pages in
  `wiki/pages/project-structure/`).
- **Phase 3**: PHAS-EAI (4 pages), HSI (5 pages), V&V (4 pages),
  and INCOSE Needs and Requirements (3 pages).
- **Phase 4**: AMBSE cluster (20 pages organised in four
  sub-clusters: agile-process, requirements, architecture,
  git-workflow).
- **Phase 5**: SySiDE Automator reference (6 pages in
  `wiki/pages/syside/`) and INCOSE VSE practices (5 pages in
  `wiki/pages/incose-vse/`).

Phase 6 (final cleanup, scheduled for the 1.0.0 release) will
delete this directory entirely.

## Bundle catalogue

| Bundle | Source pages | Consuming skill |
|---|---|---|
| `wiki/bundles/architecture-design.md` | 5 | architecture-design |
| `wiki/bundles/attention-regime.md` | 4 | attention-regime |
| `wiki/bundles/iteration-orchestrator.md` | 25 | iteration-orchestrator |
| `wiki/bundles/needs-and-requirements.md` | 13 | needs-and-requirements |
| `wiki/bundles/project-audit.md` | 2 | project-audit |
| `wiki/bundles/project-setup.md` | 15 | project-setup |
| `wiki/bundles/sysml2-allocations.md` | 4 | sysml2-allocations |
| `wiki/bundles/sysml2-behaviour.md` | 12 | sysml2-behaviour |
| `wiki/bundles/sysml2-cases.md` | 3 | sysml2-cases |
| `wiki/bundles/sysml2-expressions.md` | 6 | sysml2-expressions |
| `wiki/bundles/sysml2-metadata.md` | 11 | sysml2-metadata |
| `wiki/bundles/sysml2-model-structure.md` | 5 | sysml2-model-structure |
| `wiki/bundles/sysml2-modelling.md` | 23 | sysml2-modelling |
| `wiki/bundles/sysml2-variants.md` | 4 | sysml2-variants |
| `wiki/bundles/sysml2-views.md` | 4 | sysml2-views |
| `wiki/bundles/verification-validation.md` | 6 | verification-validation |
