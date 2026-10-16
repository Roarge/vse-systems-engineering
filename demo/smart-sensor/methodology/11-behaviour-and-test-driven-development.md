# 11. Behaviour-Driven and Test-Driven Development

## 11.1 Purpose and scope

This section specifies two disciplines that run through every workflow
stage of §4 to §7, and through any implementation work kept in the
project repository.

1. **Behaviour first, for every story at every profile.**
   Behaviour-driven development (BDD) describes the behaviour a
   stakeholder expects as concrete example scenarios before anyone
   designs or builds it. In this methodology every acceptance criterion
   of a User Story (§1.4.4) is a Gherkin scenario. Gherkin is the
   plain-text Given/When/Then format that Cucumber-family test tools
   read and run. A story's scenarios live in one `.feature` file beside
   the story, and they are written before design or code.
2. **Test first, wherever a test harness is viable.** Test-driven
   development (TDD) writes a failing automated test before the code
   that makes it pass. A test harness is the tooling that runs those
   tests and reports pass or fail. Where a harness can test the
   project's code, test first is mandatory. Where it cannot, the
   judgement and its reason are recorded (§11.5).

Scenarios are always written. A runner executes them only where test
first applies (§11.8). Elsewhere they remain the acceptance criteria
that verification and validation cases verify, and executing those
cases is the project-determined activity of §4.8 and §5.7.

This section does not bring construction into the methodology's scope.
Detailed design and construction stay out of scope (§0.9, §9.2). What
§11 adds is a discipline for whatever implementation code the
repository holds, so that code arrives with its tests and stories
arrive with their scenarios.

The four gates that enforce the two disciplines block at every profile,
and only a recorded override lowers one (§11.9). They are the default
floor that §0.10.1 describes, not a profile-scaled choice.

## 11.2 Gherkin conventions

### 11.2.1 Placement and naming

A story's feature file is named `<StoryIdentifier>.feature` and sits in
the directory of the `.sysml` file that declares the story. The story
identifier matches `^[A-Za-z_][A-Za-z0-9_]*$` and equals the file stem,
so the story `US_001_SeeReadingsOnDashboard` is described by
`US_001_SeeReadingsOnDashboard.feature`. A register file that declares
several stories therefore has several feature files beside it, one per
story.

Feature files lie under a `stories/` directory, at system scope or at
component scope (§8.3). A file whose name begins with `_` is a template
and is not checked.

### 11.2.2 The Feature and its narrative

A feature file holds exactly one Feature. It may open with the header
`# language: en`. Any other language is an error, because the tooling
recognises the English keywords only.

The Feature carries exactly one tag, `@<StoryIdentifier>`. A tag is a
word starting with `@` on the line above a Gherkin keyword, and tools
use tags to select and link scenarios.

The Feature description opens with the story's three narrative lines,
in this order:

```gherkin
  As a <role>
  I want <capability>
  So that <benefit>
```

`<role>` is the name of the part definition that types the story's
role (§1.4.1), without any package qualifier. `<capability>` and
`<benefit>` are the story's `capability` and `benefit` strings (§1.4.2,
§1.4.3). The tooling compares the three lines with the SysML story
after normalising whitespace, so the narrative cannot drift from the
model. The opening words `As a`, `I want` and `So that` are fixed, so
`As an` or `I want to` is a mismatch. Further description lines may
follow the three.

### 11.2.3 Scenarios and criterion names

A scenario is one concrete example of the behaviour, written as steps.
Each scenario (a Scenario, Example, Scenario Outline or Scenario
Template) carries exactly one `@AC_<name>` tag, where `<name>` is the
name of the acceptance criterion the scenario states. A scenario may
carry further tags that do not begin with `@AC_`, such as a runner's
`@wip`.

A criterion name is lowerCamelCase, that is, words run together with
each word after the first capitalised, starting in lower case. It
matches `^[a-z][A-Za-z0-9]*$`, which is the convention the story members
already follow (for example `sla`), and it is unique within the
Feature. The scenario title is free text.

A Scenario Outline is a scenario template that runs once for each row
of its Examples table, with each `<placeholder>` in its steps replaced
by that row's value. An Outline states one criterion and carries one
`@AC_<name>` tag, however many rows its Examples hold.

### 11.2.4 Permitted elements and step order

