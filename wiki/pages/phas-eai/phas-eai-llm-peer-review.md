---
title: "LLM as expert peer in VSE requirement reviews"
slug: phas-eai-llm-peer-review
type: pattern
layer: phas-eai
summary: Case evidence for LLM-as-expert-peer requirement reviews in a VSE, with cautions on scoring and model ageing
tags: [phas-eai, llm, peer-review, requirements-quality, vse, case-study]
sources:
  - citation: "Georgsen, R. E. (2023). Beyond Code Assistance with GPT-4: Leveraging GitHub Copilot and ChatGPT for Peer Review in VSE Engineering. Norsk IKT-konferanse for forskning og utdanning (NIKT), no. 2 (NOKOBIT track), November 2023. https://www.ntnu.no/ojs/index.php/nikt/article/view/5674"
    raw: "Paper IV - 5674-Article Text-21352-1-10-20231101.pdf"
related:
  - phas-eai-overview
  - phas-eai-de-requirements
  - phas-eai-levers-and-evidence
  - phas-eai-designing-attention-regimes
  - sysmod-neg-human-dimension
  - requirements-elicitation-and-writing
confidence: medium
created: 2026-08-13
updated: 2026-08-13
referenced_by: [attention-regime, needs-and-requirements]
---

# LLM as expert peer in VSE requirement reviews

## Contents

- Problem
- Context
- Forces
- Solution
- Evidence
- Consequences and cautions
- Related patterns

Confidence note: this page sits at `medium` rather than `high` for four
reasons. The evidence is a single case study of one company, the study was
participatory action research conducted with the company, it isolates no
causal effect, and the models it used are several generations old. What the
page keeps are the findings about the shape of the interaction between
engineers and a language model, which do not depend on which model
generation is in use.

## Problem

A very small entity, meaning an organisation of up to 25 people, is usually
staffed by domain specialists and lacks in-house expertise in supporting
disciplines such as security and reliability engineering, process improvement,
quality management, and systems engineering. The same organisations find
standardised methods too broad for their needs and prefer informal,
organically evolved ways of working. Research cited by the source records that
contractual obligations to follow industry standards and best practice have
little effect on what engineering actually happens, so documented compliance
and real practice drift apart. Requirements quality is one of the places where
the gap costs most, because well-formed requirements reduce revisions and
delays and keep stakeholders aligned on what is being built.

## Context

Apply this pattern when review competence is missing, whether the constraint
is the budget or a labour market that does not supply it.
It suits a team that already works on a shared digital collaboration platform
and can accept cloud tooling for the material under review.

The evidence is dated, and stating that up front is part of using the pattern
honestly. The study ran during 2023 with the language models then available.
Its findings about specific model weaknesses and about the privacy landscape
of that year have been overtaken, and this page does not carry them. What it
carries are the findings about how the humans and the model interacted, which
concern the working arrangement rather than model capability.

## Forces

- Cost and training time pull against review quality. A very small entity
  cannot fund either an expert hire or a long adoption programme.
- Automation pulls against human judgement. A review that runs without a human
  owner produces output nobody has weighed.
- Confidentiality pulls against cloud tooling. Proprietary material passing
  through an external service demands an explicit posture before adoption.

## Solution

The case company was a seven-person Norwegian producer of software and
hardware for building automation. Five elements make up the pattern as it was
practised there.

1. **Give the model the same references the humans use.** The INCOSE Systems
   Engineering Handbook and the Systems Engineering Book of Knowledge were
   supplied as links, together with a written description of the system
   context and of the scoring system. There was no fine-tuning and no curated
   vector database, and the tools used were the freely or cheaply available
   ones.
2. **Let it work in the team's normal channel.** A workflow action fired when
   an issue was labelled as a requirement, called the model, and posted the
   evaluation back as a comment on that issue, where the engineers were
   already reading.
3. **Have it apply the team's own rubric.** Each requirement was scored from 1
   to 5 on clarity, conciseness, testability, and traceability, weighted 0.30,
   0.15, 0.35, and 0.20 respectively, and combined into a composite score. The
   human engineers scored with the same rubric, using a Planning Poker style
   of estimation to surface disagreement.
4. **Ask for improvements, not verdicts.** The output broke the requirement
   down attribute by attribute and returned a task list of concrete
   improvements, such as naming the conditions under which a limit applies and
   stating how it would be tested.
5. **Keep a human reviewer in the loop at all times.** A systems engineer
   reviewed the model's output throughout, and the review itself was part of
   the study's cycles of planning, action, observation, and reflection.

## Evidence

The tracked metrics were the number of requirement revisions, the time spent
on each requirement, and how often a requirement-labelled issue was approved
without further revision. The company recorded more precise and more complete
requirements, with fewer revisions and less time spent per requirement.

Two findings matter more than the metrics. The first is a mentor effect.
Engineers gradually adopted thought patterns similar to the model-generated
output, so their requirements became clearer even when they wrote without
assistance, with the model in effect serving as a systems engineering mentor.
This is the strongest published evidence behind the R2 premise in
[[phas-eai-de-requirements]], that competence can be embedded in the toolchain
rather than carried by an individual. The second is the mechanism behind the
quality gain. The improvement was not primarily due to the quality of the
generated output, which was sometimes lacking. It came from the model
prompting the engineer to take a broader perspective, to write in more detail,
and to notice edge cases.

## Consequences and cautions

- **Scores are discussion triggers, not verdicts.** The model's numerical
  scores often diverged from the human evaluations. The value came from
  treating each divergence as a prompt for discussion, which in the case led
  the team to refine its own evaluation criteria and reach a more stable
  consensus. Any skill that presents quality scores should present them in
  that spirit.
- **Data privacy needs an explicit posture before adoption.** Engineers in the
  case were concerned about proprietary material reaching an external service.
  The specific mitigations available have changed since, the obligation to
  decide has not.
- **Scalability was an open question in the source.** The study covered a
  narrow topic and a simple technical implementation, and it did not establish
  how the benefits behave on more complex work.

## Related patterns

- [[phas-eai-de-requirements]] states R2, for which this case is the evidence,
  and [[phas-eai-levers-and-evidence]] records the same claim as hypothesis
  H7, that designed reserve outperforms investment in individual skill.
- [[phas-eai-designing-attention-regimes]] gives the design procedure for the
  kind of arrangement the review pipeline is, since a recurring review in the
  team's own channel functions as a Patterned Practice.
- [[sysmod-neg-human-dimension]] states the industry-side version of the same
  problem, a methods and tools curve that falls behind and is bridged by
  project heroes.
- [[requirements-elicitation-and-writing]] carries the writing rules and
  quality attributes a review of this kind assesses against.
