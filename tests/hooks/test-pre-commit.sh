#!/usr/bin/env bash
# Behavioural tests for hooks/pre-commit.sh, concern 1 (SysML lint)
# and concern 3 (the traceability gate, delegated to
# pre-commit-traceability.sh).
#
# Each case installs the hook into a scratch repository, stubs the
# toolchain the case needs, stages content, runs the hook, and asserts
# the exit code and the operator-facing text. The dispositions come
# from the rigour profile: block from project_profile full, warn from
# standard, and info from a gate_overrides entry, per methodology
# section 0.10.4.
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

case_trace_covered() {
    tc_setup_repo
    config_for block opensysml
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
    config_for block opensysml
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

if tc_summary "test-pre-commit"; then
    exit 0
fi
exit 1
