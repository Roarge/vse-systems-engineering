# ISO 29110 Compliance Hooks Guide

*A companion to the methodology specification — implementation
guidance for automating ISO/IEC TR 29110‑5‑6‑2:2014 compliance with
git hooks and Claude Code hooks.*

## 1. Purpose

This guide specifies how to automate the ISO 29110 compliance
discipline established in §9 (compliance mapping) and §10 (Project
Management) of the methodology. The goal is to make compliance
*ambient* rather than periodic — the right things happen because the
tools do them, not because someone remembered.

Two hook surfaces are exploited:

1. **Git hooks** — fire on git events (commit, push, merge, etc.) and
   either gate the operation (block on violation) or trigger
   side-effects (regenerate derived artefacts, notify a backup remote).
2. **Claude Code hooks** — fire on agent events (session start,
   prompt submission, tool use, response completion) and either
   inject context (compliance status, ISO obligations relevant to
   the task) or gate agent actions (block edits to baselined
   artefacts unless a Change Request is open).

The two surfaces complement each other. Git hooks are the
*enforcement* layer — they prevent non-compliant state from reaching
the repository. Claude Code hooks are the *guidance* layer — they
keep the agent and its operator aligned with ISO obligations during
authoring.

## 2. ISO 29110 obligations covered by hooks

| ISO obligation | Hook(s) that cover it |
|---|---|
| PM.O1 — Plan reviewed and accepted | `pre-push` to main; PR-required CI lint |
| PM.O2 — Progress monitored; corrections | `post-merge` regenerator; CC `Stop` hook prompts for Progress Status entry |
| PM.O3 — Change Requests handled | `pre-commit` baselined-artefact check; CC `PreToolUse` on Edit |
| PM.O4 — Review meetings recorded | `commit-msg` meeting commit format; CC `UserPromptSubmit` after sync review |
| PM.O5 — Risk register monitored | CC `SessionStart` Risk summary; weekly CI cron job for stale risks |
| PM.O6 — Configuration management | `pre-push` baseline integrity; mirror via `post-receive` |
| PM.O7 — V&V performed | `pre-push` checks V&V cases for ready stories |
| PM.O8 — Disposal Management Approach | CI lint for Plan completeness |
| SR.O2 — Requirements analysed and baselined | `pre-commit` story well-formedness; CC `PreToolUse` story-file checks |
| SR.O3 — Architectural design baselined; traceability | `post-merge` Traceability Matrix regeneration |
| SR.O6 — System Configuration baselined | tag-protection; `pre-push` on tags |
| SR.O7 — V&V tasks performed; reports stored | `post-merge` V&V report aggregator; CC `Stop` after V&V execution |

Coverage is not exhaustive — hooks reduce friction but do not replace
human judgement. The hooks raise the floor; the team raises the
ceiling.

## 3. Repository setup

### 3.1 Hook directory structure

```
<repo-root>/
├── .git/                         # standard git directory
├── .githooks/                    # checked-in hook scripts
│   ├── pre-commit
│   ├── commit-msg
│   ├── prepare-commit-msg
│   ├── pre-push
│   ├── post-merge
│   ├── post-checkout
│   └── lib/                      # shared helpers
│       ├── iso-checks.sh
│       └── story-lint.py
├── .claude/                      # Claude Code configuration
│   ├── settings.json             # hook configuration
│   └── hooks/                    # Claude Code hook scripts
│       ├── session-start.sh
│       ├── pre-tool-use.sh
│       ├── post-tool-use.sh
│       ├── stop.sh
│       └── lib/
│           └── iso-status.sh     # shared with .githooks/lib
├── tools/                        # methodology tooling
│   ├── render/                   # model → ISO documents
│   │   ├── traceability-matrix.py
│   │   ├── stakeholder-reqs-doc.py
│   │   ├── system-reqs-doc.py
│   │   ├── ivv-plan.py
│   │   └── justification-doc.py
│   └── lint/
│       ├── story-wellformed.py
│       └── plan-complete.py
├── .github/workflows/            # CI for things hooks alone can't do
│   └── compliance.yml
└── docs/                         # ISO 29110 artefacts
    ├── project-plan.md
    ├── progress-status-record.md
    ├── correction-register.md
    ├── risk-register.md
    ├── product-acceptance-record.md
    ├── meetings/
    ├── decisions/
    └── templates/
```

