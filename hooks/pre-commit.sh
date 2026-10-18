#!/usr/bin/env bash
# Project-side git pre-commit hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §4.1 and methodology §11.9.
# Four concerns:
#   1. precommit_lint: SysML lint on staged .sysml files through
#      lib/sysml-toolchain.sh (preferred toolchain, automatic fallback,
#      never silent).
#   2. The story lint, tools/lint/story-wellformed.py under the
#      engineering root, over every stories directory that a changed
#      .sysml or .feature file under stories/ touches, and over every
#      changed .feature file under model/ that sits outside stories/,
#      so that F10 reports it. A .feature file outside model/ is the
#      project's own, such as a Cucumber feature for its code, and is
#      left alone. precommit_story_wellformed runs the lint with --only
#      wellformed (§1.9), precommit_gherkin with --only gherkin
#      (§11.9.1).
#   3. precommit_traceability: traceability integrity, delegated to
#      pre-commit-traceability.sh.
#   4. precommit_test_first: test before code (§11.9), through
#      lib/test-first.sh.
#
# Each concern carries a disposition drawn from the project rigour
# profile and any per-gate override, per methodology §0.10.4. block
# reports and stops the commit, warn reports and lets it through, info
# prints one summary line, off skips the gate. precommit_gherkin and
# precommit_test_first block at every profile until an override lowers
# them (§11.9). A missing story lint or a missing python3 is reported
# at the gate's own disposition, so a broken install cannot pass
# quietly.
#
# The file set. With VSE_PRECOMMIT_RANGE unset the hook reads the
# staged set. CI sets it to a git range (such as origin/main...HEAD),
# and the hook reads the files that range changes, or to "all", and the
# hook reads every tracked file. A fresh CI checkout has nothing staged,
# so a staged-set check there would pass without checking anything. In
# range mode concern 1 is skipped with a note, because CI validates the
# model in its own step.
#
# The engineering root is the directory of the configuration file that
# iso_config_path names (VSE_ISO_CONFIG, then .iso-config.yaml at the
# repository root, then engineering/.iso-config.yaml), or the
# repository root when there is none. The story lint lives under it and
# runs from it, with paths relative to it, and when it sits below the
# repository root the lint detail opens with a line that says so.
#
# Baselined-artefact protection lives in the commit-msg hook, where the
# pending message is reliably available. The pre-commit baseline check
# in v1.x read .git/COMMIT_EDITMSG, which carries the previous commit's
# message at this stage, not the message about to be authored. The
# commit-msg hook is the right gate.
#
# Install via core.hooksPath:
#   git config core.hooksPath .githooks
# Where .githooks/ is the project-side hooks directory containing this
# script (renamed to "pre-commit", without the .sh suffix).
set -euo pipefail

HOOK_DIR="$(dirname "$0")"
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Load the shared profile helpers. The project-side copy wins, the
# plugin copy is the fallback for a partial install.
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
    # An install without the library reports rather than blocks for the
    # gates that scale with the profile, which is their standard-profile
    # disposition. The Gherkin and test-first gates block at every
    # profile, so a partial install cannot lower them.
    iso_gate_disposition() {
        case "$1" in
            precommit_gherkin|precommit_test_first) printf 'block\n' ;;
            *) printf 'warn\n' ;;
        esac
    }
    # The library's search for the configuration: VSE_ISO_CONFIG when
    # it names a readable file, then the greenfield and brownfield
    # layouts.
    iso_config_path() {
        if [ -n "${VSE_ISO_CONFIG:-}" ] && [ -f "${VSE_ISO_CONFIG}" ] && [ -r "${VSE_ISO_CONFIG}" ]; then
            printf '%s\n' "${VSE_ISO_CONFIG}"
        elif [ -f "${ROOT}/.iso-config.yaml" ]; then
            printf '%s\n' "${ROOT}/.iso-config.yaml"
        elif [ -f "${ROOT}/engineering/.iso-config.yaml" ]; then
            printf '%s\n' "${ROOT}/engineering/.iso-config.yaml"
        fi
    }
