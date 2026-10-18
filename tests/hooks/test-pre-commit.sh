#!/usr/bin/env bash
# Behavioural tests for hooks/pre-commit.sh: concern 1 (SysML lint),
# concern 2 (story well-formedness and Gherkin conformance, through the
# story lint in tools/lint/), concern 3 (the traceability gate,
# delegated to pre-commit-traceability.sh), concern 4 (test before
# code), the file set (staged, a range, or every tracked file), and the
# baselined-artefact note.
#
# Each case installs the hook into a scratch repository, stubs the
# toolchain the case needs, stages content, runs the hook, and asserts
# the exit code and the operator-facing text. The dispositions come
# from the rigour profile: block from project_profile full, warn from
# standard, and info from a gate_overrides entry, per methodology
# section 0.10.4. The Gherkin and test-first gates block at every
# profile (methodology section 11.9).
#
# Every toolchain is stubbed, so the whole file asserts the same
# behaviour on a runner with no SysML tool installed.
#
# Run: bash tests/hooks/test-pre-commit.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

# block, warn and info, expressed the way a project records them.
config_for() {
    case "$1" in
        block) tc_config full "$2" ;;
        warn)  tc_config standard "$2" ;;
        info)  tc_config standard "$2" "override=info" ;;
        *)     tc_fail "config_for: unknown disposition '$1'" ;;
    esac
}

write_model() {
    tc_write model/a.sysml <<'EOF'
package A {
    part def Sensor {
        attribute x : NoSuchType;
    }
}
EOF
    tc_stage model/a.sysml
}

write_clean_model() {
    tc_write model/a.sysml <<'EOF'
package A {
    part def Sensor;
}
EOF
    tc_stage model/a.sysml
}

# ------------------------------- 1. the preferred toolchain is present

case_preferred_available() {
    local disp="$1"
    tc_setup_repo
    config_for "$disp" opensysml
    tc_stub_sysml "sysml v0.6.0"
    write_clean_model
    tc_env
    tc_run_hook
    tc_assert_rc 0 "preferred available (${disp}): the commit proceeds"
    tc_assert_grep "All checks passed" "$OUT" "preferred available (${disp}): summary is clean"
    tc_assert_not_grep "unavailable" "$ERR" "preferred available (${disp}): no fallback notice"
}

# ------------------------------------- 2. the preferred toolchain fails

case_fallback_notice() {
    local disp="$1" transcript
    tc_setup_repo
    config_for "$disp" syside
    tc_stub_syside
    tc_stub_java "21.0.12"
    tc_pilot_install
    transcript="${FAKEHOME}/pilot-clean.txt"
    tc_write_at "$transcript" <<'EOF'
SysML v2 Pilot Implementation
1> Package A (7d0c1f2e-1111-4222-8333-444455556666)
2> 
EOF
    write_clean_model
    tc_env "PILOT_TRANSCRIPT=${transcript}"
    tc_run_hook
    tc_assert_rc 0 "fallback (${disp}): the commit proceeds on the second toolchain"
    tc_assert_grep "[pre-commit] syside unavailable (licence expired, exit 2); validating with omg-pilot instead" \
        "$ERR" "fallback (${disp}): the notice names the reason and the replacement"
    tc_assert_grep "All checks passed" "$OUT" "fallback (${disp}): summary is clean"
}

# ------------------------------------------- 3. no toolchain installed

case_no_toolchain() {
    tc_setup_repo
    config_for block syside
    write_clean_model
    tc_env
    tc_run_hook
    tc_assert_rc 1 "no toolchain (block): the commit is stopped"
    tc_assert_grep "No SysML toolchain is available and precommit_lint is block" "$ERR" \
        "no toolchain (block): the reason is stated"

    tc_setup_repo
    config_for warn syside
    write_clean_model
    tc_env
    tc_run_hook
    tc_assert_rc 0 "no toolchain (warn): the commit proceeds"
    tc_assert_grep "warning: no SysML toolchain available" "$ERR" \
        "no toolchain (warn): the gap is reported as a warning"
    tc_assert_grep "1 warning(s)" "$OUT" "no toolchain (warn): the summary counts it"

    tc_setup_repo
    config_for info syside
    write_clean_model
    tc_env
    tc_run_hook
    tc_assert_rc 0 "no toolchain (info): the commit proceeds"
    tc_assert_grep "No SysML toolchain available, staged model files not validated." "$ERR" \
        "no toolchain (info): one info line"
    tc_assert_not_grep "warning:" "$ERR" "no toolchain (info): nothing is raised to a warning"
    tc_assert_grep "All checks passed" "$OUT" "no toolchain (info): summary is clean"
}

# --------------------------------------------- 4. no model file staged

case_no_sysml_staged() {
    local invocations
    tc_setup_repo
    config_for block opensysml
    tc_stub_recorder sysml
    tc_stub_recorder syside
    tc_stub_recorder java
    invocations="${FAKEHOME}/invocations.txt"
    : > "$invocations"
    tc_write README.md <<'EOF'
# Scratch project
EOF
    tc_stage README.md
    tc_env "TC_INVOCATIONS=${invocations}"
    tc_run_hook
    tc_assert_rc 0 "no model staged: the commit proceeds"
    tc_assert_grep "All checks passed" "$OUT" "no model staged: summary is clean"
    tc_assert_empty "$(cat "$invocations")" "no model staged: no validator was invoked"
}

# ------------------------------------------ 5 and 6. lint findings

case_findings() {
    local disp="$1" kind="$2" transcript expected
    tc_setup_repo
    config_for "$disp" omg-pilot
    tc_stub_java "21.0.12"
    tc_pilot_install
    transcript="${FAKEHOME}/pilot-${kind}.txt"
    if [ "$kind" = "error" ]; then
        tc_write_at "$transcript" <<'EOF'
SysML v2 Pilot Implementation
1> ERROR:Couldn't resolve reference to Type 'NoSuchType'. (1.sysml line : 3 column : 23)
2> 
EOF
        expected="model/a.sysml:3:23: error: Couldn't resolve reference to Type 'NoSuchType'."
    else
        tc_write_at "$transcript" <<'EOF'
SysML v2 Pilot Implementation
1> WARNING:Duplicate of inherited member name 'x' from A (1.sysml line : 3 column : 9)
2> 
EOF
        expected="model/a.sysml:3:9: warning: Duplicate of inherited member name 'x' from A"
    fi
    write_model
    tc_env "PILOT_TRANSCRIPT=${transcript}"
    tc_run_hook
    if [ "$disp" = "block" ]; then
        tc_assert_rc 1 "${kind} finding (block): the commit is stopped"
        tc_assert_grep "$expected" "$ERR" "${kind} finding (block): the diagnostic is shown"
        tc_assert_grep "SysML lint failed" "$ERR" "${kind} finding (block): the gate names itself"
    else
        tc_assert_rc 0 "${kind} finding (warn): the commit proceeds"
        tc_assert_grep "$expected" "$ERR" "${kind} finding (warn): the diagnostic is shown"
        tc_assert_grep "1 warning(s)" "$OUT" "${kind} finding (warn): the summary counts it"
    fi
}

# ------------------------------------------------- 7. partial install

case_partial_install() {
    local disp="$1"
    tc_setup_repo
    config_for "$disp" opensysml
    rm -f "${REPO}/.githooks/lib/sysml-toolchain.sh"
    tc_stub_sysml "sysml v0.6.0"
    write_clean_model
    tc_env
    tc_run_hook
    tc_assert_grep "partial install" "$ERR" "partial install (${disp}): the missing library is named"
    if [ "$disp" = "block" ]; then
        tc_assert_rc 1 "partial install (block): the commit is stopped"
    else
        tc_assert_rc 0 "partial install (warn): the commit proceeds"
        tc_assert_grep "1 warning(s)" "$OUT" "partial install (warn): the summary counts it"
    fi
}

# ---------------------------------------------- 8. context filtering

