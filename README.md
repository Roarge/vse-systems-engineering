# vse-systems-engineering

A Claude Code plugin for systems engineering in Very Small Entities (VSEs).

## What it does

This plugin supports ISO/IEC 29110 compliant systems engineering workflows that are model-based and digital first, rooted in SysML 2.0 textual syntax. The plugin enforces a story-driven adaptation of agile MBSE in which the user story is the canonical stakeholder-intent artefact at every stage. Stakeholder concerns are captured as `concern def` instances. Stakeholder stories `frame` those concerns. System stories `derive` from stakeholder stories. Subsystem stories `derive` from system stories. Architectural trade studies source their assessment criteria from the formalised `benefit` constraints already present on system stories, so architectural decisions cannot drift from stakeholder intent.

The methodology rejects fixed-length iteration containers (Douglass nanocycle, microcycle, and macrocycle scheduling units). It embraces iteration as recursive practice. The story register is the cross-iteration index, and `StoryMeta.status` records each story's position. The git workflow operates per story: a `story/<US_id>_<short>` branch is opened from `main`, a draft pull request is opened on the first commit, iterative review proceeds on the draft, and the PR is squash-merged after the §8.6 review checklist passes. Releases group `done` stories under `release-vN.M` tags.

The full specification is shipped under `<plugin>/methodology/` and copied into each project that adopts the plugin, so a project may modify its process without forking the plugin.

The plugin works in concert with the official Anthropic engineering plugin, adding VSE-specific systems engineering knowledge and attention-sustaining environmental design.

## Design principles

Grounded in the PHAS-EAI framework (Georgsen, 2026):

1. **Reduce information burden** by filtering guidance to the current story and its workflow stage.
2. **Build designed cognitive reserve** by embedding SE competence in the tooling.
3. **Provide machine-readable traceability** through SysML 2.0 model relationships (`derive`, `frame concern`, `verify`, `allocation`).
4. **Sustain attention** through environmental design rather than compliance mandates.

## Skills

### Core orchestration skills

| Skill | Purpose |
|---|---|
| vse-companion-overview | Set the methodology lens and route to specialist skills (loads first in any VSE session) |
| story-orchestrator | Open and advance user stories per §1 and §8.4–§8.5 (story branch, draft PR, StoryMeta lifecycle) |
| release-orchestrator | Plan, baseline, and report on releases per §10 (story groups, baseline tag, ISO 29110 PM.4 closure) |
| change-request | Author and process Change Requests per §10.4.2 (PM.O3) |
| project-plan | Author or revise the Project Plan, SEMP, Risk Register, CM Strategy, Disposal Approach per §10.3 |

### Workflow-stage skills

| Skill | Purpose |
|---|---|
| needs-and-requirements | Stakeholder needs elicitation and system requirements analysis (§1, §3, §4, §5) |
| architecture-design | Base Architecture authoring, trade studies, subsystem decomposition (§2, §6, §7) |
| verification-validation | Verification cases, validation cases, IVV plan rendering (§4.3.6, §5.4.6, §9.8) |
| traceability-guard | Trace integrity check (`derive`, `frame concern`, `verify`, `allocation`) |

### Lifecycle skills

| Skill | Purpose |
|---|---|
| project-setup | Bootstrap a VSE project per §8.3 layout, copy the methodology into the project, optional brownfield `engineering/` subdirectory |
| project-audit | Audit project layout, story well-formedness, trace integrity, ISO 29110 artefact presence, hook installation, version drift (read-only) |
| attention-regime | Configure ISO 29110 hook surface and install project-side git hooks (per `methodology/iso-29110-hooks-guide.md`) |
| session-journal | Manage cross-session continuity journal |
| document-export | Export work products to docx, pptx, or pdf |

### SysML 2.0 specialist skills

These are routed from `sysml2-modelling` for topic-specific authoring guidance.

| Skill | Purpose |
|---|---|
| sysml2-modelling | SysML 2.0 syntax, validation, and the canonical project layout (umbrella) |
| sysml2-model-structure | Project layout, base architecture reuse, recursive component nesting |
| sysml2-behaviour | Actions, successions, flows, messages, state machines |
| sysml2-allocations | Allocation between functional, logical, and physical layers |
| sysml2-cases | Use cases, analysis cases, verification cases |
| sysml2-expressions | Expressions, calc definitions, constraints, parametric calculations |
| sysml2-metadata | Metadata application (RiskInfo, ConfigItem, Baseline) and reflection |
| sysml2-extension | Domain libraries and user-defined keywords |
| sysml2-variants | Variation points, variant usages, configuration selection |
| sysml2-views | Views, viewpoints, expose statements, rendering |

## Slash commands

The plugin ships a small set of `/vse-*` slash commands as quick entry points to the most-used skills. Each command is a thin wrapper that hands off to the named skill.

