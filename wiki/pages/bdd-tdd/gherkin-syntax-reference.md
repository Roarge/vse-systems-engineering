---
title: "Gherkin syntax reference"
slug: gherkin-syntax-reference
type: reference
layer: bdd-tdd
summary: Gherkin keywords, steps, Background, Outlines, doc strings, data tables and comments, with the limits §11 sets
tags: [gherkin, syntax, feature-file, scenarios]
sources:
  - citation: "Cucumber Open Source Project (2026). Reference (Gherkin syntax). https://cucumber.io/docs/gherkin/reference/ (accessed October 2026)."
    raw: null
  - citation: "Cucumber Open Source Project (2026). Cucumber reference, section Step results. https://cucumber.io/docs/cucumber/api/ (accessed October 2026)."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §11.2 (Gherkin conventions) and §11.8 (scenario automation)."
    raw: methodology/11-behaviour-and-test-driven-development.md
related:
  - gherkin-tags-and-tag-expressions
  - gherkin-declarative-style
  - behaviour-and-test-first
  - user-story-canonical-artefact
confidence: high
created: 2026-10-18
updated: 2026-10-18
referenced_by: [story-orchestrator, needs-and-requirements, test-first]
---

# Gherkin syntax reference

## Contents

- Document structure
- Feature, descriptions and Rule
- Example (Scenario) and steps
- Steps and step definitions
- Background
- Scenario Outline and Examples
- Step arguments
- Comments and spoken languages
- The limits §11.2 sets
- See also

Gherkin is the plain-text Given/When/Then format that Cucumber-family test tools read and run. It "uses a set of special keywords to give structure and meaning to executable specifications" (Reference). This page selects the syntax from the Gherkin Reference and the Step results section of the Cucumber reference, and then states the narrower profile of methodology §11.2.

## Document structure

- "Most lines in a Gherkin document start with one of the keywords."
- The primary keywords are Feature, Rule (since Gherkin 6), Example or Scenario, Given, When, Then, And, But or `*`, Background, Scenario Outline or Scenario Template, and Examples or Scenarios.
- The secondary elements are `"""` (doc strings), `|` (data tables), `@` (tags) and `#` (comments).
- "If you add a colon after a keyword that should not be followed by one, your test(s) will be ignored."
- "The recommended indentation level is two spaces."
- "The first primary keyword in a Gherkin document must always be `Feature`".
- "You can only have a single Feature in a .feature file."

## Feature, descriptions and Rule

- The purpose of Feature is "to provide a high-level description of a software feature, and to group related scenarios."
- "The name and the optional description have no special meaning to Cucumber."
- Descriptions: "These description lines are ignored by Cucumber at runtime, but are available for reporting".
- Descriptions may also sit under Example or Scenario, Background, Scenario Outline and Rule. "You can write anything you like, as long as no line starts with a keyword."
- Rule:
  - "The (optional) Rule keyword has been part of Gherkin since v6."
  - "The purpose of the Rule keyword is to represent one business rule that should be implemented."
  - "A Rule is used to group together several scenarios that belong to this business rule."

## Example (Scenario) and steps

- "This is a concrete example that illustrates a business rule."
- "In addition to being a specification and documentation, an example is also a test."
- "The keyword `Scenario` is a synonym of the keyword `Example`."
- The pattern is "Describe an initial context (Given steps)", "Describe an event (When steps)", "Describe an expected outcome (Then steps)", and "we recommend 3-5 steps per example."
- "Each step starts with Given, When, Then, And, or But."
- "Cucumber executes each step in a scenario one at a time, in the sequence you’ve written them in."
- Given:
  - "Given steps are used to describe the initial context of the system"
  - "It is typically something that happened in the past."
  - "Avoid talking about user interaction in `Given`'s."
- When:
  - "When steps are used to describe an event, or an action."
  - "This can be a person interacting with the system, or it can be an event triggered by another system."
- Then:
  - "Then steps are used to describe an expected outcome, or result."
  - "An outcome should be on an observable output."
- And and But: "replacing the successive Given's or Then's with And's and But's".
- Asterisk: "Gherkin also supports using an asterisk (*) in place of any of the normal step keywords."

## Steps and step definitions

A step definition is the code that binds a step's text to an action or an assertion (methodology §11.8).

