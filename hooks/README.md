# `hooks/` directory

This directory holds shell scripts that belong to two different execution
models. They are grouped here for historical and discoverability reasons,
but they are not interchangeable. Read this file before editing, adding,
or relocating anything in `hooks/`.

The hook surface is specified by `methodology/iso-29110-hooks-guide.md`
§4 (project-side git hooks) and §5 (Claude Code lifecycle hooks).

## 1. Claude Code lifecycle hooks (run by the harness)

These scripts are registered in [`../hooks.json`](../hooks.json) and
executed automatically by the Claude Code harness at specific lifecycle
events. Claude does not invoke them. The contributor never copies them
anywhere. They run because the harness reads `hooks.json` at plugin load
time and wires them up.

| Script | Event | Matcher | Purpose |
|---|---|---|---|
| `session-start.sh` | `SessionStart` | (none) | Detect contributor mode, a SysML-only repository or a VSE project, and print context per §5.1. In a VSE project the context ends with the Behaviour-first and Test-first lines of methodology §11 (the Test-first line names the recorded `test_first.applies` value), a nudge when test tooling is found while that value is false or unrecorded, and a warning when `jq` is missing. In contributor mode it prints one pointer to `.claude/rules/tdd-bdd.md`. |
| `user-prompt-submit.sh` | `UserPromptSubmit` | (none) | Reverse-engineering guard, baselined-edit reminder, meeting-record reminder per §5.2. |
| `pre-tool-use.sh` | `PreToolUse` | `Edit\|Write\|MultiEdit\|NotebookEdit` | The in-session Gherkin-first and test-first gates of methodology §11.9.3, which deny the edit at `block`. Asks the human to confirm an edit that changes `gate_overrides` or `test_first` (methodology §11.10). Passes on the baselined-path and story reminders per §5.3. |
| `post-tool-use.sh` | `PostToolUse` | `Edit\|Write\|MultiEdit\|NotebookEdit` | Post-edit reminders for feature files, stories, concerns, architecture, the Project Plan, and code where test first applies, per §5.4. |
| `source-added-reminder.sh` | `PostToolUse` | `Edit\|Write\|MultiEdit\|NotebookEdit` | Wiki-only contributor hook. Reminds the agent to run `/vse-wiki-ingest` and appends a source-added stub to `wiki/LOG.md` when `sources/` files change. |
| `stop.sh` | `Stop` | (none) | ADR and V&V (verification and validation) capture reminders for the user at the end of a turn, and the test-first finding for the agent once for each session and state, per §5.5. Silent while `stop_hook_active` is true. |
| `subagent-stop.sh` | `SubagentStop` | (none) | Runs `stop.sh` for the `SubagentStop` event per §5.6. |
| `pre-compact.sh` | `PreCompact` | (none) | Snapshot ISO state before context compaction per §5.7. |
| `notification.sh` | `Notification` | (none) | Periodic reminders on stale Change Requests and risks per §5.8. |

The matcher is a regular expression over the tool name, so
`Edit|Write|MultiEdit|NotebookEdit` (escaped as `\|` in the table)
covers the four file tools an agent edits with. The harness runs every
lifecycle hook with the session's working directory, normally the user
project root. The tool-use and stop hooks also read a JSON payload on
stdin and find the project from the edited file or the payload's
`cwd`, so they work from any directory.

**Output contract.** What a hook prints reaches Claude only in the form
its event expects (hooks guide §5).

- `SessionStart` and `UserPromptSubmit`: plain text on stdout is added
  to Claude's context. `session-start.sh` keeps that text to printable
  ASCII.
- `PreToolUse`, `PostToolUse`, `Stop` and `SubagentStop`: Claude never
  sees plain stdout. A hook with something to say prints exactly one
  JSON object, and a hook with nothing to say prints nothing. The
  harness drops a malformed object, or any text beside it, so these
  hooks print through `lib/hook-json.sh` and never with `echo`.
- Diagnostics go to stderr, never to stdout, so they cannot corrupt
  the JSON object.
- The JSON hooks always exit 0. An internal error ends one with a line
  on stderr and no decision, so a deny never comes from a crash. The
  `pre-commit` and CI gates are the backstop.

The JSON object uses these fields:

| Field | Meaning |
|---|---|
| `hookSpecificOutput.hookEventName` | The event name, present whenever `hookSpecificOutput` is |
| `hookSpecificOutput.permissionDecision` | `deny` or `ask`, at `PreToolUse` only. No hook ever answers `allow`, so the engineer's own permission settings still govern every call a hook lets through |
| `hookSpecificOutput.permissionDecisionReason` | The reason the agent reads, clipped so it stays under 1,500 characters (1,499 at most) |
| `hookSpecificOutput.additionalContext` | Text added to the agent's context |
| `systemMessage` | Text shown to the human, not to the agent |

