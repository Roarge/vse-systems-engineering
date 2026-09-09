#!/usr/bin/env bash
# Contract tests for hooks/lib/sysml-toolchain.sh.
#
# The stub sections shadow the three toolchains with scripts that
# reproduce the output shapes the library parses, so they assert the
# same behaviour on a machine with no SysML tool installed. The real
# sections at the end run the installed toolchains and print SKIPPED
# when one is absent, which is what a CI runner sees.
#
# Run: bash tests/hooks/check-toolchain.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

tc_setup_repo
trap tc_teardown EXIT

# A java stub at an arbitrary path, for the resolution-order cases.
write_java_at() {
    local path="$1" version="$2"
    mkdir -p "$(dirname "$path")"
    cat > "$path" <<EOF
#!/usr/bin/env bash
set -uo pipefail
if [ "\${1:-}" = "-version" ]; then
    echo 'openjdk version "${version}" 2026-07-21' >&2
    exit 0
fi
cat > /dev/null
exit 0
EOF
    chmod +x "$path"
}

TRANSCRIPTS="${FAKEHOME}/transcripts"
mkdir -p "$TRANSCRIPTS"

# ------------------------------------------------------ 1. preference

rm -f "${REPO}/.iso-config.yaml"
tc_env
tc_run_lib preference
tc_assert_eq "syside" "$OUT" "preference: absent config defaults to syside"
tc_assert_empty "$ERR" "preference: absent config is silent"

tc_config standard omg-pilot
tc_run_lib preference
tc_assert_eq "omg-pilot" "$OUT" "preference: recorded omg-pilot is read back"

cat > "${REPO}/.iso-config.yaml" <<'EOF'
project_profile: standard
sysml_toolchain: "opensysml"   # quoted, with a trailing comment
EOF
tc_run_lib preference
tc_assert_eq "opensysml" "$OUT" "preference: quoted value and trailing comment"

tc_config standard omg-pilot
tc_env VSE_SYSML_TOOLCHAIN=opensysml
tc_run_lib preference
tc_assert_eq "opensysml" "$OUT" "preference: VSE_SYSML_TOOLCHAIN wins over the file"

tc_env
tc_config standard bogus
tc_run_lib preference
tc_assert_eq "syside" "$OUT" "preference: unrecognised value falls back to syside"
tc_assert_grep "Unrecognised sysml_toolchain 'bogus'" "$ERR" \
    "preference: unrecognised value is reported"
tc_assert_line_count 1 "$ERR" "preference: unrecognised value reports exactly one line"

# ------------------------------------------------------ 2. candidates

tc_config standard syside
tc_run_lib candidates
tc_assert_eq "syside
omg-pilot
opensysml" "$OUT" "candidates: syside preferred"

tc_config standard omg-pilot
tc_run_lib candidates
tc_assert_eq "omg-pilot
syside
opensysml" "$OUT" "candidates: omg-pilot preferred"

tc_config standard opensysml
tc_run_lib candidates
tc_assert_eq "opensysml
syside
omg-pilot" "$OUT" "candidates: opensysml preferred"

# ------------------------------------------------------------ 3. java

tc_config standard omg-pilot

tc_stub_java "1.8.0_392"
tc_run_lib java
tc_assert_rc 2 "java: 1.8.0_392 is rejected"
tc_assert_grep "is major 8, need 21 or later" "$ERR" "java: 1.8 reason names the major"

tc_stub_java "17.0.2"
tc_run_lib java
tc_assert_rc 2 "java: 17.0.2 is rejected"
tc_assert_grep "is major 17, need 21 or later" "$ERR" "java: 17 reason names the major"

tc_stub_java "21.0.12"
tc_run_lib java
tc_assert_rc 0 "java: 21.0.12 is accepted"
tc_assert_eq "${STUBS}/java" "$OUT" "java: the accepted binary is printed"

write_java_at "${STUBS}/vsejava/java" "21.0.12"
write_java_at "${STUBS}/javahome/bin/java" "21.0.12"

tc_env "VSE_JAVA=${STUBS}/vsejava/java" "JAVA_HOME=${STUBS}/javahome"
tc_run_lib java
tc_assert_eq "${STUBS}/vsejava/java" "$OUT" "java: VSE_JAVA beats JAVA_HOME"

