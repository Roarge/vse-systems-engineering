#!/usr/bin/env bash
# Project-side git post-checkout hook.
#
# Per methodology/iso-29110-hooks-guide.md §4.6. Inform the operator
# of compliance status when switching branches.
#
# git runs the hook at the top level of the repository. The project is
# located from there as the lifecycle hooks locate it (hooks/README.md
# section 1): through its .iso-config.yaml, the canonical project
# marker, with vse_tf_locate_workdir, else by a methodology/ or
# engineering/methodology/ folder, the fallback for projects that
# predate the configuration and for an install where no copy of the
# libraries is readable. The project-side copy of the libraries wins,
# and the plugin copy is the fallback for a partial install. Outside a
# project the hook is silent.
#
# Install as <project>/.githooks/post-checkout.
set -euo pipefail

# git invokes post-checkout with three positional arguments:
#   $1 = previous HEAD ref, $2 = new HEAD ref, $3 = flag (1 if branch
# checkout, 0 if file checkout). The first two are unused here.
checkout_type="${3:-0}"

# Only on branch checkouts (not file checkouts).
[ "$checkout_type" = "1" ] || exit 0

HOOK_DIR="$(dirname "$0")"
LIB_DIR=""
if [ -r "${HOOK_DIR}/lib/iso-profile.sh" ] && [ -r "${HOOK_DIR}/lib/test-first.sh" ]; then
    LIB_DIR="${HOOK_DIR}/lib"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -r "${CLAUDE_PLUGIN_ROOT}/hooks/lib/iso-profile.sh" ] \
    && [ -r "${CLAUDE_PLUGIN_ROOT}/hooks/lib/test-first.sh" ]; then
    LIB_DIR="${CLAUDE_PLUGIN_ROOT}/hooks/lib"
fi

IN_PROJECT=0
if [ -n "$LIB_DIR" ]; then
    # shellcheck source=/dev/null
    . "${LIB_DIR}/iso-profile.sh"
    # shellcheck source=/dev/null
    . "${LIB_DIR}/test-first.sh"
    if vse_tf_locate_workdir "$(pwd -P)"; then
        IN_PROJECT=1
    fi
fi
if [ "$IN_PROJECT" -eq 0 ] && { [ -d "methodology" ] || [ -d "engineering/methodology" ]; }; then
    IN_PROJECT=1
fi

# Skip silently outside a VSE project.
[ "$IN_PROJECT" -eq 1 ] || exit 0

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)

# Story branch: surface the story status briefly.
if [[ "$CURRENT_BRANCH" =~ ^story/ ]]; then
    echo "[post-checkout] Now on ${CURRENT_BRANCH}. Story branch."
    if command -v gh >/dev/null 2>&1; then
        if gh pr list --head "$CURRENT_BRANCH" --json number --jq '.[0].number' 2>/dev/null | grep -qE '^[0-9]+$'; then  # portability: ok jq prints one line, which grep reads whole
            echo "  Draft PR open."
        else
            echo "  No draft PR found. Open one before advancing per §8.5.1."
        fi
    fi
elif [[ "$CURRENT_BRANCH" == "main" ]]; then
    # awk reads the whole listing. head would stop after one line, and
    # with more tags than the pipe holds git would be killed by SIGPIPE
    # (the signal a process gets when it writes to a pipe that nobody
    # reads any more), which pipefail and set -e turn into the end of
    # the hook.
    LAST_RELEASE=$(git tag --list 'release-*' --sort=-v:refname 2>/dev/null | awk 'NR == 1')
    if [ -n "$LAST_RELEASE" ]; then
        echo "[post-checkout] On main. Last release: ${LAST_RELEASE}."
    else
        echo "[post-checkout] On main."
    fi
fi

exit 0
