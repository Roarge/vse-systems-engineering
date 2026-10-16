#!/usr/bin/env bash
# SessionStart hook for the vse-systems-engineering plugin.
#
# Three detection modes. The numbers name the modes, and the code
# evaluates them in this order:
#   1. Contributor mode: wiki/CLAUDE.md present (plugin development repo).
#   3. SysML-only repo: no methodology/ folder, .sysml content present.
#   2. VSE project: <root>/methodology/ present, or
#                   <root>/engineering/methodology/ present (brownfield).
#
# When none match, exits 0 with no output.
#
# Mode 2 also states the behaviour-first and test-first policy of
# methodology section 11: a Behaviour-first line, a Test-first line that
# names the recorded test_first.applies value, a nudge when test tooling
# is found while that value is false or unrecorded, and a warning when
# jq is missing. Mode 1 prints one pointer to the plugin's own rules for
# the same discipline.
#
# Plain text on stdout is added to the conversation as context, which is
# the SessionStart output contract (hooks guide section 5), so this hook
# prints no JSON. The text stays printable ASCII. Exit 0 always. The
# hook is advisory.
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

# Cheap SysML content detection for the SysML-only fallback. The
# markers cover all three toolchains: Syside's project file, the
# editor wiring for Syside or OpenSysML, the recorded sysml_toolchain
# key, the model tree, or any .sysml file within four levels.
has_sysml_content() {
    local cfg
    if [ -f "syside.toml" ] || [ -f "engineering/syside.toml" ]; then
        return 0
    fi
    if [ -f ".lsp.json" ] && grep -qE '"(syside|sysml-lsp)"' ".lsp.json" 2>/dev/null; then
        return 0
    fi
    for cfg in ".iso-config.yaml" "engineering/.iso-config.yaml"; do
        if [ -f "$cfg" ] && grep -qE '^sysml_toolchain:' "$cfg" 2>/dev/null; then
            return 0
        fi
    done
    if [ -d "engineering/model" ] || [ -d "model" ]; then
        return 0
    fi
    if [ -n "$(find . -maxdepth 4 -name '*.sysml' -print -quit 2>/dev/null)" ]; then
        return 0
    fi
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
    if [ -r "wiki/LINT_REPORT.md" ]; then
        # Read the values from the report's own summary block, which is
        # written as "- ERROR: <n>" / "- WARN: <n>" by /vse-wiki-lint.
        # Counting matching lines instead would count the summary lines
        # themselves and announce findings on a clean report.
        ERRORS=$(sed -n 's/^- ERROR: \([0-9][0-9]*\)[[:space:]]*$/\1/p' "wiki/LINT_REPORT.md" 2>/dev/null | head -n 1 || true)
        WARNS=$(sed -n 's/^- WARN: \([0-9][0-9]*\)[[:space:]]*$/\1/p' "wiki/LINT_REPORT.md" 2>/dev/null | head -n 1 || true)
        LINT_GENERATED=$(sed -n 's/^Generated: \(.*\)$/\1/p' "wiki/LINT_REPORT.md" 2>/dev/null | head -n 1 || true)
        if [ -n "$ERRORS" ] && [ -n "$WARNS" ]; then
            echo "  Last /vse-wiki-lint report: ${ERRORS} ERROR, ${WARNS} WARN findings."
        else
            echo "  /vse-wiki-lint report present but has no readable summary block."
        fi
        if [ -n "$LINT_GENERATED" ]; then
            echo "  Report generated: ${LINT_GENERATED}."
        fi
    else
        echo "  No /vse-wiki-lint report on disk. Run /vse-wiki-lint for a health check."
    fi
    echo "Contributor rules: plugin work goes test first and Gherkin first, see .claude/rules/tdd-bdd.md."
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
        echo "spec, ISO/IEC 29110 process backbone, story-driven workflow,"
        echo "traceability enforcement), run /vse-setup."
        echo ""
        echo "Toolchain: run /vse-toolchain to choose and install a SysML v2 validator (Syside, OMG pilot, or OpenSysML)."
    fi
    exit 0
fi

# Mode 2: VSE project. Context lines, not instructions. The engineer
# decides what follows, per methodology section 0.10.1.

# Print the path of the shared library <name>, or nothing when no copy
# is readable. The copy beside this script is the primary source,
# because this hook runs from the plugin tree, and the plugin root is
# the fallback.
plugin_lib() {
    if [ -r "$(dirname "$0")/lib/$1" ]; then
        printf '%s\n' "$(dirname "$0")/lib/$1"
    elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -r "${CLAUDE_PLUGIN_ROOT}/hooks/lib/$1" ]; then
        printf '%s\n' "${CLAUDE_PLUGIN_ROOT}/hooks/lib/$1"
    fi
}

# The configuration in force is the project's own, in the working
# directory (else under engineering/, the same order iso-profile.sh
# searches). Left to itself, iso-profile.sh searches the git top level,
# which misses a project below it (demo/smart-sensor in the plugin
# repository, or a monorepo subproject), while the gates find the
# project's file by walking up from the edited file. A path the
# environment already names is kept.
if [ -z "${VSE_ISO_CONFIG:-}" ]; then
    if [ -f ".iso-config.yaml" ]; then
        VSE_ISO_CONFIG="$(pwd -P)/.iso-config.yaml"
        export VSE_ISO_CONFIG
    elif [ -f "engineering/.iso-config.yaml" ]; then
        VSE_ISO_CONFIG="$(pwd -P)/engineering/.iso-config.yaml"
        export VSE_ISO_CONFIG
    fi
