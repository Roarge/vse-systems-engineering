<!-- PR template per methodology §8.6.1. -->

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
       SmartSensor_Concerns::AlertResponseTime
     -->

## Files changed by package

<!-- Group by package: model/core/stories/stakeholder/, etc., feature
     files included. -->

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

- [ ] Story declares `role`, typed by a part def from `model/core/stakeholders/`.
- [ ] Story declares `capability` and `benefit` strings (narrative form retained per §1.7.2).
- [ ] Story declares `subject` referencing `SmartSensor_System`.
- [ ] Story has its feature file, `<ID>.feature`, beside it, with at least one scenario tagged `@AC_<name>`, and each scenario is mirrored by a named criterion nested in `requirement :>> acceptance` (§11.2, §11.3).
- [ ] Framed `concern def`s exist in `model/core/concerns/`.
- [ ] Use cases (if any) declare the story as `objective` with conformant `subject` and `actor` types per §1.4.5.
- [ ] `StoryMeta` points, priority, status are recorded.
- [ ] The model validates under the project's SysML v2 toolchain, `omg-pilot` here. The commands are in the README validation record.
- [ ] Cross-references resolve (no dangling type names, no orphan stories).

## Reviewer checklist (§8.6.3)

- [ ] **Methodology conformance**: §1.9 well-formedness and the level-specific rules of §4 / §5 / §7.
- [ ] **Concern coverage**: no concern is newly orphaned.
- [ ] **Trace integrity**: `derive` from system stories to stakeholder stories. No dangling references.
- [ ] **No methodology drift**: methodology amendments are not smuggled through a story PR.
- [ ] **Variation hygiene** (§6 only): variation point declares all feasible variants, the resolved variant is recorded.
- [ ] **Behaviour first and test first** (§11): every acceptance criterion is reached by a verification or validation case, even if only by a stub whose body is deferred (§11.4). Where test first applies, the Test-first evidence section shows a failing test before each code change (§11.7).
- [ ] **Self-contained**: no half-finished work in unrelated packages.

For architectural branches, additionally:

- [ ] Trade-study `analysis def` is reproducible.
- [ ] Selected variant's score advantage is documented in the PR description.

## Change Request reference

<!-- If this PR modifies any baselined artefact (per .iso-config.yaml
     baselined_paths), reference the open Change Request Issue:
       Refs: CR #<n>
     -->
