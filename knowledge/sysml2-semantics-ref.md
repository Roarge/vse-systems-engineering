# SysML v2 Semantics and Type System Reference

Source: OMG Systems Modeling Language v2.0, March 2023 (formal/2025-01-01).
Covers type hierarchy, semantic rules, and EBNF grammar from Chapters 6 and 8.
Items marked *syntax to be verified* require further checking.

---

## 1. Language Architecture (Ch 6)

SysML v2 is a two-layer language. The Kernel Modeling Language (KerML) provides
the core metamodel: types, features, classifiers, and relationships. SysML
extends KerML with systems engineering constructs such as parts, ports, actions,
requirements, and verification cases. A VSE engineer authors .sysml files, but
the underlying semantics are defined by KerML.

### 1.1 The Definition/Usage Pattern

This is the central organising principle of SysML v2. Definitions (KerML
Classifiers) declare reusable types. Usages (KerML Features) create instances
of those types within a context.

- `part def Vehicle` is a **definition**. It declares a reusable type.
- `part myVehicle : Vehicle` is a **usage**. It instantiates that type.

Definitions own features that describe the structure and behaviour of the type.
Usages own features that describe the specific instance. Every usage must be
typed by at least one definition (or by an implicit library type if none is
given).

### 1.2 Implicit Library Specialisation

Every user-defined SysML type implicitly specialises a base type from the
Systems Model Library (Ch 9) via `specializeFromLibrary()` constraints. This
means that even a bare `part def Sensor;` automatically specialises
`Parts::Part`, which in turn specialises `Items::Item`, `Objects::Object`, and
`Occurrences::Occurrence`. The engineer does not need to write these
specialisations. They are applied automatically by the language.

This matters for validation: a tool can check whether a model element conforms
to the semantic rules of its implicit base type without any explicit annotation
from the engineer.

### 1.3 Conformance Levels

The specification defines five conformance levels: Abstract Syntax (metamodel
structure), Concrete Syntax in both Textual and Graphical forms, Semantic
(meaning and well-formedness rules), and Model Interchange (JSON-based API).
For a VSE, the most relevant levels are Textual Concrete Syntax (what you
write) and Semantic (what the rules enforce). This reference covers the
Semantic level. The companion quick reference covers Textual Concrete Syntax.

---

## 2. Type Hierarchy

### 2.1 The Two Disjoint Branches

The SysML type system has two fundamental branches that cannot overlap:

- **DataValue branch** (attributes, enumerations): things that have no
  independent existence, no lifecycle, and no spatial extent.
- **Occurrence branch** (parts, ports, actions, states, etc.): things that
  exist in time and space, have lifecycles, and can participate in
  interactions.

**Key rule: DataValue and Occurrence are disjoint.** You cannot define something
that is both an attribute and a part. An attribute cannot own composite
features. This rule is the single most common source of validation errors for
new modellers.

### 2.2 Hierarchy Tree

```
Base::Anything
 +-- Base::DataValue
 |    +-- AttributeDefinition
 |    +-- EnumerationDefinition (always isVariation=true)
 |
 +-- Occurrences::Occurrence
      +-- OccurrenceDefinition
           +-- Items::Item (specialises Objects::Object)
           |    +-- ItemDefinition
           |    +-- Parts::Part (specialises Items::Item)
           |         +-- PartDefinition
           |         +-- Connections::Connection (also Links::LinkObject)
           |         |    +-- ConnectionDefinition
           |         |    +-- Interfaces::Interface (ends must be PortUsages)
           |         |    |    +-- InterfaceDefinition
           |         |    +-- Allocations::Allocation (binary)
           |         |         +-- AllocationDefinition
           |         +-- Views::View
           |         |    +-- ViewDefinition
           |         +-- Views::Rendering
           |              +-- RenderingDefinition
           |
           +-- Objects::Object
           |    +-- Ports::Port
           |         +-- PortDefinition
           |
           +-- Performances::Performance
                +-- Actions::Action
                     +-- ActionDefinition
                     +-- States::StateAction
                     |    +-- StateDefinition
                     +-- Calculations::Calculation (also Evaluations::Evaluation)
                          +-- CalculationDefinition
                          +-- Constraints::ConstraintCheck (BooleanEvaluation)
                          |    +-- ConstraintDefinition
                          |    +-- Requirements::RequirementCheck
                          |         +-- RequirementDefinition
                          |         +-- Requirements::ConcernCheck
                          |         |    +-- ConcernDefinition
                          |         +-- Views::ViewpointCheck
                          |              +-- ViewpointDefinition
                          +-- Cases::Case
                               +-- CaseDefinition
                               +-- AnalysisCases::AnalysisCase
                               |    +-- AnalysisCaseDefinition
                               +-- VerificationCases::VerificationCase
                               |    +-- VerificationCaseDefinition
                               +-- UseCases::UseCase
                                    +-- UseCaseDefinition
```

