#!/usr/bin/env bash
# Shared SysML v2 toolchain helpers for the project-side git hooks, the
# SessionStart lifecycle hook, the CI templates, the sysml-toolchain
# skill, and the project audit.
#
# Three toolchains: syside (Sensmetry Syside CLI), omg-pilot (OMG SysML
# v2 Pilot Implementation, Java 21 or later), opensysml (Open-MBEE
# OpenSysML). The project records its preference as the flat key
# sysml_toolchain in .iso-config.yaml. Absent means syside. When the
# preferred tool is unavailable the helpers fall back along the fixed
# order syside, omg-pilot, opensysml and print one notice naming why.
#
# Contract of vse_tc_validate, vse_tc_run and vse_tc_run_staged:
#   exit 0  clean (warnings count as findings, as --warnings-as-errors)
#   exit 1  findings on stdout, one per line: file:line:col: severity: message
#   exit 2  toolchain unavailable, reason on stderr as
#           [<tag>] <tool> unavailable (<reason>)
#
# Sourced like iso-profile.sh by pre-commit and session-start. Executed
# by CI, the Makefile check, the audit and the sysml-toolchain skill:
#   sysml-toolchain.sh preference | candidates | java | status
#   sysml-toolchain.sh detect <tool>
#   sysml-toolchain.sh validate [--tool <tool>] <file>...
#
# Environment: VSE_SYSML_TOOLCHAIN (one-run override of the key),
# VSE_SYSML_PILOT_HOME (pilot unpack directory, default
# $HOME/.local/share/sysml-pilot), VSE_JAVA (java binary, checked before
# JAVA_HOME/bin/java and java on PATH), VSE_TC_TAG (notice prefix),
# VSE_TC_TIMEOUT (seconds per validator run, default 180),
# VSE_TC_PROBE_TIMEOUT (seconds per availability probe, default 20).
#
# Portability: bash 3.2 (no mapfile, no associative arrays) and POSIX
# awk (mawk is the Ubuntu default: no match(s, r, arr), no {n} counts).
#
# Install as <project>/.githooks/lib/sysml-toolchain.sh at every profile.
set -euo pipefail

VSE_TC_TAG="${VSE_TC_TAG:-sysml-toolchain}"
VSE_TC_TIMEOUT="${VSE_TC_TIMEOUT:-180}"
VSE_TC_PROBE_TIMEOUT="${VSE_TC_PROBE_TIMEOUT:-20}"
VSE_TC_ORDER="syside omg-pilot opensysml"
VSE_TC_REASON=""
# shellcheck disable=SC2034
VSE_TC_USED=""
VSE_TC_JAVA=""
VSE_TC_PILOT_JAR=""
VSE_TC_PILOT_LIB=""

# Reuse the configuration locator from iso-profile.sh when it sits
# beside this file and has not been sourced already.
if [ -z "${ISO_CONFIG_FILE+x}" ]; then
    _vse_tc_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -r "${_vse_tc_dir}/iso-profile.sh" ]; then
        # shellcheck source=/dev/null
        . "${_vse_tc_dir}/iso-profile.sh"
    else
        ISO_CONFIG_FILE=""
    fi
fi

# Read one top-level scalar. Uses the iso-profile reader when present,
# otherwise the same awk idiom against the same two locations.
_vse_tc_scalar() {
    local key="$1" root cfg="" value
    if command -v _iso_scalar >/dev/null 2>&1; then
        _iso_scalar "$key"
        return 0
    fi
    root="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
    if [ -f "${root}/.iso-config.yaml" ]; then
        cfg="${root}/.iso-config.yaml"
    elif [ -f "${root}/engineering/.iso-config.yaml" ]; then
        cfg="${root}/engineering/.iso-config.yaml"
    fi
    [ -n "$cfg" ] || return 0
    value=$(awk -v key="$key" '
        $0 ~ ("^" key ":") {
            sub(/^[A-Za-z_]+:[[:space:]]*/, "")
            sub(/[[:space:]]*#.*$/, "")
            sub(/[[:space:]]+$/, "")
            print
            exit
        }
    ' "$cfg")
    value="${value%\"}"; value="${value#\"}"
    value="${value%\'}"; value="${value#\'}"
    printf '%s\n' "$value"
}

# timeout is coreutils. A platform without it runs the command bare.
_vse_tc_timeout() {
    local secs="$1"
    shift
    if command -v timeout >/dev/null 2>&1; then
        timeout "$secs" "$@"
    else
        "$@"
    fi
}

# Print the recorded preference: syside, omg-pilot, or opensysml.
vse_tc_preference() {
    local value="${VSE_SYSML_TOOLCHAIN:-}"
    [ -n "$value" ] || value="$(_vse_tc_scalar sysml_toolchain)"
    case "$value" in
        syside|omg-pilot|opensysml) printf '%s\n' "$value" ;;
        "") printf 'syside\n' ;;
        *)
            echo "[${VSE_TC_TAG}] Unrecognised sysml_toolchain '${value}', using syside (the absent-key default)." >&2
            printf 'syside\n'
            ;;
    esac
}

