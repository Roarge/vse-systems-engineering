# vse-systems-engineering plugin validation
#
# Run 'make' or 'make all' before opening a PR.
#
# Kept in parity with .github/workflows/plugin-ci.yml. A check added
# here must be added there, and the reverse.
#
# 'make test-portable' runs the platform-dependent checks. The macOS CI
# job (portable) runs it under the stock /bin/bash 3.2 and the BSD
# tools (the grep, sed, awk and date that macOS ships).

# Claude Code CLI version pinned by the CI workflow. Kept here so a
# contributor can see which CLI the CI result came from.
CLAUDE_CODE_VERSION ?= 2.1.224

.PHONY: all validate lint check-versions check-validate check-hooks \
        check-refs check-skills check-config check-templates check-routing \
        check-mirrors check-test-first check-toolchain test-python test-bdd \
        test-hooks check-demo-generated check-demo-lint validate-demo \
        test-portable test-hooks-each

all: validate check-versions check-validate lint check-hooks check-skills check-refs check-routing check-config check-templates check-mirrors check-test-first check-toolchain test-python test-bdd test-hooks check-demo-generated check-demo-lint validate-demo
	@echo "All checks passed."

validate:
	@echo "Checking JSON syntax..."
	@jq empty .claude-plugin/plugin.json
	@jq empty .claude-plugin/marketplace.json

lint:
	@echo "Linting hook and test scripts..."
	@shellcheck hooks/*.sh hooks/lib/*.sh tests/hooks/*.sh

check-versions:
	@echo "Checking version consistency..."
	@PLUGIN_VERSION=$$(jq -r '.version' .claude-plugin/plugin.json); \
	 MARKET_VERSION=$$(jq -r '.metadata.version' .claude-plugin/marketplace.json); \
	 if [ "$$PLUGIN_VERSION" != "$$MARKET_VERSION" ]; then \
	   echo "ERROR: plugin.json ($$PLUGIN_VERSION) != marketplace.json ($$MARKET_VERSION)"; \
	   exit 1; \
	 else \
	   echo "  Versions match: $$PLUGIN_VERSION"; \
	 fi

# Validates the tracked tree only, which is what an installer receives.
# Gitignored contributor files such as CLAUDE.local.md sit in the
# working directory but never ship, and validating them in place would
# report findings that CI (a fresh checkout) can never see. The tracked
# files are staged into a temporary directory with their working-tree
# contents, so uncommitted edits are still covered.
check-validate:
	@echo "Validating plugin manifests with the Claude Code CLI..."
	@if ! command -v claude >/dev/null 2>&1; then \
	   echo "  SKIPPED: claude CLI not on PATH (CI pins $(CLAUDE_CODE_VERSION))"; \
	 else \
	   TMPDIR_VALIDATE=$$(mktemp -d); \
	   trap 'rm -rf "$$TMPDIR_VALIDATE"' EXIT; \
	   git ls-files -z | tar --null -T - -cf - | tar -xf - -C "$$TMPDIR_VALIDATE"; \
	   claude plugin validate --strict "$$TMPDIR_VALIDATE/.claude-plugin/plugin.json" || exit 1; \
	   claude plugin validate --strict "$$TMPDIR_VALIDATE/.claude-plugin/marketplace.json" || exit 1; \
	 fi

# Every script in hooks/, hooks/lib/ and tests/hooks/ must be
# executable and carry the shebang and failure mode the hook
# conventions require. A non-executable or unguarded hook fails
# silently at runtime, and a test script that does not stop on the
# first error reports a pass it did not earn.
check-hooks:
	@echo "Checking hook and test script conventions..."
	@EXIT_CODE=0; \
	 for hook_file in hooks/*.sh hooks/lib/*.sh tests/hooks/*.sh; do \
	   if [ ! -x "$$hook_file" ]; then \
	     echo "ERROR: $$hook_file is not executable"; \
	     EXIT_CODE=1; \
	   fi; \
	   if [ "$$(head -1 "$$hook_file")" != '#!/usr/bin/env bash' ]; then \
	     echo "ERROR: $$hook_file does not start with #!/usr/bin/env bash"; \
	     EXIT_CODE=1; \
	   fi; \
	   if ! grep -qF 'set -euo pipefail' "$$hook_file"; then \
	     echo "ERROR: $$hook_file does not set -euo pipefail"; \
	     EXIT_CODE=1; \
	   fi; \
	 done; \
	 exit $$EXIT_CODE

check-skills:
	@echo "Checking skill structure..."
	@EXIT_CODE=0; \
	 for skill_dir in skills/*/; do \
	   skill_file="$${skill_dir}SKILL.md"; \
	   if [ ! -f "$$skill_file" ]; then \
	     echo "ERROR: Missing SKILL.md in $$skill_dir"; \
	     EXIT_CODE=1; \
	     continue; \
	   fi; \
	   if ! head -20 "$$skill_file" | grep -q '^name:'; then \
	     echo "ERROR: $$skill_file missing 'name:' in frontmatter"; \
	     EXIT_CODE=1; \
	   fi; \
	   if ! head -20 "$$skill_file" | grep -q '^description:'; then \
	     echo "ERROR: $$skill_file missing 'description:' in frontmatter"; \
	     EXIT_CODE=1; \
	   fi; \
	 done; \
	 exit $$EXIT_CODE

