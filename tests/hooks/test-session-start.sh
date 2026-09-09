#!/usr/bin/env bash
# Behavioural tests for hooks/session-start.sh.
#
# Two detection modes are exercised from scratch directories: mode 3,
# the SysML-only repository, on each of the three markers that can fire
# it, and mode 2, the VSE project, on the toolchain status line in its
# three states. The hook is advisory, so every case also asserts exit 0
# and plain-text output, which is what reaches the conversation.
#
# Every toolchain is stubbed, so the file asserts the same behaviour on
# a runner with no SysML tool installed.
#
# Run: bash tests/hooks/test-session-start.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

# The scratch repository is not used here, but its fake HOME and stub
# directory are what keep the machine's own toolchains out of reach.
tc_setup_repo
trap tc_teardown EXIT

HOOK="${TC_PLUGIN_ROOT}/hooks/session-start.sh"

# The hook output is injected into a conversation verbatim, so it has
# to be printable text: no terminal escapes, no stray control bytes.
assert_plain_text() {
    local text="$1" name="$2" stray
    stray="$(printf '%s' "$text" | LC_ALL=C tr -d '\011\012\040-\176')"
    if [ -z "$stray" ]; then
        tc_pass "$name"
    else
        tc_fail "$name" "output carries non-printable bytes"
    fi
}

run_hook_in() {
    tc_run_in "$1" bash "$HOOK"
}

# --------------------------------------- mode 3: SysML-only repository

case_mode3() {
    local name="$1" dir
    dir="$(tc_mktemp_d)"
    shift
    "$@" "$dir"
    tc_env
    run_hook_in "$dir"
    tc_assert_rc 0 "mode 3 (${name}): exit 0"
    tc_assert_grep "SysML 2.0 modelling repository detected" "$OUT" \
        "mode 3 (${name}): the SysML-only banner fires"
    tc_assert_grep "run /vse-toolchain to choose and install a SysML v2 validator" "$OUT" \
        "mode 3 (${name}): the toolchain pointer is offered"
    assert_plain_text "$OUT" "mode 3 (${name}): output is plain text"
}

# shellcheck disable=SC2317  # called indirectly through case_mode3
marker_iso_config() {
    printf 'sysml_toolchain: opensysml\n' > "${1}/.iso-config.yaml"
}

# shellcheck disable=SC2317  # called indirectly through case_mode3
marker_lsp_json() {
    cat > "${1}/.lsp.json" <<'EOF'
{
  "servers": {
    "sysml-lsp": { "command": "sysml-lsp", "args": ["--stdio"] }
  }
}
EOF
}

# shellcheck disable=SC2317  # called indirectly through case_mode3
marker_syside_toml() {
    cat > "${1}/syside.toml" <<'EOF'
[project]
name = "scratch"
EOF
}

# ----------------------------------------------- mode 2: VSE project

# A VSE project is a methodology/ directory plus the configuration the
# rigour profile and the toolchain preference are read from.
make_vse_project() {
    local dir="$1" toolchain="$2"
    mkdir -p "${dir}/methodology"
    printf '# Methodology overview\n' > "${dir}/methodology/00-methodology-overview.md"
    {
        printf 'project_profile: standard\n'
        printf 'sysml_toolchain: %s\n' "$toolchain"
    } > "${dir}/.iso-config.yaml"
}

case_mode2() {
    local name="$1" toolchain="$2" expected="$3" dir
    dir="$(tc_mktemp_d)"
    make_vse_project "$dir" "$toolchain"
    tc_env
    run_hook_in "$dir"
    tc_assert_rc 0 "mode 2 (${name}): exit 0"
    tc_assert_grep "VSE project (story-driven AMBSE, ISO/IEC 29110)." "$OUT" \
        "mode 2 (${name}): the VSE banner fires"
    tc_assert_grep "$expected" "$OUT" "mode 2 (${name}): the toolchain line"
    assert_plain_text "$OUT" "mode 2 (${name}): output is plain text"
}

case_mode3 "iso-config key" marker_iso_config
case_mode3 "lsp.json" marker_lsp_json
case_mode3 "syside.toml" marker_syside_toml

# State 1: the preferred toolchain is installed.
tc_stub_java "21.0.12"
tc_pilot_install
case_mode2 "preferred available" omg-pilot \
    "Toolchain:   omg-pilot (preferred, available)"

# State 2: the preferred toolchain is absent and a fallback is not.
case_mode2 "fallback available" syside \
    "Toolchain:   syside (preferred) unavailable: syside not on PATH. Hooks fall back to omg-pilot. Run /vse-toolchain to install or switch."

# State 3: nothing is installed.
tc_reset_stubs
tc_pilot_uninstall
case_mode2 "nothing available" syside \
    "Toolchain:   syside (preferred) unavailable: syside not on PATH. No fallback installed. Run /vse-toolchain."

if tc_summary "test-session-start"; then
    exit 0
fi
exit 1
