---
name: project-setup
description: Bootstrap a VSE systems engineering project. Use when starting a new project, scaffolding, initialising ISO 29110 structure, or adding VSE to an existing repository. Enters Plan Mode for review before making any file system changes. Best run on Claude Opus with extended thinking.
user-invocable: true
---

# Project Setup

You are the project bootstrapping skill for VSE systems engineering. You
create a complete project structure aligned with ISO/IEC 29110, populate it
with work product templates, and configure the development environment.

This skill has two modes:

- **Greenfield mode** runs when invoked outside any git repository. It
  creates a fresh project directory at the chosen location and lays out the
  full VSE structure at the project root.
- **Brownfield mode** runs when invoked inside an existing git repository.
  It harvests context from the host project (README, existing CLAUDE.md, git
  config, package manifests, source tree), places VSE work products under
  an `engineering/` subfolder so they sit alongside the host project's own
  files, merges VSE guidance into any existing CLAUDE.md via an idempotent
  marker block, and respects the host project's existing git history.

The mode is detected automatically in Step 0.

## Operating Mode and Prerequisites

This skill makes irreversible changes to the file system. It scaffolds
directories, writes templated files, installs git hooks, and (in
greenfield mode) runs `git init` and creates an initial commit. To make
those changes safe to inspect before they happen, the skill operates in
two phases:

1. **Read-only context gathering** (Steps 0 and 1). The skill detects
   the mode, harvests context from the existing repository if any, and
   asks the user only for fields it could not infer. No files are
   created or modified during this phase.
2. **Plan Mode review and execution** (Steps 2 through 12). The skill
   enters Claude Code's Plan Mode, drafts a concrete setup plan based on
   the gathered context, and surfaces it for explicit user approval via
   `ExitPlanMode`. Execution begins only after approval.

### Recommended model

Both the brownfield context harvest and the CLAUDE.md marker-block merge
involve judgement calls that benefit from a more capable model. For best
results, run this skill on **Claude Opus with extended thinking enabled**.

At the start of Step 0, report the model the harness is currently
running and ask the user whether they want to switch to Opus before
proceeding. If the active model is Sonnet or Haiku, recommend the switch
but proceed if the user declines. The recommendation is a soft
prerequisite, not an enforced requirement.

## When This Skill Triggers

- The user asks to start a new project, create a project, or set up a project
- The user asks to add VSE to an existing repository, adopt VSE on a
  codebase that already has source files, or "VSE-ify" a project
- The `@lifecycle-orchestrator` routes here for new project initialisation
- The user says "bootstrap", "scaffold", or "initialise a project"

## Step 0: Report Model and Detect Mode

Begin by reporting which Claude model the harness is currently running
and surfacing the Opus recommendation from the prerequisites section
above. Phrase it as a single short message, for example:

> "I am currently running on Claude Sonnet 4.6. The `project-setup`
> skill makes judgement calls during the brownfield harvest and the
> CLAUDE.md merge that benefit from Claude Opus with extended thinking.
> Would you like to switch to Opus before continuing, or proceed on the
> current model?"

If the user is already on Opus, acknowledge it and continue. If the user
declines the switch, continue on the active model. If the user wants to
switch, pause until they confirm the switch is done, then continue.

After the model handshake, run the following to determine whether the
current working directory is inside an existing git repository:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

- **Exit non-zero or output "false"**: greenfield mode. Continue with the
  greenfield flow below.
- **Exit zero with output "true"**: capture the repository root with
  `git rev-parse --show-toplevel` as `PROJECT_ROOT`. Then check whether the
  project has already been VSE-initialised:

```bash
test -f "$PROJECT_ROOT/.vse-phase"
```

  - **File exists**: this project is already VSE-initialised. Tell the user,
    route them to `@lifecycle-orchestrator` for ongoing phase navigation,
    and exit without re-scaffolding any files.
  - **File missing**: switch to brownfield mode and continue with the
    brownfield flow below.

The greenfield and brownfield flows share most steps. Where they diverge,
each step calls out which mode applies. Both flows end at Step 11 with a
summary and a handoff to `@lifecycle-orchestrator`.

## Step 1: Gather Project Information

### Greenfield mode

Ask the user for:

1. **Project name** (used for directory, package names, and template placeholders)
2. **Brief description** (one sentence describing the system)
3. **Acquirer name** (the customer or sponsor)
4. **Primary stakeholder roles** (users, maintainers, regulators, or other parties
   with interest in the system)