| Command | Delegates to | Use case |
|---|---|---|
| `/vse-setup` | `project-setup` | Bootstrap a new VSE project (greenfield or brownfield) |
| `/vse-story` | `story-orchestrator` | Open or advance a user story |
| `/vse-release` | `release-orchestrator` | Plan, baseline, or report on a release |
| `/vse-cr` | `change-request` | Open a Change Request issue with §10.4.2 impact analysis |
| `/vse-plan` | `project-plan` | Author or revise the Project Plan, SEMP, Risk Register, CM Strategy |
| `/vse-trace` | `traceability-guard` | Run a traceability check and report gaps |
| `/vse-audit` | `project-audit` | Audit project structure, story well-formedness, version drift |
| `/vse-journal` | `session-journal` | Open or append the cross-session continuity journal |

You can still invoke any skill directly with `@skill-name` if you need a workflow that the slash commands do not cover.

## Subagents

The plugin ships read-only subagents that the orchestrating skills dispatch to for parallelisable, context-heavy work. Each subagent runs in an isolated context, returns a suggestion-shaped markdown report to the parent skill, and never writes files. The parent skill presents the proposals to the engineer for editing.

| Subagent | Fired by | What it returns |
|---|---|---|
| vse-stakeholder-elicitor | needs-and-requirements at §4 persona-driven elicitation | Per-persona interview script, candidate need statements attributed to the persona of origin, and a cross-persona conflict summary |
| vse-trade-study-runner | architecture-design at §6 trade-off steps | Weighted trade-off matrix with score rationale, sensitivity analysis, and any missing alternatives |
| vse-traceability-matrix-builder | traceability-guard, project-audit, and verification-validation | Complete trace matrix with gap report keyed by rule, plus a bidirectional consistency check across the SysML model tree |

The tool surface for every subagent is restricted to `Read`, `Glob`, and `Grep`. None has access to `Write`, `Edit`, or any other file-modifying tool, so the engineer always remains in control of what reaches the StRS, the System Design Document, the Traceability Matrix, or any other baselined work product.

## Knowledge base

The plugin's reference content sits in three surfaces:

- **`methodology/`** — the canonical methodology specification (§0–§10 plus the ISO 29110 hooks guide). Shipped to every project that adopts the plugin, so the project carries its own copy and may modify the process locally.
- **`wiki/pages/<layer>/`** — atomic markdown reference pages, cross-linked with `[[wikilinks]]`, concatenated into per-skill bundles under `wiki/bundles/` that skills embed at load time. Eleven layers, including a `methodology` layer that summarises the spec and cross-links to it.
- **`templates/`** — work-product templates copied into user projects by `project-setup`.

See `wiki/INDEX.md` for the page catalogue and `wiki/CLAUDE.md` for the authoring schema. The current totals are 129 atomic pages across 11 layers, consumed via 21 skill bundles.

## Sources

Knowledge is extracted from these source categories, consulted in priority order:

1. **The plugin's own methodology specification** — `methodology/00-methodology-overview.md` through `methodology/10-project-management.md` plus `methodology/iso-29110-hooks-guide.md`. When a project carries its own copy at `<project>/methodology/`, that copy wins.
2. **ISO/IEC 29110-5-6-2:2014** — Systems Engineering Profile for VSEs.
3. **PHAS-EAI framework** — Georgsen (2026), thesis on attention in SE.
4. **INCOSE SE Handbook 4e** and domain guides (Needs and Requirements, V&V, HSI).
5. **AMBSE source methodology** — Douglass (2016) *Agile Systems Engineering*, Douglass (2021) *Agile MBSE Cookbook*. The plugin's methodology adapts the source arc per §0.4 of the spec; where it disagrees, the spec wins.
6. **SYSMOD** (Weilkiens, 2020) — Base Architecture and System Context concepts adopted in §2 and §3.
7. **SysML 2.0 specification** — OMG and *The SysML v2 Book* (Weilkiens and Molnár, 2026-04 release).
8. **Domain guides** — Galinier et al. on SME practices.

Source PDFs are private (gitignored) and not distributed with the plugin.

## Tooling

