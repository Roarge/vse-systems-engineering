# 9. ISO/IEC TR 29110‑5‑6‑2 Compliance

## 9.1 Purpose

This section demonstrates how the methodology specified in §0–§8 (and
the Project Management process specified in §10) satisfies the Basic
Profile of ISO/IEC TR 29110‑5‑6‑2:2014 — *Systems and software
engineering — Lifecycle profiles for Very Small Entities (VSEs) — Part
5‑6‑2: Systems engineering — Management and engineering guide: Generic
profile group: Basic profile*. It provides:

- the objective-by-objective coverage matrix for both ISO 29110
  processes (Project Management and System Definition and Realization);
- the artefact mapping from our SysML v2 model elements to ISO 29110
  product types;
- the role mapping;
- a gap analysis with stated remediations;
- the lifecycle interpretation that reconciles our iteration-driven,
  user-story-first approach with the ISO 29110 process structure.

The methodology is not a literal restatement of ISO 29110. It uses
ISO 29110 as a normative reference for the process and artefact set
that a VSE-scale systems engineering effort shall produce. Our
contribution is the user-story-first, model-driven realisation of
those obligations in SysML v2.

## 9.2 Scope of compliance

ISO 29110‑5‑6‑2 covers the systems engineering lifecycle from project
initiation through disposal. This methodology covers a defined subset
of that lifecycle. The boundary is:

| ISO 29110 activity | Methodology coverage |
|---|---|
| PM.1 Project Planning | §10 (full) |
| PM.2 Project Plan Execution | §10 + §8 (full) |
| PM.3 Project Assessment and Control | §10 (full) |
| PM.4 Project Closure | §10 (full) |
| SR.1 System Definition and Realization Initiation | §10.3 + §0.6 (full) |
| SR.2 System Requirements Engineering | §1, §3, §4, §5 (full) |
| SR.3 System Architectural Design | §6, §7 (full) |
| SR.4 System Construction | **Out of scope** — handed off to detailed design (§0.9) |
| SR.5 System Integration, Verification and Validation | §5.4.6, §7 (V&V *specification*); execution is project-determined |
| SR.6 Product Delivery | **Out of scope** — handed off |

The methodology is therefore a *partial* implementation of the Basic
Profile, complete for SR.1–SR.3 and PM, and providing the V&V
*specification* (cases, plans, procedures) that SR.5 requires for
execution. SR.4 (Construction) and SR.6 (Product Delivery) are
declared out of scope; a project that needs Basic Profile certification
across the full lifecycle shall combine this methodology with a
construction and delivery process appropriate to its product type.

## 9.3 PM objective coverage

| ISO objective | Coverage | Methodology element(s) |
|---|---|---|
| PM.O1 — Plan and SOW reviewed and accepted; tasks and resources sized | Full | §10.3 Project Planning produces *Project Plan* with §10.3.1–§10.3.13 elements; PR/review cycle (§8.5–§8.6) provides acceptance |
| PM.O2 — Progress monitored; corrections taken; closure with Acceptance Record | Full | §10.5 Assessment and Control; §10.6 Closure; *Progress Status Record* and *Product Acceptance Record* are first-class artefacts |
| PM.O3 — Change Requests received, analysed for cost/schedule/risk/technical impact | Full | §10.4 Plan Execution (Change Request lifecycle); §8.4–§8.5 (PR-based change workflow); §1 lifecycle StoryMeta states |
| PM.O4 — Review meetings; agreements registered and tracked | Full | §10.4 Plan Execution; *Meeting Record* artefact; PR review (§8.6) provides asynchronous review record |
| PM.O5 — Risk Management Approach; risks identified, analysed, prioritised, monitored | Full | §10.7 Risk Management Approach; integrated into Project Plan |
| PM.O6 — Product/Configuration Management Strategy; baselines, releases, storage | Full | §10.8 Configuration Management Strategy; §8.3 Repository structure; git as the version-control substrate; StoryMeta lifecycle |
| PM.O7 — Quality Assurance via verification, validation, review tasks | Full | V&V cases throughout §4–§7; review checklists in §8.6; CI lint and well-formedness gates |
| PM.O8 — Disposal Management Approach to end existence of system entity | Full | §10.9 Disposal Management Approach; ties to dependability concerns in §5.4.5 |

## 9.4 SR objective coverage

