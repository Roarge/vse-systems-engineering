#!/usr/bin/env bash
# SessionStart hook: detect VSE project and output lifecycle context.
# This script is called by Claude Code at the start of every session.
# stdout is injected into the conversation as context.
#
# Exit 0: always. stdout (if any) is injected into the conversation as context.
# When no VSE project is detected, the script exits 0 with no output.
set -euo pipefail

PHASE_FILE=".vse-phase"
JOURNAL_FILE=".vse-journal.yml"

# Only activate if this is a VSE project (phase file exists)
if [ ! -f "$PHASE_FILE" ]; then
    exit 0
fi

PHASE=$(tr -d '[:space:]' < "$PHASE_FILE")

# Map phase codes to human-readable names
case "$PHASE" in
    PM.1) PHASE_NAME="Project Planning" ;;
    PM.2) PHASE_NAME="Plan Execution" ;;
    PM.3) PHASE_NAME="Assessment and Control" ;;
    PM.4) PHASE_NAME="Closure" ;;
    SR.1) PHASE_NAME="Initiation" ;;
    SR.2) PHASE_NAME="Requirements" ;;
    SR.3) PHASE_NAME="Architecture" ;;
    SR.4) PHASE_NAME="Construction" ;;
    SR.5) PHASE_NAME="Integration, Verification and Validation" ;;
    SR.6) PHASE_NAME="Delivery" ;;
    *)    PHASE_NAME="Unknown" ;;
esac

echo "VSE SYSTEMS ENGINEERING PROJECT DETECTED"
echo "========================================="
echo "Current phase: $PHASE ($PHASE_NAME)"
echo ""
echo "This project uses the vse-systems-engineering plugin."
echo "Use @lifecycle-orchestrator to navigate the lifecycle and check phase gates."

# Check for session journal
if [ -f "$JOURNAL_FILE" ]; then
    # Extract last session date if available (simple grep, no YAML parser needed)
    LAST_DATE=$(grep -m1 'date:' "$JOURNAL_FILE" 2>/dev/null | sed 's/.*date:\s*"\?\([^"]*\)"\?.*/\1/' || true)
    if [ -n "$LAST_DATE" ]; then
        echo ""
        echo "Session journal found. Last session: $LAST_DATE"
        echo "Use @session-journal to review previous session context."
    fi
fi

# Check for trace gaps in models
if [ -d "models" ]; then
    REQ_COUNT=$(grep -rl 'requirement def' models/*.sysml 2>/dev/null | wc -l || echo "0")
    VER_COUNT=$(grep -rl 'verification def' models/*.sysml 2>/dev/null | wc -l || echo "0")
    if [ "$REQ_COUNT" -gt 0 ] || [ "$VER_COUNT" -gt 0 ]; then
        echo ""
        echo "SysML models present: $REQ_COUNT file(s) with requirements, $VER_COUNT file(s) with verification cases."
        echo "Use @traceability-guard to check trace completeness."
    fi
fi

# Report SySiDE CLI availability
if command -v syside >/dev/null 2>&1; then
    SYSIDE_VER=$(syside --version 2>/dev/null | head -1 || echo "unknown")
    echo ""
    echo "SySiDE CLI available: $SYSIDE_VER"
    echo "  Validate models:  syside check --warnings-as-errors --stats"
    echo "  Check formatting: syside format --check"
    echo "  Generate diagrams: syside viz view models/ --output-dir build/diagrams"
fi

exit 0
