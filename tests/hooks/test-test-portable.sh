#!/usr/bin/env bash
# Behavioural tests for the test-portable Makefile target, which the
# macOS job of the CI workflow runs with 'make -k test-portable'.
#
# Under make -k (keep going), a failing prerequisite stops the recipe
# of the target that lists it, although make still builds the other
# prerequisites. So every hook test file has to run under a
# prerequisite of its own, or one failing check would hide every
# platform difference the hook tests could show.
#
# Each case builds a scratch tree that holds a copy of the working-tree
# Makefile and two stand-in hook test files, tests/hooks/test-a.sh and
# tests/hooks/test-b.sh, each of which prints a line and exits with the
# status the case gives it. The real prerequisites of test-portable,
# read from make's own database, are marked as already made with -o,
# so none of the real checks runs in the scratch tree. A case that
# needs a failing check puts a stand-in one in front of them in the
# copied Makefile.
#
# make runs without MAKEFLAGS, MAKELEVEL and MFLAGS, so the -k or -j of
# an outer make does not reach the scratch run.
#
# Run: bash tests/hooks/test-test-portable.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

SCRATCH=""

# The stand-in check that fails, and the line it prints.
STAND_IN_CHECK="stand-in-failing-check"
STAND_IN_LINE="stand-in check failed"

# A scratch tree with the working-tree Makefile and no hook test file.
fresh() {
    SCRATCH="$(tc_mktemp_d)"
    mkdir -p "${SCRATCH}/tests/hooks"
    cp "${TC_PLUGIN_ROOT}/Makefile" "${SCRATCH}/Makefile"
}

# stand_in_test <name> <exit status>: tests/hooks/test-<name>.sh, which
# prints "stand-in test-<name> ran" and exits with the status.
stand_in_test() {
    printf 'echo "stand-in test-%s ran"\nexit %s\n' "$1" "$2" \
        > "${SCRATCH}/tests/hooks/test-${1}.sh"
}

# The copied Makefile with a failing stand-in check listed first among
# the prerequisites of test-portable. sed writes a new file, so no
# in-place edit is needed.
add_failing_check() {
    sed "s/^test-portable:/test-portable: ${STAND_IN_CHECK}/" \
        "${TC_PLUGIN_ROOT}/Makefile" > "${SCRATCH}/Makefile"
    printf '\n%s:\n\t@echo "%s"; exit 1\n' "$STAND_IN_CHECK" "$STAND_IN_LINE" \
        >> "${SCRATCH}/Makefile"
}

scratch_make() {
    env -u MAKEFLAGS -u MAKELEVEL -u MFLAGS \
        make --no-print-directory -C "$SCRATCH" "$@"
}

# The prerequisites of test-portable as make reads them. Question mode
# (-q) runs no recipe, and -p prints the database that holds the list.
portable_prerequisites() {
    scratch_make -qp test-portable 2>/dev/null \
        | sed -n 's/^test-portable:[[:space:]]*//p' || true
}

# make -k test-portable, with every real check marked as already made.
# The stand-in check and test-hooks-each, the target that runs the hook
# test files, are left to run.
run_target() {
    local prerequisite
    local made
    made=()
    for prerequisite in $(portable_prerequisites); do
        case "$prerequisite" in
            "$STAND_IN_CHECK"|test-hooks-each) ;;
            *) made+=(-o "$prerequisite") ;;
        esac
    done
    _tc_capture scratch_make -k ${made[@]+"${made[@]}"} test-portable
}

# ------------------------------------------------------------- cases

# The macOS case: a check fails, and the first hook test file fails.
# Both hook test files still run, the failing one is named, and the
# target fails.
case_failing_check() {
    fresh
    add_failing_check
    stand_in_test a 1
    stand_in_test b 0
    run_target
    tc_assert_rc 2 "a failing check: the target fails"
    tc_assert_line "$STAND_IN_LINE" "$OUT" "a failing check: the stand-in check ran"
    tc_assert_line "stand-in test-a ran" "$OUT" "a failing check: the failing hook test file ran"
    tc_assert_line "stand-in test-b ran" "$OUT" "a failing check: the hook test file after it ran"
    tc_assert_line "FAILED: tests/hooks/test-a.sh" "$OUT" \
        "a failing check: the failing hook test file is named"
    tc_assert_not_grep "FAILED: tests/hooks/test-b.sh" "$OUT" \
        "a failing check: the passing hook test file is not named"
}

# Every check passes and only a hook test file fails. The target must
# still fail, and its summary line must not print, or the macOS job
# would turn green while a hook test fails there.
case_failing_hook_test() {
    fresh
    stand_in_test a 1
    stand_in_test b 0
    run_target
    tc_assert_rc 2 "a failing hook test file: the target fails"
    tc_assert_line "stand-in test-a ran" "$OUT" \
        "a failing hook test file: the failing hook test file ran"
    tc_assert_line "stand-in test-b ran" "$OUT" \
        "a failing hook test file: the hook test file after it ran"
    tc_assert_line "FAILED: tests/hooks/test-a.sh" "$OUT" \
        "a failing hook test file: the failing hook test file is named"
    tc_assert_not_grep "The platform-dependent checks passed." "$OUT" \
        "a failing hook test file: the target does not report a pass"
}

# Every check and every hook test file passes, so the target passes.
case_all_pass() {
    fresh
    stand_in_test a 0
    stand_in_test b 0
    run_target
    tc_assert_rc 0 "everything passes: the target passes"
    tc_assert_line "stand-in test-a ran" "$OUT" "everything passes: the first hook test file ran"
    tc_assert_line "stand-in test-b ran" "$OUT" "everything passes: the second hook test file ran"
    tc_assert_not_grep "FAILED:" "$OUT" "everything passes: no hook test file is named"
}

case_failing_check
case_failing_hook_test
case_all_pass

if tc_summary "test-test-portable"; then
    exit 0
fi
exit 1
