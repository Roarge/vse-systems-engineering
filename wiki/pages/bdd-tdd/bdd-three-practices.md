---
title: "Behaviour-driven development: the three practices"
slug: bdd-three-practices
type: concept
layer: bdd-tdd
summary: What BDD is, its discovery, formulation and automation practices, and where each sits in the methodology
tags: [bdd, discovery, formulation, automation]
sources:
  - citation: "Cucumber Open Source Project (2026). Behaviour-Driven Development. https://cucumber.io/docs/bdd/ (accessed October 2026)."
    raw: null
  - citation: "Cucumber Open Source Project (2026). Who does what? https://cucumber.io/docs/bdd/who-does-what/ (accessed October 2026)."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §11.1, §11.4, §11.7 and §11.8."
    raw: methodology/11-behaviour-and-test-driven-development.md
related:
  - bdd-discovery-workshop-and-example-mapping
  - gherkin-declarative-style
  - behaviour-and-test-first
  - tdd-red-green-refactor
  - stakeholder-stories-workflow
confidence: high
created: 2026-10-18
updated: 2026-10-18
referenced_by: [needs-and-requirements, story-orchestrator]
---

# Behaviour-driven development: the three practices

## Contents

- What BDD is
- The loop
- Discovery
- Formulation
- Automation
- Where each practice sits in this methodology
- See also

Behaviour-driven development (BDD) describes the behaviour a stakeholder expects as concrete example scenarios before anyone designs or builds it (methodology §11.1). This page gives the Cucumber documentation's account of BDD and its three practices, then places each practice in the methodology, which wins wherever the two differ.

## What BDD is

- "BDD is a way for software teams to work that closes the gap between business people and technical people by:"
  - "Encouraging collaboration across roles to build shared understanding of the problem to be solved"
  - "Working in rapid, small iterations to increase feedback and the flow of value"
  - "Producing system documentation that is automatically checked against the system's behaviour"
- "We do this by focusing collaborative work around concrete, real-world examples".
- "BDD does not replace your existing agile process, it enhances it."
- "Although documentation and automated tests are produced by a BDD team, you can think of them as nice side-effects."

## The loop

1. "First, take a small upcoming change to the system -- a User Story -- and talk about concrete examples" / "of the new functionality to explore, discover and agree on the details of what's expected to be done."
2. "Next, document those examples in a way that can be automated, and check for agreement."
3. "Finally, implement the behaviour described by each documented example, starting with an automated test" / "to guide the development of the code."

- "The idea is to make each change small and iterate rapidly, moving back up a level each time you need more information."
- "We call these practices Discovery, Formulation, and Automation."

## Discovery

- The Cucumber page opens this section with a quotation from Fred Brooks, The mythical man-month: "The hardest single part of building a software system is deciding precisely what to build."
- "We use structured conversations, called discovery workshops, that focus around real-world examples" / "of the system from the users' perspective."
- "These conversations grow our team's shared understanding of the needs of our users".
- "If you're new to BDD, discovery is the right place to start."
- [[bdd-discovery-workshop-and-example-mapping]] describes how a discovery workshop runs.

## Formulation

- "we can now formulate each example as structured documentation."
- "a medium that can be read by both humans and computers."
- "We can get feedback from the whole team about our shared vision of what we're building."
- Who writes it (Who does what?). Gherkin is the plain-text Given/When/Then format that Cucumber-family test tools read and run (§11.1).
  - "it is recommended that the entire team collaborate on writing the Gherkin."
  - Later a pair (developer and tester) can do it "as long as their output is actively reviewed by the product owner (or business representative)."

## Automation

- "Now that we have our executable specification, we can use it to guide our development of the implementation."
- "The test fails because we have not implemented the behaviour it describes yet."
- "This rapid, repeatable feedback reduces the burden of manual regression testing,".
- "Over time, the documented examples become an asset".

## Where each practice sits in this methodology

The methodology wins. Every mapping below cites §11.

- **Discovery** feeds the story's scenarios. A `backlog` story needs only its feature file, `<ID>.feature`, with the story tag and the narrative ("Zero scenarios are allowed"), and `ready` needs "At least one tagged scenario" (§11.4).
- **Formulation** is the feature file beside the story, written "before design or code" (§11.1). The order of work starts with "write the feature file with its narrative and the scenarios known so far" (§11.4).
- **Automation** happens only where test first applies: "Gherkin scenarios are executed only where test first applies" (§11.8). Test-driven development (TDD) writes a failing automated test before the code that makes it pass (§11.1).
  - The runner (the Cucumber-family tool that executes the feature files) reads the files in place and runs in strict mode, so that an undefined or pending step fails instead of passing silently. Step definitions, the code that binds each step's text to an action or an assertion, are test code (§11.8).
  - Where `scenario_command` (the command that runs the scenarios, §11.8) is recorded, the scenarios form an outer loop around red-green-refactor (§11.7). Red-green-refactor is the TDD loop of a failing test (red), the least code that makes it pass (green), then a tidy-up (refactor).
  - Where test first does not apply, "no runner is wired" and "the cases that reach them verify and validate them" (§11.8).

## See also

- [[bdd-discovery-workshop-and-example-mapping]] for running a discovery workshop or an Example Mapping session.
- [[gherkin-declarative-style]] for formulating scenarios that describe behaviour rather than implementation.
- [[behaviour-and-test-first]] for methodology §11 in one page.
- [[tdd-red-green-refactor]] for the red-green-refactor cycle of the automation practice.
- [[stakeholder-stories-workflow]] for the §4 stage where stakeholder stories are authored.
