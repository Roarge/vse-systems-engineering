#!/usr/bin/env bash
# The example values that the template checks give the project
# placeholders @project-setup fills, so that a model template parses as
# SysML. Sourced by check-templates.sh (the story lint of the templates)
# and validate-demo.sh (their OpenSysML validation), so both read the
# templates with the same values.
set -euo pipefail

# fill_placeholders <dir>: in every .sysml file under <dir>, replace
# {{PROJECT_NAME}} with Example and {{PROJECT_SHORT_CODE}} with EX.
fill_placeholders() {
    find "$1" -name '*.sysml' -exec sed -i.orig \
        -e 's/{{PROJECT_NAME}}/Example/g' -e 's/{{PROJECT_SHORT_CODE}}/EX/g' {} +
    find "$1" -name '*.orig' -exec rm -f {} +
}