fi

# Load the test-first helpers with the same resolution. They read the
# configuration through the profile library and refuse to load without
# it, so they are looked for only when the library loaded.
TEST_FIRST_LIB=""
if [ -n "$ISO_PROFILE_LIB" ]; then
    if [ -r "${HOOK_DIR}/lib/test-first.sh" ]; then
        TEST_FIRST_LIB="${HOOK_DIR}/lib/test-first.sh"
    elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -r "${CLAUDE_PLUGIN_ROOT}/hooks/lib/test-first.sh" ]; then
        TEST_FIRST_LIB="${CLAUDE_PLUGIN_ROOT}/hooks/lib/test-first.sh"
    fi
fi
if [ -n "$TEST_FIRST_LIB" ]; then
    # shellcheck source=/dev/null
    . "$TEST_FIRST_LIB"
fi

# Load the shared toolchain helpers with the same resolution: the
# project-side copy wins, the plugin copy is the fallback.
VSE_TC_TAG="pre-commit"
export VSE_TC_TAG
SYSML_TOOLCHAIN_LIB=""
if [ -r "${HOOK_DIR}/lib/sysml-toolchain.sh" ]; then
    SYSML_TOOLCHAIN_LIB="${HOOK_DIR}/lib/sysml-toolchain.sh"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -r "${CLAUDE_PLUGIN_ROOT}/hooks/lib/sysml-toolchain.sh" ]; then
    SYSML_TOOLCHAIN_LIB="${CLAUDE_PLUGIN_ROOT}/hooks/lib/sysml-toolchain.sh"
fi
if [ -n "$SYSML_TOOLCHAIN_LIB" ]; then
    # shellcheck source=/dev/null
    . "$SYSML_TOOLCHAIN_LIB"
fi

WARNINGS=0
RATIONALE="[pre-commit] To proceed anyway, record a one-line rationale per methodology §0.10.6."

# Report one finding at a gate's disposition. block prints the detail,
# the headline and the §0.10.6 rationale line, and stops the commit.
# warn prints the detail and the headline marked as a warning, and
# counts it. info prints the headline alone, one line. off prints
# nothing. Everything goes to stderr.
#
# Usage: gate_report <disposition> <headline> [<detail>]
gate_report() {
    local disposition="$1" headline="$2" detail="${3:-}"
    case "$disposition" in
        block)
            [ -z "$detail" ] || printf '%s\n' "$detail" >&2
            printf '[pre-commit] %s\n' "$headline" >&2
            printf '%s\n' "$RATIONALE" >&2
            exit 1
            ;;
        warn)
            [ -z "$detail" ] || printf '%s\n' "$detail" >&2
            printf '[pre-commit] warning: %s\n' "$headline" >&2
            WARNINGS=$((WARNINGS + 1))
            ;;
        info)
            printf '[pre-commit] %s\n' "$headline" >&2
            ;;
    esac
    return 0
}

# The engineering root, resolved, and its path below the repository
# root with a trailing slash (empty when they are the same). A
# configuration outside the repository leaves no changed file inside
# the engineering root.
TOP_REAL="$(pwd -P)"
ISO_CONFIG="$(iso_config_path)"
ENG_ROOT="$TOP_REAL"
if [ -n "$ISO_CONFIG" ]; then
    ENG_ROOT="$(CDPATH='' cd -- "$(dirname -- "$ISO_CONFIG")" && pwd -P)" || ENG_ROOT="$TOP_REAL"
