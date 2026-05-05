---
name: project-setup
description: Bootstrap a new VSE systems engineering project per the methodology §8 layout. Use when starting a new project, scaffolding from scratch (greenfield), adopting VSE on an existing repo (brownfield), copying the methodology spec into the project, laying down model/core scaffolding, placing work under an engineering/ subdirectory, or producing an ISO 29110 compliant layout. Enters Plan Mode before any file system change.
user-invocable: true
---

# Project Setup

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You are the project bootstrapping skill for VSE systems engineering. You scaffold a methodology-conformant project per `methodology/08-project-structure.md` §8.2 and §8.3, copy the methodology specification into the project so it travels with the code, and prepare the repository for the story-driven AMBSE workflow. Setup is a one-time act. Once `methodology/` is present at the engineering root and `model/core/` is populated, hand off to other skills.

The skill has two modes:

- **Greenfield mode** runs when invoked outside any git repository, or in an empty directory. It creates a fresh project, runs `git init`, and lays the full layout at the chosen scaffold root.
- **Brownfield mode** runs when invoked inside an existing repository, possibly one with implementation source code. It places engineering work products under an `engineering/` subdirectory by default so the SysML modelling stays separate from the host project's implementation tree, and merges VSE guidance into any existing `CLAUDE.md` via an idempotent marker block.

Mode is detected automatically in Step 0.

## When This Skill Triggers

- The user runs `/vse-setup`.
- The user asks to "bootstrap a new project", "scaffold a VSE project", "start a new MBSE project", "set up an ISO 29110 project layout", or "VSE-ify an existing repo".
- `vse-companion-overview` routes here when no `methodology/` folder is present at the project root or under the chosen engineering root.

## Operating Mode and Prerequisites

This skill makes irreversible changes to the file system. It scaffolds directories, copies the methodology specification, writes templated files, and (in greenfield mode) initialises git. To make those changes safe to inspect before they happen, the skill operates in two phases:

1. **Read-only context gathering** (Step 0 and Step 1). Detect mode, harvest context from any existing repository, ask the user only for fields that cannot be inferred. No files are created or modified during this phase.
2. **Plan Mode review and execution** (Step 2 onward). Enter Claude Code's Plan Mode, draft the concrete setup plan that lists every directory and every file the skill will create, surface it for explicit approval via `ExitPlanMode`. Execution begins only after approval.

The brownfield context harvest and the `CLAUDE.md` marker-block merge involve judgement calls that benefit from a more capable model. Run this skill on Claude Opus with extended thinking enabled where possible. At the start of Step 0, report the active model and ask whether to switch before proceeding. The recommendation is a soft prerequisite.

## Step 0: Report Model and Detect Mode

Report the active model in one short message and offer the switch to Opus. If the user declines, proceed on the active model.

After the model handshake, determine whether the current working directory is inside a git repository:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

- **Exit non-zero, or output "false"**: greenfield mode. Continue with the greenfield flow.
- **Exit zero, output "true"**: brownfield mode. Capture the repository root with `git rev-parse --show-toplevel` as `PROJECT_ROOT`. Check whether the project has already been initialised by testing for `methodology/` or `engineering/methodology/`.
  - If a `methodology/` directory already exists at the candidate engineering root, refuse to scaffold over it without explicit confirmation. Offer to route to `@project-audit` instead.
  - Otherwise continue with the brownfield flow.

