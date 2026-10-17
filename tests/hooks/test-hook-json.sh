#!/usr/bin/env bash
# Behavioural tests for hooks/lib/hook-json.sh.
#
# The library writes the one JSON object a lifecycle hook prints on
# stdout (PreToolUse, PostToolUse, Stop, SubagentStop), and reads one
# field of the payload the harness gives a hook on stdin. Every case
# sources the library from the plugin tree into a fresh shell, inside a
# scratch directory, and calls it. Four groups of behaviour are pinned:
#
#   1. The one-shot emitters print exactly one object of the shape the
#      harness reads, with every string kept exactly: quotes,
#      backslashes, newlines, tabs, non-ASCII and control characters.
#      A permission reason longer than 1,499 characters is clipped, so
#      it always stays under 1,500.
#   2. The encoder is jq, else python3 in isolated mode, else a fixed
#      literal. Each case runs once per engine, with the other tools
#      taken off PATH, and an engine that fails hands over to the next,
#      so the object stays valid whatever the machine has.
#   3. A payload field is read by a dotted path, with jq or python3,
#      and a path of any other form is refused, so no program text can
#      be passed in through it.
#   4. The accumulator gathers several findings and prints them as one
#      object, a deny outranking an ask, and starts again empty.
#
# Run: bash tests/hooks/test-hook-json.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

HJ_LIB="${TC_PLUGIN_ROOT}/hooks/lib/hook-json.sh"

# The driver body is expanded by the shell it is handed to.
# shellcheck disable=SC2016
HJ_DRIVER='
lib="$1"
shift
. "$lib"
"$@"
'

# As HJ_DRIVER, but the function writes into the file named by the
# second argument, so a test can compare the bytes, trailing newlines
# included.
# shellcheck disable=SC2016
HJ_FILE_DRIVER='
lib="$1"
out="$2"
shift 2
. "$lib"
"$@" > "$out"
'

# As HJ_DRIVER, for a sequence of calls in one shell: the calls are
# separated by ';;' arguments, so the accumulator state carries from
# one call to the next.
# shellcheck disable=SC2016
HJ_SEQ_DRIVER='
lib="$1"
shift
. "$lib"
call=()
for arg in "$@" ";;"; do
    if [ "$arg" = ";;" ]; then
        "${call[@]}"
        call=()
    else
        call+=("$arg")
    fi
done
'

# One scratch repository serves every case: the library touches no
# file, so nothing carries over from one case to the next.
tc_setup_repo

# run_hj <function> [arg ...]: call one library function inside $REPO.
run_hj() {
    tc_run_in "$REPO" bash -c "$HJ_DRIVER" hj-driver "$HJ_LIB" "$@"
}

# run_hj_seq <call> [';;' <call>]...: several calls in one shell.
run_hj_seq() {
    tc_run_in "$REPO" bash -c "$HJ_SEQ_DRIVER" hj-driver "$HJ_LIB" "$@"
}

# PATH values that take jq, python3 or both out of reach.
HJ_BIN_NO_PYTHON="$(tc_bin_without python3)"
HJ_BIN_NO_JQ="$(tc_bin_without jq)"
HJ_BIN_NO_JSON="$(tc_bin_without jq python3)"

HJ_ENGINES="jq python3"

# hj_engine <jq|python3|none>: the PATH for the next runner call, with
# the other JSON tools taken away so the named one must do the work.
hj_engine() {
    case "$1" in
        jq) tc_env PATH="$HJ_BIN_NO_PYTHON" ;;
        python3) tc_env PATH="$HJ_BIN_NO_JQ" ;;
        none) tc_env PATH="$HJ_BIN_NO_JSON" ;;
    esac
}

# hj_assert_value <jq-filter> <expected> <case>: the filter applied to
# stdout gives exactly the expected string, compared inside jq so that
# trailing newlines and control characters count.
hj_assert_value() {
    local filter="$1" want="$2" name="$3"
    if printf '%s' "$OUT" | jq -e --arg want "$want" "(${filter}) == \$want" > /dev/null 2>&1; then
        tc_pass "$name"
    else
        tc_fail "$name" "expected ${filter} to equal: ${want}
$(_tc_context)"
    fi
}

# Strings that break naive JSON: a quote, a backslash, a newline, a
# tab, non-ASCII (Latin, CJK and an emoji outside the basic plane),
# control characters including an escape sequence and DEL, and text
# that would close the object early if pasted in raw.
HJ_TRICKY="$(printf 'say "hi" \\ back\\slash\\n\nline two\ttab\rcafé 日本 \360\237\232\200 \001\002\033[0m\037 \177 "}}, {"x": 1}')"
# A string that ends in newlines, which a command substitution drops.
HJ_TRAILING="$(printf 'ends here\n\nx')"
HJ_TRAILING="${HJ_TRAILING%x}"

HJ_DENY_SHAPE='(keys_unsorted == ["hookSpecificOutput"])
    and (.hookSpecificOutput | keys_unsorted == ["hookEventName", "permissionDecision", "permissionDecisionReason"])'
HJ_CONTEXT_SHAPE='(keys_unsorted == ["hookSpecificOutput"])
    and (.hookSpecificOutput | keys_unsorted == ["hookEventName", "additionalContext"])'
HJ_SYSTEM_SHAPE='keys_unsorted == ["systemMessage"]'

# ------------------------------------------------------ one-shot output