tc_env "JAVA_HOME=${STUBS}/javahome"
tc_run_lib java
tc_assert_eq "${STUBS}/javahome/bin/java" "$OUT" "java: JAVA_HOME beats PATH"

tc_env
tc_run_lib java
tc_assert_eq "${STUBS}/java" "$OUT" "java: PATH is the last resort"

# ---------------------------------------------- 4. detect omg-pilot

tc_pilot_uninstall
tc_run_lib detect omg-pilot
tc_assert_rc 2 "detect omg-pilot: no jar is unavailable"
tc_assert_grep "pilot jar not found under" "$ERR" "detect omg-pilot: missing jar reason"

mkdir -p "$(tc_pilot_home)/sysml"
: > "$(tc_pilot_home)/sysml/jupyter-sysml-kernel-0.61.0-all.jar"
tc_run_lib detect omg-pilot
tc_assert_rc 2 "detect omg-pilot: no model library is unavailable"
tc_assert_grep "pilot sysml.library not found" "$ERR" "detect omg-pilot: missing library reason"

tc_pilot_install
tc_run_lib detect omg-pilot
tc_assert_rc 0 "detect omg-pilot: jar plus library plus java 21 is available"
tc_assert_grep "omg-pilot: available" "$OUT" "detect omg-pilot: available is reported"

# ------------------------------------------------- 5. detect syside

tc_stub_syside
tc_run_lib detect syside
tc_assert_rc 2 "detect syside: expired licence is unavailable"
tc_assert_grep "syside unavailable (licence expired, exit 2)" "$ERR" \
    "detect syside: expired licence reason"

tc_env SYSIDE_OK=1
tc_run_lib detect syside
tc_assert_rc 0 "detect syside: a passing check is available"

tc_env
rm -f "${STUBS}/syside"
tc_run_lib detect syside
tc_assert_rc 2 "detect syside: absent binary is unavailable"
tc_assert_grep "syside not on PATH" "$ERR" "detect syside: absent binary reason"

# ---------------------------------------------- 6. detect opensysml

tc_stub_sysml "sysml v0.6.0"
tc_run_lib detect opensysml
tc_assert_rc 0 "detect opensysml: a release banner is available"

tc_stub_sysml "sysml dev"
tc_run_lib detect opensysml
tc_assert_rc 0 "detect opensysml: a dev banner is available"

tc_stub_sysml "SysML CLI 9.9"
tc_run_lib detect opensysml
tc_assert_rc 2 "detect opensysml: a foreign banner is unavailable"
tc_assert_grep "is not OpenSysML" "$ERR" "detect opensysml: foreign banner reason"

rm -f "${STUBS}/sysml"

# ------------------------------------------- 7. pilot offset mapping

tc_write a.sysml <<'EOF'
package A {
    part def Sensor;
}
EOF
tc_write b.sysml <<'EOF'
package B {
    private import A::*;
    part s : Sensor {
        attribute x;
    }
}
EOF

cat > "${TRANSCRIPTS}/pilot-findings.txt" <<'EOF'
SysML v2 Pilot Implementation
1> ERROR:Couldn't resolve reference to Type 'NoSuchType'. (1.sysml line : 5 column : 34)
WARNING:Duplicate of inherited member name 'x' from A (1.sysml line : 7 column : 35)
2> 
EOF

tc_stub_java "21.0.12"
tc_env "PILOT_TRANSCRIPT=${TRANSCRIPTS}/pilot-findings.txt"
tc_run_lib_fn vse_tc_validate omg-pilot a.sysml b.sysml
tc_assert_rc 1 "pilot mapping: findings exit 1"
tc_assert_eq "b.sysml:2:34: error: Couldn't resolve reference to Type 'NoSuchType'.
b.sysml:4:35: warning: Duplicate of inherited member name 'x' from A" "$OUT" \
    "pilot mapping: block lines map back to the second file"

