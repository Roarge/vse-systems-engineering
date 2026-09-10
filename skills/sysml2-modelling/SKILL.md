---
name: sysml2-modelling
description: The SysML 2.0 workbench and umbrella router. Owns project layout, CI validation, and the top-level syntax quick reference, routes toolchain installation and configuration to sysml-toolchain, and routes topic authoring to the focused siblings.
when_to_use: Use when the SysML topic is not yet clear, when creating or editing .sysml files generally, when checking syntax, when navigating or querying a model, or when a toolchain question is not yet specific enough to route to `@sysml-toolchain`. Route to the sibling that owns the topic once it is clear.
paths: ["**/*.sysml"]
user-invocable: true
---

# SysML 2.0 Modelling

A `methodology/` folder at the project root, or under `engineering/`, marks a VSE project. If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first. In a SysML-only repository with no `methodology/` folder, skip the lens and proceed directly with this skill.

You are the modelling workbench for SysML 2.0 textual notation. You guide
authoring of .sysml files, validate syntax against the OMG specification, and
provide templates for common model elements. The full SysML 2.0 reference set
plus the toolchain reference (Syside, the OMG pilot, OpenSysML) lives in
the plugin wiki, as atomic pages under the `wiki/pages/sysml2/` and
`wiki/pages/tooling/` layers.

## When This Skill Triggers

- The user asks to create or edit a SysML 2.0 model
- The user asks about SysML 2.0 syntax at the project level
- The user wants to navigate or query existing models
- The user asks about validation or CI and the toolchain is not yet the
  question (toolchain work routes to `@sysml-toolchain`)
- Any other skill needs to create model elements
- The user has a SysML question but the topic is not yet clear

## Routing to Focused Siblings

This skill is the workbench and the router. For topic-specific
authoring, hand off to one of the focused siblings, and for toolchain
work to `@sysml-toolchain`. Keep the umbrella active if the engineer
moves between topics in one session.

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
| Toolchain choice, installation, switching, licence problems, the validator wrapper, `syside.toml`, `.lsp.json` | `@sysml-toolchain` | Choosing or installing Syside, the OMG pilot, or OpenSysML, a licence failure, or running validation by hand |

The umbrella still owns project layout, the validation checklist, and
the high-level quick reference. `@sysml-toolchain` owns the toolchains
themselves.

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
2021, Ch 14-16, Ch 35, VAMOS 2016, and ISO/IEC 29110.

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

// Verification (a case verifies a member of a story usage, by dot
// notation, inside a `verification def` objective, per §5.4.6)
objective { verify SystemStories::SYS_001_StoryName.acceptance; }

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

- **Find all requirements**: `Grep for "requirement def" and "requirement <ID> : UserStory" in model/**/*.sysml`
- **Find all parts**: `Grep for "part def" in model/**/*.sysml`
- **Find all verification cases**: `Grep for "verification def" in model/**/*.sysml`
- **Find trace links**: `Grep for "satisfy \|verify " in model/**/*.sysml`
- **Find a specific element**: `Grep for the element name in model/**/*.sysml`

## Tooling

The toolchain is a project decision rather than this skill's. A project
records `sysml_toolchain` in `.iso-config.yaml`, and the hooks and the
CI read that key, falling back along syside, omg-pilot, opensysml when
the preferred tool is unavailable. Prefer the recorded tool in every
command you suggest, and never assume Syside is installed.

| Toolchain | Validate | Format | Language server | Diagrams | Scripting |
| --- | --- | --- | --- | --- | --- |
| Syside 0.10.3 (`syside`) | `syside check` | `syside format` | `syside lsp` | `syside viz` (Labs) | Automator Python |
| OMG SysML v2 Pilot Implementation 2026-07 (`omg-pilot`) | `SysMLInteractive` in batch | none | none | `%viz` in Jupyter only | `SysML2JSON` export |
| OpenSysML v0.6.0 (`opensysml`) | `sysml -validate -strict` | none | `sysml-lsp` | `-render` to text, Mermaid or Markdown | gRPC, Python, Node, Java, Rust |

