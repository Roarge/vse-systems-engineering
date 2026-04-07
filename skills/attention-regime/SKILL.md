---
name: attention-regime
description: Configure environmental hooks, guards, and reminders for sustained attention. Use when setting up the SE environment, running health checks, or adjusting process rigour.
user-invocable: true
---

# Attention Regime

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You are the meta-skill that configures the working environment for sustained
attention to systems engineering practices. This skill implements R4 (sustain
attention through environmental design) using niche construction: actively
reshaping the environment so that good SE practice becomes the path of least
resistance.

## When This Skill Triggers

- The user asks to set up or configure the SE environment
- The user asks about hooks, guards, or reminders
- The user asks for a project health check
- The `@iteration-orchestrator` routes here for environment configuration

## Why These Hooks

The hooks, guards, and reminders configured below are not arbitrary
conveniences. They are environmental interventions in the PHAS-EAI sense
(Predictive Homeostatic Allostatic Stress, Environmental Adaptation
Index), the framework that motivates this plugin's R4 attention regime.
The hooks reshape the engineering environment so that traceability,
iteration discipline, and verification become the path of least
resistance rather than acts of remembered virtue. See the embedded PHAS-EAI
framework reference at the bottom of this skill for the full rationale,
the lever taxonomy, and the calibration guidance that informs the
adjustments offered later in this skill.

## Environment Configuration

### Step 1: Set Up Hooks

This plugin provides two layers of hooks:

**Claude Code hooks** (`hooks.json` at the plugin root):
- **SessionStart**: automatically reads `.vse-iteration.yml` and
  `.vse-journal.yml` at the start of every session, presenting the
  iteration position (iteration number, mission, status, centre of
  gravity) and session continuity context without manual invocation.
- **PostToolUse (Write/Edit)**: when a `.sysml` file is modified, reminds the
  engineer to maintain trace links and check traceability.

These hooks fire automatically when the plugin is installed. No manual setup
is required.

**Git hooks** (installed per project during `@project-setup`):

**Pre-commit traceability hook** (`hooks/pre-commit-traceability.sh`):
- Fires before every commit that includes .sysml files
- Checks that all requirements have satisfy and verify links
- Blocks the commit if trace gaps are found
- Install: copy from the plugin to the project's `.git/hooks/pre-commit`

```bash
# Install the git hook (run from the project directory)
cp ${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**Iteration-boundary check** (`hooks/iteration-boundary-check.sh`):
- Checks work product completeness across every active centre-of-gravity
  activity listed in `.vse-iteration.yml`
- Called manually or by `@iteration-orchestrator` at iteration close
- Advisory only: reports missing items as iteration-boundary closure debt
  and exits 0. The hard closure gate lives at the macrocycle (release
  tag), not here.

### Step 2: Set Up Iteration Tracking

Ensure `.vse-iteration.yml` exists at the project root. If it does not,
route to `@project-setup`, which owns the state file template
(`${CLAUDE_PLUGIN_ROOT}/templates/common/vse-iteration.yml`). This skill
installs hooks and does not own the content of the iteration state file.

The iteration state is read by `@iteration-orchestrator` to determine the
current microcycle number, mission, and centre of gravity. Update it only
through the iteration-open and iteration-close procedures owned by
`@iteration-orchestrator` (the `/vse-microcycle` and `/vse-iteration`
commands).

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
`${CLAUDE_PLUGIN_ROOT}/templates/pm/` and `${CLAUDE_PLUGIN_ROOT}/templates/sr/`.

### Step 4: Configure SySiDE Tooling

If the user has Sensmetry SySiDE installed:

1. Copy the annotated `syside.toml` template from
   `${CLAUDE_PLUGIN_ROOT}/templates/common/syside.toml` to the project root.
   Populate the project name.

2. Verify the CLI is available:
   ```bash
   syside --version
   ```
   If not found, the user needs Java 21 and the Syside CLI installed. See
   `@sysml2-modelling` for installation details.

3. Verify the licence:
   ```bash
   export SYSIDE_LICENSE_KEY="your-licence-key"
   syside check --stats
   ```
   For CI/CD, use a Deployment Licence Key (prefix `CI-`) stored in secrets.

## Patterned Practice Prompts

These prompts implement the ritualised interactions that sustain attention.
They should be triggered at specific lifecycle moments:

### On Project Start
- "Have you identified all stakeholders and their key concerns?"
- "Have you reviewed the Statement of Work with the Work Team?"
- "Have you established the Project Repository and CM strategy?"

### On Iteration Close
- "Have you run the iteration-boundary closure check for the active
  centre-of-gravity activities?"
- "Have you updated the Traceability Matrix for every thread this
  iteration touched?"
- "Have you recorded any unresolved items as explicit iteration-boundary
  closure debt on the next iteration's backlog?"

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
| Iteration-boundary skipping | Closing an iteration without running the closure check | Flag the skipped check, offer to run it now. Concurrent SR.2 and SR.3 activity inside one iteration is NOT skipping. |
| Skipping nanocycle verification | "We will verify later" on a commit that touches a baselined artefact | Remind that every nanocycle should carry at least one verification action tied to the anchor thread |
| Baseline violations | Modifying baselined artefacts without Change Request | Flag the violation, guide Change Request creation |
| Orphan artefacts | Work products with no input lineage (no anchor thread in the iteration backlog or an existing baseline) | Ask which backlog item, requirement, or design element this anchors on |
| Process decay | Hooks disabled, `.vse-iteration.yml` stale, matrix not updated | Run a health check |
| Backward drift | Reopening settled requirements without a Change Request | Flag the change, require a Change Request |
| Macrocycle debt accrual | Iteration-boundary closure debt carried across multiple iterations without a resolution plan | Flag as orphaned output risk, request baseline linkage and a closure plan before the macrocycle release gate |

## Project Health Check

When the user asks for a health check, or when drift indicators accumulate,
run this diagnostic:

### Environment Check
- [ ] `.vse-iteration.yml` file exists at the project root with a valid
      `current_iteration` block (number, mission, status, centre of
      gravity)
- [ ] `models/` directory exists with .sysml files
- [ ] Git hooks are installed (`.git/hooks/pre-commit` exists)
- [ ] `syside.toml` exists (if SySiDE is being used)
- [ ] `docs/pm/` contains all 9 PM work product templates
- [ ] `docs/sr/` contains all 15 SR work product templates
- [ ] `TASKS.md` exists with ISO 29110 task checklist
- [ ] `build/` directory exists and is gitignored
- [ ] `scripts/` directory exists (if using Automator)
- [ ] `.venv/` is gitignored (if using Automator)

### Tooling Check

**SySiDE CLI** (if `syside --version` succeeds):

```bash
# Semantic validation of all models
syside check --warnings-as-errors --stats

