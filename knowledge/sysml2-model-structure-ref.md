# SysML v2 Model Structure Reference

AMBSE canonical model organisation for VSE projects, with base-architecture
reuse, federation, namespace hygiene, risk modelling, variant modelling
organisation, and model-level configuration management.

Primary sources, in declining authority order for structural decisions:

1. Douglass, B.P. (2016) *Agile Systems Engineering*, Elsevier, Ch 3.2.5
   "Model Organization Matters" and Ch 8.3 "Gather Subsystem Specification
   Data". Fig 3.13 "Canonical system engineering model organization" is
   the primary SE-model figure. Figs 3.14, 8.2, 8.4 cover subsystem layout
   and federation.
2. Douglass, B.P. (2021) *Agile MBSE Cookbook*, Packt, Ch 1 recipes
   "Organizing the systems model" and "Architecture 0". Figs 1.35-1.41
   walk a canonical example through SE, shared, and subsystem models.
3. Weilkiens, T. and Molnár, V. (2026-03) *The SysML v2 Book*, MBSE4U,
   Ch 14 for `:>` (definition specialisation) and `:>>` (usage
   redefinition), Chs 15-16 for namespace hygiene, Ch 35 for variant
   syntax (see `sysml2-variants-ref.md`).
4. Weilkiens, T. (2016) *Variant Modeling with SysML*, MBSE4U, Chs 2-3
   (VAMOS). Read for the Core / Variations / Configurations organisation
   concept only. VAMOS v1 stereotypes (`«variation»`, `«variant»`,
   `«variantConfiguration»`, `«variationPoint»`, `«XOR»`, `«REQUIRES»`)
   are **not** reproduced. Ch 35 of *The SysML v2 Book* is the SysML 2.0
   syntax authority.
5. ISO/IEC TR 29110-5-6-2:2014 PM.1.11, PM.1.13, PM.1.18, PM.2.3, PM.2.5,
   PM.O5, PM.O6, SR.O6. See `knowledge/iso29110-profile.md`.
6. Galinier, A. et al. (2024) *Systems Engineering Practices for Small
   and Medium Enterprises* for VSE-scale risk and reuse practice.

All claims paraphrase the sources. Verbatim material longer than ~30 words
is avoided. Do not redistribute the source PDFs.

---

## 1. Why a Canonical Structure (ASE 2016 Ch 3.2.5)

Reorganising a model late in a project is unscheduled rework, and the
cost grows with every reference that must be rewired. Douglass recommends
deciding the structure early, once the project's shape is known. The
decision factors are: project size, single-model versus multi-model,
single-product versus product-family, co-located versus distributed team,
information hiding between subsystems, and how architectural decisions
will be enforced across the team (ASE 2016, Ch 3.2.5).

Douglass offers a rule of thumb: teams of 15 or fewer can work with a
single SE model, teams of 20 or more benefit from multiple connected
models. For VSEs the default is a single SE model. Section 4 explains
when to federate.

---

## 2. The AMBSE Canonical Layout (ASE 2016 Fig 3.13, Cookbook 2021 Fig 1.35)

Both primary sources converge on the same top-level package set, with minor
wording differences. The VSE-adapted canonical layout has **ten mandatory
top-level packages** for the SE model, **one model overview file** at the
root, and **three optional top-level packages** that are scaffolded only
when the project needs them.

### 2.1 Mandatory top-level packages

