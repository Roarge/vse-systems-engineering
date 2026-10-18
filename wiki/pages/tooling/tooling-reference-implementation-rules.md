---
title: "SysML v2 rules the reference implementations enforce"
slug: tooling-reference-implementation-rules
type: reference
layer: tooling
summary: SysML v2 forms the pilot and OpenSysML refuse or accept, from subject ordering to derivation and enum literals
tags: [validation, conformance, omg-pilot, opensysml, requirements, derivation, verify, satisfy, metadata, units, user-story, acceptance-criteria]
sources:
  - citation: "Systems-Modeling. Requirement Derivation domain library, RequirementDerivation.sysml, SysML v2 Pilot Implementation release 2026-07. https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation (accessed 2026-09)."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Probe and demo validation runs under the pilot 2026-07 and OpenSysML v0.6.0, recorded 2026-09-09."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Nested acceptance criteria runs on a probe package and a copy of the Smart Sensor demo model under the pilot 2026-07 and OpenSysML v0.6.0, recorded 2026-10-16."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Smart Sensor demo validation record, pilot 2026-07 on Java 21 and OpenSysML v0.6.0 over the sixteen model files, recorded 2026-10-17."
    raw: demo/smart-sensor/README.md
related:
  - tooling-omg-pilot-batch-validation
  - tooling-opensysml-cli
  - tooling-sysml-toolchain-choice
  - sysml2-requirements-semantics
  - sysml2-grammar-and-validation
  - sysml2-domain-libraries-causation-geometry
  - sysml2-vse-library-metadata
  - sysml2-case-kinds
  - sysml2-quantities-and-units
  - user-story-canonical-artefact
  - system-stories-workflow
  - behaviour-and-test-first
confidence: high
created: 2026-09-10
updated: 2026-10-18
referenced_by: [sysml-toolchain, sysml2-modelling, sysml2-cases, sysml2-metadata, needs-and-requirements, verification-validation, story-orchestrator, traceability-guard]
---

# SysML v2 rules the reference implementations enforce

## Contents

- The rules
- Validated pattern
- What each tool does not enforce
- See also

Syside 0.8 and OpenSysML v0.2.1 accepted several forms that the OMG pilot 2026-07 refuses, and the plugin's own templates and demo carried them. From release 4.0.0 the methodology examples, the templates, the demo, the renderer and the skills emit only the accepted forms. The central change is that a story is a requirement usage typed by the library definition, `requirement US_042_AckFromDashboard : UserStory { ... }`, because `verify`, `satisfy` and the derivation library all target usages. Every rule below was established by running both tools on probe models on 2026-09-09, except the named-criterion rule for a deep verify (a `verify` that reaches one named acceptance criterion by its full path, `verify <story>.acceptance.<name>`), which was established on 2026-10-16.

## The rules

| Rule | Refused form | Accepted form | Enforced by |
|---|---|---|---|
| Subject first | `requirement def R { stakeholder role : Op; subject s : Sys; }` | `subject` declared before `stakeholder` and `actor` | pilot |
| Trace targets are usages | `verify Story::acceptance`, `satisfy Def by x`, `end ::> Def` | `verify story.acceptance`, `satisfy story by x`, `end ::> story` | both |
| Dot notation for nested targets | `verify Story::member` | `verify story.member` | both |
| A deep verify names a declared criterion | `verify story.acceptance.readingArchived` with no criterion of that name | `verify story.acceptance.latestReadingShown`, with `requirement latestReadingShown { ... }` nested inside `requirement :>> acceptance` | both |
| `verify` needs a requirement usage | `verify story.sla` where `sla` is a `require constraint` | `requirement sla { require constraint { ... } }` then `verify story.sla` | OpenSysML v0.6.0 |
| `#derive` annotates usages | `#derive requirement def SYS_001 ...` | `#derive requirement SYS_001 : UserStory ...` | pilot |
| Derivation connection form | `connection x : RequirementDerivation::derivations { end ::> A; end ::> B; }` | `#derivation connection x { end #original ::> a; end #derive ::> b; }` | both |
| Objective subject redefinition | `objective r :> story;` in a use case | `objective r :> story { subject :>> system = sys; }` | pilot |
| `verify` only in verification cases | `objective { verify story; }` in a use case | the objective subsets the story instead | both |
| Attribute versus item typing | `attribute readingRef : Reading;` with `item def Reading` | `ref item readingRef : Reading;` | both |
| Qualified enumeration literals | `@StoryMeta { priority = high; }` | `@StoryMeta { priority = Priority::high; status = StoryStatus::ready; }` | both |
| No millisecond unit | `200 [ms]` with the 2026-07 library alone | a local `<ms>` declaration, see [[sysml2-quantities-and-units]] | both |

The derivation rules follow the library itself: `RequirementDerivation.sysml` declares the `derive` metadata with `baseType = derivations meta SysML::Usage`, and `DerivationConnections.sysml` declares `Derivation` as the connection definition and `derivations` as a connection usage, so a connection typed by `derivations` has no definition and its ends must subset usages.

## Validated pattern

The following package passes the pilot 2026-07 and OpenSysML v0.6.0 with no diagnostic. The templates and the demo use its forms, with one difference. Every story there, system stories included, nests one named criterion for each scenario of its Gherkin feature file, and every case verifies that criterion by its full path, where `VC_001` below keeps the shallow `verify SYS_001_DashboardLatency.acceptance`. The two named criteria inside `US_001_SeeReadings` and the case `VAL_001` that verifies each of them were added on 2026-10-16, and the whole package was validated again under both tools that day. The demo in that form was validated under both tools on 2026-10-17, with no diagnostic over its sixteen model files.

