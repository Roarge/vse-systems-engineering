# As-Is Architecture Classification

**Project:** {{PROJECT_NAME}}
**Project short code:** {{PROJECT_SHORT_CODE}}
**Survey author:** {{AUTHOR}}
**Date:** {{DATE}}
**Methodology reference:** §2.7 Discovery, §2.1 Base Architecture corollaries
**Baselines:**
- `BL-BA-AS-IS-0.1` (mandated, locked-in subset, frozen in `model/core/base-architecture/`)
- `BL-AS-IS-CURRENT-0.1` (contingent, current-state subset, frozen in `model/core/as-is/`)

## Posture (read this before reading the tables)

This document records facts about decisions that pre-existed the
project. It does not contain stakeholder needs, concerns, or stories
about those decisions. The methodology forbids reverse-engineering of
needs, concerns, or stories whose role is to fabricate post-hoc
justification for an existing architectural decision (§2.6 rule 7).

The survey distinguishes two categories:

- **Mandated** elements are externally constrained. The project must
  build on them. The mandate has a single source: parent organisation,
  customer, parent product, or regulator. Mandated elements live in
  `model/core/base-architecture/` as `part def`s in a `library package`
  and carry `@ConfigItem { ciState = CIState::Baselined }`.
- **Contingent** elements are currently used but the project owns the
  choice. They live in `model/core/as-is/` and carry
  `@ConfigItem { ciState = CIState::Proposed }`. The project may
  replace, refine, or retire them through forward-going stories.

A third pile, **Skipped or irrelevant**, records elements the survey
considered but did not model (typically tooling-only items that do not
shape the architecture).

## Mandated (Base Architecture, BL-BA-AS-IS-0.1)

| Element | Category | Source of mandate | Evidence | Version | Notes |
|---|---|---|---|---|---|
| _add one row per mandated element_ | platform / protocol / reused-subsystem / regulatory | parent-organisation / customer / parent-product / regulator | `path/to/file` | `x.y.z` | _optional one-line description_ |

## Contingent (current state, BL-AS-IS-CURRENT-0.1)

| Element | Category | Evidence | Version | Notes |
|---|---|---|---|---|
| _add one row per contingent element_ | platform / protocol / framework / runtime / library | `path/to/file` | `x.y.z` | _optional one-line description_ |

## Skipped or irrelevant

- _list elements the survey considered and rejected as non-architectural (linters, formatters, build-only tooling)_

## Promotion path (contingent to mandated)

A contingent element today may become mandated tomorrow, for example
when the customer locks in a database choice or a regulator publishes
a new standard. Promotion is a change to baselined paths and follows
the Change Request workflow:

1. Open a Change Request via `/vse-cr`. Reference the contingent
   element's `ciId` and the new evidence that establishes the mandate.
2. Update `model/core/base-architecture/{{PROJECT_NAME}}_BaseArchitecture.sysml`
   to declare the part def under the `library package`. Move attributes
   and version, and replace `ciState = CIState::Proposed` with
   `ciState = CIState::Baselined` against a new
   `baselineId = "BL-BA-AS-IS-x.y"`.
3. Update
   `model/core/base-architecture/{{PROJECT_NAME}}_BaseArchitecture_CM.sysml`
   with the new `Baseline` item def, listing the part def in `scope`
   and naming the previous baseline in `supersedes`.
4. Remove the part def from `model/core/as-is/{{PROJECT_NAME}}_AsIs.sysml`.
5. Move the row in this document from the contingent table to the
   mandated table, recording the source of mandate.
6. Land the Change Request under elevated final-review criteria per
   §8.6.3, because Base Architecture changes propagate to every story
   whose subject specialises a Base Architecture `part def`.

The reverse path (a mandated element loses its external constraint)
is rare but uses the same Change Request workflow in reverse.

## Survey skipped marker

If the user declined the as-is survey at `/vse-setup` time, the
following marker is set so a later run of `@architecture-design`
or `/vse-setup` can resume:

```
<!-- as-is-survey: skipped at {{DATE}} -->
```

Remove this marker after running the survey.
