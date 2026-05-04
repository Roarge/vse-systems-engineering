---
title: "Verification and Validation Methods, Test Case Design"
slug: vv-methods
type: reference
layer: vv
tags: [vv, methods, inspection, demonstration, test, analysis, test-case]
sources:
  - citation: "INCOSE (2022). Guide to Verification and Validation, v1.0. Sections on Verification Methods, Validation Methods, and Test Case Design."
    raw: INCOSE_VV_Guide_v1.pdf
related:
  - vv-definitions
  - vv-planning
  - vv-reporting-and-vse-guidance
  - sysml2-case-kinds
  - sysml2-case-patterns
  - sysml2-systems-model-library
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [verification-validation]
---

# Verification and Validation Methods, Test Case Design

The four standard methods apply to both verification and
validation. For underlying definitions see [[vv-definitions]];
for planning that ties methods to requirements see
[[vv-planning]]. For SysML 2.0 verification-case syntax that
formalises these methods in the model, see [[sysml2-case-kinds]].

## Inspection

Visual examination to verify or validate construction features,
workmanship, dimension, or physical characteristics. Includes
simple measurements (length, weight) performed without special
laboratory or precision equipment.

**VSE applicability**: Lowest cost. Use for labelling, physical
assembly, packaging, cosmetic requirements, and simple
dimensional checks. Requires minimal equipment.

## Demonstration

A qualitative determination of properties or functional
characteristics, made through observation with or without test
equipment or instrumentation. Does not involve direct
quantitative measurement.

