---
name: test-first
description: Record whether test-first applies in a VSE project, wire Gherkin features to a scenario runner, or resolve a test-first gate denial.
when_to_use: Use on /vse-test-first, when the session banner says test_first.applies is not recorded or prints a Test-first nudge, when pre-commit or CI reports precommit_test_first, when a PreToolUse denial names pretooluse_test_first, when project-setup or attention-regime hands off the test-first question, when wiring behave, Cucumber, pytest-bdd, Reqnroll or Godog to the stories' feature files, or in a VSE project where test first applies and no superpowers:test-driven-development skill is available.
user-invocable: true
---

# Test First

If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first.

You are the skill that owns one recorded decision of a VSE project: whether test first applies (methodology §11.5). Test-driven development (TDD) writes a failing automated test before the code that makes it pass. A test harness is the tooling that runs those tests and reports pass or fail. The project records its judgement as the `test_first` block of `.iso-config.yaml`, and the two test-first gates read it: `precommit_test_first` at commit time and in continuous integration (CI, the checks that run on every push and pull request), and `pretooluse_test_first` before each agent edit (§11.9). Both watch the paths the record names as code. You also wire the stories' Gherkin feature files to a Cucumber-family scenario runner where test first applies (§11.8). Gherkin is the plain-text Given/When/Then format that Cucumber-family test tools read and run. Finally, you answer a test-first denial by doing what it asks.

This skill has read-write behaviour inside the project. It writes four records at the engineering root `<ENG_ROOT>`, the directory that holds `.iso-config.yaml` (Step 1): `<ENG_ROOT>/.iso-config.yaml`, the managed block of `<ENG_ROOT>/CLAUDE.md`, `<ENG_ROOT>/docs/semp.md` (the SEMP, Systems Engineering Management Plan) and `<ENG_ROOT>/docs/project-plan.md`. For runner wiring it also writes the runner's configuration, step definitions under the test paths and a set-up step in `.github/workflows/traceability-check.yml` at the git top level. Every write is shown before it is made. Software is installed only after a separate approval per step.

The methodology wins over this skill and over every external source. Consult the project-local `methodology/11-behaviour-and-test-driven-development.md` first, then `${CLAUDE_PLUGIN_ROOT}/methodology/11-behaviour-and-test-driven-development.md`.

## When This Skill Triggers

- The engineer runs `/vse-test-first`, or asks whether the project must work test first.
- The SessionStart banner says `test_first.applies is not recorded`, or prints a `Test-first nudge` naming detected tooling.
- The pre-commit hook or CI reports `precommit_test_first`, including "test_first is not recorded and test tooling was detected".
- A PreToolUse denial names `pretooluse_test_first`.
- `@project-setup` asks the test-first question after the toolchain question, or `@attention-regime` finds `test_first` unrecorded.
- `@project-audit` reports `test_first` as absent or incomplete.
- The engineer asks to run the stories' scenarios, or to wire a Cucumber-family runner to the feature files.
- The project's tooling changed (a harness added or removed), so the judgement needs revisiting (§11.5.1).

Arguments: `status` reports and stops. `revisit` makes the judgement again although one is recorded. `wire` goes straight to the runner wiring for a project where test first applies. No argument runs the whole workflow.

## Step 1: Read the Record

Locate `.iso-config.yaml` at the project root, then under `engineering/`. Its directory is `<ENG_ROOT>`, the engineering root. Take `<TOP>` from `git -C <ENG_ROOT> rev-parse --show-toplevel`. `<TOP>` is the directory that `code_paths` and `test_paths` are relative to, and in a brownfield project it lies above `<ENG_ROOT>`. If there is no `.iso-config.yaml`, hand off to `@project-setup`.

Every probe in this skill sources the libraries the hooks and CI use, so that all three read the record the same way. Read the record and the two gate dispositions:

