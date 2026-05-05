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
       OpsConcerns::FastIncidentResponse
     -->

## Files changed by package

<!-- Automated section if your CI populates it. Otherwise list the
     model/core/ packages and docs/ files touched. Group by package. -->

## Author readiness checklist (§8.6.2)

For every story advanced by this PR:

- [ ] Story declares `role`, typed by a part def from the appropriate stakeholders package.
- [ ] Story declares `capability` and `benefit` strings (narrative form retained per §1.7.2).
- [ ] Story declares `subject` referencing a part def from the enclosing scope.
- [ ] Story declares at least one `acceptance` criterion in Given/When/Then form (or as a `verification def` reference).
- [ ] Framed `concern def`s exist in the appropriate concerns package.
- [ ] Use cases (if any) declare the story as `objective` with conformant `subject` and `actor` types per §1.4.5.
- [ ] `StoryMeta.points`, `priority`, and `status` are set.
- [ ] CI lint and well-formedness checks pass on the latest commit.
- [ ] Cross-references resolve (no dangling type names, no orphan stories).

## Reviewer checklist (§8.6.3)

In addition to confirming the §8.6.2 items:

- [ ] **Methodology conformance**: §1.9 well-formedness rules and the level-specific rules of §4 / §5 / §7.
- [ ] **Concern coverage**: no concern in the affected stakeholders' set is newly orphaned.
- [ ] **Trace integrity**: `derive` from system stories to stakeholder stories, from subsystem stories to system stories. No dangling references.
- [ ] **No methodology drift**: methodology amendments are not smuggled through a story PR.
- [ ] **Variation hygiene** (§6 work only): variations declare all feasible variants, `assert constraint` covers cross-decision rules, the resolved architecture redefines every variation.
- [ ] **Verification-case stubs exist** for each acceptance criterion, even if the case body is deferred.
- [ ] **Self-contained**: no half-finished work in unrelated packages.

For architectural branches, additionally:

- [ ] Trade-study `analysis def` is reproducible.
- [ ] Selected variant's score advantage is documented in the PR description.

## Change Request reference

<!-- If this PR modifies any baselined artefact (per .iso-config.yaml
     baselined_paths), reference the open Change Request Issue:
       Refs: CR #<n>
     The commit-msg hook enforces this. -->
