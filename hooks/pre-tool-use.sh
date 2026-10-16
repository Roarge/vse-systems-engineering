#!/usr/bin/env bash
# PreToolUse hook for the vse-systems-engineering plugin.
#
# Runs before each Edit, Write, MultiEdit or NotebookEdit call the
# agent makes, and carries the two in-session gates of methodology
# §11.9.3 (hooks guide §5.3):
#
#   1. Gherkin first (pretooluse_gherkin_first). An edit to a
#      */stories/*.sysml file that adds a story, or changes a story's
#      text (its declaration line through its matching closing brace),
#      waits until <dir>/<ID>.feature carries the tag @<ID>. The edit
#      is applied to the file first and the stories before and after
#      are compared, so only the stories it touches are gated.
#      Untouched siblings without a feature file draw a warning, and
#      deleting a story is never denied. Templates (file names that
#      begin with "_") and */model/library/* are skipped.
#   2. Test first (pretooluse_test_first). Where test_first.applies is
#      true, an edit to a code path waits until a test path has changed
#      in the working tree or on the branch since its merge base. On a
#      refactor branch the finding becomes a reminder.
#
# It also guards the configuration and passes on two reminders:
#
#   3. An edit to .iso-config.yaml that changes gate_overrides or
#      test_first asks the human to confirm it (methodology §11.10). A
#      new .iso-config.yaml below the configuration in force is
#      compared with that configuration, which it would replace for
#      the files in its directory and below.
#   4. An edit to a baselined path draws the Change Request reminder,
#      and an edit to a story file draws the §1.9 reminder.
#
# Each gate's disposition comes from iso_gate_disposition: block
# denies, warn adds the finding to the agent's context, info adds one
# line, and off skips the gate.
#
# Output contract. Claude never sees plain stdout at PreToolUse, so the
# hook prints exactly one JSON object through hooks/lib/hook-json.sh,
# or nothing at all. Every finding for one call goes into that object,
# a deny outranking an ask. The hook never answers allow, so the
# engineer's own permission settings still govern every call it lets
# through. Diagnostics go to stderr. The exit status is always 0: an
# internal error fails open with one line on stderr, so a deny never
# comes from a crash. The pre-commit and CI gates are the backstop.
# With neither jq nor python3 the payload cannot be read, and a fixed
# notice says so.
#
# Locating the project. The hook may run from any working directory,
# so everything is found from the edited file (a relative path is
# taken from the payload's cwd). The configuration is the first
# .iso-config.yaml found walking up from the file to the git top level
# (also engineering/.iso-config.yaml at the top), exported as
# VSE_ISO_CONFIG so every reader agrees on it. With none the hook is
# silent. In contributor mode (the plugin repository, recognised by
# wiki/CLAUDE.md at the git top level) only a configuration under
# demo/ counts, so the shipped template under templates/ is ignored.
#
# Cost. The hook runs on every edit, so the cheap checks come first:
# one payload read, then file tests up the directory tree. git and the
# image work run only when a configuration was found and the target
# can be gated.
#
# stdin: the PreToolUse JSON payload (tool_name, tool_input, cwd).
# stdout: one JSON object, or nothing.
set -euo pipefail

PTU_EVENT="PreToolUse"
PTU_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib"
PTU_WORK=""

# At most this many story identifiers are listed in one finding, the
# rest are counted, so a reason stays under 1,500 characters.
PTU_LIST_MAX=3

# Fail open. Any unexpected exit status becomes 0 with one line on
# stderr, and nothing has been printed on stdout yet, because the one
# object is emitted last. The function is reached through the trap.
# shellcheck disable=SC2317
_ptu_finish() {
    local rc=$?
    if [ -n "$PTU_WORK" ]; then
        rm -rf "$PTU_WORK"
    fi
    if [ "$rc" -ne 0 ]; then
        echo "[pre-tool-use] Internal error (exit ${rc}), so this edit was not checked and proceeds. The pre-commit and CI gates still check it." >&2
        exit 0
    fi
}
trap _ptu_finish EXIT

PTU_WORK="$(mktemp -d "${TMPDIR:-/tmp}/vse-pre-tool-use.XXXXXX")"
PTU_PAYLOAD="${PTU_WORK}/payload.json"
cat > "$PTU_PAYLOAD"

