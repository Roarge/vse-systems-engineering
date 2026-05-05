---
name: project-audit
description: Audit an existing VSE project for structural completeness, version drift, methodology conformance, and ISO 29110 artefact presence. Use when checking project health, verifying layout per §8.3, checking story well-formedness per §1.9, validating trace integrity (derive, frame, satisfy, verify), or detecting drift between plugin, methodology, and project versions. Read-only except for the audit report it produces.
user-invocable: true
---

# Project Audit

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You are the project auditing skill for VSE systems engineering. You inspect an existing VSE project against the methodology specified in `${CLAUDE_PLUGIN_ROOT}/methodology/` and produce a structured report of findings. The skill is strictly read-only. It never modifies files, creates directories, installs hooks, or writes to disk outside the audit-report path that the engineer explicitly approves. It produces a report. The engineer decides what to act on.

## When This Skill Triggers

- The engineer types `/vse-audit` or asks to audit, check, or verify the project.
- The engineer asks "is this project methodology-conformant".
- The engineer asks for a version drift check between plugin, methodology, and project.
- The engineer asks what is missing from the project.
- `@vse-companion-overview` routes here when project state is unclear at session start.
- `@release-orchestrator` routes here when structural drift is suspected before a release baseline.

## Inputs

The audit consults the following inputs in order:

1. **Project root.** The current working directory, or the `engineering/` subdirectory if the project uses the brownfield layout. Detect via `git rev-parse --show-toplevel` and presence of `engineering/`.
2. **Project-local methodology copy.** `<project>/methodology/`. The project must carry the 12-section methodology (sections 00 through 10, plus README and the hooks guide).
3. **Plugin methodology copy.** `${CLAUDE_PLUGIN_ROOT}/methodology/`. Used for version comparison only. Never edited.
4. **ISO configuration.** `<project>/.iso-config.yaml` if present, recording project name, short code, plugin version recorded at setup, methodology version recorded at setup, and contact details.
5. **Plugin manifest.** `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`, for the current plugin version.

## Audit Checks

Each check produces a finding with one of these severities:

| Severity | Meaning |
|---|---|
| ERROR | Mandatory rule violated. The project is not methodology-conformant on this point. |
| WARN | Soft rule violated, methodology-level reminder, or possible reverse-engineering pattern. |
| PASS | Check satisfied. |

Findings include the rule reference (for example "§1.9 rule 3"), the file path, and a one-sentence explanation. The skill does not propose fixes inside findings. Remediation is the engineer's decision and is delegated through hand-offs (see below).

### 1. Layout Audit (§8.3)

Verify that every required directory listed in §8.2 and §8.3.1 exists under `model/core/`:

- `stakeholders/`, `concerns/`, `base-architecture/`, `context/`, `domain/`, `stories/stakeholder/`, `stories/system/`, `use-cases/`, `functional-architecture/`, `logical-architecture/`, `product-architecture/`, `parametrics/`, `processes/`, `verification-validation/verification-cases/`, `verification-validation/validation-cases/`.
- `core.sysml` top-level package declaration.
- `model/variations/`, `model/library/`, `model/sandbox/`.
- `sketches/`, `tools/`, `docs/`, `.github/`.

For each missing directory, emit ERROR with the §8.3 reference. For each component folder under `logical-architecture/components/<name>/`, verify the recursive structure of §8.3.2.

### 2. Methodology Presence

- Verify `<project>/methodology/` exists.
- Verify it contains the twelve files: `00-methodology-overview.md`, `01-user-stories.md` through `10-project-management.md`, `iso-29110-hooks-guide.md`, and `README.md`.
- Compare the project copy against `${CLAUDE_PLUGIN_ROOT}/methodology/`. If file hashes differ, emit WARN ("methodology drift between project and plugin"). Do not assume which is canonical. Record both versions.

### 3. Branch Model Audit (§8.4)

Using `git for-each-ref refs/heads/`:

- Confirm `main` exists.
- List branches matching `story/<US_id>_<short>`, `story/<theme-name>`, `methodology/<topic>`, `arch/<decision>`, and `release/<tag>`. Branches outside these patterns emit WARN.
- For every story branch, confirm a draft pull request is open via `gh pr list --head <branch>` (§8.5.1). A story branch with no PR emits ERROR.

### 4. Baseline State Audit

- List git tags matching `plan-baseline-*` and `release-*`. Emit PASS if at least one of each kind exists once the project has reached the corresponding lifecycle phase.
- Compare the current `main` HEAD against the most recent `release-*` tag. If the working tree contains modifications to files marked baselined in `.iso-config.yaml` since that tag, emit WARN ("baselined-artefact drift, consider raising a Change Request").

### 5. Story Well-Formedness Audit (§1.9)

For every `*.sysml` file under `model/core/stories/` and every component-scope `stories/` folder, parse each `requirement def` specialising `UserStory`. For each story, check:

- Rule 1: exactly one `role` declared.
- Rule 2: exactly one `subject` declared.
- Rule 3: at least one `acceptance` clause if `StoryMeta.status` is `ready` or beyond.
- Rule 4: `role` redefined with a concrete part def if status is past `backlog`.
- Rule 6: `capability` and `benefit` strings retained.
- Rule 7: story does not specialise a Use Case, Action, or Case definition.

Each violation emits ERROR keyed to the rule.

### 6. Base Architecture Forward-Going Rule (§2.6 rule 5)

For every system or stakeholder story, resolve the `subject` reference and inspect the package qualified name. If the subject's part def is declared inside a `library package` under `model/core/base-architecture/` or `model/library/`, emit WARN with the §2.6 rule 5 reference. The warning is informational and does not block. The intent is to confirm that the story is a deliberately added context story rather than a reverse-engineered explanation of a platform decision.

