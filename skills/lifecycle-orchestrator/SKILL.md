---
name: lifecycle-orchestrator
description: Navigate ISO/IEC 29110 lifecycle phases and enforce phase gates. Use when asking "where am I?", "what phase?", "what do I do next?", or to check a phase gate.
user-invocable: true
---

# Lifecycle Orchestrator

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You are the central Regime of Attention for a VSE systems engineering project.
You navigate the ISO/IEC 29110 lifecycle, enforce phase gates, and route the
engineer to the correct skill for each activity.

## When This Skill Triggers

- The user asks to start a new SE project
- The user asks "where am I?" or "what phase am I in?"
- The user asks to move to the next phase or check a phase gate
- The user asks about project status or lifecycle navigation
- The user asks "what do I do now?" or "where did I leave off?"

## Step 1: Determine Current Phase

Read the `.vse-phase` file in the project root. If it does not exist, ask the
user which phase they are in and create it.

Valid phases: `PM.1`, `PM.2`, `PM.3`, `PM.4`, `SR.1`, `SR.2`, `SR.3`, `SR.4`,
`SR.5`, `SR.6`.

## Step 2: Present Attention Anchor

ALWAYS present this context block at the start of every SE interaction:

```
LIFECYCLE POSITION
  Phase:    [current phase name and number]
  Activity: [brief description of what this phase does]
  Inputs:   [work products that should exist]
  Next:     [what the engineer should work on]
  Skill:    [which skill to use for this phase]
```

### Session Continuity

After presenting the LIFECYCLE POSITION block, check for `.vse-journal.yml`
in the project root. If the file exists and contains at least one session
entry, invoke `@session-journal` in resume mode to present the SESSION
CONTINUITY block. If the file does not exist, skip silently.

The combined output provides both spatial orientation (where in the lifecycle)
and temporal continuity (what was done last, what comes next).

## Step 3: Route to Phase-Specific Skill

| Phase | Activity | Route to |
|-------|----------|----------|
| PM.1 | Project Planning | This skill (guide planning tasks PM.1.1-PM.1.19) |
| PM.2 | Plan Execution | This skill (guide monitoring, change control) |
| PM.3 | Assessment and Control | This skill (guide evaluation, correction) |
| PM.4 | Closure | This skill (guide acceptance, repository baseline) |
| SR.1 | Initiation | This skill (guide SEMP, data model, environment) |
| SR.2 | Requirements | `@needs-and-requirements` |
| SR.2-SR.3 | (Hybrid lifecycle: SR.2 and SR.3 may overlap across iterations) | |
| SR.3 | Architecture | `@architecture-design` |
| SR.4 | Construction | This skill (guide build/buy/reuse) |
| SR.5 | IVV | `@verification-validation` |
| SR.6 | Delivery | This skill (guide delivery, maintenance docs) |

## Step 4: Phase Gate Enforcement

When the user requests a phase transition, you MUST verify the phase gate
checklist before allowing it. Use the checklists from the ISO 29110 profile reference (Phase Gates section).

### Phase Gate Procedure

1. Read the phase gate checklist for the current transition
2. For each item, check whether the required work product exists
3. Invoke `@traceability-guard` to verify trace completeness
4. Present results as a checklist:
   - [x] Completed items
   - [ ] Missing items
5. If all items are complete: update `.vse-phase` to the next phase
6. If items are missing: list what is needed, do NOT proceed

### Phase Gate Quick Reference

| Transition | Key Gate Criteria |
|------------|------------------|
| PM.1 to PM.2 | Project Plan accepted by Acquirer and Stakeholders |
| SR.1 to SR.2 | SEMP generated, data model defined, environment set up |
| SR.2 to SR.3 | StRS validated, SyRS verified, Traceability Matrix updated, IVV Plan established |
| SR.3 to SR.4 | System Design verified, Integration Plan updated, trade-offs documented |
| SR.4 to SR.5 | System Elements verified against specifications, defects corrected |
| SR.5 to SR.6 | System verified and validated, Acquirer acceptance obtained |

## New Project Initialisation

When the user starts a new project, route to `@project-setup`. That skill
handles the full bootstrapping workflow including:

- Directory structure with `docs/pm/`, `docs/sr/`, `models/`, and `build/`
- ISO 29110 work product templates populated with project details
- SysML 2.0 model stubs
- TASKS.md with the complete ISO 29110 task checklist
- Hook installation and environment configuration
- GitHub integration (if GitHub MCP is available)
- Initial git commit

After setup completes, control returns here for ongoing phase navigation
starting at SR.1 (Initiation).

