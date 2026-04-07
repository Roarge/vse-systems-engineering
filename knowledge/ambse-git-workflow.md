# AMBSE Git Workflow (Branch per Microcycle)

This file is the canonical mapping between Agile Model-Based Systems
Engineering and a feature-branch git workflow used by this plugin. The
three AMBSE timeframes (nanocycle, microcycle, macrocycle) map onto the
three units of git collaboration that almost every modern hosting platform
supports: the commit, the feature branch with a pull request (or merge
request), and the release tag.

The mapping is host-agnostic. The text below uses the term *pull request*
but everything applies equally to GitLab merge requests, Forgejo pull
requests, Gitea pull requests, and Bitbucket pull requests. Where the
plugin ships ready-made automation, it ships GitHub Actions workflow
templates in `templates/github/`. Translating those to GitLab CI or
Forgejo Actions is mechanical: the gate scripts are plain bash and live
in `hooks/`.

---

## 1. Premise: Three Timeframes from Douglass

Continuous verification in AMBSE operates at three timeframes (Douglass,
B.P. (2021) *Agile MBSE Cookbook*, Packt, pp. 40-41):

> Verification taking place in three timeframes:
>
> - Nanocycle: 30 minutes to 1 day
> - Microcycle: 1-4 weeks
> - Macrocycle: Project length

Each timeframe applies the Vee verification pattern at its own scale.
Douglass is explicit on this point (Cookbook, p. 64, discussing
Figure 2.6):

> A difference between this process and a traditional V process is the
> path labeled "[more reqs]"; if there are more requirements, this loop
> of activities is done again. In fact, a traditional V process is
> simply this process cycle done once.

In other words, the traditional Vee is a single execution of the AMBSE
cycle. AMBSE iterates the same Vee structure many times, at three
different scales, and verifies at every iteration boundary.

The Cookbook describes the iteration boundary itself as a workflow, not
an event (Cookbook, p. 61):

> The handoff to downstream engineering isn't an event, rather it is a
> workflow where we convert and organize the relevant systems engineering
> data into data needed and consumable for detailed design and
> implementation.

And on the verification work that happens at each iteration boundary
(Cookbook, pp. 53-54):

> At the end of each systems engineering iteration, some work products
> are produced ... these work products can be verified that they are
> individually correct and that the integration of those elements works
> as expected.

Douglass himself does not use the language of branches, commits, or
pull requests. The mapping that follows is this plugin's
operationalisation of Douglass's "handoff workflow" onto a feature-branch
git flow. The vocabulary of git is the plugin's contribution. The
underlying discipline (verify at every iteration boundary, treat the
handoff as a workflow with explicit work products) is Douglass's.

---

## 2. The Three-Way Mapping

| AMBSE timeframe | Git unit | Verification scope | Trigger |
|-----------------|----------|--------------------|---------|
| Nanocycle (30 min - 1 day) | Commit on a feature branch | One model element, one trace, one constraint | Pre-commit hook |
| Microcycle (1 - 4 weeks) | Feature branch merged via pull request | One iteration mission, full trace closure, phase gate | PR check (CI workflow) |
| Macrocycle (project length) | Release tag on `main` | Full system V&V before delivery | Manual tag, optional release workflow |

This mapping is the inner skeleton of every AMBSE-managed project the
plugin scaffolds. The rest of this file describes each row in detail
and gives concrete naming, commit, and PR conventions.

---

## 3. Nanocycle = Commit

A nanocycle is the 30-minute to 1-day inner loop of model writing.
Each nanocycle ends with the model being slightly more complete or
slightly more correct, and a verification step that confirms the change
did not break anything.

### Mapping

- One commit per nanocycle is the typical case. A single commit captures
  one focused unit of work: a new requirement and its `satisfy` link,
  a new verification case and its `verify` link, a refactored package
  structure, a corrected trace, a clarified doc string.
- Several small commits per nanocycle are also fine. The important
  property is that each commit leaves the model in a verifiable state.
- The commit happens on a feature branch, never directly on `main`.
  See Section 4 for branch naming.

### Vee inside the nanocycle

Mapped onto the Vee verification pattern:

- **Left side (specification)**: write the model element, the trace
  link, the doc string, the constraint.
