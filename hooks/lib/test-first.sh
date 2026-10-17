#!/usr/bin/env bash
# Shared test-first and story-scanning helpers for the lifecycle hooks
# (PreToolUse, PostToolUse, Stop, SubagentStop and SessionStart, and the
# project locator for UserPromptSubmit, PreCompact and Notification) and
# the project-side pre-commit gate (methodology §11.9).
#
# Gherkin first (behaviour described as scenarios before the model
# changes) needs three answers: which stories an edit adds or changes,
# what the file looks like after the edit, and whether a story's
# .feature file carries its tag. Test first (a failing test before the
# code) needs three more: whether a path is test, code or neither,
# whether test evidence exists, and which test tooling a project has.
#
# Functions (each returns 0 on success, and failures use an explicit
# return, so errexit is not load-bearing inside them):
#
#   vse_tf_canonical <path>            absolute path, directories resolved
#   vse_tf_find_config <abs-path>      nearest .iso-config.yaml
#   vse_tf_locate_project <path>       the project for a lifecycle hook:
#                                      sets VSE_TF_CONFIG, VSE_TF_ENG_ROOT
#                                      and VSE_TF_TOP, 1 when none
#   vse_tf_locate_workdir <dir>        the same, for a hook that knows
#                                      only its working directory
#   vse_tf_story_blocks                stdin SysML, stdout ID<TAB>block
#   vse_tf_touched_stories <pre> <post>  IDs new or changed in post
#   vse_tf_feature_has_tag <file> <ID>   0 when tagged @<ID>
#   vse_tf_post_image <payload> <file>   file content after the edit
#   vse_tf_disk_image <file>           file content before the edit
#   vse_tf_classify <relpath>          never, test, code or other
#   vse_tf_evidence <toplevel>         evidence: <path>, or reason: ...
#   vse_tf_refactor_branch [<toplevel> [<branch>]]  0 on a refactor branch
#   vse_tf_detect <dir>                one key per detected test tool
#   vse_tf_applies                     true, false or nothing
#
# In-shell classifier, a supported interface for loops over many paths
# (hooks/pre-commit.sh, and the plugin's own
# tests/hooks/check-test-first.sh). vse_tf_classify costs a subshell
# and a git call per path, and these two do not:
#
#   _vse_tf_load                       read the globs into globals, once
#   _vse_tf_kind <relpath>             set _VSE_TF_KIND to never, test,
#                                      code or other
#
# Call _vse_tf_load once before the loop, then _vse_tf_kind for each
# path. _VSE_TF_CODE_GLOBS is empty when the record names no
# code_paths. A change to these names or globals is a change to both
# callers.
#
# Configuration comes from iso-profile.sh, which shall be sourced
# first: ISO_CONFIG_FILE names the file, iso_section_scalar and
# iso_section_list read the test_first record, and iso_list reads
# protected_branches. Sourcing this file does no other work. A caller
# that found the configuration by walking up from an edited file
# exports VSE_ISO_CONFIG before sourcing iso-profile.sh, so both
# libraries read the same file.
#
# File content never passes through awk -v or the environment. Text
# goes in on stdin or as a file, so its size and bytes are kept.
#
# Portability: bash 3.2 (no mapfile, no associative arrays) and POSIX
# awk (mawk is the Ubuntu default: no match(s, r, arr), no {n} counts,
# so [ \t\r\n] stands in for the POSIX character classes). Glob lists
# from the configuration are walked with while-read loops under set -f,
# never with an unquoted for, so no pattern is expanded against the
# file system.
#
# Install as <project>/.githooks/lib/test-first.sh beside
# iso-profile.sh. The lifecycle hooks source the plugin's own copy.
set -euo pipefail

if ! command -v iso_section_scalar >/dev/null 2>&1 \
    || ! command -v iso_section_list >/dev/null 2>&1 \
    || ! command -v iso_list >/dev/null 2>&1; then
    echo "[test-first] Source iso-profile.sh before test-first.sh." >&2
    # The exit is reached only when the file is run instead of sourced.
    # shellcheck disable=SC2317
    return 1 2>/dev/null || exit 1
fi

# ------------------------------------------------------------- paths

