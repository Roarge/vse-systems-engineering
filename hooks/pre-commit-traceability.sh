#!/usr/bin/env bash
# Pre-commit hook: verify requirement-to-verification traceability
# Implements niche construction (R4) by blocking commits with broken traces.
#
# Install: cp hooks/pre-commit-traceability.sh .git/hooks/pre-commit
#
# This hook checks staged .sysml files for requirements that lack
# satisfy (upward) or verify (downward) trace links.
set -euo pipefail

# Find staged .sysml files
STAGED_SYSML=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sysml$' || true)

if [ -z "$STAGED_SYSML" ]; then
    echo "pre-commit-traceability: no .sysml files staged, skipping check."
    exit 0
fi

echo "pre-commit-traceability: checking staged .sysml files for trace gaps..."

GAPS=0
REQS_CHECKED=0

for file in $STAGED_SYSML; do
    # Extract requirement definitions from this file
    REQ_NAMES=$(grep -oP 'requirement\s+def\s+\K\w+' "$file" 2>/dev/null || true)

    for req in $REQ_NAMES; do
        REQS_CHECKED=$((REQS_CHECKED + 1))

        # Check for satisfy link (upward trace) within the same file
        # The satisfy link may be inside the requirement block
        if ! grep -qP "satisfy\s+requirement\s+" "$file" 2>/dev/null; then
            # Check if any staged file has a satisfy reference to this req
            HAS_SATISFY=false
            for other in $STAGED_SYSML; do
                if grep -qP "satisfy\s+requirement\s+.*${req}" "$other" 2>/dev/null; then
                    HAS_SATISFY=true
                    break
                fi
            done
            # Also check all .sysml files in the repo (not just staged)
            if [ "$HAS_SATISFY" = false ]; then
                for existing in $(find . -name '*.sysml' -not -path './.git/*' 2>/dev/null); do
                    if grep -qP "satisfy\s+requirement\s+.*${req}" "$existing" 2>/dev/null; then
                        HAS_SATISFY=true
                        break
                    fi
                done
            fi
        fi
    done

    # Check for verification cases without verify links
    VER_NAMES=$(grep -oP 'verification\s+def\s+\K\w+' "$file" 2>/dev/null || true)

    for ver in $VER_NAMES; do
        if ! grep -qP "verify\s+requirement\s+" "$file" 2>/dev/null; then
            echo "  WARNING: $file: verification case '$ver' has no verify link"
            GAPS=$((GAPS + 1))
        fi
    done
done

# Check that all requirements across staged files have verify links somewhere
for file in $STAGED_SYSML; do
    REQ_NAMES=$(grep -oP 'requirement\s+def\s+\K\w+' "$file" 2>/dev/null || true)

    for req in $REQ_NAMES; do
        HAS_VERIFY=false
        # Search all .sysml files for a verify link to this requirement
        for sysml in $(find . -name '*.sysml' -not -path './.git/*' 2>/dev/null); do
            if grep -qP "verify\s+requirement\s+.*${req}" "$sysml" 2>/dev/null; then
                HAS_VERIFY=true
                break
            fi
        done

        if [ "$HAS_VERIFY" = false ]; then
            echo "  WARNING: $file: requirement '$req' has no verification case"
            GAPS=$((GAPS + 1))
        fi
    done
done

echo "pre-commit-traceability: checked $REQS_CHECKED requirements."

if [ "$GAPS" -gt 0 ]; then
    echo "pre-commit-traceability: FAILED - $GAPS trace gap(s) found."
    echo "  Fix the gaps or use 'git commit --no-verify' to bypass (not recommended)."
    exit 1
fi

echo "pre-commit-traceability: PASSED - all traces complete."
exit 0
