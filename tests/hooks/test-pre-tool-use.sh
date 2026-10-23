#!/usr/bin/env bash
# Behavioural tests for hooks/pre-tool-use.sh, the PreToolUse lifecycle
# hook (methodology §11.9.3, hooks guide §5.3).
#
# Each case builds a scratch project, feeds the hook the JSON payload
# Claude Code would send for an Edit, Write, MultiEdit or NotebookEdit
# call, and reads the one JSON object the hook prints. Five groups of
# behaviour are pinned:
#
#   1. Gherkin first. An edit that adds a story, or changes a story's
#      text, is denied while <dir>/<ID>.feature is missing or lacks the
#      @<ID> tag. Untouched siblings draw a warning, deletion is never
#      denied, templates and the library are skipped, and the gate's
#      disposition comes from the configuration.
#   2. Test first. Where test_first.applies is true, an edit to a code
#      path is denied while no test path has changed in the working
#      tree or on the branch. A refactor branch draws a reminder.
#   3. The self-bypass guard. An edit to .iso-config.yaml that changes
#      gate_overrides or test_first asks the human to confirm, and a
#      new .iso-config.yaml below the one in force is compared with
#      the configuration it would replace.
#   4. Locating the project. The configuration is found by walking up
#      from the edited file, whatever the hook's working directory, and
#      contributor mode (the plugin repository) counts only the demo.
#   5. The output contract. Exactly one JSON object or nothing, never
#      an explicit allow, a capped deny reason, and exit 0 always, with
#      an internal error failing open.
#
# Run: bash tests/hooks/test-pre-tool-use.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" > /dev/null && pwd)/lib.sh"

trap tc_teardown EXIT

PTU_HOOK="${TC_PLUGIN_ROOT}/hooks/pre-tool-use.sh"
PTU_STORIES="model/core/stories/stakeholder"

# Physical path of $REPO, set by ptu_project, so expected paths match
# the canonical paths the hook names.
PTU_REAL=""

# PATH values that take jq, python3 or both out of reach.
PTU_BIN_NO_JQ="$(tc_bin_without jq)"
PTU_BIN_NO_PYTHON="$(tc_bin_without python3)"
PTU_BIN_NO_JSON="$(tc_bin_without jq python3)"

# ------------------------------------------------------------- fixtures

# ptu_project [profile] [spec ...]: a fresh scratch repository with a
# configuration at its top level.
ptu_project() {
    local profile="${1:-light}"
    shift || true
    tc_setup_repo
    tc_env
    tc_config "$profile" - "$@"
    PTU_REAL="$(cd "$REPO" && pwd -P)"
}

# ptu_test_first_project [profile] [spec ...]: a project where test
# first applies to src/ with tests under tests/, committed on main with
# a clean working tree.
ptu_test_first_project() {
    ptu_project "$@"
    tc_config_append <<'EOF'
test_first:
  applies: true
  rationale: "pytest runs the code under src/."
  test_command: "pytest -q"
  code_paths: [src/*]
  test_paths: [tests/*]
EOF
    git -C "$REPO" add -A
    tc_commit "chore: start the project"
}

# ptu_story <ID>: one story block, with a capability unique to the ID
# so that an edit to one story never matches another.
ptu_story() {
    local id="$1"
    cat <<EOF
    requirement ${id} : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "use ${id}";
        attribute :>> benefit    = "the device is known to work";

        requirement :>> acceptance {
            requirement firstReading {
                doc /* Given the device is on, when it reads, then the reading is shown. */
            }
        }
    }
EOF
}

# ptu_register <ID>...: a story file holding the named stories.
ptu_register() {
    local id
    printf 'package ExampleStories {\n    private import VSE_Library::*;\n\n'
    for id in "$@"; do
        ptu_story "$id"
        printf '\n'
    done
    printf '}\n'
}

# ptu_feature <ID> [tag]: a feature file for <ID> in the stories
# directory, tagged @<tag> (the ID by default).
ptu_feature() {
    local id="$1" tag="${2:-$1}"
    tc_write "${PTU_STORIES}/${id}.feature" <<EOF
# language: en
@${tag}
Feature: Use ${id}
  As an operator
  I want to use ${id}
  So that the device is known to work
EOF
}

# ------------------------------------------------------------- payloads

# ptu_write_json <abs-path> <content>
ptu_write_json() {
    jq -n -c --arg p "$1" --arg c "$2" --arg cwd "${REPO}" \
        '{session_id: "test", cwd: $cwd, hook_event_name: "PreToolUse",
          tool_name: "Write", tool_input: {file_path: $p, content: $c}}'
}

# ptu_edit_json <abs-path> <old> <new>
ptu_edit_json() {
    jq -n -c --arg p "$1" --arg o "$2" --arg n "$3" --arg cwd "${REPO}" \
        '{session_id: "test", cwd: $cwd, hook_event_name: "PreToolUse",
          tool_name: "Edit",
          tool_input: {file_path: $p, old_string: $o, new_string: $n}}'
}

# ptu_multiedit_json <abs-path> <old1> <new1> [<old2> <new2>]...
ptu_multiedit_json() {
    local path="$1" edits="[]"
    shift
    while [ "$#" -ge 2 ]; do
        edits="$(jq -c --arg o "$1" --arg n "$2" '. + [{old_string: $o, new_string: $n}]' <<<"$edits")"
        shift 2
    done
    jq -n -c --arg p "$path" --argjson e "$edits" --arg cwd "${REPO}" \
        '{session_id: "test", cwd: $cwd, hook_event_name: "PreToolUse",
          tool_name: "MultiEdit", tool_input: {file_path: $p, edits: $e}}'
}

# ptu_notebook_json <abs-path>
ptu_notebook_json() {
    jq -n -c --arg p "$1" --arg cwd "${REPO}" \
        '{session_id: "test", cwd: $cwd, hook_event_name: "PreToolUse",
          tool_name: "NotebookEdit",
          tool_input: {notebook_path: $p, new_source: "print(1)", cell_id: "a"}}'
}

