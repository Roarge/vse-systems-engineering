#!/usr/bin/env bash
# Shared helpers for the behavioural hook tests under tests/hooks/.
#
# Sourced by check-toolchain.sh and the test-*.sh files beside it.
# Provides a scratch git repository with the project-side hooks
# installed, a stub directory that shadows the real SysML toolchains, a
# PATH directory without named tools (tc_bin_without), assertion
# helpers, and a pass/fail summary.
#
# Two runners:
#   tc_run_hook, tc_run_lifecycle, tc_run_lib, tc_run_lib_fn are
#     sandboxed. PATH is the stub directory followed by /usr/bin and
#     /bin, HOME is a scratch directory, and the pilot home points
#     inside it, so nothing the machine has installed can reach the
#     code under test.
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
# Requires git and a POSIX userland. The helpers run on GNU/Linux and
# on macOS with its stock bash 3.2 and BSD tools, so they use no GNU-only
# option (env -C, for one). _tc_in_dir changes directory for the
# runners instead.
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
# assignment would never reach this scope. The root is named by its
# physical path, because on macOS the temporary directory is reached
# through a symbolic link (/var links to /private/var) and a hook that
# resolves its directory with pwd -P would otherwise print a path the
# test never built. The two steps stay two statements. Nested in one,
# a failed mktemp would leave cd an empty name, which keeps the working
# directory, so errexit (set -e) would not stop the script and the
# scratch root would become the working directory.
TC_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/vse-hooktest.XXXXXX")"
TC_ROOT="$(cd -- "$TC_ROOT" && pwd -P)"

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
# @attention-regime installs them, the story lint and the renderers it
# imports under tools/, plus an empty fake HOME and an empty stub
# directory.
tc_setup_repo() {
    local name
    REPO="$(tc_mktemp_d)"
    git -C "$REPO" init -q -b main
    git -C "$REPO" config user.email "hook-test@example.invalid"
    git -C "$REPO" config user.name "VSE hook test"
    git -C "$REPO" config commit.gpgsign false
    mkdir -p "${REPO}/.githooks/lib" "${REPO}/tools"
    cp "${TC_PLUGIN_ROOT}/hooks/pre-commit.sh" "${REPO}/.githooks/pre-commit"
    cp "${TC_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" "${REPO}/.githooks/pre-commit-traceability.sh"
    cp "${TC_PLUGIN_ROOT}/hooks/lib/iso-profile.sh" "${REPO}/.githooks/lib/iso-profile.sh"
    cp "${TC_PLUGIN_ROOT}/hooks/lib/sysml-toolchain.sh" "${REPO}/.githooks/lib/sysml-toolchain.sh"
    cp "${TC_PLUGIN_ROOT}/hooks/lib/test-first.sh" "${REPO}/.githooks/lib/test-first.sh"
    chmod +x "${REPO}/.githooks/pre-commit" \
             "${REPO}/.githooks/pre-commit-traceability.sh" \
             "${REPO}/.githooks/lib/iso-profile.sh" \
             "${REPO}/.githooks/lib/sysml-toolchain.sh" \
             "${REPO}/.githooks/lib/test-first.sh"
    # The lint imports ../render/sysml_model.py, so both directories
    # are installed. Bytecode caches are left behind.
    for name in lint render; do
        mkdir -p "${REPO}/tools/${name}"
        find "${TC_PLUGIN_ROOT}/templates/tools/${name}" -maxdepth 1 -type f \
            -exec cp {} "${REPO}/tools/${name}/" \;
    done
    git -C "$REPO" config core.hooksPath .githooks
    FAKEHOME="$(tc_mktemp_d)"
    STUBS="$(tc_mktemp_d)"
}

