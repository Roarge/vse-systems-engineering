---
title: "Base Architecture Reuse and Federation in AMBSE Models"
slug: sysml2-base-architecture-and-federation
type: reference
layer: sysml2
tags: [base-architecture, federation, reuse, shared-model, subsystem-model]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-04 release. MBSE4U. Chapter 14, pages 56 to 58."
    raw: sysmlv2.pdf
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Elsevier. Chapter 8.3 and Figures 3.12, 3.14, 8.2, 8.4."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Packt. Chapter 1."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - sysml2-canonical-model-layout
  - sysml2-namespace-hygiene
  - sysml2-specialisation-and-typing
confidence: high
created: 2026-05-04
updated: 2026-05-06
bundled_by: [sysml2-model-structure]
---

# Base Architecture Reuse and Federation in AMBSE Models

> **Canonical for this plugin: methodology §2 and §8.3.1.**
> Templated SysML 2.0 package names below describe the AMBSE
> convention at the language level. The plugin's canonical
> project directory for the Base Architecture is
> `model/core/base-architecture/` per
> `methodology/08-project-structure.md` §8.3.1, and the
> §2 specification at `methodology/02-base-architecture.md`
> is the authoritative source on Base Architecture content.

Most projects are not greenfield. A base architecture records
decisions an earlier programme has already made and constrains
the solution space for the next project. As the team or
programme grows, a single SE model may also need to federate into
multiple connected models.

## Base architecture as a top-level peer package

The plugin treats `{{sc}}_BaseArchitecture` as an **optional
top-level peer** of `{{sc}}_ArchDesign`, not as an inner folder.
This matches Douglass's shared-repository philosophy, in which
reusable content is a peer of the SE model rather than a
subdirectory inside it (ASE 2016 Fig 3.12), while adopting the
Chapter 14 specialisation syntax from SysML 2.0.

The base is populated only when the project genuinely inherits an
architecture. A greenfield project does not carry an empty base
package.

## Specialisation operators for reuse

SysML 2.0 provides two operators for reuse (Ch 14.2,
pp 56 to 58):

| Operator | Applies to | Meaning |
|---|---|---|
| `:>` | definitions | This definition specialises another |
| `:>>` | usages | This usage redefines an inherited usage |

Use `:>` to state that a new part definition extends or
specialises a base part definition. Use `:>>` inside a part body
to redefine a usage inherited from the specialised parent. See
[[sysml2-specialisation-and-typing]] for the full semantics.

```sysml
package HS_ArchDesign {
    private import HS_BaseArchitecture::BaseSensorSystem;
    private import HS_BaseArchitecture::Operator;

    part def SensorSystem :> BaseSensorSystem {
        part :>> sensors[2];      // override inherited multiplicity
        part :>> operator : Operator;
    }
}
```

## System context is methodological

Chapter 14.2 of the SysML v2 book treats the system context as a
methodological wrapper, not a SysML keyword. In the canonical
layout it lives inside `{{sc}}_ArchDesign` as a specialised part
def holding the system of interest with its actors and
environment. No separate top-level package.

## Growing the base

When a second project starts from the same base, **harden it** by
migrating stable definitions out of `{{sc}}_ArchDesign` into
`{{sc}}_BaseArchitecture`. When the base is shared across several
programmes, it migrates out of the SE model entirely and becomes
a shared model. This is the reuse curve Douglass describes
(ASE 2016 Ch 8.3, Fig 8.4).

## Federation for scale

A single SE model suffices for most VSE projects. **Federate**
into multiple connected models only when one of the following
holds (ASE 2016 Ch 3.2.5):

- Load and save time has become painful.
- Different teams have narrow focus and need smaller models.
- Information protection between teams requires it.
- The same base architecture is reused across multiple programmes.

## The three model types

| Model | Owner | Content |
|---|---|---|
| **SE model** | Systems team | The canonical layout |
| **Shared model** | Cross-programme stewardship | Physical interfaces, common types, shared domains, reusable base architectures |
| **Subsystem model** | Subsystem team | Subsystem specification, functional analysis, architectural design, deployment, software design |

Cookbook 2021 Fig 1.38 names the shared model's canonical
structure. Its `Interfaces` and `CommonTypes` packages are
referenced (not copied) by the subsystem models. ASE 2016 Fig
3.14 and Cookbook 2021 Fig 1.39 show the subsystem model layout:
each subsystem has its own small copy of the AMBSE canonical
pattern, scaled to the subsystem's scope.

## Copy versus reference for subsystem specification

Cookbook 2021 Chapter 1 discusses the trade-off explicitly.
Copying isolates the subsystem model from later SE-model changes.
Referencing keeps it live-linked. **For VSEs, reference is the
default** because the team is small enough to manage a single
coherent change stream.

## Plugin scope

`project-setup` does not scaffold federated models automatically.
The pattern stays manual until the project outgrows a single
model. Federation is a scale response, not a default.

## See also

- [[sysml2-canonical-model-layout]] for the SE model layout.
- [[sysml2-namespace-hygiene]] for the import discipline that
  federation relies on.
- [[sysml2-specialisation-and-typing]] for the `:>` and `:>>`
  semantics.
