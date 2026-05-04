---
title: "SysML 2.0 Contextual References: self and that"
slug: sysml2-self-and-that
type: reference
layer: sysml2
tags: [self, that, this, navigation, context, kerml]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Section 17.3, pages 98 to 99. New in the 2026-04 release."
    raw: sysmlv2.pdf
related:
  - sysml2-actions
  - sysml2-occurrence-context-and-variables
  - sysml2-binding-connectors
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-behaviour]
---

# SysML 2.0 Contextual References: self and that

KerML defines two special features that every type and every feature
inherits: `self` and `that`. They are the most fundamental
navigation capabilities in the language. This material was added to
the SysML v2 book in the 2026-04 release as a new Section 17.3.
A third related feature, `this`, is covered in
[[sysml2-occurrence-context-and-variables]] and connects to the
4D-modelling worldview.

## The self feature

The feature `self` is defined on the library type `Anything` (see
Section 87.1 of the SysML v2 book), so every type in KerML and
SysML inherits it. In any context, `self` refers to the instance
being talked about.

| Context | What `self` refers to |
|---|---|
| Inside a part definition | The part instance |
| Inside a connector body | The connector |
| Inside an action definition | The action being performed |

Typical uses of `self`:

- Passing the context into an expression (see Chapter 30 of the
  SysML v2 book and [[sysml2-expressions-overview]]).
- Connecting the context to one of its components (see Chapter 20
  on connections).

```sysml
part def DroneSystem {
    part operator;
    part drone {
        // "self" refers to the drone
        connect self to operator;
    }
}
```

### Practical detail: typing self

The inherited `self` is typed by `Anything`, which is too general
to navigate model-specific features. To use `self` for navigation,
redefine it with the proper type, or cast it inline.

## The that feature

The feature `that` is defined on the library feature `things`, the
base of every feature and usage. It points to the **domain instance
of the feature it appears in**: the instance that owns the feature.

The relationship to ordinary feature evaluation:

- Inside a feature `f`, evaluating `f` gives its value.
- Evaluating `f.that` gives the instance that owns `f`.

This lets the model navigate **backwards** through a feature chain.

```sysml
part def DroneSystem {
    part operator;
    part drone {
        // "that" refers to the DroneSystem instance featuring the drone
        redefines that : DroneSystem;
        ref part operator = that.operator;
    }
}
```

Like `self`, the inherited `that` is typed by `Anything` and needs
a redefinition to be useful. In practice, authors can often avoid
`that` entirely by referring to outer-namespace names directly. A
model interpreter still infers the navigation through a `that`
chain under the hood, the model author just does not have to write
it.

## Self versus that versus this

These three look similar but mean different things:

- **`self`** is always the instance itself. Every type in KerML has
  a `self` feature pointing at the featuring instance.
- **`that`** is the **domain instance of a feature**, the instance
  to which the feature value is related.
- **`this`** is the **context** in which an occurrence takes place,
  the innermost structural occurrence in its composition chain. It
  propagates through composition and is overridden when the chain
  reaches a structural occurrence. See
  [[sysml2-occurrence-context-and-variables]].

A useful identity to keep in mind: `this.that == self` is always
true.

## See also

- [[sysml2-occurrence-context-and-variables]] for the related
  `this` feature and 4D-context behaviour.
- [[sysml2-actions]] for the action contexts where these features
  most often appear.
- [[sysml2-binding-connectors]] for binding values across contexts.
