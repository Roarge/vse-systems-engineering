---
name: attention-regime
description: Configure the ISO/IEC 29110 hook surface and install the git hooks, the story lint and the CI workflow at the project rigour profile, with the Gherkin-first and test-first gates that block at every profile.
when_to_use: Use when setting up environmental hooks, installing pre-commit, the story lint or the CI workflow, reinstalling the hooks after a plugin upgrade such as 5.0.0, configuring `.iso-config.yaml`, choosing or changing a rigour profile, overriding a single gate disposition, wiring `core.hooksPath`, or reviewing why a hook fired or a Gherkin-first or test-first gate denied an edit.
user-invocable: true
---

# Attention Regime

If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first.

You are the meta-skill that configures the working environment for sustained attention to the AMBSE methodology and ISO/IEC TR 29110-5-6-2 obligations. This skill installs and registers two complementary hook surfaces. Lifecycle (Claude Code) hooks inject context and surface reminders during agent authoring. Project-side (git) hooks run the automated gates at commit, merge, and checkout.

Both surfaces implement methodology §0.10.1: the tooling raises the floor, the team raises the ceiling. A gate reports what it found and names the section the finding comes from. For the profile-scaled gates, whether it also stops the operation is a project choice recorded in `.iso-config.yaml`, not a plugin default. The four gates of methodology §11.9 are the exception. Gherkin first and test first, at commit time and in session, block at every profile until a recorded override lowers one (§0.10.1, §0.10.4). Gherkin is the plain-text Given/When/Then format of a story's feature file, and test first means a failing test is written before the code it covers.

This skill has read-write behaviour. It writes into the user project under `.githooks/`, `tools/lint/` at the engineering root, `.github/workflows/`, `.iso-config.yaml`, and `.gitignore`. When the engineer accepts the refresh of `tools/render/` offered on a reinstall, it also writes `tools/render/` and `docs/generated/` at the engineering root. It does not write outside the project root, and it never edits the `test_first` record, which `@test-first` owns.

## When This Skill Triggers

- The user asks to "set up hooks", "install pre-commit", "configure ISO/IEC 29110 hooks", "install project hooks", or "wire core.hooksPath".
- The user asks to change the rigour profile, tighten one gate, or loosen one gate.
- The user asks for a hook health check or asks why a hook is firing.
- `@project-setup` routes here once scaffolding completes.
- The plugin was updated, or `@project-audit` reports drift between the installed hooks and the plugin copies, a `light` project without `pre-commit`, or a missing story lint or CI workflow.
- The pre-commit hook says the story lint is missing, or CI says `.githooks/pre-commit` or `.githooks/lib/test-first.sh` is not installed.

## Lifecycle Hook Surface (Claude Code)

These hooks are registered in the plugin's `hooks.json` and fire inside the Claude Code harness. `PreToolUse` carries the two in-session gates of methodology §11.9 and may deny an agent's edit. Every other lifecycle hook is advisory at every profile: it injects context or surfaces a reminder, and it never denies a tool call. The script contracts mirror §5 of the hooks guide, and `${CLAUDE_PLUGIN_ROOT}/hooks/README.md` states the output contract.

