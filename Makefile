# vse-systems-engineering plugin validation
#
# Run 'make' or 'make all' before opening a PR.
#
# Kept in parity with .github/workflows/plugin-ci.yml. A check added
# here must be added there, and the reverse.

.PHONY: all validate lint check-versions check-refs check-skills

all: validate lint check-versions check-skills check-refs
	@echo "All checks passed."

validate:
	@echo "Checking JSON syntax..."
	@jq empty .claude-plugin/plugin.json
	@jq empty .claude-plugin/marketplace.json

lint:
	@echo "Linting hook scripts..."
	@shellcheck hooks/*.sh

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
