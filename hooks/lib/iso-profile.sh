#!/usr/bin/env bash
# Shared rigour-profile helpers for the project-side git hooks.
#
# Sourced by pre-commit, commit-msg, pre-commit-traceability, and the
# SessionStart lifecycle hook. Answers two questions:
#
#   1. Which rigour profile does this project run at (methodology
#      §0.10.2)?
#   2. What disposition does a named gate carry (methodology §0.10.4)?
#
# It also reads the values nested one level under a top-level key, such
# as the test_first record (methodology §11.5.2), as a scalar or as an
# inline flow list (a bracketed, comma-separated list on one line).
#
# The configuration schema stays flat and at most two levels deep, so
# awk is enough and no YAML library dependency is taken. A "#" inside
# a quoted value is kept, and any other "#" starts a comment.
#
# Sourcing the file resolves the configuration path and the profile
# once, into ISO_CONFIG_FILE and ISO_PROFILE. Resolving eagerly keeps a
# malformed value to a single diagnostic line per hook run, because the
# per-gate lookups below run inside command substitutions and cannot
# write back to the caller.
#
# Install as <project>/.githooks/lib/iso-profile.sh. The file is a
# library rather than a git entry point, so git never invokes it.
set -euo pipefail

# Locate the project .iso-config.yaml. VSE_ISO_CONFIG, when it names a
# readable file, wins over the search. A hook that has already found the
# configuration (for example by walking up from an edited file to a
# project below the git toplevel) exports it, and every reader then
# agrees on one file. Otherwise the greenfield layout keeps the file at
# the repository root, the brownfield layout under engineering/. Prints
# nothing when the project carries no configuration file.
_iso_locate_config() {
    local root
    if [ -n "${VSE_ISO_CONFIG:-}" ] && [ -f "${VSE_ISO_CONFIG}" ] && [ -r "${VSE_ISO_CONFIG}" ]; then
        printf '%s\n' "${VSE_ISO_CONFIG}"
        return 0
    fi
    root="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
    if [ -f "${root}/.iso-config.yaml" ]; then
        printf '%s\n' "${root}/.iso-config.yaml"
    elif [ -f "${root}/engineering/.iso-config.yaml" ]; then
        printf '%s\n' "${root}/engineering/.iso-config.yaml"
    fi
}

# Awk functions shared by every reader below.
#
# iso_value takes the text after "key:" and returns it with any
# trailing comment cut off. A quote opens a quoted token only where a
# token starts: at the start of the value or, with list set, after "["
# or ",". So a "#" inside a quoted token is kept, and an apostrophe in
# the middle of a plain value opens nothing. Any "#" outside a quoted
# token starts the comment, as it always has. With list set, the commas
# that separate flow-list items come back as SUBSEP.
#
# iso_item trims a scalar value or one list item and removes one layer
# of quotes, only when a matching pair wraps the whole text. Quotes
# inside a plain value (pytest -k "not slow") are part of it.
#
# "\047" is a single quote, which this shell string cannot hold.
_ISO_AWK_LIB='
function iso_value(s, list,    i, n, c, q, start, out) {
    sub(/^[ \t]+/, "", s)
    n = length(s)
    q = ""
    start = 1
    out = ""
    for (i = 1; i <= n; i++) {
        c = substr(s, i, 1)
        if (q == "\"" && c == "\\") {
            out = out c substr(s, i + 1, 1)
            i++
            continue
        }
        if (q != "" && c == q) {
            if (q == "\047" && substr(s, i + 1, 1) == q) {
                out = out c c
                i++
                continue
            }
            q = ""
        } else if (q == "") {
            if (c == "#")
                break
            if (list && c == ",") {
                out = out SUBSEP
                start = 1
                continue
            }
            if (start && (c == "\"" || c == "\047"))
                q = c
            if (list && c == "[")
                start = 1
            else if (c != " " && c != "\t")
                start = 0
        }
        out = out c
    }
    sub(/[ \t]+$/, "", out)
    return out
}
function iso_item(s,    f) {
    sub(/^[ \t]+/, "", s)
    sub(/[ \t]+$/, "", s)
    f = substr(s, 1, 1)
    if (length(s) >= 2 && (f == "\"" || f == "\047") && substr(s, length(s), 1) == f)
        s = substr(s, 2, length(s) - 2)
    return s
}
'

# Read one top-level scalar key out of the configuration file, with
# one layer of quotes removed. Prints nothing for a missing key.
_iso_scalar() {
    [ -n "${ISO_CONFIG_FILE}" ] || return 0
    awk -v key="$1" "${_ISO_AWK_LIB}"'
        { sub(/\r$/, "") }
        index($0, key ":") == 1 {
            print iso_item(iso_value(substr($0, length(key) + 2), 0))
            exit
        }
    ' "$ISO_CONFIG_FILE"
}