| Package | Purpose | Source |
| --- | --- | --- |
| `{{sc}}_Actors` | Actor part defs, external systems, operators | Cookbook 2021 Fig 1.35 Actor Package |
| `{{sc}}_StakeholderNeeds` | Stakeholder needs with `subject` pointing at the system of interest | ASE 2016 Fig 3.13, ISO 29110 SR.2.1 |
| `{{sc}}_UseCases` | Use cases and use case diagrams | Cookbook 2021 Fig 1.35 Use Case Diagrams Package |
| `{{sc}}_Requirements` | System requirements with `satisfy` links to stakeholder needs | ASE 2016 Fig 3.13 Requirements Package |
| `{{sc}}_FunctionalAnalysis` | One nested package per use case analysis | ASE 2016 Fig 3.13, Cookbook 2021 Fig 1.35 |
| `{{sc}}_ArchAnalysis` | Architectural trade studies, one nested package per trade | ASE 2016 Fig 3.13 Architecture Package (trade half) |
| `{{sc}}_ArchDesign` | The selected architecture, one nested package per subsystem | ASE 2016 Fig 3.13 ArchDesign, Cookbook 2021 Fig 1.35 |
| `{{sc}}_Interfaces` | Logical interfaces and the logical data schema | ASE 2016 Fig 3.13, Cookbook 2021 Fig 1.35 |
| `{{sc}}_Verification` | Verification cases with `verify` links | Plugin traceability chain, ASE 2016 Ch 8.3 handoff |
| `{{sc}}_Risks` | Risk register with `RiskInfo` metadata applied | ISO 29110 PM.O5, PM.1.11; Galinier et al. |

The short-code prefix `{{sc}}_` is the namespace-hygiene discipline from
Section 5. A VSE project for a hydrogen sensor uses `HS_Actors`,
`HS_Requirements`, and so on.

### 2.2 Root model overview file

Cookbook 2021 Fig 1.36 recommends a model overview diagram at the outermost
level, with hyperlinks to key tables and diagrams. The plugin materialises
this as a `{{sc}}_Model` file that carries a `doc` comment pointing at the
overview diagram and cross-links each top-level package. It holds no
engineering content of its own.

### 2.3 Optional top-level packages

Three top-level packages are scaffolded only when the project needs them:

- **`{{sc}}_BaseArchitecture`** when the project inherits from a prior
  programme (Section 3).
- **`{{sc}}_Configurations`** when the project carries product-line
  variants (Section 6). Variation definitions themselves stay inline in
  the owning AMBSE package per the Chapter 35 rule.
- **`{{sc}}_CM`** when the project declares model-level configuration
  items or baselines (Section 7).

### 2.4 Why workflow-centric rather than phase-sequential

Every package in the mandatory set is named for a **kind of work** rather
than a lifecycle phase. AMBSE iterations routinely edit several packages
concurrently. A phase-sequential layout fights this concurrency. See
Section 9 and `knowledge/iteration-centred-operation.md`.

---

## 3. Base Architecture Reuse (SysML v2 Book Ch 14, ASE 2016 Ch 8.3)

Projects are rarely greenfield. A base architecture records decisions that
an earlier programme has already made, and it constrains the solution space
for the next project (SysML v2 Book, Ch 14.1). The pattern is a first-class
SysML 2.0 concern.

### 3.1 Base architecture as a top-level peer package

The plugin treats `{{sc}}_BaseArchitecture` as an **optional top-level peer**
of `{{sc}}_ArchDesign`, not as an inner folder. This matches Douglass's
shared-repository philosophy, in which reusable content is a peer of the
SE model rather than a subdirectory inside it (ASE 2016 Fig 3.12), while
adopting the Chapter 14 specialisation syntax from SysML v2.

The base is populated only when the project genuinely inherits an
architecture. A greenfield project does not carry an empty base package.

### 3.2 Specialisation operators

SysML 2.0 provides two operators for reuse (SysML v2 Book, Ch 14.2,
pp 56-58):

| Operator | Applies to | Meaning |
| --- | --- | --- |
| `:>` | definitions | This definition specialises another |
| `:>>` | usages | This usage redefines an inherited usage |

Use `:>` to state that a new part definition extends or specialises a
base part definition. Use `:>>` inside a part body to redefine a usage
inherited from the specialised parent.

```sysml
package HS_ArchDesign {
    private import HS_BaseArchitecture::BaseSensorSystem;
    private import HS_BaseArchitecture::Operator;

    part def SensorSystem :> BaseSensorSystem {
        part :>> sensors[2];      // override inherited multiplicity
        part :>> operator : Operator;
    }
}
```

### 3.3 System context is methodological

Ch 14.2 treats the system context as a methodological wrapper, not a
SysML keyword. In the canonical layout it lives inside
`{{sc}}_ArchDesign` as a specialised part def holding the system of
interest with its actors and environment. No separate top-level package.

