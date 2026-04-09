# SysML v2 Metadata, Reflection, and Language Extension Reference

Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U, 2026-03 release.
Chapter and page citations appear inline. This file paraphrases the source, which
is a copyrighted commercial reference and is not reproduced verbatim.

---

## 1. Overview (Ch 36, p 252)

Reflection in programming and modelling languages is the ability of the
language to refer to its own structure. KerML and SysML v2 support reflection
in several ways. Models can be extended with metadata annotations, which store
information about the model elements rather than about the modelled instances.
Reflective expressions can access these annotations together with built-in
ones that describe the model element itself. Reflection and metadata can be
used in filters to implement smart packages and to specify view contents
declaratively (Ch 36, p 252).

Metadata and reflection sit at the boundary between language use and language
extension. Chapter 41 builds directly on them to define user-defined keywords
and domain-specific extensions.

---

## 2. Metadata Definitions (Ch 36, pp 252-254)

Metadata is a specialised form of annotation. Unlike a comment, a metadata
definition imposes a structured format for its annotations. The structured
form enables automatic evaluation, such as tracking the development status of
a model element or linking the element to an external representation in
another tool (Ch 36, p 252).

Metadata is defined as items (see Ch 19.1) but uses the `metadata` keyword
instead of `item`. A metadata definition declares the attributes that every
annotation of this kind must carry (Ch 36, p 252).

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

A similar metadata element is available in the SysML domain libraries
(Ch 99 in the reference part of the book). Despite being items, metadata
usages are annotations. They are associated with the model element on
metalayer M1, not with instances on metalayer M0. Metadata is therefore always
about the model and never about the system being modelled (Ch 36, p 254).

---

## 3. Annotating Elements (Ch 36, pp 253-254)

A metadata usage is an annotation attached to an element. The graphical
notation is similar to a comment, with the `metadata` keyword and a structured
list of data. The annotation can also appear as a compartment inside the
annotated element (Ch 36, p 253).

The textual notation begins with `@` followed by the metadata definition name.
If no further data is given, the annotation closes with a semicolon. Otherwise
the structured data sits inside curly braces (Ch 36, p 253).

```sysml
part def Battery {
    @Status {
        status = StatusKind::draft;
        priority = LevelKind::high;
        responsiblePerson = "Vince";
    }
}
```

The `@` syntax is the most practical one in most situations. A longer
alternative uses the classical `name : Definition` form with redefinitions of
the metadata features. The longer form is useful when an element carries more
than one metadata of the same definition, because the long form lets the
author give each annotation a distinct name (Ch 36, p 254).

KerML and SysML ship with several metadata libraries, including the KerML and
SysML reflective libraries (Ch 87.5 and Ch 105). Those libraries contain
metadata definitions that describe the KerML and SysML metamodel itself.
Every modelling element carries an implicit metadata annotation of its
corresponding meta-type, which is accessible through reflective expressions
(Ch 36, p 254).

---

## 4. Reflective and Metaclassification Expressions (Ch 36, pp 254-255)

Metaclassification expressions form the foundation of the SysML reflection
mechanism. They enable access to both explicit and implicit metadata
annotations associated with an element. The resulting expression can reason
about properties of the element itself, for example to filter all abstract
types (Ch 36, p 254).

A metadata access expression returns all the metadata associated with a model
element, including the implicit metadata describing the element itself. The
access expression is written as the element name, a dot, and the `metadata`
keyword. Metadata access is already enough for full reflection, but two
operators make it easier to work with specific metadata (Ch 36, p 254).

- **`@@`** takes an element as its first operand and a metadata definition as
  the second, and checks whether the first operand carries at least one
  metadata annotation defined by the second. It is similar to `@` but
  operates one meta-layer below. Most often used with the metadata definitions
  in the KerML and SysML libraries to create reflective checks
  (Ch 36, p 254).
- **`meta`** takes the same operands but, instead of checking for matching
  metadata, returns all metadata of the specified type. Useful for navigating
  into M2. Applied when filtering by metaproperties and in language
  extension (Ch 36, pp 254-255).

```sysml
metadata def DesignPart;

abstract part def UAV {
    @DesignPart;
}

attribute isDesign = UAV.metadata @ DesignPart;
attribute isPartDef = (UAV @@ SysML::PartDefinition);
attribute isAbstract = (UAV meta SysML::PartDefinition).isAbstract;
```

