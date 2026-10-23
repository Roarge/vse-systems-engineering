#!/usr/bin/env bash
# Self-tests for the shared harness in tests/hooks/lib.sh.
#
# The lifecycle hook tests rely on three harness promises that nothing
# else checks: the JSON payload reaches the hook on stdin, a project
# configuration can carry any gate override, and the JSON assertion
# accepts exactly one object. Each promise is exercised here against a
# stub, so a broken helper fails in this file rather than turning a
# hook test into a false pass.
#
# Run: bash tests/hooks/test-harness.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT
tc_setup_repo

# Run one assertion helper in a subshell, against a chosen OUT, and
# print the PASS or FAIL line it wrote. The subshell keeps the probe out
# of this file's own pass and fail counts, and leaves OUT untouched.
probe() (
    out="$1"
    shift
    OUT="$out" "$@"
)

# --------------------------------------------------- lifecycle runner

case_stdin_reaches_hook() {
    local root payload expected_cwd
    root="$(tc_mktemp_d)"
    mkdir -p "${root}/hooks"
    cat > "${root}/hooks/echo-stdin.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat
printf 'cwd=%s\n' "$(pwd -P)" >&2
printf 'root=%s\n' "${CLAUDE_PLUGIN_ROOT:-unset}" >&2
EOF
    chmod +x "${root}/hooks/echo-stdin.sh"
    payload='{"hook_event_name":"PreToolUse","tool_name":"Write"}'
    expected_cwd="$(cd "$REPO" && pwd -P)"

    tc_env
    TC_HOOK_ROOT="$root" tc_run_lifecycle echo-stdin "$payload"
    tc_assert_rc 0 "lifecycle runner: the stub hook exits 0"
    tc_assert_eq "$payload" "$OUT" "lifecycle runner: the JSON payload reaches the hook on stdin"
    tc_assert_line "cwd=${expected_cwd}" "$ERR" "lifecycle runner: the hook runs in the scratch repository"
    tc_assert_line "root=${root}" "$ERR" "lifecycle runner: CLAUDE_PLUGIN_ROOT names the hook root"
}

# Other runners keep an empty stdin, so a hook that reads stdin cannot
# block on the terminal of whoever runs the tests. The here-string is
# what such a hook would read if the runner let stdin through.
case_other_runners_read_empty_stdin() {
    tc_env
    tc_run_in "$REPO" cat <<< "leaked"
    tc_assert_rc 0 "other runners: cat exits 0"
    tc_assert_empty "$OUT" "other runners: stdin is empty"
}

# The profile library honours VSE_ISO_CONFIG, so a value exported by an
# outer run would steer every case to the wrong configuration. The
# sandboxed runners drop it, and a case that needs it passes it through
# tc_env.
case_runners_drop_outer_vse_iso_config() {
    local show
    # shellcheck disable=SC2016  # expanded by the shell under test
    show='printf "%s\n" "${VSE_ISO_CONFIG-unset}"'
    export VSE_ISO_CONFIG="/outer/run/.iso-config.yaml"
    tc_env
    tc_run_in "$REPO" bash -c "$show"
    tc_assert_eq "unset" "$OUT" "outer VSE_ISO_CONFIG: tc_run_in drops it"
    tc_run_lib_fn bash -c "$show"
    tc_assert_eq "unset" "$OUT" "outer VSE_ISO_CONFIG: the hook runners drop it"
    tc_run_real bash -c "$show"
    tc_assert_eq "unset" "$OUT" "outer VSE_ISO_CONFIG: the real-toolchain runner drops it"
    tc_env VSE_ISO_CONFIG=/from/tc-env.yaml
    tc_run_in "$REPO" bash -c "$show"
    tc_assert_eq "/from/tc-env.yaml" "$OUT" "VSE_ISO_CONFIG: tc_env still passes it through"
    tc_env
    unset VSE_ISO_CONFIG
}

# GITHUB_HEAD_REF names a pull request's branch in CI, and the
# project-side gates read it in range mode, so a value from the outer
# run (a CI job on a refactor/* branch, say) would steer every case.
# The sandboxed runners drop it, and a case that needs it passes it
# through tc_env.
case_runners_drop_outer_github_head_ref() {
    local show
    # shellcheck disable=SC2016  # expanded by the shell under test
    show='printf "%s\n" "${GITHUB_HEAD_REF-unset}"'
    export GITHUB_HEAD_REF="refactor/outer-run"
    tc_env
    tc_run_in "$REPO" bash -c "$show"
    tc_assert_eq "unset" "$OUT" "outer GITHUB_HEAD_REF: tc_run_in drops it"
    tc_run_lib_fn bash -c "$show"
    tc_assert_eq "unset" "$OUT" "outer GITHUB_HEAD_REF: the hook runners drop it"
    tc_run_real bash -c "$show"
    tc_assert_eq "unset" "$OUT" "outer GITHUB_HEAD_REF: the real-toolchain runner drops it"
    tc_env GITHUB_HEAD_REF=refactor/from-tc-env
    tc_run_lib_fn bash -c "$show"
    tc_assert_eq "refactor/from-tc-env" "$OUT" "GITHUB_HEAD_REF: tc_env still passes it through"
    tc_env
    unset GITHUB_HEAD_REF
}

