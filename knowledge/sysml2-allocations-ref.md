# SysML v2 Allocations Reference

Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U, 2026-03 release.
Chapter and page citations appear inline. This file paraphrases the source, which
is a copyrighted commercial reference and is not reproduced verbatim. Chapter 75
(Allocations Reference in Part V) is marked as pending in the 2026-03 release.
This file will be extended when that chapter is published.

---

## 1. Overview (Ch 34, p 245)

Allocations play an important role in systems engineering to bridge different
layers and viewpoints, such as mapping logical architecture elements to physical
architecture elements. Rather than imposing a fixed design methodology,
allocations provide a general-purpose mechanism for mapping across different
structures. The mapping is especially useful in early design stages, where the
goal is to sketch out relationships and responsibilities in a high-level,
abstract, and sometimes provisional manner (Ch 34, p 245).

In SysML v2, an allocation definition is a type of connection definition that
indicates a target element is responsible for fulfilling some or all of the
intent of a source element. A single allocation can be refined by nesting
additional allocation usages within it, which allows progressively more detailed,
fine-grained mappings as the design matures from early conceptual modelling to
more concrete architecture and implementation (Ch 34, p 245).

---

## 2. Allocation Definitions (Ch 34, p 245)

An allocation definition is a specialisation of a connection definition with
defined ends and typed relationships. The basic structure includes (Ch 34, p 245,
Ch 41, p 266):

- Named connection ends that identify the elements being allocated.
- Typed ends that constrain what kind of element may participate in the
  allocation. For example, a `FunctionalAllocation` has one end typed to
  `Function` and another typed to `Platform`.
- Cross subsettings (Ch 20 for subsettings, Ch 18.2.2 for cross subsettings)
  which model bidirectional relationships. Connected functions and platforms
  appear in the responsibility usages of the element on the opposite side of
  the connection.

Allocation definitions typically live in library packages, so they can be reused
across projects, and can be specialised to create domain-specific allocation
types (Ch 41, p 265).

```sysml
library package PlatformBasedSystemsEngineering {
    occurrence def Function {
        occurrence realizingPlatforms : Platform[1];
    }
    occurrence def Platform {
        occurrence realizedFunctions : Function[*];
    }
    allocation def FunctionalAllocation {
        end occurrence function : Function crosses platform.realizedFunctions;
        end occurrence platform : Platform crosses function.realizingPlatforms;
    }
}
```

---

## 3. Allocation Usages (Ch 34, p 245, Ch 41, p 267)

Allocation usages apply an allocation definition in a specific context. The
`allocate` keyword provides a concise shorthand for expressing allocations
without the verbose connection syntax.

```sysml
part def Drone {
    occurrence navigation : PBSE::Function;
    occurrence navigationSubsystem : PBSE::Platform;
    allocation : PBSE::FunctionalAllocation
        allocate navigation to navigationSubsystem;
}
```

Named allocations give meaningful identifiers to allocation usages for
traceability and documentation. Allocations may also be nested to support
progressive refinement as design matures from abstract to concrete
(Ch 34, p 245).

---

## 4. Directionality (Ch 34, p 245, Ch 41, p 267)

Allocations in SysML v2 are inherently directed, reflecting the typical systems
engineering flow from abstract intent to concrete realisation. The structure
has two ends:

- The source end, that is the element whose intent must be fulfilled.
- The target end, that is the element responsible for fulfilling that intent.

The `allocate X to Y` notation makes the direction explicit. X is the source
and Y is the target. Reversing the order changes the meaning fundamentally
(Ch 41, p 267). Cross subsettings derived from the allocation definition give
each end an automatic reverse view of the relationship, so traceability works
in both directions without being modelled twice (Ch 41, p 266).

---

## 5. Cross-Architecture Mapping Patterns

Allocations enable several standard mapping patterns that commonly arise in a
VSE systems-engineering workflow (Ch 34, p 245, Ch 41, pp 265-267).

### 5.1 Functional to Logical

Map functional requirements and capabilities to logical components that perform
those functions. Preserves the functional intent while exposing logical design
decisions.

### 5.2 Logical to Physical

Map logical components to physical hardware, software, or hybrid
implementations. This layer bridges architectural abstraction with
implementation reality.

### 5.3 Behaviour to Structure

Map behavioural flows, state machines, and action sequences to the structural
elements (parts, components, subsystems) that realise those behaviours.
Particularly important in control systems and embedded applications.

### 5.4 Platform-Based Allocation