case_deny() {
    local engine
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj vse_hj_deny PreToolUse "Write the feature file first."
        tc_assert_rc 0 "deny (${engine}): exit 0"
        tc_assert_json "$HJ_DENY_SHAPE" "deny (${engine}): one object, hookSpecificOutput only"
        tc_assert_json '.hookSpecificOutput.hookEventName == "PreToolUse"' "deny (${engine}): the event is named"
        tc_assert_json '.hookSpecificOutput.permissionDecision == "deny"' "deny (${engine}): the decision is deny"
        hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "Write the feature file first." \
            "deny (${engine}): the reason is kept"
        tc_assert_line_count 1 "$OUT" "deny (${engine}): one line on stdout"
        tc_assert_empty "$ERR" "deny (${engine}): nothing on stderr"
    done
    tc_env
}

case_ask() {
    local engine
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj vse_hj_ask PreToolUse "This edit lowers a gate. Confirm with the user."
        tc_assert_rc 0 "ask (${engine}): exit 0"
        tc_assert_json "$HJ_DENY_SHAPE" "ask (${engine}): one object, hookSpecificOutput only"
        tc_assert_json '.hookSpecificOutput.hookEventName == "PreToolUse"' "ask (${engine}): the event is named"
        tc_assert_json '.hookSpecificOutput.permissionDecision == "ask"' "ask (${engine}): the decision is ask"
        hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "This edit lowers a gate. Confirm with the user." \
            "ask (${engine}): the reason is kept"
        tc_assert_empty "$ERR" "ask (${engine}): nothing on stderr"
    done
    tc_env
}

case_context() {
    local engine event
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        for event in PreToolUse PostToolUse Stop SubagentStop; do
            run_hj vse_hj_context "$event" "Story US_001 has no feature file yet."
            tc_assert_rc 0 "context (${engine}, ${event}): exit 0"
            tc_assert_json "$HJ_CONTEXT_SHAPE" "context (${engine}, ${event}): one object, hookSpecificOutput only"
            hj_assert_value '.hookSpecificOutput.hookEventName' "$event" \
                "context (${engine}, ${event}): the event is named"
            hj_assert_value '.hookSpecificOutput.additionalContext' "Story US_001 has no feature file yet." \
                "context (${engine}, ${event}): the text is kept"
            tc_assert_empty "$ERR" "context (${engine}, ${event}): nothing on stderr"
        done
    done
    tc_env
}

case_system_message() {
    local engine
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj vse_hj_system_message "Record an ADR for this decision."
        tc_assert_rc 0 "system message (${engine}): exit 0"
        tc_assert_json "$HJ_SYSTEM_SHAPE" "system message (${engine}): one object, systemMessage only"
        hj_assert_value '.systemMessage' "Record an ADR for this decision." \
            "system message (${engine}): the text is kept"
        tc_assert_empty "$ERR" "system message (${engine}): nothing on stderr"
    done
    tc_env
}

# An empty text is still one object, so a caller never has to guard the
# call to keep the output valid.
case_empty_text() {
    local engine
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj vse_hj_context PostToolUse ""
        tc_assert_json "$HJ_CONTEXT_SHAPE and .hookSpecificOutput.additionalContext == \"\"" \
            "empty text (${engine}): an empty context is one object"
        run_hj vse_hj_deny PreToolUse ""
        tc_assert_json "$HJ_DENY_SHAPE and .hookSpecificOutput.permissionDecisionReason == \"\"" \
            "empty text (${engine}): an empty reason is one object"
        run_hj vse_hj_system_message ""
        tc_assert_json "$HJ_SYSTEM_SHAPE and .systemMessage == \"\"" \
            "empty text (${engine}): an empty system message is one object"
    done
    tc_env
}

case_tricky_strings() {
    local engine text label
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        for label in tricky trailing; do
            case "$label" in
                tricky) text="$HJ_TRICKY" ;;
                trailing) text="$HJ_TRAILING" ;;
            esac
            run_hj vse_hj_deny PreToolUse "$text"
            tc_assert_json "$HJ_DENY_SHAPE" "${label} (${engine}): deny is one valid object"
            hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "$text" \
                "${label} (${engine}): the deny reason survives byte for byte"
            run_hj vse_hj_ask PreToolUse "$text"
            hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "$text" \
                "${label} (${engine}): the ask reason survives byte for byte"
            run_hj vse_hj_context PostToolUse "$text"
            tc_assert_json "$HJ_CONTEXT_SHAPE" "${label} (${engine}): context is one valid object"
            hj_assert_value '.hookSpecificOutput.additionalContext' "$text" \
                "${label} (${engine}): the context survives byte for byte"
            run_hj vse_hj_system_message "$text"
            tc_assert_json "$HJ_SYSTEM_SHAPE" "${label} (${engine}): the system message is one valid object"
            hj_assert_value '.systemMessage' "$text" \
                "${label} (${engine}): the system message survives byte for byte"
        done
    done
    tc_env
}

# A byte that is not valid UTF-8 becomes U+FFFD, so the object is valid
# UTF-8 JSON whatever the hook passes in.
case_invalid_utf8() {
    local engine
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj vse_hj_context PostToolUse "$(printf 'caf\351 ok')"
        tc_assert_json "$HJ_CONTEXT_SHAPE" "invalid UTF-8 (${engine}): one valid object"
        tc_assert_json '.hookSpecificOutput.additionalContext == "caf� ok"' \
            "invalid UTF-8 (${engine}): the stray byte becomes U+FFFD"
        tc_assert_not_grep '\udc' "$OUT" \
            "invalid UTF-8 (${engine}): the stray byte is not passed on as a lone surrogate"
    done
    tc_env
}

