---
name: verification-validation
description: Author and execute verification cases (against the system model, §5.4.6) and validation cases (against stakeholder intent, §4.3.6), bound to each acceptance criterion and its Gherkin scenario.
when_to_use: Use when writing a verification def, binding an acceptance criterion with verify <story>.acceptance.<name>, checking that every scenario is reached by a case, running the recorded scenario or test command for a case, choosing between verification and validation, preparing the IVV Plan or IVV Procedures, or running a V&V coverage check before release.
user-invocable: true
---

# Verification and Validation

If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first.

This skill owns the discipline of binding acceptance criteria to executable cases and turning the resulting `verification def` set into the IVV Plan, the IVV Procedures, and the Verification and Validation Reports specified by ISO/IEC 29110. Each acceptance criterion is a Gherkin scenario in the story's feature file, `<ID>.feature`, mirrored by a named criterion in the story (§11.3). Gherkin is the plain-text Given/When/Then format that Cucumber-family test tools read. A case binds criteria one by one, by name.

The methodology distinguishes two activities that share the SysML v2 `verification def` syntax. *Verification* asks whether the system, as modelled, meets its system stories per §5.4.6. *Validation* asks whether the realised system meets stakeholder intent per §4.3.6. Both produce `verification def` instances. The distinction lies in which acceptance the `objective { verify ... }` clause binds, and in which folder the file lives.

## When this skill triggers

Phrases that activate the skill:

- "write a verification case", "author a verification def".
- "write a validation case", "exercise stakeholder intent".
- "bind this acceptance to a verification def", "verify the acceptance criterion", "which case covers this scenario".
- "render the IVV Plan", "render the IVV Procedures".
- "verify the system", "exercise the system model".
- "check V&V coverage", "every acceptance has a case", "every scenario has a case".
- "run the scenarios", "run the tests for this case".

Routed in by `@story-orchestrator` once a story is open. `@story-orchestrator` writes the case stub that reaches every criterion when it opens the story, because the stub comes before `inProgress` (§11.4), and this skill fills the stub's body (Workflows A and B). Routed in by `@release-orchestrator` during the release baseline coverage check, where every acceptance criterion on `main` must have at least one case reaching it. Routed in by `@architecture-design` when the architectural model needs verification cases authored against subsystem stories or control laws.

## Inputs

The project layout (per §8.3) provides:

- `model/core/verification-validation/verification-cases/`. System-level verification cases.
- `model/core/verification-validation/validation-cases/`. System-level validation cases.
- `model/core/logical-architecture/components/<comp>/verification-validation/{verification-cases,validation-cases}/`. Recursive subsystem-scope V&V per §8.3.2.

The story register provides:

- `model/core/stories/stakeholder/`. Stakeholder stories whose acceptance criteria are bound to validation cases.
- `model/core/stories/system/`. System stories whose acceptance criteria are bound to verification cases.
- `model/core/logical-architecture/components/<comp>/stories/`. Subsystem stories.

Each story carries one or more named acceptance criteria, nested in `requirement :>> acceptance` per §1.4.4. Each criterion mirrors one scenario of the story's feature file, beside the story, whose tag `@AC_<name>` carries the criterion's name (§11.3.1). Each criterion may be the target of zero or more `verify` clauses, and of at least one once the story is `inProgress` (§11.4). The methodology copy at `<project>/methodology/` is the authoritative reference and is read whenever a rule is in question.

The case templates are `${CLAUDE_PLUGIN_ROOT}/templates/common/models/core/verification-validation/validation-cases/_template.sysml` and `${CLAUDE_PLUGIN_ROOT}/templates/common/models/core/verification-validation/verification-cases/_template.sysml`. Each binds one criterion by name, `.acceptance.exampleCriterion`, as the pattern to follow.

## Workflow A: Validation case authoring (§4.3.6)

A validation case exercises stakeholder intent rather than system internals. It asks "does the system, as observed, satisfy what the stakeholder wanted?" Answers are typically obtained by demonstration, walkthrough, or operational test, not by an automated unit-level check.

