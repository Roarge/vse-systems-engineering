---
title: "SysML 2.0 Viewpoints, Views, and Concerns"
slug: sysml2-viewpoints-and-concerns
type: concept
layer: sysml2
tags: [views, viewpoints, concerns, stakeholders, iso42010]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 37, pages 258 to 260."
    raw: sysmlv2.pdf
  - citation: "ISO/IEC/IEEE 42010:2022. Systems and software engineering — Architecture description."
    raw: null
related:
  - sysml2-view-definitions
  - sysml2-view-patterns
  - sysml2-standard-views
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-views]
---

# SysML 2.0 Viewpoints, Views, and Concerns

Views and viewpoints in SysML 2.0 are grounded in ISO/IEC/IEEE 42010,
which addresses stakeholder concerns through a structured
visualisation mechanism. The SysML v2 book offers a memorable
analogy. A viewpoint is the recipe, answering what stakeholders are
hungry for. A view is the cake, the actual result. The stakeholder
is the person with a concern, and the viewpoint lists the
ingredients and steps needed to satisfy that concern (Ch 37, p 258).

## What viewpoints and views are

In SysML 2.0 terms:

- A **viewpoint** is a special kind of requirement that frames
  stakeholder concerns. It specifies what must be addressed by any
  conforming view but does not produce a rendering on its own.
- A **view** is a special kind of part that satisfies a viewpoint.
  It specifies which model elements appear and how they are
  rendered. See [[sysml2-view-definitions]] for the declaration
  syntax.
- A **concern** is a model element that captures what a stakeholder
  cares about. Viewpoints frame one or more concerns through `frame
  concern` clauses.
- A **stakeholder** is a part that expresses a concern, the person
  who is hungry in the analogy.

## Viewpoint definitions

A viewpoint is technically a special requirement. Viewpoints are
declared with the `viewpoint def` keyword and specify the concerns
that must be addressed by any conforming view (Ch 37, p 258).

```sysml
viewpoint def 'Top-Level System Perspective' {
    frame concern 'requirements overview';
    frame concern 'architecture overview';
}
```

Viewpoints can be composed. A top-level viewpoint may frame two or
more sub-viewpoints, allowing a hierarchical organisation of
concerns. Viewpoints may also inherit from or specialise other
viewpoints through the standard SysML 2.0 definition and usage
mechanisms (Ch 37, p 259).

## Concerns and stakeholders

A concern captures what a stakeholder cares about. The full formal
structure of concerns, including relationships to other model
elements, is detailed in Chapter 32.1 and 32.5 of the SysML v2 book,
which are outside the scope of this page.

```sysml
concern 'system breakdown' {
    stakeholder se : 'Systems Engineer';
    doc /* What is the physical decomposition of the system? */
}
```

A stakeholder is a part with declared concerns. The stakeholder
element is described in Chapters 32.1 and 32.5. A view satisfies a
viewpoint that frames the stakeholder's concerns. The chain
stakeholder, concern, viewpoint, view is the spine of the
ISO/IEC/IEEE 42010 architecture description in SysML 2.0.

## Two satisfaction mechanisms

A view may satisfy a viewpoint in two ways (Ch 37, p 260):

- **Explicit `satisfy` relationship.** The view declares
  `satisfy viewpoint <name>`. This is the form covered in
  Chapter 32.4.
- **Owned viewpoint usage.** The view owns a usage of the viewpoint.
  Ownership provides implicit satisfaction.

The two forms have subtly different effects on model composition.
See [[sysml2-view-patterns]] for guidance on choosing between them.

## Where this fits in VSE practice

For VSE-scale projects, viewpoints and views are the primary
mechanism for producing audience-specific deliverables from a single
underlying model. A safety officer, a project manager, and a system
engineer can each have a tailored view of the system without forks
in the model. See [[sysml2-view-patterns]] for VSE-scale patterns
and [[sysml2-standard-views]] for the eight predefined view types
that ship with the language.
