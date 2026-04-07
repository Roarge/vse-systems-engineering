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

# Detect VSE engineering root: prefer engineering/ if present (brownfield
# layout, where VSE work products live under engineering/ to keep an
# existing host project's root clean), else . (greenfield layout).
# .vse-phase and .vse-journal.yml always live at the project root in
# both layouts, so this detection only governs the model and document
# paths below.
if [ -d "engineering/models" ] || [ -f "engineering/syside.toml" ]; then
    ENG_ROOT="engineering"
else
    ENG_ROOT="."
fi

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
echo ""
echo "MANDATORY FIRST ACTION:"
echo "Before responding to the user, invoke the vse-companion-overview skill"
echo "via the Skill tool. This skill sets the lens (identity, source-processing"
echo "order, phase-based filtering, traceability rules, ISO 29110 process map,"
echo "and routing) that every VSE project response must apply. Do not skip"
echo "this even for trivial questions, and do not restate the lens content"
echo "in your reply, just load it and apply it."
echo ""
echo "Current phase: $PHASE ($PHASE_NAME)"
echo ""
echo "This project uses the vse-systems-engineering plugin."
echo "After loading vse-companion-overview, route phase-specific work to"
echo "lifecycle-orchestrator and the other specialised skills it indexes."

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
if [ -d "$ENG_ROOT/models" ]; then
    REQ_COUNT=$(grep -rl 'requirement def' "$ENG_ROOT"/models/*.sysml 2>/dev/null | wc -l || echo "0")
    VER_COUNT=$(grep -rl 'verification def' "$ENG_ROOT"/models/*.sysml 2>/dev/null | wc -l || echo "0")
    if [ "$REQ_COUNT" -gt 0 ] || [ "$VER_COUNT" -gt 0 ]; then
        echo ""
        echo "SysML models present in $ENG_ROOT/models/: $REQ_COUNT file(s) with requirements, $VER_COUNT file(s) with verification cases."
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
    echo "  Generate diagrams: syside viz view $ENG_ROOT/models/ --output-dir $ENG_ROOT/build/diagrams"
fi

exit 0