1. Identify the stakeholder story and the acceptance criteria to be validated, by the names their scenarios' `@AC_` tags carry.
2. Author a `verification def` whose `subject` matches the stakeholder story's `subject`. The §4.3.6 example fixes this discipline.
3. Bind each criterion by name: `objective { verify <story>.acceptance.<name>; }`, one clause per criterion the case covers. `verify <story>.acceptance` reaches every criterion of the story and suits a case that covers them all (§11.3.3). Prefer the narrow form when different cases verify different criteria, because the traceability matrix then shows which case verifies which scenario. Dot notation reaches a member of the story usage, and both reference implementations refuse the `::` namespace form per §5.4.6.
4. Provide an action body that names the demonstration or operational fixture (collect, evaluate). The body may be deferred, but the stub, holding the subject and the objective, must exist before the story moves to `inProgress` (§11.4, §8.6.3 item 6).
5. Place the file in `model/core/verification-validation/validation-cases/<name>.sysml`, starting from the validation case template. Use `VAL_` as the case name prefix.

The pattern is the one shown in methodology §4.3.6:

```sysml
verification def VAL_AckFromDashboard {
    subject sys : Aiwell_OnlineSentral;

    objective {
        verify US_042_AckFromDashboard.acceptance.ackAllWithinOneSecond;
    }

    action collectData { /* observed user task on representative hardware */ }
    action evaluate    { /* pass criterion in stakeholder vocabulary */ }
}
```

## Workflow B: Verification case authoring (§5.4.6)

A verification case exercises the system as modelled. It asks "does the system exhibit the required behaviour or property?" Answers are typically obtained by model execution, automated check, or simulation.

1. Identify the system story and the acceptance criteria to be verified, by the names their scenarios' `@AC_` tags carry.
2. Author a `verification def` whose `subject` matches the system story's `subject`.
3. Bind each criterion by name: `objective { verify <story>.acceptance.<name>; }`, or `verify <story>.acceptance` for every criterion (§11.3.3). Where the story carries a formalised benefit as a nested requirement usage, a single case may verify both that usage (`verify <story>.<benefit>;`) and the criteria.
4. Provide an action body covering setup, measurement, and evaluation. The stub must exist before the story moves to `inProgress` (§11.4). The body is the case's procedure, the source of the IVV Procedures (§9.5, §9.8), so it is populated before the release baseline, where `@release-orchestrator` checks it against SR.O7, "V&V tasks performed" (§9.4).
5. Place the file in `model/core/verification-validation/verification-cases/<name>.sysml`, starting from the verification case template. Use `VC_` as the case name prefix.

The pattern is the one shown in methodology §5.4.6:

```sysml
verification def VC_BatchAckLatency {
    subject sys : Aiwell_OnlineSentral;

    objective {
        verify SYS_142_BatchAcknowledgement.sla;
        verify SYS_142_BatchAcknowledgement.acceptance.p99LatencyWithinOneSecond;
    }

    action setup    { /* fixture preparation */ }
    action measure  { /* observation method */ }
    action evaluate { /* pass criterion in measurable form */ }
}
```

A single case may verify multiple acceptance criteria where they share a fixture, with one `verify` clause for each. An acceptance criterion may be the target of multiple cases when different conditions warrant separate runs.

## Workflow C: Subsystem V&V (§7.3.7 and §7.3.8)

§7 architectural decomposition introduces new failure modes at subsystem boundaries. Each component identified in §7 is itself a system at its own scope per §8.3.2, so the same authoring discipline applies recursively.

- Subsystem-scoped verification cases live under `model/core/logical-architecture/components/<comp>/verification-validation/verification-cases/`.
- Subsystem-scoped validation cases live under `.../validation-cases/`. The "stakeholders" of a subsystem may be sibling subsystems, the parent system, or external actors local to the subsystem boundary.
- Each subsystem story's criteria are bound the same way as a system story's, by name, against the subsystem `part def` rather than the system `part def`.
- Where a control law (§7.3.6) is allocated across multiple subsystems, the case verifying that law belongs at the scope (system or component) that contains all the involved parts.

The §7.3.8 review questions are asked by `@architecture-design`, not here. This skill answers only "is the case well-formed and does it bind the right acceptance?".

