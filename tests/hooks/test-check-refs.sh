#!/usr/bin/env bash
# Behavioural tests for the check-refs Makefile target, which proves
# that every ${CLAUDE_PLUGIN_ROOT}/<path> reference in a harness-loaded
# component (a skill, a command, an agent, hooks.json) resolves inside
# the plugin tree.
#
# Each case builds a scratch plugin tree that holds the working-tree
# Makefile and small stand-ins for the components and the files they
# name, and runs the target. Every case runs twice, once with the grep
# of the machine and once with the BSD grep stub first on PATH, which
# refuses -P the way macOS grep does. A target that reads the
# references with a GNU-only grep then finds none on the stub run, and
# a scan that finds no reference at all is an error rather than a
# vacuous pass.
#
# Run: bash tests/hooks/test-check-refs.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

# The BSD grep stub, written once into its own directory.
STUBS="$(tc_mktemp_d)"
tc_stub_bsd_grep
BSD_PATH="${STUBS}:${PATH}"

# A scratch plugin tree with the Makefile, one skill and the files a
# reference may name. The skill body comes from stdin.
fresh() {
    REPO="$(tc_mktemp_d)"
    cp "${TC_PLUGIN_ROOT}/Makefile" "${REPO}/"
    mkdir -p "${REPO}/skills/demo" "${REPO}/templates/present-dir" "${REPO}/hooks"
    printf 'present\n' > "${REPO}/templates/present.md"
    printf '#!/usr/bin/env bash\n' > "${REPO}/hooks/session-start.sh"
    cat > "${REPO}/skills/demo/SKILL.md"
}

# run_target <machine|bsd>
run_target() {
    local path="$PATH"
    if [ "$1" = bsd ]; then
        path="$BSD_PATH"
    fi
    _tc_capture _tc_in_dir "$REPO" env -u MAKEFLAGS -u MAKELEVEL -u MFLAGS \
        -u CLAUDE_PLUGIN_ROOT PATH="$path" \
        make --no-print-directory check-refs
}

# --------------------------------------------- references that resolve

# Every component kind is read: a skill, a command, an agent and
# hooks.json. A file reference and a directory reference both count.
case_all_resolve() {
    local grep_kind="$1" label="all references resolve (${1} grep)"
    fresh <<'EOF'
---
name: demo
description: A stand-in skill.
---
Read ${CLAUDE_PLUGIN_ROOT}/templates/present.md first
Copy ${CLAUDE_PLUGIN_ROOT}/templates/present-dir/ into the project
EOF
    mkdir -p "${REPO}/commands" "${REPO}/agents"
    cat > "${REPO}/commands/run.md" <<'EOF'
See ${CLAUDE_PLUGIN_ROOT}/templates/present.md for the layout
EOF
    cat > "${REPO}/agents/helper.md" <<'EOF'
Use ${CLAUDE_PLUGIN_ROOT}/templates/present-dir/ here
EOF
    cat > "${REPO}/hooks.json" <<'EOF'
{ "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh\"" }
EOF
    run_target "$grep_kind"
    tc_assert_rc 0 "${label}: the target passes"
    tc_assert_not_grep "ERROR" "$OUT" "${label}: no error"
    tc_assert_not_grep "WARNING" "$OUT" "${label}: no warning"
    tc_assert_line "  Checked 5 plugin-root references." "$OUT" \
        "${label}: every reference is counted"
}

# ------------------------------------------------- a missing file fails

case_missing_file() {
    local grep_kind="$1" label="a missing file (${1} grep)"
    fresh <<'EOF'
Read ${CLAUDE_PLUGIN_ROOT}/templates/present.md and
${CLAUDE_PLUGIN_ROOT}/templates/absent.md before you start
EOF
    run_target "$grep_kind"
    tc_assert_rc 2 "${label}: the target fails"
    tc_assert_line "ERROR: skills/demo/SKILL.md references templates/absent.md which does not exist" \
        "$OUT" "${label}: the reference is named"
    tc_assert_line "  Checked 2 plugin-root references." "$OUT" \
        "${label}: both references are counted"
}

# ------------------------------------- a missing directory is a warning

case_missing_directory() {
    local grep_kind="$1" label="a missing directory (${1} grep)"
    fresh <<'EOF'
Read ${CLAUDE_PLUGIN_ROOT}/templates/present.md and copy
${CLAUDE_PLUGIN_ROOT}/templates/absent-dir/ when it exists.
EOF
    run_target "$grep_kind"
    tc_assert_rc 0 "${label}: the target passes"
    tc_assert_line "WARNING: skills/demo/SKILL.md references directory templates/absent-dir/ which does not exist" \
        "$OUT" "${label}: the reference is named as a warning"
    tc_assert_not_grep "ERROR" "$OUT" "${label}: no error"
    tc_assert_line "  Checked 2 plugin-root references." "$OUT" \
        "${label}: both references are counted"
}

# ------------------------------------------- no reference at all fails

# Every shipped skill names at least one plugin-root path, so a scan
# that finds none has read nothing, and passing it would hide that.
case_no_reference() {
    local grep_kind="$1" label="no reference at all (${1} grep)"
    fresh <<'EOF'
A skill body that names no plugin-root path.
EOF
    run_target "$grep_kind"
    tc_assert_rc 2 "${label}: the target fails"
    tc_assert_line "  Checked 0 plugin-root references." "$OUT" \
        "${label}: the count is zero"
    tc_assert_line "ERROR: found no plugin-root reference to check, so the check proved nothing" \
        "$OUT" "${label}: the reason is stated"
}

for grep_kind in machine bsd; do
    case_all_resolve "$grep_kind"
    case_missing_file "$grep_kind"
    case_missing_directory "$grep_kind"
    case_no_reference "$grep_kind"
done

if tc_summary "test-check-refs"; then
    exit 0
fi
exit 1
