# SySiDE Automator Reference

## Tool Selection Guide

SySiDE offers four complementary tools for SysML v2. Choose based on workflow:

| Workflow | Tool | Licence |
| --- | --- | --- |
| Learning, lightweight editing | **Editor** (VS Code extension) | Free |
| Model writing, diagrams, interactive exploration | **Modeler** (VS Code extension) | Licensed |
| CI/CD validation, headless diagrams | **Modeler CLI** (`syside check`, `syside format`, `syside viz`) | Licensed |
| Programmatic analysis, scripting, report generation | **Automator** (Python library) | Licensed |

**Combined workflows:** use Modeler for visual review and Automator for automated
analysis. Both share the same licence key.

**Decision matrix:**

- "I need to write and visualise models" -> Modeler
- "I need to run queries, extract data, or generate reports from models" -> Automator
- "I need to validate models in CI/CD or generate diagrams headlessly" -> Modeler CLI
- "I am learning SysML v2 or making quick edits" -> Editor (free)
- "I need visual review with automated analysis" -> Modeler + Automator

If you have Modeler, you already have everything Editor offers. Disable the
Editor extension when Modeler is active to avoid conflicts.

Reference: https://docs.sensmetry.com/about/which-tool.html

---

## Installation

**Requirements:** Python 3.12+ (64-bit), internet connectivity for licence
validation.

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate    # Linux/macOS
# .\.venv\Scripts\activate   # Windows

# Install
pip install syside

# Verify
python -c "import syside; print(syside.__version__)"

# Update
pip install syside --upgrade
```

**Additional dependencies for specific workflows:**

```bash
pip install pandas openpyxl          # Requirements Excel import/export
pip install python-statemachine      # State machine simulation
pip install weasyprint               # PDF report generation
sudo apt install graphviz            # Dependency graph rendering
sudo apt install pandoc              # DOCX conversion
```

**Licence setup** (same key as Modeler):

```bash
# Option 1: Environment variable
export SYSIDE_LICENSE_KEY="your-licence-key"

# Option 2: .env file (add .env to .gitignore)
echo "SYSIDE_LICENSE_KEY=your-licence-key" > .env

# Option 3: System keyring
python -c "import keyring; keyring.set_password('license-key.syside', 'license-key', 'your-key')"
```

For CI/CD, use a Deployment Licence Key (prefix `CI-`) stored in the provider's
secret management (GitHub secrets, GitLab CI/CD variables).

Reference: https://docs.sensmetry.com/automator/install.html

---

## Core API

### Loading Models

```python
import syside

# Load from files (primary entry point)
model, diagnostics = syside.load_model(paths=["models/system-requirements.sysml"])

# Load multiple files
model, diagnostics = syside.load_model(
    paths=syside.collect_files_recursively("models/")
)

# Load from string (useful for testing)
model, diagnostics = syside.load_model(
    sysml_source='package P { requirement def R1 { doc /* test */ } }'
)

# Tolerant loading (does not raise on errors)
model, diagnostics = syside.try_load_model(paths=["models/draft.sysml"])

# Check for issues
assert not diagnostics.contains_errors(warnings_as_errors=True)
```

### Querying Elements

```python
# Iterate all elements of a specific type
for req in model.nodes(syside.RequirementDefinition):
    print(req.declared_name, req.qualified_name)

# Include subtypes
for element in model.elements(syside.Element, include_subtypes=True):
    print(element.name)

# Access user documents only (excludes standard library)
for doc_resource in model.user_docs:
    with doc_resource.lock() as doc:
        # work with doc.root_node
        pass

# Filter by document tier (exclude standard library elements)
for part in model.nodes(syside.PartUsage):
    if part.document.document_tier is syside.DocumentTier.Project:
        print(part.name)
```

### Element Properties

```python
element.name                # Basic name
element.qualified_name      # Full hierarchy path
element.declared_name       # Explicitly declared name
element.short_name          # SysML v2 short name (between < >)
element.owner               # Parent element
element.document            # Owning document
element.parent              # Parent AST node
```

### Traversing Relationships

```python
# Children (owned elements)
for child in element.owned_elements.collect():
    print(child.name)

# Navigate upward
if element.owner is not None:
    print(element.owner.name)

# Features and usages
for usage in element.usages.collect():
    print(type(usage).__name__, usage.name)

# Heritage (specialisation, conjugation)
for rel in element.heritage.relationships:
    if isinstance(rel, syside.Redefinition):
        print("Redefines:", rel.first_target.name)

# Type checking
part_def = element.try_cast(syside.PartDefinition)
if part_def is not None:
    print("Is a PartDefinition")

# Alternative type check
if isinstance(element, syside.ActionUsage.STD):
    print("Is an ActionUsage")
```

### Document Locking (Thread Safety)

```python
# Single document
for doc_resource in model.user_docs:
    with doc_resource.lock() as doc:
        for child in doc.root_node.owned_elements.collect():
            print(child.name)

# Multiple documents
from contextlib import ExitStack
with ExitStack() as stack:
    documents = [stack.enter_context(m.lock()) for m in model.user_docs]
    # work with all documents
