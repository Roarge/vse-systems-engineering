---
name: verification-validation
description: Author and execute verification cases (against the system model, §5.4.6) and validation cases (against stakeholder intent, §4.3.6). Use when writing a verification def, binding acceptance criteria to a verify clause, choosing between verification and validation, rendering the IVV Plan or IVV Procedures, or running a V&V coverage check before release.
user-invocable: true
---

# Verification and Validation

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

This skill owns the discipline of binding acceptance criteria to executable cases and turning the resulting `verification def` set into the IVV Plan, the IVV Procedures, and the Verification and Validation Reports specified by ISO 29110.

The methodology distinguishes two activities that share the SysML v2 `verification def` syntax. *Verification* asks whether the system, as modelled, meets its system stories per §5.4.6. *Validation* asks whether the realised system meets stakeholder intent per §4.3.6. Both produce `verification def` instances. The distinction lies in which acceptance the `objective { verify ... }` clause binds, and in which folder the file lives.

## When this skill triggers

Phrases that activate the skill:

- "write a verification case", "author a verification def".
- "write a validation case", "exercise stakeholder intent".
- "bind this acceptance to a verification def", "verify the acceptance criterion".
- "render the IVV Plan", "render the IVV Procedures".
- "verify the system", "exercise the system model".
- "check V&V coverage", "every acceptance has a case".

Routed in by `@story-orchestrator` whenever an acceptance criterion is being formalised on a story moving from `ready` to `inProgress`. Routed in by `@release-orchestrator` during the release baseline coverage check, where every acceptance on `main` must have at least one case bound. Routed in by `@architecture-design` when the architectural model needs verification cases authored against subsystem stories or control laws.

## Inputs

The project layout (per §8.3) provides:

- `model/core/verification-validation/verification-cases/`. System-level verification cases.
- `model/core/verification-validation/validation-cases/`. System-level validation cases.
- `model/core/logical-architecture/components/<comp>/verification-validation/{verification-cases,validation-cases}/`. Recursive subsystem-scope V&V per §8.3.2.

The story register provides:

- `model/core/stories/stakeholder/`. Stakeholder stories whose acceptance criteria are bound to validation cases.
- `model/core/stories/system/`. System stories whose acceptance criteria are bound to verification cases.
- `model/core/logical-architecture/components/<comp>/stories/`. Subsystem stories.

Each story carries one or more `acceptance` subrequirements per §1.4.4. Each acceptance may be the target of zero or more `verify` clauses. The methodology copy at `<project>/methodology/` is the authoritative reference and is read whenever a rule is in question.

## Workflow A: Validation case authoring (§4.3.6)

A validation case exercises stakeholder intent rather than system internals. It asks "does the system, as observed, satisfy what the stakeholder wanted?" Answers are typically obtained by demonstration, walkthrough, or operational test, not by an automated unit-level check.

1. Identify the stakeholder story and the acceptance subrequirement to be validated.
2. Author a `verification def` whose `subject` matches the stakeholder story's `subject`. The §4.3.6 example fixes this discipline.
3. Bind the acceptance via `objective { verify <story>::<acceptance>; }`.
4. Provide an action body that names the demonstration or operational fixture (collect, evaluate). The body may be deferred per §8.6.3 item 6, but a stub is mandatory at final review.
5. Place the file in `model/core/verification-validation/validation-cases/<name>.sysml`. Use `VAL_` as the case name prefix.

The pattern is the one shown in methodology §4.3.6:

```sysml
verification def VAL_AckFromDashboard {
    subject sys : Aiwell_OnlineSentral;

    objective {
        verify US_042_AckFromDashboard::acceptance;
    }

    action collectData { /* observed user task on representative hardware */ }
    action evaluate    { /* pass criterion in stakeholder vocabulary */ }
}
```

## Workflow B: Verification case authoring (§5.4.6)

A verification case exercises the system as modelled. It asks "does the system exhibit the required behaviour or property?" Answers are typically obtained by model execution, automated check, or simulation.

1. Identify the system story and the acceptance subrequirement to be verified.
2. Author a `verification def` whose `subject` matches the system story's `subject`.
3. Bind the acceptance via `objective { verify <story>::<acceptance>; }`. Where the story carries a `require constraint` (formalised benefit), a single case may verify both the constraint and the acceptance.
4. Provide an action body covering setup, measurement, and evaluation. Stubs are permitted at final review but must be populated by release per §10.5.3.
5. Place the file in `model/core/verification-validation/verification-cases/<name>.sysml`. Use `VC_` as the case name prefix.

The pattern is the one shown in methodology §5.4.6:

```sysml
verification def VC_BatchAckLatency {
    subject sys : Aiwell_OnlineSentral;

    objective {
        verify SYS_142_BatchAcknowledgement::sla;
        verify SYS_142_BatchAcknowledgement::acceptance;
    }

    action setup    { /* fixture preparation */ }
    action measure  { /* observation method */ }
    action evaluate { /* pass criterion in measurable form */ }
}
```

A single case may verify multiple acceptance criteria where they share a fixture. An acceptance criterion may be the target of multiple cases when different conditions warrant separate runs.

## Workflow C: Subsystem V&V (§7.3.7 and §7.3.8)