# tc_config <profile> <toolchain|-> [spec ...]
#
# Each spec is <gate>=<block|warn|info|off>, or override=<disp>, the
# older form that means precommit_lint. Every spec lands in one
# gate_overrides block, in the order given. A spec without "=" is
# refused with return 2 before anything is written.
tc_config() {
    local profile="$1" toolchain="$2" spec gate
    shift 2
    for spec in "$@"; do
        case "$spec" in
            *=*) : ;;
            *)
                printf "tc_config: '%s' is not a <gate>=<disposition> spec\n" "$spec" >&2
                return 2
                ;;
        esac
    done
    {
        printf 'project_profile: %s\n' "$profile"
        if [ "$toolchain" != "-" ]; then
            printf 'sysml_toolchain: %s\n' "$toolchain"
        fi
        if [ "$#" -gt 0 ]; then
            printf 'gate_overrides:\n'
            for spec in "$@"; do
                gate="${spec%%=*}"
                if [ "$gate" = "override" ]; then
                    gate="precommit_lint"
                fi
                printf '  %s: %s\n' "$gate" "${spec#*=}"
            done
        fi
    } > "${REPO}/.iso-config.yaml"
}

# tc_config_append: append stdin verbatim to the project configuration,
# for keys tc_config does not write.
tc_config_append() {
    cat >> "${REPO}/.iso-config.yaml"
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

# jq 1.5 has no halt_error. The stub refuses any program that calls it,
# with the compile error and exit status 3 jq 1.5 gives, and passes
# every other call to the real jq found when the stub is written.
tc_stub_old_jq() {
    local real
    real="$(command -v jq)"
    tc_stub jq <<EOF
#!/usr/bin/env bash
set -uo pipefail
for arg in "\$@"; do
    case "\$arg" in
        *halt_error*)
            echo "jq: error: halt_error/1 is not defined at <top-level>, line 18:" >&2
            echo "jq: 1 compile error" >&2
            exit 3
            ;;
    esac
done
exec "${real}" "\$@"
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

# BSD-behaviour stubs.
#
# macOS ships BSD grep, BSD date and the one true awk (BWK awk, after
# Brian W. Kernighan, who maintains it), and each accepts less than its
# GNU counterpart.
# Each stub below refuses what the macOS tool refuses, the way that tool
# refuses it, and passes every other call to the real tool found when
# the stub is written. A hook under test meets the stub through the
# sandboxed PATH, so a hook that relies on a GNU-only form fails on
# Linux too. The test script itself keeps the real tool.

# _tc_stub_wrap <name>: write the stub <name> into $STUBS from stdin,
# after a header that names the real <name> found now as $real. The
# body is read verbatim, so it is written without escapes.
_tc_stub_wrap() {
    local name="$1" real
    real="$(command -v "$name")"
    {
        printf '#!/usr/bin/env bash\nset -uo pipefail\nreal=%q\n' "$real"
        cat
    } | tc_stub "$name"
}

# tc_stub_bsd_grep: BSD grep has no -P (Perl regular expressions). It
# refuses -P with "grep: invalid option -- P" and --perl-regexp with
# "grep: unrecognized option `--perl-regexp'", then prints its usage
# text and exits 2. The stub reads the options the way grep's
# getopt_long does: anywhere before "--", with single letters grouped
# (so -oP is refused as -P is), and with the argument of -e, -f and the
# other options that take one never read as an option (so the pattern
# "-P" after -e is a pattern). POSIX leaves \| in a basic regular
# expression undefined, so a BSD grep need not read it as alternation.
# The stub refuses an unescaped \| in a basic regular expression (no
# -E, no -F) with a message and exit 2, so a use fails loudly here. The
# patterns checked are those given with -e or --regexp, or else the
# first operand. A pattern file named by -f is not read.
tc_stub_bsd_grep() {
    _tc_stub_wrap grep <<'EOF'
usage() {
    echo 'usage: grep [-abcdDEFGHhIiJLlMmnOopqRSsUVvwXxZz] [-A num] [-B num] [-C[num]]' >&2
    printf '\t%s\n' '[-e pattern] [-f file] [--binary-files=value] [--color=when]' \
        '[--context[=num]] [--directories=action] [--label] [--line-buffered]' \
        '[--null] [pattern] [file ...]' >&2
    exit 2
}
mode=basic
patterns=()
from_option=0
operand=""
have_operand=0
expect=""
ended=0
for arg in "$@"; do
    if [ -n "$expect" ]; then
        if [ "$expect" = pattern ]; then
            patterns+=("$arg")
        fi
        expect=""
        continue
    fi
    if [ "$ended" -eq 0 ]; then
        case "$arg" in
            --)
                ended=1
                continue
                ;;
            --perl*)
                printf "grep: unrecognized option \`%s'\n" "$arg" >&2
                usage
                ;;
            --extended-regexp) mode=extended; continue ;;
            --fixed-strings) mode=fixed; continue ;;
            --basic-regexp) mode=basic; continue ;;
            --regexp=*) patterns+=("${arg#--regexp=}"); from_option=1; continue ;;
            --regexp) expect=pattern; from_option=1; continue ;;
            --file=*) from_option=1; continue ;;
            --file) expect=file; from_option=1; continue ;;
            --after-context|--before-context|--binary-files|--devices|--directories|\
            --exclude|--exclude-dir|--include|--include-dir|--label|--max-count)
                expect=argument
                continue
                ;;
            --*) continue ;;
            -?*)
                group="${arg#-}"
                while [ -n "$group" ]; do
                    letter="${group%"${group#?}"}"
                    group="${group#?}"
                    case "$letter" in
                        P)
                            echo 'grep: invalid option -- P' >&2
                            usage
                            ;;
                        E) mode=extended ;;
                        F) mode=fixed ;;
                        G) mode=basic ;;
                        e)
                            from_option=1
                            if [ -n "$group" ]; then
                                patterns+=("$group")
                            else
                                expect=pattern
                            fi
                            group=""
                            ;;
                        f|A|B|C|D|d|m)
                            if [ "$letter" = f ]; then
                                from_option=1
                            fi
                            if [ -z "$group" ]; then
                                expect=argument
                            fi
                            group=""
                            ;;
                    esac
                done
                continue
                ;;
        esac
    fi
    if [ "$have_operand" -eq 0 ]; then
        operand="$arg"
        have_operand=1
    fi
