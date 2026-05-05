---
title: "ISO/IEC TR 29110-5-6-2 compliance mapping"
slug: iso-29110-compliance-mapping
type: reference
layer: methodology
tags: [iso29110, compliance, basic-profile, pm-objectives, sr-objectives, traceability, baselines]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §9 (ISO/IEC TR 29110-5-6-2 Compliance)."
    raw: methodology/09-iso-29110-compliance.md
related:
  - methodology-overview
  - story-branch-pr-workflow
  - storymeta-lifecycle
  - project-management-workflow
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, project-setup, project-audit, release-orchestrator, project-plan]
---

# ISO/IEC TR 29110-5-6-2 compliance mapping

The VSE methodology declares partial compliance with the Basic Profile of ISO/IEC TR 29110-5-6-2:2014. It covers Project Management in full and the SR.1 to SR.3 activities of System Definition and Realization in full, plus the V&V *specification* portion of SR.5. SR.4 (Construction) and SR.6 (Product Delivery) are out of scope and shall be supplied by a separate, project-determined process. The methodology is a user-story-first, model-driven realisation of ISO 29110 obligations expressed in SysML v2, not a literal restatement of the standard. See [[methodology-overview]] for the broader frame.

## Scope of compliance (§9.2)

| ISO 29110 activity | Methodology coverage |
|---|---|
| PM.1 Project Planning | Full |
| PM.2 Project Plan Execution | Full |
| PM.3 Project Assessment and Control | Full |
| PM.4 Project Closure | Full |
| SR.1 SR Initiation | Full |
| SR.2 System Requirements Engineering | Full |
| SR.3 System Architectural Design | Full |
| SR.4 System Construction | Out of scope |
| SR.5 Integration, Verification and Validation | Specification only (execution is project-determined) |
| SR.6 Product Delivery | Out of scope |

A VSE seeking Basic Profile coverage of the entire lifecycle shall combine the methodology with a construction and delivery process matched to the product type.

## PM objective coverage (§9.3)

All eight PM objectives are satisfied in full:

- **PM.O1** (plan and SOW reviewed and accepted; tasks and resources sized) is met by the *Project Plan* artefact and the PR/review cycle that records acceptance.
- **PM.O2** (progress monitored, corrections taken, closure with Acceptance Record) is met by Assessment and Control plus Closure, with *Progress Status Record* and *Product Acceptance Record* as first-class artefacts.
- **PM.O3** (Change Requests analysed for cost, schedule, risk, technical impact) is met by the PR-based change workflow and the StoryMeta lifecycle states. See [[storymeta-lifecycle]].
- **PM.O4** (review meetings; agreements registered and tracked) is met by the *Meeting Record* artefact and the asynchronous PR review record.
- **PM.O5** (Risk Management Approach; risks identified, analysed, prioritised, monitored) is met by the Risk Management Approach integrated into the Project Plan.
- **PM.O6** (Configuration Management Strategy; baselines, releases, storage) is met by the Configuration Management Strategy and the git repository structure used as the version-control substrate.
- **PM.O7** (quality assurance through verification, validation, review tasks) is met by V&V cases throughout the model, review checklists, and CI lint and well-formedness gates.
- **PM.O8** (Disposal Management Approach) is met by the Disposal Management Approach tied to dependability concerns in the system stories.

## SR objective coverage (§9.4)

- **SR.O1** (tasks performed per current Project Plan): full.
- **SR.O2** (system requirements defined, analysed, baselined, communicated): full, baselined per story via the StoryMeta `done` status. See [[storymeta-lifecycle]].
- **SR.O3** (architectural design developed and baselined; consistency and traceability to requirements): full, with traceability via `derive`, `frame concern`, `verify`, and `allocation` relations.
- **SR.O4** (system elements produced or acquired with acceptance tests; traceability): **specification only**. Verification cases are specified, but construction of system elements is out of scope.
- **SR.O5** (system elements integrated; consistency and traceability to architecture): **specification only**. Inter-subsystem interfaces and integration tasks are referenced in the Plan, but execution is project-determined.
- **SR.O6** (System Configuration baselined and stored; change requests detected): full, via the repository, the PR workflow, and the CM Strategy.
- **SR.O7** (V&V tasks performed; defects corrected; reports stored): specification plus report templates. Verification and validation case definitions are part of the model. *Verification Report* and *Validation Report* templates are provided in §10.10. Execution-time V&V occurs at construction and is out of scope.

## Artefact mapping (§9.5)

The methodology produces SysML v2 model elements. ISO 29110 specifies information products. Many ISO products are *generated* from the model rather than authored separately, which is a deliberate property of the methodology rather than an exception:

