#!/usr/bin/env bash
# The demo model and the shipped model templates, validated with
# OpenSysML through the toolchain library in its executable form.
#
# OpenSysML is the demo's second reference toolchain (the validation
# record in demo/smart-sensor/README.md). A verify path such as
# US_001_SeeReadingsOnDashboard.acceptance.latestReadingShown resolves
# only when the story nests a criterion of that name (methodology
# §11.3), so a story and the cases that verify it cannot drift apart
# unseen.
#
# Two runs, each over one tree as a whole, because the files of a tree
# import one another:
#
#   1. every .sysml file under demo/smart-sensor/model, from the demo's
#      root, the demo's copy of the SysML library included.
#   2. every .sysml file under templates/common/models, with the SysML
#      library of templates/common/library, in a scratch copy where the
#      project placeholders carry example values, because a placeholder
#      such as {{PROJECT_NAME}} is not SysML. A .tmpl file is completed
#      by project setup and is not read.
#
# Both runs always take place, so one call reports every finding.
# Exit 0 when both trees validate, 1 when either draws a finding, and 2
# when OpenSysML is unavailable. The script never skips: the
# validate-demo target of the Makefile skips with a notice when sysml is
# not on PATH, and CI installs OpenSysML v0.6.0 before running this.
#
# Run: bash tests/hooks/validate-demo.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TOOLCHAIN="${ROOT}/hooks/lib/sysml-toolchain.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/vse-validate-demo.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

# validate_tree <dir> <passed> <note> <failed>: every .sysml file under
# <dir>/model in one OpenSysML run from <dir>. A clean run prints
# "<passed> under OpenSysML (<n> files<note>).", a run with findings
# prints "ERROR: <failed>" after them. Returns the library's status.
validate_tree() {
    local dir="$1" passed="$2" note="$3" failed="$4" file rc=0
    local files=()
    while IFS= read -r file; do
        files+=("$file")
    done < <(cd "$dir" && find model -name '*.sysml' -type f | LC_ALL=C sort)
    if [ "${#files[@]}" -eq 0 ]; then
        echo "ERROR: ${dir}/model holds no .sysml file"
        return 1
    fi
    (cd "$dir" && bash "$TOOLCHAIN" validate --tool opensysml "${files[@]}") || rc=$?
    case "$rc" in
        0) echo "  ${passed} under OpenSysML (${#files[@]} files${note})." ;;
        1) echo "ERROR: ${failed}" ;;
    esac
    return "$rc"
}

EXIT_CODE=0
validate_tree "${ROOT}/demo/smart-sensor" "The demo model validates" "" \
    "the demo model (demo/smart-sensor/model) draws OpenSysML findings, listed above" \
    || EXIT_CODE=$?
[ "$EXIT_CODE" -ne 2 ] || exit 2

mkdir -p "${WORK}/templates"
cp -R "${ROOT}/templates/common/models" "${WORK}/templates/model"
mkdir -p "${WORK}/templates/model/library"
cp "${ROOT}/templates/common/library/vse-library.sysml" "${WORK}/templates/model/library/"
find "${WORK}/templates/model" -name '*.sysml' -exec sed -i.orig \
    -e 's/{{PROJECT_NAME}}/Example/g' -e 's/{{PROJECT_SHORT_CODE}}/EX/g' {} +
find "${WORK}/templates/model" -name '*.orig' -exec rm -f {} +
TEMPLATE_RC=0
validate_tree "${WORK}/templates" "The model templates validate" ", placeholders filled" \
    "the model templates (templates/common/models, validated with the placeholders filled) draw OpenSysML findings, listed above" \
    || TEMPLATE_RC=$?
[ "$TEMPLATE_RC" -ne 2 ] || exit 2
[ "$TEMPLATE_RC" -eq 0 ] || EXIT_CODE=1
exit "$EXIT_CODE"