if ! command -v jq >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
    printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"The VSE plugin could not check this edit against the Gherkin-first and test-first gates (methodology §11.9.3), because neither jq nor python3 is available to read the hook payload. The edit proceeds unchecked, and the pre-commit and CI gates remain the backstop. Ask the user to install jq."},"systemMessage":"VSE plugin: the PreToolUse gates could not run because neither jq nor python3 is installed. Install jq so that edits are checked."}'
    exit 0
fi

# shellcheck source=/dev/null
. "${PTU_LIB}/hook-json.sh"

# ------------------------------------------------------------- target

PTU_RAW="$(vse_hj_read "$PTU_PAYLOAD" .tool_input.file_path)"
if [ -z "$PTU_RAW" ]; then
    PTU_RAW="$(vse_hj_read "$PTU_PAYLOAD" .tool_input.notebook_path)"
fi
[ -n "$PTU_RAW" ] || exit 0
case "$PTU_RAW" in
    /*) : ;;
    *)
        PTU_CWD="$(vse_hj_read "$PTU_PAYLOAD" .cwd)"
        case "$PTU_CWD" in
            /*) PTU_RAW="${PTU_CWD%/}/${PTU_RAW}" ;;
            *) exit 0 ;;
        esac
        ;;
esac

# The libraries are loaded against an empty placeholder configuration,
# so that sourcing them reads nothing from the hook's own working
# directory. The real configuration is loaded once it is found.
: > "${PTU_WORK}/unset.yaml"
VSE_ISO_CONFIG="${PTU_WORK}/unset.yaml"
export VSE_ISO_CONFIG
# shellcheck source=/dev/null
. "${PTU_LIB}/iso-profile.sh"
# shellcheck source=/dev/null
. "${PTU_LIB}/test-first.sh"

PTU_TARGET="$(vse_tf_canonical "$PTU_RAW")"
PTU_DIR="${PTU_TARGET%/*}"
[ -n "$PTU_DIR" ] || PTU_DIR=/
PTU_BASE="${PTU_TARGET##*/}"

# Return 0 when a .iso-config.yaml or an engineering/.iso-config.yaml
# sits in <dir> or in any directory above it. File tests only, so a
# file outside every project costs no git call.
_ptu_config_above() {
    local dir="$1"
    while :; do
        if [ -f "${dir%/}/.iso-config.yaml" ] || [ -f "${dir%/}/engineering/.iso-config.yaml" ]; then
            return 0
        fi
        [ "$dir" != / ] || return 1
        dir="${dir%/*}"
        [ -n "$dir" ] || dir=/
    done
}

_ptu_config_above "$PTU_DIR" || exit 0
PTU_CONFIG="$(vse_tf_find_config "$PTU_TARGET")"
[ -n "$PTU_CONFIG" ] || exit 0

PTU_PROBE="$PTU_DIR"
while [ ! -d "$PTU_PROBE" ]; do
    PTU_PROBE="${PTU_PROBE%/*}"
    [ -n "$PTU_PROBE" ] || PTU_PROBE=/
done
PTU_TOP="$(git -C "$PTU_PROBE" rev-parse --show-toplevel 2>/dev/null)" || PTU_TOP=""

if [ -n "$PTU_TOP" ] && [ -f "${PTU_TOP}/wiki/CLAUDE.md" ]; then
    case "$PTU_CONFIG" in
        "${PTU_TOP%/}/demo/"*) : ;;
        *) exit 0 ;;
    esac
fi

VSE_ISO_CONFIG="$PTU_CONFIG"
export VSE_ISO_CONFIG
# shellcheck source=/dev/null
. "${PTU_LIB}/iso-profile.sh"

# Read on first use by the arms that apply the edit.
PTU_TOOL=""
PTU_PRE=""
PTU_POST=""

# ------------------------------------------------------------ helpers

# _ptu_tool: set PTU_TOOL from the payload, once.
_ptu_tool() {
    if [ -z "$PTU_TOOL" ]; then
        PTU_TOOL="$(vse_hj_read "$PTU_PAYLOAD" .tool_name)"
        [ -n "$PTU_TOOL" ] || PTU_TOOL="unknown"
    fi
    return 0
}

