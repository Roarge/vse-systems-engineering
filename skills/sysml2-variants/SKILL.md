---
name: sysml2-variants
description: Author SysML 2.0 variation points, variant usages, and configuration selection.
when_to_use: Use for `variation`, `variation part`, `variant`, configuration binding through `:>>`, product lines, alternatives, and configuration trade spaces. Not for the trade study that chooses between them (`@sysml2-cases`, `@architecture-design`).
paths: ["**/*.sysml"]
user-invocable: true
---

# SysML 2.0 Variations and Variants

A `methodology/` folder at the project root, or under `engineering/`, marks a VSE project. If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first. In a SysML-only repository with no `methodology/` folder, skip the lens and proceed directly with this skill.

You guide the engineer through variation and variant modelling in
SysML 2.0. SysML 2.0 treats product variation as a core language feature,
which sits within the shared-assets superset of Product Line Engineering
(ISO/IEC 26580). For project layout and tooling, route back to
`@sysml2-modelling`. For feature-model integration via the PLEML
extension, consult the pending-extensions section in the knowledge file.

## When This Skill Triggers

- The user asks to model alternatives for a part, attribute, or action
- The user wants a product line or configuration trade space
- The user asks how to bind a concrete variant to a base model
- The user asks about cross-variation constraints

## Core Vocabulary

| Element | Keyword | Purpose |
| --- | --- | --- |
| Variation | `variation part`, `variation part def` | Decision point with candidate options |
| Variant | `variant part` | A specialisation of the variation |
| Configuration constraint | `assert constraint` | Rules over combinations of variants |
| Variant selection | `part :>> name = ...::variant` | Picks a concrete variant for a subject |

A variation acts as a placeholder. Its variants are members of the
variation's namespace through a variant membership relationship, not as
owned parts. A variation may only own variants and annotations such as
comments.

## Authoring Patterns

### Part Variation with Named Variants

```sysml
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
```

The `battery` usage is the variation. `standardBattery` and
`powerBattery` are variants, each carrying the attributes that
distinguish it.

### Variation as a Definition

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

When the same variation structure is reused across contexts, declare
it as a variation definition that subclassifies a concrete part
definition.

### Cross-Variation Constraint

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

Valid combinations across variations are expressed as
`assert constraint` bodies with `implies` expressions. This is how
SysML captures the rules that live in PLE feature constraints.

### Selecting a Concrete Configuration

```sysml
package 'Delivery Drone Product' {
    part def DeliveryDrone :> DSPA::Drone {
        part :>> battery = battery::powerBattery;
        part :>> engines = engines::sixEngines;
    }
}
```

To materialise a product, specialise the owner and redefine every
variation by binding it to a specific variant. Setting a variant
directly on the base variation does not produce a concrete product.

## Validation Checklist

1. **Variants are specialisations** of the variation. A variant that
   does not specialise the variation is ill-formed.
2. **Variations own only variants and annotations.** Any other owned
   element violates the variation semantics.
3. **Every variation in the configured product has a variant binding.**
   An unbound variation leaves a placeholder in the product.
4. **Cross-variation constraints are asserted.** Unasserted constraints
   are informational only and do not enforce compatibility.
5. **Multiplicity on variants is explicit** when the base variation
   carries a range such as `[4..6]`.
6. **Every `:>>` variant binding in a configuration targets a
   `variation part` declaration, not a regular part.** If the target
   is a regular part, the binding is a plain redefinition with no
   variant semantics.

## Red Flags

WARN the engineer if:

- A variant owns composite parts that should belong to the variation
  instead (variants are not owned parts of the variation)
- A variation definition has structural content other than variants and
  annotations
- A configuration is declared by binding variants directly on the base
  variation rather than on a specialised owner
- Constraints across variations are written as plain constraints
  without `assert`
- A concrete product has a constraint that its chosen variants violate
- A configuration binds a variant via `:>>` on a part that was never
  declared as `variation part`. The model parses but the variant intent
  is lost. Declare the target as `variation part` in the owning
  definition first

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| SysML 2.0 Variant Configuration and Constraints | pages/sysml2/sysml2-variant-configuration.md | Cross-variation constraints, materialising a configuration, and binding to an external feature model |
| SysML 2.0 Variant Patterns and Gotchas | pages/sysml2/sysml2-variant-patterns.md | Practical variation patterns and the recurring mistakes that show up in review |
| SysML 2.0 Variation Definitions and Variant Usages | pages/sysml2/sysml2-variation-definitions.md | The two declaration forms for variations and the variant usages they own |
| SysML 2.0 Variations and Variants Overview | pages/sysml2/sysml2-variations-overview.md | SysML 2.0 treats product variation as a first-class language feature |
| Binding times and variant constraints | pages/sysmod/sysmod-vamos-binding-and-constraints.md | Binding times, REQUIRES and XOR semantics, configuration validity rules, and their SysML 2.0 mappings |
| Variant modelling concepts: core, variants, and variations | pages/sysmod/sysmod-vamos-concepts.md | The variant vocabulary, the abstraction-distance bound, and deciding whether variants belong in one model |
| Variants and variant configurations: the configuration discipline | pages/sysmod/sysmod-vamos-configurations.md | What belongs in a variant, what a configuration adds, interface management, and behaviour variants |
| Variation points and feature trees in VAMOS | pages/sysmod/sysmod-vamos-feature-trees.md | Variation-point granularity, selection multiplicities on variations, and reading the package tree as a feature tree |
| The VAMOS method: one model for the whole configuration space | pages/sysmod/sysmod-vamos-method.md | VAMOS's core, variations, and configurations packages, their dependency rules, and the superset-model idea |
<!-- wiki-routing:end -->
