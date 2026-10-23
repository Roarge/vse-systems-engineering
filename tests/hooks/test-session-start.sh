#!/usr/bin/env bash
# Behavioural tests for hooks/session-start.sh.
#
# All three detection modes are exercised from scratch directories:
# mode 3, the SysML-only repository, on the markers that can fire it,
# mode 2, the VSE project, on the toolchain status line in its three
# states, and mode 1, the plugin repository, on its pointer to the
# contributor rules.
#
# A VSE project is located through its .iso-config.yaml, as the gates
# locate it (vse_tf_locate_project): from the working directory up to
# the git top level, then from engineering/ below it. A methodology/
# folder without a configuration still draws the report, as a fallback
# for projects that predate the configuration. The Methodology line
# names the project's own methodology/ folder, else the plugin's copy.
# The hook is advisory, so every case also asserts exit 0 and
# plain-text output, which is what reaches the conversation.
#
# A pair of cases pins the budget the availability probe runs under,
# because the hook has to set it before the library is sourced for the
# shorter session-start value to take effect at all.
#
# The policy cases pin what the session is told about working behaviour
# first and test first (methodology section 11): the Behaviour-first
# and Test-first lines in a VSE project, the nudge when test tooling is
# found in the located project while test_first.applies is false or
# unrecorded, the warning when jq is missing, and the one pointer to the
# contributor rules in the plugin repository (mode 1).
#
# A VSE project below its git top level (greenfield and brownfield
# layouts) has its own configuration read, the same file the gates
# find by walking up from an edited file, and a configuration path the
# environment already names is kept.
#
# Every toolchain is stubbed, so the file asserts the same behaviour on
# a runner with no SysML tool installed.
#
# Run: bash tests/hooks/test-session-start.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" > /dev/null && pwd)/lib.sh"

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

# State 4: the recorded value is not one of the three. The preference
# falls back to syside, and the banner says so, so that a typo in the
# configuration does not read back as a deliberate choice.
case_mode2 "unrecognised value" cameo \
    "recorded 'cameo' is not recognised, treated as syside"

# --------------------------------------------- the probe budget

# The library defaults VSE_TC_PROBE_TIMEOUT to 20 seconds at source
# time, so the hook has to export the shorter session-start budget of
# 10 before it sources the library. A stub timeout records the budget
# it is handed, which is the only place the effective value shows.
tc_stub_timeout_recorder() {
    tc_stub timeout <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
printf '%s\n' "${1:-}" >> "${TC_TIMEOUT_RECORD:-/dev/null}"
shift
exec "$@"
EOF
}

# case_probe_budget <name> <expected-seconds> [NAME=VALUE ...]
case_probe_budget() {
    local name="$1" expected="$2" dir record
    shift 2
    dir="$(tc_mktemp_d)"
    make_vse_project "$dir" syside
    record="$(mktemp "${TC_ROOT}/timeout.XXXXXX")"
    tc_env "TC_TIMEOUT_RECORD=${record}" SYSIDE_OK=1 "$@"
    run_hook_in "$dir"
    tc_assert_rc 0 "probe budget (${name}): exit 0"
    tc_assert_grep "Toolchain:   syside (preferred, available)" "$OUT" \
        "probe budget (${name}): the probe ran through the preferred tool"
    tc_assert_eq "$expected" "$(head -n 1 "$record")" \
        "probe budget (${name}): the probe runs under ${expected} seconds"
}

tc_stub_syside
tc_stub_timeout_recorder

case_probe_budget "unset" 10
case_probe_budget "preset" 3 VSE_TC_PROBE_TIMEOUT=3

tc_env
tc_reset_stubs

# ------------------------------- behaviour-first and test-first policy

# A PATH value that takes jq out of reach.
SS_BIN_NO_JQ="$(tc_bin_without jq)"

