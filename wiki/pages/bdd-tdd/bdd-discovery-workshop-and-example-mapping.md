---
title: "Discovery workshops and Example Mapping"
slug: bdd-discovery-workshop-and-example-mapping
type: process
layer: bdd-tdd
summary: Running a discovery workshop or an Example Mapping session to find a story's rules, examples and open questions
tags: [bdd, discovery-workshop, example-mapping, three-amigos]
sources:
  - citation: "Cucumber Open Source Project (2026). Discovery workshop. https://cucumber.io/docs/bdd/discovery-workshop/ (accessed October 2026)."
    raw: null
  - citation: "Cucumber Open Source Project (2026). Example Mapping. https://cucumber.io/docs/bdd/example-mapping/ (accessed October 2026)."
    raw: null
  - citation: "Cucumber Open Source Project (2026). Who does what? https://cucumber.io/docs/bdd/who-does-what/ (accessed October 2026)."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §11.2.2, §11.2.3, §11.2.4, §11.3.1 and §11.4, with §8.7."
    raw: methodology/11-behaviour-and-test-driven-development.md
related:
  - bdd-three-practices
  - gherkin-syntax-reference
  - user-story-canonical-artefact
  - stakeholder-stories-workflow
  - requirements-elicitation-and-writing
confidence: high
created: 2026-10-18
updated: 2026-10-18
referenced_by: [needs-and-requirements]
---

# Discovery workshops and Example Mapping

Behaviour-driven development (BDD) describes the behaviour a stakeholder expects as concrete example scenarios before anyone designs or builds it, and discovery is the BDD practice that finds those examples (see [[bdd-three-practices]]). This page gives the Cucumber documentation's account of a discovery workshop and of Example Mapping, then maps the result onto the story's feature file under methodology §11, which wins wherever the two differ.

## Goal

- "A discovery workshop is a conversation where technical and business people collaborate" / "to explore, discover and agree as much as they can about the desired behaviour for a User Story."
- From Example Mapping: before development, "it’s crucial to have a conversation" / "to clarify and confirm the acceptance criteria."

## Preconditions: when and who

- "As late as possible before development on a new User Story begins".
- "A good rule-of-thumb is 3-6 people" / "at a bare minimum your Three Amigos should be present: a product owner, a developer, and a tester."
- The Three Amigos are the product owner, tester and developer perspectives, brought together in one meeting. "The Three Amigos is a meeting that takes user stories and turns them into clean, thorough Gherkin scenarios" ("Who does what?"). Gherkin is the plain-text Given/When/Then format that Cucumber-family test tools read and run.
- The three perspectives:
  - Product owner: "This person is most concerned with the scope of the application."
  - Tester: "This person will be generating lots of Scenarios, and lots of edge cases."
  - Developer: "This person will add many of the Steps to the Scenarios, and think of the details that go into each requirement."
- "there is no reason to limit these meetings to three people".

## Three formats

- Example Mapping "Uses a pack of index cards in four different colours to map rules" / "(a summary of constraints/acceptance criteria the team has agreed upon)" / "to examples (illustrations/cases of the acceptance criteria)".
- OOPSI Mapping ("Outcomes, Outputs, Processes, Scenarios, Inputs"): "Similar to Example Mapping, uses Post-it Notes of different colours" / "to map shared processes/relationships between outputs and scenarios."
- Feature Mapping: "Also uses Post-it Notes of different colours." / "The team picks a story from the backlog, identifies the actors involved, breaks the story down into tasks," / "and maps those tasks to specific examples."

## Steps of an Example Mapping session

The actor for every step is the workshop group (the Three Amigos at minimum). The input is one story, and the outputs are the cards.

1. "We write the story on a yellow card and place it on top."
2. "Each of the acceptance criteria, or rules, is written on a blue card and placed beneath the yellow story card."
3. "Examples to illustrate these rules are written on a green card and placed under the relevant rule."
4. "Questions that cannot be answered during the session are captured on a red card" / "so we can move on with the conversation."
5. Also captured: "new user stories discovered or sliced and deferred out of scope."
6. "We keep going until the group is satisfied that the scope of the story is clear, or we run out of time."

## Timebox and failure modes

- "A discovery workshop should ideally only last about 25-30 minutes per story."
- "If you need any more time than this, it's likely the story is far too large and should be broken down".
- Where specifics are missing: "In the latter case, you should set aside the story as the team needs to do more research."

## Postconditions and work products: from the map to the feature file

This is a synthesis grounded in §11, and the methodology wins.

- The yellow card becomes the story and its `<ID>.feature` with the tag and the narrative. Zero scenarios are allowed in `backlog` (§11.4).
- The Cucumber page "Who does what?" describes the Feature narrative as "`In order to` ... `As a` ... `I want`", whereas methodology §11.2.2, which wins, requires "As a / I want / So that" in that order, and the plugin's story lint (its automated check of stories and feature files) reports F6 when the lines are missing or out of order.
- A blue rule becomes, where wanted, a Gherkin `Rule:` that "Groups scenarios" and "states no criterion of its own" (§11.2.4). This fits the Gherkin Reference's Rule "to represent one business rule" (see [[gherkin-syntax-reference]]).
- Each green example becomes one scenario with one `@AC_<name>` tag, mirrored by a named criterion (§11.2.3, §11.3.1). A scenario is written before the criterion that mirrors it (§11.4, consequence 3).
- A sliced story enters the backlog. It need not yet exist as a file (§8.7). Once it is written as a file, it carries its feature file with the story tag and the narrative (§11.4, consequence 4).
- Red cards have no artefact in §11. This page makes no claim about where they are recorded.
- Who formulates afterwards: the whole team, or a pair with product owner review ("Who does what?").

## See also

- [[bdd-three-practices]] for where discovery sits among the three BDD practices.
- [[gherkin-syntax-reference]] for the syntax the scenarios are written in.
- [[user-story-canonical-artefact]] for the story and its named acceptance criteria.
- [[stakeholder-stories-workflow]] for the §4 stage where stakeholder stories are authored.
- [[requirements-elicitation-and-writing]] for elicitation techniques and the rules for writing requirement statements.
