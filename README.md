# vse-systems-engineering

A Claude Code plugin for systems engineering in Very Small Entities (VSEs).

## What it does

This plugin supports ISO/IEC 29110 compliant systems engineering workflows that
are model-based and digital first, rooted in SysML 2.0 textual syntax. It
enforces hybrid AMBSE (Agile Model-Based Systems Engineering) per Douglass
(2021) as the single workflow for VSE projects. AMBSE applies the Vee
verification pattern at three timeframes (nanocycle, microcycle, macrocycle),
with verification performed at every iteration boundary. The plugin pairs use
case driven elicitation, structured trade studies, and continuous verification
with a branch-per-microcycle git workflow in which each iteration ends in a
pull request review. See
[knowledge/ambse-git-workflow.md](knowledge/ambse-git-workflow.md) for the full
mapping.

The plugin works in concert with the official Anthropic engineering plugin,
adding VSE-specific systems engineering knowledge and attention-sustaining
environmental design.

## Design principles

Grounded in the PHAS-EAI framework (Georgsen, 2026):

1. **Reduce information burden** by filtering guidance to the current
   iteration and its centre-of-gravity activity
2. **Build designed cognitive reserve** by embedding SE competence in the tooling
3. **Provide machine-readable traceability** through SysML 2.0 models
4. **Sustain attention** through environmental design rather than compliance
   mandates

## Skills

### Core workflow skills

| Skill | Purpose |
|-------|---------|
| vse-companion-overview | Set the VSE lens, source-processing order, and routing for any VSE session (loads first) |
| iteration-orchestrator | Manage AMBSE iterations, open and close microcycles, run iteration-boundary and macrocycle closure checks |
| needs-and-requirements | Elicit stakeholder needs and derive SysML requirements (use case driven) |
| architecture-design | Develop architecture with trade studies, five views, and handoff workflow |
| verification-validation | Plan and execute V&V with continuous verification and trace links |
| traceability-guard | Check and enforce trace completeness |
| sysml2-modelling | Author and validate SysML 2.0 textual models (router to specialist skills below) |
| attention-regime | Configure environmental hooks, guards, and reminders |
| session-journal | Manage cross-session continuity journal |
| project-setup | Bootstrap a new VSE project with templates and structure |
| project-audit | Audit an existing VSE project for structural completeness and non-canonical configuration |
| document-export | Export work products to docx, pptx, or pdf |

### SysML 2.0 specialist skills

These are routed from `sysml2-modelling` for topic-specific authoring guidance.

| Skill | Purpose |
|-------|---------|
| sysml2-model-structure | Organise a SysML 2.0 model into the AMBSE canonical layout with base-architecture reuse, variant configurations, and CM |
| sysml2-behaviour | Model actions, successions, flows, messages, and state machines |
| sysml2-allocations | Map behaviour to structure across functional, logical, and physical architecture layers |
| sysml2-cases | Author use cases, analysis cases, and verification cases |
| sysml2-expressions | Author expressions, calc definitions, constraints, and parametric calculations |
| sysml2-metadata | Apply metadata (RiskInfo, ConfigItem, Baseline), user-defined keywords, and model queries |
| sysml2-variants | Model variation points, variant usages, and configuration selection for product lines |
| sysml2-views | Author views, viewpoints, expose statements, and rendering configuration |

## Slash commands

The plugin ships a small set of `/vse-*` slash commands as quick entry points
to the most-used skills. Each command is a thin wrapper that hands off to the
named skill and forwards any arguments you supply.

| Command           | Delegates to             | Use case                                                                                     |
|-------------------|--------------------------|----------------------------------------------------------------------------------------------|
| `/vse-setup`      | `project-setup`          | Bootstrap a new VSE project (greenfield or brownfield)                                       |
| `/vse-iteration`  | `iteration-orchestrator` | Report iteration position, run the iteration-boundary closure check, handle a Change Request |
| `/vse-microcycle` | `iteration-orchestrator` | Open a new AMBSE microcycle: elicit mission, centre of gravity, branch, backlog              |
| `/vse-nanocycle`  | `iteration-orchestrator` | Plan a single commit: anchor thread, intent, verification hook, commit message               |
| `/vse-trace`      | `traceability-guard`     | Run a traceability check against the current SysML models and report gaps                    |
| `/vse-journal`    | `session-journal`        | Open or append the cross-session continuity journal                                          |
| `/vse-audit`      | `project-audit`          | Audit project structure for completeness and non-canonical configuration                     |

You can still invoke any skill directly with `@skill-name` if you need a
workflow that the slash commands do not cover.

## Subagents

