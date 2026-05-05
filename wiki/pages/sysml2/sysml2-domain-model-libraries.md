---
title: "SysML 2.0 Domain Model Libraries"
slug: sysml2-domain-model-libraries
type: reference
layer: sysml2
tags: [language-extension, libraries, domain-libraries, library-package]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 41 Section 41.1, pages 291 to 293."
    raw: sysmlv2.pdf
related:
  - sysml2-language-extension
  - sysml2-user-defined-keywords
  - sysml2-allocation-definitions
  - sysml2-libraries-architecture
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [sysml2-extension]
---

# SysML 2.0 Domain Model Libraries

The first strategy for extending SysML 2.0 is to **model the new
concepts with the existing ones**. This is no different from
everyday modelling, except that the author defines more abstract
concepts like `Function` or `Platform`, and organises them into
model libraries for reuse (Ch 41.1, p 291). The same pattern is
used by SysML 2.0 itself, where every built-in concept is modelled
in the Systems Library (Part VII). Domain libraries simply move
the same mechanism into project-specific or methodology-specific
territory.

See [[sysml2-libraries-architecture]] for the layering of the
Systems Model Library, the standard domain libraries shipped with
SysML 2.0, and where user libraries fit alongside them.

## Library packages

A library is published in a `library package`, a package modifier
that signals to readers and tools that the contents are intended
for reuse rather than to model a specific system (Ch 41.1, p 292,
and see Section 16.2). The `library` keyword precedes `package` in
the declaration:

```sysml
library package PlatformBasedSystemsEngineering {
    // library content
}
```

Outside of a `library` package, the same definitions would still
work, but the intent would be unclear. The `library` modifier is a
documentation contract, not a runtime gate.

## The PBSE canonical example

Chapter 41 develops a small Platform-Based Systems Engineering
library to illustrate domain extension. The library defines two
abstract concepts (`Function` and `Platform`) and one allocation
(`FunctionalAllocation`) that crosses them.

```sysml
library package <PBSE> PlatformBasedSystemsEngineering {
    occurrence def Function {
        occurrence realizingPlatforms : Platform [1];
    }
    occurrence def Platform {
        occurrence realizedFunctions : Function [*];
    }
    allocation def FunctionalAllocation {
        end occurrence function : Function
            crosses platform.realizedFunctions;
        end occurrence platform : Platform
            crosses function.realizingPlatforms;
    }
}
```

The angle-bracket name `<PBSE>` is a short alias used inside
qualified-name references. `Function` and `Platform` are declared
as occurrence definitions, which keeps users free to specialise
them with their own kinds (an action for a function, a part for a
platform, or otherwise). The general advice is to **stay as
general as possible** in libraries. Pinning a library concept to a
narrower kind unnecessarily limits its scope of application
(Ch 41.1, p 292).

`FunctionalAllocation` is an allocation definition, which is itself
a special kind of connection (Chapter 34). The `crosses` clauses
on each end derive the reverse-direction trace from a single
declaration: when an `allocate` usage links a `Function` to a
`Platform`, the `realizingPlatforms` and `realizedFunctions`
collections on each side are populated automatically through cross
subsetting (Section 18.2.2). This is a library design pattern, not
something the user of the library writes. See
[[sysml2-allocation-definitions]] for the allocation mechanism in
isolation.

## Avoid abstract definitions in libraries

A useful design rule from Chapter 41: to support usage-focused
modelling (Section 17.4), **avoid abstract definitions in
libraries unless they are meant to be incomplete and unusable on
their own**. The `Function` and `Platform` definitions in the PBSE
library above are concrete on purpose. Users of the library may
choose to specialise them, or simply use them as the type of their
own usages and detail those in place with nested usages. An
abstract definition in a library forces the user to subclass
before they can use it, which is heavier than necessary in most
cases (Ch 41.1, p 292).

The exception is when the library deliberately wants to enforce
specialisation, for example because every concrete realisation
must declare a feature that a default value cannot provide. State
that intent in a comment or in companion documentation, so the
abstract marker reads as a contract rather than as oversight.

## Applying the library

Once the library is published, users either import it or refer to
its concepts by qualified name:

```sysml
part def Drone {
    occurrence navigation : PBSE::Function;
    occurrence navigationSubsystem : PBSE::Platform;
    allocation : PBSE::FunctionalAllocation
        allocate navigation to navigationSubsystem;
}
```

The single `allocate` line populates both
`navigation.realizingPlatforms` and
`navigationSubsystem.realizedFunctions` through the cross
subsetting in the library. Users do not need to write the trace
in two directions, and they do not need to know that the library
expressed it that way. This is a useful concrete benefit of moving
a domain pattern into a library.

For a more compact call site that drops the explicit
specialisation, see [[sysml2-user-defined-keywords]], which builds
on this library to register `#function`, `#platform`, and
`#functionalAllocation` keywords.

## See also

- [[sysml2-language-extension]] for the overview of the two
  extension strategies.
- [[sysml2-user-defined-keywords]] for keyword shortcuts that
  build on libraries like this one.
- [[sysml2-libraries-architecture]] for how Systems Model Library
  and standard domain libraries are layered.
- [[sysml2-allocation-definitions]] for the allocation mechanism
  used in `FunctionalAllocation`.
