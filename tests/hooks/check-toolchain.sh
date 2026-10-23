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
. "$(cd "$(dirname "$0")" > /dev/null && pwd)/lib.sh"

# The trap goes in first, because the scratch root exists from the
# moment lib.sh is sourced and a failure inside tc_setup_repo would
# otherwise leak it.
trap tc_teardown EXIT
tc_setup_repo

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

# A JVM prints "Picked up JAVA_TOOL_OPTIONS: ..." on stderr ahead of
# its version line whenever that variable is set, which CI runners and
# managed workstations often do. The version is read from the first
# line that names one, so the banner must not hide it. The stub takes
# the whole version line, because a legacy JVM says "java version"
# where a modern one says "openjdk version".
tc_stub_java_banner_first() {
    local version_line="$1"
    tc_stub java <<EOF
#!/usr/bin/env bash
set -uo pipefail
if [ "\${1:-}" = "-version" ]; then
    echo 'Picked up JAVA_TOOL_OPTIONS: -Dfoo=bar' >&2
    echo '${version_line}' >&2
    exit 0
fi
cat > /dev/null
exit 0
EOF
}

case_java_banner_first() {
    tc_env

    tc_stub_java_banner_first 'openjdk version "21.0.12" 2026-07-21'
    tc_run_lib_fn vse_tc_java
    tc_assert_rc 0 "java: a JAVA_TOOL_OPTIONS banner before 21.0.12 is skipped"

    tc_stub_java_banner_first 'java version "1.8.0_402"'
    tc_run_lib_fn vse_tc_java
    tc_assert_rc 1 "java: a JAVA_TOOL_OPTIONS banner before 1.8.0_402 is rejected"
    tc_assert_grep "is major 8, need 21 or later" "$ERR" \
        "java: the reason past a banner names major 8"
}

case_java_banner_first

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

# A java that never gets far enough to print a version banner. The
# resolution order has to fall off the end for the reason it recorded to
# be the one reported, so the dead binary must be the only java in
# reach: VSE_JAVA names it and PATH lists its directory first (the
# sandbox unsets JAVA_HOME).
mkdir -p "${STUBS}/deadjava"
cat > "${STUBS}/deadjava/java" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
echo 'Error occurred during initialization of VM' >&2
echo 'Could not reserve enough space for object heap' >&2
exit 1
EOF
chmod +x "${STUBS}/deadjava/java"

tc_env "VSE_JAVA=${STUBS}/deadjava/java" "PATH=${STUBS}/deadjava:${STUBS}:/usr/bin:/bin"
tc_run_lib java
tc_assert_rc 2 "java: a JVM that never starts is rejected"
tc_assert_grep "java at ${STUBS}/deadjava/java printed no version line. It said: Error occurred during initialization of VM" \
    "$ERR" "java: the reason quotes the first line the binary printed, as what it said"

# A JVM that prints the JAVA_TOOL_OPTIONS banner and no version line.
# The banner is not quoted as if it were the version line, and the
# JVM runs once, not a second time to read the line to quote.
mkdir -p "${STUBS}/bannerjava"
cat > "${STUBS}/bannerjava/java" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
printf 'run\n' >> "${TC_INVOCATIONS:-/dev/null}"
echo 'Picked up JAVA_TOOL_OPTIONS: -Dfoo=bar' >&2
exit 1
EOF
chmod +x "${STUBS}/bannerjava/java"
: > "${FAKEHOME}/java-runs"
tc_env "VSE_JAVA=${STUBS}/bannerjava/java" "PATH=${STUBS}/bannerjava:${STUBS}:/usr/bin:/bin" \
    "TC_INVOCATIONS=${FAKEHOME}/java-runs"
tc_run_lib java
tc_assert_rc 2 "java: a JVM that prints only the banner is rejected"
tc_assert_grep "java at ${STUBS}/bannerjava/java printed no version line" "$ERR" \
    "java: the reason says no version line was printed"
