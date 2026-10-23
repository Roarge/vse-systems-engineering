#!/usr/bin/env bash
# Behavioural tests for hooks/lib/test-first.sh.
#
# The library is shared by the PreToolUse lifecycle hook and the
# pre-commit gate. Each case sources iso-profile.sh and test-first.sh
# from the plugin tree into a fresh shell, inside a scratch directory,
# and calls one function. Six groups of behaviour are pinned here:
#
#   1. The story scanner finds each `requirement <ID> : UserStory`
#      declaration and its block text. It reads past strings, comments,
#      KerML notes (//* ... */) and doc bodies, and it ignores
#      definitions. The demo registers and the VSE library are read
#      live from the plugin tree, with their expected IDs in the cases.
#      The hand-made corpus under tests/fixtures/stories/ carries one
#      .ids file beside each .sysml file.
#   2. The post-edit image applies a Write, Edit or MultiEdit payload
#      to the file on disk, with jq or, failing that, python3, reading
#      CRLF line endings as LF and saying when an old_string does not
#      occur. The disk image takes the same path with no edit, so a
#      pre-image and a post-image are normalised the same way.
#   3. A feature file carries a story tag only on a tag line before
#      its Feature: line.
#   4. A path relative to the git top level is classified as never,
#      test, code or other, with the never-list anchored at the
#      engineering root (the directory of the configuration file).
#   5. Test evidence comes from the working tree or from the branch
#      since its merge base, and a shallow clone, a detached HEAD or an
#      unborn HEAD gives a reason instead of branch evidence.
#   6. Configuration lookup, path canonicalisation, refactor branches,
#      test tooling detection and the applies record.
#
# Run: bash tests/hooks/test-test-first-lib.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

TF_LIB="${TC_PLUGIN_ROOT}/hooks/lib"
TF_FIXTURES="${TC_PLUGIN_ROOT}/tests/fixtures/stories"

# The live demo registers and the shipped library, read in place so the
# scanner is checked against the files users actually have.
TF_DEMO_STORIES="${TC_PLUGIN_ROOT}/demo/smart-sensor/model/core/stories"
TF_STAKEHOLDER="${TF_DEMO_STORIES}/stakeholder/stakeholder-stories.sysml"
TF_SYSTEM="${TF_DEMO_STORIES}/system/system-stories.sysml"
TF_LIBRARY="${TC_PLUGIN_ROOT}/templates/common/library/vse-library.sysml"
TF_STAKEHOLDER_IDS='US_001_SeeReadingsOnDashboard
US_002_AcknowledgeAlertsBatched
US_003_CalibrateInField
US_004_RetainAlertHistory'
TF_SYSTEM_IDS='SYS_001_DashboardLatency
SYS_002_BatchAcknowledgement
SYS_003_CalibrationOffsetCommit
SYS_004_AlertRetentionWindow'

# The driver bodies are expanded by the shell they are handed to.
# shellcheck disable=SC2016
TF_DRIVER='
lib="$1"
shift
. "${lib}/iso-profile.sh"
. "${lib}/test-first.sh"
"$@"
'

# As TF_DRIVER, but the function writes into the file named by the
# second argument, so a test can compare the bytes, trailing newlines
# included.
# shellcheck disable=SC2016
TF_FILE_DRIVER='
lib="$1"
out="$2"
shift 2
. "${lib}/iso-profile.sh"
. "${lib}/test-first.sh"
"$@" > "$out"
'

# run_tf <function> [arg ...]: call one library function inside $REPO.
run_tf() {
    tc_run_in "$REPO" bash -c "$TF_DRIVER" tf-driver "$TF_LIB" "$@"
}

# run_tf_at <dir> <function> [arg ...]: as run_tf, inside <dir>.
run_tf_at() {
    local dir="$1"
    shift
    tc_run_in "$dir" bash -c "$TF_DRIVER" tf-driver "$TF_LIB" "$@"
}

# run_tf_stdin <file> <function> [arg ...]: as run_tf, with <file> on
# stdin.
run_tf_stdin() {
    # Read by _tc_capture in lib.sh, which run_tf reaches.
    # shellcheck disable=SC2034
    local TC_STDIN="$1"
    shift
    run_tf "$@"
}

# run_tf_to <out-file> <function> [arg ...]: as run_tf, with the
# function's stdout written to <out-file>.
run_tf_to() {
    local out="$1"
    shift
    tc_run_in "$REPO" bash -c "$TF_FILE_DRIVER" tf-driver "$TF_LIB" "$out" "$@"
}

# PATH values that take jq, python3 or both out of reach.
TF_BIN_NO_PYTHON="$(tc_bin_without python3)"
TF_BIN_NO_JQ="$(tc_bin_without jq)"
TF_BIN_NO_JSON="$(tc_bin_without jq python3)"

# ids_of <scanner-output>: the ID column, one per line.
ids_of() {
    printf '%s\n' "$1" | cut -f1
}

# block_of <ID> <scanner-output>: the block column of one story.
block_of() {
    printf '%s\n' "$2" | awk -F '\t' -v id="$1" '$1 == id { print $2 }'
}

# A light-profile project whose test_first record watches src/ and
# scripts/*.sh as code and tests/ as tests.
tf_config() {
    tc_config light -
    tc_config_append <<'EOF'
test_first:
  applies: true
  test_command: "pytest -q"
  code_paths: [src/*, scripts/*.sh]
  test_paths: [tests/*]
EOF
}

# ------------------------------------------------------- story scanner

case_story_blocks_demo_register() {
    local block
    tc_setup_repo
    tc_env

    run_tf_stdin "$TF_STAKEHOLDER" vse_tf_story_blocks
    tc_assert_rc 0 "story blocks: the stakeholder register scans"
    tc_assert_eq "$TF_STAKEHOLDER_IDS" "$(ids_of "$OUT")" \
        "story blocks: the four demo stakeholder stories, in order"
    tc_assert_line_count 4 "$OUT" "story blocks: one line per stakeholder story"
    block="$(block_of US_001_SeeReadingsOnDashboard "$OUT")"
    tc_assert_match '^requirement US_001_SeeReadingsOnDashboard : UserStory \{ @StoryMeta \{ points = 5;' "$block" \
        "story blocks: a block starts at the declaration, whitespace collapsed"
    tc_assert_match 'of arrival at the cloud broker\. \*/ \} \} \}$' "$block" \
        "story blocks: a block ends at the matching closing brace"
    tc_assert_not_match 'US_002' "$block" \
        "story blocks: a block stops before the next story"

    run_tf_stdin "$TF_SYSTEM" vse_tf_story_blocks
    tc_assert_eq "$TF_SYSTEM_IDS" "$(ids_of "$OUT")" \
        "story blocks: the four demo system stories, each after #derive"
    block="$(block_of SYS_001_DashboardLatency "$OUT")"
    tc_assert_match '^requirement SYS_001_DashboardLatency : UserStory \{' "$block" \
        "story blocks: the #derive prefix is not part of the block"
    tc_assert_match 'over a 1-hour window\. \*/ \} \} \}$' "$block" \
        "story blocks: a nested requirement does not end the story block"
}

case_story_blocks_ignores_library() {
    tc_setup_repo
    tc_env
    run_tf_stdin "$TF_LIBRARY" vse_tf_story_blocks
    tc_assert_rc 0 "library: the scan succeeds"
    tc_assert_empty "$OUT" "library: the definition and the doc example are not stories"
}

case_story_blocks_string_with_comment_opener() {
    local block
    tc_setup_repo
    tc_env
    run_tf_stdin "${TF_FIXTURES}/string-with-comment-opener.sysml" vse_tf_story_blocks
    tc_assert_eq "$(cat "${TF_FIXTURES}/string-with-comment-opener.ids")" "$(ids_of "$OUT")" \
        "strings: a /* inside a string does not swallow later stories"

    run_tf_stdin "${TF_FIXTURES}/string-escapes.sysml" vse_tf_story_blocks
    tc_assert_eq "$(cat "${TF_FIXTURES}/string-escapes.ids")" "$(ids_of "$OUT")" \
        "strings: backslash escapes are honoured"
    block="$(block_of US_201_QuoteInString "$OUT")"
    tc_assert_match '/\* a brace in a block comment \} \*/ \}$' "$block" \
        "strings: braces inside strings and comments do not close the block"
}

case_story_blocks_note_syntax() {
    tc_setup_repo
    tc_env
    run_tf_stdin "${TF_FIXTURES}/note-syntax.sysml" vse_tf_story_blocks
    tc_assert_eq "$(cat "${TF_FIXTURES}/note-syntax.ids")" "$(ids_of "$OUT")" \
        "notes: //* ... */ is read as a note, not as a line comment"
    tc_assert_not_grep "US_90" "$(ids_of "$OUT")" \
        "notes: no declaration inside a note, comment or doc body counts"
}

case_story_blocks_requirement_def_not_matched() {
    tc_setup_repo
    tc_env
    run_tf_stdin "${TF_FIXTURES}/requirement-def.sysml" vse_tf_story_blocks
    tc_assert_eq "$(cat "${TF_FIXTURES}/requirement-def.ids")" "$(ids_of "$OUT")" \
        "definitions: only usages typed by UserStory or VSE_Library::UserStory count"
}

# Every hand-made corpus file scans to the IDs its .ids file lists, so a
# fixture added for the Python lint is checked here too.
case_story_blocks_fixture_corpus() {
    local sysml ids name count=0
    tc_setup_repo
    tc_env
    for sysml in "${TF_FIXTURES}"/*.sysml; do
        name="${sysml##*/}"
        ids="${sysml%.sysml}.ids"
        count=$((count + 1))
        if [ ! -f "$ids" ]; then
            tc_fail "corpus: ${name} has a sibling .ids file"
            continue
        fi
        run_tf_stdin "$sysml" vse_tf_story_blocks
        if [ -s "$ids" ]; then
            tc_assert_eq "$(cat "$ids")" "$(ids_of "$OUT")" "corpus: ${name} scans to its .ids list"
        else
            tc_assert_empty "$OUT" "corpus: ${name} holds no story"
        fi
    done
    tc_assert_eq 5 "$count" "corpus: five fixtures are present"
}