## Workflow D: Coverage check

Coverage is checked per criterion, not per story. Walk the story register before any release baseline, and whenever a story moves to `inProgress`. For each story:

1. Read its named criteria, nested in `requirement :>> acceptance`, and the `@AC_` tags of its feature file. They match one to one (§11.3.1). A criterion without a tag, or a tag without a criterion, is finding S4 or S5 of the story lint (`tools/lint/story-wellformed.py`, the check the `precommit_gherkin` gate runs, §11.9.1), routed to `@story-orchestrator`.
2. For each criterion, find every `verification def` whose `objective` reaches it: `verify <story>`, `verify <story>.acceptance`, or `verify <story>.acceptance.<name>` (§11.3.3).
3. Record criteria that no case reaches. For a story at `inProgress` or `done` this breaks the §11.4 ordering, and the `precommit_gherkin` gate reports it as S8 and blocks the commit at every profile unless a recorded override lowers it. For a `backlog` or `ready` story it is planned work. Route every gap to `@story-orchestrator` for remediation.
4. Record verification cases whose action body is empty (stub state). A stub is enough from `inProgress` until final review (§11.4, §8.6.3 item 6). The body is the case's procedure (§9.5, §9.8), so it is populated before the release baseline, where `@release-orchestrator` checks it against SR.O7 (§9.4). The list is surfaced to the engineer.

The story lint checks steps 1 to 3 mechanically. Run it from the engineering root, `python3 tools/lint/story-wellformed.py --only gherkin model`, and read S4, S5 and S8. This is Contract 2 of the hooks guide (§4.4), which the pre-commit hook and CI also run.

Where the model size exceeds what the skill can hold in working context, dispatch to `@traceability-guard` with the trace rule "every acceptance criterion shall be reached by at least one `verify` clause".

## Workflow E: IVV Plan and IVV Procedures (§9.8)

Per §9.8 model-derived artefacts, the IVV Plan and IVV Procedures are *generated* from the model rather than authored.

- The IVV Plan is rendered from the `verification def` set: subjects, objectives, expected outcomes. It is the union of `model/core/verification-validation/` and every recursive component-scope equivalent.
- The IVV Procedures are rendered from the action bodies of those cases.
- **No IVV renderer ships with the plugin.** The renderers the plugin installs under `tools/render/` produce the traceability matrix and the stakeholder and system requirements specifications only. The `ivv_plan` and `ivv_procedures` keys of the `renderers:` block in `.iso-config.yaml` stay commented out until the project authors those scripts under `tools/render/`. Until then, prepare the IVV Plan and the IVV Procedures by hand from the model, with the engineer, at `docs/ivv-plan.md`, beside the other documents `@project-setup` writes, from `${CLAUDE_PLUGIN_ROOT}/templates/sr/ivv-plan.md`. List each case with its subject and the criteria its objective reaches, and take the case-to-story links from the rendered `docs/generated/traceability-matrix.md`. Fill section 5 of the template, IVV Procedures, from the cases' action bodies, one entry per case. Keep the hand-prepared Plan out of `docs/generated/`, which holds renderer output only, so no reader takes it for a regenerated artefact.
- Where an acceptance criterion in the story register has no case reaching it, run Workflow D first and carry the result into the Plan as an explicit coverage-gap section (see Judgement calls for the per-profile disposition).
- Once the project has its own IVV renderer and has uncommented its key, the renderer writes `docs/generated/ivv-plan.md` and `docs/generated/ivv-procedures.md`. The freshness check in CI reruns every configured renderer and reports committed copies that differ, advisory at `light` and `standard` and blocking at `full` (Contract 3, hooks guide §3.4 and §4.4). The post-merge hook, installed at `full`, regenerates them on `main` (hooks guide §4.5). Confirm that the rendered files are current before reporting completion.
- Hand off to `@document-export` only to convert the finished Plan or Procedures to docx, pptx or pdf.

## Workflow F: V&V execution and reporting

Authoring stops at the `verification def`. Execution produces a Verification Report or Validation Report from the report templates `${CLAUDE_PLUGIN_ROOT}/templates/sr/verification-report.md` and `${CLAUDE_PLUGIN_ROOT}/templates/sr/validation-report.md` (§9.5).