| ISO objective | Coverage | Methodology element(s) |
|---|---|---|
| SR.O1 — Tasks performed per current Project Plan | Full | §10.3 Project Plan integrates §1–§7 task structure; SR Initiation in §10.3 |
| SR.O2 — System requirements defined, analysed, baselined, communicated | Full | §1 (UserStory base type); §4 (stakeholder stories + concerns); §5 (system stories with `require constraint`); StoryMeta lifecycle baselines via `done` status |
| SR.O3 — System architectural design developed and baselined; consistency and traceability to requirements | Full | §6 (architectural analysis with `variation`/`variant`); §7 (subsystem decomposition with allocation); Traceability via `derive`, `frame concern`, `verify`, `allocation` |
| SR.O4 — System elements produced/acquired with acceptance tests; traceability | Specification only | §5.4.6 and §7 specify verification cases. *Construction* of system elements is out of scope per §9.2 |
| SR.O5 — System elements integrated; consistency and traceability to architecture | Specification only | §7.3.4 inter-subsystem interfaces; §10.4 references SR.5 integration tasks in the Plan. *Execution* is project-determined |
| SR.O6 — System Configuration baselined and stored; change requests detected | Full | §8.3 repository; §8.4–§8.6 PR workflow; §10.8 CM Strategy; StoryMeta lifecycle |
| SR.O7 — V&V tasks performed; defects corrected; reports stored | Specification + report templates | §4.3.6, §5.4.6, §7 V&V case definitions; *Verification Report* and *Validation Report* artefact templates in §10.10 |

## 9.5 Artefact mapping

The methodology produces SysML v2 model elements; ISO 29110 specifies
information products. Many ISO products are *generated* from the model
rather than authored separately. The mapping:

| ISO 29110 product | Source in methodology | Form |
|---|---|---|
| Statement of Work | Project initiation; outside the formal model | Markdown / customer-supplied document |
| Project Plan | §10.3 | Markdown document referencing model packages |
| Systems Engineering Management Plan (SEMP) | §10.3 (sub-section of Project Plan, or separate) | Markdown; references model |
| Stakeholders Requirements Specifications | §4 stakeholder story register + concerns | SysML v2 packages: `core/stories/stakeholder/`, `core/concerns/`; rendered to Markdown for delivery |
| System Requirements Specifications | §5 system story register | SysML v2 package `core/stories/system/` with `require constraint` clauses; rendered |
| System Elements Requirements Specifications | §7 subsystem stories per component | SysML v2 packages under `core/logical-architecture/components/<comp>/stories/`; rendered per component |
| System Design Document — Functional Architecture | §6 functional architecture; §5 action defs | `core/functional-architecture/` package |
| System Design Document — Physical Architecture | §7 logical architecture (decomposition + allocations) | `core/logical-architecture/` package; `product-architecture/` for physical |
| Justification Document | §6 trade studies + design rationale | `analysis def` instances in `model/variations/trade-studies/` + per-PR ADRs (Architecture Decision Records); §10.3 specifies aggregation |
| Traceability Matrix | Generated from `derive`, `frame`, `satisfy`, `verify`, `allocation` relations | Auto-generated artefact; see §9.8 |
| IVV Plan | §4.3.6 + §5.4.6 verification/validation case sets | SysML v2 `verification def` set; rendered as IVV Plan |
| IVV Procedures | §5.4.6 verification action bodies | `verification def` action body; rendered per case |
| System | Realised system (Construction phase output) | Out of scope artefact; produced downstream |
| System Element | Subsystem realisation | Out of scope artefact |
| System Configuration | Tagged git commit; resolved variation set | Tag + manifest; §8 repository structure |
| Verification Report | Execution of verification cases | Generated; §10.10 template |
| Validation Report | Execution of validation cases | Generated; §10.10 template |
| Integration Report | Execution of integration tests | Out of scope (SR.4/SR.5 execution); template provided in §10.10 |
| System Operation Guide | Project-determined; references model | Out of scope (delivery artefact); §10.10 template |
| System User Manual | Project-determined; references model | Out of scope; §10.10 template |
| System Maintenance Document | Project-determined | Out of scope; §10.10 template |
| System Training Specifications | Project-determined | Out of scope; §10.10 template |
| Change Request | §8.4 story branch + PR + StoryMeta state transitions | Git branch + PR + commit metadata |
| Correction Register | §10.5 deviations log | Markdown log committed to repository |
| Progress Status Record | §10.5 iteration cadence | Markdown log; per-iteration |
| Meeting Record | §10.4 | Markdown notes committed to `docs/meetings/` |
| Product Acceptance Record | §10.6 | Signed Markdown record committed at closure |
| Project Repository | §8.3 git repository structure | Git repository |
| Project Repository Backup | §10.8 CM Strategy | Mirror remote / backup of git repository |
| Purchase Order | §10.4 (procurement) | Markdown / external system; out of model |
| Disposed System | §10.9 Disposal Management Approach execution | Operational record |
| Data Model | Implicit in §1 (StoryMeta), §3 (item defs), throughout | SysML v2 model; explicit data model package optional |
| Implementation Environment | §8.3 `tools/` + repository tooling | Setup scripts + documentation |

