#!/usr/bin/env bash
# Iteration-boundary check: verify AMBSE iteration closure items.
# Implements niche construction (R4) by surfacing closure debt at
# iteration boundaries. The check is advisory: it reports missing items
# as iteration-boundary closure debt but does not block. The hard gate
# for closure lives at the macrocycle (release tag), not here.
#
# Usage: bash hooks/iteration-boundary-check.sh
#   Reads centre-of-gravity activities from .vse-iteration.yml and
#   accumulates findings across every active centre. No CLI arguments:
#   the state file is the source of truth for what to check.
#
# Exit codes:
#   0 = always (advisory). Findings are reported on stdout.
#   2 = no .vse-iteration.yml file found.
set -euo pipefail

ITERATION_FILE=".vse-iteration.yml"

# Detect VSE engineering root: prefer engineering/ if present (brownfield
# layout, where VSE work products live under engineering/ to keep an
# existing host project's root clean), else . (greenfield layout).
# .vse-iteration.yml always lives at the project root in both layouts,
# so this detection only governs the work-product globs below.
if [ -d "engineering/models" ] || [ -f "engineering/syside.toml" ]; then
    ENG_ROOT="engineering"
else
    ENG_ROOT="."
fi

if [ ! -f "$ITERATION_FILE" ]; then
    echo "iteration-boundary-check: no .vse-iteration.yml file found, skipping check."
    exit 2
fi

# Extract centre-of-gravity entries from .vse-iteration.yml.
# The YAML is managed by the iteration-orchestrator skill and has a
# stable shape. We use awk to pull every list item between the
# centre_of_gravity: key and the next sibling key at the same indent.
COG_LINES=$(awk '
    /^  centre_of_gravity:/ { inside = 1; next }
    inside && /^  [A-Za-z]/ { inside = 0 }
    inside && /^    - / {
        line = $0
        sub(/^    - /, "", line)
        gsub(/"/, "", line)
        print line
    }
' "$ITERATION_FILE")

if [ -z "$COG_LINES" ]; then
    echo "iteration-boundary-check: no centre_of_gravity entries found in $ITERATION_FILE."
    echo "  The iteration state file may be malformed. Expected a list under current_iteration.centre_of_gravity."
    exit 2
fi

ITER_NUMBER=$(grep -m1 '^  number:' "$ITERATION_FILE" | sed 's/.*number:[[:space:]]*//' | tr -d '[:space:]')
ITER_MISSION=$(grep -m1 '^  mission:' "$ITERATION_FILE" | sed 's/.*mission:[[:space:]]*//' | sed 's/^"//' | sed 's/"$//')

echo "iteration-boundary-check: checking closure for iter-${ITER_NUMBER} (${ITER_MISSION})"
echo "  Centre of gravity: $(echo "$COG_LINES" | tr '\n' ' ' | sed 's/ $//')"
echo ""

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
        echo "  [ ] $desc (closure debt)"
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
        echo "  [ ] $desc (closure debt)"
        MISSING=$((MISSING + 1))
    fi
}

# Loop over every active centre of gravity and accumulate findings.
# The check list per activity mirrors the work-product catalogue from
# the old phase-gate-check.sh, but the activities are now independent
# centres that may legitimately coexist in one iteration.
while IFS= read -r COG; do
    [ -z "$COG" ] && continue
    echo "Closure items for centre of gravity $COG:"
    case "$COG" in
        SR.1|SR.1.*)
            check_file "Project Plan or SEMP exists" "$ENG_ROOT/docs/*[Pp]lan*" "$ENG_ROOT/docs/sr/*[Ss][Ee][Mm][Pp]*" "$ENG_ROOT/docs/pm/*plan*"
            check_dir "Models directory exists" "$ENG_ROOT/models"
            ;;
        SR.2|SR.2.*)
            check_file "Stakeholder needs model" "$ENG_ROOT/models/*stakeholder*" "$ENG_ROOT/models/*needs*"
            check_file "System requirements model" "$ENG_ROOT/models/*requirement*" "$ENG_ROOT/models/*system-req*"
            check_file "Traceability Matrix" "$ENG_ROOT/docs/sr/*traceability*"
            check_file "IVV Plan" "$ENG_ROOT/docs/sr/*ivv*"
            ;;
        SR.3|SR.3.*)
            check_file "Architecture model" "$ENG_ROOT/models/*architecture*" "$ENG_ROOT/models/*arch*" "$ENG_ROOT/models/*smart*"
            check_file "System Design Document" "$ENG_ROOT/docs/sr/*system-design*" "$ENG_ROOT/docs/sr/*design*"
            check_file "Traceability Matrix" "$ENG_ROOT/docs/sr/*traceability*"
            ;;
        SR.4|SR.4.*)
            check_file "Architecture model" "$ENG_ROOT/models/*architecture*" "$ENG_ROOT/models/*arch*" "$ENG_ROOT/models/*smart*"
            check_file "System requirements model" "$ENG_ROOT/models/*requirement*" "$ENG_ROOT/models/*system-req*"
            check_file "System Element Requirements" "$ENG_ROOT/docs/sr/*element*" "$ENG_ROOT/docs/sr/*system-element*"
            ;;
        SR.5|SR.5.*)
            check_file "Verification model" "$ENG_ROOT/models/*verification*" "$ENG_ROOT/models/*verify*"
            check_file "Validation model" "$ENG_ROOT/models/*validation*" "$ENG_ROOT/models/*valid*"
            check_file "System requirements model" "$ENG_ROOT/models/*requirement*" "$ENG_ROOT/models/*system-req*"
            ;;
        SR.6|SR.6.*)
            check_file "Verification model" "$ENG_ROOT/models/*verification*" "$ENG_ROOT/models/*verify*"
            check_file "Validation model" "$ENG_ROOT/models/*validation*" "$ENG_ROOT/models/*valid*"
            ;;
        PM.1|PM.1.*)
            check_file "Project Plan" "$ENG_ROOT/docs/*[Pp]lan*" "$ENG_ROOT/docs/pm/*plan*"
            ;;
        PM.2|PM.2.*)
            check_file "Project Plan" "$ENG_ROOT/docs/*[Pp]lan*" "$ENG_ROOT/docs/pm/*plan*"
            check_file "Progress Status Record" "$ENG_ROOT/docs/pm/*progress*"
            ;;
        PM.3|PM.3.*)
            check_file "Project Plan" "$ENG_ROOT/docs/*[Pp]lan*" "$ENG_ROOT/docs/pm/*plan*"
            check_file "Correction Register" "$ENG_ROOT/docs/pm/*correction*"
            ;;
        PM.4|PM.4.*)
            check_file "Project Plan" "$ENG_ROOT/docs/*[Pp]lan*" "$ENG_ROOT/docs/pm/*plan*"
            check_file "Product Acceptance Record" "$ENG_ROOT/docs/pm/*acceptance*"
            ;;
        *)
            echo "  (no closure checklist defined for activity '$COG')"
            ;;
    esac
    echo ""
done <<< "$COG_LINES"

echo "iteration-boundary-check: checked $CHECKED item(s)."

if [ "$MISSING" -gt 0 ]; then
    echo "iteration-boundary-check: $MISSING item(s) are iteration-boundary closure debt."
    echo "  They must be carried explicitly on the iteration backlog (closure_debt"
    echo "  field in .vse-iteration.yml) and resolved before the macrocycle gate."
    echo "  This check is advisory. The engineer decides whether to close the"
    echo "  iteration with debt carried forward or to rework inside the current"
    echo "  iteration."
    exit 0
fi

echo "iteration-boundary-check: iteration boundary clean."
exit 0
