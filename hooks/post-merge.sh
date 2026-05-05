#!/usr/bin/env bash
# Project-side git post-merge hook.
#
# Per methodology/iso-29110-hooks-guide.md §4.5. Regenerate model-
# derived artefacts when main advances. Cannot itself create commits
# without surprising the user; it regenerates and reports drift.
# Production of the follow-up commit is left to CI on main.
#
# Install as <project>/.githooks/post-merge.
set -euo pipefail

# Only run on main.
[[ "$(git rev-parse --abbrev-ref HEAD)" == "main" ]] || exit 0

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Locate iso-config to find renderer paths.
ISO_CONFIG=""
[ -f ".iso-config.yaml" ] && ISO_CONFIG=".iso-config.yaml"
[ -f "engineering/.iso-config.yaml" ] && ISO_CONFIG="engineering/.iso-config.yaml"

if [ -z "$ISO_CONFIG" ]; then
    exit 0
fi

# Stub: invoke renderers when they exist. The real implementations
# land in tools/render/ as the project matures. The hook is silent
# when renderers are absent.
RENDERERS=$(awk '
    /^renderers:/ { inside=1; next }
    inside && /^[A-Za-z]/ { inside=0 }
    inside && /^[[:space:]]+[a-z_]+:[[:space:]]+/ {
        sub(/^[[:space:]]+[a-z_]+:[[:space:]]+/, "")
        print
    }
' "$ISO_CONFIG")

DREW=0
while IFS= read -r renderer; do
    [ -z "$renderer" ] && continue
    if [ -x "$renderer" ]; then
        DREW=1
        # Run the renderer; output goes to docs/generated/ by convention.
        # The renderer is responsible for its own destination path.
        "$renderer" > /dev/null 2>&1 || true
    fi
done <<< "$RENDERERS"

if [ "$DREW" -eq 1 ]; then
    if ! git diff --quiet -- docs/ 2>/dev/null; then
        echo "[post-merge] Derived artefacts regenerated. Commit the updates or run CI."
    else
        echo "[post-merge] Derived artefacts already current."
    fi
fi

exit 0
