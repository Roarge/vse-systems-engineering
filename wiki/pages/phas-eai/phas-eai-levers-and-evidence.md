---
title: "PHAS-EAI Lever Tables and Cross-Case Hypothesis Evidence"
slug: phas-eai-levers-and-evidence
type: reference
layer: phas-eai
tags: [phas-eai, levers, hypotheses, h7, h9, h13, h14, evidence]
sources:
  - citation: "Georgsen, R. E. (2026). Resilient Smart City Design (Doctoral thesis). Tables 17 to 20 and Section 7.5."
    raw: kappe.pdf
related:
  - phas-eai-overview
  - phas-eai-equations
  - phas-eai-de-requirements
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [attention-regime]
---

# PHAS-EAI Lever Tables and Cross-Case Hypothesis Evidence

This page collects the four lever tables (Tables 17 to 20 in the
thesis), the four hypotheses with strongest cross-case support,
and a quick-reference summary linking constructs to plugin
levers and DE requirements. For background see
[[phas-eai-overview]] and [[phas-eai-equations]]. For the
requirements these levers serve, see
[[phas-eai-de-requirements]].

## Table 17: Configuration-space levers

| Lever | If moved up | If moved down |
|---|---|---|
| Hard constraints `K` | Fewer feasible options, lower `C` | More options, higher `C` |
| Dimension count | Larger space, harder to search | Smaller space, easier to manage |
| Binning granularity | Coarser bins, fewer distinct options | Finer bins, more distinct options |
| Coupling between dims | More constraints propagate | Dimensions more independent |

## Table 18: Mobilisation-time levers

| Lever | If moved up | If moved down |
|---|---|---|
| Designed reserve `h` | Higher floor on headroom | Floor drops, skill-dependent |
| Skill factor `u` | Faster response, lower `sigma_tau` | Slower response |
| Tool quality `q(IT)` | Better headroom utilisation | Tools become bottleneck |
| Structural drag (`CP`) | Longer stage times | Shorter stage times |

## Table 19: Information and inference levers

| Lever | If moved up | If moved down |
|---|---|---|
| Observation precision | More accurate state estimates | Noisier signals, worse decisions |
| Generative model fit | Better predictions, less surprise | More prediction errors |
| Functional info `I*` | Costlier choices, more expertise | Easier choices, lower barrier |
| Success set ratio | More paths to goal, more forgiving | Fewer paths, less margin |

## Table 20: Coordination and governance levers

| Lever | If moved up | If moved down |
|---|---|---|
| Shared priors | Lower coordination cost | More misalignment, rework |
| Regime of Attention | Sustained dependability focus | Attention drifts to urgent tasks |
| Practice ritualisation | Stronger habits, less cognitive load | Ad hoc behaviour, inconsistency |
| Niche construction | Environment reinforces good practice | Environment undermines practice |

## Hypotheses with strongest cross-case support

The thesis tests 14 hypotheses (H1 to H14) across four cases (A
to D). Four hypotheses achieved convergent support across three
or more cases.

### H7: Designed reserve outperforms experience investment

Prediction: Increasing designed reserve `h` yields larger
resilience gains than equivalent investment in raising
individual skill `u(E, MF)`.

Evidence: Direct support from Cases A (episode A1), B (B1), C
(C1), D (D4). Teams with higher `h` sustained performance
through personnel changes, while teams relying on individual
expertise suffered when key staff departed.

### H9: Regimes of attention reduce drift

Prediction: Teams operating within a Regime of Attention show
lower rates of process drift than those without.

Evidence: Direct support from Cases B (B1), C (C2), D (D2). The
mechanism operates through precision weighting: the regime keeps
dependability signals salient even when competing priorities
demand attention.

### H13: Patterned practices reduce functional information

Prediction: Established Patterned Practices reduce `I*_g` by
narrowing the configuration space to proven routines, lowering
the cognitive cost of choosing correctly.

Evidence: Direct support from Cases A (A1), B (B3), C (C4), D
(D3). Teams with ritualised practices made faster, more
consistent decisions. New team members reached baseline
competence sooner when practices were explicit.

### H14: Machine-readable traceability reduces noise

Prediction: Machine-readable models improve observation
precision `omega`, reducing detection time and decision rework.

Evidence: Direct support from Cases A (A3, A4), B (B2), C (C3),
D (D4). The effect was strongest when traceability was
integrated into daily tools rather than maintained as a separate
artefact.

## Quick-reference summary

| Construct | Model symbol | Plugin lever | DE Req |
|---|---|---|---|
| Configuration space | `X`, `C`, `CP_i` | Context filtering | R1 |
| Designed cognitive reserve | `h`, `H_cog` | LLM as embedded SE | R2 |
| Observation precision | `omega` | SysML 2.0 models | R3 |
| Regime of Attention | precision wt. | Hooks and guards | R4 |
| Patterned Practices | `I*_g` reduction | Phase-specific skills | R1 |
| Niche Construction | feedback loops | Workspace conventions | R4 |
| Response time | `tau`, `sigma_tau` | Automation, templates | R2 |
| Functional information | `I*_g`, `I^op_g` | Option pre-filtering | R1 |

## See also

- [[phas-eai-overview]] for construct definitions.
- [[phas-eai-equations]] for the formal equations behind the
  symbols listed above.
- [[phas-eai-de-requirements]] for R1 to R4 with plugin
  mappings.
