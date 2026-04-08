# SysML v2 Views and Viewpoints Reference

Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U, 2026-03 release.
Chapter and page citations appear inline. This file paraphrases the source, which
is a copyrighted commercial reference and is not reproduced verbatim. Further
layout and rendering semantics are planned for SysML v2.1 and will be added when
those details are published.

---

## 1. Overview (Ch 37, p 258)

Views and viewpoints in SysML v2 are grounded in ISO/IEC 42010, which addresses
stakeholder concerns through a structured visualisation mechanism. The book
offers a memorable analogy. A viewpoint is the recipe, answering what stakeholders
are hungry for. A view is the cake, the actual result. The stakeholder is the
person with a concern, and the viewpoint lists the ingredients and steps needed
to satisfy that concern (Ch 37, p 258).

In SysML v2 terms, a viewpoint is a special kind of requirement that frames
stakeholder concerns. A view is a special kind of part that satisfies a
viewpoint, specifying the model elements that appear on the view and the kind
of rendering used (Ch 37, p 258).

---

## 2. Viewpoint Definitions (Ch 37, pp 258-259)

A viewpoint is technically a special requirement that frames stakeholder
concerns. Viewpoints are declared with the keyword `viewpoint def` and specify
the concerns that must be addressed by any conforming view (Ch 37, p 258).

```sysml
viewpoint def 'Top-Level System Perspective' {
    frame concern 'requirements overview';
    frame concern 'architecture overview';
}
```

Figure 37.1 demonstrates viewpoint definitions for a Requirements Perspective
and an Architecture Perspective, both framed inside a Top-Level System
Perspective (Ch 37, p 259).

Viewpoint satisfaction by a view can be modelled in two ways (Ch 37, p 260):

- With an explicit `satisfy` relationship (see Ch 32.4).
- By a view that owns a usage of the viewpoint, which provides implicit
  satisfaction through ownership.

Viewpoints can be composed. Figure 37.1 shows a top-level viewpoint framing two
sub-viewpoints, allowing a hierarchical organisation of concerns. Viewpoints may
also inherit from or specialise other viewpoints through the standard SysML
definition and usage mechanisms (Ch 37, p 259).

---

## 3. Concerns and Stakeholders (Ch 37, p 258)

Stakeholders and concerns are linked with requirements and are used together
with views and viewpoints (Ch 37, p 258). A stakeholder is a part that expresses
a concern, the person who is hungry in the analogy. The stakeholder element is
described in Ch 32.1 and Ch 32.5.

A concern is a special kind of model element that captures what a stakeholder
cares about. A viewpoint frames one or more concerns through `frame concern`
clauses, tying the viewpoint to what the stakeholder needs to know
(Ch 37, p 258).

```sysml
concern 'system breakdown' {
    stakeholder se : 'Systems Engineer';
    doc /* What is the physical decomposition of the system? */
}
```

The full formal structure of concerns, including relationships to other model
elements, is detailed in Ch 32.1 and Ch 32.5, which are outside the scope of
Ch 37 and not reproduced here.

---

## 4. View Definitions (Ch 37, p 260)

A view definition declares a view that satisfies a viewpoint. The view specifies
the model elements that appear on the view and the kind of rendering used. In
textual notation, the view begins with `view def`, followed by an optional
specialisation clause, and the body declares the expose statements, filters,
render hints, and satisfied viewpoints (Ch 37, p 260).

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

---

## 5. Expose Statements and Filters (Ch 37, p 260)

The elements rendered on a view are declared by expose relationships, which are
a special kind of import relationship (see Ch 15.1). As with import
relationships, the selection can be further restricted using filters
(see Ch 36.3) (Ch 37, p 260).

Expose relationships always have protected visibility. The exposed elements are
only visible in the view itself and in specialisations of the view
(Ch 37, p 260). Authors must treat `expose` as scoped to the view, not as a
general import into the containing package.

Filters are Boolean expressions about model elements that determine which of
the exposed elements actually appear on the view. Filters allow a single
underlying model to be viewed from multiple perspectives without duplication
(Ch 37, p 260).

---

## 6. Render Semantics (Ch 37, p 260)

A rendering is a special kind of part usage declared with the `render` keyword.
The standard library `Views` provides predefined render usages such as
`asElementTable` and `asTreeDiagram` (Ch 37, p 260). A view picks a rendering
style by referencing one of these predefined usages or declaring its own.

Further detail on render styles and their interaction with the view body will
be expanded when Ch 108 (the `StandardViewDefinitions` library chapter) is
published in a later release.

---

## 7. Standard Views Catalogue (Ch 13, pp 51-54)

SysML v2 defines eight standard views in the `StandardViewDefinitions` package.
These views provide predefined visual representations that map to common SysML
v1 diagram types, easing migration and ensuring consistency (Ch 13, p 51). The
standard views are:

- **General View.** A general-purpose graph-based representation of model
  elements. Suitable when no more specific view fits the purpose.
- **Interconnection View.** Displays connections and relationships between
  system elements. Closest relative of the SysML v1 internal block diagram.
- **Action Flow View.** Shows the sequence and flow of actions within a
  behaviour. The successor of the SysML v1 activity diagram.
