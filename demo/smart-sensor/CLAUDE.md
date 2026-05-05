# Smart Sensor Demo

This project is the dogfood demo for the `vse-systems-engineering`
plugin. It exercises the installed plugin in a realistic story-driven
AMBSE workflow against a small IoT sensor product.

This project follows ISO/IEC 29110 (Basic Profile) for Very Small
Entity (VSE) systems engineering. All work is governed by the VSE
Systems Engineering plugin and the methodology specification at
`methodology/` (a project-local copy of the plugin's authoritative
spec).

## Methodology First

When answering any question about this project:

1. Consult the project's `methodology/` folder. The project-local
   copy is authoritative for this project. The plugin-shipped copy
   at `${CLAUDE_PLUGIN_ROOT}/methodology/` is the fallback.
2. Invoke the `vse-companion-overview` skill before any other VSE
   skill. It sets the methodology lens, story-centric routing, and
   the §2.6 rule 7 reverse-engineering guard.
3. Route work to the right specialist skill via the routing table
   below.
4. Warn if the requested action touches a baselined artefact
   without an open Change Request, or if it would synthesise a
   context story that justifies a Base Architecture decision
   (forbidden by §2.6 rule 7 unless the user explicitly confirms
   intent).

If the VSE plugin is not installed, follow the methodology
specification at `methodology/` directly.

## Story-driven Workflow

This project follows a story-driven adaptation of agile MBSE
expressed natively in SysML 2.0. Three ideas carry the methodology.

**Foundational artefacts (§1–§3).** User stories are the canonical
stakeholder-intent artefact at every workflow stage. The Base
Architecture (§2) captures architectural and technical decisions
that pre-exist the project (the parent product line picked the
ESP32 platform and the MQTT broker). The System Context (§3)
declares the system boundary, the four categories of external
actor, and the interfaces and item flows.

**Workflow stages (§4–§7).** Stakeholder Requirements Engineering
(§4) produces the stakeholder story register. System Requirements
Definition and Analysis (§5) derives system stories with formalised
`require constraint` benefits. Architectural Analysis and Trade
Studies (§6) sources criteria from those benefit constraints (the
§0.3 connective mechanism). Architectural Design (§7) decomposes
into subsystems and propagates stories downward.

**Connective mechanism (§0.3).** The `benefit` slot of a user
story, when expressed as a `require constraint`, is the same model
element that supplies trade-study criteria in §6. Architectural
decisions cannot drift from stakeholder intent because the criteria
are the stakeholder intent.

The methodology rejects fixed-length iteration containers and
embraces iteration as recursive practice. Revisiting earlier stages
as feedback arrives is allowed and encouraged. The story register
is the cross-iteration index. `StoryMeta.status` records each
story's position.

## Branch and PR conventions

- All non-trivial work goes on a `story/<US_id>_<short>` branch
  (or `methodology/<topic>`, `arch/<decision>`, `release/<tag>`
  per §8.4.3). Direct commits to `main` are prohibited.
- A draft pull request is opened on the first commit of every
  story branch. The draft is the operational expression of
  `StoryMeta.status = inProgress` (§8.5.1).
- The author marks the PR ready for review when the §8.6.2
  readiness checklist passes. Final review applies the §8.6.3
  reviewer checklist. The PR is squash-merged on approval. The
  branch is deleted on merge.
- Commits use conventional-commit form with story scope or Change
  Request reference: `feat(US_042): subject`,
  `fix(SYS_142): subject`, `plan: revise schedule (CR #17)`.
- Releases group `done` stories under annotated `release-vN.M`
  tags. The Project Plan is baselined at `plan-baseline-vN.M` per
  §10.3.4.

For the full mapping see `methodology/08-project-structure.md` and
`methodology/iso-29110-hooks-guide.md`.

## Routing Table

