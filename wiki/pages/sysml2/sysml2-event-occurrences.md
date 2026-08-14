---
title: "SysML 2.0 Event Occurrences"
slug: sysml2-event-occurrences
type: reference
layer: sysml2
summary: Referring to an occurrence that must happen during the owner's life, the basis of perform, exhibit, and messages
tags: [occurrences, event-occurrence, reference-subsetting, messages, behaviour]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-07 release. MBSE4U. Section 25.9, pages 161 to 162."
    raw: sysmlv2.pdf
related:
  - sysml2-occurrence-context-and-variables
  - sysml2-occurrences-4d
  - sysml2-temporal-spatial-relations
  - sysml2-flows-and-messages
  - sysml2-actions
  - sysml2-state-machines
  - sysml2-case-kinds
confidence: high
created: 2026-08-10
updated: 2026-08-14
referenced_by: [sysml2-behaviour]
---

# SysML 2.0 Event Occurrences

## Contents

- The gap an event occurrence fills
- Declaring an event occurrence
- Why the name is "event"
- What builds on it
- See also

An event occurrence is the smallest construct in the occurrence
family: a reference to another occurrence, plus the single assertion
that the referenced occurrence happens during the referring one's
life (Ch 25, pp 161 to 162).

## The gap an event occurrence fills

A referential occurrence usage points at an occurrence without saying
when it happens. The referenced occurrence may start before the
owner, outlive it, or fall entirely outside its life. Sometimes that
is too loose, because the model needs to refer to an occurrence and
also require it to take place during the owner's life, without owning
it as a composite usage (Ch 25, p 161). See
[[sysml2-occurrence-context-and-variables]] for the composite and
referential distinction this builds on.

An event occurrence usage is declared with the keyword `event`,
placed just before `occurrence`. It adds exactly one constraint to an
ordinary referential usage. When it is owned by an occurrence, it
subsets that owner's `timeEnclosedOccurrences`, which are the
occurrences that happen during the owner. The referenced occurrence
is thereby pinned to happen during the owner, and nothing more. It
remains referential, so it is not owned by the occurrence and,
unlike a suboccurrence, is not forced to end with the owner
(Ch 25, p 161). See [[sysml2-temporal-spatial-relations]] for
`timeEnclosedOccurrences` and the Allen interval relations behind it.

Because an event occurrence is always referential, the `ref` keyword
is optional and redundant (Ch 25, p 161).

## Declaring an event occurrence

The occurrence being referred to is identified by a **reference
subsetting**, which is the keyword `references` or the symbol `::>`.
If no reference is given, the event occurrence stands for itself, as
an occurrence of its own type happening during the owner
(Ch 25, p 161).

```sysml
part def Mission {
    ref part station : GroundStation {
        occurrence contact;
    }
    event occurrence groundContact references station.contact;
    event station.contact;
}
```

The `groundContact` declaration is the **full form**. The part
`GroundStation` has a `contact` occurrence representing a
communication session, and the `Mission` refers to the event
occurrence `groundContact`, asserting that the ground station's
contact occurs during the mission. The reference is a feature chain
reached through the referential part `station`
(Ch 25, p 161, Figure 25.11).

The `event station.contact;` declaration is the **short form**. The
keyword `event` followed directly by the referenced occurrence
declares an unnamed event occurrence that points to it. The two
notations are equivalent. The short form is handy when the event
occurrence needs no name of its own, in which case it inherits the
name of the referred occurrence (Ch 25, pp 161 to 162).

## Why the name is "event"

An occurrence taking place during the lifetime of another reads
naturally as an event in that other's life, which is where the name
comes from. The fit is imperfect, because parts are occurrences too,
so an event occurrence could in principle refer to a part, and
calling a part an event is odd. The portions of an occurrence are
another matter. They are occurrences in their own right, and the
`start` and `done` snapshots are events in the most literal sense,
being the instants a thing comes into being and ceases to be
(Ch 25, p 162). See [[sysml2-occurrences-4d]] for the portion
vocabulary.

In practice an event occurrence nearly always refers to something
that genuinely reads as an event: the boundary of an occurrence, a
placeholder for a behaviour, or the endpoint of a message
(Ch 25, p 162).

## What builds on it

Event occurrences underlie several constructs introduced in later
chapters, and each refines the same idea for its own kind of
behaviour (Ch 25, p 162).

| Construct | Relationship to an event occurrence |
|---|---|
| Perform action | An event occurrence that is also an action, with some extra features. See [[sysml2-actions]]. |
| Exhibit state | Builds on perform action. See [[sysml2-state-machines]]. |
| Include use case | Builds on perform action. See [[sysml2-case-kinds]]. |
| Message ends | The send and receive events of a message are event occurrences. See [[sysml2-flows-and-messages]]. |

## See also

- [[sysml2-occurrence-context-and-variables]] for referential versus
  composite occurrence usages.
- [[sysml2-occurrences-4d]] for the 4D worldview and portions.
- [[sysml2-temporal-spatial-relations]] for the temporal relations
  the one constraint is expressed in.
- [[sysml2-flows-and-messages]] for messages, whose ends are event
  occurrences.
