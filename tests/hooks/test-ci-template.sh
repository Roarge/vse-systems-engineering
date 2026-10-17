#!/usr/bin/env bash
# Behavioural tests for the shell steps of
# templates/github/traceability-check.yml, the CI workflow every VSE
# project installs (hooks guide §3.4 and §4.4).
#
# A workflow file cannot run outside GitHub Actions, so this test plays
# the runner for four steps: the commit-time gates (which choose the
# range of changes for each event), the test-first read, and the runs
# of the recorded test_command and scenario_command. It reads each step
# from the template as shipped, the same way the runner does: the run
# script with its block indentation removed, the env entries, and the
# if condition. An env entry or a condition written as an expression is
# resolved against the event under test and the outputs of the steps
# already run. A form the test cannot resolve fails the case, so a
# change to the template cannot slip past it unread.
#
# Each script runs in a scratch project repository, with the hooks
# installed the way @attention-regime installs them and the shipped
# configuration template, under "bash --noprofile --norc -eo pipefail",
# the command the runner uses for a bash step. Two groups are pinned:
#
#   1. The range for each event shape: a pull request, a push with a
#      previous tip, a push whose previous tip is all zeros or empty, a
#      push whose previous tip the checkout does not hold, a tag push,
#      and any other event. Every shape is run against a change that
#      draws a finding, so a range that reads nothing (the false green
#      of a fresh checkout with nothing staged) fails here. A range is
#      also shown to stop at its base, and all mode to reach a finding
#      committed long before.
#   2. The recorded tests and scenarios run only where
#      test_first.applies is true and the command is recorded
#      (methodology §11.8), from the top level of the repository, and a
#      failing command fails its step.
#
# Run: bash tests/hooks/test-ci-template.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"
# shellcheck source=/dev/null
. "${TC_LIB_DIR}/ci-step.sh"

trap tc_teardown EXIT

# Read by ci_step, from ci-step.sh.
# shellcheck disable=SC2034
CI_TEMPLATE="${TC_PLUGIN_ROOT}/templates/github/traceability-check.yml"
CI_FIXTURES="${TC_PLUGIN_ROOT}/tests/fixtures/lint/scenarios"

GATES="Run the commit-time gates over the change"
READ="Read the test-first record"
TESTS="Run the recorded tests (test_command)"
SCENARIOS="Run the recorded scenarios (scenario_command)"

ZERO40=0000000000000000000000000000000000000000
ZERO64="${ZERO40}000000000000000000000000"
GONE=2222222222222222222222222222222222222222

# ------------------------------------------------------------ the runner

# The event under test, as the runner exposes it.
CI_EVENT=""
CI_REF=""
CI_HEAD_REF=""
CI_PR_BASE=""
CI_PR_HEAD=""
CI_BEFORE=""
CI_AFTER=""

# Outputs of the steps run so far, one file per step id.
CI_OUTPUTS=""

# Whether the last ci_run ran its step (1) or skipped it (0).
CI_RAN=0

# ci_event <name> <ref> [VAR=value ...]: the event for the steps that
# follow. The variables are CI_HEAD_REF, CI_PR_BASE, CI_PR_HEAD,
# CI_BEFORE and CI_AFTER, and any not named is empty. The outputs of
# earlier steps are forgotten.
ci_event() {
    local assignment
    CI_EVENT="$1"
    CI_REF="$2"
    shift 2
    CI_HEAD_REF=""
    CI_PR_BASE=""
    CI_PR_HEAD=""
    CI_BEFORE=""
    CI_AFTER=""
    for assignment in "$@"; do
        case "${assignment%%=*}" in
            CI_HEAD_REF|CI_PR_BASE|CI_PR_HEAD|CI_BEFORE|CI_AFTER)
                eval "${assignment%%=*}=\"\${assignment#*=}\""
                ;;
            *)
                printf 'ci_event: %s is not an event variable\n' "$assignment" >&2
                return 2
                ;;
        esac
    done
    CI_OUTPUTS="$(tc_mktemp_d)"
}