The plugin ships three read-only subagents that the orchestrating
skills dispatch to for parallelisable, context-heavy work. Each
subagent runs in an isolated context, returns a suggestion-shaped
markdown report to the parent skill, and never writes files. The
parent skill presents the proposals to the engineer for editing.

| Subagent | Fired by | What it returns |
|---|---|---|
| vse-trade-study-runner | architecture-design at SR.3 trade-off steps | Weighted trade-off matrix with score rationale, sensitivity analysis, and any missing alternatives the engineer may not have considered |
| vse-traceability-matrix-builder | traceability-guard and verification-validation | Complete trace matrix with gap report keyed by rule and a bidirectional consistency check across the SysML model tree |
| vse-stakeholder-elicitor | needs-and-requirements at SR.2 persona-driven elicitation | Per-persona interview script, candidate need statements attributed to the persona of origin, and a cross-persona conflict summary |

The tool surface for every subagent is restricted to `Read`, `Glob`,
and `Grep`. None has access to `Write`, `Edit`, or any other
file-modifying tool, so the engineer always remains in control of what
reaches the StRS, the System Design Document, the Traceability Matrix,
or any other baselined work product.

## Knowledge base

The plugin's reference content sits in two surfaces:

- **`wiki/pages/<layer>/`**: atomic markdown pages of 80 to 250 lines,
  cross-linked with Obsidian-style `[[wikilinks]]`, concatenated into
  per-skill bundles under `wiki/bundles/` that skills embed at load
  time. The full SysML 2.0 reference set (61 pages, 9 bundles) lives
  here as of version 0.17.0.
- **`knowledge/`**: 14 flat reference files awaiting atomisation in
  later migration phases. Each is embedded directly into the
  consuming skill via `!cat ${CLAUDE_PLUGIN_ROOT}/knowledge/...`.

See `wiki/INDEX.md` for the page catalogue, `wiki/CLAUDE.md` for the
authoring schema, and `knowledge/INDEX.md` for the legacy
catalogue.

### SysML 2.0 (wiki, OMG formal/2025-01-01 plus Weilkiens and Molnár 2026-04)

61 atomic pages organised by skill. Each consuming skill loads its
bundle (`wiki/bundles/<skill>.md`):

| Bundle | Pages | Skill | Topic |
|---|---|---|---|
| sysml2-modelling | 17 | `sysml2-modelling` | Notation cheat sheet, semantics, libraries (umbrella) |
| sysml2-behaviour | 12 | `sysml2-behaviour` | Actions, successions, state machines, flows, occurrences/4D, model execution |
| sysml2-expressions | 6 | `sysml2-expressions` | Expressions, constraints, calculations, advanced quantities |
| sysml2-metadata | 6 | `sysml2-metadata` | Metadata, reflection, filters, language extension, VSE_Library |
| sysml2-model-structure | 5 | `sysml2-model-structure` | Canonical layout, base architecture, namespace hygiene, variants, CM |
| sysml2-views | 4 | `sysml2-views` | Viewpoints, views, standard views, patterns |
| sysml2-allocations | 4 | `sysml2-allocations` | Allocations, binding connectors, patterns |
| sysml2-variants | 4 | `sysml2-variants` | Variations, variant configuration, patterns |
| sysml2-cases | 3 | `sysml2-cases` | Use, analysis, verification cases |

The 2026-04 release of *The SysML v2 Book* is fully captured:
self/that contextual references (Section 17.3), binding connectors
(Chapter 21), advanced quantities and units (Section 24.3),
occurrences and 4D modelling (Chapter 25, four pages), and model
execution (Chapter 39).

### Legacy reference files awaiting migration

These are still flat files under `knowledge/`. Each will be
atomised into `wiki/pages/` in a follow-on migration phase.

**ISO/IEC 29110** (process backbone)

- `iso29110-profile.md` -- process structure, roles, work products, lifecycle-neutral entry
- `iso29110-task-lists.md` -- actionable checklists organised by activity, for use as centre-of-gravity selectors
- `iteration-centred-operation.md` -- how ISO 29110 tasks map onto AMBSE iterations, centre of gravity, brownfield entry, closure checks

**PHAS-EAI** (design rationale)

- `phas-eai-framework.md` -- attention constructs, lever tables, DE requirements

**INCOSE** (best practices, scaled)

- `incose-vse-practices.md` -- lifecycle models, stakeholder analysis, V&V
- `needs-and-reqs-guide.md` -- needs elicitation, SMART criteria, writing rules
- `vv-guide.md` -- verification and validation methods, VCRM
- `hsi-primer.md` -- human-systems integration

