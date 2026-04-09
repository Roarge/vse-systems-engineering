# SysML v2 Cases Reference

Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U, 2026-03 release.
Chapter and page citations appear inline. This file paraphrases the source, which
is a copyrighted commercial reference and is not reproduced verbatim. Some case
composition patterns and detailed verdict semantics are marked as pending in the
2026-03 release and will be extended when those sections are published.

---

## 1. Overview of Cases as a Family (Ch 33, p 230)

Cases are one of the most important new concepts in SysML v2. They generalise the
use cases of SysML v1 and capture the abstract notion of considering a system or
a component, called the subject of the case, in a specific situation for a
specific purpose (Ch 33, p 230).

Cases are behaviour models, but they do not represent system behaviours. Instead,
they model what happens to the subject in different situations, such as during
a use case or a verification task. Cases may invoke behaviours of their subject
as substeps (Ch 33, p 230).

Cases are a special kind of calculation, and therefore a special kind of action
(see Ch 27 and `sysml2-behaviour-ref.md`). As such, they always have a result
representing the outcome of performing the case, if any, and they also carry
dedicated input parameters (Ch 33, p 230).

SysML v2 defines three standard case kinds (Ch 33, p 233):

- Use cases
- Analysis cases
- Verification cases

A plain case may be useful in itself, but authors should prefer one of the three
standard kinds. The book's examples apply to all three kinds equally
(Ch 33, p 233).

---

## 2. Shared Case Features (Ch 33, pp 230-233)

### 2.1 Subject

The subject of a case is the system or component considered in the modelled case.
It is declared with the `subject` keyword and is always the first `in` parameter
of the case (Ch 33, p 230).

### 2.2 Actors

A case may involve actors, which are parts interacting with the subject. Actors
are declared with the `actor` keyword and are automatically input parameters of
the case (Ch 33, p 230).

Actors represent roles. Different actors may refer to the same entity but in
different roles (Ch 33, p 230). Because cases are calculations, they can be
evaluated with different arguments, and a case usage provides the values for the
subject and any actors declared in the case definition (Ch 33, p 230).

### 2.3 Objective

A case may also have an objective, which captures why the case is being
considered. Typical examples include testing the subject's behaviour or
verifying a requirement. Objectives are requirements but are declared with the
`objective` keyword (Ch 33, p 233).

The `requirement` element in SysML v2 is not necessarily a system requirement.
It is a neutral statement about a property of a subject. Requirement usages may
apply those statements in several ways. Declared through a satisfy relationship
(see Ch 32.4), the statement becomes an actual system requirement. Declared as
an objective, it becomes a goal to achieve, without the assertion that it can
or will be achieved (Ch 33, p 233).

### 2.4 Case Body

The body of a case contains the steps or interactions that describe what happens
during the case. These steps may model how actors interact with the subject, how
the subject is exercised to verify a requirement, how a property of it is
measured, and so on (Ch 33, p 230).

Steps inside a case body can be ordered with successions in the usual way (see
`sysml2-behaviour-ref.md` Section 4).

---

## 3. Use Cases (Ch 33, pp 233-238)

Use cases describe the behaviour of a system from an outside perspective. The
use case concept is older than SysML, but became more formally defined in SysML
v2 (Ch 33, p 233).

A use case definition models interactions between one or more actors and the
system or component. The case definition may carry a specific arrangement around
the system, such as a test configuration or a sample environment, to illustrate
the use case (Ch 33, p 230).

```sysml
use case def 'Provide Transportation' {
    subject vehicle : Vehicle;
    actor driver : Person;
    actor passengers : Person[0..4];

    objective {
        doc /* Transport passengers safely from origin to destination. */
    }
}
```

Case definitions fit nicely with part definitions, as illustrated in Figure 33.1.
A part definition can model a specific arrangement of the subject and its
environment that frames a use case (Ch 33, p 230).

---

## 4. Analysis Cases (Ch 33, p 238)

Analysis cases capture parametric analysis. They enable computation over system
properties to evaluate outcomes such as energy consumption, cost, or performance
metrics under defined conditions (Ch 33, p 238).

An analysis case invokes behaviour of its subject and binds results through
parametric relationships to analyse system performance or properties. The
analysis case body uses calculations and constraint bindings to compute the
result that the case returns (Ch 33, p 238).

---

## 5. Verification Cases (Ch 33, p 242)

Verification cases model the verification of requirements. They specify how a
requirement is to be verified (Ch 33, p 242).

A verification case includes a verification definition that specifies the
verification task. The verification definition binds the subject to the element
being verified. A verification case may include a `verify` clause that
explicitly declares which requirement is being verified. The subject of the
verification case is bound to the subject of the requirement being verified
(Ch 33, p 242).

```sysml
verification def VehicleMassTest {
    subject testVehicle : Vehicle;

    objective {
        verify vehicleMaxMass;
    }
}
```

### 5.1 Verdict Semantics

Verification cases return a verdict, typically drawn from the standard enumeration
with values such as `pass`, `fail`, `inconclusive`, and `error`. The 2026-03
release of the book does not provide a dedicated section on verdict semantics.
The verdict kind definitions live in the standard domain library and are
referenced from the chapter without full elaboration.

