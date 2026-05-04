---
title: "SysML 2.0 Language Extension: User-Defined Keywords and Semantic Metadata"
slug: sysml2-language-extension
type: reference
layer: sysml2
tags: [language-extension, semantic-metadata, user-defined-keywords, libraries]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 41, pages 265 to 271."
    raw: sysmlv2.pdf
related:
  - sysml2-metadata-overview
  - sysml2-metadata-definitions
  - sysml2-allocation-definitions
  - sysml2-vse-library-metadata
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-metadata]
---

# SysML 2.0 Language Extension: User-Defined Keywords and Semantic Metadata

SysML 2.0 is a general purpose modelling language. Domain-specific
languages that have all the important concepts built in tend to be
more efficient in a concrete domain. SysML 2.0 can be extended to
include important domain concepts, whether to enhance the language
with new features, to introduce methodology-specific terminology,
or to use it as a customised domain-specific language
(Ch 41, p 265).

## Two extension strategies

### Strategy 1: model libraries

The primary way of extending SysML 2.0 (or KerML) is to **model
the new concepts with the existing ones**. This is no different
from everyday modelling, except that the author defines more
abstract concepts like `Function` or `Platform`. These new
elements are organised into model libraries, in the same way as
SysML 2.0 concepts are modelled in the Systems Library
(Part VII) (Ch 41, p 265).

The SysML v2 book's canonical example defines `Function` and
`Platform` as occurrence definitions, together with a
`FunctionalAllocation` that can allocate functions to platforms.
See [[sysml2-allocation-definitions]] for the allocation pattern.

```sysml
library package PlatformBasedSystemsEngineering {
    occurrence def Function;
    occurrence def Platform;
    allocation def FunctionalAllocation { /* ... */ }
}
```

Libraries should be packaged in `library` packages to signal that
the elements are meant for reuse (Ch 41, p 266).

A cautionary note from Chapter 41: to support usage-focused
modelling, **avoid abstract definitions in libraries** unless they
are meant to be incomplete and unusable on their own. Users of a
library should decide whether to specialise a definition or simply
use it with nested usages (Ch 41, p 266).

### Strategy 2: user-defined keywords via SemanticMetadata

Libraries already enable domain-specific vocabularies, but the
language goes a step further and allows extending the language
itself with **user-defined keywords**. SysML 2.0 and KerML support
this with semantic metadata (Ch 41, p 267).

The metadata definition `SemanticMetadata` is a kind of `Metadata`
defined in the KerML Metaobjects library (Ch 87.7). Unlike other
metadata, usages of `SemanticMetadata` and its specialisations are
**interpreted by the modelling tool**. They instruct tools to
perform the same trick that happens when a `part` or `action`
keyword is used: insert an implicit specialisation into the element
that has the metadata (Ch 41, p 268).

When the author declares a definition with the keyword `part`, the
definition implicitly specialises `Parts::Part` from the Parts
library. Any metadata can be used as a user-defined keyword by
preceding its long or short name with `#`. When the keyword is
included just before the kind-keyword (for example `part` or
`action`), the declared element gets the metadata, and if it is a
kind of `SemanticMetadata`, the implicit specialisation is
triggered (Ch 41, p 268).

## Defining a user-defined keyword

```sysml
abstract occurrence functions : Function;
abstract occurrence platforms : Platform;
abstract allocation functionalAllocations : FunctionalAllocation;

metadata def <function> FunctionMetadata :> Metaobjects::SemanticMetadata {
    :>> baseType = functions meta SysML::Type;
}
metadata def <platform> PlatformMetadata :> Metaobjects::SemanticMetadata {
    :>> baseType = platforms meta SysML::Type;
}
metadata def <functionalAllocation> FunctionalAllocationMetadata
    :> Metaobjects::SemanticMetadata {
    :>> baseType = functionalAllocations meta SysML::Type;
}
```

The angle-bracket name (`<function>`) is the short keyword. The
`baseType` redefinition specifies the abstract usage that elements
tagged with this keyword implicitly specialise.

## Applying user-defined keywords

Once the semantic metadata definitions are in scope, the new
keywords can be applied with the `#` prefix. The kind-keyword such
as `occurrence` is optional, but the resulting element is then a
plain `Usage` rather than the more specific `OccurrenceUsage`,
which may have unexpected effects for API access or filter
evaluation (Ch 41, p 270):

```sysml
part def Drone {
    // Functions
    #function navigation;
    // Execution platforms
    #platform occurrence navigationSubsystem;
    // Allocations
    #functionalAllocation allocate navigation to navigationSubsystem;
}
```

More than one user-defined keyword can be applied to the same
element, which is useful when the keywords capture orthogonal
aspects. For example, `navigation` could also be `#critical`
alongside `#function`, adding the features of a critical-function
metadata. User-defined keywords can target definitions or usages
(Ch 41, p 271).

## Gotchas

### Kind-keyword is optional but recommended

The kind-keyword such as `occurrence`, `part`, or `action` is
optional after a `#` keyword. Omitting it makes the declared
element a plain `Usage` rather than a more specific kind. This can
cause unexpected results when the model is accessed via the API,
or when filters match on element kind (Ch 41, p 270).

### Silent base-type mismatch

The base type of semantic metadata can be set to a definition
rather than a usage. That is sensible only when the keyword is
meant for definitions. If the keyword is then accidentally used
with a usage, no implicit specialisation is added, and there is no
error message. To avoid this silent failure, redefine the
`annotatedElement` feature of the semantic metadata with the type
`SysML::Definition`, which triggers a meaningful error when the
keyword is applied to a usage (Ch 41, p 271).

### No custom validation rules

There is currently no way to attach extra validation rules to
user-defined keywords. Incorrect usage may fail silently.
Heavyweight domain-specific language development may still need
traditional transformation-based approaches (Ch 41, p 271).

## See also

- [[sysml2-metadata-overview]] for the broader metadata frame.
- [[sysml2-metadata-definitions]] for ordinary metadata syntax.
- [[sysml2-allocation-definitions]] for the allocation extension
  example used in this chapter.
- [[sysml2-vse-library-metadata]] for the VSE_Library that ships
  reusable risk and configuration metadata definitions.