# ------------------------------------------------------------- runners

ptu_run() {
    tc_run_lifecycle pre-tool-use "$1"
}

# ptu_run_from <dir> <json>: run the hook with <dir> as its working
# directory, the way a session started elsewhere would.
ptu_run_from() {
    local dir="$1" TC_STDIN
    TC_STDIN="$(mktemp "${TC_ROOT}/stdin.XXXXXX")"
    printf '%s' "$2" > "$TC_STDIN"
    tc_run_in "$dir" CLAUDE_PLUGIN_ROOT="$TC_PLUGIN_ROOT" "$PTU_HOOK"
    rm -f "$TC_STDIN"
}

# ----------------------------------------------------------- assertions

ptu_assert_denied() {
    tc_assert_rc 0 "$1: exit 0"
    tc_assert_json '.hookSpecificOutput.hookEventName == "PreToolUse"
        and .hookSpecificOutput.permissionDecision == "deny"' "$1"
}

ptu_assert_asked() {
    tc_assert_rc 0 "$1: exit 0"
    tc_assert_json '.hookSpecificOutput.hookEventName == "PreToolUse"
        and .hookSpecificOutput.permissionDecision == "ask"' "$1"
}

# The call proceeds: nothing at all, or one object with no decision.
ptu_assert_proceeds() {
    tc_assert_rc 0 "$1: exit 0"
    if [ -z "$OUT" ]; then
        tc_pass "$1"
    else
        tc_assert_json '.hookSpecificOutput.permissionDecision == null' "$1"
    fi
}

# ptu_assert_reason <fixed-string> <case>
ptu_assert_reason() {
    tc_assert_json "(.hookSpecificOutput.permissionDecisionReason // \"\") | contains($(jq -n --arg s "$1" '$s'))" "$2"
}

# ptu_assert_reason_lacks <fixed-string> <case>
ptu_assert_reason_lacks() {
    tc_assert_json "(.hookSpecificOutput.permissionDecisionReason // \"\") | contains($(jq -n --arg s "$1" '$s')) | not" "$2"
}

# ptu_assert_context <fixed-string> <case>
ptu_assert_context() {
    tc_assert_json "(.hookSpecificOutput.additionalContext // \"\") | contains($(jq -n --arg s "$1" '$s'))" "$2"
}

# ptu_assert_context_lacks <fixed-string> <case>: no context, or one
# that does not hold the string.
ptu_assert_context_lacks() {
    if [ -z "$OUT" ]; then
        tc_pass "$2"
    else
        tc_assert_json "(.hookSpecificOutput.additionalContext // \"\") | contains($(jq -n --arg s "$1" '$s')) | not" "$2"
    fi
}

# ------------------------------------------------- locating the project

case_outside_project_silent() {
    local dir
    tc_setup_repo
    tc_env
    dir="$(tc_mktemp_d)"
    ptu_run "$(ptu_write_json "${dir}/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example)")"
    tc_assert_rc 0 "outside: exit 0 for a story outside any project"
    tc_assert_json_silent "outside: a story outside any project is silent"
    tc_assert_empty "$ERR" "outside: nothing on stderr outside any project"

    ptu_run "$(ptu_write_json "${REPO}/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example)")"
    tc_assert_json_silent "outside: a git repository with no configuration is silent"
    ptu_run "$(ptu_write_json "${REPO}/src/reading.py" "x = 1")"
    tc_assert_json_silent "outside: a code file with no configuration is silent"
    ptu_run '{"session_id": "test", "tool_name": "Write", "tool_input": {"content": "x"}}'
    tc_assert_rc 0 "outside: exit 0 with no file path"
    tc_assert_json_silent "outside: no file path is silent"
}

