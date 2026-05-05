---
title: "Story-driven AMBSE Methodology Overview"
slug: methodology-overview
type: concept
layer: methodology
tags: [methodology, ambse, sysmlv2, user-stories, iteration]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §0 (Methodology Overview)."
    raw: methodology/00-methodology-overview.md
related:
  - user-story-canonical-artefact
  - base-architecture-corollaries
  - system-context-completeness
  - stakeholder-stories-workflow
  - system-stories-workflow
  - architectural-analysis-workflow
  - architectural-design-workflow
  - story-branch-pr-workflow
  - iso-29110-compliance-mapping
  - project-management-workflow
  - methodology-library-packaging
  - benefit-as-criterion
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, story-orchestrator, release-orchestrator, project-setup, project-audit]
---

# Story-driven AMBSE Methodology Overview

The plugin's methodology specifies an agile model-based systems engineering process expressed natively in SysML v2. It adapts the process arc of Harmony aMBSE (Douglass, 2016, Chapters 4 to 7) and integrates supporting concepts from the SysML v2 standard library (Weilkiens and Molnár, 2025) and SYSMOD (Weilkiens, 2020). This page is the entry point for the methodology layer of the wiki and orients readers to the foundational artefacts, the workflow stages, the connective mechanism between stakeholder intent and architectural choice, and the iteration discipline that governs how the stages compose over time.

## Three Substantive Changes from Harmony aMBSE

The methodology departs from Douglass in three places, each chosen so that stakeholder intent stays connected to architectural decisions through the SysML v2 model itself rather than through a parallel matrix.

1. **User stories are the primary requirement artefact at every stage.** Where the source treats stakeholder use cases as primary and stories as informal companions, this methodology inverts the relationship. The user story is canonical. A use case is one mode of behavioural elaboration of a story's capability. See [[user-story-canonical-artefact]].
2. **The notation is SysML v2 throughout.** Stories, use cases, item flows, action definitions, analysis cases, verification cases, and subsystem decompositions are all expressed in SysML v2 textual notation. SysML v1 stereotypes and profile mechanisms are not used. Native constructs are preferred: `concern def` for stakeholder needs, `variation` and `variant` for trade-study candidates, and `metadata def` with semantic metadata for methodology library packaging.
3. **Project context is modelled explicitly.** Two foundational artefacts adopted from SYSMOD precede stakeholder work: the Base Architecture captures architectural and technical decisions preset before the project starts (see [[base-architecture-corollaries]]), and the System Context captures the system's environment and external actors (see [[system-context-completeness]]).

The agile cadence of the source is retained. Each workflow stage is performed iteratively over a small set of stories at a time, not exhaustively before the next stage begins.

## Methodology Structure

The methodology distinguishes **foundational sections**, which define artefact types and modelling concepts, from **workflow stages**, which prescribe activities. Foundational sections are referenced from multiple stages. Workflow stages are executed iteratively.

**Foundational sections (§1 to §3):**

- §1 User Stories. The canonical stakeholder-intent artefact, propagated through every workflow stage.
- §2 Base Architecture. Pre-existing architectural and technical decisions that constrain the project from the start (adopted from SYSMOD §5.7).
- §3 System Context. The system's environment: external actors, interfaces, item flows (adopted from SYSMOD §5.11).

**Workflow stages (§4 to §7):**

- §4 Stakeholder Requirements Engineering. Captures stakeholder intent. Inputs are stakeholder identification, concerns, the Base Architecture, and the System Context. Output is a Stakeholder User Story set. See [[stakeholder-stories-workflow]].
- §5 System Requirements Definition and Analysis. Translates stakeholder intent into system-level specification with verifiable behaviour. Input is the Stakeholder User Story set. Output is a System User Story set with behavioural elaborations. See [[system-stories-workflow]].
- §6 Architectural Analysis and Trade Studies. Selects an architecture against story-derived criteria. Inputs are the System User Story set and candidate solution variants. Output is the selected architecture expressed as a resolved variant set. See [[architectural-analysis-workflow]].
- §7 Architectural Design. Decomposes into subsystems and propagates stories downward. Input is the selected architecture. Output is Subsystem User Story sets and allocations. See [[architectural-design-workflow]].

User stories propagate through all four workflow stages. Each transition produces a new story set whose elements `derive` from stories at the level above, so the trace from any subsystem-level capability back to a stakeholder concern is a chain of `derive` and `frame concern` relationships through the model rather than a manual matrix.

## The Connective Mechanism: Benefit as Trade-Study Criterion

The most important structural property of this methodology is that the `benefit` slot of a user story is the same model element that supplies assessment criteria during architectural trade studies in §6. When a story's benefit is expressed as a `require constraint` over value properties of the system, that constraint is invoked directly as a criterion in the trade-study analysis case. No separate criterion-authoring step is required, and architectural decisions cannot drift from stakeholder intent because the criteria are the stakeholder intent. See [[benefit-as-criterion]] for the construction pattern.

Stories whose benefits remain as informal text (the minimal §1 form) do not contribute to trade studies. They may still pass through the methodology, but architectural decisions cannot be defended against them. This creates a natural pressure to formalise benefit constraints before entering §6.

## Iteration Discipline

Every workflow stage operates over a *subset* of the artefacts at its input level, typically the stories selected for the current activity. The methodology is not waterfall-by-stage. The four workflow stages compose in iteration cycles where, for example, a stakeholder story may be created in §4 in iteration *n*, derived to system stories in §5 in iteration *n*, allocated to subsystems in §7 in iteration *n+1*, and revisited in §4 in iteration *n+2* if validation surfaces a missed concern.

Two points are load-bearing:

- The methodology **rejects the fixed-length iteration container**. Douglass nanocycle, microcycle, and macrocycle scheduling units are not adopted. Calendar cadence and team ceremonies are project-determined and out of scope here.
- The methodology **embraces iteration as recursive practice**. Revisiting earlier stages as feedback arrives is allowed and encouraged. The story register is the authoritative cross-iteration index. The `StoryMeta.status` attribute records each story's position in the workflow, and the mapping between status values and the repository's branch and pull-request state is specified in §8 (see [[story-branch-pr-workflow]]).

Foundational artefacts (Base Architecture, System Context) are treated as *evolving but stable*. They are updated when a discovery warrants it, but the update is a deliberate event rather than a routine per-iteration activity.

## Related Methodology Material

The methodology specification continues with project structure and Git workflow (see [[story-branch-pr-workflow]]), the ISO/IEC TR 29110-5-6-2 compliance mapping (see [[iso-29110-compliance-mapping]]), project management practice (see [[project-management-workflow]]), and the forthcoming SysML v2 library packaging that will let downstream projects adopt the methodology by `import` rather than by re-declaration (see [[methodology-library-packaging]]).
