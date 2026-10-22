---
title: "Declarative Gherkin: describe behaviour, not implementation"
slug: gherkin-declarative-style
type: pattern
layer: bdd-tdd
summary: Writing scenarios that describe behaviour rather than implementation, in a declarative style that survives redesign
tags: [gherkin, declarative-style, scenarios, living-documentation]
sources:
  - citation: "Cucumber Open Source Project (2026). Writing better Gherkin. https://cucumber.io/docs/bdd/better-gherkin/ (accessed October 2026)."
    raw: null
  - citation: "Cucumber Open Source Project (2026). Reference (Gherkin syntax). https://cucumber.io/docs/gherkin/reference/ (accessed October 2026)."
    raw: null
  - citation: "Cucumber Open Source Project (2026). Who does what? https://cucumber.io/docs/bdd/who-does-what/ (accessed October 2026)."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §11.1, §11.3 (criterion doc restates the scenario, worked example) and §11.8."
    raw: methodology/11-behaviour-and-test-driven-development.md
related:
  - gherkin-syntax-reference
  - bdd-three-practices
  - requirements-elicitation-and-writing
confidence: high
created: 2026-10-18
updated: 2026-10-22
referenced_by: [needs-and-requirements, story-orchestrator]
---

# Declarative Gherkin: describe behaviour, not implementation

Gherkin is the plain-text Given/When/Then format that Cucumber-family test tools read and run (methodology §11.1). A scenario in it can be written imperatively, as the steps a user takes through the user interface (UI), or declaratively, as the behaviour the system shows. This page records the Cucumber documentation's case for the declarative style and how it fits the methodology.

## Problem

Scenarios written as UI procedures change whenever the implementation does. Of the imperative style, Writing better Gherkin says: "Any time the implementation changes, the tests need to be updated too."

## Context

In this methodology every acceptance criterion is a scenario (§11.1). Where no runner, the tool that executes the feature files, is wired, "The scenarios are still the acceptance criteria" (§11.8), so a scenario must read well whether or not a runner executes it.

## Forces

- "Imperative tests communicate details, and in some contexts this style of test is appropriate."
- "Declarative style describes the behaviour of the application, rather than the implementation details."

## Solution

- "Your scenarios should describe the intended behaviour of the system, not the implementation".
- "In other words, it should describe what, not how."
- The test question: "Will this wording need to change if the implementation does?" and "If the answer is “Yes”, then you should rework it avoiding implementation specific details."
- "Functional requirements are features, but procedures belong in the implementation details."
- The details "are specified in the step definitions" / "(the automation code that interacts with the system)."
- Contrast:
  - Imperative: `Given I am on the login page` and `And I press the "Submit" button`.
  - Declarative: `Given Free Frieda has a free subscription` and `When Free Frieda logs in with her valid credentials`.
- Step advice:
  - Avoid user interaction in Given steps (Reference).
  - "An outcome should be on an observable output" (Reference).
  - Aim for 3 to 5 steps (Reference). The methodology sets no step count.
  - "In general, any `Given` step line should describe only one thing." ("Who does what?")
  - Say the same thing the same way every time (paraphrase of "Who does what?").
- VSE example: the demo scenario of §11.3.2.

  ```gherkin
  Given the device is online and reporting
  When the operator opens the dashboard
  Then the latest reading is displayed within 5 seconds of arrival at the cloud broker
  ```

## Consequences

- Scenarios "will be a lot shorter and much easier to follow and understand".
- "Declarative scenarios read better as "living documentation"."
- The business can change details "without having to change this scenario and other scenarios that use the same step definitions."
- In the model, the criterion's `doc` "restates the scenario in prose" (§11.3.1), and a declarative scenario restates cleanly. This last point is a synthesis of this page, not a statement of either source.

## Related patterns

- [[gherkin-syntax-reference]] for the step keywords and the limits §11.2 sets.
- [[bdd-three-practices]] for formulation, the practice this pattern serves.
- [[requirements-elicitation-and-writing]] for the rules for writing requirement statements.