§7 architectural decomposition introduces new failure modes at subsystem boundaries. Each component identified in §7 is itself a system at its own scope per §8.3.2, so the same authoring discipline applies recursively.

- Subsystem-scoped verification cases live under `model/core/logical-architecture/components/<comp>/verification-validation/verification-cases/`.
- Subsystem-scoped validation cases live under `.../validation-cases/`. The "stakeholders" of a subsystem may be sibling subsystems, the parent system, or external actors local to the subsystem boundary.
- Each subsystem story's acceptance is bound the same way as a system story's acceptance, against the subsystem `part def` rather than the system `part def`.
- Where a control law (§7.3.6) is allocated across multiple subsystems, the case verifying that law belongs at the scope (system or component) that contains all the involved parts.

The §7.3.8 review questions are asked by `@architecture-design`, not here. This skill answers only "is the case well-formed and does it bind the right acceptance?".

## Workflow D: Coverage check

Walk the story register before any release baseline. For each story:

1. Read its `acceptance` subrequirements.
2. For each acceptance, find every `verification def` whose `objective` includes a `verify` clause naming that acceptance.
3. Record acceptance criteria with no bound case. These are gaps and are routed to `@story-orchestrator` for remediation.
4. Record verification cases whose action body is empty (stub state). Per §8.6.3 item 6, stubs are mandatory at final review. Per §10.5.3, bodies must be populated by release. The list is surfaced to the engineer.

Where the model size exceeds what the skill can hold in working context, dispatch to `@traceability-guard` with the trace rule "every acceptance shall be the target of at least one `verify` clause".

## Workflow E: IVV Plan and IVV Procedures rendering (§9.8)

Per §9.8 model-derived artefacts, the IVV Plan and IVV Procedures are *generated* from the model rather than authored.

- The IVV Plan is rendered from the `verification def` set: subjects, objectives, expected outcomes. It is the union of `model/core/verification-validation/` and every recursive component-scope equivalent.
- The IVV Procedures are rendered from the action bodies of those cases.
- Hand off to `@document-export` for the rendering itself. Refuse to render the IVV Plan if any acceptance criterion in the story register has no verification or validation case bound (route through Workflow D first).
- The renderer writes to `docs/generated/ivv-plan.md` and `docs/generated/ivv-procedures.md`. CI regenerates these on merge to `main` per §9.10. Confirm that the rendered files are current before reporting completion.

## Workflow F: V&V execution and reporting

Authoring stops at the `verification def`. Execution produces a Verification Report or Validation Report per the §10.10 templates.

- A Verification Report records the result of running a verification case against the model (or, downstream, the realised system). Each report cross-references the story or constraint it covers per §10.5.3.
- A Validation Report records the result of running a validation case with stakeholder participation in the operational context.
- The default storage location is `docs/verification-reports/<case>-<date>.md` and `docs/validation-reports/<case>-<date>.md`, subject to the project's CM Strategy (§10.8).
- Failures are recorded in the Correction Register at `docs/correction-register.md` per §10.5.2, with each correction following the normal PR workflow.

## Refusals

The skill refuses to act in the following cases.

- The verification case's `subject` does not match (or specialise) the story's `subject`. Per §4.3.6 and §5.4.6, the case binds to the story it verifies, and a subject mismatch makes the binding incoherent.
- The verification case's `objective` does not name an acceptance criterion of an existing story. There is nothing to verify.
- The IVV Plan is requested while one or more acceptance criteria in the story register have no bound case. The plan would misrepresent coverage. Route to Workflow D first.
- A story is asked to transition to `done` while its bound verification cases have empty bodies. Per §8.6.3 item 6 stubs are mandatory at final review, and per §10.5.3 bodies must be populated by release. The transition is blocked.

In each case, the skill states the rule, points to the methodology section, and proposes the corrective routing (typically back to Workflow D, or to `@story-orchestrator`).

## Hand-offs

| Situation | Route to |
|---|---|
| Story needs a verification case stub authored | `@story-orchestrator` |
| V&V coverage is the gate for a release baseline | `@release-orchestrator` |
| `verify` link surfaces as broken in the trace | `@traceability-guard` |
| The case body needs SysML v2 `verification def` syntax help | `@sysml2-cases` |
| The case requires `action def` execution detail | `@sysml2-behaviour` |
| IVV Plan or IVV Procedures rendering | `@document-export` |
| Verification Report or Validation Report rendering | `@document-export` |
| The case is being edited inside a baselined artefact | `@change-request` |

## Outputs

- `model/core/verification-validation/verification-cases/<name>.sysml`. System-level verification cases (§5.4.6).
- `model/core/verification-validation/validation-cases/<name>.sysml`. System-level validation cases (§4.3.6).
- `model/core/logical-architecture/components/<comp>/verification-validation/...`. Subsystem-scope equivalents per §8.3.2.
- `docs/generated/ivv-plan.md`. Rendered, not authored. Produced by `@document-export`.
- `docs/generated/ivv-procedures.md`. Rendered, not authored.
- `docs/verification-reports/<name>-<date>.md`. Execution-time, per §10.10.
- `docs/validation-reports/<name>-<date>.md`. Execution-time, per §10.10.

## Reference

`!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/verification-validation.md`
