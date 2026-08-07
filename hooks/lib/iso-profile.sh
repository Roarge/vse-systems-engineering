#!/usr/bin/env bash
# Shared rigour-profile helpers for the project-side git hooks.
#
# Sourced by pre-commit, commit-msg, pre-commit-traceability, and the
# SessionStart lifecycle hook. Answers two questions:
#
#   1. Which rigour profile does this project run at (methodology
#      §0.10.2)?
#   2. What disposition does a named gate carry (methodology §0.10.4)?
#
# The configuration schema stays flat and at most two levels deep, so
# awk is enough and no YAML library dependency is taken. The parsing
# idiom is the one the shipped hooks already use for baselined_paths.
#
# Sourcing the file resolves the configuration path and the profile
# once, into ISO_CONFIG_FILE and ISO_PROFILE. Resolving eagerly keeps a
# malformed value to a single diagnostic line per hook run, because the
# per-gate lookups below run inside command substitutions and cannot
# write back to the caller.
#
# Install as <project>/.githooks/lib/iso-profile.sh. The file is a
# library rather than a git entry point, so git never invokes it.
set -euo pipefail

# Locate the project .iso-config.yaml. Greenfield layout keeps it at the
# repository root, brownfield layout under engineering/. Prints nothing
# when the project carries no configuration file.
_iso_locate_config() {
    local root
    root="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
    if [ -f "${root}/.iso-config.yaml" ]; then
        printf '%s\n' "${root}/.iso-config.yaml"
    elif [ -f "${root}/engineering/.iso-config.yaml" ]; then
        printf '%s\n' "${root}/engineering/.iso-config.yaml"
    fi
}

# Read one top-level scalar key out of the configuration file.
_iso_scalar() {
    local key="$1" value
    [ -n "${ISO_CONFIG_FILE}" ] || return 0
    value=$(awk -v key="$key" '
        $0 ~ ("^" key ":") {
            sub(/^[A-Za-z_]+:[[:space:]]*/, "")
            sub(/[[:space:]]*#.*$/, "")
            sub(/[[:space:]]+$/, "")
            print
            exit
        }
    ' "$ISO_CONFIG_FILE")
    _iso_unquote "$value"
}

# Strip a single layer of surrounding quotes.
_iso_unquote() {
    local value="$1"
    value="${value%\"}"
    value="${value#\"}"
    value="${value%\'}"
    value="${value#\'}"
    printf '%s\n' "$value"
}

# Print the path of the project .iso-config.yaml, or nothing when the
# project carries none.
iso_config_path() {
    printf '%s\n' "${ISO_CONFIG_FILE}"
}

# Print the project rigour profile: light, standard, or full.
iso_profile() {
    printf '%s\n' "${ISO_PROFILE}"
}

# Print the disposition of a named gate: block, warn, info, or off.
#
# A gate_overrides entry wins over the profile default, per methodology
# §0.10.4. An unset or unrecognised override falls through to the
# profile column of the §0.10.4 table.
#
# Usage: iso_gate_disposition commit_msg_pattern
iso_gate_disposition() {
    local gate="$1"
    local override=""

    if [ -n "${ISO_CONFIG_FILE}" ]; then
        override=$(awk -v key="$gate" '
            /^gate_overrides:/ { inside = 1; next }
            inside && /^[A-Za-z]/ { inside = 0 }
            inside && $0 ~ ("^[[:space:]]+" key ":") {
                sub(/^[[:space:]]+[A-Za-z_]+:[[:space:]]*/, "")
                sub(/[[:space:]]*#.*$/, "")
                sub(/[[:space:]]+$/, "")
                print
                exit
            }
        ' "$ISO_CONFIG_FILE")
        override="$(_iso_unquote "$override")"
    fi

    case "$override" in
        block|warn|info|off)
            printf '%s\n' "$override"
            return 0
            ;;
        "")
            : # No override recorded, fall through to the profile default.
            ;;
        *)
            echo "[iso-profile] Unrecognised gate_overrides.${gate} value '${override}', using the profile default (methodology §0.10.4)." >&2
            ;;
    esac

    # Profile defaults, methodology §0.10.4.
    case "$gate" in
        commit_msg_pattern|commit_msg_cr_reference|precommit_story_wellformed)
            case "${ISO_PROFILE}" in
                light)    printf 'off\n' ;;
                standard) printf 'warn\n' ;;
                full)     printf 'block\n' ;;
            esac
            ;;
        precommit_lint)
            case "${ISO_PROFILE}" in
                light)    printf 'warn\n' ;;
                standard) printf 'warn\n' ;;
                full)     printf 'block\n' ;;
            esac
            ;;
        precommit_traceability)
            case "${ISO_PROFILE}" in
                light)    printf 'info\n' ;;
                standard) printf 'warn\n' ;;
                full)     printf 'block\n' ;;
            esac
            ;;
        *)
            echo "[iso-profile] Unknown gate '${gate}', reporting without blocking." >&2
            printf 'warn\n'
            ;;
    esac

    return 0
}

# Eager resolution. An absent key, an absent configuration file, and an
# unreadable value all mean standard, per methodology §0.10.2. A
# malformed value is reported once so the engineer can correct it.
ISO_CONFIG_FILE="$(_iso_locate_config)"
ISO_PROFILE="$(_iso_scalar project_profile)"

case "${ISO_PROFILE}" in
    light|standard|full)
        : # Recorded and recognised.
        ;;
    "")
        ISO_PROFILE="standard"
        ;;
    *)
        echo "[iso-profile] Unrecognised project_profile '${ISO_PROFILE}', using standard (methodology §0.10.2)." >&2
        ISO_PROFILE="standard"
        ;;
esac
