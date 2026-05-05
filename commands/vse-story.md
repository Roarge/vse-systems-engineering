---
description: Open or advance a user story under the methodology. Creates the story/<US_id>_<short> branch, scaffolds the story file in the right package, opens a draft PR, and manages StoryMeta status transitions.
argument-hint: "[optional story ID, short name, or one-line intent]"
---

Invoke the `vse-systems-engineering:story-orchestrator` skill to open
or advance a user story per the methodology specification at
`<project>/methodology/01-user-stories.md` and §8.4 (branch model)
of `08-project-structure.md`.

Pass the user-supplied arguments through as additional context for the skill:

$ARGUMENTS

The skill will:

- Confirm the project's repository layout matches §8.3 (a `model/core/`
  tree with the expected sub-packages). If brownfield-style
  scaffolding sits under a subdirectory (for example `engineering/`),
  the skill resolves paths relative to that root.
- Elicit the story role, capability, and benefit per §1.4. Defer
  formalisation of `benefit` as a `require constraint` until the
  story is selected for an architectural trade study.
- Elicit at least one acceptance criterion in Given/When/Then form
  per §1.4.4. The story remains in `backlog` status until the
  criterion is captured.
- Propose a branch name in the `story/<US_id>_<short-name>` form
  per §8.4.2 and confirm with the engineer before creating it.
- Scaffold the story file in
  `model/core/stories/stakeholder/` (§4 stories) or
  `model/core/stories/system/` (§5 stories), or recursively under
  `model/core/logical-architecture/components/<component>/stories/`
  for §7 component stories.
- Apply `@StoryMeta { status = inProgress; }` and seed `points` and
  `priority` if the engineer supplies them.
- Optionally open the draft pull request (per §8.5.1) using the
  PR template at `.github/pull_request_template.md`.
- Refuse to advance to `ready` until the §1.9 well-formedness rules
  pass: typed `role`, declared `subject`, at least one acceptance,
  retained narrative `capability` and `benefit`.

This command is the normal way to advance forward-going work. The
methodology forbids reverse-engineering context stories from the
Base Architecture (§2.6 rule 7); when the engineer's intent is
context capture rather than forward-going work, the skill confirms
intent before authoring.
