---
name: project-setup
description: Bootstrap a new VSE systems engineering project per the methodology §8 layout. Enters Plan Mode before any file system change.
when_to_use: Use when starting a new project, scaffolding from scratch (greenfield), adopting VSE on an existing repo (brownfield), copying the methodology spec into the project, laying down model/core scaffolding, placing work under an engineering/ subdirectory, or producing an ISO 29110 compliant layout.
user-invocable: true
---

# Project Setup

If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first.

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

## Step 0: Detect Mode

Determine whether the current working directory is inside a git repository:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

- **Exit non-zero, or output "false"**: greenfield mode. Continue with the greenfield flow.
- **Exit zero, output "true"**: brownfield mode. Capture the repository root with `git rev-parse --show-toplevel` as `PROJECT_ROOT`. Check whether the project has already been initialised by testing for `methodology/` or `engineering/methodology/`.
  - If a `methodology/` directory already exists at the candidate engineering root, the project is already initialised. Stop the scaffold here and route to `@project-audit` instead. This is the hard stop restated in Step 3.
  - Otherwise continue with the brownfield flow.

Detect implementation code. Look for any of: `src/`, `lib/`, `app/`, `pkg/`, `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `pom.xml`, `Makefile`, `CMakeLists.txt`. If implementation code is detected at the repo root, propose `engineering/` and treat the repo root as an override the user confirms explicitly (Step 3).

## Step 1: Gather Inputs

Ask the user only for the values that cannot be inferred. Confirm inferred values before using them.

- **Project name.** Default to the basename of `PROJECT_ROOT` for brownfield, or the chosen target directory name for greenfield. Ask if uncertain.
- **Project short code.** A 3 to 5 letter prefix used for SysML package names per `methodology/08-project-structure.md` §8.3.4 (for example `Aiwell`, `FFDS`, `SnowMelt`). Ask the user. The skill never invents this.
- **Rigour profile.** Ask once, here. See the profile question below. The answer is `PROFILE` from this point on and it scales the scaffold, the configuration, and the tailoring record.
- **Acquirer name.** Optional at setup. Used in the SOW reference inside `docs/project-plan.md`. May be left blank and filled in later.
- **Author name.** Default to `git config user.name`. Ask if missing.
- **Engineering root prefix.** This is the mode-specific scaffold target.
  - Greenfield default: repo root.
  - Brownfield default: `engineering/` subdirectory. Rationale: SysML modelling artefacts stay separate from the host project's implementation tree.
  - Override: repo root, accepted only when no implementation code is detected, or when the user confirms after the warning.
  - Override: a custom subdirectory name (for example `mbse/`, `systems/`).

The chosen scaffold target is `<ENG_ROOT>` from this point on. For greenfield with a fresh directory, `<ENG_ROOT>` equals `PROJECT_ROOT`. For brownfield with the default, `<ENG_ROOT>` equals `<PROJECT_ROOT>/engineering`.

### The profile question

The rigour profile scales how much ceremony the project carries. It is recorded once, it is changed at any time, and it is defined normatively in `methodology/00-methodology-overview.md` §0.10. Offer the three tiers with these one-line glosses, verbatim:

- **`light`.** Solo work, prototypes, exploration. The methodology guides, nothing blocks, minimal artefact set.
- **`standard`.** Small team, real product. Gates warn, core artefacts required, full ceremony optional. This is the default.
- **`full`.** Audit-ready ISO/IEC 29110 conformance. Complete §9 mapping, blocking gates, full artefact set.

Where the user is unsure, offer the two-question heuristic from §0.10.2:

1. Does more than one person work on the project?
2. Is there an external acquirer, an audit obligation, or a safety obligation?

Two answers of no suggest `light`. Either answer of yes suggests `standard`. A project that needs an acquirer or an assessor to sign off on the process itself selects `full`.

**Default.** `standard`, in both greenfield and brownfield mode. Accept it without argument if the user declines to choose, and say which tier was recorded.

**Brownfield with an existing `.iso-config.yaml`.** If the file is already present and carries no `project_profile` key, treat the project as `standard` per §0.10.2, say so, and offer to record the key explicitly so the choice stops being implicit. If the key is present, read it and do not ask. A profile already recorded is the project's decision, not something setup revisits.

**Say that it is reversible.** Raising the profile late is expected practice, and §0.10.2 describes how the change is recorded. A prototype that acquires its first external stakeholder moves from `light` to `standard` at that moment.

## Step 2: Enter Plan Mode

Enter Plan Mode. Draft a concrete plan that lists, in this order:

0. The chosen profile, and the one-line statement of what it changes about the scaffold below (which `docs/` artefacts are written, which `baselined_paths` and `storymeta.required_fields` defaults are recorded).
1. Every directory that the skill will create, grouped by purpose.
2. Every file that the skill will copy from `${CLAUDE_PLUGIN_ROOT}/methodology/` or `${CLAUDE_PLUGIN_ROOT}/templates/`, with destination paths.
3. Every file that the skill will generate from a template (project plan, SEMP stub, risk register stub, CM strategy stub, correction register, progress status record, `CLAUDE.md`, `.iso-config.yaml`).
4. The exact `.gitignore` extensions that will be appended (or the file that will be created for greenfield).
5. The brownfield merge actions on `CLAUDE.md`, if any, naming the marker block.
6. For brownfield projects with detected implementation code: a note that the as-is architecture survey (Step 6.5) will be offered, and that the offer is opt-in. The plan does not predict the survey outputs because the classification is a runtime decision; the plan names the four candidate output paths (`model/core/base-architecture/<sc>_BaseArchitecture.sysml`, `model/core/base-architecture/<sc>_BaseArchitecture_CM.sysml`, `model/core/as-is/<sc>_AsIs.sysml`, `docs/as-is-classification.md`) so the user knows what may appear if they accept.
7. The `git init` and initial commit, for greenfield only.

Surface the plan via `ExitPlanMode`. Execute only after approval. If the user requests changes to the engineering root, the short code, the profile, or the optional folders, revise the plan and surface it again.

## Step 3: Pre-execution Safety Checks

Run these checks immediately before the first write. They guard against destroying content that Plan Mode approval did not cover, because the plan describes what the skill will create rather than what already sits at the target path.

- **The target `<ENG_ROOT>` is non-empty and holds files the scaffold would clash with.** Name each clashing path. Offer to scaffold into a different sub-path, to skip the clashing files, or to abort. Proceed once the user has chosen.
- **A `methodology/` folder already exists at `<ENG_ROOT>`. Hard stop.** The project-local copy may carry edits that make it the authority for that project, and overwriting it destroys them with no way back. This is the one check the skill does not proceed past on confirmation alone. Route to `@project-audit` for an upgrade plan, or ask the user to move the existing copy aside by hand first.
- **Implementation code is detected at the repo root and the user has selected the repo root as `<ENG_ROOT>`.** Name the detected paths, say that the SysML tree and the implementation tree will interleave, and propose `engineering/` instead. Proceed once the user confirms the override explicitly.

## Step 4: Scaffold Repository-Root Files

Create or extend the following at `<PROJECT_ROOT>`:

- `README.md`. Greenfield writes from the project README template. Brownfield leaves any existing `README.md` untouched.
- `CONTRIBUTING.md`. Copy from `${CLAUDE_PLUGIN_ROOT}/templates/CONTRIBUTING.md` (created in Phase 7 of the v2.0 restructuring). Carries the §8.4 branch model and the §8.5 PR workflow rules.
- `CHANGELOG.md`. Greenfield writes a fresh empty Keep-a-Changelog skeleton. Brownfield leaves any existing file alone.
- `.github/pull_request_template.md`. Copy from `${CLAUDE_PLUGIN_ROOT}/templates/github/pull-request-template.md`. Embeds the §8.6 review checklists.
- `.github/CODEOWNERS`. Copy from `${CLAUDE_PLUGIN_ROOT}/templates/github/CODEOWNERS` (created in Phase 7) as a placeholder. The user customises it later.
- `.iso-config.yaml`. Copy from `${CLAUDE_PLUGIN_ROOT}/templates/iso-config/.iso-config.yaml` and then apply the four edits below. Drives baselined-path enforcement and ISO 29110 hook behaviour per `methodology/iso-29110-hooks-guide.md` §8.
  1. Substitute the `{{PLUGIN_VERSION}}` placeholder with the installed plugin version read from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`, so `@project-audit` can detect version drift later.
  2. Set `project_profile` to the tier chosen in Step 1.
  3. Set `baselined_paths` to that tier's default from the §0.10.3 obligation table. The template ships the `standard` list and carries the other two as comments. `light` is the empty list `[]`, which keeps the Change Request machinery dormant. `full` is the five-entry list. `methodology/` is deliberately absent at every tier.
  4. Set `storymeta.required_fields` to that tier's default: `[status]` at `light`, `[status, priority]` at `standard`, `[points, priority, status]` at `full`.

  Leave the commented `gate_overrides` block commented. A project raises or lowers a single gate later by uncommenting one key, and an override written at setup that nobody asked for is a surprise the engineer meets at their first blocked commit.
