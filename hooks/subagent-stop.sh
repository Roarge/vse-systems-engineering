#!/usr/bin/env bash
# SubagentStop hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §5.6. When using subagents
# for parallel work, aggregate compliance check results from each
# subagent.
#
# This hook is intentionally minimal in v2. It echoes a marker so the
# orchestrating session can see that a subagent completed within a VSE
# project context, and surfaces the project's current state path as a
# reminder of where to write any compliance findings.
#
# Exit 0 always.
set -euo pipefail

# Skip silently outside a VSE project.
if [ ! -d "methodology" ] && [ ! -d "engineering/methodology" ]; then
    exit 0
fi

echo "[subagent complete in VSE project context. Methodology spec at $(test -d methodology && echo methodology/ || echo engineering/methodology/).]"

exit 0