Line 5 fetches all metadata annotations attached to `UAV` and uses the `@`
operator to check whether at least one is an instance of `DesignPart`. Line 6
uses `@@` to do the same for `PartDefinition` from the SysML library. Line 7
fetches all attached metadata instances of a given type and navigates into
them via a feature chain (Ch 36, p 255).

---

## 5. Filter Conditions (Ch 36, pp 256-257)

Imports can be restricted with filter conditions that impact which elements
are brought into a namespace. A filter condition is a Boolean expression about
model elements. An imported element is brought in only when the filter
condition is true for it (Ch 36, p 256).

Filters can reduce the number of imported elements, which cuts naming
conflicts and can improve tool performance, since tools must handle fewer
elements in a namespace. Another important use is smart packages. A public
import with a filter condition can define the content of a package
declaratively, collecting certain elements from other packages based on a
condition. Filters also define views (Ch 36, p 256, cross-referenced from
Ch 37).

```sysml
package PartsCatalogue {
    private import 'Drone System Logical Architecture'::**;
    private import 'Drone System Product Architecture'::**;

    filter @SysML::PartUsage;
}
```

Filters can also be written in terms of custom metadata. A filter can combine
reflective metadata with project metadata (Ch 36, p 257).

```sysml
package ApprovedPartsCatalogue {
    private import 'Drone System Logical Architecture'::**;
    private import 'Drone System Product Architecture'::**;

    filter @SysML::PartUsage and
        @MBSEMethodology::Status::status == MBSEMethodology::StatusKind::approved;
}
```

If a filter condition is placed in square brackets without the `filter`
keyword immediately after a specific import statement, the filter applies only
to that import rather than to all imports in the package. This is a subtle
distinction that changes scope (Ch 36, p 257).

---

## 6. Risks as Metadata (Ch 38, pp 261-262)

SysML v2 offers a simple way to model risks. Risks are not first-class model
elements. They are a language extension defined in a SysML metadata domain
library. The library ships with the book and is referenced in Ch 112.4 of the
reference section (Ch 38, p 261).

The model element `Risk` is a metadata definition. A `Risk` metadata usage
annotates an element and provides a risk assessment. When more than one risk
applies to an element, the author can name the usages to distinguish them.
The usage syntax follows the standard metadata options from Ch 36.1
(Ch 38, p 261).

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

Risks demonstrate the general pattern of how metadata libraries extend the
modelling vocabulary without changing the language itself.

---

## 7. Model Libraries as Extension (Ch 41, pp 265-267)

SysML is a general purpose modelling language. Domain-specific languages that
have all the important concepts built in tend to be more efficient in a
concrete domain. SysML can be extended to include important domain concepts,
whether to enhance the language with new features, to introduce
methodology-specific terminology, or to use it as a customised domain-specific
language (Ch 41, p 265).

The primary way of extending SysML (or KerML) is to model the new concepts
with the existing ones. This is no different from everyday modelling, except
that the author defines more abstract concepts like `Function` or `Platform`.
These new elements are organised into model libraries, in the same way as
SysML concepts are modelled in the Systems Library (Part VII) (Ch 41, p 265).

The book's canonical example defines `Function` and `Platform` as occurrence
definitions, together with a `FunctionalAllocation` that can allocate
functions to platforms. Libraries should be packaged in `library` packages to
signal that the elements are meant for reuse (Ch 41, p 266).

A cautionary note from the chapter. To support usage-focused modelling, avoid
abstract definitions in libraries unless they are meant to be incomplete and
unusable on their own. Users of a library should decide whether to specialise
a definition or simply use it with nested usages (Ch 41, p 266).

---

## 8. User-Defined Keywords (Ch 41, pp 267-271)

Libraries already enable domain-specific vocabularies, but the language goes a
step further and allows extending the language itself with user-defined
keywords. SysML and KerML support this with semantic metadata (Ch 41, p 267).

The metadata definition `SemanticMetadata` is a kind of `Metadata` defined in
the KerML Metaobjects library (Ch 87.7). Unlike other metadata, usages of
`SemanticMetadata` and its specialisations are interpreted by the modelling
tool. They instruct tools to perform the same trick that happens when a `part`
or `action` keyword is used, that is they insert an implicit specialisation
into the element that has the metadata (Ch 41, p 268).

When the author declares a definition with the keyword `part`, the definition
implicitly specialises `Parts::Part` from the Parts library. When the author
declares a usage with the keyword `action`, the usage implicitly subsets
`Actions::actions` from the Actions library. Any metadata can be used as a
user-defined keyword by preceding its long or short name with `#`. When the
keyword is included just before the kind-keyword (for example `part` or
`action`), the declared element gets the metadata, and if it is a kind of
`SemanticMetadata`, the implicit specialisation is triggered (Ch 41, p 268).

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

