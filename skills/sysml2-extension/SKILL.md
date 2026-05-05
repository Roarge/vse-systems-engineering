---
name: sysml2-extension
description: Author SysML 2.0 domain extensions with model libraries and user-defined keywords. Use when introducing a domain library (Function/Platform style), declaring a `library package` for reuse, defining a `#keyword` via SemanticMetadata, building a methodology vocabulary on top of SysML, or hitting the kind-keyword, baseType, or annotatedElement pitfalls of the keyword mechanism.
user-invocable: true
---

# SysML 2.0 Extension: Domain Libraries and User-Defined Keywords

If you are inside a VSE project (`.vse-iteration.yml` present at the project root) and the VSE lens has not been set this session, invoke `vse-companion-overview` first, then continue. In a SysML-only repository (no `.vse-iteration.yml`), skip the lens and proceed directly with this skill.

You guide the engineer through extending and customising SysML 2.0
to fit a domain or methodology. Two strategies are supported and
can be combined: model libraries that publish reusable abstract
concepts (Strategy 1), and user-defined keywords that give those
concepts a compact `#name` syntax at the call site (Strategy 2).
This skill owns the producer side of the extension story. For the
consumer side (applying the VSE_Library metadata such as
`RiskInfo`, `ConfigItem`, `Baseline`, `VariantScope`, and
`VerificationScope`), route to `@sysml2-metadata`. For project
layout and tooling, route back to `@sysml2-modelling`. For where
domain libraries sit in the canonical AMBSE model layout, route to
`@sysml2-model-structure`. For the allocation mechanism reused in
the canonical PBSE example, route to `@sysml2-allocations`.

## When This Skill Triggers

- The user wants to introduce a reusable domain library for a
  methodology (PBSE, FAS, SYSMOD, a safety vocabulary)
- The user wants to declare a `library package` and is unsure what
  the `library` modifier means
- The user wants a project-specific keyword with the `#` syntax
- The user wants to build a domain-specific language on top of
  SysML 2.0
- The user has a SemanticMetadata-based keyword that "does
  nothing" or produces a plain `Usage` instead of the expected
  kind
- The user wants a keyword that targets definitions only and a
  meaningful error if applied to a usage

## Two Strategies

The two extension strategies are independent and stackable. A
typical domain extension uses Strategy 1 to publish concepts and
Strategy 2 to give them a compact call-site syntax. See the
overview at `[[sysml2-language-extension]]` and the strategy
detail pages for the full pattern.

| Strategy | Mechanism | Use when |
| --- | --- | --- |
| 1. Model library | `library package` + abstract or concrete defs | A reusable domain vocabulary is the goal |
| 2. User-defined keyword | `metadata def ... :> Metaobjects::SemanticMetadata` + `#name` | A compact call-site syntax is the goal |

## Core Vocabulary

| Element | Keyword | Purpose |
| --- | --- | --- |
| Library package | `library package` | Signals reusable intent for the contents |
| Abstract usage | `abstract <kind>` | Target of a SemanticMetadata `baseType` |
| SemanticMetadata def | `metadata def <name> Foo :> Metaobjects::SemanticMetadata` | Registers a user-defined keyword |
| baseType redefinition | `:>> baseType = abs meta SysML::Type` | Names the abstract usage to specialise |
| Meta-cast operator | `meta` | Returns the reflective metadata instance |
| Keyword application | `#name` | Compact call-site syntax with implicit specialisation |
| annotatedElement guard | `redef annotatedElement : SysML::Definition` | Refuses misuse on the wrong kind |

## Authoring Patterns

### Library Package with Domain Concepts

```sysml
library package <PBSE> PlatformBasedSystemsEngineering {
    occurrence def Function {
        occurrence realizingPlatforms : Platform [1];
    }
    occurrence def Platform {
        occurrence realizedFunctions : Function [*];
    }
    allocation def FunctionalAllocation {
        end occurrence function : Function
            crosses platform.realizedFunctions;
        end occurrence platform : Platform
            crosses function.realizingPlatforms;
    }
}
```

The `library` keyword in front of `package` signals reusable
intent. `crosses` on the allocation ends derives the
reverse-direction trace from one declaration. The author's
guideline is to **stay general** and avoid abstract definitions
in libraries unless they are meant to be incomplete. See the
detail page `[[sysml2-domain-model-libraries]]`.

