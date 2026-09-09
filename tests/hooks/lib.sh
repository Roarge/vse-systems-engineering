#!/usr/bin/env bash
# Shared helpers for the behavioural hook tests under tests/hooks/.
#
# Sourced by check-toolchain.sh, test-pre-commit.sh and
# test-session-start.sh. Provides a scratch git repository with the
# project-side hooks installed, a stub directory that shadows the real
# SysML toolchains, assertion helpers, and a pass/fail summary.
#
# Two runners:
#   tc_run_hook, tc_run_lib, tc_run_lib_fn are sandboxed. PATH is the
#     stub directory followed by /usr/bin and /bin, HOME is a scratch
#     directory, and the pilot home points inside it, so nothing the
#     machine has installed can reach the code under test.
#   tc_run_real uses the machine's own PATH and HOME, for the sections
#     that exercise a really installed toolchain. Those sections are
#     guarded and print SKIPPED when the tool is absent, which is what
#     a CI runner with no SysML tool sees.
#
# Set VSE_TC_TEST_PATH to a colon-separated list of extra directories
# to place in front of the real PATH. That is how a local checkout of
# OpenSysML or the pilot is exercised without installing it.
#
# tc_run_lib_fn sources the library into a fresh shell and calls one
# function with errexit off, so that VSE_TC_REASON survives and can be
# asserted. The library sets that variable without printing it, and a
# subprocess would otherwise lose it. Every library function reports
# failure through an explicit return, so errexit is not load-bearing
# inside them.
#
# Requires GNU coreutils (env -C) and git.
set -euo pipefail

TC_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TC_PLUGIN_ROOT="$(cd "${TC_LIB_DIR}/../.." && pwd)"

TC_PASS_COUNT=0
TC_FAIL_COUNT=0
TC_SKIP_COUNT=0

# One scratch root per run. Every scratch directory and capture file is
# a child of it, so a single removal in tc_teardown cannot miss one.
# The root is created here rather than on first use, because a helper
# called inside a command substitution runs in a subshell and its
# assignment would never reach this scope.
TC_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/vse-hooktest.XXXXXX")"

# Extra environment for the next runner call, as NAME=VALUE words.
TC_ENV=()

# Scratch locations, filled in by tc_setup_repo.
REPO=""
FAKEHOME=""
STUBS=""

# Result of the last runner call.
# shellcheck disable=SC2034
OUT=""
# shellcheck disable=SC2034
ERR=""
RC=0

TC_REAL_PATH="${PATH}"
if [ -n "${VSE_TC_TEST_PATH:-}" ]; then
    TC_REAL_PATH="${VSE_TC_TEST_PATH}:${TC_REAL_PATH}"
fi
if [ -d "${HOME}/go/bin" ]; then
    TC_REAL_PATH="${TC_REAL_PATH}:${HOME}/go/bin"
fi

# ---------------------------------------------------------------- temp

tc_mktemp_d() {
    mktemp -d "${TC_ROOT}/d.XXXXXX"
}

# Remove the scratch root and everything under it. The name guard keeps
# an unexpected value from turning the teardown into a wide delete.
tc_teardown() {
    case "$TC_ROOT" in
        */vse-hooktest.*) [ ! -d "$TC_ROOT" ] || rm -rf "$TC_ROOT" ;;
    esac
}

# ------------------------------------------------------------- fixture

# Scratch git repository with the project-side hooks installed the way
# @attention-regime installs them, plus an empty fake HOME and an empty
# stub directory.
tc_setup_repo() {
    REPO="$(tc_mktemp_d)"
    git -C "$REPO" init -q -b main
    git -C "$REPO" config user.email "hook-test@example.invalid"
    git -C "$REPO" config user.name "VSE hook test"
    git -C "$REPO" config commit.gpgsign false
    mkdir -p "${REPO}/.githooks/lib"
    cp "${TC_PLUGIN_ROOT}/hooks/pre-commit.sh" "${REPO}/.githooks/pre-commit"
    cp "${TC_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" "${REPO}/.githooks/pre-commit-traceability.sh"
    cp "${TC_PLUGIN_ROOT}/hooks/lib/iso-profile.sh" "${REPO}/.githooks/lib/iso-profile.sh"
    cp "${TC_PLUGIN_ROOT}/hooks/lib/sysml-toolchain.sh" "${REPO}/.githooks/lib/sysml-toolchain.sh"
    chmod +x "${REPO}/.githooks/pre-commit" \
             "${REPO}/.githooks/pre-commit-traceability.sh" \
             "${REPO}/.githooks/lib/iso-profile.sh" \
             "${REPO}/.githooks/lib/sysml-toolchain.sh"
    git -C "$REPO" config core.hooksPath .githooks
    FAKEHOME="$(tc_mktemp_d)"
    STUBS="$(tc_mktemp_d)"
}

