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

# Locate iso-config to find renderer paths. The directory that holds it
# is the engineering root, which is either the project root or
# engineering/ under a brownfield scaffold. Renderer paths, renderer
# working directory, and derived artefacts all resolve from there.
ISO_CONFIG=""
ENG_ROOT=""
if [ -f ".iso-config.yaml" ]; then
    ISO_CONFIG=".iso-config.yaml"
    ENG_ROOT="."
elif [ -f "engineering/.iso-config.yaml" ]; then
    ISO_CONFIG="engineering/.iso-config.yaml"
    ENG_ROOT="engineering"
fi

if [ -z "$ISO_CONFIG" ]; then
    exit 0
fi

# Invoke renderers when they exist. The real implementations live in
# tools/render/ as the project matures. The hook is silent when
# renderers are absent.
#
# Renderer paths are constrained to start with tools/render/ to prevent
# arbitrary command execution from a project-controlled YAML.
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
    case "$renderer" in
        *..*)
            echo "[post-merge] Skipping renderer with unsafe path: ${renderer}" >&2
            echo "[post-merge] Renderer paths shall not contain .. segments." >&2
            continue
            ;;
        tools/render/*) ;;
        *)
            echo "[post-merge] Skipping renderer with unsafe path: ${renderer}" >&2
            echo "[post-merge] Renderer paths shall start with tools/render/." >&2
            continue
            ;;
    esac
    if [ -x "$ENG_ROOT/$renderer" ]; then
        DREW=1
        # Run the renderer from the engineering root, because it discovers
        # model/ relative to its working directory. Output goes to
        # docs/generated/ under that same directory by convention. The
        # renderer is responsible for its own destination path.
        ( cd "$ENG_ROOT" && "./$renderer" ) > /dev/null 2>&1 || true
    fi
done <<< "$RENDERERS"

if [ "$DREW" -eq 1 ]; then
    if ! git diff --quiet -- "$ENG_ROOT/docs/" 2>/dev/null; then
        echo "[post-merge] Derived artefacts regenerated. Commit the updates or run CI."
    else
        echo "[post-merge] Derived artefacts already current."
    fi
fi

exit 0