# make_policy_project <dir> <applies|-> [marker ...]
#
# A VSE project whose configuration records test_first.applies with the
# given value, or carries no test_first block for "-". Where the value
# is true the record also names its code_paths and test_paths, as a
# complete record does. Each marker is a file created empty at the
# project root, so that the test tooling detection finds it (pytest.ini
# reads as pytest, go.mod as go).
make_policy_project() {
    local dir="$1" applies="$2" marker
    shift 2
    make_vse_project "$dir" syside
    if [ "$applies" != "-" ]; then
        printf 'test_first:\n  applies: %s\n' "$applies" >> "${dir}/.iso-config.yaml"
    fi
    if [ "$applies" = "true" ]; then
        printf '  code_paths: [src/*]\n  test_paths: [tests/*]\n' >> "${dir}/.iso-config.yaml"
    fi
    for marker in "$@"; do
        : > "${dir}/${marker}"
    done
}

case_mode2_behaviour_first_line() {
    local dir
    dir="$(tc_mktemp_d)"
    make_policy_project "$dir" -
    tc_env
    run_hook_in "$dir"
    tc_assert_rc 0 "behaviour first: exit 0"
    tc_assert_match '^Behaviour-first: .*Gherkin feature.*@<ID>.*before design or code \(methodology section 11\)' "$OUT" \
        "behaviour first: every story gets its tagged Gherkin feature before design or code"
    assert_plain_text "$OUT" "behaviour first: output is plain text"
}

# case_mode2_test_first_recorded <applies|-> <shown>
#
# The Test-first line names the value the configuration records, and an
# unrecognised value reads as unrecorded rather than being echoed back.
# Where test first applies, or is not recorded, the line points at the
# TDD skill. Where the recorded judgement is that it does not apply, the
# line says test first is not required here and that Gherkin first
# still applies, with no pointer to the skill.
case_mode2_test_first_recorded() {
    local applies="$1" shown="$2" dir
    dir="$(tc_mktemp_d)"
    make_policy_project "$dir" "$applies"
    tc_env
    run_hook_in "$dir"
    tc_assert_rc 0 "test first (${applies}): exit 0"
    tc_assert_match "^Test-first: test_first\\.applies is ${shown}[ .,]" "$OUT" \
        "test first (${applies}): the line names the recorded value, ${shown}"
    if [ "$shown" = "false" ]; then
        tc_assert_match '^Test-first: test_first\.applies is false\. .*test first is not required here' "$OUT" \
            "test first (${applies}): the recorded judgement is that test first is not required here"
        tc_assert_match '^Test-first: .*Gherkin first still applies' "$OUT" \
            "test first (${applies}): Gherkin first still applies"
        tc_assert_not_grep "superpowers:test-driven-development" "$OUT" \
            "test first (${applies}): no pointer to the TDD skill"
    else
        tc_assert_match '^Test-first: .*If superpowers:test-driven-development is listed in your skills, use it, otherwise follow methodology section 11\.' "$OUT" \
            "test first (${applies}): an installed TDD skill comes first, else section 11"
    fi
    if [ "$shown" = "not recorded" ]; then
        tc_assert_match '^Test-first: .*/vse-test-first' "$OUT" \
            "test first (${applies}): the line points at /vse-test-first to record it"
    fi
    assert_plain_text "$OUT" "test first (${applies}): output is plain text"
}

# An unrecognised applies value is reported on stderr once, not once
# for each helper that reads it.
case_mode2_test_first_unrecognised_warned_once() {
    local dir
    dir="$(tc_mktemp_d)"
    make_policy_project "$dir" yes
    tc_env
    run_hook_in "$dir"
    tc_assert_rc 0 "test first (unrecognised): exit 0"
    tc_assert_line_count 1 "$(printf '%s\n' "$ERR" | grep -F "Unrecognised test_first.applies value 'yes'" || true)" \
        "test first (unrecognised): the warning is printed once"
}

