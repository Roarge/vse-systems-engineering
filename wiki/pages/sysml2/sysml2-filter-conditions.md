---
title: "SysML 2.0 Filter Conditions on Imports and Views"
slug: sysml2-filter-conditions
type: reference
layer: sysml2
tags: [filters, imports, smart-packages, views]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 36, pages 256 to 257; Chapter 37, page 260."
    raw: sysmlv2.pdf
related:
  - sysml2-metadata-overview
  - sysml2-reflection-and-classification
  - sysml2-view-definitions
  - sysml2-view-patterns
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-metadata]
---

# SysML 2.0 Filter Conditions on Imports and Views

Imports can be restricted with filter conditions that impact which
elements are brought into a namespace. A filter condition is a
Boolean expression about model elements. An imported element is
brought in only when the filter condition is true for it
(Ch 36, p 256).

## What filters are good for

Filters can:

- **Reduce the number of imported elements.** Cuts naming
  conflicts and improves tool performance, since tools must handle
  fewer elements in a namespace.
- **Define smart packages.** A public import with a filter
  condition can define the content of a package declaratively,
  collecting certain elements from other packages based on a
  condition.
- **Define views.** Cross-referenced from Chapter 37 of the SysML
  v2 book and [[sysml2-view-definitions]].

## Smart package example

```sysml
package PartsCatalogue {
    private import 'Drone System Logical Architecture'::**;
    private import 'Drone System Product Architecture'::**;

    filter @SysML::PartUsage;
}
```

The package collects every `PartUsage` reachable from either
imported namespace. The filter is evaluated against every
candidate, and only matching elements appear in the package's
content.

## Combining reflective and project metadata

Filters can be written in terms of custom metadata. A filter can
combine reflective metadata with project metadata
(Ch 36, p 257):

```sysml
package ApprovedPartsCatalogue {
    private import 'Drone System Logical Architecture'::**;
    private import 'Drone System Product Architecture'::**;

    filter @SysML::PartUsage and
        @MBSEMethodology::Status::status == MBSEMethodology::StatusKind::approved;
}
```

Only `PartUsage` elements whose `Status` metadata says `approved`
appear in the smart package.

## Filter scope: package versus single import

The placement of a filter condition determines its scope:

- **Filter with the `filter` keyword** applies to **every import**
  in the containing package.
- **Filter condition in square brackets** placed immediately after
  a specific import statement applies **only to that import**, not
  to all imports in the package.

This is a subtle distinction that changes scope. See
[[sysml2-view-patterns]] for the gotcha. The two scopes differ
subtly and surface only at evaluation time.

## Use in views

Filters reuse the same syntax inside view definitions. The filter
governs which exposed elements actually appear on the view. See
[[sysml2-view-definitions]].

## Open issue on filter expression syntax

Chapter 36 of the SysML v2 book flags an open issue in the OMG
KerML group (KERML11-183) regarding filter expressions. Syntax may
change in future SysML 2.0 releases (Ch 36, p 257).

## See also

- [[sysml2-metadata-overview]] for what filters are filtering on.
- [[sysml2-reflection-and-classification]] for the operators used
  inside filter expressions.
- [[sysml2-view-definitions]] and [[sysml2-view-patterns]] for the
  view consumption of filters.