# ----------------------------------------- runners on a BSD userland

# bsd_env_dir: print a new directory holding an env wrapper that parses
# its options the way BSD env does (getopt with the option string
# 0iP:S:u:v, as on macOS). It refuses -C, which BSD env lacks, with
# BSD's message, usage text and exit 1, and passes every other call to
# the real env found when the wrapper is written. Placed first on the
# PATH of a test script, it stands in for macOS env, so a runner that
# still changes directory with env -C fails on Linux too. The path of
# the real env is written quoted for the shell (printf %q), and the body
# comes from a quoted heredoc, so no character in that path is expanded
# when the wrapper runs.
bsd_env_dir() {
    local dir real
    dir="$(tc_mktemp_d)"
    real="$(command -v env)"
    {
        printf '#!/usr/bin/env bash\nset -uo pipefail\nreal=%q\n' "$real"
        cat <<'EOF'
usage() {
    echo 'usage: env [-0iv] [-P utilpath] [-S string] [-u name]' >&2
    echo '           [name=value ...] [utility [argument ...]]' >&2
    exit 1
}
while getopts ':0iP:S:u:v' opt; do
    case "$opt" in
        '?')
            echo "env: illegal option -- ${OPTARG}" >&2
            usage
            ;;
        ':')
            echo "env: option requires an argument -- ${OPTARG}" >&2
            usage
            ;;
    esac
done
exec "$real" "$@"
EOF
    } > "${dir}/env"
    chmod +x "${dir}/env"
    printf '%s\n' "$dir"
}

# The runners change into the scratch directory without env -C. A
# nested bash sources lib.sh with the BSD env wrapper first on its PATH
# and runs one runner per way the harness starts a command: tc_run_in,
# the sandboxed runner behind tc_run_hook (and the lifecycle and
# library runners), and tc_run_real. Each runs pwd -P in the scratch
# repository, and the nested shell prints "<runner>: ok" when the exit
# status is 0 and the directory is the repository's physical path.
case_runners_without_env_dash_c() {
    local wrap nested
    wrap="$(bsd_env_dir)"
    tc_env
    _tc_capture "${wrap}/env" -C "$REPO" true
    tc_assert_rc 1 "BSD env wrapper: -C is refused with exit 1"
    tc_assert_line "env: illegal option -- C" "$ERR" "BSD env wrapper: -C is refused with BSD's message"
    # shellcheck disable=SC2016  # expanded by the shell under test
    _tc_capture "${wrap}/env" -u TC_UNSET TC_SET=1 sh -c 'echo "${TC_SET}"'
    tc_assert_eq "1" "$OUT" "BSD env wrapper: options BSD env knows reach the real env"

    # shellcheck disable=SC2016  # expanded by the nested shell
    nested='
. "$1"
trap tc_teardown EXIT
tc_setup_repo
printf "#!/usr/bin/env bash\npwd -P\n" > "${REPO}/.githooks/pre-commit"
want="$(cd "$REPO" && pwd -P)"
report() {
    if [ "$RC" -eq 0 ] && [ "$OUT" = "$want" ]; then
        printf "%s: ok\n" "$1"
    else
        printf "%s: exit %s, pwd %s, stderr %s\n" "$1" "$RC" "$OUT" "$ERR"
    fi
}
tc_env
tc_run_in "$REPO" pwd -P
report tc_run_in
tc_run_hook
report tc_run_hook
tc_run_real pwd -P
report tc_run_real
'
    _tc_capture env PATH="${wrap}:${PATH}" TMPDIR="$(tc_mktemp_d)" \
        bash -c "$nested" nested "${TC_LIB_DIR}/lib.sh"
    tc_assert_rc 0 "without env -C: the nested test script exits 0"  # portability: ok a case name, not a call
    tc_assert_line "tc_run_in: ok" "$OUT" "without env -C: tc_run_in runs in the directory it names"  # portability: ok a case name, not a call
    tc_assert_line "tc_run_hook: ok" "$OUT" "without env -C: the sandboxed runner runs in the scratch repository"  # portability: ok a case name, not a call
    tc_assert_line "tc_run_real: ok" "$OUT" "without env -C: tc_run_real runs in the scratch repository"  # portability: ok a case name, not a call
}

