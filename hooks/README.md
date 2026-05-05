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

| Script                     | Event              | Matcher                | Purpose                                                                                              |
|----------------------------|--------------------|------------------------|------------------------------------------------------------------------------------------------------|
| `session-start.sh`         | `SessionStart`     | (none)                 | Detect VSE project / SysML repo / contributor mode and inject methodology context per §5.1.          |
| `user-prompt-submit.sh`    | `UserPromptSubmit` | (none)                 | Reverse-engineering guard, baselined-edit reminder, meeting-record reminder per §5.2.                |
| `pre-tool-use.sh`          | `PreToolUse`       | `Edit\|Write\|NotebookEdit` | Block edits to baselined artefacts without an open Change Request per §5.3.                          |
| `post-tool-use.sh`         | `PostToolUse`      | `Write\|Edit`          | Post-edit reminders for stories, concerns, architecture, Project Plan per §5.4.                      |
| `source-added-reminder.sh` | `PostToolUse`      | `Write\|Edit`          | Wiki-only contributor hook: appends source-added stub to wiki/LOG.md when sources/ files change.     |
| `stop.sh`                  | `Stop`             | (none)                 | ADR / V&V capture prompts at end of agent response per §5.5.                                         |
| `subagent-stop.sh`         | `SubagentStop`     | (none)                 | Aggregate compliance findings from subagents per §5.6.                                               |
| `pre-compact.sh`           | `PreCompact`       | (none)                 | Snapshot ISO state before context compaction per §5.7.                                               |
| `notification.sh`          | `Notification`     | (none)                 | Periodic reminders on stale Change Requests and risks per §5.8.                                      |

These scripts assume they run from the user project root, which is how
the harness invokes them. They consume `stdin` for tool use events
(`pre-tool-use.sh`, `post-tool-use.sh`) or no input at all (the rest).

**To add a new lifecycle hook:**

1. Write the script here in `hooks/`.
2. Give it `set -euo pipefail` and a `#!/usr/bin/env bash` shebang.
3. Make it executable: `chmod +x hooks/your-hook.sh`.
4. Register it in `../hooks.json` under the correct lifecycle event.
5. Test it by sourcing it directly with the same environment variables
   the harness would set (do not rely on Claude to "feel" whether it
   fires).

**Do not** expect these scripts to be copied into anyone's `.git/hooks/`
or run in CI. That is what category 2 is for.

## 2. Project-side scripts (installed into user projects via `core.hooksPath`)

These scripts are **not** registered in `hooks.json`. The Claude Code
harness never touches them. They are installed into the user's own
project under `<project>/.githooks/` and activated with
`git config core.hooksPath .githooks`.

| Script                       | Installed as                             | Purpose                                                                                                                                              |
|------------------------------|------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| `pre-commit.sh`              | `<project>/.githooks/pre-commit`         | Orchestrate four checks per §4.1: SysML lint, story well-formedness (§1.9), baselined-artefact protection, traceability integrity.                   |
| `pre-commit-traceability.sh` | called by `pre-commit`                   | Trace-integrity check (existing legacy script). Delegated by the orchestrator above.                                                                 |
| `commit-msg.sh`              | `<project>/.githooks/commit-msg`         | Enforce conventional-commit pattern with story scope, CR reference, or meeting-record format per §4.2.                                               |
| `prepare-commit-msg.sh`      | `<project>/.githooks/prepare-commit-msg` | Prepopulate the commit subject with the Story ID inferred from the branch name per §4.3.                                                             |
| `pre-push.sh`                | `<project>/.githooks/pre-push`           | Story-state-on-main, V&V coverage, traceability matrix freshness, baseline integrity on tags per §4.4. Stub passthrough until tools/lint/ matures.   |
| `post-merge.sh`              | `<project>/.githooks/post-merge`         | Regenerate model-derived artefacts when main advances per §4.5. Reports drift; does not auto-commit.                                                 |
| `post-checkout.sh`           | `<project>/.githooks/post-checkout`      | Print methodology / branch status when switching branches per §4.6.                                                                                  |

The `post-receive` server-side hook (§4.7) is documented in the hooks
guide but not shipped here. It is a server-side responsibility. See
the methodology spec for the mirror-to-backup-remote pattern.

These scripts ship to installers as part of the plugin tree, exactly
like `templates/`, `methodology/`, and `wiki/`, even though they are
not listed in `hooks.json`.

**Installation example (user project, executed by `@attention-regime`):**

```bash
mkdir -p .githooks
cp "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit.sh"          .githooks/pre-commit
cp "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" .githooks/pre-commit-traceability.sh
cp "${CLAUDE_PLUGIN_ROOT}/hooks/commit-msg.sh"          .githooks/commit-msg
cp "${CLAUDE_PLUGIN_ROOT}/hooks/prepare-commit-msg.sh"  .githooks/prepare-commit-msg
cp "${CLAUDE_PLUGIN_ROOT}/hooks/pre-push.sh"            .githooks/pre-push
cp "${CLAUDE_PLUGIN_ROOT}/hooks/post-merge.sh"          .githooks/post-merge
cp "${CLAUDE_PLUGIN_ROOT}/hooks/post-checkout.sh"       .githooks/post-checkout
chmod +x .githooks/*
git config core.hooksPath .githooks
```

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