| Element | Use |
|---|---|
| `Feature:` | One per file, describing one story |
| `Rule:` | Groups scenarios. A Rule states no criterion of its own |
| `Background:` | Given steps shared by the scenarios that follow. At most one per Feature and one per Rule, placed before the first scenario at its level |
| `Scenario:` or `Example:` | One acceptance criterion |
| `Scenario Outline:` or `Scenario Template:`, with `Examples:` or `Scenarios:` | One acceptance criterion, run once per example row |
| `Given`, `When`, `Then`, `And`, `But`, `*` | Steps. `And`, `But` and `*` continue the kind of the step before them |
| Doc strings and data tables | Step arguments. A doc string is a block between `"""` or three backticks, and a data table is a set of rows whose cells sit between vertical bars |
| Tags and full-line comments | Selection, linkage and notes. A comment line starts with `#` |

Steps follow the order `Given* When+ Then+`. That is, zero or more
Given steps (the context), then one or more When steps (the action),
then one or more Then steps (the expected outcome). A scenario without
a When step or without a Then step is incomplete. A Background holds
Given steps only. In a Scenario Outline every placeholder appears in
the header of every Examples table, and every Examples table has a
header and at least one row.

### 11.2.5 Three meanings of "feature"

The word "feature" carries three unrelated meanings in this
methodology, and the tooling keeps them apart.

- A **Gherkin Feature** is one story's feature file, as specified in
  this section.
- The library's **`Feature` requirement definition** (§1.3) is
  coarser-grained stakeholder intent above a User Story, connected
  down to stories by `derive`. It has no feature file.
- A **SysML feature** is any member of a definition or usage, such as
  an attribute, a port or a nested requirement.

## 11.3 Story-to-feature mapping and coverage

### 11.3.1 One criterion, two artefacts

Each scenario tag `@AC_<name>` maps to exactly one named requirement
usage nested inside the story's redefinition of `acceptance`, and each
nested criterion maps back to exactly one scenario tag:

```sysml
requirement :>> acceptance {
    requirement <name> { doc /* ... */ }
}
```

The scenario is the normative statement of the criterion. The nested
requirement is its anchor in the model, which `verify` clauses and the
traceability tooling address by name. The criterion's `doc` restates
the scenario in prose, so that the model reads on its own.

Three forms are not used.

- The sibling form `requirement <name> :> acceptance` declares the
  criterion beside the redefinition rather than inside it.
- A typed criterion (`requirement <name> : SomeDefinition`) brings in a
  definition the story does not own.
- Acceptance prose placed directly in `requirement :>> acceptance`,
  outside any named criterion, is the form used before plugin version
  5.0.0. A story still in that form is migrated when it is next
  changed, by formalising its existing Given/When/Then text as
  scenarios and named criteria without adding behaviour.

### 11.3.2 Worked example

The demo stakeholder story `US_001_SeeReadingsOnDashboard` has one
criterion. Its feature file,
`model/core/stories/stakeholder/US_001_SeeReadingsOnDashboard.feature`,
reads:

```gherkin
# language: en
@US_001_SeeReadingsOnDashboard
Feature: See readings on the dashboard
  As a Operator
  I want see live temperature and humidity readings on a dashboard
  So that deployment-site conditions are visible without on-site visits

  @AC_latestReadingShown
  Scenario: The latest reading appears within 5 seconds of arrival
    Given the device is online and reporting
    When the operator opens the dashboard
    Then the latest reading is displayed within 5 seconds of arrival at the cloud broker
```

The story in `stakeholder-stories.sysml`, in the same directory,
mirrors the tag with a nested criterion of the same name:

```sysml
requirement US_001_SeeReadingsOnDashboard : UserStory {
    @StoryMeta { points = 5; priority = Priority::high; status = StoryStatus::ready; }

    subject :>> system : SmartSensor_System;
    stakeholder :>> role : Operator;

    attribute :>> capability = "see live temperature and humidity readings on a dashboard";
    attribute :>> benefit    = "deployment-site conditions are visible without on-site visits";

    frame concern : StableMonitoring;

    requirement :>> acceptance {
        requirement latestReadingShown {
            doc /* Given the device is online and reporting,
                   when the operator opens the dashboard,
                   then the latest reading is displayed within 5 seconds
                   of arrival at the cloud broker. */
        }
    }
}
```