```

---

## Expression Evaluation

The `Compiler` class evaluates SysML expressions, attribute values, and
metadata filters.

```python
STDLIB = syside.Environment.get_default().lib
compiler = syside.Compiler()
```

### Evaluate Expressions

```python
# Evaluate an attribute's value expression
expr = attribute.feature_value_expression
result, report = compiler.evaluate(expr)
if not report.fatal:
    print(f"Value: {result}")
```

### Evaluate Features (Value Rollup with Units)

```python
# Evaluate a feature in scope (handles redefinitions, unit conversion)
value, report = compiler.evaluate_feature(
    feature=mass_attribute,
    scope=owning_part,
    stdlib=STDLIB,
    experimental_quantities=True,   # enables 10 [kg] expressions
)
if not report.fatal:
    print(f"Mass: {value}")  # value in SI base units
```

### Evaluate Filters (Metadata-Based)

```python
# Check if an element matches a filter expression
result, report = compiler.evaluate_filter(
    target=element,
    filter=filter_expression,
    stdlib=STDLIB,
)
# result is boolean
```

### Supported Operations

All SysML operators except `all` and `~`. Standard library functions:

- **Fully supported:** BaseFunctions, BooleanFunctions, DataFunctions,
  IntegerFunctions, NaturalFunctions, RealFunctions, ScalarFunctions,
  StringFunctions, TrigFunctions, SequenceFunctions
- **Partially supported:** ComplexFunctions (excluding `rect`, `polar`),
  RationalFunctions (excluding `numer`, `denom`, `gcd`)
- **Experimental:** Quantity expressions via `experimental_quantities=True`

---

## Model Modification

### Adding Elements

```python
# Add a new package to a namespace
mem, new_pkg = namespace.children.append(
    syside.OwningMembership, syside.Package
)

# Add a reference (non-owning membership)
_, _ = namespace.children.append(syside.Membership, existing_element)
```

### Removing Elements

```python
namespace.children.remove_element(element)
```

### Creating Documents In-Memory

```python
# Create a new SysML document in memory
doc = syside.Document.create_st(url="memory://generated.sysml")
with doc.lock() as locked:
    # Add elements to the document
    mem, pkg = locked.root_node.children.append(
        syside.OwningMembership, syside.Package
    )
```

### Exporting to Text

```python
# Pretty-print an element to SysML textual notation
text = syside.pprint(element)

# With custom formatting
options = syside.FormatOptions()
printer = syside.ModelPrinter.sysml(format=options)
text = syside.pprint(element, printer=printer)
```

### Debugging Model Structure

```python
# S-expression representation
print(syside.sexp(element, print_references=True))
```

**Constraints:**

- An element can have only one owner (multiple references allowed)
- Moving elements between documents raises `ValueError`
- Adding elements that violate type constraints raises `TypeError`

---

## Element Types Quick Reference

### Definitions (type declarations)

`PartDefinition`, `RequirementDefinition`, `VerificationCaseDefinition`,
`ActionDefinition`, `StateDefinition`, `PortDefinition`,
`InterfaceDefinition`, `UseCaseDefinition`, `EnumerationDefinition`,
`ViewDefinition`, `AttributeDefinition`, `ConnectionDefinition`,
`ConstraintDefinition`, `CalculationDefinition`, `AllocationDefinition`,
`AnalysisCaseDefinition`, `FlowDefinition`, `ItemDefinition`,
`RenderingDefinition`, `ViewpointDefinition`, `DataType`, `Structure`

### Usages (instances)

`PartUsage`, `RequirementUsage`, `VerificationCaseUsage`, `ActionUsage`,
`StateUsage`, `PortUsage`, `AttributeUsage`, `ConnectionUsage`,
`FlowUsage`, `TransitionUsage`, `ItemUsage`, `ReferenceUsage`,
`ConstraintUsage`, `AllocationUsage`, `AnalysisCaseUsage`,
`CalculationUsage`, `CaseUsage`, `InterfaceUsage`, `PerformActionUsage`,
`RenderingUsage`, `SendActionUsage`, `UseCaseUsage`, `ViewUsage`

### Relationships

`Redefinition`, `Subsetting`, `ReferenceSubsetting`, `Specialization`,
`Conjugation`, `Dependency`, `OwningMembership`, `Membership`,
`FeatureTyping`, `FeatureChaining`, `Binding`, `Succession`,
`Association`, `Differencing`, `Disjoining`, `Intersecting`, `Unioning`

### Support Types

`Documentation`, `Element`, `Namespace`, `Type`, `Classifier`, `Feature`,
`Relationship`, `AstNode`, `Package`

### Document Tiers

- `DocumentTier.Project`: user-defined elements
- `DocumentTier.StandardLibrary`: built-in SysML/KerML elements
- `DocumentTier.External`: third-party library elements

---

## Interactive Mode

Launch an interactive Python REPL with a loaded model:

```bash
python -m syside interactive models/system-requirements.sysml
```

Features:

- Validates model on load (displays errors with location)
- Full Python API access via the `model` object
- Single-line and multi-line queries
- Quick inspection without creating scripts

```python
>>> len(list(model.nodes(syside.RequirementDefinition)))
12

