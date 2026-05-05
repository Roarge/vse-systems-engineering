#!/usr/bin/env bash
# Project-side git post-checkout hook.
#
# Per methodology/iso-29110-hooks-guide.md §4.6. Inform the operator
# of compliance status when switching branches.
#
# Install as <project>/.githooks/post-checkout.
set -euo pipefail

prev=$1
new=$2
checkout_type=$3

# Only on branch checkouts (not file checkouts).
[[ "$checkout_type" == "1" ]] || exit 0

# Skip silently outside a VSE project.
ENG_ROOT=""
if [ -d "engineering/methodology" ]; then
    ENG_ROOT="engineering"
elif [ -d "methodology" ]; then
    ENG_ROOT="."
else
    exit 0
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)

# Story branch: surface the story status briefly.
if [[ "$CURRENT_BRANCH" =~ ^story/ ]]; then
    echo "[post-checkout] Now on ${CURRENT_BRANCH}. Story branch."
    if command -v gh >/dev/null 2>&1; then
        if gh pr list --head "$CURRENT_BRANCH" --json number --jq '.[0].number' 2>/dev/null | grep -qE '^[0-9]+$'; then
            echo "  Draft PR open."
        else
            echo "  No draft PR found. Open one before advancing per §8.5.1."
        fi
    fi
elif [[ "$CURRENT_BRANCH" == "main" ]]; then
    LAST_RELEASE=$(git tag --list 'release-*' --sort=-v:refname 2>/dev/null | head -1)
    if [ -n "$LAST_RELEASE" ]; then
        echo "[post-checkout] On main. Last release: ${LAST_RELEASE}."
    else
        echo "[post-checkout] On main."
    fi
fi

exit 0
