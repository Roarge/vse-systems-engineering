---
title: "SysML 2.0 Extension: Overview"
slug: sysml2-language-extension
type: concept
layer: sysml2
tags: [extension, language-extension]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 41, pages 291 to 297."
    raw: sysmlv2.pdf
related:
  - sysml2-domain-model-libraries
  - sysml2-user-defined-keywords
  - sysml2-extension-gotchas
  - sysml2-metadata-overview
  - sysml2-vse-library-metadata
confidence: high
created: 2026-05-04
updated: 2026-05-05
bundled_by: [sysml2-extension]
---

# SysML 2.0 Extension: Overview

SysML 2.0 is a general purpose modelling language. Domain-specific
languages that have all the important concepts built in tend to be
more efficient in a concrete domain. SysML 2.0 can be extended to
include important domain concepts, whether to enhance the language
with new features, to introduce methodology-specific terminology,
or to use it as a customised domain-specific language (Ch 41,
p 291).

The language offers two extension strategies that can be used
independently or together. This page is the hub. It frames the
choice and points at the atomic pages that cover each strategy in
depth.

## Strategy 1: model libraries

Define new abstract concepts as ordinary modelling elements,
organise them into `library package` declarations, and ship them
for reuse. This is the same mechanism the language uses for its
own built-in concepts (Parts, Actions, Cases, and so on). Use this
strategy when the goal is a reusable vocabulary of domain
abstractions: `Function` and `Platform` for platform-based
systems engineering, `Hazard` and `SafetyMeasure` for safety
engineering, `Component` and `Interface` for a reference
architecture.

See [[sysml2-domain-model-libraries]] for the full pattern,
including the canonical PBSE example with `Function`, `Platform`,
and `FunctionalAllocation`, the `library` package modifier, the
guidance to avoid abstract definitions, and how users apply the
library by import or qualified name.

## Strategy 2: user-defined keywords

Register short keywords through `Metaobjects::SemanticMetadata`,
and apply them at the call site with the `#` prefix. The
modelling tool interprets these keywords and inserts the implicit
specialisation that the explicit form would have written. Use
this strategy when the goal is a compact call-site vocabulary on
top of an existing library, for example to write `#function
navigation;` instead of `occurrence navigation : PBSE::Function;`.

See [[sysml2-user-defined-keywords]] for the mechanics, including
the abstract-usage targets, the meta-cast operator on `baseType`,
the `#name` application syntax, and how to stack multiple keywords
on a single element.

## Choosing between them, or stacking them

The two strategies are complementary, not exclusive. A typical
domain extension defines a model library first (Strategy 1) and
then registers user-defined keywords on top of it (Strategy 2).
The library does the conceptual work, and the keywords give it a
clean call-site syntax. A domain that does not need the
conceptual scaffolding can stop after Strategy 1, and a project
that only needs vocabulary shortcuts can stop after Strategy 2.

## Limits and pitfalls

User-defined keywords come with three pitfalls that fail silently:
the kind-keyword optionality changes the resulting type, the
choice of `SysML::Type` versus `SysML::Usage` in the meta-cast can
turn the keyword into a no-op, and definition-only keywords need
an `annotatedElement` redefinition to refuse misuse. There is also
no built-in custom validation rule machinery and there are
known name-resolution edge cases.

See [[sysml2-extension-gotchas]] for each pitfall and the
recommended workaround.

## See also

- [[sysml2-domain-model-libraries]] for Strategy 1 in depth.
- [[sysml2-user-defined-keywords]] for Strategy 2 in depth.
- [[sysml2-extension-gotchas]] for the silent-failure modes and
  the workarounds.
- [[sysml2-metadata-overview]] for the broader metadata frame
  that user-defined keywords sit inside.
- [[sysml2-vse-library-metadata]] for a worked example of a
  library that combines metadata definitions and reusable
  enumerations for VSE workflows.
