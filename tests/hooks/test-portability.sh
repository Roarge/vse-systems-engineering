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
# of those words carries the banned letter, alone or in a group of
# letters and digits (-oP, -0r).
# The forms and what each one looks for:
#   grep -P                a -P option of grep (Perl regular expressions)
#   grep --perl-regexp     the long form of the same
#   \| in a basic regex    \| after grep or sed in the same pipeline
#                          segment (no | between them), when the last
#                          grep or sed before the \| carries no -E or
#                          -F (in an extended regular expression \| is
#                          a plain |)
#   env -C                 a -C option of env (run in a directory)
#   date -d, date --date   GNU date's date string
#   sed -i without a backup suffix
#                          a -i option of sed with no suffix attached,
#                          that is followed by a blank or by an empty
#                          quoted suffix (-i'' or -i""). -i.bak is the
#                          portable form
#   sed --in-place         the long option in any form, a suffix
#                          (--in-place=.bak) included, because BSD sed
#                          has no long options
#   \r in a sed call       \r anywhere in a sed call before the next |
#   readlink -f, stat -c, xargs -r, sort -V
#   head -n -N             a negative line count
#   ln -t, cp -t           a target directory named first
#   mapfile, readarray, declare -A (also typeset -A and local -A),
#   ${x,,}, ${x^^}         bash 4 features (the single , and ^ forms too)
#   awk match with three arguments
#                          match( with two commas before any parenthesis
#   <(...) as an argument  a process substitution handed to a command
#                          or a function as a file name. After any
#                          external command finishes, bash 3.2 closes
#                          the descriptor behind every such /dev/fd
#                          path still pending, so the receiver may find
#                          it closed. Every "<" followed by blanks and
#                          "<(" is taken out first, because input
#                          redirected from one (done < <(...), also
#                          3< <(...)) is opened by bash itself and safe.
#                          A process substitution starts a word, so
#                          only a "<(" after a blank counts, and a
#                          comparison such as i<(n-1) in embedded awk or
#                          in shell arithmetic does not
#   cd "$(dirname ...)" without > /dev/null
#                          a cd into a directory named by dirname whose
#                          standard output is kept, up to the next &&,
#                          || or ;. Under an exported CDPATH, cd prints
#                          the directory it found for a relative name,
#                          and a script that finds its own directory
#                          that way would capture the extra line. A cd
#                          after a CDPATH assignment (CDPATH='' cd) is
#                          left alone, and so is a cd into a name that
#                          dirname does not give, because the scan
#                          cannot tell a relative name from an absolute
#                          one
#   >(...) as an argument  the output form of the same, with the same
#                          hazard. Every ">" followed by blanks and
#                          ">(" is taken out first, because output
#                          redirected into one (exec > >(...), also
#                          2> >(...) and >> >(...)) is opened by bash
#                          itself and safe. Only a ">(" after a blank
#                          counts
#
# A finding is printed as <file>:<line>: <form>.
#
# Run: bash tests/hooks/test-portability.sh
#
# The fixtures are shell text that is written to files, not expanded.
# shellcheck disable=SC2016
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" > /dev/null && pwd)/lib.sh"

trap tc_teardown EXIT