- `.githooks/`. Create the directory empty for now. Population is deferred to `@attention-regime`. Add a placeholder `README.md` that points to `methodology/iso-29110-hooks-guide.md` §3.

Append to `.gitignore` (create if absent):

```text
docs/generated/
.iso-config.local.yaml
```

## Step 5: Copy the Methodology Specification

Copy the entire contents of `${CLAUDE_PLUGIN_ROOT}/methodology/` to `<ENG_ROOT>/methodology/`. The copy is verbatim, preserving all twelve markdown files, the companion `iso-29110-hooks-guide.md`, and any README at the methodology root. File mode bits are preserved.

The copy travels with the project so the methodology version is pinned to the repository state, the project's CI can validate against the local copy, and methodology amendments go through the same PR workflow as model changes per §8.4.3.

If `<ENG_ROOT>/methodology/` already exists, a Step 3 safety check has already stopped execution before this point. Do not silently overwrite.

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

### 6.5.6 Hard stops

These three are agent discipline rather than ceremony, so they are hard at every profile. Explain the reason and offer the conforming path.

- The user asks the skill to "just figure out what is mandated for me" or "decide which ones are locked in". The classification is a human decision, because a mandate is a fact about the organisation rather than a fact readable from the repository. Surface the candidate list and ask the user to mark each row.
- The user asks the skill to draft stakeholder needs or stories from the survey output. Name §2.6 rule 7 and offer the rationale-doc field instead.
- The user asks the skill to populate `require constraint` clauses from the evidence. Constraints are added later via `@architecture-design`, once the engineering implications are understood rather than inferred from a manifest file.

