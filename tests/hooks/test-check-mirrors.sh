#!/usr/bin/env bash
# Behavioural tests for the check-mirrors Makefile target, which keeps
# the demo's copies of the methodology, the SysML library, the
# renderers and the story lint byte-identical to the plugin's own.
#
# Each case builds a scratch git repository that holds the working-tree
# Makefile, the repository's .gitignore and small stand-ins at the four
# mirrored paths, diverges or decorates one side, and runs the target.
# A file the .gitignore ignores (an OS or editor artefact, a bytecode
# cache) never ships, so it is skipped. Every other file, tracked or
# not, is compared, so an untracked file on one side still fails.
#
# make runs with a scratch HOME, without XDG_CONFIG_HOME or
# GIT_CONFIG_GLOBAL and with GIT_CONFIG_NOSYSTEM set, so no global or
# system git configuration, and no global git ignore file, can hide a
# difference from the target.
#
# Run: bash tests/hooks/test-check-mirrors.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

LIB_COPY="demo/smart-sensor/model/library/vse-library.sysml"

# The error line the target prints for a pair that differs.
pair_error() {
    printf 'ERROR: %s and %s are not byte-identical\n' "$1" "$2"
}

# seed_side <dir>: the same stand-in content on either side of a
# directory pair, so a fresh scratch copy starts identical.
seed_side() {
    local dir="$1"
    mkdir -p "${REPO}/${dir}/sub"
    printf '# Methodology\n' > "${REPO}/${dir}/README.md"
    printf 'page\n' > "${REPO}/${dir}/sub/page.md"
    printf 'print("tool")\n' > "${REPO}/${dir}/tool.py"
}

# A scratch repository with identical mirrors, committed.
fresh() {
    local dir
    REPO="$(tc_mktemp_d)"
    FAKEHOME="$(tc_mktemp_d)"
    git -C "$REPO" init -q -b main
    git -C "$REPO" config user.email "hook-test@example.invalid"
    git -C "$REPO" config user.name "VSE hook test"
    git -C "$REPO" config commit.gpgsign false
    cp "${TC_PLUGIN_ROOT}/Makefile" "${TC_PLUGIN_ROOT}/.gitignore" "${REPO}/"
    for dir in methodology demo/smart-sensor/methodology \
            templates/tools/render demo/smart-sensor/tools/render \
            templates/tools/lint demo/smart-sensor/tools/lint; do
        seed_side "$dir"
    done
    mkdir -p "${REPO}/templates/common/library" "$(dirname "${REPO}/${LIB_COPY}")"
    printf 'package VSE_Library;\n' > "${REPO}/templates/common/library/vse-library.sysml"
    printf 'package VSE_Library;\n' > "${REPO}/${LIB_COPY}"
    git -C "$REPO" add -A
    git -C "$REPO" commit -q --no-verify -m "identical mirrors"
}

run_target() {
    _tc_capture env -C "$REPO" -u MAKEFLAGS -u MAKELEVEL -u MFLAGS \
        -u XDG_CONFIG_HOME -u GIT_CONFIG_GLOBAL \
        HOME="$FAKEHOME" GIT_CONFIG_NOSYSTEM=1 GIT_CEILING_DIRECTORIES="$(dirname "$REPO")" \
        make --no-print-directory check-mirrors
}

# expect_fail <label> <pair-src> <pair-copy>
expect_fail() {
    local label="$1"
    tc_assert_rc 2 "${label}: the target fails"
    tc_assert_line "$(pair_error "$2" "$3")" "$OUT" "${label}: the pair is named"
}

expect_pass() {
    local label="$1"
    tc_assert_rc 0 "${label}: the target passes"
    tc_assert_not_grep "ERROR:" "$OUT" "${label}: no pair is named"
    tc_assert_line "  Checked 4 mirror pairs." "$OUT" "${label}: every pair is checked"
}

# ------------------------------------------------- differences fail

case_identical() {
    fresh
    run_target
    expect_pass "identical mirrors"
}

case_changed_methodology() {
    fresh
    printf 'x' >> "${REPO}/demo/smart-sensor/methodology/README.md"
    run_target
    expect_fail "a changed methodology byte" methodology demo/smart-sensor/methodology
    tc_assert_line "Files methodology/README.md and demo/smart-sensor/methodology/README.md differ" \
        "$OUT" "a changed methodology byte: the file is named"
}

case_changed_library() {
    fresh
    printf 'x' >> "${REPO}/${LIB_COPY}"
    run_target
    expect_fail "a changed library byte" templates/common/library/vse-library.sysml "$LIB_COPY"
}

case_changed_render() {
    fresh
    printf 'x' >> "${REPO}/templates/tools/render/tool.py"
    run_target
    expect_fail "a changed render byte" templates/tools/render demo/smart-sensor/tools/render
}

case_changed_lint() {
    fresh
    printf 'x' >> "${REPO}/templates/tools/lint/tool.py"
    run_target
    expect_fail "a changed lint byte" templates/tools/lint demo/smart-sensor/tools/lint
}