# The python3 engine decodes its arguments by the locale. A C locale
# still keeps every non-ASCII character.
case_c_locale() {
    tc_env PATH="$HJ_BIN_NO_JQ" LC_ALL=C LANG=C
    run_hj vse_hj_context PostToolUse "$HJ_TRICKY"
    hj_assert_value '.hookSpecificOutput.additionalContext' "$HJ_TRICKY" \
        "C locale (python3): the text survives byte for byte"
    tc_env PATH="$HJ_BIN_NO_PYTHON" LC_ALL=C LANG=C
    run_hj vse_hj_context PostToolUse "$HJ_TRICKY"
    hj_assert_value '.hookSpecificOutput.additionalContext' "$HJ_TRICKY" \
        "C locale (jq): the text survives byte for byte"
    tc_env
}

# ------------------------------------------------------------ clipping

# hj_repeat <string> <count>: the string repeated, on stdout.
hj_repeat() {
    local i=0 s=""
    while [ "$i" -lt "$2" ]; do
        s="${s}$1"
        i=$((i + 1))
    done
    printf '%s' "$s"
}

# The deny reasons stay under 1,500 characters, so the longest reason
# kept whole is 1,499 characters, and a clipped one is its first 1,490
# characters and "…and more" (9 characters), 1,499 in all.
case_clip() {
    local engine a1490 a1499 a1500 a1600 e1490 e1600 long
    a1490="$(hj_repeat a 1490)"
    a1499="$(hj_repeat a 1499)"
    a1500="${a1499}a"
    a1600="$(hj_repeat a 1600)"
    e1490="$(hj_repeat 'é' 1490)"
    e1600="$(hj_repeat 'é' 1600)"
    long="$(hj_repeat 'context ' 400)"
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj vse_hj_deny PreToolUse "$a1499"
        hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "$a1499" \
            "clip (${engine}): a reason of exactly 1,499 characters is kept"
        run_hj vse_hj_deny PreToolUse "$a1500"
        hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "${a1490}…and more" \
            "clip (${engine}): a reason of 1,500 characters is clipped"
        tc_assert_json '.hookSpecificOutput.permissionDecisionReason | length == 1499' \
            "clip (${engine}): a reason of 1,500 characters is clipped to 1,499"
        run_hj vse_hj_deny PreToolUse "$a1600"
        hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "${a1490}…and more" \
            "clip (${engine}): a long reason ends in …and more"
        tc_assert_json '.hookSpecificOutput.permissionDecisionReason | length == 1499' \
            "clip (${engine}): a clipped reason is 1,499 characters"
        run_hj vse_hj_ask PreToolUse "$a1600"
        hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "${a1490}…and more" \
            "clip (${engine}): an ask reason is clipped too"
        run_hj vse_hj_deny PreToolUse "$e1600"
        hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "${e1490}…and more" \
            "clip (${engine}): the limit counts characters, not bytes"
        run_hj vse_hj_context PostToolUse "$long"
        hj_assert_value '.hookSpecificOutput.additionalContext' "$long" \
            "clip (${engine}): context is not clipped"
        run_hj vse_hj_system_message "$long"
        hj_assert_value '.systemMessage' "$long" \
            "clip (${engine}): a system message is not clipped"
    done
    tc_env
}

# --------------------------------------------------------- no JSON tool

# With neither jq nor python3 the text cannot be encoded safely, so a
# fixed literal stands in for it. The decision and the event survive,
# because both are fixed words the library checks. The user is told
# through systemMessage, and the original text goes to stderr.
case_no_json_tool() {
    hj_engine none
    run_hj vse_hj_deny PreToolUse "$HJ_TRICKY"
    tc_assert_rc 0 "no JSON tool: deny exits 0"
    tc_assert_json '.hookSpecificOutput.hookEventName == "PreToolUse"
        and .hookSpecificOutput.permissionDecision == "deny"
        and (.hookSpecificOutput.permissionDecisionReason | test("neither jq nor python3"))
        and (.systemMessage | test("neither jq nor python3"))' \
        "no JSON tool: deny stays a deny with a fixed reason and a system message"
    tc_assert_grep "say \"hi\"" "$ERR" "no JSON tool: the deny reason goes to stderr"
    tc_assert_not_grep "say" "$OUT" "no JSON tool: the deny reason is not on stdout"

    run_hj vse_hj_ask PreToolUse "Confirm this."
    tc_assert_json '.hookSpecificOutput.permissionDecision == "ask"
        and (.hookSpecificOutput.permissionDecisionReason | test("neither jq nor python3"))' \
        "no JSON tool: ask stays an ask"

    run_hj vse_hj_context Stop "Story US_001 has no feature file yet."
    tc_assert_rc 0 "no JSON tool: context exits 0"
    tc_assert_json '(.hookSpecificOutput | keys_unsorted == ["hookEventName", "additionalContext"])
        and .hookSpecificOutput.hookEventName == "Stop"
        and (.hookSpecificOutput.additionalContext | test("neither jq nor python3"))
        and (.systemMessage | test("neither jq nor python3"))' \
        "no JSON tool: context is a fixed additionalContext plus a system message"
    tc_assert_grep "Story US_001 has no feature file yet." "$ERR" "no JSON tool: the context goes to stderr"

    run_hj vse_hj_system_message "Record an ADR."
    tc_assert_json '(keys_unsorted == ["systemMessage"]) and (.systemMessage | test("neither jq nor python3"))' \
        "no JSON tool: a system message is a fixed system message"
    tc_assert_grep "Record an ADR." "$ERR" "no JSON tool: the system message goes to stderr"
    tc_env
}

# ------------------------------------------------------------ fallback

