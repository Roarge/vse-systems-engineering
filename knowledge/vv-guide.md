# Verification and Validation Guide (VSE-scaled)

Source: INCOSE Guide to Verification and Validation, v1.0, May 2022 (INCOSE-TP-2021-004-01).
Scaled for Very Small Entities (1-3 people doing SE) per ISO/IEC 29110.

---

## Definitions

### Verification
Confirmation and provision of objective evidence that an engineering element:
1. Has been produced by an acceptable transformation.
2. Meets its requirements (context dependent).
3. Meets the rules and characteristics defined for the organisation's best practices and guidelines.

Core question: "Are we designing and building the product right?"

Verification checks two things at every lifecycle stage:
- Artifacts against their success criteria (needs against writing standards, design against requirements, built system against design output specifications).
- Each stage of development against organisational guidelines, best practices, procedures, and work instructions.

### Validation
Confirmation and provision of objective evidence that an engineering element will result or has resulted in a system that meets its intended use in its intended operational environment.

Core question: "Have we designed and built the right product?"

Validation compares requirements, design, system elements, subsystems, and the integrated system against stakeholder needs at the applicable architecture level. The "stakeholder" for lower-level parts may be the higher-level system entity within the same organisation.

### Key distinction
Verification addresses the risk of building the wrong thing technically (not meeting stated requirements). Validation addresses the risk that a perfectly verified system still fails to deliver value to the customer. A system can pass all verification yet fail validation (the "perfectly square wheel" problem).

### Levels of application
Verification and validation apply at four levels across the lifecycle:
1. **Needs**: Verification checks well-formedness. Validation checks whether needs capture stakeholder intent.
2. **Requirements**: Verification checks quality rules. Validation checks whether requirements correctly address needs.
3. **Design (output specifications)**: Verification checks the design against requirements. Validation checks the design will yield a system meeting needs in the operational environment.
4. **System (realised product)**: Verification checks the built system against requirements. Validation confirms it works for intended users in the intended environment.

### Terminology for VSE context
- **System of Interest (SOI)**: The product, system, or element being developed, verified, validated, and delivered.
- **Design input requirements**: What are commonly called "system requirements". Conditions the realised system must satisfy.
- **Design output specifications**: Drawings, manufacturing specs, production guides. The "build-to" package.
- **Success criteria**: The measurable threshold for pass/fail of each verification or validation instance.

---

## V and V Planning

### When to start
Planning for verification and validation begins at the start of the project, concurrently with lifecycle concepts and needs definition. It is not a right-side-of-the-Vee activity only. Early planning reduces cost overruns and schedule delays.

### VSE-scaled planning approach
For a small team, collapse the formal MIVV (Master Integration, Verification, and Validation) plan and SIVV (System Integration, Verification, and Validation) plan into a single lightweight document or a section within the project SEMP. The plan should cover:

1. **Success criteria** for each need and requirement (what does "pass" look like?).
2. **Method** for each need and requirement (test, analysis, inspection, or demonstration).
3. **Strategy** (single-level or multi-level, risk-driven prioritisation).
4. **Responsible person** (in a VSE, likely one person wearing multiple hats).
5. **Planned event or timing** (when in the lifecycle will each activity occur).

### Define success criteria first
Each requirement must be written so that objective evidence can be obtained to verify or validate it. Vague statements ("user friendly", "should not slow down beyond acceptable use") are not verifiable. Requirements need specific, measurable thresholds with tolerances.

Success criteria are driven by five sources:
1. The need.
2. The design input requirement.
3. The design output specification.
4. Organisational design guidelines.
5. Acceptance, qualification, or certification requirements.

### Risk-driven strategy (essential for VSE)
No small team can verify and validate every requirement to the deepest possible extent. Use a risk-based approach to determine depth of effort:

- **Priority**: How important is this requirement to stakeholders? (High / Medium / Low)
- **Criticality**: Is this essential for the system to fulfil its intended use? (Essential / Not essential)
- **Risk of non-compliance**: What happens if this requirement is not met?