# Print the absolute form of <path> with every symbolic link among its
# existing directories resolved. The path need not exist: the nearest
# existing directory is resolved with pwd -P and the rest is put back
# as written. So a final component that is not a directory is kept as
# it is, and a final symbolic link to a file is not resolved. A
# relative path is taken from the working directory.
vse_tf_canonical() {
    local path="$1" dir base tail="" real
    case "$path" in
        /*) : ;;
        *) path="$(pwd -P)/${path}" ;;
    esac
    dir="$path"
    while [ ! -d "$dir" ]; do
        base="${dir##*/}"
        dir="${dir%/*}"
        [ -n "$dir" ] || dir=/
        case "$base" in
            ""|.) : ;;
            *) tail="/${base}${tail}" ;;
        esac
    done
    real="$(CDPATH='' cd -- "$dir" 2>/dev/null && pwd -P)" || return 1
    if [ "$real" = / ]; then
        printf '%s\n' "${tail:-/}"
    else
        printf '%s%s\n' "$real" "$tail"
    fi
    return 0
}

# Print the .iso-config.yaml that governs <abs-path>: the first one
# found walking up from the path's directory to the git top level, or
# to / outside git. At the top level, engineering/.iso-config.yaml (the
# brownfield layout) is tried after .iso-config.yaml. Prints nothing
# when there is none, which is contributor mode inside the plugin
# repository.
vse_tf_find_config() {
    local path dir probe top
    path="$(vse_tf_canonical "$1")" || return 0
    dir="${path%/*}"
    [ -n "$dir" ] || dir=/
    probe="$dir"
    while [ ! -d "$probe" ]; do
        probe="${probe%/*}"
        [ -n "$probe" ] || probe=/
    done
    top="$(git -C "$probe" rev-parse --show-toplevel 2>/dev/null)" || top=""
    while :; do
        if [ -f "${dir%/}/.iso-config.yaml" ]; then
            printf '%s\n' "${dir%/}/.iso-config.yaml"
            return 0
        fi
        if [ -n "$top" ] && [ "$dir" = "$top" ]; then
            if [ -f "${top%/}/engineering/.iso-config.yaml" ]; then
                printf '%s\n' "${top%/}/engineering/.iso-config.yaml"
            fi
            return 0
        fi
        [ "$dir" != / ] || return 0
        dir="${dir%/*}"
        [ -n "$dir" ] || dir=/
    done
}