case_context_filtering() {
    local transcript
    tc_setup_repo
    config_for block omg-pilot
    tc_stub_java "21.0.12"
    tc_pilot_install
    tc_write model/_template.sysml <<'EOF'
package Template {
    part def Placeholder;
}
EOF
    tc_stage model/_template.sysml
    tc_commit "add the story template"
    write_clean_model
    # The staged file holds block lines 1 to 3, so line 5 falls inside
    # the unstaged template that follows it in the same block.
    transcript="${FAKEHOME}/pilot-template.txt"
    tc_write_at "$transcript" <<'EOF'
SysML v2 Pilot Implementation
1> ERROR:Couldn't resolve reference to Type 'NoSuchType'. (1.sysml line : 5 column : 20)
2> 
EOF
    tc_env "PILOT_TRANSCRIPT=${transcript}"
    tc_run_hook
    tc_assert_rc 0 "context filtering: a finding in unstaged context does not stop the commit"
    tc_assert_grep "All checks passed" "$OUT" "context filtering: summary is clean"
    tc_assert_not_grep "_template.sysml" "$ERR" "context filtering: the context file is not reported"
    tc_assert_not_grep "error:" "$ERR" "context filtering: no diagnostic is reported"
}

# ------------------------------------------- 9. the traceability gate

write_story() {
    tc_write model/core/stories/stakeholder/s.sysml <<'EOF'
package S {
    requirement US_9_X : UserStory {
        subject :>> system : Sys;
        stakeholder :>> role : Op;
        attribute :>> capability = "acknowledge an alarm";
        attribute :>> benefit = "the queue clears";
        requirement :>> acceptance { doc /* the alarm leaves the queue */ }
    }
}
EOF
    tc_stage model/core/stories/stakeholder/s.sysml
}

# write_case <verified|unverified>: the verification case for US_9_X,
# with or without the verify line.
write_case() {
    if [ "$1" = "verified" ]; then
        tc_write model/core/verification-validation/verification-cases/v.sysml <<'EOF'
package V {
    verification def VC_9_X {
        subject sys : Sys;
        objective {
            verify US_9_X.acceptance;
        }
    }
}
EOF
    else
        tc_write model/core/verification-validation/verification-cases/v.sysml <<'EOF'
package V {
    verification def VC_9_X {
        subject sys : Sys;
        objective {
        }
    }
}
EOF
    fi
    tc_stage model/core/verification-validation/verification-cases/v.sysml
}

# The traceability cases stage a story with no feature file and no
# @StoryMeta, so the two story gates are off and the traceability gate
# is the one the case observes.
trace_config() {
    tc_config full opensysml precommit_gherkin=off precommit_story_wellformed=off
}

case_trace_covered() {
    tc_setup_repo
    trace_config
    tc_stub_sysml "sysml v0.6.0"
    write_story
    write_case verified
    tc_env
    tc_run_hook
    tc_assert_rc 0 "trace covered: the commit proceeds"
    tc_assert_grep "2 touched element(s) checked, no trace gaps" "$OUT" \
        "trace covered: the story and its case are both checked and clean"
}

case_trace_gap() {
    tc_setup_repo
    trace_config
    tc_stub_sysml "sysml v0.6.0"
    # The case is committed with its verify line, so that deleting the
    # line is the only change the gate can attribute to this commit.
    write_case verified
    tc_commit "add the verification case"
    write_story
    write_case unverified
    tc_env
    tc_run_hook
    tc_assert_rc 1 "trace gap (block): the commit is stopped"
    tc_assert_grep "1 trace gap(s) on touched requirements" "$OUT" \
        "trace gap (block): exactly one gap is counted"
    tc_assert_grep "requirement 'US_9_X' has no verification case" "$OUT" \
        "trace gap (block): the finding names the story"
}

# A story written inside a doc comment is documentation, not a
# declaration. The gate strips comment bodies before matching, so a
# worked example inside a project file cannot be reported as an
# uncovered story. The file sits outside library/ on purpose, so that
# the comment stripping is what the case proves.
case_trace_comment_only() {
    tc_setup_repo
    config_for block opensysml
    tc_stub_sysml "sysml v0.6.0"
    tc_write model/core/domain/d.sysml <<'EOF'
package L {
    part def Sensor;

    doc /*
        Example, not a declaration:
        requirement US_8_Y : UserStory {
            subject :>> system : Sensor;
        }
    */

    // requirement US_8_Z : UserStory { }
}
EOF
    tc_stage model/core/domain/d.sysml
    tc_env
    tc_run_hook
    tc_assert_rc 0 "comment-only story: the commit proceeds"
    tc_assert_grep "All checks passed" "$OUT" "comment-only story: summary is clean"
    tc_assert_not_grep "US_8_Y" "$OUT" "comment-only story: the doc-comment story is not reported"
    tc_assert_not_grep "US_8_Z" "$OUT" "comment-only story: the line-comment story is not reported"
    tc_assert_not_grep "pre-commit-traceability:" "$OUT" \
        "comment-only story: 0 touched elements, so the gate says nothing"
}

# The shipped library declares the methodology's own definitions, which
# the project's stories are typed by. Nothing in a project verifies
# them, and project-setup stages the library on the first commit, so a
# gate that read them would stop that commit at the full profile.
case_trace_library_skipped() {
    tc_setup_repo
    config_for block opensysml
    tc_stub_sysml "sysml v0.6.0"
    tc_write model/library/vse-library.sysml \
        < "${TC_PLUGIN_ROOT}/templates/common/library/vse-library.sysml"
    tc_stage model/library/vse-library.sysml
    tc_env
    tc_run_hook
    tc_assert_rc 0 "shipped library: the commit proceeds"
    tc_assert_grep "All checks passed" "$OUT" "shipped library: summary is clean"
    tc_assert_not_grep "UserStory" "$OUT" \
        "shipped library: no library definition is reported as a gap"
    tc_assert_not_grep "pre-commit-traceability:" "$OUT" \
        "shipped library: 0 touched elements, so the gate says nothing"
}

# A KerML note (//* ... */) may span lines, and a story inside it is
# documentation. A comment opener inside a string opens nothing, so the
# story after it is still read.
case_trace_note_and_string() {
    tc_setup_repo
    config_for block opensysml
    tc_stub_sysml "sysml v0.6.0"
    tc_write model/core/domain/d.sysml <<'EOF'
package L {
    //* A note, not a declaration:
        requirement US_8_W : UserStory { }
    */
    attribute storyFiles = "stories/*.sysml";
    requirement US_8_V : UserStory {
        subject :>> system : Sensor;
    }
}
EOF
    tc_stage model/core/domain/d.sysml
    tc_env
    tc_run_hook
    tc_assert_rc 1 "note and string: the story after the string stops the commit"
    tc_assert_grep "requirement 'US_8_V' has no verification case" "$OUT" \
        "note and string: the story after the string is read"
    tc_assert_not_grep "US_8_W" "$OUT" "note and string: the story in the note is not reported"
}

# A case reaches one criterion through a chain (methodology §11.3.3),
# and the story may sit inside requirement groups, so the chain can
# carry any number of "::" and "." segments before the story's name.
# US_9_X is reached as US_9_X.acceptance.alarmCleared. US_9_Y sits two
# groups down and is reached as
# S::Alarms.Queue.US_9_Y.acceptance.allCleared. Both chains reach their
# story, so neither story is a gap.
case_trace_deep_verify_counts() {
    tc_setup_repo
    trace_config
    tc_stub_sysml "sysml v0.6.0"
    tc_write model/core/stories/stakeholder/s.sysml <<'EOF'
package S {
    requirement US_9_X : UserStory {
        subject :>> system : Sys;
        stakeholder :>> role : Op;
        attribute :>> capability = "acknowledge an alarm";
        attribute :>> benefit = "the queue clears";
        requirement :>> acceptance {
            requirement alarmCleared {
                doc /* Given an alarm, when it is acknowledged, then it leaves the queue. */
            }
        }
    }
    requirement Alarms {
        requirement Queue {
            requirement US_9_Y : UserStory {
                subject :>> system : Sys;
                stakeholder :>> role : Op;
                attribute :>> capability = "clear every alarm at once";
                attribute :>> benefit = "nothing waits";
                requirement :>> acceptance {
                    requirement allCleared {
                        doc /* Given alarms, when all are acknowledged, then the queue is empty. */
                    }
                }
            }
        }
    }
}
EOF
    tc_stage model/core/stories/stakeholder/s.sysml
    tc_write model/core/verification-validation/verification-cases/v.sysml <<'EOF'
package V {
    private import S::*;
    verification def VC_9_X {
        subject sys : Sys;
        objective {
            verify US_9_X.acceptance.alarmCleared;
            verify S::Alarms.Queue.US_9_Y.acceptance.allCleared;
        }
    }
}
EOF
    tc_stage model/core/verification-validation/verification-cases/v.sysml
    tc_env
    tc_run_hook
    tc_assert_rc 0 "deep verify: the commit proceeds"
    tc_assert_grep "3 touched element(s) checked, no trace gaps" "$OUT" \
        "deep verify: both stories and the case are checked and clean"
    tc_assert_not_grep "US_9_Y" "$OUT" \
        "deep verify: the chain through two groups reaches the story"
}

