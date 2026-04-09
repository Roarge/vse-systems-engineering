---
name: project-audit
description: >-
  Audit an existing VSE project for structural completeness, version drift,
  and non-canonical configuration. Use when checking project health,
  upgrading from an older plugin version, or verifying setup correctness.
  Read-only, never modifies files.
user-invocable: true
---

# Project Audit

If the VSE lens has not been set in this session, invoke
`vse-companion-overview` first, then continue.

You are the project auditing skill for VSE systems engineering. You check
an existing VSE project against the canonical structure defined by the
current plugin version and produce a structured report of findings.

**This skill is strictly read-only.** It never modifies files, creates
directories, installs hooks, or writes to disk. It produces a report and
optionally a remediation plan. The user decides what to act on.

## When This Skill Triggers

- The user asks to audit, check, or verify their VSE project setup
- The user asks if their project is up to date with the current plugin
- The user asks what is missing from their project
- The user asks to upgrade or refresh their project structure
- The `@iteration-orchestrator` routes here on detected structural issues

## Step 0: Detect Layout

Run the following to confirm the project is VSE-initialised:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

If not inside a git repository, report "This is not a git repository.
The audit requires an existing VSE project." and exit.

Capture the repository root:

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
```

Check for the VSE iteration file:

```bash
test -f "$PROJECT_ROOT/.vse-iteration.yml"
```

If the file does not exist, report: "This project has not been set up
with the VSE plugin. Run `/vse-setup` first." and exit.

Detect the layout:

```bash
test -d "$PROJECT_ROOT/engineering"
```

- **Directory exists**: brownfield layout. Set `MODEL_ROOT` to
  `$PROJECT_ROOT/engineering/models` and `DOC_ROOT` to
  `$PROJECT_ROOT/engineering/docs`.
- **Directory does not exist**: greenfield layout. Set `MODEL_ROOT` to
  `$PROJECT_ROOT/models` and `DOC_ROOT` to `$PROJECT_ROOT/docs`.

## Step 1: Structural Completeness Checks

For each check, record a finding with one of these severity levels:

| Severity | Meaning |
|----------|---------|
| CRITICAL | Required file missing or project cannot function correctly |
| OUTDATED | File exists but content is from an older plugin version |
| OPTIONAL | Optional file or feature not present (informational) |
| NON-CANONICAL | File exists but in a non-standard location or format |

### Check 1: Root Files

1. **`.vse-iteration.yml`**: must exist (already confirmed in Step 0).
   Parse the `version` field. If absent or not `1`, report OUTDATED.
   Check for required fields under `current_iteration`:
   `number`, `mission`, `branch`, `status`, `centre_of_gravity`,
   `opened`, `macrocycle_target`, `backlog`. Report any missing fields
   as OUTDATED.

2. **`.vse-journal.yml`**: check existence at `$PROJECT_ROOT`. If
   missing, report CRITICAL.

3. **`CLAUDE.md`**: check existence at `$PROJECT_ROOT`. If missing,
   report CRITICAL. If present, check for the marker block delimiters:
   ```
   <!-- BEGIN VSE COMPANION (managed by project-setup) -->
   <!-- END VSE COMPANION -->
   ```
   If markers are absent, report NON-CANONICAL ("CLAUDE.md exists but
   does not contain the VSE companion marker block").
   If markers are present, extract the marker block content and compare
   it against the current template at
   `${CLAUDE_PLUGIN_ROOT}/templates/common/CLAUDE.md` (after
   placeholder substitution using values from the project). If content
   differs, report OUTDATED with a summary of what changed.

### Check 2: Model Files and Directory Structure

1. **Detect the model tier.** Scan `$MODEL_ROOT` for the layout:

   - **Package directories present** (subdirectories like `actors/`,
     `requirements/`, `verification/` each containing `.sysml` files):
     this is the package-per-directory layout (0.14.0+).
     - If `functional-analysis/` and `arch-analysis/` and
       `configurations/` are present: **Canonical AMBSE**.
     - If those are absent: **Minimal AMBSE**.
   - **Flat `.sysml` files at root** (`package.sysml` or
     `model-overview.sysml` with no subdirectories): this is the flat
     layout (pre-0.14.0 or Flat tier).
     - If `model-overview.sysml` exists with short-code-prefixed
       packages: **Minimal or Canonical (flat layout, pre-0.14.0)**.
       Report NON-CANONICAL ("model files use flat layout, current
       plugin version uses package-per-directory").
     - If `package.sysml` exists with non-prefixed packages
       (`StakeholderNeeds`, `SystemRequirements`): **Flat tier**.

2. **Check VSE Library.** Look for `$MODEL_ROOT/library/vse-library.sysml`.
   If the tier is Minimal or Canonical and the library is missing, report
   CRITICAL ("VSE Library missing, introduced in plugin version 0.13.0").

3. **Check per-package views.** For each package directory, check that
   both a definition file and a `-view.sysml` file exist. If views are
   missing, report OUTDATED ("package views missing, introduced in plugin
   version 0.14.0").

4. **Check cross-cutting views.** Look for
   `$MODEL_ROOT/traceability-view.sysml`. If missing and tier is Minimal
   or Canonical, report OUTDATED.

5. **Check `model-overview.sysml`.** Must exist at `$MODEL_ROOT` for
   Minimal and Canonical tiers. For Flat tier, check `package.sysml`.

6. **Check optional packages.** Look for `base-architecture/`,
   `configurations/` (Minimal only, since Canonical includes it),
   `cm/`. Report as OPTIONAL if missing.

### Check 3: Document Templates

1. **PM templates.** Count files in `$DOC_ROOT/pm/`. The canonical set
   has 9 files. List any missing from:
   `project-plan.md`, `statement-of-work.md`, `progress-status.md`,
   `meeting-record.md`, `change-request.md`, `correction-register.md`,
   `justification-document.md`, `purchase-order.md`,
   `product-acceptance.md`.
   Report missing files as CRITICAL.

2. **SR templates.** Count files in `$DOC_ROOT/sr/`. The canonical set
   has 15 files. List any missing from:
   `semp.md`, `data-model.md`, `stakeholder-requirements.md`,
   `system-requirements.md`, `system-element-requirements.md`,
   `traceability-matrix.md`, `system-design.md`, `ivv-plan.md`,
   `integration-report.md`, `verification-report.md`,
   `validation-report.md`, `system-user-manual.md`,
   `system-operation-guide.md`, `maintenance-guide.md`,
   `training-specifications.md`.
   Report missing files as CRITICAL.

3. **TASKS.md.** Check for `TASKS.md` at the project root (greenfield)
   or `$PROJECT_ROOT/engineering/TASKS.md` (brownfield). If missing,
   report CRITICAL.

### Check 4: Hooks

1. **Pre-commit traceability hook.** Check
   `$PROJECT_ROOT/.git/hooks/pre-commit`:
   - Does the file exist? If not, report CRITICAL.
   - Is it executable? If not, report NON-CANONICAL.
   - Compare its content against
     `${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh`.
     If content differs, report OUTDATED ("pre-commit hook does not
     match current plugin version").

### Check 5: SySiDE Configuration

1. **`syside.toml`**: check at the correct location per layout
   ($PROJECT_ROOT for greenfield, `$PROJECT_ROOT/engineering/` for
   brownfield). If missing, report CRITICAL. If present but empty,
   report NON-CANONICAL.

2. **`.lsp.json`**: check at the correct location per layout. If
   missing, report CRITICAL.

### Check 6: GitHub Actions

All findings in this group are OPTIONAL severity.

1. `.github/workflows/traceability-check.yml`
2. `.github/workflows/iteration-boundary.yml`
3. `.github/workflows/document-export.yml`
4. `.github/pull_request_template.md` (or
   `.github/PULL_REQUEST_TEMPLATE.md`)

Report each missing file as OPTIONAL.

### Check 7: Gitignore

1. **Both layouts**: check that `.gitignore` contains a `build/` entry.
   If missing, report NON-CANONICAL.

2. **Brownfield only**: check that `.gitignore` contains
   `engineering/build/` and `engineering/.venv/` entries. If missing,
   report NON-CANONICAL.

## Step 2: Produce Report

Present the findings as a structured report:

```text
VSE PROJECT AUDIT REPORT
========================
Plugin version: [current plugin version from plugin.json]
Project layout: [greenfield | brownfield]
Detected tier:  [Flat | Minimal AMBSE | Canonical AMBSE]
Model layout:   [package-per-directory | flat (pre-0.14.0)]

CRITICAL ([N] items)
  - [description and path]
  ...

OUTDATED ([N] items)
  - [description, current state, expected state]
  ...

NON-CANONICAL ([N] items)
  - [description and recommendation]
  ...

OPTIONAL ([N] items)
  - [description of what could be added]
  ...

Summary: [N] critical, [N] outdated, [N] non-canonical, [N] optional
```

If the project passes all checks with no CRITICAL or OUTDATED findings,
report:

```text
VSE PROJECT AUDIT: PASS
========================
All structural checks passed. The project matches the current plugin
version's canonical structure.
```

## Step 3: Remediation Plan (On Request)

If the user asks for remediation (via `--remediate` argument or by
asking "how do I fix this?"), produce an actionable plan grouped by
approach. Each remediation step includes the exact commands or file
paths needed.

### 3a. Missing Files (CRITICAL)

For each missing template file, provide the exact copy command:

```bash
cp "${CLAUDE_PLUGIN_ROOT}/templates/[category]/[file]" "[target path]"
```

Note: placeholder substitution must be applied after copying. List the
placeholders that need replacement (`{{PROJECT_NAME}}`,
`{{PROJECT_SHORT_CODE}}`, `{{DATE}}`, `{{ACQUIRER}}`, `{{AUTHOR}}`).

### 3b. Outdated Hook

```bash
cp "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" \
   "$PROJECT_ROOT/.git/hooks/pre-commit"
chmod +x "$PROJECT_ROOT/.git/hooks/pre-commit"
```

### 3c. CLAUDE.md Refresh

If the marker block is outdated, recommend re-running the marker block
merge. Provide the manual approach:

1. Read the current template from
   `${CLAUDE_PLUGIN_ROOT}/templates/common/CLAUDE.md`
2. Apply placeholder substitution
3. Replace the content between (and including) the marker lines in the
   project's `CLAUDE.md`

### 3d. VSE Library Installation

For projects predating 0.13.0:

```bash
mkdir -p "$MODEL_ROOT/library"
cp "${CLAUDE_PLUGIN_ROOT}/templates/common/library/vse-library.sysml" \
   "$MODEL_ROOT/library/"
```

Note: existing model files may need `import VSE_Library::*` lines added
to use the metadata definitions.

### 3e. Model Layout Migration (Flat to Package-Per-Directory)

For projects using the pre-0.14.0 flat layout:

1. Create package subdirectories under `$MODEL_ROOT`
2. Move each `.sysml` file into its corresponding directory
3. Copy view template files from
   `${CLAUDE_PLUGIN_ROOT}/templates/common/models/[pkg]/[pkg]-view.sysml`
4. Copy `traceability-view.sysml` to `$MODEL_ROOT`
5. Apply placeholder substitution to the new view files

This is a significant restructuring. Recommend doing it on a dedicated
branch and verifying that all SysML imports still resolve correctly
after the move.

### 3f. Tier Upgrade

If the user wants to move from Minimal to Canonical (or from Flat to
either), list the additional package directories to create and the
files to copy from the plugin templates.

## Cross-References

- `@project-setup`: scaffolds the canonical structure this skill audits
- `@iteration-orchestrator`: may route here on detected structural issues
- `@traceability-guard`: checks model-level trace completeness (different
  from structural completeness)
- `${CLAUDE_PLUGIN_ROOT}/knowledge/canonical-project-structure.md`:
  authoritative definition of the canonical layout

## Reference: Canonical Project Structure

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/canonical-project-structure.md`