| ISO 29110 product | Source in methodology | Form |
|---|---|---|
| Project Plan | §10.3 | Markdown referencing model packages |
| Stakeholders Requirements Specification | Stakeholder story register and concerns | SysML v2 packages, rendered to Markdown |
| System Requirements Specification | System story register | SysML v2 package with `require constraint` clauses, rendered |
| System Elements Requirements Specifications | Subsystem stories per component | Per-component packages, rendered |
| System Design Document (Functional) | Functional architecture, action defs | `core/functional-architecture/` |
| System Design Document (Physical) | Logical decomposition and allocations | `core/logical-architecture/` and `product-architecture/` |
| Justification Document | Trade studies plus per-PR ADRs | `analysis def` instances aggregated per §10.3 |
| Traceability Matrix | Generated from `derive`, `frame`, `satisfy`, `verify`, `allocation` relations | Auto-generated artefact |
| IVV Plan | Verification and validation case sets | SysML v2 `verification def` set, rendered |
| IVV Procedures | Verification action bodies | Rendered per case |
| Change Request | Story branch plus PR plus StoryMeta state transitions | Git branch, PR, commit metadata |
| Meeting Record | §10.4 | Markdown notes in `docs/meetings/` |
| Progress Status Record | Per iteration | Markdown log |
| Product Acceptance Record | §10.6 | Signed Markdown record at closure |
| System Configuration | Tagged git commit, resolved variation set | Tag plus manifest |
| System, System Element, Integration Report, User Manual | Construction or delivery outputs | Out of scope; templates only |

The Stakeholders Requirements Spec, System Requirements Spec, Justification Document, and Traceability Matrix are all auto-generated from the model. Documentation lag is structurally impossible because the model is the source of truth. The renderer itself is a methodology artefact, lives in `tools/`, and is reviewed under the same PR discipline as the model.

## Lifecycle interpretation (§9.9)

ISO 29110-5-6-2 §6 states that the Basic Profile is intended to be used with any lifecycle, including waterfall, iterative, incremental, evolutionary, and agile. The standard is methodology-neutral. The compliance question is therefore whether the ISO process objectives are met across iterations, not whether iteration is permitted.

The methodology meets the objectives across iterations as follows:

- **PM.O1** is performed once at project start and re-confirmed at each significant Plan revision via the Change Request loop. The Project Plan is a living artefact with an immutable git history.
- **SR.O2** is performed *per story*. Each story is baselined at the moment its StoryMeta transitions to `done`. The system therefore has a rolling baseline, the merged model on `main`, with each story contributing to it incrementally. See [[storymeta-lifecycle]].
- Each release tags a baselined snapshot. Tagged releases are System Configurations in ISO terms.
- **SR.O3** is performed at each iteration that completes a trade study or decomposition. The resolved architecture is the baseline, updated through Change Requests when subsequent iterations reopen a decision.

ISO 29110 does not require all requirements to be baselined before any design, only that each requirement, when present, is analysed, approved, baselined, and traced. Iterative authoring is fully consistent with the standard. See [[story-branch-pr-workflow]] and [[project-management-workflow]] for the operational shape of this loop.

## Compliance automation (§9.10)

ISO 29110 compliance is mechanically enforced rather than periodically audited. The hook set documented in `iso-29110-hooks-guide.md` covers:

- **Pre-commit and pre-push gates** that block commits violating artefact well-formedness, StoryMeta lifecycle rules, or Traceability Matrix consistency.
- **Claude Code session and tool hooks** that nudge author and reviewer behaviour toward ISO-compliant authoring patterns, including Change Request creation before edits to baselined artefacts, V&V case authoring after story changes, and Meeting Record creation after synchronous reviews.
- **CI generators** that produce ISO documents from the model on merge to `main`, ensuring model-derived artefacts (Stakeholders Reqs Spec, System Reqs Spec, Traceability Matrix, IVV Plan, IVV Procedures) are always current.

The hooks guide is the operational complement to this compliance section.

## Limitations of the compliance claim (§9.12)

This section documents *methodology* compliance. It asserts that a project executed in accordance with the methodology can satisfy the ISO 29110 Basic Profile objectives within the scope declared above. It does *not*:

- guarantee that any specific project's artefacts are ISO-compliant at any given moment,
- substitute for an ISO 29110 assessment per ISO/IEC TR 29110-3, or cover the parts of the standard outside the declared scope (notably SR.4 Construction and SR.6 Product Delivery).

A VSE seeking certification per ISO/IEC TR 29110-3 shall (1) adopt this methodology for SR.1 to SR.3 and PM, (2) extend it with a construction and delivery process appropriate to the product type, and (3) submit to formal assessment. Methodology compliance, project compliance, and formal assessment are three separate claims and shall not be conflated.
