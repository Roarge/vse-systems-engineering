#!/usr/bin/env bash
# Behavioural tests for the validate-demo Makefile target and the
# script it runs, tests/hooks/validate-demo.sh, which validate the demo
# model and the shipped model templates with OpenSysML.
#
# Each case builds a scratch tree that holds the working-tree Makefile,
# the script, the toolchain library it calls and small stand-ins for
# the demo model, the model templates and the SysML library, then runs
# the target or the script on a sandboxed PATH. A stub sysml records
# the files of each run, reports a finding for any file that still
# holds a {{ placeholder, and reports one more for the file that
# SYSML_FAIL_ON names. Without a sysml on PATH the target skips with a
# notice, while the script, which CI runs after installing OpenSysML,
# fails, so a broken install cannot pass in CI.
#
# Run: bash tests/hooks/test-validate-demo.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

SKIP_LINE="  SKIPPED: sysml (OpenSysML) not on PATH. CI installs OpenSysML v0.6.0 and runs this check."

# A scratch tree with the target, the script, the library and one
# stand-in file of each kind, plus a stub sysml in $STUBS.
fresh() {
    REPO="$(tc_mktemp_d)"
    FAKEHOME="$(tc_mktemp_d)"
    STUBS="$(tc_mktemp_d)"
    SYSML_LOG="${REPO}.sysml-log"
    mkdir -p "${REPO}/tests/hooks" "${REPO}/hooks/lib"
    cp "${TC_PLUGIN_ROOT}/Makefile" "${REPO}/"
    # A missing script stays missing in the scratch tree, so its absence
    # fails the assertions below rather than the fixture.
    if [ -f "${TC_PLUGIN_ROOT}/tests/hooks/validate-demo.sh" ]; then
        cp "${TC_PLUGIN_ROOT}/tests/hooks/validate-demo.sh" "${REPO}/tests/hooks/"
    fi
    cp "${TC_PLUGIN_ROOT}/hooks/lib/sysml-toolchain.sh" \
       "${TC_PLUGIN_ROOT}/hooks/lib/iso-profile.sh" "${REPO}/hooks/lib/"
    printf 'package Demo_Core;\n' | tc_write demo/smart-sensor/model/core/core.sysml
    printf 'package VSE_Library;\n' | tc_write demo/smart-sensor/model/library/vse-library.sysml
    printf '@US_001_X\nFeature: X\n' | tc_write demo/smart-sensor/model/core/stories/US_001_X.feature
    printf 'package {{PROJECT_NAME}}_Stories {\n    private import {{PROJECT_SHORT_CODE}}_Context::*;\n}\n' \
        | tc_write templates/common/models/core/stories/_template.sysml
    printf 'package {{PROJECT_NAME}}_AsIs;\n' \
        | tc_write templates/common/models/core/base-architecture/as-is.sysml.tmpl
    printf 'package VSE_Library;\n' | tc_write templates/common/library/vse-library.sysml
    tc_stub sysml <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
if [ "${1:-}" = "-version" ]; then
    echo 'sysml v0.6.0'
    exit 0
fi
files=""
rc=0
for arg in "$@"; do
    case "$arg" in
        -*) continue ;;
    esac
    files="${files:+${files} }${arg}"
    if grep -qF '{{' "$arg"; then
        echo "${arg}:1:9: error: expected a namespace member" >&2
        rc=1
    fi
    if [ -n "${SYSML_FAIL_ON:-}" ] && [ "$arg" = "$SYSML_FAIL_ON" ]; then
        echo "${arg}:1:1: error: unresolved reference" >&2
        rc=1
    fi
done
printf '%s\n' "$files" >> "$SYSML_LOG"
exit "$rc"
EOF
}