# The wrapper names the real env quoted for the shell, so a path that
# holds a blank, a double quote or a dollar sign still reaches the env
# it was written for, with every argument. PATH is assigned on its own
# inside the command substitution, not as a prefix of the call, because
# bash 3.2 keeps the env it has already hashed for a function called
# with a prefix assignment, and the wrapper would name /usr/bin/env.
case_bsd_env_wrapper_quotes_real_env() {
    local odd wrap
    odd="$(tc_mktemp_d)/odd dir \$HOME \"q\""
    mkdir -p "$odd"
    cat > "${odd}/env" <<'EOF'
#!/bin/sh
printf 'odd env:'
printf ' %s' "$@"
printf '\n'
EOF
    chmod +x "${odd}/env"
    wrap="$(PATH="${odd}:${PATH}"; bsd_env_dir)"
    tc_env
    _tc_capture "${wrap}/env" -u TC_UNSET TC_SET=1 true
    tc_assert_rc 0 "BSD env wrapper, odd path: the real env runs"
    tc_assert_eq "odd env: -u TC_UNSET TC_SET=1 true" "$OUT" \
        "BSD env wrapper, odd path: the env it was written for gets every argument"
}

# An exported CDPATH makes cd print the directory it found, so a cd in a
# helper whose output is captured would add that line to the output.
# _tc_in_dir and the scratch root read a name relative to the working
# directory through CDPATH, and neither prints it. A TMPDIR relative to
# the working directory makes the scratch root such a name. Each nested
# shell makes its scratch root in a TMPDIR of this run, never in the
# TMPDIR of whoever runs the tests, and removes it, so nothing is left.
case_cd_ignores_cdpath() {
    local base work physical tmp
    base="$(tc_mktemp_d)"
    mkdir "${base}/cdpath-target"
    physical="$(cd "${base}/cdpath-target" && pwd -P)"
    tmp="$(tc_mktemp_d)"
    tc_env
    # shellcheck disable=SC2016  # expanded by the nested shell
    _tc_capture env CDPATH="$base" TMPDIR="$tmp" bash -c '. "$1"; trap tc_teardown EXIT; _tc_in_dir cdpath-target pwd -P' \
        nested "${TC_LIB_DIR}/lib.sh"
    tc_assert_eq "$physical" "$OUT" "CDPATH: _tc_in_dir prints only what the command prints"
    tc_assert_empty "$(ls -A "$tmp")" "CDPATH: the nested shell leaves no scratch root behind"

    work="$(tc_mktemp_d)"
    mkdir "${work}/tmp"
    physical="$(cd "${work}/tmp" && pwd -P)"
    # shellcheck disable=SC2016  # expanded by the nested shell
    _tc_capture _tc_in_dir "$work" env CDPATH=. TMPDIR=tmp bash -c '
. "$1"
trap tc_teardown EXIT
printf "root=%s\n" "$TC_ROOT"
' nested "${TC_LIB_DIR}/lib.sh"
    tc_assert_line_count 1 "$OUT" "CDPATH: the scratch root is one line"
    tc_assert_match "^root=${physical}/vse-hooktest[.]" "$OUT" \
        "CDPATH: the scratch root is made in TMPDIR, named by its physical path"
    tc_assert_empty "$(ls -A "${work}/tmp")" "CDPATH: the relative scratch root is removed"
}

# On macOS the temporary directory is reached through a symbolic link
# (/var links to /private/var), while a hook resolves its directory
# with pwd -P. The scratch root is therefore its own physical path, so
# a path a test builds from it equals the path a hook prints. Here
# TMPDIR names a symbolic link to a scratch directory.
case_scratch_root_is_physical() {
    local real link physical
    real="$(tc_mktemp_d)"
    physical="$(cd "$real" && pwd -P)"
    link="$(tc_mktemp_d)/tmp-link"
    ln -s "$real" "$link"
    tc_env
    # shellcheck disable=SC2016  # expanded by the nested shell
    _tc_capture env TMPDIR="$link" bash -c '
. "$1"
trap tc_teardown EXIT
printf "root=%s\n" "$TC_ROOT"
if [ "$TC_ROOT" = "$(cd "$TC_ROOT" && pwd -P)" ]; then
    echo "scratch root: physical"
else
    echo "scratch root: reached through a symbolic link"
fi
' nested "${TC_LIB_DIR}/lib.sh"
    tc_assert_rc 0 "physical scratch root: the nested test script exits 0"
    tc_assert_grep "root=${physical}/vse-hooktest." "$OUT" \
        "physical scratch root: the root is made in TMPDIR, named by its physical path"
    tc_assert_line "scratch root: physical" "$OUT" \
        "physical scratch root: the root equals its own pwd -P"
}

