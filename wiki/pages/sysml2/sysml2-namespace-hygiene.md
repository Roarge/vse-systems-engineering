---
title: "SysML 2.0 Namespace Hygiene: Short Codes, Imports, File Rules"
slug: sysml2-namespace-hygiene
type: reference
layer: sysml2
tags: [namespace, imports, short-code, file-organisation, reuse]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapters 15 and 16, pages 74 to 84."
    raw: sysmlv2.pdf
related:
  - sysml2-canonical-model-layout
  - sysml2-base-architecture-and-federation
  - sysml2-syntax-packages-and-definitions
confidence: high
created: 2026-05-04
updated: 2026-05-06
bundled_by: [sysml2-model-structure]
---

# SysML 2.0 Namespace Hygiene: Short Codes, Imports, File Rules

> **Canonical for this plugin: methodology §8.3.4.** The
> short-code prefix and SysML 2.0 package-naming guidance below
> describes the language-level convention. Project file and
> folder names follow the kebab-case rules in
> `methodology/08-project-structure.md` §8.3.4
> (`base-architecture/`, `system-stories.sysml`, and so on).
> Where the two conventions appear to disagree, the methodology
> spec wins.

The structural chapters of *The SysML v2 Book* contribute one
discipline to the plugin's canonical layout: how to keep
namespaces from colliding as the model grows.

## Short-code prefixes

Prefix every top-level package with a project short code (two to
four letters): `HS_Actors`, `HS_Requirements`, `SS_ArchDesign`. A
lighter variant of Chapter 16's angle-bracket convention, serving
the same purpose: when two projects share a workspace or a base
is reused across programmes, the package names do not collide.

This is the `{{sc}}_` discipline in templates. The token is
expanded by `project-setup` to the chosen short code at scaffold
time.

## Imports

SysML 2.0 distinguishes public and private imports
(Ch 15, pp 74 to 75). A `private import` brings a namespace into
scope without re-exporting it. **Use `private import` by
default.** Reserve public imports for packages that deliberately
forward a namespace.

**Prefer named imports over wildcards** so the dependency surface
stays visible:

```sysml
package HS_Verification {
    private import HS_Requirements::SR_WaterLevelAccuracy;
    private import HS_Requirements::SR_ResponseTime;
    // rather than HS_Requirements::*
}
```

The wildcard form (`::*` or `::**`) is convenient but obscures
the dependency surface and slows tool resolution.

## One top-level package per file

Nested packages inside a single top-level package must sit in
**one file textually** (Chs 15-16). Top-level packages can live
in separate files. The VSE rule is:

- **One top-level package per file.**
- Nested packages only for tight groups (the children of
  `{{sc}}_FunctionalAnalysis`, one per analysed use case).

This rule keeps file scope predictable. A reviewer can open a
single file and see exactly one top-level package's content.

## Reuse boundary check

A package that imports only from `{{sc}}_BaseArchitecture`,
`{{sc}}_Actors`, and `{{sc}}_Interfaces` is **reusable across
projects**. A package that imports freely from any peer cannot be
lifted into a shared model later.

This is a cheap reuse guard to run when considering federation
(see [[sysml2-base-architecture-and-federation]]). If a candidate
package fails the boundary check, refactor before lifting.

## Import resolution order

When several public imports could resolve a name, SysML 2.0
follows a deterministic resolution order. In practice, name
clashes between imported namespaces are rare in a VSE-scale model
because the short-code prefix discipline keeps top-level package
names disjoint. When clashes do occur, qualify the name explicitly
at the use site rather than relying on import order.

## See also

- [[sysml2-canonical-model-layout]] for the package set that this
  hygiene applies to.
- [[sysml2-base-architecture-and-federation]] for the reuse-curve
  context that motivates the boundary check.
- [[sysml2-syntax-packages-and-definitions]] for the import
  syntax cheat sheet.