tc_assert_not_grep "Picked up" "$ERR" "java: the banner is not quoted as the version line"
# VSE_JAVA and PATH both name this binary, so it fills two candidate
# slots, and a binary already tried is not run again.
tc_assert_eq 1 "$(grep -c '^run$' "${FAKEHOME}/java-runs" || true)" \
    "java: a binary named by two candidate slots runs once"

# JAVA_HOME/bin/java is often the java on PATH through a symbolic link.
# A candidate is resolved through its links before it runs, so a Java
# 17 that VSE_JAVA and PATH reach through a relative link and JAVA_HOME
# names directly runs once, and the reason still names it.
mkdir -p "${STUBS}/home17/bin" "${STUBS}/linkbin"
cat > "${STUBS}/home17/bin/java" <<'JAVA17'
#!/usr/bin/env bash
set -uo pipefail
printf 'run\n' >> "${TC_INVOCATIONS:-/dev/null}"
echo 'openjdk version "17.0.2" 2022-01-18' >&2
exit 0
JAVA17
chmod +x "${STUBS}/home17/bin/java"
ln -s ../home17/bin/java "${STUBS}/linkbin/java"
: > "${FAKEHOME}/java17-runs"
tc_env "VSE_JAVA=${STUBS}/linkbin/java" "JAVA_HOME=${STUBS}/home17" \
    "PATH=${STUBS}/linkbin:${STUBS}:/usr/bin:/bin" "TC_INVOCATIONS=${FAKEHOME}/java17-runs"
tc_run_lib java
tc_assert_rc 2 "java: a Java 17 in every candidate slot is rejected"
tc_assert_grep "java at ${STUBS}/linkbin/java is major 17, need 21 or later" "$ERR" \
    "java: the reason names the first slot that reached the Java 17"
tc_assert_eq 1 "$(grep -c '^run$' "${FAKEHOME}/java17-runs" || true)" \
    "java: a binary reached through a link from other slots runs once"

tc_env

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

# The reason comes from the first lines, and the output goes on for
# more than a pipe buffer holds (64 KiB). The whole output is read, so
# the reason is found every time, not only when the writer finished
# before the reader stopped.
tc_stub syside <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
echo "License check failed:"
echo "  License expired. Please contact the Syside support team."
awk 'BEGIN { for (i = 1; i <= 10000; i++) printf "  detail %05d of a long report\n", i }'
exit 2
EOF
tc_run_lib detect syside
tc_assert_rc 2 "detect syside: expired licence with a long report is unavailable"
tc_assert_grep "syside unavailable (licence expired, exit 2)" "$ERR" \
    "detect syside: expired licence reason found in a long report"

tc_stub syside <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
echo "Error: No display server detected and 'xvfb-run' is not installed." >&2
awk 'BEGIN { for (i = 1; i <= 10000; i++) printf "  detail %05d of a long report\n", i }' >&2
exit 1
EOF
tc_run_lib detect syside
tc_assert_rc 2 "detect syside: a headless launcher with a long report is unavailable"
tc_assert_grep "syside unavailable (no display server" "$ERR" \
    "detect syside: headless launcher reason found in a long report"

# Any other failure quotes the first line of the output, however long
# the output runs.
tc_stub syside <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
echo "Error: the probe model could not be read"
awk 'BEGIN { for (i = 1; i <= 10000; i++) printf "  detail %05d of a long report\n", i }'
exit 3
EOF
tc_run_lib detect syside
tc_assert_rc 2 "detect syside: another failure with a long report is unavailable"
tc_assert_grep "syside unavailable (syside exit 3 on the probe model: Error: the probe model could not be read)" "$ERR" \
    "detect syside: another failure quotes the first line of a long report"

tc_stub_syside
tc_env SYSIDE_OK=1
tc_run_lib detect syside
tc_assert_rc 0 "detect syside: a passing check is available"

# The launcher refuses to start without X11, Wayland or xvfb-run. That
# is the tool being unavailable on this machine, not a model finding.
tc_env
tc_stub syside <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
echo "Error: No display server detected and 'xvfb-run' is not installed." >&2
exit 1
EOF
tc_run_lib detect syside
tc_assert_rc 2 "detect syside: a headless launcher is unavailable"
tc_assert_grep "syside unavailable (no display server" "$ERR" \
    "detect syside: headless launcher reason"