# applies: true with code_paths or test_paths that read empty leaves
# the gates unable to tell code from tests, so the Test-first line
# names the key in place of the plain "applies is true" line.
case_mode2_test_first_paths_unreadable() {
    local dir
    dir="$(tc_mktemp_d)"
    make_policy_project "$dir" -
    printf 'test_first:\n  applies: true\n  code_path: [src/*]\n  test_paths: [tests/*]\n' >> "${dir}/.iso-config.yaml"
    tc_env
    run_hook_in "$dir"
    tc_assert_rc 0 "test first, misspelt key: exit 0"
    tc_assert_match '^Test-first: test_first\.applies is true, but .*test_first\.code_paths.*/vse-test-first' "$OUT" \
        "test first, misspelt key: the line names the key that reads empty and points at /vse-test-first"
    tc_assert_not_match '^Test-first: test_first\.applies is true\. ' "$OUT" \
        "test first, misspelt key: the plain applies-is-true line is replaced"
    tc_assert_match '^Test-first: .*If superpowers:test-driven-development is listed in your skills' "$OUT" \
        "test first, misspelt key: the TDD skill pointer stays"
    assert_plain_text "$OUT" "test first, misspelt key: output is plain text"

    make_policy_project "$dir" -
    printf 'test_first:\n  applies: true\n  code_paths:\n    -src/*\n  test_paths: [tests/*]\n' >> "${dir}/.iso-config.yaml"
    run_hook_in "$dir"
    tc_assert_match '^Test-first: test_first\.applies is true\. ' "$OUT" \
        "test first, -src/* item: the item is read and the plain line is given"
}

# case_mode2_nudge_when_detected <name> <applies|-> <expected|-> [marker ...]
#
# <expected> is the nudge text after "Test-first nudge: ", or "-" when
# no nudge is due.
case_mode2_nudge_when_detected() {
    local name="$1" applies="$2" expected="$3" dir
    shift 3
    dir="$(tc_mktemp_d)"
    make_policy_project "$dir" "$applies" "$@"
    tc_env
    run_hook_in "$dir"
    tc_assert_rc 0 "nudge (${name}): exit 0"
    if [ "$expected" = "-" ]; then
        tc_assert_not_grep "Test-first nudge:" "$OUT" "nudge (${name}): no nudge"
    else
        tc_assert_grep "Test-first nudge: ${expected}" "$OUT" \
            "nudge (${name}): the tooling found and the recorded value are named"
        tc_assert_match '^Test-first nudge: .*/vse-test-first' "$OUT" \
            "nudge (${name}): the nudge points at /vse-test-first"
        assert_plain_text "$OUT" "nudge (${name}): output is plain text"
    fi
}

# A copy of the hook whose lib/ holds no test-first.sh still runs to the
# end, and says the value is unknown rather than unrecorded.
case_mode2_test_first_library_missing() {
    local dir plugin
    dir="$(tc_mktemp_d)"
    plugin="$(tc_mktemp_d)"
    mkdir -p "${plugin}/hooks/lib"
    cp "$HOOK" "${plugin}/hooks/session-start.sh"
    cp "${TC_PLUGIN_ROOT}/hooks/lib/iso-profile.sh" \
       "${TC_PLUGIN_ROOT}/hooks/lib/sysml-toolchain.sh" "${plugin}/hooks/lib/"
    make_policy_project "$dir" true pytest.ini
    tc_env
    tc_run_in "$dir" bash "${plugin}/hooks/session-start.sh"
    tc_assert_rc 0 "test-first library missing: exit 0"
    tc_assert_match '^Test-first: test_first\.applies is unknown \(test-first library missing\)\.' "$OUT" \
        "test-first library missing: the value reads as unknown, not as unrecorded"
    tc_assert_not_grep "Test-first nudge:" "$OUT" "test-first library missing: no nudge"
    tc_assert_grep "Lens: load vse-companion-overview" "$OUT" \
        "test-first library missing: the hook runs to the end"
}

