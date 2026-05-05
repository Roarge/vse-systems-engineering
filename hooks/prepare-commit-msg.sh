#!/usr/bin/env bash
# Project-side git prepare-commit-msg hook.
#
# Per methodology/iso-29110-hooks-guide.md §4.3. Prepopulates the
# commit subject with the Story ID inferred from the branch name.
#
# Install as <project>/.githooks/prepare-commit-msg.
set -euo pipefail

MSG_FILE="$1"
SOURCE_TYPE="${2:-}"

# Skip if message already set (merge, squash, template, etc.).
[ -n "$SOURCE_TYPE" ] && exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
[ -z "$BRANCH" ] && exit 0

# story/US_042_AckFromDashboard -> US_042
if [[ "$BRANCH" =~ ^story/([A-Z]+_[0-9]+) ]]; then
    STORY_ID=${BASH_REMATCH[1]}
    if head -n1 "$MSG_FILE" | grep -qE '^[[:space:]]*(#|$)'; then
        # Inject as the first line if message is empty or starts with comment.
        TMP=$(mktemp)
        printf 'feat(%s): \n\n' "$STORY_ID" > "$TMP"
        cat "$MSG_FILE" >> "$TMP"
        mv "$TMP" "$MSG_FILE"
    fi
fi

exit 0