# A jq that exits non-zero hands over to python3, and a python3 that
# fails (the macOS stub that asks for the developer tools does this)
# hands over to the literal. The output is valid in every case.
case_failing_engine_falls_back() {
    tc_reset_stubs
    tc_stub jq <<'EOF'
#!/usr/bin/env bash
echo "jq: simulated failure" >&2
exit 5
EOF
    tc_env PATH="${STUBS}:${HJ_BIN_NO_JQ}"
    run_hj vse_hj_deny PreToolUse "$HJ_TRICKY"
    tc_assert_rc 0 "fallback: a failing jq still exits 0"
    tc_assert_json "$HJ_DENY_SHAPE" "fallback: a failing jq hands over to python3"
    hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "$HJ_TRICKY" \
        "fallback: python3 keeps the reason after jq fails"

    tc_stub jq <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    run_hj vse_hj_context PostToolUse "$HJ_TRICKY"
    tc_assert_json "$HJ_CONTEXT_SHAPE" "fallback: a jq that prints nothing hands over to python3"
    hj_assert_value '.hookSpecificOutput.additionalContext' "$HJ_TRICKY" \
        "fallback: python3 keeps the context after jq prints nothing"

    tc_stub jq <<'EOF'
#!/usr/bin/env bash
exit 5
EOF
    tc_stub python3 <<'EOF'
#!/usr/bin/env bash
echo "xcode-select: note: no developer tools were found" >&2
exit 1
EOF
    tc_env PATH="${STUBS}:${HJ_BIN_NO_JSON}"
    run_hj vse_hj_deny PreToolUse "$HJ_TRICKY"
    tc_assert_rc 0 "fallback: failing jq and python3 still exit 0"
    tc_assert_json '.hookSpecificOutput.permissionDecision == "deny"
        and (.systemMessage | test("neither jq nor python3"))' \
        "fallback: failing jq and python3 give the fixed literal"

    tc_reset_stubs
    tc_stub python3 <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
    tc_env PATH="${STUBS}:${HJ_BIN_NO_JSON}"
    run_hj vse_hj_context PostToolUse "text"
    tc_assert_json '.hookSpecificOutput.additionalContext | test("neither jq nor python3")' \
        "fallback: a failing python3 with no jq gives the fixed literal"
    tc_reset_stubs
    tc_env
}

# python3 runs in isolated mode, so a json.py in the hook's working
# directory (the user's project) is never imported in place of the
# standard library.
case_python_isolated() {
    printf 'import sys\nsys.stdout.write("HIJACKED")\nsys.exit(0)\n' > "${REPO}/json.py"
    tc_env PATH="$HJ_BIN_NO_JQ" PYTHONPATH="$REPO"
    run_hj vse_hj_context PostToolUse "safe"
    tc_assert_not_grep "HIJACKED" "$OUT" "isolated: a json.py in the working directory is not imported"
    hj_assert_value '.hookSpecificOutput.additionalContext' "safe" "isolated: the standard library encodes"
    rm -f "${REPO}/json.py"
    tc_env
}

# --------------------------------------------------------------- usage

# The event is part of a fixed literal, so it must be a plain word. A
# bad call prints nothing on stdout (the hook stays silent rather than
# invalid) and names the problem on stderr.
case_bad_event() {
    local fn event
    hj_engine jq
    for fn in vse_hj_deny vse_hj_ask vse_hj_context; do
        for event in "" 'Pre"Tool' 'Pre Tool'; do
            run_hj "$fn" "$event" "text"
            tc_assert_rc 64 "bad event: ${fn} '${event}' exits 64"
            tc_assert_json_silent "bad event: ${fn} '${event}' prints nothing on stdout"
            tc_assert_grep "[hook-json]" "$ERR" "bad event: ${fn} '${event}' names the problem on stderr"
        done
    done
    tc_env
}

# A call that leaves out an argument returns 64 with nothing on stdout,
# rather than ending the hook on an unbound variable under set -u.
case_missing_argument() {
    local call
    hj_engine jq
    while IFS= read -r call; do
        # The words of each call are split on purpose.
        # shellcheck disable=SC2086
        run_hj $call
        tc_assert_rc 64 "missing argument: '${call}' exits 64"
        tc_assert_json_silent "missing argument: '${call}' prints nothing on stdout"
        tc_assert_grep "[hook-json]" "$ERR" "missing argument: '${call}' names the problem on stderr"
    done <<'CALLS'
vse_hj_deny
vse_hj_deny PreToolUse
vse_hj_ask
vse_hj_ask PreToolUse
vse_hj_context
vse_hj_context PostToolUse
vse_hj_system_message
vse_hj_add_decision
vse_hj_add_decision deny
vse_hj_add_context
vse_hj_add_system_message
vse_hj_emit
vse_hj_read
vse_hj_read /dev/null
CALLS
    tc_env
}

# An emit refused for its event still starts again empty, so the
# findings of a refused call never leak into the next object.
case_emit_bad_event_clears() {
    hj_engine jq
    # shellcheck disable=SC2016  # expanded by the shell under test
    tc_run_in "$REPO" bash -c '
        . "$1"
        vse_hj_add_decision deny "Gone."
        vse_hj_add_context "Gone too."
        vse_hj_emit "Pre Tool" || echo "emit returned $?" >&2
        vse_hj_add_context "Kept."
        vse_hj_emit PostToolUse
    ' hj-driver "$HJ_LIB"
    tc_assert_rc 0 "bad event clears: exit 0"
    tc_assert_grep "emit returned 64" "$ERR" "bad event clears: the refused emit returns 64"
    tc_assert_json '(.hookSpecificOutput | keys_unsorted == ["hookEventName", "additionalContext"])
        and .hookSpecificOutput.additionalContext == "Kept."' \
        "bad event clears: the next object holds only what was added after the refused emit"
    tc_env
}

