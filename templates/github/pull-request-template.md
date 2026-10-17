<!-- PR template per methodology §8.6.1. -->

**Complete the items for your project profile (methodology §0.10 and §8.6.4).**
Untagged items apply at every profile. `[standard]` items apply at
`standard` and `full`. `[full]` items apply at `full` only. The profile
is recorded as `project_profile` in `.iso-config.yaml`.

## Story or change summary

<!-- For story branches: the story's narrative form (As a <role>, I want
     <capability>, so that <benefit>), as its feature file states it.
     For methodology and architectural branches: the change rationale.
     One paragraph. -->

## Stories advanced

<!-- List the story IDs and the StoryMeta status transitions this PR
     applies. Example:
       US_042_AckFromDashboard: ready -> inProgress
       SYS_142_BatchAcknowledgement: backlog -> ready
     -->

## Concerns addressed

<!-- List the concern def references for which this PR adds or
     strengthens framing. Example:
       OpsConcerns::FastIncidentResponse
     -->

## Files changed by package

<!-- Automated section if your CI populates it. Otherwise list the
     model/core/ packages and docs/ files touched, feature files
     included. Group by package. -->

## Test-first evidence (§11.7)

<!-- Required at every profile where test first applies, that is, where
     test_first.applies is true in .iso-config.yaml (§11.5). For each
     code change, paste the failing test command and its first failing
     lines, captured before the code that made the test pass. Example:
       $ pytest -q tests/test_alarm_queue.py
       FAILED tests/test_alarm_queue.py::test_ack_clears_alarm
     A change made on a refactor branch with the tests unchanged says
     so here. Where test first does not apply, write "Not applicable"
     with the reason recorded in test_first.rationale. -->

## Author readiness checklist (§8.6.2)

For every story advanced by this PR:

- [ ] `[standard]` Story declares `role`, typed by a part def from the appropriate stakeholders package.
- [ ] Story declares `capability` and `benefit` strings (narrative form retained per §1.7.2).
- [ ] `[standard]` Story declares `subject` referencing a part def from the enclosing scope.
- [ ] Story has its feature file, `<ID>.feature`, beside it, with at least one scenario tagged `@AC_<name>`, and each scenario is mirrored by a named criterion nested in `requirement :>> acceptance` (§11.2, §11.3).
- [ ] `[full]` Framed `concern def`s exist in the appropriate concerns package.
- [ ] `[full]` Use cases (if any) declare the story as `objective` with conformant `subject` and `actor` types per §1.4.5.
- [ ] `[standard]` The `StoryMeta` fields listed in `storymeta.required_fields` are set.
- [ ] The model parses.
- [ ] `[full]` CI lint and well-formedness checks pass on the latest commit.
- [ ] `[full]` Cross-references resolve (no dangling type names, no orphan stories).

At `light`, the two items above marked `[standard]` for `role` and
`subject` are covered coarsely by this one instead:

- [ ] The story file sits in the package appropriate to its level.

## Reviewer checklist (§8.6.3)

In addition to confirming the author items:

- [ ] `[standard]` **Methodology conformance**: §1.9 well-formedness rules and the level-specific rules of §4 / §5 / §7.
- [ ] `[full]` **Concern coverage**: no concern in the affected stakeholders' set is newly orphaned.
- [ ] **Trace integrity**: `derive` from system stories to stakeholder stories, from subsystem stories to system stories. No dangling references.
- [ ] `[full]` **No methodology drift**: methodology amendments are not smuggled through a story PR.
- [ ] `[full]` **Variation hygiene** (§6 work only): variations declare all feasible variants, `assert constraint` covers cross-decision rules, the resolved architecture redefines every variation.
- [ ] `[standard]` **Behaviour first and test first** (§11): every acceptance criterion is reached by a verification or validation case, even if only by a stub whose body is deferred (§11.4). Where test first applies, the Test-first evidence section shows a failing test before each code change (§11.7).
- [ ] **Self-contained**: no half-finished work in unrelated packages.
- [ ] **Still the right change**: the story matches the intent that prompted it.

For architectural branches, additionally:

- [ ] `[full]` Trade-study `analysis def` is reproducible.
- [ ] `[full]` Selected variant's score advantage is documented in the PR description.

## Change Request reference

<!-- If this PR modifies any baselined artefact (per .iso-config.yaml
     baselined_paths), reference the open Change Request Issue:
       Refs: CR #<n>
     The commit-msg hook enforces this at standard and full. At light
     the default baselined_paths list is empty, so this section applies
     only once the project has baselined something. -->
