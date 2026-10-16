#!/usr/bin/env bash
# Behavioural tests for hooks/lib/iso-profile.sh.
#
# The library is exercised the way the hooks use it: each case writes a
# project configuration into a scratch repository, sources the
# installed copy (.githooks/lib/iso-profile.sh) in a fresh shell inside
# that repository, and calls one function. Four things are pinned here:
#
#   1. The four Gherkin-first and test-first gates block at every
#      profile, and only a gate_overrides entry lowers one
#      (methodology section 0.10.4).
#   2. VSE_ISO_CONFIG, when it names a readable file, wins over the
#      search from the git toplevel.
#   3. The section readers return a value or an inline list nested
#      under a top-level key, such as the test_first record. A value
#      loses one matching pair of outer quotes and nothing more.
#   4. A "#" inside quotes is part of the value, while a "#" outside
#      quotes starts a comment, as it always has.
#
# Run: bash tests/hooks/test-iso-profile.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

# The driver body is expanded by the shell it is handed to, not here.
# shellcheck disable=SC2016
ISO_DRIVER='
. ./.githooks/lib/iso-profile.sh
"$@"
'

# run_iso <function> [arg ...]: source the library inside $REPO, the
# way a hook does, and call one of its functions.
run_iso() {
    tc_run_in "$REPO" bash -c "$ISO_DRIVER" iso-driver "$@"
}

# Command substitution drops trailing newlines, so OUT cannot tell
# "printed nothing" from "printed an empty line". This driver prints
# the number of bytes the function wrote instead.
# shellcheck disable=SC2016
ISO_BYTES_DRIVER='
. ./.githooks/lib/iso-profile.sh
n=$("$@" | wc -c)
printf "%s\n" $((n))
'

# run_iso_bytes <function> [arg ...]: as run_iso, but OUT is the byte
# count of what the function printed.
run_iso_bytes() {
    tc_run_in "$REPO" bash -c "$ISO_BYTES_DRIVER" iso-bytes-driver "$@"
}

NEW_GATES="precommit_gherkin precommit_test_first pretooluse_gherkin_first pretooluse_test_first"

# ------------------------------------------------------ gate defaults

case_new_gates_block_every_profile() {
    local profile gate
    for profile in light standard full; do
        tc_setup_repo
        tc_config "$profile" -
        tc_env
        for gate in $NEW_GATES; do
            run_iso iso_gate_disposition "$gate"
            tc_assert_eq "block" "$OUT" "${gate} at ${profile}: block by default"
            tc_assert_empty "$ERR" "${gate} at ${profile}: no unknown-gate diagnostic"
        done
    done
}

case_override_lowers_new_gate() {
    tc_setup_repo
    tc_config light - precommit_gherkin=warn pretooluse_test_first=off
    tc_env
    run_iso iso_gate_disposition precommit_gherkin
    tc_assert_eq "warn" "$OUT" "override: precommit_gherkin lowered to warn"
    run_iso iso_gate_disposition pretooluse_test_first
    tc_assert_eq "off" "$OUT" "override: pretooluse_test_first lowered to off"
    run_iso iso_gate_disposition precommit_test_first
    tc_assert_eq "block" "$OUT" "override: a new gate with no entry keeps block"
}

# The override forms a project may already record: a comment line in
# the block, a quoted value with a trailing comment, a value the table
# does not know, and a gate key outside the gate_overrides block.
case_override_forms_kept() {
    tc_setup_repo
    tc_config_append <<'EOF'
project_profile: full
gate_overrides:
  # lowered for the pilot
  precommit_lint: "info" # recorded at review
  precommit_traceability: sometimes
sysml_toolchain: opensysml
precommit_gherkin: off
EOF
    tc_env
    run_iso iso_gate_disposition precommit_lint
    tc_assert_eq "info" "$OUT" "override: a quoted value with a comment applies"
    run_iso iso_gate_disposition precommit_traceability
    tc_assert_eq "block" "$OUT" "override: an unknown value falls back to the profile default"
    tc_assert_grep "Unrecognised gate_overrides.precommit_traceability value 'sometimes'" "$ERR" \
        "override: an unknown value is reported"
    run_iso iso_gate_disposition precommit_gherkin
    tc_assert_eq "block" "$OUT" "override: a gate key outside gate_overrides is ignored"
}

# --------------------------------------------------- config location

case_vse_iso_config_wins() {
    local alt
    tc_setup_repo
    tc_config light -
    alt="$(tc_mktemp_d)/alt-config.yaml"
    printf 'project_profile: full\n' > "$alt"

    tc_env VSE_ISO_CONFIG="$alt"
    run_iso iso_config_path
    tc_assert_eq "$alt" "$OUT" "VSE_ISO_CONFIG: names the configuration file"
    run_iso iso_profile
    tc_assert_eq "full" "$OUT" "VSE_ISO_CONFIG: the profile comes from that file"

    tc_env VSE_ISO_CONFIG="${alt}.missing"
    run_iso iso_profile
    tc_assert_eq "light" "$OUT" "VSE_ISO_CONFIG: an unreadable file falls back to the search"
    tc_env
}

# ---------------------------------------------------- section readers

case_section_scalar_quoted_hash() {
    tc_setup_repo
    tc_config light -
    tc_config_append <<'EOF'
test_first:
  applies: true   # judgement per section 11
  rationale: "pytest # under tests" # why
  test_command: 'make test # all'
  scenario_command: behave stories # optional
EOF
    tc_env
    run_iso iso_section_scalar test_first rationale
    tc_assert_eq "pytest # under tests" "$OUT" "section scalar: a # inside double quotes is kept"
    run_iso iso_section_scalar test_first test_command
    tc_assert_eq "make test # all" "$OUT" "section scalar: a # inside single quotes is kept"
    run_iso iso_section_scalar test_first scenario_command
    tc_assert_eq "behave stories" "$OUT" "section scalar: a # after an unquoted value starts a comment"
    run_iso iso_section_scalar test_first applies
    tc_assert_eq "true" "$OUT" "section scalar: a plain value with a comment"
}