# ci_expr <expression>: the value of one expression, the way the runner
# evaluates it for this event. Returns 1 for an expression the test
# does not know.
ci_expr() {
    local id name
    case "$1" in
        github.event.pull_request.base.sha) printf '%s' "$CI_PR_BASE" ;;
        github.event.pull_request.head.sha) printf '%s' "$CI_PR_HEAD" ;;
        github.event.before) printf '%s' "$CI_BEFORE" ;;
        github.event.after) printf '%s' "$CI_AFTER" ;;
        steps.*.outputs.*)
            id="${1#steps.}"
            id="${id%%.outputs.*}"
            name="${1##*.outputs.}"
            # A step that has not run, or set no such output, gives an
            # empty value, as on the runner. The last line written wins.
            if [ -f "${CI_OUTPUTS}/${id}" ]; then
                awk -v name="$name" '
                    index($0, name "=") == 1 { value = substr($0, length(name) + 2) }
                    END { printf "%s", value }' "${CI_OUTPUTS}/${id}"
            fi
            ;;
        *) return 1 ;;
    esac
}

# ci_value <text>: an env value as the runner sets it, either one whole
# ${{ <expression> }} or literal text. Returns 1 for any other use of
# an expression.
ci_value() {
    local expr
    # The ${{ }} delimiters are the workflow syntax, matched literally.
    # shellcheck disable=SC2016
    case "$1" in
        '${{ '*' }}')
            expr="${1#'${{ '}"
            expr="${expr%' }}'}"
            ci_expr "$expr"
            ;;
        *'${{'*) return 1 ;;
        *) printf '%s' "$1" ;;
    esac
}

# ci_run <name>: run the step named <name> as the runner would. Its if
# condition decides whether it runs (CI_RAN). Its env entries, the
# variables the runner sets for every step, and GITHUB_OUTPUT are its
# whole environment. It runs in $REPO, the checkout, and its outputs
# are kept under its id. The result is in RC, OUT and ERR, with both
# streams together in LOG. A step, entry or condition the test cannot
# read fails the case.
ci_run() {
    local name="$1" work cond left value id key entry
    local envs
    CI_RAN=0
    RC=0
    OUT=""
    ERR=""
    LOG=""
    work="$(tc_mktemp_d)"
    if ! ci_step "$name" run > "${work}/step.sh" || [ ! -s "${work}/step.sh" ]; then
        tc_fail "the template has a step named '${name}' with a run script"
        RC=99
        return 0
    fi
    cond="$(ci_step "$name" if)"
    case "$cond" in
        "") : ;;
        *" != ''")
            left="${cond%" != ''"}"
            if ! value="$(ci_expr "$left")"; then
                tc_fail "${name}: the condition '${cond}' names an expression the test knows"
                RC=99
                return 0
            fi
            [ -n "$value" ] || return 0
            ;;
        *)
            tc_fail "${name}: the condition '${cond}' has a form the test knows"
            RC=99
            return 0
            ;;
    esac
    envs=()
    while IFS="$(printf '\t')" read -r key entry; do
        if ! value="$(ci_value "$entry")"; then
            tc_fail "${name}: the env entry ${key} (${entry}) has a form the test knows"
            RC=99
            return 0
        fi
        envs+=("${key}=${value}")
    done < <(ci_step "$name" env)
    : > "${work}/output"
    : > "${work}/env"
    CI_RAN=1
    _tc_capture env -C "$REPO" -i \
        PATH="${STUBS}:/usr/bin:/bin" HOME="$FAKEHOME" GIT_CONFIG_NOSYSTEM=1 \
        CI=true GITHUB_ACTIONS=true GITHUB_WORKSPACE="$REPO" \
        GITHUB_EVENT_NAME="$CI_EVENT" GITHUB_REF="$CI_REF" \
        ${CI_HEAD_REF:+GITHUB_HEAD_REF="$CI_HEAD_REF"} \
        GITHUB_OUTPUT="${work}/output" GITHUB_ENV="${work}/env" \
        ${envs[@]+"${envs[@]}"} \
        bash --noprofile --norc -eo pipefail "${work}/step.sh"
    LOG="${OUT}
${ERR}"
    id="$(ci_step "$name" id)"
    if [ -n "$id" ]; then
        cp "${work}/output" "${CI_OUTPUTS}/${id}"
    fi
}

