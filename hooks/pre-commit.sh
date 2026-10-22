#!/usr/bin/env bash
# Project-side git pre-commit hook for the vse-systems-engineering plugin.
#
# Per methodology/iso-29110-hooks-guide.md §4.1 and methodology §11.9.
# Four concerns:
#   1. precommit_lint: SysML lint on staged .sysml files through
#      lib/sysml-toolchain.sh (preferred toolchain, automatic fallback,
#      never silent).
#   2. The story lint, tools/lint/story-wellformed.py under the
#      engineering root, over the stories the change touches (a story
#      whose declaration block it adds or alters, or whose feature file
#      it adds, changes, renames or deletes) and the story and feature
#      files it changes, and over every changed .feature file under
#      model/ that sits outside stories/, so that F10 reports it.
#      Stories the change leaves alone are listed in one note and never
#      block. With the range all every story is checked. A .feature
#      file outside model/ is the project's own, such as a Cucumber
#      feature for its code, and is left alone.
#      precommit_story_wellformed runs the lint with --only wellformed
#      (§1.9), precommit_gherkin with --only gherkin (§11.9.1).
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
# staged set. CI sets the variable, because a fresh CI checkout has
# nothing staged, and a staged-set check there would pass without
# checking anything. A git range (such as origin/main...HEAD) makes the
# hook read the files that range changes. The value "all" makes it read
# every tracked file. In range mode concern 1 is skipped with a note,
# because CI validates the model in its own step, and a blocked gate
# gives no rationale advice, because a check in CI cannot be bypassed
# from a workstation (methodology §0.10.6).
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
# What a blocked change does next. A check in CI (range mode, set by
# VSE_PRECOMMIT_RANGE) cannot be bypassed from a workstation (§0.10.6),
# so there it gives no rationale advice and asks for a new push.
FIX_AGAIN="Fix them and commit again."
if [ -n "${VSE_PRECOMMIT_RANGE:-}" ]; then
    RATIONALE=""
    FIX_AGAIN="Fix them on the branch and push again."
fi

# Report one finding at a gate's disposition. block prints the detail,
# the headline and the §0.10.6 rationale line (none in range mode), and
# stops the commit.
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
            [ -z "$RATIONALE" ] || printf '%s\n' "$RATIONALE" >&2
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
# a name arrives intact. Renames are read as a deletion and an addition,
# so that both names are seen. CHANGED_ALL keeps deletions, because
# deleting a feature file leaves its story uncovered. CHANGED_LIVE drops
# them, because a deleted file is neither code nor test evidence.
RANGE="${VSE_PRECOMMIT_RANGE:-}"

# Usage: file_set <git diff filter>
file_set() {
    if [ -z "$RANGE" ]; then
        git diff --cached --no-renames --name-only --diff-filter="$1" -z | tr '\0' '\n'
    elif [ "$RANGE" = "all" ]; then
        git ls-files -z | tr '\0' '\n'
    else
        git diff --no-renames --name-only --diff-filter="$1" -z "$RANGE" | tr '\0' '\n'
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

# 2. The story lint. It runs from the engineering root, with paths
# relative to it. A file outside the engineering root is not passed. A
# changed .feature file under model/ outside stories/ is passed as
# itself, so that F10 reports it. Each path is one argument, so a space
# in a name is kept.
#
# In staged and range mode the gates check the stories the change
# touches (methodology §11.9). A story is touched when the change adds
# its declaration block or alters the block's text, compared with the
# PreToolUse scanner of lib/test-first.sh between the before and after
# images of a .sysml file under stories/, or when it adds, changes,
# renames or deletes the story's <StoryIdentifier>.feature file.
# Deleting a story touches nothing. The before image is HEAD in staged
# mode and the range start in range mode (the merge base for a
# three-dot range), and the after image is the index or the range end.
# A story file the change renames, as git detects renames, takes its
# before image from the story file it was renamed from, so renaming a
# register or a stories directory touches none of its stories. That
# holds for a rename within one directory and for a file whose whole
# directory moved. A story file moved on its own to another directory
# leaves its feature files behind, and a template (a name that begins
# with "_") renamed to a working name was never checked, so their
# stories count as new.
# The changed story and feature files that still exist are passed,
# with the touched identifiers in --stories, so the lint reports the
# story-side findings for those stories and the findings about a file
# alone for those files. A deleted feature file is replaced by the
# story files of its directory that declare its story. Stories the
# change leaves alone in those directories are listed in one note.
#
# With the range all, and in a partial install without
# lib/test-first.sh, the gates check every story in each stories
# directory that holds a changed .sysml or .feature file, which for the
# range all is every stories directory.
SCOPE_TOUCHED=0
if [ -n "$TEST_FIRST_LIB" ] && [ "$RANGE" != all ]; then
    SCOPE_TOUCHED=1
fi

# The before and after images. A revision reads the file from git, ":"
# from the index, "-" from the working tree, and "none" reads empty.
BEFORE_REV=HEAD
AFTER_REV=":"
range_end() {
    if [ -n "$1" ]; then printf '%s\n' "$1"; else printf 'HEAD\n'; fi
}
if [ "$SCOPE_TOUCHED" -eq 1 ] && [ -n "$RANGE" ]; then
    case "$RANGE" in
        *...*)
            AFTER_REV="$(range_end "${RANGE#*...}")"
            BEFORE_REV="$(git merge-base "$(range_end "${RANGE%%...*}")" "$AFTER_REV" 2>/dev/null)" || BEFORE_REV=none
            ;;
        *..*)
            BEFORE_REV="$(range_end "${RANGE%%..*}")"
            AFTER_REV="$(range_end "${RANGE#*..}")"
            ;;
        *)
            BEFORE_REV="$RANGE"
            AFTER_REV="-"
            ;;
    esac
