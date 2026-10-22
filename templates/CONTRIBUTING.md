# Contributing to {{PROJECT_NAME}}

This project follows the story-driven AMBSE methodology shipped by the `vse-systems-engineering` plugin. Three sections of `methodology/` are binding on every contribution: §8 (project structure, branch model, pull request workflow, review checklists), §11 (behaviour first and test first) and §0.10 (which of those obligations this project owes at its recorded rigour profile). Read them before your first change. When this document and the methodology disagree, the methodology wins.

## Behaviour first, test first

Every story has a Gherkin feature file, `<ID>.feature`, beside it. Gherkin is the plain-text Given/When/Then format, and each scenario in the file is one acceptance criterion. Write the feature file first, then the story with a named criterion for each scenario, then the case stubs that reach each criterion, and only then the design (§11.4). Where test first applies (`test_first.applies` in `.iso-config.yaml`, §11.5), write the failing test before the code that makes it pass, and keep the failing output for the pull request's Test-first evidence section (§11.7). The pre-commit hook and CI block a story without its feature file, and a code change without a test change, where test first applies, at every profile unless a recorded override lowers the gate (§11.9).

## Branch names

- `story/<US_id>_<short-name>` or `story/<theme-name>` for story work, the standard case.
- `methodology/<topic>` for changes to the spec under `methodology/`.
- `arch/<decision-name>` for §6 trade studies.
- `refactor/<slug>` for restructuring code without changing its behaviour, with the tests unchanged. On these branches the test-first gates remind rather than block (§8.4.3, §11.9). The patterns are listed in `test_first.refactor_branches`.
- `release/<tag>` for tagged model releases, optional.

## Commit messages

The common forms, per §4.2 of `methodology/iso-29110-hooks-guide.md`
(the hook accepts the full conventional-commit type set, and a Change
Request reference may accompany any type):

- `test(US_042): brief subject` for the failing test, committed before the `feat` commit that makes it pass, where test first applies (§11.7).
- `feat(US_042): brief subject` for story work.
- `plan: revise schedule (CR #17)` for work referencing a Change Request.
- `meeting: 2026-05-05 architecture sync` for Meeting Records.

Edits to any path on the `baselined_paths` list in `.iso-config.yaml` carry a Change Request reference in the message, written as `(CR #<n>)`, `CR #<n>`, or `Refs: CR #<n>`.

## Hooks

Project-side git hooks live in `.githooks/` and are activated once per clone with `git config core.hooksPath .githooks`. Which hooks are installed and whether each gate blocks or warns follows the project profile, per §3.4 and §4 of `methodology/iso-29110-hooks-guide.md`. The CI workflow `.github/workflows/traceability-check.yml` runs the same commit-time gates over the changes each pull request or push brings, and, where test first applies, runs the recorded `test_first.test_command` and `test_first.scenario_command`. To check a branch locally the way CI does, run `VSE_PRECOMMIT_RANGE=origin/main...HEAD .githooks/pre-commit`.
