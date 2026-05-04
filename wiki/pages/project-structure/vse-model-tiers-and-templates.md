---
title: "VSE Model Tiers and Document Templates"
slug: vse-model-tiers-and-templates
type: reference
layer: project-structure
tags: [project-setup, model-tiers, ambse, package-per-directory, document-templates]
sources:
  - citation: "Plugin-internal model, the model tiers used by @project-setup and audited by @project-audit."
    raw: null
related:
  - vse-canonical-project-layout
  - sysml2-canonical-model-layout
  - sysml2-vse-library-metadata
  - iso29110-template-mapping
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [project-setup, project-audit]
---

# VSE Model Tiers and Document Templates

This page defines the three SysML model tiers (Flat, Minimal
AMBSE, Canonical AMBSE) used by `@project-setup` and the document
templates scaffolded under `docs/pm/` and `docs/sr/`. For root
files and `.vse-iteration.yml` schema see
[[vse-canonical-project-layout]]. For the AMBSE canonical package
layout the model tiers ground out in, see
[[sysml2-canonical-model-layout]].

## Model tiers

### Flat tier (legacy, teaching only)

Six files flat under `models/` (greenfield) or `engineering/models/`
(brownfield). No subdirectories, no views, no short code, no VSE
Library.

| File | Package |
|---|---|
| `package.sysml` | Root overview (`{{PROJECT_PACKAGE}}`) |
| `stakeholder-needs.sysml` | `StakeholderNeeds` |
| `system-requirements.sysml` | `SystemRequirements` |
| `architecture.sysml` | `Architecture` |
| `verification.sysml` | `Verification` |
| `validation.sysml` | `Validation` |

### Minimal AMBSE tier (opt-down)

**Package-per-directory layout.** Each package has its own
directory containing a package definition file and a co-located
view file. The VSE Library is always included.

**Always present:**

| Directory | Definition file | View file | View type |
|---|---|---|---|
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
|---|---|
| `model-overview.sysml` | Root overview, cross-links all packages |
| `traceability-view.sysml` | Cross-cutting Grid View: requirements to verification |

**Library (always present for Minimal and Canonical):**

| Directory | File | Purpose |
|---|---|---|
| `library/` | `vse-library.sysml` | Reusable metadata (RiskInfo, ConfigItem, Baseline; see [[sysml2-vse-library-metadata]]) |

### Canonical AMBSE tier (default)

Everything in the Minimal tier, plus these additional package
directories:

| Directory | Definition file | View file | View type |
|---|---|---|---|
| `functional-analysis/` | `functional-analysis.sysml` | `functional-analysis-view.sysml` | Action Flow View |
| `arch-analysis/` | `arch-analysis.sysml` | `arch-analysis-view.sysml` | Grid View |
| `configurations/` | `configurations.sysml` | `configurations-view.sysml` | Grid View |

The `configurations/` directory (variant modelling) is included
by default in the Canonical tier.

### Optional package directories (independent opt-ins)

| Directory | Definition file | View file | View type | Use when |
|---|---|---|---|---|
| `base-architecture/` | `base-architecture.sysml` | `base-architecture-view.sysml` | Interconnection View | Inheriting from a prior programme |
| `cm/` | `cm.sysml` | `cm-view.sysml` | Grid View | Declaring model-level baselines and CIs |

For the underlying SysML 2.0 layout principles (short-code
prefixes, namespace hygiene, base-architecture reuse,
configurations as a peer package), see
[[sysml2-canonical-model-layout]].

## Document templates

### PM work products (`docs/pm/`, 9 files)

1. `project-plan.md`
2. `statement-of-work.md`
3. `progress-status.md`
4. `meeting-record.md`
5. `change-request.md`
6. `correction-register.md`
7. `justification-document.md`
8. `purchase-order.md`
9. `product-acceptance.md`

### SR work products (`docs/sr/`, 15 files)

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

For the phase-to-template mapping see
[[iso29110-template-mapping]].

## See also

- [[vse-canonical-project-layout]] for root files, layouts, and
  the `.vse-iteration.yml` schema.
- [[sysml2-canonical-model-layout]] for the AMBSE canonical
  package set that the Minimal and Canonical tiers materialise.
- [[sysml2-vse-library-metadata]] for the metadata definitions
  shipped in `library/vse-library.sysml`.
- [[iso29110-template-mapping]] for the phase-to-template-file
  mapping these templates implement.
