---
name: sysml2-metadata
description: Apply SysML 2.0 metadata, reflection, and user-defined keywords, including the RiskInfo risk library and the ConfigItem and Baseline configuration management library. Use when tagging elements with risk, configuration item state, priority, or status metadata, when defining user keywords, when declaring baselines, or when querying model elements by applied metadata.
user-invocable: true
---

# SysML 2.0 Metadata, Reflection, and Language Extension

If you are inside a VSE project (`.vse-iteration.yml` present at the project root) and the VSE lens has not been set this session, invoke `vse-companion-overview` first, then continue. In a SysML-only repository (no `.vse-iteration.yml`), skip the lens and proceed directly with this skill.

You guide the engineer through metadata, reflection, and user-defined
keywords in SysML 2.0. Metadata is the official extension mechanism
for the language. It supports tagging, filtering, user-defined
keywords, and domain libraries. This skill owns the **VSE Library**
(`VSE_Library` package), which is the single definition site for all
reusable metadata and enumerations the plugin uses across AMBSE
workflow skills. The library contains: the `RiskInfo` risk library
that backs the `{{sc}}_Risks` register, the `ConfigItem` and
`Baseline` library that backs `{{sc}}_CM`, and the variant-aware
`VariantScope` and `VerificationScope` metadata for VAMOS
organisation. For project layout and tooling, route back to
`@sysml2-modelling`. For the canonical `{{sc}}_Risks` and `{{sc}}_CM`
package structures, route to `@sysml2-model-structure`. For filter
expressions inside view definitions, route to `@sysml2-views`.

## Migration Note

Projects created before the VSE Library was introduced may have
declared `RiskInfo`, `ConfigItem`, `Baseline`, and their enumerations
inline in a per-project `Metadata` package. Those declarations still
work. New projects should import from `VSE_Library` instead
(`private import VSE_Library::RiskInfo`). Existing projects can
migrate at their own pace by replacing `Metadata::` imports with
`VSE_Library::` imports and removing the inline declarations. The
library package name is `VSE_Library`, not `Metadata`, so there is
no collision during migration.

## When This Skill Triggers

- The user wants to tag elements with categories such as baselines,
  risks, or security classifications
- The user wants to filter package imports or view contents by
  metadata
- The user asks for a project-specific keyword with `#` syntax
- The user wants to introduce a domain library that extends SysML
- The user wants to declare a risk with severity, likelihood, and
  status fields
- The user wants to query the model for all open high-severity risks
- The user wants to declare a baseline or tag a model element as a
  configuration item under a baseline
- The user wants to list every configuration item frozen in a given
  baseline

## Core Vocabulary

| Element | Keyword | Purpose |
| --- | --- | --- |
| Metadata definition | `metadata def` | Declares a metadata type |
| Metadata usage | `metadata`, `@Type` | Annotates a model element |
| SemanticMetadata | `SemanticMetadata` | Registers a user-defined keyword |
| Metaclassification | `@`, `@@`, `meta` | Tests classification at run time |
| Filter condition | `filter`, `[...]` | Metadata-based selection |

## Authoring Patterns

### Metadata Definition

```sysml
metadata def ApprovedBaseline {
    attribute baselineId : String;
    attribute approvedOn : String;
}
```

Metadata definitions specialise a kernel metadata base. The attributes
become tag fields that appear on every usage.

### Applying Metadata to an Element

```sysml
@ApprovedBaseline {
    baselineId = "2026-04-01-R2";
    approvedOn = "2026-04-01";
}
requirement def SR3_SensorAccuracy {
    doc /* The sensor shall report temperature within +/- 0.5 K. */
}
```

Annotations use the `@` prefix directly above the annotated element.
The values bind to the metadata attributes.

### Metaclassification Expression

```sysml
attribute isBaselined : Boolean = SR3_SensorAccuracy@@ApprovedBaseline;
```

`@` tests whether a value is classified by a type. `@@` tests whether
an element has a given metadata annotation, which is a metaclass-level
check.

### Filter over a Package Import

```sysml
package ActiveRequirements {
    import SystemRequirements::* [@ApprovedBaseline];
}
```

A bracketed filter after an import brings in only elements that carry
the specified metadata. This is called a smart package in the book.

### User-Defined Keyword via SemanticMetadata

```sysml
metadata def functionalAllocation
    :> Metaobjects::SemanticMetadata
{
    attribute :>> baseType = FunctionalAllocation;
}
```

After registering the keyword, usages can shorten the allocation call
site to the `#` form:

```sysml
#functionalAllocation allocate navigation to navigationSubsystem;
```

See `@sysml2-allocations` for the allocation usage form that this
keyword shortcuts.

