---
name: attention-regime
description: Configure the ISO 29110 hook surface and install the project-side git hooks at the project rigour profile.
when_to_use: Use when setting up environmental hooks, installing pre-commit, configuring `.iso-config.yaml`, choosing or changing a rigour profile, overriding a single gate disposition, wiring `core.hooksPath`, or reviewing why a hook fired.
user-invocable: true
---

# Attention Regime

If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first.

You are the meta-skill that configures the working environment for sustained attention to the AMBSE methodology and ISO/IEC TR 29110-5-6-2 obligations. This skill installs and registers two complementary hook surfaces. Lifecycle (Claude Code) hooks inject context and surface reminders during agent authoring. Project-side (git) hooks run the automated gates at commit, merge, and checkout.

Both surfaces implement methodology §0.10.1: the tooling raises the floor, the team raises the ceiling. A gate reports what it found and names the section the finding comes from. Whether it also stops the operation is a project choice recorded in `.iso-config.yaml`, not a plugin default.

This skill has read-write behaviour. It writes into the user project under `.githooks/`, `.iso-config.yaml`, and `.gitignore`. It does not write outside the project root.

## When This Skill Triggers

- The user asks to "set up hooks", "install pre-commit", "configure ISO 29110 hooks", "install project hooks", or "wire core.hooksPath".
- The user asks to change the rigour profile, tighten one gate, or loosen one gate.
- The user asks for a hook health check or asks why a hook is firing.
- `@project-setup` routes here once scaffolding completes.

## Lifecycle Hook Surface (Claude Code)

These hooks are registered in the plugin's `hooks.json` and fire inside the Claude Code harness. They are advisory at every profile. They inject context and surface reminders, and none of them denies a tool call. The script contracts mirror §5 of the hooks guide.

- **SessionStart** (`session-start.sh`): emit project context per §5.1. Reports the methodology copy, the rigour profile, the current branch, in-flight story branches, the Plan baseline tag, the last release tag, and open Change Requests, then names the lens skill and the §2.6 rule 7 posture.
- **UserPromptSubmit** (`user-prompt-submit.sh`): scan the submitted prompt per §5.2. Three heuristics fire. Edits to plausibly baselined artefacts trigger a PM.O3 Change Request reminder. Mentions of a synchronous review trigger a PM.O4 Meeting Record reminder. Prompts that imply synthesising stakeholders, concerns, or stories from pre-existing context trigger the §2.1 corollary 2 and §2.6 rule 7 guard.
- **PreToolUse** (`pre-tool-use.sh`): matched on `Edit|Write|NotebookEdit` per §5.3. **Advisory, not blocking.** When the target is on `baselined_paths` the hook prints one note naming the §10.4.2 obligation, and the tool call proceeds. The firm gate is the project-side `commit-msg` hook, at whatever disposition the profile sets. The open-Change-Request heuristic is too coarse to carry a hard block without false positives. For story files the hook injects the §1.9 required-fields reminder, also without blocking.
- **PostToolUse** (`post-tool-use.sh`): matched on `Edit|Write|NotebookEdit` per §5.4. After a story edit, prompt for verification-case alignment and StoryMeta status. After a concern edit, prompt for framing-story coverage. After a logical-architecture edit, prompt for allocation refresh and ADR capture. After a Project Plan edit, prompt for PM.O1 Acquirer review and a `plan-baseline` tag.
- **Stop** (`stop.sh`): at the end of an agent response per §5.5. Inspect changes pending in `git status` and prompt for ADR capture if architectural files moved, or for V&V Report alignment if verification artefacts moved.
- **SubagentStop** (`subagent-stop.sh`): aggregate compliance findings from parallel subagent runs per §5.6.
- **PreCompact** (`pre-compact.sh`): snapshot the ISO status output to a workspace file before context compaction per §5.7.
- **Notification** (`notification.sh`): emit periodic, non-blocking reminders on stale risks and overdue Change Requests per §5.8.

No per-project action is required for this layer. The harness loads it from the plugin's `hooks.json` when the plugin is installed.

## Project-Side Hook Surface (git)

These scripts are copied from the plugin into the user project under `.githooks/` and activated through `core.hooksPath`. The contracts mirror §4 of the hooks guide.