# Forms the corpus does not carry: CRLF line ends, a story with no
# body, a story whose closing brace is missing, a "requirement"
# keyword left dangling by a partial edit, and a type name that only
# begins with UserStory.
case_story_blocks_edge_forms() {
    local input
    tc_setup_repo
    tc_env
    input="$(tc_mktemp_d)/edge.sysml"
    printf 'requirement US_1 : UserStory {\r\n    attribute x;\r\n}\r\nrequirement US_2 : UserStory;\r\nrequirement US_3 : UserStory {\n    attribute y;\n' > "$input"
    run_tf_stdin "$input" vse_tf_story_blocks
    tc_assert_eq "US_1
US_2
US_3" "$(ids_of "$OUT")" "edge forms: CRLF, body-less and unterminated stories are found"
    tc_assert_eq "requirement US_1 : UserStory { attribute x; }" "$(block_of US_1 "$OUT")" \
        "edge forms: carriage returns collapse with the other whitespace"
    tc_assert_eq "requirement US_2 : UserStory;" "$(block_of US_2 "$OUT")" \
        "edge forms: a body-less story ends at its semicolon"
    tc_assert_eq "requirement US_3 : UserStory { attribute y;" "$(block_of US_3 "$OUT")" \
        "edge forms: an unterminated story runs to the end of the text"

    printf 'requirement\nrequirement US_4 : UserStory {\n}\nrequirement US_5 : UserStory\nrequirement US_6 : UserStory {\n}\n' > "$input"
    run_tf_stdin "$input" vse_tf_story_blocks
    tc_assert_eq "US_4
US_6" "$(ids_of "$OUT")" "edge forms: a dangling requirement keyword starts nothing"
    tc_assert_eq "requirement US_6 : UserStory { }" "$(block_of US_6 "$OUT")" \
        "edge forms: a new declaration replaces an unfinished one"

    printf 'requirement US_7 : UserStory::Part {\n}\nrequirement US_8 : VSE_Library::UserStory::Part {\n}\n' > "$input"
    run_tf_stdin "$input" vse_tf_story_blocks
    tc_assert_empty "$OUT" "edge forms: a type nested under UserStory is not UserStory"

    printf 'requirement US_9 : UserStory ::> base {\n}\nrequirement US_10 : VSE_Library::UserStory ::> base;\n' > "$input"
    run_tf_stdin "$input" vse_tf_story_blocks
    tc_assert_eq "US_9
US_10" "$(ids_of "$OUT")" "edge forms: a reference subsetting (::>) after the type keeps the story"
    tc_assert_eq "requirement US_9 : UserStory ::> base { }" "$(block_of US_9 "$OUT")" \
        "edge forms: ::> is read as one token, not as :: and >"
}

case_touched_only_changed_block() {
    local dir pre post
    tc_setup_repo
    tc_env
    dir="$(tc_mktemp_d)"
    pre="$TF_STAKEHOLDER"
    post="${dir}/post.sysml"

    sed -e 's/in one action/in a single action/' \
        -e 's/requirement US_003_CalibrateInField : UserStory {/requirement   US_003_CalibrateInField :  UserStory  {/' \
        "$pre" > "$post"
    run_tf vse_tf_touched_stories "$pre" "$post"
    tc_assert_eq "US_002_AcknowledgeAlertsBatched" "$OUT" \
        "touched: only the story whose text changed, whitespace aside"

    awk '/requirement US_004_RetainAlertHistory/ { exit } { print }' "$pre" > "$post"
    printf '    requirement US_005_New : UserStory {\n    }\n}\n' >> "$post"
    run_tf vse_tf_touched_stories "$pre" "$post"
    tc_assert_eq "US_005_New" "$OUT" "touched: a new story is touched and a deleted one is not listed"

    run_tf vse_tf_touched_stories "${dir}/absent.sysml" "$pre"
    tc_assert_eq "$TF_STAKEHOLDER_IDS" "$OUT" \
        "touched: with no pre-image every story is new"

    run_tf vse_tf_touched_stories "$pre" "$pre"
    tc_assert_empty "$OUT" "touched: an unchanged file touches nothing"
    tc_assert_rc 0 "touched: exit 0"
}

# ---------------------------------------------------- post-edit image

# tf_engine <jq|python3|jq-no-devfd|python3-no-devfd>: the PATH for
# the next runner call, with the other JSON tool taken away so the
# named one must do the work. jq-no-devfd is jq behind
# tc_stub_closed_devfd_jq, which cannot open a /dev/fd path, as jq
# cannot under the stock bash 3.2 of macOS once that shell has closed
# the descriptor behind it. python3-no-devfd is python3 behind
# tc_stub_closed_devfd_python3, beside a jq 1.5 (tc_stub_old_jq) whose
# probe fails, so python3 does the work after an external command has
# run, which is when bash 3.2 closes the descriptor. The two stub
# engines start from an empty stub directory, so neither sees the
# other's stubs.
tf_engine() {
    case "$1" in
        jq) tc_env PATH="$TF_BIN_NO_PYTHON" ;;
        python3) tc_env PATH="$TF_BIN_NO_JQ" ;;
        jq-no-devfd)
            tc_reset_stubs
            tc_stub_closed_devfd_jq
            tc_env PATH="${STUBS}:${TF_BIN_NO_PYTHON}"
            ;;
        python3-no-devfd)
            tc_reset_stubs
            tc_stub_old_jq
            tc_stub_closed_devfd_python3
            tc_env PATH="${STUBS}:/usr/bin:/bin"
            ;;
    esac
}

TF_ENGINES="jq python3"

# The disk image builds a payload of its own, which must reach jq or
# python3 as a path each can still open, so its cases also run with
# jq-no-devfd and python3-no-devfd.
TF_DISK_ENGINES="${TF_ENGINES} jq-no-devfd python3-no-devfd"

# tf_payload_edit <old> <new> <replace_all>: an Edit payload on stdout.
tf_payload_edit() {
    jq -n --arg o "$1" --arg n "$2" --argjson r "$3" \
        '{tool_name: "Edit", tool_input: {file_path: "x", old_string: $o, new_string: $n, replace_all: $r}}'
}

# tf_post_image <engine> <payload-json> <target> <case>: apply the
# payload, leaving the image in $TF_IMAGE.
TF_IMAGE=""
tf_post_image() {
    local engine="$1" json="$2" target="$3" dir
    dir="$(tc_mktemp_d)"
    printf '%s' "$json" > "${dir}/payload.json"
    TF_IMAGE="${dir}/image"
    tf_engine "$engine"
    run_tf_to "$TF_IMAGE" vse_tf_post_image "${dir}/payload.json" "$target"
}

# tf_assert_same <expected-file> <actual-file> <case>
tf_assert_same() {
    if cmp -s "$1" "$2"; then
        tc_pass "$3"
    else
        tc_fail "$3" "$(diff "$1" "$2" | head -20)
$(_tc_context)"
    fi
}

case_post_image_rename_by_name_only() {
    local engine target expected
    tc_setup_repo
    target="${REPO}/model/core/stories/stakeholder/stakeholder-stories.sysml"
    mkdir -p "$(dirname "$target")"
    cp "$TF_STAKEHOLDER" "$target"
    expected="$(tc_mktemp_d)/expected"
    sed 's/US_002_AcknowledgeAlertsBatched :/US_002_AcknowledgeAlertsInBatches :/' "$target" > "$expected"
    for engine in $TF_ENGINES; do
        tf_post_image "$engine" \
            "$(tf_payload_edit "US_002_AcknowledgeAlertsBatched :" "US_002_AcknowledgeAlertsInBatches :" false)" \
            "$target"
        tc_assert_rc 0 "post image (${engine}): a rename applies"
        tf_assert_same "$expected" "$TF_IMAGE" "post image (${engine}): the renamed register, byte for byte"
        tc_env
        run_tf vse_tf_touched_stories "$target" "$TF_IMAGE"
        tc_assert_eq "US_002_AcknowledgeAlertsInBatches" "$OUT" \
            "post image (${engine}): a rename alone makes the new ID a touched story"
    done
}

case_post_image_replace_all() {
    local engine target expected
    tc_setup_repo
    target="${REPO}/stories.sysml"
    cp "$TF_STAKEHOLDER" "$target"
    expected="$(tc_mktemp_d)/expected"
    sed 's/role : Operator;/role : Supervisor;/g' "$target" > "$expected"
    for engine in $TF_ENGINES; do
        tf_post_image "$engine" "$(tf_payload_edit "role : Operator;" "role : Supervisor;" true)" "$target"
        tc_assert_rc 0 "post image (${engine}): replace_all applies"
        tf_assert_same "$expected" "$TF_IMAGE" "post image (${engine}): replace_all replaces every occurrence"
        tc_env
        run_tf vse_tf_touched_stories "$target" "$TF_IMAGE"
        tc_assert_eq "US_001_SeeReadingsOnDashboard
US_002_AcknowledgeAlertsBatched" "$OUT" "post image (${engine}): both stories with the role are touched"
    done
}

case_post_image_edit_inside_doc() {
    local engine target expected
    tc_setup_repo
    target="${REPO}/stories.sysml"
    cp "$TF_STAKEHOLDER" "$target"
    expected="$(tc_mktemp_d)/expected"
    sed 's/displayed within 5 seconds/displayed within 3 seconds/' "$target" > "$expected"
    for engine in $TF_ENGINES; do
        tf_post_image "$engine" \
            "$(tf_payload_edit "displayed within 5 seconds" "displayed within 3 seconds" false)" "$target"
        tf_assert_same "$expected" "$TF_IMAGE" "post image (${engine}): an edit inside a doc body applies"
        tc_env
        run_tf vse_tf_touched_stories "$target" "$TF_IMAGE"
        tc_assert_eq "US_001_SeeReadingsOnDashboard" "$OUT" \
            "post image (${engine}): an acceptance text change touches its story"
    done
}

