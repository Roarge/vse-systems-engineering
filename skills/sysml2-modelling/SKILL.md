---
name: sysml2-modelling
description: Author and validate SysML 2.0 textual models (.sysml files). Use when creating or editing SysML models, checking syntax, or navigating model elements.
user-invocable: true
---

# SysML 2.0 Modelling

You are the modelling workbench for SysML 2.0 textual notation. You guide
authoring of .sysml files, validate syntax against the OMG specification, and
provide templates for common model elements. Reference:
`${CLAUDE_PLUGIN_ROOT}/knowledge/sysml2-quick-ref.md`.

## When This Skill Triggers

- The user asks to create or edit a SysML 2.0 model
- The user asks about SysML 2.0 syntax
- The user wants to navigate or query existing models
- Any other skill needs to create model elements

## Project Template

When initialising a new project, create this structure:

```sysml
// models/package.sysml
package ProjectName {
    import StakeholderNeeds::*;
    import SystemRequirements::*;
    import Architecture::*;
    import Verification::*;
    import Validation::*;
}
```

```sysml
// models/stakeholder-needs.sysml
package StakeholderNeeds {
    // Stakeholder requirements go here
    // Each need uses: requirement def Name { ... }
    // Attributes: id, priority, source
}
```

```sysml
// models/system-requirements.sysml
package SystemRequirements {
    import StakeholderNeeds::*;

    // System requirements go here
    // Each requirement uses: requirement def Name { ... satisfy ... }
    // Attributes: id, verificationMethod, priority
}
```

```sysml
// models/architecture.sysml
package Architecture {
    import SystemRequirements::*;

    // Part definitions, ports, connections go here
}
```

```sysml
// models/verification.sysml
package Verification {
    import SystemRequirements::*;

    // Verification cases go here
    // Each case uses: verification def Name { ... verify ... }
}
```

```sysml
// models/validation.sysml
package Validation {
    import StakeholderNeeds::*;

    // Validation cases go here
}
```

## Syntax Reference (Key Patterns)

### Requirements

```sysml
requirement def RequirementName {
    doc /* The system shall [do something measurable]. */
    attribute id : String = "REQ-001";
    attribute priority : String = "essential";
    attribute verificationMethod : String = "test";
    satisfy requirement StakeholderNeeds::NeedName;
}
```

### Part Definitions (Architecture)

```sysml
part def SystemName {
    part subsystemA : SubsystemAType;
    part subsystemB : SubsystemBType;

    port externalInput : InputPort;
    port externalOutput : OutputPort;

    connect subsystemA.outPort to subsystemB.inPort;
}
```

### Port Definitions

```sysml
port def DataPort {
    attribute dataRate : Real;
    attribute protocol : String;
}

// Conjugated port (receiver side)
port def ~DataPort;
```

### Verification Cases

```sysml
verification def VerificationName {
    doc /* Description of how to verify the requirement. */
    attribute id : String = "VER-001";
    attribute method : String = "test";
    attribute passCriteria : String = "...";
    verify requirement SystemRequirements::RequirementName;
}
```

### Actions (Behaviour)

```sysml
action def MeasureTemperature {
    in item rawReading : Real;
    out item calibratedTemp : Real;

    action read : ReadSensor { in item = rawReading; }
    action calibrate : ApplyCalibration { out item = calibratedTemp; }

    succession read then calibrate;
}
```

### States

```sysml
state def SensorStates {
    entry state idle;
    state measuring;
    state alerting;

    transition idle_to_measuring
        first idle then measuring
        if startMeasurement;

    transition measuring_to_alerting
        first measuring then alerting
        if thresholdExceeded;
}
```

### Traceability Links

```sysml
// Satisfaction (requirement satisfies a need)
satisfy requirement StakeholderNeeds::NeedName;

// Verification (case verifies a requirement)
verify requirement SystemRequirements::ReqName;

// Allocation (function allocated to physical element)
allocate FunctionalArch::FunctionName to PhysicalArch::ElementName;
```

## Model Validation

When reviewing a .sysml file, check:

1. **Package structure**: every file starts with a `package` declaration
2. **Imports**: all cross-package references use proper imports
3. **Naming conventions**: PascalCase for definitions, camelCase for usages
4. **ID attributes**: all requirements and verification cases have unique IDs
5. **Traceability links**: every requirement has satisfy, every verification
   has verify
6. **Documentation**: every definition has a `doc` comment

## Model Navigation

When the user asks to find something in the model:

- **Find all requirements**: `Grep for "requirement def" in models/**/*.sysml`
- **Find all parts**: `Grep for "part def" in models/**/*.sysml`
- **Find all verification cases**: `Grep for "verification def" in models/**/*.sysml`
- **Find trace links**: `Grep for "satisfy requirement\|verify requirement" in models/**/*.sysml`
- **Find a specific element**: `Grep for the element name in models/**/*.sysml`

## Tooling Integration

### Sensmetry SySiDE Product Suite

Four complementary tools for SysML v2:

| Workflow | Tool | Licence |
| --- | --- | --- |
| Learning, lightweight editing | **Syside Editor** (VS Code extension) | Free |
| Model writing, diagrams, interactive exploration | **Syside Modeler** (VS Code extension) | Licensed |
| CI/CD validation, headless diagrams | **Syside CLI** (included with Modeler) | Licensed |
| Programmatic analysis, scripting, reports | **Syside Automator** (Python library) | Licensed |

**Syside Editor**: syntax highlighting, validation, auto-completion,
go-to-definition for .sysml and .kerml files.

**Syside Modeler**: everything Editor provides plus synchronised diagram
visualisation. You MUST disable the Editor extension when Modeler is active
to avoid conflicts.

**Syside CLI**: standalone command-line tool for validation, formatting, and
diagram generation. Requires Java 21. See the CLI Commands section below.

**Syside Automator**: Python 3.12+ library for programmatic model access,
querying, expression evaluation, requirements import/export, report generation,
and custom automation. Install via `pip install syside`. See the Automator
Python API section below.

Additionally:
- **Sysand**: open-source SysML v2 package manager for reusable libraries.

**Combined workflows:** use Modeler for visual review and Automator for
automated analysis. Both share the same licence key.

### SySiDE CLI Commands

The CLI is the primary tool for terminal-based model operations. All commands
operate on the current directory recursively unless paths are specified.

**Prerequisites:** Java 21 runtime, valid Modeler licence. Set the licence via:
```bash
export SYSIDE_LICENSE_KEY="your-licence-key"
```

#### Validate Models

```bash
# Validate all models in the current directory
syside check

# Validate specific files
syside check models/system-requirements.sysml models/verification.sysml

# Fail on warnings (recommended for CI/CD)
syside check --warnings-as-errors

# Show statistics and timing
syside check --stats --time

# Exclude draft files
syside check --exclude "*.draft.sysml"
```

Exit codes: 0 = valid, non-zero = errors found.

Output format for errors:
```
models/system-requirements.sysml:12:5: error (CODE): message
```

#### Format Models

```bash
# Format all models in place
syside format

# Check formatting without modifying (for CI/CD and pre-commit)
syside format --check

# Custom line width
syside format --line-width 120

# Use tabs with 2-space width
syside format --tabs --tab-width 2
```

Exit codes for `--check` mode: 0 = properly formatted, 1 = needs reformatting,
2 = syntax errors.

#### Generate Diagrams (Labs, available until 2026-06-01)

**Element diagrams** (by qualified name, no view definition needed):

```bash
# Generate SVG of a specific element
syside viz element "SmartSensor::SensorSystem" models/ --output-file build/sensor-system.svg

# PNG with depth control and zoom
syside viz element "SmartSensor::SensorSystem" models/ --depth=2 --zoom-level 3.0 --output-file build/sensor-system.png

# Full tree rendering
syside viz element "SmartSensor::SensorSystem" models/ --depth=-1 --rendering tree --output-file build/sensor-tree.svg
```

**View-based diagrams** (from SysML v2 view definitions in the model):

```bash
# Render all views to output directory
syside viz view models/ --output-dir build/diagrams

# Render a specific view
syside viz view models/ --qualified-name "Views::SystemOverview" --output-dir build/diagrams
```

Output formats: `.svg`, `.png`, `.pdf` (inferred from file extension).

**Headless Linux** (CI/CD, WSL without display): prefix with `xvfb-run -a`:

```bash
xvfb-run -a syside viz element "SmartSensor::SensorSystem" models/ --output-file build/sensor.svg
```

### Configuration

Create `syside.toml` in the project root. The `@project-setup` skill generates
this from the template at `${CLAUDE_PLUGIN_ROOT}/templates/common/syside.toml`.

Key sections:

```toml
# Exclude generated files
exclude = ["build/**", "*.draft.sysml"]

[format]
line-width = 100       # Column limit for wrapping
tab-width = 4          # Spaces per indent
tabs = false           # Spaces, not tabs
markdown = true        # Treat comments as Markdown
empty-brackets = "braces"  # Use {} not ; for empty blocks

[lint]
standard-library-package = "warning"

[lsp]
completion-limit = 256
edit = "project"
```

