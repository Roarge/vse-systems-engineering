---
paths:
  - "hooks/**"
  - "templates/tools/**"
  - "tests/**"
  - "Makefile"
  - ".github/**"
---

# Test-First and Gherkin-First Rules

The plugin asks its users to work behaviour first and test first, and
its own development follows the same discipline. Test-driven
development (TDD, writing a failing test before the code that makes it
pass) applies wherever a test can run, and where it can run it is
mandatory. Behaviour-driven development (BDD, describing behaviour as
concrete example scenarios before building it) applies to every plugin
behaviour. The scenarios are written in Gherkin, the plain-text
Given/When/Then format that Cucumber-family tools execute.

**Where TDD applies.**

- Bash under `hooks/`, tested from `tests/hooks/`.
- Python under `templates/tools/` and `tests/`, tested with the
  standard-library `unittest` under `tests/python/`. The `pytest`
  module is not importable by `python3` locally or in CI.
- Makefile logic.

The cycle is red, green, refactor. Write the failing test and watch it
fail for the expected reason (red). Write the minimal code that makes
it pass (green). Then tidy the code with the tests unchanged
(refactor). Before changing untested legacy code, first add
characterisation tests (tests that pin down what the code does today).

**What is exempt.**

- Prose: skills, agents, commands, wiki, methodology, and Markdown
  templates. A `SKILL.md` edit counts as prose, so the superpowers
  writing-skills pressure-testing is not required either.
- CI YAML under `.github/`. Testing it directly is judged not viable.
  Its check is parity: the Makefile and
  `.github/workflows/plugin-ci.yml` carry the same checks, so every CI
  check also runs locally under `make`.

**Superpowers precedence.** When `superpowers:test-driven-development`
is in the available skills, invoke it before writing code. It governs
the cycle, with three adjustments.

- Its "ask your human partner" exception list is already answered for
  this repository by the judgement above (what applies and what is
  exempt). Do not stop to ask again.
- Its "delete it and start over" becomes "stop, write the failing
  test, and keep human-authored artefacts". Deleting human-authored
  work needs the engineer's explicit confirmation, because it is a
  destructive action (the explicit-request discipline of methodology
  §2.6 rule 7).
- The prose exemption above stands, including for `SKILL.md` files.

When superpowers is absent, follow the fallback cycle in methodology
§11, which is the cycle described above with the red output kept as
evidence.

**Gherkin first.** Plugin behaviour is described in
`tests/features/*.feature` before the code that implements it.
`tests/bdd/run.py` (standard library only) runs the scenarios, and an
undefined step fails. A behaviour change starts with a new or changed
scenario, then the failing unit or hook test, then the code.

**Evidence.**

- Each pull request body carries a "Test-first evidence" section with
  the red output, that is, the failing command and its first failing
  lines.
- `tests/hooks/check-test-first.sh` enforces test-before-code under
  `make all` and in CI.
  It fails a branch that changes code without changing a test.