# A criterion nested inside a story's acceptance is a member of that
# story, not a requirement of its own, so the gate never asks for a
# case that names it (verify US_9_X.acceptance covers it). The criterion
# alarmCleared is typed. The story lint reports that form (S7, off
# here), and it is the form that reads like a requirement declaration.
# The second commit adds a criterion inside the acceptance that is
# already committed, so the gate can only tell where the added line
# sits by reading it in its place in the whole file.
case_trace_nested_criterion_not_a_requirement() {
    tc_setup_repo
    trace_config
    tc_stub_sysml "sysml v0.6.0"
    tc_write model/core/stories/stakeholder/s.sysml <<'EOF'
package S {
    requirement US_9_X : UserStory {
        subject :>> system : Sys;
        stakeholder :>> role : Op;
        attribute :>> capability = "acknowledge an alarm";
        attribute :>> benefit = "the queue clears";
        requirement :>> acceptance {
            requirement alarmCleared : AlarmBehaviour {
                doc /* Given an alarm, when it is acknowledged, then it leaves the queue. */
            }
            requirement queueEmpty {
                doc /* Given one alarm, when it is acknowledged, then the queue is empty. */
            }
        }
    }
}
EOF
    tc_stage model/core/stories/stakeholder/s.sysml
    write_case verified
    tc_env
    tc_run_hook
    tc_assert_rc 0 "nested criterion: the commit proceeds"
    tc_assert_grep "2 touched element(s) checked, no trace gaps" "$OUT" \
        "nested criterion: the story and its case are checked, the criteria are not"
    tc_assert_not_grep "alarmCleared" "$OUT" \
        "nested criterion: the typed criterion is not reported as a requirement"

    tc_commit "add the story and its case"
    tc_write model/core/stories/stakeholder/s.sysml <<'EOF'
package S {
    requirement US_9_X : UserStory {
        subject :>> system : Sys;
        stakeholder :>> role : Op;
        attribute :>> capability = "acknowledge an alarm";
        attribute :>> benefit = "the queue clears";
        requirement :>> acceptance {
            requirement alarmCleared : AlarmBehaviour {
                doc /* Given an alarm, when it is acknowledged, then it leaves the queue. */
            }
            requirement batchCleared : AlarmBehaviour {
                doc /* Given ten alarms, when all are acknowledged, then all leave the queue. */
            }
            requirement queueEmpty {
                doc /* Given one alarm, when it is acknowledged, then the queue is empty. */
            }
        }
    }
}
EOF
    tc_stage model/core/stories/stakeholder/s.sysml
    tc_env
    tc_run_hook
    tc_assert_rc 0 "nested criterion, added later: the commit proceeds"
    tc_assert_not_grep "batchCleared" "$OUT" \
        "nested criterion, added later: the criterion is not reported as a requirement"
    tc_assert_not_grep "pre-commit-traceability:" "$OUT" \
        "nested criterion, added later: 0 touched elements, so the gate says nothing"
}

# write_two_stories <without-x|with-x>: US_9_Y alone, or US_9_Y and
# US_9_X, in one file. Neither story has a verification case.
write_two_stories() {
    {
        printf 'package S {\n'
        printf '    requirement US_9_Y : UserStory {\n'
        printf '        subject :>> system : Sys;\n'
        printf '    }\n'
        if [ "$1" = "with-x" ]; then
            printf '    requirement US_9_X : UserStory {\n'
            printf '        subject :>> system : Sys;\n'
            printf '    }\n'
        fi
        printf '}\n'
    } | tc_write model/core/stories/stakeholder/s.sysml
    tc_stage model/core/stories/stakeholder/s.sysml
}

# Range mode is what CI runs, where nothing is staged. The range still
# scopes the gate to what it adds: US_9_Y has no case either, but it
# predates the branch, so only all, which reads every tracked file,
# reports it. A range git cannot read stops the delegate, run alone,
# rather than passing it.
case_trace_range_mode() {
    tc_setup_repo
    trace_config
    tc_stub_sysml "sysml v0.6.0"
    write_two_stories without-x
    tc_commit "add the first story"
    git -C "$REPO" checkout -q -b feat/alarm
    write_two_stories with-x
    tc_commit "add the second story"

    tc_env
    tc_run_hook
    tc_assert_rc 0 "trace range: the staged set is empty and passes"

    tc_env "VSE_PRECOMMIT_RANGE=main...HEAD"
    tc_run_hook
    tc_assert_rc 1 "trace range: the story added on the branch stops the check"
    tc_assert_grep "1 trace gap(s) on touched requirements" "$OUT" \
        "trace range: exactly one gap is counted"
    tc_assert_grep "requirement 'US_9_X' has no verification case" "$OUT" \
        "trace range: the finding names the story the range adds"
    tc_assert_not_grep "US_9_Y" "$OUT" \
        "trace range: the story that predates the range is not reported"

    tc_env "VSE_PRECOMMIT_RANGE=all"
    tc_run_hook
    tc_assert_rc 1 "trace range all: the check stops"
    tc_assert_grep "2 trace gap(s) on touched requirements" "$OUT" \
        "trace range all: every story in every tracked file is checked"

    tc_env "VSE_PRECOMMIT_RANGE=no-such-ref...HEAD"
    tc_run_githook pre-commit-traceability.sh
    tc_assert_rc 1 "trace bad range: the delegate stops"
    tc_assert_grep "pre-commit-traceability: Cannot list the files changed by the range 'no-such-ref...HEAD'" "$ERR" \
        "trace bad range: the range is named on stderr"
    tc_assert_empty "$OUT" "trace bad range: nothing is printed on stdout"
}

# A damaged index cannot be listed, so the delegate stops and says so on
# stderr.
case_trace_cannot_list_staged() {
    tc_setup_repo
    trace_config
    commit_readme
    printf 'not an index\n' > "${REPO}/.git/index"
    tc_env
    tc_run_githook pre-commit-traceability.sh
    tc_assert_rc 1 "trace cannot list: the delegate stops"
    tc_assert_grep "pre-commit-traceability: Cannot list the staged files." "$ERR" \
        "trace cannot list: the failure is named on stderr"
    tc_assert_empty "$OUT" "trace cannot list: nothing is printed on stdout"
}

# A textconv driver (a diff filter that rewrites a file for display)
# must not change what the gate reads. This one hides every line, so a
# gate that used it would see no story at all.
case_trace_textconv_ignored() {
    tc_setup_repo
    trace_config
    commit_readme
    printf '*.sysml diff=hide\n' | tc_write .gitattributes
    git -C "$REPO" config diff.hide.textconv true
    tc_stage .gitattributes
    tc_commit "hide model files from diffs"
    write_story
    tc_env
    tc_run_githook pre-commit-traceability.sh
    tc_assert_rc 1 "trace textconv, staged: the story is read"
    tc_assert_grep "requirement 'US_9_X' has no verification case" "$OUT" \
        "trace textconv, staged: the finding names the story"

    tc_commit "add the story"
    tc_env "VSE_PRECOMMIT_RANGE=HEAD~1..HEAD"
    tc_run_githook pre-commit-traceability.sh
    tc_assert_rc 1 "trace textconv, range: the story is read"
    tc_assert_grep "requirement 'US_9_X' has no verification case" "$OUT" \
        "trace textconv, range: the finding names the story"
}

# all lists the index, so a tracked file missing from the working tree
# is read from the index, as the commit would record it.
case_trace_all_reads_the_index() {
    tc_setup_repo
    trace_config
    write_story
    tc_commit "add the story"
    rm "${REPO}/model/core/stories/stakeholder/s.sysml"
    tc_env "VSE_PRECOMMIT_RANGE=all"
    tc_run_githook pre-commit-traceability.sh
    tc_assert_rc 1 "trace all, file missing: the story in the index is read"
    tc_assert_grep "requirement 'US_9_X' has no verification case" "$OUT" \
        "trace all, file missing: the finding names the story"
    tc_assert_not_grep "No such file" "$ERR" "trace all, file missing: no shell error"
}