## Step 7: Scaffold the Engineering-Root Auxiliary Folders

Create the following at `<ENG_ROOT>`:

- `sketches/`. Empty. Holds diagrams, hand sketches, and images per §8.2.
- `tools/`. Empty except for a `README.md` listing the renderer and lint scripts described in `methodology/iso-29110-hooks-guide.md` §3.1. Population is deferred.
- `docs/`. Scaffold the ISO 29110 work products and supporting folders. **The artefact set is scaled by the profile chosen in Step 1**, per the §0.10.3 obligation table. Write the artefacts marked for the project's tier and omit the rest. An omitted artefact is available on demand later through the skill that owns it, so omission costs the project nothing except the empty file it does not have to look at.

  | Artefact | Home section | light | standard | full |
  |---|---|---|---|---|
  | `docs/project-plan.md` | §10.3 | write, one-page element set | write, core element set | write, all 17 elements |
  | `docs/semp.md` | §10.3.2 | omit | omit, Plan section instead | write |
  | `docs/risk-register.md` | §10.7 | omit, risks listed in the Plan | write | write |
  | `docs/cm-strategy.md` | §10.8 | omit, one CM paragraph in the Plan | write | write |
  | `docs/disposal-management-approach.md` | §10.9 | omit | omit, stub on request | write |
  | `docs/correction-register.md` | §10.5.2 | omit | write | write |
  | `docs/progress-status-record.md` | §10.5 | omit | write | write |
  | `docs/meetings/` | §10.4.3 | omit | write | write, PM.O4 |
  | `docs/decisions/` | §10.5.3 | write | write | write |
  | `docs/releases/` | §8.4.3 | write | write | write |
  | `docs/generated/` | §9.8 | write | write | write |
  | `docs/templates/` | n/a | write | write | write |

  Sources for the generated files:

  - `docs/project-plan.md` from `${CLAUDE_PLUGIN_ROOT}/templates/pm/project-plan.md` per `methodology/10-project-management.md` §10.3. Substitute `{{PROFILE}}` alongside `{{PROJECT_NAME}}`, `{{DATE}}`, and `{{AUTHOR}}`, which writes the one-line tailoring record under the Profile and tailoring heading in the form `Profile: <tier>. Tailoring per methodology §0.10 defaults.` Where the project deviates from the tier defaults, name the deviation on that same line.
  - `docs/semp.md` from `${CLAUDE_PLUGIN_ROOT}/templates/sr/semp.md`.
  - `docs/risk-register.md` from the risk-register template per §10.7.
  - `docs/cm-strategy.md` from the cm-strategy template per §10.8.
  - `docs/correction-register.md` from `${CLAUDE_PLUGIN_ROOT}/templates/pm/correction-register.md`.
  - `docs/progress-status-record.md` from `${CLAUDE_PLUGIN_ROOT}/templates/pm/progress-status.md`.
  - `docs/disposal-management-approach.md`, the §10.9 stub.

  The four directories written at every tier are empty and carry a `.gitkeep`. `docs/generated/` is gitignored, for renderer outputs.

  Report the omissions in Step 11 rather than silently skipping them, so the engineer knows what the tier decided and can ask for any of it later.

