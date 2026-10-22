#!/usr/bin/env bash
# Self-tests for the shared harness in tests/hooks/lib.sh.
#
# The lifecycle hook tests rely on three harness promises that nothing
# else checks: the JSON payload reaches the hook on stdin, a project
# configuration can carry any gate override, and the JSON assertion
# accepts exactly one object. Each promise is exercised here against a
# stub, so a broken helper fails in this file rather than turning a
# hook test into a false pass.
#
# Run: bash tests/hooks/test-harness.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT
tc_setup_repo

# Run one assertion helper in a subshell, against a chosen OUT, and
# print the PASS or FAIL line it wrote. The subshell keeps the probe out
# of this file's own pass and fail counts, and leaves OUT untouched.
probe() (
    out="$1"
    shift
    OUT="$out" "$@"
)

# --------------------------------------------------- lifecycle runner

case_stdin_reaches_hook() {
    local root payload expected_cwd
    root="$(tc_mktemp_d)"
    mkdir -p "${root}/hooks"
    cat > "${root}/hooks/echo-stdin.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat
printf 'cwd=%s\n' "$(pwd -P)" >&2
printf 'root=%s\n' "${CLAUDE_PLUGIN_ROOT:-unset}" >&2
EOF
    chmod +x "${root}/hooks/echo-stdin.sh"
    payload='{"hook_event_name":"PreToolUse","tool_name":"Write"}'
    expected_cwd="$(cd "$REPO" && pwd -P)"

    tc_env
    TC_HOOK_ROOT="$root" tc_run_lifecycle echo-stdin "$payload"
    tc_assert_rc 0 "lifecycle runner: the stub hook exits 0"
    tc_assert_eq "$payload" "$OUT" "lifecycle runner: the JSON payload reaches the hook on stdin"
    tc_assert_line "cwd=${expected_cwd}" "$ERR" "lifecycle runner: the hook runs in the scratch repository"
    tc_assert_line "root=${root}" "$ERR" "lifecycle runner: CLAUDE_PLUGIN_ROOT names the hook root"
}

# Other runners keep an empty stdin, so a hook that reads stdin cannot
# block on the terminal of whoever runs the tests. The here-string is
# what such a hook would read if the runner let stdin through.
case_other_runners_read_empty_stdin() {
    tc_env
    tc_run_in "$REPO" cat <<< "leaked"
    tc_assert_rc 0 "other runners: cat exits 0"
    tc_assert_empty "$OUT" "other runners: stdin is empty"
}

# The profile library honours VSE_ISO_CONFIG, so a value exported by an
# outer run would steer every case to the wrong configuration. The
# sandboxed runners drop it, and a case that needs it passes it through
# tc_env.
case_runners_drop_outer_vse_iso_config() {
    local show
    # shellcheck disable=SC2016  # expanded by the shell under test
    show='printf "%s\n" "${VSE_ISO_CONFIG-unset}"'
    export VSE_ISO_CONFIG="/outer/run/.iso-config.yaml"
    tc_env
    tc_run_in "$REPO" bash -c "$show"
    tc_assert_eq "unset" "$OUT" "outer VSE_ISO_CONFIG: tc_run_in drops it"
    tc_run_lib_fn bash -c "$show"
    tc_assert_eq "unset" "$OUT" "outer VSE_ISO_CONFIG: the hook runners drop it"
    tc_run_real bash -c "$show"
    tc_assert_eq "unset" "$OUT" "outer VSE_ISO_CONFIG: the real-toolchain runner drops it"
    tc_env VSE_ISO_CONFIG=/from/tc-env.yaml
    tc_run_in "$REPO" bash -c "$show"
    tc_assert_eq "/from/tc-env.yaml" "$OUT" "VSE_ISO_CONFIG: tc_env still passes it through"
    tc_env
    unset VSE_ISO_CONFIG
}

