#!/usr/bin/env bash
# PreToolUse hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §5.3. Gates tool calls that
# would violate compliance, particularly edits to baselined artefacts
# without an open Change Request.
#
# stdin: JSON payload with tool_name and tool_input.
# stdout: JSON payload with decision: "block" to refuse, or non-JSON
#         text to inject as advisory context (allow proceeding).
# Exit 0 always.
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // .tool // ""' 2>/dev/null || echo "")
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

# Read baselined paths from .iso-config.yaml. Simple grep, no YAML library.
# Format expected:
#   baselined_paths:
#     - docs/project-plan.md
#     - methodology/
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
    ' "$ISO_CONFIG" | while read -r baselined; do
        case "$path" in
            "$baselined"|"$baselined"/*) echo "match"; break;;
        esac
    done | grep -q match
}

has_open_cr() {
    if command -v gh >/dev/null 2>&1; then
        OPEN=$(gh issue list -l change-request -s open --json number 2>/dev/null | grep -c '"number"' || echo "0")
        [ "$OPEN" -gt 0 ]
    else
        return 1
    fi
}

# Gate edits to baselined artefacts.
if is_baselined "$TARGET"; then
    if ! has_open_cr; then
        cat <<EOF
{
  "decision": "block",
  "reason": "File '$TARGET' is a baselined ISO 29110 artefact (per .iso-config.yaml baselined_paths). Per PM.O3 (§10.4.2), modifications require an open Change Request. Open a CR issue first via /vse-cr, then reference 'CR #<n>' in your commits."
}
EOF
        exit 0
    fi
fi

# For story files, surface §1.9 reminders without blocking.
if [[ "$TARGET" =~ /stories/.*\.sysml$ ]]; then
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
fi

exit 0
