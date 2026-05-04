---
title: "SySiDE Project Configuration: syside.toml and .lsp.json"
slug: syside-project-configuration
type: reference
layer: syside
tags: [syside, configuration, toml, lsp, vscode, project-setup]
sources:
  - citation: "Sensmetry. SySiDE Modeler CLI configuration. https://docs.sensmetry.com/modeler/cli/configuration.html (accessed 2026-04)."
    raw: sensmetry_docs_2026-04
related:
  - syside-tooling-overview
  - syside-core-api
  - vse-canonical-project-layout
  - vse-model-tiers-and-templates
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling, project-setup]
---

# SySiDE Project Configuration

A VSE project bootstrapped through `project-setup` carries two
distinct SySiDE-related configuration files in its root. They
serve different consumers and must not be conflated.

## syside.toml

`syside.toml` is read by SySiDE itself. Modeler, Modeler CLI,
and Automator share the same loader. It controls:

- File inclusion and exclusion globs (which `.sysml` and `.kerml`
  files belong to the project)
- Format rules (line width, tab width, Markdown comments)
- LSP completion limits and edit tiers
- Lint severity per rule
- Telemetry behaviour

The annotated template lives at
`${CLAUDE_PLUGIN_ROOT}/templates/common/syside.toml` and is
copied into every new project at `project-setup` Step 4. The
default profile enforces 80-character line width, Markdown
comments, and a strict lint severity for the rules the AMBSE
canonical model layout depends on (see
sysml2-canonical-model-layout).

Reference:
https://docs.sensmetry.com/modeler/cli/configuration.html

## .lsp.json

`.lsp.json` is read by the Claude Code IDE, not by SySiDE. It
tells the IDE which language server binary to launch
(`syside lsp` over stdio) and which file extensions (`.sysml`,
`.kerml`) to route to it.

The IDE looks for this file in the workspace the user has open,
so it must live in the project root, not in the plugin cache
directory. The template at
`${CLAUDE_PLUGIN_ROOT}/templates/common/lsp.json` is identical
for every project (no placeholder substitution) and is copied by
`project-setup` Step 4.

Without this file the IDE will not spawn the SysML language
server, and editing `.sysml` files inside Claude Code falls back
to plain text. The vse-canonical-project-layout page records
both files as required at the project root for the bootstrap to
be considered complete.

## The two files are independent

Removing `.lsp.json` does not affect `syside check` or Automator
scripts. The CI pipeline still validates the model on push
because `syside.toml` drives the headless tooling. Removing
`syside.toml` does not affect IDE syntax highlighting beyond the
format settings the LSP reports back.

The vse-model-tiers-and-templates page describes how the model
tier files (`vse-library.sysml`, project starter files, sample
model contents) are matched against the inclusion globs in
`syside.toml` so that the tier separation survives toolchain
updates.