fi

# A scratch directory for the images, made on first use and removed on
# exit. The function is reached through the trap.
STORY_TMP=""
# shellcheck disable=SC2317
cleanup_story_tmp() {
    if [ -n "$STORY_TMP" ]; then
        rm -rf "$STORY_TMP" || :
    fi
}
trap cleanup_story_tmp EXIT

# The story files the change renames, as git detects renames (git diff
# -M), read as lines of three: the status, the old path and the new
# path. The file set reads a rename as a deletion and an addition, so
# without this a renamed register would have no before image and every
# story in it would count as new. A failure here only widens the check.
RENAMES=""
if [ "$SCOPE_TOUCHED" -eq 1 ]; then
    if [ -z "$RANGE" ]; then
        RENAMES="$(git diff --cached -M --name-status --diff-filter=R -z | tr '\0' '\n')" || RENAMES=""
    else
        RENAMES="$(git diff -M --name-status --diff-filter=R -z "$RANGE" | tr '\0' '\n')" || RENAMES=""
    fi
fi

# Usage: dir_holds_stories <revision> <directory from the top level>:
# 0 when the directory holds a story or feature file of its own at
# <revision>, read as story_image reads a file. A template (a name that
# begins with "_") does not count, and neither does a file in a
# subdirectory. When git cannot list the directory, it counts as
# holding one, which only widens the check.
dir_holds_stories() {
    local names name
    case "$1" in
        none) return 1 ;;
        -)
            for name in "$2"/*.sysml "$2"/*.feature; do
                [ -f "$name" ] || continue
                case "${name##*/}" in
                    _*) continue ;;
                esac
                return 0
            done
            return 1
            ;;
        :) names="$(git --literal-pathspecs ls-files -z -- "$2/" | tr '\0' '\n')" || return 0 ;;
        *) names="$(git --literal-pathspecs ls-tree -z --name-only "$1" -- "$2/" | tr '\0' '\n')" || return 0 ;;
    esac
    while IFS= read -r name; do
        case "$name" in
            "$2"/*/*|"$2"/_*) continue ;;
            "$2"/*.sysml|"$2"/*.feature) return 0 ;;
        esac
    done <<EOF
$names
EOF
    return 1
}

# Usage: rename_source <path from the top level>: print the story file
# the change renamed to <path>, or nothing. Only a story file under the
# engineering root pairs, so a file moved into a stories directory from
# elsewhere brings its stories in as new. A template never pairs, so a
# template renamed to a working name brings its stories in as new too.
# A story file moved to another directory pairs only when its whole
# directory moved, that is when the old directory holds no story or
# feature file in the after image. Otherwise its feature files stayed
# behind, and its stories count as touched. The rename list is read
# from a here-string, so the awk that stops at the first match cannot
# cut off a writer.
rename_source() {
    local from
    [ -n "$RENAMES" ] || return 0
    from="$(VSE_RENAMED="$1" awk '
        NR % 3 == 2 { old = $0 }
        NR % 3 == 0 && $0 == ENVIRON["VSE_RENAMED"] { print old; exit }
    ' <<< "$RENAMES")"
    case "$from" in
        "${ENG_PREFIX}"stories/*.sysml|"${ENG_PREFIX}"*/stories/*.sysml) : ;;
        *) return 0 ;;
    esac
    case "${from##*/}" in
        _*) return 0 ;;
    esac
    if [ "${from%/*}" != "${1%/*}" ] && dir_holds_stories "$AFTER_REV" "${from%/*}"; then
        return 0
    fi
    printf '%s\n' "$from"
}

