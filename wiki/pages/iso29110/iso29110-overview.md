---
title: "ISO/IEC 29110 VSE Systems Engineering Profile Overview"
slug: iso29110-overview
type: concept
layer: iso29110
tags: [iso29110, vse, lifecycle-neutral, basic-profile, generic-profile-group]
sources:
  - citation: "ISO/IEC TR 29110-5-6-2:2014. Systems Engineering — Lifecycle profiles for Very Small Entities (VSEs) — Part 5-6-2: Management and Engineering Guide for the Generic Profile Group: Basic Profile."
    raw: ISO_IEC_TR_29110-5-6-2_2014.pdf
  - citation: "ISO/IEC 15288. Systems and software engineering — System life cycle processes."
    raw: null
  - citation: "ISO/IEC/IEEE 15289. Systems and software engineering — Content of life-cycle information items."
    raw: null
related:
  - iso29110-pm-process
  - iso29110-sr-process
  - iso29110-roles-and-work-products
  - iso29110-phase-gates
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [project-setup, release-orchestrator]
---

# ISO/IEC 29110 VSE Systems Engineering Profile Overview

ISO/IEC TR 29110-5-6-2:2014 provides a Management and Engineering
Guide for the Basic Profile of the Generic Profile Group for Systems
Engineering. It targets **Very Small Entities (VSEs)**, defined as
enterprises, organisations, departments, or projects having up to
**25 people**. The standard applies to non-critical systems
development projects.

## Lifecycle-neutrality

The Basic Profile is **lifecycle-neutral**: it can be used with
waterfall, iterative, incremental, evolutionary, agile, or
test-driven approaches. The ISO/IEC 29110 series can be applied at
any phase of system or software development within a lifecycle.
This plugin enters the lifecycle at the centre-of-gravity activity
indicated in `.vse-iteration.yml` rather than at a fixed PM.1 or
SR.1 starting point. See [[methodology-overview]] for the
iteration-centred operating model that takes this freedom
seriously.

## Two interrelated processes

The guide is structured around two processes:

- **Project Management (PM).** Uses the Acquirer's Statement of
  Work (SOW) to elaborate a Project Plan, monitor progress, handle
  change requests, and close the project. Detailed in
  [[iso29110-pm-process]].
- **System Definition and Realization (SR).** Driven by the Systems
  Engineering Management Plan (SEMP) and covers requirements
  elicitation, architectural design, construction, integration,
  verification, validation, and product delivery. Detailed in
  [[iso29110-sr-process]].

## Entry conditions

Before running the Basic Profile, the standard requires:

- Project needs and expectations are documented.
- Feasibility has been assessed.
- A project team (including project manager and systems engineer)
  is assigned and trained.
- Goods, services, and infrastructure are available.

## Foundations and references

The standard is based on:

- **ISO/IEC 15288**: system life cycle processes.
- **ISO/IEC/IEEE 15289**: life cycle information products.

For the role catalogue (PJM, SYS, DES, DEV, IVV, ACQ, STK, SUP, WT)
and the full work-product list, see
[[iso29110-roles-and-work-products]]. For phase-transition
checklists, see [[iso29110-phase-gates]].

## See also

- [[iso29110-pm-process]] for PM.1-PM.4 tasks and objectives.
- [[iso29110-sr-process]] for SR.1-SR.6 tasks and objectives.
- [[iso29110-roles-and-work-products]] for role responsibilities
  and the catalogue of work products.
- [[iso29110-phase-gates]] for phase-to-phase transition
  checklists.
- [[methodology-overview]] for the iteration-centred
  operating model the plugin uses on top of this catalogue.
