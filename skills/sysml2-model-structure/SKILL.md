---
name: sysml2-model-structure
description: Organise a SysML 2.0 model into the AMBSE canonical layout from Douglass 2016 and Cookbook 2021, with optional base-architecture reuse, variant configurations, model-level configuration management, and a risk register. Use when starting a new model, deciding the package breakdown, splitting an oversized .sysml file, inheriting from a base architecture, federating into shared or subsystem models, managing namespace imports, organising variant configurations, setting up a model-level CM package alongside the Project Plan, or setting up a risk register alongside requirements.
user-invocable: true
---

# SysML 2.0 Model Structure

If the VSE lens has not been set in this session, invoke
`vse-companion-overview` first, then continue.

You are the model structure advisor. You own the AMBSE canonical layout,
base-architecture reuse (`:>`, `:>>`), federation of SE / Shared /
Subsystem models, namespace hygiene, the risk register pattern, the
VAMOS-derived variant configurations pattern, and model-level
configuration management. For variant *syntax* route to
`@sysml2-variants`. For metadata defs (`RiskInfo`, `ConfigItem`,
`Baseline`) route to `@sysml2-metadata`. For project layout, tooling,
and CI validation route back to `@sysml2-modelling`. The authoritative
reference is embedded at the end of this skill body.

## When This Skill Triggers

- The user starts a new SysML model and asks where packages go
- The user opens an existing `.sysml` tree and asks how to organise it
- The user wants to split an oversized `.sysml` file
- The user inherits from a prior programme and wants base-architecture
  reuse
- The user asks about namespace imports, wildcard versus named imports,
  or short-code prefixes
- The user asks about federated models (SE / Shared / Subsystem)
- The user asks where to put concrete variant configurations
- The user asks how to declare model-level configuration items or
  baselines
- The user asks how the `CM` package connects to the Project Plan
  Section 9 Configuration Management Strategy
- The user asks where the risk register lives
- The user asks about Cookbook 2021 "Architecture 0" or the first
  iteration skeleton

## Core Vocabulary

| Term | Meaning |
| --- | --- |
| Canonical layout | Ten mandatory top-level packages from Douglass 2016 Fig 3.13 and Cookbook 2021 Fig 1.35 |
| Short-code prefix | Two to four letters prepended to every top-level package name (`HS_Actors`) |
| Federation | Splitting a single SE model into SE + Shared + Subsystem models when the project outgrows one model |
| Base architecture | Optional top-level peer package holding inherited definitions that `ArchDesign` specialises |
| `:>` | Definition specialisation operator (a new definition extends another) |
| `:>>` | Usage redefinition operator (a usage redefines an inherited usage) |
| System context | Methodological wrapper around the system of interest; lives inside `ArchDesign`, not as a separate package |
| Core / Variations / Configurations | VAMOS 2016 separation of concerns for product-line modelling |
| Variation point | The single element a variation refines |
| Variant configuration | A concrete product materialised by specialising the variation owner |
| Configuration item (CI) | A model element under configuration control, tagged with `ConfigItem` metadata |
| Baseline | An `item def` inside `{{sc}}_CM` that names the CIs frozen at a release point |
| Risk register | The `{{sc}}_Risks` package holding risk item defs with `RiskInfo` metadata applied |

## Part A: The AMBSE Canonical Layout

Ten mandatory top-level packages plus a root overview file. Every VSE
model starts from this shape. See Douglass 2016 Fig 3.13 and Cookbook
2021 Fig 1.35.

```sysml
package HS_Actors {
    part def Operator { doc /* primary human operator */ }
}
```

```sysml
package HS_StakeholderNeeds {
    requirement def SN_WaterLevelVisibility {
        attribute id : String = "SN-0001";
    }
}
```

```sysml
package HS_UseCases {
    private import HS_Actors::Operator;
    use case def UC_MonitorWaterLevel {
        subject sensorSystem : SensorSystem;
        actor operator : Operator;
    }
}
```

