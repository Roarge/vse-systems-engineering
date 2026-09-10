---
title: "SysML v2 rules the reference implementations enforce"
slug: tooling-reference-implementation-rules
type: reference
layer: tooling
summary: SysML v2 forms the pilot and OpenSysML refuse or accept, from subject ordering to derivation and enum literals
tags: [validation, conformance, omg-pilot, opensysml, requirements, derivation, verify, satisfy, metadata, units, user-story]
sources:
  - citation: "Systems-Modeling. Requirement Derivation domain library, RequirementDerivation.sysml, SysML v2 Pilot Implementation release 2026-07. https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation (accessed 2026-09)."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Probe and demo validation runs under the pilot 2026-07 and OpenSysML v0.6.0, recorded 2026-09-09."
    raw: null
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
confidence: high
created: 2026-09-10
updated: 2026-09-10
referenced_by: [sysml-toolchain, sysml2-modelling, sysml2-cases, sysml2-metadata, needs-and-requirements, verification-validation, story-orchestrator, traceability-guard]
---

# SysML v2 rules the reference implementations enforce

## Contents

- The rules
- Validated pattern
- What each tool does not enforce
- See also

Syside 0.8 and OpenSysML v0.2.1 accepted several forms that the OMG pilot 2026-07 refuses, and the plugin's own templates and demo carried them. From release 4.0.0 the methodology examples, the templates, the demo, the renderer and the skills emit only the accepted forms. The central change is that a story is a requirement usage typed by the library definition, `requirement US_042_AckFromDashboard : UserStory { ... }`, because `verify`, `satisfy` and the derivation library all target usages. Every rule below was established by running both tools on probe models on 2026-09-09.

## The rules

| Rule | Refused form | Accepted form | Enforced by |
|---|---|---|---|
| Subject first | `requirement def R { stakeholder role : Op; subject s : Sys; }` | `subject` declared before `stakeholder` and `actor` | pilot |
| Trace targets are usages | `verify Story::acceptance`, `satisfy Def by x`, `end ::> Def` | `verify story.acceptance`, `satisfy story by x`, `end ::> story` | both |
| Dot notation for nested targets | `verify Story::member` | `verify story.member` | both |
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

The following package passes the pilot 2026-07 and OpenSysML v0.6.0 with no diagnostic. It is the shape the templates and the demo now use.

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
        requirement :>> acceptance { doc /* readings appear within 5 s */ }
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

    use case def UC {
        subject sys : Sys;
        actor operator : Op;
        objective realises :> US_001_SeeReadings { subject :>> system = sys; }
    }

    part deployment { part sys : Sys; satisfy SYS_001_DashboardLatency by sys; }
}
```

The `@StoryMeta` line of a real story (`@StoryMeta { points = 5; priority = Priority::high; status = StoryStatus::ready; }`) is omitted here because the metadata definition and its enumerations come from the shipped `VSE_Library`, which the package would have to import, see [[sysml2-vse-library-metadata]]. The satisfying element and the case subject must conform to the story's subject type, otherwise both tools report `Bound features should have conforming types`.

## What each tool does not enforce

OpenSysML v0.6.0 does not enforce subject-first ordering, `#derive` on a definition, or the `Only one subject is allowed` rule for a case objective. A model that passes OpenSysML can therefore still fail the pilot, which is why the demo validates under both and why the pilot sits before OpenSysML in the fallback order. Syside 0.8 tolerated every refused form in the table, so a project migrating from Syside should expect findings on its first pilot run and use the accepted-form column as the migration guide.

## See also

- [[tooling-omg-pilot-batch-validation]] and [[tooling-opensysml-cli]] for running the two tools.
- [[tooling-sysml-toolchain-choice]] for choosing between them.
- [[sysml2-requirements-semantics]] and [[sysml2-case-kinds]] for the requirement and case semantics behind the rules.
- [[sysml2-grammar-and-validation]] for the grammar checklist.
- [[sysml2-domain-libraries-causation-geometry]] for the derivation library.
- [[user-story-canonical-artefact]] and [[system-stories-workflow]] for the story form in the methodology.
