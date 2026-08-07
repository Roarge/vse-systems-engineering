#!/usr/bin/env bash
# Project-side git commit-msg hook.
#
# Per methodology/iso-29110-hooks-guide.md §4.2. Two gates:
#   1. commit_msg_pattern: conventional commit patterns with story
#      scope, Change Request reference, or Meeting Record format.
#   2. commit_msg_cr_reference: a 'CR #<n>' reference when the staged
#      diff touches a baselined artefact (per .iso-config.yaml
#      baselined_paths).
#
# Each gate carries a disposition drawn from the project rigour profile
# and any per-gate override, per methodology §0.10.4. block reports and
# stops the commit, warn reports and lets it through, info prints one
# summary line, off skips the gate.
#
# Install as <project>/.githooks/commit-msg.
set -euo pipefail

MSG_FILE="$1"
MSG=$(head -n 1 "$MSG_FILE")
FULL_MSG=$(cat "$MSG_FILE")

# Skip merge commits.
if echo "$MSG" | grep -qE '^Merge '; then
    exit 0
fi

# Load the shared profile helpers. The project-side copy wins, the
# plugin copy is the fallback for a partial install.
HOOK_DIR="$(dirname "$0")"
ISO_PROFILE_LIB=""
if [ -r "${HOOK_DIR}/lib/iso-profile.sh" ]; then
    ISO_PROFILE_LIB="${HOOK_DIR}/lib/iso-profile.sh"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -r "${CLAUDE_PLUGIN_ROOT}/hooks/lib/iso-profile.sh" ]; then
    ISO_PROFILE_LIB="${CLAUDE_PLUGIN_ROOT}/hooks/lib/iso-profile.sh"
fi

if [ -n "$ISO_PROFILE_LIB" ]; then
    # shellcheck source=/dev/null
    . "$ISO_PROFILE_LIB"
else
    # An install without the library reports rather than blocks, which
    # is the standard-profile disposition for both gates.
    iso_gate_disposition() { printf 'warn\n'; }
fi

PATTERN_DISPOSITION="$(iso_gate_disposition commit_msg_pattern)"
CR_DISPOSITION="$(iso_gate_disposition commit_msg_cr_reference)"

# 1. Conventional-commit pattern gate.
PATTERN_STORY='^(feat|fix|docs|refactor|test|chore|perf)(\(([A-Z]+_[0-9]+(_[A-Za-z0-9]+)?|US_[0-9]+|SYS_[0-9]+|[A-Za-z][A-Za-z0-9_-]*)\))?: .+'
PATTERN_CR='^(plan|feat|fix|docs|refactor|chore): .+ \(CR #[0-9]+\)$'
PATTERN_MEETING='^meeting: [0-9]{4}-[0-9]{2}-[0-9]{2} .+'

report_pattern_finding() {
    cat >&2 <<EOF
${1} Commit message does not match the required conventions.

Allowed forms (hooks guide §4.2):
  feat(US_042): brief subject
  fix(SYS_142): brief subject
  plan: revise schedule (CR #17)
  meeting: 2026-05-05 architecture sync

Got:
  ${MSG}
EOF
}

report_cr_finding() {
    cat >&2 <<EOF
${1} This commit modifies baselined artefacts but the message does not
reference a Change Request:

$(printf '%s' "$BASELINED_HIT" | sed 's/^/  /')

Per methodology §10.4.2 and hooks guide §4.2, edits to baselined
artefacts shall reference an open Change Request issue. Forms accepted:
  ... (CR #<n>)        in the subject line
  CR #<n>              anywhere in the body
  Refs: CR #<n>        in the trailer

Open a CR via /vse-cr if one does not exist.
EOF
}

if [ "$PATTERN_DISPOSITION" != "off" ]; then
    if [[ "$MSG" =~ $PATTERN_STORY ]] || [[ "$MSG" =~ $PATTERN_CR ]] || [[ "$MSG" =~ $PATTERN_MEETING ]]; then
        : # Subject pattern ok, continue to the baseline gate.
    else
        case "$PATTERN_DISPOSITION" in
            block)
                report_pattern_finding "[commit-msg]"
                echo "" >&2
                echo "To proceed anyway, record a one-line rationale per methodology §0.10.6." >&2
                exit 1
                ;;
            warn)
                report_pattern_finding "[commit-msg] warning:"
                ;;
            info)
                echo "[commit-msg] Subject does not match the conventional-commit forms (hooks guide §4.2)." >&2
                ;;
        esac
    fi
fi

# 2. Baselined-artefact gate. If any staged file is on the
# baselined_paths list, the message body shall reference a CR.
if [ "$CR_DISPOSITION" = "off" ]; then
    exit 0
fi

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

    # An empty list means the Change Request machinery is dormant,
    # which is the light-profile default per methodology §0.10.3.
    if [ -z "$BASELINED" ]; then
        exit 0
    fi

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
            case "$CR_DISPOSITION" in
                block)
                    report_cr_finding "[commit-msg]"
                    echo "" >&2
                    echo "To proceed anyway, record a one-line rationale per methodology §0.10.6." >&2
                    exit 1
                    ;;
                warn)
                    report_cr_finding "[commit-msg] warning:"
                    ;;
                info)
                    echo "[commit-msg] Baselined artefacts modified without a CR reference (methodology §10.4.2)." >&2
                    ;;
            esac
        fi
    fi
fi

exit 0