### 2.3 Summary Table

| Definition Keyword | Implicit Base Type | Branch | Key Constraint |
|---|---|---|---|
| `attribute def` | Base::DataValue | DataValue | Always referential, no composite features |
| `enum def` | variation AttributeDefinition | DataValue | isVariation=true always |
| `occurrence def` | Occurrences::Occurrence | Occurrence | General occurrence |
| `item def` | Items::Item | Occurrence | Specialises Objects::Object |
| `part def` | Parts::Part | Occurrence | Composite by default |
| `port def` | Ports::Port | Occurrence | Boundary feature, supports conjugation |
| `connection def` | Connections::Connection | Occurrence | At least 2 ends (unless abstract) |
| `interface def` | Interfaces::Interface | Occurrence | Ends must be PortUsages |
| `allocation def` | Allocations::Allocation | Occurrence | Binary connection |
| `action def` | Actions::Action | Occurrence | Owns subactions, successions, control nodes |
| `state def` | States::StateAction | Occurrence | Exclusive substates unless parallel |
| `calc def` | Calculations::Calculation | Occurrence | Has result parameter |
| `constraint def` | Constraints::ConstraintCheck | Occurrence | Boolean evaluation |
| `requirement def` | Requirements::RequirementCheck | Occurrence | Has subject, assume/require structure |
| `concern def` | Requirements::ConcernCheck | Occurrence | Specialises RequirementCheck |
| `case def` | Cases::Case | Occurrence | Specialises Calculation |
| `analysis def` | AnalysisCases::AnalysisCase | Occurrence | Specialises Case |
| `verification def` | VerificationCases::VerificationCase | Occurrence | Specialises Case, verify link |
| `use case def` | UseCases::UseCase | Occurrence | Specialises Case |
| `view def` | Views::View | Occurrence | Specialises Part |
| `viewpoint def` | Views::ViewpointCheck | Occurrence | Specialises RequirementCheck |
| `rendering def` | Views::Rendering | Occurrence | Specialises Part |

---

## 3. Core Semantic Rules (Ch 8.4)

### 3.1 Specialisation

Specialisation creates subtype relationships. SysML v2 enforces a strict rule:
definitions specialise definitions, and usages specialise usages. You cannot
have a usage specialise a definition or vice versa.

- **`:>` (specializes)** creates a subtype relationship. The specialising type
  inherits all features of the general type.
- **`:>>` (redefines)** replaces an inherited feature with a more specific one.
  The redefined feature must be type-compatible with the original.
- **`subsets`** declares that a usage is a subset of another collection. The
  subsetting usage's values are always a subset of the subsetted usage's values.

Practical rule: use `:>` to create subtypes of definitions. Use `:>>` inside a
specialisation to override an inherited feature with a more specific type or
value.

### 3.2 Ownership and Composition

Parts are **composite** (owned) by default. Destroying the owner destroys the
part. This models physical containment: a vehicle owns its engine. If the
vehicle ceases to exist, its engine (as a part of that vehicle) also ceases to
exist.

