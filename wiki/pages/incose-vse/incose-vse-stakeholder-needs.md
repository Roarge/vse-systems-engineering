---
title: "INCOSE Stakeholder Needs Definition for VSEs"
slug: incose-vse-stakeholder-needs
type: concept
layer: incose-vse
tags: [incose, stakeholder-needs, conops, vse, strs]
sources:
  - citation: "INCOSE (2015). Systems Engineering Handbook, 4th edition. Wiley. Chapter 4.2."
    raw: incose_handbook_4e.pdf
  - citation: "Galinier, M., et al. (2021). Systems Engineering Practices for Small and Medium Enterprises. INCOSE-TP-2021-005-01."
    raw: galinier_sme_practices.pdf
related:
  - needs-vs-requirements
  - requirements-elicitation-and-writing
  - ambse-use-case-driven-elicitation
  - ambse-requirements-as-models
  - sysml2-cases-overview
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator]
---

# INCOSE Stakeholder Needs Definition for VSEs

## Purpose

Transform stakeholder concerns into a structured set of
stakeholder requirements that can be validated. The output is the
Stakeholder Requirements Specification (StRS).

## Activities

1. Identify stakeholders and their concerns across the full
   lifecycle (acquirer, users, maintainers, regulators, disposal
   authorities).
2. Elicit needs through interviews, workshops, observation, and
   operational scenario analysis. See requirements-elicitation-and-writing for
   the canonical workshop and interview patterns.
3. Define operational scenarios (CONOPS) describing system
   behaviour in its intended environment. Use exchange sequences
   showing actors, system services, and environmental hypotheses.
   In an AMBSE workflow these scenarios become use case models
   (see ambse-use-case-driven-elicitation and sysml2-cases-overview).
4. Analyse and reconcile conflicting needs. Prioritise using
   MoSCoW or similar scheme.
5. Express needs as stakeholder requirements in the StRS. Each
   requirement must be traceable to its source stakeholder and
   concern. The needs-vs-requirements page describes the
   distinction between a need and a requirement at the level of
   the StRS.

## VSE guidance

In a VSE the acquirer and end users are often the same person.
Do not skip stakeholder analysis. Identify at least: the paying
customer, the end user (if different), the maintainer, and any
regulatory body. Even a two-person project benefits from writing
down operational scenarios before jumping to requirements.

The smallest viable stakeholder package, suitable for a project
of fewer than six person-months, is:

- Stakeholder list (one paragraph per stakeholder)
- Operational scenarios as a small set of use cases
  (`UseCaseDefinition` per ambse-use-case-driven-elicitation)
- StRS expressed as `RequirementDefinition` elements with
  documentation strings, owned by a `StakeholderRequirements`
  package

The CONOPS does not need to be a separate document for a VSE.
Use the `doc /* ... */` block on each top-level use case to
capture the operational context. The `vse-companion-overview`
skill assembles a single document at SR.1 closure that includes
the stakeholder list, the use case set, and the StRS.

## Tracing back to stakeholders

Every system requirement (SyRS) must trace back to at least one
stakeholder requirement. Every stakeholder requirement must
trace back to at least one named stakeholder. The trace is
verified by the `traceability-guard` skill at every iteration
boundary, which raises the unallocated requirement as a defect
on the iteration board.
