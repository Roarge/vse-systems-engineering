---
title: "SysML 2.0 User-Defined Keywords"
slug: sysml2-user-defined-keywords
type: reference
layer: sysml2
tags: [language-extension, semantic-metadata, user-defined-keywords]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 41 Section 41.2, pages 293 to 295."
    raw: sysmlv2.pdf
related:
  - sysml2-language-extension
  - sysml2-domain-model-libraries
  - sysml2-extension-gotchas
  - sysml2-metadata-definitions
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [sysml2-extension]
---

# SysML 2.0 User-Defined Keywords

Domain libraries already enable a domain-specific vocabulary
through ordinary modelling (see
[[sysml2-domain-model-libraries]]), but the language goes a step
further and lets the author **extend the language itself** with
user-defined keywords. SysML 2.0 and KerML support this through
semantic metadata, a special kind of metadata that the modelling
tool interprets at parse time (Ch 41.2, p 293).

## How the mechanism works

The metadata definition `SemanticMetadata` is a kind of `Metadata`
defined in the KerML Metaobjects Library (Section 87.7). Unlike
ordinary metadata, usages of `SemanticMetadata` and its
specialisations **instruct the modelling tool to insert an
implicit specialisation** into the element they annotate. This is
the same trick the language uses for its built-in keywords:

- When you declare a definition with `part`, the language
  implicitly specialises `Parts::Part` from the Parts Library
  (Chapter 100).
- When you declare a usage with `action`, the usage implicitly
  subsets `Actions::actions` from the Actions Library (Chapter 88).

A user-defined keyword reuses this machinery. Any metadata can be
applied as a user-defined keyword by preceding its long or short
name with the `#` symbol, just before the kind-keyword in the
declaration. If the metadata is a kind of `SemanticMetadata`, the
implicit-specialisation effect is triggered (Ch 41.2, p 294).

For ordinary metadata syntax (without the implicit-specialisation
machinery), see [[sysml2-metadata-definitions]].

## The pattern

The pattern has three parts:

1. **Abstract usages** in a domain library that act as the targets
   of the implicit specialisation.
2. **SemanticMetadata definitions** that name short keywords and
   redefine `baseType` to point at one of those abstract usages
   through the meta-cast operator.
3. **Application** of the keyword with the `#` prefix at the call
   site.

Built on the PBSE library from
[[sysml2-domain-model-libraries]], the declarations look like this:

```sysml
abstract occurrence functions : Function;
abstract occurrence platforms : Platform;
abstract allocation functionalAllocations : FunctionalAllocation;

metadata def <function> FunctionMetadata
    :> Metaobjects::SemanticMetadata
{
    :>> baseType = functions meta SysML::Type;
}
metadata def <platform> PlatformMetadata
    :> Metaobjects::SemanticMetadata
{
    :>> baseType = platforms meta SysML::Type;
}
metadata def <functionalAllocation> FunctionalAllocationMetadata
    :> Metaobjects::SemanticMetadata
{
    :>> baseType = functionalAllocations meta SysML::Type;
}
```

The angle-bracket `<function>` and so on are the **short
keywords**. They are the names that appear after `#` at the call
site. The longer name (`FunctionMetadata`) remains available for
explicit references and reflection.

The `:>> baseType` redefines an inherited feature called
`baseType` on `SemanticMetadata`. The right-hand side uses the
**meta-cast operator** `meta` (Chapter 30). The left-hand side is
the abstract base usage of the new concept. The right-hand side
tells the operator to return the `SysML::Type` reflective metadata
instance for that usage. Through reflection, `baseType` ends up
holding a value that represents the modelling element itself,
which is what the tool needs in order to know which element to
specialise when it encounters the keyword.

The standard SysML 2.0 libraries are full of abstract package-level
usages for the same reason: they exist to be the targets of
implicit specialisations.

## Applying the keywords

Once the SemanticMetadata definitions are in scope (either
imported or referred to by qualified name), the new keywords can
be applied at the call site. The `#` prefix replaces the explicit
specialisation:

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

The effect is the same as if `navigation` had been declared
`occurrence navigation : PBSE::Function`,
`navigationSubsystem` had been declared
`occurrence navigationSubsystem : PBSE::Platform`, and the
allocation had been typed by `PBSE::FunctionalAllocation`. The
custom domain model is easier to read and write, and the modeller
does not need to spell out the underlying specialisations
(Ch 41.2, p 294).

## Stacking keywords

User-defined keywords can be stacked when they capture orthogonal
aspects. For example, the function `navigation` could also be
marked `#critical`, where `#critical` is registered through a
separate SemanticMetadata definition that adds the features
characteristic of critical functions:

```sysml
#function #critical navigation;
```

Each keyword contributes its own implicit specialisation. The
order does not affect the resulting type, but conventional reading
order tends to put the more general kind first.

## Definitions and usages

User-defined keywords work on both definitions and usages, even
when the SemanticMetadata's `baseType` is set to a usage. In that
case, the implicit specialisation will target all the definitions
of the usage that was named as the `baseType` value. The mechanism
quietly resolves the difference (Ch 41.2, p 295).

The reverse direction is also supported. The `baseType` of a
SemanticMetadata can be set to a definition rather than a usage.
That is sensible if the keyword is meant to be used with
definitions only. See [[sysml2-extension-gotchas]] for the
recommended `annotatedElement` redefinition that makes a misuse of
such a keyword produce a meaningful error rather than fail
silently.

## See also

- [[sysml2-language-extension]] for the overview of the two
  extension strategies.
- [[sysml2-domain-model-libraries]] for the libraries that supply
  the abstract usages used as `baseType` targets.
- [[sysml2-extension-gotchas]] for the three pitfalls that come
  with this mechanism.
- [[sysml2-metadata-definitions]] for the ordinary (non-keyword)
  metadata syntax.