```bash
cd "<TOP>" && VSE_ISO_CONFIG="<ENG_ROOT>/.iso-config.yaml" bash -c '
  . "$1" && . "$2" || exit 2
  printf "applies: %s\n" "$(vse_tf_applies)"
  for key in rationale test_command scenario_command; do
    printf "%s: %s\n" "$key" "$(iso_section_scalar test_first "$key")"
  done
  for key in code_paths test_paths refactor_branches; do
    printf "%s: %s\n" "$key" "$(iso_section_list test_first "$key" | paste -sd, -)"
  done
  for gate in precommit_test_first pretooluse_test_first; do
    printf "%s: %s\n" "$gate" "$(iso_gate_disposition "$gate")"
  done' _ "${CLAUDE_PLUGIN_ROOT}/hooks/lib/iso-profile.sh" "${CLAUDE_PLUGIN_ROOT}/hooks/lib/test-first.sh"
```

Read the result as follows.

- **`applies: true` with `code_paths`, `test_paths` and `test_command`.** The judgement is recorded. Report it and do not ask again. Continue to Step 2, so that a change of tooling shows.
- **`applies: true` with a required key missing.** The record is incomplete (§11.5.2, §11.12 rule 7). Without `code_paths` the gates watch nothing. Complete the missing keys with the engineer in Step 3.
- **`applies: false`.** The judgement is recorded and both test-first gates are silent. Gherkin first still applies to every story. Report the rationale and continue to Step 2.
- **Empty.** The judgement is unrecorded, or the value is not `true` or `false` (the library then names the value on stderr). Say what that means: the commit-time gate reports a finding at its disposition when it detects test tooling or a change to paths that `code_paths` or `test_paths` name, and otherwise prints one line asking for the record. The in-session test-first gate does not run.

A recorded judgement is not revisited without the argument `revisit` or the engineer's request.

## Step 2: Detection Report

Run the shared detection at the engineering root and, when it differs, at the git top level. The probe skips the second directory when it is the first:

```bash
cd "<TOP>" && VSE_ISO_CONFIG="<ENG_ROOT>/.iso-config.yaml" bash -c '
  . "$1" && . "$2" || exit 2
  set -- "$3" "$4"
  [ "$(cd "$1" && pwd -P)" = "$(cd "$2" && pwd -P)" ] && set -- "$1"
  for dir in "$@"; do
    printf "%s:\n" "$dir"
    vse_tf_detect "$dir" | sed "s/^/  /" || echo "  none"
  done' _ "${CLAUDE_PLUGIN_ROOT}/hooks/lib/iso-profile.sh" "${CLAUDE_PLUGIN_ROOT}/hooks/lib/test-first.sh" "<ENG_ROOT>" "<TOP>"
```

Each key is one row of this table, which mirrors `vse_tf_detect` in `hooks/lib/test-first.sh` and the table of §11.5.1. The SessionStart nudge and the commit-time gate run the same function.

| Key | Evidence | Tooling it suggests |
|---|---|---|
| `pytest` | `pytest.ini`, `conftest.py`, a `[tool.pytest` section in `pyproject.toml`, `[tool:pytest]` in `setup.cfg`, `[pytest]` in `tox.ini` | pytest |
| `npm-test` | A `test` script in `package.json`, other than an empty script or npm's "no test specified" placeholder | npm test |
| `jest` | `jest.config.*`, or a `jest` key in `package.json` | Jest |
| `vitest` | `vitest.config.*` | Vitest |
| `cargo` | `Cargo.toml` | cargo test |
| `go` | `go.mod` | go test |
| `maven` | `pom.xml` with a `src/test/` tree | JUnit-style tests |
| `gradle` | `build.gradle` or `build.gradle.kts` with a `src/test/` tree | JUnit-style tests |
| `ctest` | `enable_testing` or `add_test` in `CMakeLists.txt` | CTest |
| `make-test` | A `test:` target in the Makefile | make test |
| `tests-dir` | A `tests/` or `test/` directory | A project test suite |
| `spec-dir` | A `spec/` directory | A project test suite |
| `behave` | `behave.ini`, `.behaverc`, a `[behave]` section in `setup.cfg` or `tox.ini`, `[tool.behave]` in `pyproject.toml`, a `features/steps/` directory | behave, a Cucumber-family scenario runner |
| `cucumber` | `cucumber.js` and its variants, `cucumber.yml`, `config/cucumber.yml`, `src/test/resources/cucumber.properties`, a `features/step_definitions/` directory | Cucumber |
| `bats` | A `*.bats` file up to three levels down | Bats (Bash Automated Testing System) |

