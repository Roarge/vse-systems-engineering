---
name: project-setup
description: Bootstrap a new VSE systems engineering project. Use when starting a new project, scaffolding, or initialising ISO 29110 structure.
user-invocable: true
---

# Project Setup

You are the project bootstrapping skill for VSE systems engineering. You create
a complete project structure aligned with ISO/IEC 29110, populate it with work
product templates, and configure the development environment.

## When This Skill Triggers

- The user asks to start a new project, create a project, or set up a project
- The `@lifecycle-orchestrator` routes here for new project initialisation
- The user says "bootstrap", "scaffold", or "initialise a project"

## Step 1: Gather Project Information

Ask the user for:

1. **Project name** (used for directory, package names, and template placeholders)
2. **Brief description** (one sentence describing the system)
3. **Acquirer name** (the customer or sponsor)
4. **Primary stakeholder roles** (users, maintainers, regulators, or other parties
   with interest in the system)

If the user provides a Statement of Work, extract this information from it.

Store the gathered information for template population:
- `{{PROJECT_NAME}}`: project name in plain text
- `{{PROJECT_PACKAGE}}`: project name in PascalCase (for SysML 2.0 packages)
- `{{DATE}}`: current date in YYYY-MM-DD format
- `{{ACQUIRER}}`: acquirer name
- `{{AUTHOR}}`: user name (ask if not known)

## Step 2: Initialise Git Repository

```bash
mkdir -p <project-name>
cd <project-name>
git init
```

Copy the `.gitignore` from `${CLAUDE_PLUGIN_ROOT}/templates/common/gitignore`. This
ensures generated files (docx, pptx, pdf) are excluded from version control.

## Step 3: Create Directory Structure

