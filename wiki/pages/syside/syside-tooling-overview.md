---
title: "SySiDE Tooling Overview and Installation"
slug: syside-tooling-overview
type: reference
layer: syside
tags: [syside, tooling, installation, vscode, ci, licence]
sources:
  - citation: "Sensmetry. SySiDE documentation: which tool, install, and licence pages. https://docs.sensmetry.com/about/which-tool.html, https://docs.sensmetry.com/automator/install.html (accessed 2026-04)."
    raw: sensmetry_docs_2026-04
related:
  - syside-project-configuration
  - syside-core-api
  - vse-canonical-project-layout
  - sysml2-canonical-model-layout
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling, sysml2-metadata, project-setup]
---

# SySiDE Tooling Overview and Installation

## Tool selection guide

SySiDE offers four complementary tools for SysML v2. Choose
based on workflow:

| Workflow | Tool | Licence |
|----------|------|---------|
| Learning, lightweight editing | **Editor** (VS Code extension) | Free |
| Model writing, diagrams, interactive exploration | **Modeler** (VS Code extension) | Licensed |
| CI/CD validation, headless diagrams | **Modeler CLI** (`syside check`, `syside format`, `syside viz`) | Licensed |
| Programmatic analysis, scripting, report generation | **Automator** (Python library) | Licensed |

Combined workflows: use Modeler for visual review and Automator
for automated analysis. Both share the same licence key.

Decision matrix:

- I need to write and visualise models -> Modeler
- I need to run queries, extract data, or generate reports
  from models -> Automator
- I need to validate models in CI/CD or generate diagrams
  headlessly -> Modeler CLI
- I am learning SysML v2 or making quick edits -> Editor (free)
- I need visual review with automated analysis -> Modeler +
  Automator

If you have Modeler, you already have everything Editor offers.
Disable the Editor extension when Modeler is active to avoid
conflicts. Reference: https://docs.sensmetry.com/about/which-tool.html

## Installation

Requirements: Python 3.12 or later (64-bit), internet
connectivity for licence validation.

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate    # Linux/macOS
# .\.venv\Scripts\activate   # Windows

# Install
pip install syside

# Verify
python -c "import syside; print(syside.__version__)"

# Update
pip install syside --upgrade
```

Additional dependencies for specific workflows:

```bash
pip install pandas openpyxl          # Requirements Excel import/export
pip install python-statemachine      # State machine simulation
pip install weasyprint               # PDF report generation
sudo apt install graphviz            # Dependency graph rendering
sudo apt install pandoc              # DOCX conversion
```

Licence setup (the same key works for Modeler and Automator):

```bash
# Option 1: Environment variable
export SYSIDE_LICENSE_KEY="your-licence-key"

# Option 2: .env file (add .env to .gitignore)
echo "SYSIDE_LICENSE_KEY=your-licence-key" > .env

# Option 3: System keyring
python -c "import keyring; keyring.set_password('license-key.syside', 'license-key', 'your-key')"
```

For CI/CD, use a Deployment Licence Key (prefix `CI-`) stored in
the provider's secret management (GitHub secrets, GitLab CI/CD
variables). Reference: https://docs.sensmetry.com/automator/install.html

## VSE workflow positioning

A typical VSE bootstrapped through `project-setup` installs the
Modeler VS Code extension for interactive editing and the
Automator Python package for automation hooks (CI gates, report
generation, traceability checks). The plugin's `traceability-guard`
and `document-export` skills both depend on Automator being
available in the project's virtual environment.

The vse-canonical-project-layout page describes where SySiDE
tools sit in the canonical directory layout, and the
sysml2-canonical-model-layout page describes the model directory
structure SySiDE consumes.