Then show where implementation code lives: the tracked files under `<TOP>` (`git -C <TOP> ls-files`) grouped by top-level directory and file extension. Leave out what is never code or not the project's own: `.iso-config.yaml`, `*.feature`, `model/`, `methodology/`, and `docs/generated/`, `tools/render/` and `tools/lint/` under the engineering root, plus `.githooks/`, which holds the plugin's installed hook copies.

With the argument `status`, stop after the report.

For a complete recorded judgement without the argument `revisit`, compare the report with the rationale. When they agree, go to Step 6. When tooling appears that the rationale does not name, or a harness it names has gone, say so and offer to revisit the judgement (§11.5.1).

## Step 3: The Judgement

Detection informs the judgement. It does not make it (§11.5.1). **Viable means mandatory**: where a harness can test a kind of code, that code is written test first. So the question to the engineer is not whether they want TDD but whether a harness can test this code. Ask once, presenting a proposal for every key of §11.5.2:

- `applies`: `true` or `false`.
- `rationale`: one line naming the harness and the call made for each kind of file below.
- `test_command`: one command that runs the whole suite from `<TOP>` and exits non-zero when a test fails.
- `scenario_command`: optional, see "Wiring the Scenarios to a Runner".
- `code_paths` and `test_paths`: globs relative to `<TOP>`. A glob is a file-name pattern such as `src/*`, and here a `*` matches any characters, `/` included. A path that matches a `test_paths` glob is test code even when a `code_paths` glob also matches it, and a path that matches neither is not watched.
- `refactor_branches`: globs for branches that restructure code without changing behaviour. Absent means `[refactor/*]`.

`applies: true` requires `code_paths`, `test_paths` and `test_command`. Only `code_paths` decides what the gates watch, so each edge-case call lands in that list and in the rationale:

- **Shell scripts.** Testable with Bats, or with a test script that runs them against fixtures. Viable when the project accepts that dependency. List them in `code_paths` and name the harness, or say in the rationale that the dependency was declined.
- **SysML models.** Not viable, because no execution runtime runs a model as a test. Models follow the model-tier test first of §11.4 (every criterion reached by a case before the story is `inProgress`), which `@story-orchestrator` drives. Never list them as code.
- **Continuous integration configuration.** Usually not viable to test directly. The usual check is that every CI step runs a command the project can also run locally. Not listed as code.
- **No implementation code.** Record `applies: false` with a rationale that says so. The plugin's demo is the example: models and documents only, with vendored tools tested where they are maintained.
- **Code without a harness yet.** Still viable when a harness can be added, so propose one and record `applies: true`. For Python, the standard-library `unittest` adds no dependency. A missing harness is not a reason for `false`.
- **Tooling with no code behind it.** A `tests/` directory of test reports, or a `test:` target that runs the SysML validator, is not a harness for code. Say so in the rationale.
- **Code that needs hardware.** Logic compiled and tested on the workstation is viable. A layer that only runs on the target usually is not. List the host-testable paths and name the rest in the rationale.
- **Generated and vendored code.** List the generator and its templates, not its output. Vendored third-party code is tested where it is maintained and is not listed. A one-off change that cannot be written test first is an exception of §11.7, recorded on its own tailoring line.

**No default is forced.** If the engineer declines to decide, do not write the block. Say what an unrecorded judgement means (Step 1) and stop after the report.

