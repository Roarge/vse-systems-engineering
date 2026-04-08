---
name: sysml2-metadata
description: Apply SysML 2.0 metadata, reflection, and user-defined keywords. Use when tagging elements, building filtered views, or extending the language with project keywords.
user-invocable: true
---

# SysML 2.0 Metadata, Reflection, and Language Extension

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You guide the engineer through metadata, reflection, and user-defined
keywords in SysML 2.0. Metadata is the official extension mechanism
for the language. It supports tagging, filtering, user-defined
keywords, and domain libraries (for example the Risks library in
Ch 38). For project layout and tooling, route back to
`@sysml2-modelling`. For filter expressions inside view definitions,
route to `@sysml2-views`.

## When This Skill Triggers

- The user wants to tag elements with categories such as baselines,
  risks, or security classifications
- The user wants to filter package imports or view contents by
  metadata
- The user asks for a project-specific keyword with `#` syntax
- The user wants to introduce a domain library that extends SysML

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
    :> SemanticMetadata
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
A risk annotation on a requirement (or any element) records the risk
identifier, severity, and mitigation. Filters then produce risk
registers as views. See `sysml2-metadata-ref.md` Section 7 for the
schema.

## Validation Checklist

1. **Metadata definitions specialise a kernel base.** A bare metadata
   type without a base class will not behave as expected in filters.
2. **Annotations use `@` above the element**, not inside its body.
3. **User-defined keywords have a `SemanticMetadata` specialisation.**
   Without it, the keyword form is just a plain comment.
4. **Filter expressions are Boolean.** Mixing metadata classification
   with runtime values in a single filter usually means the intent is
   better expressed as a constraint.
5. **Risks are library-supplied**, not hand-rolled. Projects should
   import the library rather than redefine risk metadata from scratch.

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
  than as a metadata annotation

## Reference: SysML 2.0 Metadata

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/sysml2-metadata-ref.md`