# ------------------------------------------------------------- fixtures

# ci_project: a project repository with the hooks installed, the story
# lint and the renderers, and the shipped configuration template, with
# one commit on main.
ci_project() {
    tc_setup_repo
    sed 's/{{PLUGIN_VERSION}}/5.0.0/' "${TC_PLUGIN_ROOT}/templates/iso-config/.iso-config.yaml" \
        > "${REPO}/.iso-config.yaml"
    printf '# Scratch project\n' | tc_write README.md
    git -C "$REPO" add -A
    tc_commit "chore: start the project"
}

# ci_story [identifier] [dir]: a story without its feature file, which
# the Gherkin gate reports as S1 wherever it reads it.
ci_story() {
    local id="${1:-US_901_Example}" dir="${2:-model/core/stories/stakeholder}"
    mkdir -p "${REPO}/${dir}"
    sed "s/US_901_Example/${id}/" "${CI_FIXTURES}/story-criterion.sysml" \
        > "${REPO}/${dir}/${id}.sysml"
}

# ci_feature: the feature file of the story ci_story writes by default.
ci_feature() {
    cp "${CI_FIXTURES}/feature-tagged.feature" \
        "${REPO}/model/core/stories/stakeholder/US_901_Example.feature"
}

ci_commit_all() {
    git -C "$REPO" add -A
    tc_commit "$1"
}

# ci_pr_checkout <branch>: what actions/checkout gives a pull request,
# a detached merge commit of the branch into main.
ci_pr_checkout() {
    git -C "$REPO" checkout -q --detach main
    git -C "$REPO" -c core.hooksPath=/dev/null merge -q --no-ff --no-edit "$1"
}

# ci_test_first <applies|-> [test_command|-] [scenario_command|-]:
# append a test_first block to the configuration. "-" leaves the key
# out. The values are written as given, so a case can carry quotes and
# trailing comments.
ci_test_first() {
    {
        printf '\ntest_first:\n'
        [ "$1" = "-" ] || printf '  applies: %s\n' "$1"
        printf '  rationale: "the project runs its tests from the top level."\n'
        [ "${2:--}" = "-" ] || printf '  test_command: %s\n' "$2"
        [ "${3:--}" = "-" ] || printf '  scenario_command: %s\n' "$3"
        printf '  code_paths: [src/*]\n  test_paths: [tests/*]\n'
    } >> "${REPO}/.iso-config.yaml"
}

# ----------------------------------------------------- 1. range per event

case_pull_request() {
    local base head
    ci_project
    base="$(git -C "$REPO" rev-parse main)"
    git -C "$REPO" checkout -q -b story/US_901_Example
    ci_story
    ci_commit_all "feat(US_901): add the story without its feature"
    head="$(git -C "$REPO" rev-parse HEAD)"
    ci_pr_checkout story/US_901_Example
    ci_event pull_request refs/pull/1/merge CI_HEAD_REF=story/US_901_Example \
        CI_PR_BASE="$base" CI_PR_HEAD="$head"
    ci_run "$GATES"
    tc_assert_rc 1 "pull request: a story without its feature blocks"
    tc_assert_grep "the pull request's changes since its base (VSE_PRECOMMIT_RANGE=${base}...${head})" \
        "$LOG" "pull request: the range is base...head"
    tc_assert_grep "S1 US_901_Example has no feature file" "$LOG" \
        "pull request: the range reads the story the pull request adds"

    # The same checkout with nothing staged and no range passes, which
    # is the false green range mode removes.
    tc_env
    _tc_sandboxed env -u VSE_PRECOMMIT_RANGE ./.githooks/pre-commit
    tc_assert_rc 0 "pull request: without a range the empty staged set passes, so the range is what finds S1"

    git -C "$REPO" checkout -q story/US_901_Example
    ci_feature
    ci_commit_all "feat(US_901): add its feature"
    head="$(git -C "$REPO" rev-parse HEAD)"
    ci_pr_checkout story/US_901_Example
    ci_event pull_request refs/pull/1/merge CI_HEAD_REF=story/US_901_Example \
        CI_PR_BASE="$base" CI_PR_HEAD="$head"
    ci_run "$GATES"
    tc_assert_rc 0 "pull request: once the feature arrives the change passes"
}