The demo's validation case reaches the criterion by its full path. The
story is `ready`, so the case is not yet required, but it must exist
before the story moves to `inProgress` (§11.4):

```sysml
verification def VAL_001_OperatorSeeReadings {
    subject system : SmartSensor_System;

    objective {
        verify US_001_SeeReadingsOnDashboard.acceptance.latestReadingShown;
    }
}
```

### 11.3.3 Coverage rule

A verification or validation case reaches a criterion when its
objective holds one of these clauses:

| Clause | Criteria it reaches |
|---|---|
| `verify <story>` | Every criterion of the story |
| `verify <story>.acceptance` | Every criterion of the story |
| `verify <story>.acceptance.<name>` | The criterion `<name>` only |

The narrowest form is preferred when different cases verify different
criteria, because the traceability matrix then shows which case
verifies which scenario. The path uses dot notation. The `::` namespace
form addresses a definition member, and the reference implementations
refuse it (§5.4.6).

## 11.4 Story ordering

Behaviour comes before design, and the model-tier test comes before
design too. A story's status (`StoryMeta.status`, §1.5) decides what
must already exist. Each row includes the rows above it.

| `StoryMeta.status` | Required before the story may hold the status |
|---|---|
| `backlog` | `<ID>.feature` exists, with the story tag and the narrative. Zero scenarios are allowed. |
| `ready` | At least one tagged scenario, each mirrored by a named criterion (§11.3). This replaces the prose form of §1.9 rule 4. |
| `inProgress`, `done` | Every criterion is reached by at least one verification or validation case (§11.3.3). A stub, holding the subject and the objective with the body still to come, is enough. This is test first at the model tier. |

Four consequences follow.

1. **The order of work for a new story** is: write the feature file
   with its narrative and the scenarios known so far, write the
   story's SysML with a named criterion for each scenario, add the
   case stubs when the story moves to `inProgress`, and only then
   elaborate, analyse and design. A story branch opens its story
   directly at `inProgress` (§8.5.1), so its opening commit carries
   the feature file, the story and the case stubs together.
2. **Design never precedes behaviour.** A `satisfy <story> by
   <element>` relationship for a story that has no scenarios is a
   finding, because it allocates a design element to behaviour nobody
   has described yet.
3. **A change to a story starts with its feature file.** A new or
   changed scenario is written before the criterion that mirrors it.
4. **Repository state follows the same table.** §8.7 maps each status
   to branch and pull-request state. A `backlog` story that already
   exists as a file carries its feature file like any other.

## 11.5 Test-first applicability

### 11.5.1 The judgement

Whether test first applies is a judgement made once per project,
recorded, and revisited when the project's tooling changes. The
judgement is a yes or a no for the project as a whole, plus the list of
paths that count as code. Viable means mandatory: when a harness can
test a kind of code, that code is written test first.

Detection starts from the evidence of test tooling in the repository.

| Evidence | Tooling it suggests |
|---|---|
| A pytest configuration | pytest |
| A `test` script in `package.json`, or a Jest or Vitest configuration | npm test, Jest, Vitest |
| `Cargo.toml` | cargo test |
| `go.mod` | go test |
| A Maven or Gradle project with a `src/test/` tree | JUnit-style tests |
| A CMake project with CTest enabled | CTest |
| A `test:` target in a `Makefile` | make test |
| A `tests/` or `spec/` directory | A project test suite |
| A behave or Cucumber configuration | A Cucumber-family scenario runner |
| `*.bats` files | Bats (Bash Automated Testing System) |

Detection informs the judgement. It does not make it. Three kinds of
file need an explicit call, recorded in the rationale.

- **Shell scripts.** Testable with Bats, or with a test script that
  runs them against fixtures. Viable when the project accepts that
  dependency.
- **SysML models.** Not viable, because no execution runtime runs a
  model as a test. Models follow the model-tier test first of §11.4
  instead, and they are not listed as code.
- **Continuous integration configuration**, such as GitHub Actions
  YAML. Usually not viable to test directly. The usual check is that
  every CI step runs a command the project can also run locally.

A project with no implementation code records `applies: false` with a
rationale that says so. The plugin's demo project is an example. It
holds models and documents only, and its vendored tools are tested
where they are maintained.

