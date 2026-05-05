# Contributing to {{PROJECT_NAME}}

This project follows the story-driven AMBSE methodology shipped by the `vse-systems-engineering` plugin. The methodology specification at `methodology/00-methodology-overview.md` through `methodology/10-project-management.md` is the binding reference. When this document and the methodology disagree, the methodology wins.

## Branch model (§8.4)

`main` is the project's accepted state. Direct commits to `main` are prohibited. Every change reaches `main` through a feature branch and a pull request. Four kinds of feature branch are recognised, each with a fixed naming pattern.

- **Story branches** (`story/<US_id>_<short-name>` or `story/<theme-name>`) are the standard case. They advance one story or a small coherent group of stories through a workflow stage.
- **Methodology branches** (`methodology/<topic>`) carry changes to the spec under `methodology/`.
- **Architectural branches** (`arch/<decision-name>`) carry §6 trade studies. They are typically longer-lived and are reviewed under the §8.6.3 stricter criteria.
- **Release branches** (`release/<tag>`) are optional and used only if the project produces tagged model releases.

Hot-fixes follow the same workflow at elevated priority. They do not bypass the PR step.

## Pull request workflow (§8.5)

A draft pull request is opened on the first commit of every branch. The opening commit minimum is the story file (or methodology section, or trade-study artefact, depending on branch kind), the §1 story members where applicable, and `StoryMeta.status = inProgress`. CI lint runs on every push and is advisory while the PR is in draft.

The author marks the PR ready for review when the §8.6.2 readiness checklist passes. Final review applies the §8.6.3 reviewer checklist. The PR is merged via squash-and-merge after at least one approval. The branch is deleted on merge.

If final review surfaces issues, the PR is converted back to draft. The story status returns to `inProgress`.

## Commit message conventions

Commits follow the conventional-commit pattern with one of three scopes per §4.2 of `methodology/iso-29110-hooks-guide.md`:

- `feat(US_042): brief subject` for story work.
- `plan: revise schedule (CR #17)` for Plan changes referencing a Change Request.
- `meeting: 2026-05-05 architecture sync` for Meeting Records.

The commit-msg hook enforces the pattern. Edits to baselined artefacts (per `.iso-config.yaml` `baselined_paths`) must reference an open Change Request as `(CR #<n>)`, `CR #<n>`, or `Refs: CR #<n>` in the message body. The hook blocks the commit otherwise.

## Code review

The PR template at `.github/pull_request_template.md` embeds the §8.6.1 fields: story summary, stories advanced, concerns addressed, files changed by package, and the §8.6.2 / §8.6.3 checklists.

CODEOWNERS at `.github/CODEOWNERS` assigns reviewers per role (per §10.11 of the methodology).

## Change Requests (§10.4.2)

Edits to baselined artefacts (Project Plan, baselined stories, baselined architecture, methodology spec) require an open Change Request. Open one with `/vse-cr` or via a GitHub Issue with the `change-request` label. The CR Issue is the audit-trail artefact. The implementing PR thread is the implementation record. Both are preserved indefinitely.

## Hooks

This project ships project-side git hooks under `.githooks/`, activated by `git config core.hooksPath .githooks`. The hooks enforce SysML lint, story well-formedness, conventional-commit patterns, baselined-artefact protection, V&V coverage on `done` stories, and traceability matrix freshness. See `methodology/iso-29110-hooks-guide.md` §4 for the full specification.

The Claude Code lifecycle hooks declared by the `vse-systems-engineering` plugin run automatically inside Claude Code sessions and surface methodology reminders.

## Style

- UK English throughout (organisation, behaviour, modelling).
- No em-dashes. Restructure with commas, parentheses, or "that is".
- No semicolons in body text. Split into two sentences.
- No contractions (do not, cannot, will not, it is).
- Plain language first, specialist terms introduced with explanation.
