#!/usr/bin/env bash
# SessionStart hook: detect VSE project (or a lighter SysML-only repo)
# and output lifecycle context.
# This script is called by Claude Code at the start of every session.
# stdout is injected into the conversation as context.
#
# Exit 0: always. stdout (if any) is injected into the conversation as context.
# Three detection modes, evaluated in order:
#   1. Contributor mode: wiki/CLAUDE.md present (vse-systems-engineering plugin repo)
#   2. Full VSE project: .vse-iteration.yml present
#   3. SysML-only repo: .sysml files reachable, but no .vse-iteration.yml
# When none match, the script exits 0 with no output.
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

# Shared SySiDE CLI reporter, called by both the full-VSE and the
# SysML-only branches below. Emits a single block describing CLI
# availability and the most useful invocations against $ENG_ROOT/models/.
# Silent if `syside` is not on $PATH.
report_syside_cli() {
    if command -v syside >/dev/null 2>&1; then
        local syside_ver
        syside_ver=$(syside --version 2>/dev/null | head -1 || echo "unknown")
        echo ""
        echo "SySiDE CLI available: $syside_ver"
        echo "  Validate models:  syside check --warnings-as-errors --stats"
        echo "  Check formatting: syside format --check"
        echo "  Generate diagrams: syside viz view $ENG_ROOT/models/ --output-dir $ENG_ROOT/build/diagrams"
    fi
}

# Detect whether the repository carries any SysML 2.0 models. Used by
# the SysML-only branch and by the full-VSE branch's trace-gap reporter.
# Cheap short-circuits first; bounded find as a fallback so a large
# repo does not pay a full-tree walk.
has_sysml_content() {
    [ -f "syside.toml" ] && return 0
    [ -f "engineering/syside.toml" ] && return 0
    [ -d "$ENG_ROOT/models" ] && return 0
    [ -n "$(find . -maxdepth 4 -name '*.sysml' -print -quit 2>/dev/null)" ] && return 0
    return 1
}

# Wiki freshness (contributor-facing). Only activates inside the
# vse-systems-engineering plugin repo itself, detected by the presence
# of wiki/CLAUDE.md. End-user projects that install the plugin never
# carry this file, so the block below stays silent for them. Runs
# before the VSE-project gate because the plugin repo is not a VSE
# project in its own right.
if [ -f "wiki/CLAUDE.md" ]; then
    echo "Wiki (contributor repo):"

    if [ -f "wiki/LOG.md" ]; then
        LAST_LOG_LINE=$(grep -oE '^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}\]' "wiki/LOG.md" | tail -1 || true)
        if [ -n "$LAST_LOG_LINE" ]; then
            LAST_LOG_DATE=$(echo "$LAST_LOG_LINE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
            LAST_EPOCH=$(date -d "$LAST_LOG_DATE" +%s 2>/dev/null || echo "")
            NOW_EPOCH=$(date +%s)
            if [ -n "$LAST_EPOCH" ]; then
                DAYS_SINCE=$(( (NOW_EPOCH - LAST_EPOCH) / 86400 ))
                echo "  Last LOG.md entry: ${LAST_LOG_DATE} (${DAYS_SINCE} days ago)."
            else
                echo "  Last LOG.md entry: ${LAST_LOG_DATE}."
            fi
        else
            echo "  LOG.md has no dated entries yet."
        fi

        UNRESOLVED=$(grep -cE '^## \[[0-9-]+\] source-added \|' "wiki/LOG.md" 2>/dev/null || true)
        INGESTED=$(grep -cE '^## \[[0-9-]+\] ingest \|' "wiki/LOG.md" 2>/dev/null || true)
        STUBS=$(( UNRESOLVED - INGESTED ))
        if [ "$STUBS" -lt 0 ]; then
            STUBS=0
        fi
        echo "  Unresolved source-added stubs: ${STUBS}."
    else
        echo "  LOG.md missing (wiki not initialised)."
    fi

    if [ -f "wiki/LINT_REPORT.md" ]; then
        ERRORS=$(grep -cE '^- .*ERROR' "wiki/LINT_REPORT.md" 2>/dev/null || true)
        WARNS=$(grep -cE '^- .*WARN' "wiki/LINT_REPORT.md" 2>/dev/null || true)
        echo "  Last /vse-wiki-lint report: ${ERRORS} ERROR, ${WARNS} WARN findings."
    else
        echo "  No /vse-wiki-lint report on disk. Run /vse-wiki-lint for a health check."
    fi
    echo ""
fi

# Mode 2: Full VSE project (.vse-iteration.yml present)
# ------------------------------------------------------------------
# When this gate fails, fall through to the SysML-only branch below.
if [ ! -f "$ITERATION_FILE" ]; then
    # Mode 3: SysML-only repository (no iteration state, but has SysML
    # content). Emits a lighter banner pointing at the SysML 2.0
    # specialist skills rather than the full VSE lens.
    #
    # Suppress this branch in the plugin contributor repo (detected by
    # wiki/CLAUDE.md). The plugin repo carries .sysml files under
    # templates/ and demo/ that would otherwise trip the SysML-only
    # detection, but the contributor's task is plugin development, not
    # SysML modelling.
    if [ ! -f "wiki/CLAUDE.md" ] && has_sysml_content; then
        echo "SysML 2.0 modelling repository detected"
        echo "======================================="
        echo ""
        echo "No .vse-iteration.yml found, so this is not a full VSE project"
        echo "under iteration management. The repository does carry SysML"
        echo "content, so the SysML 2.0 specialist skills are available"
        echo "directly:"
        echo ""
        echo "  @sysml2-modelling   Author and validate .sysml files"
        echo "                      (umbrella, routes to siblings below)"
        echo ""
        echo "Routed siblings (load on demand):"
        echo "  @sysml2-behaviour, @sysml2-cases, @sysml2-allocations,"
        echo "  @sysml2-variants, @sysml2-views, @sysml2-metadata,"
        echo "  @sysml2-model-structure, @sysml2-expressions"
        echo ""
        echo "All nine SysML 2.0 skills front-load atomic-page bundles from"
        echo "wiki/bundles/ at activation, so reference content is available"
        echo "without further setup."
        echo ""
        echo "To upgrade this repository to a full VSE project (ISO 29110"
        echo "process backbone, AMBSE iteration framing, traceability"
        echo "enforcement), run /vse-setup."
        report_syside_cli
    fi
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

report_syside_cli

exit 0