If the user provides a Statement of Work, extract this information from it.

### Brownfield mode

Harvest as much information as possible from the existing repository before
asking the user anything. The goal is to ask the user only for fields that
genuinely require human input (acquirer, stakeholder roles).

1. **README.md** (case-insensitive lookup at `$PROJECT_ROOT`). Extract:
   - The first H1 heading as the `{{PROJECT_NAME}}` candidate.
   - The first non-empty paragraph after the H1 as the description candidate.

2. **Existing CLAUDE.md** (root, if any). Preserve the entire file content
   as `EXISTING_CLAUDE_MD` for the merge step in Step 4. Scan for any
   `## Project Information` block and pick up `Acquirer` and `Author`
   fields if they are present.

3. **Git config**:
   ```bash
   git config user.name
   git config user.email
   ```
   Use the name as the `{{AUTHOR}}` candidate.

4. **Language ecosystem detection** by file presence at `$PROJECT_ROOT`:
   - `package.json` indicates Node.js or TypeScript
   - `Cargo.toml` indicates Rust
   - `pyproject.toml`, `setup.py`, or `requirements*.txt` indicates Python
   - `go.mod` indicates Go
   - `pom.xml`, `build.gradle`, or `build.gradle.kts` indicates JVM
   - `Gemfile` indicates Ruby
   - `composer.json` indicates PHP
   - `*.csproj` or `*.sln` indicates .NET

5. **Source tree summary**:
   ```bash
   git ls-files | head -200
   ```
   Group the output by top-level directory and count entries per group.
   Record this as a "system context" note that seeds two places later in
   the flow:
   - A comment block at the top of `engineering/models/architecture.sysml`
     listing the host project's source layout as raw input for the
     architectural decomposition.
   - The "System overview" section of `engineering/docs/sr/system-design.md`.

6. **Present harvested values back to the user** as a confirmation prompt.
   Show each field with its detected value and ask the user to confirm or
   correct. Then ask only for the fields that could not be harvested:
   - `{{ACQUIRER}}`
   - Primary stakeholder roles

Store the gathered information for template population:
- `{{PROJECT_NAME}}`: project name in plain text
- `{{PROJECT_PACKAGE}}`: project name in PascalCase (for SysML 2.0 packages)
- `{{DATE}}`: current date in YYYY-MM-DD format
- `{{ACQUIRER}}`: acquirer name
- `{{AUTHOR}}`: author name

## Step 2: Draft Setup Plan and Enter Plan Mode

By this point Steps 0 and 1 have completed. The skill knows:

- Whether the run is greenfield or brownfield
- The project name, acquirer, author, date, and stakeholder roles
- (Brownfield only) the harvested README content, the existing
  CLAUDE.md content, the detected language stack, and the source tree
  summary
- The intended file system layout (root or `engineering/` subfolder)

No files have been created or modified yet. Now draft a concrete setup
plan and present it for user approval through Claude Code's Plan Mode.

### Drafting the plan

Compose a markdown plan with the following sections, in order:

1. **Mode and project summary**: one sentence stating greenfield or
   brownfield and the project name.
2. **Decisions taken from harvested context** (brownfield only): the
   project name source (README H1, user override), the detected
   language stack, the author from git config, and any
   already-populated CLAUDE.md fields.
3. **Files and directories to be created**: a tree showing every path
   that will land on disk, with the source template for each (for
   example, `engineering/docs/pm/project-plan.md` from
   `${CLAUDE_PLUGIN_ROOT}/templates/pm/project-plan.md`). Group templates
   by directory rather than listing each file on its own line, so the
   plan stays scannable.
4. **Files to be modified in place**: the existing files the skill will
   touch. Greenfield has none beyond the new ones. Brownfield has the
   `.gitignore` append and the `CLAUDE.md` marker-block merge.
5. **Hooks and integrations**: the pre-commit hook installation, the
   SySiDE detection plan, and any GitHub Actions workflows offered
   conditional on GitHub MCP availability.
6. **Git operations**: greenfield states the `git init` and the
   initial commit message. Brownfield states "no git plumbing, the user
   will stage and commit on a `vse/iter-00-architecture-zero` branch".
7. **What happens after approval**: the skill executes Steps 3 through
   12 in order and ends with the Step 12 summary. The user can reject
   the plan at the review prompt to abort without any disk changes.

