#!/usr/bin/env bash
# Behavioural tests for the two PostToolUse lifecycle hooks:
# hooks/post-tool-use.sh (the methodology follow-up reminders, hooks
# guide §5.4) and hooks/source-added-reminder.sh (the contributor-only
# wiki reminder).
#
# Each case builds a scratch project, feeds the hook the JSON payload
# Claude Code sends after an Edit, Write, MultiEdit or NotebookEdit
# call, and reads what the hook prints. Claude never sees plain stdout
# at PostToolUse, so every reminder must arrive as exactly one JSON
# object carrying hookSpecificOutput.additionalContext, and a hook with
# nothing to say prints nothing. Four groups of behaviour are pinned:
#
#   1. The reminders after a feature file, a story file and a code path
#      (where test_first.applies is true), and the older ones after a
#      concern, an architecture file and the Project Plan.
#   2. Locating the project. The configuration is found by walking up
#      from the edited file, and contributor mode (the plugin
#      repository) counts only the demo.
#   3. The output contract. One object or nothing, never a decision,
#      and exit 0 always.
#   4. The wiki reminder after a file under sources/, with the LOG.md
#      stub appended once a day, only in the plugin repository.
#
# Run: bash tests/hooks/test-post-tool-use.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

POST_STORIES="model/core/stories/stakeholder"

# The phrases the reminders carry, with their code in backticks, which
# stay literal inside single quotes.
# shellcheck disable=SC2016
POST_MIRROR='mirror each `@AC_` tag as a nested criterion in the story'
# shellcheck disable=SC2016
POST_AC_TAG='`@AC_` tag'
# shellcheck disable=SC2016
POST_BIND='bind `verify <story>.acceptance.<name>` for new criteria'
# shellcheck disable=SC2016
POST_RUN_PYTEST='run `pytest -q`'

# ------------------------------------------------------------- fixtures

# post_project [profile]: a fresh scratch repository with a
# configuration at its top level.
post_project() {
    tc_setup_repo
    tc_env
    tc_config "${1:-light}" -
}

# post_test_first_project [test_command]: a project where test first
# applies to src/ with tests under tests/, committed on main. An empty
# argument leaves test_command out of the record.
post_test_first_project() {
    local command="${1-pytest -q}"
    post_project light
    {
        printf 'test_first:\n'
        printf '  applies: true\n'
        printf '  rationale: "pytest runs the code under src/."\n'
        if [ -n "$command" ]; then
            printf '  test_command: "%s"\n' "$command"
        fi
        printf '  code_paths: [src/*]\n'
        printf '  test_paths: [tests/*]\n'
    } | tc_config_append
    git -C "$REPO" add -A
    tc_commit "chore: start the project"
}

# ------------------------------------------------------------- payloads

# post_json <tool> <path> [cwd]: the payload after a <tool> call on
# <path>, with the repository as the session's working directory.
post_json() {
    jq -n -c --arg t "$1" --arg p "$2" --arg cwd "${3:-$REPO}" \
        '{session_id: "test", cwd: $cwd, hook_event_name: "PostToolUse",
          tool_name: $t, tool_input: {file_path: $p, content: "x"},
          tool_response: {success: true}}'
}

# post_notebook_json <path>
post_notebook_json() {
    jq -n -c --arg p "$1" --arg cwd "$REPO" \
        '{session_id: "test", cwd: $cwd, hook_event_name: "PostToolUse",
          tool_name: "NotebookEdit",
          tool_input: {notebook_path: $p, new_source: "print(1)"}}'
}

# ------------------------------------------------------------- runners

post_run() {
    tc_run_lifecycle post-tool-use "$1"
}

source_run() {
    tc_run_lifecycle source-added-reminder "$1"
}

# source_run_from <dir> <json>: run the wiki reminder with <dir> as its
# working directory.
source_run_from() {
    local dir="$1" TC_STDIN
    TC_STDIN="$(mktemp "${TC_ROOT}/stdin.XXXXXX")"
    printf '%s' "$2" > "$TC_STDIN"
    tc_run_in "$dir" CLAUDE_PLUGIN_ROOT="$TC_PLUGIN_ROOT" \
        "${TC_PLUGIN_ROOT}/hooks/source-added-reminder.sh"
    rm -f "$TC_STDIN"
}

