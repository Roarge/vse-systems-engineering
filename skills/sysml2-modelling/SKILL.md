---
name: sysml2-modelling
description: The SysML 2.0 workbench and umbrella router. Owns project layout, Syside tooling, CI validation, and the top-level syntax quick reference, and routes topic authoring to the eight focused siblings.
when_to_use: Use when the SysML topic is not yet clear, when creating or editing .sysml files generally, when checking syntax, when navigating or querying a model, or when configuring Syside and `syside.toml`. Route to the sibling that owns the topic once it is clear.
paths: ["**/*.sysml", "**/syside.toml"]
user-invocable: true
---

# SysML 2.0 Modelling

A `methodology/` folder at the project root, or under `engineering/`, marks a VSE project. If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first. In a SysML-only repository with no `methodology/` folder, skip the lens and proceed directly with this skill.

You are the modelling workbench for SysML 2.0 textual notation. You guide
authoring of .sysml files, validate syntax against the OMG specification, and
provide templates for common model elements. The full SysML 2.0 reference set
plus the Syside Python API reference lives in the plugin wiki, as atomic pages
under the `wiki/pages/sysml2/` and `wiki/pages/syside/` layers.

## When This Skill Triggers

- The user asks to create or edit a SysML 2.0 model
- The user asks about SysML 2.0 syntax at the project level
- The user wants to navigate or query existing models
- The user wants tooling integration (Syside, Automator, CI validation)
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

### Sensmetry Syside product lineup

| Workflow | Product | Licence |
| --- | --- | --- |
| Learning, lightweight editing | **Syside Editor: SysML v2 Essential** (VS Code extension) | Free |
| Model writing, diagrams, grid views | **Syside Pro Suite** (Modeler) | Paid |
| CI/CD validation, headless diagrams, scripting | **Syside Pro Suite** (Automator and the `syside` CLI) | Paid |
| The Pro Suite without a local installation | **Syside Cloud** | Paid |
| Safety and security analysis (ISO 26262, ISO/SAE 21434, FMEA) | **Syside Derisker** | Beta |

**Syside Editor**: syntax highlighting, validation, auto-completion,
go-to-definition for .sysml and .kerml files.

**Syside Pro Suite**: everything the Editor provides plus synchronised
diagram visualisation and editable grid views (Modeler), the `syside`
command-line tool for validation, formatting, and diagram generation,
and the Automator, a Python 3.12+ library for programmatic model access,
querying, expression evaluation, requirements import and export, report
generation, and custom automation. Install the Automator with
`pip install syside`. One licence key covers the whole suite. You MUST
disable the Editor extension when the Modeler is active, to avoid
conflicts.

Additionally:
- **Sysand**: open-source SysML v2 package manager for reusable
  libraries. Read `pages/syside/syside-sysand-package-management.md`.

Reference release: 0.10.3 (23 July 2026). Syside is pre-v1.0, so pin the
version a project depends on. Read
`pages/syside/syside-tooling-overview.md` for the lineup, the roadmap,
and the breaking-change window.

### Syside CLI Commands

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

For full API details, read the `syside-tooling-overview`, `syside-core-api`,
`syside-expression-evaluation`, `syside-model-modification`, and
`syside-vse-workflows` atomic pages under `wiki/pages/syside/`.

## Red Flags

