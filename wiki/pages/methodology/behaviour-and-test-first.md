---
title: "Behaviour first and test first (§11)"
slug: behaviour-and-test-first
type: concept
layer: methodology
summary: "Section 11 in one page: a feature file per story, mirrored criteria, story ordering, the test-first record, gates"
tags: [gherkin, test-first, user-story, gates]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §11 (Behaviour-Driven and Test-Driven Development)."
    raw: methodology/11-behaviour-and-test-driven-development.md
related:
  - user-story-canonical-artefact
  - storymeta-lifecycle
  - story-branch-pr-workflow
  - methodology-overview
  - tooling-reference-implementation-rules
  - gherkin-syntax-reference
  - gherkin-tags-and-tag-expressions
  - tdd-red-green-refactor
  - bdd-three-practices
confidence: high
created: 2026-10-18
updated: 2026-10-18
referenced_by: [story-orchestrator, needs-and-requirements, verification-validation, test-first]
---

# Behaviour first and test first (§11)

## Contents

- Two disciplines (§11.1)
- Gherkin conventions (§11.2)
- One criterion, two artefacts (§11.3)
- Story ordering (§11.4)
- The test-first judgement and its record (§11.5)
- The cycle (§11.6, §11.7)
- Scenario automation (§11.8)
- Gates, self-bypass and limits (§11.9 to §11.11)
- Out of scope (§11.13)
- See also

Section 11 of the methodology specification sets two disciplines that run through every workflow stage of §4 to §7, and through any implementation work kept in the project repository (§11.1). This page summarises the section and cites the subsection behind every claim. The section itself is the authority.

## Two disciplines (§11.1)

- Behaviour first "for every story at every profile". Behaviour-driven development (BDD) describes the behaviour a stakeholder expects as concrete example scenarios before anyone designs or builds it. Every acceptance criterion of a User Story is a Gherkin scenario, Gherkin being the plain-text Given/When/Then format that Cucumber-family test tools read and run. A story's scenarios live in one `.feature` file beside the story and are written before design or code.
- Test first "wherever a test harness is viable". Test-driven development (TDD) writes a failing automated test before the code that makes it pass, and a test harness is the tooling that runs those tests and reports pass or fail.
- "Scenarios are always written. A runner executes them only where test first applies". Elsewhere they remain the acceptance criteria that verification and validation cases verify.
- Construction stays out of scope (§0.9, §9.2). The section adds a discipline for whatever implementation code the repository holds.
- The four gates "block at every profile, and only a recorded override lowers one" (§11.9). A profile is the project's tailoring tier, light, standard or full.

## Gherkin conventions (§11.2)