# A pull request reads its own changes, not the whole tree.
case_pull_request_stops_at_base() {
    local base head
    ci_project
    ci_story US_902_Old model/core/stories/system
    ci_commit_all "feat(US_902): an old story without its feature"
    base="$(git -C "$REPO" rev-parse main)"
    git -C "$REPO" checkout -q -b docs/readme
    printf '# Scratch project\n\nMore words.\n' | tc_write README.md
    ci_commit_all "docs: more words"
    head="$(git -C "$REPO" rev-parse HEAD)"
    ci_pr_checkout docs/readme
    ci_event pull_request refs/pull/2/merge CI_HEAD_REF=docs/readme \
        CI_PR_BASE="$base" CI_PR_HEAD="$head"
    ci_run "$GATES"
    tc_assert_rc 0 "pull request: a finding older than the base is not read"
}

case_push_with_previous_tip() {
    local before after
    ci_project
    before="$(git -C "$REPO" rev-parse HEAD)"
    ci_story
    ci_commit_all "feat(US_901): the story without its feature"
    after="$(git -C "$REPO" rev-parse HEAD)"
    ci_event push refs/heads/main CI_BEFORE="$before" CI_AFTER="$after"
    ci_run "$GATES"
    tc_assert_rc 1 "push: a story without its feature blocks"
    tc_assert_grep "the push's changes since the previous tip (VSE_PRECOMMIT_RANGE=${before}..${after})" \
        "$LOG" "push: the range is before..after"
    tc_assert_grep "S1 US_901_Example has no feature file" "$LOG" \
        "push: the range reads the story the push adds"

    before="$after"
    printf '# Scratch project\n\nMore words.\n' | tc_write README.md
    ci_commit_all "docs: more words"
    after="$(git -C "$REPO" rev-parse HEAD)"
    ci_event push refs/heads/main CI_BEFORE="$before" CI_AFTER="$after"
    ci_run "$GATES"
    tc_assert_rc 0 "push: a finding older than the previous tip is not read"
}

# assert_all_mode <why> <case>: the gates read every tracked file, and
# found the story without its feature that main has held all along.
assert_all_mode() {
    tc_assert_rc 1 "$2: blocks on the old story"
    tc_assert_grep "every tracked file, because $1 (VSE_PRECOMMIT_RANGE=all)" "$LOG" \
        "$2: reads every tracked file"
    tc_assert_grep "S1 US_902_Old has no feature file" "$LOG" \
        "$2: finds a story committed long before"
}

# main holds an old story without its feature and, since, a clean
# change, so only all mode can find anything.
all_mode_project() {
    ci_project
    ci_story US_902_Old model/core/stories/system
    ci_commit_all "feat(US_902): an old story without its feature"
    printf '# Scratch project\n\nMore words.\n' | tc_write README.md
    ci_commit_all "docs: more words"
}

case_push_without_previous_tip() {
    local after
    ci_project
    ci_story
    ci_feature
    ci_commit_all "feat(US_901): the story and its feature"
    after="$(git -C "$REPO" rev-parse HEAD)"
    ci_event push refs/heads/main CI_BEFORE="$ZERO40" CI_AFTER="$after"
    ci_run "$GATES"
    tc_assert_rc 0 "zero previous tip: a clean tree passes in all mode"

    all_mode_project
    after="$(git -C "$REPO" rev-parse HEAD)"
    ci_event push refs/heads/main CI_BEFORE="$ZERO40" CI_AFTER="$after"
    ci_run "$GATES"
    assert_all_mode "the push has no previous tip" "zero previous tip"
    ci_event push refs/heads/main CI_BEFORE="$ZERO64" CI_AFTER="$after"
    ci_run "$GATES"
    assert_all_mode "the push has no previous tip" "64-digit zero previous tip"
    ci_event push refs/heads/main CI_AFTER="$after"
    ci_run "$GATES"
    assert_all_mode "the push has no previous tip" "empty previous tip"
}

