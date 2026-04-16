---
title: "[Process Title]"
slug: [kebab-case-slug]
type: process
layer: [iso29110|phas-eai|incose-vse|ambse|sysml2|syside|needs-and-reqs|vv|hsi|project-structure]
tags: []
sources:
  - citation: "[Source defining the process]"
    raw: [source-filename.pdf]
related: []
confidence: high
created: YYYY-MM-DD
updated: YYYY-MM-DD
bundled_by: []
---

# [Process Title]

A **process** page captures a sequence of steps. Use this type for ISO/IEC
29110 task flows, AMBSE nanocycle workflows, V&V procedures, and any
repeatable activity a contributor or engineer would execute.

## When to use this type

- The content is "how to do X", with ordered steps.
- Skipping or reordering steps would change the outcome.
- The process produces one or more work products that can be listed
  explicitly.

## What this page should contain

- A one-sentence statement of the process goal.
- Preconditions. What must be true before the process can start.
- Numbered steps. Each step names an actor (engineer, subagent, hook),
  inputs, outputs, and any decision points.
- Postconditions. What must be true when the process completes.
- Work products produced, with links to the relevant templates if any.
- Failure modes. What can go wrong, and the recovery action for each.

## What this page should not contain

- The rationale behind the process. That belongs in a `concept` page,
  linked from the preconditions or the first step.
- Syntax details for tools used in the process. Link out to `reference`
  pages instead.

## Size guidance

Process pages typically run 100 to 300 lines depending on step count. A
process with more than ten steps is a candidate for splitting into a
high-level overview plus sub-processes.
