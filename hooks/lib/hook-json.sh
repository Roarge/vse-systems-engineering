#!/usr/bin/env bash
# Shared JSON output helpers for the Claude Code lifecycle hooks.
#
# Plain stdout reaches the model only at SessionStart and
# UserPromptSubmit. At PreToolUse, PostToolUse, Stop and SubagentStop a
# hook speaks through exactly one JSON object on stdout, and the harness
# drops a malformed object or any text beside it as a non-blocking
# error. A dropped object loses a deny without a word, so these helpers
# always print one valid object, or nothing at all on a bad call.
#
#   {"hookSpecificOutput": {"hookEventName": "PreToolUse",
#     "permissionDecision": "deny" | "ask",
#     "permissionDecisionReason": "..."}}
#   {"hookSpecificOutput": {"hookEventName": "<event>",
#     "additionalContext": "..."}}
#   {"systemMessage": "..."}            shown to the user, not the model
#
# One-shot functions, for a hook with one thing to say:
#
#   vse_hj_deny <event> <reason>        permissionDecision deny
#   vse_hj_ask <event> <reason>         permissionDecision ask
#   vse_hj_context <event> <text>       additionalContext for the model
#   vse_hj_system_message <text>        systemMessage only
#
# Each prints exactly one JSON object and a newline, and returns 0.
#
# Accumulator, for a hook with several findings in one call (a deny for
# one story and a warning for another, say), printed as one object:
#
#   vse_hj_add_decision <deny|ask> <reason>
#   vse_hj_add_context <text>
#   vse_hj_add_system_message <text>
#   vse_hj_emit <event>                 one object, or nothing when
#                                       nothing was added
#
# Payload reads, for the JSON the harness passes on stdin (saved to a
# file first):
#
#   vse_hj_read <payload-file> <path>   print one string or boolean field
#
# A permission reason longer than 1,499 characters is clipped to 1,499,
# ending in "…and more", so it always stays under 1,500. Context and
# system messages are not clipped. A call that leaves out an argument,
# an event that is not a plain word (letters only), or a decision other
# than deny or ask, returns 64 with nothing on stdout and the problem
# on stderr.
#
# The encoder is jq, else python3 in isolated mode (so a json.py in the
# user's project is never imported), else a fixed literal. An engine
# that fails hands over to the next. A byte that is not valid UTF-8
# becomes U+FFFD. The fixed literal keeps the event and the decision,
# which are checked words, replaces every text with a notice that
# neither jq nor python3 is available, adds that notice as a
# systemMessage for the user, and writes the original texts to stderr.
#
# Portability: bash 3.2 (no mapfile, no associative arrays).
#
# Sourced by the lifecycle hooks from the plugin root. Not installed
# into projects. Sourcing this file defines the functions and an empty
# accumulator, and does no other work.
set -euo pipefail

_VSE_HJ_REASON_LIMIT=1499

# The engines take the same seven arguments: event, decision (empty for
# none), reason, a 1 when there is a context, the context, a 1 when
# there is a system message, the system message. Each prints one object
# on a single line.
# shellcheck disable=SC2016
_VSE_HJ_JQ_BUILD='
def clip:
    if length > ($limit | tonumber)
    then .[:(($limit | tonumber) - 9)] + "\u2026and more"
    else . end;
(if $decision != ""
 then {permissionDecision: $decision, permissionDecisionReason: ($reason | clip)}
 else {} end) as $d
| (if $has_context == "1" then {additionalContext: $context} else {} end) as $c
| (if ($d + $c) == {} then {} else {hookSpecificOutput: ({hookEventName: $event} + $d + $c)} end)
  + (if $has_system == "1" then {systemMessage: $system} else {} end)
'

_VSE_HJ_PY_BUILD='
import json
import os
import sys

limit = int(sys.argv[1])
event, decision, reason, has_context, context, has_system, system = [
    os.fsencode(arg).decode("utf-8", "replace") for arg in sys.argv[2:9]
]
inner = {}
if decision:
    if len(reason) > limit:
        reason = reason[: limit - 9] + "\u2026and more"
    inner["permissionDecision"] = decision
    inner["permissionDecisionReason"] = reason
if has_context == "1":
    inner["additionalContext"] = context
out = {}
if inner:
    hook = {"hookEventName": event}
    hook.update(inner)
    out["hookSpecificOutput"] = hook
if has_system == "1":
    out["systemMessage"] = system