How a case is executed depends on the `test_first` record in `.iso-config.yaml` (§11.5.2). Read it before running anything, and route any question about it to `@test-first`.

- **Where test first applies** (`test_first.applies: true`), the story's scenarios are executable (§11.8). Run the recorded `scenario_command` from the git top level, narrowed to the story's feature file by its path, or to one criterion by that path plus the runner's tag filter for `@AC_<name>`. Never narrow by an `@AC_` tag alone, because a criterion name is unique only within its feature (§11.2.3), so the same tag can select another story's scenarios. Run the recorded `test_command` for the tests beneath them. A passing run of the scenario that states a criterion is execution evidence for the case that reaches it. Record the command, its exit status and the commit it ran on in the report. Where `scenario_command` is not recorded, no runner is wired, so run `test_command` alone and offer the wiring through `@test-first` rather than inventing a command.
- **Where test first does not apply**, no runner is wired. Execute the case by the project-determined method of §4.8 and §5.7, such as demonstration, inspection, analysis or a test outside the repository, and report as below.
- **Scenarios no machine can exercise**, such as a stakeholder's judgement during a field trial, carry a tag the project chooses, such as `@manual`, which `scenario_command` excludes. A validation case reaches them, and its report records the judgement (§11.8).
- A Verification Report records the result of running a verification case against the model (or, downstream, the realised system). Each report cross-references the story or constraint it covers per §10.5.3, down to the criteria the case reaches.
- A Validation Report records the result of running a validation case with stakeholder participation in the operational context.
- The default storage location is `docs/verification-reports/<case>-<date>.md` and `docs/validation-reports/<case>-<date>.md`, subject to the project's CM Strategy (§10.8).
- Failures are recorded in the Correction Register at `docs/correction-register.md` per §10.5.2, with each correction following the normal PR workflow. Where test first applies, a fix to code starts with a failing test that reproduces the failure (§11.7), through `@test-first`.

## Judgement calls

Each entry names a rule and the section it comes from, states the concrete risk of departing from it, and recommends the conforming path. The default is to proceed once the engineer has confirmed with that information in hand. Two entries become hard stops at the `full` profile and say so.

Obligations scale with the project profile, methodology §0.10. Read `project_profile` per the lens convention before deciding how firmly to press. The coverage of the §11.4 ordering does not scale: an `inProgress` or `done` story with a criterion no case reaches is blocked by the `precommit_gherkin` gate at every profile, lowered only by a recorded override (Workflow D).

- **Subject mismatch.** The case's `subject` does not match, or specialise, the story's `subject`. Per §4.3.6 and §5.4.6 the case binds to the story it verifies, so a mismatched subject means the case exercises something other than the thing the story is about, and the trace reads as covered when it is not. Offer the two conforming paths: correct the case subject, or correct the story subject if that is where the error is. Proceed once the engineer confirms which they intend. The disposition is the same at every profile, because the risk is an incoherent binding rather than ceremony.

