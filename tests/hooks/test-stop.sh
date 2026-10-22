#!/usr/bin/env bash
# Behavioural tests for hooks/stop.sh and hooks/subagent-stop.sh, the
# Stop and SubagentStop lifecycle hooks (hooks guide §5.5 and §5.6).
#
# At Stop and SubagentStop, additionalContext makes Claude carry on
# with the turn, under the same loop protections as a block: the
# harness sets stop_hook_active in the next payload, and caps the
# number of consecutive continuations. So these hooks must never say
# the same thing twice. Each case builds a scratch project, feeds the
# hook the JSON payload Claude Code sends when the agent (or a
# subagent) ends its turn, and reads the one object the hook prints.
# Five groups of behaviour are pinned:
#
#   1. Silence while stop_hook_active is true, for both events.
#   2. The test-first finding (code changed in the working tree, no
#      test change, test_first.applies true) goes out as
#      additionalContext once for each session and state of the
#      working tree, tracked by a marker file under $TMPDIR. Stop and
#      SubagentStop keep separate markers, so a subagent never uses up
#      the main agent's finding.
#   3. Every other reminder goes out as a top-level systemMessage,
#      which the user sees and which does not continue the turn, also
#      once for each session and state. The marker records the
#      reminders and the finding apart, so a finding that falls due in
#      a state where only a reminder went out is still sent once. Only
#      Stop carries the ADR and SR.O7 reminders, and the SubagentStop
#      note names the project's methodology/ folder, else the plugin's
#      copy.
#   4. The marker never lands outside $TMPDIR, and a marker that cannot
#      be recorded turns the finding into a systemMessage.
#   5. Locating the project from the payload's cwd, and the output
#      contract: one object or nothing, exit 0 always.
#
# Run: bash tests/hooks/test-stop.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

# The scratch TMPDIR the hooks keep their markers in, one per project.
STOP_TMP=""

# PATH values that take jq, python3 or both out of reach.
STOP_BIN_NO_JQ="$(tc_bin_without jq)"
STOP_BIN_NO_JSON="$(tc_bin_without jq python3)"

# ------------------------------------------------------------- fixtures

# stop_project [profile] [spec ...]: a fresh scratch repository with a
# configuration at its top level, committed on main, and a scratch
# TMPDIR for the hook's markers.
stop_project() {
    local profile="${1:-light}"
    shift || true
    tc_setup_repo
    STOP_TMP="$(tc_mktemp_d)"
    tc_env TMPDIR="$STOP_TMP"
    tc_config "$profile" - "$@"
    git -C "$REPO" add -A
    tc_commit "chore: start the project"
}