# A scratch root that mktemp cannot make must stop the test script
# where lib.sh is sourced. Otherwise the root falls back to the working
# directory, which under make is the plugin root, and the scratch
# repositories land in the tree that ships. Here TMPDIR names a missing
# directory. The nested script sets no teardown trap, because its
# working directory sits under this run's scratch root and would match
# the teardown's name guard, which would remove the evidence.
case_scratch_root_needs_mktemp() {
    local work missing listing
    work="$(tc_mktemp_d)"
    missing="${TC_ROOT}/no-such-dir"
    tc_env
    # shellcheck disable=SC2016  # expanded by the nested shell
    _tc_capture _tc_in_dir "$work" env TMPDIR="$missing" bash -c '
. "$1"
tc_setup_repo
printf "lib.sh carried on with TC_ROOT=%s\n" "$TC_ROOT"
' nested "${TC_LIB_DIR}/lib.sh"
    if [ "$RC" -ne 0 ]; then
        tc_pass "failed mktemp: the nested test script exits non-zero"
    else
        tc_fail "failed mktemp: the nested test script exits non-zero" "$(_tc_context)"
    fi
    tc_assert_grep "mktemp" "$ERR" "failed mktemp: stderr names mktemp as the cause"
    tc_assert_not_grep "lib.sh carried on" "$OUT" \
        "failed mktemp: the script stops where lib.sh is sourced"
    listing="$(ls -A "$work")"
    tc_assert_empty "$listing" "failed mktemp: nothing is written to the working directory"
}

# ------------------------------------------------ BSD-behaviour stubs

# Each stub refuses a GNU-only form with the message and exit status of
# the macOS tool, and lets the portable form through to the real tool.
# The commands run through tc_run_in, whose PATH puts the stub
# directory first, as a hook under test meets it.

case_bsd_grep_stub() {
    local file
    tc_stub_bsd_grep
    tc_env
    tc_run_in "$REPO" sh -c 'printf "a1\n" | grep -oP "a[0-9]"'  # portability: ok the BSD grep stub must refuse it
    tc_assert_rc 2 "BSD grep stub: -P in the group -oP exits 2"
    tc_assert_line "grep: invalid option -- P" "$ERR" "BSD grep stub: -P is refused with BSD's message"
    tc_assert_match '^usage: grep ' "$ERR" "BSD grep stub: the refusal prints the usage text"
    tc_assert_empty "$OUT" "BSD grep stub: a refused call prints nothing on stdout"
    tc_run_in "$REPO" grep -qP x /dev/null  # portability: ok the BSD grep stub must refuse it
    tc_assert_rc 2 "BSD grep stub: -P in the group -qP exits 2"
    tc_run_in "$REPO" grep --perl-regexp x /dev/null  # portability: ok the BSD grep stub must refuse it
    tc_assert_rc 2 "BSD grep stub: --perl-regexp exits 2"
    tc_assert_line "grep: unrecognized option \`--perl-regexp'" "$ERR" \
        "BSD grep stub: --perl-regexp is refused with BSD's message"
    tc_run_in "$REPO" sh -c 'printf "b\n" | grep "a\|b"'  # portability: ok the BSD grep stub must refuse it
    tc_assert_rc 2 "BSD grep stub: \\| in a basic regular expression exits 2"  # portability: ok a case name, not a call
    tc_assert_grep '\| in a basic regular expression' "$ERR" \
        "BSD grep stub: the refusal of \\| says why"  # portability: ok a case name, not a call
    tc_run_in "$REPO" sh -c 'printf "b\n" | grep -e x -e "a\|b"'  # portability: ok the BSD grep stub must refuse it
    tc_assert_rc 2 "BSD grep stub: \\| in a pattern given with -e exits 2"  # portability: ok a case name, not a call

    tc_run_in "$REPO" sh -c 'printf "a1\nb\n" | grep -oE "a[0-9]"'
    tc_assert_rc 0 "BSD grep stub: -oE runs the real grep"
    tc_assert_eq "a1" "$OUT" "BSD grep stub: -oE prints the match"
    tc_run_in "$REPO" sh -c 'printf "b\n" | grep -E "a|b"'
    tc_assert_eq "b" "$OUT" "BSD grep stub: alternation with -E runs the real grep"
    file="$(tc_mktemp_d)/text"
    printf '%s\n' 'a\|b' > "$file"
    tc_run_in "$REPO" grep -F 'a\|b' "$file"
    tc_assert_rc 0 "BSD grep stub: \\| with -F is a fixed string"  # portability: ok a case name, not a call
    tc_run_in "$REPO" grep 'a\\|b' "$file"  # portability: ok an escaped backslash, which the stub must pass
    tc_assert_rc 0 "BSD grep stub: an escaped backslash before | is not \\|"
    printf '%s\n' 'a|b' > "$file"
    tc_run_in "$REPO" grep 'a[\|]b' "$file"  # portability: ok in a bracket expression \| is two plain members
    tc_assert_rc 0 "BSD grep stub: a backslash and | in a bracket expression are plain members"
    tc_assert_eq "a|b" "$OUT" "BSD grep stub: the bracket expression reaches the real grep"
    tc_run_in "$REPO" grep 'a[]\|]b' "$file"  # portability: ok in a bracket expression \| is two plain members
    tc_assert_rc 0 "BSD grep stub: a ] first in a bracket expression does not close it"
    tc_run_in "$REPO" grep 'a[[:space:]\|]b' "$file"  # portability: ok in a bracket expression \| is two plain members
    tc_assert_rc 0 "BSD grep stub: the ] of a character class does not close the bracket expression"
    tc_run_in "$REPO" grep 'a[[=a=]\|]b' "$file"  # portability: ok in a bracket expression \| is two plain members
    tc_assert_rc 0 "BSD grep stub: the ] of an equivalence class does not close the bracket expression"
    printf '%s\n' 'axb' > "$file"
    tc_run_in "$REPO" grep 'a[^]\|]b' "$file"  # portability: ok in a bracket expression \| is two plain members
    tc_assert_rc 0 "BSD grep stub: a ] first in a negated bracket expression does not close it"
    tc_assert_eq "axb" "$OUT" "BSD grep stub: the negated bracket expression reaches the real grep"
    tc_run_in "$REPO" grep '[a]\|b' "$file"  # portability: ok the BSD grep stub must refuse it
    tc_assert_rc 2 "BSD grep stub: \\| after a bracket expression is still refused"  # portability: ok a case name, not a call
    tc_run_in "$REPO" sh -c 'printf "%s\n" -P | grep -e -P'  # portability: ok -P is the pattern here
    tc_assert_eq "-P" "$OUT" "BSD grep stub: -P after -e is a pattern"
    tc_run_in "$REPO" sh -c 'printf "%s\n" -P | grep -- -P'  # portability: ok -P is the pattern here
    tc_assert_eq "-P" "$OUT" "BSD grep stub: -P after -- is a pattern"
    tc_reset_stubs
}

