# vse-systems-engineering

A Claude Code plugin for systems engineering in Very Small Entities (VSEs).

## What it does

This plugin supports ISO/IEC 29110 aligned systems engineering workflows that are model-based and digital first, rooted in SysML 2.0 textual syntax. It carries the knowledge to guide a VSE through a story-driven adaptation of agile MBSE in which the user story is the canonical stakeholder-intent artefact at every stage. Stakeholder concerns are captured as `concern def` instances. Stakeholder stories `frame` those concerns. System stories `derive` from stakeholder stories. Subsystem stories `derive` from system stories. Architectural trade studies source their assessment criteria from the formalised `benefit` constraints already present on system stories, so architectural decisions cannot drift from stakeholder intent.

The plugin guides rather than polices. Every project records a **rigour profile** (`light`, `standard`, or `full`, per methodology §0.10) that scales the artefact set, the ceremony, and the disposition of every automated gate. At `light` nothing blocks and the methodology advises. At `standard` (the default) gates warn and the core artefacts are required. At `full` the project runs audit-ready ISO/IEC 29110 conformance with blocking gates. Any single gate can be raised or lowered per project, and every deviation is recorded on a one-line tailoring record.

The methodology rejects fixed-length iteration containers (Douglass nanocycle, microcycle, and macrocycle scheduling units). It embraces iteration as recursive practice. The story register is the cross-iteration index, and `StoryMeta.status` records each story's position. The git workflow operates per story: a `story/<US_id>_<short>` branch is opened from `main`, a draft pull request is opened on the first commit, iterative review proceeds on the draft, and the PR is squash-merged after the §8.6 review checklist passes (tiered by profile). Releases group `done` stories under `release-vN.M` tags.

The full specification is shipped under `<plugin>/methodology/` and copied into each project that adopts the plugin, so a project may modify its process without forking the plugin.

## Design principles

Grounded in the PHAS-EAI framework (Georgsen, 2026):

1. **Reduce information burden** by filtering guidance to the current story and its workflow stage.
2. **Build designed cognitive reserve** by embedding SE competence in the tooling.
3. **Provide machine-readable traceability** through SysML 2.0 model relationships (`derive`, `frame concern`, `satisfy`, `verify`, `allocation`).
4. **Sustain attention** through environmental design rather than compliance mandates.

## Skills

The plugin ships 28 skills in five groups.

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
| traceability-guard | Trace integrity check (`satisfy` and `verify` links, validation coverage) |

### Lifecycle skills

| Skill | Purpose |
|---|---|
| project-setup | Bootstrap a VSE project per §8.3 layout, ask the rigour-profile question once, copy the methodology into the project, optional brownfield `engineering/` subdirectory |
| project-audit | Audit project layout, story well-formedness, trace integrity, ISO 29110 artefact presence, hook installation, version drift (read-only apart from its audit report) |
| attention-regime | Configure the ISO 29110 hook surface and install profile-scaled project-side git hooks (per `methodology/iso-29110-hooks-guide.md`) |
| session-journal | Manage cross-session continuity journal |
| document-export | Export work products to docx, pptx, or pdf |

### SysML 2.0 specialist skills

These are routed from `sysml2-modelling` for topic-specific authoring
guidance, and they activate on `.sysml` files (`paths` gating), so a
session that never touches a model does not carry them.

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

### Wiki contributor skills

Four skills maintain the plugin's own knowledge base and are relevant
inside this repository, not in user projects. They are user-invocable
only (`disable-model-invocation`), so they never activate on their own.

| Skill | Purpose |
|---|---|
| vse-wiki-ingest | Process one new source into atomic wiki pages through an interactive proposal |
| vse-wiki-lint | Read-only wiki health check reporting to a gitignored scratch file |
| vse-wiki-refactor | Periodic editorial sweep (merges, splits, cross-links, confidence) |
| vse-wiki-index | Regenerate `wiki/INDEX.md` and every skill routing block from page frontmatter |

## Slash commands

The plugin ships twelve `/vse-*` slash commands as quick entry points. Each command is a thin wrapper that hands off to the named skill.

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
| `/vse-wiki-ingest` | `vse-wiki-ingest` | Ingest one source into the wiki (contributor) |
| `/vse-wiki-lint` | `vse-wiki-lint` | Health-check the wiki (contributor) |
| `/vse-wiki-refactor` | `vse-wiki-refactor` | Editorial sweep of the wiki (contributor) |
| `/vse-wiki-index` | `vse-wiki-index` | Regenerate INDEX and routing blocks (contributor) |

You can still invoke any skill directly with `@skill-name` if you need a workflow that the slash commands do not cover.

## Subagents