- **Right side (verification)**: run the local checks immediately. The
  pre-commit traceability hook (`hooks/pre-commit-traceability.sh`)
  blocks the commit if a requirement was added without a `satisfy` or
  `verify` link. SySiDE's syntax validation runs continuously in the
  IDE. If you have the SySiDE CLI on your PATH,
  `syside check --warnings-as-errors --stats` is the equivalent
  command-line gate.

### Commit message convention

The plugin's git history uses conventional commits with a scope, for
example:

```text
feat(requirements): add REQ-014 ambient pressure threshold
fix(architecture): correct allocate from REQ-007 to ProcessingSubsystem
refactor(model): split sensors package into sensing and acquisition
docs(use-cases): clarify abnormal-flow precondition for UC-MonitorTemp
```

Free-form messages are acceptable, but each commit body should answer
two questions: which work product or use case did the change touch, and
why was the change needed. The pre-commit hook is the mechanical gate.
The commit message is the human-readable trace.

### Anti-pattern at the nanocycle scale

- Bypassing the trace check with `git commit --no-verify`. This breaks
  the niche-construction guard (PHAS-EAI R4) that the plugin's
  attention regime depends on. If a trace genuinely cannot be added
  yet (for example because the parent requirement does not exist),
  add a placeholder requirement with a doc comment explaining the gap,
  then file the gap as a backlog item to resolve in the same iteration.

---

## 4. Microcycle = Feature Branch with Pull Request

A microcycle is one AMBSE iteration: 1 to 4 weeks of work that
delivers a verified slice of system specification. Every microcycle has
an iteration mission stated up front (one or two use cases specified, a
trade study completed, an interface baselined).

### Branch naming

```text
vse/iter-NN[-short-desc]
```

- `vse/` prefix marks the branch as a VSE iteration branch and
  separates it visually from `feat/`, `fix/`, `docs/` and other
  conventional-commit branch prefixes that may exist in the same repo.
- `iter-NN` is the iteration number (zero-padded). Iteration numbers
  are sequential across the project's history, never reset.
- `-short-desc` is optional but recommended. It identifies the
  iteration mission in a few words.

Examples:

```text
vse/iter-00-architecture-zero
vse/iter-01-monitor-temperature
vse/iter-02-temperature-control
vse/iter-12-acquirer-acceptance-prep
```

### Branching off main

The branch is created from the latest `main` at the start of the
iteration:

```bash
git checkout main
git pull
git checkout -b vse/iter-03-temperature-control
```

The branch lives for the duration of the microcycle (1 to 4 weeks).
All nanocycles for the iteration mission happen on this branch. Keep
the branch off `main` mid-iteration. Rebase only when the team
explicitly decides a synchronisation point is needed. Douglass's
"avoid bundling multiple iterations" guidance applies here too.

### Worked example: a small microcycle history

```text
* (HEAD -> vse/iter-03-temperature-control) refactor(model): rename SetpointPort to TemperatureSetpointPort
* docs(use-cases): add abnormal flow for setpoint out of range
* feat(verification): add VER-018 setpoint accuracy test
* feat(architecture): allocate REQ-021 to TemperatureControlSubsystem
* feat(requirements): derive REQ-021 setpoint accuracy
* feat(requirements): add UC-ControlTemperature mission and STK-014
| (main)
```

Six commits, all focused, each commit leaves the model verifiable.
The first commit opens the use case, the next four trace the use case
into requirements, architecture, and verification, and the last commit
is a refactor caught at peer review time. This is one microcycle.

### Pull request as the handoff gate

When the iteration mission is complete and all the nanocycles are
in, the branch is pushed and a pull request is opened against `main`.
The pull request is the operational form of Douglass's handoff
workflow (Cookbook, p. 61): the diff is the *converted* engineering
data, the PR description is the *organisation* of that data, and the
review event is the formal handoff.

PR title convention:

```text
Iteration NN: <iteration mission>
```

For example:

```text
Iteration 03: Temperature control use case specified and verified
```

PR body template (the plugin ships this in
`templates/github/pull-request-template.md`):