# Print the candidates, one per line: the preference, then the others
# in the fixed order.
vse_tc_candidates() {
    local pref tool
    pref="$(vse_tc_preference)"
    printf '%s\n' "$pref"
    for tool in $VSE_TC_ORDER; do
        [ "$tool" = "$pref" ] || printf '%s\n' "$tool"
    done
}

# Resolve a Java 21 or later binary into VSE_TC_JAVA. Order: VSE_JAVA,
# JAVA_HOME/bin/java, java on PATH. Returns 1 with VSE_TC_REASON set.
vse_tc_java() {
    local candidate major
    VSE_TC_JAVA=""
    VSE_TC_REASON=""
    for candidate in "${VSE_JAVA:-}" "${JAVA_HOME:+${JAVA_HOME}/bin/java}" "$(command -v java 2>/dev/null || true)"; do
        # The trailing || continue is the intent, not an else branch:
        # an empty or non-executable candidate is skipped.
        # shellcheck disable=SC2015
        [ -n "$candidate" ] && [ -x "$candidate" ] || continue
        major="$("$candidate" -version 2>&1 | sed -n '1s/.*version "\([0-9][0-9]*\)\(\.[0-9][0-9]*\)*.*/\1/p')"
        if [ "$major" = "1" ]; then
            major="$("$candidate" -version 2>&1 | sed -n '1s/.*version "1\.\([0-9][0-9]*\).*/\1/p')"
        fi
        if [ -n "$major" ] && [ "$major" -ge 21 ] 2>/dev/null; then
            VSE_TC_JAVA="$candidate"
            return 0
        fi
        VSE_TC_REASON="java at ${candidate} is major ${major:-unknown}, need 21 or later"
    done
    [ -n "$VSE_TC_REASON" ] || VSE_TC_REASON="java not found (install Java 21 or later, or set JAVA_HOME or VSE_JAVA)"
    return 1
}

vse_tc_pilot_home() {
    printf '%s\n' "${VSE_SYSML_PILOT_HOME:-${HOME}/.local/share/sysml-pilot}"
}

# Resolve the pilot jar and library into VSE_TC_PILOT_JAR and
# VSE_TC_PILOT_LIB, both absolute. A relative library path is
# percent-encoded by EMF and fails on 'Kernel Libraries'.
vse_tc_pilot_paths() {
    local home jar
    home="$(vse_tc_pilot_home)"
    VSE_TC_PILOT_JAR=""
    VSE_TC_PILOT_LIB=""
    jar="$(find "${home}/sysml" -maxdepth 1 -name 'jupyter-sysml-kernel-*-all.jar' 2>/dev/null | sort | tail -n 1)"
    if [ -z "$jar" ] || [ ! -r "$jar" ]; then
        VSE_TC_REASON="pilot jar not found under ${home}/sysml (run /vse-toolchain to install)"
        return 1
    fi
    if [ ! -d "${home}/sysml/sysml.library" ]; then
        VSE_TC_REASON="pilot sysml.library not found under ${home}/sysml"
        return 1
    fi
    VSE_TC_PILOT_JAR="$(cd "$(dirname "$jar")" && pwd)/$(basename "$jar")"
    VSE_TC_PILOT_LIB="$(cd "${home}/sysml/sysml.library" && pwd)"
    return 0
}