# The in-session gates read their payload with jq, fall back to
# python3, and let the edit through when neither is present, so the
# session is told when jq is missing and stays quiet when it is not.
case_mode2_jq_missing_warning() {
    local dir
    dir="$(tc_mktemp_d)"
    make_policy_project "$dir" true
    tc_env PATH="$SS_BIN_NO_JQ"
    run_hook_in "$dir"
    tc_assert_rc 0 "jq missing: exit 0"
    tc_assert_match '^Warning: jq is not on PATH\..*python3.*fail open' "$OUT" \
        "jq missing: the gates fall back to python3 or fail open, and the session is told"
    assert_plain_text "$OUT" "jq missing: output is plain text"
    # The sandbox PATH is the stubs, /usr/bin and /bin, so a jq
    # installed anywhere else (Homebrew, say) is out of its reach.
    if [ ! -x /usr/bin/jq ] && [ ! -x /bin/jq ]; then
        tc_skip "jq under /usr/bin or /bin" "the jq present case needs jq on the sandbox PATH"
        return 0
    fi
    tc_env
    run_hook_in "$dir"
    tc_assert_not_grep "jq is not on PATH" "$OUT" "jq present: no warning"
}

# case_mode2_nested_project <greenfield|brownfield>
#
# A VSE project that sits below its git top level, as demo/smart-sensor
# does in the plugin repository or a subproject does in a monorepo. The
# gates find the configuration by walking up from the edited file, so
# they read the project's own .iso-config.yaml (under engineering/ for
# the brownfield layout), and the session has to be told the same
# values. The top level carries no configuration, so a lookup from
# there reads the defaults: standard, syside and an unrecorded
# test_first.applies, none of which the project records.
case_mode2_nested_project() {
    local layout="$1" top proj eng
    top="$(tc_mktemp_d)"
    git init -q "$top"
    proj="${top}/projects/sensor"
    eng="$proj"
    if [ "$layout" = brownfield ]; then
        eng="${proj}/engineering"
    fi
    mkdir -p "${eng}/methodology"
    printf '# Methodology overview\n' > "${eng}/methodology/00-methodology-overview.md"
    {
        printf 'project_profile: full\n'
        printf 'sysml_toolchain: omg-pilot\n'
        printf 'test_first:\n  applies: false\n'
    } > "${eng}/.iso-config.yaml"
    tc_env
    run_hook_in "$proj"
    tc_assert_rc 0 "nested project (${layout}): exit 0"
    tc_assert_grep "Profile:     full (per methodology section 0.10)" "$OUT" \
        "nested project (${layout}): the Profile line reads the project's configuration"
    tc_assert_match '^Toolchain: +omg-pilot \(preferred' "$OUT" \
        "nested project (${layout}): the Toolchain line names the recorded preference"
    tc_assert_match '^Test-first: test_first\.applies is false\.' "$OUT" \
        "nested project (${layout}): the Test-first line names the recorded value, false"
    tc_assert_not_grep "is not recorded" "$OUT" \
        "nested project (${layout}): the recorded value is not reported as missing"
    assert_plain_text "$OUT" "nested project (${layout}): output is plain text"
}

# A configuration path the environment already names is left alone, as
# iso-profile.sh documents, rather than replaced by the one in the
# working directory.
case_mode2_preset_config_path() {
    local proj preset
    proj="$(tc_mktemp_d)"
    make_policy_project "$proj" false
    preset="$(tc_mktemp_d)/preset.yaml"
    printf 'project_profile: light\ntest_first:\n  applies: true\n  code_paths: [src/*]\n  test_paths: [tests/*]\n' > "$preset"
    tc_env "VSE_ISO_CONFIG=${preset}"
    run_hook_in "$proj"
    tc_assert_rc 0 "preset configuration path: exit 0"
    tc_assert_grep "Profile:     light (per methodology section 0.10)" "$OUT" \
        "preset configuration path: the Profile line reads the named file"
    tc_assert_match '^Test-first: test_first\.applies is true\.' "$OUT" \
        "preset configuration path: the Test-first line reads the named file"
}

# ----------------------------------- locating the project (mode 2)