### Entering Plan Mode

Call the `EnterPlanMode` tool. Inside plan mode, finalise the drafted
markdown above, then call the `ExitPlanMode` tool. The Claude Code
harness presents the plan file content to the user for approval through
the standard review UI.

- **If the user approves the plan**: continue with Step 3 below.
- **If the user rejects the plan**: stop. Do not call any tool that
  modifies the file system. Ask the user what they would like to
  change, refresh the relevant Step 1 fields based on the answer, and
  re-enter Plan Mode with a revised plan.

### Important: never bypass the gate

Do not call `Write`, `Edit`, `Bash` (for any filesystem-modifying
command), or any other tool that modifies disk state until
`ExitPlanMode` has returned with user approval. The whole point of this
step is to give the user a single binary go or no-go before any
irreversible action.

## Step 2: Prepare the Workspace

### Greenfield mode

```bash
mkdir -p <project-name>
cd <project-name>
git init
```

Copy the `.gitignore` from `${CLAUDE_PLUGIN_ROOT}/templates/common/gitignore`.
This ensures generated files (docx, pptx, pdf) are excluded from version
control.

### Brownfield mode

Do not run `mkdir`, do not `cd`, and do not run `git init`. The host
project already has a working git repository. The flow operates against
`$PROJECT_ROOT` directly.

Update the existing `.gitignore`:

- If `$PROJECT_ROOT/.gitignore` exists, append the following entries (only
  if they are not already present), preserving the rest of the file:
  ```
  engineering/build/
  engineering/.venv/
  ```
- If `$PROJECT_ROOT/.gitignore` does not exist, copy
  `${CLAUDE_PLUGIN_ROOT}/templates/common/gitignore` as the starting point
  and add the two `engineering/` paths above it.

## Step 3: Create Directory Structure

### Greenfield mode

```text
<project-name>/
├── .vse-phase              (from templates/common/vse-phase, set to SR.1)
├── .vse-journal.yml        (from templates/common/vse-journal.yml, empty journal)
├── .gitignore              (from templates/common/gitignore)
├── .lsp.json               (from templates/common/lsp.json, IDE language server config)
├── CLAUDE.md               (from templates/common/CLAUDE.md, populated)
├── syside.toml             (from templates/common/syside.toml, configured)
├── models/
│   ├── package.sysml       (root package with project name)
│   ├── stakeholder-needs.sysml  (empty, ready for STK- needs)
│   ├── system-requirements.sysml (empty, ready for REQ- requirements)
│   ├── architecture.sysml  (empty, ready for part definitions)
│   ├── verification.sysml  (empty, ready for VER- cases)
│   └── validation.sysml    (empty, ready for VAL- cases)
├── docs/
│   ├── pm/                 (PM work products from templates/pm/)
│   │   ├── statement-of-work.md
│   │   ├── project-plan.md
│   │   ├── progress-status.md
│   │   ├── meeting-record.md
│   │   ├── change-request.md
│   │   ├── correction-register.md
│   │   ├── justification-document.md
│   │   ├── purchase-order.md
│   │   └── product-acceptance.md
│   └── sr/                 (SR work products from templates/sr/)
│       ├── semp.md
│       ├── data-model.md
│       ├── stakeholder-requirements.md
│       ├── system-requirements.md
│       ├── system-element-requirements.md
│       ├── traceability-matrix.md
│       ├── system-design.md
│       ├── ivv-plan.md
│       ├── integration-report.md
│       ├── verification-report.md
│       ├── validation-report.md
│       ├── system-user-manual.md
│       ├── system-operation-guide.md
│       ├── maintenance-guide.md
│       └── training-specifications.md
├── scripts/                (Automator Python scripts, if using Automator)
├── build/                  (generated outputs, gitignored)
└── TASKS.md                (generated ISO 29110 task checklist)
```

### Brownfield mode