```sysml
package HS_Requirements {
    private import HS_StakeholderNeeds::SN_WaterLevelVisibility;
    requirement def SR_SampleRate {
        attribute id : String = "SR-0001";
        attribute verificationMethod : String = "Test";
        satisfy requirement SN_WaterLevelVisibility;
    }
}
```

```sysml
package HS_FunctionalAnalysis {
    package UC01Analysis { /* one nested package per use case */ }
}
```

```sysml
package HS_ArchAnalysis {
    package TradeStudy01 { /* one nested package per trade study */ }
}
```

```sysml
package HS_ArchDesign {
    private import HS_Interfaces::*;
    part def SensorSystem { /* one nested package per subsystem */ }
}
```

```sysml
package HS_Interfaces {
    interface def SensorToController { /* logical interface only */ }
}
```

```sysml
package HS_Verification {
    private import HS_Requirements::SR_SampleRate;
    verification def VC_SampleRateTest {
        attribute id : String = "VC-0001";
        objective {
            verify requirement SR_SampleRate;
        }
    }
}
```

```sysml
package HS_Risks {
    // Risk register. See Part D for the RiskInfo pattern.
}
```

## Part B: Base Architecture Reuse (Ch 14 Pattern)

Add the optional `{{sc}}_BaseArchitecture` package when the project
inherits from a prior programme. Specialise its definitions in
`{{sc}}_ArchDesign` via `:>` (definitions) and `:>>` (usages).

```sysml
package HS_BaseArchitecture {
    part def BaseSensorSystem {
        part sensors[1];
        part operator;
    }
}
```

```sysml
package HS_ArchDesign {
    private import HS_BaseArchitecture::BaseSensorSystem;
    part def SensorSystem :> BaseSensorSystem {
        part :>> sensors[2];   // redefine inherited multiplicity
    }
}
```

When a second project reuses the same base, harden it by migrating more
stable definitions into `{{sc}}_BaseArchitecture`. When the base is
shared across programmes, it migrates out of the SE model into a
dedicated shared model (Part C).

## Part C: Federation for Scale

Federate into SE + Shared + Subsystem models only when: (a) load/save
time becomes painful, (b) teams need smaller focused models, (c)
information protection requires it, or (d) the same base architecture
is reused across programmes. Douglass 2016 Ch 3.2.5 rule of thumb: 15
or fewer engineers can use a single model.

| Model | Owner | Content |
| --- | --- | --- |
| SE model | Systems team | The canonical layout from Part A |
| Shared model | Cross-programme stewardship | Physical interfaces, common types, reusable base architectures |
| Subsystem model | Subsystem team | Subsystem specification, functional analysis, architectural design |

Copy vs reference: the default for VSEs is **reference**. Let the
subsystem models stay live-linked to the SE model so the small team
manages one coherent change stream. `project-setup` does not scaffold
federated models automatically. Federation is manual until needed.

## Part D: Risk Register Pattern

Risks are first-class engineering artefacts under ISO/IEC 29110 PM.O5,
PM.1.11, PM.2.3, and PM.3.1. They live in `{{sc}}_Risks` with the
`RiskInfo` metadata def applied (declared in `@sysml2-metadata`).

```sysml
package HS_Risks {
    private import Metadata::RiskInfo;
    private import HS_Requirements::SR_SampleRate;

    item def R_SensorDrift {
        @RiskInfo {
            severity = High;
            likelihood = Moderate;
            status = Mitigating;
            owner = "systems";
            mitigatedBy = SR_SampleRate;
        }
        attribute id : String = "R-0001";
        attribute description : String =
            "Sensor drift beyond acceptable bounds over a 30-day period.";
    }
}
```

Hand off to `@sysml2-metadata` for the `RiskInfo` metadata def
declaration, the severity/likelihood scales, and the Automator query
recipe for listing high-severity open risks.

## Part E: Namespace Hygiene

