---
title: "SysML 2.0 Allocation Definitions and Usages"
slug: sysml2-allocation-definitions
type: reference
layer: sysml2
tags: [allocations, syntax, connection, cross-subsetting]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 34, page 245; Chapter 41, pages 265 to 267."
    raw: sysmlv2.pdf
related:
  - sysml2-allocations-overview
  - sysml2-allocation-patterns
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-allocations]
---

# SysML 2.0 Allocation Definitions and Usages

This page captures the syntax for declaring allocation definitions
and applying them through allocation usages. For background and
directionality semantics, see [[sysml2-allocations-overview]].

## Allocation definitions

An allocation definition is a specialisation of a connection
definition with defined ends and typed relationships. The basic
structure includes (Ch 34, p 245; Ch 41, p 266):

- **Named connection ends** that identify the elements being
  allocated.
- **Typed ends** that constrain what kind of element may participate
  in the allocation. For example, a `FunctionalAllocation` has one
  end typed to `Function` and another typed to `Platform`.
- **Cross subsettings** (Chapter 20 for subsettings, Chapter 18.2.2
  for cross subsettings) that model bidirectional relationships.
  Connected functions and platforms appear in the responsibility
  usages of the element on the opposite side of the connection.

```sysml
library package PlatformBasedSystemsEngineering {
    occurrence def Function {
        occurrence realizingPlatforms : Platform[1];
    }
    occurrence def Platform {
        occurrence realizedFunctions : Function[*];
    }
    allocation def FunctionalAllocation {
        end occurrence function : Function crosses platform.realizedFunctions;
        end occurrence platform : Platform crosses function.realizingPlatforms;
    }
}
```

Allocation definitions typically live in library packages, so they
can be reused across projects and specialised to create
domain-specific allocation types (Ch 41, p 265).

## Allocation usages

Allocation usages apply an allocation definition in a specific
context. The `allocate` keyword provides a concise shorthand for
expressing allocations without the verbose connection syntax
(Ch 34, p 245; Ch 41, p 267).

```sysml
alias PBSE for PlatformBasedSystemsEngineering;

part def Drone {
    occurrence navigation : PBSE::Function;
    occurrence navigationSubsystem : PBSE::Platform;
    allocation : PBSE::FunctionalAllocation
        allocate navigation to navigationSubsystem;
}
```

Named allocations give meaningful identifiers to allocation usages
for traceability and documentation. Allocations may also be nested
to support progressive refinement as design matures from abstract to
concrete (Ch 34, p 245).

## User-defined allocation keywords

A domain-specific keyword can be defined using semantic metadata
and applied with the `#` prefix. The keyword form reads more
compactly at the usage site (Ch 41, pp 267 to 270).

```sysml
#functionalAllocation allocate navigation to navigationSubsystem;
```

The keyword form is convenient but carries no extra validation. There
is currently no mechanism to attach validation rules to custom
allocation keywords, and incorrect use fails silently without an
error message (Ch 41, p 271). Treat custom keywords as syntactic
sugar, not as a way to enforce allocation semantics.

## Library design guidance

The book advises avoiding abstract allocation definitions in
libraries unless they are deliberately incomplete. Abstract
definitions force users to specialise or inline detail, which
undermines reuse (Ch 41, p 266). Concrete allocation definitions
with typed ends are preferred.

## See also

- [[sysml2-allocations-overview]] for the conceptual frame.
- [[sysml2-allocation-patterns]] for VSE-scale patterns and gotchas.
- [[sysml2-binding-connectors]] for the related binding connector
  mechanism added in the 2026-04 release.