```text
<repo-root>/                 (existing host project, otherwise unchanged)
├── README.md                 (existing, untouched)
├── .gitignore                (existing, two engineering/ entries appended)
├── CLAUDE.md                 (existing, marker block appended or replaced)
├── .vse-phase                (NEW, set to SR.1)
├── .vse-journal.yml          (NEW, empty journal)
└── engineering/              (NEW SUBFOLDER, all VSE work below)
    ├── .lsp.json             (from templates/common/lsp.json)
    ├── syside.toml           (from templates/common/syside.toml, configured)
    ├── TASKS.md              (generated)
    ├── models/
    │   ├── package.sysml
    │   ├── stakeholder-needs.sysml
    │   ├── system-requirements.sysml
    │   ├── architecture.sysml  (seeded with the harvested system context)
    │   ├── verification.sysml
    │   └── validation.sysml
    ├── docs/pm/              (9 PM templates from templates/pm/)
    ├── docs/sr/              (15 SR templates from templates/sr/, system-design.md seeded)
    └── build/                (gitignored)
```

In brownfield mode, `.vse-phase`, `.vse-journal.yml`, and `CLAUDE.md` stay
at the project root because the SessionStart hook reads them from the
current working directory. Everything else lives under `engineering/` to
keep the host project's root clean. The hooks autodetect this layout via
their `ENG_ROOT` block.

## Step 4: Populate Templates

### Greenfield mode

Copy all templates from `${CLAUDE_PLUGIN_ROOT}/templates/pm/` to `docs/pm/`
and from `${CLAUDE_PLUGIN_ROOT}/templates/sr/` to `docs/sr/`.

Copy `${CLAUDE_PLUGIN_ROOT}/templates/common/vse-journal.yml` to
`.vse-journal.yml` at the project root.

Copy `${CLAUDE_PLUGIN_ROOT}/templates/common/lsp.json` to `.lsp.json` at
the project root. The IDE reads this from the workspace, so it must live
alongside the model files.

Configure `syside.toml` with the project name.

### Brownfield mode

Copy all templates from `${CLAUDE_PLUGIN_ROOT}/templates/pm/` to
`engineering/docs/pm/` and from `${CLAUDE_PLUGIN_ROOT}/templates/sr/` to
`engineering/docs/sr/`.

Copy `${CLAUDE_PLUGIN_ROOT}/templates/common/vse-journal.yml` to
`.vse-journal.yml` at the project root.

Copy `${CLAUDE_PLUGIN_ROOT}/templates/common/lsp.json` to
`engineering/.lsp.json`. In Step 11, tell the user to open the
`engineering/` folder in their IDE for SySiDE LSP discovery, or to symlink
`engineering/.lsp.json` to the project root if their IDE expects a
root-level LSP config.

Configure `engineering/syside.toml` with the project name.

Seed `engineering/docs/sr/system-design.md` with the harvested source tree
summary in its "System overview" section so the host project's existing
layout becomes input to the SR.3 architectural decomposition.

### Placeholder substitution (both modes)

Replace the following placeholders in every copied file:

| Placeholder | Replacement |
|-------------|-------------|
| `{{PROJECT_NAME}}` | Project name |
| `{{DATE}}` | Current date (YYYY-MM-DD) |
| `{{ACQUIRER}}` | Acquirer name |
| `{{AUTHOR}}` | Author name |

### CLAUDE.md merge

The CLAUDE.md content is the same in both modes, but the way it lands in
the file system differs.

Render the merged content by:

1. Reading `${CLAUDE_PLUGIN_ROOT}/templates/common/CLAUDE.md`. The template
   already carries the AMBSE-first wording and is wrapped in marker
   delimiters at the top and bottom of the file body:
   ```text
   <!-- BEGIN VSE COMPANION (managed by project-setup) -->
   ...content...
   <!-- END VSE COMPANION -->
   ```
2. Substituting `{{PROJECT_NAME}}`, `{{DATE}}`, `{{ACQUIRER}}`, and
   `{{AUTHOR}}`.
3. **In brownfield mode only**: rewrite bare path references inside the
   marker block so they reflect the engineering subfolder layout:
   - `models/` becomes `engineering/models/`
   - `docs/pm/` becomes `engineering/docs/pm/`
   - `docs/sr/` becomes `engineering/docs/sr/`
   - `TASKS.md` becomes `engineering/TASKS.md`

   Add a leading sentence to the "Project Structure" section explaining
   that VSE work products live under `engineering/` while `.vse-phase`,
   `.vse-journal.yml`, and `CLAUDE.md` stay at the project root.

Then place the file:

- **Greenfield mode**: write the rendered content as a new `CLAUDE.md` at
  the project root. The file is the marker block plus a trailing newline.

