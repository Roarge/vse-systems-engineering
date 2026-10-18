---
title: "Gherkin tags and tag expressions"
slug: gherkin-tags-and-tag-expressions
type: reference
layer: bdd-tdd
summary: Tag placement, inheritance and tag expressions, for selecting one story's or one criterion's scenarios on a runner
tags: [gherkin, tags, tag-expressions, scenario-selection]
sources:
  - citation: "Cucumber Open Source Project (2026). Cucumber reference, sections Tags and Conditional hooks. https://cucumber.io/docs/cucumber/api/ (accessed October 2026)."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §11.2.2, §11.2.3 and §11.8 (story and criterion tags, scenario automation)."
    raw: methodology/11-behaviour-and-test-driven-development.md
related:
  - gherkin-syntax-reference
  - behaviour-and-test-first
  - tdd-red-green-refactor
confidence: high
created: 2026-10-18
updated: 2026-10-18
referenced_by: [test-first, story-orchestrator, verification-validation]
---

# Gherkin tags and tag expressions

## Contents

- What tags are for
- Where tags may sit
- Inheritance
- Tag expressions
- Running or ignoring a subset, and restricting hooks
- Tags as documentation
- The tags the methodology prescribes
- Selecting one story or one criterion
- See also

Gherkin is the plain-text Given/When/Then format that Cucumber-family test tools read and run. A tag is a word starting with `@` on the line above a Gherkin keyword, and tools use tags to select and link scenarios (methodology §11.2.2). This page selects the Tags section of the Cucumber reference, with one sentence from its Conditional hooks section, then states the tags methodology §11 prescribes and how they select one story or one criterion. A runner is the Cucumber-family tool that executes the feature files (§11.8).

## What tags are for

- "Tags are a great way to organise your features and scenarios."
- "They can be used for two purposes:" "Running a subset of scenarios" and "Restricting hooks to a subset of scenarios".
- "A feature or scenario can have as many tags as you like." "Separate them with spaces:".

## Where tags may sit

- "Tags can be placed above the following Gherkin elements:" Feature, Rule, Scenario, Scenario Outline and Examples.
- "It is not possible to place tags above Background or steps (Given, When, Then, And and But)."
- "In Scenario Outline, you can use tags on different sets of examples like below:". The source's example tags one `Examples:` block `@mobile` and another `@desktop`.

## Inheritance

- "Tags are inherited by child elements."
- "tags that are placed above a Feature will be inherited by Rule, Scenario, Scenario Outline, or Examples."
- "And similarly tags that are placed above a Scenario Outline will be inherited by Examples."

## Tag expressions

A tag expression combines tags with `and`, `or`, `not` and parentheses to pick scenarios.

- "A tag expression is an infix boolean expression." That is, the operators sit between the tags they join.
- The source's table, with its meaning column (the source calls it Description):

  | Expression | Meaning |
  |---|---|
  | `@fast` | "Scenarios tagged with @fast" |
  | `@wip and not @slow` | "Scenarios tagged with @wip that aren't also tagged with @slow" |
  | `@smoke and @fast` | "Scenarios tagged with both @smoke and @fast" |
  | `@gui or @database` | "Scenarios tagged with either @gui or @database" |

- Parentheses: "For even more advanced tag expressions you can use parenthesis for clarity, or to change operator precedence:", with the example `(@smoke or @ui) and (not @slow)`.

## Running or ignoring a subset, and restricting hooks

- "You can tell Cucumber to only run scenarios with a particular tag:". The examples are `cucumber --tags "@smoke and @fast"` (Ruby) and `mvn test -Dcucumber.filter.tags="@smoke and @fast"` (Java, JUnit 4 and TestNG).
- "You can tell Cucumber to ignore scenarios with a particular tag:". The example is `cucumber --tags "not @smoke"`.
- From the Conditional hooks section: "To run a particular hook only for certain scenarios, you can associate a hook with a tag expression."
- The option differs by implementation, and JUnit 5 has its own documentation ("For JUnit 5 see the cucumber-junit-platform-engine documentation").

## Tags as documentation

- "Tags can refer to IDs in external systems such as requirement management tools, issue trackers" / "or test management tools:".
- "You can use a custom Cucumber reporting plugin that will turn tags into links pointing to documents".
- "Another creative way to use tags is to keep track of where in the development process a certain feature is:".

## The tags the methodology prescribes

- The Feature carries exactly one tag, `@<StoryIdentifier>` (§11.2.2).
- Each scenario carries exactly one `@AC_<name>`, with `<name>` in lowerCamelCase (`^[a-z][A-Za-z0-9]*$`), that is, words run together with each word after the first capitalised, starting in lower case, and unique within the Feature (§11.2.3).
- "A scenario may carry further tags that do not begin with `@AC_`, such as a runner's `@wip`" (§11.2.3).
- Scenarios no machine can exercise are skipped "through a tag the project chooses, such as `@manual`" (§11.8).

## Selecting one story or one criterion

This section is a synthesis of the inheritance rule above and §11.2.3, not a statement of either source.

- Because the Feature tag is inherited, `@<StoryIdentifier>` selects every scenario of one story.
- Criterion names are unique only within a Feature (§11.2.3). So `@AC_<name>` alone can also match another story's scenario.
- On a runner that accepts Cucumber tag expressions, `@<StoryIdentifier> and @AC_<name>` selects one criterion. Otherwise, one criterion is selected by the feature file's path plus its `@AC_` tag.
- The Cucumber Tags section has a `@wip` subsection, but "This section is only applicable to the Rails implementation of Cucumber." This page does not carry its options.

## See also

- [[gherkin-syntax-reference]] for the keywords, steps and the other limits of §11.2.
- [[behaviour-and-test-first]] for methodology §11 in one page.
- [[tdd-red-green-refactor]] for the red-green-refactor cycle of test first, that is, a failing test (red), the least code that makes it pass (green), then a tidy-up with the tests unchanged (refactor).
