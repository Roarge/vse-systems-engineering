<!-- PR template per methodology §8.6.1. -->

## Story or change summary

<!-- For story branches: the story's narrative form (As a <role>, I want
     <capability>, so that <benefit>). For methodology and architectural
     branches: the change rationale. One paragraph. -->

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

<!-- Group by package: model/core/stories/stakeholder/, etc. -->

## Author readiness checklist (§8.6.2)

For every story advanced by this PR:

- [ ] Story declares `role`, typed by a part def from `model/core/stakeholders/`.
- [ ] Story declares `capability` and `benefit` strings (narrative form retained per §1.7.2).
- [ ] Story declares `subject` referencing `SmartSensor_System`.
- [ ] Story declares at least one `acceptance` criterion in Given/When/Then form.
- [ ] Framed `concern def`s exist in `model/core/concerns/`.
- [ ] Use cases (if any) declare the story as `objective` with conformant `subject` and `actor` types per §1.4.5.
- [ ] `StoryMeta` points, priority, status are recorded.
- [ ] `syside check --warnings-as-errors` passes on the latest commit.
- [ ] Cross-references resolve (no dangling type names, no orphan stories).

## Reviewer checklist (§8.6.3)

- [ ] **Methodology conformance**: §1.9 well-formedness and the level-specific rules of §4 / §5 / §7.
- [ ] **Concern coverage**: no concern is newly orphaned.
- [ ] **Trace integrity**: `derive` from system stories to stakeholder stories. No dangling references.
- [ ] **No methodology drift**: methodology amendments are not smuggled through a story PR.
- [ ] **Variation hygiene** (§6 only): variation point declares all feasible variants, the resolved variant is recorded.
- [ ] **Verification-case stubs** exist for each acceptance criterion, even if the body is deferred.
- [ ] **Self-contained**: no half-finished work in unrelated packages.

For architectural branches, additionally:

- [ ] Trade-study `analysis def` is reproducible.
- [ ] Selected variant's score advantage is documented in the PR description.

## Change Request reference

<!-- If this PR modifies any baselined artefact (per .iso-config.yaml
     baselined_paths), reference the open Change Request Issue:
       Refs: CR #<n>
     -->
