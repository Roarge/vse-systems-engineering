---
name: needs-and-requirements
description: Elicit stakeholder needs and derive traceable SysML 2.0 system requirements. Use when capturing needs, writing requirements, or working in SR.2.
user-invocable: true
---

# Needs and Requirements

You guide the engineer through ISO 29110 SR.2 (System Requirements Engineering).
This skill implements R1 (information filtering) by surfacing only
requirements-phase knowledge. Do NOT volunteer architecture patterns, V&V
methods, or construction details while this skill is active.

## When This Skill Triggers

- The user asks to capture stakeholder needs
- The user asks to write or review requirements
- The user is in phase SR.2 and asks for guidance
- The user wants to create a Stakeholder Requirements Specification or System
  Requirements Specification

## Process Flow

### Step 1: Stakeholder Identification

Before writing any requirements, identify stakeholders:

1. Who is paying for the system? (Acquirer)
2. Who will use it? (End users, if different from Acquirer)
3. Who will maintain it? (Maintainers)
4. Who regulates it? (Regulatory bodies, if any)
5. Who is affected by it? (Other stakeholders)

Create a lightweight stakeholder register. In a VSE, this can be a simple table:

| Stakeholder | Role | Key Concerns | Priority |
|------------|------|-------------|----------|
| [name] | [ACQ/user/maintainer/regulator] | [what they care about] | [essential/desirable/optional] |

### Step 2: Needs Elicitation

Use VSE-appropriate techniques (from `${CLAUDE_PLUGIN_ROOT}/knowledge/needs-and-reqs-guide.md`):

**Priority techniques for VSEs:**
1. **Brainstorming** with stakeholders (low cost, high yield)
2. **Structured interviews** (one-on-one with key stakeholders)
3. **Document analysis** (existing specs, competitor products, standards)
4. **Interface analysis** (what other systems must this connect to?)
5. **Use case driven elicitation** (model actor-system interactions as use cases,
   derive needs from scenario steps). See `${CLAUDE_PLUGIN_ROOT}/knowledge/ambse-requirements.md`
   Sections 3-6 for the complete use case driven workflow, including three
   approaches: flow-based, scenario-based, and state-based analysis.

**Elicitation checklist (ask for each stakeholder):**
- What problem does the system solve for you?
- What does success look like?
- What are the critical performance thresholds?
- What interfaces with other systems are required?
- What constraints exist (budget, schedule, regulations)?
- What happens if the system fails?

### Step 3: Write Stakeholder Requirements (StRS)

Express needs as stakeholder requirements in SysML 2.0:

```sysml
package StakeholderNeeds {
    requirement def MonitorTemperature {
        doc /* The operator needs to monitor ambient temperature
               in the facility to ensure safe operating conditions. */
        attribute id : String = "STK-001";
        attribute priority : String = "essential";
        attribute source : String = "Facility Manager";
    }
}
```

**Rules for stakeholder requirements:**
- Written in stakeholder language (problem domain, not solution domain)
- Each need traces to at least one stakeholder
- Categorise using: Function, Fit, Form, Quality, Compliance

### Step 4: Derive System Requirements (SyRS)

Transform stakeholder needs into system requirements:

1. For each stakeholder need, ask: "What must the system do to satisfy this?"
2. Follow the model-based derivation workflow from `${CLAUDE_PLUGIN_ROOT}/knowledge/ambse-requirements.md`
   Section 4: identify functions, derive functional requirements, derive performance
   requirements, derive interface requirements, derive constraint requirements, and
   assign a verification method to each requirement as it is written.
3. Apply SMART criteria to each requirement:
   - **S**pecific: one requirement, one thought
   - **M**easurable: quantitative where possible
   - **A**chievable: feasible within budget and schedule
   - **R**elevant: traces to a stakeholder need
   - **T**estable: verification method identifiable

```sysml
package SystemRequirements {
    import StakeholderNeeds::*;

    requirement def MeasureTemperature :> SystemRequirement {
        doc /* The system shall measure ambient temperature
               with accuracy of +/- 0.5 degrees Celsius
               over the range -20 to +60 degrees Celsius. */
        attribute id : String = "REQ-001";
        attribute verificationMethod : String = "test";
        satisfy requirement MonitorTemperature;
    }
}
```

