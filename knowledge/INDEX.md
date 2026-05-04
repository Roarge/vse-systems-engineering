# Knowledge File Index

Categorised index of the reference files remaining in `knowledge/`.
Each file is embedded into one or more skills via
`!cat ${CLAUDE_PLUGIN_ROOT}/knowledge/...` at skill load time.

Several SysML 2.0 knowledge files have been migrated to atomic
pages under `wiki/pages/sysml2/`. The migrated content is consumed
by skills via `!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/<skill>.md`.
See `wiki/INDEX.md` for the catalogue of atomic pages. Migration of
the remaining SysML 2.0 knowledge files (libraries, metadata,
quick-ref, semantics, model-structure) is planned for follow-on PRs.

## ISO/IEC 29110 (process backbone)

| File | Topic | Used by |
|------|-------|---------|
| iso29110-profile.md | Process structure, roles, work products, lifecycle-neutral entry | vse-companion-overview, project-setup |
| iso29110-task-lists.md | Actionable checklists by activity, centre-of-gravity selectors | iteration-orchestrator, attention-regime |
| iteration-centred-operation.md | ISO 29110 tasks mapped onto AMBSE iterations, centre of gravity, brownfield entry, closure checks | iteration-orchestrator |

## PHAS-EAI (design rationale)

| File | Topic | Used by |
|------|-------|---------|
| phas-eai-framework.md | Attention constructs, lever tables, DE requirements | vse-companion-overview, attention-regime |

## INCOSE (best practices, scaled)

| File | Topic | Used by |
|------|-------|---------|
| incose-vse-practices.md | Lifecycle models, stakeholder analysis, V&V | vse-companion-overview |
| needs-and-reqs-guide.md | Needs elicitation, SMART criteria, writing rules | needs-and-requirements |
| vv-guide.md | Verification and validation methods, VCRM | verification-validation |
| hsi-primer.md | Human-systems integration | vse-companion-overview |

## AMBSE (agile model-based process)

| File | Topic | Used by |
|------|-------|---------|
| ambse-agile-process.md | Hybrid lifecycle, iteration planning, verification timeframes, metrics | iteration-orchestrator |
| ambse-requirements.md | Use case driven elicitation, model-based requirements, nanocycle workflow | needs-and-requirements |
| ambse-architecture.md | Five architecture views, trade studies, handoff, model-based V&V | architecture-design |
| ambse-git-workflow.md | Branch-per-microcycle git mapping, PR template, anti-patterns | iteration-orchestrator |

## SysML 2.0 (modelling language)

Files remaining in `knowledge/`. Migrated material lives under
`wiki/pages/sysml2/`.

| File | Topic | Used by | Status |
|------|-------|---------|--------|
| sysml2-quick-ref.md | Textual notation cheat sheet for daily-use constructs | sysml2-modelling | pending migration |
| sysml2-semantics-ref.md | Language architecture, KerML/SysML two-layer model, definition/usage pattern | sysml2-modelling | pending migration |
| sysml2-libraries-ref.md | Systems Model Library, Domain Libraries, VSE import guidance | sysml2-modelling | pending migration |
| sysml2-model-structure-ref.md | Canonical AMBSE package layout, naming, import patterns | sysml2-model-structure | pending migration |
| sysml2-metadata-ref.md | RiskInfo, ConfigItem, Baseline metadata and user keywords | sysml2-metadata | pending migration |

Migrated to `wiki/pages/sysml2/` and consumed via `wiki/bundles/`:

| Bundle | Source pages | Consuming skill |
|------|-------|---------|
| `wiki/bundles/sysml2-behaviour.md` | 12 atomic pages | sysml2-behaviour |
| `wiki/bundles/sysml2-allocations.md` | 4 atomic pages | sysml2-allocations |
| `wiki/bundles/sysml2-cases.md` | 3 atomic pages | sysml2-cases |
| `wiki/bundles/sysml2-expressions.md` | 6 atomic pages | sysml2-expressions |
| `wiki/bundles/sysml2-variants.md` | 4 atomic pages | sysml2-variants |
| `wiki/bundles/sysml2-views.md` | 4 atomic pages | sysml2-views |

## SySiDE Automator (tooling)

| File | Topic | Used by |
|------|-------|---------|
| syside-automator-ref.md | Python API reference, tool selection guide, workflow patterns | sysml2-modelling, document-export |

## Project structure

| File | Topic | Used by |
|------|-------|---------|
| canonical-project-structure.md | Authoritative VSE project directory layout | project-setup, project-audit |