# ------------------------------------------------------- payload reads

# hj_payload <file>: the PreToolUse payload the read cases share, with
# fields of every JSON type and strings that break naive parsing.
hj_payload() {
    jq -n --arg path "$(printf 'docs/my "odd" café\tfile.sysml')" \
        --arg old "$HJ_TRICKY" --arg new "$HJ_TRAILING" '{
            tool_name: "Edit",
            tool_input: {
                file_path: $path,
                old_string: $old,
                new_string: $new,
                replace_all: false,
                count: 3,
                edits: [{old_string: "a"}],
                nothing: null
            },
            stop_hook_active: true
        }' > "$1"
}

# hj_read_to <engine> <payload> <path>: read into a file, so trailing
# newlines can be compared. Leaves the file in $HJ_READ.
HJ_READ=""
hj_read_to() {
    HJ_READ="$(tc_mktemp_d)/read"
    hj_engine "$1"
    tc_run_in "$REPO" bash -c "$HJ_FILE_DRIVER" hj-driver "$HJ_LIB" "$HJ_READ" vse_hj_read "$2" "$3"
}

# hj_assert_read <expected-string> <case>: $HJ_READ holds the string and
# one newline, byte for byte.
hj_assert_read() {
    local want="$1" name="$2" expected
    expected="$(tc_mktemp_d)/expected"
    printf '%s\n' "$want" > "$expected"
    if cmp -s "$expected" "$HJ_READ"; then
        tc_pass "$name"
    else
        tc_fail "$name" "expected bytes:
$(od -c "$expected" | head -n 8)
actual bytes:
$(od -c "$HJ_READ" | head -n 8)
$(_tc_context)"
    fi
}

case_read_strings() {
    local engine payload
    payload="$(tc_mktemp_d)/payload.json"
    hj_payload "$payload"
    for engine in $HJ_ENGINES; do
        hj_read_to "$engine" "$payload" .tool_name
        tc_assert_rc 0 "read (${engine}): exit 0"
        hj_assert_read "Edit" "read (${engine}): a top-level string"
        tc_assert_empty "$ERR" "read (${engine}): nothing on stderr"
        hj_read_to "$engine" "$payload" .tool_input.file_path
        hj_assert_read "$(printf 'docs/my "odd" café\tfile.sysml')" "read (${engine}): a nested string, quotes and tab kept"
        hj_read_to "$engine" "$payload" .tool_input.old_string
        hj_assert_read "$HJ_TRICKY" "read (${engine}): control characters and non-ASCII kept"
        hj_read_to "$engine" "$payload" .tool_input.new_string
        hj_assert_read "$HJ_TRAILING" "read (${engine}): trailing newlines kept"
    done
    tc_env
}

case_read_booleans() {
    local engine payload
    payload="$(tc_mktemp_d)/payload.json"
    hj_payload "$payload"
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj vse_hj_read "$payload" .stop_hook_active
        tc_assert_eq "true" "$OUT" "read (${engine}): true prints true"
        run_hj vse_hj_read "$payload" .tool_input.replace_all
        tc_assert_eq "false" "$OUT" "read (${engine}): false prints false"
    done
    tc_env
}

# A field that is absent, null, or not a string or a boolean prints
# nothing and is not an error, so a hook can treat an empty read as
# "not given".
case_read_absent() {
    local engine payload path array
    payload="$(tc_mktemp_d)/payload.json"
    hj_payload "$payload"
    array="$(tc_mktemp_d)/array.json"
    printf '[1, 2]\n' > "$array"
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        for path in .missing .tool_input.missing .tool_input.nothing .tool_input.count \
            .tool_input.edits .tool_input .tool_input.file_path.deeper .missing.deeper; do
            run_hj vse_hj_read "$payload" "$path"
            tc_assert_rc 0 "read absent (${engine}): ${path} exits 0"
            tc_assert_json_silent "read absent (${engine}): ${path} prints nothing"
            tc_assert_empty "$ERR" "read absent (${engine}): ${path} is silent on stderr"
        done
        run_hj vse_hj_read "$array" .tool_name
        tc_assert_rc 0 "read absent (${engine}): a payload that is not an object exits 0"
        tc_assert_json_silent "read absent (${engine}): a payload that is not an object prints nothing"
    done
    tc_env
}

case_read_bad_payload() {
    local engine dir
    dir="$(tc_mktemp_d)"
    printf '{"tool_name": "Edit",' > "${dir}/truncated.json"
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj vse_hj_read "${dir}/truncated.json" .tool_name
        tc_assert_rc 2 "read bad payload (${engine}): a malformed payload exits 2"
        tc_assert_json_silent "read bad payload (${engine}): a malformed payload prints nothing"
        tc_assert_grep "[hook-json]" "$ERR" "read bad payload (${engine}): a malformed payload is named on stderr"
        run_hj vse_hj_read "${dir}/absent.json" .tool_name
        tc_assert_rc 2 "read bad payload (${engine}): a missing payload exits 2"
        tc_assert_json_silent "read bad payload (${engine}): a missing payload prints nothing"
    done
    tc_env
}