sys.stdout.write(json.dumps(out, separators=(",", ":")) + "\n")
'

_VSE_HJ_NO_TOOL="neither jq nor python3 is available"

# _vse_hj_literal <event> <decision> <has-context>: the fixed object for
# a machine with no working engine. Only the checked event and decision
# words are spliced in.
_vse_hj_literal() {
    local event="$1" decision="$2" has_context="$3" inner="" notice
    notice="A VSE plugin hook could not encode its message because ${_VSE_HJ_NO_TOOL}. Install jq so that hook messages reach the session."
    case "$decision" in
        deny) inner="\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"A VSE plugin hook denied this tool call but could not encode its reason because ${_VSE_HJ_NO_TOOL}. Ask the user to install jq, then try again.\"" ;;
        ask) inner="\"permissionDecision\":\"ask\",\"permissionDecisionReason\":\"A VSE plugin hook asks for confirmation of this tool call but could not encode its reason because ${_VSE_HJ_NO_TOOL}.\"" ;;
    esac
    if [ "$has_context" = "1" ]; then
        inner="${inner:+${inner},}\"additionalContext\":\"A VSE plugin hook had a message for you but could not encode it because ${_VSE_HJ_NO_TOOL}. Ask the user to install jq.\""
    fi
    if [ -n "$inner" ]; then
        printf '{"hookSpecificOutput":{"hookEventName":"%s",%s},"systemMessage":"%s"}\n' "$event" "$inner" "$notice"
    else
        printf '{"systemMessage":"%s"}\n' "$notice"
    fi
}

# _vse_hj_build <event> <decision> <reason> <has-context> <context>
# <has-system> <system>: print one object, through the first engine that
# works. The object is captured before it is printed, so a failing
# engine never leaves half an object on stdout.
_vse_hj_build() {
    local out=""
    if command -v jq >/dev/null 2>&1; then
        if out="$(jq -n -c --arg limit "$_VSE_HJ_REASON_LIMIT" \
                --arg event "$1" --arg decision "$2" --arg reason "$3" \
                --arg has_context "$4" --arg context "$5" \
                --arg has_system "$6" --arg system "$7" \
                "$_VSE_HJ_JQ_BUILD")" && [ -n "$out" ]; then
            printf '%s\n' "$out"
            return 0
        fi
        echo "[hook-json] jq failed, trying python3." >&2
    fi
    if command -v python3 >/dev/null 2>&1; then
        if out="$(python3 -I -c "$_VSE_HJ_PY_BUILD" "$_VSE_HJ_REASON_LIMIT" "$@")" && [ -n "$out" ]; then
            printf '%s\n' "$out"
            return 0
        fi
        echo "[hook-json] python3 failed, printing a fixed notice." >&2
    fi
    echo "[hook-json] Hook output replaced by a fixed notice because ${_VSE_HJ_NO_TOOL}. The original follows." >&2
    [ -z "$2" ] || printf '[hook-json] %s reason: %s\n' "$2" "$3" >&2
    [ "$4" != "1" ] || printf '[hook-json] context: %s\n' "$5" >&2
    [ "$6" != "1" ] || printf '[hook-json] system message: %s\n' "$7" >&2
    _vse_hj_literal "$1" "$2" "$4"
    return 0
}

# _vse_hj_args <function> <needed> <given>: 0 when the call carries the
# arguments the function needs, else 64 with the problem on stderr. The
# public functions read their arguments as ${1-} and ${2-}, so a call
# that leaves one out is refused here rather than ending the hook on an
# unbound variable under set -u.
_vse_hj_args() {
    if [ "$3" -lt "$2" ]; then
        echo "[hook-json] $1 needs $2 argument(s) and was given $3, so nothing was done." >&2
        return 64
    fi
    return 0
}

# _vse_hj_check_event <event>: 0 for a plain word, else 64 with the
# problem on stderr.
_vse_hj_check_event() {
    case "$1" in
        ""|*[!A-Za-z]*)
            echo "[hook-json] The hook event name '$1' is not a plain word, so no output was printed." >&2
            return 64
            ;;
    esac
    return 0
}

vse_hj_deny() {
    _vse_hj_args vse_hj_deny 2 "$#" || return 64
    _vse_hj_check_event "${1-}" || return 64
    _vse_hj_build "${1-}" deny "${2-}" 0 "" 0 ""
}