### 11.5.2 The configuration record

The judgement lives in a `test_first` block of `.iso-config.yaml` at
the engineering root:

```yaml
test_first:
  applies: true
  rationale: "pytest under tests/. bash scripts: bats viable. SysML: not viable, no execution runtime."
  test_command: "pytest -q"
  scenario_command: "behave model/core/stories"
  code_paths: [src/*, scripts/*.sh]
  test_paths: [tests/*]
  refactor_branches: [refactor/*]
```

| Key | Meaning |
|---|---|
| `applies` | `true` or `false`, the judgement of §11.5.1 |
| `rationale` | One line naming the harness and the call made for each kind of file in §11.5.1 |
| `test_command` | The command that runs the project's tests |
| `scenario_command` | Optional. The command that runs the feature files on a Cucumber-family runner (§11.8) |
| `code_paths` | Globs for implementation code, relative to the top-level directory of the git repository |
| `test_paths` | Globs for test code, relative to the same directory |
| `refactor_branches` | Globs for branches that restructure code without changing behaviour. Absent means `[refactor/*]` |

`applies: true` requires `code_paths`, `test_paths` and
`test_command`. A glob is a file-name pattern such as `src/*`, and a
`*` in one matches any characters, including `/`. A path that matches a
`test_paths` glob is test code even when a `code_paths` glob also
matches it, and a path that matches neither is not watched. Some paths
are never code, whatever the globs say: the configuration file itself,
every `*.feature` file, and the generated documents and vendored tools
under the engineering root (`docs/generated/`, `tools/render/` and
`tools/lint/`).

Only `code_paths` decides what the test-first gates watch. The
edge-case judgement therefore lives in that list and in the rationale,
not in a fixed list inside the tooling.

### 11.5.3 The four-place record

The judgement is recorded in four places, so that the configuration,
the agent's instructions, the engineering plan and the tailoring
history agree.

1. `.iso-config.yaml`: the `test_first` block of §11.5.2.
2. The project's `CLAUDE.md`, inside the block the plugin manages: a
   `Test-first:` line among the project facts, stating whether test
   first applies and naming the test command.
3. `docs/semp.md`, when the file exists: the test harness and any
   scenario runner among the engineering tools (§10.3.2).
4. `docs/project-plan.md`: a line in the tailoring record (§0.10.2),
   for example `Test-first: applies, pytest (recorded 2026-10-16).` or
   `Test-first: not applicable, no implementation code (recorded
   2026-10-16).` Earlier lines stay, so the history remains readable.

The `/vse-test-first` command makes the judgement with the engineer and
writes the four records. A single change exempted from test first
(§11.7) is recorded in the same tailoring record.

## 11.6 Precedence of an installed test-driven development skill

An agent may have a dedicated test-driven development skill installed.
The reference case is `superpowers:test-driven-development`, a skill
from the superpowers plugin for Claude Code. It drives the
red-green-refactor cycle of §11.7 (a failing test, then the least code
that passes it, then a tidy-up) with strict rules. When such a skill is
listed among the agent's available skills, the agent invokes it before
writing code, and the skill governs the mechanics of the cycle. This
section adjusts it in three places.

1. **Its exceptions are already answered.** The skill asks the human
   partner before applying TDD to some kinds of work. For this project
   the recorded judgement of §11.5 is that answer. The agent does not
   stop to ask again about a case the record covers, and it does ask
   when the record is silent.
2. **Human work is kept.** The skill's instruction to delete code
   written before its test and start over becomes: stop, write the
   failing test, and keep human-authored artefacts. Deleting
   human-authored work needs the engineer's explicit confirmation,
   because it is a destructive action under the explicit-request
   discipline of §2.6 rule 7.
3. **Prose stays exempt.** Methodology text, documentation, skill files
   and Markdown templates are prose, not code. Neither the cycle nor
   the companion skill-writing discipline, which pressure-tests skill
   files, applies to them.

On any other point where the skill and this section differ, this
section wins for the project, as the methodology does over every other
source. When no such skill is available, the agent follows the fallback
cycle of §11.7.

## 11.7 The fallback red-green-refactor cycle

Red-green-refactor is the TDD loop: a failing test (red), the least
code that makes it pass (green), then a tidy-up with the tests
unchanged (refactor). When no test-driven development skill is
installed, the cycle runs as follows.