# A payload is exactly one JSON value. An empty payload (a hook run by
# hand, or with stdin from /dev/null) and a payload of two values are
# errors with either engine, never a silent "field absent" that a deny
# gate would read as an allow.
case_read_not_one_value() {
    local engine dir name
    dir="$(tc_mktemp_d)"
    : > "${dir}/empty.json"
    printf ' \n\t\n' > "${dir}/blank.json"
    printf '{"tool_name":"a"}{"tool_name":"b"}' > "${dir}/two.json"
    printf '{"tool_name":"a"}\n{"tool_name":"b"}\n' > "${dir}/two-lines.json"
    printf '{"tool_name":"a"} 1' > "${dir}/trailing.json"
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        for name in empty blank two two-lines trailing; do
            run_hj vse_hj_read "${dir}/${name}.json" .tool_name
            tc_assert_rc 2 "read not one value (${engine}): the ${name} payload exits 2"
            tc_assert_json_silent "read not one value (${engine}): the ${name} payload prints nothing"
            tc_assert_grep "[hook-json]" "$ERR" "read not one value (${engine}): the ${name} payload is named on stderr"
        done
        run_hj vse_hj_read /dev/null .tool_name
        tc_assert_rc 2 "read not one value (${engine}): /dev/null as the payload exits 2"
        tc_assert_json_silent "read not one value (${engine}): /dev/null as the payload prints nothing"
    done
    tc_env
}

# A byte that is not valid UTF-8 reads as U+FFFD with either engine.
case_read_invalid_utf8() {
    local engine payload
    payload="$(tc_mktemp_d)/payload.json"
    printf '{"tool_name": "caf\351"}' > "$payload"
    for engine in $HJ_ENGINES; do
        hj_read_to "$engine" "$payload" .tool_name
        tc_assert_rc 0 "read invalid UTF-8 (${engine}): exit 0"
        hj_assert_read "$(printf 'caf\357\277\275')" "read invalid UTF-8 (${engine}): the stray byte reads as U+FFFD"
    done
    tc_env
}

# The path is a dot and one or more names joined by dots, so no jq
# program and no Python expression can be passed in through it.
case_read_bad_path() {
    local payload path
    payload="$(tc_mktemp_d)/payload.json"
    hj_payload "$payload"
    hj_engine jq
    # The last path is jq's own location variable, kept literal.
    # shellcheck disable=SC2016
    for path in "" tool_name . .tool_input. .tool_input..file_path '.edits[0]' \
        '.tool_name | input' '.1st' '.tool-name' '.$__loc__'; do
        run_hj vse_hj_read "$payload" "$path"
        tc_assert_rc 64 "read bad path: '${path}' exits 64"
        tc_assert_json_silent "read bad path: '${path}' prints nothing"
        tc_assert_grep "[hook-json]" "$ERR" "read bad path: '${path}' is named on stderr"
    done
    tc_env
}

case_read_no_json_tool() {
    local payload
    payload="$(tc_mktemp_d)/payload.json"
    hj_payload "$payload"
    hj_engine none
    run_hj vse_hj_read "$payload" .tool_name
    tc_assert_rc 3 "read, no JSON tool: exit 3"
    tc_assert_json_silent "read, no JSON tool: nothing printed"
    tc_assert_grep "neither jq nor python3" "$ERR" "read, no JSON tool: the reason is on stderr"
    tc_env
}

# A jq that fails hands the read over to python3, as the encoder does.
# When no engine works the read returns 3, as when neither is present.
case_read_failing_engine_falls_back() {
    local payload dir
    payload="$(tc_mktemp_d)/payload.json"
    hj_payload "$payload"
    dir="$(tc_mktemp_d)"
    printf '{"tool_name": "Edit",' > "${dir}/truncated.json"
    tc_reset_stubs
    tc_stub jq <<'STUB'
#!/usr/bin/env bash
echo "jq: simulated failure" >&2
exit 5
STUB
    tc_env PATH="${STUBS}:${HJ_BIN_NO_JQ}"
    run_hj vse_hj_read "$payload" .tool_name
    tc_assert_rc 0 "read fallback: a failing jq hands over to python3"
    tc_assert_eq "Edit" "$OUT" "read fallback: python3 reads the field"
    run_hj vse_hj_read "${dir}/truncated.json" .tool_name
    tc_assert_rc 2 "read fallback: a malformed payload still exits 2 after the hand-over"

    tc_stub python3 <<'STUB'
#!/usr/bin/env bash
echo "xcode-select: note: no developer tools were found" >&2
exit 1
STUB
    tc_env PATH="${STUBS}:${HJ_BIN_NO_JSON}"
    run_hj vse_hj_read "$payload" .tool_name
    tc_assert_rc 3 "read fallback: failing jq and python3 exit 3"
    tc_assert_json_silent "read fallback: failing jq and python3 print nothing"
    tc_assert_grep "[hook-json]" "$ERR" "read fallback: failing jq and python3 are named on stderr"

    rm -f "${STUBS}/jq"
    run_hj vse_hj_read "$payload" .tool_name
    tc_assert_rc 3 "read fallback: a failing python3 with no jq exits 3"

    tc_reset_stubs
    tc_env
    run_hj vse_hj_read "${dir}/truncated.json" .tool_name
    tc_assert_rc 2 "read fallback: with both engines a malformed payload exits 2"
}

# A payload that starts with a UTF-8 byte order mark (some Windows
# editors write one) reads the same with either engine.
case_read_byte_order_mark() {
    local engine payload
    payload="$(tc_mktemp_d)/payload.json"
    printf '\357\273\277{"tool_name": "Edit"}' > "$payload"
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj vse_hj_read "$payload" .tool_name
        tc_assert_rc 0 "read byte order mark (${engine}): exit 0"
        tc_assert_eq "Edit" "$OUT" "read byte order mark (${engine}): the field is read"
    done
    tc_env
}