The `ref` keyword makes a usage **referential** (non-composite). The referenced
element exists independently of the referencing context. Use `ref` for
associations such as "the driver of the vehicle", where the person exists
independently.

**Critical rule:** Attributes are ALWAYS referential. The
`validateAttributeUsageIsReference` constraint enforces this. An attribute
definition cannot contain composite parts. If you need a structured element
that owns other composite elements, use a `part def` instead of an
`attribute def`.

### 3.3 Typing

A usage can be typed by one or more definitions. Multiple typing is written as
`part x : TypeA, TypeB`. The usage then conforms to the intersection of all
typing constraints.

Port conjugation (`~PortType`) reverses all `in`/`out` directions on a port
type. When two parts communicate, one typically has the original port type and
the other has the conjugated port type. The conjugated port definition is
generated automatically by the language.

### 3.4 Feature Values

Three kinds of value binding exist in SysML v2:

| Operator | Name | Semantics |
|----------|------|-----------|
| `=` | Bound value | Fixed at definition time. Can never change. |
| `:=` | Initial value | Set at creation time. Can change afterwards. |
| `default` | Default value | Applied if no more specific value is given. Can be overridden by specialisation. |

Choosing the right operator matters for verification. A bound value (`=`) is a
design constraint that the system must always satisfy. An initial value (`:=`)
is a starting condition. A default value provides a fallback that downstream
specialisations may override.

---

## 4. Structural Semantics

### 4.1 Parts

Parts model composite ownership with lifecycle coupling. A part's lifecycle is
bounded by its owner's lifecycle. If a `part def Vehicle` owns a
`part engine : Engine`, then every Vehicle instance has its own Engine instance
that cannot outlive the owning Vehicle. For shared resources (a sensor used by
multiple subsystems), model the reference as `ref part` in each subsystem and
place composite ownership in the system that physically contains the sensor.

### 4.2 Ports

Ports are boundary features defining interaction points. Semantic rules:
- Nested usages that are not PortUsages must be referential (non-composite).
- Conjugated ports (`~PortType`) reverse all `in`/`out` directions. A
  ConjugatedPortDefinition is generated automatically for every PortDefinition.
- Directed features (`in`, `out`, `inout`) specify flow direction through the
  port.

### 4.3 Connections

Connections must have at least two `connectionEnd` features unless marked
`abstract`. Binary connections redefine `source` and `target` from
`Links::BinaryLink`.

### 4.4 Binding Connectors

Binding connectors assert that two features always have the same value. Based
on `Links::selfLink`. Use them for identity constraints.

### 4.5 Interfaces

Interfaces are ConnectionDefinitions whose ends must be PortUsages. Use them
when connecting ports specifically.

### 4.6 Allocations

Allocations are binary ConnectionDefinitions for cross-concern mapping (for
example, logical function to physical element). They have exactly two ends.

### 4.7 Successions

Successions express temporal ordering via `Occurrences::happensBeforeLinks`.
`first A then B` means A must complete before B starts.

---

## 5. Behavioural Semantics

### 5.1 Actions

Actions model behaviour that transforms inputs to outputs over time:

- Parameters of a specialising action must redefine corresponding parameters
  of the specialised Behaviour.
- Actions own subactions, successions, and control nodes (fork, join, decide,
  merge).
- The `start` and `done` features mark lifecycle boundaries. `first start then
  X` means X begins when the action starts. `first Y then done` means the
  action completes when Y completes.

### 5.2 States

States model behaviour that persists over time and transitions based on events
or conditions:

- **Exclusive substates:** In a non-parallel state definition, only one
  substate can be active at any time.
- **Parallel states:** Substates represent concurrent regions, all active
  simultaneously.
- **Entry/do/exit actions** redefine features of StateAction.
- Transitions may include triggers (`accept`), guards (`if`), and effects
  (`do action`).

### 5.3 Calculations

