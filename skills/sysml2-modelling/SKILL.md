---
name: sysml2-modelling
description: Author and validate SysML 2.0 textual models (.sysml files). Use when creating or editing SysML models, checking syntax, or navigating model elements.
user-invocable: true
---

# SysML 2.0 Modelling

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You are the modelling workbench for SysML 2.0 textual notation. You guide
authoring of .sysml files, validate syntax against the OMG specification, and
provide templates for common model elements. Reference:
`${CLAUDE_PLUGIN_ROOT}/knowledge/sysml2-quick-ref.md`.

## When This Skill Triggers

- The user asks to create or edit a SysML 2.0 model
- The user asks about SysML 2.0 syntax at the project level
- The user wants to navigate or query existing models
- The user wants tooling integration (SySiDE, Automator, CI validation)
- Any other skill needs to create model elements
- The user has a SysML question but the topic is not yet clear

## Routing to Focused Siblings

This skill is the workbench and the router. For topic-specific
authoring, hand off to one of the eight focused siblings. Keep the
umbrella active if the engineer moves between topics in one session.

| Topic | Sibling skill | When to route |
| --- | --- | --- |
| Model structure, canonical layout, base architecture, federation, risk register, variant configurations, model-level CM | `@sysml2-model-structure` | Starting a new model, splitting an oversized file, inheriting a base, federating, organising variants or risks or configuration items |
| Expressions, calculations, constraints | `@sysml2-expressions` | Formulas, derived attributes, parametric bodies |
| Actions, states, flows, messages | `@sysml2-behaviour` | Behaviour bodies, succession graphs, state machines |
| Use, analysis, verification cases | `@sysml2-cases` | Test cases, trade studies, verification bodies |
| Views and viewpoints | `@sysml2-views` | Documentation views, standard view catalogue |
| Allocations across architecture layers | `@sysml2-allocations` | Function-to-platform or behaviour-to-structure maps |
| Variations and variants | `@sysml2-variants` | Product lines, alternatives, configuration bindings |
| Metadata, reflection, user-defined keywords, RiskInfo, ConfigItem, Baseline | `@sysml2-metadata` | Tagging, filters, domain keywords, risk library, CM library |

The umbrella still owns project layout, tooling, CI validation, and the
high-level quick reference. Siblings own topic authoring.

## Project Template

New projects follow the AMBSE canonical model layout adapted from
Douglass 2016 Fig 3.13 *Canonical system engineering model
organization* and Douglass 2021 Cookbook Fig 1.35. Ten mandatory
top-level packages plus a root `{{sc}}_Model` overview file, with
three optional packages scaffolded on opt-in. Every top-level package
carries a two- to four-letter short-code prefix (for example `HS_`
for a Hydrogen Sensor project) per Ch 15-16 namespace hygiene.

The layout is **workflow-centric**, not phase-sequential. Each
package is named for the kind of work it holds. Concurrent SR.2 and
SR.3 work inside one microcycle is natural because the packages are
independently editable.

Mandatory packages:

| Package | Role | Authoring sibling |
| --- | --- | --- |
| `{{sc}}_Model` | Root overview with cross-links | `@sysml2-model-structure` |
| `{{sc}}_Actors` | Actor part defs, external systems | `@sysml2-model-structure` |
| `{{sc}}_StakeholderNeeds` | Stakeholder needs with `subject` | `@needs-and-requirements` |
| `{{sc}}_UseCases` | Use cases and use case diagrams | `@sysml2-cases` |
| `{{sc}}_Requirements` | System requirements with `satisfy` links | `@needs-and-requirements`, `@sysml2-cases` |
| `{{sc}}_FunctionalAnalysis` | One sub-package per analysed use case | `@sysml2-behaviour` |
| `{{sc}}_ArchAnalysis` | One sub-package per trade study | `@architecture-design`, `@sysml2-cases` |
| `{{sc}}_ArchDesign` | Selected architecture with one sub-package per subsystem | `@architecture-design`, `@sysml2-allocations` |
| `{{sc}}_Interfaces` | Logical interfaces and logical data schema | `@sysml2-model-structure` |
| `{{sc}}_Verification` | Verification cases with `verify` links | `@verification-validation`, `@sysml2-cases` |
| `{{sc}}_Risks` | Risk register with `RiskInfo` metadata applied | `@sysml2-metadata`, `@sysml2-model-structure` |

Optional packages, scaffolded on opt-in inside `@project-setup`:

| Package | Role | Opt-in reason |
| --- | --- | --- |
| `{{sc}}_BaseArchitecture` | Inherited base specialised via `:>` / `:>>` | Project inherits from a prior programme |
| `{{sc}}_Configurations` | Concrete variant configurations as specialised owners | Project carries product-line variants |
| `{{sc}}_CM` | Model-level CIs and baselines | Project declares baselines alongside Project Plan Section 9 |

Starter files live at `${CLAUDE_PLUGIN_ROOT}/templates/common/models/`
and are copied into the project by `@project-setup`. Each file is
heavily commented with citations back to Douglass 2016, Cookbook
2021, Ch 14-16, Ch 35, VAMOS 2016, and ISO 29110.

For the full pattern walk-through, including base-architecture reuse,
federation, variant configurations, model-level CM, and the risk
register pattern, route to `@sysml2-model-structure`.

## Top-Level Syntax Summary

The quick reference at the end of this skill lists all keywords and
forms. For topic-specific authoring examples, load the appropriate
sibling. The umbrella keeps only the traceability link summary below
because every sibling produces at least one trace link and the engineer
often asks about several link types in a single session.

### Traceability Links at a Glance

```sysml
// Satisfaction (requirement satisfies a need)
satisfy requirement StakeholderNeeds::NeedName;

// Verification (case verifies a requirement)
verify requirement SystemRequirements::ReqName;

// Allocation (function allocated to physical element)
allocate FunctionalArch::FunctionName to PhysicalArch::ElementName;
```

For each link type, the authoring details live in the owning sibling:
`@sysml2-cases` for `verify`, `@sysml2-allocations` for `allocate`, and
`@needs-and-requirements` for `satisfy`.

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

**Documentation generation** (at iteration-boundary closure or at macrocycle delivery):

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
