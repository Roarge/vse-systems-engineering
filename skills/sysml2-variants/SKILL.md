---
name: sysml2-variants
description: Author SysML 2.0 variation points, variant usages, and configuration selection. Use when modelling product lines, alternatives, or configuration trade spaces.
user-invocable: true
---

# SysML 2.0 Variations and Variants

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

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

## Reference: SysML 2.0 Variations and Variants

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/sysml2-variants-ref.md`