- **pre-commit**: SysML lint on staged `.sysml` files (`precommit_lint`), story well-formedness per §1.9 (`precommit_story_wellformed`), and delegation to the traceability gate. Also prints a baselined-artefact note when the commit touches a path on `baselined_paths`.
- **pre-commit-traceability.sh**: the traceability gate (`precommit_traceability`), invoked by `pre-commit` rather than by git. Checks the requirements and verification cases the commit **touches**, not every requirement in every touched file, and points at `/vse-trace` for the full-repo report.
- **commit-msg**: the conventional-commit pattern (`commit_msg_pattern`) and the Change Request reference for baselined paths (`commit_msg_cr_reference`), per §4.2.
- **prepare-commit-msg**: prepopulate the commit subject with the Story ID inferred from the branch name (`story/US_042_*` yields `feat(US_042): `), per §4.3. Informational at every profile.
- **post-merge**: when `main` advances, regenerate the model-derived artefacts per §4.5 and report drift. Never auto-commits. Informational at every profile.
- **post-checkout**: on branch checkout, print methodology and branch status per §4.6. Informational at every profile.
- **lib/iso-profile.sh**: shared library, sourced by the gates above. Resolves the profile and the per-gate dispositions from `.iso-config.yaml`. Git never invokes it directly.

Two hooks are deliberately absent. **No local `pre-push` hook ships.** Its four obligations (story state on `main`, V&V coverage on `done` stories, traceability matrix freshness, baseline integrity on release tags) need a gate a workstation cannot reach, so §4.4 of the hooks guide documents them as continuous-integration contracts. **`post-receive`** is server-side per §4.7 and is documented in the project README rather than installed under `.githooks/`.

## Workflow: Profile-Aware Install

Run from the project root, after `@project-setup` has scaffolded the repository.

**1. Read the profile.** Take `project_profile` from `.iso-config.yaml` at the engineering root (the project root, or `engineering/` in a brownfield layout). An absent key means `standard`, per methodology §0.10.2. If the file does not exist yet, install it from `${CLAUDE_PLUGIN_ROOT}/templates/iso-config/.iso-config.yaml` first and ask which profile the project wants, using the §0.10.2 two-question heuristic: more than one person, and an external acquirer, audit, or safety obligation. Two answers of no suggest `light`, either answer of yes suggests `standard`, and a project needing sign-off on the process itself selects `full`.

**2. Install the tier set.** The per-tier install matrix is §3.4 of the hooks guide. Copy from `${CLAUDE_PLUGIN_ROOT}/hooks/` into `<project>/.githooks/`, dropping the `.sh` suffix on the git entry points because git invokes hooks by exact filename. The delegate keeps its suffix because git never calls it. The canonical copy list is the installation example in `${CLAUDE_PLUGIN_ROOT}/hooks/README.md`.

| Source in the plugin | Destination in the project | light | standard | full |
|---|---|---|---|---|
| `hooks/lib/iso-profile.sh` | `.githooks/lib/iso-profile.sh` | yes | yes | yes |
| `hooks/prepare-commit-msg.sh` | `.githooks/prepare-commit-msg` | yes | yes | yes |
| `hooks/post-checkout.sh` | `.githooks/post-checkout` | yes | yes | yes |
| `hooks/pre-commit.sh` | `.githooks/pre-commit` | no | yes | yes |
| `hooks/pre-commit-traceability.sh` | `.githooks/pre-commit-traceability.sh` | no | yes | yes |
| `hooks/commit-msg.sh` | `.githooks/commit-msg` | no | yes | yes |
| `hooks/post-merge.sh` | `.githooks/post-merge` | no | no | yes |
| `templates/github/traceability-check.yml` | `.github/workflows/traceability-check.yml` | no | yes, advisory | yes, blocking |
| `templates/github/document-export.yml` | `.github/workflows/document-export.yml` | no | no | yes (renders documents on release, never blocks) |
| Branch protection on `main` | repository settings | not configured | recommended | required |

`lib/` installs at every profile even where no installed hook reads it yet, so raising the profile later adds hook files only, with no second install step and no partial state.