## Step 8: Write or Merge `CLAUDE.md`

`CLAUDE.md` lives at `<ENG_ROOT>` so the harness picks it up when the user works inside the engineering subdirectory. The content is generated from `${CLAUDE_PLUGIN_ROOT}/templates/common/CLAUDE.md` and frames the VSE companion guidance for the project.

Substitute every placeholder the template carries: `{{PROJECT_NAME}}`, `{{PROJECT_SHORT_CODE}}`, `{{ACQUIRER}}`, `{{AUTHOR}}`, `{{DATE}}`, `{{ENGINEERING_ROOT}}` (the `<ENG_ROOT>` path relative to `<PROJECT_ROOT>`, or `.` when they are the same directory), and `{{PROFILE}}` (the tier chosen in Step 1). The Profile line in the project facts is what a later session reads when it wants the tier without parsing `.iso-config.yaml`.

The template is delimited by the marker pair it ships with, which is the pair the merge logic below matches on:

```text
<!-- BEGIN VSE COMPANION (managed by project-setup) -->
... VSE companion guidance, project facts, methodology pointer, lens pointer ...
<!-- END VSE COMPANION -->
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
- `@attention-regime` to populate `.githooks/` with the project-side scripts described in `methodology/iso-29110-hooks-guide.md` §4 and to wire the harness-side reminders. The hook set it installs follows the recorded profile per §3.4 of that guide, so mention the tier when routing.
- `@needs-and-requirements` to begin §4 stakeholder elicitation directly, producing the first `concern def` set and stakeholder `part def`s.

The skill suggests routes. The engineer chooses.

## Step 11: Outputs

Report a concise summary listing every directory created, every file copied from the plugin, every file generated from a template, and the commit (if any) that was made. Format the report so the engineer can scan it before deciding the next route.

Open the report with the recorded profile and the artefacts the tier omitted from `docs/`, naming for each the skill that writes it on request. The engineer should never discover a missing artefact by looking for it.

For brownfield projects, the report also names the outcome of the as-is survey (Step 6.5): whether it ran, the count of mandated rows, the count of contingent rows, and the count of skipped rows. If the survey was declined, the report names the resumption marker in `docs/as-is-classification.md` and points at `@architecture-design` as the re-entry skill.

If a Step 3 safety check stopped execution, the report instead names the conflict and explains how to resolve it.

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| ISO/IEC 29110 VSE Systems Engineering Profile Overview | pages/iso29110/iso29110-overview.md | What ISO/IEC TR 29110-5-6-2 covers and how the Basic Profile applies to a VSE |
| ISO/IEC 29110 Phase Gate Checklists | pages/iso29110/iso29110-phase-gates.md | Phase-to-phase transition checklists for the ISO 29110 process gates |
| ISO/IEC 29110 Project Management Process (PM.1 to PM.4) | pages/iso29110/iso29110-pm-process.md | The four ISO 29110 Project Management activities PM.1 to PM.4, with purpose, inputs, and outputs |
| ISO/IEC 29110 PM Task Checklists (PM.1 to PM.4) | pages/iso29110/iso29110-pm-task-checklists.md | Actionable task checklists for every ISO 29110 Project Management activity |
| ISO/IEC 29110 Roles and Work Products | pages/iso29110/iso29110-roles-and-work-products.md | The ISO 29110 roles and the PM and SR work products each role produces |
| ISO/IEC 29110 System Definition and Realization Process (SR.1 to SR.6) | pages/iso29110/iso29110-sr-process.md | The six ISO 29110 System Definition and Realization activities SR.1 to SR.6 |
| ISO/IEC 29110 SR Task Checklists (SR.1 to SR.6) | pages/iso29110/iso29110-sr-task-checklists.md | Actionable task checklists for every ISO 29110 System Definition and Realization activity |
| ISO/IEC 29110 Phase to Template Mapping | pages/iso29110/iso29110-template-mapping.md | Quick reference linking each ISO 29110 phase to the markdown template file it produces |
| Base Architecture: Forward-Going Stories and the Reverse-Engineering Guard | pages/methodology/base-architecture-corollaries.md | Decisions that pre-exist the project, forward-going stories, and the reverse-engineering guard |
| ISO/IEC TR 29110-5-6-2 compliance mapping | pages/methodology/iso-29110-compliance-mapping.md | The VSE methodology declares partial compliance with the Basic Profile of ISO/IEC TR 29110-5-6-2:2014 |
| Story-driven AMBSE Methodology Overview | pages/methodology/methodology-overview.md | The plugin's methodology specifies an agile model-based systems engineering process expressed natively in SysML v2 |
| Project Management workflow (§10) | pages/methodology/project-management-workflow.md | The §10 workflow with a living Project Plan, iteration-cadence status, and change requests as pull requests |
| Project Bootstrap Prerequisites | pages/project-structure/project-bootstrap-prerequisites.md | What must exist before stakeholder requirements engineering opens on a new VSE project |
| VSE Canonical Project Layout | pages/project-structure/vse-canonical-project-layout.md | The authoritative directory layout for a VSE project scaffolded by project-setup |
| VSE Model Tiers and Document Templates | pages/project-structure/vse-model-tiers-and-templates.md | The three SysML model tiers (Flat, Minimal AMBSE, Canonical AMBSE) and the templates each one scaffolds |
| SySiDE Project Configuration: syside.toml and .lsp.json | pages/syside/syside-project-configuration.md | The two SySiDE config files a project carries: syside.toml and .lsp.json, and what belongs in each |
| SySiDE Tooling Overview and Installation | pages/syside/syside-tooling-overview.md | SySiDE offers four complementary tools for SysML v2 |
| SySiDE VSE Workflows and Report Generation | pages/syside/syside-vse-workflows.md | SySiDE workflows for requirement export and import, hierarchy walks, trace checks, and report generation |
<!-- wiki-routing:end -->
