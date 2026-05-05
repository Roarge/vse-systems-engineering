#!/usr/bin/env bash
# Project-side git commit-msg hook.
#
# Per methodology/iso-29110-hooks-guide.md §4.2. Two responsibilities:
#   1. Enforce conventional commit patterns with story scope, Change
#      Request reference, or Meeting Record format.
#   2. Require a 'CR #<n>' reference when the staged diff touches a
#      baselined artefact (per .iso-config.yaml baselined_paths).
#      This is the firm gate. The pre-commit hook surfaces it as a
#      reminder; commit-msg blocks if missing.
#
# Install as <project>/.githooks/commit-msg.
# Exit non-zero blocks the commit.
set -euo pipefail

MSG_FILE="$1"
MSG=$(head -n1 "$MSG_FILE")
FULL_MSG=$(cat "$MSG_FILE")

# Skip merge commits.
if echo "$MSG" | grep -qE '^Merge '; then
    exit 0
fi

# 1. Conventional-commit pattern check.
PATTERN_STORY='^(feat|fix|docs|refactor|test|chore|perf)(\(([A-Z]+_[0-9]+(_[A-Za-z0-9]+)?|US_[0-9]+|SYS_[0-9]+|[A-Za-z][A-Za-z0-9_-]*)\))?: .+'
PATTERN_CR='^(plan|feat|fix|docs|refactor|chore): .+ \(CR #[0-9]+\)$'
PATTERN_MEETING='^meeting: [0-9]{4}-[0-9]{2}-[0-9]{2} .+'

if [[ "$MSG" =~ $PATTERN_STORY ]] || [[ "$MSG" =~ $PATTERN_CR ]] || [[ "$MSG" =~ $PATTERN_MEETING ]]; then
    : # Subject pattern ok, continue to the baseline check.
else
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
fi

# 2. Baselined-artefact gate. If any staged file is on the
# baselined_paths list, the message body shall reference a CR.
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
ISO_CONFIG=""
if [ -f "${ROOT}/.iso-config.yaml" ]; then
    ISO_CONFIG="${ROOT}/.iso-config.yaml"
elif [ -f "${ROOT}/engineering/.iso-config.yaml" ]; then
    ISO_CONFIG="${ROOT}/engineering/.iso-config.yaml"
fi

if [ -n "$ISO_CONFIG" ]; then
    BASELINED=$(awk '
        /^baselined_paths:/ { inside=1; next }
        inside && /^[A-Za-z]/ { inside=0 }
        inside && /^[[:space:]]+-[[:space:]]+/ {
            sub(/^[[:space:]]+-[[:space:]]+/, "")
            sub(/[[:space:]]+#.*$/, "")
            print
        }
    ' "$ISO_CONFIG")

    BASELINED_HIT=""
    while IFS= read -r staged_file; do
        [ -z "$staged_file" ] && continue
        while IFS= read -r baselined_path; do
            [ -z "$baselined_path" ] && continue
            case "$staged_file" in
                "$baselined_path"|"$baselined_path"/*)
                    BASELINED_HIT="${BASELINED_HIT}${staged_file}"$'\n'
                    ;;
            esac
        done <<< "$BASELINED"
    done < <(git diff --cached --name-only --diff-filter=ACM)

    if [ -n "$BASELINED_HIT" ]; then
        if ! echo "$FULL_MSG" | grep -qE '\(CR #[0-9]+\)|CR #[0-9]+|Refs?: CR #[0-9]+'; then
            cat >&2 <<EOF
[commit-msg] This commit modifies baselined artefacts but the message
does not reference a Change Request:

$(printf '%s' "$BASELINED_HIT" | sed 's/^/  /')

Per §10.4.2 / §4.2 of the hooks guide, edits to baselined artefacts
shall reference an open Change Request issue. Forms accepted:
  ... (CR #<n>)        in the subject line
  CR #<n>              anywhere in the body
  Refs: CR #<n>        in the trailer

Open a CR via /vse-cr if one does not exist.
EOF
            exit 1
        fi
    fi
fi

exit 0