# Every ${CLAUDE_PLUGIN_ROOT}/<path> reference in a harness-loaded
# component must resolve inside the plugin tree, because the whole
# committed tree is what reaches an installer. A reference written as a
# file path is an error when it does not resolve. A reference written
# as a directory path (trailing slash) stays at warning level, which
# preserves the tolerance the previous templates/ check provided for
# conditional directory copies. The references are read with an
# extended regular expression (ERE) whose bracket expressions match the
# literal $, { and } on GNU and BSD grep alike, because macOS grep has
# no -P and \{ is not portable in an ERE. Every shipped skill names at
# least one plugin-root path, so a scan that counts none has read
# nothing and fails rather than passing in silence.
check-refs:
	@echo "Checking cross-references..."
	@EXIT_CODE=0; \
	 CHECKED=0; \
	 for src_file in skills/*/SKILL.md commands/*.md agents/*.md hooks.json; do \
	   [ -f "$$src_file" ] || continue; \
	   for ref_path in $$(grep -oE '[$$][{]CLAUDE_PLUGIN_ROOT[}]/[a-zA-Z0-9_./-]+' "$$src_file" 2>/dev/null | sort -u || true); do \
	     rel_path=$$(echo "$$ref_path" | sed 's|\$${CLAUDE_PLUGIN_ROOT}/||'); \
	     CHECKED=$$((CHECKED + 1)); \
	     [ -e "$$rel_path" ] && continue; \
	     case "$$rel_path" in \
	       */) echo "WARNING: $$src_file references directory $$rel_path which does not exist";; \
	       *)  echo "ERROR: $$src_file references $$rel_path which does not exist"; EXIT_CODE=1;; \
	     esac; \
	   done; \
	 done; \
	 echo "  Checked $$CHECKED plugin-root references."; \
	 if [ "$$CHECKED" -eq 0 ]; then \
	   echo "ERROR: found no plugin-root reference to check, so the check proved nothing"; \
	   EXIT_CODE=1; \
	 fi; \
	 exit $$EXIT_CODE

