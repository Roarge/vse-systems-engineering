#!/usr/bin/env bash
# PreCompact hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §5.7. Capture compliance
# state before context compaction so it is not lost from the rolling
# memory.
#
# Exit 0 always.
set -euo pipefail

# Skip silently outside a VSE project.
if [ ! -d "methodology" ] && [ ! -d "engineering/methodology" ]; then
    exit 0
fi

# Persist a snapshot of the current ISO state to a workspace file so
# post-compaction context can re-read it. Use the same layout as the
# session-start banner.
SNAPSHOT="/tmp/vse-iso-state-snapshot-$$.txt"

{
    echo "VSE PROJECT STATE SNAPSHOT"
    echo "=========================="
    echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    if [ -d "engineering/methodology" ]; then
        echo "Engineering root: engineering/"
    else
        echo "Engineering root: ."
    fi
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
