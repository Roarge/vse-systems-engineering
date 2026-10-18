#!/usr/bin/env bash
# Behavioural tests for the lifecycle hooks that know only the session's
# working directory: hooks/user-prompt-submit.sh (hooks guide §5.2),
# hooks/pre-compact.sh (§5.7) and hooks/notification.sh (§5.8).
#
# Each hook locates the project as SessionStart does: through its
# .iso-config.yaml, the canonical project marker, with
# vse_tf_locate_workdir (from the working directory up to the git top
# level, then from engineering/ below it), and in the plugin repository
# only a configuration under demo/ counts. A methodology/ or
# engineering/methodology/ folder in the working directory still marks
# a project without a configuration, and is all a hook can go on when
# its libraries are missing. Outside a project each hook is silent.
#
# Every case asserts exit 0, because the three hooks are advisory. The
# GitHub command-line tool is a stub that lists one Change Request open
# for 30 days, so the Notification reminder has something to say and
# no case reaches the network. The PreCompact snapshot is written under
# a scratch TMPDIR.
#
# Run: bash tests/hooks/test-workdir-hooks.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

# The scratch repository is not used here, but its fake HOME and stub
# directory keep the machine's own tools out of reach.
tc_setup_repo
trap tc_teardown EXIT

SNAP_TMP="$(tc_mktemp_d)"
STALE_DATE="$(date -u -d '30 days ago' +%Y-%m-%dT%H:%M:%SZ)"
tc_stub gh <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '[{"number":7,"createdAt":"%s"}]\n' "${STALE_DATE}"
EOF

PROMPT_JSON='{"prompt":"update the risk register","hook_event_name":"UserPromptSubmit"}'

# What each hook prints when it acts in a project.
FIRES_user_prompt_submit="[methodology reminder, PM.O3]"
FIRES_pre_compact="[VSE state snapshot saved to "
FIRES_notification="[VSE notification] 1 Change Request(s) open >14 days."

# run_workdir <hook-basename> <dir> [<hook-root>]: run the hook in <dir>
# the way the harness does, with the prompt payload on stdin. The hook
# root defaults to the plugin.
run_workdir() {
    local hook="$1" dir="$2" root="${3:-${TC_PLUGIN_ROOT}}" TC_STDIN
    TC_STDIN="$(mktemp "${TC_ROOT}/stdin.XXXXXX")"
    printf '%s' "$PROMPT_JSON" > "$TC_STDIN"
    tc_env "TMPDIR=${SNAP_TMP}"
    tc_run_in "$dir" CLAUDE_PLUGIN_ROOT="$root" bash "${root}/hooks/${hook}.sh"
    tc_env
    rm -f "$TC_STDIN"
}

fires_text() {
    case "$1" in
        user-prompt-submit) printf '%s\n' "$FIRES_user_prompt_submit" ;;
        pre-compact) printf '%s\n' "$FIRES_pre_compact" ;;
        notification) printf '%s\n' "$FIRES_notification" ;;
    esac
}

# assert_fires <hook> <dir> <case> [<hook-root>]
assert_fires() {
    local hook="$1" dir="$2" name="$3" root="${4:-}"
    run_workdir "$hook" "$dir" ${root:+"$root"}
    tc_assert_rc 0 "${hook}, ${name}: exit 0"
    tc_assert_grep "$(fires_text "$hook")" "$OUT" "${hook}, ${name}: the hook acts"
}

# assert_silent <hook> <dir> <case> [<hook-root>]
assert_silent() {
    local hook="$1" dir="$2" name="$3" root="${4:-}"
    run_workdir "$hook" "$dir" ${root:+"$root"}
    tc_assert_rc 0 "${hook}, ${name}: exit 0"
    tc_assert_empty "$OUT" "${hook}, ${name}: the hook is silent"
}

# snapshot_line <prefix>: the line of the last snapshot that starts with
# <prefix>, read from the path the PreCompact hook printed.
snapshot_line() {
    local path
    path="$(printf '%s\n' "$OUT" | sed -n 's/^\[VSE state snapshot saved to \(.*\)\]$/\1/p')"
    if [ -n "$path" ] && [ -r "$path" ]; then
        grep -F -- "$1" "$path" | head -n 1
    fi
}

HOOKS="user-prompt-submit pre-compact notification"

# ------------------------------------------- located by the configuration

# A directory that holds only a .iso-config.yaml is a VSE project.
case_config_only() {
    local dir hook
    dir="$(tc_mktemp_d)"
    printf 'project_profile: light\n' > "${dir}/.iso-config.yaml"
    for hook in $HOOKS; do
        assert_fires "$hook" "$dir" "config only"
    done
    run_workdir pre-compact "$dir"
    tc_assert_eq "Engineering root: ." "$(snapshot_line "Engineering root:")" \
        "pre-compact, config only: the snapshot names the working directory"
}

