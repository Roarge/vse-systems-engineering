#!/usr/bin/env bash
# Behavioural tests for hooks/post-checkout.sh, the project-side git
# hook that reports the branch after a branch switch (hooks guide §4.6).
#
# git runs the hook at the top level of the repository. The hook
# locates the project as the lifecycle hooks do: through its
# .iso-config.yaml, the canonical project marker, with
# vse_tf_locate_workdir (the top level, then engineering/ below it). A
# methodology/ or engineering/methodology/ folder still marks a project
# without a configuration, and is all the hook can go on when no copy of
# its libraries is readable. Outside a project the hook is silent.
#
# Every case asserts exit 0, because the hook is advisory. The GitHub
# command-line tool is a stub that lists pull request 7, so no case
# reaches the network.
#
# Run: bash tests/hooks/test-post-checkout.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

ON_MAIN="[post-checkout] On main."

# pc_repo: a scratch repository on main with one commit, the hook
# installed beside its libraries, and a gh stub.
pc_repo() {
    tc_setup_repo
    tc_install_githook post-checkout
    printf '# Scratch project\n' | tc_write README.md
    tc_stage README.md
    tc_commit "chore: start the project"
    tc_stub gh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '7\n'
EOF
    tc_env
}

# pc_run [flag]: run the hook the way git runs it after a checkout.
# The flag is 1 for a branch checkout (the default), 0 for a file
# checkout.
pc_run() {
    local head
    head="$(git -C "$REPO" rev-parse HEAD)"
    tc_run_githook post-checkout "$head" "$head" "${1:-1}"
}

# pc_assert_reports <case>: the hook reported the branch.
pc_assert_reports() {
    tc_assert_rc 0 "$1: exit 0"
    tc_assert_line "$ON_MAIN" "$OUT" "$1: the branch is reported"
}

# pc_assert_silent <case>: the hook said nothing.
pc_assert_silent() {
    tc_assert_rc 0 "$1: exit 0"
    tc_assert_empty "$OUT" "$1: the hook is silent"
}

# ------------------------------------------- located by the configuration

# A project that holds only its .iso-config.yaml is a VSE project.
case_config_only() {
    pc_repo
    printf 'project_profile: light\n' | tc_write .iso-config.yaml
    pc_run
    pc_assert_reports "config only"

    git -C "$REPO" checkout -q -b story/US_001_Readings
    pc_run
    tc_assert_line "[post-checkout] Now on story/US_001_Readings. Story branch." "$OUT" \
        "config only: a story branch is reported"
    tc_assert_line "  Draft PR open." "$OUT" "config only: the open pull request is reported"
}

# A brownfield project keeps its configuration under engineering/.
case_brownfield_config() {
    pc_repo
    printf 'project_profile: light\n' | tc_write engineering/.iso-config.yaml
    pc_run
    pc_assert_reports "brownfield configuration"
}

# The libraries come from the plugin when the project holds no copy.
case_plugin_libraries() {
    pc_repo
    printf 'project_profile: light\n' | tc_write .iso-config.yaml
    rm -rf "${REPO}/.githooks/lib"
    tc_env CLAUDE_PLUGIN_ROOT="$TC_PLUGIN_ROOT"
    pc_run
    pc_assert_reports "plugin libraries"
}

# In the plugin repository only a configuration under demo/ marks a
# project, as at the gates, so the shipped template is not one.
case_contributor_mode() {
    pc_repo
    printf '# Wiki schema\n' | tc_write wiki/CLAUDE.md
    printf 'project_profile: full\n' | tc_write .iso-config.yaml
    pc_run
    pc_assert_silent "contributor mode"
}

# ---------------------------------------------------- kept behaviour

# A methodology/ folder with no configuration still marks a project, in
# both layouts, also when no copy of the libraries is readable.
case_methodology_fallback() {
    pc_repo
    mkdir -p "${REPO}/methodology"
    pc_run
    pc_assert_reports "methodology fallback"

    pc_repo
    mkdir -p "${REPO}/engineering/methodology"
    pc_run
    pc_assert_reports "engineering/methodology fallback"

    pc_repo
    mkdir -p "${REPO}/methodology"
    rm -rf "${REPO}/.githooks/lib"
    pc_run
    pc_assert_reports "methodology fallback without libraries"
}

case_outside() {
    pc_repo
    pc_run
    pc_assert_silent "outside a project"
}

case_file_checkout() {
    pc_repo
    printf 'project_profile: light\n' | tc_write .iso-config.yaml
    pc_run 0
    pc_assert_silent "file checkout"
}

case_config_only
case_brownfield_config
case_plugin_libraries
case_contributor_mode
case_methodology_fallback
case_outside
case_file_checkout

if tc_summary "test-post-checkout"; then
    exit 0
fi
exit 1
