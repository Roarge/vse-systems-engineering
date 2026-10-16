#!/usr/bin/env bash
# PostToolUse hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §5.4. After each Edit, Write,
# MultiEdit or NotebookEdit call the agent makes, reminds the agent of
# the consequent updates that ISO/IEC 29110 and methodology §11 require:
#
#   - */stories/*.feature: mirror each @AC_ tag as a nested criterion in
#     the story (§11.3).
#   - */stories/*.sysml: bind verify <story>.acceptance.<name> for new
#     criteria (SR.O7, §11.3), and check the status (§11.4).
#   - A concern, an architecture file or the Project Plan: the
#     follow-ups of SR.O3 and PM.O1.
#   - A code path, where test_first.applies is true: run the recorded
#     test_command (§11.7).
#
# A PostToolUse hook never denies anything, because the edit has
# already happened. The sibling source-added-reminder.sh is a separate,
# contributor-only PostToolUse hook for the wiki.
#
# Output contract. Claude never sees plain stdout at PostToolUse, so
# every reminder for one call goes into one JSON object, printed through
# hooks/lib/hook-json.sh as hookSpecificOutput.additionalContext, or
# nothing at all is printed. Diagnostics go to stderr. The exit status
# is always 0: an internal error ends the hook silently, with one line
# on stderr.
#
# Locating the project, as in pre-tool-use.sh. The hook may run from
# any working directory, so the project is found from the edited file
# (a relative path is taken from the payload's cwd). The configuration
# is the first .iso-config.yaml found walking up from the file to the
# git top level (also engineering/.iso-config.yaml at the top). With
# none the hook is silent. In contributor mode (the plugin repository,
# recognised by wiki/CLAUDE.md at the git top level) only a
# configuration under demo/ counts, so the shipped template under
# templates/ is ignored.
#
# stdin: the PostToolUse JSON payload (tool_name, tool_input, cwd).
# stdout: one JSON object, or nothing.
set -euo pipefail

POST_EVENT="PostToolUse"
POST_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib"
POST_WORK=""

# Fail quietly. Any unexpected exit status becomes 0 with one line on
# stderr, and nothing has been printed on stdout yet, because the one
# object is emitted last. The function is reached through the trap.
# shellcheck disable=SC2317
_post_finish() {
    local rc=$?
    if [ -n "$POST_WORK" ]; then
        rm -rf "$POST_WORK"
    fi
    if [ "$rc" -ne 0 ]; then
        echo "[post-tool-use] Internal error (exit ${rc}), so no follow-up reminder was given for this edit." >&2
        exit 0
    fi
}
trap _post_finish EXIT

POST_WORK="$(mktemp -d "${TMPDIR:-/tmp}/vse-post-tool-use.XXXXXX")"
POST_PAYLOAD="${POST_WORK}/payload.json"
cat > "$POST_PAYLOAD"

# shellcheck source=/dev/null
. "${POST_LIB}/hook-json.sh"

# ------------------------------------------------------------- target

POST_RAW="$(vse_hj_read "$POST_PAYLOAD" .tool_input.file_path)"
if [ -z "$POST_RAW" ]; then
    POST_RAW="$(vse_hj_read "$POST_PAYLOAD" .tool_input.notebook_path)"