**Only the engineer changes the record (§11.10).** The command `/vse-test-first`, a hand-off the engineer accepted, or the engineer's answer to the question above is the explicit request that §11.10 requires. A denial is never such a request. Narrowing `code_paths` or setting `applies: false` to get past a denial is the self-bypass that §11.10 forbids. The PreToolUse hook asks the human to confirm every edit that changes `test_first`, so expect that prompt and leave the answer to the engineer.

## Step 4: Record the Judgement

Four writes (§11.5.3), each at `<ENG_ROOT>` and shown before it is made:

1. **`<ENG_ROOT>/.iso-config.yaml`**: the `test_first` block of §11.5.2, two-space indented under `test_first:`, with lists in brackets and quotes around any value that holds `#` or `:`. Replace the shipped commented block (`# test_first:` and the commented keys below it), keeping the explanatory comment above it. Without either, add the block after `gate_overrides` or its commented form. With `applies: false`, write `applies` and `rationale` only, because nothing reads the commands or the globs while test first does not apply.
2. **`<ENG_ROOT>/CLAUDE.md`**, inside the managed block between `<!-- BEGIN VSE COMPANION (managed by project-setup) -->` and `<!-- END VSE COMPANION -->` only: set the `- **Test-first:**` line in the Project facts list, inserting it after the Toolchain line (or the Profile line) when absent. The value states whether test first applies and names the test command, for example "applies, test command `pytest -q`" or "not applicable, no implementation code". Keep the gloss in parentheses that the template ships after the value. Never edit outside the markers.
3. **`<ENG_ROOT>/docs/semp.md`**, when the file exists: the Development Tools row whose Purpose cell begins `Test-first tools:`. The Tool cell names the test harness and any scenario runner, and the Version cell the versions they report. Where test first does not apply, the Tool cell reads `none`. Insert the row after the SysML modelling row when it is absent. Methodology §10.3.2 obliges the SEMP to record the engineering tools.
4. **`<ENG_ROOT>/docs/project-plan.md`**, tailoring record: append `Test-first: applies, <harness> (recorded <date>).` or `Test-first: not applicable, <reason> (recorded <date>).`, keeping the earlier lines so the history stays readable (§0.10.2).

A line or cell that still carries the `{{TEST_FIRST}}` or `{{TEST_HARNESS}}` placeholder records nothing, so replace it in place instead of appending.

## Step 5: Continuous Integration

The shipped workflow `.github/workflows/traceability-check.yml` (from `${CLAUDE_PLUGIN_ROOT}/templates/github/traceability-check.yml`, installed at every profile by `@attention-regime`) reads the record through the same libraries. Tell the engineer three things about its test steps:

- They run only where `test_first.applies` is `true`. With `false`, or with no record, no recorded test or scenario runs in CI (§11.8).
- They run `test_command`, and `scenario_command` when recorded, from the git top level, the directory the globs are relative to. A command that only works from the engineering root fails there.
- They run on a bare GitHub-hosted runner, which holds the checkout and the runner image's preinstalled tools and nothing else. A harness that needs a runtime version, its dependencies or a service needs a set-up step. Offer one above the step `Run the recorded tests (test_command)`, for example `actions/setup-python` with the project's Python version followed by an install of the test dependencies. Show it, and write it only after a yes.

The workflow reads the record through `.githooks/lib/iso-profile.sh` and `.githooks/lib/test-first.sh`, so both must be committed. If either is missing, or the workflow itself is absent, hand off to `@attention-regime`.

## Step 6: Verify

Run from `<TOP>` and keep the output:

1. The Step 1 probe prints the recorded values, and the Test-first line of `<ENG_ROOT>/CLAUDE.md`, the SEMP row of `<ENG_ROOT>/docs/semp.md` and the newest tailoring line of `<ENG_ROOT>/docs/project-plan.md` name the same judgement and command.
2. Classify one existing path for each glob. A path under each `code_paths` glob prints `code`, one under each `test_paths` glob prints `test`, and a feature file prints `never`:

   ```bash
   cd "<TOP>" && VSE_ISO_CONFIG="<ENG_ROOT>/.iso-config.yaml" bash -c '
     . "$1" && . "$2" || exit 2
     shift 2
     for path in "$@"; do
       printf "%s  %s\n" "$(vse_tf_classify "$path")" "$path"
     done' _ "${CLAUDE_PLUGIN_ROOT}/hooks/lib/iso-profile.sh" "${CLAUDE_PLUGIN_ROOT}/hooks/lib/test-first.sh" <relpath>...
   ```

