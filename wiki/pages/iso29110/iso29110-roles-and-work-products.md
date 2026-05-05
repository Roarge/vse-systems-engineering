---
title: "ISO/IEC 29110 Roles and Work Products"
slug: iso29110-roles-and-work-products
type: reference
layer: iso29110
tags: [iso29110, roles, work-products, pm, sr]
sources:
  - citation: "ISO/IEC TR 29110-5-6-2:2014, Roles and Work Products tables."
    raw: ISO_IEC_TR_29110-5-6-2_2014.pdf
related:
  - iso29110-overview
  - iso29110-pm-process
  - iso29110-sr-process
  - iso29110-template-mapping
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [project-setup, release-orchestrator]
---

# ISO/IEC 29110 Roles and Work Products

## Roles

| Role | Abbreviation | Key responsibilities |
|---|---|---|
| Acquirer | ACQ | Stakeholders representative responsible for acquisition. Authority to approve requirements and changes. |
| Designer | DES | Architecture design, revision techniques, integration test planning, editing, system development and maintenance. |
| Developer | DEV | Fabrication and development (HW, SW). Application domain knowledge. |
| IVV Engineer | IVV | Requirements and design knowledge. Inspection, peer review, simulation, review, and testing techniques. |
| Project Manager | PJM | Leadership, decision making, planning, delegation, supervision, finances, and system development. |
| Stakeholder | STK | Actors with interest in the system throughout its life cycle (users, maintainers, trainers, regulators, suppliers). Authority to approve requirements. |
| Supplier | SUP | Supplier of a system element (hardware, software, or hardware with software). |
| Systems Engineer | SYS | Requirements elicitation, specification, and analysis. User interface design, revision techniques, requirements authoring, business domain, system development and integration. |
| Work Team | WT | Knowledge and experience according to project roles (SYS, DES, DEV, IVV). Knowledge of applicable standards. |

**PM-process roles**: ACQ, STK, PJM, WT, DES, SYS.

**SR-process roles**: ACQ, SYS, DES, DEV, IVV, PJM, STK, SUP, WT.

## PM work products

| Product | Type | Statuses |
|---|---|---|
| Statement of Work (SOW) | Input | reviewed |
| Project Plan | Input/Output/Internal | verified, accepted, updated, reviewed |
| Product Acceptance Record | Output/Internal | approved, published |
| Project Repository | Output/Internal | established, recovered, updated, baselined |
| Project Repository Backup | Internal | (no status) |
| Meeting Record | Output/Internal | published, updated |
| Change Request | Input/Internal | submitted, evaluated, agreed, approved, rejected, postponed |
| Correction Register | Internal | initial, published |
| Justification Document | Internal | initial, published |
| Progress Status Record | Internal | evaluated |
| Verification Report | Internal | published |
| Purchase Order | Output | initiated, approved |
| Product | Output | delivered, accepted |
| Disposed System | Output | (no status) |

## SR work products

| Product | Type | Statuses |
|---|---|---|
| Implementation Environment | Internal | (no status) |
| Data Model | Internal | (no status) |
| Systems Engineering Management Plan (SEMP) | Internal | verified, accepted, reviewed |
| Stakeholders Requirements Specifications | Internal | initiated, verified, validated, approved, baselined |
| System Requirements Specifications | Internal | initiated, verified, validated, baselined |
| System Elements Requirements Specifications | Internal | initiated, verified, validated, baselined |
| System Design Document (Functional and Physical Architecture) | Internal | verified, validated, baselined |
| Justification Document (architecture trade-offs) | Internal | initial, published |
| IVV Plan | Internal | verified, published |
| IVV Procedures | Internal | verified, accepted, updated, reviewed |
| Traceability Matrix | Internal | verified, baselined, updated |
| Bought/built/re-used System Elements (HW, HW+SW) | Internal | verified, accepted, rejected |
| System | Internal | integrated, verified, validated, corrected, approved |
| Integration Report | Internal | published |
| Verification Report | Internal | published |
| Validation Report | Internal | published |
| System User Manual | Internal | preliminary, verified, baselined |
| System Operation Guide | Internal | preliminary, verified, baselined |
| System Maintenance Document | Internal | preliminary, verified, validated |
| System Training Specifications | Internal | initiated, verified, validated, baselined |
| System Configuration | Internal | (no status) |
| Product Acceptance Record | Internal | approved, published |

## See also

- [[iso29110-overview]] for the profile context.
- [[iso29110-pm-process]] and [[iso29110-sr-process]] for the
  activities each role and work product participates in.
- [[iso29110-template-mapping]] for the file paths under
  `docs/pm/` and `docs/sr/` where each work product lives in a
  scaffolded VSE project.