# all mode reads each file from the index by a path relative to the
# working directory (":./<path>"), the form git ls-files lists from a
# subdirectory, so the delegate run from below the top level reads the
# files it lists there.
case_trace_all_from_subdirectory() {
    local sub="model/core/stories/stakeholder"
    tc_setup_repo
    trace_config
    write_story
    tc_commit "add the story"
    tc_env "VSE_PRECOMMIT_RANGE=all"
    tc_run_in "${REPO}/${sub}" "${REPO}/.githooks/pre-commit-traceability.sh"
    tc_assert_rc 1 "trace all, subdirectory: the story listed there is read"
    tc_assert_grep "requirement 'US_9_X' has no verification case" "$OUT" \
        "trace all, subdirectory: the finding names the story"
    tc_assert_not_grep "fatal:" "$ERR" "trace all, subdirectory: git finds each file in the index"
}

# The acceptance may be written without :>> (requirement acceptance
# { ... }), and a criterion nested there is a member of its story too.
case_trace_untyped_acceptance() {
    tc_setup_repo
    trace_config
    tc_stub_sysml "sysml v0.6.0"
    tc_write model/core/stories/stakeholder/s.sysml <<'EOF'
package S {
    requirement US_9_X : UserStory {
        subject :>> system : Sys;
        requirement acceptance {
            requirement alarmCleared : AlarmBehaviour {
                doc /* Given an alarm, when it is acknowledged, then it leaves the queue. */
            }
        }
    }
}
EOF
    tc_stage model/core/stories/stakeholder/s.sysml
    write_case verified
    tc_env
    tc_run_hook
    tc_assert_rc 0 "untyped acceptance: the commit proceeds"
    tc_assert_grep "2 touched element(s) checked, no trace gaps" "$OUT" \
        "untyped acceptance: the story and its case are checked, the criterion is not"
    tc_assert_not_grep "alarmCleared" "$OUT" \
        "untyped acceptance: the nested criterion is not reported as a requirement"
}

# The diff's removed lines are the old file, so a removed acceptance
# opener opens nothing. The group that replaces it is not an
# acceptance, so the requirement added inside it is touched.
case_trace_acceptance_opener_removed() {
    tc_setup_repo
    trace_config
    tc_stub_sysml "sysml v0.6.0"
    tc_write model/core/stories/stakeholder/s.sysml <<'EOF'
package S {
    requirement US_9_X : UserStory {
        subject :>> system : Sys;
        requirement :>> acceptance {
            requirement alarmCleared : AlarmBehaviour;
        }
    }
}
EOF
    tc_stage model/core/stories/stakeholder/s.sysml
    write_case verified
    tc_commit "add the story and its case"
    tc_write model/core/stories/stakeholder/s.sysml <<'EOF'
package S {
    requirement US_9_X : UserStory {
        subject :>> system : Sys;
        requirement Alarms {
            requirement alarmCleared : AlarmBehaviour;
            requirement batchCleared : AlarmBehaviour;
        }
    }
}
EOF
    tc_stage model/core/stories/stakeholder/s.sysml
    tc_env
    tc_run_hook
    tc_assert_rc 1 "acceptance opener removed: the commit is stopped"
    tc_assert_grep "1 trace gap(s) on touched requirements" "$OUT" \
        "acceptance opener removed: exactly one gap is counted"
    tc_assert_grep "requirement 'batchCleared' has no verification case" "$OUT" \
        "acceptance opener removed: the added requirement is touched"
}

# A path with a space reaches git as one name.
case_trace_filenames_with_spaces() {
    tc_setup_repo
    trace_config
    tc_stub_sysml "sysml v0.6.0"
    tc_write "model/core/stories/field team/s.sysml" <<'EOF'
package S {
    requirement US_9_X : UserStory {
        subject :>> system : Sys;
    }
}
EOF
    tc_stage "model/core/stories/field team/s.sysml"
    tc_env
    tc_run_hook
    tc_assert_rc 1 "trace spaces: the story in a directory with a space is checked"
    tc_assert_grep "model/core/stories/field team/s.sysml: requirement 'US_9_X' has no verification case" "$OUT" \
        "trace spaces: the path is named whole"
}

# ------------------------------------- 10. the story gates (concern 2)

SCENARIOS="${TC_PLUGIN_ROOT}/tests/fixtures/lint/scenarios"
STORY_DIR="model/core/stories/stakeholder"
RATIONALE="[pre-commit] To proceed anyway, record a one-line rationale per methodology §0.10.6."

# story_config <profile> [spec ...]: the SysML lint and the traceability
# gate are off, so that the gates under test are the only ones that
# report. The traceability gate would otherwise report US_901_Example,
# which has no verification case.
story_config() {
    local profile="$1"
    shift
    tc_config "$profile" - precommit_lint=off precommit_traceability=off "$@"
}

# add_story [<dir>]: US_901_Example with the criterion firstReading,
# well-formed and with no feature file beside it.
add_story() {
    local dir="${1:-$STORY_DIR}"
    tc_write "${dir}/stories.sysml" < "${SCENARIOS}/story-criterion.sysml"
    tc_stage "${dir}/stories.sysml"
}

# add_feature: the feature file that matches add_story, beside it.
add_feature() {
    tc_write "${STORY_DIR}/US_901_Example.feature" < "${SCENARIOS}/feature-tagged.feature"
    tc_stage "${STORY_DIR}/US_901_Example.feature"
}

# A README commit on main, so that a case has history to branch from.
commit_readme() {
    tc_write README.md <<'EOF'
# Scratch project
EOF
    tc_stage README.md
    tc_commit "start the project"
}

gherkin_blocks_at() {
    local profile="$1"
    tc_setup_repo
    story_config "$profile"
    add_story
    tc_env
    tc_run_hook
    tc_assert_rc 1 "gherkin (${profile}): a story without a feature file stops the commit"
    tc_assert_grep "${STORY_DIR}/stories.sysml:4: S1 US_901_Example has no feature file" "$ERR" \
        "gherkin (${profile}): finding S1 is shown"
    tc_assert_grep "precommit_gherkin" "$ERR" "gherkin (${profile}): the gate is named"
    tc_assert_match '^\[pre-commit\] precommit_gherkin: .*\. Fix them and commit again\.$' "$ERR" \
        "gherkin (${profile}): the headline says to fix the findings and commit again"
    tc_assert_line "$RATIONALE" "$ERR" "gherkin (${profile}): the rationale line follows"
    tc_assert_not_grep "The paths below are relative to" "$ERR" \
        "gherkin (${profile}): at the top level the paths need no note"
}

case_gherkin_block_light() {
    gherkin_blocks_at light
}

case_gherkin_block_standard() {
    gherkin_blocks_at standard
}

case_gherkin_block_full() {
    gherkin_blocks_at full
}

case_gherkin_override_warn() {
    tc_setup_repo
    story_config light precommit_gherkin=warn
    add_story
    tc_env
    tc_run_hook
    tc_assert_rc 0 "gherkin override warn: the commit proceeds"
    tc_assert_grep "S1 US_901_Example has no feature file" "$ERR" "gherkin override warn: finding S1 is shown"
    tc_assert_match '^\[pre-commit\] warning: .*precommit_gherkin' "$ERR" \
        "gherkin override warn: the finding is a warning that names the gate"
    tc_assert_grep "1 warning(s)" "$OUT" "gherkin override warn: the summary counts it"
}

# info prints one line and none of the lint's own output. off does not
# run the lint at all.
case_gherkin_override_info_and_off() {
    tc_setup_repo
    story_config light precommit_gherkin=info
    add_story
    tc_env
    tc_run_hook
    tc_assert_rc 0 "gherkin override info: the commit proceeds"
    tc_assert_line_count 1 "$(printf '%s\n' "$ERR" | grep 'precommit_gherkin' || true)" \
        "gherkin override info: one line names the gate"
    tc_assert_not_grep "S1 US_901_Example" "$ERR" "gherkin override info: the lint output is not shown"
    tc_assert_grep "All checks passed" "$OUT" "gherkin override info: nothing is counted as a warning"

    story_config light precommit_gherkin=off
    tc_env
    tc_run_hook
    tc_assert_rc 0 "gherkin override off: the commit proceeds"
    tc_assert_not_grep "precommit_gherkin" "$ERR" "gherkin override off: the gate says nothing"
}