# A session started below the project directory finds the project by
# walking up, as the gates do from an edited file.
case_from_subdirectory() {
    local top real hook
    top="$(tc_mktemp_d)"
    git init -q "$top"
    real="$(cd "$top" && pwd -P)"
    mkdir -p "${top}/src/deep"
    printf 'project_profile: light\n' > "${top}/.iso-config.yaml"
    for hook in $HOOKS; do
        assert_fires "$hook" "${top}/src/deep" "subdirectory"
    done
    run_workdir pre-compact "${top}/src/deep"
    tc_assert_eq "Engineering root: ${real}/" "$(snapshot_line "Engineering root:")" \
        "pre-compact, subdirectory: the snapshot names the project above"
}

# A brownfield project below its git top level is found from its own
# root, through engineering/.iso-config.yaml.
case_nested_brownfield() {
    local top proj hook
    top="$(tc_mktemp_d)"
    git init -q "$top"
    proj="${top}/projects/sensor"
    mkdir -p "${proj}/engineering"
    printf 'project_profile: full\n' > "${proj}/engineering/.iso-config.yaml"
    for hook in $HOOKS; do
        assert_fires "$hook" "$proj" "nested brownfield"
    done
    run_workdir pre-compact "$proj"
    tc_assert_eq "Engineering root: engineering/" "$(snapshot_line "Engineering root:")" \
        "pre-compact, nested brownfield: the snapshot names engineering/"
}

# In the plugin repository only a configuration under demo/ marks a
# project, as at the gates, so the shipped template is not one.
case_contributor_mode() {
    local top hook
    top="$(tc_mktemp_d)"
    git init -q "$top"
    mkdir -p "${top}/templates/iso-config" "${top}/demo/smart-sensor"
    tc_mark_plugin_repo "$top"
    printf 'project_profile: full\n' > "${top}/templates/iso-config/.iso-config.yaml"
    printf 'project_profile: full\n' > "${top}/demo/smart-sensor/.iso-config.yaml"
    for hook in $HOOKS; do
        assert_silent "$hook" "${top}/templates/iso-config" "contributor template"
        assert_fires "$hook" "${top}/demo/smart-sensor" "contributor demo"
    done
}

# ---------------------------------------------------- kept behaviour

# A methodology/ folder with no configuration still marks a project, in
# both layouts, as before the configuration existed.
case_methodology_fallback() {
    local green brown hook
    green="$(tc_mktemp_d)"
    mkdir -p "${green}/methodology"
    brown="$(tc_mktemp_d)"
    mkdir -p "${brown}/engineering/methodology"
    for hook in $HOOKS; do
        assert_fires "$hook" "$green" "methodology fallback"
        assert_fires "$hook" "$brown" "engineering/methodology fallback"
    done
    run_workdir pre-compact "$brown"
    tc_assert_eq "Engineering root: engineering/" "$(snapshot_line "Engineering root:")" \
        "pre-compact, engineering/methodology fallback: the snapshot names engineering/"
}

# Outside every project each hook is silent.
case_outside() {
    local dir hook
    dir="$(tc_mktemp_d)"
    mkdir -p "${dir}/src"
    for hook in $HOOKS; do
        assert_silent "$hook" "$dir" "outside a project"
    done
}

# An install with no hooks/lib/ still runs each hook: the methodology/
# folder marks the project, and a configuration alone cannot be read,
# so the hook stays silent rather than failing.
case_library_missing() {
    local root green config hook
    root="$(tc_mktemp_d)"
    mkdir -p "${root}/hooks"
    for hook in $HOOKS; do
        cp "${TC_PLUGIN_ROOT}/hooks/${hook}.sh" "${root}/hooks/${hook}.sh"
    done
    green="$(tc_mktemp_d)"
    mkdir -p "${green}/methodology"
    config="$(tc_mktemp_d)"
    printf 'project_profile: light\n' > "${config}/.iso-config.yaml"
    for hook in $HOOKS; do
        assert_fires "$hook" "$green" "library missing, methodology folder" "$root"
        assert_silent "$hook" "$config" "library missing, configuration only" "$root"
    done
}

case_config_only
case_from_subdirectory
case_nested_brownfield
case_contributor_mode
case_methodology_fallback
case_outside
case_library_missing

if tc_summary "test-workdir-hooks"; then
    exit 0
fi
exit 1