case_missing_copy() {
    fresh
    rm "${REPO}/demo/smart-sensor/tools/lint/tool.py"
    run_target
    expect_fail "a missing demo copy" templates/tools/lint demo/smart-sensor/tools/lint
    tc_assert_line "Only in templates/tools/lint: tool.py" "$OUT" \
        "a missing demo copy: the file is named"
}

case_missing_library() {
    fresh
    rm "${REPO}/${LIB_COPY}"
    run_target
    expect_fail "a missing library copy" templates/common/library/vse-library.sysml "$LIB_COPY"
}

case_missing_directory() {
    fresh
    rm -rf "${REPO}/demo/smart-sensor/tools/render"
    run_target
    expect_fail "a missing demo directory" templates/tools/render demo/smart-sensor/tools/render
}

case_extra_untracked() {
    fresh
    : > "${REPO}/demo/smart-sensor/tools/render/extra.py"
    run_target
    expect_fail "an extra untracked demo file" templates/tools/render demo/smart-sensor/tools/render
    tc_assert_line "Only in demo/smart-sensor/tools/render: extra.py" "$OUT" \
        "an extra untracked demo file: the file is named"
}

case_changed_subdirectory() {
    fresh
    printf 'x' >> "${REPO}/demo/smart-sensor/methodology/sub/page.md"
    run_target
    expect_fail "a changed file in a subdirectory" methodology demo/smart-sensor/methodology
}

case_two_pairs() {
    fresh
    printf 'x' >> "${REPO}/templates/tools/lint/tool.py"
    printf 'x' >> "${REPO}/methodology/README.md"
    run_target
    expect_fail "two diverged pairs, the first" templates/tools/lint demo/smart-sensor/tools/lint
    tc_assert_line "$(pair_error methodology demo/smart-sensor/methodology)" "$OUT" \
        "two diverged pairs, the second: the pair is named"
}

# A tracked file is compared even when its name matches an ignore
# pattern, because a tracked file ships.
case_tracked_ignored_name() {
    fresh
    printf 'notes\n' > "${REPO}/methodology/notes~"
    git -C "$REPO" add -f methodology/notes~
    git -C "$REPO" commit -q --no-verify -m "force-add a backup name"
    run_target
    expect_fail "a tracked file with an ignored name" methodology demo/smart-sensor/methodology
}

# Outside a git checkout git lists nothing, which would compare no
# files and pass. The target refuses instead.
case_no_git() {
    fresh
    rm -rf "${REPO}/.git"
    printf 'x' >> "${REPO}/methodology/README.md"
    run_target
    tc_assert_rc 2 "outside a git checkout: the target fails"
    tc_assert_line "ERROR: check-mirrors lists files through git, so run it inside a git checkout" \
        "$OUT" "outside a git checkout: the reason is stated"
}

# ------------------------------------------- ignored files are skipped

case_ignored_pycache() {
    fresh
    mkdir -p "${REPO}/templates/tools/lint/__pycache__"
    : > "${REPO}/templates/tools/lint/__pycache__/tool.cpython-312.pyc"
    run_target
    expect_pass "a bytecode cache on one side"
}

case_ignored_pyc() {
    fresh
    : > "${REPO}/templates/tools/render/tool.pyc"
    run_target
    expect_pass "a stray .pyc on one side"
}

case_ignored_ds_store() {
    fresh
    printf 'finder' > "${REPO}/methodology/.DS_Store"
    printf 'finder' > "${REPO}/demo/smart-sensor/methodology/sub/.DS_Store"
    run_target
    expect_pass "a .DS_Store on one side"
}

case_ignored_thumbs() {
    fresh
    printf 'thumbs' > "${REPO}/demo/smart-sensor/tools/lint/Thumbs.db"
    run_target
    expect_pass "a Thumbs.db on one side"
}

case_ignored_swap() {
    fresh
    printf 'swap' > "${REPO}/methodology/.README.md.swp"
    printf 'swap' > "${REPO}/templates/tools/lint/.tool.py.swo"
    run_target
    expect_pass "editor swap files on one side"
}

case_ignored_backup() {
    fresh
    printf 'old' > "${REPO}/demo/smart-sensor/methodology/README.md~"
    run_target
    expect_pass "an editor backup file on one side"
}

# A tracked file removed from both working copies, such as a page
# deleted on both sides before the commit, is not a difference.
case_deleted_both_sides() {
    fresh
    rm "${REPO}/methodology/sub/page.md" "${REPO}/demo/smart-sensor/methodology/sub/page.md"
    run_target
    expect_pass "a tracked file deleted on both sides"
}

case_identical
case_changed_methodology
case_changed_library
case_changed_render
case_changed_lint
case_missing_copy
case_missing_library
case_missing_directory
case_extra_untracked
case_changed_subdirectory
case_two_pairs
case_tracked_ignored_name
case_no_git
case_ignored_pycache
case_ignored_pyc
case_ignored_ds_store
case_ignored_thumbs
case_ignored_swap
case_ignored_backup
case_deleted_both_sides

if tc_summary "test-check-mirrors"; then
    exit 0
fi
exit 1