# Classify a syside run. Sets VSE_TC_REASON when the run means
# "unavailable" rather than "findings". The licence failure is text on
# stdout with exit 2, so the text is the key, not the code.
_vse_tc_classify_syside() {
    local rc="$1" out="$2"
    VSE_TC_REASON=""
    case "$rc" in
        0) return 0 ;;
        124) VSE_TC_REASON="syside timed out" ;;
        127) VSE_TC_REASON="syside not on PATH" ;;
        *)
            if printf '%s\n' "$out" | grep -q 'License check failed'; then
                if printf '%s\n' "$out" | grep -qi 'expired'; then
                    VSE_TC_REASON="licence expired, exit ${rc}"
                else
                    VSE_TC_REASON="licence check failed, exit ${rc}"
                fi
            fi
            ;;
    esac
    return 0
}

_vse_tc_detect_syside() {
    local dir out rc=0
    if ! command -v syside >/dev/null 2>&1; then
        VSE_TC_REASON="syside not on PATH"
        return 0
    fi
    # Only a real check detects an expired licence (--version passes).
    dir="$(mktemp -d "${TMPDIR:-/tmp}/vse-tc.XXXXXX")"
    printf 'package VseToolchainProbe {\n    part def Probe;\n}\n' > "${dir}/probe.sysml"
    out="$(_vse_tc_timeout "$VSE_TC_PROBE_TIMEOUT" syside check "${dir}/probe.sysml" 2>&1)" || rc=$?
    rm -rf "$dir"
    _vse_tc_classify_syside "$rc" "$out"
    if [ -z "$VSE_TC_REASON" ] && [ "$rc" -ne 0 ]; then
        VSE_TC_REASON="syside exit ${rc} on the probe model: $(printf '%s\n' "$out" | head -n 1)"
    fi
}

_vse_tc_detect_pilot() {
    vse_tc_java || return 0
    vse_tc_pilot_paths || return 0
}

_vse_tc_detect_opensysml() {
    local ver
    if ! command -v sysml >/dev/null 2>&1; then
        VSE_TC_REASON="sysml (OpenSysML) not on PATH"
        return 0
    fi
    ver="$(_vse_tc_timeout "$VSE_TC_PROBE_TIMEOUT" sysml -version 2>&1 | head -n 1 || true)"
    case "$ver" in
        sysml\ *) : ;;   # "sysml v0.6.0" or "sysml dev"
        *) VSE_TC_REASON="sysml on PATH is not OpenSysML (-version printed '${ver}')" ;;
    esac
}

# vse_tc_detect <tool>: exit 0 available, exit 2 unavailable with the
# reason on stderr and in VSE_TC_REASON.
vse_tc_detect() {
    local tool="$1"
    VSE_TC_REASON=""
    case "$tool" in
        syside)    _vse_tc_detect_syside ;;
        omg-pilot) _vse_tc_detect_pilot ;;
        opensysml) _vse_tc_detect_opensysml ;;
        *) VSE_TC_REASON="unknown toolchain '${tool}'" ;;
    esac
    if [ -n "$VSE_TC_REASON" ]; then
        echo "[${VSE_TC_TAG}] ${tool} unavailable (${VSE_TC_REASON})" >&2
        return 2
    fi
    return 0
}

_vse_tc_validate_syside() {
    local out rc=0
    if ! command -v syside >/dev/null 2>&1; then
        VSE_TC_REASON="syside not on PATH"
        return 2
    fi
    out="$(_vse_tc_timeout "$VSE_TC_TIMEOUT" syside check --warnings-as-errors "$@" 2>&1)" || rc=$?
    _vse_tc_classify_syside "$rc" "$out"
    [ -z "$VSE_TC_REASON" ] || return 2
    [ "$rc" -eq 0 ] && return 0
    # "file:line:col: error (CODE): message" to "file:line:col: error: (CODE) message".
    printf '%s\n' "$out" | sed -E 's/^([^:]+:[0-9]+:[0-9]+): (error|warning|info|hint) \(([^)]+)\): /\1: \2: (\3) /'
    return 1
}

