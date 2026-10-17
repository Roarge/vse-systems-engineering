#!/usr/bin/env bash
# SubagentStop hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §5.6. Runs when a subagent
# ends its turn. It follows the Stop contract of §5.5, so it runs
# stop.sh for the SubagentStop event: silent while stop_hook_active is
# true, a one-line completion note for the user as a systemMessage, and
# the test-first finding as additionalContext, each once for each
# session and state of the working tree. It keeps a marker of its own
# (vse-subagent-stop.<session_id>), so a subagent never uses up what
# the main agent is told at Stop. stop.sh documents the rest.
#
# Output contract. Claude never sees plain stdout at SubagentStop, so
# stop.sh prints exactly one JSON object, or nothing.
#
# stdin: the SubagentStop JSON payload, passed on to stop.sh.
# stdout: one JSON object, or nothing.
set -euo pipefail

exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/stop.sh" SubagentStop
