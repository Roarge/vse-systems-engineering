---
name: change-request
description: Author and process Change Requests under PM.O3 (§10.4.2). Use when a baselined artefact (Project Plan, baselined story, baselined architecture, anything on .iso-config.yaml baselined_paths) is about to be modified, when /vse-cr is invoked, when the user says "open a CR", "change the Plan", "modify the baselined story", or when another skill routes here on detecting a baselined-path edit. Drafts the impact analysis (cost, schedule, technical, risk), opens the GitHub Issue with the change-request label, and tracks the lifecycle (submitted, evaluated, agreed, in implementation, done, rejected, postponed).
---

# Change Request

This skill is the smallest of the orchestration skills. It exists for one task: author a Change Request artefact in the §10.4.2 form and move it through the issue and PR lifecycle that ISO 29110 PM.O3 requires.

The Change Request artefact is the GitHub Issue thread. The implementation artefact is the PR thread. Both are preserved indefinitely as audit trail. This skill writes the issue, helps manage the lifecycle labels, and hands off to other skills for the implementing work. It does not perform the engineering change itself.

## When this skill triggers

The skill is loaded in three situations:

1. The engineer invokes `/vse-cr [optional title]` directly. The slash command at `commands/vse-cr.md` delegates here.
2. The engineer's prose maps to a CR action: "open a CR", "change the Plan", "modify the baselined story", "we need a Change Request for ...".
3. Another VSE skill routes the engineer here (typed as `@change-request`) after detecting an intended edit to a path on the `baselined_paths` list. The most common caller is the story orchestrator when it sees a baselined story under change.

## Inputs the skill expects

- The project's `.iso-config.yaml`, in particular `baselined_paths` and `change_request.issue_label`. Read it before deciding whether a CR is required.
- The artefact under change, given as a file path or as a clearly named work product (Project Plan, story ID, architecture component).
- The engineer's intent: a one-line description of the proposed change, plus any rationale already articulated in the surrounding conversation.

If any of the three is missing, ask once, then proceed with the best available information and flag the gap in the issue body.

## Workflow

### 1. Confirm the artefact is baselined

Read `.iso-config.yaml` and check the artefact's path against `baselined_paths`. If the artefact is not baselined:

- Surface a short note that no Change Request is required for unbaselined work under §10.4.2.
- Offer the engineer the option of recording the change rationale through an Architecture Decision Record (ADR) in `docs/decisions/<NNNN>-<short-title>.md` instead, per methodology §10.5.3.
- Stop the CR workflow once the engineer has chosen.

If the artefact is baselined, continue.

### 2. Elicit the proposed change in §10.4.2 vocabulary

Collect, with one question per missing field at most:

- **Title.** A short noun phrase, suitable as the GitHub Issue title.
- **Summary.** Two to four sentences naming what changes.
- **Rationale.** Why the change is needed. Plain language, evidence grounded.
- **Scope of edits.** Which files or model elements the change is expected to touch. Use repository paths.
- **Proposer.** Default to the current git identity. Override only if the engineer explicitly attributes the request to a stakeholder or acquirer.

### 3. Draft the impact analysis

The impact analysis is required by §10.4.2 and ISO 29110 PM.2.2. It covers four dimensions. Each one may be flagged as "negligible" with a one-sentence justification, rather than left blank.

| Dimension | What to assess |
|---|---|
| Cost | Effort hours, tooling cost, third-party dependencies that change. |
| Schedule | Release boundaries affected, milestones at risk, prerequisite work that must finish first. |
| Technical | Architectural reach, requirement traceability touched, V&V cases that must be re-run. |
| Risk | New risks introduced, existing risks revalued, mitigations that change owner or status. |

Render the impact analysis as a markdown block with one heading per dimension and a status line at the top (`Lifecycle: submitted`).

### 4. Open the GitHub Issue

Use `gh issue create` with:

- `--label change-request` (read the actual label name from `.iso-config.yaml change_request.issue_label`, fallback to `change-request`).
- `--title "<title from step 2>"`.
- `--body "<rendered impact analysis>"` containing the §10.4.2 fields, the impact analysis, and the lifecycle line set to `submitted`.

Capture the returned issue number and surface the commit-message form the engineer must use for any subsequent baselined-path edits: `<type>: <subject> (CR #<n>)` per §4.2 of the hooks guide.

### 5. Track the lifecycle

Carry the CR through the §10.4.2 states by updating the issue labels and the lifecycle line in the issue body:

| State | Trigger | Action |
|---|---|---|
| submitted | Issue opened | Label `change-request`, body line `Lifecycle: submitted`. |
| evaluated | PJM (or designated reviewer) posts cost, schedule, technical assessment | Append the assessment as an issue comment. Update body line to `Lifecycle: evaluated`. |
| agreed | Acquirer or PJM accepts (see Refusals) | Update body line to `Lifecycle: agreed`. Optionally route to `/vse-story` for the implementation branch. |
| in implementation | PR opened against the agreed scope | Update body line to `Lifecycle: in implementation`, link the PR. |
| done | PR merged | Close the issue with a comment referencing the merge commit. Update body line to `Lifecycle: done`. |
| rejected | Decision not to proceed | Close the issue with a rationale comment. Update body line to `Lifecycle: rejected`. |
| postponed | Decision to revisit later | Add label `postponed`, update body line to `Lifecycle: postponed`. Surface again at the next release boundary. |

The Issue thread, including all comments, is the audit trail. Never edit a previous comment. Append new comments instead.

### 6. Optional implementation handoff

Once the lifecycle reaches `agreed`, offer the engineer a handoff to `/vse-story` so the implementing story branch is opened with the CR number already in scope. Pass the issue number through so the new story commits inherit the `(CR #<n>)` suffix.

## Refusals

The skill refuses, without exception, in these cases:

- The engineer asks the skill to bypass the CR workflow on a baselined artefact (for example, by suggesting `--no-verify` or by inviting the agent to "just edit it"). Surface the §10.4.2 obligation and the §4.2 commit-message form, and stop.
- The engineer asks the skill to mark a CR `agreed` when the artefact is on the §10.8 baselined paths and no Acquirer git identity has signed off in the issue thread. Require the Acquirer comment first, then proceed.

In both cases, the skill names the obligation, points at the relevant section, and waits for the engineer to take the right preceding action.

## Hand-offs

- `/vse-story` for opening the implementation branch once `agreed` is reached.
- `@release-orchestrator` when the change affects release scope (release notes, version planning, baseline integrity at the next release tag).
- `@project-plan` when the change is a Project Plan revision and the implementing branch is a Plan-revision PR rather than a story branch.

## Outputs

- A GitHub Issue with the `change-request` label, lifecycle line in the body, and the §10.4.2 impact analysis rendered as the issue body.
- The impact-analysis markdown block, returned to the engineer for review before the issue is opened.
- Optionally, a follow-up story branch and PR opened by `/vse-story` once the lifecycle reaches `agreed`.

`!cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/change-request.md`