**AMBSE** (agile model-based process)

- `ambse-agile-process.md` -- hybrid lifecycle, iteration planning, verification timeframes, metrics
- `ambse-requirements.md` -- use case driven elicitation, model-based requirements, nanocycle workflow
- `ambse-architecture.md` -- five architecture views, trade studies, handoff, model-based V&V
- `ambse-git-workflow.md` -- branch-per-microcycle git mapping, PR template, anti-patterns

**SySiDE Automator** (tooling)

- `syside-automator-ref.md` -- Python API reference, tool selection guide, workflow patterns

**Project structure**

- `canonical-project-structure.md` -- authoritative VSE project directory layout

## Sources

Knowledge is extracted from six source categories, consulted in this priority:

1. **ISO/IEC 29110** -- Systems Engineering Profile for VSEs
2. **PHAS-EAI framework** -- Georgsen (2026), thesis on attention in SE
3. **INCOSE SE Handbook 4e** and domain guides (Needs and Requirements, V&V, HSI)
4. **AMBSE methodology** -- Douglass (2016) *Agile Systems Engineering*, Douglass (2021) *Agile MBSE Cookbook*
5. **SysML 2.0 specification** -- OMG formal/2025-01-01
6. **Domain guides** -- Galinier et al. on SME practices

Source PDFs are private (gitignored) and not distributed with the plugin.

## Tooling