# Exactly one layer of quotes comes off, and only a matching pair that
# wraps the whole value. Quotes inside a plain value belong to it, so a
# test command such as pytest -k "not slow" reaches the shell intact.
case_section_scalar_one_quote_layer() {
    tc_setup_repo
    tc_config light -
    tc_config_append <<'EOF'
test_first:
  test_command: pytest -k "not slow"
  rationale: "'x'"
  scenario_command: "say 'hi'"
EOF
    tc_env
    run_iso iso_section_scalar test_first test_command
    tc_assert_eq 'pytest -k "not slow"' "$OUT" "section scalar: quotes inside a plain value are kept"
    run_iso iso_section_scalar test_first rationale
    tc_assert_eq "'x'" "$OUT" "section scalar: only the outer pair of quotes is removed"
    run_iso iso_section_scalar test_first scenario_command
    tc_assert_eq "say 'hi'" "$OUT" "section scalar: a quote of the other kind at the end is kept"
    run_iso_bytes iso_section_scalar test_first absent_key
    tc_assert_eq "0" "$OUT" "section scalar: a missing key prints nothing"
}

case_section_list_inline_quoted() {
    local expected
    tc_setup_repo
    tc_config light -
    tc_config_append <<'EOF'
test_first:
  code_paths: [src/*, "b c", 'd',  "x # y" , scripts/*.sh]  # globs
EOF
    expected='src/*
b c
d
x # y
scripts/*.sh'
    tc_env
    run_iso iso_section_list test_first code_paths
    tc_assert_eq "$expected" "$OUT" "section list: one item per line, quotes and spaces stripped"
    tc_assert_rc 0 "section list: exit 0"
}

case_section_list_missing_key_empty() {
    tc_setup_repo
    tc_config light -
    tc_config_append <<'EOF'
test_first:
  applies: false
other:
  test_paths: [elsewhere/*]
test_paths: [top/*]
EOF
    tc_env
    run_iso iso_section_list test_first test_paths
    tc_assert_empty "$OUT" "section list: a key under another section is not read"
    tc_assert_rc 0 "section list: a missing key exits 0"
    run_iso iso_section_list absent code_paths
    tc_assert_empty "$OUT" "section list: a missing section prints nothing"
    tc_assert_rc 0 "section list: a missing section exits 0"
    run_iso iso_section_scalar other test_paths
    tc_assert_eq "[elsewhere/*]" "$OUT" "section scalar: reads the named section only"

    rm -f "${REPO}/.iso-config.yaml"
    run_iso iso_section_list test_first code_paths
    tc_assert_empty "$OUT" "section list: no configuration file prints nothing"
    tc_assert_rc 0 "section list: no configuration file exits 0"
}

# ---------------------------------------------------- top-level reader

case_scalar_quoted_hash_kept() {
    tc_setup_repo
    tc_config_append <<'EOF'
project_profile: "full" # recorded at kickoff
label: "a # b" # trailing
owner: the team's call # an apostrophe opens no quote
EOF
    tc_env
    run_iso _iso_scalar label
    tc_assert_eq "a # b" "$OUT" "top-level scalar: a # inside quotes is kept"
    run_iso _iso_scalar owner
    tc_assert_eq "the team's call" "$OUT" "top-level scalar: an apostrophe inside a plain value opens no quote"
    run_iso iso_profile
    tc_assert_eq "full" "$OUT" "top-level scalar: a quoted profile with a comment still reads"
}

# The top-level reader follows the same rule as the section reader:
# one matching pair of outer quotes comes off, and nothing else.
case_scalar_one_quote_layer() {
    tc_setup_repo
    tc_config_append <<'EOF'
project_profile: light
command: pytest -k "not slow"
nested: "'x'"
EOF
    tc_env
    run_iso _iso_scalar command
    tc_assert_eq 'pytest -k "not slow"' "$OUT" "top-level scalar: quotes inside a plain value are kept"
    run_iso _iso_scalar nested
    tc_assert_eq "'x'" "$OUT" "top-level scalar: only the outer pair of quotes is removed"
    run_iso_bytes _iso_scalar absent_key
    tc_assert_eq "0" "$OUT" "top-level scalar: a missing key prints nothing"
}

case_crlf_config_read() {
    tc_setup_repo
    printf 'project_profile: full\r\ntest_first:\r\n  test_paths: [tests/*, "spec/*"]\r\n\r\n  applies: true\r\n' \
        > "${REPO}/.iso-config.yaml"
    tc_env
    run_iso iso_profile
    tc_assert_eq "full" "$OUT" "CRLF: the profile reads without the carriage return"
    run_iso iso_section_list test_first test_paths
    tc_assert_eq "tests/*
spec/*" "$OUT" "CRLF: list items carry no carriage return"
    run_iso iso_section_scalar test_first applies
    tc_assert_eq "true" "$OUT" "CRLF: a blank CRLF line does not end the section"
}

case_new_gates_block_every_profile
case_override_lowers_new_gate
case_override_forms_kept
case_vse_iso_config_wins
case_section_scalar_quoted_hash
case_section_scalar_one_quote_layer
case_section_list_inline_quoted
case_section_list_missing_key_empty
case_scalar_quoted_hash_kept
case_scalar_one_quote_layer
case_crlf_config_read

if tc_summary "test-iso-profile"; then
    exit 0
fi
exit 1
