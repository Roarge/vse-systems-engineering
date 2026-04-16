---
title: "[Reference Title]"
slug: [kebab-case-slug]
type: reference
layer: [iso29110|phas-eai|incose-vse|ambse|sysml2|syside|needs-and-reqs|vv|hsi|project-structure]
tags: []
sources:
  - citation: "[Full bibliographic citation]"
    raw: [source-filename.pdf]
related: []
confidence: high
created: YYYY-MM-DD
updated: YYYY-MM-DD
bundled_by: []
---

# [Reference Title]

A **reference** page captures authoritative content from a primary source
in a form the LLM can consume directly. Use this type for syntax tables,
normative rules, API entries, notation cheat-sheets, and other content
whose value is in fidelity to the source.

## When to use this type

- You are distilling a section of a specification, handbook, or manual.
- The content is not substantially original; your value-add is selection,
  formatting, and pointer-preservation.
- A skilled reader with access to the source could verify every claim
  directly from the citation.

## What this page should contain

- A brief orientation paragraph explaining what the source covers and how
  this page selects from it.
- The reference content itself, organised for quick lookup. Prefer tables,
  numbered lists, and short subsections. Avoid long prose.
- A "See also" block pointing to `[[related-pages]]` that a reader might
  need next.

## What this page should not contain

- Original synthesis across multiple sources. That belongs in a `concept`
  page.
- Process steps or workflow guidance. That belongs in a `process` page.
- Recurring design choices. That belongs in a `pattern` page.

## Size guidance

A reference page is typically 50 to 200 lines. If the source section you
are capturing exceeds that, split into multiple reference pages (for
example, `sysml2-successions-syntax` and `sysml2-successions-semantics`)
rather than growing one page.