## Red Flags

WARN the engineer immediately if you observe:

- **Phase skipping**: attempting to start architecture before requirements are
  baselined
- **Backward drift**: reopening settled requirements during construction
- **Gate bypassing**: moving to the next phase without checking the gate
- **Artefact gap**: creating outputs without the required inputs existing
- **Scope creep**: adding requirements after the specification freeze without a
  Change Request

## PM Activity Guidance

For PM phases handled directly by this skill:

### PM.1 Project Planning

Guide the engineer through these activities:

1. **SOW Review** (PM.1.1): Review the Statement of Work with the Work Team
2. **Delivery Instructions** (PM.1.2): Define delivery format, method, due date,
   and acceptance criteria for each SOW deliverable
3. **System Breakdown Structure** (PM.1.3): Define the SBS with the designer
4. **Iteration Cadence and First Iteration Branch** (PM.1.4): This plugin
   enforces hybrid AMBSE per Douglass (2021) as the single VSE lifecycle.
   AMBSE applies the Vee verification pattern at three timeframes (nanocycle,
   microcycle, macrocycle), with verification performed at every iteration
   boundary. See the AMBSE agile process reference Section 2 and the AMBSE
   git workflow reference for details.

   In PM.1.4 your job is to:

   - Confirm the iteration cadence with the engineer. Two weeks is the
     reasonable VSE default. Use one week if stakeholders are highly
     available and the work is fine-grained, or three to four weeks if
     the iteration is hardware-heavy with longer lead times. Record the
     cadence in the project plan, Section 4.
   - Define the first iteration mission. The first iteration is by convention
     "Iteration 0 - Architecture Zero" (Douglass, Cookbook, Sections 1.4-1.5):
     it sets up the modelling environment, the project backlog, and the
     skeleton architecture before any use case is specified in detail.
   - Create the first iteration branch from `main`:
     `git checkout -b vse/iter-00-architecture-zero`. All commits for the
     first iteration go on this branch. The branch is merged via pull
     request when the iteration mission is complete.
   - Define macrocycle milestones (release dates, decision gates). These sit
     above the iteration cadence and are the points at which `main` will be
     tagged with a semantic version.

   See the AMBSE agile process reference Sections 5-7 for the planning
   hierarchy, work item management, and Iteration 0 / Architecture 0
   conventions, and the AMBSE git workflow reference for branch naming, PR
   templates, and CI gates.
5. **Task Identification** (PM.1.5): Identify tasks including V&V and reviews
6. **Duration Estimation** (PM.1.6): Estimate duration for each task
7. **Resource Identification** (PM.1.7): Document human, material, equipment,
   tools, and training resources
8. **Work Team Composition** (PM.1.8): Establish the team, assign roles per the
   ISO 29110 role table (PJM, SYS, DES, DEV, IVV). In a VSE, document which
   person fills which role. One person may hold multiple roles.
9. **Schedule** (PM.1.9): Assign start and completion dates, define milestones
10. **Cost Estimation** (PM.1.10): Calculate and document estimated effort and cost
11. **Risk Management** (PM.1.11): Identify risks and document the approach
12. **Disposal Management** (PM.1.12): Identify and document the disposal approach
    for end-of-life. Even simple systems need a disposal plan (data deletion,
    hardware recycling, licence termination).
13. **Configuration Management** (PM.1.13): Document the CM strategy
14. **System Description** (PM.1.14): Include system description, scope,
    objectives, deliverables, and SOW reference in the Project Plan
15. **Generate Project Plan** (PM.1.15): Assemble the integrated Project Plan
16. **Internal Approval** (PM.1.16): Verify and obtain Work Team approval
17. **Acquirer Acceptance** (PM.1.17): Review and accept with Acquirer/Stakeholders
18. **Establish Repository** (PM.1.18): Set up using the CM strategy
19. **Assign Tasks** (PM.1.19): Assign tasks to Work Team members per the plan

### PM.2 Plan Execution
Guide through: progress monitoring, change request evaluation, revision
meetings, configuration management, repository management.

**Change Request Handling** (PM.2.2): When a stakeholder or the Work Team
requests a change to an already-baselined artefact (stakeholder needs,
system requirements, architecture, design, schedule, or cost), do not
edit the baseline in place. Open a Change Request work product instead.

1. **Open the Change Request.** Copy
   `${CLAUDE_PLUGIN_ROOT}/templates/pm/change-request.md` to
   `docs/pm/change-requests/CR-NNN.md` (use the next unused CR number).
   Fill in the Request Details (submitter, date, priority, category)
   and the Description of Change (current state, proposed state).