Calculations specialise both Actions and Evaluations. The `result` parameter
must redefine the result parameter of the specialised Function. The result
expression is the last expression in the body and does not require trailing
punctuation. Calculations can be used as expressions within other calculations
or constraints.

### 5.4 Constraints

Constraints evaluate to a Boolean value. An **assert constraint** subsets
`trueEvaluations` (must always hold true). A **negated assert constraint**
(`assert not constraint`) subsets `falseEvaluations` (must never hold true).
Constraints are the foundation for requirements, as RequirementCheck specialises
ConstraintCheck.

---

## 6. Requirements Semantics

### 6.1 Structure

RequirementDefinition specialises ConstraintCheck. The fundamental semantic
rule of a requirement is:

```
allTrue(assumptions) implies allTrue(constraints)
```

That is, if all assumed constraints hold, then all required constraints must
hold. This formalises the natural language pattern "given that [assumptions],
the system shall [requirements]."

### 6.2 Subject

The `subjectParameter` must be the first parameter of a requirement. It
identifies what the requirement is about (typically the System of Interest or
one of its elements). Always declare the subject explicitly, as this makes
satisfaction bindings unambiguous.

### 6.3 Actors and Stakeholders

- **Actors** are parts that interact with the subject (for example, a user or
  an external system).
- **Stakeholders** are concerned parties who have an interest in the
  requirement being satisfied but do not directly interact with the subject.

### 6.4 Assume vs Require

- `assume constraint` defines preconditions that must hold for the requirement
  to be applicable.
- `require constraint` defines the actual obligation that the system must
  satisfy.

The requirement is considered satisfied when the implication holds: if the
assumptions are true, then the required constraints are true. If the
assumptions are false, the requirement is vacuously satisfied (this is standard
logical implication).

### 6.5 Satisfaction

`SatisfyRequirementUsage` creates a BindingConnector between the
`subjectParameter` and the `satisfyingFeature`. The statement
`satisfy requirement R by part P` binds P as the subject of R. For VSE
traceability, every system requirement should have at least one satisfaction
link.

### 6.6 Verification

VerificationCaseDefinition specialises CaseDefinition. A verification case has
an objective that must contain a `verify` link to one or more requirements. The
verification case determines whether the requirement is met.

Verdicts use the `VerdictKind` enumeration:

| Verdict | Meaning |
|---------|---------|
| `pass` | The requirement is verified as satisfied |
| `fail` | The requirement is verified as not satisfied |
| `inconclusive` | The verification could not determine the result |
| `error` | The verification process itself encountered an error |

### 6.7 Variations

EnumerationDefinition is always `isVariation=true`. All owned members of a
variation must be variant usages. Each variant must specialise its owning
variation.

Variations are also used outside enumerations. A `variation part def` declares
a set of alternative configurations. Each `variant` member represents one
alternative. Variations are useful for trade studies in SR.3 (Architecture).

---

## 7. EBNF Grammar Excerpts (Ch 8.2)

### 7.1 Notation Conventions

The specification EBNF uses: `LEXICAL_ELEMENT` (all capitals) for lexical
terminals, `'terminal'` for literal keywords, `NonterminalElement` for grammar
rules. `|` denotes alternatives, `?` optional, `*` zero-or-more, `+`
one-or-more. `p = Element` assigns a result, `p += Element` adds to a list,
`p ?= Element` sets a Boolean.

### 7.2 Special Lexical Terminals

Several relationship keywords have both symbolic and verbose forms. The grammar
defines these as special lexical terminals:

| Terminal | Symbolic Form | Verbose Form |
|----------|--------------|--------------|
| `DEFINED_BY` | `:` | `defined by` |
| `SPECIALIZES` | `:>` | `specializes` |
| `SUBSETS` | `:>` | `subsets` |
| `REFERENCES` | `::>` | `references` |
| `REDEFINES` | `:>>` | `redefines` |