case_gherkin_clean_story_passes() {
    tc_setup_repo
    story_config light
    add_story
    add_feature
    tc_env
    tc_run_hook
    tc_assert_rc 0 "clean story: the commit proceeds"
    tc_assert_not_grep "precommit_gherkin" "$ERR" "clean story: the Gherkin gate reports nothing"
    tc_assert_grep "All checks passed" "$OUT" "clean story: summary is clean"
}

# Deleting a feature file leaves its story uncovered, so deletions are
# part of the file set the story gates read.
case_gherkin_deleted_feature() {
    tc_setup_repo
    story_config light
    add_story
    add_feature
    tc_commit "add the story and its feature"
    git -C "$REPO" rm -q "${STORY_DIR}/US_901_Example.feature"
    tc_env
    tc_run_hook
    tc_assert_rc 1 "deleted feature: the commit is stopped"
    tc_assert_grep "S1 US_901_Example has no feature file" "$ERR" "deleted feature: finding S1 is shown"
}

# A change that removes a stories directory whole leaves nothing to
# lint there, so the directory is not passed to the lint, which would
# otherwise stop on a path that does not exist.
case_gherkin_removed_directory() {
    tc_setup_repo
    story_config light
    add_story
    add_feature
    tc_commit "add the story and its feature"
    git -C "$REPO" rm -q -r "$STORY_DIR"
    tc_env
    tc_run_hook
    tc_assert_rc 0 "removed directory: the commit proceeds"
    tc_assert_not_grep "precommit_gherkin" "$ERR" "removed directory: the Gherkin gate reports nothing"
}

# A feature file in the model but outside a stories/ directory is
# misplaced, so the Gherkin gate lints it and F10 reports it, in the
# brownfield layout too. Deleting it leaves nothing to lint.
case_gherkin_misplaced_feature() {
    tc_setup_repo
    story_config light
    tc_write model/features/US_901_Example.feature < "${SCENARIOS}/feature-tagged.feature"
    tc_stage model/features/US_901_Example.feature
    tc_env
    tc_run_hook
    tc_assert_rc 1 "misplaced feature: the commit is stopped"
    tc_assert_grep "model/features/US_901_Example.feature:1: F10 US_901_Example.feature is not under a stories/ directory" "$ERR" \
        "misplaced feature: finding F10 is shown"
    tc_assert_grep "precommit_gherkin" "$ERR" "misplaced feature: the gate is named"

    tc_commit "add the misplaced feature"
    git -C "$REPO" rm -q model/features/US_901_Example.feature
    tc_env
    tc_run_hook
    tc_assert_rc 0 "misplaced feature deleted: the commit proceeds"
    tc_assert_not_grep "precommit_gherkin" "$ERR" "misplaced feature deleted: the Gherkin gate reports nothing"

    tc_setup_repo
    story_config light
    mkdir -p "${REPO}/engineering"
    mv "${REPO}/.iso-config.yaml" "${REPO}/engineering/.iso-config.yaml"
    mv "${REPO}/tools" "${REPO}/engineering/tools"
    tc_write engineering/model/features/US_901_Example.feature < "${SCENARIOS}/feature-tagged.feature"
    tc_stage engineering/model/features/US_901_Example.feature
    tc_env
    tc_run_hook
    tc_assert_rc 1 "misplaced feature, brownfield: the commit is stopped"
    tc_assert_grep "model/features/US_901_Example.feature:1: F10" "$ERR" \
        "misplaced feature, brownfield: F10 is shown with the path relative to engineering/"
}

# A feature file outside the model is the project's own, such as a
# Cucumber feature for its code, so the Gherkin gate leaves it alone.
case_gherkin_feature_outside_model() {
    tc_setup_repo
    story_config light
    tc_write features/login.feature <<'EOF'
Feature: Login
  Scenario: A user logs in
    Given a registered user
    When the user logs in
    Then the dashboard opens
EOF
    tc_stage features/login.feature
    tc_env
    tc_run_hook
    tc_assert_rc 0 "feature outside the model: the commit proceeds"
    tc_assert_not_grep "F10" "$ERR" "feature outside the model: no F10"
    tc_assert_not_grep "precommit_gherkin" "$ERR" "feature outside the model: the Gherkin gate reports nothing"
}

# precommit_story_wellformed keeps its profile scaling: off at light,
# warn at standard, block at full. The story has no status (W10). The
# Gherkin gate is off, because it reads a story without a status
# against the strictest ordering row.
case_wellformed_scales_by_profile() {
    local profile
    for profile in light standard full; do
        tc_setup_repo
        story_config "$profile" precommit_gherkin=off
        tc_write "${STORY_DIR}/stories.sysml" < "${SCENARIOS}/story-no-status.sysml"
        tc_stage "${STORY_DIR}/stories.sysml"
        add_feature
        tc_env
        tc_run_hook
        case "$profile" in
            light)
                tc_assert_rc 0 "wellformed (light): the commit proceeds"
                tc_assert_not_grep "W10" "$ERR" "wellformed (light): the gate is off"
                ;;
            standard)
                tc_assert_rc 0 "wellformed (standard): the commit proceeds"
                tc_assert_grep "W10 US_901_Example has no status" "$ERR" "wellformed (standard): W10 is shown"
                tc_assert_grep "1 warning(s)" "$OUT" "wellformed (standard): the summary counts it"
                ;;
            full)
                tc_assert_rc 1 "wellformed (full): the commit is stopped"
                tc_assert_grep "W10 US_901_Example has no status" "$ERR" "wellformed (full): W10 is shown"
                tc_assert_grep "precommit_story_wellformed" "$ERR" "wellformed (full): the gate is named"
                ;;
        esac
    done
}

# In the brownfield layout the configuration and the tools sit under
# engineering/. The lint runs from there, with paths relative to it.
case_brownfield_lint_found() {
    tc_setup_repo
    story_config light
    mkdir -p "${REPO}/engineering"
    mv "${REPO}/.iso-config.yaml" "${REPO}/engineering/.iso-config.yaml"
    mv "${REPO}/tools" "${REPO}/engineering/tools"
    add_story "engineering/${STORY_DIR}"
    tc_env
    tc_run_hook
    tc_assert_rc 1 "brownfield: the story without a feature file stops the commit"
    tc_assert_grep "${STORY_DIR}/stories.sysml:4: S1 US_901_Example" "$ERR" \
        "brownfield: the lint runs from engineering/ and reports paths relative to it"
    tc_assert_line "[pre-commit] The paths below are relative to engineering/, the directory that holds .iso-config.yaml." "$ERR" \
        "brownfield: the detail says which directory its paths are relative to"
    tc_assert_eq 1 "$(printf '%s\n' "$ERR" | grep -c 'The paths below are relative to' || true)" \
        "brownfield: the note is given once, by the gate that blocks"
}

# A missing lint is reported by each story gate at its own disposition:
# precommit_story_wellformed warns at standard, precommit_gherkin
# blocks.
case_lint_missing_blocks() {
    tc_setup_repo
    story_config standard
    rm -rf "${REPO}/tools/lint"
    add_story
    tc_env
    tc_run_hook
    tc_assert_rc 1 "missing lint: the commit is stopped"
    tc_assert_match '^\[pre-commit\] warning: .*precommit_story_wellformed.*tools/lint/story-wellformed\.py' "$ERR" \
        "missing lint: precommit_story_wellformed warns at standard and names the lint"
    tc_assert_match '^\[pre-commit\] .*precommit_gherkin.*tools/lint/story-wellformed\.py' "$ERR" \
        "missing lint: precommit_gherkin reports it and names the lint"
    tc_assert_line "$RATIONALE" "$ERR" "missing lint: the block carries the rationale line"
    tc_assert_grep "$(cd "$REPO" && pwd -P)/tools/lint/story-wellformed.py" "$ERR" \
        "missing lint: the full path looked at is named"
    tc_assert_match '^\[pre-commit\] precommit_gherkin: .*tools/lint/ and tools/render/ .*beside \.iso-config\.yaml' "$ERR" \
        "missing lint: the message says tools/lint/ and tools/render/ are needed beside the configuration"
    tc_assert_match '^\[pre-commit\] precommit_gherkin: .*custom scaffold sub-path.*project root' "$ERR" \
        "missing lint: the message says a custom scaffold sub-path keeps the configuration at the project root"
    tc_assert_match '^\[pre-commit\] precommit_gherkin: .*@attention-regime installs them there' "$ERR" \
        "missing lint: the message says @attention-regime installs them there"
}