# Runtime knowledge reaches a skill through a generated wiki-routing
# block, never through a concatenated bundle. Four rules keep that
# true. The wiki/bundles directory was deleted at 3.0.0, so any
# surviving reference is stale, except inside vse-wiki-lint, which has
# to name the retired surface in order to detect it. Markers inside
# fenced code blocks are documentation examples and are skipped, per
# the fenced-marker exclusion in wiki/CLAUDE.md.
check-routing:
	@echo "Checking wiki routing integrity..."
	@EXIT_CODE=0; \
	 for src_file in skills/*/SKILL.md commands/*.md agents/*.md wiki/CLAUDE.md; do \
	   [ -f "$$src_file" ] || continue; \
	   [ "$$src_file" = "skills/vse-wiki-lint/SKILL.md" ] && continue; \
	   if grep -qF 'wiki/bundles' "$$src_file"; then \
	     echo "ERROR: $$src_file references the retired wiki/bundles surface"; \
	     EXIT_CODE=1; \
	   fi; \
	 done; \
	 for skill_file in skills/*/SKILL.md; do \
	   if grep -qE '^[[:space:]]*(`!cat|!`cat|!cat)[[:space:]]' "$$skill_file"; then \
	     echo "ERROR: $$skill_file carries a bundle embed line"; \
	     EXIT_CODE=1; \
	   fi; \
	 done; \
	 CHECKED=0; \
	 for skill_file in skills/*/SKILL.md; do \
	   for page_path in $$(awk '\
	     /^[[:space:]]*```/ { fenced = !fenced; next } \
	     fenced { next } \
	     /^[[:space:]]*<!-- wiki-routing:begin -->[[:space:]]*$$/ { inblock = 1; next } \
	     /^[[:space:]]*<!-- wiki-routing:end -->[[:space:]]*$$/ { inblock = 0; next } \
	     inblock && /^\|/ { \
	       n = split($$0, cells, "|"); \
	       if (n < 4) next; \
	       p = cells[3]; \
	       gsub(/^[ \t]+|[ \t]+$$/, "", p); \
	       if (p == "Path" || p ~ /^-+$$/) next; \
	       print p; \
	     }' "$$skill_file"); do \
	     CHECKED=$$((CHECKED + 1)); \
	     if [ ! -f "wiki/$$page_path" ]; then \
	       echo "ERROR: $$skill_file routes to wiki/$$page_path which does not exist"; \
	       EXIT_CODE=1; \
	     fi; \
	   done; \
	 done; \
	 for page_file in wiki/pages/*/*.md; do \
	   [ -f "$$page_file" ] || continue; \
	   grep -q '^summary:' "$$page_file" || { \
	     echo "ERROR: $$page_file has no summary: in its frontmatter"; EXIT_CODE=1; }; \
	   grep -q '^referenced_by:' "$$page_file" || { \
	     echo "ERROR: $$page_file has no referenced_by: in its frontmatter"; EXIT_CODE=1; }; \
	 done; \
	 echo "  Checked $$CHECKED routing rows."; \
	 exit $$EXIT_CODE

