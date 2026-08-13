---
title: "Stakeholder identification and prioritisation in SYSMOD"
slug: sysmod-stakeholder-identification
type: process
layer: sysmod
summary: Workshop-based stakeholder identification, the priority-times-effort matrix, and direct versus indirect stakeholders
tags: [sysmod, stakeholders, concerns, prioritisation, elicitation, pre-traceability, sr-2]
sources:
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §4.8 (Identify Stakeholders)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §5.8 (Stakeholders)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §7.6 (How to model Stakeholders)"
    raw: sysmod.pdf
related:
  - stakeholder-stories-workflow
  - frame-concern-pattern
  - sysmod-system-context-source
  - sysmod-problem-statement-and-objectives
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [needs-and-requirements]
---

# Stakeholder identification and prioritisation in SYSMOD

## Contents

- How the list is built
- Who counts as a stakeholder
- What is recorded
- The prioritisation matrix
- Pre-traceability
- Modelling notes, carried over notation-neutrally
- Where the plugin diverges
- See also

The plugin's stakeholder work happens in methodology §4, and
[[stakeholder-stories-workflow]] is the authoritative account of
it: concerns become `concern def` elements, and stories frame them.
This page carries the SYSMOD identification method, which is the
step before that, and it carries one tool the plugin has no
equivalent for.

## How the list is built

The stakeholder list is initially elaborated in a workshop and then
continually reworked during the project. Two further sources feed
it.

- The list from a previous project can typically be reused.
- Further requirements analysis and system architecting digs up
  more stakeholders, so the list is never complete at the first
  pass.

The purpose given for the method is that it is decisive for the
success of the project that the concerns of all stakeholders are
sufficiently considered.

## Who counts as a stakeholder

A stakeholder is a person or an organisation who has concerns about
the system that can be the source for requirements of the system.

The definition deliberately admits an indirect case. A stakeholder
may have a direct link to the system, as future users do, or an
indirect link, as an authority does when it publishes laws or rules
that affect the system. The source is explicit that the indirect
kind need not have a direct link to the system and need not even
know it exists.

Concerns carry more than requirements. The source names them as a
source for requirements and, separately, as a source for needs that
are not explicitly stated but are essential and must be considered
by the system, or by the engineering team.

## What is recorded

Three fields are named: the name of the stakeholder, the
stakeholder's concerns, and contact information such as email
address and availability, so that the stakeholder can actually be
reached. Availability is worth taking seriously in a very small
entity, where the difference between a reachable and an unreachable
stakeholder decides whether elicitation happens at all.

## The prioritisation matrix

The stakeholder list gets long, so the source classifies each entry
on two axes and works the resulting quadrants.

- **Priority** of the stakeholder.
- **Effort** to consider that stakeholder.

Each quadrant is then assigned a different strategy for how to work
with the stakeholders in it. The source does not prescribe the four
strategies, which leaves the quadrant policy a project decision.

The pairing is the useful part. Priority alone over-invests in
stakeholders who are important and unreachable, and effort alone
optimises for the convenient rather than the consequential.

## Pre-traceability

System Objectives and requirements carry trace relationships back
to the stakeholders who are the source of that information. The
source calls this pre-traceability, and it is what makes a
requirement answerable later, when somebody asks who wanted it. See
[[sysmod-problem-statement-and-objectives]] for the objectives side
of the same trace.

## Modelling notes, carried over notation-neutrally

The guidance keeps the stakeholder list flat and manages it as a
table rather than a diagram.

A taxonomy of stakeholders, built by generalising concrete
stakeholders from abstract ones, is considered and set aside. The
reason given is specific to SysML v1, namely that stereotype
properties are not inherited, so a taxonomy would not propagate the
recorded fields and a diagram of it would carry little value. The
caveat is recorded here as source-specific rather than as a general
argument against structuring a stakeholder list.

## Where the plugin diverges

- **Concerns are first-class model elements.** In the plugin a
  concern is a `concern def` framed by a story (§4). See
  [[frame-concern-pattern]]. SYSMOD records concerns as recorded
  fields on a stakeholder entry.
- **Stakeholder and actor identity is fixed.** The plugin requires
  the same `part def` wherever an entity appears as a stakeholder
  and as an actor (§3.6 rule 5). See
  [[sysmod-system-context-source]] for how the source handles the
  same overlap.
- **The prioritisation matrix is a direct addition.** The plugin
  has no equivalent, and the matrix is a useful import for SR.2
  elicitation. It is also a sensible input to persona selection,
  because the personas a `vse-stakeholder-elicitor` run is pointed
  at should be the ones the matrix says are worth the effort.

## See also

- [[stakeholder-stories-workflow]] for the plugin's §4 workflow.
- [[frame-concern-pattern]] for how a story frames a concern.
- [[sysmod-system-context-source]] for the actor and stakeholder
  boundary.
- [[sysmod-problem-statement-and-objectives]] for the objectives
  that trace back to these stakeholders.