case_contributor_mode_skips() {
    tc_setup_repo
    tc_env
    PTU_REAL="$(cd "$REPO" && pwd -P)"
    tc_mark_plugin_repo
    tc_config light -
    tc_write templates/iso-config/.iso-config.yaml <<'EOF'
project_profile: light
gate_overrides:
  pretooluse_gherkin_first: block
test_first:
  applies: true
  code_paths: [hooks/*]
  test_paths: [tests/*]
EOF
    ptu_run "$(ptu_write_json "${REPO}/templates/common/models/core/stories/stakeholder/stories.sysml" "$(ptu_register US_901_Example)")"
    tc_assert_json_silent "contributor: a story outside the demo is not gated"
    ptu_run "$(ptu_write_json "${REPO}/templates/iso-config/stories/x.sysml" "$(ptu_register US_901_Example)")"
    tc_assert_json_silent "contributor: the shipped template configuration is ignored"
    ptu_run "$(ptu_edit_json "${REPO}/templates/iso-config/.iso-config.yaml" "pretooluse_gherkin_first: block" "pretooluse_gherkin_first: off")"
    tc_assert_json_silent "contributor: an edit to the template configuration is not asked"
    ptu_run "$(ptu_write_json "${REPO}/hooks/new-hook.sh" "echo hi")"
    tc_assert_json_silent "contributor: a hook edit is not gated by any configuration"

    printf 'project_profile: light\n' | tc_write demo/smart-sensor/.iso-config.yaml
    ptu_run "$(ptu_write_json "${REPO}/demo/smart-sensor/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example)")"
    ptu_assert_denied "contributor: a demo story without a feature file is denied"
    ptu_assert_reason "${PTU_REAL}/demo/smart-sensor/${PTU_STORIES}/US_901_Example.feature" "contributor: the denial names the demo feature path"
}

# A user project that keeps its own wiki schema at wiki/CLAUDE.md, with
# no plugin manifest, is not the plugin repository, so its gates run.
case_user_wiki_schema_gated() {
    ptu_test_first_project light
    printf '# Our wiki\n' | tc_write wiki/CLAUDE.md
    ptu_run "$(ptu_write_json "${REPO}/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example)")"
    ptu_assert_denied "user wiki: a new story without a feature file is denied"
    ptu_run "$(ptu_write_json "${REPO}/src/reading.py" "x = 1")"
    ptu_assert_denied "user wiki: a code edit with no test change is denied"
    ptu_run "$(ptu_edit_json "${REPO}/.iso-config.yaml" "project_profile: light" "project_profile: light
gate_overrides:
  pretooluse_test_first: off")"
    ptu_assert_asked "user wiki: a gate change asks"
}

# The configuration is found from the edited file, never from the
# hook's own working directory.
case_any_working_directory() {
    local other
    ptu_project light
    other="$(tc_mktemp_d)"
    git -C "$other" init -q -b main
    printf 'project_profile: light\ngate_overrides:\n  pretooluse_gherkin_first: off\n' > "${other}/.iso-config.yaml"

    ptu_run_from "$other" "$(ptu_write_json "${REPO}/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example)")"
    ptu_assert_denied "cwd: the edited file's project decides, not the working directory"

    ptu_run_from "$REPO" "$(ptu_write_json "${other}/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example)")"
    ptu_assert_proceeds "cwd: a project with the gate off is not gated from another project's directory"

    ptu_run_from "$(tc_mktemp_d)" "$(jq -n -c --arg cwd "$REPO" --arg c "$(ptu_register US_901_Example)" \
        '{cwd: $cwd, tool_name: "Write", tool_input: {file_path: "model/core/stories/stakeholder/stories.sysml", content: $c}}')"
    ptu_assert_denied "cwd: a relative file path is taken from the payload's cwd"
}

# --------------------------------------------------------- Gherkin first

case_new_story_without_feature_denied() {
    local file
    ptu_project light
    file="${REPO}/${PTU_STORIES}/stories.sysml"
    ptu_run "$(ptu_write_json "$file" "$(ptu_register US_901_Example)")"
    ptu_assert_denied "new story: a new story without a feature file is denied"
    ptu_assert_reason "${PTU_REAL}/${PTU_STORIES}/US_901_Example.feature" "new story: the denial names the expected path"
    ptu_assert_reason "@US_901_Example" "new story: the denial names the tag"
    ptu_assert_reason "§11" "new story: the denial cites methodology section 11"
    ptu_assert_reason "Then retry this edit" "new story: a denial asks for the edit to be retried"
    ptu_assert_reason_lacks "formalise" "new story: a new story is not told to formalise existing text"

    ptu_register US_900_Existing | tc_write "${PTU_STORIES}/stories.sysml"
    ptu_feature US_900_Existing
    ptu_run "$(ptu_edit_json "$file" "$(printf '\n}\n')" "$(printf '\n%s\n}\n' "$(ptu_story US_902_Added)")")"
    ptu_assert_denied "new story: a story added to an existing file is denied"
    ptu_assert_reason "US_902_Added.feature" "new story: the added story is named"
    ptu_assert_reason_lacks "US_900_Existing" "new story: the story with a feature file is not named"
}

case_new_story_with_feature_allowed_with_context() {
    local file
    ptu_project light
    file="${REPO}/${PTU_STORIES}/stories.sysml"
    ptu_feature US_901_Example
    ptu_run "$(ptu_write_json "$file" "$(ptu_register US_901_Example)")"
    ptu_assert_proceeds "with feature: the story goes ahead once its feature file carries the tag"
    ptu_assert_context "§1.9" "with feature: the story-file reminder reaches the agent as context"

    ptu_feature US_901_Example US_999_Other
    ptu_run "$(ptu_write_json "$file" "$(ptu_register US_901_Example)")"
    ptu_assert_denied "with feature: a feature file without the story tag does not count"
}

case_register_untouched_sibling() {
    local file
    ptu_project light
    file="${REPO}/${PTU_STORIES}/stories.sysml"
    ptu_register US_901_Example US_902_Sibling | tc_write "${PTU_STORIES}/stories.sysml"
    ptu_feature US_901_Example
    ptu_run "$(ptu_edit_json "$file" 'capability = "use US_901_Example"' 'capability = "use US_901_Example daily"')"
    ptu_assert_proceeds "sibling: an edit to a story with a feature file goes ahead"
    ptu_assert_context "US_902_Sibling" "sibling: the untouched sibling without a feature file draws a warning"
    ptu_assert_context "${PTU_REAL}/${PTU_STORIES}/US_902_Sibling.feature" "sibling: the warning names the sibling's expected feature path"
    ptu_assert_context "Write ${PTU_REAL}/${PTU_STORIES}/US_902_Sibling.feature before its next change" \
        "sibling: one sibling is asked for in the singular"
    ptu_assert_context_lacks ".feature for each" "sibling: one sibling is not asked for with for each"

    ptu_register US_901_Example US_902_Sibling US_903_Sibling | tc_write "${PTU_STORIES}/stories.sysml"
    ptu_run "$(ptu_edit_json "$file" 'capability = "use US_901_Example"' 'capability = "use US_901_Example daily"')"
    ptu_assert_context "US_902_Sibling and US_903_Sibling" "sibling: two siblings are both named"
    ptu_assert_context "Write ${PTU_REAL}/${PTU_STORIES}/<ID>.feature for each before its next change" \
        "sibling: several siblings are asked for with for each"
}

case_edit_rename_requires_new_feature() {
    local file
    ptu_project light
    file="${REPO}/${PTU_STORIES}/stories.sysml"
    ptu_register US_901_Example | tc_write "${PTU_STORIES}/stories.sysml"
    ptu_feature US_901_Example
    ptu_run "$(ptu_edit_json "$file" "requirement US_901_Example : UserStory" "requirement US_903_Renamed : UserStory")"
    ptu_assert_denied "rename: a renamed story needs a feature file under its new name"
    ptu_assert_reason "US_903_Renamed.feature" "rename: the new name is named"
    ptu_assert_reason_lacks "US_901_Example.feature" "rename: the old name is not asked for"
}

case_delete_story_allowed() {
    local file
    ptu_project light
    file="${REPO}/${PTU_STORIES}/stories.sysml"
    ptu_register US_901_Example US_902_Kept | tc_write "${PTU_STORIES}/stories.sysml"
    ptu_feature US_902_Kept
    ptu_run "$(ptu_edit_json "$file" "$(ptu_story US_901_Example)" "")"
    ptu_assert_proceeds "delete: removing a story without a feature file is never denied"
    ptu_run "$(ptu_write_json "$file" "$(ptu_register)")"
    ptu_assert_proceeds "delete: emptying the story file is never denied"
}

case_template_and_library_skipped() {
    ptu_project light
    tc_config_append <<'EOF'
test_first:
  applies: true
  code_paths: [model/library/*.py]
  test_paths: [tests/*]
EOF
    git -C "$REPO" add -A
    tc_commit "chore: start the project"
    ptu_run "$(ptu_write_json "${REPO}/${PTU_STORIES}/_template.sysml" "$(ptu_register US_901_Example)")"
    ptu_assert_proceeds "skip: a story template is not gated"
    ptu_run "$(ptu_write_json "${REPO}/model/library/stories/library-stories.sysml" "$(ptu_register US_901_Example)")"
    ptu_assert_proceeds "skip: a story file under the library is not gated"
    ptu_run "$(ptu_write_json "${REPO}/model/library/helper.py" "x = 1")"
    ptu_assert_denied "skip: the library skip never reaches a code path"
}

# At warn the edit has already gone ahead, so the finding asks for the
# feature file next and never for the edit to be retried.
case_gherkin_override_warn() {
    ptu_project light pretooluse_gherkin_first=warn
    ptu_run "$(ptu_write_json "${REPO}/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example)")"
    ptu_assert_proceeds "gherkin warn: the edit goes ahead"
    ptu_assert_context "US_901_Example.feature" "gherkin warn: the finding reaches the agent as context"
    ptu_assert_context "write the feature file next" "gherkin warn: the finding asks for the feature file next"
    ptu_assert_context_lacks "retry" "gherkin warn: the finding never asks for a retry"
    ptu_run "$(ptu_write_json "${REPO}/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example US_902_Other)")"
    ptu_assert_context "write the feature files next" "gherkin warn: two stories ask for their feature files next"
    ptu_assert_context_lacks "retry" "gherkin warn: two stories never ask for a retry"
}

case_test_first_override_warn() {
    ptu_test_first_project light pretooluse_test_first=warn
    ptu_run "$(ptu_write_json "${REPO}/src/reading.py" "x = 1")"
    ptu_assert_proceeds "test first warn: the edit goes ahead"
    ptu_assert_context "src/reading.py" "test first warn: the finding names the code path"
    ptu_assert_context "add the failing test next" "test first warn: the finding asks for the failing test next"
    ptu_assert_context "pytest -q" "test first warn: the finding names the recorded test_command"
    ptu_assert_context_lacks "retry" "test first warn: the finding never asks for a retry"
}

case_gherkin_override_off_silent() {
    ptu_project full pretooluse_gherkin_first=off
    ptu_run "$(ptu_write_json "${REPO}/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example)")"
    ptu_assert_proceeds "gherkin off: the edit goes ahead"
    ptu_assert_context_lacks "US_901_Example" "gherkin off: the gate says nothing about the story"
}

# At info each gate adds one line of context for the call, whatever it
# found, and the edit goes ahead.
case_info_disposition_one_line() {
    local file
    ptu_test_first_project light pretooluse_gherkin_first=info pretooluse_test_first=info
    file="${REPO}/${PTU_STORIES}/stories.sysml"
    ptu_run "$(ptu_write_json "$file" "$(ptu_register US_901_Example)")"
    ptu_assert_proceeds "info: a story without a feature file goes ahead"
    ptu_assert_context "Gherkin first (info)" "info: the Gherkin-first line reaches the agent"
    ptu_assert_context "US_901_Example" "info: the line names the story"

    # A touched story and an untouched sibling, both without a feature
    # file, still give one Gherkin-first line, which names both.
    ptu_register US_902_Sibling | tc_write "${PTU_STORIES}/stories.sysml"
    ptu_run "$(ptu_edit_json "$file" "$(printf '\n}\n')" "$(printf '\n%s\n}\n' "$(ptu_story US_901_Example)")")"
    ptu_assert_proceeds "info: a touched story and an untouched sibling go ahead"
    tc_assert_json '[.hookSpecificOutput.additionalContext | split("\n")[] | select(startswith("Gherkin first"))] | length == 1' \
        "info: one Gherkin-first line for the call"
    tc_assert_json '.hookSpecificOutput.additionalContext | split("\n")[] | select(startswith("Gherkin first"))
        | contains("US_901_Example") and contains("US_902_Sibling")' \
        "info: the one line names the touched story and the untouched sibling"
    ptu_run "$(ptu_write_json "${REPO}/src/reading.py" "x = 1")"
    ptu_assert_proceeds "info: a code edit with no test change goes ahead"
    ptu_assert_context "Test first (info)" "info: the test-first line reaches the agent"
    tc_assert_json '.hookSpecificOutput.additionalContext | split("\n") | length == 1' "info: the test-first finding is one line"
}

# A story from before 5.0.0 carries Given/When/Then prose and no
# feature file. Its denial says to formalise that text first.
case_legacy_story_formalise_first() {
    local file
    ptu_project light
    file="${REPO}/${PTU_STORIES}/stories.sysml"
    tc_write "${PTU_STORIES}/stories.sysml" <<'EOF'
package ExampleStories {
    private import VSE_Library::*;

    requirement US_901_Example : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::ready; }
        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
        requirement :>> acceptance {
            doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */
        }
    }
}
EOF
    ptu_run "$(ptu_edit_json "$file" "StoryStatus::ready" "StoryStatus::inProgress")"
    ptu_assert_denied "legacy: a status change on a story without a feature file is denied"
    ptu_assert_reason "formalise the existing Given/When/Then first" "legacy: the denial says to formalise the existing text"
}