Once the semantic metadata definitions are in scope, the new keywords can be
applied with the `#` prefix. The `kind-keyword` such as `occurrence` in this
example is optional, but the resulting element is then a plain `Usage` rather
than the more specific `OccurrenceUsage`, which may have unexpected effects
for API access or filter evaluation (Ch 41, p 270).

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

More than one user-defined keyword can be applied to the same element, which
is useful when the keywords capture orthogonal aspects. For example,
`navigation` could also be `#critical` alongside `#function`, adding the
features of a critical-function metadata. User-defined keywords can target
definitions or usages (Ch 41, p 271).

A caveat from the chapter. The base type of semantic metadata can be set to a
definition rather than a usage. That is sensible only when the keyword is
meant for definitions. If the keyword is then accidentally used with a usage,
no implicit specialisation is added, and there is no error message. To avoid
this silent failure, redefine the `annotatedElement` feature of the semantic
metadata with the type `SysML::Definition`, which triggers a meaningful error
when the keyword is applied to a usage (Ch 41, p 271).

---

## 9. Practical Patterns for VSE Authors

### 9.1 Status Tracking on Elements

Define a metadata with `status`, `priority`, and `responsiblePerson` and
annotate elements as they move through the lifecycle. A filtered view can
then produce a list of elements that still need review (Ch 36, pp 252-253).

### 9.2 Smart Package Through Filter

Use a `filter` clause in a package to define its contents declaratively. For
example, a parts catalogue that collects all approved part usages from other
packages using the reflective `@SysML::PartUsage` check together with a
project-specific approval metadata (Ch 36, pp 256-257).

### 9.3 Reflective Abstract-Type Check

Use the `@@` operator together with the SysML reflective library to test
whether a model element is a part definition, an abstract definition, or any
other meta type. Useful in model validation scripts and automated checks
(Ch 36, pp 254-255).

### 9.4 Risk Annotation

Attach a `RiskMetadata::Risk` annotation to a part or project element to
record probability, impact, and category-specific risk levels. A filter can
surface all elements carrying medium or high risks for review (Ch 38, p 261).

### 9.5 Domain Library with Semantic Keywords

Define `Function`, `Platform`, and `FunctionalAllocation` in a library and
ship semantic metadata alongside them. Downstream authors then write
`#function navigation` and `#platform occurrence navigationSubsystem` rather
than the long form (Ch 41, pp 265-270).

### 9.6 Stacked Keywords

Apply more than one user-defined keyword to a single element when the
keywords capture orthogonal aspects, such as `#critical #function navigation`
to mark a function as both a function and a critical element (Ch 41, p 271).

### 9.7 View-Filtered Import

Combine a package-level import with a metadata filter to produce a
view-specific namespace. Only elements carrying the required metadata appear
in the filtered view (Ch 36, p 257, Ch 37, p 260).

---

## 10. Gotchas and Red Flags

1. **Metadata annotates models, not instances.** Metadata usages sit on the
   model element at metalayer M1, not on instances at M0. Metadata is always
   about the model, not about the system being modelled. Misreading this
   leads authors to attempt tag-based runtime state, which does not work
   (Ch 36, p 254).
2. **`@` versus `@@`.** The two operators operate at different meta-layers.
   `@` checks explicit metadata annotations on an element, while `@@` checks
   metadata annotations one meta-layer below. Reflective library checks
   typically need `@@` (Ch 36, p 254).
3. **`meta` can return null.** The `meta` operator returns all metadata of a
   given type. When the base type is a definition but the element is a
   usage, the operator returns null. Silent null results can mask bugs
   (Ch 41, p 271).
4. **Filter condition scope.** Filter conditions in square brackets after a
   specific import apply only to that import. A filter condition with the
   `filter` keyword applies to every import in the package. The two scopes
   differ subtly and surface only at evaluation time (Ch 36, p 257,
   Ch 37, p 260).
5. **Kind-keyword is optional but recommended.** The kind-keyword such as
   `occurrence`, `part`, or `action` is optional after a `#` keyword. Omitting
   it makes the declared element a plain `Usage` rather than a more specific
   kind. This can cause unexpected results when the model is accessed via the
   API, or when filters match on element kind (Ch 41, p 270).
