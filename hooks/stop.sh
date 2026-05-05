#!/usr/bin/env bash
# Stop hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §5.5. At the end of an
# agent response, prompt the operator (or the agent) to capture
# decision rationale and follow-up tasks.
#
# Exit 0 always.
set -euo pipefail

# Skip silently outside a VSE project.
if [ ! -d "methodology" ] && [ ! -d "engineering/methodology" ]; then
    exit 0
fi

# Look at the changes in this session and prompt for ADR or report capture.
RECENT_CHANGES=$(git status --porcelain 2>/dev/null || echo "")

# Architecture decision indicators.
if echo "$RECENT_CHANGES" | grep -qE '^.[MA] (model/variations/|model/core/logical-architecture/|engineering/model/variations/|engineering/model/core/logical-architecture/)'; then
    cat <<'EOF'

[methodology prompt — end of session]
Architectural changes detected. Per §10.5.3 (Justification Document) consider:
  - Writing an ADR in docs/decisions/ if a non-trivial decision was made.
  - Updating the trade-study analysis def if a variant was selected.
EOF
fi

# V&V execution indicators.
if echo "$RECENT_CHANGES" | grep -qE '^.[MA] docs/(verification-reports|validation-reports)/'; then
    cat <<'EOF'

[methodology prompt — end of session]
V&V activity detected. Per SR.O7:
  - Ensure the report references its IVV procedure.
  - Update the relevant story's StoryMeta if verification passed or failed.
EOF
fi

exit 0
