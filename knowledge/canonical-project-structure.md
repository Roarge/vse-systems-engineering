# Canonical VSE Project Structure

This file defines the authoritative layout for a VSE project set up by
`@project-setup`. Both `@project-setup` and `@project-audit` embed this
file to ensure a single source of truth for structural completeness checks.

## Layouts

A VSE project uses one of two layouts:

- **Greenfield**: all VSE content at the project root.
- **Brownfield**: `.vse-iteration.yml`, `.vse-journal.yml`, and `CLAUDE.md`
  at the project root. All other VSE content under an `engineering/`
  subfolder.

The layout is detected by checking for an `engineering/` directory.

## Root Files (Both Layouts)

| File | Purpose | Required |
|------|---------|----------|
| `.vse-iteration.yml` | Iteration state (schema version 1) | Yes |
| `.vse-journal.yml` | Session continuity journal | Yes |
| `CLAUDE.md` | VSE companion guidance (marker block) | Yes |
| `.gitignore` | Excludes `build/`, generated files | Yes |

## Greenfield-Only Root Files

| File | Purpose |
|------|---------|
| `.lsp.json` | SySiDE language server config |
| `syside.toml` | SySiDE formatting and linting |
| `TASKS.md` | ISO 29110 task checklist |

In brownfield mode these live under `engineering/`.

## CLAUDE.md Marker Block

The VSE companion content is wrapped in idempotent markers:

```text
<!-- BEGIN VSE COMPANION (managed by project-setup) -->
...content...
<!-- END VSE COMPANION -->
```

The audit compares the marker block content against the current template
at `${CLAUDE_PLUGIN_ROOT}/templates/common/CLAUDE.md` via diff.

## .vse-iteration.yml Schema (Version 1)

Required fields under `current_iteration`:

- `number` (integer, starting at 0)
- `mission` (string, action-first description)
- `branch` (string, `vse/iter-NN-<slug>` form)
- `status` (enum: `open`, `closing`, `merged`)
- `centre_of_gravity` (list of ISO 29110 task IDs)
- `opened` (ISO date string)
- `macrocycle_target` (string, e.g. `v0.1.0`)
- `backlog` (list of items with `item`, `status`, `anchor`)

Optional fields: `closure_debt`, `notes`, `history`.

## Model Tiers

### Flat Tier (Legacy, Teaching Only)

Six files flat under `models/` (greenfield) or `engineering/models/`
(brownfield). No subdirectories, no views, no short code, no VSE Library.

| File | Package |
|------|---------|
| `package.sysml` | Root overview (`{{PROJECT_PACKAGE}}`) |
| `stakeholder-needs.sysml` | `StakeholderNeeds` |
| `system-requirements.sysml` | `SystemRequirements` |
| `architecture.sysml` | `Architecture` |
| `verification.sysml` | `Verification` |
| `validation.sysml` | `Validation` |

### Minimal AMBSE Tier (Opt-Down)

Package-per-directory layout. Each package has its own directory containing
a package definition file and a co-located view file. The VSE Library is
always included.

**Always present:**

| Directory | Definition File | View File | View Type |
|-----------|----------------|-----------|-----------|
| `actors/` | `actors.sysml` | `actors-view.sysml` | General View |
| `stakeholder-needs/` | `stakeholder-needs.sysml` | `stakeholder-needs-view.sysml` | Grid View |
| `use-cases/` | `use-cases.sysml` | `use-cases-view.sysml` | General View |
| `requirements/` | `requirements.sysml` | `requirements-view.sysml` | Grid View |
| `arch-design/` | `arch-design.sysml` | `arch-design-view.sysml` | Interconnection View |
| `interfaces/` | `interfaces.sysml` | `interfaces-view.sysml` | Interconnection View |
| `verification/` | `verification.sysml` | `verification-view.sysml` | Grid View |
| `risks/` | `risks.sysml` | `risks-view.sysml` | Grid View |

**Root-level files (not in a package directory):**

| File | Purpose |
|------|---------|
| `model-overview.sysml` | Root overview, cross-links all packages |
| `traceability-view.sysml` | Cross-cutting Grid View: requirements to verification |

**Library (always present for Minimal and Canonical):**

| Directory | File | Purpose |
|-----------|------|---------|
| `library/` | `vse-library.sysml` | Reusable metadata (RiskInfo, ConfigItem, Baseline, etc.) |

### Canonical AMBSE Tier (Default)

Everything in the Minimal tier, plus these additional package directories:

| Directory | Definition File | View File | View Type |
|-----------|----------------|-----------|-----------|
| `functional-analysis/` | `functional-analysis.sysml` | `functional-analysis-view.sysml` | Action Flow View |
| `arch-analysis/` | `arch-analysis.sysml` | `arch-analysis-view.sysml` | Grid View |
| `configurations/` | `configurations.sysml` | `configurations-view.sysml` | Grid View |

The `configurations/` directory (variant modelling) is included by default
in the Canonical tier.

### Optional Package Directories (Independent Opt-Ins)

| Directory | Definition File | View File | View Type | Use When |
|-----------|----------------|-----------|-----------|----------|
| `base-architecture/` | `base-architecture.sysml` | `base-architecture-view.sysml` | Interconnection View | Inheriting from a prior programme |
| `cm/` | `cm.sysml` | `cm-view.sysml` | Grid View | Declaring model-level baselines and CIs |

## Document Templates

### PM Work Products (`docs/pm/`, 9 files)

1. `project-plan.md`
2. `statement-of-work.md`
3. `progress-status.md`
4. `meeting-record.md`
5. `change-request.md`
6. `correction-register.md`
7. `justification-document.md`
8. `purchase-order.md`
9. `product-acceptance.md`

### SR Work Products (`docs/sr/`, 15 files)

1. `semp.md`
2. `data-model.md`
3. `stakeholder-requirements.md`
4. `system-requirements.md`
5. `system-element-requirements.md`
6. `traceability-matrix.md`
7. `system-design.md`
8. `ivv-plan.md`
9. `integration-report.md`
10. `verification-report.md`
11. `validation-report.md`
12. `system-user-manual.md`
13. `system-operation-guide.md`
14. `maintenance-guide.md`
15. `training-specifications.md`

## Hooks

| Hook | Location | Purpose |
|------|----------|---------|
| Pre-commit traceability | `.git/hooks/pre-commit` | Blocks commits with broken SysML trace links |

The hook script is copied from
`${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh` and must be
executable. It autodetects the engineering root via its `ENG_ROOT` block.

## GitHub Actions (Optional)

| Workflow | Location | Purpose |
|----------|----------|---------|
| Traceability check | `.github/workflows/traceability-check.yml` | PR-time trace gate |
| Iteration boundary | `.github/workflows/iteration-boundary.yml` | Advisory closure debt check |
| Document export | `.github/workflows/document-export.yml` | Generates documents on release tags |
| PR template | `.github/pull_request_template.md` | AMBSE iteration context checklist |

## SySiDE Configuration

| File | Location (greenfield) | Location (brownfield) |
|------|-----------------------|----------------------|
| `syside.toml` | Project root | `engineering/syside.toml` |
| `.lsp.json` | Project root | `engineering/.lsp.json` |

## Gitignore Entries

**Both layouts:**
- `build/` (generated outputs)

**Brownfield additionally:**
- `engineering/build/`
- `engineering/.venv/`
