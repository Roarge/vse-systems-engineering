# vse-systems-engineering

A Claude Code plugin for systems engineering in Very Small Entities (VSEs).

## What it does

This plugin supports ISO/IEC 29110 compliant systems engineering workflows that
are model-based and digital first, rooted in SysML 2.0 textual syntax. It
supports both traditional (Vee model) and agile model-based SE (hybrid lifecycle)
approaches, with use case driven elicitation, structured trade studies, and
continuous verification at nanocycle, microcycle, and macrocycle timeframes.

The plugin works in concert with the official Anthropic engineering plugin,
adding VSE-specific systems engineering knowledge and attention-sustaining
environmental design.

## Design principles

Grounded in the PHAS-EAI framework (Georgsen, 2026):

1. **Reduce information burden** by filtering guidance to the current lifecycle
   phase
2. **Build designed cognitive reserve** by embedding SE competence in the tooling
3. **Provide machine-readable traceability** through SysML 2.0 models
4. **Sustain attention** through environmental design rather than compliance
   mandates

## Skills

| Skill | Purpose |
|-------|---------|
| lifecycle-orchestrator | Navigate ISO 29110 phases, enforce phase gates, select lifecycle approach |
| needs-and-requirements | Elicit stakeholder needs and derive SysML requirements (use case driven) |
| architecture-design | Develop architecture with trade studies, five views, and handoff workflow |
| verification-validation | Plan and execute V&V with continuous verification and trace links |
| traceability-guard | Check and enforce trace completeness |
| sysml2-modelling | Author and validate SysML 2.0 textual models |
| attention-regime | Configure environmental hooks, guards, and reminders |
| session-journal | Manage cross-session continuity journal |
| project-setup | Bootstrap a new VSE project with templates and structure |
| document-export | Export work products to docx, pptx, or pdf |

## Knowledge base

Eleven reference files in `knowledge/`, each 250 to 600 lines, filtered for VSE
context and organised by source.

**ISO/IEC 29110** (process backbone)

- `iso29110-profile.md` -- process structure, roles, work products, phase gates
- `iso29110-task-lists.md` -- actionable checklists reorganised by phase

**PHAS-EAI** (design rationale)

- `phas-eai-framework.md` -- attention constructs, lever tables, DE requirements

**INCOSE** (best practices, scaled)

- `incose-vse-practices.md` -- lifecycle models, stakeholder analysis, V&V
- `needs-and-reqs-guide.md` -- needs elicitation, SMART criteria, writing rules
- `vv-guide.md` -- verification and validation methods, VCRM
- `hsi-primer.md` -- human-systems integration

**AMBSE** (agile model-based process)

- `ambse-agile-process.md` -- hybrid lifecycle, iteration planning, verification timeframes, metrics
- `ambse-requirements.md` -- use case driven elicitation, model-based requirements, nanocycle workflow
- `ambse-architecture.md` -- five architecture views, trade studies, handoff, model-based V&V

**SysML 2.0** (modelling language)

- `sysml2-quick-ref.md` -- textual notation cheat sheet verified against the OMG spec

## Sources

Knowledge is extracted from six source categories, consulted in this priority:

1. **ISO/IEC 29110** -- Systems Engineering Profile for VSEs
2. **PHAS-EAI framework** -- Georgsen (2026), thesis on attention in SE
3. **INCOSE SE Handbook 4e** and domain guides (Needs and Requirements, V&V, HSI)
4. **AMBSE methodology** -- Douglass (2016) *Agile Systems Engineering*, Douglass (2021) *Agile MBSE Cookbook*
5. **SysML 2.0 specification** -- OMG formal/2025-01-01
6. **Domain guides** -- Galinier et al. on SME practices

Source PDFs are private (gitignored) and not distributed with the plugin.

## Tooling

The recommended modelling toolchain is Sensmetry SySiDE:

- **Syside Editor** (free VS Code extension) for syntax highlighting, validation,
  completion, and navigation of .sysml and .kerml files
- **Syside Modeler** (paid) for diagram visualisation (disable the Editor extension
  when using Modeler)
- **Sysand** (open-source) for SysML v2 package management
- Configuration via `syside.toml` in the project root

## Getting started

### Prerequisites

- [Claude Code](https://claude.com/claude-code) CLI installed
- (Recommended) [Sensmetry SySiDE](https://sensmetry.com) VS Code extension for
  `.sysml` file editing, validation, and navigation

### Installation from a local clone

Clone the repository, then register it as a local marketplace inside Claude
Code:

```bash
git clone https://github.com/Roarge/vse-systems-engineering.git
```

Inside a Claude Code session, run the slash commands:

```text
/plugin marketplace add /path/to/vse-systems-engineering
/plugin install vse-systems-engineering@vse-systems-engineering
```

### Installation from GitHub

Inside a Claude Code session:

```text
/plugin marketplace add Roarge/vse-systems-engineering
/plugin install vse-systems-engineering@Roarge-vse-systems-engineering
```

After adding the marketplace, restart Claude Code so it discovers the new
source. Then install the plugin.

### Git hooks (optional)

The `hooks/` directory contains two git hook scripts for automated enforcement:

- **pre-commit-traceability.sh** blocks commits when staged `.sysml` files have
  requirements without `satisfy` or `verify` trace links.
- **phase-gate-check.sh** verifies that required work products exist before a
  phase transition.

To install them in a project:

```bash
cp hooks/pre-commit-traceability.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

These are standard git hooks, not Claude Code plugin hooks. They complement the
plugin by catching trace gaps at commit time.

### Starting a new project

1. Open a fresh project directory in your terminal.
2. Launch Claude Code and invoke the `project-setup` skill.
3. The skill scaffolds the directory structure, creates SysML 2.0 model stubs,
   populates work product templates, and sets the initial phase to SR.1.
4. Use `lifecycle-orchestrator` to navigate through phases, enforce phase gates,
   and select a lifecycle approach (Vee, incremental, or hybrid).

### Picking up an existing project

1. Create a `.vse-phase` file in your project root containing the current phase
   (for example, `SR.2`).
2. Invoke `lifecycle-orchestrator` to pick up from that phase. The orchestrator
   will check prerequisites and guide you through the remaining activities.

### Demo walkthrough

The `demo/smart-sensor/` directory contains a complete lifecycle example that
walks through stakeholder needs, system requirements, architecture, verification,
and validation. See its README for a guided tour.