### 3.2 Activate the hooks

Git hooks live in `.git/hooks/` by default but that directory is not
versioned. The standard workaround is to use `core.hooksPath`:

```bash
# Run once per clone:
git config core.hooksPath .githooks
chmod +x .githooks/*
```

Optionally, automate this in `tools/setup.sh` and document it in the
README under "First-time setup."

For Claude Code, settings live in `.claude/settings.json` (project-
local) or `~/.claude/settings.json` (user-level). Project-local
settings take precedence and are version-controlled.

### 3.3 Verify the documentation cutoff

Claude Code hook APIs evolve. Before deploying the configurations in
this guide, verify the current hook event names and JSON schemas
against the official documentation at
`https://docs.claude.com/en/docs/agents-and-tools/claude-code/hooks`.
Any changes since this guide was written should be applied to the
example configurations below.

## 4. Git hooks

### 4.1 `pre-commit`

**Purpose.** Block commits that introduce non-compliant state.

**Checks performed:**

1. **SysML model lint.** Run a SysML v2 parser against every changed
   `.sysml` file; fail on syntax error.
2. **Story well-formedness.** For each changed file in
   `model/core/stories/` or
   `model/core/logical-architecture/components/.../stories/`, run the
   story linter (per §1.9 well-formedness rules + §10 metadata).
3. **Baselined-artefact protection.** If a file under a baselined
   path (configured in `.iso-config.yaml`) has been changed, require
   the commit message to reference an open Change Request issue.
4. **Traceability integrity.** Reject commits that introduce dangling
   `derive`, `frame concern`, or `verify` references.

