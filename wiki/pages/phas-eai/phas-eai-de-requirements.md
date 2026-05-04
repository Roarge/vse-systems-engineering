---
title: "PHAS-EAI Digital Engineering Integration Requirements R1-R4"
slug: phas-eai-de-requirements
type: reference
layer: phas-eai
tags: [phas-eai, de-requirements, r1, r2, r3, r4, iso29110, complementarity]
sources:
  - citation: "Georgsen, R. E. (2026). Resilient Smart City Design (Doctoral thesis). Sections 6.5 and 7.4. Table 24."
    raw: kappe.pdf
  - citation: "ISO/IEC TR 29110-5-6-2:2014 (paired with the PHAS-EAI complementarity argument)."
    raw: ISO_IEC_TR_29110-5-6-2_2014.pdf
related:
  - phas-eai-overview
  - phas-eai-equations
  - phas-eai-levers-and-evidence
  - iso29110-overview
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [attention-regime]
---

# PHAS-EAI Digital Engineering Integration Requirements R1-R4

The PHAS-EAI framework distils four integration requirements
that link the formal model (see [[phas-eai-equations]]) to
digital engineering tool design. Together they constitute the
plugin's design rationale. The requirements are paired with a
complementarity argument that connects PHAS-EAI to ISO/IEC
29110 (see [[iso29110-overview]]).

## R1: Reduce functional information burden

| Aspect | Detail |
|---|---|
| Model link | `C` (complexity), `\|A_g,rho\|/C` (success set ratio), `I*_g` |
| Metrics | Option count proxies, success set estimates, quality scores |
| Case support | A, B, C, D |
| Mechanism | Tools narrow the configuration space before the human decides, reducing `I*_g` without removing valid options. |

**Plugin mapping**: Skills pre-filter lifecycle activities by
phase and context, presenting only relevant options to the user.

## R2: Build designed cognitive reserve

| Aspect | Detail |
|---|---|
| Model link | `h` (reserve floor), `lambda_tau` (skill multiplier) |
| Metrics | Personnel-change robustness, tool-dependency ratios, internalisation indicators |
| Case support | A, B, C, D |
| Mechanism | Embed SE competence in the toolchain so that performance floor `h` is maintained even with staff turnover. |

**Plugin mapping**: The LLM acts as embedded SE competence,
providing guidance that does not depend on the individual user
having deep SE experience.

## R3: Provide machine-readable traceability

| Aspect | Detail |
|---|---|
| Model link | `omega` (observation precision), `g(.)` (generative model), `Phi` (inference mapping) |
| Metrics | Detection-to-decision time, integration surprise rate, decision rework rate |
| Case support | A, B, C, D |
| Mechanism | Machine-readable models increase `omega`, making hidden states observable and reducing detection lag. |

**Plugin mapping**: SysML 2.0 textual models provide
traceability that both humans and tools can parse, reducing
`tau_detect`.

## R4: Sustain attention through environmental design

| Aspect | Detail |
|---|---|
| Model link | Regime of Attention, precision weighting |
| Metrics | Drift indicators, engagement persistence, remediation rate |
| Case support | B, C, D |
| Mechanism | Environmental structures (hooks, gates, dashboards) maintain dependability salience under workload pressure. |

**Plugin mapping**: Hooks fire at lifecycle transitions, guards
check model consistency, preventing silent process drift.

## Complementarity with ISO/IEC 29110

ISO/IEC 29110 specifies **what** activities to perform.
PHAS-EAI explains **why** those activities work and what
sustains them. The relationship is complementary on five
mechanisms:

1. **Process mandates are necessary but insufficient.** In
   resource-constrained settings, inference systems
   deprioritise low-affordance activities under workload
   pressure. Without Regimes of Attention, process mandates
   decay.
2. **Regimes of Attention provide the missing mechanism.** They
   make process compliance visible and actionable, bridging the
   gap between what the standard requires and what teams
   actually do.
3. **Machine-readable traceability (H14) supports quality
   evidence.** ISO 29110 certification requires documented
   evidence of process execution. SysML 2.0 models and automated
   checks generate this evidence as a by-product of normal work,
   rather than as separate documentation effort.
4. **Designed cognitive reserve (H7) addresses the staffing
   constraint.** Laporte identified limited SE expertise as the
   central barrier for VSEs. By embedding competence in the
   toolchain, designed reserve compensates for the expertise gap
   without requiring additional hires.
5. **Patterned Practices translate process into action.** They
   function as implementation guides that convert ISO 29110
   activity descriptions into operational routines suited to the
   team context.

See [[iso29110-overview]] for the ISO/IEC 29110 profile that
this complementarity argument frames.

## See also

- [[phas-eai-overview]] for the five core constructs.
- [[phas-eai-equations]] for the formal equations the four
  requirements lever.
- [[phas-eai-levers-and-evidence]] for the lever tables and
  cross-case evidence supporting H7, H9, H13, H14.
- [[iso29110-overview]] for the ISO/IEC 29110 Basic Profile.