# GITHUB_HEAD_REF names a pull request's branch in CI, and the
# project-side gates read it in range mode, so a value from the outer
# run (a CI job on a refactor/* branch, say) would steer every case.
# The sandboxed runners drop it, and a case that needs it passes it
# through tc_env.
case_runners_drop_outer_github_head_ref() {
    local show
    # shellcheck disable=SC2016  # expanded by the shell under test
    show='printf "%s\n" "${GITHUB_HEAD_REF-unset}"'
    export GITHUB_HEAD_REF="refactor/outer-run"
    tc_env
    tc_run_in "$REPO" bash -c "$show"
    tc_assert_eq "unset" "$OUT" "outer GITHUB_HEAD_REF: tc_run_in drops it"
    tc_run_lib_fn bash -c "$show"
    tc_assert_eq "unset" "$OUT" "outer GITHUB_HEAD_REF: the hook runners drop it"
    tc_run_real bash -c "$show"
    tc_assert_eq "unset" "$OUT" "outer GITHUB_HEAD_REF: the real-toolchain runner drops it"
    tc_env GITHUB_HEAD_REF=refactor/from-tc-env
    tc_run_lib_fn bash -c "$show"
    tc_assert_eq "refactor/from-tc-env" "$OUT" "GITHUB_HEAD_REF: tc_env still passes it through"
    tc_env
    unset GITHUB_HEAD_REF
}

# -------------------------------------------------- project configuration

case_config_two_gates() {
    tc_config standard - precommit_gherkin=off precommit_lint=info
    tc_assert_eq "project_profile: standard
gate_overrides:
  precommit_gherkin: off
  precommit_lint: info" "$(cat "${REPO}/.iso-config.yaml")" \
        "config: two gate specs share one gate_overrides block"
}

case_config_legacy_override() {
    tc_config full opensysml override=info
    tc_assert_eq "project_profile: full
sysml_toolchain: opensysml
gate_overrides:
  precommit_lint: info" "$(cat "${REPO}/.iso-config.yaml")" \
        "config: override=<disp> still sets precommit_lint"
}

case_config_no_specs() {
    tc_config light -
    tc_assert_eq "project_profile: light" "$(cat "${REPO}/.iso-config.yaml")" \
        "config: no spec writes no gate_overrides block"
}

# A spec without "=" names no disposition. Writing it as "gate: gate"
# would hand the hook under test a value nobody meant, so the helper
# refuses it and leaves the configuration file as it was.
case_config_rejects_spec_without_equals() {
    local errf rc=0
    tc_config light -
    errf="$(mktemp "${TC_ROOT}/err.XXXXXX")"
    ( tc_config standard - precommit_gherkin ) 2> "$errf" || rc=$?
    tc_assert_eq 2 "$rc" "config: a spec without = returns 2"
    tc_assert_grep "'precommit_gherkin' is not a <gate>=<disposition> spec" "$(cat "$errf")" \
        "config: the refusal names the spec and the expected form"
    tc_assert_eq "project_profile: light" "$(cat "${REPO}/.iso-config.yaml")" \
        "config: a refused spec leaves the configuration file unchanged"
}

case_config_append() {
    tc_config standard -
    tc_config_append <<'EOF'
tdd_scope:
  - src/
EOF
    tc_assert_eq "project_profile: standard
tdd_scope:
  - src/" "$(cat "${REPO}/.iso-config.yaml")" \
        "config: appended text lands verbatim after the generated keys"
}

# ------------------------------------------------------- JSON assertions

case_assert_json_accepts_one_object() {
    local result
    result="$(probe '{"decision":"deny"}' tc_assert_json '.decision == "deny"' "one object")"
    tc_assert_eq "PASS: one object" "$result" "assert_json: one matching object passes"
}

case_assert_json_rejects_two_objects() {
    local result
    result="$(probe '{"decision":"deny"}{"decision":"deny"}' tc_assert_json '.decision == "deny"' "two objects")"
    tc_assert_grep "FAIL: two objects" "$result" "assert_json: two matching objects fail"
}

case_assert_json_rejects_false_filter() {
    local result
    result="$(probe '{"decision":"ask"}' tc_assert_json '.decision == "deny"' "false filter")"
    tc_assert_grep "FAIL: false filter" "$result" "assert_json: a filter that does not hold fails"
}

