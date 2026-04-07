<!-- BEGIN VSE COMPANION (managed by project-setup) -->
# {{PROJECT_NAME}}

This project follows ISO/IEC 29110 (Basic Profile) for Very Small Entity (VSE)
systems engineering. All work is governed by the VSE Systems Engineering plugin.

## VSE-First Rule

When answering any question about this project:

1. Consult the VSE Systems Engineering plugin skills first
2. Check the current iteration state in `.vse-iteration.yml`
3. Apply iteration-appropriate guidance (the `vse-companion-overview`
   skill is the canonical lens, with iteration work routed by
   centre-of-gravity activity to specialised skills such as
   `iteration-orchestrator`, `needs-and-requirements`,
   `architecture-design`, and `verification-validation`)
4. Warn if the requested action touches a baselined artefact without a
   Change Request or conflicts with the iteration's declared centre of
   gravity

If the VSE plugin is not installed, follow the ISO 29110 process map below.

## AMBSE Workflow

This project uses hybrid AMBSE (Agile Model-Based Systems Engineering) per
Douglass (2021). AMBSE is the fixed VSE lifecycle for every project that uses
this plugin. AMBSE applies the Vee verification pattern at three timeframes:

- **Nanocycle** (30 minutes to 1 day): one model edit, one trace fix, one
  constraint added. The unit of git work is a commit on a feature branch.
  The pre-commit traceability hook runs at this scale.
- **Microcycle** (1 to 4 weeks): one iteration with a stated mission. The unit
  of git work is a feature branch named `vse/iter-NN[-short-desc]`, merged via
  pull request (or merge request, on non-GitHub hosts). The PR review is the
  formal handoff event Douglass describes (Cookbook, p. 61). CI workflows in
  `.github/workflows/` run the trace check and the advisory
  iteration-boundary check before the PR can merge.
- **Macrocycle** (project length): one major release. The unit of git work
  is a semantic version tag on `main`, created after formal system V&V is
  complete.

The Vee verification pattern is the inner shape of every cycle. Douglass
(Cookbook, p. 64) frames it directly: "a traditional V process is simply this
process cycle done once". AMBSE applies the Vee many times, at three scales,
with verification at every iteration boundary.

### Branch and PR conventions for this project

- All non-trivial work goes on a `vse/iter-NN[-short-desc]` branch.
- Each commit on the branch is one nanocycle and references the affected work
  product or use case in the commit message.
- Merging the branch via pull request is the microcycle handoff. The PR body
  states the iteration mission and trace status. See the PR template in
  `.github/PULL_REQUEST_TEMPLATE.md` if it exists, or
  `templates/github/pull-request-template.md` in the plugin.
- Trace gates: the `pre-commit-traceability` hook blocks local commits with
  broken traces. The `traceability-check` GitHub Actions workflow blocks PR
  merge with broken traces.
- Iteration-boundary check: the `iteration-boundary-check` script reports
  closure debt across every active centre of gravity. The
  `iteration-boundary` GitHub Actions workflow runs the same script on
  PRs that touch `.vse-iteration.yml` and reports as advisory (does not
  block). The hard closure gate lives at the macrocycle (release tag on
  `main`), not at the iteration boundary.

For the full mapping (anti-patterns, solo-developer guidance, host-agnostic
notes, the worked microcycle history example), see
`${CLAUDE_PLUGIN_ROOT}/knowledge/ambse-git-workflow.md` in the plugin or the
`@iteration-orchestrator` skill, which loads it at activation time.

## Current Iteration

Read `.vse-iteration.yml` in the project root to determine the active
iteration. At the start of every SE-related interaction, state:

- **Iteration**: the iteration number and mission
- **Status**: open, closing, or merged
- **Centre of gravity**: one or more ISO 29110 task identifiers governing
  which specialist skills apply inside the active microcycle
- **Next action**: what the engineer should work on next inside the
  iteration

Read the `.vse-journal.yml` file to understand what was done in the previous
session and what the engineer should work on next. If the file exists and has
entries, present a SESSION CONTINUITY block after the iteration information:

- **Last session**: when the previous session occurred
- **Summary**: what was accomplished
- **Pending**: next steps from the previous session
- **Open issues**: unresolved items needing attention

### Centre-of-Gravity Filtering

| Centre of gravity | Focus on | Deprioritise |
| ----------------- | -------- | ------------ |
| SR.1 Initiation | SEMP, data model, environment setup | Late delivery detail |
| SR.2 Requirements | Stakeholder needs, SMART criteria, elicitation | Detailed V&V tactics |
| SR.3 Architecture | Decomposition, interfaces, trade-offs | Detailed test case design |
| SR.4 Construction | Build/buy/reuse, component specs | Upstream requirements debates |
| SR.5 IVV | Verification methods, test derivation, trace checking | Re-opening baselines outside a Change Request |
| SR.6 Delivery | Acceptance, documentation, training, maintenance | All upstream activities |

Concurrent centres of gravity are normal: surface the focus row for every
centre listed in `current_iteration.centre_of_gravity`. If the engineer
asks about a topic outside the active centres of gravity, provide the
information but flag it: "Note: this relates to [activity], which is not
the current centre of gravity. Consider opening an iteration with this
activity as its centre of gravity, or handling the change via a Change
Request if it touches a baselined artefact."

## Source Processing Order