# Deleting the closer of a doc comment makes the comment run on into
# the next story, so the edited story's block absorbs it and the hidden
# story is gone from the post-image (a deletion is never touched).
case_post_image_delete_comment_closer() {
    local engine target expected
    tc_setup_repo
    target="${REPO}/stories.sysml"
    cp "$TF_STAKEHOLDER" "$target"
    expected="$(tc_mktemp_d)/expected"
    sed 's|of arrival at the cloud broker\. \*/|of arrival at the cloud broker.|' "$target" > "$expected"
    for engine in $TF_ENGINES; do
        tf_post_image "$engine" \
            "$(tf_payload_edit "of arrival at the cloud broker. */" "of arrival at the cloud broker." false)" \
            "$target"
        tf_assert_same "$expected" "$TF_IMAGE" "post image (${engine}): the closer is removed"
        tc_env
        run_tf_stdin "$TF_IMAGE" vse_tf_story_blocks
        tc_assert_eq "US_001_SeeReadingsOnDashboard
US_003_CalibrateInField
US_004_RetainAlertHistory" "$(ids_of "$OUT")" \
            "post image (${engine}): the story inside the open comment disappears"
        run_tf vse_tf_touched_stories "$target" "$TF_IMAGE"
        tc_assert_eq "US_001_SeeReadingsOnDashboard" "$OUT" \
            "post image (${engine}): the story that lost its closer is touched"
    done
}

case_post_image_empty_old_string() {
    local engine dir expected
    tc_setup_repo
    dir="$(tc_mktemp_d)"
    expected="${dir}/expected"
    printf 'package P {\n}\n' > "$expected"
    printf 'old content\n' > "${dir}/existing"
    : > "${dir}/empty"
    for engine in $TF_ENGINES; do
        tf_post_image "$engine" "$(tf_payload_edit "" "package P {
}
" false)" "${dir}/missing"
        tc_assert_rc 0 "post image (${engine}): an empty old_string on a missing file applies"
        tf_assert_same "$expected" "$TF_IMAGE" "post image (${engine}): an empty old_string gives new_string"

        tf_post_image "$engine" "$(tf_payload_edit "" "package P {
}
" false)" "${dir}/existing"
        tf_assert_same "$expected" "$TF_IMAGE" \
            "post image (${engine}): an empty old_string replaces the whole file"

        tf_post_image "$engine" "$(tf_payload_edit "old" "new" false)" "${dir}/missing"
        tc_assert_rc 4 "post image (${engine}): an edit to a missing file cannot be reproduced"
        tf_assert_same "${dir}/empty" "$TF_IMAGE" "post image (${engine}): a missing file reads as empty"
    done
    tc_env
}

case_post_image_multiedit() {
    local engine target expected json
    tc_setup_repo
    target="${REPO}/stories.sysml"
    cp "$TF_STAKEHOLDER" "$target"
    expected="$(tc_mktemp_d)/expected"
    sed -e 's/US_001_SeeReadingsOnDashboard/US_001_ViewReadingsLive/' \
        -e 's/Priority::medium/Priority::low/g' "$target" > "$expected"
    # The second edit only matches the text the first one wrote.
    json="$(jq -n '{tool_name: "MultiEdit", tool_input: {file_path: "x", edits: [
        {old_string: "US_001_SeeReadingsOnDashboard", new_string: "US_001_ViewReadings"},
        {old_string: "US_001_ViewReadings :", new_string: "US_001_ViewReadingsLive :"},
        {old_string: "Priority::medium", new_string: "Priority::low", replace_all: true}]}}')"
    for engine in $TF_ENGINES; do
        tf_post_image "$engine" "$json" "$target"
        tc_assert_rc 0 "post image (${engine}): MultiEdit applies"
        tf_assert_same "$expected" "$TF_IMAGE" "post image (${engine}): MultiEdit applies its edits in order"
    done
    tc_env
}

case_post_image_write() {
    local engine dir json
    tc_setup_repo
    dir="$(tc_mktemp_d)"
    printf 'old\n' > "${dir}/target"
    printf 'caf\303\251 "quoted" \\ back\n\nlast line, no newline' > "${dir}/expected"
    json="$(jq -n --rawfile c "${dir}/expected" '{tool_name: "Write", tool_input: {file_path: "x", content: $c}}')"
    for engine in $TF_ENGINES; do
        tf_post_image "$engine" "$json" "${dir}/target"
        tc_assert_rc 0 "post image (${engine}): Write applies"
        tf_assert_same "${dir}/expected" "$TF_IMAGE" "post image (${engine}): Write gives its content, byte for byte"
    done
    tc_env
}

case_post_image_no_json_tool() {
    local dir
    tc_setup_repo
    dir="$(tc_mktemp_d)"
    printf '%s' "$(tf_payload_edit a b false)" > "${dir}/payload.json"
    printf 'a\n' > "${dir}/target"
    tc_env PATH="$TF_BIN_NO_JSON"
    run_tf vse_tf_post_image "${dir}/payload.json" "${dir}/target"
    tc_assert_rc 3 "post image: exit 3 when neither jq nor python3 is present"
    tc_assert_empty "$OUT" "post image: nothing printed without a JSON tool"
    run_tf vse_tf_disk_image "${dir}/target"
    tc_assert_rc 3 "disk image: exit 3 when neither jq nor python3 is present"
    tc_env
}

# jq 1.5 has no halt_error, so it cannot compile the image program
# (tc_stub_old_jq stands in for it). python3 then does the work, as if
# jq were absent, so the in-session gates still see the edit instead
# of failing open.
case_post_image_old_jq_falls_back() {
    local dir
    tc_setup_repo
    tc_stub_old_jq
    dir="$(tc_mktemp_d)"
    printf 'alpha\r\nbeta\r\n' > "${dir}/target"
    printf 'alpha\ngamma\n' > "${dir}/expected"
    printf 'alpha\nbeta\n' > "${dir}/expected-disk"
    printf '%s' "$(tf_payload_edit beta gamma false)" > "${dir}/payload.json"
    printf '%s' "$(tf_payload_edit delta gamma false)" > "${dir}/missed.json"
    tc_env
    run_tf_to "${dir}/image" vse_tf_post_image "${dir}/payload.json" "${dir}/target"
    tc_assert_rc 0 "old jq: the edit applies through python3"
    tf_assert_same "${dir}/expected" "${dir}/image" "old jq: python3 gives the post image"
    tc_assert_not_grep "compile error" "$ERR" "old jq: the compile error is not passed on"
    run_tf_to "${dir}/image" vse_tf_post_image "${dir}/missed.json" "${dir}/target"
    tc_assert_rc 4 "old jq: an edit that cannot be reproduced still exits 4"
    run_tf_to "${dir}/image" vse_tf_disk_image "${dir}/target"
    tc_assert_rc 0 "old jq: the disk image reads through python3"
    tf_assert_same "${dir}/expected-disk" "${dir}/image" "old jq: python3 gives the disk image"
    tc_env PATH="${STUBS}:${TF_BIN_NO_PYTHON}"
    run_tf vse_tf_post_image "${dir}/payload.json" "${dir}/target"
    tc_assert_rc 3 "old jq: exit 3 when python3 is missing too"
    tc_env
}

# jq reads its input as UTF-8 and turns a byte that is not valid UTF-8
# into U+FFFD, while python3 keeps it. A pre-image read raw from disk
# would then differ from a jq post-image in every story holding such a
# byte, and an edit to one story would touch another. The disk image
# goes through the same engine as the post image, so only the edited
# story is touched, whichever engine runs.
case_disk_image_symmetric_latin1() {
    local engine dir target pre
    tc_setup_repo
    dir="$(tc_mktemp_d)"
    target="${dir}/stories.sysml"
    pre="${dir}/pre"
    # \351 is e-acute in Latin-1, a lone byte that is not valid UTF-8.
    printf 'package P {\n    requirement US_1 : UserStory {\n        doc /* caf\351 */\n    }\n    requirement US_2 : UserStory {\n        doc /* old text */\n    }\n}\n' \
        > "$target"
    for engine in $TF_DISK_ENGINES; do
        tf_engine "$engine"
        run_tf_to "$pre" vse_tf_disk_image "$target"
        tc_assert_rc 0 "disk image (${engine}): the register is read"
        tf_post_image "$engine" "$(tf_payload_edit "old text" "new text" false)" "$target"
        tc_assert_rc 0 "disk image (${engine}): the edit to US_2 applies"
        tc_env
        run_tf vse_tf_touched_stories "$pre" "$TF_IMAGE"
        tc_assert_eq "US_2" "$OUT" \
            "disk image (${engine}): a Latin-1 byte in US_1 does not touch US_1"
    done
    tc_reset_stubs
}

case_disk_image_plain() {
    local engine dir
    tc_setup_repo
    dir="$(tc_mktemp_d)"
    printf 'caf\303\251 "quoted" \\ back\r\n\nlast line, no newline\r' > "${dir}/utf8"
    printf 'caf\303\251 "quoted" \\ back\n\nlast line, no newline\r' > "${dir}/lf"
    : > "${dir}/empty"
    for engine in $TF_DISK_ENGINES; do
        tf_engine "$engine"
        run_tf_to "${dir}/image" vse_tf_disk_image "${dir}/utf8"
        tc_assert_rc 0 "disk image (${engine}): a UTF-8 file is read"
        tf_assert_same "${dir}/lf" "${dir}/image" \
            "disk image (${engine}): valid UTF-8 comes back byte for byte, with CRLF read as LF and a lone CR kept"
        run_tf_to "${dir}/image" vse_tf_disk_image "${dir}/missing"
        tc_assert_rc 0 "disk image (${engine}): a missing file is not an error"
        tf_assert_same "${dir}/empty" "${dir}/image" "disk image (${engine}): a missing file reads as empty"
    done
    tc_reset_stubs
    tc_env
}

