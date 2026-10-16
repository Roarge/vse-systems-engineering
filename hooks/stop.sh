#!/usr/bin/env bash
# Stop hook for the vse-systems-engineering plugin, and the body of the
# SubagentStop hook.
#
# Per methodology/iso-29110-hooks-guide.md §5.5 and §5.6. Runs when the
# agent ends its turn (Stop) and, through subagent-stop.sh, when a
# subagent ends its own (SubagentStop). The first argument names the
# event, Stop by default.
#
# The loop contract. At these events additionalContext makes Claude
# carry on with the turn, under the same protections as a block: the
# harness sets stop_hook_active in the payload of the next stop, and
# caps the consecutive continuations. So the hook:
#
#   1. exits silently when stop_hook_active is true, or when the
#      payload cannot be read.
#   2. sends every reminder meant for the human as a top-level
#      systemMessage, which the user sees and which continues nothing.
#   3. uses additionalContext only for the test-first finding, once for
#      each session and state of the working tree.
#
# The reminders. At Stop, an architecture change in the working tree
# suggests an ADR (§10.5.3), and a verification or validation report
# suggests linking it to its procedure (SR.O7). At SubagentStop, one
# line says where the project and its methodology live.
#
# The test-first finding (methodology §11.7). Where test_first.applies
# is true, a code path changed in the working tree (deletions aside)
# with no test change draws the finding. A test path changed in the
# working tree or on the branch is evidence (vse_tf_evidence), as for
# the PreToolUse gate. A refactor branch, or the in-session gate
# pretooluse_test_first set to off, draws nothing.
#
# The marker. The state is a checksum of HEAD and git status. The
# states already sent are kept one per line in
# ${TMPDIR:-/tmp}/vse-stop.<session_id>, shared by both events, so
# concurrent sessions never share a marker. The session id is reduced
# to letters, digits, "_" and "-", so the marker never lands outside
# TMPDIR. The marker is replaced by a rename from the hook's own work
# directory, never written through a symbolic link. When it cannot be
# recorded, the finding goes to the user as a systemMessage instead, so
# it can never continue the turn twice.
#
# Locating the project, through the shared vse_tf_locate_project. The
# project is located through its .iso-config.yaml: the first one found
# walking up from the payload's cwd (else the hook's own working
# directory) to the git top level, also engineering/.iso-config.yaml at
# the top. Its directory is the engineering root. With none the hook is
# silent. In contributor mode (the plugin repository, recognised by
# wiki/CLAUDE.md at the git top level) only a configuration under demo/
# counts.
#
# Output contract. Claude never sees plain stdout at Stop or
# SubagentStop, so the hook prints exactly one JSON object through
# hooks/lib/hook-json.sh, or nothing at all. Diagnostics go to stderr.
# The exit status is always 0: an internal error ends the hook
# silently, with one line on stderr.
#
# stdin: the Stop or SubagentStop JSON payload (session_id, cwd,
# stop_hook_active).
# stdout: one JSON object, or nothing.
set -euo pipefail

STOP_EVENT="${1:-Stop}"
STOP_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib"
STOP_TMPDIR="${TMPDIR:-/tmp}"
STOP_TMPDIR="${STOP_TMPDIR%/}"
STOP_WORK=""

# Fail quietly. Any unexpected exit status becomes 0 with one line on
# stderr, and nothing has been printed on stdout yet, because the one
# object is emitted last. The function is reached through the trap.
# shellcheck disable=SC2317
_stop_finish() {
    local rc=$?
    if [ -n "$STOP_WORK" ]; then
        rm -rf "$STOP_WORK"
    fi
    if [ "$rc" -ne 0 ]; then
        echo "[stop] Internal error (exit ${rc}) at ${STOP_EVENT}, so no reminder was given." >&2
        exit 0
    fi
}
trap _stop_finish EXIT

case "$STOP_EVENT" in
    Stop|SubagentStop) : ;;
    *)
        echo "[stop] '${STOP_EVENT}' is not Stop or SubagentStop, so nothing was checked." >&2
        exit 0
        ;;
esac

STOP_WORK="$(mktemp -d "${STOP_TMPDIR}/vse-stop-work.XXXXXX")"
STOP_PAYLOAD="${STOP_WORK}/payload.json"
cat > "$STOP_PAYLOAD"

# shellcheck source=/dev/null
. "${STOP_LIB}/hook-json.sh"

