---
title: "SysML 2.0 View Definitions, Expose, Filters, and Render"
slug: sysml2-view-definitions
type: reference
layer: sysml2
tags: [views, syntax, expose, filter, render]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 37, pages 259 to 260."
    raw: sysmlv2.pdf
related:
  - sysml2-viewpoints-and-concerns
  - sysml2-standard-views
  - sysml2-view-patterns
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-views]
---

# SysML 2.0 View Definitions, Expose, Filters, and Render

This page covers the textual notation for view definitions and the
three mechanisms that determine view content: expose statements,
filters, and render usages. For the conceptual frame and ISO 42010
grounding, see [[sysml2-viewpoints-and-concerns]].

## View definitions

A view definition declares a view that satisfies a viewpoint. In
textual notation, the view begins with `view def`, followed by an
optional specialisation clause. The body declares the satisfied
viewpoints, the rendering, the exposed elements, and any filters
(Ch 37, p 260).

```sysml
view def StructureView {
    satisfy viewpoint 'Top-Level System Perspective';
    render asTreeDiagram;
}

view systemOverview : StructureView {
    expose vehicle::**;
    filter @ApprovedBaseline;
}
```

The pattern is familiar from other SysML 2.0 elements: the `def`
form declares the view kind, and a usage instantiates it with
specific exposed elements and filters.

## Expose statements

The elements rendered on a view are declared by `expose`
relationships, which are a special kind of import relationship (see
Chapter 15.1 of the SysML v2 book). Selection can be further
restricted using filters (see Chapter 36.3) (Ch 37, p 260).

Expose relationships always have **protected visibility**. The
exposed elements are only visible in the view itself and in
specialisations of the view (Ch 37, p 260). Authors must treat
`expose` as scoped to the view, not as a general import into the
containing package.

## Filters

Filters are Boolean expressions about model elements that determine
which of the exposed elements actually appear on the view. Filters
allow a single underlying model to be viewed from multiple
perspectives without duplication (Ch 37, p 260).

```sysml
filter @ApprovedBaseline;
filter element.confidence == 'high';
```

The filter expression is evaluated for every exposed element. Only
elements that satisfy the predicate appear on the view. Filters can
be combined with logical operators inside a single `filter`
statement.

A filter condition placed in square brackets without the `filter`
keyword applies to all imports in the containing package, not just
to the view. This is a subtle source of bugs. See
[[sysml2-view-patterns]].

## Render

A rendering is a special kind of part usage declared with the
`render` keyword. The standard library `Views` provides predefined
render usages such as `asElementTable` and `asTreeDiagram`
(Ch 37, p 260). A view picks a rendering style by referencing one
of these predefined usages or declaring its own.

```sysml
view def TableView {
    render asElementTable;
}

view def TreeView {
    render asTreeDiagram;
}
```

Further detail on render styles and their interaction with the view
body will appear when Chapter 108 (the `StandardViewDefinitions`
library chapter) is published in a later release of the SysML v2
book.

## View composition

Views may be composed. Multiple specialised views can be combined
into a higher-level view, allowing stakeholders to see both
detailed and abstract perspectives on the system. This follows
from the general SysML 2.0 definition and usage mechanism, so a
view definition can specialise another view and a view usage can
reference several view definitions (Ch 37, p 259).

```sysml
view def CombinedSystemView :> StructureView, BehaviourView {
    expose vehicle::**;
}
```

## See also

- [[sysml2-viewpoints-and-concerns]] for the conceptual frame.
- [[sysml2-standard-views]] for the eight predefined view types.
- [[sysml2-view-patterns]] for VSE-scale patterns and gotchas.
