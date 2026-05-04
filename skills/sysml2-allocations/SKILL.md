---
name: sysml2-allocations
description: Author SysML 2.0 allocations between functional, logical, and physical architectures. Use when mapping behaviour to structure or bridging architecture layers.
user-invocable: true
---

# SysML 2.0 Allocations

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You guide the engineer through allocations in SysML 2.0. Allocations
are a first-class mechanism for mapping elements across architecture
layers: functional to logical, logical to physical, behaviour to
structure, or function to platform. For project layout and tooling,
route back to `@sysml2-modelling`. For allocation matrix views, route
to `@sysml2-views`.

## When This Skill Triggers

- The user wants to allocate a function to a physical element
- The user wants to bridge logical and physical architectures
- The user asks about platform-based allocation
- The user wants an allocation matrix or traceability between layers

## Core Vocabulary

| Element | Keyword | Purpose |
| --- | --- | --- |
| Allocation definition | `allocation def` | Typed connection between two element kinds |
| Allocation usage | `allocation`, `allocate` | Applies an allocation definition |
| Allocate shorthand | `allocate X to Y` | Concise directional allocation |
| Cross subsetting | `crosses` | Derives reverse traceability |

Allocations specialise connections. All connection rules apply. The
`allocate X to Y` form is a shorthand for a connection usage where X is
the source and Y is the target.

## Authoring Patterns

### Library Allocation Definition

```sysml
library package PlatformBasedSystemsEngineering {
    occurrence def Function {
        occurrence realizingPlatforms : Platform[1];
    }
    occurrence def Platform {
        occurrence realizedFunctions : Function[*];
    }
    allocation def FunctionalAllocation {
        end occurrence function : Function
            crosses platform.realizedFunctions;
        end occurrence platform : Platform
            crosses function.realizingPlatforms;
    }
}
```

`crosses` links each end to a derived feature on the opposite end, so a
single `allocate` usage populates both sides of the trace.

### Allocation Usage

```sysml
alias PBSE for PlatformBasedSystemsEngineering;

part def Drone {
    occurrence navigation : PBSE::Function;
    occurrence navigationSubsystem : PBSE::Platform;
    allocation : PBSE::FunctionalAllocation
        allocate navigation to navigationSubsystem;
}
```

The named allocation gives the relationship an identifier for
documentation. Omit the name for one-off allocations.

### User-Defined Allocation Keyword

```sysml
#functionalAllocation allocate navigation to navigationSubsystem;
```

Register a domain keyword via `SemanticMetadata` in a metadata library,
then prefix allocation usages with `#keyword` for a compact call site.
See `@sysml2-metadata` for keyword registration.

### Nested Allocation Refinement

```sysml
allocation topLevel : FunctionalAllocation
    allocate navigation to navigationSubsystem {
        allocation sub1 : FunctionalAllocation
            allocate navigation.pathPlanning to navigationSubsystem.planner;
        allocation sub2 : FunctionalAllocation
            allocate navigation.localisation to navigationSubsystem.gnss;
    }
```

Progressive refinement adds more granular allocations as the design
matures. The outer allocation carries the overall responsibility; the
nested ones pin down the specifics.

## Validation Checklist

1. **Directionality matters.** `allocate X to Y` is not the same as
   `allocate Y to X`. Reversing the order changes the meaning.
2. **Ends are type-compatible** with the allocation definition. A
   function-to-platform allocation cannot take a part usage that is not
   typed as either.
3. **Cross-subsetting references exist.** If the allocation definition
   uses `crosses`, the referenced features must be defined on the
   opposite end type.
4. **Nested allocations remain within the parent scope.** A nested
   allocation that reaches outside the parent's subject is usually a
   sign of misplaced responsibility.
5. **Allocation matrices are rendered via Grid View** with a filter
   over allocation metadata. Avoid rolling your own matrix format.

## Red Flags

WARN the engineer if:

- A function has no allocation at all but is referenced from a case or
  requirement at the implementation layer
- Multiple allocations cover the same function-platform pair without
  nesting or refinement intent
- An allocation crosses architecture layers in the wrong direction (a
  physical element allocated to a logical function, for example)
- The model uses custom keywords without a corresponding
  `SemanticMetadata` registration

## Reference: SysML 2.0 Allocations

!`cat ${CLAUDE_PLUGIN_ROOT}/wiki/bundles/sysml2-allocations.md`