# Format compliance
syside format --check
```

If `syside check` fails, the model has semantic errors that go beyond trace
gaps. Fix these before closing the current iteration.

If `syside format --check` fails, run `syside format` to fix formatting, then
commit the formatted files.

**Syside Automator** (if `python -c "import syside"` succeeds):

```bash
# Check Automator availability and version
python -c "import syside; print(syside.__version__)"
```

If Automator is available, report version and suggest using Automator-enhanced
workflows:
- Semantic trace checking via `@traceability-guard` (Automator section)
- Requirements Excel export via `@needs-and-requirements` (Import/Export section)
- Value rollup and variant analysis via `@architecture-design` (Model Analysis section)
- Model-based report generation via `@document-export` (Report Generation section)

If Automator is not installed but a licence key is set, suggest:

```bash
python -m venv .venv && source .venv/bin/activate && pip install syside
```

### Process Check
- [ ] Work products required by the active centre-of-gravity activities
      exist per ISO 29110 (run `hooks/iteration-boundary-check.sh` to
      accumulate findings)
- [ ] Traceability Matrix is up to date (invoke `@traceability-guard`)
- [ ] No baselined artefacts modified without Change Request
- [ ] Previous iteration closure report recorded in `.vse-iteration.yml`
      `history[]`, with any carry-forward items listed in
      `closure_debt[]`
- [ ] `syside check` passes without errors (if CLI available)
- [ ] `syside format --check` passes (if CLI available)

### Model Check
- [ ] All .sysml files have valid package declarations
- [ ] All requirements have unique IDs
- [ ] All requirements have satisfy and verify links
- [ ] No orphan verification cases
- [ ] `syside check --warnings-as-errors` passes (if CLI available)

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
| Niche construction | Env. configuration | Add or remove hooks, adjust iteration-boundary closure rigour |

To adjust a lever, the engineer discusses the desired change and this skill
modifies the environment configuration accordingly. For example:
- "Relax iteration-boundary closure for prototyping iterations" reduces
  the closure rigour for scratch iterations while leaving the macrocycle
  gate intact
- "Add stricter traceability for safety-critical work" increases observation
  precision and tightens iteration-boundary closure

## Red Flags

WARN the engineer if:
- Hooks have been disabled or removed
- The `.vse-iteration.yml` file is missing, malformed, or contains no
  valid `current_iteration` block
- The project has no .sysml files in the models/ directory
- Multiple drift indicators are active simultaneously
- The health check shows "AT RISK" status

## Reference: PHAS-EAI Framework

Source: Georgsen (2026), Resilient Smart City Design, the design rationale
for this plugin's environmental interventions and lever calibration.

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/phas-eai-framework.md`
