# vse-systems-engineering

A Claude Code plugin for systems engineering in Very Small Entities (VSEs).

## What it does

This plugin supports ISO/IEC 29110 aligned systems engineering workflows that are model-based and digital first, rooted in SysML 2.0 textual syntax. It carries the knowledge to guide a VSE through a story-driven adaptation of agile MBSE in which the user story is the canonical stakeholder-intent artefact at every stage. Stakeholder concerns are captured as `concern def` instances. Stakeholder stories `frame` those concerns. System stories `derive` from stakeholder stories. Subsystem stories `derive` from system stories. Architectural trade studies source their assessment criteria from the formalised `benefit` constraints already present on system stories, so architectural decisions cannot drift from stakeholder intent.

The plugin guides rather than polices, above one floor. Every project records a **rigour profile** (`light`, `standard`, or `full`, per methodology §0.10) that scales the artefact set, the ceremony, and the disposition of the profile-scaled gates. At `light` the methodology advises and those gates warn, inform, or stay off. At `standard` (the default) they warn and the core artefacts are required. At `full` the project runs audit-ready ISO/IEC 29110 conformance with blocking gates. The floor holds at every profile: four Gherkin-first and test-first gates block at `light`, `standard` and `full` alike, so a story gets its Gherkin feature file (its acceptance criteria written as plain-text Given/When/Then scenarios) before it changes, and, where test first applies, code gets its failing test first (methodology §11). Only a `gate_overrides` entry recorded with its reason lowers one of these four (§0.10.4, §11.10). Any other single gate can be raised or lowered per project, and every deviation is recorded on a one-line tailoring record.

The methodology rejects fixed-length iteration containers (Douglass nanocycle, microcycle, and macrocycle scheduling units). It embraces iteration as recursive practice. The story register is the cross-iteration index, and `StoryMeta.status` records each story's position. The git workflow operates per story: a `story/<US_id>_<short>` branch is opened from `main`, a draft pull request is opened on the first commit, iterative review proceeds on the draft, and the PR is squash-merged after the §8.6 review checklist passes (tiered by profile). Releases group `done` stories under `release-vN.M` tags.

The full specification is shipped under `<plugin>/methodology/` and copied into each project that adopts the plugin, so a project may modify its process without forking the plugin.

## Design principles

Grounded in the PHAS-EAI framework (Georgsen, 2026):

1. **Reduce information burden** by filtering guidance to the current story and its workflow stage.
2. **Build designed cognitive reserve** by embedding SE competence in the tooling.
3. **Provide machine-readable traceability** through SysML 2.0 model relationships (`derive`, `frame concern`, `satisfy`, `verify`, `allocation`).
4. **Sustain attention** through environmental design rather than compliance mandates, so even a gate that blocks is part of the working environment and names the fix in its reason.

## Skills

The plugin ships 30 skills in five groups.

### Core orchestration skills

| Skill | Purpose |
|---|---|
| vse-companion-overview | Set the methodology lens and route to specialist skills (loads first in any VSE session) |
| story-orchestrator | Open and advance user stories per §1 and §8.4–§8.5 (story branch, draft PR, StoryMeta lifecycle) |
| release-orchestrator | Plan, baseline, and report on releases per §10 (story groups, baseline tag, ISO/IEC 29110 PM.4 closure) |
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
| project-audit | Audit project layout, story well-formedness, trace integrity, ISO/IEC 29110 artefact presence, hook installation, version drift (read-only apart from its audit report) |
| attention-regime | Configure the ISO/IEC 29110 hook surface and install profile-scaled project-side git hooks (per `methodology/iso-29110-hooks-guide.md`) |
| session-journal | Manage cross-session continuity journal |
| document-export | Export work products to docx, pptx, or pdf |
| sysml-toolchain | Choose, install, switch, and run the SysML v2 toolchain (Syside, OMG pilot, OpenSysML), including the automatic fallback when a licence expires |
| test-first | Record whether test first applies (§11.5) in the four places the methodology names, wire the stories' Gherkin features to a scenario runner, and resolve test-first denials, with `superpowers:test-driven-development` governing the cycle where it is installed |

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