case_read_python_isolated() {
    local payload
    payload="$(tc_mktemp_d)/payload.json"
    hj_payload "$payload"
    printf 'import sys\nsys.stdout.write("HIJACKED")\nsys.exit(0)\n' > "${REPO}/json.py"
    tc_env PATH="$HJ_BIN_NO_JQ" PYTHONPATH="$REPO"
    run_hj vse_hj_read "$payload" .tool_name
    tc_assert_eq "Edit" "$OUT" "read, isolated: a json.py in the working directory is not imported"
    rm -f "${REPO}/json.py"
    tc_env
}

# --------------------------------------------------------- accumulator

# A hook often has several findings in one call, such as a deny for one
# story and a warning for another, and stdout carries one object. The
# accumulator gathers them and vse_hj_emit prints the one object.

HJ_FULL_SHAPE='(keys_unsorted == ["hookSpecificOutput", "systemMessage"])
    and (.hookSpecificOutput | keys_unsorted == ["hookEventName", "permissionDecision", "permissionDecisionReason", "additionalContext"])'

case_accumulate_combined() {
    local engine
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj_seq vse_hj_add_context "First finding." ';;' \
            vse_hj_add_decision deny "Write the feature file first." ';;' \
            vse_hj_add_context "Second finding." ';;' \
            vse_hj_add_system_message "Note one." ';;' \
            vse_hj_add_system_message "Note two." ';;' \
            vse_hj_emit PreToolUse
        tc_assert_rc 0 "accumulate (${engine}): exit 0"
        tc_assert_json "$HJ_FULL_SHAPE" "accumulate (${engine}): one object with every part"
        tc_assert_json '.hookSpecificOutput.hookEventName == "PreToolUse"
            and .hookSpecificOutput.permissionDecision == "deny"' \
            "accumulate (${engine}): the event and the decision"
        hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "Write the feature file first." \
            "accumulate (${engine}): the reason"
        hj_assert_value '.hookSpecificOutput.additionalContext' "$(printf 'First finding.\n\nSecond finding.')" \
            "accumulate (${engine}): contexts are paragraphs in call order"
        hj_assert_value '.systemMessage' "$(printf 'Note one.\nNote two.')" \
            "accumulate (${engine}): system messages are lines in call order"
        tc_assert_empty "$ERR" "accumulate (${engine}): nothing on stderr"

        run_hj_seq vse_hj_add_context "$HJ_TRICKY" ';;' \
            vse_hj_add_decision ask "$HJ_TRAILING" ';;' \
            vse_hj_emit PreToolUse
        hj_assert_value '.hookSpecificOutput.additionalContext' "$HJ_TRICKY" \
            "accumulate (${engine}): a tricky context survives byte for byte"
        hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "$HJ_TRAILING" \
            "accumulate (${engine}): trailing newlines in a reason survive"
    done
    tc_env
}

case_accumulate_partial() {
    local engine
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj_seq vse_hj_add_context "Only context." ';;' vse_hj_emit Stop
        tc_assert_json "$HJ_CONTEXT_SHAPE and .hookSpecificOutput.hookEventName == \"Stop\"" \
            "accumulate partial (${engine}): context alone is a context object"
        run_hj_seq vse_hj_add_system_message "Only a note." ';;' vse_hj_emit SubagentStop
        tc_assert_json "$HJ_SYSTEM_SHAPE and .systemMessage == \"Only a note.\"" \
            "accumulate partial (${engine}): a system message alone has no hookSpecificOutput"
        run_hj_seq vse_hj_add_decision deny "No." ';;' vse_hj_emit PreToolUse
        tc_assert_json "$HJ_DENY_SHAPE" "accumulate partial (${engine}): a decision alone is a decision object"
        run_hj_seq vse_hj_add_context "" ';;' vse_hj_add_system_message "" ';;' vse_hj_emit PostToolUse
        tc_assert_rc 0 "accumulate partial (${engine}): empty additions exit 0"
        tc_assert_json_silent "accumulate partial (${engine}): empty additions add nothing"
    done
    tc_env
}

case_accumulate_nothing() {
    hj_engine jq
    run_hj vse_hj_emit PreToolUse
    tc_assert_rc 0 "accumulate nothing: exit 0"
    tc_assert_json_silent "accumulate nothing: a hook with nothing to say prints nothing"
    tc_assert_empty "$ERR" "accumulate nothing: nothing on stderr"
    tc_env
}

# A deny outranks an ask. Reasons of the same decision are paragraphs
# in call order, and a weaker decision's reason is dropped.
case_accumulate_decisions() {
    local engine
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj_seq vse_hj_add_decision deny "Deny one." ';;' \
            vse_hj_add_decision ask "Ask one." ';;' vse_hj_emit PreToolUse
        tc_assert_json '.hookSpecificOutput.permissionDecision == "deny"
            and .hookSpecificOutput.permissionDecisionReason == "Deny one."' \
            "decisions (${engine}): an ask after a deny is dropped"
        run_hj_seq vse_hj_add_decision ask "Ask one." ';;' \
            vse_hj_add_decision deny "Deny one." ';;' vse_hj_emit PreToolUse
        tc_assert_json '.hookSpecificOutput.permissionDecision == "deny"
            and .hookSpecificOutput.permissionDecisionReason == "Deny one."' \
            "decisions (${engine}): a deny after an ask replaces it"
        run_hj_seq vse_hj_add_decision deny "Deny one." ';;' \
            vse_hj_add_decision deny "Deny two." ';;' vse_hj_emit PreToolUse
        hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "$(printf 'Deny one.\n\nDeny two.')" \
            "decisions (${engine}): two denies give both reasons"
        run_hj_seq vse_hj_add_decision ask "Ask one." ';;' \
            vse_hj_add_decision ask "Ask two." ';;' vse_hj_emit PreToolUse
        tc_assert_json '.hookSpecificOutput.permissionDecision == "ask"' \
            "decisions (${engine}): two asks stay an ask"
        hj_assert_value '.hookSpecificOutput.permissionDecisionReason' "$(printf 'Ask one.\n\nAsk two.')" \
            "decisions (${engine}): two asks give both reasons"
    done
    tc_env
}

