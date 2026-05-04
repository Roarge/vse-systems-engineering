---
title: "[Pattern Title]"
slug: [kebab-case-slug]
type: pattern
layer: [iso29110|phas-eai|incose-vse|ambse|sysml2|syside|needs-and-reqs|vv|hsi|project-structure]
tags: []
sources:
  - citation: "[Source supporting the pattern, if any]"
    raw: [source-filename.pdf]
related: []
confidence: high
created: YYYY-MM-DD
updated: YYYY-MM-DD
bundled_by: []
---

# [Pattern Title]

A **pattern** page captures a recurring design choice with a clear
problem, context, solution, and consequences. Use this type for SysML
modelling patterns, AMBSE architecture patterns, elicitation patterns, and
other reusable answers to recurring questions.

## When to use this type

- The situation comes up repeatedly in VSE projects.
- Multiple solutions compete and one or a few are preferred.
- The choice has consequences that contributors and engineers need to
  weigh in their own context.

## What this page should contain

- **Problem.** One paragraph stating the recurring situation in its
  neutral form.
- **Context.** When this pattern applies, and when it does not.
- **Forces.** The competing concerns the pattern balances.
- **Solution.** The recommended approach, with a short example in prose,
  SysML 2.0 snippet, or directory-structure fragment.
- **Consequences.** Trade-offs the engineer accepts by using this
  pattern. Be explicit about both benefits and costs.
- **Related patterns.** Wikilinks to alternatives and compositions.

## What this page should not contain

- Full working examples. Keep the snippet minimal and link to templates or
  the demo project for a runnable example.
- Justification essays. Forces and consequences should state the trade-off
  plainly without argumentation.

## Size guidance

Pattern pages typically run 80 to 200 lines. Larger patterns are a sign
the content should be decomposed into a concept page plus one or more
smaller patterns.
