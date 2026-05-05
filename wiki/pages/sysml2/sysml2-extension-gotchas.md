---
title: "SysML 2.0 Extension Gotchas"
slug: sysml2-extension-gotchas
type: pattern
layer: sysml2
tags: [language-extension, gotchas, semantic-metadata]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 41 Section 41.2, pages 295 to 297."
    raw: sysmlv2.pdf
related:
  - sysml2-user-defined-keywords
  - sysml2-language-extension
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [sysml2-extension]
---

# SysML 2.0 Extension Gotchas

Three pitfalls accompany the user-defined-keyword mechanism
described in [[sysml2-user-defined-keywords]]. Each can fail
silently and is worth recognising before adopting the mechanism
for a domain library.

## Pitfall 1: kind-keyword optionality changes the resulting type

The kind-keyword (`occurrence`, `part`, `action`, and so on) is
optional after a `#` user-defined keyword. Omitting it makes the
declared element a plain `Usage` rather than a more specific kind.
For example:

```sysml
#platform occurrence navigationSubsystem;   // OccurrenceUsage
#platform navigationSubsystem;              // plain Usage
```

The two declarations carry the same metadata and the same implicit
specialisation, but they differ in their concrete type in the
SysML 2.0 abstract syntax. The downstream consequences appear
when the model is accessed via the API or filtered by element
kind. A view filter that targets `OccurrenceUsage` will pick up
the first form and miss the second (Ch 41.2, p 295). The
recommendation is to keep the kind-keyword in code that crosses
API or view boundaries, even though the language allows omitting
it.

## Pitfall 2: SysML::Type versus SysML::Usage in the meta-cast

Many examples in the wild show the meta-cast operator on the
right-hand side of `:>> baseType` written as `meta SysML::Usage`:

```sysml
:>> baseType = navigations meta SysML::Usage;
```

This works when `baseType` resolves to a usage. The trap is that
**if the base type is a definition rather than a usage, the
meta-cast returns null, and the semantic metadata then does
nothing, silently and without an error message** (Ch 41.2, p 295).
The recommended pattern is to use the more general
`SysML::Type` instead:

```sysml
:>> baseType = navigations meta SysML::Type;
```

`SysML::Type` is the common supertype of `SysML::Usage` and
`SysML::Definition`, so the meta-cast resolves whether the
abstract base is a usage or a definition. The cost is zero, the
benefit is no silent failure mode.

## Pitfall 3: definition-only keywords need an annotatedElement guard

The `baseType` of a SemanticMetadata can be set to a definition
rather than a usage. That is a reasonable choice when the keyword
is meant for definitions only. The trap is that **if a user then
applies the keyword to a usage, no implicit specialisation is
added, and there is no error message** (Ch 41.2, p 296).

To make the misuse fail loudly rather than silently, redefine the
inherited `annotatedElement` feature of the SemanticMetadata with
the type `SysML::Definition`. The metadata machinery then refuses
to apply the keyword to any element that is not a definition, and
the user gets a meaningful error:

```sysml
metadata def <safetyCritical> SafetyCriticalMetadata
    :> Metaobjects::SemanticMetadata
{
    :>> baseType = safetyCriticalDefs meta SysML::Type;
    redef annotatedElement : SysML::Definition;
}
```

The same pattern works in the other direction (`SysML::Usage`)
when the keyword is meant to apply to usages only.

## When user-defined keywords are not enough

User-defined keywords build domain-specific languages on top of
SysML 2.0 with low ceremony, and the resulting models are easier
to read and write than ones with explicit specialisations. Two
practical limitations are worth flagging before adopting the
mechanism for a heavyweight DSL (Ch 41.2, p 297):

- **No custom validation rules.** There is currently no built-in
  way to attach extra validation rules to user-defined keywords
  that signal an error when concepts are used incorrectly.
- **Name-resolution edge cases.** Some specific situations have
  known issues with name resolution. The book expects some of
  these to be addressed in future releases of the language.

For domains that need rigorous validation or transformation into
another representation, traditional transformation-based DSL
toolchains are still the more robust option. Within the limits
above, user-defined keywords are an excellent fit for terminology
shortcuts and methodology vocabularies.

## See also

- [[sysml2-user-defined-keywords]] for the mechanism the pitfalls
  apply to.
- [[sysml2-language-extension]] for the overview of the two
  extension strategies and when to choose which.