# stop_test_first_project [profile] [spec ...]: a project where test
# first applies to src/ with tests under tests/, and src/reading.py has
# changed in the working tree with no test change.
stop_test_first_project() {
    stop_project "$@"
    tc_config_append <<'EOF'
test_first:
  applies: true
  rationale: "pytest runs the code under src/."
  test_command: "pytest -q"
  code_paths: [src/*]
  test_paths: [tests/*]
EOF
    git -C "$REPO" add -A
    tc_commit "chore: record test first"
    printf 'x = 1\n' | tc_write src/reading.py
}

# ------------------------------------------------------------- payloads

# stop_json <event> [active] [session] [cwd]
stop_json() {
    jq -n -c --arg e "$1" --argjson a "${2:-false}" --arg s "${3:-session-1}" \
        --arg cwd "${4:-$REPO}" \
        '{session_id: $s, transcript_path: "/dev/null", cwd: $cwd,
          hook_event_name: $e, stop_hook_active: $a}'
}

# ------------------------------------------------------------- runners

stop_run() {
    tc_run_lifecycle stop "$(stop_json Stop "$@")"
}

subagent_run() {
    tc_run_lifecycle subagent-stop "$(stop_json SubagentStop "$@")"
}

# stop_run_from <dir> <json>: run the Stop hook with <dir> as its
# working directory.
stop_run_from() {
    local dir="$1" TC_STDIN
    TC_STDIN="$(mktemp "${TC_ROOT}/stdin.XXXXXX")"
    printf '%s' "$2" > "$TC_STDIN"
    tc_run_in "$dir" CLAUDE_PLUGIN_ROOT="$TC_PLUGIN_ROOT" \
        "${TC_PLUGIN_ROOT}/hooks/stop.sh"
    rm -f "$TC_STDIN"
}

# ----------------------------------------------------------- assertions

# stop_assert_finding <event> <case>: one object whose context carries
# the test-first finding.
stop_assert_finding() {
    tc_assert_rc 0 "$2: exit 0"
    tc_assert_json ".hookSpecificOutput.hookEventName == \"$1\"
        and (.hookSpecificOutput.additionalContext // \"\" | contains(\"Test first\"))" "$2"
}

# stop_assert_no_context <case>: nothing at all, or an object with no
# additionalContext, so the turn is not continued.
stop_assert_no_context() {
    tc_assert_rc 0 "$1: exit 0"
    if [ -z "$OUT" ]; then
        tc_pass "$1"
    else
        tc_assert_json '.hookSpecificOutput.additionalContext == null' "$1"
    fi
}

# ------------------------------------------------ 1. stop_hook_active

case_stop_hook_active_silent() {
    stop_test_first_project light
    printf 'part def Sensor;\n' | tc_write model/core/logical-architecture/sensor.sysml
    stop_run true
    tc_assert_rc 0 "active: exit 0"
    tc_assert_json_silent "active: the Stop hook is silent while a stop hook is active"
    tc_assert_eq "" "$(ls -A "$STOP_TMP")" "active: no marker is written while a stop hook is active"

    stop_run false
    stop_assert_finding Stop "active: the same state draws the finding once the flag is false"
    tc_assert_json '.systemMessage | contains("Architectural")' \
        "active: the same state draws the reminder once the flag is false"
}

case_subagent_stop_active_silent() {
    stop_test_first_project light
    subagent_run true
    tc_assert_rc 0 "subagent active: exit 0"
    tc_assert_json_silent "subagent active: the SubagentStop hook is silent while a stop hook is active"

    subagent_run false
    stop_assert_finding SubagentStop "subagent: the finding names the SubagentStop event"
    tc_assert_json '.systemMessage | contains("Subagent complete")' \
        "subagent: the completion note reaches the user as a systemMessage"
}

# ---------------------------------------------- 2. once for each state

case_stop_once_per_state() {
    local marker
    stop_test_first_project light
    stop_run false session-1
    stop_assert_finding Stop "once: the first stop in a state draws the finding"
    tc_assert_json '.hookSpecificOutput.additionalContext | contains("src/reading.py")' \
        "once: the finding names the changed code path"
    tc_assert_json '.hookSpecificOutput.additionalContext | contains("pytest -q")' \
        "once: the finding names the recorded test_command"
    marker="${STOP_TMP}/vse-stop.session-1"
    if [ -f "$marker" ]; then
        tc_pass "once: the marker is ${STOP_TMP}/vse-stop.<session_id>"
    else
        tc_fail "once: the marker is ${STOP_TMP}/vse-stop.<session_id>" "$(ls -la "$STOP_TMP")"
    fi

    stop_run false session-1
    stop_assert_no_context "once: a second stop in the same state draws no finding"

    printf 'y = 2\n' | tc_write src/sensor.py
    stop_run false session-1
    stop_assert_finding Stop "once: a stop in a new state draws the finding again"

    rm -f "${REPO}/src/sensor.py"
    stop_run false session-1
    stop_assert_no_context "once: a state seen before in the session draws no finding"

    stop_run false session-2
    stop_assert_finding Stop "once: another session in the same state draws the finding"
    stop_run false session-2
    stop_assert_no_context "once: the other session keeps its own marker"

    subagent_run false session-3
    stop_assert_finding SubagentStop "once: a subagent stop draws the finding once"
    if [ -f "${STOP_TMP}/vse-subagent-stop.session-3" ]; then
        tc_pass "once: the SubagentStop marker is ${STOP_TMP}/vse-subagent-stop.<session_id>"
    else
        tc_fail "once: the SubagentStop marker is ${STOP_TMP}/vse-subagent-stop.<session_id>" "$(ls -la "$STOP_TMP")"
    fi
    subagent_run false session-3
    stop_assert_no_context "once: a second subagent stop in the same state draws no finding"
    stop_run false session-3
    stop_assert_finding Stop "once: a subagent's finding does not use up the main agent's"
    stop_run false session-3
    stop_assert_no_context "once: the main agent then has its own finding once"

    git -C "$REPO" add src/reading.py
    tc_commit "feat: read"
    printf 'z = 3\n' | tc_write src/reading.py
    stop_run false session-1
    stop_assert_finding Stop "once: a new commit makes a new state"
}

case_stop_finding_conditions() {
    stop_test_first_project light
    printf 'def test_reading():\n    assert False\n' | tc_write tests/test_reading.py
    stop_run
    stop_assert_no_context "conditions: a test change in the working tree is evidence"

    stop_test_first_project light
    git -C "$REPO" checkout -q -b feat/readings
    printf 'def test_reading():\n    assert False\n' | tc_write tests/test_reading.py
    git -C "$REPO" add tests/test_reading.py
    tc_commit "test: read a value"
    stop_run
    stop_assert_no_context "conditions: a test committed on the branch is evidence"

    stop_test_first_project light
    git -C "$REPO" checkout -q -b refactor/tidy
    stop_run
    stop_assert_no_context "conditions: a refactor branch draws no finding"

    stop_test_first_project light pretooluse_test_first=off
    stop_run
    stop_assert_no_context "conditions: the in-session test-first gate set to off draws no finding"

    # A file named .iso-config.yaml is never code, even below a code
    # path, so the finding agrees with PreToolUse.
    stop_test_first_project light
    rm "${REPO}/src/reading.py"
    printf 'project_profile: light\n' | tc_write src/.iso-config.yaml
    stop_run
    stop_assert_no_context "conditions: a configuration file under a code path draws no finding"

    stop_test_first_project light
    git -C "$REPO" add src/reading.py
    tc_commit "feat: read"
    git -C "$REPO" rm -q src/reading.py
    printf 'z = 1\n' | tc_write docs/notes.py
    stop_run
    stop_assert_no_context "conditions: deleted code and a path outside code_paths draw no finding"

    stop_project light
    tc_config_append <<'EOF'
test_first:
  applies: false
  rationale: "No implementation code."
  code_paths: [src/*]
  test_paths: [tests/*]
EOF
    printf 'x = 1\n' | tc_write src/reading.py
    stop_run
    stop_assert_no_context "conditions: applies false draws no finding"

    stop_project light
    printf 'x = 1\n' | tc_write src/reading.py
    stop_run
    stop_assert_no_context "conditions: an unrecorded test_first draws no finding"
}

# ------------------------------------------------ 3. systemMessage only

case_stop_reminders_are_system_message() {
    stop_project light
    printf 'part def Sensor;\n' | tc_write model/core/logical-architecture/sensor.sysml
    git -C "$REPO" add -A
    tc_commit "feat: add the sensor"
    printf 'part def Sensor { }\n' | tc_write model/core/logical-architecture/sensor.sysml
    stop_run
    tc_assert_rc 0 "system: exit 0"
    tc_assert_json '(.systemMessage | contains("Architectural changes detected"))
        and (.systemMessage | contains("ADR"))
        and .hookSpecificOutput == null' \
        "system: an architecture change draws a systemMessage and no context"

    printf '# VR-001\n' | tc_write docs/verification-reports/VR-001.md
    stop_run
    tc_assert_json '(.systemMessage | contains("Architectural changes detected"))
        and (.systemMessage | contains("SR.O7"))
        and .hookSpecificOutput == null' \
        "system: two reminders share one systemMessage in one object"

    stop_project light
    printf 'part def Sensor;\n' | tc_write engineering/model/variations/sensor.sysml
    rm -f "${REPO}/.iso-config.yaml"
    printf 'project_profile: light\n' | tc_write engineering/.iso-config.yaml
    stop_run
    tc_assert_json '.systemMessage | contains("Architectural changes detected")' \
        "system: a new file under the brownfield engineering root draws the reminder"

    stop_test_first_project light
    printf 'part def Sensor;\n' | tc_write model/variations/sensor.sysml
    stop_run
    tc_assert_json '(.systemMessage | contains("Architectural changes detected"))
        and (.hookSpecificOutput.additionalContext | contains("Test first"))' \
        "system: the finding and a reminder share one object"

    stop_project light
    printf '# Notes\n' | tc_write docs/notes.md
    stop_run
    tc_assert_json_silent "system: a change no reminder covers is silent"
}

# An ordinary reminder reaches the user once for each session and state
# too, so a Stop that repeats in an unchanged working tree is silent.
case_stop_reminders_once_per_state() {
    stop_project light
    printf 'part def Sensor;\n' | tc_write model/core/logical-architecture/sensor.sysml
    stop_run false session-1
    tc_assert_json '.systemMessage | contains("ADR")' "reminders once: the first stop draws the ADR reminder"
    stop_run false session-1
    tc_assert_rc 0 "reminders once: exit 0"
    tc_assert_json_silent "reminders once: a second stop in the same state is silent"
    stop_run false session-2
    tc_assert_json '.systemMessage | contains("ADR")' "reminders once: another session draws it again"

    printf '# VR-001\n' | tc_write docs/verification-reports/VR-001.md
    stop_run false session-1
    tc_assert_json '(.systemMessage | contains("ADR")) and (.systemMessage | contains("SR.O7"))' \
        "reminders once: a new state draws the reminders again"

    subagent_run false session-1
    tc_assert_json '.systemMessage | contains("Subagent complete")' \
        "reminders once: the first subagent stop draws the completion note"
    subagent_run false session-1
    tc_assert_json_silent "reminders once: a second subagent stop in the same state is silent"
    rm -f "${REPO}/docs/verification-reports/VR-001.md"
    subagent_run false session-1
    tc_assert_json '.systemMessage | contains("Subagent complete")' \
        "reminders once: the completion note returns in a new state"
}

# The marker records the reminders and the finding separately. A switch
# from a refactor branch to another branch at the same commit keeps the
# state, but makes the finding due. It goes out once, and the reminders
# already given in that state are not repeated.
case_stop_finding_after_reminder() {
    local event label
    for event in Stop SubagentStop; do
        label="after a reminder (${event})"
        stop_test_first_project light
        printf 'part def Sensor;\n' | tc_write model/core/logical-architecture/sensor.sysml
        git -C "$REPO" checkout -q -b refactor/tidy
        if [ "$event" = "Stop" ]; then stop_run false session-1; else subagent_run false session-1; fi
        tc_assert_json '.systemMessage != null and .hookSpecificOutput == null' \
            "${label}: on the refactor branch only the reminder goes out"
        git -C "$REPO" checkout -q -b feat/x
        if [ "$event" = "Stop" ]; then stop_run false session-1; else subagent_run false session-1; fi
        stop_assert_finding "$event" "${label}: the finding goes out once the branch is not a refactor branch"
        tc_assert_json '.systemMessage == null' "${label}: the reminder already given is not repeated"
        if [ "$event" = "Stop" ]; then stop_run false session-1; else subagent_run false session-1; fi
        tc_assert_rc 0 "${label}: exit 0"
        tc_assert_json_silent "${label}: a third stop in the same state is silent"
    done
}

# The ADR and SR.O7 reminders are for the end of the agent's turn, not
# for each subagent.
case_subagent_stop_no_stop_reminders() {
    stop_project light
    printf 'part def Sensor;\n' | tc_write model/core/logical-architecture/sensor.sysml
    printf '# VR-001\n' | tc_write docs/verification-reports/VR-001.md
    subagent_run false session-1
    tc_assert_json '(.systemMessage | contains("Subagent complete"))
        and (.systemMessage | contains("Architectural") | not)
        and (.systemMessage | contains("SR.O7") | not)' \
        "subagent: no Stop-only reminder at SubagentStop"
}

# The completion note names the project's own methodology/ folder only
# when it exists, else the plugin's copy.
case_subagent_stop_methodology() {
    local eng plugin
    stop_project light
    eng="$(cd "$REPO" && pwd -P)"
    plugin="$(cd "$TC_PLUGIN_ROOT" && pwd -P)"
    subagent_run false session-1
    tc_assert_json ".systemMessage | contains(\"${plugin}/methodology/\")" \
        "subagent methodology: without a project folder the plugin's copy is named"
    tc_assert_json ".systemMessage | contains(\"${eng}/methodology/\") | not" \
        "subagent methodology: a missing project folder is not named"
    mkdir -p "${REPO}/methodology"
    printf '# Overview\n' | tc_write methodology/00-methodology-overview.md
    subagent_run false session-2
    tc_assert_json ".systemMessage | contains(\"${eng}/methodology/\")" \
        "subagent methodology: the project's own folder is named when it exists"
}

# ----------------------------------------------------- 4. the marker

case_stop_marker_stays_in_tmpdir() {
    local outside marker
    stop_test_first_project light
    outside="$(tc_mktemp_d)"
    tc_env TMPDIR="${STOP_TMP}/inner"
    # With vse-stop.x present as a directory, a marker path built from
    # the raw session id x/../../escape would resolve to
    # ${STOP_TMP}/escape, outside TMPDIR.
    mkdir -p "${STOP_TMP}/inner/vse-stop.x"
    stop_run false "x/../../escape"
    stop_assert_finding Stop "tmpdir: a session id holding a path still draws the finding"
    tc_assert_eq "" "$(find "$STOP_TMP" -maxdepth 1 -name '*escape*')" \
        "tmpdir: a session id holding ../ writes nothing outside TMPDIR"
    tc_assert_eq 1 "$(find "${STOP_TMP}/inner" -maxdepth 1 -type f -name 'vse-stop.*escape*' | grep -c '')" \
        "tmpdir: the marker for that session sits in TMPDIR"
    stop_run false "x/../../escape"
    stop_assert_no_context "tmpdir: that session's marker is honoured"

    printf 'keep\n' > "${outside}/target"
    ln -s "${outside}/target" "${STOP_TMP}/inner/vse-stop.linked"
    stop_run false linked
    stop_assert_finding Stop "tmpdir: a marker that is a symbolic link is replaced"
    tc_assert_eq "keep" "$(cat "${outside}/target")" \
        "tmpdir: the file a linked marker pointed at is unchanged"
    if [ -f "${STOP_TMP}/inner/vse-stop.linked" ] && [ ! -L "${STOP_TMP}/inner/vse-stop.linked" ]; then
        tc_pass "tmpdir: the linked marker becomes a plain file in TMPDIR"
    else
        tc_fail "tmpdir: the linked marker becomes a plain file in TMPDIR" "$(ls -la "${STOP_TMP}/inner")"
    fi

    # mv onto a link to a directory would move the marker into that
    # directory, outside TMPDIR.
    mkdir -p "${outside}/dir"
    ln -s "${outside}/dir" "${STOP_TMP}/inner/vse-stop.dirlink"
    stop_run false dirlink
    stop_assert_finding Stop "tmpdir: a marker that is a link to a directory is replaced"
    tc_assert_eq "" "$(ls -A "${outside}/dir")" \
        "tmpdir: nothing is written into the directory a linked marker pointed at"

    mkdir -p "${STOP_TMP}/inner/vse-stop.blocked"
    stop_run false blocked
    tc_assert_rc 0 "tmpdir: exit 0 when the marker cannot be recorded"
    tc_assert_json '.hookSpecificOutput == null and (.systemMessage | contains("Test first"))' \
        "tmpdir: a finding that cannot be recorded goes to the user, not the agent"
}

# ------------------------------------------- 5. location and contract

case_stop_outside_project_silent() {
    local other
    stop_test_first_project light
    other="$(tc_mktemp_d)"
    stop_run_from "$other" "$(stop_json Stop false session-1 "$REPO")"
    stop_assert_finding Stop "location: the project is found from the payload's cwd"

    stop_run_from "$REPO" "$(stop_json Stop false session-9 "$other")"
    tc_assert_json_silent "location: a payload cwd outside any project is silent"

    mkdir -p "${REPO}/src/deep"
    stop_run false session-8 "${REPO}/src/deep"
    stop_assert_finding Stop "location: a cwd below the project still finds its configuration"

    tc_setup_repo
    STOP_TMP="$(tc_mktemp_d)"
    tc_env TMPDIR="$STOP_TMP"
    tc_mark_plugin_repo
    mkdir -p "${REPO}/methodology"
    printf 'part def Sensor;\n' | tc_write model/variations/sensor.sysml
    stop_run
    tc_assert_json_silent "location: the plugin repository root is silent at Stop"
    subagent_run
    tc_assert_json_silent "location: the plugin repository root is silent at SubagentStop"

    printf 'project_profile: light\n' | tc_write templates/iso-config/.iso-config.yaml
    subagent_run false session-1 "${REPO}/templates/iso-config"
    tc_assert_json_silent "location: contributor mode ignores the shipped template configuration"
    printf 'project_profile: light\n' | tc_write demo/smart-sensor/.iso-config.yaml
    subagent_run false session-1 "${REPO}/demo/smart-sensor"
    tc_assert_json '.systemMessage | contains("Subagent complete")' \
        "location: contributor mode counts the demo configuration"
}

# A payload that cannot be read is not an internal error: the hook says
# so in one plain line on stderr and exits 0, silent on stdout.
case_stop_output_contract() {
    stop_test_first_project light
    tc_run_lifecycle stop '{"session_id": "x", "stop_hook_active": '
    tc_assert_rc 0 "contract: a malformed payload exits 0"
    tc_assert_json_silent "contract: a malformed payload is silent"
    tc_assert_grep "[stop] Could not read the Stop payload" "$ERR" \
        "contract: a malformed payload is named in a plain line on stderr"
    tc_assert_not_grep "Internal error" "$ERR" "contract: a malformed payload is not an internal error"
    tc_run_lifecycle subagent-stop '{"session_id": "x", "stop_hook_active": '
    tc_assert_rc 0 "contract: a malformed payload exits 0 at SubagentStop"
    tc_assert_json_silent "contract: a malformed payload is silent at SubagentStop"
    tc_assert_grep "[stop] Could not read the SubagentStop payload" "$ERR" \
        "contract: a malformed payload is named at SubagentStop"
    tc_assert_not_grep "Internal error" "$ERR" "contract: a malformed payload is not an internal error at SubagentStop"

    tc_env TMPDIR="$STOP_TMP" PATH="$STOP_BIN_NO_JQ"
    stop_run false session-py
    stop_assert_finding Stop "contract: without jq, python3 reads the payload and the finding goes out"
    stop_run true session-py2
    tc_assert_json_silent "contract: without jq, stop_hook_active still silences the hook"

    tc_env TMPDIR="$STOP_TMP" PATH="$STOP_BIN_NO_JSON"
    stop_run false session-none
    tc_assert_rc 0 "contract: exit 0 with neither jq nor python3"
    tc_assert_json_silent "contract: with neither jq nor python3 the hook cannot read stop_hook_active and stays silent"
    tc_assert_grep "[stop] Could not read the Stop payload" "$ERR" \
        "contract: a missing JSON engine is named in a plain line on stderr"
    tc_assert_not_grep "Internal error" "$ERR" "contract: a missing JSON engine is not an internal error"
    tc_env TMPDIR="$STOP_TMP"
}

# ------------------------------------------------------------------ run

case_stop_hook_active_silent
case_subagent_stop_active_silent
case_stop_once_per_state
case_stop_finding_conditions
case_stop_reminders_are_system_message
case_stop_reminders_once_per_state
case_stop_finding_after_reminder
case_subagent_stop_no_stop_reminders
case_subagent_stop_methodology
case_stop_marker_stays_in_tmpdir
case_stop_outside_project_silent
case_stop_output_contract

if tc_summary "test-stop"; then
    exit 0
fi
exit 1
