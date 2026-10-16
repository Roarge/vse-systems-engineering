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
    tc_assert_grep "cwd=${expected_cwd}" "$ERR" "lifecycle runner: the hook runs in the scratch repository"
    tc_assert_grep "root=${root}" "$ERR" "lifecycle runner: CLAUDE_PLUGIN_ROOT names the hook root"
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
    tc_env VSE_ISO_CONFIG=/from/tc-env.yaml
    tc_run_in "$REPO" bash -c "$show"
    tc_assert_eq "/from/tc-env.yaml" "$OUT" "VSE_ISO_CONFIG: tc_env still passes it through"
    tc_env
    unset VSE_ISO_CONFIG
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

case_assert_json_silent() {
    local result
    result="$(probe '' tc_assert_json_silent "empty")"
    tc_assert_eq "PASS: empty" "$result" "assert_json_silent: empty stdout passes"
    result="$(probe '{}' tc_assert_json_silent "object")"
    tc_assert_grep "FAIL: object" "$result" "assert_json_silent: any stdout fails"
}

case_stdin_reaches_hook
case_other_runners_read_empty_stdin
case_runners_drop_outer_vse_iso_config
case_config_two_gates
case_config_legacy_override
case_config_no_specs
case_config_append
case_assert_json_accepts_one_object
case_assert_json_rejects_two_objects
case_assert_json_rejects_false_filter
case_assert_json_silent

if tc_summary "test-harness"; then
    exit 0
fi
exit 1