Note that `SPECIALIZES` and `SUBSETS` share the same symbolic form (`:>`). The
parser disambiguates based on context: `:>` after a definition keyword is
specialisation, while `:>` after a usage keyword in certain contexts is
subsetting. In practice, prefer the verbose forms `specializes` and `subsets`
when ambiguity might confuse a human reader.

### 7.3 Reserved Keywords

The SysML v2 grammar reserves 97 keywords that cannot be used as unquoted
identifiers. If you must use a reserved word as a name, enclose it in single
quotes (for example, `'system'`).

Common keywords that VSE engineers are likely to encounter as naming conflicts:
`action`, `attribute`, `block`, `case`, `comment`, `connection`, `constraint`,
`default`, `end`, `event`, `flow`, `frame`, `import`, `in`, `interface`,
`item`, `language`, `merge`, `message`, `not`, `occurrence`, `of`, `or`, `out`,
`package`, `part`, `port`, `ref`, `render`, `requirement`, `return`, `send`,
`state`, `subject`, `to`, `use`, `variation`, `view`, `while`.

The full list of all 97 keywords is in the SysML v2 specification, Ch 8.2.

### 7.4 Key Grammar Productions (Simplified)

Simplified from the full EBNF in Ch 8.2 to show patterns relevant to model
authoring. Non-essential alternatives and deeply nested rules are omitted.

**Package:**

```ebnf
PackageDefinition =
    'package' Identification? PackageBody ;

PackageBody =
    '{' ( PackageMember | Import | Alias )* '}' ;
```

**Import:**

```ebnf
Import =
    Visibility? 'import' 'all'? ImportTarget ';' ;

ImportTarget =
    QualifiedName '::' ( '*' | '**' )
  | QualifiedName ;
```

The `*` form imports direct members, `**` imports recursively, and `all`
includes private members.

**Definition (general pattern):**

```ebnf
DefinitionElement =
    DefinitionKeyword Identification?
    ( SPECIALIZES QualifiedName ( ',' QualifiedName )* )?
    DefinitionBody ;

DefinitionBody =
    '{' DefinitionBodyItem* '}'
  | ';' ;
```

Where `DefinitionKeyword` is one of: `part def`, `port def`, `action def`,
`requirement def`, and so on (27 definition types total).

**Usage (general pattern):**

```ebnf
UsageElement =
    'ref'? UsageKeyword Identification?
    ( DEFINED_BY QualifiedName ( ',' QualifiedName )* )?
    ( SPECIALIZES QualifiedName )?
    Multiplicity?
    FeatureValue?
    UsageBody ;

UsageBody =
    '{' UsageBodyItem* '}'
  | ';' ;
```

**Feature Value:**

```ebnf
FeatureValue =
    '=' Expression
  | ':=' Expression
  | 'default' '='? Expression ;
```

**Requirement:**

```ebnf
RequirementDefinition =
    'requirement' 'def' Identification?
    ( SPECIALIZES QualifiedName )?
    RequirementBody ;

RequirementBody =
    '{' ( 'doc' Comment
        | 'subject' UsageElement
        | 'actor' UsageElement
        | 'stakeholder' UsageElement
        | 'assume' 'constraint' ConstraintBody
        | 'require' 'constraint' ConstraintBody
        | RequirementBodyItem )* '}' ;
```

The full grammar contains additional alternatives for metadata, comments, and
nested elements.

---

## 8. Well-Formedness Summary

Common validation errors a VSE engineer is likely to encounter, with semantic
causes and recommended fixes. These correspond to the `validate*` constraints
in Ch 8.4.

