#!/usr/bin/env bash
# UserPromptSubmit hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §5.2. Detects prompts that
# imply ISO-relevant actions and injects reminders before the agent
# plans its work.
#
# Three heuristics:
#   1. Edits to plausibly baselined artefacts -> PM.O3 Change Request reminder.
#   2. Synchronous-review mentions -> PM.O4 Meeting Record reminder.
#   3. Reverse-engineering prompts -> §2.6 rule 7 guard.
#
# stdin: JSON payload from Claude Code with the user prompt.
# stdout: appended to the prompt context.
# Exit 0 always.
set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // .user_message // ""' 2>/dev/null || echo "")

# Skip silently outside a VSE project.
if [ ! -d "methodology" ] && [ ! -d "engineering/methodology" ]; then
    exit 0
fi

# Heuristic 1: edits + plausibly baselined artefact references.
if echo "$PROMPT" | grep -qiE '(change|edit|modify|update|delete|revise|amend).*(plan|baselined|US_[0-9]+|SYS_[0-9]+|architecture|risk register|cm strategy)'; then
    cat <<'EOF'

[methodology reminder — PM.O3]
This prompt may involve changes to baselined or load-bearing artefacts.
Per §10.4.2 Change Request lifecycle:
- Confirm with the user whether a Change Request issue exists.
- If not, propose opening one with cost/schedule/technical/risk impact analysis (/vse-cr).
- Reference 'CR #<n>' in any commit modifying baselined artefacts.
EOF
fi

# Heuristic 2: meeting/review mentions.
if echo "$PROMPT" | grep -qiE '(meeting|reviewed with|sync|standup|workshop|kickoff) (today|yesterday|this morning|earlier|just now)'; then
    cat <<'EOF'

[methodology reminder — PM.O4]
A synchronous review may have occurred. Per §10.4.3:
- Capture a Meeting Record in docs/meetings/<YYYY-MM-DD>-<topic>.md.
- Include attendees, agreements, open issues, next meeting.
EOF
fi

# Heuristic 3: reverse-engineering of pre-existing context (§2.6 rule 7).
if echo "$PROMPT" | grep -qiE '(generate|create|infer|complete|fill in|fill out|reverse[- ]?engineer|derive).*(stories|stakeholders|concerns|requirements).*(for|from|based on|covering|matching).*(platform|architecture|existing|current|legacy|base|infrastructure)'; then
    cat <<'EOF'

[methodology reminder — agent-collaboration discipline (§2.6 rule 7)]
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

exit 0