tc_env
rm -f "${STUBS}/syside"
tc_run_lib detect syside
tc_assert_rc 2 "detect syside: absent binary is unavailable"
tc_assert_grep "syside not on PATH" "$ERR" "detect syside: absent binary reason"

# A hung probe on a machine without coreutils timeout, which is what
# macOS gives. The library tries timeout, then gtimeout (the name
# Homebrew coreutils installs it under), then perl, and only then runs
# the probe with no limit. Each case takes timeout and gtimeout out of
# PATH, keeps the stub directory in front, and sets the probe budget to
# one second. The syside stub is a launcher script that waits in a
# child process, so a limit that stops the script alone leaves the
# child holding the output open, and the probe still hangs.
TC_BIN_NO_TIMEOUT="$(tc_bin_without timeout gtimeout)"
TC_BIN_NO_TIMEOUT_PERL="$(tc_bin_without timeout gtimeout perl)"
TC_GTIMEOUT_RECORD="${FAKEHOME}/gtimeout-runs"

tc_stub syside <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
exit 0
EOF
tc_stub gtimeout <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
printf '%s\n' "${1:-}" >> "${TC_GTIMEOUT_RECORD:-/dev/null}"
shift
exec "$@"
EOF
tc_env "PATH=${STUBS}:${TC_BIN_NO_TIMEOUT}" VSE_TC_PROBE_TIMEOUT=1 \
    "TC_GTIMEOUT_RECORD=${TC_GTIMEOUT_RECORD}"
tc_run_lib detect syside
tc_assert_rc 0 "detect syside, no timeout: the probe runs under gtimeout"
tc_assert_eq 1 "$(head -n 1 "$TC_GTIMEOUT_RECORD" 2>/dev/null || true)" \
    "detect syside, no timeout: gtimeout is handed the probe budget"
rm -f "${STUBS}/gtimeout"

tc_stub syside <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
sleep 5
exit 0
EOF
tc_env "PATH=${STUBS}:${TC_BIN_NO_TIMEOUT}" VSE_TC_PROBE_TIMEOUT=1
TC_START=$SECONDS
tc_run_lib detect syside
TC_ELAPSED=$((SECONDS - TC_START))
tc_assert_rc 2 "detect syside, no timeout or gtimeout: a hung probe is unavailable"
tc_assert_grep "syside unavailable (syside timed out)" "$ERR" \
    "detect syside, no timeout or gtimeout: the reason is a timeout"
if [ "$TC_ELAPSED" -le 3 ]; then
    tc_pass "detect syside, no timeout or gtimeout: perl gives up within 3 seconds"
else
    tc_fail "detect syside, no timeout or gtimeout: perl gives up within 3 seconds" \
        "took ${TC_ELAPSED} seconds"
fi

# A probe that fails at once under the perl fallback keeps its own exit
# status, so detection quotes the tool's reason and does not read the
# failure as a timeout.
tc_stub syside <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
echo "Error: the probe model could not be read"
exit 3
EOF
tc_env "PATH=${STUBS}:${TC_BIN_NO_TIMEOUT}" VSE_TC_PROBE_TIMEOUT=1
tc_run_lib detect syside
tc_assert_rc 2 "detect syside, perl fallback: a probe that fails at once is unavailable"
tc_assert_grep "syside unavailable (syside exit 3 on the probe model: Error: the probe model could not be read)" "$ERR" \
    "detect syside, perl fallback: the reason is the probe's own exit status and first line"
tc_assert_not_grep "timed out" "$ERR" \
    "detect syside, perl fallback: a probe that fails at once is not read as a timeout"

# A command the perl fallback cannot start exits 127, and the reason is
# printed on stderr, as coreutils timeout prints it.
tc_env "PATH=${STUBS}:${TC_BIN_NO_TIMEOUT}"
tc_run_lib_fn _vse_tc_timeout 5 no-such-validator
tc_assert_rc 127 "perl fallback, no such command: exit 127"
tc_assert_line "timeout: failed to run command 'no-such-validator': No such file or directory" "$ERR" \
    "perl fallback, no such command: the reason is printed on stderr"