| Error | Semantic Cause | Fix |
|-------|---------------|-----|
| Attribute with composite feature | `validateAttributeUsageIsReference`: attributes are always referential and cannot own composite parts or items | Move the composite feature to a `part def`, or mark the nested usage with `ref` |
| Port with composite non-port nested usage | Port nested usages that are not PortUsages must be referential | Add `ref` to the nested usage, or restructure it as a port |
| Connection with fewer than 2 ends | Non-abstract connections require at least 2 `connectionEnd` features | Add the missing end feature, or mark the connection `abstract` |
| Enumeration not a variation | `EnumerationDefinition` must always have `isVariation=true` | This is normally automatic. Check whether you are using `enum def` correctly |
| Requirement without subject | The `subjectParameter` should be the first parameter | Add a `subject` declaration at the top of the requirement body |
| Assert constraint evaluating to false | Assert constraints must subset `trueEvaluations` (always true) | Fix the constraint expression, or correct the model values that violate it |
| Cross-hierarchy specialisation | DataValue and Occurrence are disjoint branches | Do not specialise an `attribute def` from a `part def` or vice versa |
| Variation member not a variant | All owned members of a variation definition must be `variant` usages | Add the `variant` keyword to each member of the variation |
| Missing verify link in verification case | Verification case objective should contain `verify requirement` | Add `verify requirement <name>` inside the `objective` block |
| Usage specialising a definition | Usages specialise usages, definitions specialise definitions | Use `:` (typing) to type a usage by a definition, not `:>` (specialisation) |
| Redefinition type mismatch | A redefining feature must be type-compatible with the redefined feature | Ensure the new type is a subtype of the original feature's type |
| Multiple subjects in one requirement | A requirement may have only one subject parameter | Remove the extra subject declarations and keep only one |

### 8.1 Validation Checklist for VSE Engineers

Before committing a model file, verify the following:

1. **Every part usage** is either composite (default) or explicitly marked
   `ref`. Unintended composite ownership causes lifecycle coupling.
2. **Every attribute definition** contains only referential features. If you
   need composite sub-elements, use a `part def`.
3. **Every requirement** has an explicit `subject`, at least one `require
   constraint`, and traces upward (satisfy link) and downward (verify link).
4. **Every connection** has at least two ends, or is marked `abstract`.
5. **Every enumeration member** uses the `variant` keyword.
6. **Every verification case objective** contains a `verify` link to the
   requirement it verifies.
7. **No cross-branch specialisation** exists between DataValue types and
   Occurrence types.
8. **Reserved keywords** used as names are enclosed in single quotes.

---

## 9. Practical Implications for VSE Modelling

### 9.1 When to Use Each Branch

| Situation | Use | Reason |
|-----------|-----|--------|
| Physical component with lifecycle | `part def` | Composite ownership, occurrence semantics |
| Measured quantity (mass, voltage) | `attribute def` | DataValue, no lifecycle |
| Enumerated choices | `enum def` | Variation over DataValue |
| Interaction point on a boundary | `port def` | Port semantics, supports conjugation |
| Mapping logical to physical | `allocation def` | Binary connection for cross-concern tracing |
| Behavioural step in a process | `action def` | Action semantics, parameters, successions |
| System mode or operating condition | `state def` | State semantics, transitions, exclusivity |
| Testable condition | `constraint def` | Boolean evaluation |
| Stakeholder need or system obligation | `requirement def` | Assume/require structure, satisfaction |
| Test procedure | `verification def` | Case semantics with verify link |

### 9.2 Common Modelling Mistakes

1. **Using attribute where part is needed.** If an element needs to own
   composite sub-elements, it must be a `part def`. Attributes cannot own
   composite features.
2. **Forgetting `ref` for shared references.** Without `ref`, each owning part
   gets a separate composite instance rather than a shared reference.
3. **Omitting the subject in requirements.** Syntactically valid, but makes
   satisfaction bindings ambiguous.
4. **Using `:>` where `:` is needed.** Typing uses `:` (defined by).
   Specialisation between usages uses `:>`. Confusing these produces a
   cross-hierarchy error.
5. **Mixing DataValue and Occurrence.** An attribute typed by a part
   definition, or vice versa, will fail validation.

---

*Generated from OMG SysML v2.0 specification Chapters 6 and 8 for use with the VSE Systems Engineering plugin.*
