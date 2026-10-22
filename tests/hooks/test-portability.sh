#!/usr/bin/env bash
# A scan of the hook scripts, the hook libraries, the hook tests and the
# Makefile for GNU-only forms, which macOS refuses or reads differently.
# The shipped hooks and their tests run under the stock bash 3.2 and
# the BSD tools of macOS (grep, sed, awk, date, env, stat and the rest)
# as well as on GNU/Linux, so none of these forms may appear.
#
# The scan reads hooks/*.sh, hooks/lib/*.sh, tests/hooks/*.sh (except
# this file, which holds every form as a fixture) and the Makefile. It
# skips a comment line (one whose first character other than a blank is
# #) and a line that carries the allow-list marker
# "# portability: ok <reason>", which a reviewer accepts for a
# deliberate use, such as a self-test that feeds a GNU-only form to a
# BSD-behaviour stub. A marker with no reason exempts nothing.
#
# The patterns are deliberately simple. A command is a word not joined
# to a letter, digit, "_", "." or "-" on its left. Its options are the
# words that start with "-" right after it, and a form matches when one
# of those words carries the banned letter, alone or in a group (-oP).
# The forms and what each one looks for:
#   grep -P                a -P option of grep (Perl regular expressions)
#   grep --perl-regexp     the long form of the same
#   \| in a basic regex    \| after grep or sed, when that grep or sed
#                          carries no -E or -F on the line (in an
#                          extended regular expression \| is a plain |)
#   env -C                 a -C option of env (run in a directory)
#   date -d, date --date   GNU date's date string
#   sed -i without a backup suffix
#                          a -i option of sed followed by a blank, where
#                          -i.bak is the portable form
#   \r in a sed call       \r anywhere in a sed call before the next |
#   readlink -f, stat -c, xargs -r, sort -V
#   head -n -N             a negative line count
#   ln -t, cp -t           a target directory named first
#   mapfile, readarray, declare -A (also typeset -A and local -A),
#   ${x,,}, ${x^^}         bash 4 features (the single , and ^ forms too)
#   awk match with three arguments
#                          match( with two commas before any parenthesis
#
# A finding is printed as <file>:<line>: <form>.
#
# Run: bash tests/hooks/test-portability.sh
#
# The fixtures are shell text that is written to files, not expanded.
# shellcheck disable=SC2016
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

# The scanner, in POSIX awk so it runs under mawk, gawk and the BWK awk
# of macOS. Each line is matched with a blank added at either end, so a
# command at the start of a line and an option at its end need no
# anchor inside a group, which not every awk reads the same way.
PORTABILITY_AWK='
BEGIN {
    b = "[^A-Za-z0-9_.-]"
    o = "[ \t]+(-[^ \t]*[ \t]+)*"
    n = 0
    n++; form[n] = "grep -P"; re[n] = b "grep" o "-[A-Za-z]*P"
    n++; form[n] = "grep --perl-regexp"; re[n] = b "grep" o "--perl-regexp"
    n++; form[n] = "env -C"; re[n] = b "env" o "-[A-Za-z]*C"
    n++; form[n] = "date -d"; re[n] = b "date" o "-[A-Za-z]*d"
    n++; form[n] = "date --date"; re[n] = b "date" o "--date"
    n++; form[n] = "sed -i without a backup suffix"; re[n] = b "sed" o "-[A-Za-z]*i[ \t]"
    n++; form[n] = "\\r in a sed call"; re[n] = b "sed[ \t][^|]*\\\\r"
    n++; form[n] = "readlink -f"; re[n] = b "readlink" o "-[A-Za-z]*f"
    n++; form[n] = "stat -c"; re[n] = b "stat" o "-[A-Za-z]*c"
    n++; form[n] = "xargs -r"; re[n] = b "xargs" o "-[A-Za-z]*r"
    n++; form[n] = "sort -V"; re[n] = b "sort" o "-[A-Za-z]*V"
    n++; form[n] = "head -n -N"; re[n] = b "head" o "-n[ \t]*-[0-9]"
    n++; form[n] = "ln -t"; re[n] = b "ln" o "-[A-Za-z]*t"
    n++; form[n] = "cp -t"; re[n] = b "cp" o "-[A-Za-z]*t"
    n++; form[n] = "mapfile"; re[n] = b "mapfile[ \t]"
    n++; form[n] = "readarray"; re[n] = b "readarray[ \t]"
    n++; form[n] = "declare -A"; re[n] = b "(declare|typeset|local)" o "-[A-Za-z]*A"
    n++; form[n] = "${x,,}"; re[n] = "[$][{][A-Za-z_][A-Za-z0-9_]*,"
    n++; form[n] = "${x^^}"; re[n] = "[$][{][A-Za-z_][A-Za-z0-9_]*\\^"
    n++; form[n] = "awk match with three arguments"; re[n] = b "match[ \t]*[(][^()]*,[^()]*,"
    bre = b "(grep|sed)[ \t][^|]*\\\\[|]"
    ere = b "(grep|sed)" o "-[A-Za-z]*[EF]"
}
/^[ \t]*#/ { next }
/#[ \t]*portability: ok[ \t]+[^ \t]/ { next }
{
    line = " " $0 " "
    for (i = 1; i <= n; i++)
        if (line ~ re[i])
            printf "%s:%d: %s\n", FILENAME, FNR, form[i]
    if (line ~ bre && line !~ ere)
        printf "%s:%d: %s\n", FILENAME, FNR, "\\| in a basic regex"
}
'

# portability_scan <file>...: print one finding per banned form a line
# carries.
portability_scan() {
    awk "$PORTABILITY_AWK" "$@"
}

