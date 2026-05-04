---
title: "PHAS-EAI Framework: Core Constructs"
slug: phas-eai-overview
type: concept
layer: phas-eai
tags: [phas-eai, configuration-space, cognitive-reserve, regimes-of-attention, patterned-practices, niche-construction]
sources:
  - citation: "Georgsen, R. E. (2026). Resilient Smart City Design (Doctoral thesis). Sections 4.2.2 to 4.2.5 and 5.5."
    raw: kappe.pdf
related:
  - phas-eai-equations
  - phas-eai-de-requirements
  - phas-eai-levers-and-evidence
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [attention-regime]
---

# PHAS-EAI Framework: Core Constructs

The PHAS-EAI framework grounds the plugin's design rationale in
five core constructs: a configuration space, designed cognitive
reserve, regimes of attention, patterned practices, and niche
construction. Each construct is formalised in the thesis and maps
to one or more design levers in the plugin. Companion pages cover
the formal equations ([[phas-eai-equations]]), the four DE
integration requirements ([[phas-eai-de-requirements]]), and the
lever tables plus cross-case evidence
([[phas-eai-levers-and-evidence]]).

## Configuration space

The system state is modelled as a product of seven configuration
dimensions:

```text
X = X_tech * X_org * X_policy * X_practice * X_language * X_worldview * X_boundary
```

Each dimension contains a finite set of possible settings. Hard
constraints `K` remove infeasible combinations, yielding the
feasible set `O^Delta`. A binning map `phi` groups similar
configurations to produce distinct options. Complexity is then:

```text
C = |O^Delta|       (count of feasible distinct options)
```

Complexity potential for a single dimension `i`:

```text
CP_i = |X_i| / |X_i^min|
```

Higher `CP_i` means the dimension contributes more to total
optionality. The configuration space is the load-bearing object
that all PHAS-EAI levers manipulate.

## Designed cognitive reserve

Designed cognitive reserve (`h`) is the fraction of cognitive
headroom guaranteed by design, independent of individual skill.
It is achieved through automation, checklists, pre-authorised
actions, and scaffolded workflows.

Cognitive headroom:

```text
H_cog = h + (1 - h) * u(E, MF) * q(IT)
```

where `u(E, MF)` is a skill factor (experience `E`, mental
fitness `MF`, both in `[0,1]`) and `q(IT)` is the
inference-tool quality factor.

**Floor property**: `H_cog >= h` regardless of skill. When
`u = 0` (novice, fatigued), headroom equals `h`. This is what
makes reserve **designed** rather than accidental.

Plugin implication (R2): LLM-assisted workflows raise `h` by
embedding SE competence in the toolchain, so that even
inexperienced VSE staff maintain a minimum performance floor.

## Regimes of attention

An institutional arrangement that increases the precision of
dependability signals and the affordance of dependability
actions. Four formal mechanisms:

1. **Noise reduction**. Filters irrelevant signals so that
   dependability-relevant information stands out.
2. **Observation mapping**. Improves the mapping from hidden
   system states to observable indicators (increases `omega`
   precision).
3. **Affordance increase**. Raises the perceived and actual
   feasibility of dependability actions, lowering the activation
   threshold.
4. **Expectation stabilisation**. Creates shared priors across
   team members, reducing coordination cost.

Regimes of Attention are not one-off interventions. They are
sustained environmental structures (review gates, dashboards,
automated checks) that keep dependability visible under workload
pressure.

Plugin implication (R4): Hooks and guards in the plugin sustain
attention by triggering at lifecycle boundaries, preventing
silent drift away from process compliance.

## Patterned practices

Regular, ritualised interactions through which agents engage with
Regimes of Attention and internalise knowledge. Examples from the
case studies:

- End-of-Phase (EoP) game sessions (Case B)
- LLM-assisted review pipelines (Case D)
- Patch-triage huddles (Case C)
- Structured lessons-learned workshops (Case A)

Patterned Practices reduce functional information by narrowing
the success set to well-understood routines. They function as
implementation guides that translate abstract process
requirements into operational habits.

Plugin implication (R1): Skills in the plugin encode Patterned
Practices as reusable, phase-specific workflows.

## Niche construction

Teams actively reshape their environment to support their own
inference. This creates feedback loops where the modified
environment reinforces desired behaviour, which in turn motivates
further environmental modification.

In the PHAS-EAI model, niche construction explains why some
teams sustain good practices while others drift: the environment
either reinforces or undermines the inference system that drives
behaviour.

## See also

- [[phas-eai-equations]] for the formal equations governing
  response time, resilience, and functional information.
- [[phas-eai-de-requirements]] for the four DE integration
  requirements (R1 to R4) and their plugin mappings.
- [[phas-eai-levers-and-evidence]] for the four lever tables
  and the cross-case hypotheses.