- **SessionStart** (`session-start.sh`): emit project context per §5.1. Reports the methodology copy, the rigour profile, the current branch, in-flight story branches, the Plan baseline tag, the last release tag, and open Change Requests, then names the lens skill and the §2.6 rule 7 posture. It ends with a Behaviour-first line and a Test-first line naming the recorded `test_first.applies` value, a nudge when test tooling is found while that value is false or unrecorded, and a warning when `jq` is missing.
- **UserPromptSubmit** (`user-prompt-submit.sh`): scan the submitted prompt per §5.2. Three heuristics fire. Edits to plausibly baselined artefacts trigger a PM.O3 Change Request reminder. Mentions of a synchronous review trigger a PM.O4 Meeting Record reminder. Prompts that imply synthesising stakeholders, concerns, or stories from pre-existing context trigger the §2.1 corollary 2 and §2.6 rule 7 guard.
- **PreToolUse** (`pre-tool-use.sh`): matched on `Edit|Write|MultiEdit|NotebookEdit` per §5.3. It carries the two in-session gates, which deny the edit at `block`, their default at every profile:
  - **Gherkin first** (`pretooluse_gherkin_first`) denies an edit that adds a story, or changes a story's text, while `<dir>/<ID>.feature` is missing or lacks the `@<ID>` tag.
  - **Test first** (`pretooluse_test_first`), where `test_first.applies` is `true`, denies an edit to a code path while no test path has changed in the working tree or on the branch.

  An edit that changes `gate_overrides` or `test_first` in `.iso-config.yaml` asks the human to confirm it (§11.10). The rest stays advisory. When the target is on `baselined_paths` the hook passes on one note naming the §10.4.2 obligation, and the tool call proceeds. The firm Change Request gate is the project-side `commit-msg` hook, at whatever disposition the profile sets, because the open-Change-Request heuristic is too coarse to carry a hard block without false positives. For story files the hook passes on the §1.9 required-fields reminder. The hook cannot see a file written through the Bash tool (§11.11), which is why `pre-commit` and CI carry the same checks.
- **PostToolUse** (`post-tool-use.sh`): matched on `Edit|Write|MultiEdit|NotebookEdit` per §5.4. After a feature-file edit, prompt to mirror each `@AC_` tag as a named criterion. After a story edit, prompt for a case stub that reaches each criterion and for a StoryMeta status within the §11.4 ordering. After a code edit where test first applies, prompt to run `test_command`. After a concern edit, prompt for framing-story coverage. After a logical-architecture edit, prompt for allocation refresh and ADR capture. After a Project Plan edit, prompt for PM.O1 Acquirer review and a `plan-baseline` tag.
- **Stop** (`stop.sh`): at the end of an agent response per §5.5. Inspect changes pending in `git status` and remind the human to capture an ADR if architectural files moved, or to align the V&V Report if verification artefacts moved. Where test first applies, tell the agent when code changed without a test. Each goes out once per session and working-tree state, and the hook stays silent while a Stop hook has already continued the turn.
- **SubagentStop** (`subagent-stop.sh`): run the Stop checks for a subagent per §5.6, a completion note and the test-first finding, with a marker of its own so a subagent never uses up what the main agent is told.
- **PreCompact** (`pre-compact.sh`): snapshot the ISO status output to a workspace file before context compaction per §5.7.
- **Notification** (`notification.sh`): emit periodic, non-blocking reminders on stale risks and overdue Change Requests per §5.8.

No per-project action is required for this layer. The harness loads it from the plugin's `hooks.json` when the plugin is installed, so its two gates act from the first edit after a plugin update, without a reinstall.

## Project-Side Hook Surface (git)

These scripts are copied from the plugin into the user project under `.githooks/` and activated through `core.hooksPath`. The contracts mirror §4 of the hooks guide.

- **pre-commit**: SysML lint on staged `.sysml` files (`precommit_lint`), story well-formedness per §1.9 (`precommit_story_wellformed`) and Gherkin conformance per §11.9.1 (`precommit_gherkin`), both through the story lint under `tools/lint/`, test before code per §11.9 (`precommit_test_first`) through `lib/test-first.sh`, and delegation to the traceability gate. In CI it runs in range mode over the changes a pull request or a push brings (`VSE_PRECOMMIT_RANGE`, hooks guide §4.1), so a fresh checkout with nothing staged cannot pass vacuously. Also prints a baselined-artefact note when the commit touches a path on `baselined_paths`.
- **pre-commit-traceability.sh**: the traceability gate (`precommit_traceability`), invoked by `pre-commit` rather than by git. Checks the requirements and verification cases the commit **touches**, not every requirement in every touched file, and points at `/vse-trace` for the full-repo report.
- **commit-msg**: the conventional-commit pattern (`commit_msg_pattern`) and the Change Request reference for baselined paths (`commit_msg_cr_reference`), per §4.2.
- **prepare-commit-msg**: prepopulate the commit subject with the Story ID inferred from the branch name (`story/US_042_*` yields `feat(US_042): `), per §4.3. Informational at every profile.
- **post-merge**: when `main` advances, regenerate the model-derived artefacts per §4.5 and report drift. Never auto-commits. Informational at every profile.
- **post-checkout**: on branch checkout, print methodology and branch status per §4.6. Informational at every profile.
- **lib/iso-profile.sh**: shared library, sourced by the gates above. Resolves the profile and the per-gate dispositions from `.iso-config.yaml`, and reads nested records such as `test_first`. Git never invokes it directly.
- **lib/sysml-toolchain.sh**: shared library sourced by pre-commit and session-start. Resolves the recorded SysML toolchain, probes availability, validates, and falls back along syside, omg-pilot, opensysml with a notice.
- **lib/test-first.sh**: shared library sourced by pre-commit, post-checkout and the CI workflow, after `lib/iso-profile.sh`. Locates the project, classifies paths against `test_first.code_paths` and `test_paths`, finds test evidence and detects test tooling (§11.5, §11.9).

