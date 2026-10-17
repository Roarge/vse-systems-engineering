#!/usr/bin/env bash
# PreCompact hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §5.7. Capture compliance
# state before context compaction so it is not lost from the rolling
# memory.
#
# The project is located from the working directory as SessionStart
# locates it (hooks/README.md section 1): through its .iso-config.yaml,
# the canonical project marker, with vse_tf_locate_workdir, else by a
# methodology/ or engineering/methodology/ folder, the fallback for
# projects that predate the configuration and for an install without
# hooks/lib/. Outside a project the hook is silent.
#
# Exit 0 always.
set -euo pipefail

PC_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib"
PC_CWD="$(pwd -P)"
PC_ENG=""
if [ -r "${PC_LIB}/iso-profile.sh" ] && [ -r "${PC_LIB}/test-first.sh" ]; then
    # shellcheck source=/dev/null
    . "${PC_LIB}/iso-profile.sh"
    # shellcheck source=/dev/null
    . "${PC_LIB}/test-first.sh"
    if vse_tf_locate_workdir "$PC_CWD"; then
        PC_ENG="$VSE_TF_ENG_ROOT"
    fi
fi
if [ -z "$PC_ENG" ]; then
    if [ -d "engineering/methodology" ]; then
        PC_ENG="${PC_CWD}/engineering"
    elif [ -d "methodology" ]; then
        PC_ENG="$PC_CWD"
    fi
fi

# Skip silently outside a VSE project.
if [ -z "$PC_ENG" ]; then
    exit 0
fi

# The engineering root, relative to the working directory when it is
# the working directory or below it, else in full.
case "$PC_ENG" in
    "$PC_CWD") PC_ENG_SHOWN="." ;;
    "$PC_CWD"/*) PC_ENG_SHOWN="${PC_ENG#"$PC_CWD"/}/" ;;
    *) PC_ENG_SHOWN="${PC_ENG%/}/" ;;
esac

# Persist a snapshot of the current ISO state to a workspace file
# the engineer can inspect after compaction. Same shape as the
# session-start banner. The file is informational; nothing reads it
# back automatically.
SNAPSHOT=$(mktemp -t vse-iso-state-XXXXXX.txt 2>/dev/null || mktemp 2>/dev/null) || {
    # mktemp unavailable; fall back to a deterministic location.
    SNAPSHOT="/tmp/vse-iso-state-snapshot.txt"
}

{
    echo "VSE PROJECT STATE SNAPSHOT"
    echo "=========================="
    echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "Engineering root: ${PC_ENG_SHOWN}"
    echo "Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
    echo "Last plan baseline: $(git tag --list 'plan-baseline-*' --sort=-v:refname 2>/dev/null | head -1)"
    echo "Last release: $(git tag --list 'release-*' --sort=-v:refname 2>/dev/null | head -1)"
    if command -v gh >/dev/null 2>&1; then
        OPEN=$(gh issue list -l change-request -s open --json number 2>/dev/null | grep -c '"number"' || echo "0")
        echo "Open Change Requests: ${OPEN}"
    fi
} > "$SNAPSHOT" 2>/dev/null

echo "[VSE state snapshot saved to ${SNAPSHOT}]"

exit 0