fi

# Rigour profile via the shared library.
ISO_PROFILE_LIB="$(plugin_lib iso-profile.sh)"

if [ -n "$ISO_PROFILE_LIB" ]; then
    # shellcheck source=/dev/null
    . "$ISO_PROFILE_LIB"
    PROFILE="$(iso_profile)"
else
    PROFILE="standard"
fi

# Toolchain state via the shared library.
SYSML_TOOLCHAIN_LIB="$(plugin_lib sysml-toolchain.sh)"

# Test-first helpers. They read the test_first record through
# iso-profile.sh, so they load only when it did.
TEST_FIRST_LIB=""
if [ -n "$ISO_PROFILE_LIB" ]; then
    TEST_FIRST_LIB="$(plugin_lib test-first.sh)"
fi

if [ -n "$TEST_FIRST_LIB" ]; then
    # shellcheck source=/dev/null
    . "$TEST_FIRST_LIB"
fi

if [ -n "$SYSML_TOOLCHAIN_LIB" ]; then
    VSE_TC_PROBE_TIMEOUT="${VSE_TC_PROBE_TIMEOUT:-10}"
    export VSE_TC_PROBE_TIMEOUT
    # shellcheck source=/dev/null
    . "$SYSML_TOOLCHAIN_LIB"
fi

echo "VSE project (story-driven AMBSE, ISO/IEC 29110)."
echo "Methodology: ${ENG_ROOT}/methodology/ (project-local, authoritative)"
echo "Profile:     ${PROFILE} (per methodology section 0.10)"

if [ -n "$SYSML_TOOLCHAIN_LIB" ]; then
    vse_tc_status_line 2>/dev/null || echo "Toolchain:   (status unavailable)"
else
    echo "Toolchain:   (library missing, run /vse-toolchain)"
fi

# Story state.
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(no git)")
echo "Branch:      ${CURRENT_BRANCH}"

# In-flight stories: count story branches and surface the active one.
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    STORY_BRANCHES=$(git for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null | grep -c '^story/' || true)
    if [ -n "$STORY_BRANCHES" ] && [ "$STORY_BRANCHES" -gt 0 ]; then
        echo "In-flight story branches: ${STORY_BRANCHES}"
    fi

    # Most recent plan-baseline tag.
    PLAN_BASELINE=$(git tag --list 'plan-baseline-*' --sort=-v:refname 2>/dev/null | head -n 1)
    if [ -n "$PLAN_BASELINE" ]; then
        echo "Plan baseline: ${PLAN_BASELINE}"
    else
        echo "Plan baseline: (none yet, run /vse-plan to author)"
    fi

    # Most recent release tag.
    LAST_RELEASE=$(git tag --list 'release-*' --sort=-v:refname 2>/dev/null | head -n 1)
    if [ -n "$LAST_RELEASE" ]; then
        echo "Last release:  ${LAST_RELEASE}"
    fi
fi

# Pending change requests via gh CLI if configured.
if command -v gh >/dev/null 2>&1; then
    OPEN_CRS=$(gh issue list -l change-request -s open --json number 2>/dev/null | grep -c '"number"' || true)
    if [ -n "$OPEN_CRS" ] && [ "$OPEN_CRS" -gt 0 ]; then
        echo "Open Change Requests: ${OPEN_CRS} (run /vse-cr to manage)"
    fi
fi

# Behaviour first and test first, per methodology section 11. These are
# context lines. The PreToolUse and pre-commit gates enforce both.
echo "Behaviour-first: every story gets its Gherkin feature, Given/When/Then scenarios in <ID>.feature beside the story and tagged @<ID>, before design or code (methodology section 11)."

TF_APPLIES=""
if [ -n "$TEST_FIRST_LIB" ]; then
    TF_APPLIES="$(vse_tf_applies)"
    TF_SHOWN="${TF_APPLIES:-not recorded}"
else
    TF_SHOWN="unknown (test-first library missing)"
fi
TF_SKILL="If superpowers:test-driven-development is listed in your skills, use it, otherwise follow methodology section 11."
if [ "$TF_SHOWN" = "not recorded" ]; then
    echo "Test-first: test_first.applies is not recorded, run /vse-test-first to record the judgement. ${TF_SKILL}"
else
    echo "Test-first: test_first.applies is ${TF_SHOWN}. ${TF_SKILL}"
fi

# Test tooling in the project while the record says no, or says
# nothing, suggests the judgement is missing or out of date.
if [ -n "$TEST_FIRST_LIB" ] && [ "$TF_APPLIES" != "true" ]; then
    TF_TOOLS="$(vse_tf_detect . 2>/dev/null | awk 'NR > 1 { printf ", " } { printf "%s", $0 }' || true)"
    if [ -n "$TF_TOOLS" ]; then
        echo "Test-first nudge: test tooling found (${TF_TOOLS}) while test_first.applies is ${TF_SHOWN}. Record or revisit the judgement with /vse-test-first (methodology section 11.5)."
    fi
fi

# The in-session gates read the tool payload with jq, fall back to
# python3, and let the edit through when neither is present.
if ! command -v jq >/dev/null 2>&1; then
    echo "Warning: jq is not on PATH. The in-session gates fall back to python3, and fail open (let every edit through) when python3 is missing too. Install jq."
fi

echo "Lens: load vse-companion-overview before engineering work if not yet loaded this session."
echo "Agent posture: forward-going stories only (section 2.6 rule 7)."

exit 0