case_bsd_date_stub() {
    tc_stub_bsd_date
    tc_env
    tc_run_in "$REPO" date -u -d '30 days ago' +%Y  # portability: ok the BSD date stub must refuse it
    tc_assert_rc 1 "BSD date stub: -d exits 1"
    tc_assert_line "date: illegal option -- d" "$ERR" "BSD date stub: -d is refused with BSD's message"
    tc_assert_match '^usage: date ' "$ERR" "BSD date stub: the refusal prints the usage text"
    tc_assert_empty "$OUT" "BSD date stub: a refused call prints nothing on stdout"
    tc_run_in "$REPO" date -ud yesterday +%Y  # portability: ok the BSD date stub must refuse it
    tc_assert_line "date: illegal option -- d" "$ERR" "BSD date stub: -d in the group -ud is refused"
    tc_run_in "$REPO" date --date=yesterday +%Y  # portability: ok the BSD date stub must refuse it
    tc_assert_rc 1 "BSD date stub: --date exits 1"
    tc_assert_line "date: illegal option -- -" "$ERR" \
        "BSD date stub: --date is refused as getopt refuses a long option"
    tc_run_in "$REPO" date +%Y -d yesterday
    tc_assert_rc 1 "BSD date stub: -d after the format exits 1"
    tc_assert_line "date: illegal time format" "$ERR" \
        "BSD date stub: -d after the format is read as the time to set"

    tc_run_in "$REPO" date -u +%Y-%m-%dT%H:%M:%SZ
    tc_assert_rc 0 "BSD date stub: -u with a format runs the real date"
    tc_assert_match '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' "$OUT" \
        "BSD date stub: the real date prints the time"
    tc_reset_stubs
}

case_bwk_awk_stub() {
    local two_lines
    two_lines="first
second"
    tc_stub_bwk_awk
    tc_env
    tc_run_in "$REPO" awk -v "list=${two_lines}" 'BEGIN { print "ran" }'
    tc_assert_rc 2 "BWK awk stub: a newline in a -v value exits 2"
    tc_assert_empty "$OUT" "BWK awk stub: the program is skipped"
    tc_assert_grep "awk: newline in string first" "$ERR" "BWK awk stub: the refusal is BWK awk's message"
    tc_run_in "$REPO" awk "-vlist=${two_lines}" 'BEGIN { print "ran" }'
    tc_assert_rc 2 "BWK awk stub: a newline in an attached -v value exits 2"

    tc_env "LIST=${two_lines}"
    tc_run_in "$REPO" awk 'BEGIN { print ENVIRON["LIST"] }'
    tc_assert_rc 0 "BWK awk stub: a value read through ENVIRON runs the real awk"
    tc_assert_eq "$two_lines" "$OUT" "BWK awk stub: the value keeps its newline through ENVIRON"
    tc_env
    tc_run_in "$REPO" awk -v 'list=first\nsecond' 'BEGIN { print list }'
    tc_assert_eq "$two_lines" "$OUT" "BWK awk stub: an escaped \\n in a -v value passes"
    tc_reset_stubs
}