### Risks as a Metadata Library

The book's Ch 38 ships a Risks library implemented as metadata usages.
The plugin carries this pattern forward as the `RiskInfo` library
declared below. See the `sysml2-metadata-definitions` and
`sysml2-vse-library-metadata` atomic pages for the book schema and
the plugin form respectively.

## Risk Library (RiskInfo)

The `RiskInfo` metadata def is the plugin's concrete risk-tagging
library. It backs the `{{sc}}_Risks` package from
`@sysml2-model-structure` and satisfies ISO/IEC 29110 PM.O5
(Risk identified and monitored), PM.1.11 (document Risk Management
Approach), PM.2.3 (review risk status in revision meetings), and
PM.3.1 (evaluate progress including risk).

### RiskInfo Metadata Def

The canonical definition lives in `VSE_Library`
(`templates/common/library/vse-library.sysml`). The definition is
reproduced here for reference:

```sysml
// Inside VSE_Library (do not redeclare in user projects)
metadata def RiskInfo {
    attribute severity : Severity;
    attribute likelihood : Likelihood;
    attribute status : RiskStatus;
    attribute owner : String;
    attribute mitigatedBy : Anything[0..*];
}
```

`mitigatedBy` is an open-ended reference list so a risk can point at
one requirement, one verification case, or several. The `Severity`,
`Likelihood`, and `RiskStatus` enumerations also live in
`VSE_Library`. User projects must import the enums explicitly
alongside `RiskInfo` when they need to reference enum members by
name (for example, `Severity::High`). See the standalone risk
example below for the full import set.

### Applying RiskInfo to a Standalone Risk

```sysml
package HS_Risks {
    private import VSE_Library::RiskInfo;
    private import VSE_Library::Severity;
    private import VSE_Library::Likelihood;
    private import VSE_Library::RiskStatus;
    private import HS_Requirements::SR_SampleRate;

    item def R_SensorDrift {
        @RiskInfo {
            severity = Severity::High;
            likelihood = Likelihood::Moderate;
            status = RiskStatus::Mitigating;
            owner = "systems";
            mitigatedBy = SR_SampleRate;
        }
        attribute id : String = "R-0001";
        attribute description : String =
            "Sensor drift beyond acceptable bounds over a 30-day period.";
    }
}
```

### Applying RiskInfo to a Requirement

```sysml
package HS_Requirements {
    private import VSE_Library::RiskInfo;
    private import VSE_Library::Severity;
    private import VSE_Library::Likelihood;
    private import VSE_Library::RiskStatus;

    requirement def SR_SampleRate {
        @RiskInfo {
            severity = Severity::High;
            likelihood = Likelihood::Low;
            status = RiskStatus::Mitigating;
            owner = "systems";
        }
        attribute id : String = "SR-0001";
        doc /* The sensor shall sample at 10 Hz or higher. */
    }
}
```

Use this form when a risk is tightly coupled to a single requirement
and does not need a standalone entry in the risk register.

### Automator Query: High-Severity Open Risks

```python
from syside import Model

model = Model.load("models/")
for element in model.elements_with_metadata("VSE_Library::RiskInfo"):
    risk = element.metadata("VSE_Library::RiskInfo")
    if (risk.severity in ("High", "VeryHigh", "Critical")
            and risk.status in ("Open", "Mitigating")):
        print(f"{element.qualified_name}: {risk.severity} / {risk.status}")
```

The query is advisory. A full risk-management workflow skill covering
the identify-assess-mitigate-monitor loop is flagged as a follow-up.
See `knowledge/syside-automator-ref.md` for the Automator API.

### ISO 29110 Framing

PM.O5 (Risk identified and monitored) becomes a model query rather
than a spreadsheet update. PM.1.11 writes the Risk Management
Approach into the Project Plan. PM.2.3 re-runs the Automator query
at each revision meeting. PM.3.1 uses the same query at iteration-
boundary closure inside `@iteration-orchestrator`.

## Configuration Management Library (ConfigItem, Baseline)

The `ConfigItem` metadata def and the `Baseline` item def pattern
give the model a machine-readable surface for configuration
management. They back the `{{sc}}_CM` package from
`@sysml2-model-structure` and complement (not replace) the Project
Plan Section 9 Configuration Management Strategy (PM.1.13 output)
and the SEMP Section 4.3 stub. Together they satisfy ISO/IEC 29110
PM.1.13, PM.1.18 (Establish Project Repository), PM.2.5 (Perform
configuration management), PM.O6 (System Configuration baselined),
and SR.O6 (System Configuration baselined at handover).

### ConfigItem Metadata Def