For each system requirement, also consider:
- **Boundary conditions**: what is inside versus outside the system
- **Design constraints**: mandatory technology, standards, or regulations
- **External functions**: functions provided by external systems
- **Reuse constraints**: requirements that must be met by existing components

### Step 5: Elaborate System Elements Requirements (SR.2.5)

Derive element-level requirements from system requirements. For each system
element identified in the System Breakdown Structure:

1. **Identify the element** and its role in the system architecture
2. **Allocate system requirements** to the element (which system requirements
   does this element contribute to satisfying?)
3. **Derive element-specific requirements** that are not visible at system level
   (e.g., interface constraints, performance budgets, environmental tolerances)
4. **Document in the System Elements Requirements Specification**
   (`docs/sr/system-element-requirements.md`)

Element requirements use the `ELE-` prefix in SysML 2.0 models.

Each element requirement MUST:
- Trace upward to at least one system requirement via a `satisfy` link
- Be verifiable at the element level (before system integration)
- Include the target element name in its documentation

```sysml
// Example: element requirement for a temperature sensor
package ElementRequirements {
    requirement def SensorAccuracy :> SystemElementRequirement {
        doc /* The temperature sensor shall measure with accuracy +/- 0.3 C. */
        satisfy requirement SystemRequirements::MeasureTemperature;
    }
}
```

> VSE note: For simple systems with few elements, system requirements and
> element requirements may overlap significantly. Document the allocation
> even if it seems obvious, as this is what an auditor will check.

### Step 6: Verify Requirements (SR.2.6)

Run a quality check on every requirement:

| Check | Pass Criteria |
|-------|--------------|
| Necessary | Removing it would leave a stakeholder need unsatisfied |
| Unambiguous | Only one interpretation possible |
| Complete | All conditions and exceptions specified |
| Singular | One requirement per statement |
| Achievable | Can be implemented within constraints |
| Verifiable | Verification method exists (test, analysis, inspection, demonstration) |
| Implementation-free | Describes WHAT, not HOW |

**Common defects to catch:**
- Vague terms: "fast", "user-friendly", "reliable" (replace with measurables)
- Combined requirements: "shall do X and Y" (split into two)
- Design constraints disguised as requirements: "shall use TCP/IP" (ask: why?)
- Missing boundary conditions: "shall operate in high temperatures" (specify range)

### Step 7: Obtain Work Team Agreement (SR.2.2, SR.2.6)

Before presenting to external stakeholders, obtain internal agreement:

1. **Review StRS with PJM and Work Team** (SR.2.2):
   - Present the StRS to the project manager and work team
   - Verify completeness and consistency
   - Record review comments and resolutions

2. **Review SyRS and System Elements Requirements with Work Team** (SR.2.6):
   - Present the complete set of system and element requirements
   - Verify SMART criteria compliance
   - Obtain Work Team sign-off (record in Meeting Record)

> VSE note: In a small team, this may be a single review meeting covering both
> StRS and SyRS. The important thing is that the technical team agrees before
> the acquirer sees the documents.

### Step 8: Validate StRS and SyRS with Stakeholders (SR.2.3, SR.2.7)

Present the StRS and SyRS to stakeholders for validation:
- Does each stakeholder need have at least one system requirement?
- Do the system requirements collectively satisfy the stakeholder needs?
- Are there any missing needs not captured?

### Step 9: Establish Traceability (SR.2.8)

Invoke `@traceability-guard` to verify:
- Every system requirement traces upward to a stakeholder need (satisfy link)
- The Traceability Matrix is updated
- No orphan requirements exist (requirements with no parent need)

### Step 10: Establish IVV Plan and IVV Procedures (SR.2.9)

For each system requirement, identify the verification method:
- **Test**: operational exercise with measurement
- **Analysis**: mathematical or computational assessment
- **Inspection**: visual examination of product or documentation
- **Demonstration**: functional operation without measurement

Create initial verification cases (route to `@verification-validation` for
detailed V&V planning).

**Nanocycle verification**: When using the agile MBSE approach, begin nanocycle
verification (20-60 minute loops) during requirements development, not just at
SR.5. Run SySiDE validation, check traceability with `@traceability-guard`, and
review each use case model as it is created. See `${CLAUDE_PLUGIN_ROOT}/knowledge/ambse-agile-process.md`
Section 3 for the full verification timeframe model.

