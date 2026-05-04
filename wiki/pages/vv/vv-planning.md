---
title: "V&V Planning, Success Criteria, and the VCRM"
slug: vv-planning
type: process
layer: vv
tags: [vv, planning, vcrm, success-criteria, risk-driven, mivv]
sources:
  - citation: "INCOSE (2022). Guide to Verification and Validation, v1.0. Section on V and V Planning."
    raw: INCOSE_VV_Guide_v1.pdf
related:
  - vv-definitions
  - vv-methods
  - vv-reporting-and-vse-guidance
  - sysml2-syntax-requirements-and-cases
  - sysml2-cases-overview
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [verification-validation]
---

# V&V Planning, Success Criteria, and the VCRM

For the underlying definitions, see [[vv-definitions]]. For
methods and validation techniques, see [[vv-methods]]. For
reporting and AMBSE timeframes, see
[[vv-reporting-and-vse-guidance]].

## When to start

Planning for verification and validation begins at the **start
of the project**, concurrently with lifecycle concepts and
needs definition. It is not a right-side-of-the-Vee activity
only. Early planning reduces cost overruns and schedule delays.

## VSE-scaled planning approach

For a small team, collapse the formal MIVV (Master Integration,
Verification, and Validation) plan and SIVV (System Integration,
Verification, and Validation) plan into a single lightweight
document or a section within the project SEMP. The plan should
cover:

1. **Success criteria** for each need and requirement (what does
   "pass" look like?).
2. **Method** for each need and requirement (test, analysis,
   inspection, or demonstration).
3. **Strategy** (single-level or multi-level, risk-driven
   prioritisation).
4. **Responsible person** (in a VSE, likely one person wearing
   multiple hats).
5. **Planned event or timing** (when in the lifecycle will each
   activity occur).

## Define success criteria first

Each requirement must be written so that objective evidence can
be obtained to verify or validate it. Vague statements ("user
friendly", "should not slow down beyond acceptable use") are
not verifiable. Requirements need specific, measurable
thresholds with tolerances.

Success criteria are driven by five sources:

1. The need.
2. The design input requirement.
3. The design output specification.
4. Organisational design guidelines.
5. Acceptance, qualification, or certification requirements.

For SysML 2.0 requirement syntax that ensures verifiability
(SMART criteria, `assume`/`require`, satisfy and verify links),
see [[sysml2-syntax-requirements-and-cases]].

## Risk-driven strategy (essential for VSE)

No small team can verify and validate every requirement to the
deepest possible extent. Use a risk-based approach to determine
depth of effort:

- **Priority**: How important is this requirement to
  stakeholders? (High / Medium / Low)
- **Criticality**: Is this essential for the system to fulfil
  its intended use? (Essential / Not essential)
- **Risk of non-compliance**: What happens if this requirement
  is not met?

Five risk categories to consider:

1. Risk to the customer if a requirement is not implemented
   (especially health and safety).
2. Risk that verified system still does not meet needs in
   operation (validation gap).
3. Risk to cost, schedule, and technical execution of
   verification activities themselves.
4. Risk of programmatic cuts forcing reduced verification scope.
5. Risk to intended users from unmet quality, safety, or
   security requirements.

If a demonstration of functionality can confirm the system
meets a need, an instrumented test may be unnecessarily costly.
Conversely, do not cut high-risk tests simply because they are
expensive.

## Verification and Validation Cross Reference Matrix (VCRM)

The primary planning artifact. For a VSE, this can be a simple
spreadsheet with columns:

| Req. ID | Requirement text | Method | Success criteria | Planned event | Status |
|---|---|---|---|---|---|

This matrix ensures every requirement has a planned
verification or validation activity. It also reveals
requirements that need too many activities (possibly too vague
or complex) and activities that cover too many requirements
(single point of failure).

A **Validation Cross Reference Matrix (VaCRM)** follows the same
structure but maps needs instead of requirements and tracks
validation events.

In a SysML 2.0 model, a verification case carries its
`subject`, an `objective` containing one or more `verify`
clauses, and a method metadata annotation. The VCRM becomes a
view (Grid View) over the verification-case set in
`{{sc}}_Verification`. See [[sysml2-cases-overview]].

## See also

- [[vv-definitions]] for the underlying definitions.
- [[vv-methods]] for selecting inspection, demonstration, test,
  or analysis as the planned method.
- [[vv-reporting-and-vse-guidance]] for the SVCM (the executed
  version of the VCRM) and for AMBSE continuous-verification
  timeframes that supplement phase-gate planning.
- [[sysml2-syntax-requirements-and-cases]] for the SysML 2.0
  syntax that operationalises requirement-level verifiability.
- [[sysml2-cases-overview]] for the verification-case construct.