### Abstract Usages and SemanticMetadata Pair

```sysml
abstract occurrence functions : Function;
abstract occurrence platforms : Platform;
abstract allocation functionalAllocations : FunctionalAllocation;

metadata def <function> FunctionMetadata
    :> Metaobjects::SemanticMetadata
{
    :>> baseType = functions meta SysML::Type;
}
metadata def <platform> PlatformMetadata
    :> Metaobjects::SemanticMetadata
{
    :>> baseType = platforms meta SysML::Type;
}
metadata def <functionalAllocation> FunctionalAllocationMetadata
    :> Metaobjects::SemanticMetadata
{
    :>> baseType = functionalAllocations meta SysML::Type;
}
```

The angle-bracket name is the short keyword used after `#`. The
abstract usages give the meta-cast a concrete element to
reflect. Use `meta SysML::Type`, not `meta SysML::Usage`, to
avoid the silent-failure pitfall described in
`[[sysml2-extension-gotchas]]`.

### Keyword Application With Kind-Keyword

```sysml
part def Drone {
    #function navigation;
    #platform occurrence navigationSubsystem;
    #functionalAllocation allocate navigation to navigationSubsystem;
}
```

Keep the kind-keyword (`occurrence`, `part`, `action`) explicit
when the model crosses an API or view-filter boundary. Omitting
it produces a plain `Usage` rather than the more specific kind,
which downstream consumers may not match.

### Stacking Keywords

```sysml
#function #critical navigation;
```

User-defined keywords stack when they cover orthogonal aspects.
Each keyword contributes its own implicit specialisation. The
order does not affect the resulting type, but reading order tends
to put the more general kind first.

### Definition-Only Keyword Guard

```sysml
metadata def <safetyCritical> SafetyCriticalMetadata
    :> Metaobjects::SemanticMetadata
{
    :>> baseType = safetyCriticalDefs meta SysML::Type;
    redef annotatedElement : SysML::Definition;
}
```

When the `baseType` is a definition, redefine `annotatedElement`
to `SysML::Definition` so a usage-side application produces a
meaningful error rather than a silent no-op.

## Validation Checklist

1. **Library packages use the `library` modifier.** Plain
   packages of reusable content are technically legal but they
   read as if they model a specific system.
2. **Domain concepts in libraries are concrete by default.**
   Abstract definitions are reserved for cases where
   specialisation must be enforced. State the reason in the body
   when this is the case.
3. **Allocations use cross subsetting** when the library wants
   reverse-direction traces populated from one `allocate` usage.
4. **SemanticMetadata `baseType` redefinitions use
   `meta SysML::Type`**, not `meta SysML::Usage`. The cost is
   zero. The benefit is no silent failure when the base resolves
   to a definition.
5. **Abstract usages backing keywords are declared `abstract`.**
   These usages exist only as targets for the meta-cast, never to
   be instantiated.
6. **`annotatedElement` is redefined to `SysML::Definition` or
   `SysML::Usage`** when the keyword is meant for one side only.
   Without this, misapplication fails silently.
7. **Kind-keywords are kept explicit** in code that crosses API
   or view-filter boundaries.

## Red Flags

WARN the engineer if:

- A `#keyword` appears at a call site without a matching
  SemanticMetadata definition in scope (the keyword degrades to a
  plain comment with no effect)
- A SemanticMetadata definition uses `meta SysML::Usage` and the
  abstract base might be a definition (silent no-op risk)
- A `metadata def` is declared as `:> Metaobjects::SemanticMetadata`
  but the `baseType` is missing or set without a meta-cast
- A `library package` contains abstract definitions without an
  accompanying explanation of why specialisation is forced
- A user-defined keyword is meant for definitions only but
  `annotatedElement` is not redefined
- A heavyweight DSL is being authored that needs custom
  validation rules, since SysML 2.0 user-defined keywords cannot
  carry validation logic at this time
- A library duplicates a built-in concept that already exists in
  the Systems Model Library or one of the standard domain
  libraries (see `[[sysml2-libraries-architecture]]`)

## Reference: SysML 2.0 Extension

!`cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/sysml2-extension.md`