cat > "${TRANSCRIPTS}/pilot-clean.txt" <<'EOF'
SysML v2 Pilot Implementation
1> Package A (7d0c1f2e-1111-4222-8333-444455556666)
Package B (7d0c1f2e-1111-4222-8333-444455556667)
2> 
EOF
tc_env "PILOT_TRANSCRIPT=${TRANSCRIPTS}/pilot-clean.txt"
tc_run_lib_fn vse_tc_validate omg-pilot a.sysml b.sysml
tc_assert_rc 0 "pilot mapping: root elements only is clean"
tc_assert_empty "$OUT" "pilot mapping: a clean run prints no diagnostics"

: > "${TRANSCRIPTS}/pilot-empty.txt"
tc_env "PILOT_TRANSCRIPT=${TRANSCRIPTS}/pilot-empty.txt"
tc_run_lib_fn vse_tc_validate omg-pilot a.sysml b.sysml
tc_assert_rc 2 "pilot mapping: silence is unavailable, not clean"
tc_assert_grep "neither a root element" "$ERR" "pilot mapping: silence reason"

tc_env "PILOT_TRANSCRIPT=${TRANSCRIPTS}/pilot-clean.txt" PILOT_RC=1
tc_run_lib_fn vse_tc_validate omg-pilot a.sysml b.sysml
tc_assert_rc 2 "pilot mapping: a JVM failure is unavailable"
tc_assert_grep "JVM exit 1" "$ERR" "pilot mapping: JVM failure reason"

tc_env
rm -f "${STUBS}/java"

# ------------------------------------------------- 8. opensysml stub

tc_write f.sysml <<'EOF'
package F {
    part def Widget;
}
EOF

cat > "${TRANSCRIPTS}/osml-error.txt" <<'EOF'
f.sysml:2:32: error: unresolved reference: NoSuchType
        attribute x : NoSuchType;
                      ^~~~~~~~~~
EOF
tc_stub_sysml "sysml v0.6.0"
tc_env "SYSML_TRANSCRIPT=${TRANSCRIPTS}/osml-error.txt" SYSML_RC=2
tc_run_lib_fn vse_tc_validate opensysml f.sysml
tc_assert_rc 1 "opensysml: a diagnostic with exit 2 is findings, not unavailable"
tc_assert_eq "f.sysml:2:32: error: unresolved reference: NoSuchType" "$OUT" \
    "opensysml: the source echo and caret line are dropped"

cat > "${TRANSCRIPTS}/osml-warning.txt" <<'EOF'
f.sysml:3:5: warning: unused import
EOF
tc_env "SYSML_TRANSCRIPT=${TRANSCRIPTS}/osml-warning.txt" SYSML_RC=0
tc_run_lib_fn vse_tc_validate opensysml f.sysml
tc_assert_rc 1 "opensysml: a warning with exit 0 is promoted to findings"
tc_assert_eq "f.sysml:3:5: warning: unused import" "$OUT" "opensysml: the warning line is reported"

cat > "${TRANSCRIPTS}/osml-clean.txt" <<'EOF'
✓ package F
✓ f.sysml: no errors
EOF
tc_env "SYSML_STDOUT=${TRANSCRIPTS}/osml-clean.txt" SYSML_RC=0
tc_run_lib_fn vse_tc_validate opensysml f.sysml
tc_assert_rc 0 "opensysml: clean marks only is clean"
tc_assert_empty "$OUT" "opensysml: a clean run prints no diagnostics"

cat > "${TRANSCRIPTS}/osml-broken.txt" <<'EOF'
sysml: could not open f.sysml
EOF
tc_env "SYSML_TRANSCRIPT=${TRANSCRIPTS}/osml-broken.txt" SYSML_RC=2
tc_run_lib_fn vse_tc_validate opensysml f.sysml
tc_assert_rc 2 "opensysml: exit 2 with no diagnostic is unavailable"
tc_assert_grep "sysml exit 2" "$ERR" "opensysml: unavailable reason names the exit code"

tc_env
tc_reset_stubs

# -------------------------------------------- 9. fallback in validate