fi
ENG_PREFIX=""
ENG_INSIDE=1
case "${ENG_ROOT}/" in
    "${TOP_REAL}/") : ;;
    "${TOP_REAL}"/*) ENG_PREFIX="${ENG_ROOT#"${TOP_REAL}"/}/" ;;
    *) ENG_INSIDE=0 ;;
esac

# The file set, as paths relative to the repository root, one per line.
# git writes NUL-delimited names, so a space or an unusual character in
# a name arrives intact. CHANGED_ALL keeps deletions, because deleting
# a feature file leaves its story uncovered. CHANGED_LIVE drops them,
# because a deleted file is neither code nor test evidence.
RANGE="${VSE_PRECOMMIT_RANGE:-}"

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

if ! CHANGED_ALL="$(file_set ACMRD)" || ! CHANGED_LIVE="$(file_set ACMR)"; then
    if [ -n "$RANGE" ]; then
        echo "[pre-commit] Cannot list the files changed by the range '${RANGE}'. Set VSE_PRECOMMIT_RANGE to a range git can read, such as origin/main...HEAD, or to all." >&2
    else
        echo "[pre-commit] Cannot list the staged files." >&2
    fi
    exit 1
fi

# 1. SysML lint on staged .sysml files. The library runs the recorded
# sysml_toolchain and falls back along the fixed order, printing one
# notice per fallback on stderr. Exit 0 clean, 1 findings, 2 no
# toolchain. An unavailable toolchain is reported at every disposition
# except off, so a full-profile project never gets a green summary
# with no validation performed. In range mode CI validates the model
# in its own step, so the hook says so and moves on.
LINT_DISPOSITION="$(iso_gate_disposition precommit_lint)"
if [ "$LINT_DISPOSITION" != "off" ] && [ -n "$RANGE" ]; then
    echo "[pre-commit] Note: precommit_lint is skipped in range mode, because CI validates the model in its own step." >&2
elif [ "$LINT_DISPOSITION" != "off" ]; then
    # NUL-delimited to survive spaces in filenames. grep exits 1 on an
    # empty match, which is not a failure here.
    STAGED_SYSML=$(git diff --cached --name-only --diff-filter=ACM -z \
                    | tr '\0' '\n' \
                    | grep -E '\.sysml$' || true)
    if [ -n "$STAGED_SYSML" ]; then
        STAGED_SYSML_FILES=()
        while IFS= read -r staged_sysml; do
            [ -n "$staged_sysml" ] && STAGED_SYSML_FILES+=("$staged_sysml")
        done <<< "$STAGED_SYSML"
        LINT_STATUS=0
        LINT_OUTPUT=""
        if [ -n "$SYSML_TOOLCHAIN_LIB" ]; then
            # stdout carries the diagnostics. stderr (fallback notices and
            # unavailability reasons) reaches the terminal directly.
            LINT_CAPTURE="$(mktemp "${TMPDIR:-/tmp}/vse-lint.XXXXXX")"
            vse_tc_run_staged "${STAGED_SYSML_FILES[@]}" > "$LINT_CAPTURE" || LINT_STATUS=$?
            LINT_OUTPUT="$(cat "$LINT_CAPTURE")"
            rm -f "$LINT_CAPTURE"
        else
            LINT_STATUS=2
            echo "[pre-commit] .githooks/lib/sysml-toolchain.sh is missing (partial install). Re-run @attention-regime." >&2
        fi
        case "$LINT_STATUS" in
            0)
                : # Clean.
                ;;
            1)
                case "$LINT_DISPOSITION" in
                    block)
                        printf '%s\n' "$LINT_OUTPUT" >&2
                        echo "[pre-commit] SysML lint failed. Fix the findings before committing." >&2
                        echo "[pre-commit] To proceed anyway, record a one-line rationale per methodology §0.10.6." >&2
                        exit 1
                        ;;
                    warn)
                        printf '%s\n' "$LINT_OUTPUT" >&2
                        echo "[pre-commit] warning: SysML lint reported findings on the staged model files." >&2
                        WARNINGS=$((WARNINGS + 1))
                        ;;
                    info)
                        echo "[pre-commit] SysML lint reported findings on the staged model files." >&2
                        ;;
                esac
                ;;
            *)
                # 2, or anything unexpected: no toolchain ran.
                case "$LINT_DISPOSITION" in
                    block)
                        echo "[pre-commit] No SysML toolchain is available and precommit_lint is block at this profile." >&2
                        echo "[pre-commit] Run /vse-toolchain to install or select one, or set gate_overrides.precommit_lint to warn (methodology §0.10.4)." >&2
                        exit 1
                        ;;
                    warn)
                        echo "[pre-commit] warning: no SysML toolchain available, the staged model files were not validated. Run /vse-toolchain." >&2
                        WARNINGS=$((WARNINGS + 1))
                        ;;
                    info)
                        echo "[pre-commit] No SysML toolchain available, staged model files not validated." >&2
                        ;;
                esac
                ;;
        esac
    fi
fi

# 2. The story lint over every stories directory the change touches: a
# directory holding a changed .sysml or .feature file that sits under a
# stories/ directory. A changed .feature file under model/ outside
# stories/ is passed as itself, so the lint reads its directory and F10
# reports it. Paths are given relative to the engineering root. A file
# outside the engineering root, a directory the change removed, or a
# feature file it deleted, is not passed. Each path is one argument, so
# a space in a name is kept.
STORY_PATH_LIST=""
if [ "$ENG_INSIDE" -eq 1 ]; then
    while IFS= read -r changed; do
        case "$changed" in
            stories/*.sysml|*/stories/*.sysml|stories/*.feature|*/stories/*.feature) kind=directory ;;
            *.feature) kind=feature ;;
            *) continue ;;
        esac
        case "$changed" in
            "${ENG_PREFIX}"*) changed="${changed#"${ENG_PREFIX}"}" ;;
            *) continue ;;
        esac
        if [ "$kind" = feature ]; then
            case "$changed" in
                model/*) : ;;
                *) continue ;;
            esac
            [ -f "${ENG_ROOT}/${changed}" ] || continue
        else
            case "$changed" in
                */*) changed="${changed%/*}" ;;
                *) continue ;;
            esac
            [ -d "${ENG_ROOT}/${changed}" ] || continue
        fi
        STORY_PATH_LIST="${STORY_PATH_LIST}${changed}"$'\n'
    done <<EOF
