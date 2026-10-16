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
`set -euo pipefail`, executable bit set. CI checks all three. Hook code
stays bash 3.2 and POSIX-awk compatible (no `mapfile`, no associative
arrays, no `match(s, r, arr)`).

**Rigour profiles.** Gate-carrying hooks are profile-aware. They read
the project's `.iso-config.yaml` (`project_profile`: light, standard,
or full, plus per-gate `gate_overrides`) through
`hooks/lib/iso-profile.sh`, and the SysML validator through
`hooks/lib/sysml-toolchain.sh` (preference, availability, fallback). Do
not call `syside`, `java` or `sysml` directly from a hook body. Gate
dispositions scale block, warn, info, or off per methodology §0.10.
From 5.0.0, the four test-first and Gherkin gates
(`precommit_gherkin`, `precommit_test_first`,
`pretooluse_gherkin_first`, `pretooluse_test_first`) default to block
at every profile, and only a recorded `gate_overrides` entry lowers
one. The other gates scale as before: their profile defaults reserve
block for the full profile, and a `gate_overrides` entry may raise any
single gate to block at any profile. Do not hard-code a disposition in
a hook body.

**Output contract.** Plain stdout reaches the model only for
`SessionStart` and `UserPromptSubmit`. For `PreToolUse`,
`PostToolUse`, `Stop` and `SubagentStop`, Claude never sees plain
text. When one of these hooks has something to say, its stdout
carries exactly one JSON object with `hookSpecificOutput.hookEventName`
set to the event name. Diagnostics go to stderr, never stdout.

**Testing.** Hook changes follow `.claude/rules/tdd-bdd.md`, so the
failing test comes first. Source the script directly with the same
environment variables and stdin the harness would provide, and record
expected exit codes. Lifecycle hook tests feed the stdin JSON payload
through `tc_run_lifecycle` in `tests/hooks/lib.sh` and assert on the
single JSON object the hook prints. Do not rely on Claude to feel
whether the hook fires.
