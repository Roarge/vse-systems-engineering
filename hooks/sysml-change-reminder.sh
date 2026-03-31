#!/usr/bin/env bash
# PostToolUse hook: remind about traceability after SysML file modifications.
# Receives JSON on stdin with tool use details.
# Only activates when a .sysml file was modified.
#
# Exit 0: proceed (stdout becomes context reminder)
# Exit 2: block (not used here, we only remind)
set -euo pipefail

# Read the tool use event from stdin
INPUT=$(cat)

# Check if the modified file is a .sysml file
# The input JSON contains the file path in the tool parameters
if echo "$INPUT" | grep -q '\.sysml'; then
    echo "A SysML model file was modified. Remember to:"
    echo "  - Maintain satisfy/verify trace links"
    echo "  - Update the Traceability Matrix if requirements changed"
    echo "  - Run @traceability-guard before the next phase transition"

    # If SySiDE CLI is available, run format check on the modified file
    if command -v syside >/dev/null 2>&1; then
        # Extract the file path from the JSON input
        FILE_PATH=$(echo "$INPUT" | grep -oP '"file_path"\s*:\s*"\K[^"]+\.sysml' || true)
        if [ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ]; then
            FORMAT_OUTPUT=$(syside format --check "$FILE_PATH" 2>&1 || true)
            if echo "$FORMAT_OUTPUT" | grep -qi 'would reformat\|not formatted\|differ'; then
                echo ""
                echo "SySiDE format check: this file needs formatting."
                echo "  Run: syside format $FILE_PATH"
            fi
        fi
    fi
fi

exit 0
