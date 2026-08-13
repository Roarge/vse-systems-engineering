---
paths:
  - "hooks/**"
  - "hooks.json"
---

# Hook Rules

Read `hooks/README.md` before adding or editing anything in `hooks/`.
The directory holds two distinct kinds of script:

- **Lifecycle hooks**, registered in `hooks.json` (referenced from
  `plugin.json`) and executed by the harness at the eight registered
  events: `SessionStart`, `UserPromptSubmit`, `PreToolUse` and
  `PostToolUse` (matcher `Edit|Write|NotebookEdit`), `Stop`,
  `SubagentStop`, `PreCompact`, `Notification`. They are not Claude
  actions and Claude does not invoke them.
- **Project-side scripts**, not registered in `hooks.json`, installed
  into user projects (as `.githooks/`) by the attention-regime skill or
  invoked by CI workflows from `templates/github/`.

Conventions for every script: `#!/usr/bin/env bash`,
`set -euo pipefail`, executable bit set. CI checks all three.

**Rigour profiles.** Gate-carrying hooks are profile-aware. They read
the project's `.iso-config.yaml` (`project_profile`: light, standard,
or full, plus per-gate `gate_overrides`) through
`hooks/lib/iso-profile.sh`, and gate dispositions scale block, warn,
info, or off per methodology §0.10. Profile defaults reserve block for
the full profile, and a `gate_overrides` entry may raise any single
gate to block at any profile. Do not hard-code a disposition in a hook
body.

**Testing.** Source the script directly with the same environment
variables and stdin the harness would provide, and record expected exit
codes. Do not rely on Claude to feel whether the hook fires.