- **The `objective` names no existing acceptance criterion.** This is a missing input rather than a rule violation. Do not stop on it. A `verify <story>.acceptance.<name>` whose name the story does not declare fails to resolve when the model is validated. Say which story and which criterion the `verify` clause appears to reach for, list the criteria the named story does declare (the names its scenarios' `@AC_` tags carry), and ask which one the case should bind. If the story genuinely has no criterion for the behaviour yet, route to `@story-orchestrator`, which writes the scenario first and then the criterion, since a case with nothing to verify is not a case. Resolve the gap and continue.

- **IVV Plan requested with unbound acceptance criteria.** At `light` and `standard`, prepare the Plan and carry the gap explicitly: a coverage-gap table naming every criterion no case reaches, by story ID and criterion name, placed where a reader meets it before the case list. A Plan that names its gaps is more useful to the engineer than a refusal, because it is the document the gaps get closed against. At `full` this is a hard stop. The Plan is a §9.8 model-derived artefact that an assessor reads as a coverage claim, and a Plan that overstates coverage misrepresents the project. Route through Workflow D first.

- **Transition to `done` with empty verification bodies.** Per §11.4 and §8.6.3 item 6 a stub is enough at final review, and the release baseline expects the bodies, because a body is the procedure the IVV Procedures come from (§9.5, §9.8) and SR.O7 asks for V&V tasks performed (§9.4). An empty body means the case was planned and never run. Name every case with an empty body. At `light`, report and proceed. At `standard`, wait for explicit confirmation. At `full` this is a hard stop, because the `done` status is what the release baseline collects on.

In every case, state the rule, point to the methodology section, and propose the corrective routing (typically back to Workflow D, or to `@story-orchestrator`).

## Hand-offs

| Situation | Route to |
|---|---|
| A story has no case stub reaching its criteria (the stub is written when the story opens, and this skill fills its body) | `@story-orchestrator` |
| A scenario or its named criterion is missing, or the two disagree (lint finding S4 or S5) | `@story-orchestrator` |
| Whether test first applies, or wiring the scenarios to a runner before Workflow F can run them | `@test-first` |
| V&V coverage is the gate for a release baseline | `@release-orchestrator` |
| `verify` link surfaces as broken in the trace | `@traceability-guard` |
| The case body needs SysML v2 `verification def` syntax help | `@sysml2-cases` |
| The case requires `action def` execution detail | `@sysml2-behaviour` |
| Converting the IVV Plan, the IVV Procedures or a V&V report to docx, pptx or pdf | `@document-export` |
| The case is being edited inside a baselined artefact | `@change-request` |

## Outputs

- `model/core/verification-validation/verification-cases/<name>.sysml`. System-level verification cases (§5.4.6).
- `model/core/verification-validation/validation-cases/<name>.sysml`. System-level validation cases (§4.3.6).
- `model/core/logical-architecture/components/<comp>/verification-validation/...`. Subsystem-scope equivalents per §8.3.2.
- `docs/ivv-plan.md`. The IVV Plan prepared with the engineer from the IVV Plan template while the project has no IVV renderer (Workflow E).
- `docs/generated/ivv-plan.md` and `docs/generated/ivv-procedures.md`. Rendered, not authored, once the project's own IVV renderers exist and their keys are uncommented (Workflow E).
- `docs/verification-reports/<name>-<date>.md`. Execution-time, from the Verification Report template (§9.5).
- `docs/validation-reports/<name>-<date>.md`. Execution-time, from the Validation Report template (§9.5).

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| AMBSE Principles and Modelling Rules | pages/ambse/ambse-principles.md | Why agile methods apply differently to systems engineering, and the AMBSE modelling rules that follow |
| Gherkin tags and tag expressions | pages/bdd-tdd/gherkin-tags-and-tag-expressions.md | Tag placement, inheritance and tag expressions, for selecting one story's or one criterion's scenarios on a runner |
| Behaviour first and test first (§11) | pages/methodology/behaviour-and-test-first.md | Section 11 in one page: a feature file per story, mirrored criteria, story ordering, the test-first record, gates |
| SYSMOD test modelling: Model Test Cases and the Test Architecture | pages/sysmod/sysmod-test-modelling.md | SYSMOD's verdict-returning test behaviours, the Model Test Case, and the Test Architecture as a system in its own right |
| SysML v2 rules the reference implementations enforce | pages/tooling/tooling-reference-implementation-rules.md | SysML v2 forms the pilot and OpenSysML refuse or accept, from subject ordering to derivation and enum literals |
| Verification and Validation Definitions | pages/vv/vv-definitions.md | What verification and validation each mean, how they differ, and the levels they apply at |
| Verification and Validation Methods, Test Case Design | pages/vv/vv-methods.md | The four standard methods apply to both verification and validation |
| V&V Planning, Success Criteria, and the VCRM | pages/vv/vv-planning.md | V&V planning, success criteria, and the verification cross-reference matrix |
| V&V Reporting, VSE Guidance, and AMBSE Continuous Verification | pages/vv/vv-reporting-and-vse-guidance.md | V&V records, the SVCM, approval packages, and continuous verification scaled for a VSE |
<!-- wiki-routing:end -->