# The jq stub refuses every /dev/fd path, open or not, the way jq on
# macOS refuses one whose descriptor bash 3.2 has already closed. The
# sh -c and jq programs are expanded by the shell and jq they reach.
# shellcheck disable=SC2016
case_closed_devfd_jq_stub() {
    local file
    file="$(tc_mktemp_d)/payload.json"
    printf '{"a": 1}\n' > "$file"
    tc_stub_closed_devfd_jq
    tc_env
    tc_run_in "$REPO" sh -c 'jq -n --slurpfile payload /dev/fd/3 "\$payload[0].a" 3< "$1"' sh "$file"
    tc_assert_rc 2 "closed /dev/fd jq stub: a /dev/fd path after --slurpfile exits 2"
    tc_assert_line "jq: Bad JSON in --slurpfile payload /dev/fd/3: Could not open /dev/fd/3: Bad file descriptor" "$ERR" \
        "closed /dev/fd jq stub: the refusal is the message jq gives for a closed descriptor"
    tc_assert_empty "$OUT" "closed /dev/fd jq stub: a refused call prints nothing on stdout"
    tc_run_in "$REPO" sh -c 'jq .a /dev/fd/3 3< "$1"' sh "$file"
    tc_assert_rc 2 "closed /dev/fd jq stub: a /dev/fd input file exits 2"
    tc_assert_line "jq: error: Could not open file /dev/fd/3: Bad file descriptor" "$ERR" \
        "closed /dev/fd jq stub: an input file is refused with jq's message"
    tc_run_in "$REPO" bash -c 'jq -n --slurpfile payload <(cat "$1") "\$payload[0].a"' bash "$file"  # portability: ok the stub must refuse a process substitution
    tc_assert_rc 2 "closed /dev/fd jq stub: a process substitution is refused"

    tc_run_in "$REPO" jq -n --slurpfile payload "$file" '$payload[0].a'
    tc_assert_rc 0 "closed /dev/fd jq stub: a regular file runs the real jq"
    tc_assert_eq "1" "$OUT" "closed /dev/fd jq stub: the real jq reads the regular file"
    tc_run_in "$REPO" sh -c 'jq .a < "$1"' sh "$file"
    tc_assert_eq "1" "$OUT" "closed /dev/fd jq stub: input on stdin runs the real jq"
    tc_reset_stubs
}

# The python3 stub refuses every /dev/fd path argument the way the
# image program fails on one whose descriptor bash 3.2 has closed, and
# lets a regular file through to the real python3. The programs are
# expanded by the shell and python3 they reach.
# shellcheck disable=SC2016
case_closed_devfd_python3_stub() {
    local file read
    file="$(tc_mktemp_d)/payload.json"
    printf '{"a": 1}\n' > "$file"
    read='import sys; sys.stdout.write(open(sys.argv[1]).read())'
    tc_stub_closed_devfd_python3
    tc_env
    tc_run_in "$REPO" sh -c 'python3 -I -c "$1" /dev/fd/3 3< "$2"' sh "$read" "$file"
    tc_assert_rc 2 "closed /dev/fd python3 stub: a /dev/fd path exits 2"
    tc_assert_line "[Errno 9] Bad file descriptor: '/dev/fd/3'" "$ERR" \
        "closed /dev/fd python3 stub: the refusal is the line the image program prints"
    tc_assert_empty "$OUT" "closed /dev/fd python3 stub: a refused call prints nothing on stdout"
    tc_run_in "$REPO" bash -c 'python3 -I -c "$1" <(cat "$2")' bash "$read" "$file"  # portability: ok the stub must refuse a process substitution
    tc_assert_rc 2 "closed /dev/fd python3 stub: a process substitution is refused"

    tc_run_in "$REPO" python3 -I -c "$read" "$file"
    tc_assert_rc 0 "closed /dev/fd python3 stub: a regular file runs the real python3"
    tc_assert_eq '{"a": 1}' "$OUT" "closed /dev/fd python3 stub: the real python3 reads the regular file"
    tc_reset_stubs
}

# ------------------------------------------------------ CRLF fixtures

# tc_crlf ends every line in a carriage return and a line feed (CR LF,
# the Windows line ending), a last line without a newline included, and
# changes nothing else.
case_crlf_helper() {
    local dir
    dir="$(tc_mktemp_d)"
    printf 'one\ntwo\n' | tc_crlf > "${dir}/got"
    printf 'one\r\ntwo\r\n' > "${dir}/want"
    if cmp -s "${dir}/want" "${dir}/got"; then
        tc_pass "crlf: every line ends in CR LF"
    else
        tc_fail "crlf: every line ends in CR LF" "$(od -c "${dir}/got")"
    fi
    printf 'one\ntwo' | tc_crlf > "${dir}/got"
    if cmp -s "${dir}/want" "${dir}/got"; then
        tc_pass "crlf: a last line without a newline ends in CR LF"
    else
        tc_fail "crlf: a last line without a newline ends in CR LF" "$(od -c "${dir}/got")"
    fi
    tc_crlf < /dev/null > "${dir}/got"
    if [ ! -s "${dir}/got" ]; then
        tc_pass "crlf: empty input gives empty output"
    else
        tc_fail "crlf: empty input gives empty output" "$(od -c "${dir}/got")"
    fi
}