# A filter jq cannot compile fails the assertion, and the failure shows
# jq's own message, so a typo in a test reads as a typo rather than as
# a hook that printed the wrong JSON.
case_assert_json_shows_jq_error() {
    local result
    result="$(probe '{"decision":"deny"}' tc_assert_json '.decision ==' "bad filter")"
    tc_assert_grep "FAIL: bad filter" "$result" "assert_json: a filter jq cannot compile fails"
    tc_assert_grep "jq: error" "$result" "assert_json: the failure shows jq's error"
}

# Without jq no JSON assertion can hold, and the failure says why
# rather than reporting a hook fault. The PATH holds sed alone, which
# the failure report itself needs.
case_assert_json_reports_missing_jq() {
    local bin result
    bin="$(tc_mktemp_d)"
    ln -s "$(command -v sed)" "${bin}/sed"
    result="$(PATH="$bin" probe '{"decision":"deny"}' tc_assert_json '.decision == "deny"' "no jq")"
    tc_assert_grep "FAIL: no jq" "$result" "assert_json: a missing jq fails the assertion"
    tc_assert_grep "jq is not installed" "$result" "assert_json: the failure names the missing jq"
}

# tc_assert_line compares whole lines, so a line that only starts with
# the expected text does not pass for it.
case_assert_line_exact() {
    local result
    result="$(tc_assert_line "cwd=/a" "first
cwd=/a
last" "exact line")"
    tc_assert_eq "PASS: exact line" "$result" "assert_line: an exact line among others passes"
    result="$(tc_assert_line "cwd=/a" "cwd=/a/b" "longer line")"
    tc_assert_grep "FAIL: longer line" "$result" "assert_line: a longer line does not pass"
    result="$(tc_assert_line "cwd=/a" "x cwd=/a" "embedded line")"
    tc_assert_grep "FAIL: embedded line" "$result" "assert_line: text inside a line does not pass"
}

case_assert_json_silent() {
    local result
    result="$(probe '' tc_assert_json_silent "empty")"
    tc_assert_eq "PASS: empty" "$result" "assert_json_silent: empty stdout passes"
    result="$(probe '{}' tc_assert_json_silent "object")"
    tc_assert_grep "FAIL: object" "$result" "assert_json_silent: any stdout fails"
}

# ------------------------------------------------- a PATH without tools

# tc_bin_without names a directory that links every program of /usr/bin
# and /bin except the named ones, so a case can take jq or python3 out
# of reach while sh, git and the rest still run.
case_bin_without_named_tools() {
    local bin
    bin="$(tc_bin_without jq python3)"
    if [ -d "$bin" ]; then
        tc_pass "bin without: the result is a directory"
    else
        tc_fail "bin without: the result is a directory" "got: ${bin}"
    fi
    tc_env PATH="$bin"
    tc_run_in "$REPO" sh -c 'command -v jq || echo no-jq; command -v python3 || echo no-python3'
    tc_assert_line "no-jq" "$OUT" "bin without: jq is out of reach"
    tc_assert_line "no-python3" "$OUT" "bin without: python3 is out of reach"
    tc_run_in "$REPO" sh -c 'command -v git && command -v sed'
    tc_assert_rc 0 "bin without: the programs not named still run"
    tc_assert_line "${bin}/git" "$OUT" "bin without: git is reached through the directory"

    bin="$(tc_bin_without)"
    tc_env PATH="$bin"
    tc_run_in "$REPO" sh -c 'command -v sh'
    tc_assert_line "${bin}/sh" "$OUT" "bin without: with no name every program is linked"
    tc_env
}

case_stdin_reaches_hook
case_other_runners_read_empty_stdin
case_runners_drop_outer_vse_iso_config
case_runners_drop_outer_github_head_ref
case_config_two_gates
case_config_legacy_override
case_config_no_specs
case_config_rejects_spec_without_equals
case_config_append
case_assert_json_accepts_one_object
case_assert_json_rejects_two_objects
case_assert_json_rejects_false_filter
case_assert_json_shows_jq_error
case_assert_json_reports_missing_jq
case_assert_line_exact
case_assert_json_silent
case_bin_without_named_tools

if tc_summary "test-harness"; then
    exit 0
fi
exit 1