1. **Red.** Write one test for the next small piece of behaviour. Run
   it and watch it fail for the expected reason, that is, a failed
   assertion about the missing behaviour rather than a typo or an
   import error. Keep the failing command and its first failing lines.
   They are the red evidence that the pull request's "Test-first
   evidence" section reproduces (§8.6.1).
2. **Green.** Write the minimal code that makes the test pass. Run
   `test_command` and see every test pass.
3. **Refactor.** Improve the structure of the new code with the tests
   unchanged, running them again after each step. A pure refactoring,
   with no change of behaviour, belongs on a branch that matches
   `refactor_branches`.
4. **Legacy code.** Before changing code that has no tests, first write
   characterisation tests, that is, tests that pin down what the code
   does today, and see them pass. Then change the code test first.
5. **Exceptions.** A change that genuinely cannot be written test
   first, for example generated code or an emergency production fix,
   is recorded in the tailoring record with its reason. The test
   follows as soon as it can be written. An exception never lowers a
   gate by itself (§11.10).

Where `scenario_command` is recorded, the scenarios form an outer loop
around this cycle. The scenario for a criterion runs and fails first,
then inner red-green-refactor cycles build the code until it passes.

## 11.8 Scenario automation

Gherkin scenarios are executed only where test first applies. Where
the project's language has a Cucumber-family runner (Cucumber for the
JVM and for JavaScript, behave or pytest-bdd for Python, Reqnroll for
.NET, Godog for Go, among others), the project wires its feature files
to that runner.

1. The runner reads the feature files where they live, beside the
   stories. No copy is kept elsewhere, because a copy would drift.
2. Step definitions, the code that binds each step's text to an action
   or an assertion, are test code. Their location is covered by
   `test_paths`, and they are written before the code they exercise.
3. The runner runs in its strict mode, so that an undefined step (one
   with no step definition) or a pending step (one marked as not yet
   written) fails instead of passing silently.
4. The command that runs the scenarios is recorded as
   `scenario_command` (§11.5.2). Continuous integration runs it on
   every pull request, beside `test_command` (hooks guide §4.4).

Some scenarios describe outcomes no machine can exercise, such as a
stakeholder's judgement during a field trial. A validation case
reaches them (§4.3.6), and the runner skips them through a tag the
project chooses, such as `@manual`.

Where test first does not apply, no runner is wired. The scenarios are
still the acceptance criteria, and the cases that reach them verify and
validate them.

## 11.9 Gates and dispositions

Four gates enforce this section. Each blocks at every profile by
default, and only a recorded `gate_overrides` entry lowers one
(§0.10.4, §11.10).

| Gate | Configuration key | Carrier | light | standard | full | What it checks |
|---|---|---|---|---|---|---|
| Gherkin conformance | `precommit_gherkin` | `pre-commit` and CI | block | block | block | The story lint findings S1 to S9 and F1 to F10 (§11.9.1) over every stories directory the change touches |
| Test before code | `precommit_test_first` | `pre-commit` and CI | block | block | block | A change to a code path with no change to a test path, either in the commit set or on the branch since its merge base (the commit the branch started from). While `test_first` is unrecorded, a finding only when test tooling is detected or code-like files change, and otherwise one info line suggesting `/vse-test-first` |
| Gherkin first in session | `pretooluse_gherkin_first` | Claude Code `PreToolUse` | block | block | block | An agent edit that adds or changes a story whose feature file is missing or lacks the story tag (§11.9.3) |
| Test first in session | `pretooluse_test_first` | Claude Code `PreToolUse` | block | block | block | An agent edit to a code path with no test evidence (§11.9.3) |

### 11.9.1 The story lint

The story lint ships as `tools/lint/story-wellformed.py` under the
engineering root:

```text
story-wellformed.py [--only wellformed|gherkin|syntax] [--format text|json] PATH...
```

`--only wellformed` runs the §1.9 checks of the
`precommit_story_wellformed` gate. `--only gherkin` runs the findings
below for `precommit_gherkin`. `--only syntax` checks feature files
without story context (F1, F2, F7, F8 and F9). Exit code 0 means clean,
1 means findings, and 2 means a usage or environment error. A missing
lint or a missing `python3` is itself reported at the gate's
disposition, so a broken install cannot pass quietly.