- **Brownfield mode**: merge into the existing CLAUDE.md if any:
  - If `$PROJECT_ROOT/CLAUDE.md` does not exist, write a new file
    containing only the marker block plus a trailing newline.
  - If `$PROJECT_ROOT/CLAUDE.md` exists and already contains both markers,
    replace the bytes between (and including) the two marker lines with
    the freshly rendered marker block. The user's content outside the
    markers is preserved exactly. This makes the merge **idempotent**:
    re-running the skill picks up the current plugin version without
    duplicating or drifting from the user's surrounding text.
  - If `$PROJECT_ROOT/CLAUDE.md` exists and does not yet contain the
    markers, append a single blank line followed by the marker block plus
    a trailing newline. The user's existing content stays at the top of
    the file.

## Step 5: Create SysML 2.0 Model Files

These files live under `models/` in greenfield mode and under
`engineering/models/` in brownfield mode. The content is identical in
both modes.

Create the root package:

```sysml
// models/package.sysml
package {{PROJECT_PACKAGE}} {
    import StakeholderNeeds::*;
    import SystemRequirements::*;
    import Architecture::*;
    import Verification::*;
    import Validation::*;
}
```

Create stub files for each model domain:

```sysml
// models/stakeholder-needs.sysml
package StakeholderNeeds {
    // Stakeholder needs use STK- prefix
    // Example:
    // requirement def MonitorTemperature {
    //     doc /* The operator needs to monitor temperature. */
    // }
}
```

```sysml
// models/system-requirements.sysml
package SystemRequirements {
    // System requirements use REQ- prefix
    // Each must have a satisfy link to a stakeholder need
    // Example:
    // requirement def MeasureTemperature :> SystemRequirement {
    //     doc /* The system shall measure temperature within +/- 0.5 C. */
    //     satisfy requirement StakeholderNeeds::MonitorTemperature;
    // }
}
```

```sysml
// models/architecture.sysml
package Architecture {
    // Part definitions for the physical architecture
    // Example:
    // part def TemperatureSensor { ... }
}
```

In brownfield mode, prepend the architecture file with a comment block
listing the host project's top-level source directories (from the Step 1
harvest). This gives the SR.3 architecture work a starting point grounded
in the existing codebase.

```sysml
// models/verification.sysml
package Verification {
    // Verification cases use VER- prefix
    // Each must have a verify link to a system requirement
    // Example:
    // verification def VerifyTempAccuracy {
    //     doc /* Verify temperature measurement accuracy. */
    //     verify requirement SystemRequirements::MeasureTemperature;
    // }
}
```

```sysml
// models/validation.sysml
package Validation {
    // Validation cases use VAL- prefix
    // Each must have a verify link to a stakeholder need
    // Example:
    // validation def ValidateMonitoring {
    //     doc /* Validate the operator can monitor temperature. */
    //     verify requirement StakeholderNeeds::MonitorTemperature;
    // }
}
```

## Step 6: Generate TASKS.md

Generate a project-specific task checklist from
`${CLAUDE_PLUGIN_ROOT}/knowledge/iso29110-task-lists.md`. The generated
file should contain:

1. A header with the project name and date
2. The complete PM.1 through SR.6 task checklists
3. All checkbox items in markdown format for interactive tracking

In **greenfield mode**, write the file to `TASKS.md` at the project root.

In **brownfield mode**, write the file to `engineering/TASKS.md`. This
keeps the host project's root clean. If the host project already has its
own `TASKS.md` for unrelated work, the brownfield path leaves it alone.

## Step 7: Configure Hooks

Route to `@attention-regime` for hook installation:

1. Copy `${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh` to
   `.git/hooks/pre-commit` at the project root in both modes (the host
   project's `.git/` directory is the same in either layout).
2. Make the hook executable.
3. Confirm the `.vse-phase` file exists at the project root (created in
   earlier steps in both modes).

The hook script autodetects the engineering root via its `ENG_ROOT` block,
so the same script works under both layouts without configuration.

Inform the user that the hook will:
- Block commits with broken SysML 2.0 trace links
- Report the engineering root it detected on each invocation

## Step 8: Detect and Configure SySiDE

The `.lsp.json` copied in Step 4 wires the Claude Code IDE to the SySiDE
language server. In greenfield mode it sits at the project root. In
brownfield mode it sits at `engineering/.lsp.json`. It activates the next
time the user opens the project (or the `engineering/` folder, in
brownfield mode) in Claude Code, provided the `syside` command is on the
PATH. The checks below confirm that prerequisite and set up the CLI and
Automator workflows that sit alongside the IDE integration.

Check whether the SySiDE CLI is available:

```bash
syside --version
```

**If available:**

1. Verify the `syside.toml` configuration is complete (already populated
   in Step 4).
2. Run an initial validation to confirm the toolchain works. The path
   depends on the mode:
   ```bash
   # greenfield
   syside check --stats
   # brownfield
   syside check --stats engineering/
   ```
3. If the licence is not set, inform the user:
   ```bash
   export SYSIDE_LICENSE_KEY="your-licence-key"
   # Or create a .env file (add .env to .gitignore):
   echo "SYSIDE_LICENSE_KEY=your-licence-key" > .env
   ```
4. Run initial formatting to establish a baseline:
   ```bash
   # greenfield
   syside format
   # brownfield
   syside format engineering/
   ```

**Check Automator availability:**

```bash
python -c "import syside; print(syside.__version__)"
```

If the Automator Python library is available:

1. Confirm it is installed in a virtual environment (`.venv/` in greenfield
   mode, `engineering/.venv/` in brownfield mode).
2. Verify the relevant `.venv/` path is in `.gitignore`.
3. Inform the user of available Automator workflows:
   - Requirements export to Excel (`@needs-and-requirements`)
   - Semantic trace checking (`@traceability-guard`)
   - Value rollup and variant analysis (`@architecture-design`)
   - Model-based report generation (`@document-export`)

If the Automator is not installed but a Modeler licence exists, suggest:

```bash
# greenfield
python -m venv .venv
source .venv/bin/activate
pip install syside

# brownfield
python -m venv engineering/.venv
source engineering/.venv/bin/activate
pip install syside
```

**If neither CLI nor Automator is available:**

Inform the user that the SySiDE tools are optional but recommended:

- **CLI** requires Java 21 runtime and a Modeler licence. `syside check`
  provides deeper semantic validation than the grep-based traceability
  hook, and `syside format` ensures consistent model formatting.
- **Automator** requires Python 3.12+ and a licence (same key as Modeler).
  It enables programmatic model analysis, requirements import/export, and
  report generation.
- **Editor** (free VS Code extension) provides syntax highlighting and
  basic validation without any licence.

See `${CLAUDE_PLUGIN_ROOT}/knowledge/syside-automator-ref.md` for the full
tool selection guide.

## Step 9: Detect Other Integrations

### GitHub MCP

Check whether GitHub MCP tools are available (for example, `mcp__github`
functions). If available:

1. Offer to create a GitHub repository (greenfield mode only; brownfield
   already has one).
2. Suggest setting up branch protection on main.
3. Offer to copy GitHub Actions workflows from
   `${CLAUDE_PLUGIN_ROOT}/templates/github/`:
   - `traceability-check.yml`: PR-time trace gate (microcycle handoff)
   - `phase-gate.yml`: PR-time phase gate (macrocycle transition)
   - `document-export.yml`: generates documents on release tags
4. Copy the PR template from
   `${CLAUDE_PLUGIN_ROOT}/templates/github/pull-request-template.md`.

If GitHub MCP is not available, skip this step and inform the user they
can set up GitHub integration later. The CI workflows are host-agnostic
bash wrappers and translate mechanically to GitLab CI, Forgejo Actions, or
Gitea Actions.

### Other Plugins

Check for the presence of other Claude Code plugins and inform the user
of integration points:

| Plugin | Integration |
|--------|-------------|
| superpowers | Use `@writing-plans` for SE planning, `@test-driven-development` for SR.4 |
| product-management | Use `@write-spec` for SOW drafting, `@stakeholder-update` for PM.2 |
| engineering | Use `@architecture` for ADRs during SR.3, `@review` for SR.4 |
| document-skills | Use `@docx` and `@pptx` for work product export via `@document-export` |

## Step 10: Initial Commit

### Greenfield mode

Create the initial commit with all scaffolded files:

```bash
git add -A
git commit -m "Initial project setup: ISO 29110 structure with SysML 2.0 models

Scaffolded by @project-setup:
- PM work product templates (9 files)
- SR work product templates (15 files)
- SysML 2.0 model stubs (6 files)
- TASKS.md with full ISO 29110 checklist
- Pre-commit traceability hook
- Session journal (.vse-journal.yml, empty)
- CLAUDE.md with VSE-first guidance for Claude Code
- Phase tracking (.vse-phase = SR.1)"
```

### Brownfield mode

Skip the commit step entirely. The host project already has a working
git workflow and its own commit conventions. The user will stage and
commit the new files (`engineering/`, `.vse-phase`, `.vse-journal.yml`,
the modified `.gitignore`, the merged `CLAUDE.md`) in their own style,
following the AMBSE branch-per-microcycle workflow described in the
merged CLAUDE.md.

In the Step 11 summary, remind the user that the first commit they make
should land on a `vse/iter-00-architecture-zero` branch, not directly on
their default branch.

## Step 11: Present Summary

### Greenfield mode

```text
PROJECT SETUP COMPLETE (greenfield)
====================================
Project:    [name]
Phase:      SR.1 (Initiation)
Repository: [path]

Structure:
  docs/pm/   9 PM work product templates
  docs/sr/  15 SR work product templates
  models/    6 SysML 2.0 model files
  TASKS.md   Full ISO 29110 task checklist
  .vse-journal.yml  Session journal (empty, ready for use)

Hooks:
  pre-commit  Traceability check on .sysml files

Next Steps:
  1. Review the Project Plan (docs/pm/project-plan.md)
  2. Generate the SEMP (docs/sr/semp.md)
  3. Define the data model in models/
  4. Complete SR.1 tasks in TASKS.md
```

### Brownfield mode

```text
VSE ADDED TO EXISTING PROJECT (brownfield)
===========================================
Project:        [name]
Phase:          SR.1 (Initiation)
Repository:     [path]
Engineering:    engineering/

New at project root:
  .vse-phase           Phase tracker (= SR.1)
  .vse-journal.yml     Session journal (empty, ready for use)
  CLAUDE.md            VSE companion block merged into existing file

New under engineering/:
  models/              6 SysML 2.0 model files
  docs/pm/             9 PM work product templates
  docs/sr/            15 SR work product templates (system-design.md seeded)
  TASKS.md             Full ISO 29110 task checklist
  syside.toml          SySiDE configuration
  .lsp.json            IDE language server config

Updated:
  .gitignore           engineering/build/ and engineering/.venv/ appended

Hooks:
  pre-commit           Traceability check (autodetects engineering/ root)

Next Steps:
  1. Open engineering/ in your IDE so SySiDE picks up .lsp.json
     (or symlink engineering/.lsp.json to the project root)
  2. Create a vse/iter-00-architecture-zero branch and stage the new files
  3. Review engineering/docs/pm/project-plan.md (the harvested context is
     reflected in the System overview of engineering/docs/sr/system-design.md)
  4. Open the first iteration via @lifecycle-orchestrator
```

In both modes, route to `@lifecycle-orchestrator` for ongoing phase
navigation.

## Error Handling

- **Greenfield**: if the target directory already exists and contains
  files, warn the user and ask whether to proceed (risk of overwriting).
- **Brownfield**: if `.vse-phase` already exists at the project root, the
  Step 0 detection will already have routed to `@lifecycle-orchestrator`.
  If any of the new files (`engineering/`, `.vse-journal.yml`) already
  exist for an unrelated reason, warn the user and ask whether to merge
  or abort. Never overwrite an existing `engineering/` directory without
  explicit confirmation.
- If git is not installed in greenfield mode, create the structure
  without `git init` and inform the user.
- If template files are missing from the plugin, report which templates
  could not be found and continue with available templates.

## Cross-References

- `@lifecycle-orchestrator`: routes here for new projects, receives handoff after setup
- `@attention-regime`: hook installation and environment configuration
- `@sysml2-modelling`: SysML 2.0 model conventions and validation
- `@traceability-guard`: verifies trace completeness in models
- `@document-export`: generates docx/pptx from the populated templates
- `${CLAUDE_PLUGIN_ROOT}/knowledge/iso29110-task-lists.md`: source for TASKS.md generation
- `${CLAUDE_PLUGIN_ROOT}/knowledge/iso29110-profile.md`: ISO 29110 process reference
- `${CLAUDE_PLUGIN_ROOT}/knowledge/ambse-git-workflow.md`: branch-per-microcycle workflow that the merged CLAUDE.md points to

## Reference: ISO 29110 Task Lists

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/iso29110-task-lists.md`

## Reference: ISO 29110 Profile

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/iso29110-profile.md`