**Sample script (`.githooks/pre-commit`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib/iso-checks.sh"

# 1. SysML lint
changed_sysml=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sysml$' || true)
if [[ -n "$changed_sysml" ]]; then
    iso::lint_sysml $changed_sysml || {
        echo "❌ SysML lint failed. Fix syntax errors before committing." >&2
        exit 1
    }
fi

# 2. Story well-formedness
changed_stories=$(echo "$changed_sysml" | grep -E '/(stories|requirements)/' || true)
if [[ -n "$changed_stories" ]]; then
    python3 tools/lint/story-wellformed.py $changed_stories || {
        echo "❌ Story well-formedness failed (§1.9)." >&2
        exit 1
    }
fi

# 3. Baselined-artefact protection
if iso::touches_baselined; then
    if ! iso::commit_references_change_request; then
        echo "❌ Edit to baselined artefact without referenced Change Request." >&2
        echo "   Open an issue with label 'change-request' and reference it as" >&2
        echo "   'CR #<n>' in the commit message." >&2
        exit 1
    fi
fi

# 4. Traceability integrity
python3 tools/render/traceability-matrix.py --check || {
    echo "❌ Traceability integrity failed (dangling references)." >&2
    exit 1
}

echo "✅ pre-commit ISO 29110 checks passed."
```

### 4.2 `commit-msg`

**Purpose.** Enforce commit-message conventions that make audit trails
queryable.

**Checks performed:**

1. **Story-scoped commits** must reference a Story ID
   (`feat(US_042): ...` or `fix(SYS_142): ...`).
2. **Plan/CR commits** must reference an Issue number
   (`plan: ... (CR #17)` or `feat: ... (CR #23)`).
3. **Conventional types** are enforced: `feat`, `fix`, `docs`,
   `refactor`, `test`, `chore`, `plan`, `meeting`.

**Sample script (`.githooks/commit-msg`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
msg_file=$1
msg=$(head -n1 "$msg_file")

# Allowed forms:
#   <type>(<scope>): <subject>      [scope is Story ID or omitted]
#   <type>: <subject> (CR #<n>)     [Plan/Change Request work]
#   meeting: <date> <topic>          [Meeting Record commit]
pattern_story='^(feat|fix|docs|refactor|test|chore)(\(([A-Z]+_[0-9]+_[A-Za-z0-9]+|US_[0-9]+|SYS_[0-9]+|[A-Z]+_[0-9]+)\))?: .+'
pattern_cr='^(plan|feat|fix|docs|refactor|chore): .+ \(CR #[0-9]+\)$'
pattern_meeting='^meeting: [0-9]{4}-[0-9]{2}-[0-9]{2} .+'

if [[ "$msg" =~ $pattern_story || "$msg" =~ $pattern_cr || "$msg" =~ $pattern_meeting ]]; then
    exit 0
fi

cat >&2 <<EOF
❌ Commit message does not match required conventions.

Allowed forms:
  feat(US_042): brief subject
  fix(SYS_142): brief subject
  plan: revise schedule (CR #17)
  meeting: 2026-05-05 architecture sync

Got: "$msg"
EOF
exit 1
```

### 4.3 `prepare-commit-msg`

**Purpose.** Reduce friction by prepopulating commit messages with
the Story ID inferred from the branch name.

**Sample script (`.githooks/prepare-commit-msg`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
msg_file=$1
source_type=${2:-}

# Skip if the message is already set (merge, squash, etc.)
[[ -n "$source_type" ]] && exit 0

branch=$(git branch --show-current)
# story/US_042_AckFromDashboard → US_042
if [[ "$branch" =~ ^story/([A-Z]+_[0-9]+) ]]; then
    story_id=${BASH_REMATCH[1]}
    # Only prepopulate if the file currently begins with a comment line
    if head -n1 "$msg_file" | grep -q '^#'; then
        sed -i "1i feat($story_id): " "$msg_file"
    fi
fi
```

### 4.4 `pre-push`

**Purpose.** Final compliance gate before changes leave the local
repository. More expensive checks live here than in `pre-commit`.

**Checks performed:**

1. **Story state on `main`.** Reject pushes that would land stories
   in `inProgress` state on `main`. (Story status is in `StoryMeta`
   metadata.)
2. **V&V coverage.** Reject pushes where `done` stories lack a
   referenced verification case.
3. **Traceability matrix freshness.** Regenerate and compare against
   the committed copy; reject if out of sync.
4. **Baseline integrity on tags.** When pushing an annotated tag,
   verify all artefacts under CM are in `baselined` state.

**Sample script (`.githooks/pre-push`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib/iso-checks.sh"

while read local_ref local_sha remote_ref remote_sha; do
    # Only enforce on protected branches and tags
    case "$remote_ref" in
        refs/heads/main|refs/heads/release/*)
            iso::check_no_inprogress_stories "$local_sha" || exit 1
            iso::check_vv_coverage "$local_sha" || exit 1
            iso::check_traceability_fresh "$local_sha" || exit 1
            ;;
        refs/tags/release-*)
            iso::check_baseline_integrity "$local_sha" || exit 1
            ;;
    esac
done

echo "✅ pre-push ISO 29110 checks passed."
```

### 4.5 `post-merge`

**Purpose.** Regenerate model-derived artefacts when `main` advances.

**Side-effects performed:**

1. **Traceability Matrix** regenerated to `docs/traceability-matrix.md`.
2. **Stakeholder/System/Subsystem Requirements Specifications**
   rendered to `docs/generated/`.
3. **IVV Plan** rendered to `docs/generated/ivv-plan.md`.
4. **Justification Document** rendered (aggregating trade studies +
   ADRs).
5. **Progress Status Record** entry stub appended for the iteration
   if iteration boundary is crossed.

**Sample script (`.githooks/post-merge`):**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Only run on main
[[ "$(git rev-parse --abbrev-ref HEAD)" == "main" ]] || exit 0

echo "Regenerating ISO 29110 derived artefacts…"
python3 tools/render/traceability-matrix.py     > docs/traceability-matrix.md
python3 tools/render/stakeholder-reqs-doc.py    > docs/generated/stakeholders-requirements.md
python3 tools/render/system-reqs-doc.py         > docs/generated/system-requirements.md
python3 tools/render/ivv-plan.py                > docs/generated/ivv-plan.md
python3 tools/render/justification-doc.py       > docs/generated/justification-document.md

if git diff --quiet -- docs/; then
    echo "✓ Derived artefacts already current."
else
    echo "⚠ Derived artefacts regenerated; commit the updates."
fi
```

(Note: `post-merge` cannot itself create commits without surprising
the user; it regenerates and *reports* drift. Production of the
follow-up commit is left to CI on `main` — see §6.)

### 4.6 `post-checkout`

**Purpose.** Inform the operator of compliance status when switching
branches.

**Sample script (`.githooks/post-checkout`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
prev=$1; new=$2; checkout_type=$3
[[ "$checkout_type" == "1" ]] || exit 0   # only on branch checkouts

bash .claude/hooks/lib/iso-status.sh
```

The shared `iso-status.sh` is reused by Claude Code's
`SessionStart` hook (§5.1) so the operator and the agent see the
same status.

### 4.7 `post-receive` (server-side)

**Purpose.** Mirror to backup remote (CM Strategy backup
requirement, §10.8).

**Sample script (deployed on the canonical remote):**

```bash
#!/usr/bin/env bash
set -euo pipefail
git push --mirror git@backup-remote:org/project.git
```

This belongs on the server hosting the canonical remote (GitHub or
self-hosted GitLab). For SaaS hosts, equivalent functionality is
provided via mirroring features in the host's admin UI.

## 5. Claude Code hooks

Claude Code hooks are configured in `.claude/settings.json`. The full
schema is at `https://docs.claude.com/en/docs/agents-and-tools/claude-code/hooks` —
verify the field names below against current docs.

### 5.1 `SessionStart`

**Purpose.** Inject project compliance state at the start of every
session, so Claude has up-to-date context on what's baselined, what's
in flight, and what's overdue.

**Configuration (excerpt from `.claude/settings.json`):**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**Sample script (`.claude/hooks/session-start.sh`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
cat <<EOF
=== ISO 29110 Project Status ===

Iteration:        $(cat docs/iteration.txt 2>/dev/null || echo "not set")
Branch:           $(git branch --show-current)
Project Plan:     $(git tag -l 'plan-baseline-*' | tail -1 || echo "not yet baselined")

In-flight stories ($(python3 tools/lint/count-stories.py --status inProgress)):
$(python3 tools/lint/list-stories.py --status inProgress | head -10)

Pending Change Requests ($(gh issue list -l change-request -s open --json number | jq length 2>/dev/null || echo "?")):
$(gh issue list -l change-request -s open --json number,title --jq '.[] | "  CR #\(.number): \(.title)"' 2>/dev/null | head -5)

Stale risks (>30 days since review):
$(python3 tools/lint/stale-risks.py 2>/dev/null | head -5)

Reminders:
- Edits to baselined artefacts require an open Change Request (PM.O3).
- New stories shall declare role, capability, benefit, ≥1 acceptance (§1.9).
- After modifying a story, update its verification case (SR.O7).
- Stories build forward from the Base Architecture (§2.1). Do NOT
  reverse-engineer or auto-generate stakeholders, concerns, or
  stories that explain Base Architecture decisions; create context
  stories only on explicit user request, with confirmation of intent
  (§2.6 rule 7).

EOF
```

The output is injected into Claude's context at session start. Claude
then has the same situational awareness as a human operator running
`git status` plus their tracking tools.

### 5.2 `UserPromptSubmit`

**Purpose.** Detect prompts that imply ISO-relevant actions and
inject reminders before the agent plans its work.

**Triggers:**

- Prompts containing keywords for *change* applied to plausibly
  baselined artefacts.
- Prompts that reference synchronous review/meeting events
  (suggest creating a Meeting Record).
- Prompts that imply new story authoring (suggest the §1 template).

**Configuration:**

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/user-prompt-submit.sh"
          }
        ]
      }
    ]
  }
}
```

**Sample script (`.claude/hooks/user-prompt-submit.sh`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
# The user prompt arrives on stdin as JSON (per Claude Code hook contract).
prompt=$(jq -r '.prompt // .user_message // ""')

# Heuristic: edits + plausibly baselined artefact references
if echo "$prompt" | grep -qiE '(change|edit|modify|update|delete).*(plan|baselined|US_[0-9]+|SYS_[0-9]+|architecture)'; then
    cat <<EOF
[ISO 29110 reminder]
This prompt may involve changes to baselined or load-bearing artefacts.
Per PM.O3 (Change Request handling) and §10.4.2:
- Confirm with the user whether a Change Request issue exists.
- If not, propose opening one with cost/schedule/technical impact analysis.
- Reference 'CR #<n>' in any commit modifying baselined artefacts.
EOF
fi

# Heuristic: meeting/review mentions
if echo "$prompt" | grep -qiE '(meeting|reviewed with|sync|standup) (today|yesterday|this morning)'; then
    cat <<EOF
[ISO 29110 reminder]
A synchronous review may have occurred. Per PM.O4:
- Capture a Meeting Record in docs/meetings/<YYYY-MM-DD>-<topic>.md.
- Include attendees, agreements, open issues, next meeting.
EOF
fi

# Heuristic: requests that imply reverse-engineering of pre-existing
# context. The methodology forbids agents from synthesising stories,
# stakeholders, or concerns that "explain" Base Architecture decisions
# (§2.1 corollary 2; §2.6 rule 7).
if echo "$prompt" | grep -qiE '(generate|create|infer|complete|fill in|fill out|reverse[- ]?engineer|derive).*(stories|stakeholders|concerns|requirements).*(for|from|based on|covering|matching).*(platform|architecture|existing|current|legacy|base|infrastructure)'; then
    cat <<EOF
[ISO 29110 reminder — agent-collaboration discipline]
This prompt may be asking for stories, stakeholders, or concerns to be
synthesised from pre-existing context (Base Architecture, legacy
system, existing infrastructure). Per §2.1 corollary 2 and §2.6 rule
7, the agent shall NOT auto-generate context stories or
reverse-engineer Base Architecture justifications.

If the user explicitly wants context stories for organisational memory
or audit trail, confirm intent first ("you want me to author X
deliberately as context — confirm?") and clearly mark the resulting
artefacts as context, not as forward-going required output.

If the user wants forward-going work, ignore the existing context as
specification material and focus on what the project shall *add*.
EOF
fi
```

The script's stdout is appended to the prompt context (per Claude
Code hook semantics) — Claude sees the reminder and can act on it
before responding.

### 5.3 `PreToolUse`

**Purpose.** Gate tool calls that would violate compliance,
particularly edits to baselined artefacts without an open Change
Request.

**Configuration (with matchers for Edit/Write/NotebookEdit):**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-tool-use.sh"
          }
        ]
      }
    ]
  }
}
```

**Sample script (`.claude/hooks/pre-tool-use.sh`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // .tool')
target=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# Skip if not a file-modifying tool or no path
[[ -z "$target" ]] && exit 0

# Check baselined-artefact list (project-determined; lives in .iso-config.yaml)
if python3 tools/lint/is-baselined.py "$target"; then
    if ! python3 tools/lint/has-open-cr.py; then
        cat <<EOF
{
  "decision": "block",
  "reason": "File '$target' is a baselined ISO 29110 artefact. Per PM.O3, modifications require an open Change Request. Open a CR issue first, then reference 'CR #<n>' in your commits."
}
EOF
        exit 0
    fi
fi

# For story files: enforce template completeness will-be-met
if [[ "$target" =~ /stories/.*\.sysml$ ]]; then
    cat <<EOF
[ISO 29110 reminder] Editing a story file. Required fields per §1.9:
  - subject (typed)
  - role (typed by part def from core/stakeholders/ or component scope)
  - capability (narrative string)
  - benefit (narrative string)
  - frame concern (≥1) or documented justification
  - acceptance (≥1) before status=ready
After editing: ensure StoryMeta status is updated and the verification case (if any) is current.
EOF
fi

exit 0
```

The `decision: block` JSON tells Claude Code to refuse the tool call
with the given reason. The reminder strings (without `decision`) are
injected as additional context.

### 5.4 `PostToolUse`

**Purpose.** After model edits, prompt for the *consequent* updates
that ISO compliance requires.

**Triggers:**

- After editing a story file → suggest checking/updating the
  verification case.
- After editing an interface or part def → suggest checking
  allocations.
- After editing a concern → suggest checking story coverage.
- After editing the Project Plan → suggest updating the Progress
  Status Record.

**Configuration:**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-tool-use.sh"
          }
        ]
      }
    ]
  }
}
```

**Sample script (`.claude/hooks/post-tool-use.sh`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
input=$(cat)
target=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""')
[[ -z "$target" ]] && exit 0

case "$target" in
    */stories/*.sysml)
        story_id=$(basename "$target" .sysml)
        cat <<EOF
[ISO 29110 follow-up] Story $story_id changed. Consider:
  - Update the verification case verifying its acceptance (SR.O7).
  - Check that StoryMeta.status reflects the new state.
  - If the change introduced a new constraint, regenerate the Traceability Matrix.
EOF
        ;;
    */concerns/*.sysml)
        cat <<EOF
[ISO 29110 follow-up] Concern changed. Consider:
  - Check that all framing stories still satisfy the concern.
  - Update stakeholder communications if the concern's scope shifted.
EOF
        ;;
    */logical-architecture/*.sysml)
        cat <<EOF
[ISO 29110 follow-up] Architecture changed. Consider:
  - Update allocations if subsystem responsibilities shifted (SR.O3).
  - Re-render Traceability Matrix.
  - If decision was non-trivial, write an ADR in docs/decisions/.
EOF
        ;;
    docs/project-plan.md)
        cat <<EOF
[ISO 29110 follow-up] Project Plan changed. Per PM.O1:
  - This change requires Acquirer review and approval.
  - Reference the corresponding Change Request issue.
  - On merge, tag a new plan-baseline.
EOF
        ;;
esac
```

### 5.5 `Stop`

**Purpose.** At the end of Claude's response, prompt the operator (or
the agent itself) to capture decision rationale and follow-up tasks.

**Configuration:**

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/stop.sh"
          }
        ]
      }
    ]
  }
}
```

**Sample script (`.claude/hooks/stop.sh`):**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Look at the changes in this session and prompt for ADR / report capture
recent_changes=$(git status --porcelain)

# Architecture decision indicators
if echo "$recent_changes" | grep -qE '^.M (model/variations/|model/core/logical-architecture/)'; then
    cat <<EOF
[ISO 29110 prompt — end of session]
Architectural changes detected. Per PM.3.3 and §10.5.3, consider:
  - Writing an ADR in docs/decisions/ if a non-trivial decision was made.
  - Updating the trade-study analysis def if a variant was selected.
EOF
fi

# V&V execution indicators (verification report files modified)
if echo "$recent_changes" | grep -qE '^.M docs/.*verification-report'; then
    cat <<EOF
[ISO 29110 prompt — end of session]
Verification activity detected. Per SR.O7:
  - Ensure the Verification Report references its IVV procedure.
  - Update the relevant story's StoryMeta if verification passed/failed.
EOF
fi
```

### 5.6 `SubagentStop`

**Purpose.** When using Claude Code's subagent feature for parallel
work, aggregate compliance check results from each subagent.

```json
{
  "hooks": {
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/subagent-stop.sh"
          }
        ]
      }
    ]
  }
}
```

The subagent-stop script aggregates outputs from sub-tasks (each
working on a separate story branch, perhaps) and reports any
compliance issues to the orchestrating session.

### 5.7 `PreCompact`

**Purpose.** Capture compliance state before context compaction so it
isn't lost from the rolling memory.

```json
{
  "hooks": {
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-compact.sh"
          }
        ]
      }
    ]
  }
}
```

**Sample script:**

```bash
#!/usr/bin/env bash
set -euo pipefail
# Persist the current ISO state to a workspace file so post-compaction
# context can re-read it.
bash .claude/hooks/lib/iso-status.sh > /tmp/iso-state-snapshot.txt
echo "[ISO state snapshot saved to /tmp/iso-state-snapshot.txt]"
```

### 5.8 `Notification`

**Purpose.** Periodic compliance reminders (overdue risks, stale
Change Requests). These are unobtrusive and do not gate work.

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/notification.sh"
          }
        ]
      }
    ]
  }
}
```

## 6. CI hooks (covering what local hooks cannot)

Local git hooks fire on the developer's machine. Some checks are best
run on the canonical CI runner so that they cannot be bypassed and so
that their results are visible on the PR.

### 6.1 GitHub Actions example

`.github/workflows/compliance.yml`:

```yaml
name: ISO 29110 Compliance
on:
  pull_request:
    branches: [main, 'release/**']
  push:
    branches: [main]
    tags: ['release-*', 'plan-baseline-*']

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install -r tools/requirements.txt
      - name: Story well-formedness (§1.9)
        run: python3 tools/lint/story-wellformed.py model/
      - name: Plan completeness (§10.3.1)
        run: python3 tools/lint/plan-complete.py docs/project-plan.md
      - name: Traceability integrity (§9.8)
        run: python3 tools/render/traceability-matrix.py --check

  render:
    needs: lint
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { token: ${{ secrets.RENDER_BOT_TOKEN }} }
      - run: |
          python3 tools/render/traceability-matrix.py     > docs/traceability-matrix.md
          python3 tools/render/stakeholder-reqs-doc.py    > docs/generated/stakeholders-requirements.md
          python3 tools/render/system-reqs-doc.py         > docs/generated/system-requirements.md
          python3 tools/render/ivv-plan.py                > docs/generated/ivv-plan.md
          python3 tools/render/justification-doc.py       > docs/generated/justification-document.md
      - uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "docs: regenerate derived artefacts [skip ci]"
          file_pattern: 'docs/**/*.md'

  baseline-check:
    if: startsWith(github.ref, 'refs/tags/release-')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: python3 tools/lint/baseline-integrity.py

  backup-mirror:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - name: Mirror to backup remote
        run: |
          git push --mirror ${{ secrets.BACKUP_REMOTE_URL }}
```

The `render` job creates the auto-commit that `post-merge` could not.
The `baseline-check` job blocks tag pushes that don't satisfy CM
integrity.

## 7. Hook orchestration

Hooks compose to enforce a workflow. A typical story lifecycle from a
hooks perspective:

```
1. Operator opens story branch:    story/US_042_AckFromDashboard
   → post-checkout fires, prints ISO status

2. Claude Code session opens
   → SessionStart fires, injects status

3. Operator: "Add the story for batch alarm acknowledgement"
   → UserPromptSubmit fires; story-creation reminder injected

4. Claude calls Edit on the story file
   → PreToolUse fires; checks baselined status (not baselined → allow)
   → Reminder about §1.9 fields injected

5. Claude completes the edit
   → PostToolUse fires; reminds about verification case

6. Operator: "git commit -am 'feat(US_042): initial draft'"
   → pre-commit fires; runs lint, story well-formedness
   → commit-msg fires; validates message format
   → commit succeeds

7. Operator pushes; opens PR
   → CI compliance.yml runs; lint + Traceability check

8. PR review, merge to main
   → post-merge fires locally on next pull; regenerates artefacts
   → CI render job commits regenerated artefacts on main

9. Release tag pushed
   → pre-push fires; checks baseline integrity
   → CI baseline-check job validates
   → CI backup-mirror job mirrors to backup remote
```

The path is forced through the right ISO obligations at each
checkpoint. The operator sees ISO status at session start, gets
nudges during authoring, and is blocked only when proceeding would
land non-compliant state on a protected reference.

## 8. Configuration file (`.iso-config.yaml`)

A single project-level configuration file drives the hook behaviour:

```yaml
# .iso-config.yaml — ISO 29110 hook configuration

baselined_paths:
  - docs/project-plan.md
  - docs/cm-strategy.md
  - methodology/
  - model/library/

protected_branches:
  - main
  - release/*

iteration:
  cadence_days: 14
  current: "2026-Q2-iter-3"

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
  traceability_matrix:    tools/render/traceability-matrix.py
  stakeholder_reqs:       tools/render/stakeholder-reqs-doc.py
  system_reqs:            tools/render/system-reqs-doc.py
  ivv_plan:               tools/render/ivv-plan.py
  justification:          tools/render/justification-doc.py
```

The hook scripts read this file to determine what to enforce.

## 9. Setup checklist

For a new project adopting this methodology + ISO 29110 compliance:

- [ ] Repository scaffolded per §8.3 of methodology.
- [ ] `.githooks/` populated with scripts from §4 of this guide;
      `git config core.hooksPath .githooks` run.
- [ ] `tools/lint/` and `tools/render/` populated with project-
      specific implementations.
- [ ] `.claude/settings.json` configured with hooks per §5;
      `.claude/hooks/` populated with scripts.
- [ ] `.iso-config.yaml` authored per §8.
- [ ] `.github/workflows/compliance.yml` deployed per §6.1.
- [ ] Branch protection enabled on `main` and `release/*`
      (no force-push, required PR review, required status checks).
- [ ] Backup remote configured; mirroring tested.
- [ ] CODEOWNERS file in place mapping ISO roles to git identities.
- [ ] `docs/project-plan.md` authored and baselined
      (PR through full review cycle).
- [ ] Initial Risk Register, Correction Register, Disposal Approach
      sections in place.
- [ ] First iteration boundary set; Progress Status Record created.

## 10. Customisation guidance

The hooks specified here are a *baseline*. Project sets will adjust
them based on:

- **Tool stack.** A project using the Eclipse SysML v2 tooling may
  invoke its CLI for lint instead of a custom Python linter.
- **Issue tracker.** The `gh` CLI is GitHub-specific; GitLab projects
  use `glab`; other trackers need their own integration.
- **Renderer technology.** The renderers are Python here; they could
  equally be Node, Bash, or a single SysML v2 model-query tool.
- **Iteration cadence and granularity.** A 1-week-iteration project
  may need more frequent regeneration than the post-merge default.

Two patterns work well for customisation:

- **Override before extend.** When the standard hook doesn't fit,
  override it locally in `.githooks-local/` (gitignored) and have the
  versioned `.githooks/` scripts source the local override if
  present.
- **Configuration over code.** Push project-specific behaviour into
  `.iso-config.yaml` rather than into the scripts. The scripts stay
  the same across projects; the config differs.

## 11. Failure modes and how to handle them

| Failure | Symptom | Fix |
|---|---|---|
| Hook script not executable | Commits or pushes succeed without checks running | `chmod +x .githooks/*` |
| `core.hooksPath` not set | Same as above | `git config core.hooksPath .githooks` |
| Renderer slow at scale | `pre-commit` takes >5 s | Move heavy checks to `pre-push` or CI; keep `pre-commit` to fast lint only |
| Claude Code hooks not firing | No status injected at session start | Verify `.claude/settings.json` schema matches current docs; check shell scripts are executable |
| False positives blocking valid work | `pre-commit` blocks legitimate edits | Tighten the `is-baselined.py` heuristics; allow operator override via `--no-verify` (with audit log entry); review `.iso-config.yaml` |
| Hook bypass via `--no-verify` | Operator workaround that hides non-compliance | Mirror enforcement in CI — local hooks for fast feedback, CI hooks as the unbypassable gate |

The key principle: **local hooks are advisory speed-ups; CI is the
unbypassable gate.** A determined operator can bypass `pre-commit`
with `--no-verify`; they cannot bypass GitHub Actions blocking a PR
merge. Design the hook set with this in mind.

## 12. Out of scope of this guide

- Specific implementations of the lint and render scripts. The
  contracts are stable; the implementations are project-determined.
- Tooling for ISO 29110 *assessment* per ISO/IEC TR 29110‑3. The
  hooks here keep the project compliant; an external assessor still
  performs the formal audit.
- Migration from a non-hook-driven legacy project. Adoption strategy
  is project-set-determined; a phased rollout (lint first, then
  baseline protection, then derived artefact generation) is usually
  more humane than a big-bang switch.

---

*End of hooks guide. Companion documents: methodology §0–§10. The
guide is updated whenever methodology compliance obligations change
or Claude Code hook APIs evolve.*
