#!/usr/bin/env bash
# Project-side git commit-msg hook.
#
# Per methodology/iso-29110-hooks-guide.md §4.2. Enforces conventional
# commit patterns with story scope, Change Request reference, or
# Meeting Record format.
#
# Install as <project>/.githooks/commit-msg.
# Exit non-zero blocks the commit.
set -euo pipefail

MSG_FILE="$1"
MSG=$(head -n1 "$MSG_FILE")

# Skip merge commits.
if echo "$MSG" | grep -qE '^Merge '; then
    exit 0
fi

# Allowed forms:
#   <type>(<scope>): <subject>            scope is Story ID or omitted
#   <type>: <subject> (CR #<n>)            Plan or CR work
#   meeting: <YYYY-MM-DD> <topic>          Meeting Record
PATTERN_STORY='^(feat|fix|docs|refactor|test|chore|perf)(\(([A-Z]+_[0-9]+(_[A-Za-z0-9]+)?|US_[0-9]+|SYS_[0-9]+|[A-Z][a-z]+|.+)\))?: .+'
PATTERN_CR='^(plan|feat|fix|docs|refactor|chore): .+ \(CR #[0-9]+\)$'
PATTERN_MEETING='^meeting: [0-9]{4}-[0-9]{2}-[0-9]{2} .+'

if [[ "$MSG" =~ $PATTERN_STORY ]] || [[ "$MSG" =~ $PATTERN_CR ]] || [[ "$MSG" =~ $PATTERN_MEETING ]]; then
    exit 0
fi

cat >&2 <<EOF
[commit-msg] Commit message does not match required conventions.

Allowed forms (per §4.2 of the hooks guide):
  feat(US_042): brief subject
  fix(SYS_142): brief subject
  plan: revise schedule (CR #17)
  meeting: 2026-05-05 architecture sync

Got:
  ${MSG}

To bypass for a non-canonical commit, use 'git commit --no-verify' and
record the rationale in the Correction Register.
EOF
exit 1
