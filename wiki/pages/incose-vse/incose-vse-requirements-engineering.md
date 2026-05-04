---
title: "INCOSE Requirements Engineering for VSEs"
slug: incose-vse-requirements-engineering
type: concept
layer: incose-vse
tags: [incose, requirements, smart, traceability, volatility, vse]
sources:
  - citation: "INCOSE (2015). Systems Engineering Handbook, 4th edition. Wiley. Chapters 4.2 and 4.3."
    raw: incose_handbook_4e.pdf
  - citation: "Galinier, M., et al. (2021). Systems Engineering Practices for Small and Medium Enterprises. INCOSE-TP-2021-005-01."
    raw: galinier_sme_practices.pdf
related:
  - requirements-elicitation-and-writing
  - ambse-requirements-as-models
  - ambse-system-requirements-derivation
  - ambse-dependability-and-traceability
  - sysml2-syntax-requirements-and-cases
  - sysml2-requirements-semantics
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator]
---

# INCOSE Requirements Engineering for VSEs

## Transformation chain

Stakeholder needs (StRS) are transformed into system requirements
(SyRS), which are then allocated to system element requirements.
Each transformation must maintain bidirectional traceability. The
AMBSE realisation of this chain (see
ambse-system-requirements-derivation) preserves the chain inside
SysML 2.0 model elements rather than in a separate database, so
that the model itself is the traceability store.

## Individual requirement quality (INCOSE)

Every requirement shall be: necessary, implementation-independent,
unambiguous, complete, singular (one thought per requirement),
achievable, verifiable, and conforming to an agreed style. The
MUST mnemonic (Measurable, Useful, Simple, Traceable) provides a
quick check during reviews. The requirements-elicitation-and-writing page
expands these criteria with the SMART pattern and worked
examples.

## Set-of-requirements quality

The complete SyRS shall be: complete (no missing requirements),
consistent (no contradictions), feasible within budget and
schedule, and bounded (clear system boundary separating what is
inside from what is outside).

## Requirement attributes

Each requirement must carry: unique identifier, trace to parent
requirement, trace to source stakeholder, priority (essential,
desirable, optional), verification method (inspection, analysis,
demonstration, test), rationale, and owner. In a VSE, maintain
these attributes in a simple traceability matrix (spreadsheet or
lightweight tool) rather than a full PLM system.

In a SysML 2.0 model these attributes are carried as metadata
applied to the `RequirementDefinition` element (see
ambse-requirements-as-models, sysml2-syntax-requirements-and-cases,
and sysml2-requirements-semantics for how the metadata mechanism
encodes priority, verification method, status, and trace links).
The `vse-library` ships ready-made metadata definitions for these
attributes so a VSE does not have to author them from scratch.

## Requirements volatility

Track the number of new, modified, and cancelled requirements
over time. Rising volatility after the planned specification
freeze signals risk of cost and schedule overrun. Use the
volatility indicator to decide when to hold the specification
review.

The `iteration-orchestrator` skill exposes a `requirements
volatility` metric per iteration boundary. The metric counts
modified `RequirementDefinition` and `RequirementUsage` elements
across the iteration's PRs, classifies each modification as new
versus revised, and flags an iteration that exceeds the volatility
budget agreed with the acquirer at SR.1.

## Bidirectional traceability rule

A requirement without an upward trace to a stakeholder need is
gold-plating. A stakeholder need without a downward trace to a
system requirement is uncovered scope. A requirement without an
allocation to a system element at SR.4 cannot be implemented. A
requirement without a verification method assigned cannot close
the iteration's verification cycle. The
ambse-dependability-and-traceability page describes how the
`traceability-guard` skill enforces all four rules continuously.
