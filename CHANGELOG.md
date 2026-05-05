# Changelog

All notable changes to the vse-systems-engineering plugin will be documented
in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0-rc.7] - 2026-05-05

Phase 5.5 of the v2.0 restructuring. Top-level documentation rewrite
to match the merged Phases 1–5. The README, the `templates/common/CLAUDE.md`
template that ships into user projects, and the contributor-side
`CLAUDE.local.md` (gitignored) are all brought current with the
methodology and the new skill, command, and hook surfaces.

This release is a release candidate. End-user installs should pin to
`1.2.0` until `2.0.0` lands.

### Changed

- `README.md` rewritten:
  - "What it does" reframed around the methodology specification at
    `<plugin>/methodology/` (story-driven AMBSE, the §0.3 connective
    mechanism, the rejection of fixed-length iteration containers).
  - Skills section split into orchestration (5), workflow-stage (4),
    lifecycle (5), and SysML 2.0 specialist (10) groups. The
    decommissioned `iteration-orchestrator` skill is gone. The new
    `story-orchestrator`, `release-orchestrator`, `change-request`,
    `project-plan`, and `sysml2-extension` skills are documented.
  - Slash command table updated: `/vse-nanocycle`, `/vse-microcycle`,
    `/vse-iteration` removed. `/vse-story`, `/vse-release`, `/vse-cr`,
    `/vse-plan` documented.
  - Sources list updated: methodology spec promoted to source 1.
    SYSMOD added as source 6 per §2 and §3 origin.
  - Knowledge base section updated to the current 129 atomic pages
    across 11 layers, 21 bundles. The `methodology` layer is named.
  - Hooks section rewritten to describe the eight Claude Code
    lifecycle hooks and the seven project-side git hooks specified in
    `methodology/iso-29110-hooks-guide.md`.
  - Getting-started section reframed around `/vse-setup` Plan Mode,
    the §8.3 layout, the methodology copy step, and the orchestration
    skills as the post-setup entry points.
  - Demo walkthrough section flagged as currently lagging the v2.0
    restructuring (rebuilt in Phase 6).

- `templates/common/CLAUDE.md` rewritten. The template is what ships
  into user projects via `project-setup`. Replaced cycle vocabulary
  (`vse/iter-NN` branches, three-timeframe AMBSE Vee, centre-of-gravity
  filtering tied to SR.1–SR.6, iteration-boundary closure checklist,
  macrocycle release checklist) with story-centric guidance: the
  methodology-first rule, the three foundational artefacts (§1 stories,
  §2 Base Architecture, §3 System Context), the four workflow stages
  (§4–§7), the §0.3 connective mechanism, the §8.4 branch model, the
  §8.5 PR workflow, the §8.6 review checklists, the routing table,
  and the §8.3 project structure layout. Source order updated to
  promote the project-local `methodology/` folder to position 1.

- `CLAUDE.local.md` (gitignored, contributor-side) updated:
  - Distribution rule lists `methodology/` as a shipped artefact and
    enumerates the project-side hook scripts that
    `attention-regime` installs into user projects under
    `<project>/.githooks/`.
  - Skill authoring conventions: skill count updated from "eleven
    skills" to "nineteen skills" with the new groupings (5
    orchestration + 4 workflow-stage + 5 lifecycle + SysML 2.0
    specialist family).
  - Source-processing order: the plugin's `methodology/` folder is
    now position 1, ahead of ISO 29110. SYSMOD inserted at position
    7 per §2 and §3 adoption. Douglass 2016/2021 reframed as the
    "source arc adapted in §0.4".
  - Hook conventions: eight registered lifecycle events listed
    (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop,
    SubagentStop, PreCompact, Notification), replacing the old
    two-event enumeration.

## [2.0.0-rc.6] - 2026-05-05