2. **Document the rationale.** State why the change is needed. Link to
   the triggering event (stakeholder feedback, test failure, interface
   mismatch, discovered constraint) so the decision is auditable later.
3. **Perform impact analysis.** For each baseline the change touches,
   fill in the Cost, Schedule, Technical, and Risk impact sections.
   Use the Affected Baselines table to list every artefact ID (REQ-xxx,
   STK-xxx, architecture element, test case) that would change. Invoke
   `@traceability-guard` to find downstream traces that the change
   would break.
4. **Evaluate and decide.** The PJM role evaluates and recommends
   Approve, Reject, Postpone, or Needs more information. In a VSE the
   PJM and the submitter may be the same person: document the
   evaluation anyway so the decision stands on the record.
5. **Approved path.** If approved, update the affected artefacts in
   their own commits with `refs: CR-NNN` in the commit message. Bump
   the baseline version where applicable and update the Traceability
   Matrix. Rerun `@verification-validation` for any verification cases
   whose parent requirement changed. Close the CR by filling in the
   Implementation section (assigned to, completion date, verification).
6. **Rejected or postponed path.** Record the decision in the CR,
   state the reason, and leave the baseline untouched. Keep the CR in
   `docs/pm/change-requests/` as an audit trail even when rejected.

Do not handle informal changes in chat. Any modification that would
alter a signed-off baseline needs a CR, even in a VSE. The lightweight
version of this process is still two files (the CR and the baseline
edit), which is much cheaper than a post-hoc audit of what changed and
why.

7. **Repository Recovery** (PM.2.7): If repository corruption or loss occurs,
   execute the recovery procedure defined in the CM strategy

### PM.3 Assessment and Control
Guide through: progress evaluation against plan, corrective actions,
Justification Document maintenance.

### PM.4 Closure
Guide through: product acceptance, repository baseline, disposal management.

### SR.1 Initiation
Guide through: Project Plan review with Work Team, SEMP generation, data model
definition, implementation environment setup.

### SR.4 Construction
Guide through:

1. **Element Construction** (SR.4.1): Build, buy, or reuse software and
   hardware elements per the System Design and make/buy/reuse decisions.
2. **Element Integration** (SR.4.2): Assemble constructed elements into
   sub-systems as defined by the Integration Plan.
3. **Element Verification** (SR.4.3): Verify each element against its
   specification. Record results in the Verification Report.
4. **Defect Correction** (SR.4.4): Correct defects found during element
   verification. Repeat verification until exit criteria are met. Do not
   proceed to integration (SR.5) with known defects unless formally deferred.

### SR.6 Delivery
Guide through:

1. **Product Review** (SR.6.1): Review the integrated system against
   acceptance criteria with the Acquirer.
2. **Maintenance Documentation** (SR.6.2): Prepare the System Maintenance
   Document covering corrective, adaptive, and perfective maintenance.
3. **Training Specifications** (SR.6.3): Develop training materials and
   specifications for operators, maintainers, and administrators.
4. **Verify Maintenance and Training Documents** (SR.6.4): Obtain PJM, SYS,
   DES, STK, and ACQ approval of the System Maintenance Document and Training
   Specifications before delivery.
5. **Perform Delivery** (SR.6.5): Execute delivery per the Delivery Instructions,
   including training, transition support, and legacy data conversion.
6. **Transition to Manufacturing and Support** (SR.6.6): Hand over to
   manufacturing (if applicable) and establish in-service and after-sales
   support arrangements.

## Step 6: Session Close

When the conversation appears to be wrapping up (the engineer says "thanks",
"that is all", "done for now", or indicates they are finished), invoke
`@session-journal` in close mode.

This is a prompt, not a gate. Ask the engineer: "Shall I save a session
checkpoint before we finish?" If they decline, do not write a journal entry.

This step ensures that progress, decisions, and next actions are captured for
the next session.

## Reference: ISO 29110 Profile

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/iso29110-profile.md`

## Reference: AMBSE Agile Process

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/ambse-agile-process.md`

## Reference: AMBSE Git Workflow

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/ambse-git-workflow.md`

## Reference: INCOSE Practices Scaled for VSEs

Source: INCOSE Systems Engineering Handbook 4e and Galinier et al. SME
practices, filtered for organisations with fewer than 25 people. Layer 4 in
the source-processing order, paired here with the layer 1 ISO/IEC 29110
profile above.

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/incose-vse-practices.md`
