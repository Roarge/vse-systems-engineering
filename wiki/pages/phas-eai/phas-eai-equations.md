---
title: "PHAS-EAI Equations: Response Time, Resilience, Functional Information"
slug: phas-eai-equations
type: reference
layer: phas-eai
tags: [phas-eai, equations, response-time, resilience, functional-information]
sources:
  - citation: "Georgsen, R. E. (2026). Resilient Smart City Design (Doctoral thesis). Section 4.2.4."
    raw: kappe.pdf
related:
  - phas-eai-overview
  - phas-eai-de-requirements
  - phas-eai-levers-and-evidence
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [attention-regime]
---

# PHAS-EAI Equations: Response Time, Resilience, Functional Information

This page collects the three formal equation families that
underpin PHAS-EAI. For the conceptual frame see
[[phas-eai-overview]]. For the requirements that connect these
equations to plugin design, see [[phas-eai-de-requirements]].

## Response time

Response time decomposes into three additive stages:

```text
tau = tau_detect + tau_decide + tau_execute
```

Each stage is scaled by **structural drag** from complexity
potential `CP_i`:

```text
tau_detect  = tau_detect^base  * product(CP_i^alpha_i)
tau_decide  = tau_decide^base  * product(CP_i^beta_i)
tau_execute = tau_execute^base * product(CP_i^gamma_i)
```

The exponents `alpha_i`, `beta_i`, `gamma_i` capture how each
configuration dimension `i` slows each stage.

Skill reduces response time via the **time multiplier**:

```text
sigma_tau = 1 - lambda_tau * u(E, MF)
```

where `lambda_tau` in `[0,1]` is the maximum fractional reduction
achievable through skill.

Read together, these equations say that a team's response time
to disturbance is set by the structural drag of the configuration
they operate in (`CP` factors), reduced by their skill
(`sigma_tau`). The `h` floor in
[[phas-eai-overview]] caps how badly a low-skill operator can do.

## Resilience score

Resilience `R(M, tau_d)` is a piecewise function on `[0, 1]`:

| Outcome | Score |
|---|---|
| System absorbs disturbance within `tau_d` (deadline) | `R = 1` |
| Partial absorption (graceful degradation) | `R = f_A` |
| Adaptive response (reconfiguration) | `R = f_B` |
| Transformative response (fundamental change) | `R = f_C` |
| System fails to respond | `R = 0` |

Response functions `f_A`, `f_B`, `f_C` are ordered
`f_A > f_B > f_C`, reflecting decreasing desirability of deeper
adaptation. A graceful degradation (small adjustment) is
preferable to a reconfiguration, which is preferable to a
fundamental redesign, which is preferable to outright failure.

## Functional information

```text
I*_g(rho) = -log2 p_g(rho)
```

where `p_g(rho)` is the probability that a randomly chosen
configuration achieves goal `g` at performance threshold `rho`.
Higher functional information means **fewer configurations
succeed**, so choice is costlier.

Operational functional information adds time pressure:

```text
I^op_g = I*_g - log2 f_A
```

where `f_A` (also from the resilience score above) captures the
fraction of the success set accessible under time and resource
constraints.

The relationship between configuration space, response time, and
functional information is:

- Larger configuration space `C` means more configurations to
  search through, raising `tau_decide` and pushing `I*_g` up.
- Hard constraints `K` reduce `C` and thus reduce both
  `tau_decide` and `I*_g`. This is the **R1** lever:
  pre-filtering options reduces the cognitive burden.
- Designed reserve `h` does not change `I*_g` but ensures that
  even when burden is high, performance does not collapse below
  the floor `h`.

## See also

- [[phas-eai-overview]] for the constructs (configuration
  space, designed reserve, regimes, patterns, niche).
- [[phas-eai-de-requirements]] for how the four DE integration
  requirements R1 to R4 each lever specific terms in these
  equations.
- [[phas-eai-levers-and-evidence]] for the four lever tables that
  list each manipulable term and its direction of effect.
