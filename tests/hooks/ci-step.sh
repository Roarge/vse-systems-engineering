#!/usr/bin/env bash
# Reads one step of a GitHub Actions workflow template the way the
# runner does, for the tests that play the runner for a template's
# shell steps (test-ci-template.sh, test-document-export.sh).
#
# Sourced after lib.sh. The caller sets CI_TEMPLATE to the workflow
# file to read.
set -euo pipefail

# ci_step <name> <field>: print one field of the step named <name>.
# "run" prints its script with the block indentation removed (blank
# lines inside the block kept, trailing ones dropped), or the command
# of a one-line "run: <command>". "env" prints one NAME<TAB>value line
# per entry, and "if" and "id" print their value.
# Returns 1 when the template holds no step of that name.
ci_step() {
    LC_ALL=C awk -v want="$1" -v field="$2" '
        function lead(s,   i) { i = match(s, /[^ ]/); return i ? i - 1 : -1 }
        BEGIN { found = 0; instep = 0; mode = "" }
        {
            n = lead($0)
            if (n >= 0 && substr($0, n + 1, 8) == "- name: ") {
                if (instep && n <= dash) { instep = 0; mode = "" }
                if (!instep && substr($0, n + 9) == want) {
                    instep = 1; found = 1; dash = n; key = n + 2; mode = ""
                    next
                }
            }
            if (!instep) next
            if (n >= 0 && n <= dash) { instep = 0; mode = ""; next }
            if (mode == "run") {
                if (n < 0) { blank++; next }
                if (n > key) {
                    if (cut < 0) cut = n
                    for (; blank > 0; blank--) print ""
                    print substr($0, cut + 1)
                    next
                }
                mode = ""
            }
            if (mode == "env") {
                if (n < 0) next
                if (n > key) {
                    entry = substr($0, n + 1)
                    if (substr(entry, 1, 1) == "#") next
                    colon = index(entry, ": ")
                    printf "%s\t%s\n", substr(entry, 1, colon - 1), substr(entry, colon + 2)
                    next
                }
                mode = ""
            }
            if (n != key) next
            rest = substr($0, n + 1)
            if (field == "run" && rest == "run: |") { mode = "run"; cut = -1; blank = 0; next }
            if (field == "run" && substr(rest, 1, 5) == "run: ") print substr(rest, 6)
            if (field == "env" && rest == "env:") { mode = "env"; next }
            if (field == "if" && substr(rest, 1, 4) == "if: ") print substr(rest, 5)
            if (field == "id" && substr(rest, 1, 4) == "id: ") print substr(rest, 5)
        }
        END { exit found ? 0 : 1 }' "$CI_TEMPLATE"
}