done
if [ "$from_option" -eq 0 ] && [ "$have_operand" -eq 1 ]; then
    patterns+=("$operand")
fi
if [ "$mode" = basic ]; then
    for pattern in ${patterns[@]+"${patterns[@]}"}; do
        i=0
        while [ "$i" -lt "${#pattern}" ]; do
            if [ "${pattern:$i:1}" = '\' ]; then
                if [ "${pattern:$((i + 1)):1}" = '|' ]; then
                    echo 'grep: \| in a basic regular expression is not portable to BSD grep (use -E and |)' >&2
                    exit 2
                fi
                i=$((i + 1))
            fi
            i=$((i + 1))
        done
    done
fi
exec "$real" "$@"
EOF
}

# tc_stub_bsd_date: BSD date has no -d (GNU's date string) and no long
# options. It reads its options with getopt and the option string of
# macOS date (f:I::jnRr:uv:), so it refuses any other letter with
# "date: illegal option -- <letter>", its usage text and exit 1. That
# covers -d alone, -d in a group such as -ud, and --date, whose first
# letter getopt reads as "-". Options end at "--" or at the first
# operand, as they do for getopt. GNU date reads options after an
# operand too, so "date +%Y -d x" passes there. BSD date takes the
# operand after the +format as the time to set, and refuses one that
# starts with "-" as an illegal time format, so the stub does too.
tc_stub_bsd_date() {
    _tc_stub_wrap date <<'EOF'
usage() {
    echo 'usage: date [-jnRu] [-I[date|hours|minutes|seconds]] [-f input_fmt]' >&2
    echo '            [-r filename|seconds] [-v[+|-]val[y|m|w|d|H|M|S]]' >&2
    echo '            [[[[mm]dd]HH]MM[[cc]yy][.SS] | new_date] [+output_fmt]' >&2
    exit 1
}
check() {
    local group letter
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --) shift; break ;;
            -?*) ;;
            *) break ;;
        esac
        group="${1#-}"
        shift
        while [ -n "$group" ]; do
            letter="${group%"${group#?}"}"
            group="${group#?}"
            case "$letter" in
                j|n|R|u) ;;
                I) group="" ;;
                f|r|v)
                    if [ -z "$group" ]; then
                        if [ "$#" -eq 0 ]; then
                            echo "date: option requires an argument -- ${letter}" >&2
                            usage
                        fi
                        shift
                    fi
                    group=""
                    ;;
                *)
                    echo "date: illegal option -- ${letter}" >&2
                    usage
                    ;;
            esac
        done
    done
    case "${1:-}" in
        +*) shift ;;
    esac
    case "${1:-}" in
        -*)
            echo 'date: illegal time format' >&2
            usage
            ;;
    esac
}
check "$@"
exec "$real" "$@"
EOF
}

