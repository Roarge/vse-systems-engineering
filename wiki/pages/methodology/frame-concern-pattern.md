---
title: "frame concern: linking stories to stakeholder concerns"
slug: frame-concern-pattern
type: pattern
layer: methodology
tags: [user-story, concern, sysmlv2, stakeholder-need, traceability, framing]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §1.4.6 (frame concern)."
    raw: methodology/01-user-stories.md
related:
  - methodology-overview
  - user-story-canonical-artefact
  - stakeholder-stories-workflow
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, story-orchestrator, needs-and-requirements]
---

# frame concern: linking stories to stakeholder concerns

The `frame concern` member is the optional bridge that ties a User Story to one or more persistent stakeholder concerns held in the model. It is the SysML 2.0 mechanism that lets the project carry a stable record of what stakeholders care about, while stories addressing those concerns enter and leave the backlog at the agile cadence. See [[user-story-canonical-artefact]] for the surrounding story definition and [[methodology-overview]] for the artefact taxonomy.

## Problem

A story-driven backlog is, by design, churn-tolerant. Stories are written, refined, split, merged, superseded, and retired across iterations. Stakeholder concerns, in contrast, persist. The operations team's worry about incident response time outlasts any single story written to satisfy it. Without a stable concept that captures the persistent need, every story rewrite risks losing the underlying rationale, and the project cannot answer two basic questions: which stakeholder needs are not yet addressed, and which backlog items are not anchored to any acknowledged need.

## Context

This pattern applies whenever the project recognises a stakeholder need that exists independently of the specific capability proposed to satisfy it. It applies during stakeholder elicitation, when the engineer is capturing what stakeholders worry about before any solution is proposed, and during story authoring, when a new story should be linked to the concern it addresses. It does not apply where the need is fully captured by a single, stable system-level requirement that already participates in `satisfy` traces.

## Forces

The pattern balances three competing concerns.

- Stakeholder needs must remain stable across story churn so that traceability does not fragment.
- Stories must remain small, agile, and easy to rewrite without rewriting the underlying need.
- The model must support coverage queries in both directions: from concern to stories and from stories to concerns.

## Solution

Capture each persistent stakeholder concern as a `concern def` (SysML 2.0 §32.5). A `concern def` is a specialised requirement that captures a stakeholder need in its own right, independent of any specific story that happens to address it. Stories then declare the concerns they address through the `frame concern` mechanism, with multiplicity `[0..*]`.

```sysml
concern def FastIncidentResponse {
    subject system    : Aiwell_OnlineSentral;
    stakeholder ops   : OperationsTeam;
    require constraint {
        doc /* Operations need short time-to-acknowledge to meet
               SLA targets for incident response. */
    }
}

requirement def US_042_AckFromDashboard :> UserStory {
    stakeholder :>> role : Operator;
    capability = "acknowledge alarms from the dashboard";
    benefit    = "the queue clears quickly";

    subject system : Aiwell_OnlineSentral;

    frame concern : OpsConcerns::FastIncidentResponse;

    requirement acceptance[1] { /* ... */ }
}
```

The story does not redefine or own the concern. It frames it. The concern lives in a stakeholder-needs package (here, `OpsConcerns`) and is referenced by every story that addresses it. See [[stakeholder-stories-workflow]] for where in the elicitation flow concerns are first authored.

## Consequences

Three consequences follow once the project adopts this pattern.

1. **Concerns and stories are n:m.** A single concern, for example maintainability, can be addressed by multiple stories. A single story can address multiple concerns. The `frame concern` member makes this many-to-many relation explicit in the model rather than leaving it implicit in prose.
2. **Concerns outlive stories.** A concern modelled once in a stakeholder-needs package is referenced from any story that addresses it. When stories are reworked or superseded across iterations, the concern remains stable, and incoming stories can pick up the same framing without re-authoring the underlying need.
3. **Coverage is queryable.** The framing relation supports both directions of analysis. A `concern def` with no framing stories is an unmet stakeholder need and is candidate work for the next backlog refinement. A User Story with no framed concerns is an unrooted backlog item, often a sign that the story was added without an acknowledged stakeholder behind it.

## Relation to the narrative `benefit`

The narrative `benefit` attribute on the story is retained even when a concern is framed. The two members answer different questions and neither replaces the other.

- `benefit` articulates *what value the role gains* from the capability described in the story. It is local to the story and reads naturally on the agile card.
- `concern def` articulates *what the stakeholder fears, hopes for, or requires* at a more abstract level, independent of any one capability. It persists across the model.

Both are useful. A story whose `benefit` reads "the queue clears quickly" can frame a `FastIncidentResponse` concern that explains, at a higher level, why a quickly-clearing queue matters to the operations team in the first place.

## Well-formedness considerations

The `frame concern` member is optional, so a missing framing is not a violation in itself. The lint signal is the unrooted-story heuristic: a story that has progressed past `backlog` status without framing any concern is a candidate for review during the next backlog refinement. The complementary signal is the unmet-concern heuristic: a `concern def` in the stakeholder-needs package with no framing stories is a candidate for new story authoring.

## When not to use this pattern

Where the stakeholder need is already fully captured by a stable, named system-level requirement that participates in `satisfy` traces, framing through a separate `concern def` adds redundancy without adding traceability. In that case the requirement-kind taxonomy is sufficient, and the story's narrative `benefit` plus its acceptance criteria carry the link. Reach for `frame concern` when the need is recognised but not yet reduced to a satisfiable requirement, or when a single need legitimately stands behind multiple stories at once.
