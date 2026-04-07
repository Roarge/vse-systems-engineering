# `hooks/` directory

This directory holds shell scripts that belong to two different execution
models. They are grouped here for historical and discoverability reasons,
but they are not interchangeable. Read this file before editing, adding,
or relocating anything in `hooks/`.

## 1. Claude Code lifecycle hooks (run by the harness)

These scripts are registered in [`../hooks.json`](../hooks.json) and
executed automatically by the Claude Code harness at specific lifecycle
events. Claude does not invoke them. The contributor never copies them
anywhere. They run because the harness reads `hooks.json` at plugin load
time and wires them up.

| Script | Event | Matcher | Purpose |
|--------|-------|---------|---------|
| `session-start.sh` | `SessionStart` | (none) | Detects a VSE project (presence of `.vse-phase`) and injects phase context, session journal status, SysML model counts, and SySiDE CLI availability into the conversation. Also enforces loading the `vse-companion-overview` skill as a mandatory first action. |
| `sysml-change-reminder.sh` | `PostToolUse` | `Write\|Edit` | Fires after any `Write` or `Edit`. Internally filters to `.sysml` files only. Reminds about traceability and optionally runs `syside format --check` on the modified file. |

These scripts assume they run from the user project root, which is how
the harness invokes them. They consume `stdin` for tool use events
(`sysml-change-reminder.sh`) or no input at all (`session-start.sh`).

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

## 2. Project-side scripts (installed into user projects or called from CI)

These scripts are **not** registered in `hooks.json`. The Claude Code
harness never touches them. They are installed into the user's own
project (for example, into `.git/hooks/`) or invoked by GitHub Actions
workflows generated from [`../templates/github/`](../templates/github/).

| Script | Installed as | Invoked by | Purpose |
|--------|--------------|------------|---------|
| `pre-commit-traceability.sh` | `.git/hooks/pre-commit` in the user project | The user's local git, on every commit | Checks staged `.sysml` files for requirements without satisfy or verify trace links. Blocks the commit if gaps are found. |
| `phase-gate-check.sh` | Run in place from the repo root | The `@lifecycle-orchestrator` skill (manually) and the `phase-gate.yml` GitHub Actions workflow from `templates/github/` | Verifies that the ISO/IEC 29110 work products required for the current phase exist. Reads `.vse-phase` to determine the target phase. |

Both scripts are addressed by skills via `${CLAUDE_PLUGIN_ROOT}/hooks/`
(for example, [`skills/attention-regime/SKILL.md`](../skills/attention-regime/SKILL.md)
instructs Claude to `cp ${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh .git/hooks/pre-commit`).
They ship to installers as part of the plugin tree, exactly like
`templates/` and `knowledge/`, even though they are not listed in
`hooks.json`.

**Installation example (user project):**

```bash
cp "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

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
into `hooks/lifecycle/` and `hooks/project/`, or moving category 2 into
a sibling directory such as `project-scripts/`. That would touch the
skills that reference `${CLAUDE_PLUGIN_ROOT}/hooks/...`, so it is not a
free change.
