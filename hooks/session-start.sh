#!/usr/bin/env bash
# SessionStart hook: detect VSE project and output lifecycle context.
# This script is called by Claude Code at the start of every session.
# stdout is injected into the conversation as context.
#
# Exit 0: always. stdout (if any) is injected into the conversation as context.
# When no VSE project is detected, the script exits 0 with no output.
set -euo pipefail

ITERATION_FILE=".vse-iteration.yml"
JOURNAL_FILE=".vse-journal.yml"

# Detect VSE engineering root: prefer engineering/ if present (brownfield
# layout, where VSE work products live under engineering/ to keep an
# existing host project's root clean), else . (greenfield layout).
# .vse-iteration.yml and .vse-journal.yml always live at the project root
# in both layouts, so this detection only governs the model and document
# paths below.
if [ -d "engineering/models" ] || [ -f "engineering/syside.toml" ]; then
    ENG_ROOT="engineering"
else
    ENG_ROOT="."
fi

# Only activate if this is a VSE project (iteration state file exists)
if [ ! -f "$ITERATION_FILE" ]; then
    exit 0
fi

# Parse .vse-iteration.yml without requiring a YAML library. The shape is
# stable: top-level current_iteration block with number, mission, and
# centre_of_gravity fields. Same grep/sed technique used below for the
# journal date.
ITER_NUMBER=$(grep -m1 '^  number:' "$ITERATION_FILE" | sed 's/.*number:[[:space:]]*//' | tr -d '[:space:]')
ITER_MISSION=$(grep -m1 '^  mission:' "$ITERATION_FILE" | sed 's/.*mission:[[:space:]]*//' | sed 's/^"//' | sed 's/"$//')
ITER_STATUS=$(grep -m1 '^  status:' "$ITERATION_FILE" | sed 's/.*status:[[:space:]]*//' | tr -d '[:space:]')
ITER_COG=$(awk '
    /^  centre_of_gravity:/ { inside = 1; next }
    inside && /^  [A-Za-z]/ { inside = 0 }
    inside && /^    - / {
        line = $0
        sub(/^    - /, "", line)
        gsub(/"/, "", line)
        printf "%s%s", sep, line
        sep = ", "
    }
' "$ITERATION_FILE")

# Fallbacks for malformed or missing fields.
[ -z "$ITER_NUMBER" ]  && ITER_NUMBER="?"
[ -z "$ITER_MISSION" ] && ITER_MISSION="(mission not set)"
[ -z "$ITER_STATUS" ]  && ITER_STATUS="unknown"
[ -z "$ITER_COG" ]     && ITER_COG="(none)"

# =============================================================================
# Why this matters (do not strip the block below as cosmetic):
#
# The MANDATORY FIRST ACTION block that follows is load-bearing. It is the
# only mechanism in the plugin that guarantees `vse-companion-overview` is
# loaded into the model context before any other VSE skill runs. The lens
# skill carries the identity, source-processing order, phase-based filtering,
# traceability rules, and routing table that every VSE response depends on.
# Without this hook output, activation of the lens degrades to probabilistic
# skill matching on the user's first message, which is fragile and routinely
# misfires when the user opens with a narrow technical question.
#
# Future maintainers must not remove or "clean up" the echo lines below.
# They look like banner noise but they are the activation cue. If the
# wording needs revision, preserve the imperative framing and the explicit
# instruction to invoke the lens via the Skill tool before responding.
# =============================================================================
echo "VSE SYSTEMS ENGINEERING PROJECT DETECTED"
echo "========================================="
echo ""
echo "MANDATORY FIRST ACTION:"
echo "Before responding to the user, invoke the vse-companion-overview skill"
echo "via the Skill tool. This skill sets the lens (identity, source-processing"
echo "order, iteration-centred routing, traceability rules, AMBSE cycle framing,"
echo "and routing) that every VSE project response must apply. Do not skip"
echo "this even for trivial questions, and do not restate the lens content"
echo "in your reply, just load it and apply it."
echo ""
echo "Iteration:         iter-${ITER_NUMBER} - ${ITER_MISSION}"
echo "Status:            ${ITER_STATUS}"
echo "Centre of gravity: ${ITER_COG}"
echo ""
echo "This project uses the vse-systems-engineering plugin."
echo "After loading vse-companion-overview, route iteration work to"
echo "iteration-orchestrator and the other specialised skills it indexes."

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