# A stop hook already continued this turn. A payload that cannot be
# read fails here too, because vse_hj_read returns non-zero.
STOP_ACTIVE="$(vse_hj_read "$STOP_PAYLOAD" .stop_hook_active)"
case "$STOP_ACTIVE" in
    ""|false) : ;;
    *) exit 0 ;;
esac

# ------------------------------------------------------------ project

STOP_CWD="$(vse_hj_read "$STOP_PAYLOAD" .cwd)"
case "$STOP_CWD" in
    /*) : ;;
    *) STOP_CWD="$(pwd -P)" ;;
esac
[ -d "$STOP_CWD" ] || exit 0

# The libraries are loaded against an empty placeholder configuration,
# so that sourcing them reads nothing from the hook's own working
# directory. The real configuration is loaded once it is found.
: > "${STOP_WORK}/unset.yaml"
VSE_ISO_CONFIG="${STOP_WORK}/unset.yaml"
export VSE_ISO_CONFIG
# shellcheck source=/dev/null
. "${STOP_LIB}/iso-profile.sh"
# shellcheck source=/dev/null
. "${STOP_LIB}/test-first.sh"

vse_tf_locate_project "$STOP_CWD" || exit 0
STOP_CONFIG="$VSE_TF_CONFIG"
STOP_ENG="$VSE_TF_ENG_ROOT"
STOP_TOP="$VSE_TF_TOP"

VSE_ISO_CONFIG="$STOP_CONFIG"
export VSE_ISO_CONFIG
# shellcheck source=/dev/null
. "${STOP_LIB}/iso-profile.sh"

# The engineering root relative to the git top level, as a prefix of
# the paths git status prints: empty, or ending in "/".
STOP_ENG_REL=""
if [ -n "$STOP_TOP" ]; then
    case "${STOP_ENG}/" in
        "${STOP_TOP%/}"/*)
            STOP_ENG_REL="${STOP_ENG#"${STOP_TOP%/}"}"
            STOP_ENG_REL="${STOP_ENG_REL#/}"
            STOP_ENG_REL="${STOP_ENG_REL:+${STOP_ENG_REL}/}"
            ;;
    esac
fi

if [ "$STOP_EVENT" = "SubagentStop" ]; then
    vse_hj_add_system_message "[VSE] Subagent complete in the project at ${STOP_ENG}. Methodology specification: ${STOP_ENG}/methodology/."
fi

# Everything below reads the working tree.
if [ -z "$STOP_TOP" ]; then
    vse_hj_emit "$STOP_EVENT"
    exit 0
fi

# -------------------------------------------------------- working tree

STOP_STATUS="${STOP_WORK}/status"
if ! git -C "$STOP_TOP" status --porcelain=v1 -z -uall > "$STOP_STATUS" 2>/dev/null; then
    echo "[stop] git status failed in ${STOP_TOP}, so the working tree was not read." >&2
    : > "$STOP_STATUS"
fi

STOP_APPLIES="$(vse_tf_applies)"
STOP_ARCH=""
STOP_VV=""
STOP_CODE=""
STOP_CODE_COUNT=0
if [ "$STOP_APPLIES" = "true" ]; then
    _vse_tf_load
fi

# In the -z format a rename or copy record is followed by a field
# holding the old path, which is read and dropped so it is never taken
# for a record of its own. Deletions are passed over.
while IFS= read -r -d '' STOP_RECORD; do
    STOP_FLAGS="${STOP_RECORD:0:2}"
    STOP_PATH="${STOP_RECORD:3}"
    case "$STOP_FLAGS" in
        R*|C*|?R|?C)
            # The old path is read only to be dropped.
            # shellcheck disable=SC2034
            IFS= read -r -d '' STOP_OLD || true
            ;;
    esac
    case "$STOP_FLAGS" in
        *D*) continue ;;
    esac
    case "$STOP_PATH" in
        "${STOP_ENG_REL}model/variations/"*|"${STOP_ENG_REL}model/core/logical-architecture/"*)
            STOP_ARCH=1
            ;;
        "${STOP_ENG_REL}docs/verification-reports/"*|"${STOP_ENG_REL}docs/validation-reports/"*)
            STOP_VV=1
            ;;
    esac
    if [ "$STOP_APPLIES" = "true" ]; then
        _vse_tf_kind "$STOP_PATH"
        if [ "$_VSE_TF_KIND" = "code" ]; then
            STOP_CODE_COUNT=$((STOP_CODE_COUNT + 1))
            [ -n "$STOP_CODE" ] || STOP_CODE="$STOP_PATH"
        fi
    fi
done < "$STOP_STATUS"

# ----------------------------------------------------------- reminders

if [ "$STOP_EVENT" = "Stop" ] && [ -n "$STOP_ARCH" ]; then
    vse_hj_add_system_message "[methodology prompt at end of turn] Architectural changes detected. Per §10.5.3 (Justification Document) consider:
  - Writing an ADR in docs/decisions/ if a non-trivial decision was made.
  - Updating the trade-study analysis def if a variant was selected."
fi
if [ "$STOP_EVENT" = "Stop" ] && [ -n "$STOP_VV" ]; then
    vse_hj_add_system_message "[methodology prompt at end of turn] V&V activity detected. Per SR.O7:
  - Ensure the report references its IVV procedure.
  - Update the relevant story's StoryMeta if verification passed or failed."
fi

# ---------------------------------------------------- test-first finding

# The marker file for this session, named from the session id reduced
# to letters, digits, "_" and "-" (at most 128 of them).
STOP_SESSION="$(vse_hj_read "$STOP_PAYLOAD" .session_id)"
STOP_SESSION="$(printf '%s' "$STOP_SESSION" | LC_ALL=C tr -c 'A-Za-z0-9_-' '_')"
STOP_SESSION="${STOP_SESSION:0:128}"
STOP_MARKER="${STOP_TMPDIR}/vse-stop.${STOP_SESSION:-none}"
STOP_STATE=""

# _stop_seen: 0 when the marker, a plain file, already holds the state.
_stop_seen() {
    [ -f "$STOP_MARKER" ] && [ ! -L "$STOP_MARKER" ] \
        && grep -qxF -- "$STOP_STATE" "$STOP_MARKER" 2>/dev/null
}

# _stop_record: add the state to the marker. The new marker is written
# in the work directory, which sits in TMPDIR on the same file system,
# and renamed over the old one. A symbolic link at the marker path is
# removed first and never read, so nothing is written through it.
# Returns 1 when the marker cannot be replaced.
_stop_record() {
    local next="${STOP_WORK}/marker"
    {
        if [ -f "$STOP_MARKER" ] && [ ! -L "$STOP_MARKER" ]; then
            cat "$STOP_MARKER"
        fi
        printf '%s\n' "$STOP_STATE"
    } > "$next" 2>/dev/null || return 1
    if [ -L "$STOP_MARKER" ]; then
        rm -f "$STOP_MARKER" 2>/dev/null || return 1
    fi
    if [ -e "$STOP_MARKER" ] && [ ! -f "$STOP_MARKER" ]; then
        return 1
    fi
    mv -f "$next" "$STOP_MARKER" 2>/dev/null
}

stop_test_first() {
    local evidence reason command names finding
    [ -n "$STOP_CODE" ] || return 0
    [ "$(iso_gate_disposition pretooluse_test_first)" != "off" ] || return 0
    if vse_tf_refactor_branch "$STOP_TOP"; then
        return 0
    fi
    if evidence="$(vse_tf_evidence "$STOP_TOP")"; then
        return 0
    fi
    reason="${evidence#reason: }"
    STOP_STATE="$({ git -C "$STOP_TOP" rev-parse -q --verify HEAD 2>/dev/null || true; cat "$STOP_STATUS"; } | cksum)"
    if _stop_seen; then
        return 0
    fi
    names="$STOP_CODE"
    if [ "$STOP_CODE_COUNT" -gt 1 ]; then
        names="${names} and $((STOP_CODE_COUNT - 1)) more"
    fi
    command="$(iso_section_scalar test_first test_command)"
    finding="Test first (methodology §11.7): code changed in the working tree (${names}, under test_first.code_paths) and no test change was found: ${reason}. Before more code, write or change the failing test under test_first.test_paths, run it${command:+ (${command})} and watch it fail. A change that only restructures code belongs on a refactor branch. This finding is sent once for each state of the working tree."
    if _stop_record; then
        vse_hj_add_context "$finding"
    else
        echo "[stop] Could not record ${STOP_MARKER}, so the test-first finding goes to the user instead of the agent." >&2
        vse_hj_add_system_message "$finding"
    fi
}

# ---------------------------------------------------------------- run

stop_test_first
vse_hj_emit "$STOP_EVENT"
exit 0
