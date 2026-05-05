---
title: "Base Architecture: Forward-Going Stories and the Reverse-Engineering Guard"
slug: base-architecture-corollaries
type: concept
layer: methodology
tags: [base-architecture, methodology, agent-discipline, story-register, reverse-engineering-guard, forward-going, brownfield-discovery, as-is-survey]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §2 (Base Architecture)."
    raw: methodology/02-base-architecture.md
related:
  - methodology-overview
  - user-story-canonical-artefact
  - system-context-completeness
  - architectural-analysis-workflow
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, story-orchestrator, needs-and-requirements, architecture-design, attention-regime, project-setup]
---

# Base Architecture: Forward-Going Stories and the Reverse-Engineering Guard

The Base Architecture in the VSE methodology is the set of architectural and technical decisions that pre-exist the project and constrain its work from outside it. The methodology captures it as a reference, not as something the project specifies. Two corollaries follow from that positioning, and a single agent-collaboration rule (§2.6 rule 7) protects those corollaries from drift when an AI agent helps author the story register. This page is the canonical reference for the corollaries and the guard. It supports the `UserPromptSubmit` hook reminder, the refusal lists in the story-orchestrator and needs-and-requirements skills, and the attention regime that ships with the plugin.

## The two §2.1 corollaries

**Corollary 1: the Base Architecture is exogenous constraint, not project specification.** The decisions encoded in it are made by the parent organisation (product-line commitments, platform selections), by the customer (installed infrastructure, deployment environment), by parent products (subsystems inherited from a larger system), or by regulators (certifying authorities, mandated standards). The project shall *acknowledge* and *reference* those decisions. The project shall not produce artefacts whose role is to *justify* them.

**Corollary 2: stories move forward from the Base Architecture.** The story register authored from §4 onward records what the project shall *add* on top of the Base Architecture. Forward-going stories are the methodology's required output. Optional *context stories*, which record narrative around Base Architecture decisions for onboarding, audit trail, or organisational memory, may be added by deliberate human choice. They are neither required nor forbidden when added knowingly.

What is forbidden is *reverse-engineering*: synthesising stakeholders, concerns, or stories whose role is to fabricate post-hoc justification for an existing Base Architecture decision.

## Concrete distinction (the AC5000 example)

A reverse-engineered artefact looks like this. A stakeholder is fabricated as "AC5000 platform vendor" with the story "I want my platform to support 64 channels so that I can sell more units". That stakeholder's needs belong in the vendor's own project register, not the project's. The story exists only to retroactively justify a platform choice the project did not make and does not own.

A legitimate context story looks like this. The user adds, by deliberate choice, "operations selected the AC5000 in 2019 to consolidate the existing fleet". The entry is marked as context-only, sits outside the forward-going register, and exists because the user wanted organisational memory recorded alongside the project work. The two are distinguishable by the subject of the story and by who chose to write it.

## The §2.6 rule 7 reverse-engineering guard

Rule 7 of the well-formedness rules in §2.6 is a methodology-level instruction directed at AI agents:

- AI agents authoring or modifying the story register, the concern register, or related project artefacts shall not synthesise context stories.
- AI agents shall not reverse-engineer Base Architecture justifications.
- Such artefacts may be added only on explicit human request, with explicit confirmation of intent.
- The default agent posture is forward-going work.

Rule 7 is not enforced by CI. It is preserved through the project's `CLAUDE.md` (or equivalent project memory), through the `UserPromptSubmit` hook reminders documented in the ISO 29110 hooks guide, and through the refusal lists in the story orchestrator and the needs-and-requirements skills. Agents that detect a request which would violate rule 7 shall surface the conflict, ask for explicit confirmation of intent, and decline to proceed silently.

## Subject convention (§2.6 rule 5)

Forward-going stories declare their subject as the project's system or one of its subsystems, typically a *specialisation* of a Base Architecture `part def`, not the Base Architecture `part def` itself. Context stories added by deliberate human choice may declare a Base Architecture `part def` as `subject`.

CI emits an *informational warning* when a story's `subject` resolves to a `part def` declared in a `library package` of the Base Architecture. The warning serves two purposes. It confirms that the user intended the context-story posture, and it marks the story as optional context rather than required output. The warning shall not block the build.

