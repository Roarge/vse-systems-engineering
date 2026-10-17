#!/usr/bin/env bash
# Behavioural tests for the export steps of
# templates/github/document-export.yml, the release workflow
# @attention-regime installs at the full profile.
#
# A workflow file cannot run outside GitHub Actions, so this test plays
# the runner for the steps that turn the work products into docx files:
# "Create build directory", "Export PM documents" and "Export SR
# documents". Each run script is read from the template as shipped
# (ci-step.sh) and runs under "bash --noprofile --norc -eo pipefail",
# the command the runner uses for a bash step, in a scratch tree shaped
# like a project @project-setup scaffolded (its Step 7 table). A stub
# pandoc records each conversion and, like the real one, fails on an
# input file that does not exist.
#
# The export reads the sources the @document-export skill lists in its
# Step 2 table, under docs/ or, in a brownfield project, under
# engineering/docs/. A source the project does not have is skipped
# with a line saying so, and a conversion that fails still fails its
# step.
#
# Run: bash tests/hooks/test-document-export.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"
# shellcheck source=/dev/null
. "${TC_LIB_DIR}/ci-step.sh"

trap tc_teardown EXIT

# Read by ci_step, from ci-step.sh.
# shellcheck disable=SC2034
CI_TEMPLATE="${TC_PLUGIN_ROOT}/templates/github/document-export.yml"

BUILD="Create build directory"
PM="Export PM documents"
SR="Export SR documents"

# ------------------------------------------------------------- fixtures

# ex_project [prefix]: a scratch project with the docs/ tree that
# @project-setup Step 7 writes at the full profile, under <prefix>
# (empty, or engineering/ for a brownfield project), and a stub pandoc.
ex_project() {
    local prefix="${1:-}" doc dir
    REPO="$(tc_mktemp_d)"
    FAKEHOME="$(tc_mktemp_d)"
    STUBS="$(tc_mktemp_d)"
    PANDOC_LOG="${REPO}.pandoc-log"
    for doc in project-plan semp risk-register cm-strategy \
               disposal-management-approach correction-register \
               progress-status-record; do
        printf '# %s\n' "$doc" | tc_write "${prefix}docs/${doc}.md"
    done
    for dir in meetings decisions releases generated templates; do
        : | tc_write "${prefix}docs/${dir}/.gitkeep"
    done
    tc_stub pandoc <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
in=""
out=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        -o) out="$2"; shift 2 ;;
        --from|--to) shift 2 ;;
        -*) shift ;;
        *) in="$1"; shift ;;
    esac
done
printf '%s -> %s\n' "$in" "$out" >> "$PANDOC_LOG"
if [ ! -f "$in" ]; then
    echo "pandoc: ${in}: withBinaryFile: does not exist (No such file or directory)" >&2
    exit 1
fi
if [ -n "${PANDOC_FAIL_ON:-}" ] && [ "$in" = "$PANDOC_FAIL_ON" ]; then
    echo "pandoc: ${in}: cannot convert" >&2
    exit 64
fi
: > "$out"
EOF
}

# ex_records: the documents a project adds after setup, one of every
# source the skill's table names that the scaffold does not write.
ex_records() {
    local doc
    for doc in product-acceptance-record system-design ivv-plan maintenance-guide \
               meetings/2026-10-01-kickoff \
               verification-reports/VC_001_Example-2026-10-02 \
               validation-reports/VAL_001_Example-2026-10-03 \
               generated/stakeholder-requirements generated/system-requirements \
               generated/traceability-matrix; do
        printf '# %s\n' "$doc" | tc_write "docs/${doc}.md"
    done
}

# ------------------------------------------------------------ the runner

# ex_run <name>: run the step named <name> in $REPO the way the runner
# does. The result is in RC, OUT and ERR, with both streams in LOG.
ex_run() {
    local name="$1" work
    work="$(tc_mktemp_d)"
    LOG=""
    if ! ci_step "$name" run > "${work}/step.sh" || [ ! -s "${work}/step.sh" ]; then
        tc_fail "the template has a step named '${name}' with a run script"
        RC=99
        return 0
    fi
    _tc_capture env -C "$REPO" -i \
        PATH="${STUBS}:/usr/bin:/bin" HOME="$FAKEHOME" \
        CI=true GITHUB_ACTIONS=true GITHUB_WORKSPACE="$REPO" \
        GITHUB_EVENT_NAME=release PANDOC_LOG="$PANDOC_LOG" \
        ${TC_ENV[@]+"${TC_ENV[@]}"} \
        bash --noprofile --norc -eo pipefail "${work}/step.sh"
    LOG="${OUT}
${ERR}"
}