Phase 5 of the v2.0 restructuring. The wiki adopts the plugin's
methodology specification. Cycle-centric pages from the AMBSE and
project-structure layers are removed. A new `methodology` layer
summarises §0-§10 of the methodology spec in 16 atomic pages
cross-linked to the spec source. All 21 bundles are regenerated
(17 existing minus 1 decommissioned plus 5 new for the orchestration
skills introduced in PR #35).

This release is a release candidate. End-user installs should pin to
`1.2.0` until `2.0.0` lands.

### Removed

Ten cycle-centric wiki pages superseded by the methodology layer:

- `wiki/pages/ambse/ambse-git-nanocycle-commits.md`
- `wiki/pages/ambse/ambse-git-microcycle-prs.md`
- `wiki/pages/ambse/ambse-git-ci-gates-and-macrocycle.md`
- `wiki/pages/ambse/ambse-git-three-way-mapping.md`
- `wiki/pages/ambse/ambse-git-vse-guidance-and-anti-patterns.md`
- `wiki/pages/ambse/ambse-vee-three-timeframes.md`
- `wiki/pages/ambse/ambse-iteration-planning.md`
- `wiki/pages/ambse/ambse-nanocycle-and-use-case-analysis.md`
- `wiki/pages/project-structure/iteration-boundary-and-macrocycle-closure.md`
- `wiki/pages/project-structure/iteration-centred-operation.md`

The `wiki/bundles/iteration-orchestrator.md` bundle is also removed
(the consuming skill was decommissioned in PR #35).

### Added

New `methodology` layer with 16 atomic pages under
`wiki/pages/methodology/`:

- methodology-overview (§0)
- user-story-canonical-artefact (§1)
- frame-concern-pattern (§1.4.6)
- role-actor-coupling (§1.4.5)
- benefit-as-criterion (§0.3 connective mechanism)
- storymeta-lifecycle (§1.5, §8.7)
- base-architecture-corollaries (§2.1, §2.6 rule 7 reverse-engineering guard)
- system-context-completeness (§3)
- stakeholder-stories-workflow (§4)
- system-stories-workflow (§5)
- architectural-analysis-workflow (§6)
- architectural-design-workflow (§7)
- story-branch-pr-workflow (§8.4-§8.6)
- iso-29110-compliance-mapping (§9)
- project-management-workflow (§10)
- methodology-library-packaging (§0.8 forthcoming)

Five new skill bundles per the orchestration skills introduced in
PR #35:

- `wiki/bundles/story-orchestrator.md`
- `wiki/bundles/release-orchestrator.md`
- `wiki/bundles/change-request.md`
- `wiki/bundles/project-plan.md`
- `wiki/bundles/vse-companion-overview.md`

### Changed

- `wiki/CLAUDE.md` adds the `methodology` layer to the layer table
  with the methodology spec at `<plugin>/methodology/` as its source.
- `wiki/INDEX.md` regenerated. 129 pages indexed across 11 populated
  layers, 21 bundles.
- `wiki/LOG.md` carries a `refactor` entry for the layer addition and
  cycle-page removal.
- `bundled_by` lists across 19 surviving pages: `iteration-orchestrator`
  rewritten to `release-orchestrator`, the closest semantic successor
  for the lifecycle reference role.
- Wikilinks pointing at deleted pages rewritten to point at the
  closest methodology-layer successor (typically
  `[[story-branch-pr-workflow]]` or `[[methodology-overview]]`).

## [2.0.0-rc.5] - 2026-05-05

Phase 4 of the v2.0 restructuring. Adopts the full hook surface
specified in `methodology/iso-29110-hooks-guide.md`. Eight Claude
Code lifecycle hooks (some new, some rewritten) and seven
project-side git hooks (some new, the existing `pre-commit-traceability.sh`
preserved as a delegate of the new `pre-commit.sh`).

This release is a release candidate. End-user installs should pin to
`1.2.0` until `2.0.0` lands. Project-side hooks ship to user projects
via `@attention-regime` (per the v2.0-rc.4 skill) but the install path
is `<project>/.githooks/<hook>` (no `.sh` extension), activated with
`git config core.hooksPath .githooks`. Several `pre-push` checks are
stubs that pass through until the corresponding `tools/lint/` and
`tools/render/` scripts mature in a downstream phase or in user
projects.

### Removed

- `hooks/iteration-boundary-check.sh`. No boundary-check concept in
  the new methodology.
- `hooks/sysml-change-reminder.sh`. Replaced by `hooks/post-tool-use.sh`,
  which covers the same use case under the §5.4 lifecycle hook
  contract.

### Added

Lifecycle hooks (registered in `hooks.json`, run by the harness):

- `hooks/user-prompt-submit.sh` (UserPromptSubmit, §5.2). Reverse-engineering
  guard, baselined-edit reminder, meeting-record reminder.
- `hooks/pre-tool-use.sh` (PreToolUse on `Edit|Write|NotebookEdit`,
  §5.3). Surfaces an advisory reminder when a baselined artefact
  is being edited (per `.iso-config.yaml` `baselined_paths`). The
  firm gate lives in `commit-msg.sh`. The hook is advisory because
  the open-CR heuristic is too coarse for a hard block without
  false positives.
- `hooks/post-tool-use.sh` (PostToolUse on `Edit|Write|NotebookEdit`,
  §5.4).
  Post-edit reminders for stories, concerns, architecture, Project
  Plan.
- `hooks/stop.sh` (Stop, §5.5). ADR / V&V capture prompts.
- `hooks/subagent-stop.sh` (SubagentStop, §5.6). Marker for subagent
  completion in VSE project context.
- `hooks/pre-compact.sh` (PreCompact, §5.7). Snapshots ISO state
  before context compaction.
- `hooks/notification.sh` (Notification, §5.8). Stale Change Request
  reminders.

Project-side scripts (shipped, installed by `@attention-regime`):

- `hooks/pre-commit.sh` (§4.1). Orchestrates three checks: SysML
  lint, story well-formedness, and traceability integrity (the
  last delegated to existing `pre-commit-traceability.sh`).
  Baselined-artefact awareness is surfaced as an advisory reminder
  here. The firm CR-reference gate lives in `commit-msg.sh`.
- `hooks/commit-msg.sh` (§4.2). Enforces the conventional-commit
  pattern with story scope, CR reference, or meeting-record format.
  Additionally, when staged files include any baselined path, the
  hook requires the message to reference an open Change Request.
- `hooks/prepare-commit-msg.sh` (§4.3). Prepopulates commit subject
  with the Story ID inferred from the branch name.
- `hooks/pre-push.sh` (§4.4). Story-state, V&V coverage, traceability
  freshness, baseline integrity. Stub passthroughs in v2.0-rc.5.
- `hooks/post-merge.sh` (§4.5). Regenerates model-derived artefacts
  on `main` advance via configured renderers.
- `hooks/post-checkout.sh` (§4.6). Branch-status surfacing.

Configuration:

- `templates/iso-config/.iso-config.yaml`. Project-side configuration
  consumed by the project-side hooks. Schema per §8 of the hooks
  guide. Includes baselined paths, protected branches, StoryMeta
  schema, risk register, change request, and renderers.

### Changed

- `hooks/session-start.sh` rewritten. Three-mode detection (plugin
  contributor / VSE project / SysML-only repo). For VSE projects,
  surfaces story branches, plan baseline tag, last release tag,
  open Change Requests, and the §5.1 reminder block including the
  §2.6 rule 7 reverse-engineering guard. The methodology copy is
  detected at `methodology/` (greenfield) or `engineering/methodology/`
  (brownfield). The legacy `.vse-iteration.yml` parsing is removed.
- `hooks.json` updated to register all eight lifecycle hooks.
  `source-added-reminder.sh` is preserved as a sibling on PostToolUse
  for the wiki contributor pipeline.
- `hooks/README.md` rewritten to document the new hook split and
  the install procedure. Mentions which v1.x scripts have been
  removed.

## [2.0.0-rc.4] - 2026-05-05

Phase 3C of the v2.0 restructuring. Rewrites the three lifecycle skills
around the new methodology layout. Phase 3 is now complete, ten skills
modified across three sub-PRs.

This release is a release candidate. End-user installs should pin to
`1.2.0` until `2.0.0` lands. Until Phase 7 lands, the templates that
`project-setup` references (`templates/CONTRIBUTING.md`,
`templates/github/CODEOWNERS`, `templates/iso-config/.iso-config.yaml`,
`templates/common/models/core/core.sysml`, the Phase 7 risk-register
and cm-strategy templates) do not yet exist. The skill describes the
target file paths but the actual scaffolding will fail until Phase 7
provides them. End users will see this as a missing-file error if they
run `/vse-setup` between this release candidate and Phase 7.

### Changed

- `skills/project-setup/SKILL.md` rewritten around the methodology
  layout. The flat-tier vs canonical-tier choice is dropped (§8.3
  specifies one canonical layout). The `.vse-iteration.yml` and
  `.vse-journal.yml` files are no longer scaffolded (project state
  lives in git per §8.7). Brownfield-prompt-on-run defaults to
  `engineering/` subdirectory (rationale: SysML modelling work stays
  separate from implementation code), with override to repo root or
  custom subdirectory. The skill copies
  `${CLAUDE_PLUGIN_ROOT}/methodology/` to
  `<project>/methodology/` so the methodology travels with the
  project. Plan Mode entry preserved before any file system change.
- `skills/project-audit/SKILL.md` rewritten as a read-only audit of
  the methodology layout (§8.3), methodology presence, branch model
  (§8.4), baseline state (`plan-baseline-*` and `release-*` tags),
  story well-formedness (§1.9), Base Architecture forward-going rule
  (§2.6 rule 5), reverse-engineering guard (§2.6 rule 7), System
  Context completeness (§3.6), concern and story coverage, V&V
  coverage, trace integrity (with `vse-traceability-matrix-builder`
  subagent dispatch), ISO 29110 artefact presence, version drift,
  and hook installation. Reports findings, never edits.
- `skills/attention-regime/SKILL.md` rewritten around the new hook
  surface. Eight Claude Code lifecycle hooks (SessionStart,
  UserPromptSubmit, PreToolUse, PostToolUse, Stop, SubagentStop,
  PreCompact, Notification) and seven project-side git hooks
  (pre-commit, commit-msg, prepare-commit-msg, pre-push, post-merge,
  post-checkout, post-receive on the server). Carries an explicit
  TODO marker for Phase 4 hook-script delivery. Schema for
  `.iso-config.yaml` reproduced from the hooks guide §8.

## [2.0.0-rc.3] - 2026-05-05

Phase 3B of the v2.0 restructuring. Rewrites the three workflow-stage
skills around the new methodology. Each is reframed in terms of the
methodology section it owns and the specific subagent dispatches it
performs, and uses the canonical `model/core/` path layout from §8.3.

This release is a release candidate. End-user installs should pin to
`1.2.0` until `2.0.0` lands.

### Changed

- `skills/needs-and-requirements/SKILL.md` rewritten around §1
  (UserStory authoring discipline), §3.6 (System Context completeness
  check), §4 (Stakeholder Requirements Engineering), and §5 (System
  Requirements Definition and Analysis). The §0.3 connective mechanism
  (benefit constraints feed §6 trade studies) is surfaced under
  Workflow B Step 2 with formalisation guidance per §5.4.2. The
  `vse-stakeholder-elicitor` subagent dispatch is preserved with a
  clear return contract.
- `skills/architecture-design/SKILL.md` rewritten around §2 Base
  Architecture authoring (§2.6 well-formedness checklist including the
  reverse-engineering guard), §6 Architectural Analysis and Trade
  Studies (criteria sourced from story benefit constraints, candidates
  modelled as `variation`/`variant`), and §7 Architectural Design
  (subsystem decomposition, allocation patterns, recursive component
  nesting per §8.3.2). The `vse-trade-study-runner` subagent dispatch
  is preserved.
- `skills/verification-validation/SKILL.md` updated to align with §4.3.6
  validation cases (exercise stakeholder intent), §5.4.6 verification
  cases (exercise the system model), §7.3.7–§7.3.8 subsystem V&V, and
  §9.8 model-derived IVV Plan and IVV Procedures rendering. The
  coverage-check workflow surfaces gaps before release baseline.

## [2.0.0-rc.2] - 2026-05-05

Phase 3A of the v2.0 restructuring. Decommissions the
`iteration-orchestrator` skill and adds five orchestration skills
that bind to the commands shipped in `2.0.0-rc.1`. The lens skill
`vse-companion-overview` is rewritten to drop the AMBSE Vee
three-timeframes framing and adopt story-centric routing.

This release is a release candidate. End-user installs should pin
to `1.2.0` until `2.0.0` lands.

### Removed

- `skills/iteration-orchestrator/`. The methodology has no
  microcycle, nanocycle, or macrocycle concept. The skill's
  centre-of-gravity routing, journal integration, and red-flag
  warnings are salvaged into `story-orchestrator` and
  `release-orchestrator`.

### Added

- `skills/story-orchestrator/`. Opens or advances a single user
  story per §1 and §8.4–§8.5. Bound to `/vse-story`.
- `skills/release-orchestrator/`. Plans, baselines, or reports on
  a release per §10. Bound to `/vse-release`.
- `skills/change-request/`. Authors and processes Change Requests
  per §10.4.2. Bound to `/vse-cr`.
- `skills/project-plan/`. Authors or revises the Project Plan,
  SEMP, Risk Register, CM Strategy, and Disposal Approach per
  §10.3. Bound to `/vse-plan`.

### Changed

- `skills/vse-companion-overview/SKILL.md` rewritten to frame the
  story-driven AMBSE methodology. The AMBSE Vee three-timeframes
  table, centre-of-gravity routing, and `.vse-iteration.yml`
  reference are removed. New content includes story-centric
  routing, the methodology-as-source-of-truth convention, the
  §2.6 rule 7 reverse-engineering guard, and the new drift
  indicators (baselined edits without CR, story branches without
  draft PR, stakeholder stories without framed concerns, system
  stories without derive links, trade studies whose criteria are
  not sourced from story benefits).

## [2.0.0-rc.1] - 2026-05-05

Phase 2 of 8 in the v2.0 restructuring around the user-story-first
AMBSE methodology. The command surface flips from cycle-centric to
story-centric. The three cycle commands are removed. Four new
commands are added as thin wrappers delegating to skills that are
authored in subsequent phases. Until those skills land, invoking
the new commands routes to skill names that do not yet exist. This
phase is intentionally a stub release that makes the new surface
visible to reviewers ahead of the skill rewrite.

This release is a release candidate. End-user installs should pin
to `1.2.0` until `2.0.0` lands.

### Removed

- `/vse-nanocycle` command. The methodology has no commit-scoped
  planning concept. Commits are small and frequent within story
  branches, and a story is the smallest unit of planning.
- `/vse-microcycle` command. The methodology has no iteration
  concept. Work is grouped by story and release, not by
  fixed-length iteration.
- `/vse-iteration` command. Same reason. Closure debt and
  centre-of-gravity routing migrate into the new
  `story-orchestrator` and `release-orchestrator` skills landing
  in Phase 3.

### Added

- `/vse-story` command. Opens or advances a user story per §1 and
  §8.4–§8.5 of the methodology. Delegates to the
  `story-orchestrator` skill (created in Phase 3).
- `/vse-release` command. Plans, baselines, or reports on a
  release per §10. Delegates to the `release-orchestrator` skill
  (created in Phase 3).
- `/vse-cr` command. Opens a Change Request per §10.4.2.
  Delegates to the `change-request` skill (created in Phase 3).
- `/vse-plan` command. Authors or revises the Project Plan per
  §10.3. Delegates to the `project-plan` skill (created in
  Phase 3).

## [1.2.0] - 2026-05-05

Methodology specification ships with the plugin. The
`Methodology/` directory drafted at the repo root (sections §0–§10
plus the ISO/IEC TR 29110‑5‑6‑2 hooks guide) moves into the plugin
tree at `methodology/`. From this version forward, the methodology
is part of every install and is the canonical reference for skill
bodies, hooks, and templates.

This release is non-breaking: no command, skill, or hook surface
changes. Subsequent releases (planned for v2.0.0) restructure the
plugin around the user-story-first AMBSE process the methodology
describes.

### Added

- `methodology/00-methodology-overview.md` through
  `methodology/10-project-management.md`, plus
  `methodology/iso-29110-hooks-guide.md`. Eleven specification
  sections and one companion implementation guide.
- `methodology/README.md` documenting the project-local override
  convention: forthcoming `/vse-setup` work will copy the directory
  to `<project>/methodology/`, and the project-local copy will
  take precedence over the plugin-shipped one. Skill-side
  resolution (project-local first, falling back to the plugin
  copy) is delivered in a later phase.
- New `Methodology Authoring Conventions` section in
  `CLAUDE.local.md` (contributor-side instructions, not shipped to
  installers).

### Changed

- The `Repo Layout` table in `CLAUDE.local.md` now lists
  `methodology/` alongside the other top-level directories that
  ship to installers.

## [1.1.0] - 2026-05-05

Producer/consumer split for SysML 2.0 language extension. The new
`sysml2-extension` skill owns the authoring side of domain libraries
and user-defined keywords. The existing `sysml2-metadata` skill stays
focused on metadata application through the `VSE_Library` catalogue
(`RiskInfo`, `ConfigItem`, `Baseline`, `VariantScope`,
`VerificationScope`). Source: Chapter 41 of "The SysML v2 Book"
(Weilkiens and Molnár, 2026-04 release).

### Added

- New skill `sysml2-extension`. Triggers on declaring `library
  package`, registering user-defined `#keywords` via
  `Metaobjects::SemanticMetadata`, and the three silent-failure
  pitfalls of the keyword mechanism.
- Three new atomic wiki pages under `wiki/pages/sysml2/`:
  - `sysml2-domain-model-libraries` (reference, Ch 41.1, library
    packages, the canonical PBSE example with Function, Platform,
    and FunctionalAllocation, and the "avoid abstract definitions
    in libraries" guidance).
  - `sysml2-user-defined-keywords` (reference, Ch 41.2, the
    `SemanticMetadata` pattern, the meta-cast operator on
    `baseType`, the `#name` syntax, and keyword stacking).
  - `sysml2-extension-gotchas` (pattern, Ch 41.2 pp 295-297, the
    three pitfalls: kind-keyword optionality, `SysML::Type`
    versus `SysML::Usage` in the meta-cast, and the
    `annotatedElement` redefinition for definition-only
    keywords).
- New bundle `wiki/bundles/sysml2-extension.md` (four pages, the
  17th bundle in the wiki).

### Changed

- `wiki/pages/sysml2/sysml2-language-extension.md` retitled to
  "SysML 2.0 Extension: Overview" and rewritten as the hub for the
  three new sibling pages. Type changed from `reference` to
  `concept`. Citation page numbers updated from 265-271 to 291-297
  to match the 2026-04 release of the book. `bundled_by` moved
  from `sysml2-metadata` to `sysml2-extension`.
- `skills/sysml2-metadata/SKILL.md` description trimmed to remove
  "user-defined keywords" so the trigger surface is disjoint from
  `sysml2-extension`. The user-defined-keyword subsection collapsed
  to a three-line routing pointer to `@sysml2-extension`. The
  `SemanticMetadata` row removed from the core-vocabulary table.
  Validation checklist items and the matching red-flag bullet that
  referenced user-defined keywords removed.
- `wiki/bundles/sysml2-metadata.md` regenerated. The bundle now
  groups ten pages (was eleven), no longer including the
  language-extension overview.
- `wiki/INDEX.md` regenerated. Page count 120 to 123. Bundle count
  16 to 17.
- `wiki/LOG.md` carries a `refactor` entry recording the split.

## [1.0.0] - 2026-05-04

The 1.0 release marks the completion of the `knowledge/` to `wiki/`
consolidation. The plugin now has a single reference surface (the
wiki) consumed by all skills via deterministic per-skill bundles.

### Removed

- **`knowledge/` directory deleted in full**: the legacy flat-file
  reference surface has been removed. The directory was migrated
  slice-by-slice across plugin versions 0.16.0 to 0.21.0:
  - 0.16.0 (Phase 1): SysML 2.0 reference set
    (61 atomic pages, 9 bundles)
  - 0.18.0 (Phase 2): ISO/IEC 29110 process backbone and project
    structure (12 pages, 3 bundles)
  - 0.19.0 (Phase 3): PHAS-EAI, HSI, V&V, and INCOSE Needs and
    Requirements (16 pages, 3 bundles)
  - 0.20.0 (Phase 4): AMBSE cluster (20 pages, 1 new bundle for
    architecture-design)
  - 0.21.0 (Phase 5): SySiDE Automator and INCOSE VSE practices
    (11 pages, distributed across 4 existing bundles)
  - 1.0.0 (Phase 6): final cleanup, the directory removed, all
    stale prose references rewritten to atomic-page slugs, and
    documentation updated.

### Changed

- Eight stale `${CLAUDE_PLUGIN_ROOT}/knowledge/...` and
  `knowledge/...` prose references in skill bodies rewritten to
  point at the corresponding atomic-page slugs and bundles in
  `wiki/`. Affected skills: `architecture-design`,
  `needs-and-requirements`, `project-setup`,
  `iteration-orchestrator`, `vse-companion-overview`.
- `skills/vse-wiki-lint/SKILL.md`: the legacy "INFO during
  migration" rule about knowledge files becomes a "WARN if
  references survive after 1.0.0" rule.
- `README.md`: legacy reference-file section replaced with a
  layer-organised summary of the 11 wiki layers and their page
  counts.
- `wiki/CLAUDE.md`: page-sizing section updated to describe the
  consolidated wiki state. The historical migration note removed.
- `CLAUDE.local.md`: repo-layout table updates `knowledge/` to
  `wiki/`, distribution rule updates the directory list, skill
  authoring conventions point at the bundle pattern, and
  knowledge file conventions are removed (replaced by the wiki
  authoring conventions section).

### Documentation

- The knowledge index (`knowledge/INDEX.md`) is removed. The wiki
  catalogue (`wiki/INDEX.md`) is the single navigation surface.

## [0.21.0] - 2026-05-04

### Added

- **Phase 5 of the knowledge/ to wiki/ consolidation**: the two
  remaining knowledge files migrated. Eleven new atomic pages
  across two new layers.
  - **SySiDE Automator reference** (6 pages, 988 lines) under
    `wiki/pages/syside/`: `syside-tooling-overview`,
    `syside-project-configuration`, `syside-core-api`,
    `syside-expression-evaluation`, `syside-model-modification`,
    `syside-vse-workflows`. Distributed into the
    `sysml2-modelling`, `sysml2-metadata`, and `project-setup`
    bundles.
  - **INCOSE VSE practices** (5 pages, 535 lines) under
    `wiki/pages/incose-vse/`: `incose-vse-lifecycle-models`,
    `incose-vse-stakeholder-needs`,
    `incose-vse-requirements-engineering`,
    `incose-vse-architecture-and-vv`,
    `incose-vse-cm-risk-and-scaling`. Distributed into the
    `iteration-orchestrator` bundle.
- New cross-layer wikilinks (per the Phase 3+ rule) connect the
  two new layers into the `iso29110/`, `project-structure/`,
  `ambse/`, `sysml2/`, `vv/`, and `needs-and-reqs/` layers.

### Changed

- Bundles that consume the new pages regenerated:
  - `sysml2-modelling`: now 23 pages, 2,848 lines (+6 SySiDE
    pages).
  - `sysml2-metadata`: now 11 pages, 1,388 lines (+5 SySiDE
    pages).
  - `project-setup`: now 15 pages, 1,809 lines (+3 SySiDE
    pages).
  - `iteration-orchestrator`: now 25 pages, 2,810 lines
    (+5 INCOSE VSE pages).
- Four consuming skills rewired:
  - `skills/sysml2-modelling/SKILL.md`: removed the legacy
    `!cat ${CLAUDE_PLUGIN_ROOT}/knowledge/syside-automator-ref.md`
    block; updated three prose pointers to atomic-page slugs.
  - `skills/sysml2-metadata/SKILL.md`: updated one prose
    pointer to atomic-page slugs.
  - `skills/project-setup/SKILL.md`: updated one prose
    pointer to atomic-page slugs.
  - `skills/iteration-orchestrator/SKILL.md`: removed the legacy
    `!cat ${CLAUDE_PLUGIN_ROOT}/knowledge/incose-vse-practices.md`
    block; updated the section header to describe the merged
    bundle content.
- `knowledge/INDEX.md` rewritten to record migration completion
  through Phase 5 and updated bundle counts.

### Removed

- Legacy knowledge files deleted:
  - `knowledge/syside-automator-ref.md` (604 lines)
  - `knowledge/incose-vse-practices.md` (378 lines)
- The `knowledge/` directory now contains only `INDEX.md` (a
  pointer to the wiki). Deletion of the directory itself is
  scheduled for the 1.0.0 release in Phase 6.

### Chore

- `.gitignore` adds `.obsidian/` so the contributor-side Obsidian
  vault metadata does not leak into the plugin distribution.

## [0.20.0] - 2026-05-04

### Added

- **Phase 4 of the knowledge/ to wiki/ consolidation**: AMBSE
  cluster migrated. 20 new atomic pages under `wiki/pages/ambse/`,
  the largest and most cross-linked layer migration so far.
  Three existing bundles gain AMBSE pages:
  - `wiki/bundles/iteration-orchestrator.md` adds 10 AMBSE pages
    (agile-process + git-workflow), now 20 pages 2318 lines.
  - `wiki/bundles/needs-and-requirements.md` adds 5 AMBSE
    requirements pages, now 13 pages 1717 lines.
  - `wiki/bundles/verification-validation.md` adds 2 AMBSE
    pages (principles + vee-three-timeframes), now 6 pages 960
    lines.
  - `wiki/bundles/architecture-design.md` is created as a new
    bundle (5 AMBSE architecture pages, 590 lines).
- New AMBSE layer pages organised into four clusters:
  - **Agile process** (5): `ambse-principles`,
    `ambse-vee-three-timeframes`, `ambse-iteration-planning`,
    `ambse-risk-and-metrics`, `ambse-iso29110-mapping`.
  - **Requirements** (5): `ambse-requirements-as-models`,
    `ambse-use-case-driven-elicitation`,
    `ambse-system-requirements-derivation`,
    `ambse-nanocycle-and-use-case-analysis`,
    `ambse-dependability-and-traceability`.
  - **Architecture** (5): `ambse-architecture-analysis`,
    `ambse-trade-studies`, `ambse-architectural-design`,
    `ambse-interfaces-and-handoff`,
    `ambse-architecture-vv-and-iso29110`.
  - **Git workflow** (5): `ambse-git-three-way-mapping`,
    `ambse-git-nanocycle-commits`,
    `ambse-git-microcycle-prs`,
    `ambse-git-ci-gates-and-macrocycle`,
    `ambse-git-vse-guidance-and-anti-patterns`.
- Cross-layer wikilinks per the approved plan. AMBSE
  requirements pages link to
  `sysml2-syntax-requirements-and-cases`,
  `sysml2-requirements-semantics`, `sysml2-cases-overview`,
  `sysml2-case-kinds`, `sysml2-actions`, `sysml2-state-machines`,
  `sysml2-special-action-usages`, `needs-vs-requirements`,
  `requirements-elicitation-and-writing`,
  `requirements-traceability-and-attributes`, `hsi-in-requirements`,
  `sysml2-vse-library-metadata`,
  `sysml2-model-cm-and-risks`. AMBSE architecture pages link to
  `sysml2-canonical-model-layout`,
  `sysml2-base-architecture-and-federation`,
  `sysml2-allocations-overview`, `sysml2-syntax-structure`,
  `sysml2-domain-libraries-metadata-analysis`, `vv-definitions`,
  `vv-methods`, `sysml2-case-kinds`. Git-workflow pages link to
  `iteration-boundary-and-macrocycle-closure`, `iso29110-phase-gates`.
  Process pages link to `iso29110-pm-process`, `iso29110-sr-process`,
  `iteration-centred-operation`, `vv-reporting-and-vse-guidance`.

### Changed

- `iteration-orchestrator` skill removes two legacy `!cat`
  lines (ambse-agile-process, ambse-git-workflow). The pages
  now reach the skill via the existing
  `wiki/bundles/iteration-orchestrator.md` embed.
- `verification-validation` skill removes one legacy `!cat`
  line (ambse-agile-process). Two AMBSE pages
  (ambse-principles, ambse-vee-three-timeframes) reach it via
  the existing `wiki/bundles/verification-validation.md`
  embed.
- `needs-and-requirements` skill removes one legacy `!cat`
  line (ambse-requirements). Five AMBSE requirements pages
  reach it via the existing
  `wiki/bundles/needs-and-requirements.md` embed.
- `architecture-design` skill removes one legacy `!cat` line
  (ambse-architecture). Five AMBSE architecture pages reach
  it via the new `wiki/bundles/architecture-design.md` embed.

### Removed

- `knowledge/ambse-agile-process.md` (429 lines, atomised into
  5 pages).
- `knowledge/ambse-requirements.md` (423 lines, atomised into
  5 pages).
- `knowledge/ambse-architecture.md` (396 lines, atomised into
  5 pages).
- `knowledge/ambse-git-workflow.md` (475 lines, atomised into
  5 pages).

### Pending in follow-on PRs

- **Phase 5**: `incose-vse-practices` and `syside-automator-ref`.
- **Phase 6**: Delete `knowledge/` entirely. Bump to 1.0.0.

## [0.19.0] - 2026-05-04

### Added

- **Phase 3 of the knowledge/ to wiki/ consolidation**: PHAS-EAI,
  HSI, V&V, and Needs-and-Requirements migrated. 16 new atomic
  pages across four layers, three new bundles consumed by their
  respective skills:
  - `wiki/bundles/attention-regime.md` (4 PHAS-EAI pages, 462
    lines)
  - `wiki/bundles/needs-and-requirements.md` (8 pages: 5 HSI + 3
    needs-and-reqs, 1104 lines)
  - `wiki/bundles/verification-validation.md` (4 V&V pages, 662
    lines)
- New PHAS-EAI layer pages: `phas-eai-overview` (concept),
  `phas-eai-equations` (reference),
  `phas-eai-de-requirements` (reference),
  `phas-eai-levers-and-evidence` (reference).
- New HSI layer pages: `hsi-foundations` (concept),
  `hsi-domains` (reference), `hsi-in-requirements` (process),
  `hsi-in-architecture` (process), `hsi-vse-tiered-approach`
  (pattern).
- New V&V layer pages: `vv-definitions` (concept),
  `vv-planning` (process), `vv-methods` (reference),
  `vv-reporting-and-vse-guidance` (process).
- New Needs-and-Requirements layer pages:
  `needs-vs-requirements` (concept),
  `requirements-elicitation-and-writing` (process),
  `requirements-traceability-and-attributes` (reference).
- Cross-layer wikilinks land per the approved migration plan.
  Phase 3 examples: V&V definitions and case kinds link to
  `sysml2-cases-overview`, `sysml2-case-kinds`,
  `sysml2-systems-model-library` (VerdictKind),
  `sysml2-syntax-requirements-and-cases`. Needs-and-requirements
  pages link to `sysml2-syntax-requirements-and-cases`,
  `sysml2-requirements-semantics`, `sysml2-cases-overview`,
  `sysml2-vse-library-metadata`,
  `sysml2-domain-libraries-metadata-analysis`. HSI pages link
  to the same SysML 2.0 anchors plus
  `sysml2-canonical-model-layout` and
  `sysml2-allocations-overview`. PHAS-EAI links to
  `iso29110-overview` for the complementarity argument.

### Changed

- `attention-regime` skill replaces its single legacy
  `!cat knowledge/phas-eai-framework.md` with one
  `!cat wiki/bundles/attention-regime.md`.
- `needs-and-requirements` skill replaces two legacy
  `!cat knowledge/...` lines (needs-and-reqs-guide, hsi-primer)
  with one `!cat wiki/bundles/needs-and-requirements.md`. Keeps
  `knowledge/ambse-requirements.md` for Phase 4.
- `verification-validation` skill replaces its single legacy
  `!cat knowledge/vv-guide.md` with one
  `!cat wiki/bundles/verification-validation.md`. Keeps
  `knowledge/ambse-agile-process.md` for Phase 4.

### Removed

- `knowledge/phas-eai-framework.md` (337 lines, atomised into 4
  pages).
- `knowledge/hsi-primer.md` (438 lines, atomised into 5 pages).
- `knowledge/vv-guide.md` (346 lines, atomised into 4 pages).
- `knowledge/needs-and-reqs-guide.md` (277 lines, atomised into
  3 pages).

### Pending in follow-on PRs

- **Phase 4**: AMBSE cluster (`ambse-agile-process`,
  `ambse-requirements`, `ambse-architecture`,
  `ambse-git-workflow`). The largest and most cross-linked.
- **Phase 5**: `syside-automator-ref` and
  `incose-vse-practices`.
- **Phase 6**: Delete `knowledge/` entirely. Bump to 1.0.0.

## [0.18.1] - 2026-05-04

### Fixed

- All 9 SysML 2.0 skills (`sysml2-allocations`, `sysml2-behaviour`,
  `sysml2-cases`, `sysml2-expressions`, `sysml2-metadata`,
  `sysml2-modelling`, `sysml2-model-structure`, `sysml2-variants`,
  `sysml2-views`) carried an unconditional opening line directing
  the model to invoke `vse-companion-overview` "if the VSE lens
  has not been set in this session". After the 0.17.2
  session-start hook gained a SysML-only detection mode for
  repositories without `.vse-iteration.yml`, this directive
  became wrong in that mode: it forced a SysML-only repository to
  load the full VSE lens (ISO 29110 process backbone, AMBSE
  iteration framing, traceability rules) when none of those
  apply. The opening line in each SysML 2.0 skill now reads "If
  you are inside a VSE project (.vse-iteration.yml present) and
  the VSE lens has not been set this session, invoke
  vse-companion-overview first, then continue. In a SysML-only
  repository (no .vse-iteration.yml), skip the lens and proceed
  directly with this skill." This matches the session-start
  hook's three-mode detection (contributor → full VSE → SysML-only
  → silent) and avoids loading the wrong lens for the project
  type.

## [0.18.0] - 2026-05-04

### Added

- **Phase 2 of the knowledge/ to wiki/ consolidation**: process
  backbone migrated. 12 new atomic pages under
  `wiki/pages/iso29110/` (8 pages) and
  `wiki/pages/project-structure/` (4 pages). Three new bundles
  consumed by their respective skills:
  - `wiki/bundles/project-setup.md` (12 pages)
  - `wiki/bundles/iteration-orchestrator.md` (10 pages)
  - `wiki/bundles/project-audit.md` (2 pages)
- New ISO 29110 layer pages: `iso29110-overview` (concept),
  `iso29110-pm-process` (reference), `iso29110-sr-process`
  (reference), `iso29110-roles-and-work-products` (reference),
  `iso29110-phase-gates` (process),
  `iso29110-pm-task-checklists` (process),
  `iso29110-sr-task-checklists` (process),
  `iso29110-template-mapping` (reference).
- New project-structure layer pages:
  `iteration-centred-operation` (concept),
  `iteration-boundary-and-macrocycle-closure` (process),
  `vse-canonical-project-layout` (reference),
  `vse-model-tiers-and-templates` (reference).
- Cross-layer wikilinks added per the approved migration plan.
  Examples: ISO 29110 PM.O6 and SR.O6 link to
  `sysml2-vse-library-metadata`; SR.O2 and SR.2 task list link to
  `sysml2-syntax-requirements-and-cases` and
  `sysml2-requirements-semantics`; SR.3 task list links to
  `sysml2-canonical-model-layout` and
  `sysml2-allocations-overview`; SR.5 and SR.O7 link to
  `sysml2-cases-overview` and `sysml2-case-kinds`;
  vse-model-tiers links to `sysml2-canonical-model-layout` and
  `sysml2-vse-library-metadata`.

### Changed

- `project-setup` skill replaces three legacy `!cat
  knowledge/...` lines (canonical-project-structure,
  iso29110-task-lists, iso29110-profile) with one
  `!cat wiki/bundles/project-setup.md`.
- `iteration-orchestrator` skill replaces two legacy
  `!cat knowledge/...` lines (iteration-centred-operation,
  iso29110-profile) with one
  `!cat wiki/bundles/iteration-orchestrator.md`. The skill keeps
  its other three knowledge embeds (`ambse-agile-process`,
  `ambse-git-workflow`, `incose-vse-practices`), which migrate in
  later phases.
- `project-audit` skill replaces its single legacy
  `!cat knowledge/canonical-project-structure.md` with one
  `!cat wiki/bundles/project-audit.md`.
- `knowledge/INDEX.md` updated. ISO 29110 and Project structure
  rows now point at the migrated bundle catalogue. The remaining
  rows (PHAS-EAI, INCOSE, AMBSE, HSI, SySiDE) cover the 10 files
  awaiting migration in Phases 3 to 5.

### Removed

- `knowledge/iso29110-profile.md` (346 lines, atomised into 5
  pages).
- `knowledge/iso29110-task-lists.md` (340 lines, atomised into 3
  pages).
- `knowledge/iteration-centred-operation.md` (150 lines, atomised
  into 2 pages).
- `knowledge/canonical-project-structure.md` (198 lines, atomised
  into 2 pages).

### Pending in follow-on PRs

- **Phase 3**: `phas-eai-framework`, `hsi-primer`, `vv-guide`,
  `needs-and-reqs-guide`. Skills rewired: `attention-regime`,
  `verification-validation`, `needs-and-requirements`. Required
  cross-layer wikilinks per the approved plan.
- **Phase 4**: AMBSE cluster (`ambse-agile-process`,
  `ambse-requirements`, `ambse-architecture`,
  `ambse-git-workflow`). The largest and most cross-linked.
- **Phase 5**: `syside-automator-ref` and
  `incose-vse-practices`.
- **Phase 6**: Delete the `knowledge/` directory entirely. Run
  `/vse-wiki-refactor` for cross-link consolidation. Bump to
  1.0.0 to mark the consolidation milestone.

## [0.17.2] - 2026-05-04

### Changed

- `hooks/session-start.sh` gains a third detection mode for
  repositories that carry SysML 2.0 content but are not full VSE
  projects under iteration management. Detection priority:
  contributor (wiki/CLAUDE.md present) → full VSE project
  (.vse-iteration.yml present) → SysML-only (any of `syside.toml`,
  `engineering/syside.toml`, `engineering/models/` directory, or a
  `*.sysml` file reachable within four directory levels) → silent.
  In SysML-only mode, the hook emits a lighter banner pointing at
  `@sysml2-modelling` (the umbrella router) and its eight
  specialist siblings, rather than the full VSE lens via
  `vse-companion-overview`. The contributor repo is suppressed
  from this branch because it carries `.sysml` template files that
  would otherwise trip the detection.
- The SySiDE CLI reporter (the block that lists `syside check`,
  `syside format`, and `syside viz` commands) is extracted into a
  shared shell function and called from both the full-VSE branch
  and the new SysML-only branch.

## [0.17.1] - 2026-05-04

### Documentation

- `README.md` Knowledge base section rewritten to reflect the
  Phase 1 SysML 2.0 migration. The legacy list of eleven
  `knowledge/sysml2-*-ref.md` files is replaced by a bundle table
  describing the 61 atomic pages and 9 bundles now under
  `wiki/`. Pointers to `wiki/INDEX.md`, `wiki/CLAUDE.md`, and
  `knowledge/INDEX.md` added.
- `CLAUDE.local.md` Knowledge File Conventions migration note
  updated to record that the SysML 2.0 layer migration completed
  in 0.17.0 (61 pages, 9 bundles), with 14 non-SysML 2.0 files
  remaining for later phases.

## [0.17.0] - 2026-05-04

### Added

- 28 new atomic pages under `wiki/pages/sysml2/`, completing the
  SysML 2.0 layer migration. Each page is 80 to 250 lines and
  cross-linked with Obsidian-style `[[wikilinks]]`. The wiki now
  carries 61 atomic pages, 9 bundles, and 0 lint findings.
- New pages by source family:
  - From `sysml2-metadata-ref` (6 pages): metadata-overview,
    metadata-definitions, reflection-and-classification,
    filter-conditions, language-extension, vse-library-metadata.
  - From `sysml2-libraries-ref` (6 pages): libraries-architecture,
    systems-model-library, domain-libraries-metadata-analysis,
    domain-libraries-causation-geometry, library-import-patterns,
    quantities-and-units.
  - From `sysml2-quick-ref` (5 pages): syntax-packages-and-
    definitions, syntax-features-and-attributes, syntax-structure,
    syntax-behaviour, syntax-requirements-and-cases.
  - From `sysml2-semantics-ref` (6 pages): language-architecture,
    type-hierarchy, specialisation-and-typing, structural-and-
    behavioural-semantics, requirements-semantics, grammar-and-
    validation.
  - From `sysml2-model-structure-ref` (5 pages):
    canonical-model-layout, base-architecture-and-federation,
    namespace-hygiene, variant-organisation, model-cm-and-risks.

### Changed

- `sysml2-modelling` skill now embeds `wiki/bundles/sysml2-modelling.md`
  (17 atomic pages from quick-ref, semantics, and libraries) plus
  the unchanged `knowledge/syside-automator-ref.md`. The legacy
  three-file embed is replaced by one bundle plus one knowledge
  reference.
- `sysml2-metadata` skill now embeds `wiki/bundles/sysml2-metadata.md`
  (6 atomic pages from metadata-ref).
- `sysml2-model-structure` skill now embeds
  `wiki/bundles/sysml2-model-structure.md` (5 atomic pages from
  model-structure-ref).
- `knowledge/INDEX.md` updated: every SysML 2.0 reference file is
  now in the bundle table; only `syside-automator-ref.md` remains
  in the SysML 2.0 row pending its own migration in a later phase.

### Removed

- `knowledge/sysml2-libraries-ref.md` (579 lines, atomised into 6
  pages).
- `knowledge/sysml2-metadata-ref.md` (496 lines, atomised into 6
  pages).
- `knowledge/sysml2-model-structure-ref.md` (599 lines, atomised
  into 5 pages).
- `knowledge/sysml2-quick-ref.md` (600 lines, atomised into 5
  pages).
- `knowledge/sysml2-semantics-ref.md` (601 lines, atomised into 6
  pages).

### Pending in follow-on PRs

- Migration of `knowledge/syside-automator-ref.md` (the last
  remaining SysML 2.0-adjacent file, vendor-specific Python API
  reference).
- Migration of the non-SysML 2.0 knowledge files (Phase 2
  onwards): ISO 29110, AMBSE cluster, PHAS-EAI, INCOSE VSE
  practices, INCOSE V&V, INCOSE Needs and Requirements, HSI,
  iteration-centred-operation, canonical-project-structure.
- Eventual deletion of the `knowledge/` directory once the
  remaining files are atomised.

## [0.16.0] - 2026-05-04

### Added

- 33 atomic pages under `wiki/pages/sysml2/`, each 80 to 200 lines,
  consumed by six rewired SysML 2.0 skills via per-skill bundles
  under `wiki/bundles/`. The pages are interlinked with Obsidian-
  style `[[wikilinks]]`, allowing readers and skill consumers to
  navigate the SysML 2.0 conceptual graph rather than searching a
  flat reference directory.
- Eight new pages capture material added to the 2026-04 release of
  the SysML v2 book (Weilkiens and Molnár): `sysml2-self-and-that`
  (Section 17.3), `sysml2-binding-connectors` (Chapter 21),
  `sysml2-advanced-quantities-units` (Section 24.3),
  `sysml2-occurrences-4d`, `sysml2-portions-and-individuals`,
  `sysml2-temporal-spatial-relations`,
  `sysml2-occurrence-context-and-variables` (Chapter 25), and
  `sysml2-model-execution` (Chapter 39). All cite the new release
  and, where applicable, the OMG formal specification.

### Changed

- The skills `sysml2-variants`, `sysml2-views`, `sysml2-allocations`,
  `sysml2-cases`, `sysml2-behaviour`, and `sysml2-expressions` now
  embed `wiki/bundles/<skill>.md` instead of legacy
  `knowledge/sysml2-*-ref.md` files. Per-skill bundles are
  smaller and topically scoped, reducing the token tax that every
  invocation of these skills used to pay.
- `knowledge/INDEX.md` updated to reflect the migration: SysML 2.0
  files that have been atomised are listed under the bundle table;
  files awaiting migration carry a `pending migration` status.

### Removed

- `knowledge/sysml2-variants-ref.md` (244 lines, atomised into 4
  pages).
- `knowledge/sysml2-views-ref.md` (280 lines, atomised into 4
  pages).
- `knowledge/sysml2-allocations-ref.md` (257 lines, atomised into 3
  pages plus binding-connectors page from new release).
- `knowledge/sysml2-cases-ref.md` (297 lines, atomised into 3 pages).
- `knowledge/sysml2-behaviour-ref.md` (472 lines, atomised into 6
  pages plus 6 new chapter pages).
- `knowledge/sysml2-expressions-ref.md` (465 lines, atomised into 5
  pages plus advanced-quantities-units page from new release).

### Pending in follow-on PRs

- Migration of `knowledge/sysml2-quick-ref.md`,
  `sysml2-semantics-ref.md`, `sysml2-libraries-ref.md`,
  `sysml2-metadata-ref.md`, and `sysml2-model-structure-ref.md`.
- Migration of the non-SysML 2.0 knowledge files (ISO 29110, AMBSE,
  PHAS-EAI, INCOSE, HSI, V&V, needs-and-requirements, syside-
  automator, project structure).

## [0.15.0] - 2026-04-16

### Added

- Wiki subsystem scaffolding under `wiki/`, adapting Karpathy's LLM
  Wiki pattern for the VSE knowledge base. Atomic markdown pages are
  authored and maintained from raw sources in the gitignored
  `sources/` directory, then concatenated into per-skill bundles under
  `wiki/bundles/` which skills embed at load time. Runtime behaviour
  is unchanged: skills continue to front-load reference material via
  `!cat ${CLAUDE_PLUGIN_ROOT}/...` at skill-load time.
- `wiki/CLAUDE.md`: schema document that governs directory layout,
  layer taxonomy, frontmatter contract, wikilink convention, LOG.md
  prefixes, and page sizing. Single source of truth for wiki
  operations. Read first by every wiki skill and subagent.
- `wiki/schema/`: five page-type templates (reference, concept,
  process, pattern, glossary) used by `vse-wiki-lint` to detect
  schema drift.
- `wiki/INDEX.md`, `wiki/LOG.md`: auto-maintained catalogue and
  append-only activity record with parseable headings
  (`source-added`, `ingest`, `refactor`, `lint`, `bundle`).
- Four contributor-facing skills with slash-command wrappers:
  `vse-wiki-ingest` (process a source into atomic pages),
  `vse-wiki-lint` (read-only health check), `vse-wiki-refactor`
  (periodic full-wiki audit), `vse-wiki-bundle` (deterministic
  regeneration of per-skill bundles and the index).
- Two read-only subagents that preserve the suggestion-shaped
  contract used elsewhere in the plugin: `vse-wiki-ingestor`
  (dispatched by `vse-wiki-ingest`) and `vse-wiki-curator`
  (dispatched by `vse-wiki-refactor`).
- `hooks/source-added-reminder.sh`: PostToolUse hook that emits a
  reminder to run `/vse-wiki-ingest` when a file under `sources/` is
  written or edited, and appends an unresolved `source-added` stub to
  `wiki/LOG.md` for tracking. Only fires inside the plugin repo.
- `hooks/session-start.sh`: wiki-freshness output (days since last
  LOG.md entry, unresolved stub count, LINT_REPORT finding count)
  emitted before the VSE lens banner, gated on `wiki/CLAUDE.md`
  presence so end-user projects remain unaffected.
- `.gitignore`: `wiki/LINT_REPORT.md` excluded from commits.

### Changed

- `hooks.json`: `PostToolUse` entry under matcher `Write|Edit` now
  registers `source-added-reminder.sh` alongside the existing
  `sysml-change-reminder.sh`.

## [0.14.1] - 2026-04-09

### Fixed

- SysML model templates now contain structural content (part usages,
  ports, connections, behaviour, state machines) instead of empty
  definition-only stubs. Affected templates: arch-design, interfaces,
  functional-analysis, configurations, actors, arch-analysis.
- `sysml2-model-structure` validation checklist: added item 11 requiring
  that every `:>>` redefinition in Configurations targets a part declared
  as `variation part`, not a regular part. Added corresponding red flag.
- `sysml2-variants` validation checklist: added item 6 for reverse
  binding validation (configuration targets must be variation parts).
  Added corresponding red flag.

### Changed

- README.md: skills table expanded from 11 to 20 entries (12 core
  workflow, 8 SysML 2.0 specialist). Added `/vse-audit` command.
  Knowledge file count updated from 15 to 25.

### Added

- `.github/workflows/plugin-ci.yml`: CI workflow for PRs with JSON
  validation, version consistency, shellcheck, skill structure, and
  cross-reference checks.
- `Makefile` with `validate`, `lint`, `check-versions`, `check-skills`,
  `check-refs`, and `all` targets for pre-PR validation.
- `knowledge/INDEX.md`: categorised index of all 25 knowledge files
  with topic summaries and consuming skill cross-references.

### Documentation

- `dev_docs/testing-guide.md` updated for 20 skills, current `/plugin`
  install commands, subagent testing procedures, and hook testing
  procedures.

## [0.14.0] - 2026-04-09

### Added

- `project-audit` skill and `/vse-audit` command: read-only audit of
  existing VSE projects against the canonical structure. Reports findings
  at four severity levels (CRITICAL, OUTDATED, NON-CANONICAL, OPTIONAL)
  and optionally produces a remediation plan. Targets projects set up
  with older plugin versions that may have drifted from the current
  canonical layout.
- `knowledge/canonical-project-structure.md`: shared knowledge file
  defining the authoritative VSE project layout. Embedded by both
  `project-setup` and `project-audit` to keep structural definitions
  in sync.
- Package-per-directory model layout: each AMBSE top-level package now
  lives in its own directory containing the package definition file and
  a co-located SysML 2.0 view file (viewpoint + view satisfying it with
  an appropriate standard view type). Applies to Minimal and Canonical
  tiers. Flat tier retains the legacy 6-file flat layout.
- Per-package view templates for all 13 packages: actors (General View),
  stakeholder-needs (Grid View), use-cases (General View), requirements
  (Grid View), arch-design (Interconnection View), interfaces
  (Interconnection View), verification (Grid View), risks (Grid View),
  functional-analysis (Action Flow View), arch-analysis (Grid View),
  configurations (Grid View), base-architecture (Interconnection View),
  cm (Grid View).
- Cross-cutting `traceability-view.sysml` at models root: Grid View
  spanning requirements and verification packages to surface trace gaps.

### Changed

- `@project-setup`: default tier changed from Minimal AMBSE to
  **Canonical AMBSE with variant modelling**. Minimal is available as
  an opt-down. The Canonical tier now includes `configurations/` by
  default because variant-awareness is a standard modelling practice.
- `@project-setup`: brownfield centre-of-gravity detection rewritten
  to use an observation-first approach. Findings are presented as
  numbered observations with verification questions, not as assertions.
  The user chooses the centre of gravity from a menu rather than the
  skill proposing one.
- `@project-setup`: brownfield harvest now explicitly warns that
  harvested context (source comments, README descriptions) may be stale
  or aspirational. Values from source comments are marked
  "[from source comment, verify]".
- `@project-setup`: seeded system-design.md content in brownfield mode
  now carries an explicit caveat that it is raw observational input, not
  a validated architectural description.
- Model template files restructured from flat layout to
  package-per-directory layout under `templates/common/models/`.

## [0.13.0] - 2026-04-09

### Added

- `templates/common/library/vse-library.sysml`: shipped VSE Library
  package (`VSE_Library`) containing all reusable metadata definitions
  and enumerations. Centralises `RiskInfo`, `ConfigItem`, `Baseline`,
  `Severity`, `Likelihood`, `RiskStatus`, `CIState` (previously
  declared inline per project) plus two new variant-aware metadata
  definitions: `VariantScope` (tags any element with its target
  configurations) and `VerificationScope` (tags verification cases
  with their target configurations). User projects import from
  `VSE_Library` rather than redeclaring definitions.
- `@sysml2-metadata` skill gains a "Variant-Aware Metadata" section
  with worked examples for `@VariantScope` and `@VerificationScope`,
  including 29110 activity mapping and Automator query recipes.
- `knowledge/sysml2-metadata-ref.md` gains Section 10A documenting
  the VSE Library as the canonical definition site, variant-aware
  metadata semantics, and the variant-scoping rule for 29110 products.

### Changed

- `@sysml2-metadata` skill: all worked examples and query recipes now
  reference `VSE_Library::RiskInfo` and `VSE_Library::ConfigItem`
  instead of `Metadata::RiskInfo` and `Metadata::ConfigItem`. A
  migration note at the top guides existing projects.
- `@project-setup` skill: Minimal and Canonical tiers always copy the
  VSE Library into `models/library/vse-library.sysml`. Variant-awareness
  is now documented as an orthogonal dimension available from Minimal
  tier upward (not locked to Canonical). Minimal tier gains a
  variant-awareness opt-in (`configurations.sysml`). Canonical tier
  Variants opt-in enriched with cross-package activation guidance.

## [0.12.0] - 2026-04-08

### Added

- Seven new focused SysML 2.0 sibling skills, each embedding a single
  topic knowledge file. The harness now routes activation to the
  narrowest relevant skill rather than loading the full umbrella for
  every SysML question.
  - `sysml2-expressions`: calc definitions, constraint bodies,
    sequence operations, and classification expressions.
  - `sysml2-behaviour`: actions, successions, control nodes, state
    machines, flows, and messages.
  - `sysml2-cases`: use, analysis, and verification cases with
    subject/actor/objective framing.
  - `sysml2-views`: viewpoints, views, expose statements, filters,
    and the eight standard views catalogue.
  - `sysml2-allocations`: allocation definitions, directional
    allocation usages, cross-subsetting, and nested refinement.
  - `sysml2-variants`: variation definitions, variant membership,
    configuration constraints, and concrete product specialisation.
  - `sysml2-metadata`: metadata definitions, reflection,
    metaclassification, smart-package filters, user-defined keywords,
    and the Risks metadata library.
- Seven new knowledge files under `knowledge/`, all paraphrased from
  Weilkiens and Molnár, *The SysML v2 Book* (MBSE4U, 2026-03 release),
  with chapter and page citations inline. The source is commercial
  and remains gitignored. Every file carries an attribution line.
  - `sysml2-expressions-ref.md` (Ch 27, 30, 31, 59, 86)
  - `sysml2-behaviour-ref.md` (Ch 26, 28, 29, 39)
  - `sysml2-cases-ref.md` (Ch 33)
  - `sysml2-views-ref.md` (Ch 13, 37)
  - `sysml2-allocations-ref.md` (Ch 34, 41)
  - `sysml2-variants-ref.md` (Ch 35)
  - `sysml2-metadata-ref.md` (Ch 36, 38, 41)
- `knowledge/sysml2-libraries-ref.md` extended with Ch 24 ISQ
  quantities and units coverage.
- `knowledge/sysml2-model-structure-ref.md` codifying the AMBSE
  canonical model layout from Douglass 2016 Fig 3.13 and Douglass
  2021 Cookbook Fig 1.35, with base-architecture reuse drawn from
  Ch 14 of *The SysML v2 Book*, federation (SE model plus Shared
  model plus Subsystem models) drawn from Douglass 2016 Fig 8.4,
  namespace hygiene drawn from Ch 15-16, risk modelling, variant
  modelling organisation adapted from Weilkiens *Variant Modeling
  with SysML* (MBSE4U 2016, VAMOS) to SysML 2.0, and model-level
  configuration management grounded in ISO/IEC 29110 PM.1.13 and
  PM.2.5. Every section carries chapter and page citations.
- `skills/sysml2-model-structure/` sibling skill that teaches the
  AMBSE canonical layout, the Ch 14 `:>` and `:>>` specialisation
  pattern, the federation pattern, the risk register pattern, the
  VAMOS-derived variant configurations pattern, and the model-level
  configuration management pattern. Cross-references
  `@sysml2-variants` for Ch 35 syntax and `@sysml2-metadata` for the
  `RiskInfo`, `ConfigItem`, and `Baseline` metadata libraries.
- Fourteen AMBSE canonical model starter templates under
  `templates/common/models/`. Ten mandatory top-level packages
  (`actors.sysml`, `stakeholder-needs.sysml`, `use-cases.sysml`,
  `requirements.sysml`, `functional-analysis.sysml`,
  `arch-analysis.sysml`, `arch-design.sysml`, `interfaces.sysml`,
  `verification.sysml`, `risks.sysml`) plus a root overview file
  (`model-overview.sysml`) and three optional packages
  (`base-architecture.sysml`, `configurations.sysml`, `cm.sysml`).
  Every file uses `private import` with named imports from the first
  commit, carries short-code prefix placeholders, and is heavily
  commented with citations.
- `{{sc}}_Risks` package and `RiskInfo` metadata pattern as a
  first-class data model for ISO/IEC 29110 PM.O5, PM.1.11, PM.2.3,
  and PM.3.1 risk management.
- `{{sc}}_Configurations` optional package as the VAMOS-derived home
  for concrete variant configurations, with variation definitions
  staying inline in the owning AMBSE package per SysML 2.0 Ch 35.
- `{{sc}}_CM` optional package as the model-level complement to the
  Project Plan Section 9 Configuration Management Strategy
  (PM.1.13), holding `Baseline` item defs and the CI surface that
  `@traceability-guard` checks at iteration-boundary closure.
- `sysml2-metadata` skill extended with a Risk Library section
  covering the `RiskInfo` metadata def, application examples, an
  Automator high-severity risk query, and a Configuration Management
  Library section covering `ConfigItem` and `Baseline` metadata
  defs, application examples, and an Automator CI-by-baseline query.
- AMBSE workflow routing fan-out from `iteration-orchestrator`,
  `needs-and-requirements`, `architecture-design`,
  `verification-validation`, `traceability-guard`, and
  `vse-companion-overview` to all eight SysML 2.0 siblings including
  `sysml2-model-structure`, with variant-, CM-, and risk-specific
  routing. The iteration-boundary closure check surfaces advisory
  CI-and-baseline and risk-status refresh items.

### Changed

- `skills/sysml2-modelling/SKILL.md` slimmed from ~500 lines into a
  router and tooling workbench. The umbrella keeps project layout,
  SySiDE CLI and Automator sections, model validation, model
  navigation, and the traceability link summary, and adds a routing
  table that names each sibling and the trigger situation. Inline
  authoring patterns for requirements, parts, ports, verification
  cases, actions, and states have moved to the corresponding siblings.
  Project Template subsequently replaced with the AMBSE canonical
  ten-package layout from Douglass 2016 Fig 3.13 and Cookbook 2021
  Fig 1.35, with three optional packages and an eighth sibling routing
  row for `sysml2-model-structure`. The umbrella continues to own
  project layout, tooling, CI validation, and the high-level quick
  reference.
- `skills/vse-companion-overview/SKILL.md` cross-cutting skill table
  now lists every SysML 2.0 sibling alongside the umbrella.
- `skills/project-setup/SKILL.md` Step 6 now reads starter files
  from `templates/common/models/*.sysml` instead of inline heredocs
  and offers three scaffolding tiers: Flat (legacy five-package,
  retained for the smart-sensor demo), Minimal AMBSE (nine files,
  default for new greenfield projects), and Canonical AMBSE (eleven
  mandatory files with three independent opt-ins for base
  architecture, variants, and CM, giving 11, 12, 13, or 14 total
  files). Step 1 gathers a project short code, Step 5 substitutes
  `{{PROJECT_SHORT_CODE}}` in every copied file.

### Pending (follow-up)

- Dedicated `risk-management` workflow skill covering the full
  identify-assess-mitigate-monitor loop.
- Dedicated `cm-workflow` skill covering the full identify-baseline-
  change-retire loop.
- Automated scaffolding of federated Shared and Subsystem models in
  `project-setup`. Federation remains manual for now.
- Variant interface matrix Automator recipe from VAMOS Ch 3.6.
- PLEML feature-model integration.
- Library packaging for redistributable base architectures.

## [0.10.0] - 2026-04-07

### Changed

- **Plugin is now centred on AMBSE cycles, not ISO/IEC 29110 phases.**
  The routing backbone, the per-project state file, and every user-visible
  surface have been recentred so the temporal unit of work is the AMBSE
  iteration (microcycle), not the ISO/IEC 29110 phase. ISO/IEC 29110
  remains the catalogue of activities that may happen inside an iteration
  and is still loaded as knowledge and exposed as a task checklist, but
  it is no longer the routing backbone. This lands as a single PR on
  `fix/ambse-cycle-centric` with six commits, each a self-contained chunk
  so the review can proceed file-by-file.
- `skills/lifecycle-orchestrator/` renamed to `skills/iteration-orchestrator/`
  via `git mv` so per-file history is preserved. The skill body has been
  rewritten to open and close iterations, run iteration-boundary and
  macrocycle closure checks, and route within an iteration to the right
  specialist skill by centre-of-gravity activity rather than by phase.
  Two new guided procedures (Step 3a open microcycle, Step 3b start
  nanocycle) walk the engineer through mission elicitation, branch
  naming, backlog seeding, anchor-thread selection, verification-action
  selection, and conventional-commit message drafting. The Change
  Request workflow is preserved unchanged in substance and reframed as
  the mechanism for reopening any baselined artefact.
- `.vse-phase` (single-line file with the current ISO 29110 activity)
  replaced by `.vse-iteration.yml` (a structured state file carrying
  iteration number, mission, branch, status, centre-of-gravity activities
  as a list, backlog items with anchors, closure debt, notes, and
  history). The new file is required by `hooks/session-start.sh` and
  `hooks/iteration-boundary-check.sh`.
- `hooks/phase-gate-check.sh` renamed to `hooks/iteration-boundary-check.sh`
  and made advisory. The old script was a hard phase-to-phase gate
  (exit 1 on missing work products). The new script reads
  `.vse-iteration.yml`, loops over every active centre of gravity, and
  reports missing items as iteration-boundary closure debt while exiting
  0. The hard closure gate now lives at the macrocycle (release tag on
  `main`), not at the iteration boundary, matching how real AMBSE teams
  carry explicit debt forward on a backlog.
- `hooks/session-start.sh` rewritten to detect `.vse-iteration.yml`,
  parse iteration number, mission, and centre-of-gravity list (using
  the same grep-based approach the journal parse already uses, no
  YAML library required), and inject an iteration-position block into
  the conversation context instead of the old "Current phase:" block.
- `knowledge/iso29110-profile.md` reframed to state explicitly that
  ISO/IEC 29110 is lifecycle-neutral and may be applied at any phase
  of system or software development. This is the textual hook for
  brownfield entry at arbitrary centre of gravity.
- `knowledge/ambse-agile-process.md` reframed to state that the Vee
  shape is geometric, not temporal. Reading the Vee as a left-to-right
  schedule is the single most common misreading of AMBSE and is now
  called out directly.
- `knowledge/vv-guide.md` reframed to stop describing continuous V&V
  as a supplement to phase gates, and to restate that continuous V&V
  is the primary quality assurance mechanism in this plugin with the
  closure checks verifying accumulated evidence at the points where
  closure matters.
- `commands/vse-phase.md` renamed to `commands/vse-iteration.md` and
  rewritten to report iteration position and run iteration-boundary
  closure checks.
- Every remaining user-visible reference to `@lifecycle-orchestrator`,
  `.vse-phase`, or phase-centric language across the companion lens,
  the specialist skills (`needs-and-requirements`, `architecture-design`,
  `verification-validation`, `traceability-guard`, `document-export`,
  `sysml2-modelling`, `session-journal`), `project-setup`,
  `attention-regime`, all PM and SR templates, the PR template, the
  `hooks/README.md`, the repo-root `README.md`, and the demo
  (`demo/smart-sensor/`) has been migrated to iteration-centred
  framing.
- `skills/project-setup` now detects brownfield indicators (presence
  of existing SR work products, existing source trees) and proposes a
  centre-of-gravity entry point other than the hard-coded PM.1 plus
  SR.1 default so end users can bring existing repositories under VSE
  governance without first pretending to start at SR.1.
- `skills/architecture-design` softens its prior SR.2-complete
  prerequisite into an iteration-inputs check that requires at least
  one baselined SyRS thread to anchor on, so concurrent SR.2 and SR.3
  work inside a single iteration (the normal AMBSE mode per
  `knowledge/ambse-agile-process.md` Section 2.3) is supported as a
  first-class flow rather than flagged as drift.
- `templates/github/phase-gate.yml` renamed to
  `templates/github/iteration-boundary.yml` and updated so the CI
  workflow runs the advisory script and accepts its exit-zero contract.

### Added

- `knowledge/iteration-centred-operation.md` — new self-contained
  knowledge file explaining iteration-as-unit-of-work, the three
  cycles, centre of gravity (including concurrent centres), brownfield
  entry at arbitrary centre of gravity with baseline harvest of
  inherited artefacts, iteration-boundary closure semantics (advisory),
  macrocycle closure semantics (hard gate), and how ISO/IEC 29110
  tasks map onto iteration activities. Embedded into
  `iteration-orchestrator` and pointed at from `vse-companion-overview`.
- `templates/common/vse-iteration.yml` — the new state file template
  that `project-setup` copies into user projects. Uses `{{DATE}}`
  substitution and carries an initial Iteration 0 (Architecture Zero)
  block with centre of gravity PM.1 plus SR.1 for greenfield projects.
- `commands/vse-microcycle.md` — new thin slash-command wrapper that
  dispatches `iteration-orchestrator` with intent "open microcycle".
  Walks the engineer through closing the outgoing iteration, eliciting
  the mission, eliciting centre of gravity, proposing the
  `vse/iter-NN-<slug>` branch name, seeding the backlog, writing the
  new `.vse-iteration.yml`, and optionally routing to the first
  specialist skill.
- `commands/vse-nanocycle.md` — new thin slash-command wrapper that
  dispatches `iteration-orchestrator` with intent "start nanocycle".
  Walks the engineer through confirming the iteration is open,
  eliciting the anchor thread (requirement ID, design element,
  verification case, or backlog item), eliciting the one-sentence
  intent, selecting a verification action to run before commit,
  optional implementation handoff to the specialist skill that owns
  the artefact type, and ending with a suggested conventional-commit
  message. The command does not commit on the engineer's behalf.
- Brownfield centre-of-gravity detection in `project-setup`, which
  scans for existing SR work products and source-tree indicators and
  proposes an entry point other than PM.1 plus SR.1 when the project
  is clearly past the greenfield starting line.
- Iteration-Boundary Closure Checklist and Macrocycle Release
  Checklist added to `templates/common/CLAUDE.md` (and therefore to
  the demo's `CLAUDE.md`) so end users see both closure cadences
  explicitly.
- AMBSE Iteration Context section added to the PR template so every
  iteration-closing PR surfaces the iteration number, mission, branch,
  centre of gravity, closure status, and any debt being carried.

### Removed

- `templates/common/vse-phase` deleted. Replaced by
  `templates/common/vse-iteration.yml`.
- "Move to the next phase" and "before proceeding" phrasings removed
  from the user surface. The plugin no longer frames forward motion
  as a phase-to-phase gate.
- Strict phase-gate blocking behaviour removed from the project-side
  hook. The only hard gate left in the plugin is the macrocycle
  closure check at release time.

### Migration

- Existing projects with a `.vse-phase` file need to be migrated
  before upgrading, because the new session-start hook detects
  `.vse-iteration.yml` and will exit silently if only `.vse-phase`
  is present. Manual migration: read the single-line value in
  `.vse-phase`, copy `templates/common/vse-iteration.yml` into the
  project root, set `current_iteration.centre_of_gravity` to the
  activity named in the old file (for example `[SR.2]` if the old
  file read `SR.2`), populate `current_iteration.number`,
  `current_iteration.mission`, and `current_iteration.branch` to
  reflect where the project actually sits, then delete `.vse-phase`.
  A future minor version may ship an automated migration hook.
- Any CI workflow generated from `templates/github/phase-gate.yml`
  should be regenerated from `templates/github/iteration-boundary.yml`
  so the new advisory exit-zero contract is honoured.

## [0.9.2] - 2026-04-07

### Fixed

- Removed `"agents": "./agents/"` from `.claude-plugin/plugin.json`.
  The 0.9.1 Fixed entry misdiagnosed the root cause of the 0.9.0
  `Validation errors: agents: Invalid input` installer failure. The
  YAML-list `tools:` form in subagent frontmatter is actually valid
  (the brand-voice plugin ships working agents in that exact shape).
  The real cause is that the current Claude Code plugin schema
  rejects a string value for the top-level `agents` field in
  `plugin.json`. The other mount points (`skills`, `commands`,
  `hooks`) still accept a string path, which is why their
  declarations kept working and the error looked like an agent
  frontmatter problem. Subagents in `./agents/` are auto-discovered
  by convention, as in the superpowers and brand-voice plugins, so
  the fix is to remove the `agents` line from the manifest entirely
  and let convention-based discovery take over. 0.9.0 and 0.9.1 are
  both effectively broken for fresh installers. Upgrade to 0.9.2.

## [0.9.1] - 2026-04-07

### Fixed

- Subagent frontmatter in all three files under `agents/` declared
  the `tools` field as a YAML list (`- Read`, `- Glob`, `- Grep`).
  The Claude Code subagent schema expects a comma-separated string,
  so the installer rejected the manifest with
  `Validation errors: agents: Invalid input` and refused to load
  the plugin on 0.9.0. Rewritten as `tools: Read, Glob, Grep` in
  `vse-stakeholder-elicitor.md`, `vse-traceability-matrix-builder.md`,
  and `vse-trade-study-runner.md`. 0.9.0 is effectively broken for
  installers. Upgrade to 0.9.1.

## [0.9.0] - 2026-04-07

### Added

- Plugin manifest now declares `commands` and `agents` mount points
  pointing at the new `commands/` and `agents/` directories at the repo
  root. The directories are empty in this release (`.gitkeep` only) and
  will be populated by follow-up work in the parallel feature branches
  for slash commands and subagents. The manifest scaffolding lands
  separately so the parallel branches do not conflict on the
  `plugin.json` mount-point declarations.
- Three previously orphaned knowledge files are now embedded into the
  skills whose scope they support, so they reach model context rather
  than only shipping in the cloned tree: `knowledge/hsi-primer.md` into
  `needs-and-requirements`, `knowledge/incose-vse-practices.md` into
  `lifecycle-orchestrator`, and `knowledge/phas-eai-framework.md` into
  `attention-regime`.
- `/vse-setup` slash command. Thin wrapper that hands off to the
  `project-setup` skill to bootstrap a VSE systems engineering project,
  greenfield or brownfield, and forwards any user-supplied arguments.
- `/vse-phase` slash command. Thin wrapper that hands off to the
  `lifecycle-orchestrator` skill to query the current ISO 29110 phase,
  check phase gates, or plan a phase transition.
- `/vse-trace` slash command. Thin wrapper that hands off to the
  `traceability-guard` skill to run a satisfy and verify trace check
  across the current SysML model directory and report gaps.
- `/vse-journal` slash command. Thin wrapper that hands off to the
  `session-journal` skill to open or append the cross-session
  continuity journal at `.vse-journal.yml`.
- Three read-only subagents under `agents/`:
  `vse-trade-study-runner` for AMBSE weighted trade studies with
  sensitivity analysis, `vse-traceability-matrix-builder` for full
  matrix synthesis and gap reporting across the SysML model tree, and
  `vse-stakeholder-elicitor` for persona-driven needs interviews and
  candidate need statements. Every subagent's tool surface is
  restricted to `Read`, `Glob`, and `Grep`. Output is suggestion-shaped
  markdown returned to the parent skill, never files written to disk.
- Skill dispatch wiring for the new subagents:
  `architecture-design` dispatches to `vse-trade-study-runner` during
  the SR.3.2 functional and SR.3.4 physical trade-off steps,
  `traceability-guard` and `verification-validation` both dispatch to
  `vse-traceability-matrix-builder` for matrix generation and
  Step 4 trace completeness checks, and `needs-and-requirements`
  dispatches to `vse-stakeholder-elicitor` during Step 2 persona-driven
  elicitation. Each dispatch documents when to invoke, what to pass,
  and how to present the suggestion-shaped result back to the engineer.

### Changed

- `vse-companion-overview` frontmatter description rewritten as
  imperative and trigger-rich. The previous wording ("Use when starting
  a VSE project session") was passive and did not instruct the harness
  to load the lens before any other VSE skill. The new wording opens
  with "Load this skill first" and enumerates concrete user-message
  triggers (what the plugin does, where to start, how ISO/IEC 29110
  phases work) so the skill picker activates the lens reliably.
- The other ten VSE skills (`architecture-design`, `attention-regime`,
  `document-export`, `lifecycle-orchestrator`, `needs-and-requirements`,
  `project-setup`, `session-journal`, `sysml2-modelling`,
  `traceability-guard`, `verification-validation`) now carry a
  one-line lens-loaded check at the very top of the body. If the lens
  has not been set in the current session, the preamble routes back to
  `vse-companion-overview` before any downstream work proceeds. This
  is light-touch enforcement at the skill body level so the lens
  remains the entry point even when the session-start hook is bypassed.
- "What This Skill Does Not Do" delegation list in
  `vse-companion-overview` extended with `session-journal` (cross-
  session continuity) and `document-export` (markdown to docx, pptx,
  pdf conversion). The list now mirrors the full ten-skill set the
  lens routes to.
- "Plugin Interoperability" section in `vse-companion-overview`
  corrected. The reference to the `engineering` plugin's `review`
  skill was stale, since the upstream plugin ships the skill as
  `code-review`. Other plugin and skill references were verified
  against currently installed cache copies and left in place.
- `hooks/session-start.sh` carries a load-bearing comment block above
  the MANDATORY FIRST ACTION echo lines, explaining that the block is
  the activation cue for `vse-companion-overview` and must not be
  removed by future maintainers as cosmetic banner output.

### Fixed

### Documentation

- README Skills table now lists `vse-companion-overview` as the first
  row so the eleventh skill is visible to end users. The table had
  only ten rows even though the Subagents and brownfield-pickup
  sections already referenced the lens skill by name.
- README knowledge-base paragraph updated from "Twelve reference
  files" to "Fifteen reference files" to match the three files that
  `feat/embed-orphan-knowledge` brought into the embedded set.
- Private contributor guide (`CLAUDE.local.md`, gitignored) refreshed
  to document the `commands/` and `agents/` mount points in the Repo
  Layout table, rewrite the Distribution Rule paragraph so commands
  and agents are no longer described as "potentially" mounted, and
  add dedicated "Slash Command Conventions" and "Subagent
  Conventions" sections between Hook Conventions and Knowledge File
  Conventions.

## [0.8.0] - 2026-04-07

### Added

- `project-setup` now enters Claude Code's Plan Mode after gathering
  context (Steps 0 and 1) and before any file creation. The drafted
  plan covers the chosen layout, every file to be created or modified,
  the hook installation, and the git operations. Execution begins only
  after the user approves the plan via `ExitPlanMode`. The new Step 2
  ("Draft Setup Plan and Enter Plan Mode") is the gate. Step 0
  reorganises the read-only context-gathering phase, and Step 2
  formally hands off to the plan review UI.
- "Operating Mode and Prerequisites" section in
  `skills/project-setup/SKILL.md` documenting the two-phase split
  (read-only context gathering, then Plan Mode review and execution)
  and recommending Claude Opus with extended thinking. The
  recommendation is reported at Step 0 as a prompt to the user, who
  can switch model before continuing or proceed on the active model.
  The recommendation is a soft prerequisite, not an enforced
  requirement, since skills cannot programmatically select a model in
  Claude Code.

### Changed

- `project-setup` Steps 2 through 11 renumbered as Steps 3 through 12
  to make room for the new Step 2 Plan Mode gate. The internal
  cross-references inside the file (the brownfield CLAUDE.md merge
  pointer at "merge step in Step 5", the SySiDE configuration pointers
  at "Step 5", the brownfield Step 12 reminders) are updated in place.
  No content changes inside the renumbered steps.
- `project-setup` frontmatter description extended to surface the
  Plan Mode gate and the Opus recommendation, so the harness's skill
  picker carries the operating mode hint into the activation cue.

## [0.7.0] - 2026-04-07

### Added

- Brownfield mode for `project-setup`. The skill now detects whether
  the current working directory is inside an existing git repository
  and chooses one of two flows. Greenfield mode (run outside any
  repository) keeps the existing behaviour and lays out the full VSE
  structure at the project root. Brownfield mode (run inside an
  existing repository) harvests context from the host project
  (`README.md`, any existing `CLAUDE.md`, `git config`,
  language-ecosystem manifests, and a `git ls-files | head -200`
  source-tree summary), places VSE work products under an
  `engineering/` subfolder so they sit alongside the host project's
  own files, leaves the host project's git history alone (no
  `git init`, no initial commit), and seeds
  `engineering/docs/sr/system-design.md` with the harvested source-tree
  context as raw input to the SR.3 architectural decomposition.
- Idempotent `CLAUDE.md` merge for the brownfield path. The
  `templates/common/CLAUDE.md` body is wrapped in
  `<!-- BEGIN VSE COMPANION (managed by project-setup) -->` and
  `<!-- END VSE COMPANION -->` HTML-comment markers. Brownfield
  invocation appends the marker block on first run and replaces the
  bytes between the markers in place on every subsequent run, so
  re-running `project-setup` picks up the current plugin version
  without duplicating content or disturbing the user's surrounding
  text. Greenfield mode writes the same wrapped block as a fresh file.
- `ENG_ROOT` autodetection block in `hooks/session-start.sh`,
  `hooks/phase-gate-check.sh`, and `hooks/pre-commit-traceability.sh`.
  Each script checks for `engineering/models` or `engineering/syside.toml`
  and points its model and work-product paths at `engineering/` when
  found, falling back to the project root for greenfield projects.
  `.vse-phase` and `.vse-journal.yml` continue to live at the project
  root in both layouts so the SessionStart hook keeps working
  unchanged. The phase-gate work-product globs are prefixed with
  `"$ENG_ROOT/"` so the SR.1 through SR.6 and PM.1 through PM.4 gates
  apply to the engineering subfolder in brownfield projects.

### Changed

- `project-setup` no longer overwrites an existing `CLAUDE.md`. The
  brownfield merge preserves every byte of the user's original file
  outside the marker block.
- `project-setup` no longer runs `git init`, `git add`, or `git commit`
  in brownfield mode. The host project already has its own git
  workflow and commit conventions. The Step 11 summary tells the user
  to stage and commit the new files on a
  `vse/iter-00-architecture-zero` branch instead.
- In brownfield projects, `models/`, `docs/pm/`, `docs/sr/`,
  `TASKS.md`, `syside.toml`, and `.lsp.json` live under
  `engineering/`. The merged `CLAUDE.md` rewrites every bare path
  reference in the marker block to the `engineering/...` form so the
  AMBSE workflow guidance, project structure description, and
  traceability matrix pointer all match the actual file layout.
- `templates/common/CLAUDE.md` and `demo/smart-sensor/CLAUDE.md` now
  carry the `<!-- BEGIN VSE COMPANION ... -->` marker delimiters
  around the body content so brownfield merge has a stable boundary
  to work with. The content inside the markers is unchanged from
  0.6.0.

## [0.6.0] - 2026-04-07

### Added

- `knowledge/ambse-git-workflow.md`, the canonical mapping between
  the three AMBSE timeframes (nanocycle, microcycle, macrocycle) and
  a feature-branch git workflow. Documents the `vse/iter-NN` branch
  convention, the pull request body template, the worked microcycle
  example, the anti-pattern catalogue, and the host-agnostic
  translation notes for GitLab CI, Forgejo Actions, and Gitea
  Actions. Loaded by `@lifecycle-orchestrator` at activation time.
- AMBSE Workflow section in `templates/common/CLAUDE.md` (and the
  matching demo `CLAUDE.md`) defining the branch-per-microcycle
  convention, trace gates, and phase gates for every new VSE
  project that the plugin scaffolds.
- Iteration Plan table in `templates/pm/project-plan.md` Section 4.3
  with the `iter-00 Architecture Zero` row pre-filled, so PM.1.4
  produces a concrete first iteration record.

### Changed

- `lifecycle-orchestrator` PM.1.4 step renamed from "Lifecycle
  Selection" to "Iteration Cadence and First Iteration Branch". The
  three-option lifecycle picker is replaced with a fixed AMBSE
  workflow whose only inputs are the iteration cadence, the first
  iteration mission, and the macrocycle milestones. The skill now
  instructs the engineer to create the first `vse/iter-00-architecture-zero`
  branch from `main` and load the new git workflow knowledge file.
- `knowledge/ambse-agile-process.md` Section 2 reframed as "AMBSE: The
  Vee Applied at Three Timeframes". The Vee is described as the
  verification pattern AMBSE applies at every iteration, with a direct
  Douglass quotation from Cookbook p. 64. Section 3 (Verification
  Timeframes) now carries explicit Vee mapping and git mapping bullets
  for nanocycle, microcycle, and macrocycle. New Section 4 cross-
  references the git workflow knowledge file. Sections 4-9 renumbered
  to 5-10.
- `knowledge/ambse-architecture.md` Section 6.3 (Handoff as iteration
  boundary) now defines the canonical handoff form as a pull request
  against `main`, with the PR diff carrying the converted engineering
  data, the PR body summarising mission and trace status, and the PR
  review acting as the formal handoff acceptance per Douglass
  (Cookbook p. 61).
- `knowledge/ambse-requirements.md` Section 5 (The Nanocycle
  Requirements Workflow) now describes the nanocycle as the Vee in
  miniature and adds an iteration-boundary paragraph mapping each
  iteration onto a pull request.
- `knowledge/incose-vse-practices.md` lifecycle approaches table
  reframes the Vee row as "Vee pattern (used by AMBSE at all scales)"
  and marks Hybrid AMBSE as the enforced workflow. The Vee section
  later in the file is rewritten to describe the Vee as the inner
  structure of every AMBSE iteration with explicit nanocycle/
  microcycle/macrocycle Vee mappings.
- `templates/pm/project-plan.md` Section 4.1 pre-fills the AMBSE
  lifecycle, the two-week microcycle default cadence, and the
  branch-per-microcycle git workflow. Section 4.2 renamed to
  "Macrocycle Milestones". The matching demo project plan in
  `demo/smart-sensor/docs/pm/project-plan.md` now carries the
  concrete two-week cadence rationale for the Smart Temperature
  Sensor project.
- `templates/github/traceability-check.yml` and
  `templates/github/phase-gate.yml` carry an AMBSE comment header
  explaining that the PR is the microcycle handoff gate per Douglass
  (Cookbook p. 61). The trace check workflow runs on every PR (not
  only PRs that touch `models/**/*.sysml`), because every iteration
  handoff should be verified.

### Documentation

- README "What it does" section rewritten to describe AMBSE as the
  single VSE workflow this plugin enforces, and to point at
  `knowledge/ambse-git-workflow.md` for the branch-per-microcycle
  mapping.
- README "Knowledge base" section adds `ambse-git-workflow.md` to
  the AMBSE list.
- README "Starting a new project" Step 4 rewritten to drop the
  legacy "select a lifecycle approach" wording.

## [0.5.1] - 2026-04-07

### Added

- `templates/common/lsp.json`, copied by `project-setup` Step 4 into
  every new project as `.lsp.json`. The Claude Code IDE reads this
  file from the workspace root to launch `syside lsp` over stdio for
  `.sysml` and `.kerml` files. End users now get IDE language server
  integration out of the box rather than only the `syside.toml`
  config that SySiDE itself reads.
- `demo/smart-sensor/.lsp.json` so the contributor dogfood project
  exercises the IDE LSP path during local validation, as required by
  step 3 of the Local Validation Workflow in `CLAUDE.local.md`.
- `knowledge/syside-automator-ref.md` Project Configuration Files
  section explaining the distinction between `syside.toml` (read by
  SySiDE) and `.lsp.json` (read by the Claude Code IDE), so the
  `sysml2-modelling` skill surfaces it at load time.

### Fixed

- The repo-root `.lsp.json` introduced in 0.5.0 (commit 68d8463) only
  helped the contributor whose workspace was the plugin repo itself,
  because the IDE reads `.lsp.json` from the workspace root rather
  than from `${CLAUDE_PLUGIN_ROOT}`. End users opening their own
  project after running `project-setup` got `syside.toml` but no IDE
  language server integration. Shipping the file as a project
  template closes that gap. The repo-root copy is retained as
  contributor scaffolding for editing the plugin itself.

### Documentation

- README "Tooling" section now mentions `.lsp.json` alongside
  `syside.toml` so installers know what each file does.

## [0.5.0] - 2026-04-07

### Added

- `lifecycle-orchestrator` PM.2 now documents a concrete six-step
  Change Request handling procedure aligned to the existing
  `templates/pm/change-request.md` work product. Covers opening the
  CR, rationale, impact analysis (with `@traceability-guard` for
  downstream traces), evaluation, the approved path, and the rejected
  or postponed path. Closes a gap where the Change Request work
  product was referenced by several skills but had no authoring
  guidance.
- `hooks/README.md` clarifying which scripts in `hooks/` are Claude
  Code lifecycle hooks run by the harness (`session-start.sh`,
  `sysml-change-reminder.sh`, registered in `hooks.json`) and which
  are project-side scripts installed into user projects or invoked
  by CI (`pre-commit-traceability.sh`, `phase-gate-check.sh`). The
  two categories share the directory but are not interchangeable.
- Marketplace listing enriched with `homepage`, `license`,
  `categories`, and `keywords` fields for discoverability. Keywords
  cover systems engineering, VSE, ISO/IEC 29110, SysML 2.0, MBSE,
  AMBSE, requirements, traceability, V&V, INCOSE, PHAS-EAI, and
  SySiDE.

### Fixed

- `skills/document-export/SKILL.md` line 11 used a semicolon in body
  prose ("source of truth; generated files"), violating the project's
  writing style rule. Split into two sentences.
- `skills/document-export/SKILL.md` activation description was too
  generic ("generating deliverable documents or building formatted
  output"), risking invocation during template population or
  authoring. Tighten the trigger so the skill is unambiguously about
  converting completed markdown to docx, pptx, or pdf for delivery.
- `skills/vse-companion-overview/SKILL.md` activation description
  shortened from roughly 77 words to roughly 40 words. The
  session-start hook already guarantees this skill loads when
  `.vse-phase` is present, so the description's job is mainly to
  support manual invocation and to document scope.

### Chore

- `.claude/settings.json` removed from version control. It was
  committed in an earlier state of the repo (before the `.claude/`
  gitignore rule existed) and had been silently propagating
  Roar-specific harness permissions ever since. The `.gitignore` rule
  for `.claude/` has been preserved with a comment block clarifying
  that it is per-user harness config distinct from the
  `.claude-plugin/` manifest directory.

### Documentation

- `CLAUDE.local.md` "Distribution Rule" section rewritten to
  distinguish *what physically ships to installers* (the entire
  committed git tree, including `templates/`, `knowledge/`, `hooks/`,
  and `demo/`) from *what the Claude Code harness auto-loads as
  components* (only surfaces declared in `plugin.json`). The previous
  wording conflated the two and would have misled future contributors
  into believing that `templates/` and `knowledge/` did not reach end
  users, despite several skills depending on those paths via
  `${CLAUDE_PLUGIN_ROOT}`. Note for historical record: the 0.4.0
  changelog entry removing the repo-root `CLAUDE.md` cited the same
  imprecise reasoning. The migration itself was correct (a plugin-
  internal `CLAUDE.md` is not auto-loaded as project instructions in
  the installer's workspace), but the file did ship, it just was
  never getting loaded. This is a contributor-only file and the
  change does not reach end users.

## [0.4.0] - 2026-04-07

### Added

- `vse-companion-overview` skill: canonical lens for VSE projects. Owns the
  identity, source-processing order, phase-based information filtering,
  traceability rules, drift indicators, ISO/IEC 29110 process map, and
  routing to specialised skills. Eleventh skill in the plugin and the new
  recommended entry point for any VSE project session.

### Removed

- `CLAUDE.md` (repo root) deleted. The lens content previously inlined
  here never reached plugin installers (the repo-root `CLAUDE.md` is not
  part of the plugin distribution surface) and is now owned by the
  `vse-companion-overview` skill, which actually ships. Contributor-mode
  guidance for plugin developers lives in the gitignored `CLAUDE.local.md`
  added in 0.3.2. The committed file no longer has a role.

### Changed

- `hooks/session-start.sh` now instructs Claude to invoke the
  `vse-companion-overview` skill as a mandatory first action whenever a
  VSE project (`.vse-phase` present) is detected. End users no longer need
  to ask for the lens or rely on probabilistic skill activation: the hook
  guarantees the lens is loaded before any response is generated.
- `demo/smart-sensor/CLAUDE.md` updated to point at the new
  `vse-companion-overview` skill rather than the (now removed) plugin
  `CLAUDE.md`.
- `templates/common/CLAUDE.md` updated with the same pointer fix, so new
  VSE projects bootstrapped via `project-setup` reference the overview
  skill from day one.

## [0.3.2] - 2026-04-07

### Added

- `CLAUDE.local.md` template guidance for plugin contributors. The file
  itself is gitignored so each contributor maintains their own local
  instructions for development mode (separate from the user-facing
  framing in the committed `CLAUDE.md`).
- `.gitignore` rule for `CLAUDE.local.md` to prevent accidental commits.

## [0.3.0] - 2026-03-31

### Added

- `knowledge/syside-automator-ref.md`: comprehensive reference for the SySiDE
  Automator Python API, including tool selection guide, core API patterns,
  Compiler usage, element types, and key workflow examples
- `sysml2-modelling`: tool selection guide (Editor vs Modeler vs CLI vs
  Automator), Automator Python API section with loading, querying, evaluating,
  and interactive exploration examples
- `traceability-guard`: Automator-enhanced semantic trace checking with
  ready-to-run Python script template, comparison table (grep vs Automator)
- `document-export`: Jinja2-based model report generation pipeline with
  template functions, attribute extraction types, and branding customisation
- `needs-and-requirements`: requirements Excel import/export with round-trip
  workflow for acquirer review
- `architecture-design`: part decomposition, type queries, value rollup with
  unit conversion, variant analysis, and metadata filter evaluation
- `verification-validation`: verification coverage analysis, expression-based
  constraint checking, state machine simulation reference
- `project-setup`: Automator bootstrap (venv, pip install, scripts/ directory),
  tool selection guidance for projects without SySiDE installed
- `attention-regime`: Automator availability check in health diagnostics,
  scripts/ and .venv/ in environment checklist

### Changed

- SySiDE Product Suite overview rewritten as decision matrix with four tools
- All Automator sections degrade gracefully when Automator is not installed

## [0.2.0] - 2026-03-31

### Added

- Claude Code hooks (`hooks.json`) for automatic session start anchoring and
  SysML file change reminders (R4 niche construction)
- Dynamic knowledge injection in skills via `!`cat`` syntax, ensuring reference
  content is loaded at skill invocation time (R1 information filtering, R2
  designed cognitive reserve)
- `.lsp.json` for Sensmetry SySiDE language server configuration
- SySiDE CLI commands in `sysml2-modelling` (check, format, viz)
- CLI-based health checks in `attention-regime`
- SySiDE detection and configuration in `project-setup`
- Comprehensive annotated `syside.toml` template
- Updated GitHub Actions templates with SySiDE CLI integration
- PostToolUse hook includes `syside format --check` when CLI available
- SessionStart hook reports SySiDE CLI version and commands
- This changelog

### Changed

- Skill descriptions rewritten for better auto-invocation matching
- All `knowledge/` and `templates/` path references now use
  `${CLAUDE_PLUGIN_ROOT}` for correct resolution when installed as a plugin
- `attention-regime` skill updated to document both Claude Code hooks
  (automatic) and git hooks (per-project installation)
- `plugin.json` now references `hooks.json`
- `CLAUDE.md` slimmed from 306 to 210 lines (SysML conventions moved to
  sysml2-modelling, GitHub workflow moved to project-setup)

### Fixed

- Knowledge files were not loaded into skill context (knowledge/ is not a
  standard plugin directory, now injected via dynamic commands)
- Template paths in `project-setup` were relative (broke when plugin was
  installed outside the working directory)
- `.lsp.json` corrected to use `syside lsp` (not standalone binary)
- Duplicate Step 8 numbering in `architecture-design`

## [0.1.0] - 2026-02-28

### Added

- Initial release
- 10 skills: lifecycle-orchestrator, needs-and-requirements, architecture-design,
  verification-validation, traceability-guard, sysml2-modelling, attention-regime,
  session-journal, project-setup, document-export
- 11 knowledge files extracted from 6 authoritative sources
- 28 ISO 29110 work product templates (9 PM, 15 SR, 4 GitHub workflows)
- 2 git hook scripts (pre-commit traceability, phase gate check)
- Complete demo project (smart-sensor) walking through SR.1 to SR.5
- CLAUDE.md with plugin identity and operational model