1. **ISO/IEC 29110** (process backbone): what activities to perform
2. **PHAS-EAI framework** (design rationale): why those activities work
3. **INCOSE SE Handbook** (best practices): how to execute, scaled for VSEs
4. **SysML 2.0 specification** (modelling language): machine-readable models

## Project Information

- **Project:** {{PROJECT_NAME}}
- **Acquirer:** {{ACQUIRER}}
- **Date created:** {{DATE}}
- **Author:** {{AUTHOR}}

## Project Structure

```
models/           SysML 2.0 model files (.sysml)
docs/pm/          Project Management work products
docs/sr/          System Definition and Realisation work products
TASKS.md          ISO 29110 task checklist
```

## Traceability Chain

```
Stakeholder Needs (STK-)
    | satisfy
System Requirements (REQ-)
    | satisfy
System Element Requirements (ELE-)
    | verify
Verification Cases (VER-)

Validation Cases (VAL-)
    | verify (back to stakeholder needs)
```

Every system requirement MUST trace upward to at least one stakeholder need
via a `satisfy` link. Every system requirement MUST trace downward to at
least one verification case via a `verify` link. Every stakeholder need
MUST have at least one validation case. Macrocycle release (tagging
`main`) MUST NOT proceed if trace gaps exist. Iteration-boundary closure
MAY proceed with explicit iteration-boundary closure debt carried onto
the next iteration's backlog.

## SysML 2.0 Conventions

- Package names: `PascalCase` (e.g., `SmartSensor`)
- Definition names: `PascalCase` (e.g., `part def TemperatureSensor`)
- Usage names: `camelCase` (e.g., `part tempSensor : TemperatureSensor`)
- Requirement IDs: `REQ-` prefix (e.g., `REQ-001`)
- Stakeholder need IDs: `STK-` prefix (e.g., `STK-001`)
- Element requirement IDs: `ELE-` prefix (e.g., `ELE-001`)
- Verification case IDs: `VER-` prefix (e.g., `VER-001`)
- Validation case IDs: `VAL-` prefix (e.g., `VAL-001`)
- All trace links use `satisfy` and `verify` keywords in SysML 2.0

### Trace Link Syntax

```sysml
// Upward: system requirement satisfies stakeholder need
requirement def MeasureTemperature :> SystemRequirement {
    doc /* The system shall measure temperature within +/- 0.5 C. */
    satisfy requirement StakeholderNeeds::MonitorTemperature;
}

// Downward: verification case verifies system requirement
verification def VerifyTempAccuracy {
    doc /* Verify temperature measurement accuracy. */
    verify requirement SystemRequirements::MeasureTemperature;
}
```

## Roles

This is a VSE project. One person may fill multiple roles. Document which
person holds which role in `docs/pm/project-plan.md`.

| Role | Abbr | Responsibility |
|------|------|----------------|
| Project Manager | PJM | Planning, monitoring, control, repository management |
| Systems Engineer | SYS | Requirements, architecture, V&V coordination |
| Designer | DES | Functional and physical design, interface definitions |
| Developer | DEV | Construction of software and hardware elements |
| IVV Engineer | IVV | Integration, verification, validation execution |
| Acquirer | ACQ | Customer acceptance, needs provision |
| Stakeholder | STK | Needs and concerns provision across lifecycle |
| Work Team | WT | All internal team members collectively |
| Supplier | SUP | External provider of system elements |

## ISO 29110 Process Map

### Project Management (PM)

| Activity | Objective |
|----------|-----------|
| PM.1 Project Planning | Establish plan, assign resources, obtain acquirer acceptance |
| PM.2 Plan Execution | Monitor progress, manage changes, conduct reviews |
| PM.3 Assessment and Control | Evaluate against plan, take corrective actions |
| PM.4 Closure | Formalise completion, baseline repository, execute disposal |

### System Definition and Realisation (SR)

| Activity | Objective |
|----------|-----------|
| SR.1 Initiation | Set up SEMP, data model, implementation environment |
| SR.2 Requirements | Elicit needs, derive system and element requirements |
| SR.3 Architecture | Design functional and physical architecture |
| SR.4 Construction | Build, buy, or reuse system elements |
| SR.5 IVV | Integrate, verify against requirements, validate against needs |
| SR.6 Delivery | Review product, prepare maintenance and training, deliver |

## Iteration-Boundary Closure Checklist

Before closing an iteration and merging its feature branch, verify:

- Work products required by the iteration's centre-of-gravity activities
  exist in `docs/` (the `iteration-boundary-check` script reports any
  missing items as advisory closure debt)
- All SysML trace links are complete for threads this iteration touched
  (the pre-commit hook checks this)
- The iteration-boundary closure items in the iteration backlog are
  satisfied or explicitly carried as `closure_debt` into the next
  iteration
- The Traceability Matrix in `docs/sr/traceability-matrix.md` is current

## Macrocycle Release Checklist

Before tagging a release on `main`, verify:

- All stakeholder needs, system requirements, and verification cases
  accumulated across the merged iterations trace cleanly end-to-end
- All `closure_debt` items from prior iterations have been resolved
- The acquirer has signed the Product Acceptance Record

## Writing Style

- UK English throughout (organisation, behaviour, modelling)
- Clear, precise, evidence-grounded language
- Plain language first, specialist terms introduced with explanation
- Cross-disciplinary audience assumed
<!-- END VSE COMPANION -->
