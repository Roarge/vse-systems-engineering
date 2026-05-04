---
title: "SysML 2.0 Standard Views Catalogue"
slug: sysml2-standard-views
type: reference
layer: sysml2
tags: [views, standard-views, library, sysmlv1-migration]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 13, pages 51 to 54."
    raw: sysmlv2.pdf
related:
  - sysml2-viewpoints-and-concerns
  - sysml2-view-definitions
  - sysml2-view-patterns
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-views]
---

# SysML 2.0 Standard Views Catalogue

SysML 2.0 defines eight standard views in the
`StandardViewDefinitions` package. These views provide predefined
visual representations that map to common SysML v1 diagram types,
easing migration and ensuring consistency across projects
(Ch 13, p 51).

## The eight standard views

| Standard view | Purpose | SysML v1 lineage |
|---|---|---|
| **General View** | General-purpose graph-based representation of model elements. Suitable when no more specific view fits the purpose. | None (new in SysML 2.0). |
| **Interconnection View** | Displays connections and relationships between system elements. | Closest relative of the SysML v1 internal block diagram (IBD). |
| **Action Flow View** | Shows the sequence and flow of actions within a behaviour. | Successor of the SysML v1 activity diagram. |
| **State Transition View** | Models state machines and transitions between states. | Successor of the SysML v1 state machine diagram. |
| **Sequence View** | Depicts interactions and message exchanges over time. | Successor of the SysML v1 sequence diagram. |
| **Geometry View** | Represents spatial and geometric relationships between elements in physical space. | None (new in SysML 2.0, supports 4D modelling). |
| **Grid View** | Provides a tabular representation of model data, useful for requirements matrices and property tables. | Generalises the SysML v1 requirements diagram and tabular formats. |
| **Browser View** | Offers a hierarchical tree-based navigation of model elements. | Similar to a model browser panel. |

## SysML v1 to v2 mapping

SysML v1 diagrams map to corresponding SysML v2 standard views,
providing a transition path for legacy models (Ch 13, p 54). A
project migrating from SysML v1 to SysML v2 can usually preserve
the visual organisation of its existing diagrams by selecting the
matching standard view.

The Geometry View has no v1 predecessor. It supports the new 4D
modelling concepts introduced in the 2026-04 release (Chapter 25 of
the SysML v2 book). Projects that need spatial or temporal
relationships should adopt the Geometry View even when migrating
existing structural views.

## When to use each view

For VSE-scale projects, the recommended starting set is:

- **Interconnection View** for system structure and component
  decomposition.
- **Grid View** for requirements matrices, allocation tables, and
  trade-off summaries.
- **Browser View** for model navigation during reviews.

Behaviour-heavy projects should add **Action Flow View** and
**State Transition View** for behavioural detail. Projects with
real-time or distributed concerns add **Sequence View**.
Projects with significant spatial or temporal modelling add
**Geometry View**.

## Standard library chapter status

Chapter 108 of the SysML v2 book (the `StandardViewDefinitions`
library chapter) provides the full render style catalogue and
per-view rendering conventions. As of the 2026-04 release, this
chapter is pending. Authors should validate render output in their
chosen modelling tool until the chapter publishes.

## See also

- [[sysml2-view-definitions]] for the `view def` and `render` syntax.
- [[sysml2-viewpoints-and-concerns]] for the ISO 42010 frame.
- [[sysml2-view-patterns]] for VSE-scale patterns.