- A story's feature file, `<StoryIdentifier>.feature`, sits in the directory of the `.sysml` file that declares the story, under a `stories/` directory. A file whose name begins with `_` is a template and is not checked (§11.2.1).
- The file holds one Feature, may open with `# language: en`, and the Feature carries exactly one tag, `@<StoryIdentifier>`. A tag is a word starting with `@` on the line above a Gherkin keyword (§11.2.2).
- The narrative lines come in order: `As a <role>`, `I want <capability>`, `So that <benefit>`. "As a" or "As an" and "I want" or "I want to" may vary, the role compares case-insensitively with spaces removed against the part definition that types the story's role, and the capability and benefit "must otherwise equal the SysML strings with whitespace normalised" (§11.2.2).
- Each scenario carries exactly one `@AC_<name>` tag. The name is lowerCamelCase (words run together with each word after the first capitalised, starting in lower case) and unique within the Feature. An Outline states one criterion, however many rows its Examples hold (§11.2.3).
- The permitted elements are Feature, Rule (which states no criterion of its own), Background, Scenario or Example, Scenario Outline or Scenario Template with Examples or Scenarios, the steps, doc strings, data tables, tags and full-line comments. Steps follow the order `Given* When+ Then+`, that is, zero or more Given steps, then one or more When steps, then one or more Then steps (§11.2.4).
- "Feature" has three meanings: a Gherkin Feature (one story's feature file), the library's `Feature` requirement definition above a User Story, and a SysML feature (any member of a definition or usage) (§11.2.5).

## One criterion, two artefacts (§11.3)

- Each `@AC_<name>` tag maps to exactly one `requirement <name>` nested in the story's `requirement :>> acceptance`, and each nested criterion maps back to exactly one tag. "The scenario is the normative statement of the criterion", and the criterion's `doc` restates it in prose so that the model reads on its own (§11.3.1).
- Three forms are not used: the sibling form `requirement <name> :> acceptance`, a typed criterion, and acceptance prose placed directly in `requirement :>> acceptance` outside any named criterion. The last is the form used before plugin version 5.0.0, and a story still in it is migrated when it is next changed (§11.3.1).
- A verification or validation case reaches a criterion through its objective (§11.3.3):

  | Clause | Criteria it reaches |
  |---|---|
  | `verify <story>` | Every criterion of the story |
  | `verify <story>.acceptance` | Every criterion of the story |
  | `verify <story>.acceptance.<name>` | The criterion `<name>` only |

- "The narrowest form is preferred" when different cases verify different criteria. The path uses dot notation, and the reference implementations refuse the `::` form (§11.3.3, §5.4.6).

## Story ordering (§11.4)

Each row includes the rows above it.

| `StoryMeta.status` | Required before the story may hold the status |
|---|---|
| `backlog` | `<ID>.feature` exists, with the story tag and the narrative. Zero scenarios are allowed. |
| `ready` | At least one tagged scenario, each mirrored by a named criterion. |
| `inProgress`, `done` | Every criterion is reached by at least one verification or validation case. "A stub, holding the subject and the objective with the body still to come, is enough." |

Four consequences follow (§11.4).

1. The order of work for a new story is the feature file with its narrative and the scenarios known so far, then the story's SysML with a named criterion for each scenario, then the case stubs when the story moves to `inProgress`, and only then elaboration, analysis and design. A story branch opens its story at `inProgress` (§8.5.1), so the opening commit carries all three.
2. "Design never precedes behaviour." A `satisfy` for a story that has no scenarios "is a finding".
3. A change to a story starts with its feature file. A new or changed scenario is written before the criterion that mirrors it.
4. Repository state follows the same table (§8.7). A `backlog` story that already exists as a file carries its feature file like any other.

## The test-first judgement and its record (§11.5)

- Whether test first applies is judged once per project, recorded, and revisited when the project's tooling changes. "Viable means mandatory" (§11.5.1).
- Detection starts from the evidence of test tooling in the repository, such as a pytest configuration, `Cargo.toml` or a `tests/` directory. "Detection informs the judgement. It does not make it." (§11.5.1)
- Three kinds of file need an explicit call. Shell scripts are viable with Bats or a test script run against fixtures, when the project accepts that dependency. SysML models are "Not viable", because no execution runtime runs a model as a test, so they follow the model-tier test first of §11.4. Continuous integration (CI) configuration is usually not viable to test directly (§11.5.1).
- A project with no implementation code records `applies: false`, and the plugin's demo project is the example (§11.5.1).
- The `test_first` block of `.iso-config.yaml` holds `applies`, `rationale`, `test_command`, the optional `scenario_command`, `code_paths`, `test_paths` and `refactor_branches` (absent means `[refactor/*]`). `applies: true` requires `code_paths`, `test_paths` and `test_command` (§11.5.2).
- A glob is a file-name pattern such as `src/*`, and its `*` "matches any characters, including `/`". A path that matches `test_paths` is test code even when `code_paths` also matches it. Some paths are never code: every `.iso-config.yaml`, every `*.feature` file, and `docs/generated/`, `tools/render/` and `tools/lint/` under the engineering root (§11.5.2).
- The judgement is recorded in four places: `.iso-config.yaml`, a `Test-first:` line in the plugin-managed block of the project's `CLAUDE.md`, the engineering tools of `docs/semp.md` when that file exists, and a line in the tailoring record of `docs/project-plan.md`. `/vse-test-first` makes the judgement with the engineer and writes all four (§11.5.3).

## The cycle (§11.6, §11.7)

- When a test-driven development skill such as `superpowers:test-driven-development` is among the agent's available skills, the agent invokes it before writing code and the skill governs the mechanics of the red-green-refactor cycle (a failing test, then the least code that passes it, then a tidy-up). Three adjustments apply: its exceptions are already answered by the recorded judgement, human work is kept (deleting it needs the engineer's explicit confirmation), and prose stays exempt. On any other difference, the section wins (§11.6).
- Otherwise the fallback cycle runs in five steps (§11.7). Red: one test, watched failing for the expected reason, with the failing command and its first failing lines kept as the red evidence that the pull request's "Test-first evidence" section reproduces (§8.6.1). Green: the minimal code, then `test_command` with every test passing. Refactor: structure improved with the tests unchanged, and a pure refactoring on a branch that matches `refactor_branches`. Legacy code: characterisation tests first, that is, tests that pin down what the code does today. Exceptions: recorded in the tailoring record with the reason, and never lowering a gate by themselves.
- Where `scenario_command` is recorded, the scenarios form an outer loop. The scenario for a criterion runs and fails first, then inner red-green-refactor cycles build the code until it passes (§11.7).
- [[tdd-red-green-refactor]] gives the cycle in full.