# One JVM per run: all files concatenated into ONE % block (names do
# not resolve across blocks). An offset table maps the pilot's
# "(1.sysml line : N column : C)" back to file:line.
_vse_tc_validate_pilot() {
    local dir out rc=0 diag
    vse_tc_java || return 2
    vse_tc_pilot_paths || return 2
    dir="$(mktemp -d "${TMPDIR:-/tmp}/vse-tc.XXXXXX")"
    # awk 1 normalises a missing final newline, so the table stays exact.
    awk 'FNR == 1 { printf "%d\t%s\n", NR, FILENAME }' "$@" > "${dir}/offsets"
    { printf '%%\n'; awk '1' "$@"; printf '\n%%\n%%exit\n'; } > "${dir}/block.sysml"
    out="$(_vse_tc_timeout "$VSE_TC_TIMEOUT" "$VSE_TC_JAVA" -cp "$VSE_TC_PILOT_JAR" \
            org.omg.sysml.interactive.SysMLInteractive "$VSE_TC_PILOT_LIB" \
            < "${dir}/block.sysml" 2>/dev/null)" || rc=$?
    case "$rc" in
        0) ;;
        124)
            rm -rf "$dir"
            VSE_TC_REASON="pilot timed out after ${VSE_TC_TIMEOUT}s"
            return 2
            ;;
        *)
            rm -rf "$dir"
            VSE_TC_REASON="pilot JVM exit ${rc}: $(printf '%s\n' "$out" | grep -v '^Reading ' | tail -n 1)"
            return 2
            ;;
    esac
    rc=0
    diag="$(printf '%s\n' "$out" | awk -v offsets="${dir}/offsets" '
        BEGIN {
            while ((getline line < offsets) > 0) {
                split(line, f, "\t"); n++; start[n] = f[1] + 0; name[n] = f[2]
            }
            close(offsets)
        }
        /^Reading / { next }
        /^SysML v2 Pilot Implementation$/ { next }
        { sub(/^[0-9]+> /, "") }
        /^[[:space:]]*$/ { next }
        /^[A-Za-z]+ [^ ]+ \([0-9a-f-]+\)$/ { built = 1; next }
        /^[A-Za-z]+ <[^>]+> [^ ]+ \([0-9a-f-]+\)$/ { built = 1; next }
        /^(ERROR|WARNING):.* \(1\.sysml line : [0-9]+ column : [0-9]+\)$/ {
            sev = ($0 ~ /^ERROR:/) ? "error" : "warning"
            msg = $0
            sub(/^(ERROR|WARNING):/, "", msg)
            loc = msg
            sub(/^.* \(1\.sysml line : /, "", loc)
            sub(/\)$/, "", loc)
            split(loc, lc, " column : ")
            line = lc[1] + 0; col = lc[2] + 0
            sub(/ \(1\.sysml line : [0-9]+ column : [0-9]+\)$/, "", msg)
            fi = 1
            for (i = 1; i <= n; i++) if (start[i] <= line) fi = i
            printf "%s:%d:%d: %s: %s\n", name[fi], line - start[fi] + 1, col, sev, msg
            found++
            next
        }
        END { if (found == 0 && !built) exit 3 }
    ')" || rc=$?
    rm -rf "$dir"
    if [ "$rc" -eq 3 ]; then
        VSE_TC_REASON="pilot produced neither a root element nor a diagnostic"
        return 2
    fi
    if [ -n "$diag" ]; then
        printf '%s\n' "$diag"
        return 1
    fi
    return 0
}

# OpenSysML: diagnostics on stderr, GNU style; exit 0 leaves warnings
# in place, so warning lines are promoted to findings here.
_vse_tc_validate_opensysml() {
    local out rc=0 diag
    if ! command -v sysml >/dev/null 2>&1; then
        VSE_TC_REASON="sysml (OpenSysML) not on PATH"
        return 2
    fi
    out="$(_vse_tc_timeout "$VSE_TC_TIMEOUT" sysml -validate -strict "$@" 2>&1)" || rc=$?
    diag="$(printf '%s\n' "$out" | grep -E '^[^:]+:[0-9]+:[0-9]+: (error|warning): ' || true)"
    case "$rc" in
        0)
            [ -n "$diag" ] || return 0
            printf '%s\n' "$diag"
            return 1
            ;;
        1|2)
            if [ -n "$diag" ]; then
                printf '%s\n' "$diag"
                return 1
            fi
            VSE_TC_REASON="sysml exit ${rc}: $(printf '%s\n' "$out" | tail -n 1)"
            return 2
            ;;
        124)
            VSE_TC_REASON="sysml timed out after ${VSE_TC_TIMEOUT}s"
            return 2
            ;;
        *)
            VSE_TC_REASON="sysml exit ${rc}: $(printf '%s\n' "$out" | tail -n 1)"
            return 2
            ;;
    esac
}

