# Changelog

All notable changes to the vse-systems-engineering plugin will be documented
in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