# scan_files <root>: print the files the scan reads under <root>, one
# per line, relative to <root>.
scan_files() {
    local root="$1" f
    for f in "$root"/hooks/*.sh "$root"/hooks/lib/*.sh "$root"/tests/hooks/*.sh "$root"/Makefile; do
        [ -f "$f" ] || continue
        [ "${f##*/}" = "test-portability.sh" ] && continue
        printf '%s\n' "${f#"$root"/}"
    done
}

# scan_fixture <line>...: write the lines after a shebang into a new
# scratch script, scan it, and leave the findings in OUT and the script
# in FIXTURE.
FIXTURE=""
scan_fixture() {
    FIXTURE="$(tc_mktemp_d)/fixture.sh"
    {
        printf '#!/usr/bin/env bash\n'
        printf '%s\n' "$@"
    } > "$FIXTURE"
    RC=0
    ERR=""
    OUT="$(portability_scan "$FIXTURE")" || RC=$?
}

# ------------------------------------------- each banned form is found

# case_form <form> <line>: a script whose second line is <line> draws
# exactly one finding, which names the script, line 2 and <form>.
case_form() {
    local form="$1" line="$2"
    scan_fixture "$line"
    tc_assert_line "${FIXTURE}:2: ${form}" "$OUT" "${form}: found in: ${line}"
    tc_assert_line_count 1 "$OUT" "${form}: one finding for: ${line}"
}

case_form 'grep -P' 'names=$(grep -oP "\w+" "$f")'
case_form 'grep --perl-regexp' 'grep --perl-regexp "\d" "$f"'
case_form '\| in a basic regex' 'grep -v "\(^\|/\)library/" "$f"'
case_form '\| in a basic regex' 'sed "s/a\|b/c/" "$f"'
case_form 'env -C' 'env -C "$dir" make'
case_form 'date -d' 'date -u -d "14 days ago" +%s'
case_form 'date --date' 'date --date="14 days ago" +%s'
case_form 'sed -i without a backup suffix' 'sed -i "s/x/y/" "$f"'
case_form '\r in a sed call' 'printf "a\n" | sed "s/$/\r/" > "$f"'
case_form 'readlink -f' 'dir=$(readlink -f "$0")'
case_form 'stat -c' 'size=$(stat -c %s "$f")'
case_form 'xargs -r' 'find . -name "*.tmp" | xargs -r rm'
case_form 'sort -V' 'sort -V versions.txt'
case_form 'head -n -N' 'head -n -1 "$f"'
case_form 'ln -t' 'ln -s -t "$dir" "$src"'
case_form 'cp -t' 'cp -t "$dir" "$src"'
case_form 'mapfile' 'mapfile -t lines < "$f"'
case_form 'readarray' 'readarray -t lines < "$f"'
case_form 'declare -A' 'declare -A seen'
case_form '${x,,}' 'lower="${name,,}"'
case_form '${x^^}' 'upper="${name^^}"'
case_form 'awk match with three arguments' 'awk "{ if (match(\$0, /[0-9]+/, m)) print m[0] }" "$f"'

# --------------------------------------- what the scan leaves alone

scan_fixture '    # names=$(grep -oP "\w+" "$f") was the old form' '# sed -i "s/x/y/" "$f"'
tc_assert_empty "$OUT" "a comment line draws no finding"

scan_fixture 'grep -oP "a[0-9]" "$f"  # portability: ok the BSD grep stub must refuse it'
tc_assert_empty "$OUT" "the allow-list marker with a reason exempts the line"

scan_fixture 'grep -oP "a[0-9]" "$f"  # portability: ok'
tc_assert_line "${FIXTURE}:2: grep -P" "$OUT" "the allow-list marker with no reason exempts nothing"

scan_fixture \
    'names=$(grep -oE "[A-Za-z_]+" "$f")' \
    'grep -cE "^## \[[0-9-]+\] ingest \|" "$f"' \
    'grep -F "a\|b" "$f"' \
    'sed -i.bak "s/x/y/" "$f" && rm -f "$f.bak"' \
    'sed -n "s/^x: //p" "$f"' \
    'date -u +%Y-%m-%dT%H:%M:%SZ' \
    'head -n 1 "$f"' \
    'ln -s "$src" "$dir"' \
    'i = match(s, /[^ ]/)' \
    'awk "{ sub(/\r$/, \"\") }" "$f"' \
    'git diff --stat "$f"' \
    'echo "${name}" "${#list[@]}" "${x:-default}"'
tc_assert_empty "$OUT" "portable forms draw no finding"

# ------------------------------------------------------ the real tree

# RC and ERR are read by the assertions in lib.sh.
# shellcheck disable=SC2034
case_real_tree() {
    local list f files=()
    list="$(scan_files "$TC_PLUGIN_ROOT")"
    tc_assert_line "Makefile" "$list" "the real tree: the scan reads the Makefile"
    tc_assert_line "hooks/pre-commit.sh" "$list" "the real tree: the scan reads the hooks"
    tc_assert_line "hooks/lib/sysml-toolchain.sh" "$list" "the real tree: the scan reads the hook libraries"
    tc_assert_line "tests/hooks/lib.sh" "$list" "the real tree: the scan reads the hook tests"
    tc_assert_not_grep "test-portability.sh" "$list" "the real tree: the scan skips its own fixtures"
    while IFS= read -r f; do
        files+=("$f")
    done <<EOF
${list}
EOF
    RC=0
    ERR=""
    OUT="$(cd "$TC_PLUGIN_ROOT" && portability_scan "${files[@]}")" || RC=$?
    tc_assert_rc 0 "the real tree: the scan runs"
    tc_assert_empty "$OUT" "the real tree: no GNU-only form outside a reviewed allow-list marker"
}

case_real_tree

if tc_summary "test-portability"; then
    exit 0
fi
exit 1
