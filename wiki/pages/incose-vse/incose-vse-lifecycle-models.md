---
title: "INCOSE Lifecycle Models Scaled for VSEs"
slug: incose-vse-lifecycle-models
type: concept
layer: incose-vse
tags: [incose, lifecycle, vee, vse, decision-gates]
sources:
  - citation: "INCOSE (2015). Systems Engineering Handbook, 4th edition. Wiley."
    raw: incose_handbook_4e.pdf
  - citation: "Galinier, M., et al. (2021). Systems Engineering Practices for Small and Medium Enterprises. INCOSE-TP-2021-005-01."
    raw: galinier_sme_practices.pdf
related:
  - ambse-principles
  - iso29110-pm-process
  - iso29110-sr-process
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [release-orchestrator]
---

# INCOSE Lifecycle Models Scaled for VSEs

## Lifecycle stages (ISO/IEC/IEEE 15288)

Six generic stages apply regardless of organisation size: Concept,
Development, Production, Utilisation, Support, Retirement. A VSE
rarely executes all six in a single project. Typical VSE scope
covers Concept through Development, with Production and Support
handled operationally.

## Lifecycle approaches

| Approach | VSE fit | When to choose |
|----------|---------|----------------|
| Vee pattern (used by AMBSE at all scales) | High | The verification pattern AMBSE applies at every iteration |
| Incremental | Medium | Subsumed by hybrid AMBSE for VSE projects |
| Iterative | Medium | Subsumed by hybrid AMBSE for VSE projects |
| Spiral (ICSM) | Medium | High technical risk, novel technology (TRL below 6) |
| Hybrid AMBSE (Douglass 2021) | High (enforced) | Mixed hardware/software, model-based specification with iterative delivery. The workflow this plugin enforces |

This plugin enforces hybrid AMBSE (Douglass 2016, 2021) as the only
documented workflow. Three overlapping cycles run in pipeline:
system specification (SR.2 to SR.3), downstream engineering (SR.4),
and system verification (SR.5). System engineers specify iteration
N+1 while downstream engineers implement N and testers verify N-1.
For a one-person VSE, the same person cycles through roles at
iteration boundaries. AMBSE explicitly applies the Vee verification
pattern at three timeframes (see ambse-vee-three-timeframes):
nanocycle (30 minutes to 1 day), microcycle (1 to 4 weeks), and
macrocycle (project length).

## Iteration planning as a complement to milestone planning

Iteration planning (see ambse-iteration-planning) complements
traditional milestone-based gates. The project backlog
(prioritised work items) is allocated to iterations, each with a
mission statement. Backlog management, velocity tracking, and
iteration retrospectives provide ongoing feedback that traditional
gate reviews alone cannot.

The Vee verification pattern is the inner structure of every
AMBSE iteration. At the nanocycle scale the left side is the
model element written and the right side is the trace check that
runs immediately. At the microcycle scale the left side is the
iteration's accumulated specification and the right side is the
iteration verification at pull-request time. At the macrocycle
scale the left side is the cumulative specification across all
merged iterations and the right side is formal system V&V before
the release tag. The decision gates below sit at the macrocycle
scale, and the same Vee shape applies at every inner cycle.

## Decision gates

Standard gate sequence: MCR (Mission Concept Review), SRR (System
Requirements Review), PDR (Preliminary Design Review), CDR
(Critical Design Review), TRR (Test Readiness Review). Each gate
has defined entry and exit criteria. A VSE may merge MCR and SRR
into a single milestone when the concept phase is brief.

Gate principle: never proceed to the next stage until the current
stage outputs are verified and baselined. Cost of defect
correction grows up to 100 times from definition to operation
phase (Galinier et al., citing NASA data).

## Cost commitment rule

At the end of the design phase, only 15 percent of the budget has
been spent, yet 85 percent of total lifecycle cost is already
committed by the design decisions made. This makes upstream SE
investment critical for VSEs with tight budgets.
