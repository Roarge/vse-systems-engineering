#!/usr/bin/env bash
# Behavioural tests for tests/hooks/check-test-first.sh, the plugin's
# own test-before-code check.
#
# Each case builds a scratch git repository that holds a copy of the
# plugin's tests/test-first.yaml on main, points origin/main at it, and
# commits changes on a feature branch. The check runs on that
# repository with the libraries of this checkout, so the cases exercise
# the real configuration and the real classifier together.
#
# Run: bash tests/hooks/test-check-test-first.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" > /dev/null && pwd)/lib.sh"

trap tc_teardown EXIT

CHECK="${TC_PLUGIN_ROOT}/tests/hooks/check-test-first.sh"
FAILURE="ERROR: code changed with no change to a test path."

# A scratch repository with the configuration and a README on main,
# origin/main at the same commit, and the branch feat/change checked
# out.
setup_branch() {
    REPO="$(tc_mktemp_d)"
    git -C "$REPO" init -q -b main
    git -C "$REPO" config user.email "hook-test@example.invalid"
    git -C "$REPO" config user.name "VSE hook test"
    git -C "$REPO" config commit.gpgsign false
    mkdir -p "${REPO}/tests"
    cp "${TC_PLUGIN_ROOT}/tests/test-first.yaml" "${REPO}/tests/test-first.yaml"
    printf '# Scratch plugin\n' > "${REPO}/README.md"
    git -C "$REPO" add -A
    tc_commit "start the plugin"
    git -C "$REPO" update-ref refs/remotes/origin/main HEAD
    git -C "$REPO" checkout -q -b feat/change
}

# commit_paths <message> <path>...: append a line to each path and
# commit them together.
commit_paths() {
    local message="$1" path
    shift
    for path in "$@"; do
        mkdir -p "$(dirname "${REPO}/${path}")"
        printf 'change\n' >> "${REPO}/${path}"
    done
    git -C "$REPO" add -A
    tc_commit "$message"
}

# run_check [range]: run the check from RUN_DIR (the repository root
# by default). A range, configuration path or pull request branch from
# the caller's own environment never reaches it, so only tc_env sets
# one.
run_check() {
    _tc_capture _tc_in_dir "${RUN_DIR:-$REPO}" env -u VSE_PRECOMMIT_RANGE -u VSE_ISO_CONFIG \
        -u GITHUB_HEAD_REF \
        ${TC_ENV[@]+"${TC_ENV[@]}"} \
        bash "$CHECK" "$@"
}

# ------------------------------------------------------ the core rule

case_code_only() {
    setup_branch
    commit_paths "add a hook" hooks/x.sh
    tc_env
    run_check
    tc_assert_rc 1 "code only: the check fails"
    tc_assert_line "  code: hooks/x.sh" "$OUT" "code only: the code path is printed"
    tc_assert_grep "$FAILURE" "$OUT" "code only: the finding is stated"
}

case_code_and_test() {
    setup_branch
    commit_paths "add a hook" hooks/x.sh
    commit_paths "test the hook" tests/hooks/test-x.sh
    tc_env
    run_check
    tc_assert_rc 0 "code and test: the check passes"
    tc_assert_line "  code: hooks/x.sh" "$OUT" "code and test: the code path is printed"
    tc_assert_line "  test: tests/hooks/test-x.sh" "$OUT" "code and test: the test path is printed"
    tc_assert_not_grep "ERROR:" "$OUT" "code and test: no finding"
}

case_test_only() {
    setup_branch
    commit_paths "add a hook test" tests/hooks/test-x.sh
    tc_env
    run_check
    tc_assert_rc 0 "test only: the check passes"
    tc_assert_line "  test: tests/hooks/test-x.sh" "$OUT" "test only: the test path is printed"
}

case_other_only() {
    setup_branch
    commit_paths "edit prose" README.md skills/demo/SKILL.md .github/workflows/plugin-ci.yml
    tc_env
    run_check
    tc_assert_rc 0 "prose and CI only: the check passes"
    tc_assert_not_grep "code:" "$OUT" "prose and CI only: nothing is code"
}