tc_config standard syside
tc_stub_syside
tc_stub_java "21.0.12"
tc_pilot_install
tc_env "PILOT_TRANSCRIPT=${TRANSCRIPTS}/pilot-clean.txt"
tc_run_lib validate a.sysml b.sysml
tc_assert_rc 0 "fallback: an expired syside licence falls through to the pilot"
tc_assert_grep "syside unavailable (licence expired, exit 2); validating with omg-pilot instead" \
    "$ERR" "fallback: one notice names the reason and the replacement"

tc_env
tc_reset_stubs
tc_pilot_uninstall
tc_run_lib validate a.sysml b.sysml
tc_assert_rc 2 "fallback: nothing installed is exit 2"
tc_assert_grep "No SysML toolchain is available (preferred: syside)" "$ERR" \
    "fallback: the summary names the preference"
tc_assert_match '^  syside: ' "$ERR" "fallback: the syside reason is listed"
tc_assert_match '^  omg-pilot: ' "$ERR" "fallback: the omg-pilot reason is listed"
tc_assert_match '^  opensysml: ' "$ERR" "fallback: the opensysml reason is listed"

# --------------------------------------------------- 10. real tools

# The three sections below run the installed toolchains. Each is
# guarded by the library's own detect, so a runner with no SysML tool
# prints SKIPPED and the stub sections above carry the assertions.
tc_env
rm -f "${REPO}/a.sysml" "${REPO}/b.sysml" "${REPO}/f.sysml"
mkdir -p "${REPO}/model"

real_clean() {
    cat > "${REPO}/model/a.sysml" <<'EOF'
package A {
    part def Sensor;
}
EOF
}

real_broken() {
    cat > "${REPO}/model/broken.sysml" <<'EOF'
package Broken {
    part def Widget {
        attribute x : NoSuchType;
    }
}
EOF
}

real_b_good() {
    cat > "${REPO}/model/b.sysml" <<'EOF'
package B {
    private import A::*;
    part s : Sensor;
}
EOF
}

real_b_bad() {
    cat > "${REPO}/model/b.sysml" <<'EOF'
package B {
    private import A::*;
    part s : Sensorr;
}
EOF
}

real_validate() {
    local tool="$1"
    shift
    tc_env
    tc_run_real bash .githooks/lib/sysml-toolchain.sh validate --tool "$tool" "$@"
}

run_real_section() {
    local tool="$1" stray

    if ! tc_real_available "$tool"; then
        tc_skip "$tool" "$(printf '%s\n' "$ERR" | head -n 1)"
        return 0
    fi

    real_clean
    real_validate "$tool" model/a.sysml
    tc_assert_rc 0 "real ${tool}: a clean model is clean"
    tc_assert_empty "$OUT" "real ${tool}: a clean model prints no diagnostics"

    real_broken
    real_validate "$tool" model/broken.sysml
    tc_assert_rc 1 "real ${tool}: an unresolved type is a finding"
    stray="$(printf '%s\n' "$OUT" \
        | grep -vE '^model/broken\.sysml:[0-9]+:[0-9]+: (error|warning): ' || true)"
    tc_assert_empty "$stray" "real ${tool}: every reported line is a diagnostic on the file"
    tc_assert_match '^model/broken\.sysml:[0-9]+:[0-9]+: error: ' "$OUT" \
        "real ${tool}: the finding is an error on the broken file"
    tc_assert_grep "NoSuchType" "$OUT" "real ${tool}: the finding names the unresolved type"

    real_clean
    real_b_good
    real_validate "$tool" model/a.sysml model/b.sysml
    tc_assert_rc 0 "real ${tool}: a cross-file reference that resolves is clean"

    real_b_bad
    real_validate "$tool" model/a.sysml model/b.sysml
    tc_assert_rc 1 "real ${tool}: a cross-file reference that does not resolve is a finding"
    tc_assert_match '^model/b\.sysml:[0-9]+:[0-9]+: error: ' "$OUT" \
        "real ${tool}: the cross-file finding maps back to model/b.sysml"

    rm -f "${REPO}/model/broken.sysml" "${REPO}/model/b.sysml" "${REPO}/model/a.sysml"
}

run_real_section omg-pilot
run_real_section opensysml
run_real_section syside

if tc_summary "check-toolchain"; then
    exit 0
fi
exit 1
