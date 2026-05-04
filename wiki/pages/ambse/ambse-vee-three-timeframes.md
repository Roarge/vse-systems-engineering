---
title: "AMBSE: The Vee Applied at Three Timeframes"
slug: ambse-vee-three-timeframes
type: concept
layer: ambse
tags: [ambse, vee, hybrid, nanocycle, microcycle, macrocycle, continuous-verification]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapter 2."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Chapter 1, Figure 2.6 and discussion (p. 64), and pp. 53-54, 61."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-principles
  - ambse-iteration-planning
  - ambse-iso29110-mapping
  - iteration-centred-operation
  - vv-reporting-and-vse-guidance
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator, verification-validation]
---

# AMBSE: The Vee Applied at Three Timeframes

This plugin enforces hybrid AMBSE (Agile Model-Based Systems
Engineering) as the **single workflow** for VSE projects. AMBSE
is fixed by the plugin and shaped to ISO 29110 for every
project that the plugin scaffolds.

**The Vee is the verification pattern AMBSE applies at every
iteration**, at three different scales. Reading the Vee this way
dissolves the apparent choice between "rigour" and "agility":
AMBSE supplies both, by running the same Vee shape at multiple
cadences.

## The Vee verification pattern

The Vee shape in this section is **geometric, not temporal**.
"Specification flows down, verification flows up" describes the
diagram, not the work order. The Vee repeats at three scales
(nanocycle, microcycle, macrocycle) and at every scale
specification and verification interleave continuously. Reading
the Vee as a left-to-right schedule is the single most common
misreading of AMBSE and produces waterfall behaviour even when
the team intends to be agile.

The Vee model describes a single execution of the systems
engineering cycle. Specification flows down the left side
(stakeholder needs, system requirements, architecture, element
specifications). Verification flows up the right side (element
verification, integration verification, system verification,
validation). Each level on the left has a matching level on the
right.

The Vee is a **pattern**. Douglass frames it directly (Cookbook,
p. 64, discussing Figure 2.6):

> A difference between this process and a traditional V process
> is the path labeled "[more reqs]"; if there are more
> requirements, this loop of activities is done again. In fact,
> a traditional V process is simply this process cycle done
> once.

Reading this in the other direction: AMBSE is the Vee executed
many times, at several scales, with verification at every
iteration boundary. A "traditional Vee project" is AMBSE
collapsed to a single pass. The pattern is shared. The
discipline is shared. The difference is the cadence.

## Pure incremental (historical note)

Pure incremental development takes one slice of functionality
through all activities before the next slice begins. It assumes
iterations are independent and refactoring is cheap. Hardware
with lead times breaks the second assumption, which is why this
plugin enforces hybrid AMBSE for VSE work. Where the term "pure
incremental" appears in older VSE literature, treat it as a
degenerate AMBSE that omits the system V&V cycle.

## Hybrid AMBSE (the enforced workflow)

Hybrid AMBSE runs three interconnected cycles with handoffs
between them:

1. **System specification cycle**: Stakeholder requirements,
   system requirements, functional analysis, architectural
   design (SR.2, SR.3).
2. **Downstream engineering cycle**: Software, electronics, and
   mechanical development (SR.4).
3. **System verification cycle**: Integration, system
   verification, validation (SR.5).

Each of these cycles applies the Vee pattern at its own scale.
The cycles overlap in time: system engineers work on iteration
N+1 while downstream engineers implement iteration N and test
engineers verify iteration N-1. This maintains pipeline
parallelism even for small teams.

**VSE adaptation**: in a one- or two-person team, the same
person cycles through specification, construction, and
verification for each iteration. The hybrid model still applies
because the work products are organised by iteration, allowing
incremental baselining even when parallelism is not possible.

**Mapping to ISO 29110**: hybrid AMBSE maps to ISO 29110 as
multiple sub-passes within SR.2 through SR.5, with each
iteration producing a verified increment. SR.1 (Initiation) and
SR.6 (Delivery) remain single-pass. See
[[ambse-iso29110-mapping]] for the full mapping.

**Mapping to git**: each iteration runs on a feature branch and
ends in a pull request. See [[ambse-git-three-way-mapping]].

## Verification timeframes

Continuous verification operates at three timeframes, each
serving a different quality assurance purpose. This replaces
the traditional approach of verifying only at the end of each
phase. The same three timeframes are detailed in
[[vv-reporting-and-vse-guidance]] from the V&V layer's
perspective.

### Nanocycle (30 minutes to 1 day)

Model-level checks performed as engineering data is created:

- **Syntactic verification**: SySiDE editor validates .sysml
  file syntax in real time.
- **Constraint checking**: verify that parametric constraints
  evaluate correctly.
- **Trace completeness**: the `@traceability-guard` hook
  checks for missing links.
- **Peer review**: brief model walkthrough with a colleague (or
  LLM review).
- **Unit model verification**: verify that a single model
  element (one requirement, one action, one part) is internally
  consistent.

**Vee mapping**: the model element written or edited is the
left-side specification, the SySiDE syntax check and the
trace-completeness check are the right-side verification. Both
happen within the same nanocycle, immediately.

**Git mapping**: one nanocycle is one commit on a `vse/iter-NN`
feature branch. See [[ambse-git-nanocycle-commits]].

### Microcycle (1 to 4 weeks, one iteration)

Iteration-level verification performed at the end of each
iteration:

- **Integration verification**: combine work from multiple
  model files and verify consistency across packages.
- **Iteration acceptance**: verify that the iteration mission
  has been achieved.
- **Stakeholder review**: walkthrough of the iteration
  deliverables with stakeholders.
- **Iteration retrospective**: assess metrics, update velocity,
  adjust the plan.

**Vee mapping**: the iteration's accumulated specification work
is the left side (new requirements, new architecture, new
interfaces). The iteration verification that runs at PR review
time (CI gates plus reviewer walkthrough) is the right side.
The handoff event Douglass describes (Cookbook, p. 61) lives
here.

**Git mapping**: one microcycle is one feature branch merged
via pull request. See [[ambse-git-microcycle-prs]].

### Macrocycle (project length)

System-level verification and validation performed at the end
of the project:

- **System verification**: run all verification cases against
  the complete system.
- **System validation**: demonstrate that the system meets
  stakeholder needs in its intended operational environment.
- **Acceptance testing**: formal acceptance by the acquirer.

**Vee mapping**: the cumulative specification work across all
merged iterations is the left side. Formal system V&V is the
right side, executed before the release tag is created on
`main`.

**Git mapping**: one macrocycle ends in a release tag on
`main`. See [[ambse-git-ci-gates-and-macrocycle]].

## See also

- [[ambse-principles]] for the five core principles.
- [[ambse-iteration-planning]] for planning hierarchy and
  Iteration 0 / Architecture 0.
- [[ambse-iso29110-mapping]] for the AMBSE-to-ISO 29110 table.
- [[iteration-centred-operation]] for the centre-of-gravity
  operating model that runs on top of these timeframes.
- [[vv-reporting-and-vse-guidance]] for the V&V layer's
  perspective on the same three timeframes.