3. `test_command` exits 0. Some harnesses fail when they find no tests (pytest exits 5 when it collects nothing), so a project with no tests yet fails CI until the first test lands. Write that first test with the record, or say so.
4. Where recorded, `scenario_command` exits 0 once every scenario it selects has passing steps.
5. Run `test_command` once more in a fresh clone (`git clone <TOP>` into a directory under `mktemp -d`), which catches a dependence on untracked files. The clone still sees the workstation's installed tools, so it does not prove the set-up step of Step 5. Remove the directory afterwards.

## Step 7: Report

State the judgement and the four records written, and what the gates do from the next edit and the next commit: `pretooluse_test_first` and `precommit_test_first` at the dispositions the Step 1 probe printed (block at every profile unless a recorded `gate_overrides` entry lowers one), watching `code_paths`. Where test first does not apply, both are silent and Gherkin first still holds. State the CI implication from Step 5, and which cycle governs code from now on: `superpowers:test-driven-development` when it is available, otherwise the fallback cycle below.

## Writing Code Where Test First Applies

Where `test_first.applies` is `true`, every change to a path under `code_paths` is written test first.

**When `superpowers:test-driven-development` is in your available skills:**

**REQUIRED SUB-SKILL:** Use superpowers:test-driven-development

Invoke it before writing code. It governs the mechanics of the red-green-refactor cycle (a failing test, then the least code that passes it, then a tidy-up). Methodology §11.6 adjusts it in three places:

1. **Its exceptions are already answered.** The skill asks the human partner before applying TDD to some kinds of work. For this project the recorded `test_first` judgement is that answer. Do not stop to ask again about a case the record covers, and do ask when the record is silent, for example a new kind of file that no glob names.
2. **Human work is kept.** Its instruction to delete code written before its test and start over becomes: stop, write the failing test, and keep human-authored artefacts. Deleting human-authored work is a destructive action, so it needs the engineer's explicit confirmation, in the spirit of the explicit-request discipline of §2.6 rule 7.
3. **Prose stays exempt.** Methodology text, documentation, skill files and Markdown templates are prose, not code. Neither the cycle nor the companion skill-writing discipline, which pressure-tests skill files, applies to them.

On any other point where the skill and §11 differ, §11 wins for the project.

**Otherwise, follow the fallback cycle of §11.7:**

1. **Red.** Write one test for the next small piece of behaviour. Run it and watch it fail for the expected reason, that is, a failed assertion about the missing behaviour rather than a typo or an import error.
2. **Green.** Write the minimal code that makes the test pass. Run `test_command` and see every test pass.
3. **Refactor.** Improve the structure of the new code with the tests unchanged, running them again after each step. A pure refactoring, with no change of behaviour, belongs on a branch that matches `refactor_branches`.
4. **Legacy code.** Before changing code that has no tests, first write characterisation tests (tests that pin down what the code does today) and see them pass. Then change the code test first.
5. **Exceptions.** A change that genuinely cannot be written test first, such as generated code or an emergency production fix, is recorded in the tailoring record with its reason, for example `Test-first exception: <change>, <reason> (recorded <date>).` The test follows as soon as it can be written. An exception never lowers a gate by itself.

Under either cycle, keep the failing command and its first failing lines. They are the red evidence that the pull request's "Test-first evidence" section reproduces (§8.6.1). Where `scenario_command` is recorded, the scenarios form an outer loop: the scenario for a criterion runs and fails first, then inner cycles build the code until it passes.

## Wiring the Scenarios to a Runner

