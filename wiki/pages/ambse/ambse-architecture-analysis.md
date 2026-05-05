---
title: "AMBSE Architectural Analysis and Five Architecture Views"
slug: ambse-architecture-analysis
type: process
layer: ambse
tags: [architecture, analysis, views, subsystem, deployment, dependability, distribution, concurrency]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapter 6."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Chapter 3."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-trade-studies
  - ambse-architectural-design
  - ambse-interfaces-and-handoff
  - ambse-architecture-vv-and-iso29110
  - sysml2-canonical-model-layout
  - iso29110-sr-process
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [architecture-design]
---

# AMBSE Architectural Analysis and Five Architecture Views

Architecture in AMBSE has two distinct activities:

- **Architectural analysis**: evaluate candidate architectures
  and select the best fit through trade studies (ISO 29110
  SR.3, early). See [[ambse-trade-studies]].
- **Architectural design**: implement the selected architecture
  by identifying subsystems, allocating requirements, and
  defining interfaces (ISO 29110 SR.3). See
  [[ambse-architectural-design]].

Both activities are performed incrementally, **per iteration**.
Each iteration refines and extends the architecture as new use
cases are specified. For the underlying AMBSE iteration model
see [[methodology-overview]]. For the SysML 2.0 package
layout the architecture lands in, see
[[sysml2-canonical-model-layout]]. For the ISO 29110 SR.3
activity catalogue, see [[iso29110-sr-process]].

## Architectural analysis workflow

The architectural analysis workflow selects among candidate
architectures:

1. **Identify key system functions** from the requirements
   specified so far.
2. **Define candidate solutions** (at least two architectural
   alternatives).
3. **Perform trade study** (see [[ambse-trade-studies]]).
4. **Merge selected solutions** into the evolving system
   architecture.
5. **Perform review**.

## The five architecture views

Douglass identifies five views of the system architecture.
Each addresses a different concern and uses different SysML
2.0 constructs.

| View | Concern | SysML 2.0 constructs |
|---|---|---|
| **Subsystem** | Decomposition into major parts | `part def`, nested `part` usages |
| **Deployment** | Allocation of functions to physical elements | `allocation def`, `allocate` |
| **Dependability** | Safety, reliability, security overlay | `requirement def` with constraints |
| **Distribution** | Geographic/network distribution | `part def` with `connect` statements |
| **Concurrency** | Concurrent execution and synchronisation | `state def`, `action def` with forks |

### When each view applies

VSE guidance:

- **Subsystem view**: always required. The basic decomposition.
- **Deployment view**: add when hardware is involved.
  Function-to-element allocation drives the deployment view.
- **Dependability view**: add for safety-critical systems.
  Records the safety, reliability, and security overlay on top
  of the subsystem and deployment views.
- **Distribution view**: optional. Use when the system is
  geographically distributed or runs across networked nodes.
- **Concurrency view**: optional. Use when the system has
  concurrent execution and synchronisation concerns
  (multi-threaded software, real-time control loops).

For most VSE projects, the subsystem view plus a deployment
view (when hardware is involved) is sufficient. Distribution
and concurrency views are reserved for systems with specific
properties that demand them.

## See also

- [[ambse-trade-studies]] for the trade-study methodology that
  picks among the candidate architectures.
- [[ambse-architectural-design]] for the design workflow that
  implements the selected architecture.
- [[ambse-interfaces-and-handoff]] for interface specification
  and the handoff to downstream engineering.
- [[ambse-architecture-vv-and-iso29110]] for V&V at the
  architecture level and the ISO 29110 mapping.
- [[sysml2-canonical-model-layout]] for the AMBSE package
  layout the architecture lands in.
- [[iso29110-sr-process]] for the ISO 29110 SR.3 activity
  catalogue.
