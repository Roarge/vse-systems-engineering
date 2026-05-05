<!-- BEGIN VSE COMPANION (managed by project-setup) -->
# {{PROJECT_NAME}}

This project follows ISO/IEC 29110 (Basic Profile) for Very Small Entity (VSE) systems engineering. All work is governed by the VSE Systems Engineering plugin and the methodology specification at `methodology/` (project-local copy of the plugin's authoritative spec).

## Methodology First

When answering any question about this project:

1. Consult the project's `methodology/` folder. The project-local copy is authoritative for this project. The plugin-shipped copy at `${CLAUDE_PLUGIN_ROOT}/methodology/` is the fallback.
2. Invoke the `vse-companion-overview` skill before any other VSE skill. It sets the methodology lens, story-centric routing, and the §2.6 rule 7 reverse-engineering guard.
3. Route work to the right specialist skill via the routing table in `vse-companion-overview`.
4. Warn if the requested action touches a baselined artefact without an open Change Request, or if it would synthesise a context story that justifies a Base Architecture decision (forbidden by §2.6 rule 7 unless the user explicitly confirms intent).

If the VSE plugin is not installed, follow the methodology specification at `methodology/` directly.

## Story-driven Workflow

This project follows a story-driven adaptation of agile MBSE expressed natively in SysML 2.0. Three ideas carry the methodology.

**Foundational artefacts (§1–§3).** User stories are the canonical stakeholder-intent artefact at every workflow stage. The Base Architecture (§2) captures architectural and technical decisions that pre-exist the project. The System Context (§3) declares the system boundary, the four categories of external actor, and the interfaces and item flows.

**Workflow stages (§4–§7).** Stakeholder Requirements Engineering (§4) produces the stakeholder story register. System Requirements Definition and Analysis (§5) derives system stories with formalised `require constraint` benefits. Architectural Analysis and Trade Studies (§6) sources criteria from those benefit constraints (the §0.3 connective mechanism). Architectural Design (§7) decomposes into subsystems and propagates stories downward.

**Connective mechanism (§0.3).** The `benefit` slot of a user story, when expressed as a `require constraint`, is the same model element that supplies trade-study criteria in §6. Architectural decisions cannot drift from stakeholder intent because the criteria are the stakeholder intent.

The methodology rejects fixed-length iteration containers (Douglass nanocycle, microcycle, macrocycle scheduling units) but embraces iteration as recursive practice. Revisiting earlier stages as feedback arrives is allowed and encouraged. The story register is the cross-iteration index. `StoryMeta.status` records each story's position.

### Branch and PR conventions for this project

- All non-trivial work goes on a `story/<US_id>_<short>` branch (or `methodology/<topic>`, `arch/<decision>`, `release/<tag>` for the other branch kinds in §8.4.3). Direct commits to `main` are prohibited.
- A draft pull request is opened on the first commit of every story branch. The draft is the operational expression of `StoryMeta.status = inProgress` (§8.5.1). Iterative review proceeds on the draft.
- The author marks the PR ready for review when the §8.6.2 readiness checklist passes. Final review applies the §8.6.3 reviewer checklist. The PR is squash-merged on approval. The branch is deleted on merge.
- Commits use conventional-commit form with story scope or Change Request reference: `feat(US_042): subject`, `fix(SYS_142): subject`, `plan: revise schedule (CR #17)`, `meeting: 2026-05-05 architecture sync`.
- Trace gates: the project-side `pre-commit` hook runs SysML lint, story well-formedness (§1.9), and traceability integrity. The `commit-msg` hook enforces the conventional-commit pattern and requires a `CR #<n>` reference when staged files include any baselined path.
- Releases group `done` stories under annotated `release-vN.M` tags. The Project Plan is baselined at `plan-baseline-vN.M` per §10.3.4.

For the full mapping see `methodology/08-project-structure.md` (branch model, PR workflow, review checklists) and `methodology/iso-29110-hooks-guide.md` (hook surface).

## Current Project State

At the start of every SE-related interaction, surface:

- **Branch**: the current git branch.
- **Story (this branch)**: the active story ID and short name (if on a story branch).
- **Story status**: the `StoryMeta.status` value of the story file on this branch.
- **Plan baseline**: the most recent `plan-baseline-*` tag.
- **Last release**: the most recent `release-*` tag, where one exists.
- **Open Change Requests**: count and a brief list, when the `gh` CLI is available.

Read `.vse-journal.yml` for cross-session continuity. If the file exists and has entries, present a SESSION CONTINUITY block with the previous session's summary, pending work, and open issues.

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
| SysML 2.0 syntax and validation | `@sysml2-modelling` (umbrella, routes to siblings) |
| Project layout audit, version drift | `@project-audit` |
| Hook installation | `@attention-regime` |
| Cross-session continuity | `@session-journal` |
| Document export | `@document-export` |

## Source Order

When the methodology spec disagrees with any source, the spec wins. Sources are consulted in this priority:

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

- **Project:** {{PROJECT_NAME}}
- **Acquirer:** {{ACQUIRER}}
- **Date created:** {{DATE}}
- **Author:** {{AUTHOR}}

## Project Structure (per §8.3)

```text
methodology/                Project-local methodology spec
model/
  core/
    stakeholders/           part defs for stakeholder roles
    concerns/               concern defs
    base-architecture/      §2 platform reference (library package)
    context/                §3 System Context
    domain/                 glossary, item defs, common value types
    stories/
      stakeholder/          §4 stories
      system/               §5 stories (derive from stakeholder)
    use-cases/              §1.4.5 elaborations
    functional-architecture/
    logical-architecture/
      interface-types/
      allocations/
      components/<comp>/    recursive subsystem scope
      architecture-context.sysml
    product-architecture/
    parametrics/
    processes/
    verification-validation/
      verification-cases/   §5.4.6 (system internals)
      validation-cases/     §4.3.6 (stakeholder intent)
    core.sysml              top-level package declaration
  variations/               §6 trade-study mechanism
    trade-studies/          analysis defs per decision
    decision-points/        variation defs
    candidate-variants/     variant defs
    resolved/               specialisations that redefine variations
  library/                  methodology library (UserStory, StoryMeta, etc.)
  sandbox/                  experimental work, not imported by core
docs/
  project-plan.md           §10.3 Project Plan
  semp.md                   §10.3.2 SEMP
  risk-register.md          §10.7
  cm-strategy.md            §10.8
  correction-register.md    §10.5.2
  progress-status-record.md §10.5
  decisions/                ADRs
  meetings/                 Meeting Records (PM.O4)
  releases/                 Release plans
  generated/                Rendered ISO 29110 documents (gitignored)
sketches/                   Diagrams, hand sketches, images
tools/                      Lint and renderer scripts
.github/
  pull_request_template.md  PR template embedding §8.6 checklists
  CODEOWNERS                Role-to-identity mapping
.iso-config.yaml            ISO 29110 hook configuration (§8 of hooks guide)
.githooks/                  Project-side git hooks (installed via core.hooksPath)
```

## Traceability

Every system requirement traces upward to at least one stakeholder need through a `derive` chain (system stories `derive` from stakeholder stories per §5). Every acceptance criterion traces downward to at least one verification case through a `verify` clause (per §4.3.6 / §5.4.6). Every stakeholder concern is framed by at least one stakeholder story through `frame concern` (per §1.4.6).

Trace integrity is checked by `@traceability-guard` and by the project-side `pre-commit` hook. The Traceability Matrix is auto-generated from model relations and lives at `docs/generated/traceability-matrix.md` (§9.8 model-derived artefact).

## SysML 2.0 conventions

- Package names: `PascalCase` with project short-code prefix (e.g., `Aiwell_Core`).
- Definition names: `PascalCase` (e.g., `part def TemperatureSensor`).
- Usage names: `camelCase` (e.g., `part tempSensor : TemperatureSensor`).
- User Story IDs: `US_<n>_<ShortName>` per §1.6 (e.g., `US_042_AckFromDashboard`).
- System story IDs: `SYS_<n>_<ShortName>` (e.g., `SYS_142_BatchAcknowledgement`).
- Subsystem story IDs: project-determined component prefix (e.g., `ALM_001`).
- Verification case IDs: `VC_` prefix; validation case IDs: `VAL_` prefix.

## Roles

This is a VSE project. One person may fill multiple roles. Document which person holds which role in `docs/project-plan.md`.

| Role | Abbr | Responsibility |
|---|---|---|
| Project Manager | PJM | Planning, monitoring, control, repository management |
| Systems Engineer | SYS | Stakeholder needs, system requirements, V&V coordination |
| Designer | DES | Functional and physical design, interface definitions |
| Developer | DEV | Construction of software and hardware elements |
| IVV Engineer | IVV | Integration, verification, validation execution |
| Acquirer | ACQ | Customer acceptance, needs provision |
| Stakeholder | STK | Needs and concerns provision across lifecycle |
| Work Team | WT | All internal team members collectively |
| Supplier | SUP | External provider of system elements |

## Writing Style

- UK English throughout (organisation, behaviour, modelling).
- No em-dashes. Restructure with commas, parentheses, or "that is".
- No semicolons in body text. Split into two sentences.
- No contractions (do not, cannot, will not, it is).
- Plain language first, specialist terms introduced with explanation.
<!-- END VSE COMPANION -->