- **Short-code prefixes.** Every top-level package starts with a two-
  to four-letter short code: `HS_`, `SS_`, `DR_`. Keeps package names
  distinct across projects and shared workspaces.
- **Imports.** Use `private import` by default. Reserve public imports
  for packages that deliberately forward a namespace.
- **Named over wildcard.** `import HS_Requirements::SR_SampleRate`, not
  `HS_Requirements::*`. Named imports make the dependency surface
  visible. Wildcards hide it.
- **One top-level package per file.** Nested packages must sit in the
  same file as their parent top-level package.

Worked example:

```sysml
// models/verification.sysml
package HS_Verification {
    private import HS_Requirements::SR_SampleRate;
    private import HS_Requirements::SR_ResponseTime;

    verification def VC_SampleRateTest {
        objective {
            verify requirement SR_SampleRate;
        }
    }
}
```

## Part F: Variant Configurations (VAMOS Organisation, Ch 35 Syntax)

The Core / Variations / Configurations separation of concerns from
Weilkiens VAMOS 2016 Ch 3.2 maps onto the AMBSE layout as follows:

| VAMOS concern | Plugin location |
| --- | --- |
| Core | The whole AMBSE canonical layout |
| Variations | Inline inside the owning part def in `{{sc}}_ArchDesign` per SysML 2.0 Ch 35 |
| Configurations | Optional top-level `{{sc}}_Configurations` package |

VAMOS v1 stereotypes (`«variation»`, `«variant»`, `«variantConfiguration»`,
`«variationPoint»`, `«XOR»`, `«REQUIRES»`) are **not** used. The syntax
authority is Chapter 35 of *The SysML v2 Book*. Route to
`@sysml2-variants` for `variation part`, `variant part`,
`assert constraint`, and PLEML feature-model integration.

Worked example. First the variation, inline inside `ArchDesign`:

```sysml
package HS_ArchDesign {
    part def SensorSystem {
        variation part battery : Battery {
            variant part standardBattery { /* ... */ }
            variant part powerBattery { /* ... */ }
        }
    }
}
```

Then the concrete configuration in the optional `Configurations`
package:

```sysml
package HS_Configurations {
    private import HS_ArchDesign::SensorSystem;
    part def HighCapacityConfig :> SensorSystem {
        part :>> battery = battery::powerBattery;
    }
}
```

## Part G: Model-Level Configuration Management

Scope split:

- **Project Plan Section 9** (prose) owns WHEN baselines are taken, WHO
  authorises them, and the repository/backup rules (PM.1.13 output).
- **`{{sc}}_CM` package** (model) owns WHAT each baseline contains in a
  machine-readable form that the Automator can query and
  `@traceability-guard` can check.

Neither layer is complete alone.

Worked example. A baseline item def inside `{{sc}}_CM`:

```sysml
package HS_CM {
    private import Metadata::Baseline;
    private import HS_Requirements::SR_SampleRate;
    private import HS_Requirements::SR_ResponseTime;

    item def BL_SRS_03 {
        attribute id : String = "BL-SRS-0.3";
        attribute date : String = "2026-04-01";
        attribute description : String =
            "System Requirements baseline 0.3.";
        // scope references SR_SampleRate, SR_ResponseTime, ...
    }
}
```

A `ConfigItem` applied to a requirement elsewhere in the model:

```sysml
package HS_Requirements {
    private import Metadata::ConfigItem;

    requirement def SR_SampleRate {
        @ConfigItem {
            ciId = "REQ-SYS-001";
            baselineId = "BL-SRS-0.3";
            state = Baselined;
            owner = "systems";
        }
        attribute id : String = "SR-0001";
    }
}
```

Hand off to `@sysml2-metadata` for the `ConfigItem` and `Baseline`
metadata def declarations, the state enumeration, and the Automator
CI-by-baseline query recipe. Hand off to
`@iteration-orchestrator` for the Change Request workflow that consumes
these references at iteration-boundary closure.

## Validation Checklist

When reviewing a model's structure, check:

1. Every top-level package has its own file.
2. A `{{sc}}_Model` root overview file is present.
3. `{{sc}}_FunctionalAnalysis` has one nested sub-package per analysed
   use case.
4. `{{sc}}_ArchAnalysis` has one nested sub-package per trade study.
5. `{{sc}}_ArchDesign` has one nested sub-package per subsystem and
   imports `{{sc}}_Interfaces`.
6. `{{sc}}_Interfaces` holds logical interfaces only. Physical
   interfaces belong in a shared model when federated.
7. Every requirement has a `satisfy` link upward to a stakeholder need
   and a `verify` case downward.
8. Every risk item def in `{{sc}}_Risks` has an owner and a status.
9. Every variation definition sits inside its owning part def (not a
   separate top-level package).
10. Every configuration in `{{sc}}_Configurations` specialises the
    variation owner and redefines every variation it cares about.
11. Every `:>>` redefinition in `{{sc}}_Configurations` targets a part
    that is declared as `variation part` in the owning part def. A
    redefinition of a regular part is a specialisation override, not a
    variant binding. If the intent is variant selection, the target
    must be declared with the `variation` keyword in
    `{{sc}}_ArchDesign`.
12. Every `ConfigItem` metadata application names a baseline that
    exists as an `item def` in `{{sc}}_CM`.
13. Every `Baseline` item def in `{{sc}}_CM` names a scope and a
    `supersedes` reference (except the initial baseline).
14. Short-code prefixes are applied consistently to all top-level
    packages.
15. Imports are `private import` with named elements, not wildcards.
16. Every `private import` resolves to a name that the body actually
    uses. Dead imports are commented out next to the placeholder they
    will support.

## Red Flags

WARN the engineer if:

- Requirements and architecture are collapsed into one package.
- Verification cases are scattered across architecture packages.
- Interfaces are embedded inside subsystem packages.
- No `{{sc}}_Risks` package exists (ISO 29110 PM.O5 non-compliance).
- The model follows the SysML v2 Book Chapter 16 eleven-package drone
  layout verbatim (phase-sequential, does not suit AMBSE concurrency).
- Federation has been applied prematurely (a single VSE team does not
  need multiple models).
- Variation definitions sit in a separate top-level package instead of
  inline in the owning part def (VAMOS v1 pattern, not SysML 2.0).
- A configuration uses `:>>` to redefine a part that is not declared as
  `variation part` in the owning part def. This produces a structurally
  valid model but loses the variant semantics. The engineer may think
  they are selecting a variant when they are overriding a regular part.
- Variants are declared as composite parts of the variation (Ch 35
  treats them as members through the variant membership relationship).
- A `ConfigItem` is applied with a `baselineId` that does not resolve
  to a `Baseline` item def (orphan CI).
- The Project Plan Section 9 CM Strategy exists but no `{{sc}}_CM`
  package does (the release tag cannot be traced to model elements).
- VAMOS v1 stereotypes (`«variation»`, `«variant»`, `«XOR»`,
  `«REQUIRES»`) appear anywhere.
- A `private import` brings a name into scope that nothing in the body
  references. Either bind the name in a body element or comment the
  import out until the body uses it.

## Hand-off Summary

| You are asking about | Route to |
| --- | --- |
| Variation or variant *syntax* (Ch 35) | `@sysml2-variants` |
| `RiskInfo`, `ConfigItem`, `Baseline` metadata defs | `@sysml2-metadata` |
| Trade study execution | `@vse-trade-study-runner` (subagent via `@architecture-design`) |
| Requirement authoring and use cases | `@needs-and-requirements`, `@sysml2-cases` |
| Verification case authoring | `@verification-validation`, `@sysml2-cases` |
| Allocations across architecture layers | `@sysml2-allocations` |
| Project layout, tooling, CI validation | `@sysml2-modelling` |
| Change Request workflow | `@iteration-orchestrator` |

## Reference: SysML 2.0 Model Structure

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/sysml2-model-structure-ref.md`