# The placeholder check is an error from the pre-overhaul hygiene
# release onwards, because the placeholder now exists. The demo pin
# stays a warning until demo sync promotes it. The test_first block and
# the four test-first and Gherkin gates ship commented out, so a new
# project starts at the profile defaults and records its own judgement.
# A commented block is a "# <name>:" header line followed by commented
# keys indented under the header (two blanks or more after the #), and
# it ends at the first other line.
check-config:
	@echo "Checking ISO configuration files..."
	@if grep -qF '{{PLUGIN_VERSION}}' templates/iso-config/.iso-config.yaml; then \
	   echo "  templates/iso-config/.iso-config.yaml carries the {{PLUGIN_VERSION}} placeholder."; \
	 else \
	   echo "ERROR: templates/iso-config/.iso-config.yaml does not carry the {{PLUGIN_VERSION}} placeholder"; \
	   exit 1; \
	 fi
	@PLUGIN_VERSION=$$(jq -r '.version' .claude-plugin/plugin.json); \
	 DEMO_VERSION=$$(sed -n 's/^plugin_version:[[:space:]]*"\(.*\)"[[:space:]]*$$/\1/p' demo/smart-sensor/.iso-config.yaml); \
	 if [ -z "$$DEMO_VERSION" ]; then \
	   echo "ERROR: demo/smart-sensor/.iso-config.yaml has no readable plugin_version"; \
	   exit 1; \
	 elif [ "$$DEMO_VERSION" != "$$PLUGIN_VERSION" ]; then \
	   echo "ERROR: demo/smart-sensor/.iso-config.yaml plugin_version ($$DEMO_VERSION) does not match plugin.json ($$PLUGIN_VERSION)"; \
	   exit 1; \
	 else \
	   echo "  Demo plugin_version pin matches plugin.json ($$PLUGIN_VERSION)."; \
	 fi
	@if grep -qE '^sysml_toolchain:' templates/iso-config/.iso-config.yaml; then \
	   echo "ERROR: templates/iso-config/.iso-config.yaml records an active sysml_toolchain; the shipped line is commented out so the absent-key default applies"; \
	   exit 1; \
	 elif grep -qE '^#[[:space:]]*sysml_toolchain:[[:space:]]*syside' templates/iso-config/.iso-config.yaml; then \
	   echo "  templates/iso-config/.iso-config.yaml carries the commented sysml_toolchain default."; \
	 else \
	   echo "ERROR: templates/iso-config/.iso-config.yaml does not carry the commented sysml_toolchain default"; \
	   exit 1; \
	 fi
	@DEMO_TOOLCHAIN=$$(sed -n 's/^sysml_toolchain:[[:space:]]*//p' demo/smart-sensor/.iso-config.yaml); \
	 case "$$DEMO_TOOLCHAIN" in \
	   syside|omg-pilot|opensysml) \
	     echo "  Demo sysml_toolchain is $$DEMO_TOOLCHAIN."; \
	     ;; \
	   *) \
	     echo "ERROR: demo/smart-sensor/.iso-config.yaml records sysml_toolchain '$$DEMO_TOOLCHAIN', which is not one of syside, omg-pilot, opensysml"; \
	     exit 1; \
	     ;; \
	 esac
	@if grep -qE '^(test_first|gate_overrides):' templates/iso-config/.iso-config.yaml; then \
	   echo "ERROR: templates/iso-config/.iso-config.yaml records an active test_first or gate_overrides block. Both ship commented out, so a new project starts at the profile defaults and records its own test-first judgement with /vse-test-first"; \
	   exit 1; \
	 fi; \
	 MISSING=$$(awk '\
	   BEGIN { \
	     n = split("test_first.applies test_first.rationale test_first.test_command test_first.scenario_command test_first.code_paths test_first.test_paths test_first.refactor_branches gate_overrides.precommit_gherkin gate_overrides.precommit_test_first gate_overrides.pretooluse_gherkin_first gate_overrides.pretooluse_test_first", want, " "); \
	   } \
	   /^# [a-z_][a-z_]*:[ \t]*$$/ { block = $$0; sub(/^# /, "", block); sub(/:.*/, "", block); next } \
	   block != "" && /^#[ \t][ \t][ \t]*[a-z_][a-z_]*:/ { key = $$0; sub(/^#[ \t]*/, "", key); sub(/:.*/, "", key); seen[block "." key] = 1; next } \
	   { block = "" } \
	   END { sep = ""; for (i = 1; i <= n; i++) if (!(want[i] in seen)) { printf "%s%s", sep, want[i]; sep = " " } }' \
	   templates/iso-config/.iso-config.yaml); \
	 if [ -n "$$MISSING" ]; then \
	   echo "ERROR: templates/iso-config/.iso-config.yaml lacks these keys in its commented test_first and gate_overrides blocks: $$MISSING"; \
	   exit 1; \
	 else \
	   echo "  templates/iso-config/.iso-config.yaml carries the commented test_first block and the four test-first and Gherkin gates in its commented gate_overrides."; \
	 fi

# The story and case templates, checked the way a project meets them.
# A template's name begins with _, which the story lint skips, so the
# check copies the model templates into a scratch project under the
# names of the identifiers they declare and runs the Gherkin rule set
# there, once as shipped and once with each story at inProgress. This
# target covers the story lint of the templates only. Their OpenSysML
# validation, with the placeholders filled the same way, is in
# validate-demo.
check-templates:
	@echo "Checking the story and case templates..."
	@bash tests/hooks/check-templates.sh