For example, a denied edit:

```json
{"hookSpecificOutput": {"hookEventName": "PreToolUse",
  "permissionDecision": "deny",
  "permissionDecisionReason": "..."}}
```

**To add a new lifecycle hook:**

1. Write the script here in `hooks/`.
2. Give it `set -euo pipefail` and a `#!/usr/bin/env bash` shebang.
3. Make it executable: `chmod +x hooks/your-hook.sh`.
4. Register it in `../hooks.json` under the correct lifecycle event.
5. Follow the output contract above. At a JSON event, print through
   `lib/hook-json.sh`.
6. Test it first, under `tests/hooks/`, with the same environment
   variables and stdin payload the harness would provide
   (`tc_run_lifecycle` in `tests/hooks/lib.sh`). Do not rely on Claude
   to "feel" whether it fires.

**Do not** expect these scripts to be copied into anyone's `.git/hooks/`
or run in CI. That is what category 2 is for.

## 2. Project-side scripts (installed into user projects via `core.hooksPath`)

These scripts are **not** registered in `hooks.json`. The Claude Code
harness never touches them. They are installed into the user's own
project under `<project>/.githooks/` and activated with
`git config core.hooksPath .githooks`.

| Script                       | Installed as                             | Purpose                                                                                                                                              |
|------------------------------|------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| `pre-commit.sh`              | `<project>/.githooks/pre-commit`         | Run the commit-time gates per §4.1: SysML lint, story well-formedness (§1.9), Gherkin conformance and test before code (methodology §11.9), traceability integrity, and a note on baselined artefacts. Reads the staged set, or in CI the range `VSE_PRECOMMIT_RANGE` names. |
| `pre-commit-traceability.sh` | called by `pre-commit`                   | Trace-integrity check (existing legacy script). Delegated by the orchestrator above.                                                                 |
| `commit-msg.sh`              | `<project>/.githooks/commit-msg`         | Enforce conventional-commit pattern with story scope, CR reference, or meeting-record format per §4.2.                                               |
| `prepare-commit-msg.sh`      | `<project>/.githooks/prepare-commit-msg` | Prepopulate the commit subject with the Story ID inferred from the branch name per §4.3.                                                             |
| `post-merge.sh`              | `<project>/.githooks/post-merge`         | Regenerate model-derived artefacts when main advances per §4.5. Reports drift. Does not auto-commit.                                                |
| `post-checkout.sh`           | `<project>/.githooks/post-checkout`      | Print methodology / branch status when switching branches per §4.6.                                                                                  |
| `lib/iso-profile.sh`         | `<project>/.githooks/lib/iso-profile.sh` | Shared library (see below). |
| `lib/sysml-toolchain.sh`     | `<project>/.githooks/lib/sysml-toolchain.sh` | Shared library (see below). |
| `lib/test-first.sh`          | `<project>/.githooks/lib/test-first.sh`  | Shared library (see below). |

No local `pre-push` hook ships. The four pre-push obligations of hooks
guide §4.4 (story state on main, V&V coverage on done stories,
traceability matrix freshness, baseline integrity on release tags) are
documented there as continuous-integration contracts, because a local
hook cannot be the unbypassable gate those obligations need.

## 3. Shared libraries (`lib/`)

Four libraries hold the logic the hooks share. Each is sourced, never
run as a hook, and sourcing one defines functions and does no other
work.

| Library | Sourced by | Installed into projects | Purpose |
|---|---|---|---|
| `lib/iso-profile.sh` | `pre-commit`, `pre-commit-traceability`, `commit-msg`, `post-merge`, and the lifecycle hooks `pre-tool-use.sh`, `post-tool-use.sh`, `stop.sh` and `session-start.sh` | yes, every profile | Resolves the `.iso-config.yaml` in force, the rigour profile and the per-gate dispositions per methodology §0.10.4, and reads nested records such as `test_first`. |
| `lib/sysml-toolchain.sh` | `pre-commit` and `session-start.sh`. Also executed by CI, the Makefile check, the audit and the sysml-toolchain skill | yes, every profile | Resolves the `sysml_toolchain` preference, probes availability (including the Syside licence), validates with the preferred tool and falls back along syside, omg-pilot, opensysml. |
| `lib/test-first.sh` | `pre-commit`, `pre-tool-use.sh`, `post-tool-use.sh`, `stop.sh` and `session-start.sh` | yes, every profile | Story scanning for Gherkin first, path classification, test evidence, refactor branches, test tooling detection (`vse_tf_detect`) and the recorded `test_first.applies` value (methodology §11.5 and §11.9). Requires `iso-profile.sh` to be sourced first. |
| `lib/hook-json.sh` | `pre-tool-use.sh`, `post-tool-use.sh`, `source-added-reminder.sh` and `stop.sh` | no, it stays in the plugin | Prints the one JSON object of the output contract above, with `jq`, else `python3`, else a fixed literal that says neither is available, and reads fields from the stdin payload. |