| Code | Finding |
|---|---|
| S1 | A story has no `<ID>.feature`, or the file lacks the `@<ID>` tag |
| S2 | More than one feature file describes the same story |
| S3 | Acceptance prose outside a named criterion, the form used before 5.0.0 (§11.3.1) |
| S4 | A named criterion has no matching `@AC_` tag |
| S5 | An `@AC_` tag has no matching named criterion |
| S6 | The narrative lines differ from the story's role, capability or benefit |
| S7 | A criterion in the sibling `:> acceptance` form, or a typed criterion |
| S8 | The story ordering of §11.4 is violated, including a `satisfy` for a story with no scenarios |
| S9 | A story declaration the lint cannot read, that is, a `UserStory` usage written other than as `requirement <ID> : UserStory` (optionally qualified as `VSE_Library::UserStory`) |
| F1 | The feature file does not parse |
| F2 | A `# language:` header other than `en` |
| F3 | The Feature does not carry exactly one tag, or the tag is not a valid story identifier |
| F4 | The file name differs from the story identifier in the tag |
| F5 | A scenario's `@AC_` tag is missing, repeated, or not lowerCamelCase |
| F6 | The narrative lines are missing or out of order |
| F7 | A Background is repeated, placed after a scenario, or holds a step other than Given |
| F8 | The steps break the order `Given* When+ Then+` |
| F9 | A Scenario Outline has no Examples, an Examples table lacks a header or rows, or a placeholder is missing from a header |
| F10 | The feature file is not under a `stories/` directory |

The `precommit_story_wellformed` gate keeps §1.9 rules 2, 3, 6 and 9
and the `storymeta` fields of §0.10.3. Rule 4, the acceptance rule,
belongs to `precommit_gherkin` as finding S8, so no finding carries two
dispositions.

### 11.9.2 Commit-time and CI gates

The `pre-commit` hook runs both commit-time gates on the staged set. In
continuous integration the same hook runs in range mode, over the
changes a pull request or a push brings, so that a fresh checkout with
nothing staged cannot pass vacuously. Range mode needs the full git
history (`fetch-depth: 0` in GitHub Actions).

For `precommit_test_first`, evidence is a changed path under
`test_paths`, in the commit set or on the branch since its merge base.
On a branch that matches `refactor_branches` the finding becomes a
reminder.

### 11.9.3 In-session gates

`PreToolUse` is the Claude Code hook that runs before each agent tool
call. It sees the file tools Edit, Write, MultiEdit and NotebookEdit,
and it may deny a call with a reason the agent reads. Both in-session
gates act only inside a project. The hook finds the project by walking
up from the edited file to the top of the git repository, looking for
`.iso-config.yaml` (and, at the top, `engineering/.iso-config.yaml`),
and it reads the dispositions from the file it finds.

**Gherkin first.** The gate watches `*/stories/*.sysml` files, skipping
templates (names that begin with `_`) and anything under `library/`. It
applies the proposed edit to the file first, then compares the stories
before and after. Only a story that the edit adds, or whose declaration
it changes, must have `<dir>/<ID>.feature` carrying `@<ID>`. Untouched
stories in the same register file that still lack feature files draw a
warning, not a denial, and deleting a story is never denied. The
denial names the expected path, the tag rule and this section. For a
story still in the pre-5.0.0 form it says to formalise the existing
Given/When/Then text first.

**Test first.** The gate applies when `test_first.applies` is `true`
and the file is inside a git repository. A write to a path classified
as code is denied unless test evidence exists. Evidence is a test path
that is new or modified in the working tree, or a test path changed on
the branch since its merge base. The merge base is taken against the
first of these that exists: each branch named literally in
`protected_branches`, the same branch on `origin`, then `origin/main`,
`main`, `origin/master` and `master`. A shallow clone (a checkout
without the full history), a detached HEAD (a checkout of a commit
rather than a branch) or a branch with no commits yet gives no branch
evidence, and the denial says so. On a refactor branch the finding
becomes a reminder.

**Configuration edits.** An edit to `.iso-config.yaml` that changes
`gate_overrides` or `test_first` is neither allowed nor denied by the
hook. It asks the human to confirm the edit (§11.10).

The four dispositions take this form in session:

| Disposition | Effect on the tool call |
|---|---|
| `block` | Denied, with the finding as the reason |
| `warn` | Proceeds, with the finding added to the agent's context |
| `info` | Proceeds, with one line added to the agent's context |
| `off` | The gate does not run |

The hook never answers with an explicit allow, so the engineer's own
permission settings still govern every call it lets through.

## 11.10 Self-bypass rule

An agent never lowers a gate without an explicit request from a human.
Without such a request, an agent does not:

- add or change a `gate_overrides` entry, or edit the `test_first`
  block, in `.iso-config.yaml`
- write a denied file through the Bash tool or any other route the
  in-session gates cannot see
- set a story's status beyond what its feature file and cases support
  (§11.4)
- delete or weaken a test so that code passes.

An agent answers a denial by doing what it asks: writing the feature
file, the scenario or the failing test. The `PreToolUse` hook asks the
human to confirm any edit that changes `gate_overrides` or
`test_first`. The project's CODEOWNERS file, which names the required
reviewers for each path, lists `.iso-config.yaml`, so a human owner
also reviews the change in the pull request.

A human may lower one of these gates. The override is a tailoring
decision, recorded with its reason in the tailoring record (§0.10.2).
A one-off bypass follows §0.10.6.

## 11.11 Enforcement limits

The in-session gates guide an agent. They guarantee nothing on their
own, and the methodology says so plainly (§0.10.6).

- **Unseen writes.** `PreToolUse` sees only the file tools it is
  registered for. A file written through the Bash tool, by a redirect,
  `sed -i` or a script, passes unseen.
- **Hooks switched off.** The `disableAllHooks` setting, a session
  started with the minimal `--bare` mode, or a disabled plugin switches
  every lifecycle hook off.
- **Fail-open paths.** Without `jq` (a command-line JSON processor) and
  without `python3` the hook cannot read its input. It then lets the
  call through with a notice, rather than blocking all work. A story
  declaration the hook cannot read is not gated in session, and the
  lint reports it as S9.
- **Work outside Claude Code.** An engineer editing in another tool
  meets no in-session gate at all.

The commit-time gates and continuous integration are the backstop. They
run the same checks on what is actually committed, whichever tool wrote
it. A project that needs the checks to be unbypassable runs them in CI
against a protected branch, as §0.10.6 describes.

## 11.12 Well-formedness rules

1. Every story has exactly one `<ID>.feature` in the directory of the
   file that declares it, carrying exactly one tag, `@<ID>`, and the
   story's narrative lines (§11.2.1, §11.2.2).
2. Every scenario carries exactly one `@AC_<name>` tag, with `<name>`
   in lowerCamelCase and unique within the Feature (§11.2.3).
3. Each `@AC_<name>` tag has exactly one matching `requirement <name>`
   nested inside the story's `requirement :>> acceptance`, and each
   nested criterion has exactly one matching tag (§11.3.1).
4. Criteria are nested and untyped. The sibling `:> acceptance` form,
   typed criteria and acceptance prose outside a named criterion are
   not used (§11.3.1).
5. Feature files use only the elements of §11.2.4, with steps in the
   order `Given* When+ Then+`.
6. A story meets the row of the §11.4 table for its status, and no
   `satisfy` names a story without scenarios.
7. `test_first` is recorded in the four places of §11.5.3. With
   `applies: true` it names `code_paths`, `test_paths` and
   `test_command`.
8. Where test first applies, a change to a code path arrives with a
   change to a test path on the same branch, except on a refactor
   branch (§11.7, §11.9).
9. Where an installed test-driven development skill is available, it
   governs the cycle as adjusted by §11.6. Otherwise the cycle of §11.7
   applies.
10. An agent never lowers a gate, edits `test_first`, or routes around
    a denial without an explicit human request (§11.10).

## 11.13 Out of scope

- The choice of test framework, scenario runner and programming
  language. These are project-determined, and §11.5 records the
  choice.
- Coverage thresholds, mutation testing, and performance or load
  testing.
- Patterns for writing step definitions and for organising test code.
- Executing scenarios that no runner can exercise. Their validation
  follows the project-determined activity of §4.8 and §5.7.
- Construction itself (SR.4 beyond the test-first discipline, §9.2) and
  product delivery (SR.6).
- Gherkin in languages other than English.

---

*End of Section 11.*
