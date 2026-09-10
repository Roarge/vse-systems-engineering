# vse-systems-engineering plugin validation
#
# Run 'make' or 'make all' before opening a PR.
#
# Kept in parity with .github/workflows/plugin-ci.yml. A check added
# here must be added there, and the reverse.

# Claude Code CLI version pinned by the CI workflow. Kept here so a
# contributor can see which CLI the CI result came from.
CLAUDE_CODE_VERSION ?= 2.1.224

.PHONY: all validate lint check-versions check-validate check-hooks \
        check-refs check-skills check-config check-routing \
        check-toolchain test-hooks check-demo-generated

all: validate check-versions check-validate lint check-hooks check-skills check-refs check-routing check-config check-toolchain test-hooks check-demo-generated
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
# conditional directory copies.
check-refs:
	@echo "Checking cross-references..."
	@EXIT_CODE=0; \
	 CHECKED=0; \
	 for src_file in skills/*/SKILL.md commands/*.md agents/*.md hooks.json; do \
	   [ -f "$$src_file" ] || continue; \
	   for ref_path in $$(grep -oP '\$$\{CLAUDE_PLUGIN_ROOT\}/[a-zA-Z0-9_./-]+' "$$src_file" 2>/dev/null | sort -u || true); do \
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
# stays a warning until demo sync promotes it.
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
	   echo "  templates/iso-config/.iso-config.yaml records a sysml_toolchain."; \
	 else \
	   echo "ERROR: templates/iso-config/.iso-config.yaml does not record a sysml_toolchain"; \
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

# The behavioural hook tests under tests/hooks/. Every toolchain is
# stubbed, so the assertions hold with no SysML tool installed, which
# is what CI runs. The real-tool section of check-toolchain.sh prints
# SKIPPED for each toolchain the machine does not carry. Set
# VSE_TC_TEST_PATH to put a local toolchain checkout on the PATH.
check-toolchain:
	@echo "Checking the SysML toolchain library..."
	@bash tests/hooks/check-toolchain.sh

test-hooks:
	@echo "Testing the hook scripts..."
	@bash tests/hooks/test-pre-commit.sh && bash tests/hooks/test-session-start.sh

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