# The configuration is the canonical project marker, so a directory
# that holds only a .iso-config.yaml is a VSE project, not a SysML-only
# repository, and with no methodology/ folder of its own the
# Methodology line names the plugin's copy.
case_mode2_config_only() {
    local dir
    dir="$(tc_mktemp_d)"
    printf 'project_profile: full\nsysml_toolchain: opensysml\n' > "${dir}/.iso-config.yaml"
    tc_env
    run_hook_in "$dir"
    tc_assert_rc 0 "config only: exit 0"
    tc_assert_grep "VSE project (story-driven AMBSE, ISO/IEC 29110)." "$OUT" \
        "config only: a configuration alone marks a VSE project"
    tc_assert_not_grep "SysML 2.0 modelling repository detected" "$OUT" \
        "config only: not reported as a SysML-only repository"
    tc_assert_grep "Profile:     full (per methodology section 0.10)" "$OUT" \
        "config only: the Profile line reads the configuration"
    tc_assert_match "^Methodology: .*/methodology/ \\(the plugin's copy" "$OUT" \
        "config only: the Methodology line names the plugin's copy"
    assert_plain_text "$OUT" "config only: output is plain text"
}

# A session started below the project directory finds the project by
# walking up, as the gates do from an edited file.
case_mode2_from_subdirectory() {
    local top real
    top="$(tc_mktemp_d)"
    git init -q "$top"
    real="$(cd "$top" && pwd -P)"
    mkdir -p "${top}/methodology" "${top}/src/deep"
    printf '# Methodology overview\n' > "${top}/methodology/00-methodology-overview.md"
    printf 'project_profile: full\ntest_first:\n  applies: false\n' > "${top}/.iso-config.yaml"
    tc_env
    run_hook_in "${top}/src/deep"
    tc_assert_rc 0 "subdirectory: exit 0"
    tc_assert_grep "VSE project (story-driven AMBSE, ISO/IEC 29110)." "$OUT" \
        "subdirectory: the project above the working directory is found"
    tc_assert_grep "Profile:     full (per methodology section 0.10)" "$OUT" \
        "subdirectory: the Profile line reads the project's configuration"
    tc_assert_match '^Test-first: test_first\.applies is false\.' "$OUT" \
        "subdirectory: the Test-first line reads the project's configuration"
    tc_assert_line "Methodology: ${real}/methodology/ (project-local, authoritative)" "$OUT" \
        "subdirectory: the Methodology line names the project's folder"
}

# The test tooling nudge looks for tooling in the located project, at
# its engineering root and at the git top level when that differs, not
# in the working directory the session started in.
case_mode2_nudge_located() {
    local top
    top="$(tc_mktemp_d)"
    git init -q "$top"
    mkdir -p "${top}/src/deep"
    printf 'project_profile: light\ntest_first:\n  applies: false\n' > "${top}/.iso-config.yaml"
    : > "${top}/pytest.ini"
    tc_env
    run_hook_in "${top}/src/deep"
    tc_assert_rc 0 "located nudge (subdirectory): exit 0"
    tc_assert_grep "Test-first nudge: test tooling found (pytest) while test_first.applies is false." "$OUT" \
        "located nudge (subdirectory): the project's tooling is found from below it"

    top="$(tc_mktemp_d)"
    git init -q "$top"
    mkdir -p "${top}/engineering/src" "${top}/src/deep"
    printf 'project_profile: light\n' > "${top}/engineering/.iso-config.yaml"
    : > "${top}/engineering/pytest.ini"
    tc_env
    run_hook_in "$top"
    tc_assert_grep "Test-first nudge: test tooling found (pytest) while test_first.applies is not recorded." "$OUT" \
        "located nudge (brownfield): tooling at the engineering root is found from the top level"
    : > "${top}/go.mod"
    run_hook_in "${top}/engineering/src"
    tc_assert_grep "Test-first nudge: test tooling found (pytest, go) while test_first.applies is not recorded." "$OUT" \
        "located nudge (brownfield): tooling at the top level is found from below the engineering root"
    : > "${top}/pytest.ini"
    rm "${top}/go.mod"
    run_hook_in "${top}/engineering/src"
    tc_assert_grep "Test-first nudge: test tooling found (pytest) while test_first.applies is not recorded." "$OUT" \
        "located nudge (brownfield): a tool found at both places is named once"

    top="$(tc_mktemp_d)"
    git init -q "$top"
    mkdir -p "${top}/src/deep"
    printf 'project_profile: light\n' > "${top}/.iso-config.yaml"
    : > "${top}/src/deep/pytest.ini"
    tc_env
    run_hook_in "${top}/src/deep"
    tc_assert_rc 0 "located nudge (working directory only): exit 0"
    tc_assert_not_grep "Test-first nudge:" "$OUT" \
        "located nudge (working directory only): tooling below the project directory is not the project's"
}