### 3.4 Growing the base

When a second project starts from the same base, harden it by migrating
stable definitions out of `{{sc}}_ArchDesign` into `{{sc}}_BaseArchitecture`.
When the base is shared across several programmes, it migrates out of the
SE model entirely and becomes a shared model (Section 4). This is the
reuse curve Douglass describes (ASE 2016 Ch 8.3, Fig 8.4).

---

## 4. Federation for Scale (ASE 2016 Fig 3.12 and Fig 8.4, Cookbook 2021 Fig 1.37)

A single SE model suffices for most VSE projects. Federate into multiple
connected models only when one of the following holds (ASE 2016 Ch 3.2.5):

- Load and save time has become painful.
- Different teams have narrow focus and need smaller models.
- Information protection between teams requires it.
- The same base architecture is reused across multiple programmes.

### 4.1 The three model types

| Model | Owner | Content |
| --- | --- | --- |
| **SE model** | Systems team | The canonical layout from Section 2 |
| **Shared model** | Cross-programme stewardship | Physical interfaces, common types, shared domains, reusable base architectures |
| **Subsystem model** | Subsystem team | Subsystem specification, functional analysis, architectural design, deployment, software design |

Cookbook 2021 Fig 1.38 names the shared model's canonical structure. Its
`Interfaces` and `CommonTypes` packages are referenced (not copied) by the
subsystem models. ASE 2016 Fig 3.14 and Cookbook 2021 Fig 1.39 show the
subsystem model layout: each subsystem has its own small copy of the AMBSE
canonical pattern, scaled to the subsystem's scope.

### 4.2 Copy versus reference for subsystem specification

Cookbook 2021 Ch 1 discusses the trade-off explicitly. Copying isolates the
subsystem model from later SE-model changes. Referencing keeps it
live-linked. For VSEs, **reference** is the default because the team is
small enough to manage a single coherent change stream.

### 4.3 Plugin scope

`project-setup` does not scaffold federated models automatically. The
pattern stays manual until the project outgrows a single model.

---

## 5. Namespace Hygiene (SysML v2 Book Ch 15-16)

The structural chapters of *The SysML v2 Book* contribute one discipline
to the plugin's canonical layout: how to keep namespaces from colliding
as the model grows.

### 5.1 Short-code prefixes

Prefix every top-level package with a project short code (two to four
letters): `HS_Actors`, `HS_Requirements`, `SS_ArchDesign`. A lighter
variant of Chapter 16's angle-bracket convention, serving the same
purpose: when two projects share a workspace or a base is reused across
programmes, the package names do not collide.

### 5.2 Imports

SysML 2.0 distinguishes public and private imports (Ch 15, pp 74-75). A
`private import` brings a namespace into scope without re-exporting it.
Use `private import` by default. Reserve public imports for packages
that deliberately forward a namespace. Prefer named imports over
wildcards so the dependency surface stays visible:

```sysml
package HS_Verification {
    private import HS_Requirements::SR_WaterLevelAccuracy;
    private import HS_Requirements::SR_ResponseTime;
    // rather than HS_Requirements::*
}
```

### 5.3 One top-level package per file

Nested packages inside a single top-level package must sit in one file
textually (Chs 15-16). Top-level packages can live in separate files.
The VSE rule is: one top-level package per file, nested packages only
for tight groups (e.g. the children of `{{sc}}_FunctionalAnalysis`, one
per analysed use case).

### 5.4 Reuse boundary check

A package that imports only from `{{sc}}_BaseArchitecture`,
`{{sc}}_Actors`, and `{{sc}}_Interfaces` is reusable across projects. A
package that imports freely from any peer cannot be lifted into a shared
model later. A cheap reuse guard to run when considering federation.

---

## 6. Variant Modelling Organisation (VAMOS 2016 adapted to SysML 2.0)

