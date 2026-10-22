#!/usr/bin/env bash
# Behavioural tests for hooks/commit-msg.sh: where the Change Request
# gate (commit_msg_cr_reference) finds the project configuration.
#
# The gate reads baselined_paths from .iso-config.yaml. It finds the
# file through iso_config_path in hooks/lib/iso-profile.sh, so it reads
# the same file as the dispositions do: VSE_ISO_CONFIG when it names a
# readable file, otherwise the greenfield layout at the repository root,
# otherwise the brownfield layout under engineering/. Without the
# library (a partial install) the hook makes the same search itself.
#
# Run: bash tests/hooks/test-commit-msg.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

# A configuration that baselines docs/baseline/ and blocks a commit
# that changes it without a 'CR #<n>' reference.
baseline_config() {
    cat <<'EOF'
project_profile: standard
gate_overrides:
  commit_msg_cr_reference: block
baselined_paths:
  - docs/baseline
EOF
}

# Install the hook, stage a change to a baselined file, and write a
# conventional message that references no Change Request.
setup_commit() {
    tc_setup_repo
    tc_install_githook commit-msg
    tc_write docs/baseline/plan.md <<'EOF'
# Plan
EOF
    tc_stage docs/baseline/plan.md
    MSG_FILE="${FAKEHOME}/COMMIT_EDITMSG"
    printf 'docs: update the plan\n' > "$MSG_FILE"
}

case_cr_root_config() {
    setup_commit
    baseline_config | tc_write .iso-config.yaml
    tc_env
    tc_run_githook commit-msg "$MSG_FILE"
    tc_assert_rc 1 "root configuration: the commit without a CR reference is stopped"
    tc_assert_line "[commit-msg] This commit modifies baselined artefacts but the message does not" "$ERR" \
        "root configuration: the finding is stated"
}

case_cr_brownfield_config() {
    setup_commit
    baseline_config | tc_write engineering/.iso-config.yaml
    tc_env
    tc_run_githook commit-msg "$MSG_FILE"
    tc_assert_rc 1 "brownfield configuration: the commit without a CR reference is stopped"
}

# VSE_ISO_CONFIG names a file outside both standard places, and a root
# configuration that baselines nothing is present too. The named file
# wins, for the baselined paths as it already did for the disposition.
case_cr_vse_iso_config() {
    setup_commit
    printf 'project_profile: standard\n' | tc_write .iso-config.yaml
    baseline_config | tc_write config/vse.yaml
    tc_env "VSE_ISO_CONFIG=${REPO}/config/vse.yaml"
    tc_run_githook commit-msg "$MSG_FILE"
    tc_assert_rc 1 "VSE_ISO_CONFIG: its baselined paths are read"
    tc_assert_grep "docs/baseline/plan.md" "$ERR" "VSE_ISO_CONFIG: the baselined file is named"
}

# Without the library every gate warns, and the configuration is still
# found, in the standard places and through VSE_ISO_CONFIG.
case_cr_stub_library_root_config() {
    setup_commit
    rm -f "${REPO}/.githooks/lib/iso-profile.sh"
    baseline_config | tc_write .iso-config.yaml
    tc_env
    tc_run_githook commit-msg "$MSG_FILE"
    tc_assert_rc 0 "partial install, root configuration: the stub warns"
    tc_assert_grep "[commit-msg] warning: This commit modifies baselined artefacts" "$ERR" \
        "partial install, root configuration: the finding is a warning"
}

case_cr_stub_library_vse_iso_config() {
    setup_commit
    rm -f "${REPO}/.githooks/lib/iso-profile.sh"
    baseline_config | tc_write config/vse.yaml
    tc_env "VSE_ISO_CONFIG=${REPO}/config/vse.yaml"
    tc_run_githook commit-msg "$MSG_FILE"
    tc_assert_rc 0 "partial install, VSE_ISO_CONFIG: the stub warns"
    tc_assert_grep "[commit-msg] warning: This commit modifies baselined artefacts" "$ERR" \
        "partial install, VSE_ISO_CONFIG: the named file is read"
}

# The reference sits in the subject and the body runs on for more than
# a pipe buffer holds (64 KiB). The whole message is read, so the
# reference is found every time.
case_cr_reference_in_long_message() {
    setup_commit
    baseline_config | tc_write .iso-config.yaml
    {
        printf 'docs: update the plan (CR #12)\n\n'
        awk 'BEGIN { for (i = 1; i <= 10000; i++) printf "Line %05d of a long body.\n", i }'
    } > "$MSG_FILE"
    tc_env
    tc_run_githook commit-msg "$MSG_FILE"
    tc_assert_rc 0 "long message: the CR reference in the subject is found"
    tc_assert_not_grep "does not" "$ERR" "long message: no missing-reference finding"
}

MSG_FILE=""
case_cr_root_config
case_cr_brownfield_config
case_cr_vse_iso_config
case_cr_stub_library_root_config
case_cr_stub_library_vse_iso_config
case_cr_reference_in_long_message

if tc_summary "test-commit-msg"; then
    exit 0
fi
exit 1