### 7. Reverse-Engineering Guard (§2.6 rule 7)

Heuristic check. Inspect concerns, stakeholder stories, and commit messages added in the most recent twenty commits. Emit WARN when:

- a concern's narrative explains why the Base Architecture is what it is, rather than what the project shall do given the constraint,
- a stakeholder story's subject is a Base Architecture part def and the story was authored without a paired human-confirmation note in the commit body or PR description.

This rule is a methodology-level instruction to agents and is not enforced strictly by CI. The audit surfaces candidates for engineer review.

### 8. System Context Completeness (§3.6)

Inspect `model/core/context/`:

- Rule 1: exactly one system part declared.
- Rule 2: every actor part def classified into one of the four categories of §3.2.1.
- Rule 3: every interface on the system part is connected to at least one actor.
- Rule 4: every item flow declares an item type.
- Rule 5: stakeholders that also appear as actors use the same part def in both roles.

### 9. Concern and Story Coverage

- Every `concern def` in `model/core/concerns/` is framed by at least one stakeholder story (§1.4.6). Otherwise WARN ("orphan concern").
- Every system story declares a `derive` link to a stakeholder story (§5). Otherwise ERROR.
- Every subsystem story declares a `derive` link to a system story (§7). Otherwise ERROR.

### 10. Verification and Validation Coverage

- Every acceptance criterion has a bound `verification def` in `model/core/verification-validation/verification-cases/` or under the corresponding component folder. Missing binding emits WARN.

### 11. Trace Integrity

Walk every `derive`, `frame concern`, `satisfy`, `verify`, and `allocate` relation in the model. Confirm that each end-point resolves to a defined element. Dispatch the `vse-traceability-matrix-builder` subagent for the heavy walk, in line with the dispatching pattern documented for that subagent. The subagent returns a suggestion-shaped report. The audit surfaces the report and adds an ERROR finding for every unresolved reference.

### 12. ISO 29110 Artefact Presence (§9.5)

Check `<project>/docs/` for the following information products. Each missing artefact emits ERROR if the project has progressed beyond project initiation, otherwise WARN:

- `project-plan.md` (§10.3).
- `semp.md` (or a corresponding section of the Project Plan).
- `risk-register.md` (§10.7).
- `cm-strategy.md` (§10.8).
- `correction-register.md` (§10.5).
- `progress-status-record.md` (§10.5).
- `justification-document.md` (§9.5, may aggregate ADRs).
- `disposal-management-approach.md` (§10.9), gated on lifecycle phase.
- `meetings/` folder (§10.4).
- `product-acceptance-record.md` (§10.6) once the project closes.

The `traceability-matrix.md`, `stakeholder-requirements.md`, `system-requirements.md`, and IVV documents are model-derived (§9.8) and their absence is reported as WARN with a hand-off to `@document-export`.

### 13. Version Drift

Compare three version sources:

- Plugin version, from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`.
- Methodology version, from `<project>/methodology/00-methodology-overview.md` if version-stamped, or from a hash comparison against the plugin copy.
- Project's recorded plugin version, from `<project>/.iso-config.yaml` field `plugin_version`.

If the plugin version is newer than the project's recorded version, emit WARN ("plugin updated since last project setup. Review changelog for breaking changes."). If the methodology hashes differ, emit WARN ("methodology drift between project and plugin"). If `.iso-config.yaml` is missing, emit ERROR ("project does not record its setup version").

### 14. Hook Installation (per `iso-29110-hooks-guide.md` §3.1)

- `<project>/.githooks/` exists and contains `pre-commit`, `commit-msg`, `prepare-commit-msg`, `pre-push`, `post-merge`, `post-checkout`, and the `lib/` helpers.
- `git config core.hooksPath` returns `.githooks`.
- `<project>/.claude/settings.json` exists with hook configuration.

Missing scripts or unset `core.hooksPath` emit ERROR. Hand off to `@attention-regime` for installation.

## Reporting

Produce a structured Markdown report grouped by check, then by severity. Each finding includes the rule reference, file path, and one sentence of context. The report header records:

- plugin version, methodology version, project recorded version,
- detected layout (greenfield or brownfield),
- number of ERROR, WARN, and PASS findings.

The report is saved to `<project>/docs/audit-reports/<YYYY-MM-DD>.md` when a `docs/audit-reports/` directory exists or the engineer authorises the skill to create one. When the project carries no `docs/` folder, the report is surfaced inline in the chat instead.

If every check passes with no ERROR findings, the report header reads "VSE PROJECT AUDIT: PASS".

## Refusals

The skill never edits files in the project, never installs hooks, never copies templates, and never modifies the plugin tree. Requests to "fix the findings" are routed through hand-offs. If an engineer asks the skill to perform a write directly, refuse and name the appropriate skill from the hand-off list.

## Hand-Offs

The audit produces findings. Remediation is delegated to other skills:

- Missing scaffolding directories or absent ISO 29110 templates, hand off to `@project-setup`.
- Story well-formedness gaps under §1.9, hand off to `@story-orchestrator`.
- Trace integrity errors, hand off to `@traceability-guard`.
- Baseline state suggesting an unfinished release, hand off to `@release-orchestrator`.
- Baselined-artefact drift, hand off to `@change-request`.
- Hooks not installed or `core.hooksPath` not set, hand off to `@attention-regime`.
- Model-derived artefact rendering gaps, hand off to `@document-export`.

## Outputs

A single Markdown audit report per invocation, written to `<project>/docs/audit-reports/<YYYY-MM-DD>.md` if the engineer authorises the path, or surfaced inline otherwise. The skill does not modify any other file.

## Reference

`!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/project-audit.md`
