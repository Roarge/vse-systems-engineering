---
title: "The free-energy model beneath PHAS-EAI"
slug: phas-eai-active-inference-model
type: concept
layer: phas-eai
summary: The free-energy formal model beneath PHAS-EAI, defining surprise, affordance, peer models, and worldview principles
tags: [phas-eai, free-energy-principle, active-inference, worldview, affordance, markov-blanket]
sources:
  - citation: "Georgsen, R. E. (2026). Navigating Uncertainty: Guiding Attention in Purposeful Human Activity Systems. Systems Engineering. https://doi.org/10.1002/sys.70041"
    raw: "Paper V - Systems Engineering - 2026 - Georgsen - Navigating Uncertainty  Guiding Attention in Purposeful Human Activity Systems.pdf"
related:
  - phas-eai-overview
  - phas-eai-equations
  - phas-eai-de-requirements
  - phas-eai-designing-attention-regimes
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [attention-regime]
---

# The free-energy model beneath PHAS-EAI

## Contents

- The boundary and perceptual uncertainty
- Free energy, surprise, and alignment
- Action selection and epistemic foraging
- Niche construction formalised
- Peers, shared norms, and authority
- The multi-scale property
- The Worldview component
- What this page adds to the existing PHAS-EAI pages
- See also

Purposeful human activity systems (PHAS) are engineering teams, and comparable
socio-technical arrangements, treated as systems in their own right.
Calvo-Amodio and Rousseau built the model on four elements, System, Purpose,
Boundary, and Relationships. The source extends it with the free-energy
principle (FEP), a formalism from computational biology in which a system
holds its organised state by reducing the gap between what it predicts and
what it senses. Every engineered system has a purpose, and what marks a PHAS
is awareness of that purpose. This page is the formal layer beneath the
regime, practice, and niche-construction constructs [[phas-eai-overview]]
states in prose. The configuration-space and cognitive-reserve constructs
are formalised on the thesis side, in [[phas-eai-equations]].

## The boundary and perceptual uncertainty

A Markov blanket is the minimal structure that keeps a system's internal
states conditionally independent of its environment, and it is the convention
the source uses for a system boundary. Input states translate external signals
inwards and active states carry influence outwards, but internal and external
states stay hidden from each other, so no system observes the world beyond its
boundary directly.

```text
s = g(eta) + omega
```

Sensory input `s`, what Calvo-Amodio's framework calls signs, reflects not the
states of the world `eta` but some function `g` of them, filtered through
noise `omega`. The source states this as the Principle of Perceptual
Uncertainty: a PHAS perceives its environment mediated through a boundary,
with internal states shaped by noisy, uncertain inputs that obscure direct
observation. Two of the three symbols in the R3 row of
[[phas-eai-de-requirements]] are defined here.

## Free energy, surprise, and alignment

A generative model is a likelihood and a prior, and free energy binds the
surprise of an observation, `-ln p(s)`, to the quality of the agent's
internal model, written `mu`. Entropy is the expected surprise over time.

```text
p(s, eta) = p(s | eta) * p(eta)
F(s, mu) = KLDiv[ q_mu(eta) || p(eta | s) ] - ln p(s)
F(s, mu) = Divergence + Surprise
mu* = arg min Divergence
```

The Kullback-Leibler divergence (KLDiv) measures how far the agent's
approximate posterior sits from the true one, so minimising it aligns the
internal model with reality and lets the agent infer the causes of its
sensations. The source states this as the Principle of Alignment. A divergence
of zero would mean a perfect model, and the noise term above guarantees that
such a state is never reached.

## Action selection and epistemic foraging

Action is chosen by minimising free energy as a function of the internal model
and the input caused by the previous action:

```text
a* = arg min F(s(a), mu)
F(s, mu) = KLDiv[ q_mu(eta) || p(eta) ] - E_q[ ln p(s | eta) ]
a* = arg max Accuracy
```

The first term is complexity and the second accuracy. Action influences free
energy only by changing inputs, never by altering beliefs directly, which is
why no posterior beliefs appear inside this divergence. The source states this
as the Principle of Epistemic Foraging: a PHAS selects actions that maximise
the expected accuracy of future input by reducing its ambiguity, not by
adjusting what it believes.