- "Keywords are not taken into account when looking for a step definition."
- "This means you cannot have a Given, When, Then, And or But step with the same text as another step."
- "Implementation details should be hidden in the step definitions."
- Then steps: "The step definition of a Then step should use an assertion to compare the actual outcome" / "(what the system actually does) to the expected outcome (what the step says the system is supposed to do)."
- Undefined steps (Cucumber reference, Step results): "When Cucumber can't find a matching step definition, the step gets marked as undefined (yellow)".
- Pending steps (Cucumber reference, Step results): "When a step definition's method invokes the `pending` method, the step is marked as pending".

## Background

- "A Background allows you to add some context to the scenarios that follow it."
- "It can contain one or more Given steps, which are run before each scenario, but after any Before hooks."
- "A `Background` is placed before the first `Scenario`/`Example`, at the same level of indentation."
- "Background is also supported at the `Rule` level".
- "You can only have one set of Background steps per Feature or Rule."
- If scenarios need different setups, "consider breaking up your set of scenarios into more Rules or more Features."
- Tips:
  - "Keep your Background section short."
  - "Don't use Background to set up complicated states, unless that state is actually something the client needs to know."
  - "Think about using higher-level steps, or splitting the `*.feature` file."

## Scenario Outline and Examples

- "The Scenario Outline keyword can be used to run the same Scenario multiple times".
- "The keyword `Scenario Template` is a synonym of the keyword `Scenario Outline`."
- "The steps can use <> delimited parameters that reference headers in the examples table."
- The outline runs "once for each row in the Examples section beneath it (not counting the first header row)."
- "A Scenario Outline must contain one or more Examples (or Scenarios) section(s)."

## Step arguments

- Doc strings:
  - "The text should be offset by delimiters consisting of three double-quote marks on lines of their own:"
  - "Doc strings also support using three backticks as the delimiter:"
  - Content type: "You specify the content type after the triple quote, as follows:"
  - "Indentation beyond the column of the opening `"""` will therefore be preserved."
  - "It will automatically be passed as the last argument in the step definition."
- Data tables:
  - "Data Tables are handy for passing a list of values to a step definition:"
  - "Just like Doc Strings, Data Tables will be passed to the step definition as the last argument."
  - Cell escaping:
    - "If you want to use a newline character in a table cell, you can write this as `\n`."
    - "If you need a `|` as part of the cell, you can escape it as `\|`."
    - "And finally, if you need a `\`, you can escape that with `\\`."

## Comments and spoken languages

- "Comments are only permitted at the start of a new line, anywhere in the feature file."
- "They begin with zero or more spaces, followed by a hash sign (`#`) and some text."
- "Block comments are currently not supported by Gherkin."
- "This is why Gherkin has been translated to over 70 languages".
- "A # language: header on the first line of a feature file tells Cucumber what spoken language to use".
- "If you omit this header, Cucumber will default to English (en)."

## The limits §11.2 sets

These are methodology rules, and the methodology wins. The Reference describes a Given, When, Then pattern ("Examples follow this same pattern") but does not enforce it, so the order rule below narrows Gherkin rather than restating it.

- English only. The header may read only `# language: en`, and "Any other language is an error" (§11.2.2, lint F2).
- Exactly one Feature, carrying exactly one tag `@<StoryIdentifier>` (§11.2.2, lint F3).
- The narrative lines come first (§11.2.2). Tag rules are on [[gherkin-tags-and-tag-expressions]].
- Permitted elements come from the §11.2.4 table. A `Rule:` "Groups scenarios. A Rule states no criterion of its own".
- Background: "At most one per Feature and one per Rule, placed before the first scenario at its level". This restates the Reference. §11.2.4 adds that a Background holds Given steps only (lint F7).
- Steps follow the order `Given* When+ Then+` (§11.2.4, lint F8).
- In an Outline, every placeholder appears in the header of every Examples table, and every Examples table has a header and at least one row (lint F9).

## See also

- [[gherkin-tags-and-tag-expressions]] for tag placement, inheritance and tag expressions.
- [[gherkin-declarative-style]] for writing scenarios that describe behaviour rather than implementation.
- [[behaviour-and-test-first]] for methodology §11 in one page.
- [[user-story-canonical-artefact]] for the story whose criteria the scenarios state.