WARN the engineer if:
- A .sysml file has no package declaration
- Requirements are defined without ID attributes
- Cross-package references are used without imports
- Verification cases exist without verify links
- The model structure does not follow the project template

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| Syside Automator Core API | pages/syside/syside-core-api.md | Loading, querying, and traversing SysML 2.0 models from the Syside Automator Python library |
| Syside Expression Evaluation and Compiler | pages/syside/syside-expression-evaluation.md | Evaluating SysML expressions, feature values with units, requirements, and metadata filters |
| Syside Model Modification and Element Reference | pages/syside/syside-model-modification.md | Adding, removing, and exporting model elements through the Syside API, with an element type reference |
| Syside Project Configuration: syside.toml and .lsp.json | pages/syside/syside-project-configuration.md | Three-level syside.toml discovery, merge semantics, the format, lsp, lint and telemetry sections, and .lsp.json |
| Sysand Package Management for SysML v2 | pages/syside/syside-sysand-package-management.md | Sysand manifests, the lock file, KPAR packaging, the public index, and CI publishing for SysML v2 |
| Syside Tooling Overview and Installation | pages/syside/syside-tooling-overview.md | Choosing between Syside Editor, Pro Suite, Cloud, and Derisker, plus installation and licence setup |
| Syside VSE Workflows and Report Generation | pages/syside/syside-vse-workflows.md | Syside workflows for requirement round-trips, grid views, hierarchy walks, trace checks, CI, and reports |
| Systems Modeling API and Services | pages/sysml2/sysml2-api-and-services.md | The Systems Modeling API and Services, its PIM data structures and services for tool-independent model access |
| SysML 2.0 Domain Libraries: Causation, Derivation, Geometry | pages/sysml2/sysml2-domain-libraries-causation-geometry.md | The Cause and Effect, Requirement Derivation, and Geometry domain libraries |
| SysML 2.0 Domain Libraries: Metadata and Analysis | pages/sysml2/sysml2-domain-libraries-metadata-analysis.md | The Metadata and Analysis domain libraries, covering status, risk, tool execution, and trade studies |
| SysML 2.0 Grammar Excerpts, Well-Formedness, and Validation Checklist | pages/sysml2/sysml2-grammar-and-validation.md | SysML 2.0 grammar excerpts, well-formedness rules, and a model validation checklist |
| SysML 2.0 Language Architecture: KerML, Definition/Usage, Implicit Specialisation | pages/sysml2/sysml2-language-architecture.md | The two-layer KerML and SysML architecture, the definition and usage pattern, and implicit specialisation |
| SysML 2.0 Library Architecture: Systems Model Library and Domain Libraries | pages/sysml2/sysml2-libraries-architecture.md | The implicit Systems Model Library and the Domain Libraries a project imports explicitly |
| SysML 2.0 Library Import Patterns and VSE Selection Guide | pages/sysml2/sysml2-library-import-patterns.md | Import patterns for the domain libraries, organised by use case and ISO 29110 phase |
| SysML 2.0 Quantities and Units (ISQ and SI) | pages/sysml2/sysml2-quantities-and-units.md | A quantity is an attribute whose value carries physical meaning |
| SysML 2.0 Requirements Semantics: Subject, Assume/Require, Satisfaction, Verification | pages/sysml2/sysml2-requirements-semantics.md | Semantic rules for the requirement family, covering subject, assume, require, satisfaction, verification |
| SysML 2.0 Specialisation, Typing, Composition, and Feature Values | pages/sysml2/sysml2-specialisation-and-typing.md | Semantic rules for how types relate to each other and how usages bind values |
| SysML 2.0 Structural and Behavioural Semantics | pages/sysml2/sysml2-structural-and-behavioural-semantics.md | Semantic rules for the structural and behavioural element families |
| SysML 2.0 Syntax: Actions and States | pages/sysml2/sysml2-syntax-behaviour.md | Cheat sheet for behavioural modelling syntax, covering actions and states |
| SysML 2.0 Syntax: Multiplicity, Attributes, and Enumerations | pages/sysml2/sysml2-syntax-features-and-attributes.md | Cheat sheet for feature multiplicity, attribute values, and enumeration declarations |
| SysML 2.0 Syntax: Packages, Definitions, and Common Relationships | pages/sysml2/sysml2-syntax-packages-and-definitions.md | Cheat sheet for top-level model organisation, the def/usage pattern, and the common relationship operators |
| SysML 2.0 Syntax: Calc, Constraint, Requirement, Verification, Cases, Views | pages/sysml2/sysml2-syntax-requirements-and-cases.md | Cheat sheet for the analytical and specification vocabulary |
| SysML 2.0 Syntax: Items, Parts, Ports, Connections, Interfaces, Allocations | pages/sysml2/sysml2-syntax-structure.md | Cheat sheet for the structural modelling vocabulary |
| SysML 2.0 Systems Model Library: Base Types and Specialisations | pages/sysml2/sysml2-systems-model-library.md | The Systems Model Library provides the base types that every SysML 2.0 keyword implicitly specialises |
| SysML 2.0 Type Hierarchy: DataValue and Occurrence Branches | pages/sysml2/sysml2-type-hierarchy.md | The two disjoint root branches of the type system: DataValue and Occurrence, and what each carries |
<!-- wiki-routing:end -->