Five risk categories to consider:
1. Risk to the customer if a requirement is not implemented (especially health and safety).
2. Risk that verified system still does not meet needs in operation (validation gap).
3. Risk to cost, schedule, and technical execution of verification activities themselves.
4. Risk of programmatic cuts forcing reduced verification scope.
5. Risk to intended users from unmet quality, safety, or security requirements.

If a demonstration of functionality can confirm the system meets a need, an instrumented test may be unnecessarily costly. Conversely, do not cut high-risk tests simply because they are expensive.

### Verification and Validation Cross Reference Matrix (VCRM)
The primary planning artifact. For a VSE, this can be a simple spreadsheet with columns:

| Req. ID | Requirement text | Method | Success criteria | Planned event | Status |
|---------|-----------------|--------|-----------------|---------------|--------|

This matrix ensures every requirement has a planned verification or validation activity. It also reveals requirements that need too many activities (possibly too vague or complex) and activities that cover too many requirements (single point of failure).

A Validation Cross Reference Matrix (VaCRM) follows the same structure but maps needs instead of requirements and tracks validation events.

---

## Verification Methods

The INCOSE SE Handbook defines four primary methods. All can be used for both verification and validation.

### Inspection
Visual examination to verify or validate construction features, workmanship, dimension, or physical characteristics. Includes simple measurements (length, weight) performed without special laboratory or precision equipment.

**VSE applicability**: Lowest cost. Use for labelling, physical assembly, packaging, cosmetic requirements, and simple dimensional checks. Requires minimal equipment.

### Demonstration
A qualitative determination of properties or functional characteristics, made through observation with or without test equipment or instrumentation. Does not involve direct quantitative measurement.

**VSE applicability**: Good for functional requirements ("the system shall allow the operator to brew six cups"). Quick to execute. Suitable for stakeholder walk-throughs and prototype reviews.

### Test
Direct measurement of measurable characteristics, quantitatively verified. Measurements are obtained using instrumentation or special test equipment that is not an integral part of the test article.

**VSE applicability**: Most rigorous but most expensive. Reserve for critical performance parameters, safety requirements, and regulatory compliance. Plan test infrastructure early (test stands, instruments, calibration).

### Analysis
Engineering analyses, modelling and simulations, similarity analyses, sampling analysis. May include assessment of records (material certifications, past test data). Best choice when test is not cost-effective, inspections and demonstrations are inadequate, or test environments do not match operational environments.

Two important subcategories:
- **Analogy or similarity**: Based on evidence of similar elements or experience with testing or analysis highly related to the element under test. Useful for OTS parts with known performance data.
- **Sampling**: Verification of characteristics on a sample drawn from a larger lot. More relevant to production verification than system verification.

**VSE applicability**: High value for small teams. Use models and simulations to verify design before building. Similarity analysis can leverage supplier data sheets for OTS components. Reduces the number of physical tests needed.

### Method selection guidance for VSE
Choose the least expensive method that provides sufficient confidence:
1. Inspection (cheapest, lowest confidence for complex requirements).
2. Demonstration (low cost, moderate confidence).
3. Analysis (moderate cost, can provide high confidence for well-understood physics).
4. Test (highest cost, highest confidence).

Combine methods where sensible. A single verification event can cover multiple requirements. A single requirement may need multiple methods at different lifecycle stages.

---

## Validation Methods

Validation always asks: "Does this meet the stakeholder needs in the intended operational environment, operated by the intended users?"

### Needs and requirements validation
- **Interviews and site visits**: Confirm needs and requirements truly reflect stakeholder expectations. Do not rely solely on desk reviews.
- **Models and prototypes**: Show stakeholders early representations to validate intent before building.
- **Walkthroughs**: Small-group review of requirements against ConOps, use cases, and operational scenarios.

### Design validation
Occurs on the left side of the SE Vee, before the product is built. Key questions:
- Will the SOI built per the design output specifications meet its intended purpose in its operational environment?
- Will the resulting SOI interact properly with external interfaces?
- Is this the right design?
- Are applicable industry, customer, and internal design standards being applied?