# The demo is a standalone project, so it carries byte-identical copies
# of the methodology, the SysML library, the renderers and the story
# lint. A change to one side lands in the same commit as the other. A
# file pair is compared with cmp. A directory pair is compared file by
# file over the names git lists on either side (tracked files, and
# untracked files that no .gitignore rule ignores). So an OS or editor
# artefact or a bytecode cache, which is ignored and never ships, is
# skipped, and a new file that is not yet added still counts. A tracked
# file missing from both sides is not a difference.
check-mirrors:
	@echo "Checking the demo mirrors..."
	@git rev-parse --git-dir >/dev/null 2>&1 || { \
	   echo "ERROR: check-mirrors lists files through git, so run it inside a git checkout"; \
	   exit 1; \
	 }
	@EXIT_CODE=0; \
	 CHECKED=0; \
	 for pair in \
	   methodology:demo/smart-sensor/methodology \
	   templates/common/library/vse-library.sysml:demo/smart-sensor/model/library/vse-library.sysml \
	   templates/tools/render:demo/smart-sensor/tools/render \
	   templates/tools/lint:demo/smart-sensor/tools/lint; do \
	   src=$${pair%%:*}; \
	   copy=$${pair#*:}; \
	   CHECKED=$$((CHECKED + 1)); \
	   if [ -d "$$src" ]; then \
	     REPORT=$$( { git -C "$$src" ls-files -z -co --exclude-standard; \
	                  git -C "$$copy" ls-files -z -co --exclude-standard 2>/dev/null; } \
	       | tr '\0' '\n' | LC_ALL=C sort -u | while IFS= read -r f; do \
	         if [ ! -e "$$src/$$f" ] && [ ! -e "$$copy/$$f" ]; then \
	           continue; \
	         elif [ ! -e "$$copy/$$f" ]; then \
	           echo "Only in $$src: $$f"; \
	         elif [ ! -e "$$src/$$f" ]; then \
	           echo "Only in $$copy: $$f"; \
	         elif ! cmp -s "$$src/$$f" "$$copy/$$f"; then \
	           echo "Files $$src/$$f and $$copy/$$f differ"; \
	         fi; \
	       done ); \
	     [ -z "$$REPORT" ] || { printf '%s\n' "$$REPORT"; false; }; \
	   else \
	     cmp "$$src" "$$copy"; \
	   fi || { \
	     echo "ERROR: $$src and $$copy are not byte-identical"; \
	     EXIT_CODE=1; \
	   }; \
	 done; \
	 echo "  Checked $$CHECKED mirror pairs."; \
	 exit $$EXIT_CODE

# Test before code for the plugin itself (.claude/rules/tdd-bdd.md). A
# range that changes a code path named in tests/test-first.yaml shall
# also change a test path. The range defaults to origin/main...HEAD,
# the branch's changes since it left main, and VSE_PRECOMMIT_RANGE
# names another. CI passes the pull request's range.
check-test-first:
	@echo "Checking that code changes arrive with tests..."
	@bash tests/hooks/check-test-first.sh

# The behavioural hook tests under tests/hooks/. Every toolchain is
# stubbed, so the assertions hold with no SysML tool installed, which
# is what CI runs. The real-tool section of check-toolchain.sh prints
# SKIPPED for each toolchain the machine does not carry. Set
# VSE_TC_TEST_PATH to put a local toolchain checkout on the PATH.
check-toolchain:
	@echo "Checking the SysML toolchain library..."
	@bash tests/hooks/check-toolchain.sh

# The Python unit tests under tests/python/. They use the standard
# library unittest module, because pytest is not importable by python3
# locally or in CI.
test-python:
	@echo "Running the Python unit tests..."
	@python3 -m unittest discover -s tests/python -t . -v

# The plugin's own Gherkin scenarios under tests/features/, run by the
# standard-library runner in tests/bdd/. A scenario still tagged @wip
# fails the run (--fail-on-wip), so no work in progress reaches a
# commit or a release. A directory that holds no .feature file passes
# with a zero summary. The story lint then checks the same files in
# syntax mode (F1, F2, F7, F8 and F9), because they describe the plugin
# rather than a story and carry no story tag.
test-bdd:
	@echo "Running the plugin's Gherkin scenarios..."
	@python3 tests/bdd/run.py --fail-on-wip tests/features
	@python3 templates/tools/lint/story-wellformed.py --only syntax tests/features

# Every tests/hooks/test-*.sh file runs, found by glob, so a new hook
# test joins the suite by its file name alone. The first failing file
# stops the run. check-toolchain.sh runs under its own target.
test-hooks:
	@echo "Testing the hook scripts..."
	@for t in tests/hooks/test-*.sh; do bash "$$t" || exit 1; done

# Methodology section 9.8 Contract 3: the demo's model-derived
# artefacts are regenerated and shall match what is committed. The
# renderers run from demo/smart-sensor, because each one resolves the
# model relative to the directory that holds the demo configuration.
# The comparison runs from the repository root, where the committed
# outputs live. The two halves run from different directories because
# inside this checkout the demo is a nested project, so a locator that
# resolves from the git top level lands on the plugin repository
# rather than on the demo.
check-demo-generated:
	@echo "Checking the demo's generated artefacts..."
	@cd demo/smart-sensor && \
	 python3 tools/render/traceability-matrix.py && \
	 python3 tools/render/stakeholder-reqs-doc.py && \
	 python3 tools/render/system-reqs-doc.py
	@if git diff --exit-code -- demo/smart-sensor/docs/generated/; then \
	   echo "  Demo generated artefacts match the model."; \
	 else \
	   echo "ERROR: demo/smart-sensor/docs/generated/ is stale. Re-run the renderers and commit the result."; \
	   exit 1; \
	 fi

# The demo's stories against their feature files. The story lint of
# methodology section 11.9.1 runs with both rule sets (the section 1.9
# well-formedness checks and the Gherkin findings S1 to S9 and F1 to
# F10) from the demo's engineering root, the way a project runs it.
# Every demo story has its feature file and named criteria, so the lint
# finds nothing.
check-demo-lint:
	@echo "Linting the demo's stories and feature files..."
	@cd demo/smart-sensor && python3 tools/lint/story-wellformed.py model
	@echo "  The demo's stories pass the story lint."

# The demo model, and the model templates with their placeholders
# filled, validated with OpenSysML, the demo's second reference
# toolchain. A verify path that names a criterion, such as
# US_001_SeeReadingsOnDashboard.acceptance.latestReadingShown, resolves
# only when the story nests that criterion (methodology section 11.3).
# CI installs OpenSysML v0.6.0 with its pinned checksum and then runs
# the script, which fails when sysml is missing. Here the target skips
# with a notice when sysml is not on PATH.
validate-demo:
	@echo "Validating the demo model and the model templates with OpenSysML..."
	@if ! command -v sysml >/dev/null 2>&1; then \
	   echo "  SKIPPED: sysml (OpenSysML) not on PATH. CI installs OpenSysML v0.6.0 and runs this check."; \
	 else \
	   bash tests/hooks/validate-demo.sh; \
	 fi

# The platform-dependent checks, which the portable job of the CI
# workflow runs on macOS with 'make -k test-portable'. Each check also
# runs under all (the hook test files through test-hooks), so all is
# unchanged. The checks that need Linux (apt, shellcheck, the Claude
# Code CLI, OpenSysML and the test-first range) stay in the validate
# job. Under make -k (keep going), a failing prerequisite stops the
# recipe of the target that lists it, although make still builds the
# other prerequisites. So the hook test files run under a prerequisite
# of their own, test-hooks-each, listed last, and a failing check
# cannot stop them from running.
test-portable: check-refs check-templates check-toolchain test-python test-bdd check-demo-generated check-demo-lint test-hooks-each
	@echo "The platform-dependent checks passed."

# Every tests/hooks/test-*.sh file runs, and each failing file is named,
# so one macOS run lists every platform difference. The target fails at
# the end when any file failed. test-hooks stops at the first failing
# file instead.
test-hooks-each:
	@echo "Testing every hook script file..."
	@rc=0; for t in tests/hooks/test-*.sh; do bash "$$t" || { echo "FAILED: $$t"; rc=1; }; done; exit $$rc