# Usage: story_image <revision> <path from the top level> <file>
story_image() {
    case "$1" in
        none) : > "$3" ;;
        -) cat -- "$2" > "$3" 2>/dev/null || : > "$3" ;;
        :) git cat-file blob ":$2" > "$3" 2>/dev/null || : > "$3" ;;
        *) git cat-file blob "$1:$2" > "$3" 2>/dev/null || : > "$3" ;;
    esac
}

# Usage: story_identifier <name>: 0 when <name> can be a story
# identifier, ^[A-Za-z_][A-Za-z0-9_]*$.
story_identifier() {
    case "$1" in
        ''|[!ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_]*) return 1 ;;
        *[!ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_]*) return 1 ;;
    esac
    return 0
}

STORY_PATH_LIST=""
STORY_DIR_LIST=""
TOUCHED_LIST=""
if [ "$ENG_INSIDE" -eq 1 ]; then
    while IFS= read -r changed; do
        case "$changed" in
            stories/*.sysml|*/stories/*.sysml) kind=story ;;
            stories/*.feature|*/stories/*.feature) kind=story_feature ;;
            *.feature) kind=feature ;;
            *) continue ;;
        esac
        case "$changed" in
            "${ENG_PREFIX}"*) rel="${changed#"${ENG_PREFIX}"}" ;;
            *) continue ;;
        esac
        case "$rel" in
            */*) dir="${rel%/*}" ;;
            *) continue ;;
        esac
        if [ "$kind" = feature ]; then
            case "$rel" in
                model/*) : ;;
                *) continue ;;
            esac
            [ -f "${ENG_ROOT}/${rel}" ] || continue
            STORY_PATH_LIST="${STORY_PATH_LIST}${rel}"$'\n'
            continue
        fi
        if [ "$SCOPE_TOUCHED" -eq 0 ]; then
            [ -d "${ENG_ROOT}/${dir}" ] || continue
            STORY_PATH_LIST="${STORY_PATH_LIST}${dir}"$'\n'
            continue
        fi
        if [ "$kind" = story ]; then
            [ -f "${ENG_ROOT}/${rel}" ] || continue
            [ -n "$STORY_TMP" ] || STORY_TMP="$(mktemp -d "${TMPDIR:-/tmp}/vse-stories.XXXXXX")"
            renamed_from="$(rename_source "$changed")"
            story_image "$BEFORE_REV" "${renamed_from:-$changed}" "${STORY_TMP}/before"
            story_image "$AFTER_REV" "$changed" "${STORY_TMP}/after"
            TOUCHED_LIST="${TOUCHED_LIST}$(vse_tf_touched_stories "${STORY_TMP}/before" "${STORY_TMP}/after")"$'\n'
            STORY_PATH_LIST="${STORY_PATH_LIST}${rel}"$'\n'
            STORY_DIR_LIST="${STORY_DIR_LIST}${dir}"$'\n'
            continue
        fi
        stem="${rel##*/}"
        stem="${stem%.feature}"
        story_identifier "$stem" && TOUCHED_LIST="${TOUCHED_LIST}${stem}"$'\n'
        if [ -f "${ENG_ROOT}/${rel}" ]; then
            STORY_PATH_LIST="${STORY_PATH_LIST}${rel}"$'\n'
            STORY_DIR_LIST="${STORY_DIR_LIST}${dir}"$'\n'
            continue
        fi
        # A deleted feature file leaves its story uncovered. The story
        # files of the directory that declare the story are passed, so
        # that the lint finds the story.
        [ -d "${ENG_ROOT}/${dir}" ] || continue
        story_identifier "$stem" || continue
        for candidate in "${ENG_ROOT}/${dir}"/*.sysml; do
            [ -f "$candidate" ] || continue
            case "${candidate##*/}" in
                _*) continue ;;
            esac
            declared="$(vse_tf_story_blocks < "$candidate" | cut -f1)"
            case $'\n'"${declared}"$'\n' in
                *$'\n'"${stem}"$'\n'*)
                    STORY_PATH_LIST="${STORY_PATH_LIST}${dir}/${candidate##*/}"$'\n'
                    STORY_DIR_LIST="${STORY_DIR_LIST}${dir}"$'\n'
                    ;;
            esac
        done
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
STORY_DIRS=()
while IFS= read -r story_dir; do
    [ -n "$story_dir" ] || continue
    STORY_DIRS+=("$story_dir")