# At the project directory the Methodology line keeps its short form.
case_mode2_methodology_line() {
    local dir
    dir="$(tc_mktemp_d)"
    make_vse_project "$dir" syside
    tc_env
    run_hook_in "$dir"
    tc_assert_line "Methodology: ./methodology/ (project-local, authoritative)" "$OUT" \
        "methodology line: the project's own folder, relative to the working directory"
}

# A methodology/ folder with no configuration still draws the report,
# read with the defaults, as before the configuration existed.
case_mode2_methodology_fallback() {
    local dir
    dir="$(tc_mktemp_d)"
    mkdir -p "${dir}/methodology"
    tc_env
    run_hook_in "$dir"
    tc_assert_rc 0 "methodology fallback: exit 0"
    tc_assert_grep "VSE project (story-driven AMBSE, ISO/IEC 29110)." "$OUT" \
        "methodology fallback: the report is given"
    tc_assert_grep "Profile:     standard (per methodology section 0.10)" "$OUT" \
        "methodology fallback: the defaults are reported"
}

# In the plugin repository only a configuration under demo/ marks a
# project, as at the gates, so the shipped template is not one.
case_mode2_contributor_template() {
    local top
    top="$(tc_mktemp_d)"
    git init -q "$top"
    mkdir -p "${top}/templates/iso-config" "${top}/demo/smart-sensor"
    tc_mark_plugin_repo "$top"
    printf 'project_profile: full\n' > "${top}/templates/iso-config/.iso-config.yaml"
    printf 'project_profile: full\n' > "${top}/demo/smart-sensor/.iso-config.yaml"
    tc_env
    run_hook_in "${top}/templates/iso-config"
    tc_assert_rc 0 "contributor template: exit 0"
    tc_assert_not_grep "VSE project" "$OUT" \
        "contributor template: the shipped template configuration is not a project"
    run_hook_in "${top}/demo/smart-sensor"
    tc_assert_grep "Profile:     full (per methodology section 0.10)" "$OUT" \
        "contributor template: the demo is a project"
}

# A user project that keeps its own wiki schema at wiki/CLAUDE.md, with
# no plugin manifest, is a VSE project and gets the project report, not
# the contributor wiki lines.
case_mode2_user_wiki_schema() {
    local dir
    dir="$(tc_mktemp_d)"
    git init -q "$dir"
    mkdir -p "${dir}/wiki"
    printf '# Our wiki\n' > "${dir}/wiki/CLAUDE.md"
    printf '# Log\n' > "${dir}/wiki/LOG.md"
    printf 'project_profile: full\n' > "${dir}/.iso-config.yaml"
    tc_env
    run_hook_in "$dir"
    tc_assert_rc 0 "user wiki: exit 0"
    tc_assert_grep "VSE project (story-driven AMBSE, ISO/IEC 29110)." "$OUT" \
        "user wiki: the project report is given"
    tc_assert_grep "Profile:     full (per methodology section 0.10)" "$OUT" \
        "user wiki: the project's own configuration is read"
    tc_assert_not_grep "Wiki (contributor repo)" "$OUT" \
        "user wiki: the contributor wiki lines are not printed"
}