# The joined reasons are clipped as one reason.
case_accumulate_clip() {
    local engine a1000
    a1000="$(hj_repeat a 1000)"
    for engine in $HJ_ENGINES; do
        hj_engine "$engine"
        run_hj_seq vse_hj_add_decision deny "$a1000" ';;' \
            vse_hj_add_decision deny "$a1000" ';;' vse_hj_emit PreToolUse
        tc_assert_json '.hookSpecificOutput.permissionDecisionReason | length == 1499' \
            "accumulate clip (${engine}): joined reasons are clipped to 1,499 characters"
        hj_assert_value '.hookSpecificOutput.permissionDecisionReason' \
            "${a1000}"$'\n\n'"${a1000:0:488}…and more" \
            "accumulate clip (${engine}): the clipped reason ends in …and more"
    done
    tc_env
}

# vse_hj_emit prints the object and starts again, so a second emit with
# nothing added prints nothing, and findings added after an emit belong
# to the next object only.
case_accumulate_emit_clears() {
    hj_engine jq
    run_hj_seq vse_hj_add_context "First." ';;' vse_hj_emit PostToolUse ';;' vse_hj_emit PostToolUse
    tc_assert_line_count 1 "$OUT" "emit clears: a second emit with nothing added prints nothing"
    run_hj_seq vse_hj_add_decision deny "Gone." ';;' vse_hj_add_context "First." ';;' vse_hj_emit PreToolUse ';;' \
        vse_hj_add_context "Second." ';;' vse_hj_emit PreToolUse
    tc_assert_line_count 2 "$OUT" "emit clears: two emits print two objects"
    if printf '%s\n' "$OUT" | sed -n 2p \
        | jq -e '(.hookSpecificOutput | keys_unsorted == ["hookEventName", "additionalContext"])
            and .hookSpecificOutput.additionalContext == "Second."' > /dev/null 2>&1; then
        tc_pass "emit clears: the second object holds only what was added after the first emit"
    else
        tc_fail "emit clears: the second object holds only what was added after the first emit" "$(_tc_context)"
    fi
    tc_env
}

case_accumulate_usage() {
    local event
    hj_engine jq
    for event in "" 'Pre"Tool'; do
        run_hj_seq vse_hj_add_context "text" ';;' vse_hj_emit "$event"
        tc_assert_rc 64 "accumulate usage: emit with event '${event}' exits 64"
        tc_assert_json_silent "accumulate usage: emit with event '${event}' prints nothing"
        tc_assert_grep "[hook-json]" "$ERR" "accumulate usage: emit with event '${event}' names the problem"
    done
    run_hj_seq vse_hj_add_decision allow "Fine." ';;' vse_hj_emit PreToolUse
    tc_assert_rc 64 "accumulate usage: allow is not a decision the library emits"
    tc_assert_json_silent "accumulate usage: allow prints nothing"
    tc_assert_grep "[hook-json]" "$ERR" "accumulate usage: allow names the problem"
    tc_env
}

case_accumulate_no_json_tool() {
    hj_engine none
    run_hj_seq vse_hj_add_context "First finding." ';;' \
        vse_hj_add_decision deny "Write the feature file first." ';;' \
        vse_hj_add_system_message "Note one." ';;' \
        vse_hj_emit PreToolUse
    tc_assert_rc 0 "accumulate, no JSON tool: exit 0"
    tc_assert_json "$HJ_FULL_SHAPE
        and .hookSpecificOutput.permissionDecision == \"deny\"
        and (.hookSpecificOutput.permissionDecisionReason | test(\"neither jq nor python3\"))
        and (.hookSpecificOutput.additionalContext | test(\"neither jq nor python3\"))
        and (.systemMessage | test(\"neither jq nor python3\"))" \
        "accumulate, no JSON tool: the fixed literal keeps the deny"
    tc_assert_grep "Write the feature file first." "$ERR" "accumulate, no JSON tool: the reason goes to stderr"
    tc_assert_grep "First finding." "$ERR" "accumulate, no JSON tool: the context goes to stderr"
    tc_assert_grep "Note one." "$ERR" "accumulate, no JSON tool: the system message goes to stderr"
    tc_env
}

case_deny
case_ask
case_context
case_system_message
case_empty_text
case_tricky_strings
case_invalid_utf8
case_c_locale
case_clip
case_no_json_tool
case_failing_engine_falls_back
case_python_isolated
case_bad_event
case_missing_argument
case_emit_bad_event_clears
case_read_strings
case_read_booleans
case_read_absent
case_read_bad_payload
case_read_not_one_value
case_read_invalid_utf8
case_read_bad_path
case_read_no_json_tool
case_read_failing_engine_falls_back
case_read_byte_order_mark
case_read_python_isolated
case_accumulate_combined
case_accumulate_partial
case_accumulate_nothing
case_accumulate_decisions
case_accumulate_clip
case_accumulate_emit_clears
case_accumulate_usage
case_accumulate_no_json_tool

if tc_summary "test-hook-json"; then
    exit 0
fi
exit 1
