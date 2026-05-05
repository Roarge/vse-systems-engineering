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
6. The `git init` and initial commit, for greenfield only.

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
│   │   └── components/
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
package <Aiwell_Core> Aiwell_Core {
    // imports added as sub-packages are populated
}
```

`model/library/` receives a copy of `${CLAUDE_PLUGIN_ROOT}/templates/common/library/vse-library.sysml`, the methodology library stub per §0.8.

`model/sandbox/` receives a `README.md` explaining that sandbox content is excluded from imports by `model/core/` and `model/variations/` per §8.2.

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

If any refusal triggered in Step 3, the report instead names the conflict and explains how to resolve it.

`!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/project-setup.md`
