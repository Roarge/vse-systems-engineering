#!/usr/bin/env bash
# Project-side git pre-commit hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §4.1. Three concerns:
#   1. precommit_lint: SysML lint on staged .sysml files (delegated to
#      syside if available).
#   2. precommit_story_wellformed: story well-formedness (§1.9), full
#      lint in tools/lint/.
#   3. precommit_traceability: traceability integrity, delegated to
#      pre-commit-traceability.sh.
#
# Each concern carries a disposition drawn from the project rigour
# profile and any per-gate override, per methodology §0.10.4. block
# reports and stops the commit, warn reports and lets it through, info
# prints one summary line, off skips the gate.
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
set -euo pipefail

HOOK_DIR="$(dirname "$0")"
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Load the shared profile helpers. The project-side copy wins, the
# plugin copy is the fallback for a partial install.
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
    # is the standard-profile disposition for both local gates.
    iso_gate_disposition() { printf 'warn\n'; }
fi

WARNINGS=0

# 1. SysML lint via syside if available.
# Use NUL-delimited output to handle filenames with spaces.
LINT_DISPOSITION="$(iso_gate_disposition precommit_lint)"
if [ "$LINT_DISPOSITION" != "off" ] && command -v syside >/dev/null 2>&1; then
    LINT_OUTPUT=""
    if ! LINT_OUTPUT=$(git diff --cached --name-only --diff-filter=ACM -z \
            | tr '\0' '\n' \
            | grep -E '\.sysml$' \
            | xargs -d '\n' -r syside check --warnings-as-errors 2>&1); then
        case "$LINT_DISPOSITION" in
            block)
                printf '%s\n' "$LINT_OUTPUT" >&2
                echo "[pre-commit] SysML lint failed. Fix the syntax errors before committing." >&2
                echo "[pre-commit] To proceed anyway, record a one-line rationale per methodology §0.10.6." >&2
                exit 1
                ;;
            warn)
                printf '%s\n' "$LINT_OUTPUT" >&2
                echo "[pre-commit] warning: SysML lint reported findings on the staged model files." >&2
                WARNINGS=$((WARNINGS + 1))
                ;;
            info)
                echo "[pre-commit] SysML lint reported findings on the staged model files." >&2
                ;;
        esac
    fi
fi

# 2. Story well-formedness check.
# The shipped hook is a stub that succeeds when the lint script is absent.
STORY_DISPOSITION="$(iso_gate_disposition precommit_story_wellformed)"
if [ "$STORY_DISPOSITION" != "off" ] && [ -x "tools/lint/story-wellformed.py" ]; then
    STAGED_STORIES=$(git diff --cached --name-only --diff-filter=ACM -z \
                        | tr '\0' '\n' \
                        | grep -E '/stories/.*\.sysml$' || true)
    if [ -n "$STAGED_STORIES" ]; then
        STORY_OUTPUT=""
        if ! STORY_OUTPUT=$(echo "$STAGED_STORIES" | xargs -d '\n' -r python3 tools/lint/story-wellformed.py 2>&1); then
            case "$STORY_DISPOSITION" in
                block)
                    printf '%s\n' "$STORY_OUTPUT" >&2
                    echo "[pre-commit] Story well-formedness failed (§1.9). Fix and re-stage." >&2
                    echo "[pre-commit] To proceed anyway, record a one-line rationale per methodology §0.10.6." >&2
                    exit 1
                    ;;
                warn)
                    printf '%s\n' "$STORY_OUTPUT" >&2
                    echo "[pre-commit] warning: story well-formedness findings (§1.9)." >&2
                    WARNINGS=$((WARNINGS + 1))
                    ;;
                info)
                    echo "[pre-commit] Story well-formedness findings on the staged story files (§1.9)." >&2
                    ;;
            esac
        fi
    fi
fi

# 3. Traceability integrity (delegated). The delegate reads its own
# disposition from precommit_traceability.
TRACE_OUT=""
if [ -x "$HOOK_DIR/pre-commit-traceability.sh" ]; then
    TRACE_OUT=$("$HOOK_DIR/pre-commit-traceability.sh" 2>&1) || { printf '%s\n' "$TRACE_OUT"; exit 1; }
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -x "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" ]; then
    TRACE_OUT=$("${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" 2>&1) || { printf '%s\n' "$TRACE_OUT"; exit 1; }
fi
if [ -n "$TRACE_OUT" ]; then
    printf '%s\n' "$TRACE_OUT"
    # The delegate reports its own findings. Count its warnings so the
    # summary line below cannot contradict what was just printed.
    if printf '%s' "$TRACE_OUT" | grep -q 'warning:'; then
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# Baselined-artefact awareness (advisory only, see header). Skipped
# when baselined_paths is empty, which is the light-profile default
# per methodology §0.10.3, so the Change Request machinery stays
# dormant until the project baselines something.
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
    if [ -n "$BASELINED" ]; then
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
    fi
    if [ -n "$BASELINED_HIT" ]; then
        echo "[pre-commit] Note: this commit modifies baselined artefacts:" >&2
        printf '%s' "$BASELINED_HIT" | sed 's/^/  /' >&2
        echo "  Per methodology §10.4.2, the commit message shall reference an" >&2
        echo "  open Change Request as 'CR #<n>'. The commit-msg hook checks it" >&2
        echo "  at the disposition your profile sets (§0.10.4)." >&2
    fi
fi

if [ "$WARNINGS" -gt 0 ]; then
    echo "[pre-commit] Checks complete with ${WARNINGS} warning(s)."
else
    echo "[pre-commit] All checks passed."
fi
exit 0
