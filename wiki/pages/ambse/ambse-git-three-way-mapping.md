---
title: "AMBSE Git Workflow: Three-Way Mapping"
slug: ambse-git-three-way-mapping
type: concept
layer: ambse
tags: [git, workflow, nanocycle, microcycle, macrocycle, mapping, host-agnostic]
sources:
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Packt. Pages 40-41 (timeframes), 53-54 (iteration verification), 61 (handoff workflow), 64 (Vee as pattern)."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-vee-three-timeframes
  - ambse-git-nanocycle-commits
  - ambse-git-microcycle-prs
  - ambse-git-ci-gates-and-macrocycle
  - ambse-git-vse-guidance-and-anti-patterns
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator]
---

# AMBSE Git Workflow: Three-Way Mapping

This page is the canonical mapping between Agile Model-Based
Systems Engineering and a feature-branch git workflow used by
this plugin. The three AMBSE timeframes (nanocycle, microcycle,
macrocycle, see [[ambse-vee-three-timeframes]]) map onto the
three units of git collaboration that almost every modern
hosting platform supports: the commit, the feature branch with
a pull request (or merge request), and the release tag.

The mapping is **host-agnostic**. The text below uses the term
*pull request* but everything applies equally to GitLab merge
requests, Forgejo pull requests, Gitea pull requests, and
Bitbucket pull requests. Where the plugin ships ready-made
automation, it ships GitHub Actions workflow templates in
`templates/github/`. Translating those to GitLab CI or Forgejo
Actions is mechanical: the gate scripts are plain bash and
live in `hooks/`.

## Premise: three timeframes from Douglass

Continuous verification in AMBSE operates at three timeframes
(Douglass, B.P. (2021) *Agile MBSE Cookbook*, Packt,
pp. 40-41):

> Verification taking place in three timeframes:
>
> - Nanocycle: 30 minutes to 1 day
> - Microcycle: 1-4 weeks
> - Macrocycle: Project length

Each timeframe applies the Vee verification pattern at its
own scale. Douglass is explicit on this point (Cookbook, p. 64,
discussing Figure 2.6):

> A difference between this process and a traditional V process
> is the path labeled "[more reqs]"; if there are more
> requirements, this loop of activities is done again. In fact,
> a traditional V process is simply this process cycle done
> once.

In other words, the traditional Vee is a single execution of
the AMBSE cycle. AMBSE iterates the same Vee structure many
times, at three different scales, and verifies at every
iteration boundary.

The Cookbook describes the iteration boundary itself as a
workflow, not an event (Cookbook, p. 61):

> The handoff to downstream engineering isn't an event, rather
> it is a workflow where we convert and organize the relevant
> systems engineering data into data needed and consumable for
> detailed design and implementation.

And on the verification work that happens at each iteration
boundary (Cookbook, pp. 53-54):

> At the end of each systems engineering iteration, some work
> products are produced ... these work products can be verified
> that they are individually correct and that the integration
> of those elements works as expected.

Douglass himself does not use the language of branches,
commits, or pull requests. The mapping that follows is this
plugin's operationalisation of Douglass's "handoff workflow"
onto a feature-branch git flow. The vocabulary of git is the
plugin's contribution. The underlying discipline (verify at
every iteration boundary, treat the handoff as a workflow with
explicit work products) is Douglass's.

## The three-way mapping

| AMBSE timeframe | Git unit | Verification scope | Trigger |
|---|---|---|---|
| Nanocycle (30 min - 1 day) | Commit on a feature branch | One model element, one trace, one constraint | Pre-commit hook |
| Microcycle (1 - 4 weeks) | Feature branch merged via pull request | One iteration mission, full trace closure, phase gate | PR check (CI workflow) |
| Macrocycle (project length) | Release tag on `main` | Full system V&V before delivery | Manual tag, optional release workflow |

This mapping is the inner skeleton of every AMBSE-managed
project the plugin scaffolds. The companion pages describe
each row in detail and give concrete naming, commit, and PR
conventions:

- [[ambse-git-nanocycle-commits]] for the nanocycle = commit
  row.
- [[ambse-git-microcycle-prs]] for the microcycle = feature
  branch + PR row.
- [[ambse-git-ci-gates-and-macrocycle]] for CI gates and the
  macrocycle = release tag row.
- [[ambse-git-vse-guidance-and-anti-patterns]] for VSE-specific
  guidance (solo, 2-5 person, larger) plus the anti-pattern
  catalogue.

## See also

- [[ambse-vee-three-timeframes]] for the AMBSE timeframe
  definitions this mapping operationalises.
- [[ambse-iso29110-mapping]] for the AMBSE-to-ISO 29110
  activity table that runs on top of this git flow.
- [[iteration-centred-operation]] for the centre-of-gravity
  operating model that uses this mapping at runtime.