## Niche construction formalised

Sampling only expected input is the simplest way to satisfy that optimisation.
Modifying the environment is the more powerful one. Constant and colleagues
exploit the symmetry of the Markov blanket to reverse the equation and model
niche construction from the perspective of the niche:

```text
F(a, eta) = KLDiv[ q_eta(mu) || p(mu | a) ] - ln p(a)
F(a, eta) = Divergence + Affordance
eta* = arg min Divergence
```

The environment minimises environmental surprise, learning which actions are
likely given its own states and the agent's, so `-ln p(a)` is a mathematical
model of affordance, a measure of how natural an action is in a given
environment. Coupling through the blanket makes the mapping statistically
regular, so niche and inhabitant become mutually predictable, which the source
states as the Principle of Coupled Adaptation. The affordance-increase
mechanism named in [[phas-eai-overview]] is this term.

## Peers, shared norms, and authority

Simulations cited by the source show that active inference agents reach their
target faster when their internal model includes a shared goal, and faster
still when they maintain a model of their peer, that is, a Theory of Mind.
Peers are as opaque behind the blanket as any other external system, but the
Intentional Stance makes a separate notation useful. Incoming communication
re-purposes the perception equation, outgoing communication re-purposes action
selection, and `psi` stands for the peer's internal states.

```text
c_in = g(psi) + omega
c_out* = arg min F(c_in(c_out), mu)
Phi = f(psi) * gamma + (1 - gamma) * mu
Phi = sum over i in 1..N of [ f(psi_i) * gamma_i + (1 - gamma_i) * mu ]
```

Shared norms, conventions, and expectations are written `Phi`. The agent
builds it by combining its reading of each peer's view `f(psi_i)` with its own
model `mu`, weighting each peer by `gamma_i`, the authority granted to that
peer relative to its own beliefs. This is the third symbol named in the R3 row
of [[phas-eai-de-requirements]].

## The multi-scale property

```text
F_super = sum over i in 1..N of F_i(c_in_i, s_i, mu_i)
```

Free energy is additive and conserved, so the free energy of a supersystem
equals the sum of that of its subsystems. A PHAS can be modelled at several
scales, an individual engineer, a team, or a company, which is what makes it
legitimate to simplify a complex system by modelling it one level up.

## The Worldview component

The source's main contention is that the original PHAS model takes too little
account of humans and teams as social entities driven by beliefs, desires, and
shared cultural norms. It adds a top-level component named Worldview, after
the Worldview Inquiry Framework of Rousseau and Billingham, carrying five
principles. Human activity systems are intentional systems with a worldview.
They perceive their environment through a boundary under noisy input. They
maintain and continuously optimise a generative model of the world, that is,
their worldview, to minimise uncertainty and support progress towards their
purpose. They shape their environment through action so that it better
reflects that model. The intentional stance applies both by them and to them,
and they operate as a multi-scale hierarchy that preserves free energy.

One caution belongs with the formalism, and the source states it using
Dennett's notion of a loan of intelligence, the provisional assumption a model
makes in order to simplify. The generative model is not held inside the
components of a PHAS. It is a mathematical construct describing an observable
phenomenon. That a sentient engineer and the layout of a workshop are
described in the same notation confers no sentience on the workshop and
implies no group consciousness. Intentional systems can also be wrong, acting
rationally in the context of beliefs that may be false, so optimisation here
always means a local optimum.

## What this page adds to the existing PHAS-EAI pages

| Existing page | What this page supplies |
|---|---|
| [[phas-eai-equations]] | The response-time, resilience, and functional-information families sit on top of this model. Neither set restates the other. |
| [[phas-eai-de-requirements]] | Definitions for the three symbols the R3 row names, `omega`, `g(.)`, and `Phi`, plus the affordance term R4 depends on. |

## See also

- [[phas-eai-overview]] for the constructs this model underpins.
- [[phas-eai-equations]] for the thesis-side equation families.
- [[phas-eai-de-requirements]] for the requirements R1 to R4.
- [[phas-eai-designing-attention-regimes]] for the design procedure.
