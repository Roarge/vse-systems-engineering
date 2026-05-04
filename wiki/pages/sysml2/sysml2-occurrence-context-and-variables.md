---
title: "SysML 2.0 Occurrence Context (this), Suboccurrence vs Portion, and Time-Functions"
slug: sysml2-occurrence-context-and-variables
type: reference
layer: sysml2
tags: [this, suboccurrence, portion, variable-features, time-function, context]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Sections 25.8, 25.9, and 25.10, pages 155 to 158."
    raw: sysmlv2.pdf
related:
  - sysml2-occurrences-4d
  - sysml2-portions-and-individuals
  - sysml2-self-and-that
  - sysml2-actions
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-behaviour]
---

# SysML 2.0 Occurrence Context (this), Suboccurrence vs Portion, and Time-Functions

This page covers three closely related new topics from the 2026-04
release of the SysML v2 book Chapter 25: the distinction between a
suboccurrence and a portion (Section 25.8), the context occurrence
`this` (Section 25.9), and variable features as time-functions
(Section 25.10). For the 4D worldview that frames all three, see
[[sysml2-occurrences-4d]]. For the portion vocabulary, see
[[sysml2-portions-and-individuals]].

## Suboccurrence versus portion

When one occurrence contains another, the language distinguishes
two relationships that look similar but mean very different things.

### A suboccurrence

A **suboccurrence** is a composite occurrence usage (Section
17.2.6 of the SysML v2 book), an **independent** occurrence whose
lifetime is bound to end with the owner's (the **superoccurrence**
in library terms). The library requires its `done` to coincide
with the owner's: when the owner ends, every still-existing
suboccurrence ends with it. (A suboccurrence may have started
before the owner or may be removed earlier, but it cannot survive
the owner's destruction.)

The engine of a car is a suboccurrence of the car: a separate
thing with its own existence and identity, whose lifetime cannot
extend past the car's. A **referential** occurrence usage, by
contrast, imposes no such bound. The referenced occurrence's life
is independent of the owner's. A referential occurrence usage can
have a value that precedes the owner, outlives it, or even exists
entirely after it.

### A portion

A **portion** is a different 4D window onto the **same** thing. A
snapshot of the car at noon is a portion of the car: it is not a
separate thing, it is the car, viewed at one instant. The car and
its snapshot are the same individual.

### Comparison table

| | Suboccurrence | Portion |
|---|---|---|
| Created by | Composite usage | `snapshot` or `timeslice` modifier or subsetting a portion |
| Complete life | Its own | Shared with the owner |
| `===` to owner | False | True |
| `==` to owner | False | Only if the portion is the whole life |

### Direct modelling consequences

When you declare a part usage `engine` inside a `Car` definition,
you are **not** declaring that the engine is a portion of the car.
You are declaring that the engine is a separate occurrence whose
end is tied to the car's. The engine has its own `start`, its own
`done`, its own snapshots, its own complete history. The car's
destruction terminates the engine's existence too, by the rules
for composite usages. Suboccurrences merely **coincide** with
portions of the superoccurrence, but they themselves are not
portions.

If you want to capture that something is genuinely a 4D part of
the same thing (the "head" portion of an animal that shares the
animal's identity), mark the feature with `snapshot` or
`timeslice` (for time portions), or subset one of the owner's
portion features such as `spaceSlices` (for space portions).
Portion features are typed as occurrences and contribute to the
owner's portion structure rather than introducing a new occurrence
with its own life.

To summarise: **suboccurrences are the result of decomposition,
whereas portions represent the spatiotemporal structure of an
occurrence**.

## The context occurrence: this

Every occurrence has a feature called `this`, defined in the
library on `Occurrence`, which represents the **context
occurrence**: the occurrence in which the current one takes place.
Every occurrence is constrained to **happen during its `this`**.

By default, an occurrence's `this` is itself (denoted by the
feature `self`, see [[sysml2-self-and-that]]). The interesting
case is composition: when a behaviour occurrence is composed
inside another occurrence, `this` propagates. The chain walks up
through composition until it reaches the innermost **structural**
occurrence (an item or its specialisation), which becomes `this`.
For an action declared inside a part definition, `this` is the
part. For a sub-action of that action, `this` is still the part.
If no structural occurrence exists in the chain (a free-standing
behaviour with no owner), `this` falls back to the root behaviour
itself. For structural occurrences, `this` always defaults to
`self`.

The practical value is that `this` gives every nested element a
stable handle on the structural context it belongs to. Whatever
the depth of composition, `this` identifies the part (or item)
acting as the context.

### Typing detail

`this` is inherited with the abstract type `Occurrence`. To use
it as a context of a specific type, to refer to features defined
on a particular part, redefine `this` with the desired type in the
declaration. After redefinition, the declared element can access
the context's features directly. (In a later version of the
language, this redefinition may become automatic.)

### self vs that vs this

Three look-alike names with very different meanings:

- **`self`** is always the instance itself. Every type in KerML
  has a `self` feature pointing at the featuring instance.
- **`that`** is the **domain instance of a feature**: the instance
  to which the feature value is related.
- **`this`** is the **context** in which an occurrence takes
  place, the innermost structural occurrence in its composition
  chain. It propagates through composition and is overridden when
  the chain reaches a structural occurrence.

A useful identity: `this.that == self` is always true.

## Variable features as time-functions

Section 17.2.5 of the SysML v2 book introduced **variable usages**
as features whose values can change over time during execution. The
4D worldview gives that statement its precise meaning.

A **non-variable feature** of an occurrence `o` denotes a single
value: the function `f(o) = v`, where `v` is one specific value.
The feature is featured **by the occurrence directly**.
Conceptually, this is a simple mapping from the occurrence to a
value. The value applies for the whole 4D extent of the
occurrence.

A **variable feature** denotes a **time-function**:
`f(o, t) = v`, where `t` represents points in time. The pair
`(o, t)` is captured by the snapshots of `o`, so we can also write
`f(s) = v`, where `s` ranges over the snapshots of `o`. Different
snapshots may yield different values. Formally, the variable
feature is **not featured by `o` directly. It is featured by the
snapshots of `o`**. Each value of the feature is associated with a
specific snapshot, not with the occurrence as a whole.

### Where variable features can appear

A variable feature can only be declared in occurrences (and their
specialisations). This is part of the reason why package-level
usages are always non-variable: the default featuring type
`Anything` is not an occurrence. Usages nested in attribute
definitions or usages cannot be variable for the same reason.

SysML 2.0 currently does not have an explicit way to specify which
usages should be variable. **Structural usages declared inside an
occurrence are variable by default** (except for portions and the
special connectors: binding and succession), but behaviour usages
are not. Behaviour usages represent the 4D performances of
behaviours that happen during the lifetime of the occurrence.
(KerML has a `var` keyword for explicit specification.)

### The `constant` keyword

The `constant` keyword is valid only on variable features, because
it constrains a time-function to be constant (the variable **may**
vary, but it does not). Non-variables are just values related to an
instance and they are not constant because they have no notion of
time. A variable feature can be constant only across a particular
**timeslice** of a drone, for example, while still varying across
the drone's full extent. This is achieved by redefining the feature
inside the timeslice with the `constant` modifier.

## See also

- [[sysml2-occurrences-4d]] for the 4D worldview.
- [[sysml2-portions-and-individuals]] for the portion vocabulary
  used by `snapshot`, `timeslice`, and the variable-feature
  semantics.
- [[sysml2-self-and-that]] for `self` and `that`.
- [[sysml2-actions]] for actions as occurrences whose context is
  given by `this`.
