#!/usr/bin/env bash
# PreToolUse hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §5.3. Surfaces baselined-
# artefact warnings when an Edit, Write, or NotebookEdit targets a
# baselined path.
#
# v2.0-rc.5 design note: the hook is advisory, not blocking. The
# CR-presence heuristic (any open Change Request issue) is too coarse
# to use as a hard gate without false positives. The firm gate lives
# in the project-side commit-msg hook (CR reference required for
# baselined-path commits) and in CI.
#
# stdin: JSON payload with tool_name and tool_input.
# stdout: advisory text injected as context.
# Exit 0 always.
set -euo pipefail

INPUT=$(cat)
TARGET=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null || echo "")

# No path means nothing to check.
[ -z "$TARGET" ] && exit 0

# Skip silently outside a VSE project.
if [ ! -d "methodology" ] && [ ! -d "engineering/methodology" ]; then
    exit 0
fi

# Locate iso-config.yaml. Project-local overrides plugin-shipped fallback.
ISO_CONFIG=""
if [ -f ".iso-config.yaml" ]; then
    ISO_CONFIG=".iso-config.yaml"
elif [ -f "engineering/.iso-config.yaml" ]; then
    ISO_CONFIG="engineering/.iso-config.yaml"
fi

# Read baselined paths from .iso-config.yaml. Simple AWK, no YAML library.
is_baselined() {
    local path="$1"
    [ -z "$ISO_CONFIG" ] && return 1
    awk '
        /^baselined_paths:/ { inside=1; next }
        inside && /^[A-Za-z]/ { inside=0 }
        inside && /^[[:space:]]+-[[:space:]]+/ {
            sub(/^[[:space:]]+-[[:space:]]+/, "")
            sub(/[[:space:]]+#.*$/, "")
            print
        }
    ' "$ISO_CONFIG" | while IFS= read -r baselined; do
        [ -z "$baselined" ] && continue
        case "$path" in
            "$baselined"|"$baselined"/*) echo match; return;;
        esac
    done | grep -q match
}

# Surface a baselined-edit warning. Advisory only.
if is_baselined "$TARGET"; then
    cat <<EOF
[methodology reminder] Editing a baselined artefact: ${TARGET}.
Per PM.O3 (§10.4.2), modifications to baselined artefacts require
an open Change Request. Open a CR via /vse-cr if one does not
exist, then reference 'CR #<n>' in your commit message. The
project-side commit-msg hook enforces the CR reference.
EOF
fi

# For story files, surface §1.9 reminders.
case "$TARGET" in
    */stories/*.sysml)
        cat <<'EOF'
[methodology reminder] Editing a story file. Required fields per §1.9:
  - subject (typed)
  - role (typed by part def from model/core/stakeholders/ or component scope)
  - capability (narrative string)
  - benefit (narrative string)
  - frame concern (>= 1) or documented justification
  - acceptance (>= 1) before status=ready
After editing: ensure StoryMeta status is updated and the verification case (if any) is current.
EOF
        ;;
esac

exit 0