done <<EOF
$(printf '%s' "$STORY_DIR_LIST" | LC_ALL=C sort -u)
EOF
# The touched identifiers, comma-separated, for --stories.
TOUCHED_IDS="$(printf '%s' "$TOUCHED_LIST" | LC_ALL=C sort -u | awk 'NF { printf "%s%s", (n++ ? "," : ""), $0 }')"
STORY_SCOPE=()
if [ "$SCOPE_TOUCHED" -eq 1 ]; then
    STORY_SCOPE=("--stories=${TOUCHED_IDS}")
fi

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
        gate_report "$disposition" "${gate}: the story lint is missing at ${ENG_ROOT}/${STORY_LINT_REL}, so ${what} was not checked. The lint needs tools/lint/ and tools/render/ beside .iso-config.yaml, in ${ENG_ROOT}. A custom scaffold sub-path keeps the configuration at the project root, so they belong there too. @attention-regime installs them there, so re-run it (methodology §11.9.1)."
        return 0
    fi
    if ! command -v python3 > /dev/null 2>&1; then
        gate_report "$disposition" "${gate}: python3 is not available, so ${what} was not checked. Install python3 to run ${ENG_PREFIX}${STORY_LINT_REL} (methodology §11.9.1)."
        return 0
    fi
    output="$(cd "$ENG_ROOT" && python3 "$STORY_LINT_REL" --only "$only" ${STORY_SCOPE[@]+"${STORY_SCOPE[@]}"} "${STORY_PATHS[@]}" 2>&1)" || status=$?
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
            gate_report "$disposition" "${gate}: ${what} findings in the stories and feature files this change touches. ${FIX_AGAIN}" "$output"
            ;;
        *)
            gate_report "$disposition" "${gate}: the story lint could not run (exit ${status}), so ${what} was not checked." "$output"
            ;;
    esac
}