Detect implementation code. Look for any of: `src/`, `lib/`, `app/`, `pkg/`, `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `pom.xml`, `Makefile`, `CMakeLists.txt`. If implementation code is detected at the repo root, refuse to scaffold at the repo root without an explicit override and propose `engineering/` instead.

## Step 1: Gather Inputs

Ask the user only for the values that cannot be inferred. Confirm inferred values before using them.

- **Project name.** Default to the basename of `PROJECT_ROOT` for brownfield, or the chosen target directory name for greenfield. Ask if uncertain.
- **Project short code.** A 3 to 5 letter prefix used for SysML package names per `methodology/08-project-structure.md` §8.3.4 (for example `Aiwell`, `FFDS`, `SnowMelt`). Ask the user. The skill never invents this.
- **Acquirer name.** Optional at setup. Used in the SOW reference inside `docs/project-plan.md`. May be left blank and filled in later.
- **Author name.** Default to `git config user.name`. Ask if missing.
- **Engineering root prefix.** This is the mode-specific scaffold target.
  - Greenfield default: repo root.
  - Brownfield default: `engineering/` subdirectory. Rationale: SysML modelling artefacts stay separate from the host project's implementation tree.
  - Override: repo root, accepted only when no implementation code is detected, or when the user confirms after the warning.
  - Override: a custom subdirectory name (for example `mbse/`, `systems/`).

The chosen scaffold target is `<ENG_ROOT>` from this point on. For greenfield with a fresh directory, `<ENG_ROOT>` equals `PROJECT_ROOT`. For brownfield with the default, `<ENG_ROOT>` equals `<PROJECT_ROOT>/engineering`.

## Step 2: Enter Plan Mode

Enter Plan Mode. Draft a concrete plan that lists, in this order:

1. Every directory that the skill will create, grouped by purpose.
2. Every file that the skill will copy from `${CLAUDE_PLUGIN_ROOT}/methodology/` or `${CLAUDE_PLUGIN_ROOT}/templates/`, with destination paths.
3. Every file that the skill will generate from a template (project plan, SEMP stub, risk register stub, CM strategy stub, correction register, progress status record, `CLAUDE.md`, `.iso-config.yaml`).
4. The exact `.gitignore` extensions that will be appended (or the file that will be created for greenfield).
5. The brownfield merge actions on `CLAUDE.md`, if any, naming the marker block.
6. For brownfield projects with detected implementation code: a note that the as-is architecture survey (Step 6.5) will be offered, and that the offer is opt-in. The plan does not predict the survey outputs because the classification is a runtime decision; the plan names the four candidate output paths (`model/core/base-architecture/<sc>_BaseArchitecture.sysml`, `model/core/base-architecture/<sc>_BaseArchitecture_CM.sysml`, `model/core/as-is/<sc>_AsIs.sysml`, `docs/as-is-classification.md`) so the user knows what may appear if they accept.
7. The `git init` and initial commit, for greenfield only.

Surface the plan via `ExitPlanMode`. Execute only after approval. If the user requests changes to the engineering root, the short code, or the optional folders, revise the plan and surface it again.

## Step 3: Refusals

The skill must refuse to proceed in any of the following situations, even after Plan Mode approval, until the conflict is resolved:

- The target `<ENG_ROOT>` is non-empty and contains files that the scaffold would clash with. Offer to scaffold into a different sub-path or to abort.
- A `methodology/` folder already exists at `<ENG_ROOT>`. The project-local copy may have been edited. Overwriting it would silently destroy customisations. Offer `@project-audit` for an upgrade plan instead.
- Implementation code is detected at the repo root and the user has selected the repo root as `<ENG_ROOT>`. Warn, propose `engineering/`, and require explicit override before continuing.

## Step 4: Scaffold Repository-Root Files

Create or extend the following at `<PROJECT_ROOT>`:

- `README.md`. Greenfield writes from the project README template. Brownfield leaves any existing `README.md` untouched.
- `CONTRIBUTING.md`. Copy from `${CLAUDE_PLUGIN_ROOT}/templates/CONTRIBUTING.md` (created in Phase 7 of the v2.0 restructuring). Carries the §8.4 branch model and the §8.5 PR workflow rules.
- `CHANGELOG.md`. Greenfield writes a fresh empty Keep-a-Changelog skeleton. Brownfield leaves any existing file alone.
- `.github/pull_request_template.md`. Copy from `${CLAUDE_PLUGIN_ROOT}/templates/github/pull-request-template.md`. Embeds the §8.6 review checklists.
- `.github/CODEOWNERS`. Copy from `${CLAUDE_PLUGIN_ROOT}/templates/github/CODEOWNERS` (created in Phase 7) as a placeholder. The user customises it later.
- `.iso-config.yaml`. Copy from `${CLAUDE_PLUGIN_ROOT}/templates/iso-config/.iso-config.yaml` (created in Phase 7). Drives baselined-path enforcement and ISO 29110 hook behaviour per `methodology/iso-29110-hooks-guide.md` §8.
- `.githooks/`. Create the directory empty for now. Population is deferred to `@attention-regime`. Add a placeholder `README.md` that points to `methodology/iso-29110-hooks-guide.md` §3.

Append to `.gitignore` (create if absent):

```text
docs/generated/
.iso-config.local.yaml
```

## Step 5: Copy the Methodology Specification

Copy the entire contents of `${CLAUDE_PLUGIN_ROOT}/methodology/` to `<ENG_ROOT>/methodology/`. The copy is verbatim, preserving all twelve markdown files, the companion `iso-29110-hooks-guide.md`, and any README at the methodology root. File mode bits are preserved.

The copy travels with the project so the methodology version is pinned to the repository state, the project's CI can validate against the local copy, and methodology amendments go through the same PR workflow as model changes per §8.4.3.

If `<ENG_ROOT>/methodology/` already exists, the skill should already have refused in Step 3. Do not silently overwrite.

## Step 6: Scaffold the Model Tree

Create the following directory tree under `<ENG_ROOT>/model/`:

```text
model/
├── core/
│   ├── stakeholders/
│   ├── concerns/
│   ├── base-architecture/
│   ├── as-is/
│   ├── context/
│   ├── domain/
│   ├── stories/
│   │   ├── stakeholder/
│   │   └── system/
│   ├── use-cases/
│   ├── functional-architecture/
│   ├── logical-architecture/
│   │   ├── interface-types/
│   │   ├── allocations/
│   │   ├── components/
│   │   └── architecture-context.sysml
│   ├── product-architecture/
│   ├── parametrics/
│   ├── processes/
│   ├── verification-validation/
│   │   ├── verification-cases/
│   │   └── validation-cases/
│   └── core.sysml
├── variations/
│   ├── trade-studies/
│   ├── decision-points/
│   ├── candidate-variants/
│   └── resolved/
├── library/
└── sandbox/
```

Each subfolder receives a placeholder `.gitkeep` so git tracks the empty directory until content arrives.

`model/core/core.sysml` is generated from `${CLAUDE_PLUGIN_ROOT}/templates/common/models/core/core.sysml` (created in Phase 7) and uses the project short code from Step 1 to declare the top-level package, for example:

```sysml
package <Aiwell> Aiwell_Core {
    // imports added as sub-packages are populated
}
```

The angle-bracket short code is the project's 3-5 letter prefix (per §8.3.4), not the long PascalCase package name.

`model/library/` receives a copy of `${CLAUDE_PLUGIN_ROOT}/templates/common/library/vse-library.sysml`, the methodology library stub per §0.8.

`model/sandbox/` receives a `README.md` explaining that sandbox content is excluded from imports by `model/core/` and `model/variations/` per §8.2.

`model/core/as-is/` receives a copy of `${CLAUDE_PLUGIN_ROOT}/templates/common/models/core/as-is/_template.sysml`, the bare contingent-package shell. The directory is populated only when the brownfield as-is survey in Step 6.5 produces contingent rows, otherwise the bare shell stands. The directory is *empty in greenfield mode* (greenfield projects have no current state to capture) and is created with `.gitkeep` only.

`model/core/base-architecture/` receives a copy of `${CLAUDE_PLUGIN_ROOT}/templates/common/models/core/base-architecture/_template.sysml`, the example library-package skeleton. In brownfield mode, the survey in Step 6.5 may overwrite this template with survey-populated content for mandated elements.

## Step 6.5: As-Is Architecture Survey (brownfield only)

This step runs only when **all** of the following hold:

- `MODE = brownfield` (set in Step 0).
- Step 0 detected implementation code at `PROJECT_ROOT` (any of `src/`, `lib/`, `app/`, `pkg/`, `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `pom.xml`, `Makefile`, `CMakeLists.txt`).
- The user accepted the survey when offered.

