---
title: "AMBSE Principles and Modelling Rules"
slug: ambse-principles
type: concept
layer: ambse
tags: [ambse, principles, modelling-rules, vse, douglass]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Elsevier. Chapters 1-2."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Packt. Chapter 1."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-vee-three-timeframes
  - ambse-iteration-planning
  - ambse-risk-and-metrics
  - ambse-iso29110-mapping
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator, verification-validation]
---

# AMBSE Principles and Modelling Rules

The fundamental distinction between systems engineering and
software development drives how agile methods apply:

> The outcome of systems engineering is **specification**.
> The outcome of software development is **implementation**.

SE work products are requirements, architecture, interfaces,
trade studies, and verification plans, not running code. Agile SE
focuses on incrementally producing and verifying these
specification artefacts.

## Five principles for agile model-based SE

1. **Models are essential for agile SE.** Verifiable models are
   required because continuous verification is a core agile
   practice, and natural language specifications cannot be
   verified by testing or formal methods. Only high-precision
   models (expressible in SysML 2.0 textual notation) enable
   test-driven specification.
2. **Incremental development with continuous verification.**
   Develop a narrow slice of specification through all
   activities (requirements, architecture, V&V) before starting
   the next slice. Verify at every step, not at the end.
3. **Avoid big design up front, but do not skip design.**
   Develop and verify the specification work needed right now,
   and defer work that will not be needed until later. This
   reduces rework when requirements change.
4. **Work with stakeholders as active participants.** There is
   an "air gap" between what requirements say and what
   stakeholders actually need. Frequent demonstrations of the
   evolving specification (walkthroughs, model reviews) close
   this gap.
5. **Agile methods change the order, not the activities.**
   Traditional projects do integration and testing at the end.
   Agile methods mix these activities into the development work
   so that defects are avoided rather than discovered late.

## The modelling advantage for VSEs

MBSE provides benefits that are particularly valuable when a
small team must manage all SE activities:

- **Precision**: SysML 2.0 models are less ambiguous than
  natural language statements.
- **Consistency**: traceability links within the model ensure
  data coherence across requirements, architecture, and V&V.
- **Single source of truth**: one model repository eliminates
  the "dual maintenance" problem of keeping multiple documents
  synchronised.
- **Early verification**: models can be verified as they are
  created, catching defects before they propagate downstream.
- **Impact analysis**: when a requirement changes, trace links
  identify all affected architectural elements, interface
  specifications, and test cases.

## Drawing is not modelling

A critical distinction: drawing diagrams in a presentation tool
is not modelling. **True modelling means specifying deep
semantics in a formal language** (SysML 2.0) such that the
content can be verified through testing or formal analysis.
Diagrams are views of the model, not the model itself. The
model lives in the repository (.sysml files managed by SySiDE).

VSE guideline: every model element should have purpose, intent,
scope, language, accuracy, fidelity, and completeness
appropriate to its role. Use a core subset of SysML 2.0 (the
80/20 rule: 80% of work uses 20% of the language) and extend
only when necessary. See the `sysml2-syntax-*` family of atomic
pages (consumed via `wiki/bundles/sysml2-modelling.md`).

## Modelling rules (condensed)

Douglass identifies 20 rules of modelling. The most important
for VSEs:

1. Every model should have clear purpose, intent, scope, and
   language.
2. Follow a modelling standards guideline (naming conventions,
   package structure). See [[sysml2-canonical-model-layout]]
   and [[sysml2-namespace-hygiene]].
3. Use a core subset of SysML 2.0 and extend only when
   necessary (80/20 rule).
4. Each view (diagram) should answer a single question or show
   a single concept.
5. Create as many views as you have questions.
6. Document your models (model elements need descriptions of
   use, purpose, scope).
7. Organise like you want to find things (crucial for long-term
   model management).
8. Drawing is not modelling (diagrams are views, the
   repository is truth).
9. Be precise (each functional requirement should be
   constrained by QoS requirements).
10. Be correct first, then optimise later.
11. Be semantically complete (include preconditions,
    postconditions, invariants, QoS).
12. Verify your models early and often (nanocycle verification
    every hour or less).
13. Incrementally adopt modelling in small, verifiable steps.
14. Configuration manage your models (baseline at stable
    points, use Git).

## See also

- [[ambse-vee-three-timeframes]] for the Vee pattern applied at
  nanocycle, microcycle, and macrocycle scales.
- [[ambse-iteration-planning]] for planning hierarchy, Iteration
  0, Architecture 0, and effort estimation.
- [[ambse-risk-and-metrics]] for risk management and SE
  metrics.
- [[ambse-iso29110-mapping]] for the AMBSE-to-ISO 29110
  activity mapping.