case_reason_length_capped() {
    local ids="" n
    ptu_project light
    for n in $(seq 1 30); do
        ids="${ids} US_$(printf '%03d' "$n")_ExampleStoryWithALongerName"
    done
    # The IDs are words, split on purpose.
    # shellcheck disable=SC2086
    ptu_run "$(ptu_write_json "${REPO}/${PTU_STORIES}/stories.sysml" "$(ptu_register $ids)")"
    ptu_assert_denied "cap: thirty new stories are denied"
    tc_assert_json '.hookSpecificOutput.permissionDecisionReason | length < 1500' "cap: the reason stays under 1,500 characters"
    ptu_assert_reason "US_001_ExampleStoryWithALongerName" "cap: the first story is named"
    ptu_assert_reason "and 27 more" "cap: the rest are counted, not listed"
    ptu_assert_reason_lacks "US_030_ExampleStoryWithALongerName" "cap: the last story is not listed"
}

case_multiedit_applied() {
    local file added
    ptu_project light
    file="${REPO}/${PTU_STORIES}/stories.sysml"
    ptu_register US_901_Example | tc_write "${PTU_STORIES}/stories.sysml"
    ptu_feature US_901_Example
    added="$(printf '\n%s\n}\n' "$(ptu_story US_904_Added)")"
    ptu_run "$(ptu_multiedit_json "$file" \
        'capability = "use US_901_Example"' 'capability = "use US_901_Example daily"' \
        "$(printf '\n}\n')" "$added")"
    ptu_assert_denied "multiedit: a story added by the second edit is denied"
    ptu_assert_reason "US_904_Added.feature" "multiedit: the added story is named"

    ptu_run "$(ptu_multiedit_json "$file" \
        "$(printf '\n}\n')" "$added" \
        "$(ptu_story US_904_Added)" "")"
    ptu_assert_proceeds "multiedit: the edits apply in order, so a story added and removed again is not gated"
}

