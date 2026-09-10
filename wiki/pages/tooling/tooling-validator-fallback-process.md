---
title: "Validator selection and fallback in the pre-commit lint gate"
slug: tooling-validator-fallback-process
type: process
layer: tooling
summary: How the pre-commit lint gate picks a SysML v2 validator, falls back with a notice, and reports findings
tags: [pre-commit, hooks, validation, fallback, toolchain, iso-config, licence, exit-codes]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §0.10.4 (gate table) and ISO/IEC 29110 hooks guide §4.1 and §8."
    raw: methodology/iso-29110-hooks-guide.md
  - citation: "vse-systems-engineering plugin (2026). hooks/lib/sysml-toolchain.sh and hooks/pre-commit.sh as shipped at this release."
    raw: hooks/pre-commit.sh
related:
  - tooling-sysml-toolchain-choice
  - tooling-omg-pilot-batch-validation
  - tooling-opensysml-cli
  - tooling-java-runtime
  - syside-vse-workflows
  - syside-project-configuration
confidence: high
created: 2026-09-10
updated: 2026-09-10
referenced_by: [sysml-toolchain, attention-regime, project-audit]
---

# Validator selection and fallback in the pre-commit lint gate

## Contents

- Preconditions
- Steps
- Postconditions
- Work products
- Failure modes

The lint gate of the pre-commit hook runs the SysML v2 validator the project recorded, falls back through a fixed order when that validator is unavailable, and reports findings in one shape whatever tool produced them. The gate is the `precommit_lint` row of the methodology's §0.10.4 table, so the project profile decides whether a finding blocks, warns or informs, and the toolchain decides only which validator speaks.

## Preconditions

`.iso-config.yaml` sits at the git top level or under `engineering/`, and its `sysml_toolchain` key names `syside`, `omg-pilot` or `opensysml` (an absent key means `syside`). The `precommit_lint` disposition for the project profile is not `off`. The shared library `sysml-toolchain.sh` is installed under `.githooks/lib/` beside `iso-profile.sh`, the project copy winning over the plugin copy under `${CLAUDE_PLUGIN_ROOT}/hooks/lib/`. At least one toolchain is installed on the machine.

## Steps

1. The hook resolves the `precommit_lint` disposition through `iso-profile.sh` and stops here when it is `off`.
2. It lists the staged `.sysml` files. An empty list ends the gate with exit 0 and no message, because a commit that touches no model file has nothing to validate.
3. The library reads the preference from `sysml_toolchain`, or from `VSE_SYSML_TOOLCHAIN` when the environment sets it for one run.
4. The library probes the candidates in order, the preference first and then the remaining tools in the order syside, omg-pilot, opensysml. Syside is probed by a real `syside check` on a one-line scratch model, because `syside --version` and `syside check --help` succeed on an expired licence and only a real check prints `License check failed:` and exits 2. The pilot is probed by a Java 21 runtime, the kernel jar and the standard library under `~/.local/share/sysml-pilot`. OpenSysML is probed by `sysml -version` on the PATH.
5. When the tool that runs is not the preference, the library prints one notice on standard error naming the reason, for example `[pre-commit] syside unavailable (licence expired, exit 2); validating with omg-pilot instead`.
6. The tool runs. Syside receives the staged files and `--warnings-as-errors`. The pilot receives every tracked model file in one block so that cross-file names resolve, followed by `%exit`, and its diagnostics are mapped back to file and line from an offset table and filtered to the staged files. OpenSysML receives the same file set with `-validate -strict`, and its `warning:` lines are promoted to findings.
7. Diagnostics are normalised to `path:line:col: severity: message`, one per line, on standard output.
8. The library returns 0 for a clean run, 1 for findings, and 2 when no candidate could run at all, listing every reason. The hook applies the disposition: `block` refuses the commit, `warn` reports and counts, `info` prints one line. A 2 is reported at every disposition except `off`, so a full-profile project never sees a green summary with no validation performed.

## Postconditions

Findings appear on standard error with the `[pre-commit]` prefix. No file is written and no temporary file is left behind. The recorded preference is untouched by the hook. A fallback notice repeats on every commit until the engineer runs `/vse-toolchain` to install the missing tool or to switch the preference.

## Work products

None beyond the terminal output. The SEMP tool table and the Toolchain line in the project `CLAUDE.md` are maintained by the skills that record the choice, not by the hook.

## Failure modes

| Failure | What the gate does | Recovery |
|---|---|---|
| Syside licence expired | probe sees `License check failed:`, falls back with a notice | renew, or switch with `/vse-toolchain` |
| Java missing or older than 21 | pilot reported unavailable with the version tried, next tool runs | install a Java 21 runtime, see [[tooling-java-runtime]] |
| relative pilot library path | never happens, the library absolutises the path | none |
| missing `%exit` | never happens, the library appends it and runs under `timeout` | none |
| no staged model files | exit 0, no message | none |
| no toolchain installed at all | exit 2, refused at `block`, warned at `warn`, one line at `info` | `/vse-toolchain` installs one |
| `syside format --check` under another toolchain | skipped with a notice, no other toolchain ships a formatter | none |
| pilot runtime cost | one Java process per commit, about 8 to 15 seconds | choose OpenSysML for sub-second runs |
| CI runner | the workflow template reads the same key, installs the pilot or OpenSysML, and runs Syside steps only when `syside.toml` exists | none |

## See also

- [[tooling-sysml-toolchain-choice]] for the three toolchains and the preference key.
- [[tooling-omg-pilot-batch-validation]] and [[tooling-opensysml-cli]] for each validator's contract.
- [[syside-vse-workflows]] for the Syside gate this process generalises.
- [[syside-project-configuration]] for the files each toolchain reads.