# A copy of the hook that cannot load the test-first library makes the
# same two-file test for the plugin repository on its own.
case_mode1_library_missing() {
    local plugin contributor user
    plugin="$(tc_mktemp_d)"
    mkdir -p "${plugin}/hooks/lib"
    cp "$HOOK" "${plugin}/hooks/session-start.sh"
    cp "${TC_PLUGIN_ROOT}/hooks/lib/iso-profile.sh" \
       "${TC_PLUGIN_ROOT}/hooks/lib/sysml-toolchain.sh" "${plugin}/hooks/lib/"
    contributor="$(tc_mktemp_d)"
    tc_mark_plugin_repo "$contributor"
    user="$(tc_mktemp_d)"
    mkdir -p "${user}/wiki" "${user}/methodology"
    printf '# Our wiki\n' > "${user}/wiki/CLAUDE.md"
    tc_env
    tc_run_in "$contributor" bash "${plugin}/hooks/session-start.sh"
    tc_assert_grep "Wiki (contributor repo):" "$OUT" \
        "library missing: the plugin repository is still recognised"
    tc_run_in "$user" bash "${plugin}/hooks/session-start.sh"
    tc_assert_not_grep "Wiki (contributor repo)" "$OUT" \
        "library missing: a user project with its own wiki schema is not the plugin repository"
    tc_assert_grep "VSE project (story-driven AMBSE, ISO/IEC 29110)." "$OUT" \
        "library missing: the user project gets the project report"
}

# More plan-baseline and release tags than a pipe buffer holds in a
# listing. The hook reads each whole listing, names the latest of each,
# and goes on to the rest of the report.
case_mode2_many_tags() {
    local dir
    dir="$(tc_mktemp_d)"
    make_vse_project "$dir" syside
    git init -q "$dir"
    git -C "$dir" -c user.email=t@example.invalid -c user.name=t commit -q --allow-empty -m start
    tc_tag_many "$dir" plan-baseline- 12000
    tc_tag_many "$dir" release- 12000
    tc_env
    run_hook_in "$dir"
    tc_assert_rc 0 "many tags: exit 0"
    tc_assert_line "Plan baseline: plan-baseline-12000" "$OUT" \
        "many tags: the latest plan baseline is named"
    tc_assert_line "Last release:  release-12000" "$OUT" \
        "many tags: the latest release is named"
    tc_assert_grep "Behaviour-first: " "$OUT" "many tags: the report goes on past the tags"
}

# Contributor mode (the plugin repository) prints exactly one pointer to
# the contributor rules for test first and Gherkin first.
case_mode1_pointer() {
    local dir
    dir="$(tc_mktemp_d)"
    tc_mark_plugin_repo "$dir"
    tc_env
    run_hook_in "$dir"
    tc_assert_rc 0 "mode 1: exit 0"
    tc_assert_eq 1 "$(printf '%s\n' "$OUT" | grep -cF '.claude/rules/tdd-bdd.md' || true)" \
        "mode 1: one line points at the contributor rules"
    tc_assert_match '^Contributor rules: .*test first.*Gherkin first.*\.claude/rules/tdd-bdd\.md' "$OUT" \
        "mode 1: the pointer names test first and Gherkin first"
    assert_plain_text "$OUT" "mode 1: output is plain text"
}

# ------------------------------------------- mode 1: the wiki LOG age

# write_log <dir> <date>: a wiki LOG in <dir> whose last dated entry is
# <date>, after an older one.
write_log() {
    printf '# Log\n\n## [2019-06-01] ingest | an older entry\n\n## [%s] lint | the last entry\n' \
        "$2" > "${1}/wiki/LOG.md"
}