**VSE approach**: Conduct design reviews with customer or end-user representatives present. Even a single informed review with the right people can achieve both design verification and design validation simultaneously.

### System validation
Occurs on the right side of the SE Vee with the realised (built or coded) product. Key questions:
- Is this the right system?
- Does it work the way the users intended?
- Was the problem or opportunity addressed correctly?
- Is realisation of the system repeatable?
- Are the above still true when intended users operate the system?
- If an unintended user has access, is damage to the system or the environment prevented?

**VSE-scaled system validation approaches**:
- **Beta testing**: Release a pre-release version to representative users in the actual operating environment. Identify issues before final release.
- **Acceptance demonstration**: Walk through operational scenarios with the customer at the development facility (Factory Acceptance Test, scaled down).
- **Operational evaluation**: Let intended users operate the system in its actual environment. The simplest and most meaningful form of validation.
- **Focus groups or limited runs**: For commercial products, produce limited quantities and solicit feedback before full release.

### Integrated testing (recommended for VSE)
Combine verification and validation activities in the same event. Data collected during verification to confirm requirements can simultaneously be analysed by the validation perspective to confirm the needs are met. This saves significant cost and schedule by avoiding separate campaigns.

---

## Test Case Design

### Deriving test cases from requirements
Each design input requirement maps to one or more verification instances. For each instance:
1. Identify the success criteria (what constitutes pass or fail, including tolerances).
2. Select the method (test, analysis, inspection, demonstration).
3. Define the procedure steps, conditions, and data to collect.
4. Identify required test equipment, facilities, and personnel.

### Requirements quality drives test quality
Requirements that are vague, unbounded, or lacking measurable thresholds produce untestable verification activities. Examples of non-verifiable statements to avoid:
- "The interface shall be user friendly."
- "The system should not slow down beyond acceptable use during peak loads."
- "The device should strive for a reliability of at least 99% uptime."
- "The transistor shall produce a circuit board with a bandwidth of 2 MHz." (no tolerance)

Each requirement must have a subject, a verb, a measurable condition, and a threshold or range. Refer to the INCOSE Guide to Writing Requirements (GtWR) for rules.

### Coverage criteria
- Every requirement must have at least one verification instance.
- Every need must have at least one validation instance.
- The VCRM and VaCRM matrices make gaps visible.
- If a requirement needs more than five verification activities, it may be too vague or compound and should be decomposed.
- If a single verification activity covers a large number of requirements, that activity is high-risk (single point of failure) and deserves extra attention.

### Procedure development (scaled for VSE)
For each verification or validation event, define:
1. Preconditions (configuration, setup, equipment state).
2. Steps to execute (numbered, unambiguous).
3. Data to collect and record.
4. Success criteria for each step.
5. Actions on failure (stop, continue, note discrepancy).

For small teams, a simple checklist format often suffices. For safety-critical procedures, conduct a tabletop walkthrough or dry run before formal execution.

### Discrepancy handling
When a verification or validation activity does not pass:
- **Correct the deficiency**: Fix the design or implementation and re-test.
- **Request a waiver or concession**: Document the deviation, assess risk, and obtain approval from the customer or approving authority.
- **Change the requirement**: If the requirement was incorrect or over-specified, update it through the change management process.

Treat failures during development as opportunities. Discovering and fixing a problem before delivery is far less costly than a field failure.

---

## V and V Reporting

### Execution records
Every verification or validation activity produces an execution record documenting:
- The requirement or need being addressed.
- The method and procedure used.
- The data collected.
- The result (pass, fail, pass with concession).
- The evidence location (pointer to test report, analysis document, inspection record).

### System Verification Compliance Matrix (SVCM)
The completed version of the VCRM. Each row shows:

| Req. ID | Requirement | Method | Success criteria | Event | Result | Evidence |
|---------|------------|--------|-----------------|-------|--------|----------|

For a VSE, this is the primary deliverable proving the system meets its requirements. It can be a spreadsheet. The SVCM serves as the pointer to all compliance evidence and allows quick assessment of verification status.

### System Verification Compliance Summary Matrix (SVCSM)
A simplified roll-up for the customer or approving authority:

| ID | Compliance | Evidence |
|----|-----------|----------|

Shows pass/fail and a pointer to evidence. Useful for a quick executive overview.

### System Validation Compliance Matrix (SVaCM)
Same as the SVCM but maps needs instead of requirements and tracks validation evidence. For a VSE, these can be combined into a single matrix with a column distinguishing verification from validation instances.

### Approval package
The collection of evidence submitted for acceptance. For a VSE, this typically includes:
1. Completed SVCM (or combined verification/validation matrix).
2. Any test reports, analysis documents, and inspection records.
3. List of waivers, deviations, and non-compliances with dispositions.
4. Traceability showing each need maps to requirements, and each requirement maps to verification evidence.

### Metrics (keep minimal for VSE)
Collect only metrics that drive decisions:
- Percentage of requirements verified (progress tracking).
- Percentage of needs validated.
- Number of open discrepancies and waivers.
- Number of TBDs or TBRs remaining in the requirement set.

Do not collect metrics that will not be used. Unused data collection is waste that erodes team morale.

---

## VSE-specific Guidance

### Role consolidation
In a VSE, one person often fills multiple roles: lead systems engineer, verification engineer, test engineer, and requirements engineer. The guide acknowledges this is common and acceptable. The critical practice is to ensure that verification and validation planning still occurs early, even if the same person executes everything.

### Early verification and validation on the left side of the Vee
This is where VSEs gain the most leverage. Performing design verification and design validation before building anything (through models, simulations, prototypes, and desk reviews) catches defects when they are cheapest to fix. The guide strongly recommends this for all organisations but it is especially valuable for resource-constrained teams.

### OTS and supplier parts
For OTS components, three verification questions apply:
1. Does the part truly meet its stated data sheet specifications?
2. Does the data sheet align with the design input requirements and design output specifications?
3. Is it the right part (will the SOI pass system verification and validation with this part)?

For a VSE, accepting vendor verification data for low-risk, non-safety items is appropriate. For high-priority, safety-critical, or security-sensitive requirements, conduct independent verification.

---

## Continuous Verification Timeframes (AMBSE)

Traditional V&V concentrates verification effort at phase gates and testing stages.
Agile model-based SE (Douglass, 2016) introduces three verification timeframes
that distribute quality assurance throughout the project.

### Nanocycle (30 minutes to 1 day)

Model-level checks performed as engineering data is created:

- SySiDE syntax validation on every save
- Constraint evaluation and type checking
- Traceability completeness check (`@traceability-guard` hook)
- Brief peer review or LLM-assisted model review
- Unit-level model verification (one requirement, one action, one part)

Maps to VCRM method: inspection, analysis (automated).

### Microcycle (1 to 4 weeks, one iteration)

Iteration-level verification at the end of each iteration:

- Integration verification: combine model files and check cross-package consistency
- Iteration acceptance: verify that the iteration mission has been achieved
- Stakeholder walkthrough of iteration deliverables
- Iteration retrospective with metrics review

Maps to VCRM methods: inspection (peer review), demonstration (walkthrough).

### Macrocycle (project length)

System-level V&V at the end of the project:

- Full system verification against all requirements
- Validation against stakeholder needs in the operational environment
- Formal acceptance testing

Maps to VCRM methods: test, demonstration, analysis.

The three timeframes complement the traditional Vee model approach already described
in this guide. They do not replace phase gates but add continuous quality assurance
between gates. See `knowledge/ambse-agile-process.md` Section 3 for the full
description.

---

### Configuration management
Configuration management must be enforced before formal verification and validation begins. For a VSE, this can be as simple as version-controlled files and a change log. Any design changes after verification starts must be assessed for impact on requirements already verified or validated.

### What to keep
Store and maintain:
- Needs and requirements (with attributes including verification status).
- Verification and validation matrices (VCRM, SVCM).
- Execution records and evidence.
- Waivers and deviation dispositions.
- Traceability records.

These artifacts protect the organisation if field failures occur, customers change, or regulatory audits are conducted. Use a version-controlled repository (git, shared drive with backup).