# tc_stub_bwk_awk: BWK awk, the awk of macOS, refuses a newline inside
# a -v value. It reports "newline in string" with the first twenty
# characters of the value, then skips the program and exits 2, so the
# program prints nothing. The stub does the same for -v name=value and
# -vname=value. It reads the options the way BWK awk does: one option
# per word, -f and -F taking an argument, up to "--" or the first
# operand (the program). An escaped \n in a value is not a newline, and
# BWK awk accepts it, so the stub passes it.
tc_stub_bwk_awk() {
    _tc_stub_wrap awk <<'EOF'
newline='
'
expect=""
for arg in "$@"; do
    assignment=""
    if [ -n "$expect" ]; then
        if [ "$expect" = v ]; then
            assignment="$arg"
        fi
        expect=""
    else
        case "$arg" in
            --) break ;;
            -v) expect=v ;;
            -f|-F) expect=argument ;;
            -v*) assignment="${arg#-v}" ;;
            -?*) ;;
            *) break ;;
        esac
    fi
    case "$assignment" in
        *=*"$newline"*)
            printf 'awk: newline in string %.20s... at source line 1\n' "${assignment#*=}" >&2
            exit 2
            ;;
    esac
done
exec "$real" "$@"
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

# tc_mark_plugin_repo [<dir>]: make <dir> ($REPO by default) the
# plugin repository as the hooks recognise it: the wiki schema file
# wiki/CLAUDE.md and a plugin manifest that names the plugin.
tc_mark_plugin_repo() {
    local dir="${1:-$REPO}"
    mkdir -p "${dir}/wiki" "${dir}/.claude-plugin"
    printf '# Wiki schema\n' > "${dir}/wiki/CLAUDE.md"
    printf '{\n  "name": "vse-systems-engineering",\n  "version": "5.0.0"\n}\n' \
        > "${dir}/.claude-plugin/plugin.json"
}

# Write a file outside the repository, for transcripts and fixtures.
tc_write_at() {
    local path="$1"
    mkdir -p "$(dirname "$path")"
    cat > "$path"
}

# tc_crlf: copy stdin to stdout with every line ending in a carriage
# return and a line feed (CR LF), for fixtures that imitate a checkout
# with Windows line endings. awk writes the carriage return the same
# way everywhere, where BSD sed reads \r in a replacement as a plain r.
tc_crlf() {
    awk '{ printf "%s\r\n", $0 }'
}

tc_stage() {
    git -C "$REPO" add -- "$@"
}

tc_commit() {
    git -C "$REPO" commit -q --no-verify -m "$1"
}

# tc_tag_many <dir> <prefix> <count>: tag HEAD of the repository at
# <dir> as <prefix>1 to <prefix><count>, in one git call. Twelve
# thousand tags of about sixteen characters list as some 200 KB, more
# than a pipe buffer holds (64 KiB), so a reader that stops after the
# first line leaves the writer blocked on a full pipe.
tc_tag_many() {
    local dir="$1" prefix="$2" count="$3" head
    head="$(git -C "$dir" rev-parse HEAD)"
    awk -v prefix="$prefix" -v count="$count" -v head="$head" 'BEGIN {
        for (i = 1; i <= count; i++)
            printf "create refs/tags/%s%d %s\n", prefix, i, head
    }' | git -C "$dir" update-ref --stdin
}

# -------------------------------------------------------------- runner

# tc_env NAME=VALUE ...: environment for the next runner call. With no
# arguments the extra environment is cleared, which is the common call.
# shellcheck disable=SC2120
tc_env() {
    TC_ENV=("$@")
}

