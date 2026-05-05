---
name: attention-regime
description: Configure ISO 29110 hook surface and install project-side git hooks. Use when setting up environmental hooks, installing pre-commit, configuring `.iso-config.yaml`, registering Claude Code hooks, wiring `core.hooksPath`, or activating reverse-engineering and baselined-artefact guards after project scaffolding.
user-invocable: true
---

# Attention Regime

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You are the meta-skill that configures the working environment for sustained attention to the AMBSE methodology and ISO/IEC TR 29110-5-6-2 obligations. This skill installs and registers two complementary hook surfaces. Lifecycle (Claude Code) hooks act as the *guidance* layer during agent authoring. Project-side (git) hooks act as the *enforcement* layer at commit, push, merge, checkout, and receive. Together they make compliance ambient rather than periodic.

This skill has read-write behaviour. It writes into the user project under `.githooks/`, `.claude/`, `.iso-config.yaml`, and `.gitignore`. It does not write outside the project root.

## When This Skill Triggers

- The user asks to "set up hooks", "install pre-commit", "configure ISO 29110 hooks", "install project hooks", or "wire core.hooksPath".
- The user asks for a hook health check or asks why a hook is firing.
- `@project-setup` routes here once scaffolding completes.
- A reverse-engineering guard or baselined-artefact block needs review.

## Lifecycle Hook Surface (Claude Code)

These hooks are registered in the plugin's `hooks.json` and fire inside the Claude Code harness. Their purpose is to inject ISO context, gate compliance-relevant tool calls, and prompt for follow-up work. The script contracts mirror §5 of `methodology/iso-29110-hooks-guide.md`.

- **SessionStart** (`session-start.sh`): inject ISO 29110 status at session start per §5.1. Reports current branch, Project Plan baseline tag, in-flight stories, pending Change Requests, and stale risks. Reminders cover PM.O3 baselined-artefact protection, §1.9 story well-formedness, SR.O7 verification follow-through, and the §2.6 rule 7 reverse-engineering posture.
- **UserPromptSubmit** (`user-prompt-submit.sh`): scan the submitted prompt per §5.2. Three heuristics fire. First, edits to plausibly baselined artefacts trigger a PM.O3 Change Request reminder. Second, mentions of a synchronous review trigger a PM.O4 Meeting Record reminder. Third, prompts that imply synthesising stakeholders, concerns, or stories from pre-existing context trigger the §2.1 corollary 2 and §2.6 rule 7 reverse-engineering guard, asking the agent to confirm intent before authoring context artefacts.
- **PreToolUse** (`pre-tool-use.sh`): matched on `Edit|Write|NotebookEdit` per §5.3. Block edits to baselined artefacts when no Change Request issue is open, returning a structured `decision: block` payload with the PM.O3 rationale. For story files, inject the §1.9 required-fields reminder without blocking.
- **PostToolUse** (`post-tool-use.sh`): matched on `Edit|Write|NotebookEdit` per §5.4. After a story edit, prompt for verification-case alignment and StoryMeta status. After a concern edit, prompt for framing-story coverage. After a logical-architecture edit, prompt for allocation refresh and ADR capture. After a Project Plan edit, prompt for PM.O1 Acquirer review and a `plan-baseline` tag.
- **Stop** (`stop.sh`): at the end of an agent response per §5.5. Inspect changes pending in `git status` and prompt for ADR capture if architectural files moved, or for V&V Report alignment if verification artefacts moved.
- **SubagentStop** (`subagent-stop.sh`): aggregate compliance findings from parallel subagent runs per §5.6. Surface any blocking findings to the orchestrating session.
- **PreCompact** (`pre-compact.sh`): snapshot the ISO status output to a workspace file before context compaction per §5.7, so the post-compact context can re-read the state.
- **Notification** (`notification.sh`): emit periodic, non-blocking reminders on stale risks and overdue Change Requests per §5.8.

## Project-Side Hook Surface (git)

These hooks are copied from the plugin into the user project under `.githooks/` and activated through `core.hooksPath`. The script contracts mirror §4 of `methodology/iso-29110-hooks-guide.md`.

- **pre-commit**: SysML lint on changed `.sysml` files, story well-formedness per §1.9, baselined-artefact protection requiring an open Change Request reference, and traceability integrity (no dangling `derive`, `frame concern`, or `verify`) per §4.1.
- **commit-msg**: enforce the conventional-commit pattern with story scope (`feat(US_042): ...`), Change Request reference (`plan: ... (CR #17)`), or Meeting Record (`meeting: YYYY-MM-DD topic`) per §4.2.
- **prepare-commit-msg**: prepopulate the commit subject with the Story ID inferred from the branch name (for example, `story/US_042_*` yields `feat(US_042): `), per §4.3.
- **pre-push**: gate pushes to `main` and `release/*`. Reject pushes that would land `inProgress` stories, that lack V&V coverage on `done` stories, that drift from the committed Traceability Matrix, or that tag a release without baseline integrity, per §4.4.
- **post-merge**: when `main` advances, regenerate the Traceability Matrix, the Stakeholder, System, and Subsystem Requirements Specifications, the IVV Plan, and the Justification Document, per §4.5. Report drift. Do not auto-commit.
- **post-checkout**: on branch checkout, print the shared ISO status output (the same `iso-status.sh` library used by SessionStart) per §4.6.
- **post-receive** (server-side): mirror to the configured backup remote per §4.7. Deployed on the canonical remote host, not in the local `.githooks/`.