`sysml-toolchain.sh` is also executable, and it guards its command
dispatch on `BASH_SOURCE`, so sourcing it defines functions only.

## 4. Installing the project-side scripts

Which of the project-side scripts an install copies is a function of
the project rigour profile. The per-tier install matrix is hooks guide
§3.4, which methodology §0.10 follows, and the `attention-regime` skill
executes it. `pre-commit` carries the Gherkin-first and test-first
gates of methodology §11.9, which block at every profile, so it
installs at every profile together with its traceability delegate and
all three project-side libraries. `commit-msg` installs at `standard`
and `full`, and `post-merge` at `full` only. The same matrix also
installs `tools/lint/` (the story lint and its Gherkin parser) and the
compliance workflow at every profile.

The `post-receive` server-side hook (§4.7) is documented in the hooks
guide but not shipped here. It is a server-side responsibility. See
the methodology spec for the mirror-to-backup-remote pattern.

These scripts ship to installers as part of the plugin tree, exactly
like `templates/`, `methodology/`, and `wiki/`, even though they are
not listed in `hooks.json`.

**Installation example (user project, executed by `@attention-regime`):**

```bash
mkdir -p .githooks/lib
# Installed at every profile (light, standard, full).
cp "${CLAUDE_PLUGIN_ROOT}/hooks/lib/iso-profile.sh"     .githooks/lib/iso-profile.sh
cp "${CLAUDE_PLUGIN_ROOT}/hooks/lib/sysml-toolchain.sh" .githooks/lib/sysml-toolchain.sh
cp "${CLAUDE_PLUGIN_ROOT}/hooks/lib/test-first.sh"      .githooks/lib/test-first.sh
cp "${CLAUDE_PLUGIN_ROOT}/hooks/prepare-commit-msg.sh"  .githooks/prepare-commit-msg
cp "${CLAUDE_PLUGIN_ROOT}/hooks/post-checkout.sh"       .githooks/post-checkout
cp "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit.sh"          .githooks/pre-commit
cp "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" .githooks/pre-commit-traceability.sh
# Added at standard and full.
cp "${CLAUDE_PLUGIN_ROOT}/hooks/commit-msg.sh"          .githooks/commit-msg
# Added at full.
cp "${CLAUDE_PLUGIN_ROOT}/hooks/post-merge.sh"          .githooks/post-merge
chmod +x .githooks/* .githooks/lib/*
git config core.hooksPath .githooks
```

`lib/hook-json.sh` is not copied. Only the lifecycle hooks use it, and
they run from the plugin tree.

The destination filenames drop the `.sh` extension because git invokes
hooks by exact filename per the hooks guide §3.

**To add a new project-side script:**

1. Write the script here in `hooks/` and mark it executable.
2. **Do not** register it in `hooks.json`. That would cause the harness
   to run it at a lifecycle event, which is almost certainly not what
   you want for a project-side tool.
3. Reference it from the relevant skill using `${CLAUDE_PLUGIN_ROOT}/hooks/<script>`.
4. If it is meant to run in CI, add a corresponding workflow file
   under `templates/github/`.
5. Document the install or invocation path in the skill that owns it.

## Why these two categories live in the same directory

Historically, this plugin only had the project-side scripts, and the
`hooks/` name referred to git and CI hooks. When Claude Code lifecycle
hooks were added, they landed in the same directory because `hooks.json`
naturally points there. The two categories were never relocated, and
the contributor ergonomics of a single directory outweighed the cost of
potential confusion (as long as this README exists).

If this directory grows past a handful of scripts, consider splitting
into `hooks/lifecycle/` and `hooks/githooks/`, or moving category 2
into a sibling directory such as `project-scripts/`. That would touch
the skills that reference `${CLAUDE_PLUGIN_ROOT}/hooks/...`, so it is
not a free change.

## Removed in v2.0.0

The following scripts existed in v1.x and have been removed for v2:

- `hooks/iteration-boundary-check.sh`. No boundary-check concept in
  the new methodology. Stories advance individually through the §8.5
  PR workflow. No fixed-length iteration closes en bloc.
- `hooks/sysml-change-reminder.sh`. Replaced by `hooks/post-tool-use.sh`,
  which covers the same use case under the §5.4 lifecycle hook contract.