The plugin ships read-only subagents that the orchestrating skills dispatch for parallelisable, context-heavy work. Each subagent runs in an isolated context, returns a suggestion-shaped markdown report to the parent skill, and never writes files. The parent skill presents the proposals to the engineer for editing.

| Subagent | Fired by | What it returns |
|---|---|---|
| vse-stakeholder-elicitor | needs-and-requirements at §4 persona-driven elicitation | Per-persona interview script, candidate need statements attributed to the persona of origin, and a cross-persona conflict summary |
| vse-trade-study-runner | architecture-design at §6 trade-off steps | Weighted trade-off matrix with score rationale, sensitivity analysis, and any missing alternatives |
| vse-traceability-matrix-builder | traceability-guard and project-audit (verification-validation routes through traceability-guard) | Complete trace matrix with gap report keyed by rule, plus a bidirectional consistency check across the SysML model tree |
| vse-wiki-ingestor | vse-wiki-ingest (contributor side) | Atomic-page decomposition proposal for one converted source |
| vse-wiki-curator | vse-wiki-refactor (contributor side) | Full-wiki refactor proposal (merges, splits, cross-links, confidence revisions) |

The tool surface for every subagent is restricted to `Read`, `Glob`, and `Grep`. None has access to `Write`, `Edit`, or any other file-modifying tool, so the engineer always remains in control of what reaches the StRS, the System Design Document, the Traceability Matrix, or any other baselined work product.

## Knowledge base

The plugin's reference content sits in three surfaces:

- **`methodology/`** carries the canonical methodology specification (§0 through §10 plus the ISO 29110 hooks guide). Shipped to every project that adopts the plugin, so the project carries its own copy and may modify the process locally.
- **`wiki/pages/<layer>/`** holds atomic markdown reference pages, cross-linked with `[[wikilinks]]`. Each reference-bearing skill carries a generated routing table naming the pages it is expected to need (title, path, and a one-line read-when trigger) and reads those pages on demand with the Read tool, one page at a time. Nothing is concatenated and nothing is front-loaded. `wiki/INDEX.md` is the generated catalogue for anything a routing table does not cover.
- **`templates/`** holds work-product templates copied into user projects by `project-setup`.

See `wiki/INDEX.md` for the page catalogue and totals (158 atomic pages across 12 layers, routed to by 20 skills at the 3.0.0 release) and `wiki/CLAUDE.md` for the authoring schema.

## Sources

Knowledge is extracted from these sources, consulted in priority order:

1. **The plugin's own methodology specification** at `methodology/00-methodology-overview.md` through `methodology/10-project-management.md` plus `methodology/iso-29110-hooks-guide.md`. When a project carries its own copy at `<project>/methodology/`, that copy wins.
2. **ISO/IEC TR 29110-5-6-2:2014**, the Systems Engineering Profile for VSEs.
3. **PHAS-EAI framework**: Georgsen (2026) doctoral thesis, Georgsen (2023) on LLM peer review in VSE engineering, and Georgsen (2026) on guiding attention in purposeful human activity systems.
4. **Galinier et al.** on SME engineering practices.
5. **INCOSE SE Handbook 4e**, scaled for VSEs.
6. **AMBSE source methodology**: Douglass (2016) *Agile Systems Engineering* and Douglass (2021) *Agile MBSE Cookbook*. The plugin's methodology adapts the source arc per §0.4 of the spec. Where it disagrees, the spec wins.
7. **The Weilkiens methodology family**: *SYSMOD* 3rd edition (Base Architecture and System Context concepts adopted in §2 and §3), *Variant Modeling with SysML* (VAMOS), and *The New Engineering Game*.
8. **SysML 2.0**: the OMG specification, *The SysML v2 Book* (Weilkiens and Molnár, 2026-07 release), and Sensmetry Syside notes.
9. **Domain guides**: INCOSE Needs and Requirements, Verification and Validation, and the HSI Primer.

Source PDFs are private (gitignored) and not distributed with the plugin. Every wiki page carries a citation that stands on its own.

## Tooling