## 9.6 Role mapping

| ISO 29110 role | Methodology equivalent | Notes |
|---|---|---|
| Acquirer (ACQ) | Stakeholder typed by part def in `core/stakeholders/`, distinguished by participation in PM/PR review | Distinguished operationally, not as a separate type |
| Stakeholder (STK) | Any `part def` in `core/stakeholders/`; also actors via §3 | One-to-one |
| Project Manager (PJM) | Owner of §10 PM activities; CODEOWNERS for `Project Plan`, *Progress Status Record* | Operational role |
| Systems Engineer (SYS) | Owner of §1, §4, §5 author work; CODEOWNERS for `core/stories/`, `core/concerns/`, `core/context/` | Operational role |
| Designer (DES) | Owner of §6, §7 author work; CODEOWNERS for `core/logical-architecture/`, `core/functional-architecture/`, `model/variations/` | Operational role |
| Developer (DEV) | Out of scope (Construction) | Engaged at handoff |
| IVV Engineer (IVV) | Owner of `core/verification-validation/`; reviews V&V cases | Operational role |
| Supplier (SUP) | Out of scope; engaged at handoff for purchased system elements | — |
| Work Team (WT) | Aggregate role: SYS + DES + IVV (+ DEV/SUP when in scope) | Used in PM tasks |

ISO 29110 emphasises that "several roles may be played by a single
person and one role may be assumed by several persons." The
methodology preserves this: in a small VSE the PJM, SYS, and DES roles
are routinely performed by one person; CODEOWNERS reflects the
*assignment* of responsibility to a git identity rather than to a
distinct individual.

## 9.7 Gap analysis

The methodology was originally drafted without explicit reference to
ISO 29110. The compliance pass identifies the following gaps and
their resolutions:

| Gap | Resolution |
|---|---|
| No explicit Project Plan artefact | §10.3 introduces *Project Plan* as a Markdown artefact composing every ISO-required element |
| No Risk Management Approach | §10.7 added |
| No Disposal Management Approach | §10.9 added |
| No Configuration Management Strategy as a labelled artefact | §10.8 formalises the strategy that §8.3 implements |
| Justification Document not a labelled artefact | §10.3 adds the Justification Document as an aggregated artefact composed from trade-study `analysis def` instances and per-PR ADRs |
| Traceability Matrix not a labelled artefact | §9.8 specifies how the Matrix is generated from model relations |
| SR.4 Construction and SR.6 Delivery uncovered | Declared out of scope per §9.2; project-set determines the construction/delivery process |
| Integration Report, System Operation Guide, etc. not produced | §10.10 provides templates; production is out-of-scope downstream task |
| Meeting Record discipline unspecified | §10.4 specifies the *Meeting Record* artefact |
| Progress Status Record not a labelled artefact | §10.5 specifies it; produced per iteration |

## 9.8 Model-derived artefacts

ISO 29110 expects certain artefacts as documents. The methodology is
model-driven; several ISO documents are *generated* from the model
rather than authored. The generators read SysML v2 relations and
produce the document.

| ISO document | Derivation source | Mechanism |
|---|---|---|
| Stakeholders Requirements Specifications | `core/stories/stakeholder/` + `core/concerns/` | Render each `requirement def :> UserStory` with its narrative fields, framed concerns, acceptance criteria |
| System Requirements Specifications | `core/stories/system/` | Same renderer, applied to system stories |
| System Elements Requirements Specifications | `core/logical-architecture/components/<comp>/stories/` | Per-component render |
| System Design Document — Functional Architecture | `core/functional-architecture/` | Render of `action def` graph + relationships |
| System Design Document — Physical Architecture | `core/logical-architecture/` | Render of part decomposition + interfaces + allocations |
| Traceability Matrix | `derive`, `frame concern`, `satisfy`, `verify`, `allocation` relations across the model | Query model for relation tuples; tabulate |
| IVV Plan | `core/verification-validation/verification-cases/` + `validation-cases/` | Render verification def set with subjects and objectives |
| IVV Procedures | Verification def action bodies | Render per case |

Two consequences:

- **Documentation lag is structurally impossible.** The model is the
  source of truth; document drift happens only if the renderer is
  out-of-date, not because the document was forgotten.
- **The renderer is itself a methodology artefact.** It belongs in
  `tools/` (per §8.3) and is reviewed under the same PR discipline as
  the model.

