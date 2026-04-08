# SysML v2 Variations and Variants Reference

Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U, 2026-03 release.
Chapter and page citations appear inline. This file paraphrases the source, which
is a copyrighted commercial reference and is not reproduced verbatim. Feature
constraint semantics and trade-off analysis coverage are marked as pending in
the 2026-03 release.

---

## 1. Overview (Ch 35, p 246)

SysML v2 directly supports the modelling of variations and variants, making it
one of the few engineering modelling languages that explicitly treats product
variation as a core language feature (Ch 35, p 246). The need for variant
modelling was clear during language development. As with the rise of
model-based engineering itself, explicit variant management became relevant as
complexity increased.

Product Line Engineering (PLE) is covered by the ISO/IEC 26580 standard. The
SysML modelling of variations and variants sits within the shared assets
superset framework of PLE. Product line features are not supported directly by
the SysML language, but can be added through a language extension. For deeper
coverage of Model-Based Product Line Engineering (MBPLE), the book points to
Forlingieri et al. 2025 (Ch 35, p 246).

---

## 2. Variation Definitions (Ch 35, pp 246-248)

Every definition or usage element in SysML v2 can be marked as a variation
through the Boolean property `isVariation` (Ch 35, p 246). The property marks
the element as a decision point at which one of the provided variant options
must be chosen. The variation is sometimes called a variation point, and its
variants are members of the variation's namespace. A variation may only own
variants and annotations such as comments (Ch 35, p 247).

The variation may itself be a definition element. In that form, the variants
are usages defined by the variation definition. Because a variation can only
own variants and annotations, the variation definition typically subclassifies
a part definition that actually specifies the subject (Ch 35, p 248).

---

## 3. Variant Usages (Ch 35, p 247)

The variant part usages implicitly subset the variation. The variation acts as
a placeholder for its variants. Wherever the variation is used, the system must
be able to insert one of the variants. Variants must therefore be
specialisations of the variation (Ch 35, p 247).

In the book's drone example, the part usage `battery` is a variation, and the
part usages `standardBattery` and `powerBattery` are variants. They are members
of the namespace of `battery` through an owning membership relationship. They
are not owned parts of `battery`. The relationship is a variant membership
relationship, which designates the variants as such rather than as composite
parts (Ch 35, p 247).

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

---

## 4. Variation as a Definition (Ch 35, p 248)

A variation can also be expressed as a definition element. The variants are
usages defined by the variation definition. Because a variation can only own
variants and annotations, the variation definition subclassifies a part
definition that actually specifies the subject.

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

---

## 5. Configuration Constraints (Ch 35, p 249)

When a model carries more than one variation, valid combinations of variant
selections are expressed as `assert constraint` bodies. This is the SysML way
to capture constraints that would otherwise live in PLE feature constraints
(Ch 35, p 249).

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

The relationship between SysML variation constraints and PLE feature
constraints is out of scope for the book and is covered in Forlingieri et al.
2025 (Ch 35, p 249).

---

## 6. Setting a Variant (Ch 35, p 249)

To specify a concrete configuration, specialise the owner of the variations
and redefine all variations by setting the variant. The redefining part
rewires references to the selected variant in place of the variation
placeholder (Ch 35, p 249).

```sysml
package 'Delivery Drone Product' {
    part def DeliveryDrone :> DSPA::Drone {
        part :>> battery = battery::powerBattery;
        part :>> engines = engines::sixEngines;
    }
}
```

---

## 7. Integration with a Feature Model (Ch 35, p 250)

Full product line modelling typically lives in an external feature model. The
PLEML language extension introduces a product line feature element and binds
features to variations in a SysML model. The feature model is usually stored
in a separate repository. Feature bindings link external features to
internal variations and variants (Ch 35, p 250).

The book's example binds a mission feature to the engine variation. Because
an `assert constraint` already links engines to batteries, the battery
variation is implicitly driven by the same feature. If a long-range mission
is selected, the `sixEngines` variant applies, and the constraint implies
that the `powerBattery` variant is selected as well (Ch 35, p 250).

---

## 8. Practical Patterns for VSE Authors

### 8.1 Part Variation with Two Variants

Declare a `variation part` with named variants for each concrete option. The
variants specialise the variation and carry their distinguishing attributes
(Ch 35, p 247).

### 8.2 Variation as Definition

When the same variation structure is reused across contexts, declare it as a
variation definition that subclassifies the base part definition. Variant
usages live inside the definition body (Ch 35, p 248).

### 8.3 Cross-Variation Constraint

Use an `assert constraint` with an `implies` expression to enforce valid
combinations across multiple variations (Ch 35, p 249).

### 8.4 Configured Product from Specialisation

Specialise the variation owner and redefine each variation with a concrete
variant to materialise a product from the variation space (Ch 35, p 249).

### 8.5 Feature-Driven Variation Selection

Integrate with an external feature model via the PLEML extension. Feature
bindings connect mission-level features to internal variations, and
constraints handle dependent selections automatically (Ch 35, p 250).

---

## 9. Gotchas and Red Flags

1. **Variants are not owned parts.** Variant usages are related to their
   variation through a variant membership relationship, drawn as a solid line
   with a plus sign in a circle at the owner's end. They are not composite
   parts of the variation. This distinction is critical for correct semantic
   interpretation (Ch 35, p 247).
2. **Variation is a placeholder.** The variation acts as a placeholder.
   Anywhere the variation is used, one variant must be insertable. Variants
   must therefore be specialisations of the variation (Ch 35, p 247).
3. **Variation can only own variants and annotations.** A variation is not a
   normal definition body. It may only own variants and annotations such as
   comments. To give a variation structural detail, use a variation definition
   that subclassifies a concrete part definition (Ch 35, p 247).
4. **Cross-variation constraints live in `assert constraint`.** Valid variant
   combinations are expressed as assert constraints in SysML, not through the
   variation syntax alone. The relationship to PLE feature constraints is out
   of scope for the book (Ch 35, p 249).
5. **Setting a variant requires specialisation.** To fix a concrete
   configuration, specialise the variation owner and redefine each variation
   by binding it to a specific variant. Attempting to set variants directly
   on the base variation does not materialise a concrete product
   (Ch 35, p 249).
6. **Feature model integration needs an extension.** Full PLE feature models
   are not part of the SysML core. The PLEML language extension and tool
   support from vendors are required for a complete MBPLE workflow
   (Ch 35, p 250).

---

## 10. Cross References

- `sysml2-quick-ref.md` Section 2 for `variation part def` and `variant`
  keywords in textual notation.
- `sysml2-semantics-ref.md` for the specialisation base types that variants
  extend.
- `sysml2-expressions-ref.md` Section 9 for the `assert constraint` bodies
  used in configuration constraints.
- `sysml2-metadata-ref.md` for semantic metadata and user-defined keywords,
  which the PLEML extension relies on.

---

## 11. Pending Extensions

This file will grow once the following material is published:

- Formal treatment of feature constraints and their relationship to SysML
  variation constraints (planned for Forlingieri et al. 2025, outside this
  book).
- Trade-off analysis coverage that complements variation selection (Ch 33.2.1
  is marked as pending in the 2026-03 release).

Attribution: Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U,
2026. All claims cite chapter and page. Paraphrased for reference use. Do not
reproduce verbatim.