The recommended modelling toolchain is [Sensmetry SySiDE](https://sensmetry.com).

| Workflow | Tool | Licence |
|---|---|---|
| Learning, lightweight editing | **Syside Editor** (VS Code extension) | Free |
| Model writing, diagrams, exploration | **Syside Modeler** (VS Code extension) | Licensed |
| CI/CD validation, headless diagrams | **Syside CLI** (`syside check`, `format`, `viz`) | Licensed |
| Programmatic analysis, scripting, reports | **Syside Automator** (Python library) | Licensed |

Additionally:

- **Sysand** (open-source) for SysML v2 package management.
- Configuration via `syside.toml` in the project root (read by SySiDE itself).
- IDE language server wiring via `.lsp.json` in the project root, copied by `project-setup` so Claude Code launches `syside lsp` automatically for `.sysml` and `.kerml` files.

If you have Modeler, you already have everything Editor offers. Disable the Editor extension when Modeler is active to avoid conflicts. Modeler and Automator share the same licence key.

### Automator capabilities

The Syside Automator (`pip install syside`, Python 3.12+) enables programmatic workflows that the CLI alone cannot provide:

- **Requirements import/export**: round-trip between SysML models and Excel spreadsheets for acquirer review.
- **Semantic trace checking**: programmatic `derive`/`frame concern`/`verify` link analysis with broken link detection.
- **Value rollup**: mass, power, and cost budgets with automatic unit conversion.
- **Variant analysis**: extract and compare product line configurations.
- **Report generation**: Jinja2-based pipeline producing PDF, HTML, and DOCX with traceability matrices and dependency graphs.
- **State machine simulation**: simulate SysML state machines in Python.
- **Interactive exploration**: REPL mode for ad hoc model queries.

See the SySiDE pages under `wiki/pages/syside/` for the full API reference.

## Getting started

### Prerequisites

- [Claude Code](https://claude.com/claude-code) CLI installed.
- (Recommended) [Sensmetry SySiDE](https://sensmetry.com) VS Code extension for `.sysml` file editing, validation, and navigation.
- (Optional) Syside Automator for programmatic model analysis: `pip install syside` (requires Python 3.12+, same licence key as Modeler).

### Installation from a local clone

Clone the repository, then register it as a local marketplace inside Claude Code:

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

After adding the marketplace, you might need to restart Claude Code so it discovers the new source. Then install the plugin.

### Hooks

The plugin ships an ISO 29110 hook surface across two layers, specified in `methodology/iso-29110-hooks-guide.md`:

- **Lifecycle hooks** (registered in the plugin's `hooks.json`, run by the Claude Code harness): `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `PreCompact`, `Notification`. They inject project status, surface the §2.6 rule 7 reverse-engineering guard, and prompt for V&V or ADR follow-up.
- **Project-side git hooks** (installed into a user project under `<project>/.githooks/` by the `attention-regime` skill, activated with `git config core.hooksPath .githooks`): `pre-commit`, `commit-msg`, `prepare-commit-msg`, `pre-push`, `post-merge`, `post-checkout`. They enforce SysML lint, story well-formedness, conventional-commit patterns, baselined-artefact protection, V&V coverage on `done` stories, and traceability matrix freshness.

Project-side hook configuration sits in `<project>/.iso-config.yaml` per §8 of the hooks guide. The schema is reproduced in the `attention-regime` skill body.

### Starting a new project

1. Open a fresh project directory in your terminal.
2. Launch Claude Code and invoke `/vse-setup`.
3. The skill enters Plan Mode, drafts the §8.3 layout (`model/core/{stakeholders, concerns, base-architecture, context, domain, stories/{stakeholder, system}, use-cases, ...}`, `model/variations/`, `methodology/`, `docs/`, etc.), and asks where the engineering work goes (default: `engineering/` subdirectory; override: repo root or custom subdirectory).
4. After Plan Mode approval, the skill scaffolds the directories, copies the methodology spec into the project's `methodology/` folder, generates the Project Plan, SEMP, Risk Register, and CM Strategy stubs, and prepares the `.github/`, `.iso-config.yaml`, and `.githooks/` scaffolding. Greenfield mode runs `git init` and an initial commit. Brownfield mode leaves staging to the engineer.
5. From there, route through the orchestration skills:
   - `/vse-story` opens the first stakeholder story branch.
   - `/vse-plan` walks the §10.3 element list to populate `docs/project-plan.md`.
   - `@needs-and-requirements` begins §4 stakeholder elicitation.

### Picking up an existing VSE project

Open the project directory in Claude Code. The `SessionStart` hook detects the `methodology/` folder (at the repo root for greenfield, or at `engineering/methodology/` for brownfield), reads the current branch and any open story branches, surfaces the most recent plan-baseline tag and any open Change Requests, and prompts to load `vse-companion-overview` as the first action. From there, route through `story-orchestrator`, `release-orchestrator`, and the workflow-stage skills as required.

### Demo walkthrough

The `demo/smart-sensor/` directory contains a worked example. The demo is being rebuilt against the new methodology and currently lags the other phases of the v2.0 restructuring. See its README for the current state.

## Versioning

The plugin follows semantic versioning. The current branch is in flight on the v2.0 restructuring. End-user installs should pin to `1.2.0` until `2.0.0` lands. See `CHANGELOG.md` for the full change history.