Two more surfaces install at every profile beside `.githooks/`:

- **`tools/lint/`** at the engineering root (the directory that holds `.iso-config.yaml`): `story-wellformed.py`, the story lint of §11.9.1 that `pre-commit` and CI run, and `gherkin.py`, the parser it reads feature files with. The lint reads the model through `tools/render/sysml_model.py`, so `tools/render/` sits beside it.
- **`.github/workflows/traceability-check.yml`**: the CI workflow (hooks guide §4.4). It validates the model, runs `pre-commit` in range mode, runs `test_first.test_command` and `scenario_command` where test first applies, and checks that the committed derived artefacts are current (Contract 3). It is the backstop no workstation can bypass (§0.10.6).

Two hooks are deliberately absent. **No local `pre-push` hook ships.** Its four obligations (story state on `main`, V&V coverage on `done` stories, traceability matrix freshness, baseline integrity on release tags) need a gate a workstation cannot reach, so §4.4 of the hooks guide documents them as continuous-integration contracts. **`post-receive`** is server-side per §4.7 and is documented in the project README rather than installed under `.githooks/`.

## Workflow: Profile-Aware Install

Run from the project root, after `@project-setup` has scaffolded the repository.

**1. Read the profile.** Take `project_profile` from `.iso-config.yaml` at the engineering root (the project root, or `engineering/` in a brownfield layout). An absent key means `standard`, per methodology §0.10.2. If the file does not exist yet, install it from `${CLAUDE_PLUGIN_ROOT}/templates/iso-config/.iso-config.yaml` first and ask which profile the project wants, using the §0.10.2 two-question heuristic: more than one person, and an external acquirer, audit, or safety obligation. Two answers of no suggest `light`, either answer of yes suggests `standard`, and a project needing sign-off on the process itself selects `full`. Also read `sysml_toolchain`. If it is absent, say the hooks treat it as `syside` and that `@sysml-toolchain` records a choice and installs what is missing. Do not ask here, one skill owns that question. Read `test_first` too, with the Step 1 probe of `@test-first`, which prints the recorded values and the two test-first dispositions. Step 7 acts on the result. The judgement itself belongs to `@test-first`.

**2. Install the tier set.** The per-tier install matrix is §3.4 of the hooks guide. Copy from `${CLAUDE_PLUGIN_ROOT}/hooks/` into `<project>/.githooks/`, dropping the `.sh` suffix on the git entry points because git invokes hooks by exact filename. The delegate keeps its suffix because git never calls it. The canonical copy list for `.githooks/` is the installation example in `${CLAUDE_PLUGIN_ROOT}/hooks/README.md`. The story lint and the workflows come from `templates/`, as the last rows show.

