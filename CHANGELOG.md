# Changelog

All notable changes to the vse-systems-engineering plugin will be documented
in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
