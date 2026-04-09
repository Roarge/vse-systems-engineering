# vse-systems-engineering plugin validation
#
# Run 'make' or 'make all' before opening a PR.

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

check-refs:
	@echo "Checking cross-references..."
	@EXIT_CODE=0; \
	 for skill_file in skills/*/SKILL.md; do \
	   for ref_path in $$(grep -oP '\$$\{CLAUDE_PLUGIN_ROOT\}/knowledge/[a-zA-Z0-9_./-]+' "$$skill_file" 2>/dev/null || true); do \
	     rel_path=$$(echo "$$ref_path" | sed 's|\$${CLAUDE_PLUGIN_ROOT}/||'); \
	     if [ ! -f "$$rel_path" ]; then \
	       echo "ERROR: $$skill_file references $$rel_path which does not exist"; \
	       EXIT_CODE=1; \
	     fi; \
	   done; \
	   for ref_path in $$(grep -oP '\$$\{CLAUDE_PLUGIN_ROOT\}/templates/[a-zA-Z0-9_./-]+' "$$skill_file" 2>/dev/null || true); do \
	     rel_path=$$(echo "$$ref_path" | sed 's|\$${CLAUDE_PLUGIN_ROOT}/||'); \
	     if [ ! -f "$$rel_path" ] && [ ! -d "$$rel_path" ]; then \
	       echo "WARNING: $$skill_file references $$rel_path which does not exist"; \
	     fi; \
	   done; \
	 done; \
	 exit $$EXIT_CODE