# A checkout with CRLF line endings (core.autocrlf on Windows). The
# Edit tool matches the model's LF old_string against a CRLF file, so a
# multi-line LF edit to a CRLF story or configuration file is gated as
# it would be on an LF file.
case_crlf_story_multiline_denied() {
    local file
    ptu_project light
    file="${REPO}/${PTU_STORIES}/stories.sysml"
    ptu_register US_901_Example | tc_crlf | tc_write "${PTU_STORIES}/stories.sysml"
    ptu_feature US_901_Example
    ptu_run "$(ptu_edit_json "$file" "$(printf '    }\n\n}')" "$(printf '    }\n\n%s\n\n}' "$(ptu_story US_902_Added)")")"
    ptu_assert_denied "CRLF: a multi-line LF edit adding a story to a CRLF register is denied"
    ptu_assert_reason "US_902_Added.feature" "CRLF: the added story is named"
    ptu_assert_reason_lacks "US_901_Example" "CRLF: the untouched story with a feature file is not named"
}

case_crlf_config_multiline_asks() {
    ptu_project light precommit_lint=warn
    tc_crlf < "${REPO}/.iso-config.yaml" > "${REPO}/.iso-config.yaml.tmp" \
        && mv "${REPO}/.iso-config.yaml.tmp" "${REPO}/.iso-config.yaml"
    ptu_run "$(ptu_edit_json "${REPO}/.iso-config.yaml" "gate_overrides:
  precommit_lint: warn" "gate_overrides:
  precommit_lint: warn
  pretooluse_gherkin_first: off")"
    ptu_assert_asked "CRLF: a multi-line LF edit adding a gate override to a CRLF configuration asks"
    ptu_assert_reason "gate_overrides" "CRLF: the question names gate_overrides"
}

# An edit whose old_string does not occur in the file as the hook reads
# it cannot be reproduced, so the gates saw the file unchanged. The
# agent is told so, rather than the edit passing in silence.
case_edit_not_reproduced_context() {
    local file
    ptu_project light
    file="${REPO}/${PTU_STORIES}/stories.sysml"
    ptu_register US_901_Example | tc_write "${PTU_STORIES}/stories.sysml"
    ptu_feature US_901_Example
    ptu_run "$(ptu_edit_json "$file" "text that is not in the file" "requirement US_902_Added : UserStory;")"
    ptu_assert_proceeds "not reproduced: the edit is not denied on a guess"
    ptu_assert_context "Warning" "not reproduced: the context is a warning"
    ptu_assert_context "could not reproduce" "not reproduced: the agent is told the edit could not be reproduced"
    ptu_assert_context "commit gate remains the backstop" "not reproduced: the commit gate is named as the backstop"
    ptu_run "$(ptu_edit_json "$file" 'capability = "use US_901_Example"' 'capability = "use US_901_Example daily"')"
    ptu_assert_context_lacks "could not reproduce" "not reproduced: an edit that matches draws no such warning"
    # The Edit tool refuses an edit to a file that does not exist, so
    # there is nothing to warn about.
    ptu_run "$(ptu_edit_json "${REPO}/${PTU_STORIES}/missing.sysml" "text that is not in the file" "requirement US_902_Added : UserStory;")"
    ptu_assert_proceeds "not reproduced: an edit to a missing file is not denied"
    ptu_assert_context_lacks "could not reproduce" "not reproduced: an edit to a missing file draws no such warning"
}

# ------------------------------------------------------------ test first

case_test_first_denied_without_evidence() {
    ptu_test_first_project light
    ptu_run "$(ptu_write_json "${REPO}/src/reading.py" "def reading():\n    return 1\n")"
    ptu_assert_denied "test first: a code edit with no test change is denied"
    ptu_assert_reason "src/reading.py" "test first: the denial names the code path"
    ptu_assert_reason "failing test" "test first: the denial asks for a failing test first"
    ptu_assert_reason "main" "test first: the denial names the base the branch was measured against"
    ptu_assert_reason "then retry this edit" "test first: a denial asks for the edit to be retried"

    git -C "$REPO" checkout -q --detach
    ptu_run "$(ptu_write_json "${REPO}/src/reading.py" "x = 1")"
    ptu_assert_denied "test first: a detached HEAD gives no branch evidence"
    ptu_assert_reason "detached HEAD" "test first: the denial says why there is no branch evidence"
}

