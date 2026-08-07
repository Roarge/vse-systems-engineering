<!-- BEGIN VSE COMPANION (managed by project-setup) -->
# {{PROJECT_NAME}}

A Very Small Entity systems engineering project run under the
story-driven agile MBSE methodology, ISO/IEC 29110 aligned.

## Project facts

- **Project:** {{PROJECT_NAME}}
- **Short code:** {{PROJECT_SHORT_CODE}}
- **Acquirer:** {{ACQUIRER}}
- **Author:** {{AUTHOR}}
- **Date created:** {{DATE}}
- **Engineering root:** {{ENGINEERING_ROOT}}
- **Profile:** {{PROFILE}} (rigour profile per methodology §0.10)

## Methodology

The project-local `methodology/` folder is authoritative for this
project. The plugin-shipped copy at
`${CLAUDE_PLUGIN_ROOT}/methodology/` is the fallback when a section
file is absent locally.

Consult it before answering any methodology question, and cite the
section number in the answer. If the VSE plugin is not installed,
follow `methodology/` directly.

## Lens

Invoke the `vse-companion-overview` skill at the start of VSE work. It
sets the methodology lens, routes the request to the right specialist
skill, and carries the conventions this file does not restate.

## Pointers, not restatements

- Branch model, pull request workflow, and review checklists: §8.
- Which artefacts and which gates this project owes at its profile:
  §0.10.
- Hook surface and configuration keys:
  `methodology/iso-29110-hooks-guide.md`.
- Project management artefacts and the Change Request lifecycle: §10.

## Writing style

- UK English throughout (organisation, behaviour, modelling).
- No em-dashes. Restructure with commas, parentheses, or "that is".
- No semicolons in body text. Split into two sentences.
- No contractions (do not, cannot, will not, it is).
- Plain language first, specialist terms introduced with explanation.
<!-- END VSE COMPANION -->
