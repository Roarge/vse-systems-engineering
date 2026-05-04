---
title: "SysML 2.0 Metadata Definitions and Annotations"
slug: sysml2-metadata-definitions
type: reference
layer: sysml2
tags: [metadata, syntax, annotations, at-syntax]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 36, pages 252 to 254."
    raw: sysmlv2.pdf
related:
  - sysml2-metadata-overview
  - sysml2-reflection-and-classification
  - sysml2-filter-conditions
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-metadata]
---

# SysML 2.0 Metadata Definitions and Annotations

This page captures the syntax for declaring metadata definitions
and applying them as annotations. For background see
[[sysml2-metadata-overview]].

## Metadata definitions

Metadata is a specialised form of annotation. Unlike a comment, a
metadata definition imposes a structured format for its
annotations. The structured form enables automatic evaluation,
such as tracking the development status of a model element or
linking the element to an external representation in another tool
(Ch 36, p 252).

Metadata is defined as items (see Chapter 19.1 of the SysML v2
book) but uses the `metadata` keyword instead of `item`. A
metadata definition declares the attributes that every annotation
of this kind must carry (Ch 36, p 252).

```sysml
library package MBSEMethodology {
    metadata def Status {
        attribute status : StatusKind default StatusKind::idea;
        attribute priority : LevelKind default LevelKind::middle;
        attribute responsiblePerson : ScalarValues::String default "Vince";
    }
    enum def StatusKind {
        idea;
        draft;
        review;
        approved;
    }
}
```

A similar metadata element is available in the SysML domain
libraries (Chapter 99 in the reference part of the SysML v2 book).
Despite being items, metadata usages are annotations: they are
associated with the model element on metalayer M1, not with
instances on metalayer M0.

## Annotating elements

A metadata usage is an annotation attached to an element. The
graphical notation is similar to a comment, with the `metadata`
keyword and a structured list of data. The annotation can also
appear as a compartment inside the annotated element
(Ch 36, p 253).

The textual notation begins with `@` followed by the metadata
definition name. If no further data is given, the annotation
closes with a semicolon. Otherwise the structured data sits inside
curly braces (Ch 36, p 253):

```sysml
part def Battery {
    @Status {
        status = StatusKind::draft;
        priority = LevelKind::high;
        responsiblePerson = "Vince";
    }
}
```

The `@` syntax is the most practical one in most situations. A
longer alternative uses the classical `name : Definition` form
with redefinitions of the metadata features. The longer form is
useful when an element carries more than one metadata of the same
definition, because the long form lets the author give each
annotation a distinct name (Ch 36, p 254).

## Implicit meta-type metadata

KerML and SysML 2.0 ship with several metadata libraries,
including the KerML and SysML reflective libraries (Ch 87.5 and
Ch 105). Those libraries contain metadata definitions that
describe the KerML and SysML metamodel itself. Every modelling
element carries an implicit metadata annotation of its
corresponding meta-type, which is accessible through reflective
expressions (Ch 36, p 254). See
[[sysml2-reflection-and-classification]].

## Risks as metadata: a worked example

SysML 2.0 offers a simple way to model risks. Risks are not
first-class model elements. They are a language extension defined
in a SysML metadata domain library. The library ships with the
SysML v2 book and is referenced in Chapter 112.4 of the reference
section (Ch 38, p 261).

The model element `Risk` is a metadata definition. A `Risk`
metadata usage annotates an element and provides a risk assessment.
When more than one risk applies to an element, the author can name
the usages to distinguish them (Ch 38, p 261).

```sysml
occurrence def UAVProject {
    @RiskMetadata::Risk {
        doc /* Aviation authority approval may be delayed
             * due to evolving regulations for unmanned aerial systems,
             * impacting market launch. */
        totalRisk = new RiskMetadata::RiskLevel(
            probability = RiskMetadata::LevelEnum::medium,
            impact = RiskMetadata::LevelEnum::medium);
        technicalRisk = RiskMetadata::RiskLevelEnum::low;
        scheduleRisk = RiskMetadata::RiskLevelEnum::high;
        costRisk = RiskMetadata::RiskLevelEnum::medium;
    }
}
```

Risks demonstrate the general pattern of how metadata libraries
extend the modelling vocabulary without changing the language
itself.

## See also

- [[sysml2-metadata-overview]] for the conceptual frame.
- [[sysml2-reflection-and-classification]] for `@@` and `meta`.
- [[sysml2-filter-conditions]] for using metadata in imports.
- [[sysml2-vse-library-metadata]] for the canonical VSE_Library
  metadata definitions used across plugin skills.
