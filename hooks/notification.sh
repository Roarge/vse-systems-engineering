#!/usr/bin/env bash
# Notification hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §5.8. Periodic compliance
# reminders (overdue risks, stale Change Requests). Unobtrusive. Does
# not gate work.
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

NOTE_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib"
NOTE_PROJECT=""
if [ -r "${NOTE_LIB}/iso-profile.sh" ] && [ -r "${NOTE_LIB}/test-first.sh" ]; then
    # shellcheck source=/dev/null
    . "${NOTE_LIB}/iso-profile.sh"
    # shellcheck source=/dev/null
    . "${NOTE_LIB}/test-first.sh"
    if vse_tf_locate_workdir "$(pwd -P)"; then
        NOTE_PROJECT=1
    fi
fi

# Skip silently outside a VSE project.
if [ -z "$NOTE_PROJECT" ] && [ ! -d "methodology" ] && [ ! -d "engineering/methodology" ]; then
    exit 0
fi

# Stale Change Requests (open longer than 14 days) via gh CLI.
# A future revision will read the threshold from .iso-config.yaml's
# change_request.stale_threshold_days field.
if command -v gh >/dev/null 2>&1; then
    STALE_CRS=$(gh issue list -l change-request -s open --json number,createdAt 2>/dev/null \
        | jq -r --arg threshold "$(date -u -d '14 days ago' +%Y-%m-%dT%H:%M:%SZ)" \
            '[.[] | select(.createdAt < $threshold)] | length' 2>/dev/null || echo "0")
    if [ "$STALE_CRS" -gt 0 ]; then
        echo "[VSE notification] ${STALE_CRS} Change Request(s) open >14 days. Run /vse-cr to review."
    fi
fi

exit 0
