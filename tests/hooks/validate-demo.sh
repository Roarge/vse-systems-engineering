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
# Both runs take place unless OpenSysML is unavailable, so one call
# reports every finding. Exit 0 when both trees validate, 1 when either
# draws a finding, and 2 when OpenSysML is unavailable. Any other status
# from the library is named on an ERROR line and becomes the script's
# status, ahead of a finding, so a run that broke is never read as one
# that found something. The script never skips: the validate-demo
# target of the Makefile skips with a notice when sysml is not on PATH,
# and CI installs OpenSysML v0.6.0 before running this.
#
# Run: bash tests/hooks/validate-demo.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TOOLCHAIN="${ROOT}/hooks/lib/sysml-toolchain.sh"
# shellcheck source=/dev/null
. "${ROOT}/tests/hooks/fill-placeholders.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/vse-validate-demo.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

# validate_tree <dir> <tree> <passed> <note> <failed>: every .sysml
# file under <dir>/model in one OpenSysML run from <dir>. A clean run
# prints "<passed> under OpenSysML (<n> files<note>).", a run with
# findings prints "ERROR: <failed>" after them, and a status other than
# clean, findings or unavailable prints "ERROR: <tree> could not be
# validated (validator exited <rc>)". Returns the library's status.
validate_tree() {
    local dir="$1" tree="$2" passed="$3" note="$4" failed="$5" file rc=0
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
        2) ;;
        *) echo "ERROR: ${tree} could not be validated (validator exited ${rc})" ;;
    esac
    return "$rc"
}

# keep_status <rc>: fold the status of one run into the script's. An
# unavailable validator stops the script with 2, and the first status
# other than clean or findings outranks a finding.
STATUS=0
keep_status() {
    case "$1" in
        0) ;;
        1) [ "$STATUS" -ne 0 ] || STATUS=1 ;;
        2) exit 2 ;;
        *) [ "$STATUS" -gt 1 ] || STATUS="$1" ;;
    esac
}

RC=0
validate_tree "${ROOT}/demo/smart-sensor" "the demo model (demo/smart-sensor/model)" \
    "The demo model validates" "" \
    "the demo model (demo/smart-sensor/model) draws OpenSysML findings, listed above" \
    || RC=$?
keep_status "$RC"

mkdir -p "${WORK}/templates"
cp -R "${ROOT}/templates/common/models" "${WORK}/templates/model"
mkdir -p "${WORK}/templates/model/library"
cp "${ROOT}/templates/common/library/vse-library.sysml" "${WORK}/templates/model/library/"
fill_placeholders "${WORK}/templates/model"
RC=0
validate_tree "${WORK}/templates" "the model templates (templates/common/models)" \
    "The model templates validate" ", placeholders filled" \
    "the model templates (templates/common/models, validated with the placeholders filled) draw OpenSysML findings, listed above" \
    || RC=$?
keep_status "$RC"
exit "$STATUS"