The plugin ships fourteen `/vse-*` slash commands as quick entry points. Each command is a thin wrapper that hands off to the named skill.

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
| `/vse-toolchain` | `sysml-toolchain` | Install, switch, or run the SysML v2 toolchain |
| `/vse-test-first` | `test-first` | Record or revisit the test-first judgement, or wire the scenario runner |
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

- **`methodology/`** carries the canonical methodology specification (§0 through §11, twelve section files, plus the ISO/IEC 29110 hooks guide). Shipped to every project that adopts the plugin, so the project carries its own copy and may modify the process locally.
- **`wiki/pages/<layer>/`** holds atomic markdown reference pages, cross-linked with `[[wikilinks]]`. Each reference-bearing skill carries a generated routing table naming the pages it is expected to need (title, path, and a one-line read-when trigger) and reads those pages on demand with the Read tool, one page at a time. Nothing is concatenated and nothing is front-loaded. `wiki/INDEX.md` is the generated catalogue for anything a routing table does not cover.
- **`templates/`** holds work-product templates copied into user projects by `project-setup`.

See `wiki/INDEX.md` for the page catalogue and totals (172 atomic pages across 13 layers, routed to by 24 skills at the 5.0.0 release) and `wiki/CLAUDE.md` for the authoring schema.

## Sources

Knowledge is extracted from these sources, consulted in priority order:

1. **The plugin's own methodology specification** at `methodology/00-methodology-overview.md` through `methodology/11-behaviour-and-test-driven-development.md` plus `methodology/iso-29110-hooks-guide.md`. When a project carries its own copy at `<project>/methodology/`, that copy wins.
2. **ISO/IEC TR 29110-5-6-2:2014**, the Systems Engineering Profile for VSEs. ISO/IEC 29110-5-6-2 is at FDIS stage and is expected to be published as an international standard in 2026.
3. **PHAS-EAI framework**: Georgsen (2026) doctoral thesis, Georgsen (2023) on LLM peer review in VSE engineering, and Georgsen (2026) on guiding attention in purposeful human activity systems.
4. **Galinier et al.** on SME engineering practices.
5. **INCOSE SE Handbook 4e**, scaled for VSEs.
6. **AMBSE source methodology**: Douglass (2016) *Agile Systems Engineering* and Douglass (2021) *Agile MBSE Cookbook*. The plugin's methodology adapts the source arc per §0.4 of the spec. Where it disagrees, the spec wins.
7. **The Weilkiens methodology family**: *SYSMOD* 3rd edition (Base Architecture and System Context concepts adopted in §2 and §3), *Variant Modeling with SysML* (VAMOS), and *The New Engineering Game*.
8. **SysML 2.0**: the OMG specification, *The SysML v2 Book* (Weilkiens and Molnár, 2026-07 release), and toolchain notes (Syside, the OMG pilot, OpenSysML).
9. **Domain guides**: INCOSE Needs and Requirements, Verification and Validation, and the HSI Primer.

Source PDFs are private (gitignored) and not distributed with the plugin. Every wiki page carries a citation that stands on its own.

## Tooling

The plugin supports three SysML v2 toolchains. A project records its choice as `sysml_toolchain` in `.iso-config.yaml` (`syside`, `omg-pilot`, or `opensysml`, absent means `syside`), `/vse-setup` asks once, and `/vse-toolchain` installs or switches later. When the recorded tool is missing or its licence has expired, the pre-commit lint gate falls back in the fixed order Syside, then the OMG pilot, then OpenSysML, prints a notice, and keeps the recorded preference until the engineer changes it.