# The lint exits 2 when it cannot run, here because tools/render/, which
# it imports, is missing. That is not a clean result, so the gate
# reports it at its disposition with the lint's own message.
case_lint_environment_error_blocks() {
    tc_setup_repo
    story_config light
    rm -rf "${REPO}/tools/render"
    add_story
    tc_env
    tc_run_hook
    tc_assert_rc 1 "lint environment error: the commit is stopped"
    tc_assert_match '^\[pre-commit\] precommit_gherkin: the story lint could not run \(exit 2\)' "$ERR" \
        "lint environment error: the gate reports the exit status"
    tc_assert_grep "story-wellformed.py:" "$ERR" "lint environment error: the lint's own message is shown"
}

# A directory holding every command of /usr/bin except python3. On a
# merged-/usr runner /bin/* repeats /usr/bin/*, and a dangling link
# there fails -e, so an existing link counts as present too.
path_without_python() {
    local bin entry name
    bin="$(tc_mktemp_d)"
    for entry in /usr/bin/* /bin/*; do
        name="${entry##*/}"
        case "$name" in
            python*) continue ;;
        esac
        [ -e "${bin}/${name}" ] || [ -L "${bin}/${name}" ] || ln -s "$entry" "${bin}/${name}"
    done
    printf '%s\n' "$bin"
}

case_python_missing_blocks() {
    local bin
    tc_setup_repo
    story_config light
    add_story
    bin="$(path_without_python)"
    tc_env "PATH=${STUBS}:${bin}"
    tc_run_hook
    tc_assert_rc 1 "missing python3: the commit is stopped"
    tc_assert_match '^\[pre-commit\] .*precommit_gherkin.*python3' "$ERR" \
        "missing python3: the gate names the missing interpreter"
}

# Without iso-profile.sh the hook falls back to a stub that blocks for
# the Gherkin and test-first gates and warns for every other gate, so a
# partial install cannot lower the two gates. Without the profile
# library test-first.sh cannot load, so the test-first gate reports the
# partial install instead of running.
case_stub_library_blocks_new_gates() {
    tc_setup_repo
    story_config light
    rm -f "${REPO}/.githooks/lib/iso-profile.sh"
    add_story
    tc_env
    tc_run_hook
    tc_assert_rc 1 "stub library: a story without a feature file stops the commit"
    tc_assert_grep "S1 US_901_Example has no feature file" "$ERR" "stub library: finding S1 is shown"
    tc_assert_grep "precommit_gherkin" "$ERR" "stub library: the Gherkin gate blocks"

    tc_setup_repo
    story_config light
    rm -f "${REPO}/.githooks/lib/iso-profile.sh"
    commit_readme
    tc_write docs/notes.md <<'EOF'
# Notes
EOF
    tc_stage docs/notes.md
    tc_env
    tc_run_hook
    tc_assert_rc 1 "stub library: the test-first gate stops the commit"
    tc_assert_match '^\[pre-commit\] .*precommit_test_first.*partial install' "$ERR" \
        "stub library: the test-first gate names the partial install"
    tc_assert_line "$RATIONALE" "$ERR" "stub library: the block carries the rationale line"
}

# ----------------------------------------- 11. test before code (4)

# test_first_config <applies|-> <profile> [spec ...]: the profile, with a
# test_first record whose code is under src/ and tests under tests/.
# "-" records the paths without applies.
test_first_config() {
    local applies="$1" profile="$2"
    shift 2
    story_config "$profile" "$@"
    {
        printf 'test_first:\n'
        if [ "$applies" != "-" ]; then
            printf '  applies: %s\n' "$applies"
        fi
        printf '  test_command: "make test"\n'
        printf '  code_paths: [src/*]\n'
        printf '  test_paths: [tests/*]\n'
    } | tc_config_append
}

write_code() {
    local path="${1:-src/reading.py}"
    tc_write "$path" <<'EOF'
def reading():
    return 42
EOF
    tc_stage "$path"
}

write_test() {
    local path="${1:-tests/test_reading.py}"
    tc_write "$path" <<'EOF'
def test_reading():
    assert True
EOF
    tc_stage "$path"
}

case_test_first_code_without_test() {
    tc_setup_repo
    test_first_config true light
    commit_readme
    write_code
    tc_env
    tc_run_hook
    tc_assert_rc 1 "test first: code with no test change stops the commit"
    tc_assert_match '^\[pre-commit\] .*precommit_test_first' "$ERR" "test first: the gate is named"
    tc_assert_grep "src/reading.py" "$ERR" "test first: the code path is named"
    tc_assert_grep "reason: no test path changed" "$ERR" "test first: the evidence search is explained"
    tc_assert_line "$RATIONALE" "$ERR" "test first: the rationale line follows"
}

case_test_first_code_with_test() {
    tc_setup_repo
    test_first_config true light
    commit_readme
    write_code
    write_test
    tc_env
    tc_run_hook
    tc_assert_rc 0 "test first: code with a staged test change proceeds"
    tc_assert_not_grep "precommit_test_first" "$ERR" "test first: the gate reports nothing"
}

# A test committed earlier on the branch is evidence for code staged
# now (methodology section 11.9.2).
case_test_first_branch_evidence() {
    tc_setup_repo
    test_first_config true light
    commit_readme
    git -C "$REPO" checkout -q -b feat/reading
    write_test
    tc_commit "add the failing test"
    write_code
    tc_env
    tc_run_hook
    tc_assert_rc 0 "test first: a test changed on the branch is evidence"
    tc_assert_not_grep "precommit_test_first" "$ERR" "test first: branch evidence reports nothing"
}

# Evidence at commit time is the commit itself or the branch since its
# merge base (methodology section 11.9.2). A test left untracked, or
# modified but not staged, is in neither, so code committed without it
# is stopped.
case_test_first_uncommitted_test_blocks() {
    tc_setup_repo
    test_first_config true light
    printf 'def test_old():\n    assert True\n' | tc_write tests/test_old.py
    tc_stage tests/test_old.py
    commit_readme
    git -C "$REPO" checkout -q -b feat/reading
    write_code
    printf 'def test_reading():\n    assert True\n' | tc_write tests/test_reading.py
    tc_env
    tc_run_hook
    tc_assert_rc 1 "test first: code with an untracked test stops the commit"
    tc_assert_grep "reason: no test path changed in the commit or on the branch since the merge base with main" "$ERR" \
        "test first: the reason names the commit and the branch"
    tc_assert_not_grep "working tree" "$ERR" "test first: the reason does not mention the working tree"

    rm -f "${REPO}/tests/test_reading.py"
    printf 'def test_more():\n    assert True\n' >> "${REPO}/tests/test_old.py"
    tc_run_hook
    tc_assert_rc 1 "test first: code with a modified, unstaged test stops the commit"
}

