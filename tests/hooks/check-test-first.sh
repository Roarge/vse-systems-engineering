#!/usr/bin/env bash
# Test before code for the plugin's own development
# (.claude/rules/tdd-bdd.md). A range that changes a code path shall
# also change a test path.
#
# The paths come from tests/test-first.yaml, which uses the schema of a
# VSE project's test_first record (methodology §11.5.2). Every changed
# path is classified by the library the project-side gates use
# (hooks/lib/test-first.sh), so a test_paths glob wins over a
# code_paths glob, a "*" matches any characters, "/" included, and a
# *.feature file is never code or test. The library also never treats
# docs/generated/, tools/render/ or tools/lint/ under the
# configuration's directory as code. Here that directory is tests/,
# which holds none of them.
#
# Usage: bash tests/hooks/check-test-first.sh [<range>]
#
# The range is a git diff range: the first argument, else
# VSE_PRECOMMIT_RANGE, else origin/main...HEAD (the branch's changes
# since it left main). A deleted file is neither code nor test. The
# check reads the repository that holds the working directory, with
# the libraries of the plugin checkout this script belongs to.
#
# On a branch that matches test_first.refactor_branches (default
# refactor/*), code that changed with no change to a test path draws a
# notice instead of the finding, because a refactor keeps the behaviour
# and the tests that pin it. The branch is GITHUB_HEAD_REF when it is
# set, because CI checks a pull request out as a detached merge
# commit, and otherwise the branch checked out.
#
# Exit codes: 0 when no code path changed, a test path changed too, or
# the branch is a refactor branch, 1 when code changed with no change
# to a test path, 2 when the configuration is missing or names no
# code_paths, or git cannot read the range.
set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../hooks/lib" > /dev/null && pwd)"
RANGE="${1:-${VSE_PRECOMMIT_RANGE:-origin/main...HEAD}}"
CONFIG=tests/test-first.yaml

if ! TOP="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    echo "[check-test-first] Run the check inside a git checkout." >&2
    exit 2
fi
cd "$TOP"

if [ ! -f "$CONFIG" ] || [ ! -r "$CONFIG" ]; then
    echo "[check-test-first] ${CONFIG} is missing or unreadable, so no path can be classified." >&2
    exit 2
fi

# The libraries read the configuration named here, relative to the
# top level, which is now the working directory.
export VSE_ISO_CONFIG="$CONFIG"
# shellcheck source=/dev/null
. "${LIB_DIR}/iso-profile.sh"
# shellcheck source=/dev/null
. "${LIB_DIR}/test-first.sh"

# Without code_paths every path is other, and the check would pass
# having watched nothing.
_vse_tf_load
if [ -z "$_VSE_TF_CODE_GLOBS" ]; then
    echo "[check-test-first] ${CONFIG} names no test_first.code_paths, so no path can be code." >&2
    exit 2
fi

# git writes NUL-delimited names, so a space in a name arrives intact.
if ! CHANGED="$(git diff --name-only --diff-filter=ACMR -z "$RANGE" -- 2>/dev/null | tr '\0' '\n')"; then
    echo "[check-test-first] git cannot list the files changed by the range '${RANGE}'. Pass a range git can read, such as origin/main...HEAD, as the first argument or in VSE_PRECOMMIT_RANGE." >&2
    exit 2
fi

CODE=""
TESTS=""
while IFS= read -r path; do
    [ -n "$path" ] || continue
    _vse_tf_kind "$path"
    case "$_VSE_TF_KIND" in
        code) CODE="${CODE}  code: ${path}"$'\n' ;;
        test) TESTS="${TESTS}  test: ${path}"$'\n' ;;
    esac
done <<EOF
$CHANGED
EOF

echo "[check-test-first] Range ${RANGE}, paths from ${CONFIG}."
printf '%s' "${CODE}${TESTS}"
if [ -z "$CODE" ]; then
    echo "[check-test-first] No code path changed."
    exit 0
fi
if [ -n "$TESTS" ]; then
    echo "[check-test-first] Code and test paths both changed."
    exit 0
fi
if vse_tf_refactor_branch "$TOP" "${GITHUB_HEAD_REF:-}"; then
    echo "[check-test-first] Notice: refactor branch: run the tests before and after, no behaviour change."
    exit 0
fi
echo "ERROR: code changed with no change to a test path. Write the failing test first, then the code (methodology §11.7)."
exit 1
