# Knowledge File Index

Categorised index of the reference files remaining in `knowledge/`.
Each file is embedded into one or more skills via
`!cat ${CLAUDE_PLUGIN_ROOT}/knowledge/...` at skill load time.

Phases 1, 2, 3, and 4 of the migration are complete. The SysML 2.0
reference set, process backbone (ISO 29110, iteration-centred,
canonical project structure), Phase 3 (PHAS-EAI, HSI, V&V,
needs-and-requirements), and Phase 4 (AMBSE cluster) all live
under `wiki/pages/<layer>/` and are consumed by skills via
`!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/<skill>.md`. See
`wiki/INDEX.md` for the page catalogue. The two remaining
knowledge files (INCOSE VSE practices and SySiDE) await migration
in Phase 5.

## ISO/IEC 29110 (process backbone)

Fully migrated to `wiki/pages/iso29110/` (8 pages).

## PHAS-EAI (design rationale)

Fully migrated to `wiki/pages/phas-eai/` (4 pages).

## INCOSE (best practices, scaled)

| File | Topic | Used by | Status |
|---|---|---|---|
| incose-vse-practices.md | Lifecycle models, stakeholder analysis, V&V | iteration-orchestrator | pending Phase 5 |

`needs-and-reqs-guide.md`, `vv-guide.md`, and `hsi-primer.md`
have been migrated to `wiki/pages/needs-and-reqs/`,
`wiki/pages/vv/`, and `wiki/pages/hsi/` respectively.

## AMBSE (agile model-based process)

Fully migrated to `wiki/pages/ambse/` (20 pages organised in four
clusters: agile-process (5), requirements (5), architecture (5),
git-workflow (5)). Consumed via `wiki/bundles/iteration-orchestrator.md`,
`wiki/bundles/needs-and-requirements.md`,
`wiki/bundles/architecture-design.md`, and
`wiki/bundles/verification-validation.md`.

## SysML 2.0 (modelling language)

Fully migrated to `wiki/pages/sysml2/` and consumed via
`wiki/bundles/`:

| Bundle | Source pages | Consuming skill |
|---|---|---|
| `wiki/bundles/sysml2-allocations.md` | 4 atomic pages | sysml2-allocations |
| `wiki/bundles/sysml2-behaviour.md` | 12 atomic pages | sysml2-behaviour |
| `wiki/bundles/sysml2-cases.md` | 3 atomic pages | sysml2-cases |
| `wiki/bundles/sysml2-expressions.md` | 6 atomic pages | sysml2-expressions |
| `wiki/bundles/sysml2-metadata.md` | 6 atomic pages | sysml2-metadata |
| `wiki/bundles/sysml2-model-structure.md` | 5 atomic pages | sysml2-model-structure |
| `wiki/bundles/sysml2-modelling.md` | 17 atomic pages | sysml2-modelling |
| `wiki/bundles/sysml2-variants.md` | 4 atomic pages | sysml2-variants |
| `wiki/bundles/sysml2-views.md` | 4 atomic pages | sysml2-views |

## SySiDE Automator (tooling)

| File | Topic | Used by |
|------|-------|---------|
| syside-automator-ref.md | Python API reference, tool selection guide, workflow patterns | sysml2-modelling, document-export |

## Project structure

Fully migrated to `wiki/pages/project-structure/` (4 pages:
iteration-centred-operation, iteration-boundary-and-macrocycle-closure,
vse-canonical-project-layout, vse-model-tiers-and-templates).

## Bundles consuming Phase 2, Phase 3, and Phase 4 pages

| Bundle | Source pages | Consuming skill |
|---|---|---|
| `wiki/bundles/project-setup.md` | 12 (Phase 2) | project-setup |
| `wiki/bundles/iteration-orchestrator.md` | 20 (Phase 2 + Phase 4 agile-process + git-workflow) | iteration-orchestrator |
| `wiki/bundles/project-audit.md` | 2 (Phase 2) | project-audit |
| `wiki/bundles/attention-regime.md` | 4 (Phase 3, PHAS-EAI) | attention-regime |
| `wiki/bundles/needs-and-requirements.md` | 13 (Phase 3 HSI + needs-and-reqs + Phase 4 requirements) | needs-and-requirements |
| `wiki/bundles/verification-validation.md` | 6 (Phase 3 V&V + Phase 4 cross-cluster) | verification-validation |
| `wiki/bundles/architecture-design.md` | 5 (Phase 4 architecture cluster) | architecture-design |
