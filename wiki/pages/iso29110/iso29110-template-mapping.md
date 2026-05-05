---
title: "ISO/IEC 29110 Phase to Template Mapping"
slug: iso29110-template-mapping
type: reference
layer: iso29110
tags: [iso29110, templates, work-products, project-setup]
sources:
  - citation: "ISO/IEC TR 29110-5-6-2:2014, work-product catalogue, plus the plugin's templates/common/ scaffolding."
    raw: ISO_IEC_TR_29110-5-6-2_2014.pdf
related:
  - iso29110-pm-task-checklists
  - iso29110-sr-task-checklists
  - iso29110-roles-and-work-products
  - vse-canonical-project-layout
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [project-setup, release-orchestrator]
---

# ISO/IEC 29110 Phase to Template Mapping

Quick reference linking each ISO 29110 phase to the markdown
template file it produces. The plugin's `@project-setup` skill
scaffolds these templates under `docs/pm/` and `docs/sr/` (or
`engineering/docs/pm/` and `engineering/docs/sr/` in brownfield
layouts). For the full canonical project layout, see
[[vse-canonical-project-layout]].

## PM phase templates

| Phase | Template file | Work product |
|---|---|---|
| PM.1 | `docs/pm/statement-of-work.md` | Statement of Work |
| PM.1 | `docs/pm/project-plan.md` | Project Plan |
| PM.1-PM.4 | `docs/pm/meeting-record.md` | Meeting Record |
| PM.2 | `docs/pm/progress-status.md` | Progress Status Record |
| PM.2 | `docs/pm/change-request.md` | Change Request |
| PM.3 | `docs/pm/correction-register.md` | Correction Register |
| PM.3 / SR.3 | `docs/pm/justification-document.md` | Justification Document |
| PM.4 | `docs/pm/product-acceptance.md` | Product Acceptance Record |

The Justification Document spans PM.3 (project assessment) and
SR.3 (architecture trade-offs). The plugin uses a single document
in both phases with section-level discipline rather than two
disjoint files.

## SR phase templates

| Phase | Template file | Work product |
|---|---|---|
| SR.1 | `docs/sr/semp.md` | SEMP |
| SR.1 | `docs/sr/data-model.md` | Data Model |
| SR.2 | `docs/sr/stakeholder-requirements.md` | StRS |
| SR.2 | `docs/sr/system-requirements.md` | SyRS |
| SR.2 | `docs/sr/system-element-requirements.md` | System Elements Requirements |
| SR.2+ | `docs/sr/traceability-matrix.md` | Traceability Matrix |
| SR.2/SR.5 | `docs/sr/ivv-plan.md` | IVV Plan |
| SR.3 | `docs/sr/system-design.md` | System Design Document |
| SR.3 | `docs/pm/purchase-order.md` | Purchase Order |
| SR.3 (optional) | `docs/sr/system-user-manual.md` | System User Manual |
| SR.5 | `docs/sr/integration-report.md` | Integration Report |
| SR.5 | `docs/sr/verification-report.md` | Verification Report |
| SR.5 | `docs/sr/validation-report.md` | Validation Report |
| SR.5 (optional) | `docs/sr/system-operation-guide.md` | System Operation Guide |
| SR.6 | `docs/sr/maintenance-guide.md` | Maintenance Documentation |
| SR.6 | `docs/sr/training-specifications.md` | System Training Specifications |

The IVV Plan is created during SR.2.9 and updated during SR.5.1.
The Traceability Matrix is created during SR.2.8 and continuously
updated through SR.3 and SR.5. The Purchase Order is the only PM
template that originates in an SR phase (SR.3.3, when a system
element will be procured).

## See also

- [[iso29110-pm-task-checklists]] for PM-process task checklists
  with these templates as outputs.
- [[iso29110-sr-task-checklists]] for SR-process task checklists.
- [[iso29110-roles-and-work-products]] for the full work-product
  catalogue including statuses.
- [[vse-canonical-project-layout]] for the directory structure
  these templates live in.