# ----------------------------------------------------------- assertions

# post_assert_context <fixed-string> <case>: one PostToolUse object
# whose context holds the string, with no decision and nothing else.
post_assert_context() {
    tc_assert_rc 0 "$2: exit 0"
    tc_assert_json ".hookSpecificOutput.hookEventName == \"PostToolUse\"
        and .hookSpecificOutput.permissionDecision == null
        and (.hookSpecificOutput.additionalContext // \"\" | contains($(jq -n --arg s "$1" '$s')))" "$2"
}

# post_assert_context_lacks <fixed-string> <case>: nothing at all, or
# one object whose context does not hold the string.
post_assert_context_lacks() {
    if [ -z "$OUT" ]; then
        tc_pass "$2"
    else
        tc_assert_json "(.hookSpecificOutput.additionalContext // \"\") | contains($(jq -n --arg s "$1" '$s')) | not" "$2"
    fi
}

# ------------------------------------------------- 1. the reminders

case_post_feature_reminder() {
    post_project light
    post_run "$(post_json Write "${REPO}/${POST_STORIES}/US_901_Example.feature")"
    post_assert_context "$POST_MIRROR" \
        "feature: a feature write reminds the agent to mirror each @AC_ tag"
    post_assert_context "US_901_Example.feature" "feature: the reminder names the feature file"
    post_assert_context "§11.3" "feature: the reminder cites methodology §11.3"

    post_run "$(post_json Edit "${REPO}/${POST_STORIES}/US_901_Example.feature")"
    post_assert_context "$POST_AC_TAG" "feature: an Edit draws the same reminder as a Write"

    post_run "$(post_json Write "${REPO}/features/reading.feature")"
    post_assert_context_lacks "$POST_AC_TAG" "feature: a feature file outside a stories directory draws no story reminder"
}

case_post_story_reminder() {
    post_project light
    post_run "$(post_json Edit "${REPO}/${POST_STORIES}/stakeholder-stories.sysml")"
    post_assert_context "$POST_BIND" \
        "story: a story write reminds the agent to bind each new criterion"
    post_assert_context "stakeholder-stories.sysml" "story: the reminder names the story file"
    post_assert_context "§11.4" "story: the reminder asks for the status check of methodology §11.4"
    post_assert_context_lacks "$POST_AC_TAG" "story: a story write draws no feature reminder"

    post_run "$(post_json MultiEdit "${REPO}/${POST_STORIES}/stakeholder-stories.sysml")"
    post_assert_context "verify <story>.acceptance.<name>" "story: a MultiEdit draws the same reminder"
}

case_post_code_reminder() {
    post_test_first_project "pytest -q"
    post_run "$(post_json Write "${REPO}/src/reading.py")"
    post_assert_context "$POST_RUN_PYTEST" "code: a code write reminds the agent to run the recorded test_command"
    post_assert_context "src/reading.py" "code: the reminder names the code path"

    post_run "$(jq -n -c --arg cwd "$REPO" \
        '{cwd: $cwd, tool_name: "Write", tool_input: {file_path: "src/reading.py"}}')"
    post_assert_context "$POST_RUN_PYTEST" "code: a relative path is taken from the payload's cwd"

    post_run "$(post_notebook_json "${REPO}/src/analysis.ipynb")"
    post_assert_context "$POST_RUN_PYTEST" "code: a notebook under the code paths draws the reminder"

    post_run "$(post_json Write "${REPO}/tests/test_reading.py")"
    tc_assert_json_silent "code: a test path draws no code reminder"
    post_run "$(post_json Write "${REPO}/docs/notes.md")"
    tc_assert_json_silent "code: a path outside code_paths is silent"

    post_test_first_project ""
    post_run "$(post_json Write "${REPO}/src/reading.py")"
    post_assert_context "test_command is not recorded" "code: without a recorded test_command the reminder says so"

    post_project light
    tc_config_append <<'EOF'
test_first:
  applies: false
  rationale: "No implementation code."
  test_command: "pytest -q"
  code_paths: [src/*]
  test_paths: [tests/*]
EOF
    post_run "$(post_json Write "${REPO}/src/reading.py")"
    tc_assert_json_silent "code: applies false draws no code reminder"

    post_project light
    post_run "$(post_json Write "${REPO}/src/reading.py")"
    tc_assert_json_silent "code: an unrecorded test_first draws no code reminder"
}

# The reminders from before 5.0.0 now reach the agent as context too.
case_post_older_reminders() {
    post_project light
    post_run "$(post_json Edit "${REPO}/model/core/concerns/concerns.sysml")"
    post_assert_context "Concern changed" "older: a concern edit draws its reminder as context"
    post_run "$(post_json Edit "${REPO}/model/core/logical-architecture/sensor.sysml")"
    post_assert_context "Architecture changed" "older: an architecture edit draws its reminder as context"
    post_run "$(post_json Edit "${REPO}/docs/project-plan.md")"
    post_assert_context "PM.O1" "older: a Project Plan edit draws its reminder as context"
}

# ------------------------------------------ 2 and 3. location and output

case_post_json_shape() {
    local dir path
    post_test_first_project "pytest -q"
    for path in "${POST_STORIES}/US_901_Example.feature" "${POST_STORIES}/stories.sysml" \
            src/reading.py model/core/concerns/concerns.sysml docs/project-plan.md; do
        post_run "$(post_json Write "${REPO}/${path}")"
        tc_assert_json '.hookSpecificOutput.hookEventName == "PostToolUse"
            and (.hookSpecificOutput.additionalContext | type == "string" and length > 0)
            and .hookSpecificOutput.permissionDecision == null
            and .decision == null' "shape: ${path} draws exactly one PostToolUse object with context"
        tc_assert_not_match '^\[methodology' "$OUT" "shape: ${path} prints no plain text"
    done

    post_run "$(post_json Write "${REPO}/README.md")"
    tc_assert_rc 0 "shape: exit 0 for a file no reminder covers"
    tc_assert_json_silent "shape: a file no reminder covers prints nothing"

    post_run '{"tool_name": "Write", "tool_input": '
    tc_assert_rc 0 "shape: a malformed payload exits 0"
    tc_assert_json_silent "shape: a malformed payload prints nothing on stdout"
    tc_assert_grep "[post-tool-use] Could not read the hook payload" "$ERR" \
        "shape: a malformed payload is named in a plain line on stderr"
    tc_assert_not_grep "Internal error" "$ERR" "shape: a malformed payload is not an internal error"

    tc_env PATH="$(tc_bin_without jq python3)"
    post_run "$(post_json Write "${REPO}/src/reading.py")"
    tc_assert_rc 0 "shape: exit 0 with neither jq nor python3"
    tc_assert_json_silent "shape: with neither jq nor python3 nothing is printed on stdout"
    tc_assert_grep "[post-tool-use] Could not read the hook payload" "$ERR" \
        "shape: a missing JSON engine is named in a plain line on stderr"
    tc_assert_not_grep "Internal error" "$ERR" "shape: a missing JSON engine is not an internal error"
    tc_env

    post_run '{"tool_name": "Write", "tool_input": {"content": "x"}}'
    tc_assert_json_silent "shape: no file path is silent"

    dir="$(tc_mktemp_d)"
    post_run "$(post_json Write "${dir}/${POST_STORIES}/stories.sysml" "$dir")"
    tc_assert_json_silent "shape: a story outside any project is silent"

    post_project light
    tc_mark_plugin_repo
    rm -f "${REPO}/.iso-config.yaml"
    mkdir -p "${REPO}/methodology"
    printf 'project_profile: light\n' | tc_write templates/iso-config/.iso-config.yaml
    post_run "$(post_json Write "${REPO}/templates/iso-config/stories/stories.sysml")"
    tc_assert_json_silent "shape: contributor mode ignores the shipped template configuration"
    post_run "$(post_json Write "${REPO}/templates/common/${POST_STORIES}/stories.sysml")"
    tc_assert_json_silent "shape: contributor mode is silent outside the demo"
    printf 'project_profile: light\n' | tc_write demo/smart-sensor/.iso-config.yaml
    post_run "$(post_json Write "${REPO}/demo/smart-sensor/${POST_STORIES}/stories.sysml")"
    post_assert_context "verify <story>.acceptance.<name>" "shape: contributor mode reminds inside the demo"
}

# ---------------------------------------------- 4. the wiki reminder

# source_repo: the scratch repository as a plugin repository, with the
# wiki schema document and a LOG.md.
source_repo() {
    tc_setup_repo
    tc_env
    tc_mark_plugin_repo
    printf '# Log\n' | tc_write wiki/LOG.md
}

case_source_added_context() {
    local today stubs
    today="$(date -u +%Y-%m-%d)"
    source_repo
    source_run "$(post_json Write "${REPO}/sources/paper.pdf")"
    tc_assert_rc 0 "source: exit 0"
    tc_assert_json '.hookSpecificOutput.hookEventName == "PostToolUse"
        and (.hookSpecificOutput.additionalContext | contains("/vse-wiki-ingest"))
        and (.hookSpecificOutput.additionalContext | contains("sources/paper.pdf"))' \
        "source: a file under sources/ draws the ingest reminder as context"
    tc_assert_grep "## [${today}] source-added | paper.pdf" "$(cat "${REPO}/wiki/LOG.md")" \
        "source: the LOG.md stub is appended"

    source_run "$(post_json Edit "${REPO}/sources/paper.pdf")"
    tc_assert_json '.hookSpecificOutput.additionalContext | contains("/vse-wiki-ingest")' \
        "source: a repeated edit draws the reminder again"
    stubs="$(grep -cF "source-added | paper.pdf" "${REPO}/wiki/LOG.md" || true)"
    tc_assert_eq 1 "$stubs" "source: the stub is appended once a day"

    source_run "$(post_json Write "${REPO}/sources/say \"hi\" now.md")"
    tc_assert_json '.hookSpecificOutput.additionalContext | contains("say \"hi\" now.md")' \
        "source: a path holding quotes is read whole"

    source_run "$(jq -n -c --arg cwd "$REPO" \
        '{cwd: $cwd, tool_name: "Write", tool_input: {file_path: "sources/notes.md"}}')"
    tc_assert_json '.hookSpecificOutput.additionalContext | contains("sources/notes.md")' \
        "source: a relative path under sources/ draws the reminder"

    source_run_from "$(tc_mktemp_d)" "$(post_json Write "${REPO}/sources/report.pdf")"
    tc_assert_json '.hookSpecificOutput.additionalContext | contains("sources/report.pdf")' \
        "source: the plugin repository is found from the payload's cwd"
    tc_assert_grep "source-added | report.pdf" "$(cat "${REPO}/wiki/LOG.md")" \
        "source: the stub lands in the LOG.md of the payload's cwd"

    source_run "$(post_json Write "${REPO}/sources/.scratch/paper.md")"
    tc_assert_json_silent "source: a markitdown scratch file is silent"
    source_run "$(post_json Write "${REPO}/wiki/concepts/x.md")"
    tc_assert_json_silent "source: a file outside sources/ is silent"
    source_run '{"tool_name": "Write", "tool_input": '
    tc_assert_rc 0 "source: a malformed payload exits 0"
    tc_assert_json_silent "source: a malformed payload prints nothing"

    post_project light
    source_run "$(post_json Write "${REPO}/sources/paper.pdf")"
    tc_assert_json_silent "source: an end-user project without the wiki schema is silent"
    tc_assert_eq "" "$(ls "${REPO}/wiki" 2>/dev/null || true)" "source: no wiki is written in an end-user project"

    # A user project that keeps its own wiki schema at wiki/CLAUDE.md,
    # with no plugin manifest, is not the plugin repository.
    printf '# Our wiki\n' | tc_write wiki/CLAUDE.md
    printf '# Log\n' | tc_write wiki/LOG.md
    source_run "$(post_json Write "${REPO}/sources/paper.pdf")"
    tc_assert_json_silent "source: a user project with its own wiki schema is silent"
    tc_assert_eq "# Log" "$(cat "${REPO}/wiki/LOG.md")" "source: no stub is appended to a user project's own LOG.md"
}

# ------------------------------------------------------------------ run

case_post_feature_reminder
case_post_story_reminder
case_post_code_reminder
case_post_older_reminders
case_post_json_shape
case_source_added_context

if tc_summary "test-post-tool-use"; then
    exit 0
fi
exit 1