vse_hj_ask() {
    _vse_hj_args vse_hj_ask 2 "$#" || return 64
    _vse_hj_check_event "${1-}" || return 64
    _vse_hj_build "${1-}" ask "${2-}" 0 "" 0 ""
}

vse_hj_context() {
    _vse_hj_args vse_hj_context 2 "$#" || return 64
    _vse_hj_check_event "${1-}" || return 64
    _vse_hj_build "${1-}" "" "" 1 "${2-}" 0 ""
}

vse_hj_system_message() {
    _vse_hj_args vse_hj_system_message 1 "$#" || return 64
    _vse_hj_build "" "" "" 0 "" 1 "${1-}"
}

# ---------------------------------------------------------- accumulator

# A hook with several findings in one call gathers them here and prints
# them as one object with vse_hj_emit. The state lives in the sourcing
# shell, so call these directly, never inside a command substitution.
_VSE_HJ_DECISION=""
_VSE_HJ_REASON=""
_VSE_HJ_CONTEXT=""
_VSE_HJ_SYSTEM=""
_VSE_HJ_BLANK=$'\n\n'
_VSE_HJ_NL=$'\n'

# vse_hj_add_decision <deny|ask> <reason>: record a permission decision.
# A deny outranks an ask: an ask after a deny is dropped, and a deny
# after an ask replaces it. Reasons of the same decision are kept as
# paragraphs in call order. Any other decision returns 64, because the
# hooks never emit allow.
vse_hj_add_decision() {
    local decision="${1-}" reason="${2-}"
    _vse_hj_args vse_hj_add_decision 2 "$#" || return 64
    case "$decision" in
        deny|ask) : ;;
        *)
            echo "[hook-json] '${decision}' is not a decision the hooks emit (deny or ask)." >&2
            return 64
            ;;
    esac
    if [ "$decision" = "$_VSE_HJ_DECISION" ]; then
        _VSE_HJ_REASON="${_VSE_HJ_REASON}${_VSE_HJ_BLANK}${reason}"
    elif [ -z "$_VSE_HJ_DECISION" ] || [ "$decision" = deny ]; then
        _VSE_HJ_DECISION="$decision"
        _VSE_HJ_REASON="$reason"
    fi
    return 0
}

# vse_hj_add_context <text>: add a paragraph for the model. An empty
# text adds nothing.
vse_hj_add_context() {
    _vse_hj_args vse_hj_add_context 1 "$#" || return 64
    [ -n "${1-}" ] || return 0
    _VSE_HJ_CONTEXT="${_VSE_HJ_CONTEXT:+${_VSE_HJ_CONTEXT}${_VSE_HJ_BLANK}}${1-}"
    return 0
}

# vse_hj_add_system_message <text>: add a line for the user. An empty
# text adds nothing.
vse_hj_add_system_message() {
    _vse_hj_args vse_hj_add_system_message 1 "$#" || return 64
    [ -n "${1-}" ] || return 0
    _VSE_HJ_SYSTEM="${_VSE_HJ_SYSTEM:+${_VSE_HJ_SYSTEM}${_VSE_HJ_NL}}${1-}"
    return 0
}

# vse_hj_emit <event>: print what was added as one object, or nothing
# when nothing was added, then start again empty. The reason is clipped
# as one reason after the paragraphs are joined. A refused call (no
# event, or one that is not a plain word) also starts again empty
# before it returns 64, so its findings never reach a later object.
vse_hj_emit() {
    local decision="$_VSE_HJ_DECISION" reason="$_VSE_HJ_REASON"
    local context="$_VSE_HJ_CONTEXT" system="$_VSE_HJ_SYSTEM"
    local has_context=0 has_system=0
    _VSE_HJ_DECISION=""
    _VSE_HJ_REASON=""
    _VSE_HJ_CONTEXT=""
    _VSE_HJ_SYSTEM=""
    _vse_hj_args vse_hj_emit 1 "$#" || return 64
    _vse_hj_check_event "${1-}" || return 64
    [ -z "$context" ] || has_context=1
    [ -z "$system" ] || has_system=1
    if [ -n "$decision" ] || [ "$has_context" = 1 ] || [ "$has_system" = 1 ]; then
        _vse_hj_build "${1-}" "$decision" "$reason" \
            "$has_context" "$context" "$has_system" "$system"
    fi
    return 0
}

# ------------------------------------------------------- payload reads