The canonical definition lives in `VSE_Library`. Reproduced here for
reference:

```sysml
// Inside VSE_Library (do not redeclare in user projects)
metadata def ConfigItem {
    attribute ciId : String;
    attribute baselineId : String;
    attribute state : CIState;
    attribute owner : String;
}
```

`baselineId` is a string reference to a `Baseline` item def declared
in `{{sc}}_CM`. The string form keeps the metadata application light
and keeps the trace resolvable by Automator query. `CIState` is an
enumeration also defined in `VSE_Library`.

### Baseline Item Def

```sysml
package HS_CM {
    private import VSE_Library::Baseline;
    private import HS_Requirements::SR_SampleRate;
    private import HS_Requirements::SR_ResponseTime;

    item def BL_SRS_03 {
        attribute id : String = "BL-SRS-0.3";
        attribute date : String = "2026-04-01";
        attribute description : String =
            "System Requirements baseline 0.3.";
        // scope references the CIs frozen at this baseline:
        // SR_SampleRate, SR_ResponseTime, ...
        // supersedes : BL_SRS_02
    }
}
```

The `scope` attribute is a reference list of the CIs frozen at the
baseline. The `supersedes` attribute names the previous baseline in
the chain and is empty for the initial baseline.

### Baseline Metadata Def

The `Baseline` metadata def lives alongside `ConfigItem` and
`RiskInfo` in `VSE_Library` so the `{{sc}}_CM` item defs carry
machine-readable scope information that Automator can walk.

```sysml
// Inside VSE_Library (do not redeclare in user projects)
metadata def Baseline {
    attribute baselineId : String;
    attribute date : String;
    attribute scope : Anything[0..*];
    attribute supersedes : Anything[0..1];
}
```

### Applying ConfigItem to a Requirement

```sysml
package HS_Requirements {
    private import VSE_Library::ConfigItem;
    private import VSE_Library::CIState;

    requirement def SR_SampleRate {
        @ConfigItem {
            ciId = "REQ-SYS-001";
            baselineId = "BL-SRS-0.3";
            state = CIState::Baselined;
            owner = "systems";
        }
        attribute id : String = "SR-0001";
        doc /* The sensor shall sample at 10 Hz or higher. */
    }
}
```

### Applying ConfigItem to a Part Def

```sysml
package HS_ArchDesign {
    private import VSE_Library::ConfigItem;
    private import VSE_Library::CIState;

    part def SensorSystem {
        @ConfigItem {
            ciId = "ARCH-SYS-001";
            baselineId = "BL-ARCH-0.2";
            state = CIState::Baselined;
            owner = "systems";
        }
        // part body ...
    }
}
```

### Automator Query: CIs by Baseline

```python
from syside import Model

model = Model.load("models/")
target_baseline = "BL-SRS-0.3"
baselined = []
not_yet = []
for element in model.elements_with_metadata("VSE_Library::ConfigItem"):
    ci = element.metadata("VSE_Library::ConfigItem")
    if ci.baselineId != target_baseline:
        continue
    if ci.state == "Baselined":
        baselined.append((ci.ciId, element.qualified_name))
    else:
        not_yet.append((ci.ciId, ci.state, element.qualified_name))
print(f"In {target_baseline}: {len(baselined)} baselined,",
      f"{len(not_yet)} not yet at state Baselined")
```

The second list is the orphan-CI surface `@traceability-guard`
checks at iteration-boundary closure. A full model-level CM workflow
skill covering the identify-baseline-change-retire loop is flagged
as a follow-up.

### Authority Boundary

Neither layer is complete alone. The Project Plan Section 9
Configuration Management Strategy owns WHEN baselines are taken,
WHO authorises them, and the repository and backup rules (the prose
and the governance). The `{{sc}}_CM` package and the `ConfigItem`
metadata own WHAT each baseline contains (the machine-readable CI
and baseline data that Automator can query and that
`@traceability-guard` can check). A release tag on `main` names a
baseline declared in `{{sc}}_CM`, and the tag message points back at
Section 9 for the governance authority.

### ISO 29110 Framing

PM.1.13 (Document the Configuration Management Strategy) writes the
Project Plan Section 9 prose and additionally scaffolds the
`{{sc}}_CM` package if the engineer opts in during `@project-setup`.
PM.1.18 (Establish the Project Repository) initialises the
repository and the first baseline. PM.2.5 (Perform configuration
management) updates `ConfigItem` metadata on each configuration
event and creates a new `Baseline` item def on each baseline event.
SR.O6 (System Configuration baselined) is satisfied when the
release-tag baseline exists and every SR-produced artefact named in
its scope is in the `Baselined` state.

## Variant-Aware Metadata (VariantScope, VerificationScope)