Set the scripts executable and activate:

```bash
chmod +x .githooks/* .githooks/lib/*
git config core.hooksPath .githooks
```

The `core.hooksPath` value shall be a path inside the project root.

**3. Confirm the dispositions.** Nothing further is needed for the gates to behave correctly: each one reads its own disposition from the profile at run time, per methodology §0.10.4. Report the resulting table back to the engineer so the behaviour is not a surprise on the first commit.

| Gate | Configuration key | light | standard | full |
|---|---|---|---|---|
| Conventional-commit pattern | `commit_msg_pattern` | off | warn | block |
| Change Request reference | `commit_msg_cr_reference` | off | warn | block |
| SysML lint | `precommit_lint` | warn | warn | block |
| Story well-formedness | `precommit_story_wellformed` | off | warn | block |
| Traceability on touched requirements | `precommit_traceability` | info | warn | block |

`block` reports and stops the operation, `warn` reports and lets it through, `info` prints one summary line, `off` skips the gate.

**4. Offer the per-gate overrides.** When one gate is wrong for this project, the fix is `gate_overrides` in `.iso-config.yaml`, never an edit to a shipped script. The override wins over the profile column, and an unset key follows it:

```yaml
project_profile: light
gate_overrides:
  precommit_traceability: block
```

Record the override on the tailoring line in the Project Plan, per §0.10.2. Editing a script instead means the next plugin upgrade silently overwrites the project's intent.

**5. Offer the phased-rollout path.** A project adopting the methodology on an existing repository does not have to start at its eventual profile. Start at `light`, raise to `standard` once the model parses cleanly and the commit conventions are habitual, and raise to `full` when an acquirer or an assessment makes the complete artefact set worth its cost. Each step is a one-line change to `project_profile` followed by a re-run of this install. This is §3.4 of the hooks guide operationalising the §12 phased-rollout advice.

**6. Update `.gitignore`.** Append `.iso-config.local.yaml` so engineers may keep machine-local overrides without committing them.

**7. Verify.** Make a no-op commit on a non-baselined file and confirm the installed hooks fire at the expected disposition. Open a Claude Code session in the project root and confirm the SessionStart output appears with the right `Profile:` line.

## Workflow: Change the Profile

1. Confirm which direction the project is moving and why.
2. Edit `project_profile` in `.iso-config.yaml`.
3. Re-run the install workflow above. Raising a profile adds hook files. Lowering one leaves the extra files in place but relaxes their dispositions, which is harmless. Offer to remove them.
4. Record the change and its date on the tailoring line, keeping the previous entry so the history stays readable, per §0.10.2.
5. Raising to `full` also brings the `full` column of the §0.10.3 obligation table, which is the real cost of the change. Say so before the engineer commits to it.

A profile change needs no Change Request unless the project has put `.iso-config.yaml` on its own `baselined_paths` list.

## Configuration via `.iso-config.yaml`

The hooks read this file to determine what to enforce. Schema per §8 of the hooks guide:

```yaml
# Project rigour profile per methodology section 0.10.
# One of: light | standard | full. Absent means standard.
project_profile: standard

# Optional per-gate overrides: block | warn | info | off.
# Unset keys follow the profile default (section 0.10.4).
# gate_overrides:
#   precommit_traceability: block

baselined_paths:
  - docs/project-plan.md

protected_branches:
  - main
  - release/*

storymeta:
  required_fields: [status, priority]
  valid_statuses: [backlog, ready, inProgress, done]

risk_register:
  stale_threshold_days: 30
  path: docs/risk-register.md

change_request:
  issue_label: change-request
  required_for_paths: ${baselined_paths}
```

The `baselined_paths` list shown is the `standard` default. `light` ships an empty list, so the Change Request machinery stays dormant, and `full` adds the CM Strategy, Risk Register, Disposal Approach, and `model/library/`. `methodology/` is deliberately absent at every profile: Change Request protection on the project-local methodology copy contradicts the override convention that makes the copy useful.

The schema stays flat and at most two levels deep so the shipped hooks can parse it with awk rather than taking a YAML dependency. Push project-specific behaviour into this file rather than into the scripts.