# -------------------------------------------------- project configuration

case_config_two_gates() {
    tc_config standard - precommit_gherkin=off precommit_lint=info
    tc_assert_eq "project_profile: standard
gate_overrides:
  precommit_gherkin: off
  precommit_lint: info" "$(cat "${REPO}/.iso-config.yaml")" \
        "config: two gate specs share one gate_overrides block"
}

case_config_legacy_override() {
    tc_config full opensysml override=info
    tc_assert_eq "project_profile: full
sysml_toolchain: opensysml
gate_overrides:
  precommit_lint: info" "$(cat "${REPO}/.iso-config.yaml")" \
        "config: override=<disp> still sets precommit_lint"
}

case_config_no_specs() {
    tc_config light -
    tc_assert_eq "project_profile: light" "$(cat "${REPO}/.iso-config.yaml")" \
        "config: no spec writes no gate_overrides block"
}

# A spec without "=" names no disposition. Writing it as "gate: gate"
# would hand the hook under test a value nobody meant, so the helper
# refuses it and leaves the configuration file as it was.
case_config_rejects_spec_without_equals() {
    local errf rc=0
    tc_config light -
    errf="$(mktemp "${TC_ROOT}/err.XXXXXX")"
    ( tc_config standard - precommit_gherkin ) 2> "$errf" || rc=$?
    tc_assert_eq 2 "$rc" "config: a spec without = returns 2"
    tc_assert_grep "'precommit_gherkin' is not a <gate>=<disposition> spec" "$(cat "$errf")" \
        "config: the refusal names the spec and the expected form"
    tc_assert_eq "project_profile: light" "$(cat "${REPO}/.iso-config.yaml")" \
        "config: a refused spec leaves the configuration file unchanged"
}

case_config_append() {
    tc_config standard -
    tc_config_append <<'EOF'
tdd_scope:
  - src/
EOF
    tc_assert_eq "project_profile: standard
tdd_scope:
  - src/" "$(cat "${REPO}/.iso-config.yaml")" \
        "config: appended text lands verbatim after the generated keys"
}

# ------------------------------------------------------- JSON assertions

case_assert_json_accepts_one_object() {
    local result
    result="$(probe '{"decision":"deny"}' tc_assert_json '.decision == "deny"' "one object")"
    tc_assert_eq "PASS: one object" "$result" "assert_json: one matching object passes"
}

case_assert_json_rejects_two_objects() {
    local result
    result="$(probe '{"decision":"deny"}{"decision":"deny"}' tc_assert_json '.decision == "deny"' "two objects")"
    tc_assert_grep "FAIL: two objects" "$result" "assert_json: two matching objects fail"
}

case_assert_json_rejects_false_filter() {
    local result
    result="$(probe '{"decision":"ask"}' tc_assert_json '.decision == "deny"' "false filter")"
    tc_assert_grep "FAIL: false filter" "$result" "assert_json: a filter that does not hold fails"
}

# A filter jq cannot compile fails the assertion, and the failure shows
# jq's own message, so a typo in a test reads as a typo rather than as
# a hook that printed the wrong JSON.
case_assert_json_shows_jq_error() {
    local result
    result="$(probe '{"decision":"deny"}' tc_assert_json '.decision ==' "bad filter")"
    tc_assert_grep "FAIL: bad filter" "$result" "assert_json: a filter jq cannot compile fails"
    tc_assert_grep "jq: error" "$result" "assert_json: the failure shows jq's error"
}

# Without jq no JSON assertion can hold, and the failure says why
# rather than reporting a hook fault. The PATH holds sed alone, which
# the failure report itself needs.
case_assert_json_reports_missing_jq() {
    local bin result
    bin="$(tc_mktemp_d)"
    ln -s "$(command -v sed)" "${bin}/sed"
    result="$(PATH="$bin" probe '{"decision":"deny"}' tc_assert_json '.decision == "deny"' "no jq")"
    tc_assert_grep "FAIL: no jq" "$result" "assert_json: a missing jq fails the assertion"
    tc_assert_grep "jq is not installed" "$result" "assert_json: the failure names the missing jq"
}