In greenfield mode, or in brownfield mode where the user declined the survey, this step is skipped and the bare templates from Step 6 stand alone.

The step operationalises the §2.7 Discovery lifecycle category of the methodology. It is *acknowledgement work*: the survey records facts about decisions that pre-existed the project. It does **not** synthesise stakeholders, concerns, or stories to justify those decisions. The §2.6 rule 7 reverse-engineering guard binds every Claude turn inside this step.

### 6.5.1 Offer the survey

Surface a short message naming the trigger evidence (the implementation-code paths Step 0 detected) and ask whether to run the survey. Two options:

- **Run the survey.** Continue to 6.5.2.
- **Skip.** Write the skip marker (described in 6.5.5) into `<ENG_ROOT>/docs/as-is-classification.md` and continue to Step 7. A later `/vse-setup` re-entry or `@architecture-design` invocation may resume the survey.

### 6.5.2 Mechanical scan

Read-only scan of the host project for architectural evidence. For each probe in the table below, capture the file path, the declared version (where parseable), and the implied architectural element. Do not read source files outside this list. Do not infer intent from variable names or comments.

| Probe | Evidence harvested |
|---|---|
| `package.json`, `package-lock.json` | Node version, framework family (Next.js, NestJS, Express), declared engines |
| `pyproject.toml`, `requirements.txt`, `setup.py` | Python interpreter, frameworks (FastAPI, Django, Flask) |
| `Cargo.toml` | rustc edition, declared crate types |
| `go.mod` | Go version, module path |
| `Gemfile`, `Gemfile.lock` | Ruby runtime and framework family |
| `Dockerfile`, `docker-compose.yml`, `.devcontainer/` | base images, declared services |
| `terraform/`, `*.tf`, `pulumi.yaml`, `cdk.json`, `serverless.yml` | cloud provider, regions, managed services |
| `.github/workflows/*.yml`, `.gitlab-ci.yml`, `Jenkinsfile`, `azure-pipelines.yml` | CI runner, deployment target |
| `*.proto`, `openapi.yaml`, `openapi.json`, `asyncapi.yaml` | declared protocols |
| `helm/`, `k8s/`, `kustomization.yaml` | runtime orchestrator |
| `*.kicad_pcb`, `boards/`, `firmware/`, `*.dts` | hardware platform (only if surfaced) |

