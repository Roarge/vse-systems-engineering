# Contributing to {{PROJECT_NAME}}

This project follows the story-driven AMBSE methodology shipped by the `vse-systems-engineering` plugin. Two sections of `methodology/` are binding on every contribution: §8 (project structure, branch model, pull request workflow, review checklists) and §0.10 (which of those obligations this project owes at its recorded rigour profile). Read them before your first change. When this document and the methodology disagree, the methodology wins.

## Branch names

- `story/<US_id>_<short-name>` or `story/<theme-name>` for story work, the standard case.
- `methodology/<topic>` for changes to the spec under `methodology/`.
- `arch/<decision-name>` for §6 trade studies.
- `release/<tag>` for tagged model releases, optional.

## Commit messages

Three forms are accepted, per §4.2 of `methodology/iso-29110-hooks-guide.md`:

- `feat(US_042): brief subject` for story work.
- `plan: revise schedule (CR #17)` for work referencing a Change Request.
- `meeting: 2026-05-05 architecture sync` for Meeting Records.

Edits to any path on the `baselined_paths` list in `.iso-config.yaml` carry a Change Request reference in the message, written as `(CR #<n>)`, `CR #<n>`, or `Refs: CR #<n>`.

## Hooks

Project-side git hooks live in `.githooks/` and are activated once per clone with `git config core.hooksPath .githooks`. Which hooks are installed and whether each gate blocks or warns follows the project profile, per §3.4 and §4 of `methodology/iso-29110-hooks-guide.md`.
