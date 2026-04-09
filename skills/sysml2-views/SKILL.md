---
name: sysml2-views
description: Author SysML 2.0 views, viewpoints, expose statements, and standard view definitions. Use when generating documentation views, specifying viewpoints, or configuring rendering.
user-invocable: true
---

# SysML 2.0 Views and Viewpoints

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You guide the engineer through views and viewpoints in SysML 2.0.
Views and viewpoints follow ISO/IEC 42010: a viewpoint frames
stakeholder concerns, and a view satisfies a viewpoint by exposing
model elements with a chosen rendering. For project layout and tooling,
route back to `@sysml2-modelling`. For the elements being exposed
(parts, requirements, cases, allocations), route to the skill for
that element type.

## When This Skill Triggers

- The user asks to generate a documentation view of the model
- The user wants to declare a viewpoint for a stakeholder concern
- The user asks about expose statements, filters, or render usages
- The user asks which standard view fits a given layout

## Core Vocabulary

| Element | Keyword | Purpose |
| --- | --- | --- |
| Viewpoint | `viewpoint def` | Special requirement, frames concerns |
| View | `view def`, `view` | Special part, satisfies a viewpoint |
| Expose | `expose` | Brings model elements into view scope |
| Filter | `filter`, `[...]` | Restricts which exposed elements render |
| Render | `render` | Selects the rendering style |
| Concern | `concern` | A stakeholder's question or worry |
| Stakeholder | `stakeholder` | A role that expresses concerns |

## The Eight Standard Views

SysML v2 ships eight standard views in the `StandardViewDefinitions`
package. Prefer a standard view over a bespoke definition.

| View | Successor of | Use for |
| --- | --- | --- |
| General View | (generic) | Any graph-based visualisation |
| Interconnection View | Internal block diagram | Parts with ports and connectors |
| Action Flow View | Activity diagram | Action bodies with successions |
| State Transition View | State machine diagram | States and transitions |
| Sequence View | Sequence diagram | Messages over time |
| Geometry View | (new) | Spatial and geometric layouts |
| Grid View | (new) | Tabular data such as requirement matrices |
| Browser View | Package browser | Hierarchical navigation |

## Authoring Patterns

### Viewpoint Framing Concerns

```sysml
viewpoint def 'Top-Level System Perspective' {
    frame concern 'requirements overview';
    frame concern 'architecture overview';
}
```

### View Satisfying a Viewpoint

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

`expose` imports elements into the view's protected scope. The double
colon and `**` navigate down the package tree. `filter` narrows the set
using a Boolean expression over metadata.

### Grid View for a Requirements Matrix

```sysml
view def RequirementsMatrix :> StandardViewDefinitions::GridView {
    satisfy viewpoint 'requirements overview';
    expose SystemRequirements::**;
    render asElementTable;
}
```

Grid View renders a table of exposed elements. Combine with a metadata
filter to scope the matrix to a baseline or to a specific category.

### Concern with Stakeholder

```sysml
concern 'system breakdown' {
    stakeholder se : 'Systems Engineer';
    doc /* What is the physical decomposition of the system? */
}
```

A concern is the stakeholder's question. The viewpoint is the recipe
for answering it. The view is the cake that actually addresses the
concern.

## Validation Checklist

1. **Every view satisfies at least one viewpoint** either by `satisfy`
   or by owning a usage of the viewpoint.
2. **Expose scope is protected.** Elements brought in by `expose` are
   only visible inside the view and its specialisations, not inside the
   containing package.
3. **Filter expressions are metadata-aware.** Filters reference metadata
   elements, not arbitrary runtime conditions. See `@sysml2-metadata` for
   metadata definitions.
4. **Render usages come from the library** unless the engineer has
   declared a custom render.
5. **Standard view choice matches the data.** A Grid View for a state
   machine or a Sequence View for a part breakdown is almost always
   wrong.

## Red Flags

WARN the engineer if:

- A view has no `satisfy` clause and no owned viewpoint usage
- An expose statement reaches outside the intended package subtree
- A filter uses a bracketed form `[...]` at the package level (applies
  to all imports, easy to trigger unintentionally)
- The view uses a rendering style that does not exist in the standard
  library without declaring its own
- A viewpoint frames no concerns (an empty viewpoint is a code smell)

## Reference: SysML 2.0 Views and Viewpoints

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/sysml2-views-ref.md`
