---
title: "SysML 2.0 Variant Configuration and Constraints"
slug: sysml2-variant-configuration
type: reference
layer: sysml2
tags: [variants, configuration, constraints, feature-binding]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 35, pages 249 to 250."
    raw: sysmlv2.pdf
related:
  - sysml2-variations-overview
  - sysml2-variation-definitions
  - sysml2-expressions-constraints
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-variants]
---

# SysML 2.0 Variant Configuration and Constraints

This page captures the three operations that drive a variation model
from declaration to a concrete configured product: writing
cross-variation constraints, materialising a configuration through
specialisation, and binding to an external feature model. For the
declaration syntax itself, see [[sysml2-variation-definitions]].

## Cross-variation constraints

When a model carries more than one variation, valid combinations of
variant selections are expressed as `assert constraint` bodies. This
is the SysML 2.0 mechanism for capturing constraints that would
otherwise live in a PLE feature model (Ch 35, p 249).

```sysml
part def Drone {
    variation part battery : Battery { /* variants omitted */ }
    variation part engines[4..6] {
        variant part fourEngines[4];
        variant part sixEngines[6];
    }
    assert constraint {
        engines == engines::sixEngines
            implies battery == battery::powerBattery
    }
}
```

The constraint body is a Boolean expression over variant references.
It is evaluated when a configuration is materialised. If a
configuration violates the constraint, the model is inconsistent and
the configuration is rejected.

The relationship between SysML 2.0 variation constraints and PLE
feature constraints is out of scope for the SysML v2 book and is
covered in Forlingieri et al. (2025).

For the general expression and constraint language, see
[[sysml2-expressions-constraints]].

## Setting a variant through specialisation

To specify a concrete configuration, specialise the owner of the
variations and redefine all variations by setting the variant. The
redefining part rewires references to the selected variant in place
of the variation placeholder (Ch 35, p 249).

```sysml
package 'Delivery Drone Product' {
    part def DeliveryDrone :> DSPA::Drone {
        part :>> battery = battery::powerBattery;
        part :>> engines = engines::sixEngines;
    }
}
```

The `:>>` redefinition operator rebinds each variation usage to a
specific variant. The result is a concrete part definition that no
longer carries variation points. Composition, mass roll-up, and
other property derivations now compute with a single variant per
variation, as expected.

A configuration that omits a variant for a given variation leaves
that variation unresolved. The model is well-formed only when every
variation is bound. Mass and cost roll-ups on an unresolved model
remain ambiguous.

## Binding to an external feature model

Full product line modelling typically lives in an external feature
model. The PLEML language extension introduces a product line
feature element and binds features to variations in a SysML model.
The feature model is usually stored in a separate repository.
Feature bindings link external features to internal variations and
variants (Ch 35, p 250).

In the SysML v2 book's example, a mission feature is bound to the
engine variation. Because an `assert constraint` already links
engines to batteries, the battery variation is implicitly driven by
the same feature. If a long-range mission is selected, the
`sixEngines` variant applies, and the constraint implies that the
`powerBattery` variant is selected as well (Ch 35, p 250).

The PLEML extension is not part of core SysML 2.0. Tool support is
required from the modelling environment vendor. For VSE-scale
projects with limited variation, an internal-only variation model
without external feature binding is usually sufficient. See
[[sysml2-variant-patterns]] for VSE authoring guidance.

## See also

- [[sysml2-variations-overview]] for the conceptual frame.
- [[sysml2-variation-definitions]] for variation declaration syntax.
- [[sysml2-variant-patterns]] for VSE-scale patterns and gotchas.