# The disk image hands its no-edit payload to the engine in a temporary
# file under TMPDIR, which is gone when the function returns. Here
# TMPDIR is an empty scratch directory, and it is empty again after the
# image is read. A TMPDIR that does not exist makes mktemp fail, and
# the function then returns 2 with nothing on stdout, which the hooks
# read as an engine failure rather than as an empty file.
case_disk_image_payload_file() {
    local engine dir tmp
    tc_setup_repo
    dir="$(tc_mktemp_d)"
    printf 'alpha\r\nbeta\n' > "${dir}/target"
    printf 'alpha\nbeta\n' > "${dir}/expected"
    for engine in $TF_DISK_ENGINES; do
        tmp="$(tc_mktemp_d)"
        tf_engine "$engine"
        TC_ENV+=("TMPDIR=${tmp}")
        run_tf_to "${dir}/image" vse_tf_disk_image "${dir}/target"
        tc_assert_rc 0 "disk image (${engine}): the file is read with TMPDIR set"
        tf_assert_same "${dir}/expected" "${dir}/image" "disk image (${engine}): the image is the file, CRLF read as LF"
        tc_assert_empty "$(ls -A "$tmp")" "disk image (${engine}): the payload file is removed from TMPDIR"
    done
    tc_reset_stubs
    tc_env "TMPDIR=${dir}/no-such-dir"
    run_tf vse_tf_disk_image "${dir}/target"
    tc_assert_rc 2 "disk image: exit 2 when mktemp cannot make the payload file"
    tc_assert_empty "$OUT" "disk image: nothing on stdout when mktemp cannot make the payload file"
    tc_env
}

# A checkout with CRLF line endings (core.autocrlf on Windows) holds
# CRLF files, and the Edit tool matches the model's LF old_string
# against them, writing the original endings back. The image reads the
# file with CRLF as LF and normalises each old_string and new_string
# the same way, so a multi-line LF edit applies to a CRLF file, and
# the pre-image and the post-image stay comparable.
case_post_image_crlf() {
    local engine dir target expected json
    tc_setup_repo
    dir="$(tc_mktemp_d)"
    target="${dir}/stories.sysml"
    printf 'package P {\r\n    requirement US_1 : UserStory {\r\n    }\r\n}\r\n' > "$target"
    expected="${dir}/expected"
    printf 'package P {\n    requirement US_1 : UserStory {\n    }\n    requirement US_2 : UserStory {\n    }\n}\n' > "$expected"
    for engine in $TF_ENGINES; do
        tf_post_image "$engine" "$(tf_payload_edit "    }
}" "    }
    requirement US_2 : UserStory {
    }
}" false)" "$target"
        tc_assert_rc 0 "CRLF (${engine}): a multi-line LF edit applies to a CRLF file"
        tf_assert_same "$expected" "$TF_IMAGE" "CRLF (${engine}): the image reads CRLF as LF"
        tc_env
        run_tf vse_tf_touched_stories "$target" "$TF_IMAGE"
        tc_assert_eq "US_2" "$OUT" "CRLF (${engine}): only the added story is touched"

        tf_post_image "$engine" "$(tf_payload_edit "$(printf '    }\r\n}')" "$(printf '    }\r\n    requirement US_2 : UserStory {\r\n    }\r\n}')" false)" "$target"
        tf_assert_same "$expected" "$TF_IMAGE" "CRLF (${engine}): CRLF in old_string and new_string is read as LF"

        json="$(jq -n '{tool_name: "MultiEdit", tool_input: {file_path: "x", edits: [
            {old_string: "    }\n}", new_string: "    }\n    requirement US_2 : UserStory {\n    }\n}"}]}}')"
        tf_post_image "$engine" "$json" "$target"
        tf_assert_same "$expected" "$TF_IMAGE" "CRLF (${engine}): a MultiEdit applies to a CRLF file"
    done
    tc_env
}

# An old_string that occurs nowhere in the image as the edits reach it
# means the edit could not be reproduced. The image is still printed,
# unchanged by that edit, and the exit status 4 says so, so a caller
# can say the gate saw the file unchanged.
case_post_image_no_match() {
    local engine dir target json
    tc_setup_repo
    dir="$(tc_mktemp_d)"
    target="${dir}/target"
    printf 'alpha\nbeta\n' > "$target"
    for engine in $TF_ENGINES; do
        tf_post_image "$engine" "$(tf_payload_edit "gamma" "delta" false)" "$target"
        tc_assert_rc 4 "no match (${engine}): exit 4 when old_string does not occur"
        tf_assert_same "$target" "$TF_IMAGE" "no match (${engine}): the image is printed unchanged"

        json="$(jq -n '{tool_name: "MultiEdit", tool_input: {file_path: "x", edits: [
            {old_string: "alpha", new_string: "one"},
            {old_string: "alpha", new_string: "two"},
            {old_string: "beta", new_string: "three"}]}}')"
        tf_post_image "$engine" "$json" "$target"
        tc_assert_rc 4 "no match (${engine}): exit 4 when a later MultiEdit edit no longer matches"
        printf 'one\nthree\n' > "${dir}/expected"
        tf_assert_same "${dir}/expected" "$TF_IMAGE" "no match (${engine}): the edits that match still apply"

        tf_post_image "$engine" "$(tf_payload_edit "beta" "gamma" false)" "$target"
        tc_assert_rc 0 "no match (${engine}): exit 0 when every old_string occurs"
        tf_post_image "$engine" "$(tf_payload_edit "" "fresh" false)" "${dir}/missing"
        tc_assert_rc 0 "no match (${engine}): an empty old_string always applies"
    done
    tc_env
}

case_post_image_unsupported_tool() {
    local engine dir
    tc_setup_repo
    dir="$(tc_mktemp_d)"
    printf 'a\n' > "${dir}/target"
    for engine in $TF_ENGINES; do
        tf_post_image "$engine" '{"tool_name": "NotebookEdit", "tool_input": {"notebook_path": "x"}}' "${dir}/target"
        tc_assert_rc 2 "post image (${engine}): exit 2 for a tool it cannot apply"
        tf_post_image "$engine" '{"tool_name": "Write", ' "${dir}/target"
        tc_assert_rc 2 "post image (${engine}): exit 2 for a malformed payload"
    done
    tc_env
}

# ------------------------------------------------------- feature tags

case_feature_tag_bom_crlf() {
    local dir
    tc_setup_repo
    tc_env
    dir="$(tc_mktemp_d)"
    printf '\357\273\277@US_001_X @AC_shown\r\nFeature: Readings\r\n' > "${dir}/a.feature"
    run_tf vse_tf_feature_has_tag "${dir}/a.feature" US_001_X
    tc_assert_rc 0 "feature tag: found after a BOM on a CRLF line"

    printf '\357\273\277# language: en\r\n\r\n   @wip   @US_001_X\r\n# a note\r\nFeature: Readings\r\n' > "${dir}/b.feature"
    run_tf vse_tf_feature_has_tag "${dir}/b.feature" US_001_X
    tc_assert_rc 0 "feature tag: comment and blank lines before the tag line are skipped"
}

case_feature_tag_prefix_id_rejected() {
    local dir
    tc_setup_repo
    tc_env
    dir="$(tc_mktemp_d)"
    printf '@US_001_XY\nFeature: Readings\n' > "${dir}/a.feature"
    run_tf vse_tf_feature_has_tag "${dir}/a.feature" US_001_X
    tc_assert_rc 1 "feature tag: a longer tag that starts with the ID does not count"
    printf '@US_001\nFeature: Readings\n' > "${dir}/b.feature"
    run_tf vse_tf_feature_has_tag "${dir}/b.feature" US_001_X
    tc_assert_rc 1 "feature tag: a prefix of the ID does not count"
    printf 'Feature: Readings\n  @US_001_X\n  Scenario: shown\n' > "${dir}/c.feature"
    run_tf vse_tf_feature_has_tag "${dir}/c.feature" US_001_X
    tc_assert_rc 1 "feature tag: a tag after the Feature: line does not count"
    printf '@US_001_X\n' > "${dir}/d.feature"
    run_tf vse_tf_feature_has_tag "${dir}/d.feature" US_001_X
    tc_assert_rc 1 "feature tag: a file with no Feature: line does not count"
    run_tf vse_tf_feature_has_tag "${dir}/absent.feature" US_001_X
    tc_assert_rc 1 "feature tag: a missing file does not count"
}

case_feature_tag_in_comment_rejected() {
    local dir
    tc_setup_repo
    tc_env
    dir="$(tc_mktemp_d)"
    printf '# @US_001_X\nFeature: Readings\n' > "${dir}/a.feature"
    run_tf vse_tf_feature_has_tag "${dir}/a.feature" US_001_X
    tc_assert_rc 1 "feature tag: a tag inside a comment line does not count"
    printf '@other #@US_001_X @US_001_X\nFeature: Readings\n' > "${dir}/b.feature"
    run_tf vse_tf_feature_has_tag "${dir}/b.feature" US_001_X
    tc_assert_rc 1 "feature tag: a tag after a trailing comment does not count"
}

# ------------------------------------------------------ classification

