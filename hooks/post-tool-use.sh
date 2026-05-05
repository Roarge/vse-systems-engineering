#!/usr/bin/env bash
# PostToolUse hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §5.4. After model edits,
# prompt for the consequent updates that ISO compliance requires.
#
# Replaces the legacy sysml-change-reminder.sh. The legacy sibling
# source-added-reminder.sh is preserved as a separate wiki-side hook.
#
# stdin: JSON payload with tool_input.
# stdout: advisory text injected as context.
# Exit 0 always.
set -euo pipefail

INPUT=$(cat)
TARGET=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null || echo "")
[ -z "$TARGET" ] && exit 0

# Skip silently outside a VSE project.
if [ ! -d "methodology" ] && [ ! -d "engineering/methodology" ]; then
    exit 0
fi

case "$TARGET" in
    */stories/*.sysml)
        STORY_ID=$(basename "$TARGET" .sysml)
        cat <<EOF
[methodology follow-up] Story ${STORY_ID} changed. Consider:
  - Update the verification case verifying its acceptance (SR.O7).
  - Check that StoryMeta.status reflects the new state.
  - If the change introduced a new constraint, regenerate the Traceability Matrix.
EOF
        ;;
    */concerns/*.sysml)
        cat <<'EOF'
[methodology follow-up] Concern changed. Consider:
  - Check that all framing stories still satisfy the concern.
  - Update stakeholder communications if the concern's scope shifted.
EOF
        ;;
    */logical-architecture/*.sysml|*/functional-architecture/*.sysml|*/product-architecture/*.sysml)
        cat <<'EOF'
[methodology follow-up] Architecture changed. Consider:
  - Update allocations if subsystem responsibilities shifted (SR.O3).
  - Re-render Traceability Matrix.
  - If the decision was non-trivial, write an ADR in docs/decisions/.
EOF
        ;;
    docs/project-plan.md|*/docs/project-plan.md)
        cat <<'EOF'
[methodology follow-up] Project Plan changed. Per PM.O1:
  - This change requires Acquirer review and approval.
  - Reference the corresponding Change Request issue.
  - On merge, tag a new plan-baseline.
EOF
        ;;
esac

exit 0