# Read <key> indented under the top-level <section>: mapping. With
# list 0 the value is a scalar, printed with one layer of quotes
# removed. With list 1 it is an inline flow list, printed one item per
# line.
# The section ends at the next line that starts in column one, other
# than a comment. Prints nothing for a missing section or key.
#
# Usage: _iso_section_read <section> <key> <0|1>
_iso_section_read() {
    [ -n "${ISO_CONFIG_FILE}" ] || return 0
    awk -v section="$1" -v key="$2" -v list="$3" "${_ISO_AWK_LIB}"'
        { sub(/\r$/, "") }
        !inside {
            if (index($0, section ":") == 1)
                inside = 1
            next
        }
        /^[^ \t#]/ { exit }
        {
            line = $0
            sub(/^[ \t]+/, "", line)
            if (index(line, key ":") != 1)
                next
            value = iso_value(substr(line, length(key) + 2), list)
            if (!list) {
                print iso_item(value)
                exit
            }
            sub(/^\[/, "", value)
            sub(/\]$/, "", value)
            n = split(value, items, SUBSEP)
            for (i = 1; i <= n; i++) {
                item = iso_item(items[i])
                if (item != "")
                    print item
            }
            exit
        }
    ' "$ISO_CONFIG_FILE"
}

# Print the value of <key> under the top-level <section>, with one layer
# of quotes removed when a matching pair wraps the whole value. Prints
# nothing for a missing section or key.
#
# Usage: iso_section_scalar test_first test_command
iso_section_scalar() {
    _iso_section_read "$1" "$2" 0
}

# Print the items of the inline flow list <key> under the top-level
# <section>, one per line, quotes and surrounding spaces stripped.
# Prints nothing for a missing section or key.
#
# Usage: iso_section_list test_first code_paths
iso_section_list() {
    _iso_section_read "$1" "$2" 1
}

# Print the path of the project .iso-config.yaml, or nothing when the
# project carries none.
iso_config_path() {
    printf '%s\n' "${ISO_CONFIG_FILE}"
}

# Print the project rigour profile: light, standard, or full.
iso_profile() {
    printf '%s\n' "${ISO_PROFILE}"
}

# Print the disposition of a named gate: block, warn, info, or off.
#
# A gate_overrides entry wins over the profile default, per methodology
# §0.10.4. An unset or unrecognised override falls through to the
# profile column of the §0.10.4 table.
#
# Usage: iso_gate_disposition commit_msg_pattern
iso_gate_disposition() {
    local gate="$1"
    local override

    override="$(iso_section_scalar gate_overrides "$gate")"

    case "$override" in
        block|warn|info|off)
            printf '%s\n' "$override"
            return 0
            ;;
        "")
            : # No override recorded, fall through to the profile default.
            ;;
        *)
            echo "[iso-profile] Unrecognised gate_overrides.${gate} value '${override}', using the profile default (methodology §0.10.4)." >&2
            ;;
    esac

    # Profile defaults, methodology §0.10.4.
    case "$gate" in
        commit_msg_pattern|commit_msg_cr_reference|precommit_story_wellformed)
            case "${ISO_PROFILE}" in
                light)    printf 'off\n' ;;
                standard) printf 'warn\n' ;;
                full)     printf 'block\n' ;;
            esac
            ;;
        precommit_lint)
            case "${ISO_PROFILE}" in
                light)    printf 'warn\n' ;;
                standard) printf 'warn\n' ;;
                full)     printf 'block\n' ;;
            esac
            ;;
        precommit_traceability)
            case "${ISO_PROFILE}" in
                light)    printf 'info\n' ;;
                standard) printf 'warn\n' ;;
                full)     printf 'block\n' ;;
            esac
            ;;
        # The Gherkin-first and test-first gates block at every profile,
        # and only a gate_overrides entry lowers one (methodology §11.9).
        precommit_gherkin|precommit_test_first|pretooluse_gherkin_first|pretooluse_test_first)
            printf 'block\n'
            ;;
        *)
            echo "[iso-profile] Unknown gate '${gate}', reporting without blocking." >&2
            printf 'warn\n'
            ;;
    esac

    return 0
}

# Eager resolution. An absent key, an absent configuration file, and an
# unreadable value all mean standard, per methodology §0.10.2. A
# malformed value is reported once so the engineer can correct it.
ISO_CONFIG_FILE="$(_iso_locate_config)"
ISO_PROFILE="$(_iso_scalar project_profile)"

case "${ISO_PROFILE}" in
    light|standard|full)
        : # Recorded and recognised.
        ;;
    "")
        ISO_PROFILE="standard"
        ;;
    *)
        # Child hooks re-source this library. The exported guard keeps
        # the diagnostic to one line per hook run, not one per process.
        if [ -z "${ISO_PROFILE_WARNED:-}" ]; then
            echo "[iso-profile] Unrecognised project_profile '${ISO_PROFILE}', using standard (methodology §0.10.2)." >&2
            export ISO_PROFILE_WARNED=1
        fi
        ISO_PROFILE="standard"
        ;;
esac
