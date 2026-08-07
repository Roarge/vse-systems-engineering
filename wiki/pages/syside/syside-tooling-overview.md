---
title: "Syside Tooling Overview and Installation"
slug: syside-tooling-overview
type: reference
layer: syside
summary: Choosing between Syside Editor, Pro Suite, Cloud, and Derisker, plus installation and licence setup
tags: [syside, tooling, installation, vscode, ci, licence, roadmap]
sources:
  - citation: "Sensmetry. Syside documentation: which tool, install, and licence pages. https://docs.sensmetry.com/about/which-tool.html, https://docs.sensmetry.com/automator/install.html (accessed 2026-08)."
    raw: null
  - citation: "Sensmetry. Syside product pages and release notes, release 0.10.3 of 23 July 2026. https://sensmetry.com (accessed 2026-08)."
    raw: null
related:
  - syside-project-configuration
  - syside-core-api
  - syside-sysand-package-management
  - vse-canonical-project-layout
  - sysml2-canonical-model-layout
confidence: medium
created: 2026-05-04
updated: 2026-08-07
referenced_by: [sysml2-modelling, sysml2-metadata, project-setup]
---

# Syside Tooling Overview and Installation

## Contents

- Product lineup
- Choosing a tool
- Installation
- VSE workflow positioning
- Roadmap and version stability

Confidence note: this page is `medium` rather than `high` because two
of its sections describe material that is not yet settled. Syside
Derisker is a beta product, and the Roadmap section describes plans
that Sensmetry may revise. Every other section reflects the shipped
0.10.3 release and is stable.

## Product lineup

The lineup was renamed during 2026. The current names are below, with
release 0.10.3 (23 July 2026) as the reference version.

| Product | What it is | Licence |
|---|---|---|
| **Syside Editor: SysML v2 Essential** | VS Code extension for editing, validation, navigation, and completion | Free |
| **Syside Pro Suite** | Syside Modeler (diagrams, grid views, interactive exploration) plus Syside Automator (Python library and CLI) | Paid |
| **Syside Cloud** | The Pro Suite in a browser, with Claude Code preinstalled | Paid |
| **Syside Derisker** | Safety and security analysis (ISO 26262, ISO/SAE 21434, FMEA) | Beta |

Syside Derisker entered beta in Q1 2026. Treat its feature set as
provisional and confirm availability with Sensmetry before planning a
VSE workflow around it. Statement dated August 2026.

Legacy note: the earlier open-source language server, `sysml-2ls`, was
archived in October 2025 and renamed "SysIDE Editor Legacy". It is no
longer maintained and must not be recommended to a VSE. New projects
use Syside Editor.

## Choosing a tool

| Workflow | Product |
|---|---|
| Learning SysML v2, quick edits, syntax checking | Syside Editor |
| Model writing with diagrams and grid views | Syside Pro Suite (Modeler) |
| Scripted analysis, report generation, CI validation | Syside Pro Suite (Automator and the `syside` CLI) |
| The Pro Suite without a local installation | Syside Cloud |
| Safety and security analysis on top of the model | Syside Derisker (beta) |

If a project holds a Pro Suite licence it already has everything the
free Editor offers. Disable the Editor extension when the Modeler is
active, because the two compete for the same file types. Reference:
https://docs.sensmetry.com/about/which-tool.html

## Installation

Requirements: Python 3.12 or later (64-bit), internet connectivity for
licence validation.

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

Licence setup (one key covers the whole Pro Suite):

```bash
# Option 1: Environment variable
export SYSIDE_LICENSE_KEY="your-licence-key"

# Option 2: .env file (add .env to .gitignore)
echo "SYSIDE_LICENSE_KEY=your-licence-key" > .env

# Option 3: System keyring
python -c "import keyring; keyring.set_password('license-key.syside', 'license-key', 'your-key')"
```

For CI/CD, use a Deployment Licence Key (prefix `CI-`) stored in the
provider's secret management (GitHub secrets, GitLab CI/CD variables).
Reference: https://docs.sensmetry.com/automator/install.html

## VSE workflow positioning

A typical VSE bootstrapped through `project-setup` installs the Pro
Suite VS Code extension for interactive editing and the Automator
Python package for automation hooks (CI gates, report generation,
traceability checks). The plugin's `traceability-guard` and
`document-export` skills both depend on the Automator being available
in the project's virtual environment.

Package management is a separate concern handled by Sysand, the
open-source SysML v2 package manager described in
[[syside-sysand-package-management]].

[[vse-canonical-project-layout]] describes where the Syside tools sit
in the canonical directory layout, and
[[sysml2-canonical-model-layout]] describes the model directory
structure the tools consume. [[syside-project-configuration]] covers
`syside.toml` and `.lsp.json`.

## Roadmap and version stability

Roadmap as of August 2026, from Sensmetry's published plans. Treat
every item here as subject to change.

- Syside and Sysand reach v1.0 together, planned for Q3 2026.
- MCP servers are planned for both Syside and Sysand, so an agent can
  query a model and a package index through a tool interface rather
  than through shell commands.
- A high-level Python API is planned, sitting above the current
  Automator surface.

Until v1.0 lands, both products remain in a breaking-change window.
Release 0.9.0 already broke the Automator CLI, scalar handling, and
validation diagnostics. Pin the Syside version a project depends on,
read the release notes before upgrading, and expect scripted
workflows to need adjustment across minor releases.