# applies: true with a code_paths key that reads empty would leave the
# gate unable to call any path code, so the record itself is the
# finding, at the gate's disposition (methodology §11.5.2).
case_test_first_paths_unreadable() {
    tc_setup_repo
    story_config light
    tc_config_append <<'EOF'
test_first:
  applies: true
  code_path: [src/*]
  test_paths: [tests/*]
EOF
    commit_readme
    write_code
    tc_env
    tc_run_hook
    tc_assert_rc 1 "test first, misspelt key: the commit is stopped"
    tc_assert_match '^\[pre-commit\] precommit_test_first: .*test_first\.code_paths' "$ERR" \
        "test first, misspelt key: the finding names the key that reads empty"
    tc_assert_match '^\[pre-commit\] precommit_test_first: .*/vse-test-first' "$ERR" \
        "test first, misspelt key: the finding points at /vse-test-first"
    tc_assert_line "$RATIONALE" "$ERR" "test first, misspelt key: the rationale line follows"

    story_config light precommit_test_first=warn
    tc_config_append <<'EOF'
test_first:
  applies: true
  code_path: [src/*]
  test_paths: [tests/*]
EOF
    tc_run_hook
    tc_assert_rc 0 "test first, misspelt key at warn: the commit proceeds"
    tc_assert_match '^\[pre-commit\] warning: precommit_test_first: .*test_first\.code_paths' "$ERR" \
        "test first, misspelt key at warn: the finding is a warning"

    # An item with no space after its dash is read, so the gate works.
    story_config light
    tc_config_append <<'EOF'
test_first:
  applies: true
  code_paths:
    -src/*
  test_paths: [tests/*]
EOF
    tc_run_hook
    tc_assert_rc 1 "test first, -src/* item: code with no test change stops the commit"
    tc_assert_grep "code: src/reading.py" "$ERR" "test first, -src/* item: the code path is named"
}

# On a refactor branch the finding is a reminder (methodology section
# 11.9.2), so the commit proceeds.
case_test_first_refactor_branch_reminder() {
    tc_setup_repo
    test_first_config true light
    commit_readme
    git -C "$REPO" checkout -q -b refactor/tidy-readings
    write_code
    tc_env
    tc_run_hook
    tc_assert_rc 0 "test first: a refactor branch does not stop the commit"
    tc_assert_match '^\[pre-commit\] Reminder: .*precommit_test_first.*refactor' "$ERR" \
        "test first: a refactor branch draws a reminder"
    tc_assert_not_grep "$RATIONALE" "$ERR" "test first: the reminder is not a block"
}

case_test_first_not_applicable() {
    tc_setup_repo
    test_first_config false light
    commit_readme
    write_code
    tc_env
    tc_run_hook
    tc_assert_rc 0 "test first false: code alone proceeds"
    tc_assert_not_grep "precommit_test_first" "$ERR" "test first false: the gate says nothing"
    tc_assert_not_grep "/vse-test-first" "$ERR" "test first false: no suggestion to record it"
}

# A file named .iso-config.yaml is never code, even below a code path,
# so the commit gate agrees with PreToolUse (methodology §11.5.2).
case_test_first_config_never_code() {
    tc_setup_repo
    test_first_config true light
    commit_readme
    printf 'project_profile: light\n' | tc_write src/.iso-config.yaml
    tc_stage src/.iso-config.yaml
    tc_env
    tc_run_hook
    tc_assert_rc 0 "test first: a configuration file under a code path is not code"
    tc_assert_not_grep "precommit_test_first" "$ERR" "test first: the configuration file draws no finding"
}

case_test_first_unrecorded_no_code() {
    tc_setup_repo
    story_config light
    tc_write docs/project-plan.md <<'EOF'
# Project plan
EOF
    tc_stage docs/project-plan.md
    tc_env
    tc_run_hook
    tc_assert_rc 0 "test first unrecorded, no code: the commit proceeds"
    tc_assert_line_count 1 "$(printf '%s\n' "$ERR" | grep '/vse-test-first' || true)" \
        "test first unrecorded, no code: one line suggests /vse-test-first"
    tc_assert_grep "All checks passed" "$OUT" "test first unrecorded, no code: nothing is counted as a warning"
}

# Detected test tooling turns the suggestion into a finding.
case_test_first_unrecorded_detected() {
    tc_setup_repo
    story_config light
    tc_write pytest.ini <<'EOF'
[pytest]
EOF
    tc_write docs/project-plan.md <<'EOF'
# Project plan
EOF
    tc_stage docs/project-plan.md
    tc_env
    tc_run_hook
    tc_assert_rc 1 "test first unrecorded, tooling detected: the commit is stopped"
    tc_assert_match '^\[pre-commit\] .*precommit_test_first.*record test_first with /vse-test-first' "$ERR" \
        "test first unrecorded, tooling detected: the finding asks for the record"
    tc_assert_grep "pytest" "$ERR" "test first unrecorded, tooling detected: the tooling is named"

    # Several tools are joined with ", ", as SessionStart joins them.
    tc_write go.mod <<'EOF'
module example.invalid/sensor
EOF
    tc_run_hook
    tc_assert_grep "test tooling was detected (pytest, go)" "$ERR" \
        "test first unrecorded, tooling detected: several tools are joined with a comma"
}

# A changed file the recorded paths classify as code is code-like, so
# it is a finding too while applies is unrecorded.
case_test_first_unrecorded_code_like() {
    tc_setup_repo
    test_first_config - light
    write_code
    tc_env
    tc_run_hook
    tc_assert_rc 1 "test first unrecorded, code-like file: the commit is stopped"
    tc_assert_match '^\[pre-commit\] .*precommit_test_first.*record test_first with /vse-test-first' "$ERR" \
        "test first unrecorded, code-like file: the finding asks for the record"
}

# With no test_first block, no glob classifies a file as code, so a
# source file with no detected tooling draws only the one line
# (methodology §11.5.2 and the §11.9 table). The gate carries no
# guess of its own about which files are code.
case_test_first_unrecorded_unlisted_code() {
    tc_setup_repo
    story_config light
    write_code
    tc_env
    tc_run_hook
    tc_assert_rc 0 "test first unrecorded, no recorded paths: a source file is committed"
    tc_assert_not_grep "precommit_test_first" "$ERR" \
        "test first unrecorded, no recorded paths: the source file draws no finding"
    tc_assert_line_count 1 "$(printf '%s\n' "$ERR" | grep '/vse-test-first' || true)" \
        "test first unrecorded, no recorded paths: one line suggests /vse-test-first"
}

# ----------------------------------------------- 12. range mode

# A fresh checkout has nothing staged, so the staged set passes
# vacuously. Range mode reads the files the range changes.
case_range_mode_catches_story() {
    tc_setup_repo
    story_config light
    commit_readme
    git -C "$REPO" checkout -q -b feat/example
    add_story
    tc_commit "add the story"
    tc_env
    tc_run_hook
    tc_assert_rc 0 "range mode: the staged set is empty and passes"
    tc_env "VSE_PRECOMMIT_RANGE=main...HEAD"
    tc_run_hook
    tc_assert_rc 1 "range mode: the story committed on the branch stops the check"
    tc_assert_grep "S1 US_901_Example has no feature file" "$ERR" "range mode: finding S1 is shown"
    # A check in CI cannot be bypassed from a workstation (methodology
    # §0.10.6), so range mode gives no rationale advice and asks for a
    # fix on the branch and a new push.
    tc_assert_match '^\[pre-commit\] precommit_gherkin: .*\. Fix them on the branch and push again\.$' "$ERR" \
        "range mode: the headline asks for a fix on the branch and a new push"
    tc_assert_not_grep "commit again" "$ERR" "range mode: the headline does not say commit again"
    tc_assert_not_grep "$RATIONALE" "$ERR" "range mode: no rationale line is printed"
}

# The SysML lint is left to CI's own validation step in range mode, and
# the hook says so once.
case_range_mode_skips_model_lint() {
    local invocations
    tc_setup_repo
    tc_config light opensysml precommit_traceability=off
    tc_stub_recorder sysml
    invocations="${FAKEHOME}/invocations.txt"
    : > "$invocations"
    commit_readme
    write_clean_model
    tc_commit "add the model"
    tc_env "VSE_PRECOMMIT_RANGE=HEAD~1..HEAD" "TC_INVOCATIONS=${invocations}"
    tc_run_hook
    tc_assert_rc 0 "range mode: a model change alone passes"
    tc_assert_grep "precommit_lint is skipped in range mode" "$ERR" "range mode: the skipped SysML lint is noted"
    tc_assert_empty "$(cat "$invocations")" "range mode: no validator was invoked"
}

# In CI the working tree is clean and HEAD is detached, so there is no
# working-tree or branch evidence. A test changed within the range is
# the evidence, and a range with code alone is a finding.
case_test_first_range_mode() {
    local head
    tc_setup_repo
    test_first_config true light
    commit_readme
    git -C "$REPO" checkout -q -b feat/reading
    write_test
    write_code
    tc_commit "add the reading and its test"
    head="$(git -C "$REPO" rev-parse HEAD)"
    git -C "$REPO" checkout -q --detach "$head"
    tc_env "VSE_PRECOMMIT_RANGE=main...HEAD"
    tc_run_hook
    tc_assert_rc 0 "test first, range mode: a test changed in the range is evidence"

    write_code src/other.py
    tc_commit "add more code"
    tc_env "VSE_PRECOMMIT_RANGE=HEAD~1..HEAD"
    tc_run_hook
    tc_assert_rc 1 "test first, range mode: code alone in the range stops the check"
    tc_assert_grep "reason: no test path changed in the range HEAD~1..HEAD" "$ERR" \
        "test first, range mode: the reason names the range"
    tc_assert_not_grep "$RATIONALE" "$ERR" "test first, range mode: no rationale line is printed"

    # In range mode the range alone counts: a test committed on the
    # branch before the range is not evidence for it.
    git -C "$REPO" checkout -q -b feat/more-readings
    tc_run_hook
    tc_assert_rc 1 "test first, range mode: a test on the branch outside the range is not evidence"

    # all reads every tracked file, so with no tracked test the reason
    # says so rather than naming a range.
    tc_setup_repo
    test_first_config true light
    write_code
    tc_commit "add code alone"
    tc_env "VSE_PRECOMMIT_RANGE=all"
    tc_run_hook
    tc_assert_rc 1 "test first, range all: code with no tracked test stops the check"
    tc_assert_grep "reason: no tracked file is a test path" "$ERR" \
        "test first, range all: the reason says no tracked file is a test path"
}

# CI checks a pull request out as a detached merge commit and names the
# pull request's branch in GITHUB_HEAD_REF. In range mode that name
# decides whether the branch is a refactor branch, as the plugin's own
# check-test-first.sh decides it. A local commit (staged mode) never
# reads it.
case_test_first_range_mode_refactor_branch() {
    local head
    tc_setup_repo
    test_first_config true light
    commit_readme
    git -C "$REPO" checkout -q -b refactor/tidy-readings
    write_code
    tc_commit "tidy the reading"
    head="$(git -C "$REPO" rev-parse HEAD)"
    git -C "$REPO" checkout -q --detach "$head"
    tc_env "VSE_PRECOMMIT_RANGE=HEAD~1..HEAD" "GITHUB_HEAD_REF=refactor/tidy-readings"
    tc_run_hook
    tc_assert_rc 0 "range refactor: a pull request from a refactor branch passes"
    tc_assert_match '^\[pre-commit\] Reminder: .*precommit_test_first.*refactor' "$ERR" \
        "range refactor: the pull request's refactor branch draws the reminder"

    tc_env "VSE_PRECOMMIT_RANGE=HEAD~1..HEAD" "GITHUB_HEAD_REF=feat/readings"
    tc_run_hook
    tc_assert_rc 1 "range refactor: a pull request from another branch stops the check"
    tc_assert_not_grep "Reminder:" "$ERR" "range refactor: another branch draws no reminder"

    git -C "$REPO" checkout -q -b feat/more-readings
    write_code src/other.py
    tc_env "GITHUB_HEAD_REF=refactor/tidy-readings"
    tc_run_hook
    tc_assert_rc 1 "range refactor: a local commit ignores GITHUB_HEAD_REF"
    tc_assert_not_grep "Reminder:" "$ERR" "range refactor: a local commit draws no reminder from it"
}

# all reads every tracked file, which is the mode CI uses for a tag.
case_range_all_mode() {
    tc_setup_repo
    story_config light
    add_story
    tc_commit "add the story"
    commit_readme
    tc_env "VSE_PRECOMMIT_RANGE=HEAD~1..HEAD"
    tc_run_hook
    tc_assert_rc 0 "range all: the last commit alone changes only README.md"
    tc_env "VSE_PRECOMMIT_RANGE=all"
    tc_run_hook
    tc_assert_rc 1 "range all: every tracked file is checked"
    tc_assert_grep "S1 US_901_Example has no feature file" "$ERR" "range all: finding S1 is shown"
}

# A range git cannot read stops the check rather than passing it.
case_range_bad_ref() {
    tc_setup_repo
    story_config light
    commit_readme
    tc_env "VSE_PRECOMMIT_RANGE=no-such-ref...HEAD"
    tc_run_hook
    tc_assert_rc 1 "range bad ref: the check stops"
    tc_assert_grep "[pre-commit] Cannot list the files changed by the range 'no-such-ref...HEAD'" "$ERR" \
        "range bad ref: the range is named"
}

# ------------------------------------------- 13. names with spaces

case_filenames_with_spaces() {
    tc_setup_repo
    story_config light
    add_story "model/core/stories/field team"
    tc_env
    tc_run_hook
    tc_assert_rc 1 "spaces: the story in a directory with a space is checked"
    tc_assert_grep "model/core/stories/field team/stories.sysml:4: S1 US_901_Example" "$ERR" \
        "spaces: the directory reaches the lint as one argument"

    tc_setup_repo
    test_first_config true light
    commit_readme
    write_code "src/field reading.py"
    tc_env
    tc_run_hook
    tc_assert_rc 1 "spaces: code with a space in its name is classified"
    tc_assert_grep "src/field reading.py" "$ERR" "spaces: the code path is named whole"
    write_test "tests/test field reading.py"
    tc_env
    tc_run_hook
    tc_assert_rc 0 "spaces: a test with a space in its name is evidence"
}

# ------------------------------------------ 14. baselined artefacts

baseline_paths() {
    printf 'baselined_paths:\n  - docs/baseline\n'
}

case_baselined_note_root_config() {
    tc_setup_repo
    story_config light
    baseline_paths | tc_config_append
    tc_write docs/baseline/plan.md <<'EOF'
# Plan
EOF
    tc_stage docs/baseline/plan.md
    tc_env
    tc_run_hook
    tc_assert_rc 0 "baselined note: the commit proceeds"
    tc_assert_grep "[pre-commit] Note: this commit modifies baselined artefacts:" "$ERR" \
        "baselined note: the note is printed"
}

# The note reads the file VSE_ISO_CONFIG names, the same file the
# dispositions come from.
case_baselined_note_vse_iso_config() {
    tc_setup_repo
    story_config light
    mkdir -p "${REPO}/config"
    mv "${REPO}/.iso-config.yaml" "${REPO}/config/vse.yaml"
    baseline_paths >> "${REPO}/config/vse.yaml"
    tc_write docs/baseline/plan.md <<'EOF'
# Plan
EOF
    tc_stage docs/baseline/plan.md
    tc_env "VSE_ISO_CONFIG=${REPO}/config/vse.yaml"
    tc_run_hook
    tc_assert_rc 0 "baselined note, VSE_ISO_CONFIG: the commit proceeds"
    tc_assert_grep "docs/baseline/plan.md" "$ERR" "baselined note, VSE_ISO_CONFIG: the named file is read"
}

for disposition in block warn info; do
    case_preferred_available "$disposition"
done
for disposition in block warn info; do
    case_fallback_notice "$disposition"
done
case_no_toolchain
case_no_sysml_staged
for disposition in block warn; do
    case_findings "$disposition" error
done
for disposition in block warn; do
    case_findings "$disposition" warning
done
for disposition in block warn; do
    case_partial_install "$disposition"
done
case_context_filtering
case_trace_covered
case_trace_gap
case_trace_comment_only
case_trace_library_skipped
case_trace_note_and_string
case_trace_deep_verify_counts
case_trace_nested_criterion_not_a_requirement
case_trace_range_mode
case_trace_filenames_with_spaces
case_trace_cannot_list_staged
case_trace_textconv_ignored
case_trace_all_reads_the_index
case_trace_all_from_subdirectory
case_trace_untyped_acceptance
case_trace_acceptance_opener_removed
case_gherkin_block_light
case_gherkin_block_standard
case_gherkin_block_full
case_gherkin_override_warn
case_gherkin_override_info_and_off
case_gherkin_clean_story_passes
case_gherkin_deleted_feature
case_gherkin_removed_directory
case_gherkin_misplaced_feature
case_gherkin_feature_outside_model
case_wellformed_scales_by_profile
case_brownfield_lint_found
case_lint_missing_blocks
case_lint_environment_error_blocks
case_python_missing_blocks
case_stub_library_blocks_new_gates
case_test_first_code_without_test
case_test_first_code_with_test
case_test_first_branch_evidence
case_test_first_uncommitted_test_blocks
case_test_first_paths_unreadable
case_test_first_refactor_branch_reminder
case_test_first_not_applicable
case_test_first_config_never_code
case_test_first_unrecorded_no_code
case_test_first_unrecorded_detected
case_test_first_unrecorded_code_like
case_test_first_unrecorded_unlisted_code
case_range_mode_catches_story
case_range_mode_skips_model_lint
case_test_first_range_mode
case_test_first_range_mode_refactor_branch
case_range_all_mode
case_range_bad_ref
case_filenames_with_spaces
case_baselined_note_root_config
case_baselined_note_vse_iso_config

if tc_summary "test-pre-commit"; then
    exit 0
fi
exit 1