# tc_assert_line compares whole lines, so a line that only starts with
# the expected text does not pass for it.
case_assert_line_exact() {
    local result
    result="$(tc_assert_line "cwd=/a" "first
cwd=/a
last" "exact line")"
    tc_assert_eq "PASS: exact line" "$result" "assert_line: an exact line among others passes"
    result="$(tc_assert_line "cwd=/a" "cwd=/a/b" "longer line")"
    tc_assert_grep "FAIL: longer line" "$result" "assert_line: a longer line does not pass"
    result="$(tc_assert_line "cwd=/a" "x cwd=/a" "embedded line")"
    tc_assert_grep "FAIL: embedded line" "$result" "assert_line: text inside a line does not pass"
}

# TC_LABEL_SUFFIX names the pass a case runs in. tc_pass, tc_fail and
# tc_skip add it to every assertion name in parentheses, so a case run
# once with the tool of the machine and once with a BSD-behaviour stub
# reports each assertion under a name of its own. Empty, it adds
# nothing.
# shellcheck disable=SC2034  # read by tc_pass and tc_fail in lib.sh
case_label_suffix() {
    local result
    result="$(TC_LABEL_SUFFIX="BSD grep"; tc_pass "a name")"
    tc_assert_eq "PASS: a name (BSD grep)" "$result" "label suffix: a pass names the pass it ran in"
    result="$(TC_LABEL_SUFFIX="BSD grep"; tc_fail "a name" "the detail")"
    tc_assert_eq "FAIL: a name (BSD grep)
      the detail" "$result" "label suffix: a failure names the pass it ran in"
    result="$(TC_LABEL_SUFFIX=""; tc_pass "a name")"
    tc_assert_eq "PASS: a name" "$result" "label suffix: an empty suffix adds nothing"
    result="$(TC_LABEL_SUFFIX="BSD grep"; tc_skip "a tool" "the reason")"
    tc_assert_eq "SKIPPED: a tool not installed (BSD grep)
  reason: the reason" "$result" "label suffix: a skip names the pass it ran in"
    result="$(TC_LABEL_SUFFIX=""; tc_skip "a tool")"
    tc_assert_eq "SKIPPED: a tool not installed" "$result" "label suffix: an empty suffix adds nothing to a skip"
}

case_assert_json_silent() {
    local result
    result="$(probe '' tc_assert_json_silent "empty")"
    tc_assert_eq "PASS: empty" "$result" "assert_json_silent: empty stdout passes"
    result="$(probe '{}' tc_assert_json_silent "object")"
    tc_assert_grep "FAIL: object" "$result" "assert_json_silent: any stdout fails"
}

# ------------------------------------------------- a PATH without tools

# tc_bin_without names a directory that links every program of /usr/bin
# and /bin except the named ones, so a case can take jq or python3 out
# of reach while sh, git and the rest still run.
case_bin_without_named_tools() {
    local bin
    bin="$(tc_bin_without jq python3)"
    if [ -d "$bin" ]; then
        tc_pass "bin without: the result is a directory"
    else
        tc_fail "bin without: the result is a directory" "got: ${bin}"
    fi
    tc_env PATH="$bin"
    tc_run_in "$REPO" sh -c 'command -v jq || echo no-jq; command -v python3 || echo no-python3'
    tc_assert_line "no-jq" "$OUT" "bin without: jq is out of reach"
    tc_assert_line "no-python3" "$OUT" "bin without: python3 is out of reach"
    tc_run_in "$REPO" sh -c 'command -v git && command -v sed'
    tc_assert_rc 0 "bin without: the programs not named still run"
    tc_assert_line "${bin}/git" "$OUT" "bin without: git is reached through the directory"

    bin="$(tc_bin_without)"
    tc_env PATH="$bin"
    tc_run_in "$REPO" sh -c 'command -v sh'
    tc_assert_line "${bin}/sh" "$OUT" "bin without: with no name every program is linked"
    tc_env
}

case_stdin_reaches_hook
case_other_runners_read_empty_stdin
case_runners_drop_outer_vse_iso_config
case_runners_drop_outer_github_head_ref
case_runners_without_env_dash_c
case_bsd_env_wrapper_quotes_real_env
case_cd_ignores_cdpath
case_scratch_root_is_physical
case_scratch_root_needs_mktemp
case_bsd_grep_stub
case_bsd_date_stub
case_bwk_awk_stub
case_closed_devfd_jq_stub
case_closed_devfd_python3_stub
case_crlf_helper
case_config_two_gates
case_config_legacy_override
case_config_no_specs
case_config_rejects_spec_without_equals
case_config_append
case_assert_json_accepts_one_object
case_assert_json_rejects_two_objects
case_assert_json_rejects_false_filter
case_assert_json_shows_jq_error
case_assert_json_reports_missing_jq
case_assert_line_exact
case_label_suffix
case_assert_json_silent
case_bin_without_named_tools

if tc_summary "test-harness"; then
    exit 0
fi
exit 1