# run_in <PATH> <command> ...: run inside the scratch tree with a
# scratch HOME and no make state inherited from an outer make.
run_in() {
    local path="$1"
    shift
    _tc_capture env -C "$REPO" -u MAKEFLAGS -u MAKELEVEL -u MFLAGS \
        -u VSE_SYSML_TOOLCHAIN -u VSE_ISO_CONFIG -u CLAUDE_PLUGIN_ROOT \
        PATH="$path" HOME="$FAKEHOME" SYSML_LOG="$SYSML_LOG" \
        ${TC_ENV[@]+"${TC_ENV[@]}"} \
        "$@"
}

run_target() {
    run_in "${STUBS}:/usr/bin:/bin" make --no-print-directory validate-demo
}

log() {
    cat "$SYSML_LOG" 2>/dev/null || true
}

# --- no sysml on PATH: the target skips, the script fails -------------

fresh
rm -f "${STUBS}/sysml"
NO_SYSML="$(tc_bin_without sysml)"
tc_env
run_in "${STUBS}:${NO_SYSML}" make --no-print-directory validate-demo
tc_assert_rc 0 "no sysml: the target passes"
tc_assert_line "$SKIP_LINE" "$OUT" "no sysml: the target says it skipped and why"
tc_assert_empty "$(log)" "no sysml: nothing was validated"

run_in "${STUBS}:${NO_SYSML}" bash tests/hooks/validate-demo.sh
tc_assert_rc 2 "no sysml: the script CI runs fails rather than skipping"
tc_assert_grep "opensysml unavailable" "$ERR" "no sysml: the script names the missing validator"

# --- a clean run -------------------------------------------------------

fresh
tc_env
run_target
tc_assert_rc 0 "clean: the target passes"
tc_assert_line_count 2 "$(log)" "clean: one run for the demo and one for the templates"
tc_assert_line "model/core/core.sysml model/library/vse-library.sysml" "$(log)" \
    "clean: the demo run reads every demo .sysml file, from the demo's root"
tc_assert_line "model/core/stories/_template.sysml model/library/vse-library.sysml" "$(log)" \
    "clean: the template run reads the templates with the library and no .tmpl file"
tc_assert_not_grep ".feature" "$(log)" "clean: no feature file reaches the validator"
tc_assert_not_grep "expected a namespace member" "$OUT$ERR" \
    "clean: the template run sees no placeholder"
tc_assert_line "  The demo model validates under OpenSysML (2 files)." "$OUT" \
    "clean: the demo result is reported"
tc_assert_line "  The model templates validate under OpenSysML (2 files, placeholders filled)." "$OUT" \
    "clean: the template result is reported"
if grep -qF '{{PROJECT_NAME}}' "${REPO}/templates/common/models/core/stories/_template.sysml"; then
    tc_pass "clean: the shipped template keeps its placeholders"
else
    tc_fail "clean: the shipped template keeps its placeholders"
fi

# --- a finding in the demo model ---------------------------------------

fresh
tc_env SYSML_FAIL_ON=model/core/core.sysml
run_target
tc_assert_rc 2 "demo finding: the target fails"
tc_assert_line "model/core/core.sysml:1:1: error: unresolved reference" "$OUT" \
    "demo finding: the finding is shown"
tc_assert_line "ERROR: the demo model (demo/smart-sensor/model) draws OpenSysML findings, listed above" "$OUT" \
    "demo finding: the tree is named"
tc_assert_line_count 2 "$(log)" "demo finding: the templates are still validated"

# --- a finding in the model templates -----------------------------------

fresh
tc_env SYSML_FAIL_ON=model/core/stories/_template.sysml
run_target
tc_assert_rc 2 "template finding: the target fails"
tc_assert_line "model/core/stories/_template.sysml:1:1: error: unresolved reference" "$OUT" \
    "template finding: the finding is shown"
tc_assert_line "ERROR: the model templates (templates/common/models, validated with the placeholders filled) draw OpenSysML findings, listed above" "$OUT" \
    "template finding: the tree is named"
tc_assert_line "  The demo model validates under OpenSysML (2 files)." "$OUT" \
    "template finding: the demo result still stands"
tc_env

tc_summary "test-validate-demo"