# Locate the VSE project that governs <path>, for the lifecycle hooks.
# A project is located through its .iso-config.yaml, which is the
# canonical project marker. <path> is a file, which need not exist yet,
# or a directory (a working directory), which is searched from itself
# rather than from its parent. On success the function sets, in the
# calling shell, so it is called directly and never inside $(...):
#
#   VSE_TF_CONFIG     the .iso-config.yaml (vse_tf_find_config)
#   VSE_TF_ENG_ROOT   its directory, the engineering root
#   VSE_TF_TOP        the git top level, or empty outside git
#
# and returns 0. It returns 1 with the three variables empty when no
# configuration governs the path, and in contributor mode (the plugin
# repository, recognised by wiki/CLAUDE.md at the git top level) when
# the configuration is not under demo/, so the shipped template under
# templates/ is never taken for a project. File tests up the directory
# tree come first, so a path with no configuration above it costs no
# git call.
# The three variables are read by the caller.
# shellcheck disable=SC2034
vse_tf_locate_project() {
    local path dir config top
    VSE_TF_CONFIG=""
    VSE_TF_ENG_ROOT=""
    VSE_TF_TOP=""
    path="$(vse_tf_canonical "$1")" || return 1
    if [ -d "$path" ]; then
        dir="$path"
        # vse_tf_find_config walks from the directory of the path it
        # is given, so a name inside the directory starts the walk there.
        path="${path%/}/.vse-locate"
    else
        dir="${path%/*}"
        [ -n "$dir" ] || dir=/
    fi
    while :; do
        if [ -f "${dir%/}/.iso-config.yaml" ] || [ -f "${dir%/}/engineering/.iso-config.yaml" ]; then
            break
        fi
        [ "$dir" != / ] || return 1
        dir="${dir%/*}"
        [ -n "$dir" ] || dir=/
    done
    config="$(vse_tf_find_config "$path")"
    [ -n "$config" ] || return 1
    top="$(git -C "${config%/*}" rev-parse --show-toplevel 2>/dev/null)" || top=""
    if [ -n "$top" ] && [ -f "${top%/}/wiki/CLAUDE.md" ]; then
        case "$config" in
            "${top%/}/demo/"*) : ;;
            *) return 1 ;;
        esac
    fi
    VSE_TF_CONFIG="$config"
    VSE_TF_ENG_ROOT="${config%/*}"
    [ -n "$VSE_TF_ENG_ROOT" ] || VSE_TF_ENG_ROOT=/
    VSE_TF_TOP="$top"
    return 0
}

# Locate the VSE project for a lifecycle hook that knows only its
# working directory <dir> (SessionStart, UserPromptSubmit, PreCompact
# and Notification). vse_tf_locate_project runs from <dir> first, then
# from <dir>/engineering when that folder exists, so a brownfield
# project below its git top level is found from its own root. Sets the
# three variables and returns as vse_tf_locate_project does, so it is
# called directly and never inside $(...).
vse_tf_locate_workdir() {
    vse_tf_locate_project "$1" && return 0
    [ -d "${1%/}/engineering" ] || return 1
    vse_tf_locate_project "${1%/}/engineering"
}

# ------------------------------------------------------ story scanner

# The scanner reads the text line by line and builds a masked copy of
# each line, column for column, in which string contents, comments,
# KerML notes and doc bodies are blanked. Declarations and braces are
# matched in the masked copy, and the block is cut from the raw lines,
# so a change inside a string or a doc body still changes the block.
#
# Mask modes: 0 model text, 1 inside a "string", 2 inside a /* */
# comment or a //* */ note. A // line comment ends the masked line. The
# note opener //* is checked before //, because a note may span lines.
#
# Declaration states: 1 after "requirement", 2 after the ID, 3 after
# ":", 4 after "VSE_Library", 5 after "VSE_Library::", 6 after the
# UserStory type, waiting for "{" (a block) or ";" (no body). In states
# 1 to 5 any unexpected token resets the state. State 6 passes over
# other tokens, such as a multiplicity or a reference subsetting
# ("::>", read as one token before "::" is tried), and ends at a "}" or
# at "::" straight after the type (a type nested under UserStory). A new
# "requirement" keyword always starts a new declaration, so a keyword
# left dangling by a partial edit does not hide the story after it.
# shellcheck disable=SC2016
_VSE_TF_SCAN_AWK='
function mask(line, ln,    n, i, c, d, m) {
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
    tokens(m, ln)
}
function tokens(m, ln,    n, i, j, c) {
    n = length(m)
    i = 1
    while (i <= n) {
        c = substr(m, i, 1)
        if (c == " " || c == "\t" || c == "\r") {
            i++
        } else if (c ~ /[A-Za-z_]/) {
            match(substr(m, i), /^[A-Za-z_][A-Za-z0-9_]*/)
            feed(substr(m, i, RLENGTH), ln, i)
            i += RLENGTH
        } else if (c == ":" && substr(m, i + 1, 2) == ":>") {
            feed("::>", ln, i)
            i += 3
        } else if (c == ":" && substr(m, i + 1, 1) == ":") {
            feed("::", ln, i)
            i += 2
        } else if (c == ":" && substr(m, i + 1, 1) == ">") {
            j = i + 1
            while (substr(m, j, 1) == ">")
                j++
            feed(":>", ln, i)
            i = j
        } else {
            feed(c, ln, i)
            i++
        }
    }
}
function feed(tok, ln, col) {
    if (st == 1) {
        if (tok ~ /^[A-Za-z_]/ && tok != "requirement") {
            cid = tok
            st = 2
            return
        }
        st = 0
    } else if (st == 2) {
        if (tok == ":") {
            st = 3
            return
        }
        st = 0
    } else if (st == 3 || st == 5) {
        if (tok == "UserStory") {
            st = 6
            fresh = 1
            return
        }
        if (st == 3 && tok == "VSE_Library") {
            st = 4
            return
        }
        st = 0
    } else if (st == 4) {
        if (tok == "::") {
            st = 5
            return
        }
        st = 0
    } else if (st == 6) {
        if (fresh && tok == "::") {
            st = 0
            return
        }
        fresh = 0
        if (tok == "{") {
            depth++
            count++
            sid[count] = cid
            sl[count] = dl
            sc[count] = dc
            el[count] = 0
            sp++
            stack[sp] = count
            sdepth[sp] = depth
            st = 0
            return
        }
        if (tok == ";") {
            count++
            sid[count] = cid
            sl[count] = dl
            sc[count] = dc
            el[count] = ln
            ec[count] = col
            st = 0
            return
        }
        if (tok != "}" && tok != "requirement")
            return
        st = 0
    }
    if (tok == "requirement") {
        st = 1
        dl = ln
        dc = col
    } else if (tok == "{") {
        depth++
    } else if (tok == "}") {
        if (sp > 0 && sdepth[sp] == depth) {
            el[stack[sp]] = ln
            ec[stack[sp]] = col
            sp--
        }
        depth--
    }
}
{
    raw[NR] = $0
    mask($0, NR)
}
END {
    for (k = 1; k <= count; k++) {
        if (el[k] == 0) {
            el[k] = NR
            ec[k] = length(raw[NR])
        }
        if (sl[k] == el[k]) {
            text = substr(raw[sl[k]], sc[k], ec[k] - sc[k] + 1)
        } else {
            text = substr(raw[sl[k]], sc[k])
            for (j = sl[k] + 1; j < el[k]; j++)
                text = text "\n" raw[j]
            text = text "\n" substr(raw[el[k]], 1, ec[k])
        }
        gsub(/[ \t\r\n]+/, " ", text)
        sub(/ $/, "", text)
        print sid[k] "\t" text
    }
}
'

# Read SysML text on stdin and print one line per story, in declaration
# order: the ID, a tab, and the block text. A story is a usage
# declared as `requirement <ID> : UserStory` or `: VSE_Library::UserStory`.
# A definition (`requirement def <ID> :> UserStory`) and a subsetting
# usage (`:>`) are not stories. The block runs from "requirement"
# through the matching closing brace, or through ";" for a story with no
# body, or to the end of the text when the brace is missing, with every
# run of whitespace collapsed to one space. Braces inside strings,
# comments, notes and doc bodies are ignored, and no declaration inside
# them counts.
vse_tf_story_blocks() {
    LC_ALL=C awk "$_VSE_TF_SCAN_AWK"
}

# Print, one per line, the ID of every story in <post> that is new or
# whose block differs from <pre>. A story deleted by the edit is not
# listed. A missing file reads as empty, so with no <pre> every story is
# new.
vse_tf_touched_stories() {
    local pre="$1" post="$2"
    [ -f "$pre" ] || pre=/dev/null
    [ -f "$post" ] || post=/dev/null
    LC_ALL=C awk -F '\t' '
        FILENAME == ARGV[1] { seen[$0] = 1; next }
        !($0 in seen) && !($1 in listed) { listed[$1] = 1; print $1 }
    ' <(vse_tf_story_blocks < "$pre") <(vse_tf_story_blocks < "$post")
}

# Return 0 when <feature-file> has a tag line (a line that starts with
# "@") carrying the tag @<ID> before its first Feature: line. A byte
# order mark and carriage returns are stripped. Every other line before
# Feature:, comment and blank lines among them, is passed over, and a
# "#" on a tag line ends its tags. The match is on the whole tag, so
# @US_001_XY does not stand for US_001_X. A file with no Feature: line
# has no tag.
vse_tf_feature_has_tag() {
    local feature="$1" id="$2"
    case "$id" in
        ""|[!A-Za-z_]*|*[!A-Za-z0-9_]*) return 1 ;;
    esac
    { [ -f "$feature" ] && [ -r "$feature" ]; } || return 1
    LC_ALL=C awk -v want="@${id}" '
        NR == 1 && substr($0, 1, 3) == "\357\273\277" { $0 = substr($0, 4) }
        {
            sub(/\r$/, "")
            line = $0
            sub(/^[ \t]+/, "", line)
            sub(/[ \t]+$/, "", line)
        }
        index(line, "Feature:") == 1 { feature = 1; exit }
        substr(line, 1, 1) == "@" {
            n = split(line, tags, /[ \t]+/)
            for (i = 1; i <= n; i++) {
                if (substr(tags[i], 1, 1) == "#")
                    break
                if (tags[i] == want)
                    found = 1
            }
        }
        END { exit !(feature && found) }
    ' "$feature"
}

# ---------------------------------------------------- post-edit image

# Apply one edit: an empty old_string means the content is new_string
# (the Edit tool creating a file). Otherwise every occurrence is
# replaced. Without replace_all the Edit tool has already refused an
# old_string that is not unique, so replacing every occurrence is exact.
# shellcheck disable=SC2016
_VSE_TF_JQ_IMAGE='
def apply($e):
    ($e.old_string // "") as $old
    | ($e.new_string // "") as $new
    | if $old == "" then $new else (split($old) | join($new)) end;
$payload[0] as $p
| ($p.tool_input // {}) as $in
| if $p.tool_name == "Write" then ($in.content // "")
  elif $p.tool_name == "Edit" then apply($in)
  elif $p.tool_name == "MultiEdit" then reduce ($in.edits // [])[] as $e (.; apply($e))
  else error("unsupported tool \($p.tool_name)")
  end
'

_VSE_TF_PY_IMAGE='
import json
import sys


def apply(text, edit):
    old = edit.get("old_string") or ""
    new = edit.get("new_string") or ""
    if old == "":
        return new
    return text.replace(old, new)


def main():
    with open(sys.argv[1], "rb") as handle:
        payload = json.loads(handle.read().decode("utf-8"))
    with open(sys.argv[2], "rb") as handle:
        text = handle.read().decode("utf-8", "surrogateescape")
    tool = payload.get("tool_name")
    given = payload.get("tool_input") or {}
    if tool == "Write":
        text = given.get("content") or ""
    elif tool == "Edit":
        text = apply(text, given)
    elif tool == "MultiEdit":
        for edit in given.get("edits") or []:
            text = apply(text, edit)
    else:
        sys.stderr.write("unsupported tool %s\n" % tool)
        return 2
    sys.stdout.buffer.write(text.encode("utf-8", "surrogateescape"))
    return 0


try:
    sys.exit(main())
except (OSError, ValueError, AttributeError, TypeError) as error:
    sys.stderr.write("%s\n" % error)
    sys.exit(2)
'

# Print the content <target-file> would have after the Write, Edit or
# MultiEdit call in <payload-file> (the PreToolUse JSON). Write gives
# tool_input.content. Edit replaces old_string with new_string in the
# file on disk. MultiEdit applies tool_input.edits in order. A missing
# file reads as empty. Uses jq, else python3 in isolated mode. Returns 2
# for a malformed payload or another tool, and 3 when neither jq nor
# python3 is present.
#
# The text passes through the engine, which normalises it. Valid UTF-8
# comes back byte for byte. A byte that is not valid UTF-8 is kept by
# python3 but turned into U+FFFD by jq. So compare a post image only
# with the pre-image vse_tf_disk_image prints: both take the same path
# and are normalised identically.
vse_tf_post_image() {
    local payload="$1" target="$2" input=/dev/null
    if [ -f "$target" ] && [ -r "$target" ]; then
        input="$target"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq -j -R -s --slurpfile payload "$payload" "$_VSE_TF_JQ_IMAGE" < "$input" || return 2
        return 0
    fi
    if command -v python3 >/dev/null 2>&1; then
        python3 -I -c "$_VSE_TF_PY_IMAGE" "$payload" "$input" || return 2
        return 0
    fi
    return 3
}

# An empty MultiEdit, which changes nothing.
_VSE_TF_NO_EDIT='{"tool_name": "MultiEdit", "tool_input": {"edits": []}}'

# Print the content of <file> before any edit, normalised exactly as
# vse_tf_post_image normalises a post image: the file goes through the
# same function and engine with an edit list that changes nothing. A
# missing file reads as empty. Returns 3 when neither jq nor python3 is
# present.
vse_tf_disk_image() {
    vse_tf_post_image <(printf '%s' "$_VSE_TF_NO_EDIT") "$1"
}

# ----------------------------------------------------- classification

# Return 0 when <subject> matches one of the newline-separated globs in
# <list>. A "*" matches any characters, "/" included. The loop runs
# under set -f, which is restored afterwards.
_vse_tf_glob_any() {
    local subject="$1" list="$2" glob rc=1 restore=0
    [ -n "$list" ] || return 1
    case "$-" in
        *f*) : ;;
        *) restore=1; set -f ;;
    esac
    while IFS= read -r glob; do
        [ -n "$glob" ] || continue
        # The glob is matched as a pattern, so it stays unquoted.
        # shellcheck disable=SC2254
        case "$subject" in
            $glob) rc=0; break ;;
        esac
    done <<EOF
$list
EOF
    [ "$restore" -eq 0 ] || set +f
    return "$rc"
}

# Load what classification needs into globals, once per public call:
# the engineering-root prefix (the configuration file's directory
# relative to the git top level, with a trailing slash, empty at the top
# level) and the two glob lists.
_vse_tf_load() {
    local config="${ISO_CONFIG_FILE:-}" dir top rel
    _VSE_TF_ENG=""
    _VSE_TF_TEST_GLOBS=""
    _VSE_TF_CODE_GLOBS=""
    [ -n "$config" ] || return 0
    dir="$(CDPATH='' cd -- "$(dirname -- "$config")" 2>/dev/null && pwd -P)" || return 0
    top="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" || top=""
    if [ -n "$top" ]; then
        case "${dir}/" in
            "${top%/}"/*)
                rel="${dir#"${top%/}"}"
                rel="${rel#/}"
                _VSE_TF_ENG="${rel:+${rel}/}"
                ;;
        esac
    fi
    _VSE_TF_TEST_GLOBS="$(iso_section_list test_first test_paths)"
    _VSE_TF_CODE_GLOBS="$(iso_section_list test_first code_paths)"
    return 0
}

# Classify <rel> into _VSE_TF_KIND without a subshell, for loops.
_vse_tf_kind() {
    local rel="$1"
    _VSE_TF_KIND="other"
    case "$rel" in
        .iso-config.yaml|*/.iso-config.yaml|*.feature|"${_VSE_TF_ENG}"docs/generated/*|"${_VSE_TF_ENG}"tools/render/*|"${_VSE_TF_ENG}"tools/lint/*)
            _VSE_TF_KIND="never"
            return 0
            ;;
    esac
    if _vse_tf_glob_any "$rel" "$_VSE_TF_TEST_GLOBS"; then
        _VSE_TF_KIND="test"
    elif _vse_tf_glob_any "$rel" "$_VSE_TF_CODE_GLOBS"; then
        _VSE_TF_KIND="code"
    fi
    return 0
}

# Print never, test, code or other for <relpath>, a path relative to
# the git top level. Some paths are never code, whatever the globs say:
# every file named .iso-config.yaml (the one in force or any other, as
# PreToolUse treats them, so every gate agrees), every *.feature file,
# and, under the engineering root only, docs/generated/, tools/render/
# and tools/lint/ (generated documents and vendored tools). Anchoring
# at the engineering root keeps the plugin's own templates/tools/render/
# classifiable as code. Then test_first.test_paths wins over
# test_first.code_paths. Returns 2 for an absolute path or one that
# leaves the top level.
vse_tf_classify() {
    local rel="$1"
    case "$rel" in
        ""|/*|..|../*)
            printf "[test-first] classify needs a path relative to the git top level, not '%s'.\n" "$rel" >&2
            return 2
            ;;
    esac
    _vse_tf_load
    _vse_tf_kind "$rel"
    printf '%s\n' "$_VSE_TF_KIND"
    return 0
}

# ----------------------------------------------------------- evidence

# Print the refs a branch is measured against, in order: each literal
# protected_branches entry (read by iso_list, so an inline flow list
# and a block sequence both count) and the same branch on origin, then
# origin/main, main, origin/master and master. An entry holding a glob
# character names no single branch and is skipped.
_vse_tf_base_candidates() {
    local entry
    while IFS= read -r entry; do
        case "$entry" in
            ""|-*|*[*?[]*) continue ;;
        esac
        printf '%s\norigin/%s\n' "$entry" "$entry"
    done <<EOF
$(iso_list protected_branches)
EOF
    printf '%s\n' origin/main main origin/master master
}

# Return 0 and print "evidence: <path>" when a test path is new or
# modified in the working tree of <toplevel> (untracked files included,
# deletions not), or changed on the branch since its merge base with
# the first base candidate that resolves. Otherwise return 1 and print
# "reason: <text>", which names a shallow clone, a detached HEAD, an
# unborn HEAD, or the base the branch was measured against.
vse_tf_evidence() {
    local top="$1" record status path old base="" candidate merge_base
    if ! git -C "$top" rev-parse --git-dir >/dev/null 2>&1; then
        printf 'reason: %s is not inside a git repository\n' "$top"
        return 1
    fi
    _vse_tf_load

    # Working tree. In the -z format a rename or copy record is
    # followed by a field holding the old path, which is read and
    # dropped so it is never taken for a record of its own.
    while IFS= read -r -d '' record; do
        status="${record:0:2}"
        path="${record:3}"
        case "$status" in
            R*|C*|?R|?C)
                # The old path is read only to be dropped.
                # shellcheck disable=SC2034
                IFS= read -r -d '' old || true
                ;;
        esac
        case "$status" in
            *D*) continue ;;
        esac
        _vse_tf_kind "$path"
        if [ "$_VSE_TF_KIND" = test ]; then
            printf 'evidence: %s\n' "$path"
            return 0
        fi
    done < <(git -C "$top" status --porcelain=v1 -z -uall 2>/dev/null)

    # Branch.
    if ! git -C "$top" rev-parse -q --verify HEAD >/dev/null 2>&1; then
        printf 'reason: unborn HEAD (the branch has no commits yet), so there is no branch evidence and no test path changed in the working tree\n'
        return 1
    fi
    if ! git -C "$top" symbolic-ref -q HEAD >/dev/null 2>&1; then
        printf 'reason: detached HEAD (no branch is checked out), so there is no branch evidence and no test path changed in the working tree\n'
        return 1
    fi
    if [ "$(git -C "$top" rev-parse --is-shallow-repository 2>/dev/null)" = true ]; then
        printf 'reason: shallow clone (the history is incomplete), so there is no branch evidence and no test path changed in the working tree\n'
        return 1
    fi
    while IFS= read -r candidate; do
        if git -C "$top" rev-parse -q --verify "${candidate}^{commit}" >/dev/null 2>&1; then
            base="$candidate"
            break
        fi
    done <<EOF
$(_vse_tf_base_candidates)
EOF
    if [ -z "$base" ]; then
        printf 'reason: no base branch found (protected_branches, main or master), and no test path changed in the working tree\n'
        return 1
    fi
    if ! merge_base="$(git -C "$top" merge-base HEAD "$base" 2>/dev/null)"; then
        printf 'reason: the branch shares no history with %s, and no test path changed in the working tree\n' "$base"
        return 1
    fi
    while IFS= read -r -d '' path; do
        _vse_tf_kind "$path"
        if [ "$_VSE_TF_KIND" = test ]; then
            printf 'evidence: %s\n' "$path"
            return 0
        fi
    done < <(git -C "$top" diff --no-color --name-only -z --diff-filter=ACMR "$merge_base" HEAD 2>/dev/null)
    printf 'reason: no test path changed in the working tree or since the merge base with %s\n' "$base"
    return 1
}

# Return 0 when the branch checked out in <toplevel>, or in the working
# directory's repository when no top level is named, matches a
# test_first.refactor_branches glob. A non-empty <branch> is matched
# instead of the branch checked out, for a checkout that has none, such
# as the detached merge commit CI checks out for a pull request. An
# absent key means [refactor/*], and an explicit empty list names no
# branch. A detached HEAD with no <branch> named is never a refactor
# branch.
vse_tf_refactor_branch() {
    local top="${1:-.}" branch="${2:-}" globs
    if [ -z "$branch" ]; then
        branch="$(git -C "$top" symbolic-ref --short -q HEAD 2>/dev/null)" || return 1
    fi
    globs="$(iso_section_list test_first refactor_branches)"
    if [ -z "$globs" ]; then
        [ -z "$(iso_section_scalar test_first refactor_branches)" ] || return 1
        globs='refactor/*'
    fi
    _vse_tf_glob_any "$branch" "$globs"
}

# ---------------------------------------------------------- detection

# Return 0 when <file> exists and holds the fixed string <text>.
_vse_tf_file_has() {
    [ -f "$1" ] && grep -qF -- "$2" "$1" 2>/dev/null
}

# Return 0 when the package.json <file> has a "test" key in its
# top-level "scripts" object, other than the npm placeholder ("no test
# specified"). The reader follows strings, with their escapes, and the
# nesting of objects and arrays, so the same key elsewhere, such as
# directories.test, does not count.
_vse_tf_npm_test() {
    [ -f "$1" ] || return 1
    LC_ALL=C awk '
        { text = text $0 "\n" }
        END {
            n = length(text)
            for (i = 1; i <= n; i++) {
                c = substr(text, i, 1)
                if (c == "\"") {
                    s = ""
                    for (i++; i <= n; i++) {
                        c = substr(text, i, 1)
                        if (c == "\\") {
                            s = s c substr(text, i + 1, 1)
                            i++
                        } else if (c == "\"") {
                            break
                        } else {
                            s = s c
                        }
                    }
                    if (value) {
                        if (scripts && depth == 2 && key == "test" && !index(s, "no test specified"))
                            hit = 1
                        value = 0
                    } else {
                        last = s
                    }
                } else if (c == ":") {
                    key = last
                    value = 1
                } else if (c == "{" || c == "[") {
                    depth++
                    if (c == "{" && value && depth == 2 && key == "scripts")
                        scripts = 1
                    value = 0
                } else if (c == "}" || c == "]") {
                    if (depth == 2)
                        scripts = 0
                    depth--
                } else if (c == ",") {
                    value = 0
                }
            }
            exit !hit
        }' "$1"
}

# Return 0 when <dir> holds any of the named files.
_vse_tf_any_file() {
    local dir="$1" name
    shift
    for name in "$@"; do
        [ ! -f "${dir}/${name}" ] || return 0
    done
    return 1
}

# Print one key per test tool found in <dir>, in this order, and return
# 1 when none is found. The test-first skill mirrors this table.
#
#   pytest     pytest.ini, conftest.py, [tool.pytest in pyproject.toml,
#              [tool:pytest] in setup.cfg, [pytest] in tox.ini
#   npm-test   a "test" key in the "scripts" object of package.json,
#              other than the npm placeholder ("no test specified")
#   jest       jest.config.*, or a "jest" key in package.json
#   vitest     vitest.config.*
#   cargo      Cargo.toml
#   go         go.mod
#   maven      pom.xml with src/test/
#   gradle     build.gradle or build.gradle.kts with src/test/
#   ctest      enable_testing or add_test in CMakeLists.txt
#   make-test  a test: target in the Makefile
#   tests-dir  a tests/ or test/ directory (test/ is the common name in
#              JavaScript and Go projects, so both count)
#   spec-dir   a spec/ directory
#   behave     behave.ini, .behaverc, a [behave] section, features/steps/
#   cucumber   cucumber.js and its kin, features/step_definitions/,
#              src/test/resources/cucumber.properties
#   bats       a *.bats file up to three levels down
vse_tf_detect() {
    local dir="$1" found=1
    [ -d "$dir" ] || return 1

    if _vse_tf_any_file "$dir" pytest.ini conftest.py \
        || _vse_tf_file_has "${dir}/pyproject.toml" '[tool.pytest' \
        || _vse_tf_file_has "${dir}/setup.cfg" '[tool:pytest]' \
        || _vse_tf_file_has "${dir}/tox.ini" '[pytest]'; then
        printf 'pytest\n'
        found=0
    fi
    if _vse_tf_npm_test "${dir}/package.json"; then
        printf 'npm-test\n'
        found=0
    fi
    if _vse_tf_any_file "$dir" jest.config.js jest.config.ts jest.config.mjs \
            jest.config.cjs jest.config.json \
        || { [ -f "${dir}/package.json" ] && LC_ALL=C awk '
            /"jest"[ \t]*:/ { hit = 1 }
            END { exit !hit }' "${dir}/package.json"; }; then
        printf 'jest\n'
        found=0
    fi
    if _vse_tf_any_file "$dir" vitest.config.js vitest.config.ts vitest.config.mjs \
            vitest.config.cjs vitest.config.mts vitest.config.cts; then
        printf 'vitest\n'
        found=0
    fi
    if [ -f "${dir}/Cargo.toml" ]; then
        printf 'cargo\n'
        found=0
    fi
    if [ -f "${dir}/go.mod" ]; then
        printf 'go\n'
        found=0
    fi
    if [ -f "${dir}/pom.xml" ] && [ -d "${dir}/src/test" ]; then
        printf 'maven\n'
        found=0
    fi
    if _vse_tf_any_file "$dir" build.gradle build.gradle.kts && [ -d "${dir}/src/test" ]; then
        printf 'gradle\n'
        found=0
    fi
    if _vse_tf_file_has "${dir}/CMakeLists.txt" enable_testing \
        || _vse_tf_file_has "${dir}/CMakeLists.txt" add_test; then
        printf 'ctest\n'
        found=0
    fi
    if _vse_tf_make_test "$dir"; then
        printf 'make-test\n'
        found=0
    fi
    if [ -d "${dir}/tests" ] || [ -d "${dir}/test" ]; then
        printf 'tests-dir\n'
        found=0
    fi
    if [ -d "${dir}/spec" ]; then
        printf 'spec-dir\n'
        found=0
    fi
    if _vse_tf_any_file "$dir" behave.ini .behaverc \
        || _vse_tf_file_has "${dir}/setup.cfg" '[behave]' \
        || _vse_tf_file_has "${dir}/tox.ini" '[behave]' \
        || _vse_tf_file_has "${dir}/pyproject.toml" '[tool.behave]' \
        || [ -d "${dir}/features/steps" ]; then
        printf 'behave\n'
        found=0
    fi
    if _vse_tf_any_file "$dir" cucumber.js cucumber.cjs cucumber.mjs cucumber.json \
            cucumber.yml cucumber.yaml config/cucumber.yml \
            src/test/resources/cucumber.properties \
        || [ -d "${dir}/features/step_definitions" ]; then
        printf 'cucumber\n'
        found=0
    fi
    if [ -n "$(find "$dir" -maxdepth 3 \( -name .git -o -name node_modules \) -prune \
            -o -name '*.bats' -print -quit 2>/dev/null || true)" ]; then
        printf 'bats\n'
        found=0
    fi
    return "$found"
}

# Return 0 when a Makefile in <dir> has a test: target (not a := or
# = assignment to a variable named test).
_vse_tf_make_test() {
    local dir="$1" name
    for name in GNUmakefile makefile Makefile; do
        [ -f "${dir}/${name}" ] || continue
        if LC_ALL=C awk '
                /^test[ \t]*:/ && !/^test[ \t]*:=/ { hit = 1 }
                END { exit !hit }' "${dir}/${name}"; then
            return 0
        fi
    done
    return 1
}

# Print true or false from test_first.applies, or nothing when the
# record is absent. An unrecognised value prints nothing and is
# reported once on stderr, so it reads as unrecorded.
vse_tf_applies() {
    local value
    value="$(iso_section_scalar test_first applies)"
    case "$value" in
        true|True|TRUE) printf 'true\n' ;;
        false|False|FALSE) printf 'false\n' ;;
        "") : ;;
        *)
            echo "[test-first] Unrecognised test_first.applies value '${value}', treating test_first as unrecorded (methodology §11.5.2)." >&2
            ;;
    esac
    return 0
}