The `renderers:` block ships commented out. Uncomment it when the project authors those scripts under `tools/render/`, because a configured path to a script that does not exist makes `post-merge` report a failure the project cannot act on.

## Judgment Calls

The pattern for every item below: name the rule and the section it comes from, state the concrete risk, recommend the conforming path, and then proceed on the engineer's informed confirmation. Require explicit confirmation before acting when the action is destructive or irreversible.

- **Overwriting a customised `.githooks/`.** If the target directory already exists with content that does not match the plugin's distribution, stop and show what would be replaced. Overwriting local hook logic is destructive and git does not track what was never committed. Recommend moving local overrides to `.githooks-local/` (gitignored) and sourcing them from the standard scripts, per §10 of the hooks guide. Proceed only on explicit confirmation.
- **Setting `core.hooksPath` outside the project root.** A hooksPath outside the working tree is shared mutable state: it breaks reproducibility for collaborators, and an unrelated clone can change what this project enforces. Say so, recommend a path inside the root, and proceed on explicit confirmation if the engineer has a reason.
- **Being asked how to get past a gate.** Answer honestly. Git provides a bypass mechanism, it is documented in the git manual, and no local hook can prevent its use. Name the mechanism, name the recording obligation from methodology §0.10.6 (the Correction Register at `full`, one line in the commit body otherwise), and recommend the conforming path first: fix the finding, or set the gate to `warn` through `gate_overrides` if it is wrong for this project. Refusing to discuss a mechanism the engineer can find in one search buys no compliance and costs trust in everything else the skill says.

## Hand-offs

- **To `@project-setup`** if hooks cannot be installed because the project is not scaffolded. The hooks rely on the §8.3 directory layout and on `.iso-config.yaml`.
- **To `@change-request`** when a baselined-artefact finding fires, so the engineer can open a CR issue and reference it in subsequent commits.
- **To `@release-orchestrator`** when post-merge regeneration drift suggests a release boundary needs a new `plan-baseline-*` or `release-*` tag.
- **To `@traceability-guard`** or `/vse-trace` when the traceability gate reports a gap, because the gate only sees the requirements this commit touched.

## Outputs

After a successful run, the following exist in the user project:

- `<project>/.githooks/` populated with the profile's hook set from the §3.4 matrix, plus `lib/iso-profile.sh` at every profile, all executable.
- `<project>/.iso-config.yaml` carrying `project_profile`, any `gate_overrides`, and the project-specific values.
- `<project>/.gitignore` updated to ignore `.iso-config.local.yaml`.
- `core.hooksPath` set to `.githooks` in the local git config.
- At `standard` and `full`, `.github/workflows/traceability-check.yml` from `${CLAUDE_PLUGIN_ROOT}/templates/github/traceability-check.yml`.

Lifecycle hooks need no per-project files. They load from the plugin's `hooks.json`. A project that needs behaviour beyond the plugin defaults authors `<project>/.claude/settings.json` directly against the Claude Code settings schema. The plugin ships no settings template, so there is nothing to copy.

`post-receive` is **not** installed locally. Document it in the project README as a server-side responsibility.

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| Base Architecture: Forward-Going Stories and the Reverse-Engineering Guard | pages/methodology/base-architecture-corollaries.md | Decisions that pre-exist the project, forward-going stories, and the reverse-engineering guard |
| PHAS-EAI Digital Engineering Integration Requirements R1-R4 | pages/phas-eai/phas-eai-de-requirements.md | The four PHAS-EAI digital engineering integration requirements R1 to R4 |
| PHAS-EAI Equations: Response Time, Resilience, Functional Information | pages/phas-eai/phas-eai-equations.md | The three PHAS-EAI equation families for response time, resilience, and functional information |
| PHAS-EAI Lever Tables and Cross-Case Hypothesis Evidence | pages/phas-eai/phas-eai-levers-and-evidence.md | The four PHAS-EAI lever tables and the hypotheses with the strongest cross-case support |
| PHAS-EAI Framework: Core Constructs | pages/phas-eai/phas-eai-overview.md | The five PHAS-EAI constructs, from configuration space and cognitive reserve to niche construction |
<!-- wiki-routing:end -->
