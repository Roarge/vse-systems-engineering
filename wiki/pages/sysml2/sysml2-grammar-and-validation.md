---
title: "SysML 2.0 Grammar Excerpts, Well-Formedness, and Validation Checklist"
slug: sysml2-grammar-and-validation
type: reference
layer: sysml2
tags: [ebnf, grammar, validation, well-formedness, vse-checklist]
sources:
  - citation: "OMG (2023). OMG Systems Modeling Language v2.0, formal/2025-01-01. Chapter 8.2 and 8.4."
    raw: 2-OMG_Systems_Modeling_Language.pdf
related:
  - sysml2-language-architecture
  - sysml2-type-hierarchy
  - sysml2-specialisation-and-typing
  - sysml2-requirements-semantics
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [sysml2-modelling]
---

# SysML 2.0 Grammar Excerpts, Well-Formedness, and Validation Checklist

## Notation conventions (8.2)

The OMG SysML 2.0 specification EBNF uses:

- `LEXICAL_ELEMENT` (all capitals) for lexical terminals
- `'terminal'` for literal keywords
- `NonterminalElement` for grammar rules
- `|` for alternatives, `?` optional, `*` zero-or-more, `+`
  one-or-more
- `p = Element` assigns a result, `p += Element` adds to a list,
  `p ?= Element` sets a Boolean

## Special lexical terminals

Several relationship keywords have both symbolic and verbose
forms. The grammar defines these as special lexical terminals:

| Terminal | Symbolic form | Verbose form |
|---|---|---|
| `DEFINED_BY` | `:` | `defined by` |
| `SPECIALIZES` | `:>` | `specializes` |
| `SUBSETS` | `:>` | `subsets` |
| `REFERENCES` | `::>` | `references` |
| `REDEFINES` | `:>>` | `redefines` |

`SPECIALIZES` and `SUBSETS` share the same symbolic form (`:>`).
The parser disambiguates based on context: `:>` after a definition
keyword is specialisation, `:>` after a usage keyword in certain
contexts is subsetting. **In practice, prefer the verbose forms**
`specializes` and `subsets` when ambiguity might confuse a human
reader.

## Reserved keywords

The SysML 2.0 grammar reserves 97 keywords that cannot be used as
unquoted identifiers. If you must use a reserved word as a name,
enclose it in single quotes (`'system'`).

Common keywords that VSE engineers are likely to encounter as
naming conflicts: `action`, `attribute`, `block`, `case`,
`comment`, `connection`, `constraint`, `default`, `end`, `event`,
`flow`, `frame`, `import`, `in`, `interface`, `item`, `language`,
`merge`, `message`, `not`, `occurrence`, `of`, `or`, `out`,
`package`, `part`, `port`, `ref`, `render`, `requirement`,
`return`, `send`, `state`, `subject`, `to`, `use`, `variation`,
`view`, `while`.

## Key grammar productions (simplified)

Simplified from the full EBNF in Chapter 8.2 to show patterns
relevant to model authoring.

### Package

```ebnf
PackageDefinition =
    'package' Identification? PackageBody ;

PackageBody =
    '{' ( PackageMember | Import | Alias )* '}' ;
```

### Import

```ebnf
Import =
    Visibility? 'import' 'all'? ImportTarget ';' ;

ImportTarget =
    QualifiedName '::' ( '*' | '**' )
  | QualifiedName ;
```

The `*` form imports direct members, `**` imports recursively, and
`all` includes private members.

### Definition (general pattern)

```ebnf
DefinitionElement =
    DefinitionKeyword Identification?
    ( SPECIALIZES QualifiedName ( ',' QualifiedName )* )?
    DefinitionBody ;

DefinitionBody =
    '{' DefinitionBodyItem* '}'
  | ';' ;
```

Where `DefinitionKeyword` is one of: `part def`, `port def`,
`action def`, `requirement def`, and so on (27 definition types
total).

### Usage (general pattern)

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

### Feature value

```ebnf
FeatureValue =
    '=' Expression
  | ':=' Expression
  | 'default' '='? Expression ;
```

### Requirement

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

## Well-formedness summary

Common validation errors a VSE engineer is likely to encounter:

| Error | Semantic cause | Fix |
|---|---|---|
| Attribute with composite feature | `validateAttributeUsageIsReference`: attributes are always referential | Move the composite feature to a `part def`, or mark the nested usage with `ref` |
| Port with composite non-port nested usage | Port nested usages that are not PortUsages must be referential | Add `ref` to the nested usage, or restructure it as a port |
| Connection with fewer than 2 ends | Non-abstract connections require at least 2 `connectionEnd` features | Add the missing end feature, or mark the connection `abstract` |
| Enumeration not a variation | `EnumerationDefinition` must always have `isVariation=true` | Normally automatic. Check whether you are using `enum def` correctly |
| Requirement without subject | The `subjectParameter` should be the first parameter | Add a `subject` declaration at the top of the requirement body |
| Assert constraint evaluating to false | Assert constraints must subset `trueEvaluations` | Fix the constraint or correct the model values that violate it |
| Cross-hierarchy specialisation | DataValue and Occurrence are disjoint | Do not specialise an `attribute def` from a `part def` or vice versa |
| Variation member not a variant | All owned members of a variation must be `variant` usages | Add the `variant` keyword to each member |
| Missing verify link in verification case | Verification case objective should contain `verify requirement` | Add `verify requirement <name>` inside the `objective` block |
| Usage specialising a definition | Usages specialise usages, definitions specialise definitions | Use `:` (typing) to type a usage by a definition, not `:>` (specialisation) |
| Redefinition type mismatch | A redefining feature must be type-compatible with the redefined feature | Ensure the new type is a subtype of the original |
| Multiple subjects in one requirement | A requirement may have only one subject parameter | Remove the extra subject declarations |

## VSE validation checklist

Before committing a model file, verify the following:

1. **Every part usage** is either composite (default) or
   explicitly marked `ref`. Unintended composite ownership causes
   lifecycle coupling.
2. **Every attribute definition** contains only referential
   features. If you need composite sub-elements, use a `part def`.
3. **Every requirement** has an explicit `subject`, at least one
   `require constraint`, and traces upward (satisfy link) and
   downward (verify link).
4. **Every connection** has at least two ends, or is marked
   `abstract`.
5. **Every enumeration member** uses the `variant` keyword.
6. **Every verification case objective** contains a `verify` link
   to the requirement it verifies.
7. **No cross-branch specialisation** exists between DataValue
   types and Occurrence types.
8. **Reserved keywords** used as names are enclosed in single
   quotes.

## Common modelling mistakes

1. **Using attribute where part is needed.** If an element needs
   to own composite sub-elements, it must be a `part def`.
   Attributes cannot own composite features.
2. **Forgetting `ref` for shared references.** Without `ref`,
   each owning part gets a separate composite instance rather
   than a shared reference.
3. **Omitting the subject in requirements.** Syntactically valid,
   but makes satisfaction bindings ambiguous.
4. **Using `:>` where `:` is needed.** Typing uses `:` (defined
   by). Specialisation between usages uses `:>`. Confusing these
   produces a cross-hierarchy error.
5. **Mixing DataValue and Occurrence.** An attribute typed by a
   part definition, or vice versa, will fail validation.

## See also

- [[sysml2-language-architecture]] for KerML/SysML layering.
- [[sysml2-type-hierarchy]] for the type tree.
- [[sysml2-specialisation-and-typing]] for the relationship
  operators referenced here.
- [[sysml2-requirements-semantics]] for the requirement family
  validation rules.