For each candidate, record:

- **name**: a short, parser-stable identifier (for example `Node20`, `NextJS14`, `AWSLambda`, `IEC61131-3`).
- **category**: one of *Platform*, *Protocol*, *Reused subsystem*, *Regulatory framework*, *Tooling-only*.
- **evidence paths**: list of file paths where the candidate was detected.
- **declared version**: the version string parsed from the evidence, or `(unspecified)`.

Present the consolidated list to the user as a single table.

### 6.5.3 Classification dialogue

For each row, ask the user to choose exactly one of:

- **`mandated`** — externally constrained, the project may not change without an external mandate.
- **`contingent`** — currently used, but the project owns the choice and may revisit.
- **`irrelevant`** — tooling-only, not architectural; will be excluded from both packages.

For every row marked `mandated`, ask one additional question and **only** this question:

> What is the source of the mandate? Choose one: `parent-organisation`, `customer`, `parent-product`, `regulator`, or `other` (free text).

Three guard rails bind this dialogue. They are §2.6 rule 7 in operation:

1. The skill MUST NOT ask "why is X mandated?" or any "why" variant. The four-bucket source enum (plus optional free text) is the only motivational field captured. The user may volunteer a justification narrative; if so, record it verbatim into `docs/as-is-classification.md` and emit no SysML for it.
2. The skill MUST NOT emit any of the following SysML keywords during this step: `concern def`, `requirement def`, `userStory`, or any `part def` whose name resembles a stakeholder role (Operator, Maintainer, Customer, Regulator, Vendor). The classification produces architectural part defs only, never stakeholder or story constructs.
3. If the user requests "add a story for this" or "capture the rationale as a need", refuse and explain that the survey is acknowledgement work under §2.7 Discovery, and that stories are forward-going (§2.6 rule 5). Offer the rationale-doc field instead. Proceed only after the user explicitly confirms intent to add a context story per §2.6 rule 7.