| Toolchain | Licence | Install | Validate | Format | Language server |
|---|---|---|---|---|---|
| [Sensmetry Syside](https://sensmetry.com) 0.10.3 | Proprietary, the Editor is free and the `syside` CLI needs a Solo or Business plan | `pip install syside` (Automator), Syside Editor from the VS Code marketplace | `syside check --warnings-as-errors` | `syside format` | `syside lsp` |
| [OMG SysML v2 Pilot Implementation](https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation) 2026-07 | EPL-2.0 | Java 21 plus the `jupyter-sysml-kernel-0.61.0.zip` release asset unpacked under `~/.local/share/sysml-pilot` | `SysMLInteractive` in batch, verdict parsed from stdout | none | none |
| [OpenSysML](https://github.com/Open-MBEE/OpenSysML) v0.6.0 | Apache-2.0 | Release tarball into `~/.local/bin`, `brew install Open-MBEE/tap/opensysml`, or `go install github.com/Open-MBEE/OpenSysML/cmd/sysml@v0.6.0` | `sysml -validate -strict` | none | `sysml-lsp` |

Sysand (open source, v0.2.0) handles SysML v2 package management under every toolchain. `syside.toml` configures Syside, `.lsp.json` wires the language server of the recorded toolchain (Syside or OpenSysML), and the OMG pilot has no editor integration. The archived `sysml-2ls` language server is not supported. See the pages under `wiki/pages/tooling/` for installation, exit contracts, and the forms the reference implementations enforce.

### Automator capabilities

The Syside Automator (part of the Pro Suite, `pip install syside`, Python 3.12+) enables programmatic workflows that the extensions alone cannot provide: requirements round-trip with spreadsheets, semantic trace checking over `satisfy` and `verify` links, value rollup with unit conversion, variant analysis, report generation, state machine simulation, and interactive model exploration. See the pages under `wiki/pages/tooling/` for the API surface the plugin's skills rely on. `traceability-guard` and `document-export` fall back to grep-based and pandoc-based procedures when the Automator is absent.

## Getting started

### Prerequisites

- [Claude Code](https://claude.com/claude-code) CLI installed.
- One SysML v2 toolchain: Syside (Editor for editing, Pro Suite for the `syside` CLI), the OMG SysML v2 Pilot Implementation (needs a Java 21 runtime, a headless JRE suffices), or OpenSysML (a static binary). `/vse-toolchain` detects what is missing and shows the install commands.
- Python 3 (3.8 or later, standard library only). It runs the story lint that the commit-time Gherkin gate calls, the renderers that write `docs/generated/`, and the lifecycle hooks' fallback reader. Without it, a commit that touches a story or a feature file is refused at the `precommit_gherkin` disposition (block by default), because the lint cannot run.
- `jq` (recommended). The lifecycle hooks read their JSON payload with it and fall back to `python3`, which also builds the post-edit image (the file as it would read after the edit) when `jq` is older than 1.6. With neither, the in-session gates let every edit through with a notice, and the commit-time and CI gates remain the backstop.
- (Optional) Syside Pro Suite for diagrams, formatting, and the Automator Python API (`pip install syside`, Python 3.12+).

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
/plugin install vse-systems-engineering@vse-systems-engineering
```

After adding the marketplace, you might need to restart Claude Code so it discovers the new source. Then install the plugin.

### Hooks

The plugin ships an ISO/IEC 29110 hook surface across two layers, specified in `methodology/iso-29110-hooks-guide.md`:

- **Lifecycle hooks** (registered in the plugin's `hooks.json`, run by the Claude Code harness): `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `PreCompact`, `Notification`. They locate a project through its `.iso-config.yaml`, inject project status including the rigour profile and the behaviour-first and test-first policy, surface the §2.6 rule 7 reverse-engineering guard, and prompt for V&V or ADR follow-up. `PreToolUse` (matcher `Edit|Write|MultiEdit|NotebookEdit`) carries the two in-session gates of methodology §11.9. It denies an edit that adds or changes a story whose `<StoryIdentifier>.feature` is missing or lacks the story's tag, and, where test first applies, an edit to a code path while no test path has changed. The deny reason says what to write first. It also asks the human to confirm an edit that changes `gate_overrides` or `test_first`. `PostToolUse`, `Stop` and `SubagentStop` speak through one JSON object, `additionalContext` for the agent and `systemMessage` for the human, because their plain output never reaches the agent. Only `PreToolUse` denies, and it does so from the plugin update onwards, with no reinstall.
- **Project-side git hooks** (installed into a user project under `<project>/.githooks/` by the `attention-regime` skill, activated with `git config core.hooksPath .githooks`): `pre-commit`, `commit-msg`, `prepare-commit-msg`, `post-merge`, `post-checkout`, the `pre-commit-traceability` delegate the pre-commit hook invokes, and the shared `lib/iso-profile.sh`, `lib/sysml-toolchain.sh` and `lib/test-first.sh`, beside the story lint under `tools/lint/`. They cover SysML lint (through the recorded toolchain, with automatic fallback), story well-formedness, Gherkin conformance and test before code (§11.9) for the stories and paths a change touches, conventional-commit patterns, baselined-artefact protection, and traceability on touched requirements. `pre-commit`, its delegate, the three libraries, `tools/lint/` and the CI workflow install at every profile, `light` included, because they carry the two commit-time gates of §11. Which other hooks an install copies, and whether each gate blocks, warns, informs, or stays off, is a function of the project rigour profile per §0.10.4 of the methodology and §3.4 of the hooks guide. No local `pre-push` hook ships: those obligations are continuous-integration contracts documented in §4.4 of the hooks guide. The CI workflow runs `pre-commit` over the range a pull request or a push brings, and over every story at a release or baseline tag.

The in-session gates guide an agent and guarantee nothing on their own. A file written through the Bash tool passes unseen, and the `disableAllHooks` setting, a `--bare` session or a disabled plugin switches every lifecycle hook off. The commit-time and CI gates are the backstop (methodology §11.11).

Project-side hook configuration sits in `<project>/.iso-config.yaml` (`project_profile`, `sysml_toolchain`, `gate_overrides`, `test_first`, `baselined_paths`, and the other keys per §8 of the hooks guide). The schema is reproduced in the `attention-regime` skill body.

### Starting a new project

1. Open a fresh project directory in your terminal.
2. Launch Claude Code and invoke `/vse-setup`.
3. The skill enters Plan Mode, asks the rigour-profile question once (`light`, `standard`, or `full`, reversible later), drafts the §8.3 layout (`model/core/{stakeholders, concerns, base-architecture, context, domain, stories/{stakeholder, system}, use-cases, ...}`, `model/variations/`, `methodology/`, `docs/`, etc.), and asks where the engineering work goes. For a fresh project the default is the repo root. Brownfield adoption defaults to an `engineering/` subdirectory, and a custom sub-path is possible in both modes. Under a custom sub-path the configuration stays at the project root, and `tools/lint/` and `tools/render/` are installed beside it as a second copy so that the gates find them. The renderers, and the story lint when it reads the verification and validation cases across the model, look for `model/` or `engineering/model/` from there, so they do not yet find the model under a custom sub-path, and the commit gate can then report a story's cases as missing. That is why `engineering/` is recommended.
4. After Plan Mode approval, the skill scaffolds the directories, copies the methodology spec into the project's `methodology/` folder, writes the profile and its tailoring record, generates the profile-scaled document stubs, and prepares the `.github/`, `.iso-config.yaml`, and `.githooks/` scaffolding. Greenfield mode runs `git init` and an initial commit. Brownfield mode leaves staging to the engineer.
5. From there, route through the orchestration skills:
   - `/vse-story` opens the first stakeholder story branch.
   - `/vse-plan` walks the §10.3 element list to populate `docs/project-plan.md`.
   - `@needs-and-requirements` begins §4 stakeholder elicitation.

### Picking up an existing VSE project

Open the project directory in Claude Code. The `SessionStart` hook locates the project through its `.iso-config.yaml` (or, for older projects, the `methodology/` folder), at the repo root for greenfield or under `engineering/` for brownfield, reads the profile, the current branch, and any open story branches, surfaces the most recent plan-baseline tag and any open Change Requests, states the behaviour-first and test-first policy, and prompts to load `vse-companion-overview` as the first action. A project set up before 5.0.0 follows the migration steps of the 5.0.0 entry in `CHANGELOG.md` first. From there, route through `story-orchestrator`, `release-orchestrator`, and the workflow-stage skills as required.

### Demo walkthrough

The `demo/smart-sensor/` directory contains a worked example: a Wi-Fi-connected environmental sensor with stakeholder and system stories, a resolved trade study, verification and validation cases, and the full ISO/IEC 29110 work-product set at the `standard` profile. It is the plugin's dogfood ground and is kept level with the shipped version by a CI check.

## Versioning

The plugin follows semantic versioning, with the plugin and marketplace manifests bumped in lockstep on every landed change. The current release is **5.0.0**. During a multi-PR train, release candidates accumulate under the `[Unreleased]` heading in `CHANGELOG.md` and the next rc number is assigned at merge time. See `CHANGELOG.md` for the full change history.
