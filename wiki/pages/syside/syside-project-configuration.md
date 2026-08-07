---
title: "Syside Project Configuration: syside.toml and .lsp.json"
slug: syside-project-configuration
type: reference
layer: syside
summary: "Three-level syside.toml discovery, merge semantics, the format, lsp, lint and telemetry sections, and .lsp.json"
tags: [syside, configuration, toml, lsp, lint, vscode, project-setup]
sources:
  - citation: "Sensmetry. Syside CLI configuration reference. https://docs.sensmetry.com/modeler/cli/configuration.html (accessed 2026-08)."
    raw: null
related:
  - syside-tooling-overview
  - syside-core-api
  - syside-sysand-package-management
  - vse-canonical-project-layout
  - vse-model-tiers-and-templates
  - sysml2-canonical-model-layout
confidence: high
created: 2026-05-04
updated: 2026-08-07
referenced_by: [sysml2-modelling, project-setup]
---

# Syside Project Configuration

## Contents

- The two configuration files
- Configuration discovery
- Merge semantics
- Top-level keys
- The format section
- The lint section
- The lsp section
- The telemetry section
- .lsp.json
- The two files are independent

## The two configuration files

A VSE project bootstrapped through `project-setup` carries two distinct
configuration files in its root. They serve different consumers and
must not be conflated. `syside.toml` is read by Syside itself. The
Modeler, the `syside` CLI, and the Automator share one loader.
`.lsp.json` is read by the Claude Code IDE.

The annotated `syside.toml` template lives at
`${CLAUDE_PLUGIN_ROOT}/templates/common/syside.toml` and is copied into
every new project at `project-setup` Step 4.

Reference: https://docs.sensmetry.com/modeler/cli/configuration.html

## Configuration discovery

Syside reads configuration from three levels, in increasing order of
precedence.

| Level | File | Purpose |
|---|---|---|
| Global | `$XDG_CONFIG_HOME/syside/syside.toml` | Personal defaults across every project on the machine |
| Project | `<project-root>/syside.toml` | The project's shared, committed configuration |
| Personal | `<project-root>/syside.user.toml` | One engineer's local overrides for this project |

The project root is found by walking upwards from the working directory
until a root marker appears. The markers are a `.git` directory and a
`sysand-lock.toml` file, so a project that uses Sysand for package
management (see [[syside-sysand-package-management]]) is discoverable
even outside a git working tree.

`syside.user.toml` is a personal file. Add it to `.gitignore`. Commit
`syside.toml` so every engineer and the CI runner share one baseline.

## Merge semantics

The three levels are merged rather than replaced, and the rule differs
by value kind.

- **Tables merge key by key.** A project-level `[format]` table that
  sets only `line-width` keeps every other `[format]` key from the
  global file.
- **Scalars and arrays overwrite.** A higher-precedence level replaces
  the value outright. There is no element-wise merge for arrays.
- **`exclude` concatenates.** This is the documented exception. Every
  level's `exclude` entries apply, so a personal exclusion cannot
  silently drop a project-level one.

The practical consequence for a VSE: put the model-wide rules in the
committed `syside.toml`, and leave `syside.user.toml` for personal
noise suppression. An engineer cannot weaken a project lint rule by
merging, only by overwriting the specific severity, which is visible in
their own file.

## Top-level keys

```toml
# Standard library path (omit to use the bundled version)
std = "/path/to/standard/library"

# Additional files or directories to include (glob patterns)
include = ["model/**/*.sysml"]

# Files or directories to exclude (concatenates across levels)
exclude = ["build/**", "*.draft.sysml"]
```

The inclusion globs decide which `.sysml` and `.kerml` files belong to
the project. [[vse-model-tiers-and-templates]] describes how the model
tier files (`vse-library.sysml`, project starter files, sample model
contents) are matched against these globs so the tier separation
survives a toolchain update.

## The format section

`[format]` and its `[format.breaks]` subtable carry more than sixty
options controlling the pretty-printer that `syside format` and the
Automator's printer both use. The template ships the handful a VSE
normally changes.

| Key | Meaning |
|---|---|
| `line-width` | Visual column limit for wrapping |
| `tab-width` | Spaces per indentation level |
| `tabs` | Indent with tabs instead of spaces |
| `markdown` | Treat comments as Markdown |
| `strip-unnecessary-quotes` | Remove redundant identifier quoting |
| `empty-brackets` | Render an empty body as `{}` or as `;` |
| `breaks.force-bodies` | Force child elements onto new lines |
| `breaks.operator` | Place a broken operator before or after the break |

Consult the CLI configuration reference for the full option set. Change
a format option once, in the committed file, because a divergent
personal setting produces diff churn on every save.

## The lint section

`[lint]` sets a severity per diagnostic rule. Each key accepts
`"error"`, `"warning"`, `"information"`, `"hint"`, or `"off"`.

| Rule | What it reports |
|---|---|
| `type-error` | A general type error in the model |
| `usage-feature-typing` | A usage whose feature typing does not resolve as expected |
| `standard-library-package` | Use of a package name that collides with the standard library |
| `global-namespace-distinguishability` | Two elements that are not distinguishable in the global namespace |
| `quantity-operator-expression` | An operator expression over quantities that the evaluator cannot check |
| `related-feature-conformance` | A related feature that does not conform to its declared relationship |

The descriptions summarise each rule from its name. The versioned
Syside settings reference is authoritative for exact semantics and
default severities.

The AMBSE canonical model layout depends on namespace hygiene, so a VSE
raises `standard-library-package` and
`global-namespace-distinguishability` to at least `warning` and treats
`type-error` as an error in CI. See
[[sysml2-canonical-model-layout]] for the layout those rules protect.

## The lsp section

`[lsp]` controls the language server rather than the model.
`completion-limit` caps the number of autocomplete suggestions.
`edit` names the file tiers the server may modify, one of `"project"`,
`"external"`, or `"all"`. Leaving `edit` at `"project"` prevents an
accidental write into the standard library or a vendored package.

## The telemetry section

`[telemetry]` carries `crash-reports`, either `"ignore"` or
`"upload"`. A VSE working on a confidential model leaves it at
`"ignore"`, which is the default.

## .lsp.json

`.lsp.json` is read by the Claude Code IDE, not by Syside. It tells the
IDE which language server binary to launch (`syside lsp` over stdio)
and which file extensions (`.sysml`, `.kerml`) to route to it.

The IDE looks for this file in the workspace the user has open, so it
must live in the project root, not in the plugin cache directory. The
template at `${CLAUDE_PLUGIN_ROOT}/templates/common/lsp.json` is
identical for every project (no placeholder substitution) and is copied
by `project-setup` Step 4.

Without this file the IDE does not spawn the SysML language server, and
editing `.sysml` files inside Claude Code falls back to plain text.
[[vse-canonical-project-layout]] records both files as required at the
project root for the bootstrap to count as complete.

## The two files are independent

Removing `.lsp.json` does not affect `syside check` or Automator
scripts. The CI pipeline still validates the model on push because
`syside.toml` drives the headless tooling. Removing `syside.toml` does
not affect IDE syntax highlighting beyond the format settings the
language server reports back.