# The path arrives as data, never as program text: jq splits it into
# keys, and python3 walks the same keys. Anything that is not an object
# on the way reads as absent. The payload must hold exactly one JSON
# value. jq slurps it (reads every value into one array) so that an
# empty payload, or one with two values, fails as it does in python3,
# rather than reading as an absent field.
# shellcheck disable=SC2016
_VSE_HJ_JQ_READ='
if length != 1 then error("expected exactly one JSON value") else .[0] end
| (try getpath($path | ltrimstr(".") | split(".")) catch null)
| if type == "string" then .
  elif type == "boolean" then tostring
  else empty end
'

_VSE_HJ_PY_READ='
import json
import sys

try:
    with open(sys.argv[1], "rb") as handle:
        value = json.loads(handle.read().decode("utf-8-sig", "replace"))
except (OSError, ValueError) as error:
    sys.stderr.write("%s\n" % error)
    sys.exit(2)
for key in sys.argv[2].split(".")[1:]:
    value = value.get(key) if isinstance(value, dict) else None
if isinstance(value, bool):
    value = "true" if value else "false"
if isinstance(value, str):
    sys.stdout.buffer.write(value.encode("utf-8", "replace"))
'

# _vse_hj_check_path <path>: 0 for a dot and names joined by dots, else
# 64 with the problem on stderr. A dot is appended so that every name,
# the last included, ends at a dot.
_vse_hj_check_path() {
    local rest name
    case "$1" in
        .?*) rest="${1#.}." ;;
        *) rest="." ;;
    esac
    while [ -n "$rest" ]; do
        name="${rest%%.*}"
        case "$name" in
            ""|[!A-Za-z_]*|*[!A-Za-z0-9_]*)
                echo "[hook-json] The payload path '$1' is not of the form .name.name, so nothing was read." >&2
                return 64
                ;;
        esac
        rest="${rest#*.}"
    done
    return 0
}

# _vse_hj_print_read <captured>: print a read captured with its "x"
# sentinel, followed by a newline, or nothing for an empty field.
_vse_hj_print_read() {
    local out="${1%x}"
    [ -z "$out" ] || printf '%s\n' "$out"
    return 0
}

# vse_hj_read <payload-file> <path>: print one field of the JSON
# payload, followed by a newline, as jq -r prints it. The path is a dot
# and names joined by dots, such as .tool_input.file_path, each name a
# letter or underscore followed by letters, digits or underscores. A
# string prints as it is, a boolean as true or false. A field that is
# absent, null, empty or of another type prints nothing and returns 0.
# Returns 2 when the payload cannot be read or is not exactly one JSON
# value (an empty payload included), 3 when no engine works (neither jq
# nor python3 is available, or each one failed), and 64 for a missing
# argument or a path of another form. Uses jq, and hands over to
# python3 in isolated mode when jq fails, as the encoder does. jq
# cannot tell a payload it cannot read from a failure of its own, so a
# failing jq with no python3 returns 2. A byte that is not valid UTF-8
# reads as U+FFFD, and a leading byte order mark is skipped.
vse_hj_read() {
    local payload="${1-}" path="${2-}" out rc=3
    _vse_hj_args vse_hj_read 2 "$#" || return 64
    _vse_hj_check_path "$path" || return 64
    # The x keeps the trailing newlines a substitution would drop.
    if command -v jq >/dev/null 2>&1; then
        if out="$(jq -j -s --arg path "$path" "$_VSE_HJ_JQ_READ" "$payload" && printf x)"; then
            _vse_hj_print_read "$out"
            return 0
        fi
        rc=2
    fi
    if command -v python3 >/dev/null 2>&1; then
        [ "$rc" -ne 2 ] || echo "[hook-json] jq failed, trying python3." >&2
        if out="$(python3 -I -c "$_VSE_HJ_PY_READ" "$payload" "$path" && printf x)"; then
            _vse_hj_print_read "$out"
            return 0
        else
            rc=$?
        fi
        # The reader exits 2 for a payload it cannot read. Any other
        # failure is python3's own (the macOS stub that asks for the
        # developer tools, say), so no engine works.
        [ "$rc" -eq 2 ] || rc=3
    fi
    if [ "$rc" -eq 3 ]; then
        echo "[hook-json] Could not read the hook payload because ${_VSE_HJ_NO_TOOL}, or each one failed." >&2
    else
        echo "[hook-json] Could not read the hook payload ${payload}." >&2
    fi
    return "$rc"
}
