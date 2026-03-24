---
name: attention-regime
description: Configure environmental hooks, guards, and reminders that sustain attention through niche construction (R4).
user-invocable: true
---

# Attention Regime

You are the meta-skill that configures the working environment for sustained
attention to systems engineering practices. This skill implements R4 (sustain
attention through environmental design) using niche construction: actively
reshaping the environment so that good SE practice becomes the path of least
resistance.

## When This Skill Triggers

- The user asks to set up or configure the SE environment
- The user asks about hooks, guards, or reminders
- The user asks for a project health check
- The `@lifecycle-orchestrator` routes here for environment configuration

## Environment Configuration

### Step 1: Set Up Hooks

Configure the two project hooks:

**Pre-commit traceability hook** (`hooks/pre-commit-traceability.sh`):
- Fires before every commit that includes .sysml files
- Checks that all requirements have satisfy and verify links
- Blocks the commit if trace gaps are found
- Install: symlink or copy to `.git/hooks/pre-commit`

```bash
# Install the hook
cp hooks/pre-commit-traceability.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**Phase gate check** (`hooks/phase-gate-check.sh`):
- Checks work product completeness for the current phase
- Called manually or by `@lifecycle-orchestrator` at transitions
- Does not block automatically but reports missing items

### Step 2: Set Up Phase Tracking

Create the `.vse-phase` file:

```bash
echo "SR.1" > .vse-phase
```

This file is read by `@lifecycle-orchestrator` to determine the current phase.
Update it only through the phase gate procedure.

### Step 3: Set Up Project Structure

Ensure the standard directory layout exists:

```
models/           (SysML 2.0 .sysml files)
docs/
├── pm/           (PM work products from templates)
└── sr/           (SR work products from templates)
build/            (generated outputs, gitignored)
TASKS.md          (ISO 29110 task checklist)
```

If the project was created with `@project-setup`, this structure already
exists. If not, create missing directories and copy templates from
`templates/pm/` and `templates/sr/`.

### Step 4: Configure SySiDE Tooling

If the user has Sensmetry SySiDE installed, create `syside.toml`:

```toml
[project]
name = "ProjectName"

[build]
source = ["models"]
```

## Patterned Practice Prompts

These prompts implement the ritualised interactions that sustain attention.
They should be triggered at specific lifecycle moments:

### On Project Start
- "Have you identified all stakeholders and their key concerns?"
- "Have you reviewed the Statement of Work with the Work Team?"
- "Have you established the Project Repository and CM strategy?"

### On Phase Transition
- "Have you completed the phase gate checklist?"
- "Have you updated the Traceability Matrix?"
- "Have you obtained the required approvals?"

### On Work Product Creation
- "Which ISO 29110 task does this work product belong to?"
- "What are the required inputs for this work product?"
- "Who needs to review this before it is baselined?"

### On Commit (enforced by hook)
- "Do all modified requirements maintain their trace links?"
- "Have you updated the Traceability Matrix?"

## Attention Drift Monitoring

Watch for these drift indicators and raise them with the engineer:

| Indicator | What It Means | Response |
|-----------|--------------|----------|
| Phase jumping | Working on architecture during requirements phase | Flag out-of-phase activity, suggest completing current phase |
| Skipping verification | "We will test later" | Remind that V&V planning happens during SR.2, not after construction |
| Baseline violations | Modifying baselined artefacts without Change Request | Flag the violation, guide Change Request creation |
| Orphan artefacts | Work products not linked to any ISO 29110 task | Ask which task this belongs to |
| Process decay | Hooks disabled, phase file outdated, matrix not updated | Run a health check |
| Backward drift | Reopening settled requirements during construction or IVV | Flag the change, require a Change Request before proceeding |
| Artefact gap | Creating outputs (e.g., architecture) without required inputs (e.g., baselined requirements) | Halt and verify prerequisites exist before continuing |

## Project Health Check

When the user asks for a health check, or when drift indicators accumulate,
run this diagnostic:

### Environment Check
- [ ] `.vse-phase` file exists and contains a valid phase
- [ ] `models/` directory exists with .sysml files
- [ ] Git hooks are installed (`.git/hooks/pre-commit` exists)
- [ ] `syside.toml` exists (if SySiDE is being used)
- [ ] `docs/pm/` contains all 9 PM work product templates
- [ ] `docs/sr/` contains all 15 SR work product templates
- [ ] `TASKS.md` exists with ISO 29110 task checklist
- [ ] `build/` directory exists and is gitignored

### Process Check
- [ ] Current phase work products exist per ISO 29110
- [ ] Traceability Matrix is up to date (invoke `@traceability-guard`)
- [ ] No baselined artefacts modified without Change Request
- [ ] Phase gate checklist for previous transition was completed

### Model Check
- [ ] All .sysml files have valid package declarations
- [ ] All requirements have unique IDs
- [ ] All requirements have satisfy and verify links
- [ ] No orphan verification cases

### Report Format

```
PROJECT HEALTH CHECK
====================
Environment:  [n/n passed]
Process:      [n/n passed]
Model:        [n/n passed]

Issues found: [n]
  [list each issue with severity and suggested fix]

Overall: [HEALTHY / ATTENTION NEEDED / AT RISK]
```

## Lever Table Calibration

From the PHAS-EAI framework (Tables 17-20), the following levers can be
adjusted through this skill:

| Lever | Current Setting | Adjustment Available |
|-------|----------------|---------------------|
| Designed reserve (h) | LLM active | Enable/disable specific skill guidance |
| Observation precision | SysML models | Increase model detail or add views |
| Practice ritualisation | Hooks + prompts | Add or remove patterned practice prompts |
| Niche construction | Env. configuration | Add or remove hooks, adjust gate rigour |

To adjust a lever, the engineer discusses the desired change and this skill
modifies the environment configuration accordingly. For example:
- "Relax phase gates for prototyping" reduces gate rigour
- "Add stricter traceability for safety-critical work" increases observation
  precision and gate rigour

## Red Flags

WARN the engineer if:
- Hooks have been disabled or removed
- The `.vse-phase` file is missing or contains an invalid phase
- The project has no .sysml files in the models/ directory
- Multiple drift indicators are active simultaneously
- The health check shows "AT RISK" status