The Traceability Matrix in particular: ISO 29110 product description
27 specifies it as *the* artefact documenting the relationship between
engineering and IVV artefacts. In our methodology this is *not*
authored — it is queried from the model. A typical render shows for
each requirement:

```
| Stakeholder Story | derives→ | System Story | derives→ | Subsystem Story | verify| Verification Case | satisfy| System Element |
|---|---|---|---|---|---|---|---|---|
| US_042       | →         | SYS_142      | →         | ALM_001         | ←        | VC_BatchAck       | ←        | AlarmManagementSubsystem |
```

The matrix is regenerated on every commit that touches the model
(§9.10 hook automation).

## 9.9 Lifecycle interpretation — agile within ISO 29110

ISO 29110‑5‑6‑2 §6 explicitly states the Basic Profile is intended to
be used with "any lifecycles such as: waterfall, iterative,
incremental, evolutionary or agile." It is methodology-neutral. The
compliance question is therefore *not* whether our iterative
approach is permitted (it is) but whether the ISO process objectives
are met *across iterations* rather than within a single linear pass.

This methodology meets the objectives as follows:

- **PM.O1 (plan accepted)** is performed once per project at the start
  and re-confirmed at each significant Plan revision (per PM.2 Change
  Request loop). The Project Plan is a living artefact under git
  control with an immutable history.

- **SR.O2 (requirements baselined)** is performed *per story* at the
  moment the story transitions to `done` status. The system has a
  rolling baseline (the merged model on `main`), with each story
  contributing to it incrementally. Baselined snapshots are tagged
  releases.

- **SR.O3 (architectural design baselined)** is performed at each
  iteration that completes a §6 trade study or §7 decomposition. The
  resolved architecture (§6.3.6) is the baseline; it is updated
  through Change Requests when subsequent iterations reopen a
  decision.

- **SR.O5 (system elements integrated)** — the methodology specifies
  V&V cases that exercise the integrated system; physical integration
  itself happens in the construction process (out of scope) and is
  governed by the Plan.

- **SR.O7 (V&V performed)** — every PR runs the relevant verification
  cases (§9.10 hooks); execution-time V&V occurs at construction
  (out of scope).

ISO 29110 does not require "all requirements baselined before any
design" — it requires that each requirement, when present, is
analysed, approved, baselined, and traced. Iterative authoring is
fully consistent with this.

## 9.10 Compliance automation

The methodology is designed for ISO 29110 compliance to be
mechanically enforced rather than periodically audited. The set of
hooks specified in `iso-29110-hooks-guide.md` covers:

- **Pre-commit and pre-push gates** that block commits violating
  artefact well-formedness, Story Meta lifecycle, or Traceability
  Matrix consistency.
- **Claude Code session and tool hooks** that nudge author and
  reviewer behaviour toward ISO-compliant authoring patterns
  (Change Request before editing baselined artefacts, V&V case
  authoring after story changes, Meeting Record creation after
  synchronous reviews).
- **CI generators** that produce ISO documents from the model on
  merge to `main`, ensuring §9.8 model-derived artefacts are always
  current.

The hooks guide is the operational complement to this compliance
section.

## 9.11 Audit trail

For audit purposes, the following items shall be preservable from the
git repository for the lifetime of the project plus the contractually
required retention period:

- Every PR, with its review history, CI logs, and merge commit;
- The full git history (no force-pushes to protected branches);
- Tagged releases (System Configurations);
- Generated documents (rendered Markdown of derived artefacts) on a
  per-tag basis;
- The hook configuration that was in force at the time of each tag.

These are operational concerns met by standard repository hygiene
(disabling force-push on `main`, retaining CI logs, etc.); they are
not specific to ISO 29110 but are *prerequisites* for using a git
repository as the audit record.

## 9.12 Limitations of this compliance claim

This section documents *methodology* compliance — it asserts that a
project executed in accordance with §0–§8 and §10 can satisfy the
ISO 29110‑5‑6‑2 Basic Profile objectives within the scope declared in
§9.2. It does *not*:

- guarantee that any specific project's artefacts are ISO-compliant
  at any given moment;
- substitute for an ISO 29110 assessment per ISO/IEC TR 29110‑3;
- cover the parts of the standard outside the scope of §9.2 (notably
  SR.4 Construction and SR.6 Product Delivery).

A VSE seeking certification per ISO/IEC TR 29110‑3 shall:

1. adopt this methodology for SR.1–SR.3 and PM,
2. extend it with a construction and delivery process appropriate to
   the product type, and
3. submit to assessment per ISO/IEC TR 29110‑3.

---

*End of Section 9.*
