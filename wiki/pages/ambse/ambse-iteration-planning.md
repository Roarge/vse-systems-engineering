---
title: "AMBSE Iteration Planning, Iteration 0, and Architecture 0"
slug: ambse-iteration-planning
type: process
layer: ambse
tags: [iteration-planning, work-items, story-points, iteration-0, architecture-0, velocity]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapters 1-2 (planning hierarchy, work items, estimation)."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Chapter 1, Sections 1.4-1.5 (Iteration 0 / Architecture 0)."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-principles
  - ambse-vee-three-timeframes
  - ambse-risk-and-metrics
  - iteration-centred-operation
  - iso29110-pm-process
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator]
---

# AMBSE Iteration Planning, Iteration 0, and Architecture 0

For the conceptual frame on cycles see
[[ambse-vee-three-timeframes]]. For the centre-of-gravity
operating model that consumes the iteration plan, see
[[iteration-centred-operation]].

## Planning hierarchy

Agile planning uses a hierarchy of planning artefacts at
different granularity levels:

| Artefact | Scope | Granularity | Updated |
|---|---|---|---|
| Product roadmap | 12-24 months | Epics and releases | Each iteration |
| Release plan | 2-6 iterations | Use cases per release | Each iteration |
| Iteration plan | 1-4 weeks | User stories and scenarios | Start of iteration |

Definitions:

- **Epic**: A coherent set of features, use cases, and user
  stories at a strategic level. Epics typically require 2 to 6
  iterations to complete. Business epics provide visible
  stakeholder value. Technical (enabler) epics provide
  behind-the-scenes infrastructure.
- **Use case**: A set of scenarios describing actor-system
  interactions. A use case corresponds to a few to many
  scenarios, roughly corresponding to up to 100 requirements. A
  use case is typically completed within a single iteration.
- **User story**: A single interaction of one or more actors
  with the system to achieve a goal. A user story is
  implemented in a few days.
- **Scenario**: A single path through a use case, equivalent in
  scope to a user story.

## Work item management

A **work item** is a unit of work to be done. Work items are
the building blocks of backlogs and are managed through two
workflows.

### Work item properties

| Property | Description |
|---|---|
| Name | Short descriptive name |
| Description | What work is to be done, or the work product to be created |
| Acceptance criteria | How adequacy of the work will be determined |
| Classification | Epic, use case, user story, scenario, defect, risk (spike), work product |
| Priority | Urgency and importance (determines iteration allocation) |
| Estimated effort | Story points or half-days |
| Related information | Standards, source material, dependencies |

### Workflow 1: Adding a work item to the backlog

Create work item, approve, prioritise, estimate effort, place
in project backlog, allocate to an iteration backlog.

### Workflow 2: Completing a work item

Perform work, review against acceptance criteria. If accepted:
remove from iteration backlog, review and reorganise remaining
backlog. If rejected: rework.

## Iteration 0 (project initiation)

Iteration 0 maps to ISO 29110 PM.1 (Project Planning) and SR.1
(Initiation). It establishes the project infrastructure before
the first specification iteration:

- Set up the modelling environment (SySiDE, syside.toml, Git
  repository).
- Create the initial project backlog from stakeholder needs.
- Define the product roadmap and release plan.
- Establish the SEMP (Systems Engineering Management Plan).
- Identify initial risks and create spike work items.

For the ISO 29110 PM.1 and SR.1 activity catalogue, see
[[iso29110-pm-process]] and [[iso29110-sr-process]].

## Architecture 0

The first iteration typically focuses on establishing the
initial system architecture (a "skeleton" design) before
detailed specification work begins. This is done to:

- Identify the major subsystems and their interfaces.
- Establish the model package structure.
- Define the initial data model and naming conventions.
- Reduce technical risk through early architectural prototyping.

Architecture 0 maps to early SR.3 activities in ISO 29110. The
plugin's `@project-setup` skill scaffolds the SysML 2.0 package
layout that Architecture 0 builds on; see
[[sysml2-canonical-model-layout]] and
[[vse-canonical-project-layout]].

## Effort estimation for SE

### Story points for specification work

In agile SE, effort is estimated in **story points**, which are
relative measures of complexity, not absolute time units. Use
planning poker or similar techniques.

Typical complexity factors for SE specification work:

| Factor | Low complexity | Medium complexity | High complexity |
|---|---|---|---|
| Interface count | 0-2 external | 3-5 external | 6+ external |
| Constraint density | Few QoS requirements | Some QoS constraints | Many coupled constraints |
| Novelty | Well-understood domain | Some new technology | Novel, unproven approach |
| Dependability | Non-critical | Moderate safety concern | Safety/reliability critical |

### VSE estimation guidance

- Estimate in **half-days** for small teams where absolute
  planning is needed.
- Review and recalibrate estimates after each iteration using
  measured velocity.
- **SE velocity**: specified use cases per iteration.
- **SE fine-grained velocity**: story points per iteration.
- Track both planned and actual velocity on a velocity chart to
  improve accuracy.

## See also

- [[ambse-principles]] and [[ambse-vee-three-timeframes]] for
  the methodology context.
- [[ambse-risk-and-metrics]] for risk management and metrics
  that consume velocity data.
- [[iteration-centred-operation]] for centre-of-gravity-driven
  iteration routing.
- [[iso29110-pm-process]] and [[iso29110-sr-process]] for the
  PM.1 and SR.1 activity catalogue Iteration 0 satisfies.
- [[sysml2-canonical-model-layout]] for the package layout
  Architecture 0 establishes.
