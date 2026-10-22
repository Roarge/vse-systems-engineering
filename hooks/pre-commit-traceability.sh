#!/usr/bin/env bash
# Project-side traceability gate, delegated by the pre-commit hook.
#
# Per methodology/iso-29110-hooks-guide.md §4.1 concern 4. Checks the
# requirements and verification cases this commit actually touches, and
# reports the ones that carry no verify link anywhere in the model.
#
# The gate is deliberately scoped to touched content. A commit that
# edits a file whose pre-existing requirements were never verified is
# not the commit that introduced the gap, and stopping it teaches the
# engineer to reach for a bypass. /vse-trace reports the whole model.
#
# The file set follows pre-commit.sh. With VSE_PRECOMMIT_RANGE unset
# the gate reads the staged set. CI sets it to a git range (such as
# origin/main...HEAD), and the gate reads what that range adds, or to
# "all", and the gate reads every tracked file whole, as the index
# holds it. A textconv driver (a diff filter that rewrites a file for
# display) never changes what the gate reads.
#
# A criterion nested inside a story's acceptance (requirement <name>
# { ... } inside requirement :>> acceptance) is a member of its story,
# not a requirement of its own, so it never enters the touched set. A
# verify clause reaches a requirement through any chain of "::" and "."
# segments, so verify <story>.acceptance.<name> counts for the story
# (methodology §11.3.3).
#
# The disposition comes from the precommit_traceability gate, per
# methodology §0.10.4: block reports and stops the commit, warn reports
# and lets it through, info prints one summary line, off skips.
#
# Install as <project>/.githooks/pre-commit-traceability.sh.
set -euo pipefail

# Load the shared profile helpers. The project-side copy wins, the
# plugin copy is the fallback for a partial install.
HOOK_DIR="$(dirname "$0")"
ISO_PROFILE_LIB=""
if [ -r "${HOOK_DIR}/lib/iso-profile.sh" ]; then
    ISO_PROFILE_LIB="${HOOK_DIR}/lib/iso-profile.sh"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -r "${CLAUDE_PLUGIN_ROOT}/hooks/lib/iso-profile.sh" ]; then
    ISO_PROFILE_LIB="${CLAUDE_PLUGIN_ROOT}/hooks/lib/iso-profile.sh"
fi

if [ -n "$ISO_PROFILE_LIB" ]; then
    # shellcheck source=/dev/null
    . "$ISO_PROFILE_LIB"
else
    # An install without the library reports rather than blocks, which
    # is the standard-profile disposition for this gate.
    iso_gate_disposition() { printf 'warn\n'; }
fi

DISPOSITION="$(iso_gate_disposition precommit_traceability)"
if [ "$DISPOSITION" = "off" ]; then
    exit 0
fi

RANGE="${VSE_PRECOMMIT_RANGE:-}"

# The file set, as paths relative to the repository root, one per line,
# read the way pre-commit.sh reads it. git writes NUL-delimited names,
# so a space in a name arrives intact.
# Usage: file_set <git diff filter>
file_set() {
    if [ -z "$RANGE" ]; then
        git diff --cached --name-only --diff-filter="$1" -z | tr '\0' '\n'
    elif [ "$RANGE" = "all" ]; then
        git ls-files -z | tr '\0' '\n'
    else
        git diff --name-only --diff-filter="$1" -z "$RANGE" | tr '\0' '\n'
    fi
}

if ! CHANGED="$(file_set ACM)"; then
    if [ -n "$RANGE" ]; then
        echo "pre-commit-traceability: Cannot list the files changed by the range '${RANGE}'. Set VSE_PRECOMMIT_RANGE to a range git can read, such as origin/main...HEAD, or to all." >&2
    else
        echo "pre-commit-traceability: Cannot list the staged files." >&2
    fi
    exit 1
fi

# Drop every path with a library/ directory segment, the shipped
# model/library/vse-library.sysml above all. The library carries the
# methodology's own definitions (UserStory, Feature, Epic), which are
# definitions the project's stories are typed by, not requirements the
# project has to verify. Leaving them in would report the library as a
# wall of gaps on the first commit that stages it.
SYSML_FILES=$(printf '%s\n' "$CHANGED" | grep '\.sysml$' | grep -Ev '(^|/)library/' || true)

if [ -z "$SYSML_FILES" ]; then
    exit 0
fi

# Detect the VSE engineering root: prefer engineering/ if present
# (brownfield layout, where work products live under engineering/ to
# keep an existing host project's root clean), else . (greenfield). The
# repo-wide search below uses 'find .', which covers both layouts. The
# detected root is reported so the engineer can confirm the layout.
if [ -d "engineering/model" ] || [ -d "engineering/models" ] || [ -f "engineering/.iso-config.yaml" ] || [ -f "engineering/syside.toml" ]; then
    ENG_ROOT="engineering"
else
    ENG_ROOT="."
fi