- **State Transition View.** Models state machines and transitions between
  states. The successor of the SysML v1 state machine diagram.
- **Sequence View.** Depicts interactions and message exchanges over time.
  The successor of the SysML v1 sequence diagram.
- **Geometry View.** Represents spatial and geometric relationships between
  elements in physical space.
- **Grid View.** Provides a tabular representation of model data, useful for
  requirements matrices and property tables.
- **Browser View.** Offers a hierarchical tree-based navigation of model
  elements, similar to a model browser panel.

SysML v1 diagrams map to corresponding SysML v2 standard views, providing a
transition path for legacy models (Ch 13, p 54).

---

## 8. View Composition Patterns (Ch 37, p 259)

Views may be composed. Multiple specialised views can be combined into a
higher-level view, allowing stakeholders to see both detailed and abstract
perspectives on the system. This follows from the general SysML definition and
usage mechanism, so a view definition can specialise another view and a view
usage can reference several view definitions (Ch 37, p 259).

---

## 9. Practical Patterns for VSE Authors

### 9.1 Basic Viewpoint and View Pair

Define a viewpoint that frames one or more concerns, then define a view that
satisfies the viewpoint either by an explicit `satisfy` clause or by owning a
usage of the viewpoint (Ch 37, pp 259-260).

### 9.2 Stakeholder-Driven View

Model the stakeholder as a part with declared concerns, wrap those concerns in
a viewpoint, and define a view that satisfies the viewpoint and exposes the
relevant model elements (Ch 37, p 258).

### 9.3 Concern-Based Filtering

Customise view content with expose relationships constrained by filters.
Boolean filters let a single underlying model be viewed from multiple
perspectives without duplication (Ch 37, p 260).

### 9.4 Rendering Selection

Assign different render usages (such as `asElementTable` or `asTreeDiagram`) to
different views to control how model elements are displayed. The same elements
can be rendered in different formats for different audiences (Ch 37, p 260).

### 9.5 View Composition

Compose multiple specialised views into a higher-level view so stakeholders can
see both detailed and abstract perspectives. Works through the standard
specialisation mechanism (Ch 37, p 259).

### 9.6 Standard View Reuse

Use one of the eight standard views from the `StandardViewDefinitions` package
rather than defining a new view from scratch. This ensures consistency across
projects and eases the SysML v1 to v2 transition (Ch 13, p 51).

### 9.7 View Library Integration

Organise view and viewpoint definitions into a library package and reuse them
across projects. Teams can establish consistent definitions as an organisational
standard (Ch 37, p 260).

---

## 10. Gotchas and Red Flags

1. **Expose has protected visibility.** The elements brought in by an expose
   relationship are only visible in the view itself and in specialisations of
   the view. This is not obvious from casual inspection and can cause confusion
   about which elements are actually public in the containing package
   (Ch 37, p 260).
2. **View concept is still evolving.** Work is underway to extend the view
   concept with layout information so that views can be exchanged between
   tools. The extension is planned for SysML v2.1. Current view definitions may
   require migration (Ch 37, p 260).
3. **Satisfy versus owned usage is subtle.** The distinction between an explicit
   `satisfy` relationship and a view that owns a usage of a viewpoint is
   subtle. Both satisfy the viewpoint, but ownership provides implicit
   satisfaction, which may have unexpected effects on model composition
   (Ch 37, p 260).
4. **Filter conditions in square brackets.** Filter conditions placed in square
   brackets without the `filter` keyword apply to all imports in a package.
   This differs from an explicit `filter` statement and can have unintended
   consequences for what is actually imported (Ch 37, p 260).
5. **Graphical notation is thin.** The book does not extensively cover the
   graphical notation for viewpoints and views, relying instead on textual
   examples. Tool support for graphical viewpoint notation varies across
   implementations, and authors should validate output in their chosen tool
   rather than assume portable rendering (Ch 37, p 259).
6. **Concerns are only half-defined in Ch 37.** Concerns are mentioned in
   Ch 37 but fully specified in Ch 32.1 and Ch 32.5. Readers relying solely on
   Ch 37 will miss the full semantics of concerns and their relationships to
   requirements (Ch 37, p 258).

---

## 11. Cross References

- `sysml2-quick-ref.md` Section 20 for the textual syntax of `viewpoint def`,
  `view def`, `expose`, `render`, and `concern`.
- `sysml2-semantics-ref.md` for the requirement and part base types that
  viewpoints and views specialise.
- `sysml2-metadata-ref.md` for metadata and filter expressions used inside
  view filters.
- `sysml2-cases-ref.md` for the case family, which views often render together
  with verification and analysis reports.

---

## 12. Pending Extensions

This file will grow once the following chapter sections are published in a
future release of the book:

- Ch 108 `StandardViewDefinitions` library chapter, with full render style
  catalogue and per-view rendering conventions.
- Layout semantics and tool-exchange format planned for SysML v2.1.
- Detailed graphical notation for viewpoints and views.
- Extended concern and stakeholder modelling from Ch 32.1 and Ch 32.5 when
  those sections are expanded in a future release.

Attribution: Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U,
2026. All claims cite chapter and page. Paraphrased for reference use. Do not
reproduce verbatim.
