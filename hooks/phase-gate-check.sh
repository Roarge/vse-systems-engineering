#!/usr/bin/env bash
# Phase-gate check: verify ISO 29110 work product completeness
# Implements niche construction (R4) by enforcing phase-gate compliance.
#
# Usage: bash hooks/phase-gate-check.sh [target-phase]
#   If target-phase is omitted, reads current phase from .vse-phase
#
# Exit codes:
#   0 = all required work products present
#   1 = missing work products (gate not passed)
#   2 = no .vse-phase file found
set -euo pipefail

PHASE_FILE=".vse-phase"
TARGET_PHASE="${1:-}"

if [ -z "$TARGET_PHASE" ]; then
    if [ ! -f "$PHASE_FILE" ]; then
        echo "phase-gate-check: no .vse-phase file found, skipping phase gate check."
        exit 2
    fi
    TARGET_PHASE=$(cat "$PHASE_FILE" | tr -d '[:space:]')
fi

echo "phase-gate-check: verifying gate for phase $TARGET_PHASE..."

MISSING=0
CHECKED=0

check_file() {
    local desc="$1"
    shift
    CHECKED=$((CHECKED + 1))
    local found=false
    for pattern in "$@"; do
        if compgen -G "$pattern" > /dev/null 2>&1; then
            found=true
            break
        fi
    done
    if [ "$found" = true ]; then
        echo "  [x] $desc"
    else
        echo "  [ ] $desc (MISSING)"
        MISSING=$((MISSING + 1))
    fi
}

check_dir() {
    local desc="$1"
    local dir="$2"
    CHECKED=$((CHECKED + 1))
    if [ -d "$dir" ] && [ "$(ls -A "$dir" 2>/dev/null)" ]; then
        echo "  [x] $desc"
    else
        echo "  [ ] $desc (MISSING or empty)"
        MISSING=$((MISSING + 1))
    fi
}

case "$TARGET_PHASE" in
    SR.1)
        echo "Gate: SR.1 to SR.2 (Initiation to Requirements)"
        check_file "Project Plan or SEMP exists" "docs/*[Pp]lan*" "docs/sr/*[Ss][Ee][Mm][Pp]*" "docs/pm/*plan*"
        check_dir "Models directory exists" "models"
        ;;
    SR.2)
        echo "Gate: SR.2 to SR.3 (Requirements to Architecture)"
        check_file "Stakeholder needs model" "models/*stakeholder*" "models/*needs*"
        check_file "System requirements model" "models/*requirement*" "models/*system-req*"
        check_file "Traceability Matrix" "docs/sr/*traceability*"
        check_file "IVV Plan" "docs/sr/*ivv*"
        ;;
    SR.3)
        echo "Gate: SR.3 to SR.4 (Architecture to Construction)"
        check_file "Architecture model" "models/*architecture*" "models/*arch*" "models/*smart*"
        check_file "System Design Document" "docs/sr/*system-design*" "docs/sr/*design*"
        check_file "Traceability Matrix" "docs/sr/*traceability*"
        ;;
    SR.4)
        echo "Gate: SR.4 to SR.5 (Construction to IVV)"
        check_file "Architecture model" "models/*architecture*" "models/*arch*" "models/*smart*"
        check_file "System requirements model" "models/*requirement*" "models/*system-req*"
        check_file "System Element Requirements" "docs/sr/*element*" "docs/sr/*system-element*"
        ;;
    SR.5)
        echo "Gate: SR.5 to SR.6 (IVV to Delivery)"
        check_file "Verification model" "models/*verification*" "models/*verify*"
        check_file "Validation model" "models/*validation*" "models/*valid*"
        check_file "System requirements model" "models/*requirement*" "models/*system-req*"
        ;;
    SR.6)
        echo "Gate: SR.6 (Delivery readiness)"
        check_file "Verification model" "models/*verification*" "models/*verify*"
        check_file "Validation model" "models/*validation*" "models/*valid*"
        ;;
    PM.1)
        echo "Gate: PM.1 (Project Planning)"
        check_file "Project Plan" "docs/*[Pp]lan*" "docs/pm/*plan*"
        ;;
    PM.2)
        echo "Gate: PM.2 (Plan Execution)"
        check_file "Project Plan" "docs/*[Pp]lan*" "docs/pm/*plan*"
        check_file "Progress Status Record" "docs/pm/*progress*"
        ;;
    PM.3)
        echo "Gate: PM.3 (Assessment and Control)"
        check_file "Project Plan" "docs/*[Pp]lan*" "docs/pm/*plan*"
        check_file "Correction Register" "docs/pm/*correction*"
        ;;
    PM.4)
        echo "Gate: PM.4 (Closure)"
        check_file "Project Plan" "docs/*[Pp]lan*" "docs/pm/*plan*"
        check_file "Product Acceptance Record" "docs/pm/*acceptance*"
        ;;
    *)
        echo "phase-gate-check: unknown phase '$TARGET_PHASE'"
        exit 2
        ;;
esac

echo ""
echo "phase-gate-check: checked $CHECKED items."

if [ "$MISSING" -gt 0 ]; then
    echo "phase-gate-check: FAILED - $MISSING missing work product(s)."
    echo "  Complete the missing items before transitioning to the next phase."
    exit 1
fi

echo "phase-gate-check: PASSED - all required work products present."
exit 0