# vse_tc_validate <tool> <file>...
vse_tc_validate() {
    local tool="$1"
    shift
    VSE_TC_REASON=""
    [ "$#" -gt 0 ] || return 0
    case "$tool" in
        syside)    _vse_tc_validate_syside "$@" ;;
        omg-pilot) _vse_tc_validate_pilot "$@" ;;
        opensysml) _vse_tc_validate_opensysml "$@" ;;
        *)
            VSE_TC_REASON="unknown toolchain '${tool}'"
            return 2
            ;;
    esac
}

# Internal: run the candidates in order over the given files. When
# VSE_TC_STAGED_ONLY is non-empty (a newline-separated list), syside
# receives only those files and the other tools' diagnostics are
# filtered to them. Exit 2 only when every candidate is unavailable.
_vse_tc_run_impl() {
    local -a cands
    local -a staged
    local tool rc pref reasons="" i n out f capture
    pref="$(vse_tc_preference)"
    cands=()
    while IFS= read -r tool; do
        cands+=("$tool")
    done < <(vse_tc_candidates)
    staged=()
    if [ -n "${VSE_TC_STAGED_ONLY:-}" ]; then
        while IFS= read -r f; do
            [ -n "$f" ] && staged+=("$f")
        done <<< "${VSE_TC_STAGED_ONLY}"
    fi
    n="${#cands[@]}"
    VSE_TC_USED=""
    # Diagnostics go through a file rather than a command substitution,
    # because a substitution runs in a subshell and would drop the
    # VSE_TC_REASON the validator sets for the notice below.
    capture="$(mktemp "${TMPDIR:-/tmp}/vse-tc-out.XXXXXX")"
    i=0
    while [ "$i" -lt "$n" ]; do
        tool="${cands[$i]}"
        rc=0
        out=""
        if [ "$tool" = "syside" ] && [ "${#staged[@]}" -gt 0 ]; then
            # Staged files only: syside resolves the project on its own.
            vse_tc_validate syside "${staged[@]}" > "$capture" || rc=$?
            out="$(cat "$capture")"
        else
            vse_tc_validate "$tool" "$@" > "$capture" || rc=$?
            out="$(cat "$capture")"
            if [ "${#staged[@]}" -gt 0 ] && [ "$rc" -eq 1 ]; then
                out="$(printf '%s\n' "$out" | awk -v keep="${VSE_TC_STAGED_ONLY}" '
                    BEGIN { n = split(keep, k, "\n"); for (i = 1; i <= n; i++) if (k[i] != "") want[k[i]] = 1 }
                    { p = $0; sub(/:[0-9]+:[0-9]+: .*$/, "", p); if (p in want) print }
                ')"
                [ -n "$out" ] || rc=0
            fi
        fi
        if [ "$rc" -ne 2 ]; then
            # VSE_TC_USED belongs to the sourced-library surface. It is
            # read by callers such as the pre-commit gate, not here.
            # shellcheck disable=SC2034
            VSE_TC_USED="$tool"
            rm -f "$capture"
            [ -z "$out" ] || printf '%s\n' "$out"
            return "$rc"
        fi
        reasons="${reasons}  ${tool}: ${VSE_TC_REASON}"$'\n'
        i=$((i + 1))
        if [ "$i" -lt "$n" ]; then
            echo "[${VSE_TC_TAG}] ${tool} unavailable (${VSE_TC_REASON}); validating with ${cands[$i]} instead" >&2
        fi
    done
    rm -f "$capture"
    echo "[${VSE_TC_TAG}] No SysML toolchain is available (preferred: ${pref}). Run /vse-toolchain to install or switch." >&2
    printf '%s' "$reasons" >&2
    return 2
}