<!-- TODO PHASE 4 -->
The actual hook scripts referenced above (session-start.sh, user-prompt-submit.sh, pre-tool-use.sh, post-tool-use.sh, stop.sh, subagent-stop.sh, pre-compact.sh, notification.sh, pre-commit, commit-msg, prepare-commit-msg, pre-push, post-merge, post-checkout, post-receive) are written in Phase 4 of the v2.0 plugin restructuring. Until then, the skill describes the surface and the install procedure but the scripts may be placeholders.
<!-- /TODO PHASE 4 -->

## Workflow: Install Hooks Into a User Project

Run from the project root, after `@project-setup` has scaffolded the repository.

1. **Confirm the lifecycle hooks are registered.** Check that the plugin's `hooks.json` lists SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop, SubagentStop, PreCompact, and Notification entries. The harness loads these automatically when the plugin is installed. No per-project action is required for the lifecycle layer to fire, except the optional project-local override below.
2. **Install the project-side hooks.** Copy every script from `${CLAUDE_PLUGIN_ROOT}/hooks/githooks/` into `<project>/.githooks/`, preserving the `lib/` subdirectory of shared helpers. Set scripts executable with `chmod +x .githooks/*`. Activate with:

   ```bash
   git config core.hooksPath .githooks
   ```

   The `core.hooksPath` value shall be a path inside the project root.
3. **Install `.iso-config.yaml`.** Copy `${CLAUDE_PLUGIN_ROOT}/templates/iso-config/.iso-config.yaml` to the project root. The engineer fills in baselined paths, protected branches, storymeta fields, the Risk Register location, the Change Request issue label, and the renderer paths. The schema is reproduced below.
4. **Install project-local Claude Code overrides if needed.** If the project requires hook behaviour beyond the plugin defaults, copy `${CLAUDE_PLUGIN_ROOT}/templates/.claude/settings.json` to `<project>/.claude/settings.json`. Project-local settings take precedence over user-level settings per §5 of the hooks guide.
5. **Update `.gitignore`.** Append `.iso-config.local.yaml` so engineers may keep machine-local overrides without committing them.
6. **Verify.** Run a no-op commit on a non-baselined file and confirm `pre-commit` and `commit-msg` fire. Open a Claude Code session in the project root and confirm the SessionStart output appears.

## Configuration via `.iso-config.yaml`

The hooks read this file to determine what to enforce. Schema reproduced from §8 of `methodology/iso-29110-hooks-guide.md`:

```yaml
# .iso-config.yaml: ISO 29110 hook configuration

baselined_paths:
  - docs/project-plan.md
  - docs/cm-strategy.md
  - methodology/
  - model/library/

protected_branches:
  - main
  - release/*

storymeta:
  required_fields: [points, priority, status]
  valid_statuses: [backlog, ready, inProgress, done]

risk_register:
  stale_threshold_days: 30
  path: docs/risk-register.md

change_request:
  issue_label: change-request
  required_for_paths: ${baselined_paths}

renderers:
  traceability_matrix: tools/render/traceability-matrix.py
  stakeholder_reqs:    tools/render/stakeholder-reqs-doc.py
  system_reqs:         tools/render/system-reqs-doc.py
  ivv_plan:            tools/render/ivv-plan.py
  justification:       tools/render/justification-doc.py
```

Push project-specific behaviour into this file rather than into the hook scripts. The scripts are stable across projects, the configuration varies.

The schema reproduction above omits the `iteration:` block carried by §8 of the hooks guide (`cadence_days`, `current`). The new story-driven methodology has no fixed-length iteration concept. Project state lives in git per §8.7. The hooks guide itself will be updated in a later phase to reflect this.

## Refusals

Refuse the following operations and explain why:

- **Refuse to install hooks over a customised `.githooks/`.** If the target directory already exists with non-empty content that does not match the plugin's distribution, ask the engineer for confirmation before overwriting. Suggest moving local overrides to `.githooks-local/` (gitignored) and sourcing them from the standard scripts, per §10 of the hooks guide.
- **Refuse to set `core.hooksPath` outside the project root.** A hooksPath outside the working tree creates a shared-state vulnerability and breaks reproducibility for collaborators.
- **Refuse to advise `--no-verify` as a workaround.** Local hooks are an advisory floor for fast feedback. CI is the unbypassable ceiling per §11 of the hooks guide. If a hook is producing false positives, tighten the matcher in `.iso-config.yaml` rather than disabling the hook.

## Hand-offs

- **To `@project-setup`** if hooks cannot be installed because the project is not scaffolded. Lifecycle hooks rely on the directory layout from §8.2 of the methodology, and project-side hooks rely on the renderer scripts referenced from `.iso-config.yaml`.
- **To `@change-request`** when a PreToolUse block fires on a baselined artefact, so the engineer can open a CR issue and reference it in subsequent commits.
- **To `@release-orchestrator`** when post-merge regeneration drift, or a pre-push baseline-integrity finding, suggests a release boundary needs a new `plan-baseline-*` or `release-*` tag.

## Outputs

After a successful run, the following exist in the user project:

- `<project>/.githooks/` populated with the project-side hooks (pre-commit, commit-msg, prepare-commit-msg, pre-push, post-merge, post-checkout) and the shared `lib/` helpers, all executable.
- `<project>/.iso-config.yaml` populated with project-specific values.
- `<project>/.claude/settings.json` if project-local Claude Code overrides were requested.
- `<project>/.gitignore` updated to ignore `.iso-config.local.yaml`.
- `core.hooksPath` set to `.githooks` in the local git config.

`post-receive` is **not** installed locally. Document it in the project README as a server-side responsibility.

## Reference Bundle

`!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/attention-regime.md`
