# Knowledge File Index

Categorised index of the 25 reference files in `knowledge/`. Each file
is embedded into one or more skills via
`!cat ${CLAUDE_PLUGIN_ROOT}/knowledge/...` at skill load time.

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

| File | Topic | Used by |
|------|-------|---------|
| sysml2-quick-ref.md | Textual notation cheat sheet for daily-use constructs | sysml2-modelling |
| sysml2-semantics-ref.md | Language architecture, KerML/SysML two-layer model, definition/usage pattern | sysml2-modelling |
| sysml2-libraries-ref.md | Systems Model Library, Domain Libraries, VSE import guidance | sysml2-modelling |
| sysml2-model-structure-ref.md | Canonical AMBSE package layout, naming, import patterns | sysml2-model-structure |
| sysml2-behaviour-ref.md | Actions, successions, state machines, flows, messages | sysml2-behaviour |
| sysml2-allocations-ref.md | Function-to-platform allocation relationships and nesting | sysml2-allocations |
| sysml2-cases-ref.md | Use case, analysis case, verification case authoring | sysml2-cases |
| sysml2-expressions-ref.md | Constraint bodies, calc definitions, parametric bindings | sysml2-expressions |
| sysml2-metadata-ref.md | RiskInfo, ConfigItem, Baseline metadata and user keywords | sysml2-metadata |
| sysml2-variants-ref.md | Variation points, variant usages, configuration selection, VAMOS | sysml2-variants |
| sysml2-views-ref.md | Viewpoints, views, expose statements, rendering | sysml2-views |

## SySiDE Automator (tooling)

| File | Topic | Used by |
|------|-------|---------|
| syside-automator-ref.md | Python API reference, tool selection guide, workflow patterns | sysml2-modelling, document-export |

## Project structure

| File | Topic | Used by |
|------|-------|---------|
| canonical-project-structure.md | Authoritative VSE project directory layout | project-setup, project-audit |
