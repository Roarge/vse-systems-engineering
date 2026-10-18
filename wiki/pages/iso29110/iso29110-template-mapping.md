---
title: "ISO/IEC 29110 Phase to Template Mapping"
slug: iso29110-template-mapping
type: reference
layer: iso29110
summary: Quick reference linking each ISO/IEC 29110 phase to its work products and to where each one lives in a project
tags: [iso29110, templates, work-products, project-setup]
sources:
  - citation: "ISO/IEC TR 29110-5-6-2:2014, work-product catalogue, plus the plugin's templates/common/ scaffolding."
    raw: "ISOIEC TR 29110-5-6-22014.pdf"
related:
  - iso29110-pm-task-checklists
  - iso29110-sr-task-checklists
  - iso29110-roles-and-work-products
  - vse-canonical-project-layout
confidence: high
created: 2026-05-04
updated: 2026-10-18
referenced_by: [project-setup, release-orchestrator]
---

# ISO/IEC 29110 Phase to Template Mapping

Quick reference linking each ISO/IEC 29110 phase to the work products
it produces and to where each one lives in a project: a markdown file
under `docs/`, a document rendered from the model into
`docs/generated/`, a GitHub Issue, the SysML model itself, or a
template the project copies when it needs the document. The plugin
keeps its templates in `templates/pm/` and `templates/sr/`. A
project's work products sit under `docs/` (or `engineering/docs/` in
brownfield layouts), one file per document directly in it, apart from
the rendered documents in `docs/generated/` and the meeting records
and the verification and validation reports in their own folders.
`@project-setup` writes the documents of the project's profile, and a
skill whose steps name another document's template starts that
document from it. Where no skill names a template, the project copies
it into `docs/` when it needs the document. For the full canonical
project layout, see [[vse-canonical-project-layout]].

## PM phase templates

| Phase | Location in the project | Work product |
|---|---|---|
| PM.1 | the plugin ships the template at `templates/pm/statement-of-work.md` and the project copies it into `docs/` when it needs the document | Statement of Work |
| PM.1 | `docs/project-plan.md` | Project Plan |
| PM.1-PM.4 | one file per meeting under `docs/meetings/` | Meeting Record |
| PM.2 | `docs/progress-status-record.md` | Progress Status Record |
| PM.2 | a GitHub Issue labelled `change-request` (methodology §10.4.2), not a file | Change Request |
| PM.3 | `docs/correction-register.md` | Correction Register |
| PM.3 / SR.3 | `docs/justification-document.md` | Justification Document |
| PM.4 | `docs/product-acceptance-record.md` | Product Acceptance Record |

The Justification Document spans PM.3 (project assessment) and
SR.3 (architecture trade-offs). The plugin uses a single document
in both phases with section-level discipline rather than two
disjoint files.

## SR phase templates

| Phase | Location in the project | Work product |
|---|---|---|
| SR.1 | `docs/semp.md` | SEMP |
| SR.1 | the SysML model, with an optional explicit data model package (methodology §9.5) | Data Model |
| SR.2 | `docs/generated/stakeholder-requirements.md`, rendered from the model | StRS |
| SR.2 | `docs/generated/system-requirements.md`, rendered from the model | SyRS |
| SR.2 | the plugin ships the template at `templates/sr/system-element-requirements.md` and the project copies it into `docs/` when it needs the document | System Elements Requirements |
| SR.2+ | `docs/generated/traceability-matrix.md`, rendered from the model | Traceability Matrix |
| SR.2/SR.5 | `docs/ivv-plan.md` | IVV Plan |
| SR.3 | `docs/system-design.md` | System Design Document |
| SR.3 | its template is kept in `docs/templates/` (methodology §10.10) | Purchase Order |
| SR.3 (optional) | its template is kept in `docs/templates/` (methodology §10.10) | System User Manual |
| SR.5 | the plugin ships the template at `templates/sr/integration-report.md` and the project copies it into `docs/` when it needs the document | Integration Report |
| SR.5 | `docs/verification-reports/<case>-<date>.md`, one per run | Verification Report |
| SR.5 | `docs/validation-reports/<case>-<date>.md`, one per run | Validation Report |
| SR.5 (optional) | its template is kept in `docs/templates/` (methodology §10.10) | System Operation Guide |
| SR.6 | `docs/maintenance-guide.md` | Maintenance Documentation |
| SR.6 | its template is kept in `docs/templates/` (methodology §10.10) | System Training Specifications |

The IVV Plan is created during SR.2.9 and updated during SR.5.1.
The Traceability Matrix is created during SR.2.8 and continuously
updated through SR.3 and SR.5. The Purchase Order is the only PM
work product that originates in an SR phase (SR.3.3, when a system
element will be procured).

## See also

- [[iso29110-pm-task-checklists]] for PM-process task checklists
  with these templates as outputs.
- [[iso29110-sr-task-checklists]] for SR-process task checklists.
- [[iso29110-roles-and-work-products]] for the full work-product
  catalogue including statuses.
- [[vse-canonical-project-layout]] for the directory structure
  these templates live in.
