---
title: "SysML 2.0 Binding Connectors"
slug: sysml2-binding-connectors
type: reference
layer: sysml2
tags: [binding-connectors, connectors, equality, value-binding]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 21, pages 127 to 128. New chapter in the 2026-04 release."
    raw: sysmlv2.pdf
related:
  - sysml2-allocations-overview
  - sysml2-allocation-definitions
  - sysml2-self-and-that
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-allocations]
---

# SysML 2.0 Binding Connectors

A **binding connector** is a binary relationship that requires the
usages at the ends to have the **same values**. Binding connectors
are only available as a usage element, and unlike regular
connection elements, a binding connector is **not** a special
occurrence (and therefore also not a special part). This entire
chapter is new in the 2026-04 release of the SysML v2 book
(Chapter 21, pages 127 to 128).

## Connector versus connection

Note the subtle linguistic distinction:

- A **connection** is a relationship and a part. It connects
  features such as parts and items, can have its own structure, and
  is a special occurrence.
- A **connector** is a `ConnectorAsUsage` element, the base element
  for successions and connection usages.
- A **binding connector** is a special `ConnectorAsUsage` element.
  It is **not** a connection, not a part, and not an occurrence.

This distinction matters because authors often expect binding
connectors to behave like connections. They do not.

## Two declaration forms

A binding connector can be declared as part of a usage declaration
using the equal sign, or as a stand-alone element with the
`binding` keyword.

### As part of a usage declaration

The equal sign represents a binding connector. The bound usages are
on the left and right of the equal sign.

```sysml
package <PAPA> 'Payload Attachment Product Architecture' {
    part def PayloadAttachment {
        attribute currentPayloadMass :> ISQ::mass;
        binding payloadMass bind currentPayloadMass = payload.mass;
        item payload [0..1] : PAD::Payload;
    }
}
```

In line 3, the equal sign is a binding connector with bound usages
on the left (`currentPayloadMass`) and the right
(`box.mass + content.mass`).

### As a stand-alone declaration

The full form uses the `binding` keyword followed by the connector
name and the keyword `bind` before the specification of the bound
ends.

```sysml
binding payloadMass bind currentPayloadMass = payload.mass;
```

The name of a binding connector is usually not important. If the
name is omitted, the keyword `binding` can also be omitted:

```sysml
bind currentPayloadMass = payload.mass;
```

## What the connector means

The binding connector connects usages, but it is their **values**
that must be equal. The usages can be different. Since the equal
symbol is also used as an assignment operator in some languages,
some readers interpret it that way in SysML 2.0 as well. **It is
not assignment.** A binding connector is a constraint stating that
the values are equal.

A consequence: a binding connector is **commutative**. The left and
right sides of the equal sign can be swapped without changing the
meaning. An assignment would not allow this; a binding does.

## Graphical notation

The graphical notation of a binding connector is a solid line with
an attached equal sign. A small black circle on the border of an
item or part indicates a **proxy connection**. The binding is
attached not to the item itself but to one of the item's features
(for example `.mass`). The text at the proxy circle points to the
connected element such as `.mass`, which means the bound element
is `payload.mass`, but the element with the circle attached is
omitted from the diagram for clarity.

## When to use a binding connector

Binding connectors are the right tool when:

- Two usages in different contexts must hold the same value (a
  payload's mass and the attached carrier's payload-mass attribute).
- Allocation requires more than a directional mapping. See
  [[sysml2-allocations-overview]] for the contrast with allocation
  relationships.
- A constraint-style equality is needed that propagates through
  the model, rather than a one-time assignment.

For directed mappings between architectural layers, prefer an
allocation. See [[sysml2-allocation-definitions]].

## See also

- [[sysml2-allocations-overview]] for the related (but directed)
  allocation mechanism.
- [[sysml2-self-and-that]] for context navigation that often
  accompanies binding connectors across composition layers.