| Source in the plugin | Destination in the project | light | standard | full |
|---|---|---|---|---|
| `hooks/lib/iso-profile.sh` | `.githooks/lib/iso-profile.sh` | yes | yes | yes |
| `hooks/lib/sysml-toolchain.sh` | `.githooks/lib/sysml-toolchain.sh` | yes | yes | yes |
| `hooks/lib/test-first.sh` | `.githooks/lib/test-first.sh` | yes | yes | yes |
| `hooks/prepare-commit-msg.sh` | `.githooks/prepare-commit-msg` | yes | yes | yes |
| `hooks/post-checkout.sh` | `.githooks/post-checkout` | yes | yes | yes |
| `hooks/pre-commit.sh` | `.githooks/pre-commit` | yes | yes | yes |
| `hooks/pre-commit-traceability.sh` | `.githooks/pre-commit-traceability.sh` | yes | yes | yes |
| `hooks/commit-msg.sh` | `.githooks/commit-msg` | no | yes | yes |
| `hooks/post-merge.sh` | `.githooks/post-merge` | no | no | yes |
| `templates/tools/lint/` (`story-wellformed.py`, `gherkin.py`, `README.md`) | `tools/lint/` at the engineering root | yes | yes | yes |
| `templates/github/traceability-check.yml` | `.github/workflows/traceability-check.yml` | yes, model validation and Contract 3 advisory | yes, model validation and Contract 3 advisory | yes, blocking |
| `templates/github/document-export.yml` | `.github/workflows/document-export.yml` | no | no | yes (renders documents on release, never blocks) |
| Branch protection on `main` | repository settings | not configured | recommended | required |

`pre-commit`, `tools/lint/` and the CI workflow install at every profile because they carry the Gherkin-first and test-first gates of §11.9, which block at every profile (hooks guide §3.4, methodology §0.10.4). At `light` this also runs the SysML lint (`precommit_lint`, warn) and the traceability check (`precommit_traceability`, info). Say so, because a `light` project installed before 5.0.0 had neither.

Copy the story lint and the workflows as follows, from the project root:

```bash
# Every profile, under the engineering root (the directory that holds .iso-config.yaml).
mkdir -p <ENG_ROOT>/tools/lint
cp "${CLAUDE_PLUGIN_ROOT}/templates/tools/lint/story-wellformed.py" \
   "${CLAUDE_PLUGIN_ROOT}/templates/tools/lint/gherkin.py" \
   "${CLAUDE_PLUGIN_ROOT}/templates/tools/lint/README.md" <ENG_ROOT>/tools/lint/
chmod +x <ENG_ROOT>/tools/lint/story-wellformed.py <ENG_ROOT>/tools/lint/gherkin.py
# Every profile, at the git top level.
mkdir -p .github/workflows
cp "${CLAUDE_PLUGIN_ROOT}/templates/github/traceability-check.yml" .github/workflows/traceability-check.yml
# Added at full.
cp "${CLAUDE_PLUGIN_ROOT}/templates/github/document-export.yml" .github/workflows/document-export.yml
```

The lint reads the model through `<ENG_ROOT>/tools/render/sysml_model.py`, which `@project-setup` installs. If `tools/render/` is missing, copy its four files from `${CLAUDE_PLUGIN_ROOT}/templates/tools/render/` as well. On a reinstall, offer to refresh `tools/render/` from the same plugin version, because the lint imports its model reader and the two ship together. Show the difference first when the project has changed those files, and regenerate `docs/generated/` afterwards, because the Contract 3 check compares the committed copies with a fresh rendering.

At `light` and `standard` the copied `traceability-check.yml` is made advisory by uncommenting both of its `continue-on-error: true` lines, the one in the `Validate models` step and the one in the Contract 3 derived-artefact freshness check. At `full` both stay commented, so both steps block, which is what the matrix's advisory and blocking cells mean. No other step carries a toggle. The step that runs the commit-time gates reads each gate's disposition from `.iso-config.yaml` (§0.10.4), so the Gherkin and test-first gates block in CI at every profile. The test and scenario steps run only where test first applies, and a failing test fails the workflow at every profile (§11.8).

