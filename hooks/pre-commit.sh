#!/usr/bin/env bash
# Project-side git pre-commit hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §4.1. Three concerns:
#   1. SysML lint on staged .sysml files (delegated to syside if available).
#   2. Story well-formedness (§1.9), full lint in tools/lint/.
#   3. Traceability integrity, delegates to pre-commit-traceability.sh.
#
# Baselined-artefact protection lives in the commit-msg hook, where the
# pending message is reliably available. The pre-commit baseline check
# in v1.x read .git/COMMIT_EDITMSG, which carries the previous commit's
# message at this stage, not the message about to be authored. The
# commit-msg hook is the right gate.
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
# Use NUL-delimited output to handle filenames with spaces.
if command -v syside >/dev/null 2>&1; then
    if ! git diff --cached --name-only --diff-filter=ACM -z \
            | tr '\0' '\n' \
            | grep -E '\.sysml$' \
            | xargs -d '\n' -r syside check --warnings-as-errors 2>&1; then
        echo "[pre-commit] SysML lint failed. Fix syntax errors before committing." >&2
        exit 1
    fi
fi

# 2. Story well-formedness check.
# In v2.0-rc, this is a stub that succeeds if the lint script is absent.
if [ -x "tools/lint/story-wellformed.py" ]; then
    STAGED_STORIES=$(git diff --cached --name-only --diff-filter=ACM -z \
                        | tr '\0' '\n' \
                        | grep -E '/stories/.*\.sysml$' || true)
    if [ -n "$STAGED_STORIES" ]; then
        if ! echo "$STAGED_STORIES" | xargs -d '\n' -r python3 tools/lint/story-wellformed.py; then
            echo "[pre-commit] Story well-formedness failed (§1.9). Fix and re-stage." >&2
            exit 1
        fi
    fi
fi

# 3. Traceability integrity (delegated).
if [ -x "$HOOK_DIR/pre-commit-traceability.sh" ]; then
    "$HOOK_DIR/pre-commit-traceability.sh" || exit 1
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -x "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" ]; then
    "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" || exit 1
fi

# Baselined-artefact awareness (advisory only, see header).
ISO_CONFIG=""
if [ -f ".iso-config.yaml" ]; then
    ISO_CONFIG=".iso-config.yaml"
elif [ -f "engineering/.iso-config.yaml" ]; then
    ISO_CONFIG="engineering/.iso-config.yaml"
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
        echo "[pre-commit] Note: this commit modifies baselined artefacts:" >&2
        printf '%s' "$BASELINED_HIT" | sed 's/^/  /' >&2
        echo "  Per §10.4.2 / §4.2 of the hooks guide, the commit message" >&2
        echo "  shall reference an open Change Request as 'CR #<n>'." >&2
        echo "  The commit-msg hook enforces this." >&2
    fi
fi

echo "[pre-commit] All checks passed."
exit 0