# added_model_text <whole>: read one file's diff on stdin and print the
# model text of each added line. The diff carries the whole new file as
# context, so each added line is read in its place in the file: a line
# added inside an existing doc comment or acceptance body is known to
# sit there. With <whole> set to 1, stdin is the file itself and every
# line counts as added.
#
# The printed text keeps each column but blanks string contents,
# comments, KerML notes and doc bodies, so a story written inside a
# comment is documentation and does not enter the touched set. It also
# blanks the body of a story's acceptance (requirement :>> acceptance
# { ... }, or requirement acceptance { ... }), because the criteria
# nested there are members of the story. Braces in blanked comments and
# strings are not counted. POSIX awk only, per hooks/README.md.
#
# Mask modes: 0 model text, 1 inside a "string", 2 inside a /* */
# comment or a //* */ note. A // line comment ends the line. The note
# opener //* is checked before //, because a note may span lines.
#
# Acceptance states: 1 after "requirement", 2 after "requirement :>>",
# 3 after "acceptance", waiting for "{" (the body) or ";" (no body).
added_model_text() {
    LC_ALL=C awk -v whole="$1" '
        function mask(line,    n, i, c, d, m) {
            n = length(line)
            m = ""
            i = 1
            while (i <= n) {
                c = substr(line, i, 1)
                if (mode == 1) {
                    if (c == "\\") {
                        m = m "  "
                        i += 2
                        continue
                    }
                    if (c == "\"")
                        mode = 0
                    else
                        c = " "
                } else if (mode == 2) {
                    if (c == "*" && substr(line, i + 1, 1) == "/") {
                        mode = 0
                        m = m "  "
                        i += 2
                        continue
                    }
                    c = " "
                } else if (c == "\"") {
                    mode = 1
                } else if (c == "/") {
                    d = substr(line, i + 1, 1)
                    if (d == "/" && substr(line, i + 2, 1) == "*") {
                        mode = 2
                        m = m "   "
                        i += 3
                        continue
                    }
                    if (d == "/")
                        break
                    if (d == "*") {
                        mode = 2
                        m = m "  "
                        i += 2
                        continue
                    }
                }
                m = m c
                i++
            }
            return m
        }
        function feed(tok) {
            if (tok == " " || tok == "\t" || tok == "\r")
                return
            if (st == 1) {
                if (tok == ":>>") {
                    st = 2
                    return
                }
                if (tok == "acceptance") {
                    st = 3
                    return
                }
                st = 0
            } else if (st == 2) {
                if (tok == "acceptance") {
                    st = 3
                    return
                }
                st = 0
            } else if (st == 3) {
                if (tok == "{") {
                    depth++
                    if (!inside) {
                        inside = 1
                        body = depth
                    }
                    st = 0
                    return
                }
                if (tok != ";" && tok != "}" && tok != "requirement")
                    return
                st = 0
            }
            if (tok == "requirement") {
                st = 1
            } else if (tok == "{") {
                depth++
            } else if (tok == "}") {
                if (inside && depth == body)
                    inside = 0
                depth--
            }
        }
        function scan(m,    n, i, len, tok, hidden, out) {
            n = length(m)
            out = ""
            i = 1
            while (i <= n) {
                if (substr(m, i, 1) ~ /[A-Za-z_]/) {
                    match(substr(m, i), /^[A-Za-z_][A-Za-z0-9_]*/)
                    len = RLENGTH
                } else if (substr(m, i, 3) == ":>>") {
                    len = 3
                } else {
                    len = 1
                }
                tok = substr(m, i, len)
                hidden = inside
                feed(tok)
                if (hidden || inside)
                    out = out sprintf("%" len "s", "")
                else
                    out = out tok
                i += len
            }
            return out
        }
        BEGIN { started = whole }
        !started {
            if (substr($0, 1, 2) == "@@")
                started = 1
            next
        }
        {
            if (whole) {
                mark = "+"
                text = $0
            } else if (substr($0, 1, 2) == "@@") {
                next
            } else {
                mark = substr($0, 1, 1)
                text = substr($0, 2)
            }
            # "-" lines are the old side and "\" lines are notes.
            if (mark != "+" && mark != " ")
                next
            out = scan(mask(text))
            if (mark == "+")
                print out
        }
    '
}

# Context wide enough to hold any model file whole (a million lines),
# so the diff of one file is a single hunk with every line of the file.
WHOLE_FILE=1000000

# added_text <file>: the model text of the lines this change adds to
# <file>. In "all" mode every line of the file counts as added, and the
# file is read from the index, which is what git ls-files listed, so a
# tracked file missing from the working tree is still read. git ls-files
# lists paths relative to the working directory, so the index path is
# ":./<file>", which git reads from there too, and the gate works from
# a subdirectory.
added_text() {
    local file="$1"
    if [ -z "$RANGE" ]; then
        git diff --cached --no-color --no-ext-diff --no-textconv --unified="$WHOLE_FILE" -- "$file" \
            | added_model_text 0
    elif [ "$RANGE" = "all" ]; then
        git show ":./$file" | added_model_text 1
    else
        git diff --no-color --no-ext-diff --no-textconv --unified="$WHOLE_FILE" "$RANGE" -- "$file" \
            | added_model_text 0
    fi
}