Only where test first applies (§11.8). Where it does not, no runner is wired, and the scenarios remain the acceptance criteria that verification and validation cases reach.

1. **Choose the runner** for the project's language: Cucumber for the JVM and for JavaScript, behave or pytest-bdd for Python, Reqnroll for .NET, Godog for Go, among others. The detection keys `behave` and `cucumber` show a runner already configured. Install a new one as a development dependency, after approval of that step.
2. **Read the feature files where they live**, beside the stories under the `stories/` directories of the model tree. Never copy them, because a copy would drift.
3. **Step definitions are test code.** A step definition is the code that binds a step's text to an action or an assertion. Place them under `test_paths` and write each before the code it exercises. Where a runner looks for step definitions relative to the feature files, point its configuration at the test path. If it cannot be pointed elsewhere, add the location it insists on to `test_paths` and say so in the rationale.
4. **Strict mode.** The runner fails an undefined step (one with no step definition) and a pending step (one marked as not yet written) instead of passing them silently. Confirm this by experiment rather than by flag name: run the runner, with the options of `scenario_command` but without its tag filter, on a feature file whose steps have no definitions yet. It must exit non-zero.
5. **Scenarios no machine can exercise**, such as a stakeholder's judgement during a field trial, are reached by a validation case (§4.3.6) and skipped through a tag the project chooses, such as `@manual`, which `scenario_command` excludes.
6. **Record `scenario_command`** in the `test_first` block, a change to `test_first` that the engineer confirms (Step 3), then update the CLAUDE.md line and the SEMP row (Step 4) and verify (Step 6). CI runs it on every pull request beside `test_command`.

The feature file's path, or its tag `@<StoryIdentifier>`, selects one story's scenarios. The path plus the tag `@AC_<name>` selects one criterion, which suits the outer loop. An `@AC_` tag alone can also select another story's scenarios, because a criterion name is unique only within its feature (§11.2.3).

## Resolving a Denial

`pretooluse_test_first` denies an agent edit to a path under `code_paths` when no test evidence exists. `precommit_test_first` reports a commit set, or a pull request in CI, that changes code with no change to a test path. Answer by doing what the denial asks (§11.10):

1. Write or change the failing test under `test_paths`, run it, and watch it fail for the expected reason. Keep the output as red evidence.
2. Retry the edit. A test path that is new or modified in the working tree is evidence for the in-session gate, whatever the denial says about branch evidence (a shallow clone, a detached HEAD, a branch with no commits yet, no base branch). A shallow clone is one fetched without the full history, and a detached HEAD is a checkout of a commit rather than of a branch. At commit time, commit the test with the code, or before it on the same branch.
3. Where the reason names a repository state, fix it for the commits that follow: `git fetch --unshallow` for a shallow clone, a branch checkout for a detached HEAD.

Without the engineer's explicit request, never edit `test_first` or `gate_overrides`, never write the denied file through the Bash tool or any other route the gates cannot see, and never delete or weaken a test so that code passes.