See `${CLAUDE_PLUGIN_ROOT}/templates/common/syside.toml` for the full annotated
configuration.

### Terminal Workflows

**Nanocycle verification** (20-60 minute loops during model editing):

```bash
# Quick check after editing a model file
syside check models/system-requirements.sysml

# Format the file you just edited
syside format models/system-requirements.sysml
```

**Pre-commit validation** (before committing model changes):

```bash
# Run both checks
syside check --warnings-as-errors && syside format --check
```

**Documentation generation** (at phase gates or delivery):

```bash
mkdir -p build/diagrams
syside viz view models/ --output-dir build/diagrams
# On headless Linux:
xvfb-run -a syside viz view models/ --output-dir build/diagrams
```

### Syside Automator Python API

The Automator provides programmatic access to SysML v2 models from Python.
Use it for model queries, expression evaluation, requirements import/export,
report generation, and custom validation scripts.

**Prerequisites:** Python 3.12+, valid licence (same key as Modeler).

```bash
pip install syside
export SYSIDE_LICENSE_KEY="your-licence-key"
python -c "import syside; print(syside.__version__)"
```

#### Loading and Querying Models

```python
import syside

# Load model files
model, diagnostics = syside.load_model(
    paths=syside.collect_files_recursively("models/")
)
assert not diagnostics.contains_errors(warnings_as_errors=True)

# Query all requirements
for req in model.nodes(syside.RequirementDefinition):
    print(req.declared_name, req.qualified_name)

# Query all parts (user-defined only, excluding standard library)
for part in model.nodes(syside.PartUsage):
    if part.document.document_tier is syside.DocumentTier.Project:
        print(part.name)

# Extract documentation
for doc in model.nodes(syside.Documentation):
    if doc.owner and doc.owner.qualified_name:
        print(f"{doc.owner.qualified_name}: {doc.body}")
```

#### Evaluating Expressions and Constraints

```python
STDLIB = syside.Environment.get_default().lib
compiler = syside.Compiler()

# Evaluate an attribute value with unit conversion
for attr in model.nodes(syside.AttributeUsage):
    if attr.name == "TotalMass":
        value, report = compiler.evaluate_feature(
            feature=attr,
            scope=attr.owner,
            stdlib=STDLIB,
            experimental_quantities=True,
        )
        if not report.fatal:
            print(f"Total mass: {value}")
```

#### Interactive Exploration

Launch an interactive REPL to explore a model without writing scripts:

```bash
python -m syside interactive models/system-requirements.sysml
```

```python
>>> len(list(model.nodes(syside.RequirementDefinition)))
12
>>> for req in model.nodes(syside.RequirementDefinition):
...     print(req.declared_name)
```

#### Key Automator Workflows

| Workflow | Description | Skill |
| --- | --- | --- |
| Requirements to Excel | Export requirements as spreadsheet for acquirer review | `@needs-and-requirements` |
| Requirements from Excel | Import requirements from spreadsheet into SysML | `@needs-and-requirements` |
| Semantic trace checking | Programmatic verify/satisfy link analysis | `@traceability-guard` |
| Value rollup | Mass, power, cost budgets with unit conversion | `@architecture-design` |
| Part hierarchy extraction | Walk ownership tree, filter by type | `@architecture-design` |
| Variant analysis | Extract and compare configurations | `@architecture-design` |
| Report generation | Jinja2 templates with model data, traceability matrices | `@document-export` |
| State machine simulation | Simulate SysML state machines in Python | `@verification-validation` |
| Constraint checking | Evaluate requirement bounds against model values | `@verification-validation` |

For full API details, see `${CLAUDE_PLUGIN_ROOT}/knowledge/syside-automator-ref.md`.

## Red Flags

WARN the engineer if:
- A .sysml file has no package declaration
- Requirements are defined without ID attributes
- Cross-package references are used without imports
- Verification cases exist without verify links
- The model structure does not follow the project template

## Reference: SysML 2.0 Quick Reference

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/sysml2-quick-ref.md`

## Reference: SysML 2.0 Semantics and Type System

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/sysml2-semantics-ref.md`

## Reference: SysML 2.0 Model Libraries

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/sysml2-libraries-ref.md`

## Reference: SySiDE Automator API

!`cat ${CLAUDE_PLUGIN_ROOT}/knowledge/syside-automator-ref.md`