>>> for req in model.nodes(syside.RequirementDefinition):
...     print(req.declared_name)
...
```

Exit with `exit`.

---

## Key Patterns for VSE Workflows

### Extract Requirements to Excel

```python
import pandas as pd
import syside

model, diag = syside.load_model(paths=["models/system-requirements.sysml"])
assert not diag.contains_errors(warnings_as_errors=True)

data = []
for req in model.nodes(syside.RequirementDefinition):
    for doc in req.documentation.collect():
        data.append({"ID": req.declared_name, "Requirement": doc.body})
df = pd.DataFrame(data)
df.to_excel("build/requirements.xlsx", index=False)
```

### Import Requirements from Excel

```python
import pandas as pd
import syside

df = pd.read_excel("requirements.xlsx")
doc = syside.Document.create_st(url="memory://imported.sysml")
with doc.lock() as locked:
    mem, pkg = locked.root_node.children.append(
        syside.OwningMembership, syside.Package
    )
    for _, row in df.iterrows():
        mem, req = pkg.children.append(
            syside.OwningMembership, syside.RequirementDefinition
        )
        # Set requirement name, add documentation
print(syside.pprint(locked.root_node))
```

### Walk Part Hierarchy

```python
import syside

model, _ = syside.load_model(paths=["models/architecture.sysml"])

def walk(element, level=0):
    if element.try_cast(syside.PartUsage):
        print("  " * level, element.name)
    for child in element.owned_elements.collect():
        if child.document.document_tier is syside.DocumentTier.Project:
            walk(child, level + 1)

for doc_res in model.user_docs:
    with doc_res.lock() as doc:
        walk(doc.root_node)
```

### Check Trace Links Programmatically

```python
import syside

model, diag = syside.load_model(
    paths=syside.collect_files_recursively("models/")
)

gaps = []
for req in model.nodes(syside.RequirementDefinition):
    has_satisfy = False
    has_verify = False
    for rel in req.owned_elements.collect():
        if isinstance(rel, syside.Subsetting):
            # Check for satisfy/verify relationships
            pass
    # Alternatively, check heritage relationships
    for child in req.owned_elements.collect():
        if child.try_cast(syside.RequirementUsage):
            # This is a satisfy link
            has_satisfy = True
    if not has_satisfy:
        gaps.append(f"{req.declared_name}: missing satisfy link")

for gap in gaps:
    print(gap)
```

### Value Rollup with Unit Conversion

```python
import syside

model, _ = syside.load_model(paths=["models/architecture.sysml"])
STDLIB = syside.Environment.get_default().lib
compiler = syside.Compiler()

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

### Extract Documentation

```python
import syside

model, _ = syside.load_model(paths=["models/system-requirements.sysml"])

for doc_elem in model.nodes(syside.Documentation):
    if doc_elem.owner and doc_elem.owner.qualified_name:
        about = str(doc_elem.owner.qualified_name)
        print(f"Documentation about {about}: {doc_elem.body}")
```

---

## Report Generation Pipeline

For generating professional documents from SysML models, the Automator
supports a Jinja2-based report generation pipeline:

**Project structure:**

```
project/
  models/
    *.sysml                     # SysML model files
    requirements-spec.md        # Jinja2 template
  scripts/
    generate_docs.py            # Generation script
  assets/
    styles.css                  # PDF/HTML styling
    template.docx               # DOCX reference template
    logo.png                    # Company logo
  metadata/
    versions.json               # Revision history
```

**Template functions available:**

- `get_children_with_attributes(root_package, metatype, attributes)`:
  extract elements with specified attributes
- `generic_table(columns, rows, flipRowsAndCols, widths)`:
  format data as HTML table
- `traceability_matrix(row_package, col_package)`:
  build allocation matrix with X marks
- `repeat_for_each_item(data_source, sections)`:
  iterate over data, render sections per item
- `title()`, `toc()`, `page_break()`, `revision_history()`, `changelog()`

**Attribute extraction types:**

- `"ElementName"`: element name
- `"Documentation"`: doc blocks (use `""` for unnamed, or named like `"Description"`)
- `"AttributeUsage"`: named attribute values
- `"OwningNamespace"`: parent namespace qualified name
- `"Req_Parents"`: parent requirements via derivation
- `"Req_Derivations"`: child requirements via derivation
- `"Req_Implemented"`: allocated components
- `"Req_Verified"`: verification elements
- `"Req_DependencyGraph"`: SVG derivation tree

**Running the generator:**

```bash
python scripts/generate_docs.py --output ./build
python scripts/generate_docs.py --output ./build --update-version
```

Reference: https://docs.sensmetry.com/examples/report_generation.html

---

## API Reference

Full API documentation: https://docs.sensmetry.com/python/latest/index.html

Key pages:

- Model structure: https://docs.sensmetry.com/python/latest/structure.html
- Expression evaluation: https://docs.sensmetry.com/python/latest/evaluation.html
- Textual notation: https://docs.sensmetry.com/python/latest/textual.html
- JSON import/export: https://docs.sensmetry.com/python/latest/json.html
- Examples: https://docs.sensmetry.com/examples/index.html