# The scanner, in POSIX awk so it runs under mawk, gawk and the BWK awk
# of macOS. Each line is matched with a blank added at either end, so a
# command at the start of a line and an option at its end need no
# anchor inside a group, which not every awk reads the same way.
PORTABILITY_AWK='
# bre_found <line>: 1 when a grep or sed call on the line carries \| in
# a basic regular expression. A candidate runs from a grep or sed to
# the next \| with no | between them, so it stays within one pipeline
# segment. It is cut back to the last grep or sed inside it, which is
# the command the \| belongs to, and it is an extended or fixed-string
# pattern only when that command carries -E or -F.
function bre_found(line,    rest, seg) {
    rest = line
    while (match(rest, bre)) {
        seg = substr(rest, RSTART, RLENGTH)
        rest = substr(rest, RSTART + RLENGTH)
        while (match(substr(seg, 2), cmd))
            seg = substr(seg, RSTART + 1)
        if (seg !~ ere)
            return 1
    }
    return 0
}
# cd_found <line>: 1 when a cd into a directory named by dirname keeps
# its standard output. A cd after a CDPATH assignment (CDPATH= cd ...)
# is taken out first. For each cd left, the text up to the next &&, ||
# or ; must send its standard output to /dev/null (> or 1>, and &>).
function cd_found(line,    rest, seg) {
    rest = line
    gsub(/CDPATH=[^ \t]*[ \t]+cd[ \t]/, " ", rest)
    while (match(rest, cdd)) {
        seg = substr(rest, RSTART + RLENGTH)
        rest = seg
        if (match(seg, /&&|[|][|]|;/))
            seg = substr(seg, 1, RSTART - 1)
        if (seg !~ /[^0-9]1?>[ \t]*[/]dev[/]null/)
            return 1
    }
    return 0
}
BEGIN {
    b = "[^A-Za-z0-9_.-]"
    o = "[ \t]+(-[^ \t]*[ \t]+)*"
    g = "-[A-Za-z0-9]*"
    n = 0
    n++; form[n] = "grep -P"; re[n] = b "grep" o g "P"
    n++; form[n] = "grep --perl-regexp"; re[n] = b "grep" o "--perl-regexp"
    n++; form[n] = "env -C"; re[n] = b "env" o g "C"
    n++; form[n] = "date -d"; re[n] = b "date" o g "d"
    n++; form[n] = "date --date"; re[n] = b "date" o "--date"
    n++; form[n] = "sed -i without a backup suffix"
    re[n] = b "sed" o g "i([\"\047][\"\047])?[ \t]"
    n++; form[n] = "sed --in-place"; re[n] = b "sed" o "--in-place"
    n++; form[n] = "\\r in a sed call"; re[n] = b "sed[ \t][^|]*\\\\r"
    n++; form[n] = "readlink -f"; re[n] = b "readlink" o g "f"
    n++; form[n] = "stat -c"; re[n] = b "stat" o g "c"
    n++; form[n] = "xargs -r"; re[n] = b "xargs" o g "r"
    n++; form[n] = "sort -V"; re[n] = b "sort" o g "V"
    n++; form[n] = "head -n -N"; re[n] = b "head" o "-n[ \t]*-[0-9]"
    n++; form[n] = "ln -t"; re[n] = b "ln" o g "t"
    n++; form[n] = "cp -t"; re[n] = b "cp" o g "t"
    n++; form[n] = "mapfile"; re[n] = b "mapfile[ \t]"
    n++; form[n] = "readarray"; re[n] = b "readarray[ \t]"
    n++; form[n] = "declare -A"; re[n] = b "(declare|typeset|local)" o g "A"
    n++; form[n] = "${x,,}"; re[n] = "[$][{][A-Za-z_][A-Za-z0-9_]*,"
    n++; form[n] = "${x^^}"; re[n] = "[$][{][A-Za-z_][A-Za-z0-9_]*\\^"
    n++; form[n] = "awk match with three arguments"; re[n] = b "match[ \t]*[(][^()]*,[^()]*,"
    cmd = b "(grep|sed)[ \t]"
    bre = cmd "[^|]*\\\\[|]"
    ere = "^" b "(grep|sed)" o g "[EF]"
    cdd = b "cd[ \t]+(--[ \t]+)?\"?[$][(]dirname[ \t]"
}
/^[ \t]*#/ { next }
/#[ \t]*portability: ok[ \t]+[^ \t]/ { next }
{
    line = " " $0 " "
    for (i = 1; i <= n; i++)
        if (line ~ re[i])
            printf "%s:%d: %s\n", FILENAME, FNR, form[i]
    if (bre_found(line))
        printf "%s:%d: %s\n", FILENAME, FNR, "\\| in a basic regex"
    if (cd_found(line))
        printf "%s:%d: %s\n", FILENAME, FNR, "cd \"$(dirname ...)\" without > /dev/null"
    arg = line
    gsub(/<[ \t]*<[(]/, "", arg)
    if (arg ~ /[ \t]<[(]/)
        printf "%s:%d: %s\n", FILENAME, FNR, "<(...) as an argument"
    arg = line
    gsub(/>[ \t]*>[(]/, "", arg)
    if (arg ~ /[ \t]>[(]/)
        printf "%s:%d: %s\n", FILENAME, FNR, ">(...) as an argument"
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
case_form '\| in a basic regex' 'grep -E "x" "$f" | grep "a\|b"'
case_form '\| in a basic regex' 'grep -E "a\|b" "$f" | grep "c\|d"'
case_form '\| in a basic regex' 'grep -E "x" "$f" && sed "s/a\|b/c/" "$g"'
case_form 'env -C' 'env -C "$dir" make'
case_form 'date -d' 'date -u -d "14 days ago" +%s'
case_form 'date --date' 'date --date="14 days ago" +%s'
case_form 'sed -i without a backup suffix' 'sed -i "s/x/y/" "$f"'
case_form 'sed -i without a backup suffix' "sed -i'' \"s/x/y/\" \"\$f\""
case_form 'sed -i without a backup suffix' 'sed -i"" "s/x/y/" "$f"'
case_form 'sed -i without a backup suffix' 'sed -i "" "s/x/y/" "$f"'
case_form 'sed --in-place' 'sed --in-place "s/x/y/" "$f"'
case_form 'sed --in-place' 'sed --in-place=.bak "s/x/y/" "$f"'
case_form 'sed --in-place' 'sed -E --in-place "s/x/y/" "$f"'
case_form '\r in a sed call' 'printf "a\n" | sed "s/$/\r/" > "$f"'
case_form 'readlink -f' 'dir=$(readlink -f "$0")'
case_form 'stat -c' 'size=$(stat -c %s "$f")'
case_form 'xargs -r' 'find . -name "*.tmp" | xargs -r rm'
case_form 'xargs -r' 'find . -name "*.tmp" -print0 | xargs -0r rm'
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
case_form '<(...) as an argument' 'jq --slurpfile payload <(printf "%s" "$p") "$prog"'
case_form '<(...) as an argument' 'vse_tf_post_image <(printf "%s" "$p") "$1"'
case_form '<(...) as an argument' 'diff <(sort "$a") <(sort "$b")'
case_form '<(...) as an argument' 'awk -f "$prog" <(scan < "$pre")'
case_form '<(...) as an argument' "    ' <(vse_tf_story_blocks < \"\$pre\") <(vse_tf_story_blocks < \"\$post\")"
case_form '<(...) as an argument' 'paste < <(cut -f 1 "$f") <(cut -f 2 "$f")'
case_form '>(...) as an argument' 'tee >(sha256sum > "$f.sum") < "$f" > /dev/null'
case_form '>(...) as an argument' 'vse_write_image >(cat > "$out") "$1"'
case_form '>(...) as an argument' 'diff "$a" "$b" 2> >(grep -v x >&2) >(cat > "$out")'
case_form 'cd "$(dirname ...)" without > /dev/null' '. "$(cd "$(dirname "$0")" && pwd)/lib.sh"'
case_form 'cd "$(dirname ...)" without > /dev/null' 'LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib"'
case_form 'cd "$(dirname ...)" without > /dev/null' 'echo "$(cd "$(dirname "$0")/.." && pwd -P)/methodology/"'
case_form 'cd "$(dirname ...)" without > /dev/null' 'dir="$(cd -- "$(dirname "$f")" 2> /dev/null && pwd)"'

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
    'printf "%s\n" "$x" | grep -E "a\|b"' \
    'sed -E "s/a\|b//" "$f" | grep -c x' \
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

# bash opens a process substitution it redirects input from, so that
# form is safe under bash 3.2, with or without blanks or a descriptor
# number before it.
scan_fixture \
    'done < <(git diff --cached --name-only --diff-filter=ACM)' \
    'done 2> /dev/null < <(find . -name "*.sysml" -print0)' \
    'exec 3< <(sort "$f")' \
    'body="$(< "$f")"' \
    'cat <<EOF > "$f"'
tc_assert_empty "$OUT" "input redirected from a process substitution draws no finding"

# Output redirected into a process substitution is opened by bash too.
scan_fixture \
    'exec > >(tee "$log")' \
    'make all 2> >(grep -v warning >&2)' \
    'printf "%s\n" "$x" >> >(cat >> "$log")'
tc_assert_empty "$OUT" "output redirected into a process substitution draws no finding"

# A cd whose output is discarded prints nothing under CDPATH, and with
# CDPATH empty for the call it looks nothing up. A cd into a directory
# not named by dirname is left alone: the scan cannot tell a relative
# name from an absolute one, and the tests change into absolute
# scratch paths.
scan_fixture \
    'HERE="$(cd "$(dirname "$0")" > /dev/null && pwd -P)"' \
    'HERE="$(cd -- "$(dirname -- "$0")" >/dev/null 2>&1 && pwd)"' \
    'ENG="$(CDPATH='"''"' cd -- "$(dirname -- "$cfg")" && pwd -P)"' \
    'top="$(cd "$REPO" && pwd -P)"'
tc_assert_empty "$OUT" "a cd that prints nothing under CDPATH draws no finding"

# A comparison with a parenthesised operand, in embedded awk or in shell
# arithmetic, is not a process substitution, which starts a word.
scan_fixture \
    'awk "{ for (i = 1; i<(n-1); i++) print i }" "$f"' \
    'last=$((i<(n-1) ? i : n - 1))' \
    'big=$((a>(b-1)))'
tc_assert_empty "$OUT" "a comparison with a parenthesised operand draws no finding"

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