For installation, licence setup, the validator wrapper, `syside.toml`,
`.lsp.json`, each CLI, and the Automator API, route to
`@sysml-toolchain`. The rules the reference implementations enforce are
on the `tooling-reference-implementation-rules` page routed below.

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
| Systems Modeling API and Services | pages/sysml2/sysml2-api-and-services.md | The Systems Modeling API and Services, its PIM data structures and services for tool-independent model access |
| SysML 2.0 Domain Libraries: Causation, Derivation, Geometry | pages/sysml2/sysml2-domain-libraries-causation-geometry.md | The Cause and Effect, Requirement Derivation, and Geometry domain libraries |
| SysML 2.0 Domain Libraries: Metadata and Analysis | pages/sysml2/sysml2-domain-libraries-metadata-analysis.md | The Metadata and Analysis domain libraries, covering status, risk, tool execution, and trade studies |
| SysML 2.0 Grammar Excerpts, Well-Formedness, and Validation Checklist | pages/sysml2/sysml2-grammar-and-validation.md | SysML 2.0 grammar excerpts, well-formedness rules, and a model validation checklist |
| SysML 2.0 Language Architecture: KerML, Definition/Usage, Implicit Specialisation | pages/sysml2/sysml2-language-architecture.md | The two-layer KerML and SysML architecture, the definition and usage pattern, and implicit specialisation |
| SysML 2.0 Library Architecture: Systems Model Library and Domain Libraries | pages/sysml2/sysml2-libraries-architecture.md | The implicit Systems Model Library and the Domain Libraries a project imports explicitly |
| SysML 2.0 Library Import Patterns and VSE Selection Guide | pages/sysml2/sysml2-library-import-patterns.md | Import patterns for the domain libraries, organised by use case and ISO/IEC 29110 phase |
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
| Syside Automator Core API | pages/tooling/syside-core-api.md | Loading, querying, and traversing SysML 2.0 models from the Syside Automator Python library |
| Syside Expression Evaluation and Compiler | pages/tooling/syside-expression-evaluation.md | Evaluating SysML expressions, feature values with units, requirements, and metadata filters |
| Syside Model Modification and Element Reference | pages/tooling/syside-model-modification.md | Adding, removing, and exporting model elements through the Syside API, with an element type reference |
| Syside Project Configuration: syside.toml and .lsp.json | pages/tooling/syside-project-configuration.md | Three-level syside.toml discovery, merge semantics, the format, lsp, lint and telemetry sections, and .lsp.json |
| Sysand Package Management for SysML v2 | pages/tooling/syside-sysand-package-management.md | Sysand manifests, the lock file, KPAR packaging, the public index, and CI publishing for SysML v2 |
| Syside Tooling Overview and Installation | pages/tooling/syside-tooling-overview.md | Choosing between Syside Editor, Pro Suite, Cloud, and Derisker, plus installation and licence setup |
| Syside VSE Workflows and Report Generation | pages/tooling/syside-vse-workflows.md | Syside workflows for requirement round-trips, grid views, hierarchy walks, trace checks, CI, and reports |
| OMG SysML v2 Pilot Implementation: installation and batch validation | pages/tooling/tooling-omg-pilot-batch-validation.md | Installing the OMG SysML v2 Pilot Implementation and validating a model through SysMLInteractive in batch |
| OpenSysML: installation, CLI validation, and language server | pages/tooling/tooling-opensysml-cli.md | Installing OpenSysML, validating with sysml -validate, its exit codes, and wiring sysml-lsp as the editor server |
| SysML v2 rules the reference implementations enforce | pages/tooling/tooling-reference-implementation-rules.md | SysML v2 forms the pilot and OpenSysML refuse or accept, from subject ordering to derivation and enum literals |
| Choosing a SysML v2 toolchain: Syside, OMG pilot, OpenSysML | pages/tooling/tooling-sysml-toolchain-choice.md | Choosing between Syside, the OMG pilot, and OpenSysML, their licences, capabilities, and the fallback order |
<!-- wiki-routing:end -->