case_test_first_allowed_with_working_tree_test() {
    ptu_test_first_project light
    printf 'def test_reading():\n    assert False\n' | tc_write tests/test_reading.py
    ptu_run "$(ptu_write_json "${REPO}/src/reading.py" "x = 1")"
    ptu_assert_proceeds "test first: an untracked test file is evidence"

    git -C "$REPO" checkout -q -b feat/readings
    git -C "$REPO" add tests/test_reading.py
    tc_commit "test: read a value"
    ptu_run "$(ptu_write_json "${REPO}/src/reading.py" "x = 1")"
    ptu_assert_proceeds "test first: a test committed on the branch is evidence"
}

case_test_first_refactor_branch_context() {
    ptu_test_first_project light
    git -C "$REPO" checkout -q -b refactor/tidy-readings
    ptu_run "$(ptu_write_json "${REPO}/src/reading.py" "x = 1")"
    ptu_assert_proceeds "refactor: a code edit on a refactor branch goes ahead"
    ptu_assert_context "refactor" "refactor: the agent is reminded"
    ptu_assert_context "no test file has changed" "refactor: the reminder says no test file has changed"
}

case_test_first_not_applicable() {
    ptu_project light
    git -C "$REPO" add -A
    tc_commit "chore: start the project"
    ptu_run "$(ptu_write_json "${REPO}/src/reading.py" "x = 1")"
    tc_assert_json_silent "not applicable: test_first unrecorded, a code edit is silent"

    tc_config_append <<'EOF'
test_first:
  applies: false
  rationale: "No implementation code."
  code_paths: [src/*]
  test_paths: [tests/*]
EOF
    ptu_run "$(ptu_write_json "${REPO}/src/reading.py" "x = 1")"
    tc_assert_json_silent "not applicable: applies false is silent"

    ptu_test_first_project light
    ptu_run "$(ptu_write_json "${REPO}/docs/project-plan.md" "# Plan")"
    tc_assert_json_silent "not applicable: a path outside code_paths is silent"
    ptu_run "$(ptu_write_json "${REPO}/tests/test_reading.py" "x = 1")"
    tc_assert_json_silent "not applicable: a test path is silent"
    ptu_run "$(ptu_write_json "${REPO}/src/readings.feature" "Feature: x")"
    tc_assert_json_silent "not applicable: a feature file is never code"
}

case_notebook_path_read() {
    ptu_test_first_project light
    ptu_run "$(ptu_notebook_json "${REPO}/src/analysis.ipynb")"
    ptu_assert_denied "notebook: a notebook under the code paths is gated"
    ptu_assert_reason "src/analysis.ipynb" "notebook: the denial names the notebook path"
    ptu_run "$(ptu_notebook_json "${REPO}/notes/analysis.ipynb")"
    tc_assert_json_silent "notebook: a notebook outside the code paths is silent"
}

# --------------------------------------------------- self-bypass guard

case_config_gate_change_asks() {
    local config
    ptu_project light precommit_lint=warn
    config="${REPO}/.iso-config.yaml"
    ptu_run "$(ptu_edit_json "$config" "precommit_lint: warn" "precommit_lint: warn
  pretooluse_gherkin_first: off")"
    ptu_assert_asked "config: adding a gate override asks"
    ptu_assert_reason "gate_overrides" "config: the question names gate_overrides"
    ptu_assert_reason "§11.10" "config: the question cites the self-bypass rule"

    ptu_run "$(ptu_edit_json "$config" "precommit_lint: warn" "precommit_lint: off")"
    ptu_assert_asked "config: changing an override value asks"

    ptu_run "$(ptu_write_json "$config" "project_profile: light
")"
    ptu_assert_asked "config: removing gate_overrides asks"

    ptu_run "$(ptu_edit_json "$config" "project_profile: light" "project_profile: light
test_first:
  applies: false")"
    ptu_assert_asked "config: adding a test_first record asks"
    ptu_assert_reason "test_first" "config: the question names test_first"
}

# No commit gate checks a gate_overrides or test_first change, so when
# the guard cannot reproduce an edit to the configuration the warning
# says the change was not checked against §11.10 and names the review
# by the code owners of .iso-config.yaml as the remaining check. It
# names neither the commit gate nor the Gherkin-first gate, which never
# runs on the configuration.
case_config_not_reproduced_context() {
    local config
    ptu_project light precommit_lint=off
    config="${REPO}/.iso-config.yaml"
    ptu_run "$(ptu_edit_json "$config" "precommit_lint:  off" "precommit_lint: warn")"
    ptu_assert_proceeds "config not reproduced: the edit is not asked on a guess"
    ptu_assert_context "could not reproduce" "config not reproduced: the agent is told the edit could not be reproduced"
    ptu_assert_context "the self-bypass guard saw the file unchanged" \
        "config not reproduced: the guard is said to have seen the file unchanged"
    ptu_assert_context "was not checked against methodology §11.10" \
        "config not reproduced: the change is said to be unchecked against §11.10"
    ptu_assert_context "Review by the owners of .iso-config.yaml (CODEOWNERS) is the remaining check" \
        "config not reproduced: the code owners' review is named as the remaining check"
    ptu_assert_context_lacks "commit gate" "config not reproduced: the commit gate is not named as a backstop"
    ptu_assert_context_lacks "Gherkin-first" "config not reproduced: the Gherkin-first gate is not named"
}

case_config_other_change_allowed() {
    local config
    ptu_project light precommit_lint=warn
    config="${REPO}/.iso-config.yaml"
    ptu_run "$(ptu_edit_json "$config" "project_profile: light" "project_profile: standard")"
    ptu_assert_proceeds "config: a profile change is not asked"
    ptu_run "$(ptu_edit_json "$config" "precommit_lint: warn" "# A comment.
  precommit_lint: warn")"
    ptu_assert_proceeds "config: a comment line inside gate_overrides is not asked"
    ptu_run "$(ptu_edit_json "$config" "project_profile: light" "project_profile: light
baselined_paths:
  - docs/project-plan.md")"
    ptu_assert_proceeds "config: a baselined_paths change is not asked"
}

# A new .iso-config.yaml below the one in force takes over the files in
# its directory and below, so it is compared with the configuration it
# would replace there, not with an empty file.
case_config_nested_shadow_asks() {
    local nested="src/.iso-config.yaml"
    ptu_project light precommit_lint=warn
    tc_config_append <<'EOF'
test_first:
  applies: true
  rationale: "pytest runs the code under src/."
  code_paths: [src/*.py]
  test_paths: [tests/*]
EOF
    git -C "$REPO" add -A
    tc_commit "chore: start the project"
    ptu_run "$(ptu_write_json "${REPO}/src/reading.py" "x = 1")"
    ptu_assert_denied "nested config: the project configuration gates a code edit under src/"

    ptu_run "$(ptu_write_json "${REPO}/${nested}" "project_profile: light
")"
    ptu_assert_asked "nested config: a new config that drops gate_overrides and test_first asks"
    ptu_assert_reason "gate_overrides and test_first" "nested config: the question names both sections"
    ptu_assert_reason "${PTU_REAL}/${nested}" "nested config: the question names the new file"
    ptu_assert_reason "${PTU_REAL}/.iso-config.yaml" "nested config: the question names the configuration it would replace"

    ptu_run "$(ptu_write_json "${REPO}/${nested}" "project_profile: light
gate_overrides:
  precommit_lint: warn
")"
    ptu_assert_asked "nested config: a new config that drops only test_first asks"
    ptu_assert_reason_lacks "gate_overrides and" "nested config: an unchanged gate_overrides is not named"

    ptu_run "$(ptu_write_json "${REPO}/${nested}" "$(cat "${REPO}/.iso-config.yaml")")"
    ptu_assert_proceeds "nested config: a copy that keeps both sections is not asked"

    ptu_run "$(ptu_edit_json "${REPO}/${nested}" "" "project_profile: light
")"
    ptu_assert_asked "nested config: an Edit that creates the file asks too"

    ptu_run "$(ptu_write_json "${REPO}/engineering/.iso-config.yaml" "project_profile: light
")"
    ptu_assert_asked "nested config: a new engineering/ config below the top-level one asks"

    # A configuration a human already put in place is compared with
    # itself, as any other edit is.
    printf 'project_profile: light\n' | tc_write "$nested"
    ptu_run "$(ptu_edit_json "${REPO}/${nested}" "project_profile: light" "project_profile: standard")"
    ptu_assert_proceeds "nested config: an edit to an existing nested config is compared with that file"

    # Brownfield layout: a new top-level configuration would take over
    # from engineering/.iso-config.yaml.
    ptu_project light precommit_lint=warn
    mkdir -p "${REPO}/engineering"
    mv "${REPO}/.iso-config.yaml" "${REPO}/engineering/.iso-config.yaml"
    ptu_run "$(ptu_write_json "${REPO}/.iso-config.yaml" "project_profile: light
")"
    ptu_assert_asked "nested config: a new top-level config over engineering/.iso-config.yaml asks"
    ptu_assert_reason "${PTU_REAL}/engineering/.iso-config.yaml" "nested config: the question names the engineering configuration"
}

# A configuration file is never code, whatever test_first.code_paths
# says, so a .iso-config.yaml below a code path meets the self-bypass
# guard and not the test-first gate.
case_config_never_code() {
    local nested="src/.iso-config.yaml"
    ptu_test_first_project light
    ptu_run "$(ptu_write_json "${REPO}/${nested}" "$(cat "${REPO}/.iso-config.yaml")")"
    ptu_assert_proceeds "config never code: a faithful copy below a code path goes ahead"
    ptu_assert_context_lacks "Test first" "config never code: the test-first gate says nothing"
    ptu_run "$(ptu_write_json "${REPO}/${nested}" "project_profile: light
")"
    ptu_assert_asked "config never code: a copy that drops test_first is asked, not denied"
    ptu_assert_reason "test_first" "config never code: the question names test_first"
    ptu_assert_reason_lacks "Test first (pretooluse_test_first)" "config never code: no test-first finding rides with it"
}

# The baselined-path note of earlier releases reaches the agent as
# context.
case_baselined_path_context() {
    ptu_project light
    tc_config_append <<'EOF'
baselined_paths:
  - docs/project-plan.md
EOF
    ptu_run "$(ptu_edit_json "${REPO}/docs/project-plan.md" "a" "b")"
    ptu_assert_proceeds "baselined: the edit goes ahead"
    ptu_assert_context "baselined" "baselined: the agent is told the file is baselined"
    ptu_assert_context "Change Request" "baselined: the note points at a Change Request"
    ptu_run "$(ptu_edit_json "${REPO}/docs/other.md" "a" "b")"
    tc_assert_json_silent "baselined: a file off the list is silent"
}

# ------------------------------------------------------- output contract

case_no_jq_python_fallback() {
    ptu_project light
    tc_env PATH="$PTU_BIN_NO_JQ"
    ptu_run "$(ptu_write_json "${REPO}/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example)")"
    ptu_assert_denied "no jq: python3 reads the payload and the story is denied"
    ptu_assert_reason "US_901_Example.feature" "no jq: the reason is complete"
    ptu_run "$(ptu_edit_json "${REPO}/.iso-config.yaml" "project_profile: light" "project_profile: light
gate_overrides:
  pretooluse_test_first: off")"
    ptu_assert_asked "no jq: a gate change still asks"
    tc_env
}

# jq 1.5 reads the payload but cannot compile the post-image program,
# which calls halt_error. python3 builds the images instead, so the
# story and configuration gates still decide rather than failing open.
case_old_jq_python_fallback() {
    ptu_project light
    tc_stub_old_jq
    ptu_run "$(ptu_write_json "${REPO}/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example)")"
    ptu_assert_denied "old jq: python3 builds the image and the story is denied"
    ptu_assert_reason "US_901_Example.feature" "old jq: the reason is complete"
    ptu_run "$(ptu_edit_json "${REPO}/.iso-config.yaml" "project_profile: light" "project_profile: light
gate_overrides:
  pretooluse_test_first: off")"
    ptu_assert_asked "old jq: a gate change still asks"
}

# Under the stock bash 3.2 of macOS a /dev/fd path from a process
# substitution can name a descriptor the shell has already closed, so
# jq cannot open it (tc_stub_closed_devfd_jq stands in for that jq).
# python3 is taken away, so jq must build the images. The story and
# configuration gates still decide rather than failing open.
case_closed_devfd_jq_gates_decide() {
    local file
    ptu_project light
    file="${REPO}/${PTU_STORIES}/stories.sysml"
    tc_stub_closed_devfd_jq
    tc_env PATH="${STUBS}:${PTU_BIN_NO_PYTHON}"
    ptu_run "$(ptu_write_json "$file" "$(ptu_register US_901_Example)")"
    ptu_assert_denied "closed /dev/fd: a new story without a feature file is denied"
    ptu_assert_reason "US_901_Example.feature" "closed /dev/fd: the reason is complete"
    tc_assert_not_grep "Internal error" "$ERR" "closed /dev/fd: the hook does not fail open"

    ptu_register US_901_Example US_902_Sibling | tc_write "${PTU_STORIES}/stories.sysml"
    ptu_feature US_901_Example
    ptu_run "$(ptu_edit_json "$file" 'capability = "use US_901_Example"' 'capability = "use US_901_Example daily"')"
    ptu_assert_proceeds "closed /dev/fd: an edit to a story with a feature file goes ahead"
    ptu_assert_context "US_902_Sibling" "closed /dev/fd: the untouched sibling without a feature file draws a warning"

    ptu_run "$(ptu_edit_json "${REPO}/.iso-config.yaml" "project_profile: light" "project_profile: light
gate_overrides:
  pretooluse_test_first: off")"
    ptu_assert_asked "closed /dev/fd: a gate change still asks"
    tc_env
}

case_no_jq_no_python_notice() {
    ptu_project light
    tc_env PATH="$PTU_BIN_NO_JSON"
    ptu_run "$(ptu_write_json "${REPO}/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example)")"
    tc_assert_rc 0 "no engine: exit 0"
    tc_assert_json '.hookSpecificOutput.hookEventName == "PreToolUse"
        and .hookSpecificOutput.permissionDecision == null
        and (.hookSpecificOutput.additionalContext | contains("jq"))
        and (.systemMessage | contains("jq"))' "no engine: a fixed notice for the agent and the user, and no decision"
    tc_env
}

case_malformed_payload_fails_open() {
    ptu_project light
    ptu_run '{"tool_name": "Write", "tool_input": '
    tc_assert_rc 0 "fail open: a malformed payload exits 0"
    tc_assert_json_silent "fail open: a malformed payload prints nothing on stdout"
    tc_assert_grep "[pre-tool-use]" "$ERR" "fail open: the problem is reported on stderr"

    ptu_run "$(jq -n -c --arg p "${REPO}/${PTU_STORIES}/stories.sysml" \
        '{tool_name: "Edit", tool_input: {file_path: $p, old_string: 1, new_string: {}}}')"
    tc_assert_rc 0 "fail open: an edit the image cannot apply exits 0"
    ptu_assert_proceeds "fail open: an edit the image cannot apply is never denied"
}

case_never_emits_allow() {
    local json
    ptu_test_first_project light
    ptu_feature US_901_Example
    printf 'x = 1\n' | tc_write tests/test_reading.py
    for json in \
        "$(ptu_write_json "${REPO}/${PTU_STORIES}/stories.sysml" "$(ptu_register US_901_Example)")" \
        "$(ptu_write_json "${REPO}/src/reading.py" "x = 1")" \
        "$(ptu_notebook_json "${REPO}/src/analysis.ipynb")" \
        "$(ptu_edit_json "${REPO}/.iso-config.yaml" "project_profile: light" "project_profile: full")" \
        "$(ptu_write_json "${REPO}/README.md" "# Readme")"; do
        ptu_run "$json"
        tc_assert_rc 0 "allow: exit 0"
        tc_assert_not_grep '"allow"' "$OUT" "allow: no explicit allow is printed"
        if [ -n "$OUT" ]; then
            tc_assert_json '.hookSpecificOutput.hookEventName == "PreToolUse"' "allow: one object naming the event"
        fi
    done
}

# ------------------------------------------------------------------ run

case_outside_project_silent
case_contributor_mode_skips
case_user_wiki_schema_gated
case_any_working_directory
case_new_story_without_feature_denied
case_new_story_with_feature_allowed_with_context
case_register_untouched_sibling
case_edit_rename_requires_new_feature
case_delete_story_allowed
case_template_and_library_skipped
case_gherkin_override_warn
case_test_first_override_warn
case_gherkin_override_off_silent
case_info_disposition_one_line
case_legacy_story_formalise_first
case_reason_length_capped
case_multiedit_applied
case_crlf_story_multiline_denied
case_crlf_config_multiline_asks
case_edit_not_reproduced_context
case_test_first_denied_without_evidence
case_test_first_allowed_with_working_tree_test
case_test_first_refactor_branch_context
case_test_first_not_applicable
case_notebook_path_read
case_config_gate_change_asks
case_config_not_reproduced_context
case_config_other_change_allowed
case_config_nested_shadow_asks
case_config_never_code
case_baselined_path_context
case_no_jq_python_fallback
case_old_jq_python_fallback
case_closed_devfd_jq_gates_decide
case_no_jq_no_python_notice
case_malformed_payload_fails_open
case_never_emits_allow

if tc_summary "test-pre-tool-use"; then
    exit 0
fi
exit 1