# --------------------------------------------- the configuration's globs

# Every code_paths glob, each alone on the branch.
case_each_code_glob() {
    local path
    for path in hooks/lib/x.sh templates/tools/lint/x.py templates/tools/render/x.py \
            tests/bdd/run.py Makefile; do
        setup_branch
        commit_paths "change ${path}" "$path"
        tc_env
        run_check
        tc_assert_rc 1 "${path} alone: the check fails"
        tc_assert_line "  code: ${path}" "$OUT" "${path} alone: it is code"
    done
}

# Every test_paths glob, each beside a hook change.
case_each_test_glob() {
    local path
    for path in tests/hooks/lib.sh tests/python/test_x.py tests/fixtures/lint/x.txt \
            tests/bdd/steps/x.py tests/features/README.md; do
        setup_branch
        commit_paths "change a hook and ${path}" hooks/x.sh "$path"
        tc_env
        run_check
        tc_assert_rc 0 "${path} beside a hook: the check passes"
        tc_assert_line "  test: ${path}" "$OUT" "${path} beside a hook: it is a test"
    done
}

# tests/bdd/*.py matches the step modules too, and the test glob wins.
case_steps_are_tests() {
    setup_branch
    commit_paths "add a step" tests/bdd/steps/x.py
    tc_env
    run_check
    tc_assert_rc 0 "a step module alone: the check passes"
    tc_assert_not_grep "code: tests/bdd/steps/x.py" "$OUT" "a step module alone: it is not code"
}

# A scenario comes before the test, not instead of it.
case_feature_is_not_a_test() {
    setup_branch
    commit_paths "add a hook and its scenario" hooks/x.sh tests/features/x.feature
    tc_env
    run_check
    tc_assert_rc 1 "a hook and a scenario: the check fails"
    tc_assert_not_grep "test: tests/features/x.feature" "$OUT" "a hook and a scenario: the scenario is not a test"
}

# A deleted file is neither code nor test, as in the project-side gate.
case_deleted_code() {
    setup_branch
    git -C "$REPO" checkout -q main
    commit_paths "add a hook" hooks/old.sh
    git -C "$REPO" update-ref refs/remotes/origin/main HEAD
    git -C "$REPO" checkout -q -B feat/change
    git -C "$REPO" rm -q hooks/old.sh
    tc_commit "remove a hook"
    tc_env
    run_check
    tc_assert_rc 0 "a deleted hook: the check passes"
    tc_assert_not_grep "code:" "$OUT" "a deleted hook: a deletion is not code"
}

# git quotes a name with a non-ASCII byte unless it writes NUL-delimited
# names, and a quoted name would match no glob.
case_unusual_name() {
    setup_branch
    commit_paths "add a hook" "hooks/my café hook.sh"
    tc_env
    run_check
    tc_assert_rc 1 "an unusual name: the check fails"
    tc_assert_line "  code: hooks/my café hook.sh" "$OUT" "an unusual name: the path is intact"
}

# ------------------------------------------------------------ the range

# Two commits on the branch: a hook with its test, then a hook alone.
setup_two_commits() {
    setup_branch
    commit_paths "add a hook and its test" hooks/x.sh tests/hooks/test-x.sh
    commit_paths "add a second hook" hooks/y.sh
}

case_default_range() {
    setup_two_commits
    tc_env
    run_check
    tc_assert_rc 0 "default range: the whole branch is read"
    tc_assert_grep "origin/main...HEAD" "$OUT" "default range: the range is printed"
}

case_argument_range() {
    setup_two_commits
    tc_env
    run_check "HEAD~1...HEAD"
    tc_assert_rc 1 "range argument: only the last commit is read"
    tc_assert_line "  code: hooks/y.sh" "$OUT" "range argument: the last commit's hook is printed"
    tc_assert_not_grep "hooks/x.sh" "$OUT" "range argument: the earlier commit is not read"
}

case_environment_range() {
    setup_two_commits
    tc_env "VSE_PRECOMMIT_RANGE=HEAD~1...HEAD"
    run_check
    tc_assert_rc 1 "VSE_PRECOMMIT_RANGE: only the last commit is read"
}