# _ptu_images: write the file before and after the edit to PTU_PRE and
# PTU_POST, once. Both go through the same engine, so they are
# normalised alike. An edit the engine cannot apply ends the hook,
# which then fails open.
_ptu_images() {
    [ -z "$PTU_PRE" ] || return 0
    PTU_PRE="${PTU_WORK}/pre"
    PTU_POST="${PTU_WORK}/post"
    if ! vse_tf_disk_image "$PTU_TARGET" > "$PTU_PRE" \
        || ! vse_tf_post_image "$PTU_PAYLOAD" "$PTU_TARGET" > "$PTU_POST"; then
        echo "[pre-tool-use] Could not apply the ${PTU_TOOL} call to ${PTU_TARGET}." >&2
        exit 70
    fi
    return 0
}

# _ptu_count <list>: the number of non-empty lines.
_ptu_count() {
    local line n=0
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            n=$((n + 1))
        fi
    done <<EOF
$1
EOF
    printf '%s\n' "$n"
}

# _ptu_names <list>: the non-empty lines as "A", "A and B", "A, B and C",
# or "A, B, C and N more" past PTU_LIST_MAX.
_ptu_names() {
    local list="$1" id n=0 total out=""
    total="$(_ptu_count "$list")"
    while IFS= read -r id; do
        [ -n "$id" ] || continue
        n=$((n + 1))
        if [ "$n" -gt "$PTU_LIST_MAX" ]; then
            break
        elif [ "$n" -eq 1 ]; then
            out="$id"
        elif [ "$n" -eq "$total" ]; then
            out="${out} and ${id}"
        else
            out="${out}, ${id}"
        fi
    done <<EOF
$list
EOF
    if [ "$total" -gt "$PTU_LIST_MAX" ]; then
        out="${out} and $((total - PTU_LIST_MAX)) more"
    fi
    printf '%s\n' "$out"
}

# _ptu_report <disposition> <finding> <info-line>: block denies with
# the finding, warn adds it as context, info adds the one line.
_ptu_report() {
    case "$1" in
        block) vse_hj_add_decision deny "$2" ;;
        warn) vse_hj_add_context "Warning: $2" ;;
        info) vse_hj_add_context "$3" ;;
    esac
    return 0
}

# ------------------------------------------------- 3. the configuration

# _ptu_section <name>: print the lines of the top-level <name> section
# of the YAML on stdin, the key line included, without blank lines or
# full-line comments. The section ends at the next line that starts in
# column one, other than a comment, as iso-profile.sh reads it.
_ptu_section() {
    LC_ALL=C awk -v want="$1" '
        { sub(/\r$/, "") }
        /^[^ \t#]/ { inside = (index($0, want ":") == 1) }
        !inside || /^[ \t]*$/ || /^[ \t]*#/ { next }
        { sub(/[ \t]+$/, ""); print }
    '
}

# The edited configuration is compared with the one that governs it
# before the edit. That is the file itself when it exists. A new
# .iso-config.yaml below the configuration in force (PTU_CONFIG, the
# nearest one above) takes over the files in its directory and below,
# so it is compared with PTU_CONFIG. Otherwise a new file that simply
# leaves out gate_overrides or test_first would lower a gate for that
# subtree unasked.
ptu_config_guard() {
    local section before changed="" what
    [ "$PTU_BASE" = ".iso-config.yaml" ] || return 0
    _ptu_tool
    case "$PTU_TOOL" in
        Edit|Write|MultiEdit) : ;;
        *) return 0 ;;
    esac
    _ptu_images
    before="$PTU_PRE"
    if [ "$PTU_CONFIG" != "$PTU_TARGET" ]; then
        before="${PTU_WORK}/governing"
        if ! vse_tf_disk_image "$PTU_CONFIG" > "$before"; then
            echo "[pre-tool-use] Could not read ${PTU_CONFIG}." >&2
            exit 70
        fi
    fi
    for section in gate_overrides test_first; do
        if [ "$(_ptu_section "$section" < "$before")" != "$(_ptu_section "$section" < "$PTU_POST")" ]; then
            changed="${changed:+${changed} and }${section}"
        fi
    done
    [ -n "$changed" ] || return 0
    if [ "$before" = "$PTU_PRE" ]; then
        what="this edit changes ${changed} in ${PTU_TARGET}"
    else
        what="this edit creates ${PTU_TARGET}, a new configuration that would govern the files in its directory and below in place of ${PTU_CONFIG}, and its ${changed} settings differ from that configuration"
    fi
    vse_hj_add_decision ask "Self-bypass guard (methodology §11.10): ${what}. gate_overrides sets the gate dispositions and test_first decides which paths the test-first gates treat as code, so this change can lower a gate. An agent never lowers a gate without an explicit request from a human. Approve only if the user asked for this change."
}

