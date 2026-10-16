#!/usr/bin/env bash
# Project-side git post-merge hook.
#
# Per methodology/iso-29110-hooks-guide.md §4.5. Regenerate model-
# derived artefacts when main advances. The hook cannot create commits
# itself without surprising the user, so it regenerates and reports
# drift. Production of the follow-up commit is left to CI on main.
#
# Install as <project>/.githooks/post-merge.
set -euo pipefail

# Only run on main.
[[ "$(git rev-parse --abbrev-ref HEAD)" == "main" ]] || exit 0

HOOK_DIR="$(dirname "$0")"
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Load the shared profile helpers. The project-side copy wins, the
# plugin copy is the fallback for a partial install. Without either,
# the hook makes the library's search for the configuration itself:
# VSE_ISO_CONFIG when it names a readable file, then the greenfield and
# brownfield layouts.
ISO_PROFILE_LIB=""
if [ -r "${HOOK_DIR}/lib/iso-profile.sh" ]; then
    ISO_PROFILE_LIB="${HOOK_DIR}/lib/iso-profile.sh"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -r "${CLAUDE_PLUGIN_ROOT}/hooks/lib/iso-profile.sh" ]; then
    ISO_PROFILE_LIB="${CLAUDE_PLUGIN_ROOT}/hooks/lib/iso-profile.sh"
fi

if [ -n "$ISO_PROFILE_LIB" ]; then
    # shellcheck source=/dev/null
    . "$ISO_PROFILE_LIB"
else
    iso_config_path() {
        if [ -n "${VSE_ISO_CONFIG:-}" ] && [ -f "${VSE_ISO_CONFIG}" ] && [ -r "${VSE_ISO_CONFIG}" ]; then
            printf '%s\n' "${VSE_ISO_CONFIG}"
        elif [ -f "${ROOT}/.iso-config.yaml" ]; then
            printf '%s\n' "${ROOT}/.iso-config.yaml"
        elif [ -f "${ROOT}/engineering/.iso-config.yaml" ]; then
            printf '%s\n' "${ROOT}/engineering/.iso-config.yaml"
        fi
    }
fi

# The configuration names the renderers. The directory that holds it
# is the engineering root, which is the project root, engineering/
# under a brownfield scaffold, or the directory of the file
# VSE_ISO_CONFIG names. Renderer paths, the renderer working directory
# and the derived artefacts all resolve from there.
ISO_CONFIG="$(iso_config_path)"
if [ -z "$ISO_CONFIG" ]; then
    exit 0
fi
ENG_ROOT="$(dirname "$ISO_CONFIG")"

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

# The drift report compares the derived artefacts with the index. git
# diff exits 1 for a difference and 0 for none, and any other status
# means git could not compare them, which is not drift. An engineering
# root outside the repository holds nothing git can compare, so it gets
# no report.
if [ "$DREW" -eq 1 ]; then
    TOP_REAL="$(pwd -P)"
    ENG_REAL="$(CDPATH='' cd -- "$ENG_ROOT" 2>/dev/null && pwd -P)" || ENG_REAL=""
    case "${ENG_REAL}/" in
        "${TOP_REAL}/"*)
            DIFF_STATUS=0
            git diff --quiet -- "$ENG_ROOT/docs/" 2>/dev/null || DIFF_STATUS=$?
            case "$DIFF_STATUS" in
                0) echo "[post-merge] Derived artefacts already current." ;;
                1) echo "[post-merge] Derived artefacts regenerated. Commit the updates or run CI." ;;
                *) echo "[post-merge] git could not compare the derived artefacts with the index (git diff exit ${DIFF_STATUS}), so drift is not reported." >&2 ;;
            esac
            ;;
    esac
fi

exit 0