case_argument_wins() {
    setup_two_commits
    tc_env "VSE_PRECOMMIT_RANGE=HEAD~1...HEAD"
    run_check "origin/main...HEAD"
    tc_assert_rc 0 "argument and environment: the argument wins"
}

# Code that changed on main after the branch left it is not the
# branch's change, because the default range starts at the merge base.
# Compared tree to tree instead, main's edit would read as code.
case_main_moved_on() {
    setup_branch
    git -C "$REPO" checkout -q main
    commit_paths "add a hook" hooks/main.sh
    git -C "$REPO" checkout -q -B feat/change
    commit_paths "edit prose" README.md
    git -C "$REPO" checkout -q main
    commit_paths "change the hook on main" hooks/main.sh
    git -C "$REPO" update-ref refs/remotes/origin/main HEAD
    git -C "$REPO" checkout -q feat/change
    tc_env
    run_check
    tc_assert_rc 0 "main moved on: the check passes"
    tc_assert_not_grep "hooks/main.sh" "$OUT" "main moved on: main's hook is not read"
}

case_subdirectory() {
    setup_branch
    commit_paths "add a hook" hooks/x.sh
    tc_env
    RUN_DIR="${REPO}/hooks"
    run_check
    RUN_DIR=""
    tc_assert_rc 1 "run from a subdirectory: the check still fails"
    tc_assert_line "  code: hooks/x.sh" "$OUT" "run from a subdirectory: the path is relative to the top level"
}

# ---------------------------------------------------- refactor branches

NOTICE="[check-test-first] Notice: refactor branch: run the tests before and after, no behaviour change."

# A branch that matches test_first.refactor_branches (refactor/* in the
# plugin's record) changes code without changing its tests, so code
# alone draws a notice instead of the finding. Locally the branch is
# the one checked out.
case_refactor_branch_checked_out() {
    setup_branch
    git -C "$REPO" checkout -q -b refactor/tidy
    commit_paths "tidy a hook" hooks/x.sh
    tc_env
    run_check
    tc_assert_rc 0 "refactor branch checked out: the check passes"
    tc_assert_line "  code: hooks/x.sh" "$OUT" "refactor branch checked out: the code path is printed"
    tc_assert_line "$NOTICE" "$OUT" "refactor branch checked out: the notice is printed"
    tc_assert_not_grep "ERROR:" "$OUT" "refactor branch checked out: no finding"

    setup_branch
    git -C "$REPO" checkout -q -b feat/refactor-tidy
    commit_paths "tidy a hook" hooks/x.sh
    tc_env
    run_check
    tc_assert_rc 1 "other branch checked out: the check fails"
    tc_assert_grep "$FAILURE" "$OUT" "other branch checked out: the finding is stated"
    tc_assert_not_grep "Notice:" "$OUT" "other branch checked out: no notice"
}

# CI checks a pull request out as a detached merge commit and names the
# pull request's branch in GITHUB_HEAD_REF, which wins over the branch
# checked out.
case_refactor_branch_github_head_ref() {
    setup_branch
    commit_paths "tidy a hook" hooks/x.sh
    git -C "$REPO" checkout -q --detach
    tc_env "GITHUB_HEAD_REF=refactor/tidy"
    run_check
    tc_assert_rc 0 "GITHUB_HEAD_REF refactor branch: the check passes"
    tc_assert_line "$NOTICE" "$OUT" "GITHUB_HEAD_REF refactor branch: the notice is printed"

    tc_env "GITHUB_HEAD_REF=feat/refactor-tidy"
    run_check
    tc_assert_rc 1 "GITHUB_HEAD_REF other branch: the check fails"
    tc_assert_grep "$FAILURE" "$OUT" "GITHUB_HEAD_REF other branch: the finding is stated"

    git -C "$REPO" checkout -q -b refactor/tidy
    tc_env "GITHUB_HEAD_REF=feat/change"
    run_check
    tc_assert_rc 1 "GITHUB_HEAD_REF and a refactor branch checked out: GITHUB_HEAD_REF wins"
    tc_assert_not_grep "Notice:" "$OUT" "GITHUB_HEAD_REF and a refactor branch checked out: no notice"
}