```sysml
package P {
    private import ScalarValues::*;
    private import RequirementDerivation::*;
    part def Sys; part def Op;

    requirement def UserStory {
        subject system;
        stakeholder role;
        attribute capability : String[0..1];
        requirement acceptance[0..*];
    }

    requirement US_001_SeeReadings : UserStory {
        subject :>> system : Sys;
        stakeholder :>> role : Op;
        attribute :>> capability = "see readings";
        requirement :>> acceptance {
            requirement latestReadingShown { doc /* the latest reading appears within 5 s */ }
            requirement staleReadingFlagged { doc /* a silent device shows its last reading as stale */ }
        }
    }

    #derive
    requirement SYS_001_DashboardLatency : UserStory {
        subject :>> system : Sys;
        stakeholder :>> role : Op;
        attribute maxDeliveryLatency : Rational = 5.0;
        requirement dashboardSla { require constraint { maxDeliveryLatency <= 5.0 } }
    }

    #derivation connection sys001Derives {
        end #original ::> US_001_SeeReadings;
        end #derive ::> SYS_001_DashboardLatency;
    }

    verification def VC_001 {
        subject sys : Sys;
        objective { verify SYS_001_DashboardLatency.dashboardSla; verify SYS_001_DashboardLatency.acceptance; }
    }

    verification def VAL_001 {
        subject sys : Sys;
        objective {
            verify US_001_SeeReadings.acceptance.latestReadingShown;
            verify US_001_SeeReadings.acceptance.staleReadingFlagged;
        }
    }

    use case def UC {
        subject sys : Sys;
        actor operator : Op;
        objective realises :> US_001_SeeReadings { subject :>> system = sys; }
    }

    part deployment { part sys : Sys; satisfy SYS_001_DashboardLatency by sys; }
}
```

The `@StoryMeta` line of a real story (`@StoryMeta { points = 5; priority = Priority::high; status = StoryStatus::ready; }`) is omitted here because the metadata definition and its enumerations come from the shipped `VSE_Library`, which the package would have to import, see [[sysml2-vse-library-metadata]]. The satisfying element and the case subject must conform to the story's subject type, otherwise both tools report `Bound features should have conforming types`.

**Named acceptance criteria.** A story may split its acceptance into named criteria. Each criterion is a requirement usage nested inside the story's `requirement :>> acceptance`, named in lowerCamelCase (a lower-case first letter and a capital at the start of each later word, as in `latestReadingShown`). A deep verify, `verify <story>.acceptance.<name>`, then verifies one criterion, as `VAL_001` does above. Each criterion mirrors one Gherkin scenario, see [[behaviour-and-test-first]]. The shallow `verify <story>.acceptance` still validates, and it covers every criterion at once. The 2026-10-16 runs used the pilot release 2026-07 (`jupyter-sysml-kernel-0.61.0.zip` on Java 21) and OpenSysML v0.6.0, each called through the plugin's toolchain library with `validate --tool <tool>`.

Besides the package above, the runs validated a copy of the Smart Sensor demo model, all 16 `.sysml` files, with the acceptance of `US_001_SeeReadingsOnDashboard` split into `latestReadingShown` and `staleReadingFlagged`, and with `VAL_001_OperatorSeeReadings` verifying each criterion by name. Both tools reported no diagnostic, and both still did when the case went back to the shallow `verify US_001_SeeReadingsOnDashboard.acceptance`. Two negative probes on the same copy failed under both tools with exit 1.

- A deep verify that names an undeclared criterion, `verify US_001_SeeReadingsOnDashboard.acceptance.readingArchived`. The pilot reports `Couldn't resolve reference to Feature 'readingArchived'`, and OpenSysML reports `unresolved reference: US_001_SeeReadingsOnDashboard::acceptance::readingArchived`.
- The valid deep verify of `staleReadingFlagged` with its closing semicolon removed. Both tools report a syntax error, the pilot as a run of `no viable alternative at input` lines and OpenSysML as `expected '{' or ';'`.

A misspelt criterion name is therefore caught by either tool, and the deep verify needs no tool-specific workaround.

## What each tool does not enforce

OpenSysML v0.6.0 does not enforce subject-first ordering, `#derive` on a definition, or the `Only one subject is allowed` rule for a case objective. The pilot in turn accepts a `verify` whose target is a bare `require constraint`, which OpenSysML v0.6.0 refuses. A model that passes one tool can therefore still fail the other, which is why the demo validates under both. Syside 0.8 tolerated every refused form in the table, so a project migrating from Syside should expect findings on its first pilot run and use the accepted-form column as the migration guide.

## See also

- [[tooling-omg-pilot-batch-validation]] and [[tooling-opensysml-cli]] for running the two tools.
- [[tooling-sysml-toolchain-choice]] for choosing between them.
- [[sysml2-requirements-semantics]] and [[sysml2-case-kinds]] for the requirement and case semantics behind the rules.
- [[sysml2-grammar-and-validation]] for the grammar checklist.
- [[sysml2-domain-libraries-causation-geometry]] for the derivation library.
- [[user-story-canonical-artefact]] and [[system-stories-workflow]] for the story form in the methodology.