The recommended modelling toolchain is [Sensmetry Syside](https://sensmetry.com), current release 0.10.3 (July 2026).

| Workflow | Product | Licence |
|---|---|---|
| Learning SysML v2, quick edits, validation, navigation | **Syside Editor** (VS Code extension, SysML v2 Essential) | Free |
| Model writing with diagrams, grid views, scripting, CI validation | **Syside Pro Suite** (Modeler plus Automator with the `syside` CLI) | Paid |
| The Pro Suite in a browser, Claude Code preinstalled | **Syside Cloud** | Paid |

Additionally:

- **Sysand** (open source, v0.2.0) for SysML v2 package management: manifests, lock file, KPAR packaging, and CI publishing.
- Configuration via `syside.toml` in the project root (three-level discovery, read by Syside itself).
- IDE language server wiring via `.lsp.json` in the project root, copied by `project-setup` so Claude Code launches `syside lsp` automatically for `.sysml` and `.kerml` files.

The earlier open-source `sysml-2ls` language server was archived in October 2025 as "SysIDE Editor Legacy" and is no longer maintained. Use Syside Editor.

### Automator capabilities

The Syside Automator (part of the Pro Suite, `pip install syside`, Python 3.12+) enables programmatic workflows that the extensions alone cannot provide: requirements round-trip with spreadsheets, semantic trace checking over `satisfy` and `verify` links, value rollup with unit conversion, variant analysis, report generation, state machine simulation, and interactive model exploration. See the pages under `wiki/pages/syside/` for the API surface the plugin's skills rely on.

## Getting started

### Prerequisites

- [Claude Code](https://claude.com/claude-code) CLI installed.
- (Recommended) Syside Editor for `.sysml` file editing, validation, and navigation.
- (Optional) Syside Pro Suite for diagrams and programmatic model analysis (`pip install syside`, Python 3.12+).

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

- **Lifecycle hooks** (registered in the plugin's `hooks.json`, run by the Claude Code harness): `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `PreCompact`, `Notification`. They inject project status including the rigour profile, surface the §2.6 rule 7 reverse-engineering guard, and prompt for V&V or ADR follow-up. Lifecycle hooks are advisory at every profile.
- **Project-side git hooks** (installed into a user project under `<project>/.githooks/` by the `attention-regime` skill, activated with `git config core.hooksPath .githooks`): `pre-commit`, `commit-msg`, `prepare-commit-msg`, `post-merge`, `post-checkout`, the `pre-commit-traceability` delegate the pre-commit hook invokes, and the shared `lib/iso-profile.sh`. They cover SysML lint, story well-formedness, conventional-commit patterns, baselined-artefact protection, and traceability on touched requirements. Which hooks an install copies, and whether each gate blocks, warns, informs, or stays off, is a function of the project rigour profile per §0.10.4 of the methodology and §3.4 of the hooks guide. No local `pre-push` hook ships: those obligations are continuous-integration contracts documented in §4.4 of the hooks guide.

Project-side hook configuration sits in `<project>/.iso-config.yaml` (`project_profile`, `gate_overrides`, `baselined_paths`, and the other keys per §8 of the hooks guide). The schema is reproduced in the `attention-regime` skill body.

### Starting a new project

1. Open a fresh project directory in your terminal.
2. Launch Claude Code and invoke `/vse-setup`.
3. The skill enters Plan Mode, asks the rigour-profile question once (`light`, `standard`, or `full`, reversible later), drafts the §8.3 layout (`model/core/{stakeholders, concerns, base-architecture, context, domain, stories/{stakeholder, system}, use-cases, ...}`, `model/variations/`, `methodology/`, `docs/`, etc.), and asks where the engineering work goes. For a fresh project the default is the repo root. Brownfield adoption defaults to an `engineering/` subdirectory, and a custom sub-path is possible in both modes.
4. After Plan Mode approval, the skill scaffolds the directories, copies the methodology spec into the project's `methodology/` folder, writes the profile and its tailoring record, generates the profile-scaled document stubs, and prepares the `.github/`, `.iso-config.yaml`, and `.githooks/` scaffolding. Greenfield mode runs `git init` and an initial commit. Brownfield mode leaves staging to the engineer.
5. From there, route through the orchestration skills:
   - `/vse-story` opens the first stakeholder story branch.
   - `/vse-plan` walks the §10.3 element list to populate `docs/project-plan.md`.
   - `@needs-and-requirements` begins §4 stakeholder elicitation.

### Picking up an existing VSE project

Open the project directory in Claude Code. The `SessionStart` hook detects the `methodology/` folder (at the repo root for greenfield, or at `engineering/methodology/` for brownfield), reads the profile, the current branch, and any open story branches, surfaces the most recent plan-baseline tag and any open Change Requests, and prompts to load `vse-companion-overview` as the first action. From there, route through `story-orchestrator`, `release-orchestrator`, and the workflow-stage skills as required.

### Demo walkthrough

The `demo/smart-sensor/` directory contains a worked example: a Wi-Fi-connected environmental sensor with stakeholder and system stories, a resolved trade study, verification and validation cases, and the full ISO 29110 work-product set at the `standard` profile. It is the plugin's dogfood ground and is kept level with the shipped version by a CI check.

## Versioning

The plugin follows semantic versioning, with the plugin and marketplace manifests bumped in lockstep on every landed change. The current release is **3.0.0**. During a multi-PR train, release candidates accumulate under the `[Unreleased]` heading in `CHANGELOG.md` and the next rc number is assigned at merge time. See `CHANGELOG.md` for the full change history.
