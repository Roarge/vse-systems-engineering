---
title: "VSE Model Tiers and Document Templates"
slug: vse-model-tiers-and-templates
type: reference
layer: project-structure
summary: The three SysML model tiers (Flat, Minimal AMBSE, Canonical AMBSE) and the templates each one scaffolds
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
updated: 2026-10-18
referenced_by: [project-setup, project-audit]
---

# VSE Model Tiers and Document Templates

## Contents

- Model tiers
- Document templates
- See also

This page defines the three SysML model tiers (Flat, Minimal
AMBSE, Canonical AMBSE) used by `@project-setup` and where each
ISO/IEC 29110 work product lives. The plugin keeps its document
templates in `templates/pm/` and `templates/sr/`. A project's work
products sit under `docs/`, one file per document directly in it,
apart from the folders named below. For root files and
`.vse-iteration.yml` schema see [[vse-canonical-project-layout]].
For the AMBSE canonical package layout the model tiers ground out
in, see [[sysml2-canonical-model-layout]].

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

`@project-setup` writes the documents of the project's profile, and
the skill that owns any other document copies its template on
request.

### PM work products (9)

1. Project Plan: `docs/project-plan.md`
2. Statement of Work: the plugin template `templates/pm/statement-of-work.md`, copied into `docs/` on request by the skill that owns it
3. Progress Status Record: `docs/progress-status-record.md`
4. Meeting Record: one file per meeting under `docs/meetings/`
5. Change Request: a GitHub Issue labelled `change-request` (methodology §10.4.2), not a file
6. Correction Register: `docs/correction-register.md`
7. Justification Document: `docs/justification-document.md`
8. Purchase Order: its template is kept in `docs/templates/` (methodology §10.10)
9. Product Acceptance Record: `docs/product-acceptance-record.md`

### SR work products (15)

1. Systems Engineering Management Plan (SEMP): `docs/semp.md`
2. Data Model: the SysML model, with an optional explicit data model package (methodology §9.5)
3. Stakeholder Requirements Specification (StRS): `docs/generated/stakeholder-requirements.md`, rendered from the model
4. System Requirements Specification (SyRS): `docs/generated/system-requirements.md`, rendered from the model
5. System Elements Requirements: the plugin template `templates/sr/system-element-requirements.md`, copied into `docs/` on request by the skill that owns it
6. Traceability Matrix: `docs/generated/traceability-matrix.md`, rendered from the model
7. System Design Document: `docs/system-design.md`
8. IVV Plan: `docs/ivv-plan.md`
9. Integration Report: the plugin template `templates/sr/integration-report.md`, copied into `docs/` on request by the skill that owns it
10. Verification Report: `docs/verification-reports/<case>-<date>.md`, one per run
11. Validation Report: `docs/validation-reports/<case>-<date>.md`, one per run
12. System User Manual: its template is kept in `docs/templates/` (methodology §10.10)
13. System Operation Guide: its template is kept in `docs/templates/` (methodology §10.10)
14. Maintenance Documentation: `docs/maintenance-guide.md`
15. System Training Specifications: its template is kept in `docs/templates/` (methodology §10.10)

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
