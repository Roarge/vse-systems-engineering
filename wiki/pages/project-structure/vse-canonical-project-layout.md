---
title: "VSE Canonical Project Layout"
slug: vse-canonical-project-layout
type: reference
layer: project-structure
tags: [project-setup, project-audit, layout, greenfield, brownfield, .vse-iteration]
sources:
  - citation: "Plugin-internal model, the authoritative directory structure used by @project-setup and @project-audit."
    raw: null
related:
  - vse-model-tiers-and-templates
  - iteration-centred-operation
  - iteration-boundary-and-macrocycle-closure
  - iso29110-template-mapping
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [project-setup, project-audit]
---

# VSE Canonical Project Layout

This page defines the authoritative layout for a VSE project set
up by `@project-setup`. Both `@project-setup` and `@project-audit`
embed this content to ensure a single source of truth for
structural completeness checks. For model tiers and document
templates, see [[vse-model-tiers-and-templates]].

## Layouts

A VSE project uses one of two layouts:

- **Greenfield**: all VSE content at the project root.
- **Brownfield**: `.vse-iteration.yml`, `.vse-journal.yml`, and
  `CLAUDE.md` at the project root. All other VSE content under an
  `engineering/` subfolder.

The layout is detected by checking for an `engineering/`
directory.

## Root files (both layouts)

| File | Purpose | Required |
|---|---|---|
| `.vse-iteration.yml` | Iteration state (schema version 1) | Yes |
| `.vse-journal.yml` | Session continuity journal | Yes |
| `CLAUDE.md` | VSE companion guidance (marker block) | Yes |
| `.gitignore` | Excludes `build/`, generated files | Yes |

## Greenfield-only root files

| File | Purpose |
|---|---|
| `.lsp.json` | SySiDE language server config |
| `syside.toml` | SySiDE formatting and linting |
| `TASKS.md` | ISO 29110 task checklist |

In brownfield mode these live under `engineering/`.

## CLAUDE.md marker block

The VSE companion content is wrapped in idempotent markers:

```text
<!-- BEGIN VSE COMPANION (managed by project-setup) -->
...content...
<!-- END VSE COMPANION -->
```

The audit compares the marker-block content against the current
template at `${CLAUDE_PLUGIN_ROOT}/templates/common/CLAUDE.md` via
diff.

## .vse-iteration.yml schema (version 1)

Required fields under `current_iteration`:

- `number` (integer, starting at 0)
- `mission` (string, action-first description)
- `branch` (string, `vse/iter-NN-<slug>` form)
- `status` (enum: `open`, `closing`, `merged`)
- `centre_of_gravity` (list of ISO 29110 task IDs, see
  [[iteration-centred-operation]])
- `opened` (ISO date string)
- `macrocycle_target` (string, e.g. `v0.1.0`)
- `backlog` (list of items with `item`, `status`, `anchor`)

Optional fields: `closure_debt` (consumed by
[[iteration-boundary-and-macrocycle-closure]]), `notes`, `history`.

## SySiDE configuration

| File | Greenfield location | Brownfield location |
|---|---|---|
| `syside.toml` | Project root | `engineering/syside.toml` |
| `.lsp.json` | Project root | `engineering/.lsp.json` |

## Gitignore entries

**Both layouts:**

- `build/` (generated outputs)

**Brownfield additionally:**

- `engineering/build/`
- `engineering/.venv/`

## Hooks

| Hook | Location | Purpose |
|---|---|---|
| Pre-commit traceability | `.git/hooks/pre-commit` | Blocks commits with broken SysML trace links |

The hook script is copied from
`${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh` and must
be executable. It autodetects the engineering root via its
`ENG_ROOT` block.

## GitHub Actions (optional)

| Workflow | Location | Purpose |
|---|---|---|
| Traceability check | `.github/workflows/traceability-check.yml` | PR-time trace gate |
| Iteration boundary | `.github/workflows/iteration-boundary.yml` | Advisory closure debt check |
| Document export | `.github/workflows/document-export.yml` | Generates documents on release tags |
| PR template | `.github/pull_request_template.md` | AMBSE iteration context checklist |

## See also

- [[vse-model-tiers-and-templates]] for the SysML model tiers and
  the document templates that live under `docs/pm/` and `docs/sr/`.
- [[iteration-centred-operation]] for the centre-of-gravity model
  recorded in `.vse-iteration.yml`.
- [[iteration-boundary-and-macrocycle-closure]] for the closure
  workflow that consumes `closure_debt`.
- [[iso29110-template-mapping]] for the phase-to-template-file
  mapping used by `@project-setup`.