case_classify_never_list() {
    local rel
    tc_setup_repo
    tc_config light -
    tc_config_append <<'EOF'
test_first:
  applies: true
  code_paths: ["*"]
  test_paths: [tests/*]
EOF
    tc_env
    for rel in .iso-config.yaml tests/login.feature src/a/b.feature \
        docs/generated/matrix.md tools/render/doc.py tools/lint/story-wellformed.py; do
        run_tf vse_tf_classify "$rel"
        tc_assert_eq "never" "$OUT" "classify: ${rel} is never code"
    done
    run_tf vse_tf_classify templates/tools/render/doc.py
    tc_assert_eq "code" "$OUT" "classify: the never-list is anchored at the engineering root"
    # Every gate agrees with PreToolUse: a file named .iso-config.yaml
    # is never code, wherever it sits, not only the resolved one.
    for rel in sub/.iso-config.yaml src/deep/.iso-config.yaml; do
        run_tf vse_tf_classify "$rel"
        tc_assert_eq "never" "$OUT" "classify: ${rel}, a configuration file below the one in force, is never code"
    done
    run_tf vse_tf_classify src/iso-config.yaml
    tc_assert_eq "code" "$OUT" "classify: only the exact name .iso-config.yaml is never code"

    # A brownfield project keeps its configuration under engineering/.
    tc_setup_repo
    mkdir -p "${REPO}/engineering"
    printf 'project_profile: light\ntest_first:\n  code_paths: ["*"]\n  test_paths: [tests/*]\n' \
        > "${REPO}/engineering/.iso-config.yaml"
    for rel in engineering/.iso-config.yaml engineering/docs/generated/x.md \
        engineering/tools/render/doc.py engineering/tools/lint/lint.py; do
        run_tf vse_tf_classify "$rel"
        tc_assert_eq "never" "$OUT" "classify (brownfield): ${rel} is never code"
    done
    for rel in tools/render/doc.py docs/generated/x.md; do
        run_tf vse_tf_classify "$rel"
        tc_assert_eq "code" "$OUT" "classify (brownfield): ${rel} outside the engineering root is code"
    done
    run_tf vse_tf_classify .iso-config.yaml
    tc_assert_eq "never" "$OUT" "classify (brownfield): a configuration file at the top level is never code"
}

case_classify_globs_cross_slash() {
    tc_setup_repo
    tf_config
    tc_env
    # A file the glob would expand to, were it ever expanded.
    mkdir -p "${REPO}/src"
    : > "${REPO}/src/a.py"
    run_tf vse_tf_classify src/deep/er/b.py
    tc_assert_eq "code" "$OUT" "classify: a * in a glob crosses /"
    run_tf vse_tf_classify scripts/tools/x.sh
    tc_assert_eq "code" "$OUT" "classify: a * before a suffix crosses / too"
    run_tf vse_tf_classify tests/unit/test_b.py
    tc_assert_eq "test" "$OUT" "classify: a test path"
    run_tf vse_tf_classify README.md
    tc_assert_eq "other" "$OUT" "classify: a path matching neither list is other"

    tc_setup_repo
    tc_config light -
    tc_config_append <<'EOF'
test_first:
  code_paths: [src/*]
  test_paths: [src/*_test.py]
EOF
    run_tf vse_tf_classify src/app_test.py
    tc_assert_eq "test" "$OUT" "classify: test_paths wins over code_paths"
    rm -f "${REPO}/.iso-config.yaml"
    run_tf vse_tf_classify src/app.py
    tc_assert_eq "other" "$OUT" "classify: with no configuration nothing is code"
}

case_classify_absolute_path_rejected() {
    tc_setup_repo
    tf_config
    tc_env
    run_tf vse_tf_classify "${REPO}/src/app.py"
    tc_assert_rc 2 "classify: an absolute path is rejected"
    tc_assert_empty "$OUT" "classify: nothing printed for an absolute path"
    tc_assert_grep "relative to the git top level" "$ERR" "classify: the rejection names the expected form"
    run_tf vse_tf_classify ../outside/src/app.py
    tc_assert_rc 2 "classify: a path that leaves the top level is rejected"
}

# ------------------------------------------------------------ evidence

# A committed project with one code file and one test file on main.
tf_evidence_repo() {
    tc_setup_repo
    tf_config
    printf 'x = 1\n' | tc_write src/app.py
    printf 'def test_app(): pass\n' | tc_write tests/test_app.py
    tc_stage .iso-config.yaml src/app.py tests/test_app.py
    tc_commit "initial"
    tc_env
}

case_evidence_working_tree() {
    tf_evidence_repo
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 1 "evidence: a clean tree on main has none"
    tc_assert_grep "reason: " "$OUT" "evidence: no evidence comes with a reason"

    printf 'def test_more(): pass\n' >> "${REPO}/tests/test_app.py"
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 0 "evidence: a modified test file"
    tc_assert_eq "evidence: tests/test_app.py" "$OUT" "evidence: names the modified test file"

    git -C "$REPO" checkout -q -- tests/test_app.py
    git -C "$REPO" mv src/app.py tests/test_moved.py
    run_tf vse_tf_evidence "$REPO"
    tc_assert_eq "evidence: tests/test_moved.py" "$OUT" "evidence: a rename into the test paths"
}

# In the -z format a rename carries its old path as an extra field. The
# old path here reads as a test path if it is mistaken for a record of
# its own ("ab" taken as the status, "tests/x.py" as the path).
case_evidence_rename_extra_field() {
    tf_evidence_repo
    printf 'y = 1\n' | tc_write "ab tests/x.py"
    tc_stage "ab tests/x.py"
    tc_commit "odd name"
    mkdir -p "${REPO}/moved"
    git -C "$REPO" mv "ab tests/x.py" "moved/x.py"
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 1 "evidence: the old path of a rename is not a record"
    tc_assert_not_grep "evidence:" "$OUT" "evidence: nothing claimed from a rename's old path"
}

case_evidence_untracked_test() {
    tf_evidence_repo
    printf 'test_first:\n  test_paths: [tests/*.py]\n' > "${REPO}/.iso-config.yaml"
    printf 'def test_b(): pass\n' | tc_write tests/unit/test_b.py
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 0 "evidence: an untracked test file in an untracked directory"
    tc_assert_eq "evidence: tests/unit/test_b.py" "$OUT" "evidence: untracked files are listed one by one"
}

case_evidence_deleted_test_ignored() {
    tf_evidence_repo
    rm "${REPO}/tests/test_app.py"
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 1 "evidence: a deleted test file is not evidence"
    tc_assert_match "^reason: .*main" "$OUT" "evidence: the reason names the base it compared against"

    git -C "$REPO" rm -q --cached tests/test_app.py
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 1 "evidence: a staged deletion is not evidence"
}

case_evidence_branch_since_main() {
    tf_evidence_repo
    git -C "$REPO" checkout -q -b feat/new
    printf 'def test_new(): pass\n' | tc_write tests/test_new.py
    tc_stage tests/test_new.py
    tc_commit "test first"
    printf 'x = 2\n' | tc_write src/app.py
    tc_stage src/app.py
    tc_commit "code"
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 0 "evidence: a test committed on the branch"
    tc_assert_eq "evidence: tests/test_new.py" "$OUT" "evidence: names the test changed since the merge base"

    git -C "$REPO" checkout -q -b feat/code main
    printf 'x = 3\n' | tc_write src/app.py
    tc_stage src/app.py
    tc_commit "code only"
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 1 "evidence: a code-only branch has none"
    tc_assert_match "^reason: .*merge base with main" "$OUT" "evidence: the reason names main"

    # A literal protected branch comes first. develop already holds a
    # test change, so measuring from main would wrongly find it.
    tf_evidence_repo
    printf 'protected_branches:\n  - release/*\n  - develop # integration\n' >> "${REPO}/.iso-config.yaml"
    git -C "$REPO" checkout -q -b develop
    printf 'def test_dev(): pass\n' | tc_write tests/test_dev.py
    tc_stage tests/test_dev.py
    tc_commit "develop test"
    git -C "$REPO" checkout -q -b feat/on-develop
    printf 'x = 4\n' | tc_write src/app.py
    tc_stage src/app.py
    tc_commit "code"
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 1 "evidence: measured from the protected develop branch"
    tc_assert_match "^reason: .*merge base with develop" "$OUT" "evidence: the reason names develop"

    # The same branch on origin is next when no local branch exists.
    git -C "$REPO" update-ref refs/remotes/origin/develop develop
    git -C "$REPO" branch -q -D develop
    run_tf vse_tf_evidence "$REPO"
    tc_assert_match "^reason: .*merge base with origin/develop" "$OUT" "evidence: origin/develop when develop is absent"
}

# The commit gate counts only the branch since its merge base, because
# it checks the commit's own files itself. A test that is untracked,
# or modified but not staged, is not in the commit and not on the
# branch, so in branch mode it is not evidence.
case_evidence_branch_mode() {
    tf_evidence_repo
    git -C "$REPO" checkout -q -b feat/new
    printf 'def test_new(): pass\n' | tc_write tests/test_new.py
    run_tf vse_tf_evidence "$REPO" branch
    tc_assert_rc 1 "evidence, branch mode: an untracked test is not evidence"
    tc_assert_eq "reason: no test path changed in the commit or on the branch since the merge base with main" "$OUT" \
        "evidence, branch mode: the reason names the commit and the branch, not the working tree"
    # The commit gate in range mode has checked a range, not a commit,
    # and names it as the third argument, so the reason speaks of it.
    run_tf vse_tf_evidence "$REPO" branch "in the range HEAD~1..HEAD"
    tc_assert_rc 1 "evidence, branch mode: a named change set does not change what counts"
    tc_assert_eq "reason: no test path changed in the range HEAD~1..HEAD or on the branch since the merge base with main" "$OUT" \
        "evidence, branch mode: the reason names the change set the caller gives"
    printf 'def test_more(): pass\n' >> "${REPO}/tests/test_app.py"
    run_tf vse_tf_evidence "$REPO" branch
    tc_assert_rc 1 "evidence, branch mode: a modified, unstaged test is not evidence"
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 0 "evidence, default mode: the working tree still counts"

    tc_stage tests/test_new.py
    tc_commit "test first"
    run_tf vse_tf_evidence "$REPO" branch
    tc_assert_rc 0 "evidence, branch mode: a test committed on the branch"
    tc_assert_eq "evidence: tests/test_new.py" "$OUT" "evidence, branch mode: names the committed test"

    git -C "$REPO" checkout -q --detach
    run_tf vse_tf_evidence "$REPO" branch
    tc_assert_rc 1 "evidence, branch mode: a detached HEAD has none"
    tc_assert_match "^reason: detached HEAD .*no test path changed in the commit$" "$OUT" \
        "evidence, branch mode: the detached HEAD reason does not mention the working tree"
    run_tf vse_tf_evidence "$REPO" branch "in the range main..HEAD"
    tc_assert_match "^reason: detached HEAD .*no test path changed in the range main\.\.HEAD$" "$OUT" \
        "evidence, branch mode: the detached HEAD reason names the change set the caller gives"
}

# protected_branches may be written as a flow list too.
case_evidence_protected_flow_list() {
    tf_evidence_repo
    printf 'protected_branches: [release/*, "develop"]  # integration\n' >> "${REPO}/.iso-config.yaml"
    git -C "$REPO" checkout -q -b develop
    printf 'def test_dev(): pass\n' | tc_write tests/test_dev.py
    tc_stage tests/test_dev.py
    tc_commit "develop test"
    git -C "$REPO" checkout -q -b feat/on-develop
    printf 'x = 4\n' | tc_write src/app.py
    tc_stage src/app.py
    tc_commit "code"
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 1 "evidence: measured from a develop branch named in a flow list"
    tc_assert_match "^reason: .*merge base with develop" "$OUT" "evidence: the flow-list entry is the base"
}

case_evidence_shallow() {
    local clone
    tf_evidence_repo
    printf 'x = 2\n' | tc_write src/app.py
    tc_stage src/app.py
    tc_commit "second"
    clone="$(tc_mktemp_d)/clone"
    git clone -q --depth 1 "file://${REPO}" "$clone"
    run_tf_at "$clone" vse_tf_evidence "$clone"
    tc_assert_rc 1 "evidence: a shallow clone gives no branch evidence"
    tc_assert_match "^reason: .*shallow clone" "$OUT" "evidence: the reason says shallow clone"
}

case_evidence_detached() {
    tf_evidence_repo
    git -C "$REPO" checkout -q --detach
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 1 "evidence: a detached HEAD gives no branch evidence"
    tc_assert_match "^reason: .*detached HEAD" "$OUT" "evidence: the reason says detached HEAD"
}

case_evidence_unborn() {
    tc_setup_repo
    tf_config
    tc_env
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 1 "evidence: an unborn HEAD gives no branch evidence"
    tc_assert_match "^reason: .*unborn HEAD" "$OUT" "evidence: the reason says unborn HEAD"
    printf 'def test_a(): pass\n' | tc_write tests/test_a.py
    run_tf vse_tf_evidence "$REPO"
    tc_assert_rc 0 "evidence: the working tree still counts on an unborn HEAD"
    tc_assert_eq "evidence: tests/test_a.py" "$OUT" "evidence: names the untracked test"
}

# ------------------------------------------- branches, detection, misc

case_refactor_branch() {
    tf_evidence_repo
    git -C "$REPO" checkout -q -b refactor/split
    run_tf vse_tf_refactor_branch
    tc_assert_rc 0 "refactor: refactor/* is the default"
    git -C "$REPO" checkout -q -b feat/x
    run_tf vse_tf_refactor_branch
    tc_assert_rc 1 "refactor: a feature branch is not a refactor branch"

    printf '  refactor_branches: [cleanup/*, "tidy-*"]\n' >> "${REPO}/.iso-config.yaml"
    git -C "$REPO" checkout -q -b tidy-names
    run_tf vse_tf_refactor_branch
    tc_assert_rc 0 "refactor: a recorded glob matches"
    git -C "$REPO" checkout -q refactor/split
    run_tf vse_tf_refactor_branch
    tc_assert_rc 1 "refactor: a recorded list replaces the default"

    tf_evidence_repo
    printf '  refactor_branches: []\n' >> "${REPO}/.iso-config.yaml"
    git -C "$REPO" checkout -q -b refactor/split
    run_tf vse_tf_refactor_branch
    tc_assert_rc 1 "refactor: an explicit empty list names no branch"

    tf_evidence_repo
    git -C "$REPO" checkout -q --detach
    run_tf vse_tf_refactor_branch
    tc_assert_rc 1 "refactor: a detached HEAD is not a refactor branch"
}

# The PreToolUse hook runs in the session's directory, which need not be
# the repository of the edited file, so the top level can be named.
case_refactor_branch_toplevel() {
    local elsewhere
    tf_evidence_repo
    git -C "$REPO" checkout -q -b refactor/split
    elsewhere="$(tc_mktemp_d)"
    run_tf_at "$elsewhere" vse_tf_refactor_branch "$REPO"
    tc_assert_rc 0 "refactor: the branch of the named top level is read"
    git -C "$REPO" checkout -q -b feat/x
    run_tf_at "$elsewhere" vse_tf_refactor_branch "$REPO"
    tc_assert_rc 1 "refactor: a feature branch in the named top level is not a refactor branch"

    git -C "$elsewhere" init -q -b refactor/here
    git -C "$elsewhere" -c user.email=t@example.invalid -c user.name=t commit -q --allow-empty -m init
    run_tf_at "$elsewhere" vse_tf_refactor_branch "$REPO"
    tc_assert_rc 1 "refactor: the named top level wins over the working directory"
    run_tf_at "$elsewhere" vse_tf_refactor_branch
    tc_assert_rc 0 "refactor: with no top level the working directory is read"
}

# CI checks a pull request out as a detached merge commit, so a caller
# can name the branch (GITHUB_HEAD_REF there) instead of reading it.
case_refactor_branch_named() {
    tf_evidence_repo
    git -C "$REPO" checkout -q --detach
    run_tf vse_tf_refactor_branch "$REPO" refactor/split
    tc_assert_rc 0 "refactor: a named refactor branch matches on a detached HEAD"
    git -C "$REPO" checkout -q -b refactor/split
    run_tf vse_tf_refactor_branch "$REPO" feat/x
    tc_assert_rc 1 "refactor: a named branch wins over the branch checked out"
    run_tf vse_tf_refactor_branch "$REPO" ""
    tc_assert_rc 0 "refactor: an empty name reads the branch checked out"
}

case_detect_pytest() {
    local dir
    tc_setup_repo
    tc_env
    dir="$(tc_mktemp_d)"
    printf '[project]\nname = "x"\n\n[tool.pytest.ini_options]\naddopts = "-q"\n' > "${dir}/pyproject.toml"
    run_tf vse_tf_detect "$dir"
    tc_assert_rc 0 "detect: pytest configuration found"
    tc_assert_eq "pytest" "$OUT" "detect: pytest from pyproject.toml"
    mkdir "${dir}/tests"
    run_tf vse_tf_detect "$dir"
    tc_assert_eq "pytest
tests-dir" "$OUT" "detect: one key per tool, in table order"
}

case_detect_none() {
    local dir
    tc_setup_repo
    tc_env
    dir="$(tc_mktemp_d)"
    printf '# A project\n' > "${dir}/README.md"
    printf '[project]\nname = "x"\n' > "${dir}/pyproject.toml"
    printf '{"scripts": {"test": "echo \\"Error: no test specified\\" && exit 1"}}\n' > "${dir}/package.json"
    printf '<project/>\n' > "${dir}/pom.xml"
    run_tf vse_tf_detect "$dir"
    tc_assert_rc 1 "detect: exit 1 when nothing is found"
    tc_assert_empty "$OUT" "detect: nothing printed, the npm placeholder and a bare pom.xml included"
    run_tf vse_tf_detect "${dir}/absent"
    tc_assert_rc 1 "detect: exit 1 for a missing directory"
}

# Only a "test" key inside the "scripts" object of package.json is an
# npm test script. The same key elsewhere, such as directories.test,
# names something else.
case_detect_npm_test_in_scripts() {
    local dir
    tc_setup_repo
    tc_env
    dir="$(tc_mktemp_d)"
    printf '{"name": "x", "directories": {"test": "spec"}}\n' > "${dir}/package.json"
    run_tf vse_tf_detect "$dir"
    tc_assert_rc 1 "detect: directories.test is not a test script"
    tc_assert_empty "$OUT" "detect: nothing printed for directories.test"

    printf '{\n  "directories": {"test": "spec"},\n  "scripts": {\n    "build": "tsc"\n  }\n}\n' > "${dir}/package.json"
    run_tf vse_tf_detect "$dir"
    tc_assert_empty "$OUT" "detect: a scripts object with no test key is not a test script"

    printf '{"scripts": {"build": "tsc"}, "directories": {"test": "spec"}}\n' > "${dir}/package.json"
    run_tf vse_tf_detect "$dir"
    tc_assert_empty "$OUT" "detect: the scripts object ends at its closing brace"
    printf '{"config": {"scripts": {}, "test": "x"}}\n' > "${dir}/package.json"
    run_tf vse_tf_detect "$dir"
    tc_assert_empty "$OUT" "detect: a scripts object below the top level does not count"
    printf '{"scripts": {"x": {"test": "y"}}}\n' > "${dir}/package.json"
    run_tf vse_tf_detect "$dir"
    tc_assert_empty "$OUT" "detect: a test key nested deeper inside scripts does not count"
    printf '{"scripts": {"build": "tsc", "test": ""}}\n' > "${dir}/package.json"
    run_tf vse_tf_detect "$dir"
    tc_assert_rc 1 "detect: an empty test script is not test tooling"
    tc_assert_empty "$OUT" "detect: nothing printed for an empty test script"

    printf '{\n  "description": "a \\"test\\": {",\n  "scripts": {\n    "lint": "eslint .",\n    "test": "node --test"\n  }\n}\n' > "${dir}/package.json"
    run_tf vse_tf_detect "$dir"
    tc_assert_eq "npm-test" "$OUT" "detect: scripts.test over several lines, after a string holding braces"
}

# tf_detect_one <key> <setup-command>: a fresh directory, set up by the
# command run inside it, detects exactly <key>.
tf_detect_one() {
    local key="$1" setup="$2" dir
    dir="$(tc_mktemp_d)"
    (cd "$dir" && eval "$setup")
    run_tf vse_tf_detect "$dir"
    tc_assert_eq "$key" "$OUT" "detect: ${key}"
}

case_detect_each_key() {
    tc_setup_repo
    tc_env
    tf_detect_one pytest 'printf "[pytest]\n" > pytest.ini'
    tf_detect_one npm-test 'printf "{\"scripts\": {\"test\": \"node --test\"}}\n" > package.json'
    tf_detect_one jest ': > jest.config.js'
    tf_detect_one vitest ': > vitest.config.ts'
    tf_detect_one cargo 'printf "[package]\n" > Cargo.toml'
    tf_detect_one go 'printf "module x\n" > go.mod'
    tf_detect_one maven ': > pom.xml; mkdir -p src/test/java'
    tf_detect_one gradle ': > build.gradle.kts; mkdir -p src/test/kotlin'
    tf_detect_one ctest 'printf "project(x)\nenable_testing()\n" > CMakeLists.txt'
    tf_detect_one make-test 'printf "all:\n\ttrue\n\ntest: all\n\ttrue\n" > Makefile'
    tf_detect_one tests-dir 'mkdir tests'
    tf_detect_one tests-dir 'mkdir test'
    tf_detect_one spec-dir 'mkdir spec'
    tf_detect_one behave 'printf "[behave]\n" > behave.ini'
    tf_detect_one cucumber 'printf "module.exports = {}\n" > cucumber.js'
    tf_detect_one bats 'mkdir -p scripts/check && : > scripts/check/run.bats'
}

case_applies_values() {
    tc_setup_repo
    tc_config light -
    tc_env
    run_tf vse_tf_applies
    tc_assert_empty "$OUT" "applies: nothing when test_first is unrecorded"
    tc_assert_rc 0 "applies: exit 0 when unrecorded"
    printf 'test_first:\n  applies: true  # judged\n' >> "${REPO}/.iso-config.yaml"
    run_tf vse_tf_applies
    tc_assert_eq "true" "$OUT" "applies: true"
    tc_config light -
    printf 'test_first:\n  applies: False\n' >> "${REPO}/.iso-config.yaml"
    run_tf vse_tf_applies
    tc_assert_eq "false" "$OUT" "applies: False reads as false"
    tc_config light -
    printf 'test_first:\n  applies: maybe\n' >> "${REPO}/.iso-config.yaml"
    run_tf vse_tf_applies
    tc_assert_empty "$OUT" "applies: an unrecognised value prints nothing"
    tc_assert_grep "Unrecognised test_first.applies value 'maybe'" "$ERR" "applies: an unrecognised value is reported"
}

# applies: true with code_paths or test_paths that read empty (a
# missing or misspelt key, or a list that cannot be read) leaves the
# test-first gates unable to tell code from tests. The helper names the
# keys that read empty, and is false wherever test first does not apply.
case_missing_paths() {
    tc_setup_repo
    tc_env
    tc_config light -
    printf 'test_first:\n  applies: true\n  code_paths: [src/*]\n  test_paths: [tests/*]\n' >> "${REPO}/.iso-config.yaml"
    run_tf vse_tf_missing_paths
    tc_assert_rc 1 "missing paths: a complete record has none"
    tc_assert_empty "$OUT" "missing paths: nothing printed for a complete record"

    tc_config light -
    printf 'test_first:\n  applies: true\n  code_path: [src/*]\n  test_paths: [tests/*]\n' >> "${REPO}/.iso-config.yaml"
    run_tf vse_tf_missing_paths
    tc_assert_rc 0 "missing paths: a misspelt code_paths key"
    tc_assert_eq "test_first.code_paths" "$OUT" "missing paths: the misspelt key is named"

    tc_config light -
    printf 'test_first:\n  applies: true\n  code_paths: [src/*]\n' >> "${REPO}/.iso-config.yaml"
    run_tf vse_tf_missing_paths
    tc_assert_eq "test_first.test_paths" "$OUT" "missing paths: a missing test_paths key is named"

    tc_config light -
    printf 'test_first:\n  applies: true\n' >> "${REPO}/.iso-config.yaml"
    run_tf vse_tf_missing_paths
    tc_assert_eq "test_first.code_paths and test_first.test_paths" "$OUT" "missing paths: both keys are named"

    tc_config light -
    printf 'test_first:\n  applies: true\n  code_paths:\n    -src/*\n  test_paths: [tests/*]\n' >> "${REPO}/.iso-config.yaml"
    run_tf vse_tf_missing_paths
    tc_assert_rc 1 "missing paths: an item with no space after its dash is read"

    tc_config light -
    printf 'test_first:\n  applies: false\n' >> "${REPO}/.iso-config.yaml"
    run_tf vse_tf_missing_paths
    tc_assert_rc 1 "missing paths: none where applies is false"
    tc_config light -
    run_tf vse_tf_missing_paths
    tc_assert_rc 1 "missing paths: none where test_first is unrecorded"
}

# ------------------------------------------------ paths and config

# test-first.sh reads the configuration through iso-profile.sh, so
# sourcing it without that library, or beside an older copy that lacks
# iso_list, fails at once with one line.
case_requires_profile_library() {
    tc_setup_repo
    tc_env
    # shellcheck disable=SC2016  # expanded by the shell under test
    tc_run_in "$REPO" bash -c '. "$1/test-first.sh"' guard "$TF_LIB"
    tc_assert_rc 1 "guard: test-first.sh alone refuses to load"
    tc_assert_grep "Source iso-profile.sh before test-first.sh." "$ERR" "guard: the refusal names iso-profile.sh"
    # shellcheck disable=SC2016  # expanded by the shell under test
    tc_run_in "$REPO" bash -c 'iso_section_list() { :; }; iso_section_scalar() { :; }; . "$1/test-first.sh"' guard "$TF_LIB"
    tc_assert_rc 1 "guard: an iso-profile.sh without iso_list is refused"
}

case_find_config_nested_demo() {
    local outer top
    tc_setup_repo
    tc_env
    top="$(cd "$REPO" && pwd -P)"
    mkdir -p "${REPO}/demo/smart-sensor/model/core/stories/stakeholder" "${REPO}/hooks"
    printf 'project_profile: standard\n' > "${REPO}/demo/smart-sensor/.iso-config.yaml"
    run_tf vse_tf_find_config "${REPO}/demo/smart-sensor/model/core/stories/stakeholder/new-story.sysml"
    tc_assert_eq "${top}/demo/smart-sensor/.iso-config.yaml" "$OUT" \
        "find config: the nested demo project's configuration"
    run_tf vse_tf_find_config "${REPO}/demo/smart-sensor/not/yet/created/file.sysml"
    tc_assert_eq "${top}/demo/smart-sensor/.iso-config.yaml" "$OUT" \
        "find config: found from a directory that does not exist yet"
    run_tf vse_tf_find_config "${REPO}/hooks/pre-commit.sh"
    tc_assert_empty "$OUT" "find config: none above a file outside the demo"

    mkdir -p "${REPO}/engineering"
    printf 'project_profile: full\n' > "${REPO}/engineering/.iso-config.yaml"
    run_tf vse_tf_find_config "${REPO}/hooks/pre-commit.sh"
    tc_assert_eq "${top}/engineering/.iso-config.yaml" "$OUT" \
        "find config: engineering/.iso-config.yaml at the top level"
    printf 'project_profile: light\n' > "${REPO}/.iso-config.yaml"
    run_tf vse_tf_find_config "${REPO}/hooks/pre-commit.sh"
    tc_assert_eq "${top}/.iso-config.yaml" "$OUT" "find config: the top-level file wins over engineering/"

    # The walk stops at the git top level.
    outer="$(cd "$(tc_mktemp_d)" && pwd -P)"
    printf 'project_profile: full\n' > "${outer}/.iso-config.yaml"
    git init -q "${outer}/repo"
    run_tf vse_tf_find_config "${outer}/repo/src/app.py"
    tc_assert_empty "$OUT" "find config: the walk stops at the git top level"
    # Outside git the walk goes on up.
    run_tf vse_tf_find_config "${outer}/plain/dir/file.txt"
    tc_assert_eq "${outer}/.iso-config.yaml" "$OUT" "find config: outside git the walk continues upward"
}

# The lifecycle hooks locate the project they serve through one helper
# (vse_tf_locate_project, or vse_tf_locate_workdir for a hook that knows
# only its working directory), which sets three variables in the
# calling shell. The driver calls the named helper, prints the
# variables after the call and exits with the helper's status.
# shellcheck disable=SC2016
TF_LOCATE_DRIVER='
lib="$1"
fn="$2"
shift 2
. "${lib}/iso-profile.sh"
. "${lib}/test-first.sh"
rc=0
"$fn" "$@" || rc=$?
printf "config=%s\neng=%s\ntop=%s\n" "${VSE_TF_CONFIG-unset}" "${VSE_TF_ENG_ROOT-unset}" "${VSE_TF_TOP-unset}"
exit "$rc"
'

# run_locate <path>: locate the project that governs <path>, from $REPO.
run_locate() {
    tc_run_in "$REPO" bash -c "$TF_LOCATE_DRIVER" tf-locate "$TF_LIB" vse_tf_locate_project "$@"
}

# run_locate_workdir <dir>: locate the project for a hook whose working
# directory is <dir>, from $REPO.
run_locate_workdir() {
    tc_run_in "$REPO" bash -c "$TF_LOCATE_DRIVER" tf-locate "$TF_LIB" vse_tf_locate_workdir "$@"
}

# tf_assert_located <config> <eng> <top> <case>
tf_assert_located() {
    tc_assert_rc 0 "$4: found"
    tc_assert_eq "config=$1
eng=$2
top=$3" "$OUT" "$4"
}

# tf_assert_not_located <case>: return 1 with the three variables empty.
tf_assert_not_located() {
    tc_assert_rc 1 "$1: not found"
    tc_assert_eq "config=
eng=
top=" "$OUT" "$1"
}

case_locate_project_layouts() {
    local top outer
    tc_setup_repo
    tc_env
    top="$(cd "$REPO" && pwd -P)"
    tc_config light -
    run_locate "${REPO}/src/not/yet/reading.py"
    tf_assert_located "${top}/.iso-config.yaml" "$top" "$top" \
        "locate: a new file below the top-level configuration"
    run_locate "$REPO"
    tf_assert_located "${top}/.iso-config.yaml" "$top" "$top" \
        "locate: a directory is searched from itself, so the top level finds its own file"

    mkdir -p "${REPO}/projects/sensor/src"
    printf 'project_profile: full\n' > "${REPO}/projects/sensor/.iso-config.yaml"
    run_locate "${REPO}/projects/sensor"
    tf_assert_located "${top}/projects/sensor/.iso-config.yaml" "${top}/projects/sensor" "$top" \
        "locate: a project directory below the top level finds its own configuration"
    run_locate "${REPO}/projects/sensor/src/reading.py"
    tf_assert_located "${top}/projects/sensor/.iso-config.yaml" "${top}/projects/sensor" "$top" \
        "locate: the nearest configuration governs, and its directory is the engineering root"

    rm -f "${REPO}/.iso-config.yaml"
    mkdir -p "${REPO}/engineering"
    printf 'project_profile: standard\n' > "${REPO}/engineering/.iso-config.yaml"
    run_locate "${REPO}/src/reading.py"
    tf_assert_located "${top}/engineering/.iso-config.yaml" "${top}/engineering" "$top" \
        "locate: the brownfield configuration under engineering/ at the top level"

    outer="$(cd "$(tc_mktemp_d)" && pwd -P)"
    mkdir -p "${outer}/plain/dir"
    printf 'project_profile: light\n' > "${outer}/.iso-config.yaml"
    run_locate "${outer}/plain/dir/file.txt"
    tf_assert_located "${outer}/.iso-config.yaml" "$outer" "" \
        "locate: outside git the configuration is found and the top level is empty"
}

case_locate_project_none() {
    local outside
    tc_setup_repo
    tc_env VSE_TF_CONFIG=stale VSE_TF_ENG_ROOT=stale VSE_TF_TOP=stale
    run_locate "${REPO}/src/reading.py"
    tf_assert_not_located "locate: a git repository with no configuration, earlier values cleared"
    outside="$(tc_mktemp_d)"
    run_locate "${outside}/x/y.txt"
    tf_assert_not_located "locate: a path outside every project"

    # The file tests come first, so a path with no configuration above
    # costs no git call. The stub git records every call, and the empty
    # placeholder configuration keeps iso-profile.sh from searching.
    tc_stub_recorder git
    : > "${FAKEHOME}/git-calls"
    : > "${FAKEHOME}/unset.yaml"
    tc_env "TC_INVOCATIONS=${FAKEHOME}/git-calls" "VSE_ISO_CONFIG=${FAKEHOME}/unset.yaml"
    run_locate "${REPO}/src/reading.py"
    tf_assert_not_located "locate: no configuration above, with git stubbed"
    tc_assert_empty "$(cat "${FAKEHOME}/git-calls")" "locate: no configuration above means no git call"
    tc_reset_stubs
    tc_env
}

# The plugin repository is the top level that holds both the wiki
# schema file and a plugin manifest naming vse-systems-engineering. A
# user project keeping its own wiki schema at wiki/CLAUDE.md is not it.
case_is_contributor() {
    local dir
    tc_setup_repo
    tc_env
    dir="$(tc_mktemp_d)"
    run_tf vse_tf_is_contributor "$dir"
    tc_assert_rc 1 "contributor: an empty directory is not the plugin repository"
    mkdir -p "${dir}/wiki"
    printf '# Our wiki\n' > "${dir}/wiki/CLAUDE.md"
    run_tf vse_tf_is_contributor "$dir"
    tc_assert_rc 1 "contributor: the wiki schema file alone is a user project"
    tc_mark_plugin_repo "$dir"
    run_tf vse_tf_is_contributor "$dir"
    tc_assert_rc 0 "contributor: the wiki schema file and the plugin manifest"
    run_tf vse_tf_is_contributor "${dir}/"
    tc_assert_rc 0 "contributor: a trailing slash is accepted"
    printf '{"version": "1.0.0", "name" : "vse-systems-engineering"}\n' > "${dir}/.claude-plugin/plugin.json"
    run_tf vse_tf_is_contributor "$dir"
    tc_assert_rc 0 "contributor: the name is read wherever it sits on its line"
    printf '{\n  "name": "our-own-plugin"\n}\n' > "${dir}/.claude-plugin/plugin.json"
    run_tf vse_tf_is_contributor "$dir"
    tc_assert_rc 1 "contributor: a manifest naming another plugin is a user project"
    printf '{\n  "name": "vse-systems-engineering-fork"\n}\n' > "${dir}/.claude-plugin/plugin.json"
    run_tf vse_tf_is_contributor "$dir"
    tc_assert_rc 1 "contributor: a name that only starts with the plugin name does not count"
    tc_mark_plugin_repo "$dir"
    rm -f "${dir}/wiki/CLAUDE.md"
    run_tf vse_tf_is_contributor "$dir"
    tc_assert_rc 1 "contributor: the manifest alone, with no wiki schema file"
}

# A user project with its own wiki schema at wiki/CLAUDE.md is located
# like any other project.
case_locate_project_user_wiki_schema() {
    local top
    tc_setup_repo
    tc_env
    top="$(cd "$REPO" && pwd -P)"
    printf '# Our wiki\n' | tc_write wiki/CLAUDE.md
    tc_config light -
    run_locate "${REPO}/model/core/stories/new.sysml"
    tf_assert_located "${top}/.iso-config.yaml" "$top" "$top" \
        "locate, user wiki: a project with wiki/CLAUDE.md and no plugin manifest is a project"
}

# In the plugin repository (the wiki schema file and the plugin
# manifest at the top level) only a configuration under demo/ marks a
# project, so the shipped template is never taken for one.
case_locate_project_contributor_mode() {
    local top
    tc_setup_repo
    tc_env
    top="$(cd "$REPO" && pwd -P)"
    tc_mark_plugin_repo
    printf 'project_profile: light\n' | tc_write templates/iso-config/.iso-config.yaml
    printf 'project_profile: light\n' | tc_write demo/smart-sensor/.iso-config.yaml
    run_locate "${REPO}/templates/iso-config/stories/x.sysml"
    tf_assert_not_located "locate, contributor: the shipped template configuration is ignored"
    run_locate "${REPO}/hooks/pre-commit.sh"
    tf_assert_not_located "locate, contributor: a hook is in no project"
    run_locate "${REPO}/demo/smart-sensor/model/core/stories/new.sysml"
    tf_assert_located "${top}/demo/smart-sensor/.iso-config.yaml" "${top}/demo/smart-sensor" "$top" \
        "locate, contributor: the demo is a project"
    printf 'project_profile: light\n' | tc_write .iso-config.yaml
    run_locate "${REPO}/hooks/pre-commit.sh"
    tf_assert_not_located "locate, contributor: a top-level configuration in the plugin repository is ignored"
}

# A hook that knows only its working directory (SessionStart,
# UserPromptSubmit, PreCompact, Notification) locates the project from
# that directory up, as vse_tf_locate_project does, and then from
# engineering/ below it, so a brownfield project below its git top
# level is found from its own root.
case_locate_workdir() {
    local top proj
    tc_setup_repo
    tc_env
    top="$(cd "$REPO" && pwd -P)"
    tc_config light -
    mkdir -p "${REPO}/src/deep"
    run_locate_workdir "${REPO}/src/deep"
    tf_assert_located "${top}/.iso-config.yaml" "$top" "$top" \
        "locate workdir: a directory below the project finds the configuration above it"
    run_locate_workdir "$REPO"
    tf_assert_located "${top}/.iso-config.yaml" "$top" "$top" \
        "locate workdir: the project directory finds its own configuration"

    rm -f "${REPO}/.iso-config.yaml"
    proj="${REPO}/projects/sensor"
    mkdir -p "${proj}/engineering"
    printf 'project_profile: full\n' > "${proj}/engineering/.iso-config.yaml"
    run_locate_workdir "$proj"
    tf_assert_located "${top}/projects/sensor/engineering/.iso-config.yaml" \
        "${top}/projects/sensor/engineering" "$top" \
        "locate workdir: a brownfield project below the top level is found from its own root"

    tc_env VSE_TF_CONFIG=stale VSE_TF_ENG_ROOT=stale VSE_TF_TOP=stale
    run_locate_workdir "${REPO}/projects"
    tf_assert_not_located "locate workdir: a directory above the project, earlier values cleared"
    mkdir -p "${REPO}/plain/engineering"
    run_locate_workdir "${REPO}/plain"
    tf_assert_not_located "locate workdir: an engineering/ folder without a configuration"
    tc_env
}

case_canonical_missing_tail() {
    local real link
    tc_setup_repo
    tc_env
    real="$(cd "$(tc_mktemp_d)" && pwd -P)"
    link="$(tc_mktemp_d)/link"
    ln -s "$real" "$link"
    run_tf vse_tf_canonical "${link}/new/dir/file.txt"
    tc_assert_eq "${real}/new/dir/file.txt" "$OUT" "canonical: a symlinked ancestor resolves and the missing tail is kept"
    : > "${real}/present.txt"
    run_tf vse_tf_canonical "${link}/present.txt"
    tc_assert_eq "${real}/present.txt" "$OUT" "canonical: an existing file"
    run_tf vse_tf_canonical "${link}"
    tc_assert_eq "${real}" "$OUT" "canonical: an existing directory"
    run_tf_at "$link" vse_tf_canonical "sub/file.txt"
    tc_assert_eq "${real}/sub/file.txt" "$OUT" "canonical: a relative path resolves against the working directory"
    run_tf vse_tf_canonical /
    tc_assert_eq "/" "$OUT" "canonical: the root directory"
    ln -s "${real}/present.txt" "${real}/file-link"
    run_tf vse_tf_canonical "${link}/file-link"
    tc_assert_eq "${real}/file-link" "$OUT" "canonical: a final link to a file is kept, its directory resolved"
}

case_story_blocks_demo_register
case_story_blocks_ignores_library
case_story_blocks_string_with_comment_opener
case_story_blocks_note_syntax
case_story_blocks_requirement_def_not_matched
case_story_blocks_fixture_corpus
case_story_blocks_edge_forms
case_touched_only_changed_block
case_post_image_rename_by_name_only
case_post_image_replace_all
case_post_image_edit_inside_doc
case_post_image_delete_comment_closer
case_post_image_empty_old_string
case_post_image_multiedit
case_post_image_write
case_post_image_no_json_tool
case_post_image_old_jq_falls_back
case_disk_image_symmetric_latin1
case_disk_image_plain
case_disk_image_payload_file
case_post_image_crlf
case_post_image_no_match
case_post_image_unsupported_tool
case_feature_tag_bom_crlf
case_feature_tag_prefix_id_rejected
case_feature_tag_in_comment_rejected
case_classify_never_list
case_classify_globs_cross_slash
case_classify_absolute_path_rejected
case_evidence_working_tree
case_evidence_rename_extra_field
case_evidence_untracked_test
case_evidence_deleted_test_ignored
case_evidence_branch_since_main
case_evidence_branch_mode
case_evidence_protected_flow_list
case_evidence_shallow
case_evidence_detached
case_evidence_unborn
case_refactor_branch
case_refactor_branch_toplevel
case_refactor_branch_named
case_detect_pytest
case_detect_none
case_detect_npm_test_in_scripts
case_detect_each_key
case_applies_values
case_missing_paths
case_requires_profile_library
case_find_config_nested_demo
case_locate_project_layouts
case_locate_project_none
case_is_contributor
case_locate_project_user_wiki_schema
case_locate_project_contributor_mode
case_locate_workdir
case_canonical_missing_tail

if tc_summary "test-test-first-lib"; then
    exit 0
fi
exit 1