```markdown
## Iteration mission

<one or two sentences stating what this iteration set out to deliver>

## Work products created or updated

- [ ] Stakeholder needs (STK-NNN, ...)
- [ ] System requirements (REQ-NNN, ...)
- [ ] Architecture (parts, allocations, interfaces)
- [ ] Verification cases (VER-NNN, ...)
- [ ] Validation cases (VAL-NNN, ...)
- [ ] Documentation updates (project plan, traceability matrix, ...)

## Trace status

- All new requirements have `satisfy` links upward.
- All new requirements have `verify` links downward.
- All new stakeholder needs have at least one validation case.

## Phase gate status

- Current phase: <SR.x>
- Phase gate criteria: <met / not yet / N/A>

## Open issues for the next iteration

<bulleted list of items intentionally deferred to the next iteration>
```

### PR review

PR review is the formal handoff event. For a single-developer VSE,
self-review is acceptable but the PR mechanism is still load-bearing
because it triggers the CI gates (Section 5) and creates a reviewable
diff that future-you can use to understand what changed and why.

For a two-to-five person VSE, peer review on the PR satisfies the
intent of Douglass's handoff workflow without ceremony. The reviewer
is checking three things, in order:

1. Does the iteration mission match what the PR delivers?
2. Are the trace links closed (the CI workflow will catch this
   mechanically, but the reviewer should confirm the *meaning* is
   right, not just the form)?
3. Is the phase gate still satisfied (or does this iteration legitimately
   advance the phase)?

### Vee inside the microcycle

- **Left side (specification)**: the specification work that happens
  on the branch over the iteration window. New requirements,
  architectural elements, interface definitions, trade studies.
- **Right side (verification)**: the iteration verification that
  happens at PR time. The CI gates run, the reviewer walks the diff,
  and the trace matrix is regenerated. Defects found during PR review
  produce additional commits on the same branch.

### Anti-patterns at the microcycle scale

- Direct commits to `main`. Skips the microcycle gate entirely. The
  pre-commit hook still catches local trace gaps, but no PR review
  ever happens, so the iteration handoff is invisible.
- Long-running branches that bundle multiple iterations. Loses the
  one-handoff-per-iteration discipline. If an iteration runs long,
  the right move is usually to split it: merge what is finished, open
  a new branch for the rest.
- Skipping the PR description. The PR body is the iteration's record.
  An empty body is the same as no handoff workflow.

---

## 5. PR Enforcement Gates

The plugin ships two GitHub Actions workflow templates in
`templates/github/` that turn the trace and phase-gate checks into
blocking PR checks. They wrap the same scripts that run as local
hooks:

### `traceability-check.yml`

This workflow runs `hooks/pre-commit-traceability.sh` against the head
of every PR. The AMBSE recommendation is to run the trace check on
every PR, because every iteration handoff should be verified. The
workflow fails the PR if any requirement is missing a `satisfy` or
`verify` link.

### `phase-gate.yml`

This workflow runs `hooks/phase-gate-check.sh` against the value in
`.vse-phase`. It detects whether the PR advances the phase (compares
the value on the PR head to the value on `main`) and runs the
corresponding gate checklist. The workflow fails and the PR is
blocked from merging until the gate is satisfied.

Both workflows are intentionally thin wrappers around the bash scripts
in `hooks/`. Translating to GitLab CI is mechanical: invoke the same
scripts in a `.gitlab-ci.yml` job. Translating to Forgejo Actions or
Gitea Actions follows the same shape as the GitHub workflows. The
plugin does not currently ship these templates, but the underlying
scripts are host-agnostic.

### Why CI gates matter even for single-developer VSEs

A single developer working alone on `main` will have a clean local
hook history but no record of which iteration any given commit
belonged to. The PR mechanism is the cheapest way to recover that
record. Even in solo mode, opening a PR against `main` and merging it
yourself preserves the iteration boundary in git history, runs the CI
gates one more time on a known-good base, and leaves a reviewable diff
behind.

---

## 6. Macrocycle = Release Tag on Main

A macrocycle is the project length, or one major release. After a
sequence of merged iteration PRs has accumulated on `main`, and after
system-level V&V is complete (the Vee right-side at the macrocycle
scale), the project tags `main` with a semantic version:

```bash
git checkout main
git pull
git tag -a v1.0.0 -m "First production release"
git push --tags
```

The tag is the macrocycle delivery event. It is the input to whatever
release artefact pipeline the project uses: the `@document-export`
skill generates docx/pptx/pdf renderings of the work products at the
tagged commit, and the `templates/github/document-export.yml` workflow
can be wired to run on tag push.