The variant syntax authority is Chapter 35 of *The SysML v2 Book*, already
covered in `knowledge/sysml2-variants-ref.md`. This section adds the
**organisation** that surrounds that syntax, drawn from Weilkiens (2016),
*Variant Modeling with SysML*, Chapters 2-3 (VAMOS). VAMOS was written
against SysML v1 and its stereotype syntax is not reproduced in this
plugin. What transfers is the method and the organisation.

### 6.1 Core, Variations, Configurations

VAMOS Ch 3.2 separates variant models into three orthogonal concerns:
**Core** is the unchanging system model (VAMOS Ch 3.3 calls it "a normal
system model"), **Variations** are the decision points, and
**Configurations** are the concrete selections that materialise a
product. The plugin maps this onto the AMBSE layout:

| VAMOS concern | Plugin location | Authority |
| --- | --- | --- |
| Core | The whole AMBSE canonical layout from Section 2 | ASE 2016 Fig 3.13, Cookbook 2021 Fig 1.35 |
| Variations | Inline inside the owning AMBSE package (usually `{{sc}}_ArchDesign`, sometimes `{{sc}}_Requirements` or `{{sc}}_Interfaces`) | SysML v2 Book Ch 35 via `sysml2-variants-ref.md` |
| Configurations | Optional top-level package `{{sc}}_Configurations` | VAMOS 2016 Ch 3.7 adapted |

This is a hybrid. VAMOS 2016 put variations in a dedicated top-level
package alongside the core. SysML 2.0 Chapter 35 puts them inline inside
the owning part def. The plugin uses the Chapter 35 rule for inline
variation definitions because Chapter 35 is the SysML 2.0 syntax authority,
and uses the VAMOS rule for a dedicated `{{sc}}_Configurations` package
because VAMOS is the organisation authority for concrete configurations.

### 6.2 Variation point discipline (VAMOS Ch 3.4)

A variation point is the single element that a variation refines. VAMOS
Ch 3.4 lays down a discipline: do not make children of variation points
into variation points themselves. A variation declared on a child of
another variation is a smell, because the child's variation space is
ambiguous with the parent's.

The sibling skill `sysml2-model-structure` lifts this into a validation
check: nested variations are flagged.

### 6.3 Feature tree reading (VAMOS Ch 3.5)

When variation elements are nested hierarchically, the hierarchy reads as
a feature tree. VAMOS offers this as a lightweight alternative to a full
feature model. In SysML 2.0 the equivalent reading is the nesting of
variation definitions inside their owning part defs. PLEML (Section 6.6)
is the formal feature-model extension.

### 6.4 Cross-variation constraints

VAMOS used `«XOR»` and `«REQUIRES»` stereotypes. SysML 2.0 uses
`assert constraint { ... implies ... }` bodies inside the owning part def.
The worked example lives in `sysml2-variants-ref.md` Section 5.

### 6.5 Minimum viable variant organisation for a VSE

A VSE project with one or two variants does not need the full VAMOS
apparatus. The minimum viable pattern is:

1. Declare variations inline in `{{sc}}_ArchDesign` (or `{{sc}}_Requirements`
   for requirement variations) per Chapter 35.
2. Add `{{sc}}_Configurations` only when concrete product instances need
   to be materialised.
3. Write cross-variation rules with `assert constraint` inside the owning
   part def.

The `Minimal AMBSE subset` tier in `project-setup` does not scaffold
`{{sc}}_Configurations`. The `Canonical AMBSE` tier scaffolds it on opt-in.

### 6.6 The PLEML extension

SysML 2.0 has an optional Product Line Engineering Modelling Library
(PLEML) for full feature models aligned with ISO/IEC 26580 (SysML v2 Book
Ch 35). The plugin does not scaffold PLEML in this release. Adopt it when
the inline-variation pattern is outgrown. See `sysml2-variants-ref.md`
Section 7 and the `sysml2-variants` sibling skill for authoring.

---

## 7. Model-Level Configuration Management (ISO 29110 PM.1.13, PM.2.5)

This section introduces **model-level** configuration management as a
first-class pattern. The process-level Configuration Management Strategy
already lives in `templates/pm/project-plan.md` Section 9 (PM.1.13 output)
and `templates/sr/semp.md` Section 4.3. The model-level pattern introduced
here does not replace those artefacts. It complements them with a
machine-readable surface that the Automator can query, that
`traceability-guard` can check, and that a release tag on `main` can
cross-reference.

### 7.1 Scope split

| Layer | Artefact | Owns |
| --- | --- | --- |
| Process | Project Plan Section 9, SEMP Section 4.3 | Baseline naming conventions, retention rules, repository structure, change-request authority, backup strategy |
| Model | `{{sc}}_CM` package, `ConfigItem` and `Baseline` metadata | Which elements are CIs, their CI state, which baseline they belong to, the baseline scope |

Neither layer is complete without the other. The Project Plan tells the
team **when** and **how** to baseline. The model-level pattern tells the
tools **what** is in each baseline.

### 7.2 `ConfigItem` as metadata

SysML 2.0 has no built-in CI keyword. The plugin models CI state with a
user-defined `metadata def` called `ConfigItem` from the `sysml2-metadata`
sibling. Attributes: `ciId`, `baselineId`, `state` (Draft, Baselined,
UnderChange, Superseded, Retired), `owner`. Applied with the `@` syntax
to any element under configuration control.

### 7.3 `Baseline` as an item def

Baselines are first-class elements. Declare them as `item def` instances
inside `{{sc}}_CM`, one per baseline. Each carries a unique `id`
(e.g. `BL-SRS-0.3`), `date`, `description`, a `scope` reference list
naming the CIs it freezes, and a `supersedes` reference to the previous
baseline (empty for the initial one). A release tag on `main` names a
baseline, the baseline names its CIs, and each CI names the element
frozen.

### 7.4 Authority boundary

Project Plan Section 9.2 owns **when** baselines are taken and **who**
authorises them. The `{{sc}}_CM` package owns **what** each baseline
contains. A Change Request initiated under PM.2.5 references model-level
CIs rather than naming them in prose.

### 7.5 Optional `{{sc}}_CM` package

Scaffolded only in the Canonical AMBSE tier and only when the engineer
opts in. Contains a `doc` comment citing Project Plan Section 9, an
initial `BL-INIT` baseline item def, and a placeholder scope list.

### 7.6 Automator query example

"List all CIs in baseline BL-SRS-0.3" becomes a walk over elements with
`ConfigItem` applied, filtering by `baselineId == "BL-SRS-0.3"`. The same
query surfaces orphan CIs (elements whose baselineId does not resolve to
a `Baseline` item def in `{{sc}}_CM`) and un-baselined scope members
(elements named in a baseline's scope that are not in the `Baselined`
state). The `traceability-guard` skill uses this at iteration-boundary
closure. The worked Python snippet lives in the `sysml2-metadata` skill
body.

### 7.7 ISO 29110 activity mapping

| Activity | Model-level action |
| --- | --- |
| PM.1.13 Document Configuration Management Strategy | Write Project Plan Section 9 prose. Optionally scaffold `{{sc}}_CM` on opt-in. |
| PM.1.18 Establish the Project Repository | Initialise the repository and the first `BL-INIT` baseline item def. |
| PM.2.5 Perform configuration management | Update `ConfigItem` metadata on each CM event. Create a new `Baseline` item def on each baseline event. |
| PM.O6 Product Management Strategy developed | Satisfied when CIs are identified, defined, baselined, and controlled via the model surface. |
| SR.O6 System Configuration baselined | Satisfied when the release-tag baseline exists and every SR-produced CI is in the `Baselined` state. |

A dedicated `cm-workflow` skill covering the full
identify-baseline-change-retire loop is flagged as a follow-up in
Section 10.

---

## 8. Risk Modelling Inside the Canonical Layout

Risks are mandatory engineering artefacts under ISO/IEC 29110 PM.O5, PM.1.11,
PM.2.3, and PM.3.1. In a VSE context they are often tracked in a spreadsheet
that sits outside the engineering workspace, where they fall out of date.
The canonical layout moves them into the model so the engineer encounters
them structurally.

### 8.1 Risks as a dedicated package

`{{sc}}_Risks` is a mandatory top-level package. Keeping risks in their own
package gives them a home that can be imported selectively, versioned
alongside the model, and queried via the Automator without touching the
requirements namespace.

### 8.2 `RiskInfo` metadata and risk item defs

SysML 2.0 has no built-in Risk keyword. The plugin models risk with a
`metadata def` called `RiskInfo` (severity, likelihood, status, owner,
`mitigatedBy` reference). Applied with the `@` syntax on any element
carrying a risk (requirement body, use case step, architecture element,
or standalone risk item def inside `{{sc}}_Risks`).

Standalone risks not yet attached to a specific element are `item def`
instances inside `{{sc}}_Risks` with a unique identifier, a description,
and `RiskInfo` applied. When the risk is mitigated, the register entry
gains references to the responsible requirement and the verification
case.

### 8.3 Risk assessment scales

A five-level severity-by-likelihood matrix is the default: `Low`,
`Moderate`, `High`, `VeryHigh`, `Critical`. Encode the scale as an
enumeration inside `{{sc}}_Risks` so it cannot drift between projects.
Galinier et al. argue that VSE risk registers are typically under-used
because they sit outside the engineering workspace. Moving them into the
model removes the handoff friction.

### 8.4 Traceability chain including risk

The plugin extends its existing trace chain with advisory risk links:

```text
Stakeholder Needs
    -> (concern drives)
Risks
    -> (mitigated by)
System Requirements
    -> (verified by)
Verification Cases
```

`traceability-guard` already enforces the satisfy and verify backbone.
Risk links are advisory in this release. Full enforcement lands with the
follow-up `risk-management` workflow skill (Section 10).

### 8.5 ISO 29110 activity mapping

| Activity | Model-level action |
| --- | --- |
| PM.1.11 Document Risk Management Approach | Write Project Plan Risk section and scaffold `{{sc}}_Risks` with the initial scale. |
| PM.2.3 Review risk status in revision meetings | Update `RiskInfo.status` on affected entries. |
| PM.3.1 Evaluate project progress including risk | Query the register by severity and status. |
| PM.O5 Risk Management Approach developed | Satisfied when risks are identified, analysed, prioritised, and monitored inside the model. |

---

## 9. Architecture 0 and Iteration Mapping (Cookbook 2021 Ch 1)

Cookbook 2021 Chapter 1 carries a recipe named "Architecture 0". The first
iteration builds a skeletal architecture before detailed specification
work, to establish the package structure, identify major subsystems,
define the data model and naming conventions, and reduce technical risk
through early prototyping. This maps directly onto the plugin's SR.1
initiation centre of gravity, in which `project-setup` scaffolds the
canonical layout.

Because AMBSE centres of gravity can be concurrent (SR.2 and SR.3 in one
microcycle), each top-level package must be independently editable
without forcing a phase sequence. The canonical layout achieves this. See
`knowledge/iteration-centred-operation.md` for the iteration mechanics.

### 9.1 Mapping centres of gravity to packages

| Centre of gravity | Packages touched |
| --- | --- |
| SR.1 Initiation | `{{sc}}_Model`, skeleton of all packages |
| SR.2 Requirements | `{{sc}}_StakeholderNeeds`, `{{sc}}_UseCases`, `{{sc}}_Requirements`, `{{sc}}_Risks` |
| SR.3 Architecture | `{{sc}}_FunctionalAnalysis`, `{{sc}}_ArchAnalysis`, `{{sc}}_ArchDesign`, `{{sc}}_Interfaces`, optional `{{sc}}_BaseArchitecture`, optional `{{sc}}_Configurations` |
| SR.4 Construction | `{{sc}}_ArchDesign` subsystem packages, `{{sc}}_Interfaces` handoff |
| SR.5 IVV | `{{sc}}_Verification`, `{{sc}}_Risks` mitigation status updates |
| SR.6 Delivery | `{{sc}}_Model` overview |
| PM.1 Planning | Optional `{{sc}}_CM` (PM.1.13), `{{sc}}_Risks` (PM.1.11) |
| PM.2 Execution | `{{sc}}_CM` (PM.2.5), `{{sc}}_Risks` (PM.2.3) |
| PM.3 Assessment and Control | `{{sc}}_Risks` (PM.3.1) |

Multiple packages can be active simultaneously when their centres of
gravity are concurrent.

---

## 10. Gotchas and Red Flags

### 10.1 Gotchas

- The canonical layout is a recommendation, not a mandate. Minor
  variations are fine. Do not invent new top-level packages without a
  reason.
- System context is methodological. It lives inside `{{sc}}_ArchDesign`.
- Nested packages sit in one file. Only top-level packages split across
  files.
- Prefer named imports over wildcards.
- Every risk must have an owner and a status. An unowned risk is silent
  debt.
- Federation is a scale response, not a default.
- VAMOS is read for organisation concepts only. Its v1 stereotypes
  (`«variation»`, `«variant»`, `«variantConfiguration»`, `«variationPoint»`,
  `«XOR»`, `«REQUIRES»`) are not used. The SysML 2.0 syntax authority is
  Chapter 35 via `sysml2-variants-ref.md`.
- Model-level CM complements the Project Plan Section 9 CM Strategy.
  Neither layer is complete alone.

### 10.2 Red flags

- Requirements and architecture collapsed into one package (loses
  trade-off discipline).
- Verification cases scattered across architecture packages (breaks
  `verify` trace aggregation).
- Interfaces embedded inside subsystem packages (breaks handoff).
- No `{{sc}}_Risks` package at all (PM.O5 non-compliance).
- Variation definitions declared in a separate top-level package instead
  of inline in the owning part def (VAMOS v1 pattern).
- Variants declared as composite parts of the variation (Ch 35 treats
  variants as members through the variant membership relationship).
- Baselines declared in the Project Plan only, with no `{{sc}}_CM`
  package.
- `ConfigItem` metadata whose `baselineId` does not resolve to a
  `Baseline` item def (orphan CI).
- A `Baseline` scope that names elements not in `Baselined` state.
- Copying the SysML v2 Book Ch 16 eleven-package drone layout verbatim
  (phase-sequential).

---

## 11. Cross References

- `ambse-agile-process.md`, `ambse-architecture.md`, `ambse-requirements.md`
  — AMBSE iteration mechanics, subsystem decomposition, elicitation.
- `iteration-centred-operation.md` — iteration-centred routing.
- `iso29110-profile.md` — PM.1.11, PM.1.13, PM.2.3, PM.2.5, PM.O5, PM.O6,
  SR.O6 activity rows.
- `sysml2-semantics-ref.md` — feature specialisation, redefinition.
- `sysml2-cases-ref.md` — use cases and verification cases.
- `sysml2-allocations-ref.md` — function-to-structure allocation.
- `sysml2-variants-ref.md` — Chapter 35 variant syntax (authority for
  Section 6).
- `sysml2-metadata-ref.md` — metadata, `RiskInfo`, `ConfigItem`, `Baseline`
  libraries.
- `templates/pm/project-plan.md` Section 9 — process-level CM Strategy
  that `{{sc}}_CM` complements.

---

## 12. Pending Extensions

- `risk-management` workflow skill (full identify-assess-mitigate-monitor
  loop).
- `cm-workflow` skill (full identify-baseline-change-retire loop).
- Automated scaffolding of federated shared and subsystem models in
  `project-setup`.
- Variant interface matrix Automator recipe (VAMOS Ch 3.6 adapted).
- PLEML feature-model integration (pending in the 2026-03 release of
  *The SysML v2 Book*).
- Library packaging for redistributable base architectures.

---

Attribution: Structural guidance drawn from Douglass 2016 Chs 3 and 8, and
Douglass 2021 Ch 1. Specialisation syntax and namespace hygiene drawn from
*The SysML v2 Book* (2026-03) Chs 14-16 and 35. Variant organisation
concepts drawn from Weilkiens 2016 Chs 2-3 (SysML v1 stereotype syntax is
not reproduced). Configuration management and risk activity framing drawn
from ISO/IEC TR 29110-5-6-2:2014. All claims paraphrased for reference
use. Do not reproduce verbatim.