### 6.5.4 Emit artefacts

Generate the following files. Substitute `{{PROJECT_NAME}}`, `{{PROJECT_SHORT_CODE}}`, `{{AUTHOR}}`, and `{{DATE}}` as in Step 4.

- **`<ENG_ROOT>/model/core/base-architecture/<{{PROJECT_NAME}}>_BaseArchitecture.sysml`**, generated from `${CLAUDE_PLUGIN_ROOT}/templates/common/models/core/base-architecture/as-is.sysml.tmpl`. The `{{AS_IS_MANDATED_PART_DEFS}}` placeholder is replaced with one `part def` block per `mandated` row, of the shape documented inline in the template. Each block carries `@ConfigItem { :>> ciId; :>> baselineId = "BL-BA-AS-IS-0.1"; :>> ciState = CIState::Baselined; :>> owner }` with the four metadata body features using the SysML 2.0 redefinition operator. The example part def from `_template.sysml` is replaced rather than augmented; if the survey produced no mandated rows, the file is not written and `_template.sysml` stands.
- **`<ENG_ROOT>/model/core/base-architecture/<{{PROJECT_NAME}}>_BaseArchitecture_CM.sysml`**, generated from `${CLAUDE_PLUGIN_ROOT}/templates/common/models/core/base-architecture/as-is-cm.sysml.tmpl`. The `{{AS_IS_MANDATED_SCOPE_LIST}}` placeholder is replaced with a comment block listing the fully-qualified part-def names, one per line. The file is not written if the survey produced no mandated rows.
- **`<ENG_ROOT>/model/core/as-is/<{{PROJECT_NAME}}>_AsIs.sysml`**, generated from `${CLAUDE_PLUGIN_ROOT}/templates/common/models/core/as-is/as-is-current.sysml.tmpl`. The `{{AS_IS_CONTINGENT_PART_DEFS}}` placeholder is replaced with one `part def` block per `contingent` row. Each block carries `@ConfigItem { :>> ciId; :>> baselineId = "BL-AS-IS-CURRENT-0.1"; :>> ciState = CIState::Proposed; :>> owner }`. If the survey produced no contingent rows, this file is not written and `_template.sysml` stands.
- **`<ENG_ROOT>/docs/as-is-classification.md`**, generated from `${CLAUDE_PLUGIN_ROOT}/templates/docs/as-is-classification.md`. Populate the *Mandated* and *Contingent* tables with the survey rows; populate the *Skipped or irrelevant* list with the rows the user marked `irrelevant`. Remove the survey-skipped marker block at the foot of the template.

After writing the SysML files, update `<ENG_ROOT>/model/core/core.sysml` to add the import line `private import {{PROJECT_NAME}}_AsIs::*;` immediately after the existing `{{PROJECT_NAME}}_BaseArchitecture::*;` import. Skip the addition if no contingent rows were produced.

### 6.5.5 Skip path

If the user declined the survey at 6.5.1, write `<ENG_ROOT>/docs/as-is-classification.md` from the template *unmodified*, leaving the survey-skipped marker block at the foot of the file:

```
<!-- as-is-survey: skipped at {{DATE}} -->
```

The marker is the resumption signal for a later `@architecture-design` invocation or `/vse-setup` re-entry, neither of which run automatically. The user re-invokes the survey explicitly when ready.

### 6.5.6 Refusals

Refuse and explain:

- The user asks the skill to "just figure out what is mandated for me" or "decide which ones are locked in". The classification is a human decision. Surface the candidate list and ask the user to mark each row.
- The user asks the skill to draft stakeholder needs or stories from the survey output. Refuse, name §2.6 rule 7, and offer the rationale-doc field instead.
- The user asks the skill to populate `require constraint` clauses from the evidence. Refuse: constraints are added later via `@architecture-design` once the engineering implications are understood.

## Step 7: Scaffold the Engineering-Root Auxiliary Folders

Create the following at `<ENG_ROOT>`:

