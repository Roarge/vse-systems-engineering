---
title: "AMBSE Canonical Model Layout for VSE Projects"
slug: sysml2-canonical-model-layout
type: concept
layer: sysml2
tags: [ambse, canonical-layout, vse, top-level-packages, architecture-0, iteration]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Elsevier. Chapter 3.2.5 and Chapter 8.3."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Packt. Chapter 1."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - sysml2-base-architecture-and-federation
  - sysml2-namespace-hygiene
  - sysml2-variant-organisation
  - sysml2-model-cm-and-risks
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-model-structure]
---

# AMBSE Canonical Model Layout for VSE Projects

This page captures the recommended top-level package layout for a
VSE SysML 2.0 model and the rationale that drives it. Companion
pages cover base-architecture reuse and federation
([[sysml2-base-architecture-and-federation]]), namespace hygiene
([[sysml2-namespace-hygiene]]), variant organisation
([[sysml2-variant-organisation]]), and configuration management
plus risk modelling ([[sysml2-model-cm-and-risks]]).

## Why a canonical structure

Reorganising a model late in a project is unscheduled rework, and
the cost grows with every reference that must be rewired. Douglass
recommends deciding the structure early, once the project's shape
is known. The decision factors are: project size, single-model
versus multi-model, single-product versus product-family,
co-located versus distributed team, information hiding between
subsystems, and how architectural decisions will be enforced
across the team (ASE 2016, Ch 3.2.5).

Douglass offers a rule of thumb: teams of 15 or fewer can work
with a single SE model, teams of 20 or more benefit from multiple
connected models. **For VSEs the default is a single SE model.**
See [[sysml2-base-architecture-and-federation]] for when to
federate.

## Mandatory top-level packages

Both Douglass primary sources converge on the same top-level
package set. The VSE-adapted canonical layout has **ten mandatory
top-level packages** for the SE model, **one model overview file**
at the root, and **three optional top-level packages** that are
scaffolded only when the project needs them.

| Package | Purpose | Source |
|---|---|---|
| `{{sc}}_Actors` | Actor part defs, external systems, operators | Cookbook 2021 Fig 1.35 |
| `{{sc}}_StakeholderNeeds` | Stakeholder needs with `subject` pointing at the system of interest | ASE 2016 Fig 3.13, ISO 29110 SR.2.1 |
| `{{sc}}_UseCases` | Use cases and use case diagrams | Cookbook 2021 Fig 1.35 |
| `{{sc}}_Requirements` | System requirements with `satisfy` links to stakeholder needs | ASE 2016 Fig 3.13 |
| `{{sc}}_FunctionalAnalysis` | One nested package per use case analysis | ASE 2016 Fig 3.13 |
| `{{sc}}_ArchAnalysis` | Architectural trade studies, one nested package per trade | ASE 2016 Fig 3.13 |
| `{{sc}}_ArchDesign` | The selected architecture, one nested package per subsystem | ASE 2016 Fig 3.13 |
| `{{sc}}_Interfaces` | Logical interfaces and the logical data schema | ASE 2016 Fig 3.13 |
| `{{sc}}_Verification` | Verification cases with `verify` links | Plugin traceability chain |
| `{{sc}}_Risks` | Risk register with `RiskInfo` metadata applied | ISO 29110 PM.O5, PM.1.11 |

The short-code prefix `{{sc}}_` is the namespace-hygiene
discipline. A VSE project for a hydrogen sensor uses `HS_Actors`,
`HS_Requirements`, and so on. See [[sysml2-namespace-hygiene]].

## Root model overview file

Cookbook 2021 Fig 1.36 recommends a model overview diagram at the
outermost level, with hyperlinks to key tables and diagrams. The
plugin materialises this as a `{{sc}}_Model` file that carries a
`doc` comment pointing at the overview diagram and cross-links
each top-level package. It holds no engineering content of its
own.

## Optional top-level packages

Three top-level packages are scaffolded only when the project
needs them:

- **`{{sc}}_BaseArchitecture`** when the project inherits from a
  prior programme. See [[sysml2-base-architecture-and-federation]].
- **`{{sc}}_Configurations`** when the project carries
  product-line variants. Variation definitions themselves stay
  inline in the owning AMBSE package per the SysML v2 Chapter 35
  rule. See [[sysml2-variant-organisation]].
- **`{{sc}}_CM`** when the project declares model-level
  configuration items or baselines. See
  [[sysml2-model-cm-and-risks]].

## Why workflow-centric rather than phase-sequential

Every package in the mandatory set is named for a **kind of
work** rather than a lifecycle phase. AMBSE iterations routinely
edit several packages concurrently. A phase-sequential layout
fights this concurrency.

## Architecture 0 and iteration mapping

Cookbook 2021 Chapter 1 carries a recipe named "Architecture 0".
The first iteration builds a skeletal architecture before
detailed specification work, to establish the package structure,
identify major subsystems, define the data model and naming
conventions, and reduce technical risk through early prototyping.
This maps directly onto the plugin's SR.1 initiation centre of
gravity.

Because AMBSE centres of gravity can be concurrent (SR.2 and SR.3
in one microcycle), each top-level package must be independently
editable without forcing a phase sequence.

| Centre of gravity | Packages touched |
|---|---|
| SR.1 Initiation | `{{sc}}_Model`, skeleton of all packages |
| SR.2 Requirements | `{{sc}}_StakeholderNeeds`, `{{sc}}_UseCases`, `{{sc}}_Requirements`, `{{sc}}_Risks` |
| SR.3 Architecture | `{{sc}}_FunctionalAnalysis`, `{{sc}}_ArchAnalysis`, `{{sc}}_ArchDesign`, `{{sc}}_Interfaces`, optional `{{sc}}_BaseArchitecture`, optional `{{sc}}_Configurations` |
| SR.4 Construction | `{{sc}}_ArchDesign` subsystem packages, `{{sc}}_Interfaces` handoff |
| SR.5 IVV | `{{sc}}_Verification`, `{{sc}}_Risks` mitigation status updates |
| SR.6 Delivery | `{{sc}}_Model` overview |
| PM.1 Planning | Optional `{{sc}}_CM` (PM.1.13), `{{sc}}_Risks` (PM.1.11) |
| PM.2 Execution | `{{sc}}_CM` (PM.2.5), `{{sc}}_Risks` (PM.2.3) |
| PM.3 Assessment | `{{sc}}_Risks` (PM.3.1) |

Multiple packages can be active simultaneously when their centres
of gravity are concurrent.

## Structural gotchas

- The canonical layout is a recommendation, not a mandate. Minor
  variations are fine. Do not invent new top-level packages
  without a reason.
- System context is methodological. It lives inside
  `{{sc}}_ArchDesign`, not as a separate top-level package.
- Requirements and architecture collapsed into one package loses
  trade-off discipline.
- Verification cases scattered across architecture packages
  breaks `verify` trace aggregation.
- Interfaces embedded inside subsystem packages breaks handoff.
- No `{{sc}}_Risks` package at all is PM.O5 non-compliance.
- Copying the SysML v2 Book Chapter 16 eleven-package drone
  layout verbatim is phase-sequential and fights AMBSE iteration
  concurrency.

## See also

- [[sysml2-base-architecture-and-federation]] for reuse and
  federation patterns.
- [[sysml2-namespace-hygiene]] for short codes and imports.
- [[sysml2-variant-organisation]] for variant organisation.
- [[sysml2-model-cm-and-risks]] for configuration management and
  risk modelling.