## Scenario automation (§11.8)

- Scenarios are executed only where test first applies. Where the project's language has a Cucumber-family runner (Cucumber for the JVM and for JavaScript, behave or pytest-bdd for Python, Reqnroll for .NET, Godog for Go, among others), the project wires its feature files to it.
- The runner reads the feature files where they live, with no copy kept elsewhere. Step definitions, the code that binds each step's text to an action or an assertion, are test code covered by `test_paths` and written before the code they exercise.
- The runner runs in its strict mode, so that an undefined or pending step fails instead of passing silently. `scenario_command` runs in CI on every pull request, beside `test_command`.
- Scenarios no machine can exercise are reached by a validation case and skipped through a tag the project chooses, such as `@manual`.
- Where test first does not apply, no runner is wired. The scenarios are still the acceptance criteria.

## Gates, self-bypass and limits (§11.9 to §11.11)

Each gate blocks at light, standard and full by default, and only a recorded `gate_overrides` entry lowers one (§11.9).

| Gate | Configuration key | Carrier |
|---|---|---|
| Gherkin conformance | `precommit_gherkin` | `pre-commit` and CI |
| Test before code | `precommit_test_first` | `pre-commit` and CI |
| Gherkin first in session | `pretooluse_gherkin_first` | Claude Code `PreToolUse` |
| Test first in session | `pretooluse_test_first` | Claude Code `PreToolUse` |

- The story lint, `tools/lint/story-wellformed.py`, accepts `--only wellformed`, `--only gherkin` or `--only syntax` and exits 0 when clean, 1 on findings and 2 on a usage or environment error. Findings S1 to S9 concern the story and its model, for example S1 for a story with no feature file and S8 for a breach of the §11.4 ordering. Findings F1 to F10 concern the feature file, for example F2 for a language other than English and F8 for the step order (§11.9.1).
- `PreToolUse` is the Claude Code hook that runs before each agent tool call. Gherkin first denies an edit that adds or changes a story whose `<dir>/<ID>.feature` is missing or lacks `@<ID>`. Where `test_first.applies` is `true`, test first denies a write to a code path with no test evidence, that is, no test path changed in the working tree or on the branch since its merge base (the commit the branch started from). An edit that changes `gate_overrides` or `test_first` asks the human to confirm (§11.9.3).
- The four dispositions: `block` denies the call with the finding as the reason, `warn` proceeds with the finding added to the agent's context, `info` proceeds with one line added, and `off` does not run the gate (§11.9.3).
- An agent never lowers a gate without an explicit request from a human. Without one, it does not change `gate_overrides` or the `test_first` block, write a denied file by a route the in-session gates cannot see, set a story's status beyond what its feature file and cases support, or delete or weaken a test so that code passes (§11.10).
- The in-session gates guide an agent and guarantee nothing on their own. Writes through the Bash tool pass unseen, hooks can be switched off, the hook lets a call through with a notice when neither `jq` (a command-line JSON processor) nor `python3` is available, and work outside Claude Code meets no in-session gate. "The commit-time gates and continuous integration are the backstop." (§11.11)

## Out of scope (§11.13)

- The choice of test framework, scenario runner and programming language, which §11.5 records.
- Coverage thresholds, mutation testing, and performance or load testing.
- Patterns for writing step definitions and for organising test code.
- Executing scenarios that no runner can exercise.
- Construction itself beyond the test-first discipline, and product delivery.
- Gherkin in languages other than English.

## See also

- [[user-story-canonical-artefact]] for the story and its named acceptance criteria.
- [[storymeta-lifecycle]] for the four statuses the ordering table gates.
- [[story-branch-pr-workflow]] for the opening commit and the Test-first evidence section of the pull request.
- [[methodology-overview]] for the methodology as a whole.
- [[tooling-reference-implementation-rules]] for the deep verify the validators accept.
- [[gherkin-syntax-reference]] and [[gherkin-tags-and-tag-expressions]] for the Gherkin the conventions narrow.
- [[tdd-red-green-refactor]] for the cycle in full.
- [[bdd-three-practices]] for the BDD practices the section builds on.