- `sketches/`. Empty. Holds diagrams, hand sketches, and images per §8.2.
- `tools/`. Empty except for a `README.md` listing the renderer and lint scripts described in `methodology/iso-29110-hooks-guide.md` §3.1. Population is deferred.
- `docs/`. Scaffold the ISO 29110 work products and supporting folders:
  - `docs/project-plan.md`, generated from `${CLAUDE_PLUGIN_ROOT}/templates/pm/project-plan.md` per `methodology/10-project-management.md` §10.3.
  - `docs/semp.md`, the Systems Engineering Management Plan stub from `${CLAUDE_PLUGIN_ROOT}/templates/sr/semp.md`.
  - `docs/risk-register.md`, generated from the Phase 7 risk-register template per §10.7.
  - `docs/cm-strategy.md`, generated from the Phase 7 cm-strategy template per §10.8.
  - `docs/correction-register.md`, generated from `${CLAUDE_PLUGIN_ROOT}/templates/pm/correction-register.md`.
  - `docs/progress-status-record.md`, generated from `${CLAUDE_PLUGIN_ROOT}/templates/pm/progress-status.md`.
  - `docs/disposal-management-approach.md`, the §10.9 stub.
  - `docs/decisions/`, empty, for ADRs.
  - `docs/meetings/`, empty, for meeting records per PM.O4.
  - `docs/releases/`, empty, for release notes.
  - `docs/generated/`, empty, gitignored, for renderer outputs.
  - `docs/templates/`, empty, for project-specific document templates.

## Step 8: Write or Merge `CLAUDE.md`

`CLAUDE.md` lives at `<ENG_ROOT>` so the harness picks it up when the user works inside the engineering subdirectory. The content is generated from `${CLAUDE_PLUGIN_ROOT}/templates/common/CLAUDE.md` and frames the VSE companion guidance for the project.

The template inserts a marker block:

```text
<!-- VSE-START -->
... VSE companion guidance, project name, short code, methodology pointer ...
<!-- VSE-END -->
```

**Greenfield path.** Write the template verbatim to `<ENG_ROOT>/CLAUDE.md`.

**Brownfield path.** If `<ENG_ROOT>/CLAUDE.md` exists already, do not overwrite. Read the existing file. If it contains the marker block already, replace the content between the markers with the freshly rendered guidance. If the marker block is absent, append the marker block at the end of the existing file with a single blank line of separation. Preserve every line of existing content outside the marker block.

The merge logic is idempotent. Re-running the skill produces the same output, and existing user content is never lost.

## Step 9: Initial Commit (Greenfield Only)

For greenfield mode, run `git init`, then stage and commit the scaffold:

```bash
git init
git add .
git commit -m "chore: scaffold VSE methodology project"
```

For brownfield mode, do not commit. Inform the user that the new files are unstaged and recommend a single commit such as `chore: adopt VSE methodology scaffold` once they have reviewed the diff.

## Step 10: Hand-offs

After successful scaffolding, surface the following routes and let the user pick:

- `@story-orchestrator`. The first stakeholder story may be authored against §4 of the methodology now that `model/core/stories/stakeholder/` exists.
- `@project-plan` if the engineer wants to author the Project Plan immediately, populating `docs/project-plan.md` per §10.3.
- `@attention-regime` to populate `.githooks/` with the project-side scripts described in `methodology/iso-29110-hooks-guide.md` §4 and to wire the harness-side reminders.
- `@needs-and-requirements` to begin §4 stakeholder elicitation directly, producing the first `concern def` set and stakeholder `part def`s.

The skill suggests routes. The engineer chooses.

## Step 11: Outputs

Report a concise summary listing every directory created, every file copied from the plugin, every file generated from a template, and the commit (if any) that was made. Format the report so the engineer can scan it before deciding the next route.

For brownfield projects, the report also names the outcome of the as-is survey (Step 6.5): whether it ran, the count of mandated rows, the count of contingent rows, and the count of skipped rows. If the survey was declined, the report names the resumption marker in `docs/as-is-classification.md` and points at `@architecture-design` as the re-entry skill.

If any refusal triggered in Step 3, the report instead names the conflict and explains how to resolve it.

`!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/project-setup.md`