**VSE applicability**: Good for functional requirements ("the
system shall allow the operator to brew six cups"). Quick to
execute. Suitable for stakeholder walk-throughs and prototype
reviews.

## Test

Direct measurement of measurable characteristics, quantitatively
verified. Measurements are obtained using instrumentation or
special test equipment that is not an integral part of the test
article.

**VSE applicability**: Most rigorous but most expensive. Reserve
for critical performance parameters, safety requirements, and
regulatory compliance. Plan test infrastructure early (test
stands, instruments, calibration).

## Analysis

Engineering analyses, modelling and simulations, similarity
analyses, sampling analysis. May include assessment of records
(material certifications, past test data). Best choice when
test is not cost-effective, inspections and demonstrations are
inadequate, or test environments do not match operational
environments.

Two important subcategories:

- **Analogy or similarity**: Based on evidence of similar
  elements or experience with testing or analysis highly
  related to the element under test. Useful for OTS parts with
  known performance data.
- **Sampling**: Verification of characteristics on a sample
  drawn from a larger lot. More relevant to production
  verification than system verification.

**VSE applicability**: High value for small teams. Use models
and simulations to verify design before building. Similarity
analysis can leverage supplier data sheets for OTS components.
Reduces the number of physical tests needed.

## Method selection guidance for VSE

Choose the least expensive method that provides sufficient
confidence:

1. Inspection (cheapest, lowest confidence for complex
   requirements).
2. Demonstration (low cost, moderate confidence).
3. Analysis (moderate cost, can provide high confidence for
   well-understood physics).
4. Test (highest cost, highest confidence).

Combine methods where sensible. A single verification event
can cover multiple requirements. A single requirement may need
multiple methods at different lifecycle stages.

## Validation methods

Validation always asks: "Does this meet the stakeholder needs in
the intended operational environment, operated by the intended
users?"

### Needs and requirements validation

- **Interviews and site visits**: Confirm needs and requirements
  truly reflect stakeholder expectations. Do not rely solely on
  desk reviews.
- **Models and prototypes**: Show stakeholders early
  representations to validate intent before building.
- **Walkthroughs**: Small-group review of requirements against
  ConOps, use cases, and operational scenarios.

### Design validation

Occurs on the left side of the SE Vee, before the product is
built. Key questions:

- Will the SOI built per the design output specifications meet
  its intended purpose in its operational environment?
- Will the resulting SOI interact properly with external
  interfaces?
- Is this the right design?
- Are applicable industry, customer, and internal design
  standards being applied?

**VSE approach**: Conduct design reviews with customer or
end-user representatives present. Even a single informed review
with the right people can achieve both design verification and
design validation simultaneously.

### System validation

Occurs on the right side of the SE Vee with the realised
product. Key questions:

- Is this the right system?
- Does it work the way the users intended?
- Was the problem or opportunity addressed correctly?
- Is realisation of the system repeatable?
- Are the above still true when intended users operate the
  system?
- If an unintended user has access, is damage to the system or
  the environment prevented?

**VSE-scaled system validation approaches**:

- **Beta testing**: Release a pre-release version to
  representative users in the actual operating environment.
- **Acceptance demonstration**: Walk through operational
  scenarios with the customer at the development facility
  (Factory Acceptance Test, scaled down).
- **Operational evaluation**: Let intended users operate the
  system in its actual environment. The simplest and most
  meaningful form of validation.
- **Focus groups or limited runs**: For commercial products,
  produce limited quantities and solicit feedback before full
  release.

### Integrated testing (recommended for VSE)

Combine verification and validation activities in the same
event. Data collected during verification to confirm
requirements can simultaneously be analysed by the validation
perspective to confirm the needs are met. This saves
significant cost and schedule by avoiding separate campaigns.

## Test case design

Each design input requirement maps to one or more verification
instances. For each instance:

1. Identify the success criteria (what constitutes pass or fail,
   including tolerances).
2. Select the method (test, analysis, inspection, demonstration).
3. Define the procedure steps, conditions, and data to collect.
4. Identify required test equipment, facilities, and personnel.

### Requirements quality drives test quality

Requirements that are vague, unbounded, or lacking measurable
thresholds produce untestable verification activities. Examples
of non-verifiable statements to avoid:

- "The interface shall be user friendly."
- "The system should not slow down beyond acceptable use during
  peak loads."
- "The device should strive for a reliability of at least 99%
  uptime."
- "The transistor shall produce a circuit board with a
  bandwidth of 2 MHz." (no tolerance)

Each requirement must have a subject, a verb, a measurable
condition, and a threshold or range.

### Coverage criteria

- Every requirement must have at least one verification
  instance.
- Every need must have at least one validation instance.
- The VCRM and VaCRM matrices make gaps visible (see
  [[vv-planning]]).
- If a requirement needs more than five verification activities,
  it may be too vague or compound and should be decomposed.
- If a single verification activity covers a large number of
  requirements, that activity is high-risk (single point of
  failure) and deserves extra attention.

### Procedure development (scaled for VSE)

For each verification or validation event, define:

1. Preconditions (configuration, setup, equipment state).
2. Steps to execute (numbered, unambiguous).
3. Data to collect and record.
4. Success criteria for each step.
5. Actions on failure (stop, continue, note discrepancy).

For small teams, a simple checklist format often suffices. For
safety-critical procedures, conduct a tabletop walkthrough or
dry run before formal execution.

### Discrepancy handling

When a verification or validation activity does not pass:

- **Correct the deficiency**: Fix the design or implementation
  and re-test.
- **Request a waiver or concession**: Document the deviation,
  assess risk, and obtain approval from the customer or
  approving authority.
- **Change the requirement**: If the requirement was incorrect
  or over-specified, update it through the change management
  process.

Treat failures during development as opportunities. Discovering
and fixing a problem before delivery is far less costly than a
field failure.

## See also

- [[vv-definitions]] for the underlying definitions.
- [[vv-planning]] for VCRM-driven planning.
- [[vv-reporting-and-vse-guidance]] for execution records and
  SVCM.
- [[sysml2-case-kinds]] for the SysML 2.0 verification-case
  syntax that captures these methods in the model.
- [[sysml2-case-patterns]] for VSE-scale verification-case
  patterns.
- [[sysml2-systems-model-library]] for the `VerdictKind`
  enumeration that pass/fail/inconclusive/error verdicts use.