# ex_export: the three steps in order, keeping each export step's
# result.
ex_export() {
    ex_run "$BUILD"
    ex_run "$PM"
    PM_RC="$RC"
    PM_LOG="$LOG"
    ex_run "$SR"
    SR_RC="$RC"
    SR_LOG="$LOG"
}

pandoc_log() {
    cat "$PANDOC_LOG" 2>/dev/null || true
}

# ----------------------------------------------------------------- cases

# A project as @project-setup leaves it at the full profile, the
# profile that installs the workflow.
case_scaffolded_project() {
    ex_project
    tc_env
    ex_export
    tc_assert_eq 0 "$PM_RC" "scaffold: the PM step passes"
    tc_assert_eq 0 "$SR_RC" "scaffold: the SR step passes"
    tc_assert_eq "docs/project-plan.md -> build/project-plan.docx
docs/progress-status-record.md -> build/progress-status-record.docx
docs/correction-register.md -> build/correction-register.docx
docs/semp.md -> build/semp.docx" "$(pandoc_log)" \
        "scaffold: every source the scaffold writes is exported, and nothing else"
    tc_assert_not_grep "*" "$(pandoc_log)" "scaffold: no unmatched pattern reaches pandoc"
    if [ -f "${REPO}/build/project-plan.docx" ] && [ -f "${REPO}/build/semp.docx" ]; then
        tc_pass "scaffold: the documents land in build/"
    else
        tc_fail "scaffold: the documents land in build/" "$(ls -R "$REPO")"
    fi
    tc_assert_line "Skipping docs/product-acceptance-record.md: not in this project." "$PM_LOG" \
        "scaffold: a PM source the project does not have yet is named as skipped"
    tc_assert_line "Skipping docs/system-design.md: not in this project." "$SR_LOG" \
        "scaffold: an SR source the project does not have yet is named as skipped"
}

# Every source of the skill's table, once the project has written them.
case_every_source() {
    ex_project
    ex_records
    tc_env
    ex_export
    tc_assert_eq 0 "$PM_RC" "every source: the PM step passes"
    tc_assert_eq 0 "$SR_RC" "every source: the SR step passes"
    tc_assert_eq "docs/project-plan.md -> build/project-plan.docx
docs/progress-status-record.md -> build/progress-status-record.docx
docs/meetings/2026-10-01-kickoff.md -> build/2026-10-01-kickoff.docx
docs/correction-register.md -> build/correction-register.docx
docs/product-acceptance-record.md -> build/product-acceptance-record.docx
docs/semp.md -> build/semp.docx
docs/generated/stakeholder-requirements.md -> build/stakeholder-requirements.docx
docs/generated/system-requirements.md -> build/system-requirements.docx
docs/generated/traceability-matrix.md -> build/traceability-matrix.docx
docs/system-design.md -> build/system-design.docx
docs/ivv-plan.md -> build/ivv-plan.docx
docs/verification-reports/VC_001_Example-2026-10-02.md -> build/VC_001_Example-2026-10-02.docx
docs/validation-reports/VAL_001_Example-2026-10-03.md -> build/VAL_001_Example-2026-10-03.docx
docs/maintenance-guide.md -> build/maintenance-guide.docx" "$(pandoc_log)" \
        "every source: each document of the table is exported, in its order"
}

# A brownfield project keeps its engineering documents under
# engineering/docs/, beside a docs/ folder of its own.
case_brownfield() {
    ex_project engineering/
    printf '# User guide\n' | tc_write docs/user-guide.md
    tc_env
    ex_export
    tc_assert_eq 0 "$PM_RC" "brownfield: the PM step passes"
    tc_assert_eq 0 "$SR_RC" "brownfield: the SR step passes"
    tc_assert_eq "engineering/docs/project-plan.md -> build/project-plan.docx
engineering/docs/progress-status-record.md -> build/progress-status-record.docx
engineering/docs/correction-register.md -> build/correction-register.docx
engineering/docs/semp.md -> build/semp.docx" "$(pandoc_log)" \
        "brownfield: the documents under engineering/docs/ are exported"
}

# Skipping an absent source does not hide a conversion that fails.
case_conversion_fails() {
    ex_project
    tc_env PANDOC_FAIL_ON=docs/semp.md
    ex_export
    tc_assert_eq 0 "$PM_RC" "failing conversion: the PM step is unaffected"
    if [ "$SR_RC" -ne 0 ]; then
        tc_pass "failing conversion: the SR step fails"
    else
        tc_fail "failing conversion: the SR step fails" "$SR_LOG"
    fi
    tc_assert_grep "pandoc: docs/semp.md: cannot convert" "$SR_LOG" \
        "failing conversion: the error is shown"
    tc_env
}

case_scaffolded_project
case_every_source
case_brownfield
case_conversion_fails

if tc_summary "test-document-export"; then
    exit 0
fi
exit 1