The recommended modelling toolchain is [Sensmetry SySiDE](https://sensmetry.com).
Choose tools based on your workflow:

| Workflow | Tool | Licence |
| --- | --- | --- |
| Learning, lightweight editing | **Syside Editor** (VS Code extension) | Free |
| Model writing, diagrams, exploration | **Syside Modeler** (VS Code extension) | Licensed |
| CI/CD validation, headless diagrams | **Syside CLI** (`syside check`, `format`, `viz`) | Licensed |
| Programmatic analysis, scripting, reports | **Syside Automator** (Python library) | Licensed |

Additionally:

- **Sysand** (open-source) for SysML v2 package management
- Configuration via `syside.toml` in the project root (read by SySiDE itself)
- IDE language server wiring via `.lsp.json` in the project root, copied
  by `project-setup` so Claude Code launches `syside lsp` automatically
  for `.sysml` and `.kerml` files

If you have Modeler, you already have everything Editor offers. Disable the
Editor extension when Modeler is active to avoid conflicts. Modeler and
Automator share the same licence key.

### Automator capabilities

The Syside Automator (`pip install syside`, Python 3.12+) enables programmatic
workflows that the CLI alone cannot provide:

- **Requirements import/export**: round-trip between SysML models and Excel
  spreadsheets for acquirer review
- **Semantic trace checking**: programmatic satisfy/verify link analysis with
  broken link detection
- **Value rollup**: mass, power, and cost budgets with automatic unit conversion
- **Variant analysis**: extract and compare product line configurations
- **Report generation**: Jinja2-based pipeline producing PDF, HTML, and DOCX
  with traceability matrices and dependency graphs
- **State machine simulation**: simulate SysML state machines in Python
- **Interactive exploration**: REPL mode for ad hoc model queries

See `knowledge/syside-automator-ref.md` for the full API reference.

## Getting started

### Prerequisites

- [Claude Code](https://claude.com/claude-code) CLI installed
- (Recommended) [Sensmetry SySiDE](https://sensmetry.com) VS Code extension for
  `.sysml` file editing, validation, and navigation
- (Optional) Syside Automator for programmatic model analysis:
  `pip install syside` (requires Python 3.12+, same licence key as Modeler)

### Installation from a local clone

Clone the repository, then register it as a local marketplace inside Claude
Code:

```bash
git clone https://github.com/Roarge/vse-systems-engineering.git
```

Inside a Claude Code session, run the slash commands:

```text
/plugin marketplace add /path/to/vse-systems-engineering
/plugin install vse-systems-engineering@vse-systems-engineering
```

### Installation from GitHub

Inside a Claude Code session:

```text
/plugin marketplace add Roarge/vse-systems-engineering
/plugin install vse-systems-engineering@Roarge-vse-systems-engineering
```

After adding the marketplace, you might need to restart Claude Code so it discovers the new
source. Then install the plugin.

### Git hooks (optional)

The `hooks/` directory contains two git hook scripts for automated enforcement:

- **pre-commit-traceability.sh** blocks commits when staged `.sysml` files have
  requirements without `satisfy` or `verify` trace links.
- **iteration-boundary-check.sh** reports (advisory) which work products required
  by the iteration's centre-of-gravity activities are missing at iteration close.
  Missing items become explicit iteration-boundary closure debt on the backlog.
  The only hard gate in the plugin is the macrocycle closure check at release.

To install them in a project:

```bash
cp hooks/pre-commit-traceability.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

These are standard git hooks, not Claude Code plugin hooks. They complement the
plugin by catching trace gaps at commit time.

### Starting a new project

1. Open a fresh project directory in your terminal.
2. Launch Claude Code and invoke the `project-setup` skill.
3. The skill scaffolds the directory structure, creates SysML 2.0 model stubs,
   populates work product templates, and writes an initial `.vse-iteration.yml`
   for Iteration 0 (Architecture Zero) with centre of gravity PM.1 plus SR.1
   for a greenfield project, or a detected centre of gravity for a brownfield
   project.
4. Use `iteration-orchestrator` (or the `/vse-iteration`, `/vse-microcycle`,
   `/vse-nanocycle` slash commands) to navigate the AMBSE iteration cycles,
   open the next microcycle, plan a nanocycle commit, or run the
   iteration-boundary closure check. The plugin enforces hybrid AMBSE as the
   single VSE lifecycle. Each iteration is a `vse/iter-NN` feature branch
   ending in a pull request.

### Picking up an existing VSE project

For a project that was previously scaffolded by `project-setup` (or any
project that already carries a `.vse-iteration.yml` file at its root),
pickup is automatic. Open the project directory in Claude Code and the
`SessionStart` hook will:

1. Detect the `.vse-iteration.yml` file and read the current iteration
   number, mission, branch, and centre-of-gravity activities.
2. Print the iteration position, the mandatory first action (load
   `vse-companion-overview`), and the SysML model summary.
3. Surface the session journal via `session-journal` if `.vse-journal.yml`
   exists, so the previous session's pending work and open issues are
   visible.

From there, invoke `vse-companion-overview` to set the lens, then route
iteration work to `iteration-orchestrator` and the other specialised skills
it indexes. The orchestrator walks the engineer through opening the next
microcycle, planning a nanocycle commit, and running the iteration-boundary
closure check.

### Adding VSE to an existing repository

If you have an existing software project (or any other repository) and
want to bring it under VSE systems engineering governance, invoke
`project-setup` from inside the repository. The skill detects that it is
running inside an existing git working tree and switches to brownfield
mode:

1. **Context harvest.** It reads `README.md`, any existing `CLAUDE.md`,
   `git config user.name`, the language-ecosystem manifest (for example
   `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`), and a
   `git ls-files | head -200` summary of your source tree, then asks you
   only for the fields it could not infer (typically the acquirer name
   and primary stakeholder roles).
2. **Engineering subfolder layout.** All VSE work products land under a
   new `engineering/` subfolder so your existing project root stays
   clean. The `models/`, `docs/pm/`, `docs/sr/`, `TASKS.md`, `syside.toml`,
   and `.lsp.json` files all live under `engineering/`. Only
   `.vse-iteration.yml`, `.vse-journal.yml`, and the merged `CLAUDE.md`
   sit at the project root, so the SessionStart hook keeps working
   without configuration.
3. **Idempotent CLAUDE.md merge.** If your project already has a
   `CLAUDE.md`, the skill appends a marker block delimited by
   `<!-- BEGIN VSE COMPANION (managed by project-setup) -->` and
   `<!-- END VSE COMPANION -->`. Your existing content stays intact at
   the top of the file. Re-running `project-setup` later replaces the
   bytes between the markers in place, so you always pick up the
   current plugin version without duplicating content or drifting from
   the surrounding text you authored.
4. **Host-project git history is preserved.** Brownfield mode does not
   run `git init`, `git add`, or `git commit`. The skill leaves the
   staging step to you, and the Step 11 summary tells you to stage the
   new files on a `vse/iter-00-architecture-zero` branch so the AMBSE
   branch-per-microcycle workflow applies from your first commit.
5. **Hooks autodetect the layout.** The session-start,
   iteration-boundary-check, and pre-commit traceability scripts all
   check for `engineering/models` or `engineering/syside.toml` and point
   their model and work-product paths at `engineering/` automatically.
   The same scripts also work in greenfield projects without modification.

Re-running `project-setup` inside a brownfield repository is safe: the
marker-block merge is idempotent, the existing `engineering/` files are
left in place unless you confirm otherwise, and your host project's
source files are never touched.

### Demo walkthrough

The `demo/smart-sensor/` directory contains a complete lifecycle example that
walks through stakeholder needs, system requirements, architecture, verification,
and validation. See its README for a guided tour.