- **A pure restructuring.** Propose a branch that matches `refactor_branches`, where the finding becomes a reminder. Do not rename the current branch unasked.
- **A path wrongly taken for code**, such as a data file that a broad glob catches. Propose a narrower `code_paths` as a revisit of the judgement (Step 3) and leave the decision to the engineer.
- **A change that cannot be written test first.** Record the exception of §11.7 with its reason. It does not lower the gate. If the engineer asks how to proceed past the gate, answer as §0.10.6 says: name the mechanism (a recorded `gate_overrides` entry, git's `--no-verify` for the commit-time gate, or an edit made outside Claude Code for the in-session gate), name the recording obligation (the Correction Register at `full`, one line in the commit body at `standard` and `light`), and recommend the conforming path first. CI runs the same gate over the pull request, so a commit made past the local gate still meets it there.
- **An unrecorded judgement** ("test_first is not recorded and test tooling was detected"). Recording the judgement with the engineer, Steps 1 to 7, is the answer, and it is not an override.
- **A Gherkin-first denial** (`pretooluse_gherkin_first`) is not this skill's. Hand off to `@story-orchestrator`, which writes the feature file first.

## Judgement Calls

The pattern for every item: name the rule and its section, state the concrete risk, recommend the conforming path, proceed on the engineer's informed confirmation.

- **`applies: false` while a harness is viable.** §11.5.1 says viable means mandatory. The risk is code arriving untested while both gates stay silent. Recommend `true`. If the engineer still decides `false`, the rationale records the reason they give, because it is their tailoring decision (§0.10.2).
- **A broad glob** such as `*` or `*.sh`. A `*` crosses directories, so `*.sh` also matches `.githooks/lib/*.sh`, the plugin's installed copies, and every match is gated. Recommend the project's own directories, such as `src/*` or `scripts/*.sh`.
- **A brownfield project.** The globs and `test_command` are relative to the git top level, not to `engineering/`. Detect at both, as Step 2 does.
- **Several languages in one repository.** The record holds one `test_command`, so recommend one entry point that runs every suite, such as a `test` target in the Makefile.
- **A test that needs a service or a secret**, such as a database. The bare runner has neither. Recommend a set-up step or a test double, and never record a command that passes only on the workstation.
- **Scenarios of stories not yet built.** Strict mode fails a selected scenario without step definitions, so a `scenario_command` that selects every feature file fails CI once a `ready` story has scenarios. Recommend a runner tag beside the `@AC_` tag, such as `@wip` (§11.2.3 allows it), excluded by `scenario_command` and removed in the commit that adds the step definitions. An excluded scenario does not run, so the tagged scenarios are a list a reviewer reads.
- **A baselined plan or SEMP.** When `<ENG_ROOT>/docs/project-plan.md` or `<ENG_ROOT>/docs/semp.md` is under `baselined_paths`, the record changes a baselined artefact. Hand off to `@change-request` before committing.

## Hand-offs

- **To `@project-setup`** when there is no `.iso-config.yaml`, because the project is not scaffolded.
- **To `@attention-regime`** when `.githooks/`, its `lib/test-first.sh` and `lib/iso-profile.sh`, or the CI workflow are not installed.
- **To `@story-orchestrator`** for feature files, story branches, Gherkin-first denials and the model-tier test first of §11.4.
- **To `@verification-validation`** for the cases that reach each criterion, planned under §4.3.6 and §5.4.6. Their execution is project-determined (§4.8, §5.7), except the scenario runs of §11.8 where test first applies.
- **To `@change-request`** when a record lands in a baselined artefact.
- **To `@project-audit`** for a full health check after the judgement is recorded.

## Outputs

After a successful run: `<ENG_ROOT>/.iso-config.yaml` carries a `test_first` block that the libraries read back, the managed block of `<ENG_ROOT>/CLAUDE.md` carries the Test-first line, `<ENG_ROOT>/docs/semp.md` and `<ENG_ROOT>/docs/project-plan.md` record the judgement where those files exist, sample paths classify as the engineer intended, `test_command` (and `scenario_command`, when recorded) has passed from the git top level, and any CI set-up step the harness needs is in the workflow.

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| Gherkin syntax reference | pages/bdd-tdd/gherkin-syntax-reference.md | Gherkin keywords, steps, Background, Outlines, doc strings, data tables and comments, with the limits §11 sets |
| Gherkin tags and tag expressions | pages/bdd-tdd/gherkin-tags-and-tag-expressions.md | Tag placement, inheritance and tag expressions, for selecting one story's or one criterion's scenarios on a runner |
| Test-driven development: the red-green-refactor cycle | pages/bdd-tdd/tdd-red-green-refactor.md | The red-green-refactor cycle, the Iron Law, tests that can fail, and how §11.6 adjusts the installed TDD skill |
| Behaviour first and test first (§11) | pages/methodology/behaviour-and-test-first.md | Section 11 in one page: a feature file per story, mirrored criteria, story ordering, the test-first record, gates |
<!-- wiki-routing:end -->