$CHANGED_ALL
EOF
fi
STORY_PATHS=()
STORY_PATH_COUNT=0
while IFS= read -r story_path; do
    [ -n "$story_path" ] || continue
    STORY_PATHS+=("$story_path")
    STORY_PATH_COUNT=$((STORY_PATH_COUNT + 1))
done <<EOF
$(printf '%s' "$STORY_PATH_LIST" | LC_ALL=C sort -u)
EOF

STORY_LINT_REL="tools/lint/story-wellformed.py"

# Run the story lint for one gate. Exit 0 is clean, 1 is findings, and
# anything else means the lint could not run. A missing lint or python3
# is a finding at the gate's own disposition.
#
# Usage: story_gate <gate> <rule set> <what the rule set checks>
story_gate() {
    local gate="$1" only="$2" what="$3" disposition status=0 output=""
    disposition="$(iso_gate_disposition "$gate")"
    [ "$disposition" != "off" ] || return 0
    if [ ! -r "${ENG_ROOT}/${STORY_LINT_REL}" ]; then
        gate_report "$disposition" "${gate}: the story lint ${ENG_PREFIX}${STORY_LINT_REL} is missing, so ${what} was not checked. Re-run @attention-regime to install tools/lint/ (methodology §11.9.1)."
        return 0
    fi
    if ! command -v python3 > /dev/null 2>&1; then
        gate_report "$disposition" "${gate}: python3 is not available, so ${what} was not checked. Install python3 to run ${ENG_PREFIX}${STORY_LINT_REL} (methodology §11.9.1)."
        return 0
    fi
    output="$(cd "$ENG_ROOT" && python3 "$STORY_LINT_REL" --only "$only" "${STORY_PATHS[@]}" 2>&1)" || status=$?
    # The lint runs from the engineering root, so in a brownfield
    # layout its paths are relative to that directory, not to the top
    # level the commit runs from.
    if [ -n "$ENG_PREFIX" ] && [ -n "$output" ]; then
        output="[pre-commit] The paths below are relative to ${ENG_PREFIX}, the directory that holds .iso-config.yaml."$'\n'"${output}"
    fi
    case "$status" in
        0)
            : # Clean.
            ;;
        1)
            gate_report "$disposition" "${gate}: ${what} findings in the stories directories and feature files this change touches. Fix them and commit again." "$output"
            ;;
        *)
            gate_report "$disposition" "${gate}: the story lint could not run (exit ${status}), so ${what} was not checked." "$output"
            ;;
    esac
}