| Topic | Route to |
|---|---|
| Open or advance a story | `@story-orchestrator` (or `/vse-story`) |
| Plan, baseline, or report on a release | `@release-orchestrator` (or `/vse-release`) |
| Open a Change Request | `@change-request` (or `/vse-cr`) |
| Author or revise the Project Plan | `@project-plan` (or `/vse-plan`) |
| §4 stakeholder elicitation, §5 system stories | `@needs-and-requirements` |
| §2 Base Architecture, §6 trade studies, §7 decomposition | `@architecture-design` |
| Verification or validation case authoring | `@verification-validation` |
| Trace integrity check | `@traceability-guard` |
| SysML 2.0 syntax and validation | `@sysml2-modelling` (umbrella) |
| Project layout audit, version drift | `@project-audit` |
| Hook installation | `@attention-regime` |
| Cross-session continuity | `@session-journal` |
| Document export | `@document-export` |

## Source Order

When the methodology spec disagrees with any source, the spec wins.

1. The project's `methodology/` folder (project-local, authoritative).
2. `${CLAUDE_PLUGIN_ROOT}/methodology/` (plugin-shipped, fallback).
3. ISO/IEC 29110-5-6-2 (process backbone).
4. PHAS-EAI / Kappe (design rationale for VSE-scaled SE).
5. Galinier et al. (SME practices).
6. INCOSE SE Handbook (best practices, scaled for VSEs).
7. Douglass 2016 and 2021 (the Harmony aMBSE arc the methodology adapts).
8. SYSMOD (Weilkiens 2020, Base Architecture and System Context).
9. SysML v2 specification and SySiDE notes.
10. Domain guides (Needs and Requirements, V&V, HSI).

## Project Information

- **Project:** Smart Sensor (demo)
- **Acquirer:** dogfood (internal)
- **Date created:** 2026-05-05
- **Author:** vse-systems-engineering plugin contributor

## Project Structure (per §8.3)

```text
methodology/                Project-local methodology spec
model/
  core/
    stakeholders/           Operator, MaintenanceTechnician, Regulator
    concerns/               StableMonitoring, AlertResponseTime, ...
    base-architecture/      ESP32 MCU, MQTT broker (library package)
    context/                System Context composite
    domain/                 Reading, Alert, AcknowledgementCommand
    stories/
      stakeholder/          US_001..US_003
      system/               SYS_001, SYS_002 (derive from stakeholder)
    use-cases/              §1.4.5 elaborations
    logical-architecture/
      interface-types/      Reusable interface defs
    verification-validation/
      verification-cases/   VC_001, VC_002
      validation-cases/     VAL_001, VAL_002
    core.sysml              top-level package declaration
  variations/               §6 trade-study mechanism
    decision-points/        AlertHistoryStorageStrategy
    trade-studies/          AlertHistoryStorageTrade
    resolved/               Selected variant
  library/                  vse-library.sysml (UserStory, etc.)
docs/
  project-plan.md           §10.3 Project Plan
  risk-register.md          §10.7
  cm-strategy.md            §10.8
  decisions/                ADRs
  meetings/                 Meeting Records
  releases/                 Release plans
  templates/                Out-of-scope §10.10 deliverable templates
.iso-config.yaml            ISO 29110 hook configuration
```

## Traceability

Every system story (`SYS_*`) traces upward to at least one
stakeholder story (`US_*`) through `derive`. Every acceptance
criterion traces downward to at least one verification case (or a
direct validation case for stakeholder-side checks). Every
stakeholder concern is framed by at least one stakeholder story
through `frame concern`.

Trace integrity is checked by `@traceability-guard` and by the
project-side `pre-commit` hook.

## SysML 2.0 conventions

- Package names: `PascalCase` with `SmartSensor_` prefix.
- User Story IDs: `US_<n>_<ShortName>` per §1.6.
- System story IDs: `SYS_<n>_<ShortName>`.
- Verification case IDs: `VC_<n>_<ShortName>`.
- Validation case IDs: `VAL_<n>_<ShortName>`.

## Roles

For the demo, one contributor fills every role.

| Role | Abbr |
|---|---|
| Project Manager | PJM |
| Systems Engineer | SYS |
| Designer | DES |
| Developer | DEV |
| IVV Engineer | IVV |
| Acquirer | ACQ |
| Stakeholder | STK |

## Writing Style

- UK English throughout (organisation, behaviour, modelling).
- No em-dashes. Restructure with commas, parentheses, or "that is".
- No semicolons in body text. Split into two sentences.
- No contractions (do not, cannot, will not, it is).
- Plain language first, specialist terms introduced with explanation.