```
<project-name>/
├── .vse-phase              (from templates/common/vse-phase, set to SR.1)
├── .vse-journal.yml        (from templates/common/vse-journal.yml, empty journal)
├── .gitignore              (from templates/common/gitignore)
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

## Step 4: Populate Templates

Copy all templates from `${CLAUDE_PLUGIN_ROOT}/templates/pm/` to `docs/pm/` and
from `${CLAUDE_PLUGIN_ROOT}/templates/sr/` to `docs/sr/`. Copy
`${CLAUDE_PLUGIN_ROOT}/templates/common/CLAUDE.md` to the project root.
Replace the following placeholders in every copied file:

| Placeholder | Replacement |
|-------------|-------------|
| `{{PROJECT_NAME}}` | Project name |
| `{{DATE}}` | Current date (YYYY-MM-DD) |
| `{{ACQUIRER}}` | Acquirer name |
| `{{AUTHOR}}` | Author name |

Copy `${CLAUDE_PLUGIN_ROOT}/templates/common/vse-journal.yml` to `.vse-journal.yml`
in the project root. This file does not contain placeholders and requires no
substitution.

Configure `syside.toml` with the project name.

## Step 5: Create SysML 2.0 Model Files

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
`${CLAUDE_PLUGIN_ROOT}/knowledge/iso29110-task-lists.md`. The generated TASKS.md should contain:

1. A header with the project name and date
2. The complete PM.1 through SR.6 task checklists
3. All checkbox items in markdown format for interactive tracking

This file lives in the project root and serves as the master checklist for
the entire project lifecycle.

## Step 7: Configure Hooks

Route to `@attention-regime` for hook installation:

1. Copy `${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh` to `.git/hooks/pre-commit`
2. Make it executable
3. Create the `.vse-phase` file (already done in Step 3)

Inform the user that the hooks will:
- Block commits with broken SysML 2.0 trace links
- Report the current lifecycle phase on each interaction

## Step 8: Detect and Configure SySiDE

Check whether the SySiDE CLI is available:

```bash
syside --version
```

**If available:**

1. Copy the annotated `syside.toml` from
   `${CLAUDE_PLUGIN_ROOT}/templates/common/syside.toml` (already done in Step 3,
   but verify the configuration is complete)
2. Run an initial validation to confirm the toolchain works:
   ```bash
   syside check --stats
   ```
3. If the licence is not set, inform the user:
   ```bash
   export SYSIDE_LICENSE_KEY="your-licence-key"
   # Or create a .env file (add .env to .gitignore):
   echo "SYSIDE_LICENSE_KEY=your-licence-key" > .env
   ```
4. Run initial formatting to establish a baseline:
   ```bash
   syside format
   ```

**Check Automator availability:**

```bash
python -c "import syside; print(syside.__version__)"
```

If the Automator Python library is available:

1. Confirm it is installed in a virtual environment (`.venv/`)
2. Verify `.venv/` is in `.gitignore`
3. Add `scripts/` to the project directory structure for Automator scripts
4. Inform the user of available Automator workflows:
   - Requirements export to Excel (`@needs-and-requirements`)
   - Semantic trace checking (`@traceability-guard`)
   - Value rollup and variant analysis (`@architecture-design`)
   - Model-based report generation (`@document-export`)

If the Automator is not installed but a Modeler licence exists, suggest:

```bash
python -m venv .venv
source .venv/bin/activate
pip install syside
echo ".venv/" >> .gitignore
mkdir -p scripts
```

**If neither CLI nor Automator is available:**

Inform the user that the SySiDE tools are optional but recommended:

- **CLI** requires Java 21 runtime and a Modeler licence. `syside check`
  provides deeper semantic validation than the grep-based traceability hook,
  and `syside format` ensures consistent model formatting.
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

1. Offer to create a GitHub repository
2. Suggest setting up branch protection on main
3. Offer to create GitHub Actions workflows from `templates/github/`:
   - `traceability-check.yml`: checks trace links on PRs (from `${CLAUDE_PLUGIN_ROOT}/templates/github/`)
   - `phase-gate.yml`: validates phase transitions
   - `document-export.yml`: generates documents on release tags
   All workflow templates are in `${CLAUDE_PLUGIN_ROOT}/templates/github/`.
4. Copy the PR template from `${CLAUDE_PLUGIN_ROOT}/templates/github/pull-request-template.md`

If GitHub MCP is not available, skip this step and inform the user they can
set up GitHub integration later.

### Other Plugins

Check for the presence of other Claude Code plugins and inform the user of
integration points:

| Plugin | Integration |
|--------|-------------|
| superpowers | Use `@writing-plans` for SE planning, `@test-driven-development` for SR.4 |
| product-management | Use `@write-spec` for SOW drafting, `@stakeholder-update` for PM.2 |
| engineering | Use `@architecture` for ADRs during SR.3, `@review` for SR.4 |
| document-skills | Use `@docx` and `@pptx` for work product export via `@document-export` |

## Step 10: Initial Commit

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

## Step 11: Present Summary

Present the project summary to the user:

```
PROJECT SETUP COMPLETE
======================
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

Route to `@lifecycle-orchestrator` for ongoing phase navigation.

## Error Handling

- If the target directory already exists and contains files, warn the user
  and ask whether to proceed (risk of overwriting)
- If git is not installed, create the structure without git init and inform
  the user
- If template files are missing from the plugin, report which templates could
  not be found and continue with available templates

## Cross-References

- `@lifecycle-orchestrator`: routes here for new projects, receives handoff after setup
- `@attention-regime`: hook installation and environment configuration
- `@sysml2-modelling`: SysML 2.0 model conventions and validation
- `@traceability-guard`: verifies trace completeness in models
- `@document-export`: generates docx/pptx from the populated templates
- `${CLAUDE_PLUGIN_ROOT}/knowledge/iso29110-task-lists.md`: source for TASKS.md generation
- `${CLAUDE_PLUGIN_ROOT}/knowledge/iso29110-profile.md`: ISO 29110 process reference

## Reference: ISO 29110 Task Lists

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/iso29110-task-lists.md`

## Reference: ISO 29110 Profile

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/iso29110-profile.md`