The `VariantScope` and `VerificationScope` metadata defs support
VAMOS variant organisation across the AMBSE layout. Both live in
`VSE_Library` and are available to any project that imports the
library (Minimal and Canonical tiers).

### VariantScope

Tags any element with the configuration(s) it applies to. Use on
risks, requirements, or other elements that are specific to one or
more variant configurations. Omit when the element applies to all
configurations (shared).

```sysml
package HS_Risks {
    private import VSE_Library::RiskInfo;
    private import VSE_Library::VariantScope;
    private import VSE_Library::Severity;
    private import VSE_Library::Likelihood;
    private import VSE_Library::RiskStatus;

    item def R_BatteryOverheat {
        @RiskInfo {
            severity = Severity::High;
            likelihood = Likelihood::Moderate;
            status = RiskStatus::Open;
            owner = "systems";
        }
        @VariantScope {
            configurations = ("HighCapacity",);
        }
        attribute id : String = "R-0003";
        attribute description : String =
            "Battery overheat risk specific to the high-capacity configuration.";
    }
}
```

### VerificationScope

Tags a verification case with the configuration(s) it targets. Used
by `@traceability-guard` Rule 6 (advisory) and by SR.6
per-configuration report export.

```sysml
package HS_Verification {
    private import VSE_Library::VerificationScope;
    private import HS_Requirements::SR_BatteryLifetime;

    verification def VC_BatteryLifetimeHighCap {
        @VerificationScope {
            configurations = ("HighCapacity",);
        }
        objective {
            verify requirement SR_BatteryLifetime;
        }
    }
}
```

### Variant-scoping rule for 29110 products

During SR.2 through SR.5, each 29110 work product is one instance with
inline variant branches. Variant-specific elements are tagged with
`@VariantScope` or `@VerificationScope`. At the macrocycle boundary
(SR.6 delivery), configuration-scoped exports are generated from the
single model by filtering on these metadata tags. This prevents work
product explosion while preserving per-configuration documentation at
delivery.

## Validation Checklist

1. **Keyword metadata definitions specialise `Metaobjects::SemanticMetadata`.**
   Annotation metadata defs (used via `@MetaName` above an element) may
   be bare and do not need a base class. The specialisation is required
   only when the metadata def will be used as a keyword shortcut via
   `#keyword`.
2. **Annotations use `@` above the element**, not inside its body.
3. **User-defined keywords have a `SemanticMetadata` specialisation.**
   Without it, the keyword form is just a plain comment.
4. **Filter expressions are Boolean.** Mixing metadata classification
   with runtime values in a single filter usually means the intent is
   better expressed as a constraint.
5. **All metadata defs are library-supplied from `VSE_Library`**, not
   hand-rolled. Projects should import `RiskInfo`, `ConfigItem`,
   `Baseline`, `VariantScope`, and `VerificationScope` from
   `VSE_Library` rather than redefine them.
6. **Every `RiskInfo` application has a named owner and a status.**
   An unowned or status-free risk is a silent debt under ISO 29110
   PM.3.1.
7. **Every `ConfigItem` application names a `baselineId` that resolves
   to a `Baseline` item def in `{{sc}}_CM`.** An unresolvable
   `baselineId` is an orphan CI.
8. **Every `Baseline` item def has a `scope` reference list and
   a `supersedes` attribute** (empty only for the initial baseline).

## Red Flags

WARN the engineer if:

- A keyword is used without a matching `SemanticMetadata` registration
- A filter reference uses `@` where `@@` was required (classifier
  versus metaclass confusion)
- A metadata annotation sits inside an element body rather than above
  the element
- A smart package filter is written with `filter` inside the package
  body instead of `[...]` on the import line (different semantics)
- A risk record is modelled as an attribute on the requirement rather
  than as a `@RiskInfo` metadata annotation
- A risk is declared with severity or likelihood values drawn from an
  ad-hoc string scale instead of the `Severity` and `Likelihood`
  enumerations from `VSE_Library`
- A project package redeclares `metadata def RiskInfo`, `ConfigItem`,
  `Baseline`, or any enumeration that already lives in `VSE_Library`
- A `ConfigItem` is applied with a `baselineId` that does not resolve
  to a `Baseline` item def anywhere in the model (orphan CI)
- The Project Plan Section 9 CM Strategy exists but no `{{sc}}_CM`
  package does, so the release tag cannot be traced to model elements
- A `Baseline` item def is declared without a `scope` reference list,
  which leaves `@traceability-guard` unable to check CI coverage at
  iteration-boundary closure

## Reference: SysML 2.0 Metadata

!`cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/sysml2-metadata.md`