# vse_tc_run <file>...: the preference, then the fallbacks, one notice
# per fallback naming why.
vse_tc_run() {
    [ "$#" -gt 0 ] || return 0
    VSE_TC_STAGED_ONLY=""
    _vse_tc_run_impl "$@"
}

# vse_tc_run_staged <staged-file>...: like vse_tc_run, but the pilot
# and OpenSysML see every tracked .sysml file (so cross-file names
# resolve) while only diagnostics on the staged files are reported,
# which keeps the gate scoped to touched content. Tracked files under a
# sandbox/ directory, *.draft.sysml, and build/ stay out of the context
# unless staged.
vse_tc_run_staged() {
    local -a context
    local staged_list="" f rc=0
    [ "$#" -gt 0 ] || return 0
    for f in "$@"; do
        staged_list="${staged_list}${f}"$'\n'
    done
    context=("$@")
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        case "$f" in
            */sandbox/*|sandbox/*|*.draft.sysml|build/*) continue ;;
        esac
        case "$staged_list" in
            *"${f}"$'\n'*) continue ;;
        esac
        context+=("$f")
    done < <(git ls-files -- '*.sysml' 2>/dev/null || true)
    VSE_TC_STAGED_ONLY="$staged_list"
    _vse_tc_run_impl "${context[@]}" || rc=$?
    VSE_TC_STAGED_ONLY=""
    return "$rc"
}

# One banner line for SessionStart. Always returns 0.
vse_tc_status_line() {
    local pref tool rc=0 pref_reason fallback=""
    pref="$(vse_tc_preference)"
    vse_tc_detect "$pref" 2>/dev/null || rc=$?
    if [ "$rc" -eq 0 ]; then
        printf 'Toolchain:   %s (preferred, available)\n' "$pref"
        return 0
    fi
    pref_reason="$VSE_TC_REASON"
    while IFS= read -r tool; do
        [ "$tool" = "$pref" ] && continue
        rc=0
        vse_tc_detect "$tool" 2>/dev/null || rc=$?
        if [ "$rc" -eq 0 ]; then
            fallback="$tool"
            break
        fi
    done < <(vse_tc_candidates)
    if [ -n "$fallback" ]; then
        printf 'Toolchain:   %s (preferred) unavailable: %s. Hooks fall back to %s. Run /vse-toolchain to install or switch.\n' "$pref" "$pref_reason" "$fallback"
    else
        printf 'Toolchain:   %s (preferred) unavailable: %s. No fallback installed. Run /vse-toolchain.\n' "$pref" "$pref_reason"
    fi
    return 0
}

_vse_tc_main() {
    local cmd="${1:-help}" tool=""
    shift || true
    case "$cmd" in
        preference) vse_tc_preference ;;
        candidates) vse_tc_candidates ;;
        java)
            if vse_tc_java; then
                printf '%s\n' "$VSE_TC_JAVA"
            else
                echo "[${VSE_TC_TAG}] ${VSE_TC_REASON}" >&2
                return 2
            fi
            ;;
        status) vse_tc_status_line ;;
        detect)
            [ -n "${1:-}" ] || { echo "usage: sysml-toolchain.sh detect <syside|omg-pilot|opensysml>" >&2; return 64; }
            if vse_tc_detect "$1"; then
                printf '%s: available\n' "$1"
            else
                return 2
            fi
            ;;
        validate)
            if [ "${1:-}" = "--tool" ]; then
                tool="${2:-}"
                shift 2 || true
            fi
            [ "$#" -gt 0 ] || { echo "usage: sysml-toolchain.sh validate [--tool <tool>] <file>..." >&2; return 64; }
            if [ -n "$tool" ]; then
                vse_tc_validate "$tool" "$@"
            else
                vse_tc_run "$@"
            fi
            ;;
        help|-h|--help)
            sed -n '2,33p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            ;;
        *)
            echo "[${VSE_TC_TAG}] unknown subcommand '${cmd}'" >&2
            return 64
            ;;
    esac
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    _vse_tc_main "$@"
fi
