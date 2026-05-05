#!/usr/bin/env bash
# Project-side git pre-commit hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §4.1. Four concerns:
#   1. SysML lint on staged .sysml files (delegated to syside if available).
#   2. Story well-formedness (§1.9) — script stub; full lint in tools/lint/.
#   3. Baselined-artefact protection — requires CR reference in commit
#      when staged paths match .iso-config.yaml baselined_paths.
#   4. Traceability integrity — delegates to pre-commit-traceability.sh.
#
# Install via core.hooksPath:
#   git config core.hooksPath .githooks
# Where .githooks/ is the project-side hooks directory containing this
# script (renamed to "pre-commit", without the .sh suffix).
#
# Exit non-zero blocks the commit.
set -euo pipefail

HOOK_DIR="$(dirname "$0")"
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# 1. SysML lint via syside if available.
STAGED_SYSML=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sysml$' || true)
if [ -n "$STAGED_SYSML" ] && command -v syside >/dev/null 2>&1; then
    if ! echo "$STAGED_SYSML" | xargs syside check --warnings-as-errors 2>&1; then
        echo "[pre-commit] SysML lint failed. Fix syntax errors before committing." >&2
        exit 1
    fi
fi

# 2. Story well-formedness check (delegated; full implementation in
# tools/lint/story-wellformed.py per methodology iso-29110-hooks-guide.md).
# In v2.0-rc, this is a stub that succeeds if the lint script is absent.
if [ -n "$STAGED_SYSML" ] && [ -x "tools/lint/story-wellformed.py" ]; then
    STAGED_STORIES=$(echo "$STAGED_SYSML" | grep -E '/stories/' || true)
    if [ -n "$STAGED_STORIES" ]; then
        if ! echo "$STAGED_STORIES" | xargs python3 tools/lint/story-wellformed.py; then
            echo "[pre-commit] Story well-formedness failed (§1.9). Fix and re-stage." >&2
            exit 1
        fi
    fi
fi

# 3. Baselined-artefact protection.
ISO_CONFIG=""
[ -f ".iso-config.yaml" ] && ISO_CONFIG=".iso-config.yaml"
[ -f "engineering/.iso-config.yaml" ] && ISO_CONFIG="engineering/.iso-config.yaml"

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
    STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)
    BASELINED_HIT=""
    while IFS= read -r baselined_path; do
        [ -z "$baselined_path" ] && continue
        while IFS= read -r staged_file; do
            [ -z "$staged_file" ] && continue
            case "$staged_file" in
                "$baselined_path"|"$baselined_path"/*)
                    BASELINED_HIT="$BASELINED_HIT $staged_file"
                    ;;
            esac
        done <<< "$STAGED_FILES"
    done <<< "$BASELINED"

    if [ -n "$BASELINED_HIT" ]; then
        # Look for "CR #<n>" in the prepared commit message.
        COMMIT_MSG_FILE="$(git rev-parse --git-path COMMIT_EDITMSG 2>/dev/null || echo .git/COMMIT_EDITMSG)"
        if [ -f "$COMMIT_MSG_FILE" ] && grep -qE '\(CR #[0-9]+\)' "$COMMIT_MSG_FILE"; then
            : # CR reference present, allow.
        else
            echo "[pre-commit] Edit to baselined artefact without referenced Change Request:" >&2
            echo "$BASELINED_HIT" | tr ' ' '\n' | sed '/^$/d' | sed 's/^/  /' >&2
            echo "" >&2
            echo "Open a CR issue with label 'change-request' (run /vse-cr) and reference" >&2
            echo "it as 'CR #<n>' in your commit message. Per §10.4.2 / §4.2 of the hooks" >&2
            echo "guide. To bypass for an authorised exception, use 'git commit --no-verify'" >&2
            echo "and record the rationale in the Correction Register (§10.5.2)." >&2
            exit 1
        fi
    fi
fi

# 4. Traceability integrity (delegated).
if [ -x "$HOOK_DIR/pre-commit-traceability.sh" ]; then
    "$HOOK_DIR/pre-commit-traceability.sh" || exit 1
elif [ -x "${CLAUDE_PLUGIN_ROOT:-}/hooks/pre-commit-traceability.sh" ]; then
    "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" || exit 1
fi

echo "[pre-commit] All checks passed."
exit 0
