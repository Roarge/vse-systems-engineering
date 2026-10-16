#!/usr/bin/env bash
# PostToolUse hook: remind about wiki ingestion after a file under
# sources/ is written or edited.
#
# Contributor-only. It acts only when the session's working directory
# (the payload's cwd, else the hook's own) carries wiki/CLAUDE.md, the
# wiki schema document of the vse-systems-engineering plugin
# repository. End-user projects installing the plugin have no
# wiki/CLAUDE.md, so the hook is silent there and writes nothing.
#
# For a file under sources/ (other than the markitdown scratch files
# under sources/.scratch/), it reminds the agent to run
# /vse-wiki-ingest, and appends an unresolved source-added stub to
# wiki/LOG.md, at most once a day for each file name.
#
# Output contract. Claude never sees plain stdout at PostToolUse, so
# the reminder goes out as hookSpecificOutput.additionalContext in one
# JSON object, printed through hooks/lib/hook-json.sh. Diagnostics go
# to stderr. The exit status is always 0: an internal error ends the
# hook silently, with one line on stderr.
#
# stdin: the PostToolUse JSON payload (tool_name, tool_input, cwd).
# stdout: one JSON object, or nothing.
set -euo pipefail

SAR_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib"
SAR_WORK=""

# Fail quietly. The function is reached through the trap.
# shellcheck disable=SC2317
_sar_finish() {
    local rc=$?
    if [ -n "$SAR_WORK" ]; then
        rm -rf "$SAR_WORK"
    fi
    if [ "$rc" -ne 0 ]; then
        echo "[source-added-reminder] Internal error (exit ${rc}), so no wiki reminder was given." >&2
        exit 0
    fi
}
trap _sar_finish EXIT

SAR_WORK="$(mktemp -d "${TMPDIR:-/tmp}/vse-source-added.XXXXXX")"
SAR_PAYLOAD="${SAR_WORK}/payload.json"
cat > "$SAR_PAYLOAD"

# shellcheck source=/dev/null
. "${SAR_LIB}/hook-json.sh"

# Guard: this hook is contributor-facing. Only act inside a repository
# that carries the wiki schema document.
SAR_ROOT="$(vse_hj_read "$SAR_PAYLOAD" .cwd)"
case "$SAR_ROOT" in
    /*) SAR_ROOT="${SAR_ROOT%/}" ;;
    *) SAR_ROOT="$(pwd -P)" ;;
esac
if [ ! -f "${SAR_ROOT}/wiki/CLAUDE.md" ]; then
    exit 0
fi

# Write and Edit calls name the file in tool_input.file_path.
FILE_PATH="$(vse_hj_read "$SAR_PAYLOAD" .tool_input.file_path)"
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Accept both absolute paths whose tail is under sources/ and relative
# paths that start with sources/.
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

BASENAME="${FILE_PATH##*/}"
TODAY=$(date -u +%Y-%m-%d)

# Append an unresolved source-added stub to wiki/LOG.md for tracking,
# unless a stub for this basename already exists on today's date, so
# repeated edits add no duplicates. A LOG.md that cannot be written is
# reported on stderr and does not stop the reminder.
LOG_FILE="${SAR_ROOT}/wiki/LOG.md"
STUB_HEADING="## [${TODAY}] source-added | ${BASENAME}"
if [ -f "$LOG_FILE" ] && ! grep -Fq -- "$STUB_HEADING" "$LOG_FILE"; then
    if ! {
        echo ""
        echo "$STUB_HEADING"
        echo "Raw file dropped or edited under sources/. Awaiting /vse-wiki-ingest."
    } >> "$LOG_FILE"; then
        echo "[source-added-reminder] Could not append the source-added stub to ${LOG_FILE}." >&2
    fi
fi

vse_hj_context PostToolUse "A file under sources/ was written or edited: ${BASENAME}
Remember to:
  - Run /vse-wiki-ingest ${FILE_PATH} when ready to distil the source.
  - Until ingested, the wiki does not reflect this material."

exit 0