if [ "$STORY_PATH_COUNT" -gt 0 ]; then
    story_gate precommit_story_wellformed wellformed "story well-formedness (§1.9)"
    story_gate precommit_gherkin gherkin "Gherkin conformance (§11.9.1)"
fi

# 3. Traceability integrity (delegated). The delegate reads its own
# disposition from precommit_traceability.
TRACE_OUT=""
if [ -x "$HOOK_DIR/pre-commit-traceability.sh" ]; then
    TRACE_OUT=$("$HOOK_DIR/pre-commit-traceability.sh" 2>&1) || { printf '%s\n' "$TRACE_OUT"; exit 1; }
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -x "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" ]; then
    TRACE_OUT=$("${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit-traceability.sh" 2>&1) || { printf '%s\n' "$TRACE_OUT"; exit 1; }
fi
if [ -n "$TRACE_OUT" ]; then
    printf '%s\n' "$TRACE_OUT"
    # The delegate reports its own findings. Count its warnings so the
    # summary line below cannot contradict what was just printed.
    if printf '%s' "$TRACE_OUT" | grep -q 'warning:'; then
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# 4. Test before code (methodology §11.9). With test_first.applies
# true, a changed code path needs a changed test path in the file set,
# or, for a local commit, a test path changed on the branch since its
# merge base (vse_tf_evidence in branch mode). A test that is untracked
# or not staged is in neither, so it is not evidence (§11.9.2). In range
# mode the range alone counts. On a refactor branch the finding is a
# reminder (in range mode the branch is GITHUB_HEAD_REF when CI sets
# it). With
# test_first unrecorded, detected test tooling or a changed file the
# recorded paths classify as code or test is a finding that asks for
# the record, and otherwise one line suggests it. With applies true and
# code_paths or test_paths reading empty, the incomplete record is the
# finding. With applies false
# the gate is silent. Without test-first.sh, or without the profile
# library it needs, the gate reports the partial install instead.
#
# Every changed path is classified once with the library's in-shell
# classifier, which loads the globs once and needs no subshell per
# path, so a full-tree run stays fast.
test_first_gate() {
    local disposition="$1" applies changed code="" tests="" evidence tools touched missing
    applies="$(vse_tf_applies)"
    [ "$applies" != "false" ] || return 0
    _vse_tf_load
    while IFS= read -r changed; do
        [ -n "$changed" ] || continue
        _vse_tf_kind "$changed"
        case "$_VSE_TF_KIND" in
            code) code="${code}  code: ${changed}"$'\n' ;;
            test) tests="${tests}  test: ${changed}"$'\n' ;;
        esac
    done <<EOF