case_push_unreachable_previous_tip() {
    all_mode_project
    ci_event push refs/heads/main CI_BEFORE="$GONE" CI_AFTER="$(git -C "$REPO" rev-parse HEAD)"
    ci_run "$GATES"
    assert_all_mode "this checkout does not hold the previous tip ${GONE}" \
        "unreachable previous tip (a force push)"
}

case_tag_push() {
    local after
    all_mode_project
    git -C "$REPO" tag release-1
    after="$(git -C "$REPO" rev-parse HEAD)"
    ci_event push refs/tags/release-1 CI_BEFORE="$ZERO40" CI_AFTER="$after"
    ci_run "$GATES"
    assert_all_mode "a tag push brings no range of changes" "tag push"
    ci_event push refs/tags/release-1 CI_BEFORE="$(git -C "$REPO" rev-parse HEAD~1)" CI_AFTER="$after"
    ci_run "$GATES"
    assert_all_mode "a tag push brings no range of changes" "tag push with a previous value"
}

case_other_event() {
    all_mode_project
    ci_event workflow_dispatch refs/heads/main
    ci_run "$GATES"
    tc_assert_rc 1 "other event: blocks on the old story"
    tc_assert_grep "every tracked file (VSE_PRECOMMIT_RANGE=all)" "$LOG" \
        "other event: reads every tracked file"
    tc_assert_grep "S1 US_902_Old has no feature file" "$LOG" \
        "other event: finds a story committed long before"
}

case_hook_not_installed() {
    ci_project
    chmod -x "${REPO}/.githooks/pre-commit"
    ci_event workflow_dispatch refs/heads/main
    ci_run "$GATES"
    tc_assert_rc 1 "install: a hook that is not executable fails the step"
    tc_assert_grep "::error::.githooks/pre-commit is missing or not executable (run @attention-regime)" \
        "$LOG" "install: the error names the install"
    rm "${REPO}/.githooks/pre-commit"
    ci_run "$GATES"
    tc_assert_rc 1 "install: a missing hook fails the step"
}

# ---------------------------------------- 2. recorded tests and scenarios

# ci_test_steps: the read step, then both run steps, for a push to main.
ci_test_steps() {
    ci_event push refs/heads/main
    ci_run "$READ"
    READ_LOG="$LOG"
    READ_RC="$RC"
    ci_run "$TESTS"
    TESTS_RAN="$CI_RAN"
    TESTS_LOG="$LOG"
    ci_run "$SCENARIOS"
    SCENARIOS_RAN="$CI_RAN"
    SCENARIOS_LOG="$LOG"
}

case_tests_where_test_first_applies() {
    ci_project
    # A trailing comment is cut, and a # inside quotes is kept.
    ci_test_first true "\"echo 'tests # ran' && pwd\"   # the unit tests" "\"echo 'scenarios ran'\""
    ci_test_steps
    tc_assert_eq 0 "$READ_RC" "applies true: the read step passes"
    tc_assert_grep "test_first.test_command: echo 'tests # ran' && pwd" "$READ_LOG" \
        "applies true: the read step names the test command"
    tc_assert_eq 1 "$TESTS_RAN" "applies true: the test step runs"
    tc_assert_line "tests # ran" "$TESTS_LOG" "applies true: the recorded test command runs whole"
    tc_assert_line "$(cd "$REPO" && pwd -P)" "$TESTS_LOG" \
        "applies true: the test command runs from the top level"
    tc_assert_eq 1 "$SCENARIOS_RAN" "applies true: the scenario step runs"
    tc_assert_line "scenarios ran" "$SCENARIOS_LOG" "applies true: the recorded scenario command runs"
}

