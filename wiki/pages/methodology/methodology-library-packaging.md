---
title: "Methodology library packaging (forthcoming work)"
slug: methodology-library-packaging
type: concept
layer: methodology
summary: The planned section 0.8 packaging of the methodology as a SysML v2 library, not yet realised
tags: [library-package, semantic-metadata, user-defined-keywords, sysml2-ch41, deferred]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §0.8 (Forthcoming Work — Methodology Library Packaging)."
    raw: methodology/00-methodology-overview.md
related:
  - methodology-overview
  - user-story-canonical-artefact
  - storymeta-lifecycle
confidence: high
created: 2026-05-05
updated: 2026-09-10
referenced_by: []
---

# Methodology library packaging (forthcoming work)

## Forecast

Section 0.8 of the methodology specification announces a packaging step for the constructs this methodology introduces. They shall be packaged as a SysML v2 `library package` named `MBSEMethodology` (working title), so that downstream projects adopt the methodology by `import` rather than by re-declaration. Part of the step is already taken: the shipped realisation is `VSE_Library`, which `@project-setup` copies into a project as `model/library/vse-library.sysml` and which every stories package imports so that its stories can be typed by `UserStory`. What remains outstanding is the standalone library package, for which the `MBSEMethodology` name stays reserved, together with the user-defined keyword layer described below. The constructs in scope are:

- `UserStory`, the requirement definition that every story usage is typed by (see [[user-story-canonical-artefact]]).
- `StoryMeta` and the lifecycle status enumeration that drives the branch and pull-request mapping (see [[storymeta-lifecycle]]).
- `StakeholderNeed` as the upstream tier above stakeholder stories.
- The role and actor coupling pattern that links `part def` roles to external `actor` types.
- The `frame concern` discipline that records out-of-scope decisions.
- The variation-based trade-study pattern that uses `variation requirement def` for option enumeration.

The intent is to make the methodology adoptable as a single dependency, rather than copied prose, in any project that uses SysML v2 tooling.

## Two supporting SysML v2 mechanisms

The SysML v2 specification, chapter 41, provides two mechanisms that together support the packaging step.

### Model libraries

Methodology elements are declared once inside a `library package`. A project model then writes:

```sysml
import MBSEMethodology::*;
```

and inherits the full set of methodology constructs without restating their definitions. A library package marks its members as reusable across projects, which is the textbook fit for a methodology backbone.

### Semantic metadata for user-defined keywords

Keywords such as `#userStory`, `#stakeholderStory`, `#systemStory`, and `#subsystemStory` may be declared as `Metaobjects::SemanticMetadata` specialisations. Each metadata definition redefines `baseType` to point at the corresponding methodology element. The keyword then acts as syntactic sugar for the underlying typing.

## Worked example

With the library in place, a project model that declares a user story becomes shorter and more uniform:

```sysml
package SmartSensor_Stories {
    private import VSE_Library::*;

    #userStory requirement US_042 {
        doc /* As a maintenance technician, I want to read the
             * sensor's last calibration date, so that I can plan
             * the next calibration window. */
    }
}
```

Without the keyword, the same story is written `requirement US_042 : UserStory { ... }` against the imported `VSE_Library`, and the engineer must remember to name the type explicitly. The keyword form removes that burden and makes the methodology classification machine-checkable at parse time.

## Status and dependencies

Library packaging is deferred. The methodology specification states two preconditions before the library is built:

1. The foundational sections (§1 to §3) shall be stable. These cover user stories, base architecture, and system context, which are the primary sources of construct definitions.
2. At least one workflow stage shall be stable, so that the library reflects constructs that have actually been exercised in a workflow, rather than speculative ones.

Until those preconditions hold, projects adopt the constructs by importing their copy of `VSE_Library` rather than by re-declaring them, and the keyword layer stays unbuilt. The methodology specification itself is the design input for the library, and the library, once built, is the machine-readable counterpart of that specification. The two artefacts are intended to evolve together, with the prose remaining the authoritative source and the library the import target.

## Why this matters for the VSE companion

For the VSE companion, the planned `MBSEMethodology` package is a forward-looking reference rather than a current dependency, because the constructs already reach projects through `VSE_Library`. Skill guidance therefore treats them as imported from the project's copy of that library. Once `MBSEMethodology` ships, skills that emit SysML v2 text shall be updated to prefer the keyword form and the library import. The transition is therefore additive, and existing project models built without the library remain valid.

## Cross-links

- [[methodology-overview]]
- [[user-story-canonical-artefact]]
- [[storymeta-lifecycle]]
