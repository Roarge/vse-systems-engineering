#!/usr/bin/env bash
# Project-side traceability gate, delegated by the pre-commit hook.
#
# Per methodology/iso-29110-hooks-guide.md §4.1 concern 4. Checks the
# requirements and verification cases this commit actually touches, and
# reports the ones that carry no verify link anywhere in the model.
#
# The gate is deliberately scoped to touched content. A commit that
# edits a file whose pre-existing requirements were never verified is
# not the commit that introduced the gap, and stopping it teaches the
# engineer to reach for a bypass. /vse-trace reports the whole model.
#
# The disposition comes from the precommit_traceability gate, per
# methodology §0.10.4: block reports and stops the commit, warn reports
# and lets it through, info prints one summary line, off skips.
#
# Install as <project>/.githooks/pre-commit-traceability.sh.
set -euo pipefail

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
    # is the standard-profile disposition for this gate.
    iso_gate_disposition() { printf 'warn\n'; }
fi

DISPOSITION="$(iso_gate_disposition precommit_traceability)"
if [ "$DISPOSITION" = "off" ]; then
    exit 0
fi

STAGED_SYSML=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sysml$' || true)
if [ -z "$STAGED_SYSML" ]; then
    exit 0
fi

ADDED_SYSML=$(git diff --cached --name-only --diff-filter=A | grep '\.sysml$' || true)

# Detect the VSE engineering root: prefer engineering/ if present
# (brownfield layout, where work products live under engineering/ to
# keep an existing host project's root clean), else . (greenfield). The
# repo-wide search below uses 'find .', which covers both layouts. The
# detected root is reported so the engineer can confirm the layout.
if [ -d "engineering/models" ] || [ -f "engineering/syside.toml" ]; then
    ENG_ROOT="engineering"
else
    ENG_ROOT="."
fi

# Names this commit touches, as tab-separated "<file>\t<name>" records.
# For a modified file only the names on added lines count, which is
# what keeps the gate off pre-existing content. For a newly added file
# every name in it counts.
collect_touched() {
    local pattern="$1" file added names
    for file in $STAGED_SYSML; do
        added=$(git diff --cached -U0 -- "$file" | grep '^+' | grep -v '^+++' | cut -c2- || true)
        names=$(printf '%s\n' "$added" | grep -oP "$pattern" || true)
        for name in $names; do
            printf '%s\t%s\n' "$file" "$name"
        done
    done
    for file in $ADDED_SYSML; do
        names=$(grep -oP "$pattern" "$file" 2>/dev/null || true)
        for name in $names; do
            printf '%s\t%s\n' "$file" "$name"
        done
    done
}

TOUCHED_REQS=$(collect_touched 'requirement\s+def\s+\K\w+' | sort -u)
TOUCHED_VERS=$(collect_touched 'verification\s+def\s+\K\w+' | sort -u)

# Does any .sysml file in the repository carry a verify link to $1?
has_verify_link() {
    local req="$1" sysml
    while IFS= read -r -d '' sysml; do
        if grep -qP "verify\s+requirement\s+.*\b${req}\b" "$sysml" 2>/dev/null; then
            return 0
        fi
    done < <(find . -name '*.sysml' -not -path './.git/*' -print0 2>/dev/null)
    return 1
}

FINDINGS=""
GAPS=0
CHECKED=0

while IFS=$'\t' read -r file req; do
    [ -z "${req:-}" ] && continue
    CHECKED=$((CHECKED + 1))
    if ! has_verify_link "$req"; then
        FINDINGS="${FINDINGS}  ${file}: requirement '${req}' has no verification case"$'\n'
        GAPS=$((GAPS + 1))
    fi
done <<< "$TOUCHED_REQS"

while IFS=$'\t' read -r file ver; do
    [ -z "${ver:-}" ] && continue
    CHECKED=$((CHECKED + 1))
    if ! grep -qP "verify\s+requirement\s+" "$file" 2>/dev/null; then
        FINDINGS="${FINDINGS}  ${file}: verification case '${ver}' has no verify link"$'\n'
        GAPS=$((GAPS + 1))
    fi
done <<< "$TOUCHED_VERS"

if [ "$GAPS" -eq 0 ]; then
    if [ "$DISPOSITION" != "info" ] && [ "$CHECKED" -gt 0 ]; then
        echo "pre-commit-traceability: ${CHECKED} touched element(s) checked, no trace gaps (engineering root: ${ENG_ROOT})."
    fi
    exit 0
fi

if [ "$DISPOSITION" = "info" ]; then
    echo "pre-commit-traceability: ${GAPS} trace gap(s) on touched requirements. Run /vse-trace for the full-repo report."
    exit 0
fi

if [ "$DISPOSITION" = "block" ]; then
    echo "pre-commit-traceability: ${GAPS} trace gap(s) on touched requirements (engineering root: ${ENG_ROOT})."
else
    echo "pre-commit-traceability: warning: ${GAPS} trace gap(s) on touched requirements (engineering root: ${ENG_ROOT})."
fi
printf '%s' "$FINDINGS"
echo "  Run /vse-trace for the full-repo traceability report."

if [ "$DISPOSITION" = "block" ]; then
    echo "  To proceed anyway, record a one-line rationale per methodology §0.10.6."
    exit 1
fi

exit 0