**A set-up step for the recorded tests.** Where `test_first.applies` is `true`, the workflow runs `test_command`, and `scenario_command` when recorded, from the git top level on a bare GitHub-hosted runner, which holds the checkout and the runner image's preinstalled tools and nothing else. When the harness needs a runtime version, its dependencies or a service that the runner lacks, offer a set-up step above the step `Run the recorded tests (test_command)`, as `@test-first` Step 5 describes, for example `actions/setup-python` with the project's Python version followed by an install of the test dependencies. Show it, and write it only after a yes.

`.githooks/lib/` installs whole at every profile, so raising the profile later adds hook files only, with no second install step and no partial state.

Set the scripts executable and activate:

```bash
chmod +x .githooks/* .githooks/lib/*
git config core.hooksPath .githooks
```

The `core.hooksPath` value shall be a path inside the project root.

**3. Confirm the dispositions.** Nothing further is needed for the gates to behave correctly: each one reads its own disposition from the profile at run time, per methodology §0.10.4. Report the resulting table back to the engineer so the behaviour is not a surprise on the first commit.

| Gate | Configuration key | light | standard | full |
|---|---|---|---|---|
| Conventional-commit pattern (`commit-msg`) | `commit_msg_pattern` | off | warn | block |
| Change Request reference for baselined paths (`commit-msg`) | `commit_msg_cr_reference` | off | warn | block |
| SysML lint on changed model files (`pre-commit`) | `precommit_lint` | warn | warn | block |
| Story well-formedness, §1.9 rules 2, 3, 6 and 9 (`pre-commit`) | `precommit_story_wellformed` | off | warn | block |
| Traceability on touched requirements (`pre-commit`) | `precommit_traceability` | info | warn | block |
| Gherkin conformance, §11.9 (`pre-commit`) | `precommit_gherkin` | block | block | block |
| Test before code, §11.9 (`pre-commit`) | `precommit_test_first` | block | block | block |
| Gherkin first in session, §11.9 (`PreToolUse`) | `pretooluse_gherkin_first` | block | block | block |
| Test first in session, §11.9 (`PreToolUse`) | `pretooluse_test_first` | block | block | block |

`block` reports and stops the operation, and in `PreToolUse` it denies the agent's edit. `warn` reports and lets it through, `info` prints one summary line, `off` skips the gate. The table is the nine-gate table of §0.10.4. The two `commit-msg` rows take effect only where `commit-msg` is installed, that is at `standard` and `full`, or in a `light` project that adds it. The two `PreToolUse` rows need no install, because they act from the plugin's `hooks.json` in every session inside the project. The `pre-commit` rows also govern the CI step that runs the hook.

**4. Offer the per-gate overrides.** When one gate is wrong for this project, the fix is `gate_overrides` in `.iso-config.yaml`, never an edit to a shipped script. The override wins over the profile column, and an unset key follows it:

```yaml
project_profile: light
gate_overrides:
  precommit_traceability: block
```

Record the override on the tailoring line in the Project Plan, per §0.10.2. Editing a script instead means the next plugin upgrade silently overwrites the project's intent.

The four gates of §11 differ in one respect. Their default is a floor, so an override that lowers one names its reason on the tailoring line, and it is written only on the engineer's explicit request, never to get past a denial (§0.10.4, §11.10). The PreToolUse hook asks the human to confirm any edit that changes `gate_overrides`.

**5. Offer the phased-rollout path.** A project adopting the methodology on an existing repository does not have to start at its eventual profile. Start at `light`, raise to `standard` once the model parses cleanly and the commit conventions are habitual, and raise to `full` when an acquirer or an assessment makes the complete artefact set worth its cost. Each step is a one-line change to `project_profile` followed by a re-run of this install. This is §3.4 of the hooks guide operationalising the §12 phased-rollout advice. The §11 gates block from `light` onwards, so the phased path changes the other gates only.

**6. Update `.gitignore`.** Append `.iso-config.local.yaml` so engineers may keep machine-local overrides without committing them.