6. **Silent base-type mismatch.** When semantic metadata uses a definition
   for its base type and the keyword is then applied to a usage, no implicit
   specialisation is added and no error is reported. Redefine the
   `annotatedElement` feature to trigger a meaningful error (Ch 41, p 271).
7. **No custom validation rules for user-defined keywords.** There is
   currently no way to attach extra validation rules to user-defined
   keywords. Incorrect usage may fail silently. Heavyweight domain-specific
   language development may still need traditional transformation-based
   approaches (Ch 41, p 271).
8. **Open issue on filter expression syntax.** The chapter flags an open
   issue in the OMG KerML group (KERML11-183) regarding filter expressions.
   Syntax may change in future SysML releases (Ch 36, p 257).

---

## 10A. VSE Library as Canonical Definition Site

The VSE Systems Engineering plugin ships a reusable library package
(`VSE_Library`) that centralises all metadata definitions and
enumerations used across AMBSE workflow skills. The library lives at
`templates/common/library/vse-library.sysml` in the plugin and is
copied into user projects by `@project-setup`.

User projects import definitions from `VSE_Library` rather than
redeclaring them. This follows the model library extension pattern from
Section 7 above: define abstract concepts once, package them for reuse,
and import them in downstream models.

### 10A.1 Library contents

| Definition | Kind | Source |
| --- | --- | --- |
| `RiskInfo` | `metadata def` | ISO 29110 PM.O5 via Ch 38 risk pattern |
| `ConfigItem` | `metadata def` | ISO 29110 PM.1.13 |
| `Baseline` | `metadata def` | ISO 29110 PM.2.5 |
| `CIState` | `enum def` | Draft, Baselined, UnderChange, Superseded, Retired |
| `Severity` | `enum def` | Five-level risk severity scale |
| `Likelihood` | `enum def` | Five-level risk likelihood scale |
| `RiskStatus` | `enum def` | Open, Mitigating, Mitigated, Accepted, Closed |
| `VariantScope` | `metadata def` | VAMOS variant organisation (new) |
| `VerificationScope` | `metadata def` | Per-configuration V&V scoping (new) |

### 10A.2 Variant-aware metadata

`VariantScope` and `VerificationScope` support VAMOS variant
organisation across the AMBSE layout. Both carry a `configurations`
attribute (a string list matching configuration part def names in
`{{sc}}_Configurations`).

`VariantScope` tags any element (risk, requirement, architecture
element) with the configuration(s) it applies to. Omit when the
element applies to all configurations (shared).

`VerificationScope` tags a verification case with the configuration(s)
it targets. Used by `@traceability-guard` Rule 6 (advisory) and by
SR.6 per-configuration report export.

### 10A.3 Variant-scoping rule for 29110 products

During SR.2 through SR.5, each 29110 work product is one instance with
inline variant branches. Variant-specific elements are tagged with
`@VariantScope` or `@VerificationScope`. At the macrocycle boundary
(SR.6 delivery), configuration-scoped exports are generated by
filtering on these metadata tags. This prevents work product explosion
while preserving per-configuration documentation at delivery.

---

## 11. Cross References

- `sysml2-quick-ref.md` Sections 21-22 for documentation, comment, and
  metadata textual syntax.
- `sysml2-semantics-ref.md` for the `Metaobjects` library and the
  specialisation and subsetting base types that metadata and semantic
  metadata rely on.
- `sysml2-expressions-ref.md` Section 7 for classification expressions,
  which share operator notation with metaclassification.
- `sysml2-views-ref.md` Sections 4-5 for expose statements and filters, which
  are authored with the same filter syntax.
- `sysml2-allocations-ref.md` Section 7.5 for the user-defined keyword idiom
  applied to allocation usages.
- `sysml2-variants-ref.md` Section 7 for PLEML, which itself is a language
  extension built on semantic metadata.
- `sysml2-model-structure-ref.md` Section 9A for the complete 29110 product
  mapping table showing which products use which library definitions.
- `templates/common/library/vse-library.sysml` for the canonical definition
  source of all VSE metadata and enumerations.

---

## 12. Pending Extensions

This file will grow once the following material is published in a future
release of the book:

- Ch 84 Metadata in Part V SysML Reference (full formal reference).
- Ch 112.4 Risk metadata domain library (the book notes risk as a language
  extension in this chapter).
- OMG KerML group resolution of KERML11-183 on filter expression syntax.

Attribution: Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U,
2026. All claims cite chapter and page. Paraphrased for reference use. Do not
reproduce verbatim.