case_tests_not_where_test_first_does_not_apply() {
    ci_project
    ci_test_first false "\"echo 'tests ran'\"" "\"echo 'scenarios ran'\""
    ci_test_steps
    tc_assert_eq 0 "$READ_RC" "applies false: the read step passes"
    tc_assert_grep "test_first.applies is false, so no recorded test or scenario runs (methodology §11.8)." \
        "$READ_LOG" "applies false: the read step says why nothing runs"
    tc_assert_eq 0 "$TESTS_RAN" "applies false: the test step is skipped"
    tc_assert_eq 0 "$SCENARIOS_RAN" "applies false: the scenario step is skipped"

    ci_project
    ci_test_first - "\"echo 'tests ran'\"" "\"echo 'scenarios ran'\""
    ci_test_steps
    tc_assert_grep "test_first.applies is not recorded, so no recorded test or scenario runs (methodology §11.8)." \
        "$READ_LOG" "applies unrecorded: the read step says why nothing runs"
    tc_assert_eq 0 "$TESTS_RAN" "applies unrecorded: the test step is skipped"
    tc_assert_eq 0 "$SCENARIOS_RAN" "applies unrecorded: the scenario step is skipped"

    # The shipped template keeps its test_first block commented out.
    ci_project
    ci_test_steps
    tc_assert_eq 0 "$READ_RC" "shipped configuration: the read step passes"
    tc_assert_eq 0 "$TESTS_RAN" "shipped configuration: the test step is skipped"
    tc_assert_eq 0 "$SCENARIOS_RAN" "shipped configuration: the scenario step is skipped"
}

case_scenarios_only_when_recorded() {
    ci_project
    ci_test_first true "\"echo 'tests ran'\"" -
    ci_test_steps
    tc_assert_grep "test_first.scenario_command: not recorded" "$READ_LOG" \
        "no scenario command: the read step says so"
    tc_assert_eq 1 "$TESTS_RAN" "no scenario command: the test step runs"
    tc_assert_eq 0 "$SCENARIOS_RAN" "no scenario command: the scenario step is skipped"
}

case_failing_commands_fail() {
    ci_project
    ci_test_first true "\"exit 3\"" "\"false\""
    ci_event push refs/heads/main
    ci_run "$READ"
    ci_run "$TESTS"
    tc_assert_rc 1 "failing tests: the test step fails"
    tc_assert_grep "::error::test_first.test_command failed. Run 'exit 3' locally" "$LOG" \
        "failing tests: the error names the command"
    ci_run "$SCENARIOS"
    tc_assert_rc 1 "failing scenarios: the scenario step fails"
    tc_assert_grep "::error::test_first.scenario_command failed. Run 'false' locally" "$LOG" \
        "failing scenarios: the error names the command"
}

case_brownfield_record() {
    ci_project
    ci_test_first true "\"echo 'tests ran'\"" -
    mkdir -p "${REPO}/engineering"
    git -C "$REPO" mv .iso-config.yaml engineering/.iso-config.yaml
    ci_commit_all "chore: move the configuration under engineering/"
    ci_test_steps
    tc_assert_eq 1 "$TESTS_RAN" "brownfield: the record under engineering/ is read"
    tc_assert_line "tests ran" "$TESTS_LOG" "brownfield: the test command runs"
}

# The read step needs both libraries the hooks read the record with.
case_library_missing() {
    local lib
    for lib in iso-profile.sh test-first.sh; do
        ci_project
        ci_test_first true "\"echo 'tests ran'\"" "\"echo 'scenarios ran'\""
        rm "${REPO}/.githooks/lib/${lib}"
        ci_test_steps
        tc_assert_eq 0 "$READ_RC" "${lib} missing: the read step passes"
        tc_assert_grep "::warning::.githooks/lib/iso-profile.sh or .githooks/lib/test-first.sh is not installed (run @attention-regime), so test_command and scenario_command were not read and no test ran." \
            "$READ_LOG" "${lib} missing: the read step warns"
        tc_assert_eq 0 "$TESTS_RAN" "${lib} missing: the test step is skipped"
        tc_assert_eq 0 "$SCENARIOS_RAN" "${lib} missing: the scenario step is skipped"
    done
}

case_pull_request
case_pull_request_stops_at_base
case_push_with_previous_tip
case_push_without_previous_tip
case_push_unreachable_previous_tip
case_tag_push
case_other_event
case_hook_not_installed
case_tests_where_test_first_applies
case_tests_not_where_test_first_does_not_apply
case_scenarios_only_when_recorded
case_failing_commands_fail
case_brownfield_record
case_library_missing

if tc_summary "test-ci-template"; then
    exit 0
fi
exit 1