# The contributor report says how many whole days ago the last wiki LOG
# entry was written. The count needs no GNU date -d, which BSD date
# (macOS) lacks, so it is given with the BSD date stub on PATH too. The
# test reads the date before the hook runs and again after it. When UTC
# midnight passes in between, the hook may count from either day, so
# then 0 and 1 days are both accepted.
case_contributor_log_age() {
    local label="$1" dir today after
    dir="$(tc_mktemp_d)"
    tc_mark_plugin_repo "$dir"
    today="$(date -u +%Y-%m-%d)"
    write_log "$dir" "$today"
    tc_env
    run_hook_in "$dir"
    after="$(date -u +%Y-%m-%d)"
    tc_assert_rc 0 "log age, ${label}: exit 0"
    if [ "$after" = "$today" ]; then
        tc_assert_line "  Last LOG.md entry: ${today} (0 days ago)." "$OUT" \
            "log age, ${label}: an entry dated today is 0 days old"
    else
        tc_assert_match "^  Last LOG\.md entry: ${today} \((0|1) days ago\)\.\$" "$OUT" \
            "log age, ${label}: an entry dated today is 0 days old"
    fi
    write_log "$dir" 2020-01-01
    run_hook_in "$dir"
    tc_assert_match '^  Last LOG\.md entry: 2020-01-01 \([0-9]+ days ago\)\.$' "$OUT" \
        "log age, ${label}: an entry from 2020 is counted in days"
}

# fixed_clock <epoch>: a date stub whose clock reads <epoch> seconds
# since 1970. It answers date +%s and date -u +%s and refuses every
# other call, so the hook can ask it for the time and nothing else.
fixed_clock() {
    tc_stub date <<EOF
#!/usr/bin/env bash
set -euo pipefail
case "\$*" in
    "+%s"|"-u +%s")
        echo ${1}
        exit 0
        ;;
esac
echo "date: the fixed-clock stub answers only +%s and -u +%s, not: \$*" >&2
exit 1
EOF
}

# Known dates, against a clock fixed at 2024-03-01T12:00:00Z
# (1709294400): the same day, the leap day of 2024, the turn of the
# year, a whole year that holds a leap day, the leap day of 2000 (a
# century divisible by 400), 1 March 1900 (a century that is not a leap
# year) and the first day of 1970.
case_contributor_log_age_known_dates() {
    local dir entry day want
    dir="$(tc_mktemp_d)"
    tc_mark_plugin_repo "$dir"
    fixed_clock 1709294400
    tc_env
    for entry in 2024-03-01:0 2024-02-29:1 2024-02-28:2 2024-01-01:60 \
                 2023-03-01:366 2000-02-29:8767 1900-03-01:45291 1970-01-01:19783; do
        day="${entry%%:*}"
        want="${entry#*:}"
        write_log "$dir" "$day"
        run_hook_in "$dir"
        tc_assert_line "  Last LOG.md entry: ${day} (${want} days ago)." "$OUT" \
            "log age, fixed clock: ${day} is ${want} days before 2024-03-01"
    done
    rm -f "${STUBS}/date"
}

case_mode2_behaviour_first_line

case_mode2_test_first_recorded true true
case_mode2_test_first_recorded false false
case_mode2_test_first_recorded - "not recorded"
case_mode2_test_first_recorded yes "not recorded"
case_mode2_test_first_unrecognised_warned_once
case_mode2_test_first_library_missing
case_mode2_test_first_paths_unreadable

case_mode2_nudge_when_detected "false, pytest found" false \
    "test tooling found (pytest) while test_first.applies is false." pytest.ini
case_mode2_nudge_when_detected "unrecorded, pytest and go found" - \
    "test tooling found (pytest, go) while test_first.applies is not recorded." pytest.ini go.mod
case_mode2_nudge_when_detected "true, pytest found" true - pytest.ini
case_mode2_nudge_when_detected "false, nothing found" false -
case_mode2_nudge_when_detected "unrecorded, nothing found" - -

case_mode2_jq_missing_warning

case_mode2_nested_project greenfield
case_mode2_nested_project brownfield
case_mode2_preset_config_path

case_mode2_config_only
case_mode2_from_subdirectory
case_mode2_nudge_located
case_mode2_methodology_line
case_mode2_methodology_fallback
case_mode2_contributor_template
case_mode2_user_wiki_schema
case_mode2_many_tags

case_mode1_pointer
case_mode1_library_missing

case_contributor_log_age "machine date"
tc_stub_bsd_date
case_contributor_log_age "BSD date"
rm -f "${STUBS}/date"
case_contributor_log_age_known_dates

tc_env

if tc_summary "test-session-start"; then
    exit 0
fi
exit 1