# _tc_in_dir <dir> <command> [arg ...]: run the command in <dir>. The
# body is a subshell, so the caller's directory is left alone, and the
# command replaces it. It stands in for GNU env -C, which macOS env
# lacks. Exit 125 means the directory could not be entered, the status
# env -C gives for the same failure.
_tc_in_dir() (
    cd -- "$1" || exit 125
    shift
    exec "$@"
)

# Stdin is the file named by TC_STDIN, or empty when it is unset, so
# code under test never reads the terminal of whoever runs the tests.
_tc_capture() {
    local outf errf
    outf="$(mktemp "${TC_ROOT}/out.XXXXXX")"
    errf="$(mktemp "${TC_ROOT}/err.XXXXXX")"
    RC=0
    # The command the runners pass is env, or _tc_in_dir, which replaces
    # itself with env. Either way the code under test is an external
    # process, so the errexit context of this caller cannot leak into it.
    "$@" > "$outf" 2> "$errf" < "${TC_STDIN:-/dev/null}" || RC=$?
    # shellcheck disable=SC2034
    OUT="$(cat "$outf")"
    # shellcheck disable=SC2034
    ERR="$(cat "$errf")"
    rm -f "$outf" "$errf"
}

# Sandboxed run inside $REPO. The stub directory shadows /usr/bin, HOME
# and the pilot home are scratch, and every variable an installer or an
# outer run might carry into the sandbox is removed, including the probe
# budget, the configuration path and the pull request branch CI names
# (GITHUB_HEAD_REF), so a case that pins one sets it deliberately
# through tc_env.
_tc_sandboxed() {
    _tc_capture _tc_in_dir "$REPO" env \
        -u CLAUDE_PLUGIN_ROOT -u VSE_SYSML_TOOLCHAIN -u VSE_JAVA -u JAVA_HOME \
        -u VSE_TC_PROBE_TIMEOUT -u VSE_ISO_CONFIG -u GITHUB_HEAD_REF \
        PATH="${STUBS}:/usr/bin:/bin" \
        HOME="${FAKEHOME}" \
        VSE_SYSML_PILOT_HOME="$(tc_pilot_home)" \
        ${TC_ENV[@]+"${TC_ENV[@]}"} \
        "$@"
}

tc_run_hook() {
    _tc_sandboxed ./.githooks/pre-commit
}

# tc_install_githook <name>: install hooks/<name>.sh as .githooks/<name>,
# for the git hooks tc_setup_repo does not install.
tc_install_githook() {
    local name="$1"
    cp "${TC_PLUGIN_ROOT}/hooks/${name}.sh" "${REPO}/.githooks/${name}"
    chmod +x "${REPO}/.githooks/${name}"
}

# tc_run_githook <name> [arg ...]: run .githooks/<name> sandboxed in
# $REPO, the way git runs it, with the arguments git would pass.
tc_run_githook() {
    local name="$1"
    shift
    _tc_sandboxed "./.githooks/${name}" "$@"
}

