#!/usr/bin/env bash
# PostToolUse hook: remind about wiki ingestion after a file under sources/
# is written or edited.
# Receives JSON on stdin with tool use details. Only activates when the
# modified path is under sources/ AND the current working directory looks
# like the vse-systems-engineering plugin repo (wiki/CLAUDE.md present).
# End-user projects installing the plugin do not have sources/ or wiki/,
# so the hook produces no output there.
#
# Exit 0: proceed (stdout becomes context reminder)
set -euo pipefail

# Read the tool use event from stdin
INPUT=$(cat)

# Guard: this hook is contributor-facing. Only act inside a repo that
# carries the wiki schema document.
if [ ! -f "wiki/CLAUDE.md" ]; then
    exit 0
fi

# Extract the file path from the JSON input. Tool parameters include a
# file_path field for Write and Edit calls.
FILE_PATH=$(echo "$INPUT" | grep -oP '"file_path"\s*:\s*"\K[^"]+' || true)

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Normalise relative paths and check the sources/ prefix. Accept both
# absolute paths whose tail is under sources/ and relative paths that
# start with sources/.
case "$FILE_PATH" in
    */sources/*|sources/*)
        ;;
    *)
        exit 0
        ;;
esac

# Skip scratch files produced by markitdown: they live under
# sources/.scratch/ and are not new sources in their own right.
case "$FILE_PATH" in
    */sources/.scratch/*|sources/.scratch/*)
        exit 0
        ;;
esac

BASENAME=$(basename "$FILE_PATH")
TODAY=$(date -u +%Y-%m-%d)

echo "A file under sources/ was written or edited: $BASENAME"
echo "Remember to:"
echo "  - Run /vse-wiki-ingest $FILE_PATH when ready to distil the source."
echo "  - Until ingested, the wiki does not reflect this material."

# Append an unresolved source-added stub to wiki/LOG.md for tracking. If
# a stub for this basename already exists on today's date, skip the
# append to avoid duplicates on repeated edits.
LOG_FILE="wiki/LOG.md"
STUB_HEADING="## [${TODAY}] source-added | ${BASENAME}"
if [ -f "$LOG_FILE" ] && grep -Fq "$STUB_HEADING" "$LOG_FILE"; then
    exit 0
fi

if [ -f "$LOG_FILE" ]; then
    {
        echo ""
        echo "$STUB_HEADING"
        echo "Raw file dropped or edited under sources/. Awaiting /vse-wiki-ingest."
    } >> "$LOG_FILE"
fi

exit 0