When the book's treatment of verdict semantics is published, this section will
be expanded. Until then, authors should consult the OMG Systems Modeling
Language v2.0 specification (March 2023, formal/2025-01-01) for the
`VerdictKind` enumeration and its intended use in verification workflows.

---

## 6. Include Relationships (Ch 33, p 230)

Cases can reuse other cases through `include` relationships. When a case
includes another case, the behaviour of the included case is composed into the
including case (Ch 33, p 230).

The chapter introduces include relationships but defers detailed coverage of
`extend` relationships and more complex case composition patterns to a later
release.

---

## 7. Case Composition with Actions (Ch 33, p 230)

The body of a case can contain steps or interactions describing what happens
during the case. These steps may model how actors interact with the subject,
how the subject is tested, how a property is measured, and similar tasks
(Ch 33, p 230).

Steps within a case can be organised into sequences using successions, modelling
the order and flow of interactions or calculations in the same way as any other
action body (Ch 33, p 230, cross-referenced from Ch 26).

---

## 8. Practical Patterns for VSE Authors

### 8.1 Use Case with Actors and Subject

Define a use case with a subject declared first and actors for the interacting
roles. A case usage then binds these parameters to specific parts in a context
(Ch 33, p 232).

### 8.2 Case Definition as Complete Context

When the case is self-contained, use the case definition alone with precisely
typed subject and actors, avoiding a separate part definition context. This is
the most compact pattern (Ch 33, p 232).

### 8.3 Case Definition with External Part Context

Alternatively, declare a part definition that frames the subject and actors, and
let the case definition reference that context. Use this when the same context
hosts multiple cases (Ch 33, p 232).

### 8.4 Inherited Case Specialisation

Specialise a case definition from a more abstract one, overriding or refining
actor bindings and parameters. This supports reuse of a generic use case across
product variants (Ch 33, p 233).

### 8.5 Case with Objective

Embed an objective in the case definition to capture the purpose. Objectives
are goals, not satisfied requirements, so they do not claim achievement by mere
declaration (Ch 33, p 233).

### 8.6 Behaviour Invocation Inside a Case

Invoke behaviours of the subject as substeps in the case body. The case body
orchestrates these invocations alongside actor interactions to tell the full
story of the case (Ch 33, p 230).

### 8.7 Analysis Case with Result Binding

Bind results of internal calculations to case parameters using constraints.
This enables evaluation of system properties under different scenarios as a
reusable analysis (Ch 33, p 238).

### 8.8 Verification Case Chained to a Requirement

Use a verification case with an explicit `verify` clause to declare which
requirement the case verifies. The subject of the case must be bound to the
subject of the requirement (Ch 33, p 242).

---

## 9. Gotchas and Red Flags

1. **Cases are not system behaviours.** Cases model what happens *to* the
   subject, not the internal behaviour of the subject. This trips up modellers
   transitioning from traditional use case diagrams (Ch 33, p 230).
2. **Actors are roles, not entities.** Different actors may refer to the same
   physical entity in different roles. Confusing the role with the entity leads
   to models that bind actors incorrectly at the usage level (Ch 33, p 230).
3. **Requirements versus objectives.** A requirement becomes an actual system
   requirement only through a satisfy relationship. Declared as an objective, it
   is a goal without an assertion of achievement. Mixing the two leads to
   misleading trace links (Ch 33, p 233).
4. **Subject must be the first `in` parameter.** The subject of a case must
   always be the first `in` parameter. Placing actors or other parameters before
   the subject violates case semantics (Ch 33, p 230).
5. **Cases return a result.** Cases are calculations and must carry a result
   representing the outcome of performing the case. Treating them as void
   actions misses the point (Ch 33, p 230).
6. **Actor binding must be precise.** When using a case, actors must be bound
   to concrete parts. Ambiguous or missing actor bindings make the case
   impossible to interpret or execute (Ch 33, p 230).
7. **Verify clause needs a matching subject.** A verification case may declare
   `verify` against a requirement only when the case subject matches the
   requirement subject. Mismatched subjects produce an invalid verification
   model (Ch 33, p 242).

---

## 10. Cross References

- `sysml2-behaviour-ref.md` Sections 2-4 for the action and succession
  mechanics that case bodies rely on.
- `sysml2-expressions-ref.md` Sections 8-9 for the calculation and constraint
  authoring rules that cases specialise.
- `sysml2-quick-ref.md` Sections 17-19 for the textual syntax of verification,
  use case, and analysis definitions.
- `sysml2-semantics-ref.md` for the `Calculation`, `RequirementCheck`, and
  `VerificationCheck` base types referenced from the case machinery.

---

## 11. Pending Extensions

This file will grow once the following chapter sections are published in a
future release of the book:

- Detailed verdict semantics, with the `VerdictKind` enumeration and the rules
  for combining verdicts across nested cases.
- Advanced case composition patterns, including the `extend` relationship for
  optional case sequences.
- Integration patterns for cases with other concerns such as interaction
  sequences and detailed state machines.
- Tool and execution guidance for evaluating analysis and verification cases.

Attribution: Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U,
2026. All claims cite chapter and page. Paraphrased for reference use. Do not
reproduce verbatim.