A concern informed by a Base Architecture limitation is legitimate when its subject is the project's system. For example, "the chosen platform's lack of feature X means the project must compensate by Y" addresses what the project shall do given the constraint. A concern whose subject is the Base Architecture itself becomes optional context-recording, and CI warns rather than blocks.

## The §2.6 well-formedness rules at a glance

The rules in §2.6 are read together, not in isolation. They are summarised here so an agent loading this page sees the surrounding shape of the guard:

1. The Base Architecture resides in a `library package` and imports only from `library/`, `core/domain/`, or external libraries.
2. Every `require constraint` in the Base Architecture remains satisfied by every specialising part. CI flags weaker overrides.
3. The project's system part def has exactly one relationship to the Base Architecture (specialisation or allocation, not both).
4. Base Architecture changes are reviewed under elevated final-review criteria, because they propagate to every story whose subject specialises a Base Architecture part def.
5. Forward-going stories declare their `subject` as the project's system or a subsystem, typically a specialisation. Context stories may declare a Base Architecture part def. CI warns, does not block.
6. Concerns informed by Base Architecture limitations take the project's system as their subject. Concerns whose subject is the Base Architecture itself are optional context-recording.
7. Agent-collaboration discipline: no synthesis of context stories, no reverse-engineering of Base Architecture justifications, default posture is forward-going work, additions only on explicit human request with explicit confirmation of intent.

## How agents should behave under this guard

- Treat the forward-going posture as the default at every elicitation, drafting, or completion step.
- Resolve a story's `subject` before writing it. If the subject is a Base Architecture `part def`, stop and ask the user whether the entry is intended as a context story.
- Refuse to fabricate stakeholders that exist only to motivate a Base Architecture decision. Surface the request, name the rule, and offer a forward-going alternative such as a concern with the project's system as its subject.
- Record any human-confirmed context story with a marker that distinguishes it from the forward-going register, so later readers can separate organisational memory from project commitment.

## Brownfield discovery and the as-is survey

The §2.7 Discovery lifecycle category authorises *acknowledgement* of architectural givens that pre-existed the project but were missed at initial Base Architecture capture. Brownfield adoption (a project that runs `/vse-setup` against a repo that already contains implementation code) is the canonical Discovery entry path. The `@project-setup` skill performs an opt-in as-is architecture survey at Step 6.5 and walks the user through a per-element classification into two categories.

- **Mandated** elements are externally constrained and live in `model/core/base-architecture/` as `part def`s in a `library package`. They carry `@ConfigItem { :>> ciState = CIState::Baselined; :>> baselineId = "BL-BA-AS-IS-0.1" }`. The four mandate sources from §2.1 corollary 1 (parent organisation, customer, parent product, regulator) are recorded as a `mandateSource` attribute.
- **Contingent** elements are currently used but the project owns the choice. They live in `model/core/as-is/` and carry `@ConfigItem { :>> ciState = CIState::Proposed; :>> baselineId = "BL-AS-IS-CURRENT-0.1" }`. They may later be promoted, replaced, or retired through forward-going stories.

The survey is bound by rule 7 of §2.6. The dialogue captures evidence and source of mandate, never narrative justification of the decision. The skill MUST NOT ask "why is X mandated?" and MUST NOT emit `concern def`, `requirement def`, or `userStory` constructs from survey output. If the user volunteers a justification narrative, it is recorded verbatim into `docs/as-is-classification.md` and produces no SysML. The classification rationale document is *not* a needs document.

If the user declines the survey, the rationale doc carries a `<!-- as-is-survey: skipped at <date> -->` marker so a later `@architecture-design` invocation can resume under the same opt-in posture.

## Cross-links

- [[methodology-overview]] for the structure of the methodology and the position of §2 within it.
- [[user-story-canonical-artefact]] for the story shape that forward-going entries shall follow.
- [[system-context-completeness]] for the boundary between exogenous constraint and the system under specification.
- [[architectural-analysis-workflow]] for the downstream use of Base Architecture references during architecture trade studies.
