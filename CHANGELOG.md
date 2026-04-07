# Changelog

All notable changes to the vse-systems-engineering plugin will be documented
in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