### Vee inside the macrocycle

- **Left side (specification)**: the cumulative specification work
  done across all the merged iterations leading up to the tag.
- **Right side (verification)**: the formal system V&V that happens
  before the tag is created. System verification cases are executed,
  validation cases are walked through with the acquirer, the
  acceptance procedure is run.

### Pre-tag checklist

Before tagging:

1. The current `.vse-phase` is `SR.6`.
2. The phase gate checklist for SR.5 to SR.6 is satisfied.
3. All verification cases pass (the trace matrix should show
   green for every `verify` link).
4. All validation cases pass (every `STK-` need has a passing
   `VAL-` case).
5. The acquirer has signed the Product Acceptance Record.
6. The release artefacts are generated and stored.

This matches the existing SR.6 phase-gate checklist. The tag is the
point at which the checklist is enforced.

---

## 7. VSE-Specific Guidance

### Solo developer

Open the PR against `main`, self-review, and merge. The PR mechanism
runs the CI gates one more time and creates the iteration record in
git history. A solo VSE should still resist the temptation to commit
straight to `main`, because the CI gate is the only thing that will
catch a trace gap that the local hook missed.

### Two-to-five person team

PR review is peer review. One other team member reads the iteration
PR before merging. This satisfies the intent of Douglass's handoff
workflow without adding ceremony.

### Larger teams

Outside the scope of this plugin. ISO 29110 Basic Profile targets
single-team projects of fewer than 25 people, and the plugin is tuned
for that population. Larger organisations should consult INCOSE
guidance directly.

### Iteration cadence

Two-week iterations are a reasonable default for VSEs. Shorter
(one week) is appropriate when stakeholders are highly available
and the work is fine-grained. Longer (three or four weeks) is
appropriate for hardware-heavy iterations with longer lead times.
Record the iteration cadence in the project plan
(`docs/pm/project-plan.md`, Section 4).

### Naming the first iteration

`vse/iter-00-architecture-zero` by convention. This matches Douglass's
"Iteration 0" and "Architecture 0" terminology (Cookbook, Sections
1.4-1.5): the first iteration sets up the modelling environment, the
project backlog, and the skeleton architecture before any use case is
specified in detail.

---

## 8. Anti-Pattern Catalogue

The same anti-patterns appear across many AMBSE adoptions. Each one
breaks one of the gates that AMBSE depends on.

| Anti-pattern | What it breaks | Why it happens | Recovery |
|--------------|----------------|----------------|----------|
| Direct commit to `main` | Microcycle handoff gate | Habit, "this is just a tiny fix" | Revert and redo on a `vse/iter-NN` branch as a PR |
| `git commit --no-verify` | Nanocycle trace gate | Trace check feels "in the way" | Investigate why the trace was missing, then add the missing link or file a backlog item |
| Long branch bundling many iterations | Iteration discipline, PR-as-handoff | Iteration ran long, reluctance to split | Merge the finished part now and open a fresh branch for the rest |
| Empty PR description | Handoff workflow record | PR template went unused | Fill the template before merging. Ten minutes now saves an hour later |
| Tagging `main` with broken traces | Macrocycle V&V gate | Schedule pressure | Untag, fix, retag with a new version |
| Reopening settled requirements during construction (`SR.4`) | Phase discipline | Stakeholder feedback arrived late | File a Change Request (`@lifecycle-orchestrator` PM.2.2) and update the baseline through that route |

---

## 9. Cross-References

- `knowledge/ambse-agile-process.md` Section 3 for the formal
  definition of the three timeframes
- `knowledge/ambse-architecture.md` Section 6 for the handoff workflow
  in the architecture context
- `knowledge/ambse-requirements.md` Section 5 for the nanocycle
  requirements workflow
- `templates/github/traceability-check.yml` for the GitHub Actions
  trace gate
- `templates/github/phase-gate.yml` for the GitHub Actions phase gate
- `templates/github/pull-request-template.md` for the PR body template
- `hooks/pre-commit-traceability.sh` for the local trace check that
  also runs in CI
- `hooks/phase-gate-check.sh` for the local phase gate that also runs
  in CI
- `skills/lifecycle-orchestrator/SKILL.md` for the skill that uses
  this workflow as its operational model
