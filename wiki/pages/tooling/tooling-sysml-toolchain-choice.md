---
title: "Choosing a SysML v2 toolchain: Syside, OMG pilot, OpenSysML"
slug: tooling-sysml-toolchain-choice
type: pattern
layer: tooling
summary: Choosing between Syside, the OMG pilot, and OpenSysML, their licences, capabilities, and the fallback order
tags: [toolchain, syside, omg-pilot, opensysml, licence, fallback, validation, lsp, iso-config]
sources:
  - citation: "Sensmetry. Syside pricing and licensing pages. https://sensmetry.com/syside-pricing/, https://docs.sensmetry.com/resources/licensing/ (accessed 2026-09)."
    raw: null
  - citation: "Systems-Modeling. SysML v2 Pilot Implementation, release 2026-07. https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation/releases/tag/2026-07 (accessed 2026-09)."
    raw: null
  - citation: "Open-MBEE. OpenSysML, release v0.6.0. https://github.com/Open-MBEE/OpenSysML/releases/tag/v0.6.0 (accessed 2026-09)."
    raw: null
related:
  - tooling-omg-pilot-batch-validation
  - tooling-opensysml-cli
  - tooling-java-runtime
  - tooling-validator-fallback-process
  - tooling-reference-implementation-rules
  - syside-tooling-overview
  - syside-project-configuration
  - vse-canonical-project-layout
  - sysml2-api-and-services
confidence: medium
created: 2026-09-10
updated: 2026-09-10
referenced_by: [sysml-toolchain, sysml2-modelling, project-setup, project-audit, attention-regime, document-export, traceability-guard]
---

# Choosing a SysML v2 toolchain: Syside, OMG pilot, OpenSysML

A VSE project needs one SysML v2 validator behind its pre-commit lint gate and, where the editor supports it, one language server. The plugin supports three toolchains and records the project's choice in `.iso-config.yaml`, with an automatic fallback for the day the chosen one stops working.

Confidence note: this page is `medium` rather than `high` because both open-source tools are pre-1.0. OpenSysML released twenty times in August 2026 and v0.6.0 on 2026-09-07, and Sensmetry's plan terms were read in August and September 2026 and may change. The capability table reflects those versions.

## Problem

Until this release the plugin assumed one validator, the commercial Syside command line. The pre-commit gate ran `syside check` when the binary was on the PATH and did nothing otherwise. When the licence on the reference machine lapsed, `syside check` exited 2 with `License check failed: License expired` while `syside --version` and `syside check --help` still succeeded, and the gate could not tell a lapsed licence from a broken model. A project with no licence at all had no validator, and its scaffold could not even be checked.

## Context

Every project the plugin scaffolds, at every rigour profile, and every continuous-integration runner that validates on push. The free Syside Editor alone does not count as a toolchain here, because it has no command line for the hooks. A Syside Solo plan excludes CI and air-gapped use, so a project on that plan runs its own machine with Syside and its runner with an open-source tool.

## Forces

Licence cost and terms pull one way, and capability pulls the other. Only Syside ships a formatter and a diagram renderer. The OMG pilot is the reference implementation and the strictest of the three on the forms listed in [[tooling-reference-implementation-rules]] (OpenSysML enforces one rule the pilot does not), but it needs a Java 21 runtime and spends 8 to 12 seconds starting. OpenSysML is one static binary that validates in well under a second and ships a language server, but it is younger than the pilot, claims no conformance, and tolerates a few forms the pilot refuses. The pilot has no editor integration at all. A VSE can least afford lock-in, which is the argument [[sysml2-api-and-services]] makes for the standard API.

## Solution

Record the choice once, run it everywhere, and fall back with a notice when it fails. The key is flat so the git hooks can read it with the same awk idiom they already use:

```yaml
# SysML v2 toolchain the hooks and the CI validate with. One of:
#   syside | omg-pilot | opensysml. Absent means syside.
sysml_toolchain: omg-pilot
```

`/vse-setup` asks the question once, right after the rigour profile, and `/vse-toolchain` installs a tool or switches the preference later. `project-audit` warns when the key is absent, the SEMP section 4.1 records the tool per methodology §10.3.2, and the project `CLAUDE.md` facts block carries a Toolchain line. The fallback order is fixed: the preference first, then Syside, the OMG pilot and OpenSysML in that order, each tried only when the previous one is unavailable, with one notice naming why. The preference is never rewritten by a hook.

| Toolchain | Key | Publisher and licence | Validate | Warnings as errors | Format | Language server | Diagrams | Scripting | Documents |
|---|---|---|---|---|---|---|---|---|---|
| Syside 0.10.3 | `syside` | Sensmetry, proprietary, the CLI needs a Solo or Business plan | `syside check`, exit 0 or non-zero, exit 2 with `License check failed:` on an expired licence | `--warnings-as-errors` | `syside format` | `syside lsp` | `syside viz` (Labs) | Automator Python | Jinja2 pipeline |
| OMG SysML v2 Pilot Implementation 2026-07 | `omg-pilot` | OMG Systems Modeling Community, EPL-2.0 with a GPL-2.0-or-later secondary licence | `SysMLInteractive` in batch, exit always 0, verdict parsed from standard output | the wrapper greps `ERROR` or `WARNING` | none | none | `%viz` in Jupyter only, needs Graphviz | `SysML2JSON` export | none |
| OpenSysML v0.6.0 | `opensysml` | Open-MBEE, Apache-2.0 | `sysml -validate -strict`, exit 0, 1 or 2 | none, the wrapper greps `warning:` | none | `sysml-lsp` | `-render` in text, Mermaid or Markdown | gRPC, Python, Node, Java, Rust | `-render-document` to Markdown, HTML, PDF |

## Consequences

Validation no longer depends on a licence. The demo project validates under two independent tools, and a project on the pilot holds its models to the reference implementation's rules, which are listed on [[tooling-reference-implementation-rules]]. The costs are real. Without Syside there is no formatter and no diagram renderer, so `syside format --check` is skipped with a notice and the document-export workflow renders no diagrams. The pilot needs Java 21, and every commit under it pays the runtime start. A project on `omg-pilot` has no `.lsp.json` unless OpenSysML is installed beside it, in which case OpenSysML's server edits while the pilot judges commits.

## Related patterns

- [[tooling-omg-pilot-batch-validation]], [[tooling-opensysml-cli]] and [[tooling-java-runtime]] for each tool's installation and contract.
- [[tooling-validator-fallback-process]] for the gate step by step.
- [[syside-tooling-overview]] and [[syside-project-configuration]] for the Syside surface and its files.
- [[vse-canonical-project-layout]] for where each toolchain's files live.
- [[sysml2-api-and-services]] for the lock-in argument.