# One note for the stories in the touched stories directories that the
# change leaves alone and that still need migrating: S1 (no feature
# file), S3 (acceptance prose of 4.x) or S9 (a declaration the lint
# cannot read, given by its place). It never blocks. Up to five are
# named. Silent when the Gherkin gate is off or the lint cannot run,
# which the gate has already reported.
untouched_note() {
    local status=0 output entries entry count=0 shown="" what them blocks
    [ "$SCOPE_TOUCHED" -eq 1 ] && [ "${#STORY_DIRS[@]}" -gt 0 ] || return 0
    [ "$(iso_gate_disposition precommit_gherkin)" != "off" ] || return 0
    [ -r "${ENG_ROOT}/${STORY_LINT_REL}" ] || return 0
    command -v python3 > /dev/null 2>&1 || return 0
    output="$(cd "$ENG_ROOT" && python3 "$STORY_LINT_REL" --only gherkin "${STORY_DIRS[@]}" 2>/dev/null)" || status=$?
    [ "$status" -eq 1 ] || return 0
    [ -n "$STORY_TMP" ] || STORY_TMP="$(mktemp -d "${TMPDIR:-/tmp}/vse-stories.XXXXXX")"
    printf '%s\n' "${STORY_PATHS[@]}" > "${STORY_TMP}/named"
    printf '%s\n' "$output" > "${STORY_TMP}/untouched"
    entries="$(VSE_NOTE_PREFIX="$ENG_PREFIX" LC_ALL=C awk -v touched=",${TOUCHED_IDS}," '
        FILENAME == ARGV[1] { named[$0] = 1; next }
        match($0, /:[0-9]+: S[139] /) {
            path = substr($0, 1, RSTART - 1)
            head = substr($0, RSTART + 1, RLENGTH - 2)
            line = head
            sub(/:.*/, "", line)
            code = substr(head, length(head) - 1)
            if (code == "S9") {
                if (!(path in named))
                    print ENVIRON["VSE_NOTE_PREFIX"] path ":" line \
                        " (a declaration the lint cannot read)"
                next
            }
            id = substr($0, RSTART + RLENGTH)
            sub(/ .*/, "", id)
            sub(/\.feature$/, "", id)
            if (index(touched, "," id ",") == 0 && !(id in seen)) {
                seen[id] = 1
                print id
            }
        }
    ' "${STORY_TMP}/named" "${STORY_TMP}/untouched")"
    while IFS= read -r entry; do
        [ -n "$entry" ] || continue
        count=$((count + 1))
        [ "$count" -gt 5 ] || shown="${shown:+${shown}, }${entry}"
    done <<EOF
$entries
EOF
    [ "$count" -gt 0 ] || return 0
    [ "$count" -le 5 ] || shown="${shown} and $((count - 5)) more"
    if [ "$count" -eq 1 ]; then
        what="1 story that still needs migrating"
        them="it"
        blocks="it does not block"
    else
        what="${count} stories that still need migrating"
        them="them"
        blocks="they do not block"
    fi
    echo "[pre-commit] Note: this change leaves alone ${what} in the stories directories it touches: ${shown}. The commit gates check only the stories a change touches, so ${blocks} this commit. /vse-audit lists ${them}, and the check at a release tag covers every story, so a release needs ${them} migrated (methodology §11.3.1)." >&2
}

if [ "$STORY_PATH_COUNT" -gt 0 ]; then
    story_gate precommit_story_wellformed wellformed "story well-formedness (§1.9)"
    story_gate precommit_gherkin gherkin "Gherkin conformance (§11.9.1)"
    untouched_note
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
    # summary line below cannot contradict what was just printed. The
    # output is matched with case rather than piped into grep -q. grep
    # -q stops at the first match, so the writer of a long output could
    # be killed by SIGPIPE (the signal a process gets when it writes to
    # a pipe that nobody reads any more), which pipefail turns into a
    # miss.
    case "$TRACE_OUT" in
        *'warning:'*) WARNINGS=$((WARNINGS + 1)) ;;
    esac
fi

# 4. Test before code (methodology §11.9). With test_first.applies
# true, a changed code path needs a changed test path in the file set,
# or a test path changed on the branch since its merge base
# (vse_tf_evidence in branch mode). A test that is untracked or not
# staged is in neither, so it is not evidence (§11.9.2). In range mode
# the branch counts only when one is checked out, as CI does for a
# push. CI checks a pull request out detached, so there the range alone
# counts, and it already runs from the merge base. With the range all,
# every tracked file is already in the file set. On a refactor branch
# the finding is a reminder (in range mode the branch is
# GITHUB_HEAD_REF when CI sets it). With applies true and code_paths
# or test_paths reading empty, the incomplete record is the finding.
# With test_first unrecorded, detected test tooling or a changed file
# the recorded paths classify as code or test is a finding that asks
# for the record, and otherwise one line suggests it. With applies
# false the gate is silent. Without test-first.sh, or without the
# profile library it needs, the gate reports the partial install
# instead.
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
        tools="$(vse_tf_detect "$TOP_REAL" | awk '{ printf "%s%s", (NR > 1 ? ", " : ""), $0 }' || true)"
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
    elif [ -z "$RANGE" ]; then
        if evidence="$(vse_tf_evidence "$TOP_REAL" branch)"; then
            return 0
        fi
    elif git -C "$TOP_REAL" symbolic-ref -q HEAD >/dev/null 2>&1; then
        if evidence="$(vse_tf_evidence "$TOP_REAL" branch "in the range ${RANGE}")"; then
            return 0
        fi
    else
        evidence="reason: no test path changed in the range ${RANGE}"
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
