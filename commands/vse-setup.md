---
description: Bootstrap a new VSE systems engineering project (greenfield or brownfield)
argument-hint: "[optional notes about the project]"
---

Invoke the `vse-systems-engineering:project-setup` skill to bootstrap a VSE
systems engineering project aligned with ISO/IEC 29110.

Pass the user-supplied arguments through as additional context for the skill:

$ARGUMENTS

The skill will detect whether the current directory is empty (greenfield) or
already a git working tree (brownfield), gather context, and enter Plan Mode
for review before making any file system changes. It is best run on Claude
Opus with extended thinking.

Brownfield projects may enter the lifecycle at any centre-of-gravity activity,
not just PM.1 plus SR.1. The skill will detect existing work products and
propose an entry point based on what is already in the repository.

On brownfield projects with detected implementation code, the skill offers
an **as-is architecture survey and classification** step (methodology §2.7
Discovery). The survey is opt-in. If accepted, the user is led through a
per-element classification dialogue that distinguishes architectural facts
into mandated (externally constrained, locked in by parent organisation,
customer, parent product, or regulator) and contingent (currently used, but
the project owns the choice and may revisit). Outputs:

- `model/core/base-architecture/<sc>_BaseArchitecture.sysml` populated with
  mandated `part def`s tagged `@ConfigItem { ciState = CIState::Baselined }`
  under baseline `BL-BA-AS-IS-0.1`.
- `model/core/as-is/<sc>_AsIs.sysml` populated with contingent `part def`s
  tagged `@ConfigItem { ciState = CIState::Proposed }` under baseline
  `BL-AS-IS-CURRENT-0.1`.
- `docs/as-is-classification.md` with the full classification tables and
  the contingent-to-mandated promotion path.

Reverse-engineering of stakeholders, concerns, or stories during the survey
is forbidden by §2.6 rule 7. The skill captures evidence and source of
mandate, never narrative justification. If the user declines the survey, a
resumption marker is written into the rationale doc so a later
`@architecture-design` invocation can pick up.