# A signal that reaches the perl fallback (INT from Ctrl-C, TERM or
# HUP) is passed on to the command's process group, as coreutils
# timeout passes it on. Without that, Ctrl-C during a hung licence
# check stops perl and its alarm but not the command, which runs on in
# a group the terminal no longer reaches. The launcher stub records its
# process group (its own process ID, as it leads the group) and the
# wrapper's process ID (its parent), then waits in a child. Each case
# signals the wrapper, then checks that the wrapper ended with that
# signal and that no member of the group is left. A zombie (a process
# that has ended and waits only to be collected by its parent) does not
# count. The budget is 20 seconds and a case waits at most 5, so a pass
# never comes from the alarm. A command at a terminal has INT at its
# default, but bash 3.2 starts a background job with INT ignored, so
# the case resets INT before it starts the driver.
TC_GROUP_RECORD="${FAKEHOME}/group-record"
TC_WRAPPER_RC="${FAKEHOME}/wrapper-rc"
TC_WRAPPER_OUT="${FAKEHOME}/wrapper-out"
tc_stub hung-launcher <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
printf '%s %s\n' "$$" "$PPID" > "$TC_GROUP_RECORD"
if [ "${TC_LAUNCHER_STOP:-0}" = 1 ]; then
    kill -s STOP "$$"
fi
sleep 60
exit 0
EOF

# Print the members of process group $1 that are still running.
tc_group_members() {
    ps -A -o pgid= -o stat= -o pid= -o args= | awk -v g="$1" '$1 == g && $2 !~ /^Z/'
}

# The caller case runs this driver instead of the library's, so that
# whether the caller goes on after the wrapper shows on stdout.
# shellcheck disable=SC2016
TC_CALLER_DRIVER='
. ./.githooks/lib/sysml-toolchain.sh
set +e
_vse_tc_timeout 20 hung-launcher
echo "the caller went on after exit $?"
'