# Names this change touches, as tab-separated "<file>\t<name>" records.
# For a modified file only the names on added lines count, which is
# what keeps the gate off pre-existing content. For a newly added file
# every line is added, so every name in it counts.
#
# Usage: collect_touched <pattern> <extract>. grep -oE prints each
# declaration that matches the extended regular expression <pattern>,
# and the sed -E substitution <extract> cuts the name out of it. Both
# are POSIX forms, so BSD grep and sed (macOS) read them as GNU does.
collect_touched() {
    local pattern="$1" extract="$2" file names name
    while IFS= read -r file; do
        [ -n "$file" ] || continue
        names=$(added_text "$file" | grep -oE "$pattern" | sed -E "$extract" || true)
        for name in $names; do
            printf '%s\t%s\n' "$file" "$name"
        done
    done <<< "$SYSML_FILES"
}

# A requirement declaration is "requirement", an optional "def", an
# optional short name in angle brackets, then the name, followed by ":"
# or ":>" and a type. The match runs on to the first letter of the
# type, so the substitution keeps only the name.
TOUCHED_REQS=$(collect_touched \
    'requirement[[:space:]]+(def[[:space:]]+)?(<[^>]*>[[:space:]]*)?[A-Za-z_][A-Za-z0-9_]*[[:space:]]*:>?[[:space:]]*[A-Za-z_]' \
    's/^requirement[[:space:]]+(def[[:space:]]+)?(<[^>]*>[[:space:]]*)?([A-Za-z_][A-Za-z0-9_]*).*$/\3/' \
    | sort -u)
TOUCHED_VERS=$(collect_touched \
    'verification[[:space:]]+def[[:space:]]+[A-Za-z0-9_]+' \
    's/^verification[[:space:]]+def[[:space:]]+//' \
    | sort -u)

# Does any .sysml file in the repository carry a verify link to $1?
# The target may follow any chain of "::" and "." segments, such as a
# package and the requirement groups the story sits in, and may run on
# past it, as in verify <story>.acceptance.<name>. The name must end
# there, at a character that cannot continue a name or at the end of
# the line, so verify US_9_XY is not a link to US_9_X.
has_verify_link() {
    local req="$1" sysml
    while IFS= read -r -d '' sysml; do
        if grep -qE "verify[[:space:]]+(requirement[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*(::|[.]))*${req}([^A-Za-z0-9_]|\$)" "$sysml" 2>/dev/null; then
            return 0
        fi
    done < <(find . -name '*.sysml' -not -path './.git/*' -print0 2>/dev/null)
    return 1
}

FINDINGS=""
GAPS=0
CHECKED=0

while IFS=$'\t' read -r file req; do
    [ -z "${req:-}" ] && continue
    CHECKED=$((CHECKED + 1))
    if ! has_verify_link "$req"; then
        FINDINGS="${FINDINGS}  ${file}: requirement '${req}' has no verification case"$'\n'
        GAPS=$((GAPS + 1))
    fi
done <<< "$TOUCHED_REQS"

while IFS=$'\t' read -r file ver; do
    [ -z "${ver:-}" ] && continue
    CHECKED=$((CHECKED + 1))
    # "verify requirement X" starts with a letter after "verify" too, so
    # this one pattern covers both forms of the clause.
    if ! grep -qE 'verify[[:space:]]+[A-Za-z_]' "$file" 2>/dev/null; then
        FINDINGS="${FINDINGS}  ${file}: verification case '${ver}' has no verify link"$'\n'
        GAPS=$((GAPS + 1))
    fi
done <<< "$TOUCHED_VERS"

if [ "$GAPS" -eq 0 ]; then
    if [ "$DISPOSITION" != "info" ] && [ "$CHECKED" -gt 0 ]; then
        echo "pre-commit-traceability: ${CHECKED} touched element(s) checked, no trace gaps (engineering root: ${ENG_ROOT})."
    fi
    exit 0
fi

if [ "$DISPOSITION" = "info" ]; then
    echo "pre-commit-traceability: ${GAPS} trace gap(s) on touched requirements. Run /vse-trace for the full-repo report."
    exit 0
fi

if [ "$DISPOSITION" = "block" ]; then
    echo "pre-commit-traceability: ${GAPS} trace gap(s) on touched requirements (engineering root: ${ENG_ROOT})."
else
    echo "pre-commit-traceability: warning: ${GAPS} trace gap(s) on touched requirements (engineering root: ${ENG_ROOT})."
fi
printf '%s' "$FINDINGS"
echo "  Run /vse-trace for the full-repo traceability report."

if [ "$DISPOSITION" = "block" ]; then
    # A check in CI (range mode) cannot be bypassed from a workstation
    # (§0.10.6), so there it gives no rationale advice.
    if [ -z "$RANGE" ]; then
        echo "  To proceed anyway, record a one-line rationale per methodology §0.10.6."
    fi
    exit 1
fi

exit 0
