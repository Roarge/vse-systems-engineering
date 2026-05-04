---
title: "SysML 2.0 Variation Definitions and Variant Usages"
slug: sysml2-variation-definitions
type: reference
layer: sysml2
tags: [variants, syntax, definitions]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 35, pages 246 to 248."
    raw: sysmlv2.pdf
related:
  - sysml2-variations-overview
  - sysml2-variant-configuration
  - sysml2-quick-ref-keywords
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-variants]
---

# SysML 2.0 Variation Definitions and Variant Usages

This page captures the two declaration forms for variations and the
variant usages they own. For background and product line context, see
[[sysml2-variations-overview]].

## Variation as a usage

The most common form declares a variation directly inside a containing
definition. The keyword `variation` precedes the part keyword. The
body owns one or more `variant` part declarations.

```sysml
package 'Drone System Product Architecture' {
    part def Drone {
        variation part battery : Battery {
            variant part standardBattery {
                attribute :>> totalMass = 1.6 [SI::kg];
            }
            variant part powerBattery {
                attribute :>> totalMass = 2.2 [SI::kg];
            }
        }
    }
}
```

Each variant part usage implicitly subsets the variation. The
variation acts as a placeholder. Anywhere the variation is used in a
parent context, one of the variants must be insertable in its place.
Variants must therefore be specialisations of the variation
(Ch 35, p 247).

## Variation as a definition

The same variation structure can be expressed as a definition
element. The variants are usages defined by the variation definition.
Because a variation may only own variants and annotations, the
variation definition typically subclassifies a part definition that
actually specifies the subject (Ch 35, p 248).

```sysml
variation part def Battery :> DronePartsCatalogue::Battery {
    variant part standardBattery {
        attribute :>> totalMass = 1.6 [SI::kg];
    }
    variant part powerBattery {
        attribute :>> totalMass = 2.2 [SI::kg];
    }
}
```

This form is preferred when the variation structure is reused across
contexts or stored in a parts catalogue alongside non-variation
definitions.

## Variant membership relationship

Variant usages are not composite parts of the variation. They are
related to the variation through a variant membership relationship.
In notation, this relationship is drawn as a solid line with a plus
sign in a circle at the owner's end. The distinction matters because:

- Composite parts contribute to the structural decomposition of
  their owner.
- Variants contribute to the namespace of their owner without
  participating in its structural decomposition.

A model that treats variants as composite parts will compute mass,
cost, and other roll-up properties incorrectly, because every variant
will contribute when only one is meant to be selected.

## Constraints on variation contents

A variation may only own:

- Variants. Each variant is a usage that subsets or specialises the
  variation.
- Annotations. Comments and metadata are permitted.

A variation may not own:

- Composite parts that are not variants.
- Attributes, ports, or other structural members.

To attach structural detail to a variation, declare a variation
definition that subclassifies a concrete part definition. The base
definition carries the structural detail. The variation definition
carries the variant set.

## See also

- [[sysml2-variations-overview]] for the conceptual frame.
- [[sysml2-variant-configuration]] for setting variants and
  cross-variation constraints.
- [[sysml2-variant-patterns]] for VSE-scale authoring patterns.
