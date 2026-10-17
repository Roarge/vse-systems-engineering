#!/usr/bin/env bash
# The story and case templates under templates/common/models/, checked
# the way a project meets them.
#
# A template's file name begins with _, and the story lint skips such a
# file, so linting the templates in place checks nothing. This check
# copies the model templates, the SysML library and the shipped lint
# and renderers into a scratch project. It gives each story and case
# template the name of the identifier it declares (US_001_Example,
# SYS_001_Example, VC_001_Example and VAL_001_Example), names every
# other template example.sysml, and fills the project placeholders.
# Then it runs the Gherkin rule set of the story lint (methodology
# §11.9.1) over the stories, twice, and expects no finding either time:
#
#   1. as shipped, with each story in backlog;
#   2. with each story at inProgress, where finding S8 requires a case
#      to reach every acceptance criterion, so the case templates are
#      checked as well.
#
# SysML validation of the templates is not part of this check.
#
# Run: bash tests/hooks/check-templates.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MODELS="${ROOT}/templates/common/models"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/vse-check-templates.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
PROJECT="${WORK}/project"
STORIES="model/core/stories"
CASES="model/core/verification-validation"

mkdir -p "${PROJECT}/tools"
cp -R "${ROOT}/templates/tools/lint" "${ROOT}/templates/tools/render" "${PROJECT}/tools/"
rm -rf "${PROJECT}/tools/lint/__pycache__" "${PROJECT}/tools/render/__pycache__"
cp -R "${MODELS}" "${PROJECT}/model"
cp "${ROOT}/templates/common/library/vse-library.sysml" "${PROJECT}/model/library/"
find "${PROJECT}/model" \( -name .gitkeep -o -name '*.tmpl' -o -name README.md \) -exec rm -f {} +

# check_named <dir> <identifier> <extension>...: rename each
# _template.<extension> in <dir> to <identifier>.<extension>. A
# template that is missing fails the check, so the check never passes
# on files it did not read.
check_named() {
    local dir="$1" id="$2" ext
    shift 2
    for ext in "$@"; do
        if [ ! -f "${PROJECT}/${dir}/_template.${ext}" ]; then
            echo "ERROR: templates/common/models/${dir#model/}/_template.${ext} is missing"
            exit 1
        fi
        mv "${PROJECT}/${dir}/_template.${ext}" "${PROJECT}/${dir}/${id}.${ext}"
    done
}
check_named "${STORIES}/stakeholder" US_001_Example sysml feature
check_named "${STORIES}/system" SYS_001_Example sysml feature
check_named "${CASES}/verification-cases" VC_001_Example sysml
check_named "${CASES}/validation-cases" VAL_001_Example sysml

# Every other template gets a plain name, and the placeholders the
# project setup fills get example values.
find "${PROJECT}/model" -name '_template.*' | while IFS= read -r file; do
    mv "$file" "${file%/*}/example.${file##*.}"
done
find "${PROJECT}/model" -name '*.sysml' -exec sed -i.orig \
    -e 's/{{PROJECT_NAME}}/Example/g' -e 's/{{PROJECT_SHORT_CODE}}/EX/g' {} +
find "${PROJECT}/model" -name '*.orig' -exec rm -f {} +

# check_lint <label>: the Gherkin rule set over the stories, with no
# finding.
check_lint() {
    if ! (cd "$PROJECT" && python3 tools/lint/story-wellformed.py --only gherkin "$STORIES"); then
        echo "ERROR: the story and case templates draw story lint findings ($1, see the lines above)"
        exit 1
    fi
    echo "  The story and case templates pass the story lint ($1)."
}

check_lint "as shipped"

for story in stakeholder/US_001_Example system/SYS_001_Example; do
    file="${PROJECT}/${STORIES}/${story}.sysml"
    sed -i.orig 's/StoryStatus::backlog/StoryStatus::inProgress/' "$file"
    rm -f "${file}.orig"
    if ! grep -qF 'StoryStatus::inProgress' "$file"; then
        echo "ERROR: templates/common/models/core/stories/${story%/*}/_template.sysml does not start in backlog, so it cannot be moved to inProgress"
        exit 1
    fi
done

check_lint "each story at inProgress, so every criterion needs a case"
