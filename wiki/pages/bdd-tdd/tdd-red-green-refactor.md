---
title: "Test-driven development: the red-green-refactor cycle"
slug: tdd-red-green-refactor
type: process
layer: bdd-tdd
summary: The red-green-refactor cycle, the Iron Law, tests that can fail, and how §11.6 adjusts the installed TDD skill
tags: [tdd, red-green-refactor, test-first, superpowers]
sources:
  - citation: "Vincent, J. (2025). superpowers, skill test-driven-development (SKILL.md and writing-good-tests.md), plugin version 6.4.2. MIT licence. https://github.com/obra/superpowers (accessed October 2026)."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §11.5, §11.6 and §11.7 (test-first judgement, installed skill precedence, fallback cycle)."
    raw: methodology/11-behaviour-and-test-driven-development.md
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §8.6.1 (PR template, Test-first evidence)."
    raw: methodology/08-project-structure.md
related:
  - behaviour-and-test-first
  - gherkin-tags-and-tag-expressions
  - story-branch-pr-workflow
confidence: medium
created: 2026-10-18
updated: 2026-10-18
referenced_by: [test-first]
---

# Test-driven development: the red-green-refactor cycle

## Contents

- Goal and the Iron Law
- Preconditions
- The cycle
- Work products
- Tests that can fail
- How §11.6 adjusts the skill
- Failure modes
- See also

Test-driven development (TDD) writes a failing automated test before the code that makes it pass. Red-green-refactor is the TDD loop of §11.7: a failing test (red), the least code that makes it pass (green), then a tidy-up with the tests unchanged (refactor). The test-driven-development skill of the superpowers plugin for Claude Code drives this cycle with strict rules (§11.6). This page records the cycle as the skill states it, and how methodology §11.6 and §11.7 adjust it.

Confidence note: the skill is revised between superpowers releases. This page records version 6.4.2. On 2026-10-17 its SKILL.md and writing-good-tests.md were identical to the GitHub main branch, whose package version was then 7.0.0.

## Goal and the Iron Law

- "Write the test first. Watch it fail. Write minimal code to pass."
- "**Core principle:** If you didn't watch the test fail, you don't know if it tests the right thing."
- Iron Law: "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST".
- "Always": new features, bug fixes, refactoring, behaviour changes.
- "Exceptions (ask your human partner)": throwaway prototypes, generated code, configuration files.

## Preconditions

- Test first applies according to the project's record (§11.5).
- When `superpowers:test-driven-development` is listed, "the agent invokes it before writing code, and the skill governs the mechanics of the cycle" (§11.6).
- When it is not listed, the fallback cycle of §11.7 applies.

## The cycle

The actor is the agent or the engineer writing the code. The input is the next small piece of behaviour.

1. **RED:** "Write one minimal test showing what should happen." The test needs one behaviour, a clear name, and real code ("no mocks unless unavoidable"). A mock is a stand-in object that replaces a real dependency in a test.
2. **Verify RED:** "MANDATORY. Never skip."
   - Confirm that the "Test fails (not errors)", the "Failure message is expected", and it "Fails because feature missing (not typos)".
   - "**Test passes?** You're testing existing behavior. Fix test."
   - §11.7: keep "the failing command and its first failing lines". The pull request's "Test-first evidence" section reproduces them (§8.6.1).
3. **GREEN:** "Write simplest code to pass the test." "Don't add features, refactor other code, or "improve" beyond the test."
4. **Verify GREEN:**
   - Confirm that the test passes, other tests still pass, and the output is pristine.
   - ""Other tests" means the project's suite, not just your file."
   - §11.7: "Run `test_command` and see every test pass."
   - "**Test fails?** Fix code, not test."
5. **REFACTOR:** "After green only", remove duplication, improve names, extract helpers, "Keep tests green. Don't add behavior." §11.7 adds that a pure refactoring "belongs on a branch that matches `refactor_branches`."
6. **Repeat:** "Next failing test for next feature."

- Bug fixes: "Bug found? Write failing test reproducing it." "Never fix bugs without a test."
- Legacy code: characterisation tests first, "tests that pin down what the code does today" (§11.7). The skill's own answer is "You're improving it. Add tests for existing code."
- Outer loop: with `scenario_command` recorded, "The scenario for a criterion runs and fails first, then inner red-green-refactor cycles build the code until it passes" (§11.7).

## Work products

- The failing test.
- The red evidence: the failing command and its first failing lines, which the pull request's Test-first evidence section reproduces (§11.7, §8.6.1).
- The code that makes the test pass.

## Tests that can fail

From writing-good-tests.md:

- The two principles: "1. Every test names the break it catches" and "2. Every test exercises the real thing".
- Before writing, answer "what production change should make this test fail".
- "Derive expectations independently."
- "No change detectors." A change detector is a test that only an intentional decision can fail, such as a constant's value.
- "The mock earns no assertions."
- "Mock at the right level."
- The mutation check means mentally altering the production code to see whether a test fails: "at least one test should fail for each realistic mutation". The list is wrong constant or argument, wrong branch handler, missing state change or side effect, empty or default return, and missing validation.

## How §11.6 adjusts the skill

1. "Its exceptions are already answered." The recorded judgement is the answer, and the agent asks only when the record is silent.
2. "Human work is kept." The skill's "Write code before the test? Delete it. Start over." and "Delete means delete" become "stop, write the failing test, and keep human-authored artefacts". Deletion needs explicit confirmation.
3. "Prose stays exempt." This overrides writing-good-tests' "Documents that instruct agents are tested by the consuming agent's behavior (superpowers:writing-skills)".

"On any other point where the skill and this section differ, this section wins".

## Failure modes

- Red flags from the skill: "Test passes immediately", "Can't explain why test failed", "Code before test".
- "**Test errors?** Fix error, re-run until it fails correctly."
- A change that cannot be written test first "is recorded in the tailoring record with its reason", and "An exception never lowers a gate by itself" (§11.7). The tailoring record is the list of tailoring decisions in `docs/project-plan.md` (§11.5.3).

## See also

- [[behaviour-and-test-first]] for methodology §11 in one page, including the test-first record of §11.5.
- [[gherkin-tags-and-tag-expressions]] for selecting one criterion's scenario on a runner.
- [[story-branch-pr-workflow]] for the pull request template that carries the Test-first evidence section.
