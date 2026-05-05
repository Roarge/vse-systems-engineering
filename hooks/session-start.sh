#!/usr/bin/env bash
# SessionStart hook for vse-systems-engineering plugin v2.x.
#
# Three detection modes, evaluated in order:
#   1. Contributor mode: wiki/CLAUDE.md present (plugin development repo).
#   2. VSE project: <root>/methodology/ present, or
#                   <root>/engineering/methodology/ present (brownfield).
#   3. SysML-only repo: .sysml content present, no methodology/ folder.
#
# When none match, exits 0 with no output.
#
# stdout is injected into the conversation as context.
# Exit 0 always. The hook is advisory.
set -euo pipefail

# Detect VSE engineering root: prefer engineering/methodology if present
# (brownfield default per project-setup), then methodology at the repo
# root (greenfield default), then no methodology found.
if [ -d "engineering/methodology" ]; then
    ENG_ROOT="engineering"
elif [ -d "methodology" ]; then
    ENG_ROOT="."
else
    ENG_ROOT=""
fi

# Cheap SysML content detection for the SysML-only fallback.
has_sysml_content() {
    [ -f "syside.toml" ] && return 0
    [ -f "engineering/syside.toml" ] && return 0
    [ -d "engineering/model" ] && return 0
    [ -d "model" ] && return 0
    [ -n "$(find . -maxdepth 4 -name '*.sysml' -print -quit 2>/dev/null)" ] && return 0
    return 1
}

# Mode 1: Plugin contributor repo. Emits wiki freshness lines that the
# plugin contributor reads as a nudge before deciding the next action.
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
    exit 0
fi

# Mode 3: SysML-only repository (no methodology/ folder).
if [ -z "$ENG_ROOT" ]; then
    if has_sysml_content; then
        echo "SysML 2.0 modelling repository detected"
        echo "======================================="
        echo ""
        echo "No methodology/ folder found, so this is not a full VSE project"
        echo "under the story-driven AMBSE methodology. The repository does"
        echo "carry SysML content, so the SysML 2.0 specialist skills are"
        echo "available directly:"
        echo ""
        echo "  @sysml2-modelling   Author and validate .sysml files"
        echo "                      (umbrella, routes to siblings below)"
        echo ""
        echo "Routed siblings (load on demand):"
        echo "  @sysml2-behaviour, @sysml2-cases, @sysml2-allocations,"
        echo "  @sysml2-variants, @sysml2-views, @sysml2-metadata,"
        echo "  @sysml2-model-structure, @sysml2-expressions,"
        echo "  @sysml2-extension"
        echo ""
        echo "To upgrade this repository to a full VSE project (methodology"
        echo "spec, ISO 29110 process backbone, story-driven workflow,"
        echo "traceability enforcement), run /vse-setup."
    fi
    exit 0
fi

# Mode 2: VSE project.
echo "VSE SYSTEMS ENGINEERING PROJECT DETECTED"
echo "========================================="
echo ""
echo "MANDATORY FIRST ACTION:"
echo "Before responding to the user, invoke the vse-companion-overview skill"
echo "via the Skill tool. This skill sets the methodology lens (identity,"
echo "story-centric routing, the methodology-as-source-of-truth convention,"
echo "the §2.6 rule 7 reverse-engineering guard, and drift indicators) that"
echo "every VSE project response must apply."
echo ""
echo "Methodology copy: ${ENG_ROOT}/methodology/ (project-local, authoritative)"

# Story state.
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(no git)")
echo "Branch:           ${CURRENT_BRANCH}"

# In-flight stories: count story branches and surface the active one.
if command -v git >/dev/null 2>&1 && [ -d ".git" ]; then
    STORY_BRANCHES=$(git for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null | grep -c '^story/' || echo "0")
    if [ "$STORY_BRANCHES" -gt 0 ]; then
        echo "In-flight story branches: ${STORY_BRANCHES}"
    fi

    # Most recent plan-baseline tag.
    PLAN_BASELINE=$(git tag --list 'plan-baseline-*' --sort=-v:refname 2>/dev/null | head -1)
    if [ -n "$PLAN_BASELINE" ]; then
        echo "Plan baseline:    ${PLAN_BASELINE}"
    else
        echo "Plan baseline:    (none yet; run /vse-plan to author)"
    fi

    # Most recent release tag.
    LAST_RELEASE=$(git tag --list 'release-*' --sort=-v:refname 2>/dev/null | head -1)
    if [ -n "$LAST_RELEASE" ]; then
        echo "Last release:     ${LAST_RELEASE}"
    fi
fi

# Pending change requests via gh CLI if configured.
if command -v gh >/dev/null 2>&1; then
    OPEN_CRS=$(gh issue list -l change-request -s open --json number 2>/dev/null | grep -c '"number"' || echo "0")
    if [ "$OPEN_CRS" -gt 0 ]; then
        echo "Open Change Requests: ${OPEN_CRS} (run /vse-cr to manage)"
    fi
fi

echo ""
echo "Reminders (per methodology/iso-29110-hooks-guide.md §5.1):"
echo "- Edits to baselined artefacts require an open Change Request (PM.O3)."
echo "- New stories shall declare role, capability, benefit, and at least"
echo "  one acceptance criterion (§1.9)."
echo "- After modifying a story, update its bound verification case (SR.O7)."
echo "- Stories build forward from the Base Architecture (§2.1). Do NOT"
echo "  reverse-engineer or auto-generate stakeholders, concerns, or"
echo "  stories that explain Base Architecture decisions; create context"
echo "  stories only on explicit user request, with confirmation of intent"
echo "  (§2.6 rule 7)."

exit 0