Map functions to execution platforms such as processors, hardware devices, or
software environments. The `FunctionalAllocation` example in Ch 41 combines the
connection and allocation mechanisms so an allocation from `Function` to
`Platform` also populates the derived `realizingPlatforms` and
`realizedFunctions` collections (Ch 41, p 266).

---

## 6. Derived Relationships (Ch 41, p 266)

Allocations establish implicit bidirectional relationships through cross
subsettings. When a function is allocated to a platform, the platform
automatically appears in a derived `realizedFunctions` collection and the
function appears in the `realizingPlatforms` collection of the platform. These
derived relationships update as allocations are refined, which supports
automatic traceability and consistency checking across architectural layers
(Ch 41, p 266).

---

## 7. Practical Patterns for VSE Authors

### 7.1 Simple Functional to Physical Allocation

Allocate a high-level function to a concrete subsystem using a library-supplied
allocation definition (Ch 41, p 267).

```sysml
part def Drone {
    occurrence navigation : PBSE::Function;
    occurrence navigationSubsystem : PBSE::Platform;
    allocation : PBSE::FunctionalAllocation
        allocate navigation to navigationSubsystem;
}
```

### 7.2 Hierarchical Allocation Refinement

Decompose an allocation into sub-allocations that progressively refine the
responsibility assignment. A top-level allocation maps a system function to a
major subsystem, and nested allocations map the subsystem's responsibilities
to its constituent components (Ch 34, p 245).

### 7.3 Platform-Based Allocation Library

Package domain-specific allocation definitions in a library for reuse across
projects. Standardises allocation semantics as an organisational asset
(Ch 41, pp 265-266).

### 7.4 Allocation Matrix Views

Use view definitions (see `sysml2-views-ref.md`) to render allocations in a
matrix form. Views filter allocations by architectural layer to build
requirement traceability tables and allocation grids (Ch 13, p 51).

### 7.5 User-Defined Allocation Keyword

Define a domain-specific keyword using semantic metadata and apply it with the
`#` prefix. The keyword form reads more compactly at the usage site
(Ch 41, pp 267-270).

```sysml
#functionalAllocation allocate navigation to navigationSubsystem;
```

### 7.6 Responsibility Tracking Through Nested Allocation

Each nesting level of an allocation represents a finer granularity of
responsibility. Use this to document which elements take responsibility for
which intent as the design progresses (Ch 34, p 245).

---

## 8. Gotchas and Red Flags

1. **Ch 75 reference is stubbed.** Chapter 75 (Allocations in Part V SysML
   Reference) is marked as pending in the 2026-03 release (Ch 75, p 321). The
   formal reference documentation is therefore incomplete. Authors should rely
   on Ch 34 conceptual material plus the Ch 41 library example.
2. **Allocations are connections.** Allocations specialise connections, so all
   connection rules apply. Poorly defined ends or inconsistent end types
   produce allocation models that do not express the intent clearly
   (Ch 34, p 245).
3. **Directionality is load-bearing.** The order in `allocate X to Y` is
   semantic. Reversing it changes the meaning. Authors coming from SysML v1,
   where allocation was sometimes drawn as an undirected line, should take
   extra care (Ch 41, p 267).
4. **Cross-subsetting errors fail at evaluation time.** When defining an
   allocation with cross subsettings, the referenced features must exist and
   have compatible types. Broken references surface only when the model is
   evaluated (Ch 41, p 266).
5. **User-defined keywords have no extra validation.** There is currently no
   way to attach validation rules to custom allocation keywords. Incorrect use
   of a keyword fails silently without an error message (Ch 41, p 271).
6. **Library definitions should avoid being abstract.** The book advises
   avoiding abstract allocation definitions in libraries unless they are
   deliberately incomplete. Abstract definitions force users to specialise or
   inline detail, which undermines reuse (Ch 41, p 266).

---

## 9. Cross References

- `sysml2-quick-ref.md` Section 11 for the textual syntax of `allocation def`,
  `allocation`, and `allocate`.
- `sysml2-semantics-ref.md` for the connection and subsetting base types that
  allocations specialise.
- `sysml2-metadata-ref.md` for semantic metadata and user-defined keywords used
  to extend allocations.
- `sysml2-views-ref.md` for views that render allocation matrices.

---

## 10. Pending Extensions

This file will grow once the following chapters are published in a future
release of the book:

- Ch 75 Allocations in Part V SysML Reference (full formal reference).
- Ch 108 rendering conventions for allocation matrices (`StandardViewDefinitions`).

Attribution: Drawn from Weilkiens T and Molnár V, The SysML v2 Book, MBSE4U,
2026. All claims cite chapter and page. Paraphrased for reference use. Do not
reproduce verbatim.
