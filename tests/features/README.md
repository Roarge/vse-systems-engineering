# Plugin feature files

This directory describes the plugin's own behaviour as Gherkin
scenarios. Gherkin is the plain-text Given/When/Then format that
Cucumber-family tools execute. Each `.feature` file holds one feature of
the plugin, such as a hook decision or a lint finding, written as
concrete examples. The scenario comes first, before the unit or hook
test and before the code, as the contributor rule in
`.claude/rules/tdd-bdd.md` requires.

These scenarios cover the plugin itself. The scenarios an end user
writes for their own system live in their project, not here.

## Running the scenarios

From the repository root:

```sh
make test-bdd
```

which runs the same commands as CI:

```sh
python3 tests/bdd/run.py tests/features
python3 templates/tools/lint/story-wellformed.py --only syntax tests/features
```

The second command is the story lint in syntax mode. It checks that
each file parses, uses English, keeps any Background to Given steps
before the first scenario, orders steps Given, When, Then, and gives
every Scenario Outline complete Examples (findings F1, F2, F7, F8 and
F9 of methodology §11.9.1). It runs even on scenarios tagged `@wip`,
which the runner skips. These files describe the plugin rather than a
user story, so the story checks do not apply to them.

The runner, `tests/bdd/run.py`, needs the Python standard library only.
It prints one line per scenario, marked `PASS`, `FAIL`, `UNDEFINED` or
`SKIP`, and then a summary line:

```text
bdd: 3 passed, 0 failed, 0 undefined, 1 skipped
```

The exit status is:

- 0 when every scenario passed or was skipped
- 1 when a scenario failed or was undefined
- 2 when nothing could run: a feature file cannot be read or is not
  UTF-8, a feature file does not parse (any finding the parser
  reports), a step module fails to import, a path or the steps
  directory is missing, or the command line is otherwise wrong.

A step that no step definition matches is undefined, and an undefined
step fails the run. A feature file that cannot be read is named on
standard error as `<path>: <error>`, and a step module that fails to
import as `<module path>: <error>`. A directory that holds no
`.feature` file passes with a zero summary.

A path may also name a single `.feature` file. `--steps DIR` reads the
step definitions from another directory, which the runner's own unit
tests use.

## Step definitions

A step definition is a Python function that carries out one step. The
definitions live in `tests/bdd/steps/`. Each one is registered with the
`step` decorator and a regular expression that must match the whole step
text. The docstring of `tests/bdd/steps/__init__.py` shows a complete
step module and describes the shared context and the cleanup hook.

## The `@wip` tag

`@wip` (work in progress) marks a scenario that is written ahead of the
behaviour it describes. The runner skips a `@wip` scenario and reports it
as `SKIP`, so the suite stays green while the behaviour is built. The tag
may sit on a scenario, on a `Rule` or on the `Feature`, and it covers
everything beneath it. A `@wip` tag on an `Examples` block is not
supported. The runner ignores it, so the rows of that block still run.

To see the work in progress fail, run:

```sh
python3 tests/bdd/run.py --include-wip tests/features
```

A new scenario typically reports `UNDEFINED` at this point, because its
steps have no definitions yet. The task that implements the behaviour
removes the `@wip` tag and adds the step definitions in the same commit
as the code that makes the scenario pass.