# tc_signal_case <signal> <rc> <mode> <case>: run the wrapper on the
# launcher in the background, signal it, and expect exit <rc> with no
# member of the group left. The mode is one of:
#   wrapper  the signal goes to the wrapper alone.
#   stopped  the launcher stops itself first, and the signal waits
#            until it has.
#   caller   the signal goes to the caller and the wrapper together, as
#            Ctrl-C reaches every process in the foreground, and the
#            caller must stop rather than go on.
tc_signal_case() {
    local sig="$1" want="$2" mode="$3" name="$4" bg grp="" wrapper="" i left
    local stop=0 driver="$TC_DRIVER" targets
    [ "$mode" = stopped ] && stop=1
    [ "$mode" = caller ] && driver="$TC_CALLER_DRIVER"
    rm -f "$TC_GROUP_RECORD" "$TC_WRAPPER_RC" "$TC_WRAPPER_OUT"
    tc_env "PATH=${STUBS}:${TC_BIN_NO_TIMEOUT}" "TC_GROUP_RECORD=${TC_GROUP_RECORD}" \
        "TC_LAUNCHER_STOP=${stop}"
    # The perl program is perl's, not this shell's, to expand.
    # shellcheck disable=SC2016
    ( _tc_sandboxed perl -e '$SIG{INT} = "DEFAULT"; exec { $ARGV[0] } @ARGV' \
        bash -c "$driver" tc-driver _vse_tc_timeout 20 hung-launcher
      printf '%s\n' "$OUT" > "$TC_WRAPPER_OUT"
      printf '%s\n' "$RC" > "$TC_WRAPPER_RC" ) &
    bg=$!
    i=0
    while [ ! -s "$TC_GROUP_RECORD" ] && [ "$i" -lt 50 ]; do
        sleep 0.1
        i=$((i + 1))
    done
    if [ -s "$TC_GROUP_RECORD" ]; then
        read -r grp wrapper < "$TC_GROUP_RECORD" || true
    fi
    if [ -z "$grp" ] || [ -z "$wrapper" ]; then
        tc_fail "${name}: the launcher starts" "no group record after 5 seconds"
        wait "$bg" || true
        return 0
    fi
    i=0
    while [ "$stop" = 1 ] && [ "$i" -lt 50 ]; do
        case "$(ps -o stat= -p "$grp" || true)" in
            *T*) break ;;
        esac
        sleep 0.1
        i=$((i + 1))
    done
    targets="$wrapper"
    if [ "$mode" = caller ]; then
        targets="$(ps -o ppid= -p "$wrapper" | tr -d ' ') ${wrapper}"
    fi
    # shellcheck disable=SC2086
    kill -s "$sig" $targets 2>/dev/null || true
    i=0
    while [ ! -s "$TC_WRAPPER_RC" ] && [ "$i" -lt 50 ]; do
        sleep 0.1
        i=$((i + 1))
    done
    if [ -s "$TC_WRAPPER_RC" ]; then
        tc_assert_eq "$want" "$(cat "$TC_WRAPPER_RC")" "${name}: the wrapper ends with the signal"
    else
        tc_fail "${name}: the wrapper ends with the signal" \
            "still running 5 seconds after ${sig}"
        kill -s KILL "$wrapper" 2>/dev/null || true
    fi
    if [ "$mode" = caller ]; then
        if grep -qF "the caller went on" "$TC_WRAPPER_OUT" 2>/dev/null; then
            tc_fail "${name}: the caller stops as well" "$(cat "$TC_WRAPPER_OUT")"
        else
            tc_pass "${name}: the caller stops as well"
        fi
    fi
    i=0
    left="$(tc_group_members "$grp")"
    while [ -n "$left" ] && [ "$i" -lt 30 ]; do
        sleep 0.1
        i=$((i + 1))
        left="$(tc_group_members "$grp")"
    done
    if [ -z "$left" ]; then
        tc_pass "${name}: no member of the command's group is left"
    else
        tc_fail "${name}: no member of the command's group is left" "$left"
    fi
    kill -s KILL -- "-${grp}" 2>/dev/null || true
    wait "$bg" || true
}

tc_signal_case INT 130 wrapper "perl fallback, INT"
tc_signal_case TERM 143 wrapper "perl fallback, TERM"
tc_signal_case HUP 129 wrapper "perl fallback, HUP"
# CONT follows the passed-on signal, so a stopped member wakes to
# receive it rather than holding the wrapper until the alarm.
tc_signal_case TERM 143 stopped "perl fallback, TERM to a stopped command"
# Perl ends itself with the signal it passed on. A shell that took
# Ctrl-C while it waited stops only when its command died of INT, and
# goes on when the command exited normally, even with status 130.
tc_signal_case INT 130 caller "perl fallback, Ctrl-C"
rm -f "${STUBS}/hung-launcher"
tc_env

# With no perl either, the probe runs with no limit, so a slow probe
# that passes is still read as available.
tc_stub syside <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
sleep 2
exit 0
EOF
tc_env "PATH=${STUBS}:${TC_BIN_NO_TIMEOUT_PERL}" VSE_TC_PROBE_TIMEOUT=1
tc_run_lib detect syside
tc_assert_rc 0 "detect syside, no timeout, gtimeout or perl: the probe runs with no limit"

tc_env
rm -f "${STUBS}/syside"

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

# ------------------------------------ 10. validate --tool reports why

# validate --tool runs one named tool and hands back its exit code. An
# unavailable tool is exit 2, and a caller that sees only the code has
# nothing to act on, so the reason reaches stderr on that path too.
tc_config standard omg-pilot
tc_stub_java "21.0.12"
EMPTY_PILOT_HOME="$(tc_mktemp_d)"
tc_env "VSE_SYSML_PILOT_HOME=${EMPTY_PILOT_HOME}"
tc_run_lib validate --tool omg-pilot a.sysml
tc_assert_rc 2 "validate --tool: an uninstalled pilot is exit 2"
tc_assert_grep "omg-pilot unavailable (pilot jar not found" "$ERR" \
    "validate --tool: the reason names what is missing"

