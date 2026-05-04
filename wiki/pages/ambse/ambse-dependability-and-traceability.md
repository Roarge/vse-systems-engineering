---
title: "AMBSE Dependability Requirements and Traceability Matrix"
slug: ambse-dependability-and-traceability
type: reference
layer: ambse
tags: [dependability, safety, reliability, security, traceability, vse-workflow]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapter 4 (dependability) and Table 1.1 (trace recommendations)."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
related:
  - ambse-requirements-as-models
  - ambse-use-case-driven-elicitation
  - ambse-system-requirements-derivation
  - ambse-nanocycle-and-use-case-analysis
  - sysml2-vse-library-metadata
  - sysml2-model-cm-and-risks
  - hsi-in-requirements
  - requirements-traceability-and-attributes
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [needs-and-requirements]
---

# AMBSE Dependability Requirements and Traceability Matrix

For the AMBSE requirements context see
[[ambse-requirements-as-models]]. For the underlying
traceability types and attributes see
[[requirements-traceability-and-attributes]].

## Dependability requirements

Dependability assessment runs **in parallel** with all
requirements activities. Three aspects must be addressed:

| Aspect | Concern | Requirement type |
|---|---|---|
| Safety | Harm to people, property, or environment | Safety requirements, hazard mitigations |
| Reliability | Probability of failure-free operation | MTBF, failure rate requirements |
| Security | Protection against unauthorised access | Access control, encryption requirements |

For each dependability concern:

1. Identify hazards, failure modes, or threat vectors relevant
   to the current use case.
2. Derive dependability requirements that mitigate each
   concern.
3. Link dependability requirements to the affected functional
   requirements.
4. Plan verification methods appropriate to the dependability
   level.

VSE guidance: do not defer dependability analysis until a
separate phase. Address it during requirements derivation for
each use case, when the functional context is fresh.
High-level design decisions (in architecture) must also be
assessed for their impact on dependability.

For HSI-derived dependability requirements (human error
hazards, safety, occupational health), see
[[hsi-in-requirements]]. For the SysML 2.0 RiskInfo metadata
that records hazard severity and likelihood, see
[[sysml2-vse-library-metadata]] and
[[sysml2-model-cm-and-risks]].

## SE engineering data trace recommendations

The trace matrix defines which pairs of engineering data
should have trace links. Adapted from Douglass (2016)
Table 1.1, filtered for VSE relevance.

| From \ To | StRS | SyRS | Arch | IVV Plan | Safety |
|---|---|---|---|---|---|
| **StRS** | - | R | o | R | R |
| **SyRS** | R | - | R | R | S |
| **Architecture** | o | R | - | R | S |
| **IVV Plan** | R | R | R | - | S |
| **Safety Analysis** | R | S | S | S | - |

Key: **R** = Recommended, **S** = Required for safety-critical
systems, **o** = Optional.

VSE guidance: at minimum, maintain StRS-to-SyRS and
SyRS-to-IVV traces for all projects. Add architecture and
safety traces when the system has dependability concerns. The
`@traceability-guard` hook enforces the minimum trace set.

For the broader traceability catalogue (10 trace types from
INCOSE) see [[requirements-traceability-and-attributes]].

## VSE requirements modelling workflow

Step-by-step procedure combining AMBSE with ISO 29110 SR.2:

1. **Identify stakeholders** using the 16-type checklist (see
   [[ambse-requirements-as-models]]), map to named people.
2. **Identify use cases** from stakeholder interviews and
   document review.
3. **Write use case mission statements** (see
   [[ambse-use-case-driven-elicitation]]) and add to the
   project backlog.
4. **Prioritise use cases** and allocate to iterations.
5. **For each use case in the current iteration**:
   a. Define the system context (actors, connections) in
      SysML 2.0.
   b. Write scenarios (normal, alternate, exception flows).
   c. Extract stakeholder needs (STK-nnn) from scenario steps.
   d. Derive system requirements (REQ-nnn) with `satisfy`
      links (see
      [[ambse-system-requirements-derivation]]).
   e. Model the use case behaviour (flow, scenario, or
      state-based; see
      [[ambse-nanocycle-and-use-case-analysis]]).
   f. Add verification method to each requirement.
   g. Run the nanocycle workflow: validate, trace-check,
      review.
   h. Create verification cases (VER-nnn) with `verify`
      links.
6. **Update the Traceability Matrix** and run
   `@traceability-guard`.
7. **Conduct iteration review** with stakeholders (microcycle
   verification).
8. **Update the project backlog** based on what was learned.

## See also

- [[ambse-requirements-as-models]] for the dual-representation
  principle and stakeholder catalogue.
- [[ambse-use-case-driven-elicitation]] for use case mission
  and prioritisation.
- [[ambse-system-requirements-derivation]] for the per-use-case
  requirement derivation.
- [[ambse-nanocycle-and-use-case-analysis]] for the inner loop.
- [[requirements-traceability-and-attributes]] for the broader
  trace catalogue and TBX management.
- [[sysml2-vse-library-metadata]] and
  [[sysml2-model-cm-and-risks]] for the SysML 2.0 risk
  metadata that records dependability concerns.
- [[hsi-in-requirements]] for the HSI-derived dependability
  requirements (human error, safety, occupational health).
