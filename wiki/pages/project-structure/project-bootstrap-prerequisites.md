---
title: "Project Bootstrap Prerequisites"
slug: project-bootstrap-prerequisites
type: reference
layer: project-structure
tags: [project-setup, bootstrap, prerequisites, base-architecture, system-context, project-plan, sr-1, pm-1]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §4.2 (Stakeholder Requirements Engineering: Inputs and outputs)."
    raw: methodology/04-stakeholder-requirements.md
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §10.3 (PM.1 Project Planning)."
    raw: methodology/10-project-management.md
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §2 (Base Architecture)."
    raw: methodology/02-base-architecture.md
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §3 (System Context)."
    raw: methodology/03-system-context.md
related:
  - vse-canonical-project-layout
  - vse-model-tiers-and-templates
  - base-architecture-corollaries
  - system-context-completeness
  - project-management-workflow
  - methodology-overview
confidence: high
created: 2026-05-06
updated: 2026-05-06
bundled_by: [project-setup, project-audit]
---

# Project Bootstrap Prerequisites

This page collects, in one place, what shall exist before stakeholder requirements engineering (§4) opens on a new VSE project. Two complementary viewpoints together describe the bootstrap state. Both are required, and both are documented in the methodology specification, but each lives in a different section. This page is the synthesis.

## The two viewpoints

### Project-management viewpoint (§10)

Before any technical workflow stage runs, the Project Plan and the Project Repository must exist. This is the ISO/IEC 29110 PM.1 (Project Planning) obligation, satisfying objective PM.O1.

- **Project Plan** at `docs/project-plan.md`, structured per §10.3 (the seventeen elements aligned to ISO 29110 PM.1.1 to PM.1.14). The Plan is reviewed and accepted via a normal pull-request cycle, then tagged on the merge commit as `plan-baseline-v1.0`. See [[project-management-workflow]].
- **Systems Engineering Management Plan (SEMP)** is either a top-level section of the Project Plan or a separate document at `docs/semp.md`, per §10.3.2.
- **Project Repository** initialised on a `main` branch with the canonical directory tree per §10.3.3 and [[vse-canonical-project-layout]]. The protected-branch policy and CODEOWNERS are configured here.

These artefacts do not depend on the system-of-interest. They describe how the project itself is organised and run.

### Stakeholder-requirements-engineering viewpoint (§4)

Once the Project Plan is accepted, §4 begins. The §4 stage takes three explicit inputs per `methodology/04-stakeholder-requirements.md` §4.2:

- **Base Architecture (§2)** at `model/core/base-architecture/`. Pre-existing architectural and technical decisions that constrain the project from the start, adopted from SYSMOD §5.7. Base Architecture is *exogenous*: it is not produced by the project, it is supplied to the project. See [[base-architecture-corollaries]] and `methodology/02-base-architecture.md`.
- **System Context (§3)** at `model/core/context/`. The system's environment captured as external actors, interfaces, and item flows, adopted from SYSMOD §5.11. The System Context is authored by the project before §4 opens. See [[system-context-completeness]] and `methodology/03-system-context.md`.
- **Project charter or problem statement.** Project-determined and outside the formal model. The Plan references it.

The Base Architecture and the System Context are foundational artefacts. They are referenced by every workflow stage, are evolving but stable, and are updated only by deliberate decision rather than per iteration.

## How the two viewpoints meet

ISO 29110 places the Base Architecture and System Context inside SR (System definition and Realization), specifically inside SR.2 System Requirements Engineering, where SR.2.1 lists "analyse system context" as one of its activities. The methodology distinguishes the two foundational sections (§2 Base Architecture, §3 System Context) precisely so that they are authored deliberately, ahead of stakeholder elicitation, rather than being wrapped into the elicitation step itself.

In practice, the bootstrap order on a fresh project is:

1. **PM.1 (§10.3)** authors the Project Plan, the SEMP, and the Project Repository. PR-reviewed and tagged.
2. **§2** authors the Base Architecture. Where the project inherits a Base Architecture from a parent programme, this step is import-and-confirm rather than fresh authoring. See [[base-architecture-corollaries]].
3. **§3** authors the System Context. Actors, interfaces, item flows.
4. **§4** opens. Stakeholder identification, concerns, capability themes, stakeholder user stories.

Steps 2 and 3 may be sequenced as parallel branches off `main`, since the Base Architecture and the System Context are independent of each other. Both must be merged before §4 is opened.

## Greenfield versus brownfield

For brownfield projects (where a system already exists and is being engineered into the methodology), the bootstrap differs in one respect: the Base Architecture authoring step is preceded by an as-is survey of the existing system, captured per the brownfield as-is survey in `methodology/02-base-architecture.md`. The System Context and §4 sequence is unchanged.

For greenfield projects, all three artefacts (Plan, Base Architecture, System Context) are authored fresh, in the order above.

## What the `project-setup` skill scaffolds

`/vse-setup` (the `project-setup` skill) creates the directory tree per [[vse-canonical-project-layout]], drops the Project Plan template at `docs/project-plan.md`, and creates empty `model/core/base-architecture/` and `model/core/context/` packages with placeholder `.sysml` files. The skill does not author the content of the Plan, the Base Architecture, or the System Context. Those are project work, not setup work.

## ISO/IEC 29110 mapping

| Bootstrap artefact | ISO 29110 task | Methodology section |
|---|---|---|
| Project Plan | PM.1 (PM.1.1–PM.1.14) | §10.3 |
| SEMP | PM.1 | §10.3.2 |
| Project Repository | PM.1.13 (CM Strategy includes the repo) | §10.3.3 |
| Base Architecture | SR.1 (Initiation, partial; method-determined) | §2 |
| System Context | SR.2.1 (analyse system context) | §3 |

Of these, the Project Plan is reviewed and accepted before the technical work begins, and the foundational artefacts (Base Architecture, System Context) are reviewed at the merge of their respective branches. See [[methodology-overview]] for how these foundational sections relate to the workflow stages, and [[project-management-workflow]] for the PM.1 detail.

## When this page does not apply

This page describes the *initial* bootstrap. It does not cover:

- **Re-baselining or change requests** against an already-baselined Plan. See §10.4.2 (Change Request lifecycle) instead.
- **Subsystem-scope bootstrap** during §7 architectural decomposition. The recursive layout in §8.3.2 describes that case.
- **End-of-project closure**. See §10.6 (PM.4 Project Closure) for the closure-side counterpart, including the `release-vN.M` tag.