**7. Do not finish with `test_first` unrecorded.** If the Step 1 probe printed an empty `applies`, the judgement is unrecorded, or its value is neither `true` nor `false`. Do not report the install as finished. From the next commit, the test-first gate reports a finding at its disposition, block unless an override lowers it, whenever it detects test tooling (§11.9). Without a record it has no code paths to watch, so where it detects no tooling it prints one line asking for the record. The in-session test-first gate does not run at all. Route to `@test-first` (`/vse-test-first`), which makes the judgement with the engineer and writes the four records of §11.5.3, then continue with Verify. If the engineer declines to decide, report the install as incomplete and name the open record.

**8. Verify.** Make a no-op commit on a non-baselined file and confirm the installed hooks fire at the expected disposition. Run the story lint once from the engineering root, `python3 tools/lint/story-wellformed.py --only gherkin model`, and confirm that it runs: exit 0 or 1, never 2. Stories in the form used before 5.0.0 draw findings S1 (no feature file) and S3 (acceptance prose outside a named criterion), which `@story-orchestrator` resolves story by story. Open a Claude Code session in the project root and confirm the SessionStart output appears with the right `Profile:` and `Test-first:` lines. Run `.githooks/lib/sysml-toolchain.sh status` and confirm the line names the preferred tool as available, or names the fallback and its reason.

## Workflow: Change the Profile

1. Confirm which direction the project is moving and why.
2. Edit `project_profile` in `.iso-config.yaml`.
3. Re-run the install workflow above. Raising a profile adds hook files. Lowering one leaves the extra files in place but relaxes their dispositions, which is harmless. Offer to remove them. The CI workflow is already installed, so only its two `continue-on-error` toggles change, and only across the `full` boundary: comment both out when raising to `full`, uncomment both when lowering from it. Raising to `full` also adds `.github/workflows/document-export.yml`.
4. Record the change and its date on the tailoring line, keeping the previous entry so the history stays readable, per §0.10.2.
5. Raising to `full` also brings the `full` column of the §0.10.3 obligation table, which is the real cost of the change. Say so before the engineer commits to it.

A profile change needs no Change Request unless the project has put `.iso-config.yaml` on its own `baselined_paths` list.

## Workflow: Upgrade the Hook Set

A plugin update reaches the lifecycle hooks at once, including the two `PreToolUse` gates, but not the copies installed in the project. A project receives new versions of the git hooks, the story lint and the CI workflow only by re-running the install workflow above, and `@project-audit` flags drift between the installed copies and the plugin's. Overwrite the earlier copies, because a gate's logic lives in the script and the project's intent lives in `.iso-config.yaml`. The judgement call on a customised `.githooks/` applies first.

**Upgrading to 5.0.0.** The reinstall copies, at every profile:

- `pre-commit` and its traceability delegate. A `light` project installed before 5.0.0 has neither, so its commits meet the Gherkin and test-first gates, the SysML lint (warn) and the traceability line (info) for the first time. Say so.
- `lib/test-first.sh`, beside fresh copies of `lib/iso-profile.sh` and `lib/sysml-toolchain.sh`.
- `tools/lint/` at the engineering root, with the `tools/render/` refresh offered above.
- The 5.0.0 CI workflow, which a `light` project did not have. It checks out the full history and runs the commit-time gates over the change in range mode, which the earlier version did not. Re-apply the profile's toggles, and carry over any step the project added, such as a test set-up step, after showing the difference.

Then record `test_first` (Step 7), because an unrecorded judgement draws a blocking finding once test tooling is detected. Stories in the form used before 5.0.0 (findings S1 and S3) are migrated by `@story-orchestrator` when next touched, and the in-session Gherkin-first gate already denies a change to one of them until its feature file exists.

A project scaffolded before 4.0.0 also lacks `.githooks/lib/sysml-toolchain.sh`, so its SysML lint gate cannot resolve the recorded toolchain. The same reinstall copies it. The `.iso-config.yaml` already in place is left alone, because an absent `sysml_toolchain` key means `syside` and an absent `gate_overrides` key means the profile default, block for the four §11 gates.

## Configuration via `.iso-config.yaml`

The hooks read this file to determine what to enforce. Schema per §8 of the hooks guide:

```yaml
# Project rigour profile per methodology section 0.10.
# One of: light | standard | full. Absent means standard.
project_profile: standard

# SysML v2 toolchain for the lint gate and CI: syside | omg-pilot | opensysml.
# Absent means syside. Hooks fall back along that order when the tool is unavailable.
sysml_toolchain: syside

# Optional per-gate overrides: block | warn | info | off.
# Unset keys follow the profile default (section 0.10.4). The four
# gates of section 11.9 block at every profile, and lowering one is a
# tailoring decision with a recorded reason (section 11.10).
# gate_overrides:
#   precommit_traceability: block

# Test-first record per section 11.5, written by /vse-test-first.
test_first:
  applies: true
  rationale: "pytest under tests/. SysML: not viable, no execution runtime."
  test_command: "pytest -q"
  code_paths: [src/*]
  test_paths: [tests/*]

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

The `test_first` block is the first of the four records of §11.5.3. `@test-first` writes it with the engineer, and this skill only reads it. Its keys are specified in §11.5.2.

The `renderers:` block ships active with the three renderer scripts `@project-setup` installs under `tools/render/`. The remaining §9.8 artefacts have no renderer yet, so their keys stay commented until the project authors those scripts, because a configured path to a script that does not exist leaves that artefact silently unregenerated.

## Judgment Calls

The pattern for every item below: name the rule and the section it comes from, state the concrete risk, recommend the conforming path, and then proceed on the engineer's informed confirmation. Require explicit confirmation before acting when the action is destructive or irreversible.

- **Overwriting a customised `.githooks/`, `tools/lint/` or CI workflow.** If the target already exists with content that does not match the plugin's distribution, stop and show what would be replaced. Overwriting local hook logic is destructive and git does not track what was never committed. Recommend moving local overrides to `.githooks-local/` (gitignored) and sourcing them from the standard scripts, per §10 of the hooks guide. A workflow differs from the template by design once the profile's toggles or a test set-up step are applied, so carry those over and show the rest. Proceed only on explicit confirmation.
- **A `light` project that declines `pre-commit`.** Hooks guide §3.4 installs it at every profile because it carries the two commit-time gates of §11.9. Without it, a story without its feature file, or code without its test, is caught only in CI, after the push. Recommend installing it. If the SysML lint or the traceability line is unwanted noise at `light`, set `precommit_lint` or `precommit_traceability` to `off` through `gate_overrides` instead, recorded on the tailoring line.
- **Setting `core.hooksPath` outside the project root.** A hooksPath outside the working tree is shared mutable state: it breaks reproducibility for collaborators, and an unrelated clone can change what this project enforces. Say so, recommend a path inside the root, and proceed on explicit confirmation if the engineer has a reason.
- **Being asked how to get past a gate.** Answer honestly. Git provides a bypass mechanism, it is documented in the git manual, and no local hook can prevent its use. Name the mechanism, name the recording obligation from methodology §0.10.6 (the Correction Register at `full`, one line in the commit body otherwise), and recommend the conforming path first: fix the finding, or set the gate to `warn` through `gate_overrides` if it is wrong for this project. For the in-session gates the mechanisms are a recorded override and an edit made outside Claude Code (§0.10.6). Lowering one of the four §11 gates is the engineer's tailoring decision with its reason on the tailoring line, never the agent's (§11.10). CI runs the commit-time gates over the pull request, so a commit made past the local gate still meets them there. Refusing to discuss a mechanism the engineer can find in one search buys no compliance and costs trust in everything else the skill says.

## Hand-offs

- **To `@project-setup`** if hooks cannot be installed because the project is not scaffolded. The hooks rely on the §8.3 directory layout and on `.iso-config.yaml`.
- **To `@change-request`** when a baselined-artefact finding fires, so the engineer can open a CR issue and reference it in subsequent commits.
- **To `@release-orchestrator`** when post-merge regeneration drift suggests a release boundary needs a new `plan-baseline-*` or `release-*` tag.
- **To `@traceability-guard`** or `/vse-trace` when the traceability gate reports a gap, because the gate only sees the requirements this commit touched.
- **To `@sysml-toolchain`** when the lint gate prints a fallback notice or "No SysML toolchain is available".
- **To `@test-first`** (`/vse-test-first`) when `test_first` is unrecorded (Step 7), when the harness needs a CI set-up step, or when a test-first gate reports a finding.
- **To `@story-orchestrator`** when a Gherkin-first gate fires or the story lint reports findings, including the S1 and S3 findings of stories in the form used before 5.0.0.
- **To `@project-audit`** after an upgrade, to confirm that no installed copy still differs from the plugin's.

## Outputs

After a successful run, the following exist in the user project:

- `<project>/.githooks/` populated with the profile's hook set from the §3.4 matrix, all executable. At every profile it holds `pre-commit`, `pre-commit-traceability.sh`, `prepare-commit-msg`, `post-checkout`, and `lib/iso-profile.sh`, `lib/sysml-toolchain.sh` and `lib/test-first.sh`.
- `<ENG_ROOT>/tools/lint/` with the story lint and its Gherkin parser, beside `tools/render/`.
- `<project>/.iso-config.yaml` carrying `project_profile`, any `gate_overrides`, the `test_first` record written through `@test-first`, and the project-specific values.
- `<project>/.gitignore` updated to ignore `.iso-config.local.yaml`.
- `core.hooksPath` set to `.githooks` in the local git config.
- At every profile, `.github/workflows/traceability-check.yml` from `${CLAUDE_PLUGIN_ROOT}/templates/github/traceability-check.yml`, with both `continue-on-error` toggles uncommented at `light` and `standard`, plus any test set-up step the engineer approved. At `full`, also `.github/workflows/document-export.yml`.

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
| The free-energy model beneath PHAS-EAI | pages/phas-eai/phas-eai-active-inference-model.md | The free-energy formal model beneath PHAS-EAI, defining surprise, affordance, peer models, and worldview principles |
| PHAS-EAI Digital Engineering Integration Requirements R1-R4 | pages/phas-eai/phas-eai-de-requirements.md | The four PHAS-EAI digital engineering integration requirements R1 to R4 |
| Designing regimes of attention: inquiry questions and case evidence | pages/phas-eai/phas-eai-designing-attention-regimes.md | Five inquiry questions for designing regimes of attention, with a worked VSE security case and quantified outcomes |
| PHAS-EAI Equations: Response Time, Resilience, Functional Information | pages/phas-eai/phas-eai-equations.md | The three PHAS-EAI equation families for response time, resilience, and functional information |
| PHAS-EAI Lever Tables and Cross-Case Hypothesis Evidence | pages/phas-eai/phas-eai-levers-and-evidence.md | The four PHAS-EAI lever tables and the hypotheses with the strongest cross-case support |
| LLM as expert peer in VSE requirement reviews | pages/phas-eai/phas-eai-llm-peer-review.md | Case evidence for LLM-as-expert-peer requirement reviews in a VSE, with cautions on scoring and model ageing |
| PHAS-EAI Framework: Core Constructs | pages/phas-eai/phas-eai-overview.md | The five PHAS-EAI constructs, from configuration space and cognitive reserve to niche construction |
| The human dimension: craftsmanship, New Work, and the gap of slackness | pages/sysmod/sysmod-neg-human-dimension.md | Craftsmanship over Taylorism, New Work values, the gap of slackness, and the project-hero burnout warning |
| Java 21 runtime for the OMG pilot | pages/tooling/tooling-java-runtime.md | Installing a Java 21 runtime per platform for the OMG pilot, JRE versus JDK, JAVA_HOME, and the version check |
| Choosing a SysML v2 toolchain: Syside, OMG pilot, OpenSysML | pages/tooling/tooling-sysml-toolchain-choice.md | Choosing between Syside, the OMG pilot, and OpenSysML, their licences, capabilities, and the fallback order |
| Validator selection and fallback in the pre-commit lint gate | pages/tooling/tooling-validator-fallback-process.md | How the pre-commit lint gate picks a SysML v2 validator, falls back with a notice, and reports findings |
<!-- wiki-routing:end -->