# A JVM that refuses to start writes its complaint to stderr and leaves
# stdout empty, so the reason comes from the stderr the run keeps. The
# log4j line the pilot's own logging emits is not the complaint.
tc_stub_dead_jvm() {
    tc_stub java <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
if [ "${1:-}" = "-version" ]; then
    echo 'openjdk version "21.0.12" 2026-07-21' >&2
    exit 0
fi
cat > /dev/null
echo 'Could not reserve enough space for code cache' >&2
echo 'log4j:WARN Please initialize the log4j system properly.' >&2
exit 1
EOF
}

tc_stub_dead_jvm
tc_pilot_install
tc_env
tc_run_lib validate --tool omg-pilot a.sysml
tc_assert_rc 2 "validate --tool: a JVM that will not run is exit 2"
tc_assert_grep "pilot JVM exit 1: Could not reserve enough space for code cache" "$ERR" \
    "validate --tool: the reason quotes the JVM's own stderr"

tc_env
tc_reset_stubs
tc_pilot_uninstall

# ---------------------------------------------- 11. staged context

# vse_tc_run_staged widens the context to every tracked .sysml file so
# that cross-file names resolve, minus the directories that hold
# generated or throwaway models. A tracked file under a nested build/
# directory is one of those, and only the exclusion pattern keeps it
# out, so the stub records the file list it was handed.
tc_stub_sysml_recorder() {
    tc_stub sysml <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
if [ "${1:-}" = "-version" ]; then
    echo 'sysml v0.6.0'
    exit 0
fi
printf '%s\n' "$*" >> "${SYSML_ARGS:-/dev/null}"
exit 0
EOF
}

tc_config standard opensysml
tc_write engineering/model/g.sysml <<'EOF'
package G {
    part def Gadget;
}
EOF
tc_write engineering/build/x.sysml <<'EOF'
package X {
    part def Generated;
}
EOF
tc_stage f.sysml engineering/model/g.sysml engineering/build/x.sysml
tc_commit "staged-context fixture"

STAGED_ARGS="${TRANSCRIPTS}/staged-args.txt"
: > "$STAGED_ARGS"
tc_stub_sysml_recorder
tc_env "SYSML_ARGS=${STAGED_ARGS}"
tc_run_lib_fn vse_tc_run_staged f.sysml
tc_assert_rc 0 "staged context: a clean run over the widened context is clean"
tc_assert_grep "engineering/model/g.sysml" "$(cat "$STAGED_ARGS")" \
    "staged context: a tracked model outside the staged set joins the context"
tc_assert_not_grep "engineering/build/x.sysml" "$(cat "$STAGED_ARGS")" \
    "staged context: a tracked file under a nested build/ stays out"

tc_env
tc_reset_stubs

# The validator reads the widened context, but only the diagnostics on
# the staged files are reported. The staged list is one name per line,
# and BWK awk (macOS) refuses a newline in an awk -v value, so the list
# reaches awk through the environment. The case runs with the awk of the
# machine and again with the BWK awk stub.
cat > "${TRANSCRIPTS}/osml-two-files.txt" <<'EOF'
f.sysml:2:5: error: unresolved reference: NoSuchType
engineering/model/g.sysml:2:5: error: unresolved reference: NoSuchPart
EOF
for STAGED_AWK in "machine awk" "BWK awk"; do
    tc_stub_sysml "sysml v0.6.0"
    if [ "$STAGED_AWK" = "BWK awk" ]; then
        tc_stub_bwk_awk
    fi
    tc_env "SYSML_TRANSCRIPT=${TRANSCRIPTS}/osml-two-files.txt" SYSML_RC=1
    tc_run_lib_fn vse_tc_run_staged f.sysml
    tc_assert_rc 1 "staged filter, ${STAGED_AWK}: a finding on the staged file stops the run"
    tc_assert_eq "f.sysml:2:5: error: unresolved reference: NoSuchType" "$OUT" \
        "staged filter, ${STAGED_AWK}: only the staged file's diagnostic is kept"
    tc_env
    tc_reset_stubs
done

# --------------------------------------------------- 12. real tools

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