fi
[ -n "$POST_RAW" ] || exit 0
case "$POST_RAW" in
    /*) : ;;
    *)
        POST_CWD="$(vse_hj_read "$POST_PAYLOAD" .cwd)"
        case "$POST_CWD" in
            /*) POST_RAW="${POST_CWD%/}/${POST_RAW}" ;;
            *) exit 0 ;;
        esac
        ;;
esac

# The libraries are loaded against an empty placeholder configuration,
# so that sourcing them reads nothing from the hook's own working
# directory. The real configuration is loaded once it is found.
: > "${POST_WORK}/unset.yaml"
VSE_ISO_CONFIG="${POST_WORK}/unset.yaml"
export VSE_ISO_CONFIG
# shellcheck source=/dev/null
. "${POST_LIB}/iso-profile.sh"
# shellcheck source=/dev/null
. "${POST_LIB}/test-first.sh"

POST_TARGET="$(vse_tf_canonical "$POST_RAW")"
POST_NAME="${POST_TARGET##*/}"
POST_CONFIG="$(vse_tf_find_config "$POST_TARGET")"
[ -n "$POST_CONFIG" ] || exit 0
POST_TOP="$(git -C "${POST_CONFIG%/*}" rev-parse --show-toplevel 2>/dev/null)" || POST_TOP=""

if [ -n "$POST_TOP" ] && [ -f "${POST_TOP}/wiki/CLAUDE.md" ]; then
    case "$POST_CONFIG" in
        "${POST_TOP%/}/demo/"*) : ;;
        *) exit 0 ;;
    esac
fi

VSE_ISO_CONFIG="$POST_CONFIG"
export VSE_ISO_CONFIG
# shellcheck source=/dev/null
. "${POST_LIB}/iso-profile.sh"

# ---------------------------------------------------------- reminders

post_file_reminders() {
    case "$POST_TARGET" in
        */stories/*.feature)
            vse_hj_add_context "[methodology follow-up] Feature file ${POST_NAME} changed. Next, mirror each \`@AC_\` tag as a nested criterion in the story, that is, one named requirement inside the story's requirement :>> acceptance for each @AC_<name> scenario, with the same name (methodology §11.3)."
            ;;
        */stories/*.sysml)
            vse_hj_add_context "[methodology follow-up] Story file ${POST_NAME} changed. Next, bind \`verify <story>.acceptance.<name>\` for new criteria, in the verification case that covers each story (SR.O7, methodology §11.3). Check that each StoryMeta.status still fits the §11.4 ordering, and regenerate the Traceability Matrix if a constraint changed."
            ;;
        */concerns/*.sysml)
            vse_hj_add_context "[methodology follow-up] Concern changed. Consider:
  - Check that all framing stories still satisfy the concern.
  - Update stakeholder communications if the concern's scope shifted."
            ;;
        */logical-architecture/*.sysml|*/functional-architecture/*.sysml|*/product-architecture/*.sysml)
            vse_hj_add_context "[methodology follow-up] Architecture changed. Consider:
  - Update allocations if subsystem responsibilities shifted (SR.O3).
  - Re-render Traceability Matrix.
  - If the decision was non-trivial, write an ADR in docs/decisions/."
            ;;
        */docs/project-plan.md)
            vse_hj_add_context "[methodology follow-up] Project Plan changed. Per PM.O1:
  - This change requires Acquirer review and approval.
  - Reference the corresponding Change Request issue.
  - On merge, tag a new plan-baseline."
            ;;
    esac
    return 0
}

# A code path, where test_first.applies is true: run the tests now.
post_code_reminder() {
    local rel command
    [ -n "$POST_TOP" ] || return 0
    case "$POST_TARGET" in
        "${POST_TOP%/}/"*) rel="${POST_TARGET#"${POST_TOP%/}/"}" ;;
        *) return 0 ;;
    esac
    [ "$(vse_tf_applies)" = "true" ] || return 0
    _vse_tf_load
    _vse_tf_kind "$rel"
    [ "$_VSE_TF_KIND" = "code" ] || return 0
    command="$(iso_section_scalar test_first test_command)"
    if [ -n "$command" ]; then
        vse_hj_add_context "[methodology follow-up] ${rel} is a code path (test_first.code_paths). Now run \`${command}\` and read the result, so each step of the red, green, refactor cycle is seen to pass or fail (methodology §11.7)."
    else
        vse_hj_add_context "[methodology follow-up] ${rel} is a code path (test_first.code_paths). test_first.test_command is not recorded, so run the project's tests the way the project runs them and read the result, so each step of the red, green, refactor cycle is seen to pass or fail (methodology §11.7)."
    fi
}

# ---------------------------------------------------------------- run

post_file_reminders
post_code_reminder
vse_hj_emit "$POST_EVENT"
exit 0