# -------------------------------------------------- 1. Gherkin first

PTU_STORY_REMINDER="[methodology reminder] Editing a story file. Per §1.9 and §11, a story carries a typed subject, a role typed by a part def from model/core/stakeholders/ (or the component scope), the capability and benefit narrative strings, at least one frame concern or a documented justification, and one named criterion inside requirement :>> acceptance for each @AC_ scenario of its <ID>.feature file (§11.3). After editing, keep the StoryMeta status within the §11.4 ordering and the verification case current."

ptu_gherkin_first() {
    local disposition touched id missing="" siblings="" legacy names count finding where
    case "$PTU_BASE" in
        _*) return 0 ;;
    esac
    case "$PTU_TARGET" in
        */model/library/*) return 0 ;;
    esac
    _ptu_tool
    case "$PTU_TOOL" in
        Edit|Write|MultiEdit) : ;;
        *) return 0 ;;
    esac
    disposition="$(iso_gate_disposition pretooluse_gherkin_first)"
    [ "$disposition" != "off" ] || return 0
    _ptu_images

    touched="$(vse_tf_touched_stories "$PTU_PRE" "$PTU_POST")"
    while IFS= read -r id; do
        [ -n "$id" ] || continue
        if vse_tf_feature_has_tag "${PTU_DIR}/${id}.feature" "$id"; then
            continue
        fi
        case $'\n'"${touched}"$'\n' in
            *$'\n'"${id}"$'\n'*) missing="${missing}${id}"$'\n' ;;
            *) siblings="${siblings}${id}"$'\n' ;;
        esac
    done < <(vse_tf_story_blocks < "$PTU_POST" | LC_ALL=C awk -F '\t' '!($1 in seen) { seen[$1] = 1; print $1 }')

    if [ -n "$missing" ]; then
        count="$(_ptu_count "$missing")"
        names="$(_ptu_names "$missing")"
        if [ "$count" -eq 1 ]; then
            id="${missing%$'\n'}"
            finding="Gherkin first (pretooluse_gherkin_first): this edit adds or changes the story ${id}, which has no feature file carrying its tag. Write ${PTU_DIR}/${id}.feature first, with the tag @${id} on a line before Feature: and a description that opens with the story narrative (As a, I want, So that). Then retry this edit (methodology §11.2, §11.9.3)."
        else
            finding="Gherkin first (pretooluse_gherkin_first): this edit adds or changes ${count} stories that have no feature file carrying their tag: ${names}. For each story <ID>, write ${PTU_DIR}/<ID>.feature first, with the tag @<ID> on a line before Feature: and a description that opens with the story narrative (As a, I want, So that). Then retry this edit (methodology §11.2, §11.9.3)."
        fi
        # A story that already held Given/When/Then text before this
        # edit is one from before 5.0.0.
        legacy="$(vse_tf_story_blocks < "$PTU_PRE" | LC_ALL=C awk -F '\t' -v ids="$(printf '%s' "$missing" | tr '\n' ' ')" '
            BEGIN { n = split(ids, list, " "); for (i = 1; i <= n; i++) want[list[i]] = 1 }
            ($1 in want) && !($1 in done) && index($2, "Given") { done[$1] = 1; print $1 }')"
        if [ -n "$legacy" ]; then
            if [ "$(_ptu_count "$legacy")" -eq 1 ]; then
                legacy="The story $(_ptu_names "$legacy") already holds"
            else
                legacy="The stories $(_ptu_names "$legacy") already hold"
            fi
            finding="${finding} ${legacy} Given/When/Then acceptance text, so formalise the existing Given/When/Then first, as scenarios in the feature file, without adding behaviour (methodology §11.3)."
        fi
        _ptu_report "$disposition" "$finding" \
            "Gherkin first (info): no feature file carries the tag of ${names} in ${PTU_DIR}."
    fi

    if [ -n "$siblings" ]; then
        names="$(_ptu_names "$siblings")"
        if [ "$(_ptu_count "$siblings")" -eq 1 ]; then
            where="${PTU_DIR}/${siblings%$'\n'}.feature"
        else
            where="${PTU_DIR}/<ID>.feature"
        fi
        if [ "$disposition" = "info" ]; then
            vse_hj_add_context "Gherkin first (info): untouched by this edit, these stories still have no tagged feature file: ${names}."
        else
            vse_hj_add_context "Warning (pretooluse_gherkin_first): this story file also holds ${names}, untouched by this edit, with no feature file carrying the story tag. Write ${where} for each before its next change (methodology §11.2)."
        fi
    fi
    return 0
}

ptu_story_file() {
    case "$PTU_TARGET" in
        */stories/*.sysml) : ;;
        *) return 0 ;;
    esac
    ptu_gherkin_first
    vse_hj_add_context "$PTU_STORY_REMINDER"
}

# ------------------------------------------------------ 2. Test first

ptu_test_first() {
    local rel disposition evidence reason branch command finding
    [ -n "$PTU_TOP" ] || return 0
    case "$PTU_TARGET" in
        "${PTU_TOP%/}/"*) rel="${PTU_TARGET#"${PTU_TOP%/}/"}" ;;
        *) return 0 ;;
    esac
    [ "$(vse_tf_applies)" = "true" ] || return 0
    disposition="$(iso_gate_disposition pretooluse_test_first)"
    [ "$disposition" != "off" ] || return 0
    _vse_tf_load
    _vse_tf_kind "$rel"
    [ "$_VSE_TF_KIND" = "code" ] || return 0
    if evidence="$(vse_tf_evidence "$PTU_TOP")"; then
        return 0
    fi
    reason="${evidence#reason: }"
    if vse_tf_refactor_branch "$PTU_TOP"; then
        branch="$(git -C "$PTU_TOP" symbolic-ref --short -q HEAD 2>/dev/null)" || branch="this branch"
        vse_hj_add_context "Reminder (pretooluse_test_first): ${rel} is a code path and no test file has changed, but ${branch} is a refactor branch, so the edit proceeds. Keep the behaviour unchanged and the tests green (methodology §11.7, §11.9.3)."
        return 0
    fi
    command="$(iso_section_scalar test_first test_command)"
    finding="Test first (pretooluse_test_first): ${rel} is a code path (test_first.code_paths) and no test change was found: ${reason}. Write or change the failing test first under test_first.test_paths, run it${command:+ (${command})} and watch it fail, then retry this edit (methodology §11.7, §11.9.3). A change that only restructures code belongs on a refactor branch."
    _ptu_report "$disposition" "$finding" \
        "Test first (info): ${rel} is a code path and no test file has changed."
}

# ------------------------------------------------- 4. baselined paths

ptu_baselined() {
    local entry rel eng rel_top="" rel_eng="" hit=""
    eng="${PTU_CONFIG%/*}"
    if [ -n "$PTU_TOP" ]; then
        case "$PTU_TARGET" in
            "${PTU_TOP%/}/"*) rel_top="${PTU_TARGET#"${PTU_TOP%/}/"}" ;;
        esac
    fi
    case "$PTU_TARGET" in
        "${eng%/}/"*) rel_eng="${PTU_TARGET#"${eng%/}/"}" ;;
    esac
    while IFS= read -r entry; do
        entry="${entry%/}"
        [ -n "$entry" ] || continue
        for rel in "$rel_top" "$rel_eng"; do
            [ -n "$rel" ] || continue
            case "$rel" in
                "$entry"|"$entry"/*) hit="$rel"; break 2 ;;
            esac
        done
    done < <(iso_list baselined_paths)
    [ -n "$hit" ] || return 0
    vse_hj_add_context "[methodology] ${hit} is a baselined artefact. Edits reference an open Change Request per §10.4.2 (/vse-cr opens one)."
}

# ---------------------------------------------------------------- run

ptu_config_guard
ptu_story_file
ptu_test_first
ptu_baselined
vse_hj_emit "$PTU_EVENT"
exit 0