# tc_config <profile> <toolchain|-> [override=<block|warn|info|off>]
tc_config() {
    local profile="$1" toolchain="$2" extra="${3:-}"
    {
        printf 'project_profile: %s\n' "$profile"
        if [ "$toolchain" != "-" ]; then
            printf 'sysml_toolchain: %s\n' "$toolchain"
        fi
        case "$extra" in
            override=*)
                printf 'gate_overrides:\n'
                printf '  precommit_lint: %s\n' "${extra#override=}"
                ;;
        esac
    } > "${REPO}/.iso-config.yaml"
}

# tc_stub <name>: write an executable stub into $STUBS from stdin.
tc_stub() {
    local name="$1"
    cat > "${STUBS}/${name}"
    chmod +x "${STUBS}/${name}"
}

tc_reset_stubs() {
    rm -rf "${STUBS:?}"/*
}

# java prints its version banner on stderr, which is what the library
# parses. Any other invocation is a validator run: the stub swallows
# the block on stdin and replays $PILOT_TRANSCRIPT, exiting $PILOT_RC.
tc_stub_java() {
    local version="${1:-21.0.12}"
    tc_stub java <<EOF
#!/usr/bin/env bash
set -uo pipefail
if [ "\${1:-}" = "-version" ]; then
    echo 'openjdk version "${version}" 2026-07-21' >&2
    exit 0
fi
cat > /dev/null
if [ -n "\${PILOT_TRANSCRIPT:-}" ] && [ -r "\${PILOT_TRANSCRIPT}" ]; then
    cat "\${PILOT_TRANSCRIPT}"
fi
exit "\${PILOT_RC:-0}"
EOF
}

# The expired-licence failure is text on stdout with exit 2, which is
# the shape the library classifies on. SYSIDE_OK=1 makes it succeed.
tc_stub_syside() {
    tc_stub syside <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
if [ "${SYSIDE_OK:-}" = "1" ]; then
    exit 0
fi
echo "License check failed:"
echo "  License expired. Please contact the Syside support team."
exit 2
EOF
}

# OpenSysML puts diagnostics on stderr and its clean marks on stdout.
tc_stub_sysml() {
    local banner="${1:-sysml v0.6.0}"
    tc_stub sysml <<EOF
#!/usr/bin/env bash
set -uo pipefail
if [ "\${1:-}" = "-version" ]; then
    echo '${banner}'
    exit 0
fi
if [ -n "\${SYSML_TRANSCRIPT:-}" ] && [ -r "\${SYSML_TRANSCRIPT}" ]; then
    cat "\${SYSML_TRANSCRIPT}" >&2
fi
if [ -n "\${SYSML_STDOUT:-}" ] && [ -r "\${SYSML_STDOUT}" ]; then
    cat "\${SYSML_STDOUT}"
fi
exit "\${SYSML_RC:-0}"
EOF
}

# A stub that records the fact it ran and nothing else. Used to prove a
# gate did not reach for a validator at all.
tc_stub_recorder() {
    local name="$1"
    tc_stub "$name" <<EOF
#!/usr/bin/env bash
set -uo pipefail
printf '%s %s\n' "${name}" "\$*" >> "\${TC_INVOCATIONS:-/dev/null}"
exit 0
EOF
}

tc_pilot_home() {
    printf '%s\n' "${FAKEHOME}/.local/share/sysml-pilot"
}

# Lay down the two artefacts the library looks for: the highest kernel
# jar and the model library directory.
tc_pilot_install() {
    local home
    home="$(tc_pilot_home)"
    mkdir -p "${home}/sysml/sysml.library"
    : > "${home}/sysml/jupyter-sysml-kernel-0.61.0-all.jar"
}

tc_pilot_uninstall() {
    rm -rf "$(tc_pilot_home)"
}

# Write a file inside the scratch repository, creating its directory.
tc_write() {
    local path="$1"
    mkdir -p "$(dirname "${REPO}/${path}")"
    cat > "${REPO}/${path}"
}

# Write a file outside the repository, for transcripts and fixtures.
tc_write_at() {
    local path="$1"
    mkdir -p "$(dirname "$path")"
    cat > "$path"
}

tc_stage() {
    git -C "$REPO" add -- "$@"
}

tc_commit() {
    git -C "$REPO" commit -q --no-verify -m "$1"
}

# -------------------------------------------------------------- runner

# tc_env NAME=VALUE ...: environment for the next runner call. With no
# arguments the extra environment is cleared, which is the common call.
# shellcheck disable=SC2120
tc_env() {
    TC_ENV=("$@")
}

_tc_capture() {
    local outf errf
    outf="$(mktemp "${TC_ROOT}/out.XXXXXX")"
    errf="$(mktemp "${TC_ROOT}/err.XXXXXX")"
    RC=0
    # env is an external process, so the errexit context of this caller
    # cannot leak into the code under test.
    "$@" > "$outf" 2> "$errf" < /dev/null || RC=$?
    # shellcheck disable=SC2034
    OUT="$(cat "$outf")"
    # shellcheck disable=SC2034
    ERR="$(cat "$errf")"
    rm -f "$outf" "$errf"
}

# Sandboxed run inside $REPO. The stub directory shadows /usr/bin, HOME
# and the pilot home are scratch, and the three variables an installer
# might carry are removed.
_tc_sandboxed() {
    _tc_capture env -C "$REPO" \
        -u CLAUDE_PLUGIN_ROOT -u VSE_SYSML_TOOLCHAIN -u VSE_JAVA -u JAVA_HOME \
        PATH="${STUBS}:/usr/bin:/bin" \
        HOME="${FAKEHOME}" \
        VSE_SYSML_PILOT_HOME="$(tc_pilot_home)" \
        ${TC_ENV[@]+"${TC_ENV[@]}"} \
        "$@"
}

tc_run_hook() {
    _tc_sandboxed ./.githooks/pre-commit
}

# Run the library as the command-line entry point CI and the Makefile
# use.
tc_run_lib() {
    _tc_sandboxed bash .githooks/lib/sysml-toolchain.sh "$@"
}

# The driver body is expanded by the shell it is handed to, not here.
# shellcheck disable=SC2016
TC_DRIVER='
. ./.githooks/lib/sysml-toolchain.sh
set +e
"$@"
_tc_rc=$?
set -e
if [ -n "${VSE_TC_REASON:-}" ]; then
    echo "reason: ${VSE_TC_REASON}" >&2
fi
exit "$_tc_rc"
'

# Run one library function with the library sourced, so the reason a
# validator recorded reaches stderr as "reason: <text>".
tc_run_lib_fn() {
    _tc_sandboxed bash -c "$TC_DRIVER" tc-driver "$@"
}

# Run inside $REPO with the machine's real PATH and HOME, for the
# installed-toolchain sections.
tc_run_real() {
    _tc_capture env -C "$REPO" \
        -u CLAUDE_PLUGIN_ROOT -u VSE_SYSML_TOOLCHAIN \
        PATH="${TC_REAL_PATH}" \
        ${TC_ENV[@]+"${TC_ENV[@]}"} \
        "$@"
}

# Run the library as a command in a plain directory with the real PATH,
# used by the real-tool availability guards.
tc_real_available() {
    local tool="$1"
    tc_env
    tc_run_real bash "${TC_PLUGIN_ROOT}/hooks/lib/sysml-toolchain.sh" detect "$tool"
    [ "$RC" -eq 0 ]
}

# Sandboxed run in an arbitrary directory, for the SessionStart hook,
# which is not installed into a repository.
tc_run_in() {
    local dir="$1"
    shift
    _tc_capture env -C "$dir" \
        -u CLAUDE_PLUGIN_ROOT -u VSE_SYSML_TOOLCHAIN -u VSE_JAVA -u JAVA_HOME \
        PATH="${STUBS}:/usr/bin:/bin" \
        HOME="${FAKEHOME}" \
        VSE_SYSML_PILOT_HOME="$(tc_pilot_home)" \
        ${TC_ENV[@]+"${TC_ENV[@]}"} \
        "$@"
}

# ----------------------------------------------------------- assertion

tc_pass() {
    TC_PASS_COUNT=$((TC_PASS_COUNT + 1))
    printf 'PASS: %s\n' "$1"
}

tc_fail() {
    TC_FAIL_COUNT=$((TC_FAIL_COUNT + 1))
    printf 'FAIL: %s\n' "$1"
    if [ "$#" -gt 1 ]; then
        printf '%s\n' "$2" | sed 's/^/      /'
    fi
}

tc_skip() {
    TC_SKIP_COUNT=$((TC_SKIP_COUNT + 1))
    printf 'SKIPPED: %s not installed\n' "$1"
    if [ "$#" -gt 1 ] && [ -n "$2" ]; then
        printf '  reason: %s\n' "$2"
    fi
}

_tc_context() {
    printf 'exit %s\n--- stdout ---\n%s\n--- stderr ---\n%s' "$RC" "$OUT" "$ERR"
}

tc_assert_rc() {
    local expected="$1" name="$2"
    if [ "$RC" -eq "$expected" ]; then
        tc_pass "$name"
    else
        tc_fail "$name" "expected exit ${expected}
$(_tc_context)"
    fi
}

# tc_assert_grep <fixed-string> <text> <case>
tc_assert_grep() {
    local pattern="$1" text="$2" name="$3"
    if printf '%s\n' "$text" | grep -qF -- "$pattern"; then
        tc_pass "$name"
    else
        tc_fail "$name" "expected to find: ${pattern}
$(_tc_context)"
    fi
}

tc_assert_not_grep() {
    local pattern="$1" text="$2" name="$3"
    if printf '%s\n' "$text" | grep -qF -- "$pattern"; then
        tc_fail "$name" "expected not to find: ${pattern}
$(_tc_context)"
    else
        tc_pass "$name"
    fi
}

# tc_assert_match <extended-regex> <text> <case>
tc_assert_match() {
    local pattern="$1" text="$2" name="$3"
    if printf '%s\n' "$text" | grep -qE -- "$pattern"; then
        tc_pass "$name"
    else
        tc_fail "$name" "expected to match: ${pattern}
$(_tc_context)"
    fi
}

tc_assert_not_match() {
    local pattern="$1" text="$2" name="$3"
    if printf '%s\n' "$text" | grep -qE -- "$pattern"; then
        tc_fail "$name" "expected not to match: ${pattern}
$(_tc_context)"
    else
        tc_pass "$name"
    fi
}

# tc_assert_eq <expected> <actual> <case>
tc_assert_eq() {
    local expected="$1" actual="$2" name="$3"
    if [ "$expected" = "$actual" ]; then
        tc_pass "$name"
    else
        tc_fail "$name" "expected: ${expected}
actual:   ${actual}"
    fi
}

# tc_assert_line_count <n> <text> <case>. An empty text counts as zero.
tc_assert_line_count() {
    local expected="$1" text="$2" name="$3" actual=0
    if [ -n "$text" ]; then
        actual="$(printf '%s\n' "$text" | grep -c '' || true)"
    fi
    if [ "$actual" -eq "$expected" ]; then
        tc_pass "$name"
    else
        tc_fail "$name" "expected ${expected} line(s), got ${actual}
$(_tc_context)"
    fi
}

tc_assert_empty() {
    local text="$1" name="$2"
    if [ -z "$text" ]; then
        tc_pass "$name"
    else
        tc_fail "$name" "expected empty, got:
${text}"
    fi
}

# ------------------------------------------------------------- summary

tc_summary() {
    local label="$1"
    printf '\n%s: %d passed, %d failed, %d skipped\n' \
        "$label" "$TC_PASS_COUNT" "$TC_FAIL_COUNT" "$TC_SKIP_COUNT"
    [ "$TC_FAIL_COUNT" -eq 0 ]
}
