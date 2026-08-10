---
title: "SysML 2.0 Abstract Actions"
slug: sysml2-abstract-actions
type: reference
layer: sysml2
summary: Deferring an action's realisation, count, or timing with abstract usages and the four ways they become concrete
tags: [actions, abstract, behaviour, multiplicity, succession]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-06 release. MBSE4U. Section 26.8, pages 193 to 195."
    raw: sysmlv2.pdf
related:
  - sysml2-actions
  - sysml2-successions
  - sysml2-specialisation-and-typing
  - sysml2-actions-in-context
  - sysml2-behaviour-patterns
confidence: high
created: 2026-08-10
updated: 2026-08-10
referenced_by: [sysml2-behaviour]
---

# SysML 2.0 Abstract Actions

## Contents

- What a bare nested action usage means
- Three ways to narrow the specification
- How an abstract action becomes concrete
- Worked example
- When to reach for one
- See also

An abstract action is the behavioural way to record that a step
belongs in the model while leaving open how, when, and how often it
happens. This page covers the default the language gives a nested
action usage, the three ways to tighten that default, and the four
constructs that turn an abstract action into something that runs
(Ch 26, pp 193 to 195).

## What a bare nested action usage means

Consider an action definition with a single nested step and nothing
else, no successions, no multiplicity, and no body (Ch 26, p 193,
Figure 26.28).

```sysml
action def Mission {
    action selfTest;
}
```

When a `Mission` is performed, will `selfTest` be performed? The
SysML 2.0 answer surprises authors arriving from UML or SysML v1.
`selfTest` may be performed any number of times, including none, at
any point during the `Mission`. An action usage's values are its
performances, and a nested action usage defaults to multiplicity
`[0..*]`. Composite usage, which is the default for actions, fixes
only **when** a performance may happen, that is, within the owner's
life. It does not require that one happen at all (Ch 26, p 193).

That looseness is not a defect, it is the point. A SysML model is
not a program to run but a specification. It draws the line between
acceptable and unacceptable performances, and early in design that
line is deliberately generous. The declaration above says no more
than "a Mission may perform a selfTest", and it admits many legal
interpretations (Ch 26, p 193).

## Three ways to narrow the specification

As the design firms up, the interpretations are narrowed. The book
gives three routes (Ch 26, pp 193 to 194).

1. **Set a multiplicity.** Writing `action selfTest [1];` pins the
   step to exactly one performance. This is useful when the count is
   genuinely known, but ask whether it is, and whether the action may
   run at any time. This is typically not the preferred way.
2. **Add successions.** A `[1]`-to-`[1]` succession from the `start`
   snapshot performs its target exactly once, because `start` has
   multiplicity `[1]`. The constraint then propagates along the chain
   and through the control nodes. This is how most steps acquire
   their timing and count. See [[sysml2-successions]].
3. **Make it abstract.** When there is no readiness to commit to a
   count or an ordering, the lightest option is to mark the action
   `abstract`. An abstract action cannot be performed on its own,
   only through a concrete specialisation. Until one is supplied, the
   action is a named placeholder that does not run, which is exactly
   what is wanted when a step belongs in the model but its
   realisation is still open.

The third route is the behavioural counterpart of an abstract part
definition or a derived-union usage. The model commits to the concept
of the step and defers the commitment to how it happens
(Ch 26, p 194). See [[sysml2-specialisation-and-typing]] for the
underlying relationships.

## How an abstract action becomes concrete

An abstract action comes to run through any of four constructs.
Underneath they are the same thing, because each supplies a concrete
specialisation (Ch 26, p 194).

1. **Subsetting.** A concrete action subsets the abstract one, and
   its performances count as the abstract action's. This is the
   derived-union pattern, with the abstract `land` subsetted by
   `normalLanding` and `emergencyLanding`.
2. **Redefinition.** A specialisation redefines the abstract action
   with a concrete one, giving it a realisation, and most likely
   successions, in that context.
3. **Perform.** A perform action usage references the abstract action
   through a reference subsetting. The perform usage is concrete, so
   it runs where the perform sits. See [[sysml2-actions]].
4. **Succession.** The subtle one. The target end of a succession
   reference-subsets the action it points to, and a reference
   subsetting usage is a concrete specialisation. An abstract action
   that is the target or source of a succession therefore runs,
   abstract or not, purely by being wired into the flow.

## Worked example

The fourth case is the one that is easiest to miss (Ch 26, p 195,
Figure 26.29).

```sysml
action def AbstractMission {
    abstract action selfTest;
}
action def Mission :> AbstractMission {
    first [1] start then [1] selfTest;
}
```

The action `AbstractMission` has an abstract action `selfTest`, which
is inherited into the action `Mission`. Instead of redefining it,
`Mission` adds a `[1]`-to-`[1]` succession from `start`, which
performs it exactly once. The succession's target end supplies the
concrete specialisation, and the `[1]` on `start` pins the count.

## When to reach for one

An abstract action can be dropped into a base type to record that the
step exists, with no expectation that it runs. The moment it gains an
incoming succession, or is subsetted, redefined, or performed, it
gains a concrete specialisation and joins the behaviour, with nothing
else to change. Reach for an abstract action whenever a step is
needed but its realisation, count, or timing is not yet decided, and
the model should say precisely that rather than over-commit
(Ch 26, p 195).

## See also

- [[sysml2-actions]] for action definitions, usages, and perform
  actions.
- [[sysml2-successions]] for the succession end multiplicities that
  route 2 depends on.
- [[sysml2-specialisation-and-typing]] for subsetting, reference
  subsetting, and redefinition.
- [[sysml2-actions-in-context]] for how an action reaches the part
  it runs in.
- [[sysml2-behaviour-patterns]] for VSE-scale patterns and gotchas.