# tc_run_lifecycle <hook-basename> <json>: run a lifecycle hook the way
# the harness does, sandboxed in $REPO with the JSON payload on stdin
# and CLAUDE_PLUGIN_ROOT naming the plugin root. TC_HOOK_ROOT, when
# set, replaces the plugin root, so a self-test can run a stub hook.
tc_run_lifecycle() {
    local hook="$1" json="$2" root TC_STDIN
    root="${TC_HOOK_ROOT:-${TC_PLUGIN_ROOT}}"
    TC_STDIN="$(mktemp "${TC_ROOT}/stdin.XXXXXX")"
    printf '%s' "$json" > "$TC_STDIN"
    _tc_sandboxed CLAUDE_PLUGIN_ROOT="$root" "${root}/hooks/${hook}.sh"
    rm -f "$TC_STDIN"
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
# installed-toolchain sections. The configuration path and an outer
# GITHUB_HEAD_REF are dropped here too, so an outer value cannot steer
# a real-tool case.
tc_run_real() {
    _tc_capture _tc_in_dir "$REPO" env \
        -u CLAUDE_PLUGIN_ROOT -u VSE_SYSML_TOOLCHAIN -u VSE_ISO_CONFIG -u GITHUB_HEAD_REF \
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

# tc_bin_without [<tool> ...]: print a new scratch directory holding a
# symbolic link to every program in /usr/bin and /bin except the named
# tools. A case passes it as PATH to take jq or python3 out of reach
# while every other program still runs. Where /bin and /usr/bin hold
# the same name, the /usr/bin program is linked. The links are made by
# one ln call per source directory, in the POSIX form that names the
# target directory last (GNU ln -t is not available on macOS).
tc_bin_without() {
    local dir src entry name tool keep
    local links
    dir="$(tc_mktemp_d)"
    for src in /usr/bin /bin; do
        links=()
        for entry in "${src}"/*; do
            name="${entry##*/}"
            # A directory is not a program, a glob that matched nothing
            # is not a file, and a name linked from /usr/bin stays.
            if [ -d "$entry" ] || { [ ! -e "$entry" ] && [ ! -L "$entry" ]; }; then
                continue
            fi
            if [ -e "${dir}/${name}" ] || [ -L "${dir}/${name}" ]; then
                continue
            fi
            keep=1
            for tool in "$@"; do
                if [ "$name" = "$tool" ]; then
                    keep=0
                    break
                fi
            done
            if [ "$keep" -eq 1 ]; then
                links+=("$entry")
            fi
        done
        if [ "${#links[@]}" -gt 0 ]; then
            ln -s "${links[@]}" "$dir"
        fi
    done
    printf '%s\n' "$dir"
}

# Sandboxed run in an arbitrary directory, for the SessionStart hook,
# which is not installed into a repository.
tc_run_in() {
    local dir="$1"
    shift
    _tc_capture _tc_in_dir "$dir" env \
        -u CLAUDE_PLUGIN_ROOT -u VSE_SYSML_TOOLCHAIN -u VSE_JAVA -u JAVA_HOME \
        -u VSE_TC_PROBE_TIMEOUT -u VSE_ISO_CONFIG -u GITHUB_HEAD_REF \
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

# tc_assert_line <exact-line> <text> <case>: one line of the text is
# exactly the expected line, not merely a line that contains it.
tc_assert_line() {
    local line="$1" text="$2" name="$3"
    if printf '%s\n' "$text" | grep -qxF -- "$line"; then
        tc_pass "$name"
    else
        tc_fail "$name" "expected a line equal to: ${line}
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

# tc_assert_json <jq-filter> <case>: stdout is exactly one JSON value
# and the filter holds on it. A hook that prints two objects fails even
# when both satisfy the filter, because the output contract allows
# exactly one. A failure shows what jq wrote on stderr, such as the
# error for a filter it cannot compile, and a missing jq fails with a
# line that says so.
tc_assert_json() {
    local filter="$1" name="$2" jq_err="" held=0
    if ! command -v jq > /dev/null 2>&1; then
        tc_fail "$name" "jq is not installed, so no JSON assertion can hold
$(_tc_context)"
        return 0
    fi
    if jq_err="$(printf '%s' "$OUT" | jq -e "$filter" 2>&1 > /dev/null)" \
        && jq_err="$(printf '%s' "$OUT" | jq -e -s 'length == 1' 2>&1 > /dev/null)"; then
        held=1
    fi
    if [ "$held" -eq 1 ]; then
        tc_pass "$name"
    else
        tc_fail "$name" "expected one JSON value satisfying: ${filter}${jq_err:+
--- jq ---
${jq_err}}
$(_tc_context)"
    fi
}

# tc_assert_json_silent <case>: the hook printed nothing on stdout.
tc_assert_json_silent() {
    local name="$1"
    if [ -z "$OUT" ]; then
        tc_pass "$name"
    else
        tc_fail "$name" "expected no stdout
$(_tc_context)"
    fi
}

# ------------------------------------------------------------- summary

tc_summary() {
    local label="$1"
    printf '\n%s: %d passed, %d failed, %d skipped\n' \
        "$label" "$TC_PASS_COUNT" "$TC_FAIL_COUNT" "$TC_SKIP_COUNT"
    [ "$TC_FAIL_COUNT" -eq 0 ]
}
