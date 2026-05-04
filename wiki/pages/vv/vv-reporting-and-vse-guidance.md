---
title: "V&V Reporting, VSE Guidance, and AMBSE Continuous Verification"
slug: vv-reporting-and-vse-guidance
type: process
layer: vv
tags: [vv, svcm, reporting, ambse, nanocycle, microcycle, macrocycle, vse]
sources:
  - citation: "INCOSE (2022). Guide to Verification and Validation, v1.0. Sections on Reporting and VSE Guidance."
    raw: INCOSE_VV_Guide_v1.pdf
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Elsevier. Continuous-verification timeframe definitions."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
related:
  - vv-definitions
  - vv-planning
  - vv-methods
  - sysml2-case-kinds
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [verification-validation]
---

# V&V Reporting, VSE Guidance, and AMBSE Continuous Verification

This page covers the executed surface of V&V (records, the
SVCM, approval packages), VSE-specific guidance (role
consolidation, OTS verification), and the AMBSE continuous
verification timeframes that supplement phase-gate planning. For
the planning surface, see [[vv-planning]]; for methods, see
[[vv-methods]].

## Execution records

Every verification or validation activity produces an execution
record documenting:

- The requirement or need being addressed.
- The method and procedure used.
- The data collected.
- The result (pass, fail, pass with concession).
- The evidence location (pointer to test report, analysis
  document, inspection record).

## System Verification Compliance Matrix (SVCM)

The completed version of the VCRM. Each row shows:

| Req. ID | Requirement | Method | Success criteria | Event | Result | Evidence |
|---|---|---|---|---|---|---|

For a VSE, this is the primary deliverable proving the system
meets its requirements. It can be a spreadsheet. The SVCM
serves as the pointer to all compliance evidence and allows
quick assessment of verification status.

## System Verification Compliance Summary Matrix (SVCSM)

A simplified roll-up for the customer or approving authority:

| ID | Compliance | Evidence |
|---|---|---|

Shows pass/fail and a pointer to evidence. Useful for a quick
executive overview.

## System Validation Compliance Matrix (SVaCM)

Same as the SVCM but maps needs instead of requirements and
tracks validation evidence. For a VSE, these can be combined
into a single matrix with a column distinguishing verification
from validation instances.

## Approval package

The collection of evidence submitted for acceptance. For a
VSE, this typically includes:

1. Completed SVCM (or combined verification/validation matrix).
2. Any test reports, analysis documents, and inspection
   records.
3. List of waivers, deviations, and non-compliances with
   dispositions.
4. Traceability showing each need maps to requirements, and
   each requirement maps to verification evidence.

## Metrics (keep minimal for VSE)

Collect only metrics that drive decisions:

- Percentage of requirements verified (progress tracking).
- Percentage of needs validated.
- Number of open discrepancies and waivers.
- Number of TBDs or TBRs remaining in the requirement set.

Do not collect metrics that will not be used. Unused data
collection is waste that erodes team morale.

## VSE-specific guidance

### Role consolidation

In a VSE, one person often fills multiple roles: lead systems
engineer, verification engineer, test engineer, and
requirements engineer. The guide acknowledges this is common
and acceptable. The critical practice is to ensure that
verification and validation planning still occurs early, even
if the same person executes everything.

### Early V&V on the left side of the Vee

This is where VSEs gain the most leverage. Performing design
verification and design validation **before building anything**
(through models, simulations, prototypes, and desk reviews)
catches defects when they are cheapest to fix. The guide
strongly recommends this for all organisations but it is
especially valuable for resource-constrained teams.

### OTS and supplier parts

For OTS components, three verification questions apply:

1. Does the part truly meet its stated data sheet
   specifications?
2. Does the data sheet align with the design input requirements
   and design output specifications?
3. Is it the right part (will the SOI pass system verification
   and validation with this part)?

For a VSE, accepting vendor verification data for low-risk,
non-safety items is appropriate. For high-priority,
safety-critical, or security-sensitive requirements, conduct
independent verification.

## Continuous verification timeframes (AMBSE)

Traditional V&V concentrates verification effort at phase
gates and testing stages. Agile model-based SE (Douglass,
2016) introduces three verification timeframes that distribute
quality assurance throughout the project. The three timeframes
are the **primary** quality assurance mechanism in this plugin.
Iteration-boundary closure checks and the macrocycle closure
check verify that the continuous V&V evidence has accumulated
at the points where accumulated closure matters. Reading the
closure checks as the primary mechanism and the continuous V&V
as a supplement produces waterfall behaviour and is the
misreading this guide explicitly rejects.

### Nanocycle (30 minutes to 1 day)

Model-level checks performed as engineering data is created:

- SySiDE syntax validation on every save.
- Constraint evaluation and type checking.
- Traceability completeness check (`@traceability-guard`
  hook).
- Brief peer review or LLM-assisted model review.
- Unit-level model verification (one requirement, one action,
  one part).

Maps to VCRM method: inspection, analysis (automated).

### Microcycle (1 to 4 weeks, one iteration)

Iteration-level verification at the end of each iteration:

- Integration verification: combine model files and check
  cross-package consistency.
- Iteration acceptance: verify that the iteration mission has
  been achieved.
- Stakeholder walkthrough of iteration deliverables.
- Iteration retrospective with metrics review.

Maps to VCRM methods: inspection (peer review), demonstration
(walkthrough).

### Macrocycle (project length)

System-level V&V at the end of the project:

- Full system verification against all requirements.
- Validation against stakeholder needs in the operational
  environment.
- Formal acceptance testing.

Maps to VCRM methods: test, demonstration, analysis.

## Configuration management

Configuration management is in force from the first commit on
the first iteration branch. There is no point "before V&V
begins" because V&V runs continuously from the nanocycle
onward. For a VSE, configuration management can be as simple as
version-controlled files and a change log. Any change to a
baselined artefact, at any iteration, must be assessed via a
Change Request for impact on requirements already verified or
validated.

## What to keep

Store and maintain:

- Needs and requirements (with attributes including
  verification status).
- Verification and validation matrices (VCRM, SVCM).
- Execution records and evidence.
- Waivers and deviation dispositions.
- Traceability records.

These artifacts protect the organisation if field failures
occur, customers change, or regulatory audits are conducted.
Use a version-controlled repository (git, shared drive with
backup).

## See also

- [[vv-definitions]] for verification-versus-validation, levels
  of application, and the VSE terminology.
- [[vv-planning]] for the VCRM, success criteria, and
  risk-driven strategy.
- [[vv-methods]] for inspection, demonstration, test, and
  analysis methods plus test-case design.
- [[sysml2-case-kinds]] for the SysML 2.0 verification-case
  construct that records each VCRM/SVCM row in the model.