The IVV Plan defines WHAT will be verified and validated. IVV Procedures define
HOW each verification and validation activity will be executed. Both are outputs
of SR.2.9.

For each system requirement, define:
- **Verification method** (inspection, analysis, demonstration, test)
- **Procedure outline** (steps to execute the verification, expected results)
- **Pass/fail criteria** (measurable acceptance thresholds)

IVV Procedures may be documented inline in `docs/sr/ivv-plan.md` (Section 5)
or in the SysML 2.0 model (`models/verification.sysml`). For VSE projects,
the inline approach in the IVV Plan is sufficient.

## Requirements Import/Export (Automator)

When the Syside Automator Python library is available, support round-tripping
requirements between SysML models and Excel spreadsheets. This addresses the
common VSE workflow where the acquirer reviews requirements in a spreadsheet
while the SysML model remains the source of truth.

### Check Automator Availability

```bash
python -c "import syside; print(syside.__version__)"
pip install pandas openpyxl   # Required for Excel support
```

If Automator is not available, manage requirements directly in the SysML model.

### Export Requirements to Excel

Use this script to extract all requirements from the model into a spreadsheet
for acquirer review:

```python
import pathlib
import pandas as pd
import syside

MODEL_DIR = pathlib.Path("models/")
OUTPUT = pathlib.Path("build/requirements.xlsx")

def main() -> None:
    model, diagnostics = syside.load_model(
        paths=syside.collect_files_recursively(str(MODEL_DIR))
    )
    assert not diagnostics.contains_errors(warnings_as_errors=True)

    data = []
    for req in model.nodes(syside.RequirementDefinition):
        if req.document.document_tier is not syside.DocumentTier.Project:
            continue
        for doc in req.documentation.collect():
            data.append({
                "ID": req.declared_name,
                "Requirement": doc.body,
            })
    df = pd.DataFrame(data)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    df.to_excel(OUTPUT, index=False)
    print(f"Exported {len(data)} requirements to {OUTPUT}")

if __name__ == "__main__":
    main()
```

### Import Requirements from Excel

Use this script to create SysML requirement definitions from spreadsheet data:

```python
import pathlib
import pandas as pd
import syside

INPUT = pathlib.Path("requirements.xlsx")
OUTPUT = pathlib.Path("models/imported-requirements.sysml")

def main() -> None:
    df = pd.read_excel(INPUT)
    doc = syside.Document.create_st(url="memory://imported.sysml")
    with doc.lock() as locked:
        mem, pkg = locked.root_node.children.append(
            syside.OwningMembership, syside.Package
        )
        for _, row in df.iterrows():
            mem, req = pkg.children.append(
                syside.OwningMembership, syside.RequirementDefinition
            )
            # Configure requirement name and documentation
    text = syside.pprint(locked.root_node)
    OUTPUT.write_text(text)
    print(f"Imported {len(df)} requirements to {OUTPUT}")

if __name__ == "__main__":
    main()
```

### Round-Trip Workflow

1. **Export**: extract requirements from the SysML model to Excel
2. **Review**: acquirer reviews and comments on requirements in the spreadsheet
3. **Reconcile**: engineer reviews feedback, updates the SysML model
4. **Re-export**: generate updated spreadsheet to confirm changes

This keeps the SysML model as the single source of truth while supporting
acquirer workflows that rely on spreadsheets.

Reference: https://docs.sensmetry.com/examples/reqs_to_excel.html and
https://docs.sensmetry.com/examples/reqs_from_excel.html

## Red Flags

WARN the engineer if:
- Requirements are being written without stakeholder identification
- System requirements have no satisfy links to stakeholder needs
- Requirements use vague or unmeasurable language
- More than 20% of requirements change after specification freeze
- The engineer is jumping to architecture before requirements are baselined

## Requirement Attributes (VSE Minimum)

Every requirement MUST carry these attributes:

| Attribute | Description |
|-----------|-------------|
| id | Unique identifier (REQ-nnn) |
| text | The requirement statement |
| priority | essential, desirable, or optional |
| verificationMethod | test, analysis, inspection, or demonstration |
| source | Which stakeholder need this derives from |
| status | draft, reviewed, approved, baselined |

## Reference: Needs and Requirements Guide

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/needs-and-reqs-guide.md`

## Reference: AMBSE Requirements

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/ambse-requirements.md`