# The record decides which branches are refactor branches: a glob the
# plugin's file names replaces refactor/*, and an empty list names no
# branch at all. The scratch record is rewritten in the working tree
# only, so the range still holds the code change alone.
case_refactor_branches_recorded() {
    setup_branch
    git -C "$REPO" checkout -q -b tidy/x
    commit_paths "tidy a hook" hooks/x.sh
    sed -i.bak 's#^  refactor_branches:.*#  refactor_branches: [tidy/*]#' "${REPO}/tests/test-first.yaml"
    rm -f "${REPO}/tests/test-first.yaml.bak"
    tc_assert_grep "refactor_branches: [tidy/*]" "$(cat "${REPO}/tests/test-first.yaml")" \
        "recorded tidy/*: the scratch record names tidy/*"
    tc_env
    run_check
    tc_assert_rc 0 "recorded tidy/*: code alone on tidy/x passes"
    tc_assert_line "$NOTICE" "$OUT" "recorded tidy/*: tidy/x draws the notice"

    setup_branch
    git -C "$REPO" checkout -q -b refactor/tidy
    commit_paths "tidy a hook" hooks/x.sh
    sed -i.bak 's#^  refactor_branches:.*#  refactor_branches: []#' "${REPO}/tests/test-first.yaml"
    rm -f "${REPO}/tests/test-first.yaml.bak"
    tc_assert_grep "refactor_branches: []" "$(cat "${REPO}/tests/test-first.yaml")" \
        "recorded []: the scratch record names no branch"
    tc_env
    run_check
    tc_assert_rc 1 "recorded []: code alone on refactor/tidy fails"
    tc_assert_grep "$FAILURE" "$OUT" "recorded []: the finding is stated"
    tc_assert_not_grep "Notice:" "$OUT" "recorded []: no notice"
}

# ---------------------------------------------------------------- errors

case_bad_range() {
    setup_branch
    tc_env
    run_check "no-such-ref...HEAD"
    tc_assert_rc 2 "unreadable range: exit 2"
    tc_assert_grep "no-such-ref...HEAD" "$ERR" "unreadable range: the range is named"
}

case_no_origin_main() {
    setup_branch
    git -C "$REPO" update-ref -d refs/remotes/origin/main
    commit_paths "add a hook" hooks/x.sh
    tc_env
    run_check
    tc_assert_rc 2 "no origin/main: exit 2"
    tc_assert_grep "VSE_PRECOMMIT_RANGE" "$ERR" "no origin/main: the way to name a range is given"
}

# Without the configuration every path would be other and the check
# would pass having watched nothing.
case_missing_config() {
    setup_branch
    git -C "$REPO" rm -q tests/test-first.yaml
    commit_paths "add a hook" hooks/x.sh
    tc_env
    run_check
    tc_assert_rc 2 "missing configuration: exit 2"
    tc_assert_grep "tests/test-first.yaml is missing" "$ERR" "missing configuration: the file is named"
}

case_no_code_paths() {
    setup_branch
    sed -i.bak '/code_paths:/d' "${REPO}/tests/test-first.yaml"
    rm -f "${REPO}/tests/test-first.yaml.bak"
    commit_paths "add a hook" hooks/x.sh
    tc_env
    run_check
    tc_assert_rc 2 "no code_paths: exit 2"
    tc_assert_grep "code_paths" "$ERR" "no code_paths: the key is named"
}

case_code_only
case_code_and_test
case_test_only
case_other_only
case_each_code_glob
case_each_test_glob
case_steps_are_tests
case_feature_is_not_a_test
case_deleted_code
case_unusual_name
case_default_range
case_argument_range
case_environment_range
case_argument_wins
case_main_moved_on
case_subdirectory
case_refactor_branch_checked_out
case_refactor_branch_github_head_ref
case_refactor_branches_recorded
case_bad_range
case_no_origin_main
case_missing_config
case_no_code_paths

if tc_summary "test-check-test-first"; then
    exit 0
fi
exit 1
