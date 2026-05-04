---
title: "SysML 2.0 Case Patterns and Gotchas"
slug: sysml2-case-patterns
type: pattern
layer: sysml2
tags: [cases, patterns, gotchas, vse]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 33, pages 230 to 242."
    raw: sysmlv2.pdf
related:
  - sysml2-cases-overview
  - sysml2-case-kinds
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-cases]
---

# SysML 2.0 Case Patterns and Gotchas

This page collects practical patterns and recurring mistakes for
SysML 2.0 cases. For the conceptual frame, see
[[sysml2-cases-overview]]. For declaration syntax, see
[[sysml2-case-kinds]].

## VSE authoring patterns

### Use case with actors and subject

Define a use case with the subject declared first and actors for the
interacting roles. A case usage then binds these parameters to
specific parts in a context (Ch 33, p 232). This is the simplest and
most common form.

### Case definition as complete context

When the case is self-contained, use the case definition alone with
precisely typed subject and actors, avoiding a separate part
definition context. This is the most compact pattern (Ch 33, p 232).

### Case definition with external part context

Alternatively, declare a part definition that frames the subject and
actors, and let the case definition reference that context. Use this
when the same context hosts multiple cases (Ch 33, p 232).

### Inherited case specialisation

Specialise a case definition from a more abstract one, overriding or
refining actor bindings and parameters. This supports reuse of a
generic use case across product variants (Ch 33, p 233).

### Case with objective

Embed an objective in the case definition to capture the purpose.
Objectives are goals, not satisfied requirements, so they do not
claim achievement by mere declaration (Ch 33, p 233).

### Behaviour invocation inside a case

Invoke behaviours of the subject as substeps in the case body. The
case body orchestrates these invocations alongside actor
interactions to tell the full story of the case (Ch 33, p 230).

### Analysis case with result binding

Bind results of internal calculations to case parameters using
constraints. This enables evaluation of system properties under
different scenarios as a reusable analysis (Ch 33, p 238).

### Verification case chained to a requirement

Use a verification case with an explicit `verify` clause to declare
which requirement the case verifies. The subject of the case must be
bound to the subject of the requirement (Ch 33, p 242). This pattern
is the basis for VCRMs in V&V workflows.

### Case composition with successions

The body of a case can contain steps or interactions describing what
happens during the case. Steps within a case can be organised into
sequences using successions, modelling the order and flow of
interactions or calculations in the same way as any other action body
(Ch 33, p 230, cross-referenced from Chapter 26).

## Gotchas and red flags

### Cases are not system behaviours

Cases model what happens **to** the subject, not the internal
behaviour of the subject. This trips up modellers transitioning from
traditional use case diagrams (Ch 33, p 230). The system's own
behaviour models live in state machines, action definitions, and
other behaviour types, not in cases.

### Actors are roles, not entities

Different actors may refer to the same physical entity in different
roles. Confusing the role with the entity leads to models that bind
actors incorrectly at the usage level (Ch 33, p 230).

### Requirements versus objectives

A requirement becomes an actual system requirement only through a
satisfy relationship. Declared as an objective, it is a goal without
an assertion of achievement. Mixing the two leads to misleading
trace links (Ch 33, p 233).

### Subject must be the first `in` parameter

The subject of a case must always be the first `in` parameter.
Placing actors or other parameters before the subject violates case
semantics (Ch 33, p 230).

### Cases return a result

Cases are calculations and must carry a result representing the
outcome of performing the case. Treating them as void actions misses
the point (Ch 33, p 230). For analysis cases, the result is the
computed value. For verification cases, the result is the verdict.

### Actor binding must be precise

When using a case, actors must be bound to concrete parts. Ambiguous
or missing actor bindings make the case impossible to interpret or
execute (Ch 33, p 230).

### Verify clause needs a matching subject

A verification case may declare `verify` against a requirement only
when the case subject matches the requirement subject. Mismatched
subjects produce an invalid verification model (Ch 33, p 242).

## Pending material in the source

The 2026-04 release of the SysML v2 book leaves the following topics
pending:

- Detailed verdict semantics, with the `VerdictKind` enumeration and
  the rules for combining verdicts across nested cases.
- Advanced case composition patterns, including the `extend`
  relationship for optional case sequences.
- Integration patterns for cases with other concerns such as
  interaction sequences and detailed state machines.
- Tool and execution guidance for evaluating analysis and
  verification cases.

When these become available, the relevant pages should be updated
and `confidence` revisited.
