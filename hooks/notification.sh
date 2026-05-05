#!/usr/bin/env bash
# Notification hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §5.8. Periodic compliance
# reminders (overdue risks, stale Change Requests). Unobtrusive. Does
# not gate work.
#
# Exit 0 always.
set -euo pipefail

# Skip silently outside a VSE project.
if [ ! -d "methodology" ] && [ ! -d "engineering/methodology" ]; then
    exit 0
fi

# Locate iso-config.yaml for stale-risk threshold.
ISO_CONFIG=""
if [ -f ".iso-config.yaml" ]; then
    ISO_CONFIG=".iso-config.yaml"
elif [ -f "engineering/.iso-config.yaml" ]; then
    ISO_CONFIG="engineering/.iso-config.yaml"
fi

# Stale Change Requests (open longer than 14 days) via gh CLI.
if command -v gh >/dev/null 2>&1; then
    STALE_CRS=$(gh issue list -l change-request -s open --json number,createdAt 2>/dev/null \
        | jq -r --arg threshold "$(date -u -d '14 days ago' +%Y-%m-%dT%H:%M:%SZ)" \
            '[.[] | select(.createdAt < $threshold)] | length' 2>/dev/null || echo "0")
    if [ "$STALE_CRS" -gt 0 ]; then
        echo "[VSE notification] ${STALE_CRS} Change Request(s) open >14 days. Run /vse-cr to review."
    fi
fi

exit 0