$CHANGED_LIVE
EOF

    if [ "$applies" != "true" ]; then
        tools="$(vse_tf_detect "$TOP_REAL" | tr '\n' ' ' || true)"
        tools="${tools% }"
        if [ -n "$tools" ]; then
            gate_report "$disposition" "precommit_test_first: test_first is not recorded and test tooling was detected (${tools}), so record test_first with /vse-test-first (methodology §11.5)."
        elif [ -n "${code}${tests}" ]; then
            touched="${code}${tests}"
            gate_report "$disposition" "precommit_test_first: test_first is not recorded and this change touches paths its code_paths or test_paths name, so record test_first with /vse-test-first (methodology §11.5)." "${touched%$'\n'}"
        else
            echo "[pre-commit] test_first is not recorded. When the project has code to test, record test_first with /vse-test-first (methodology §11.5)." >&2
        fi
        return 0
    fi

    # applies: true with code_paths or test_paths that read empty would
    # leave the gate unable to tell code from tests, in silence.
    if missing="$(vse_tf_missing_paths)"; then
        gate_report "$disposition" "precommit_test_first: test_first.applies is true, but nothing could be read from ${missing} (a missing or misspelt key, or a list that cannot be read), so test before code was not checked. Complete the record with /vse-test-first (methodology §11.5.2)."
        return 0
    fi

    [ -n "$code" ] || return 0
    [ -z "$tests" ] || return 0
    if [ "$RANGE" = all ]; then
        evidence="reason: no tracked file is a test path"
    elif [ -n "$RANGE" ]; then
        evidence="reason: no test path changed in the range ${RANGE}"
    elif evidence="$(vse_tf_evidence "$TOP_REAL" branch)"; then
        return 0
    fi
    # In range mode CI checks a pull request out as a detached merge
    # commit and names its branch in GITHUB_HEAD_REF, so that name is
    # matched, as tests/hooks/check-test-first.sh does. A local commit
    # matches the branch checked out.
    if vse_tf_refactor_branch "$TOP_REAL" "${RANGE:+${GITHUB_HEAD_REF:-}}"; then
        echo "[pre-commit] Reminder: precommit_test_first: code changed with no change to a test path, on a refactor branch, so the commit proceeds. Keep the behaviour unchanged and the tests green (methodology §11.9.2)." >&2
        return 0
    fi
    gate_report "$disposition" \
        "precommit_test_first: code changed with no change to a test path. Write the failing test first, then the code (methodology §11.7)." \
        "${code}  ${evidence}"
}

TEST_FIRST_DISPOSITION="$(iso_gate_disposition precommit_test_first)"
if [ "$TEST_FIRST_DISPOSITION" != "off" ]; then
    if [ -n "$TEST_FIRST_LIB" ]; then
        test_first_gate "$TEST_FIRST_DISPOSITION"
    else
        gate_report "$TEST_FIRST_DISPOSITION" "precommit_test_first: .githooks/lib/test-first.sh or .githooks/lib/iso-profile.sh is missing (partial install), so test before code was not checked. Re-run @attention-regime."
    fi
fi

# Baselined-artefact awareness (advisory only, see header). Skipped
# when baselined_paths is empty, which is the light-profile default
# per methodology §0.10.3, so the Change Request machinery stays
# dormant until the project baselines something. The configuration is
# the file iso_config_path names, the same one the dispositions come
# from.
if [ -n "$ISO_CONFIG" ]; then
    BASELINED=$(awk '
        /^baselined_paths:/ { inside=1; next }
        inside && /^[A-Za-z]/ { inside=0 }
        inside && /^[[:space:]]+-[[:space:]]+/ {
            sub(/^[[:space:]]+-[[:space:]]+/, "")
            sub(/[[:space:]]+#.*$/, "")
            print
        }
    ' "$ISO_CONFIG")
    BASELINED_HIT=""
    if [ -n "$BASELINED" ]; then
        while IFS= read -r staged_file; do
            [ -z "$staged_file" ] && continue
            while IFS= read -r baselined_path; do
                [ -z "$baselined_path" ] && continue
                case "$staged_file" in
                    "$baselined_path"|"$baselined_path"/*)
                        BASELINED_HIT="${BASELINED_HIT}${staged_file}"$'\n'
                        ;;
                esac
            done <<< "$BASELINED"
        done < <(git diff --cached --name-only --diff-filter=ACM)
    fi
    if [ -n "$BASELINED_HIT" ]; then
        echo "[pre-commit] Note: this commit modifies baselined artefacts:" >&2
        printf '%s' "$BASELINED_HIT" | sed 's/^/  /' >&2
        echo "  Per methodology §10.4.2, the commit message shall reference an" >&2
        echo "  open Change Request as 'CR #<n>'. The commit-msg hook checks it" >&2
        echo "  at the disposition your profile sets (§0.10.4)." >&2
    fi
fi

if [ "$WARNINGS" -gt 0 ]; then
    echo "[pre-commit] Checks complete with ${WARNINGS} warning(s)."
else
    echo "[pre-commit] All checks passed."
fi
exit 0
