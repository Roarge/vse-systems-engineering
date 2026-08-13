---
title: "SYSMOD as a toolbox: processes, methods, products, roles"
slug: sysmod-toolbox-anatomy
type: concept
layer: sysmod
summary: "What SYSMOD is: a methods toolbox, its four processes, tailoring, and the initial model package structure"
tags: [sysmod, toolbox, processes, methods, products, roles, tailoring, package-structure]
sources:
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §3 (SYSMOD Processes)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §4.1 to §4.4 (Infrastructure methods)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §5.1 to §5.3 (Infrastructure products)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §7.1 (How to set up an initial package structure)"
    raw: sysmod.pdf
related:
  - methodology-overview
  - sysml2-canonical-model-layout
  - sysmod-model-purpose-levels
  - sysmod-architecture-kinds-and-coupling
  - sysmod-iso15288-landscape
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [project-setup]
---

# SYSMOD as a toolbox: processes, methods, products, roles

## Contents

- Orientation
- A toolbox, not a process
- The four processes and what they produce
- The anatomy: methods, products, roles
- Tailoring is a standard task
- Deploying a methodology
- Model elements as proxies for external artefacts
- The initial model package structure
- Where the plugin diverges
- See also

## Orientation

The plugin's own process backbone is the story-driven ISO/IEC 29110
flow specified in the methodology, and [[methodology-overview]] is
the authoritative account of it. This page states the SYSMOD
position on its own terms, because SYSMOD is one of the sources the
methodology adapted (§2 Base Architecture and §3 System Context),
and a reader who knows where the source stands can see which parts
of it the plugin took and which parts it left. Nothing here is
plugin process.

## A toolbox, not a process

SYSMOD describes itself as a Systems Modeling Toolbox rather than a
Systems Modeling Process. The author records the change of view
directly: processes are valuable, but of higher value is the
craftsmanship of MBSE with a well-filled toolbox of methods,
patterns, and tools.

The SYSMOD Processes are therefore described as only one useful
logical order of executing the SYSMOD Methods. The author assumes
that in practice the processes are never performed as specified,
because the order and the collection of methods differ in every
project.

The distinction that carries the weight is between logical order
and timely order. The logical order does not imply a waterfall.
SYSMOD is independent of a waterfall or an agile approach, the
execution is treated as an orthogonal aspect, and the author states
a preference for an agile approach.

## The four processes and what they produce

| Process | Note | Products named in the source |
|---|---|---|
| MBSE Adoption (SMAP) | Uses SYSMOD on itself. The system of interest is the MBSE Methodology | The customised MBSE Methodology |
| Infrastructure | Stands up the way of working and the tooling | MBSE Methodology, System Modeling Environment (SME), MBSE Training |
| Analysis | The system of interest is now the product, not the methodology | Base Architecture, Domain Knowledge, Requirements, Risks, Stakeholders, System Context, System Idea, System Objectives, System Processes, System Use Cases, Use Case Activities |
| Architecture | Turns the analysis result into architecture | Logical Architecture, Product Architecture, Scenarios, System States |

A fifth body of work sits alongside rather than inside the four.
Functional Architectures for Systems (FAS) is described as a
valuable supplement whose place is between the analysis methods and
the architecture methods, taking Use Case Activities as input and
offering a functional architecture as optional input to the
Architecture Process. See
[[sysmod-architecture-kinds-and-coupling]].

## The anatomy: methods, products, roles

Three element kinds make up the toolbox, and the fourth (the
processes) only orders them.

- **Methods** are a collection of tasks that create significant
  artefacts for the systems development.
- **Products** are the outputs of the methods. The source
  recommends SysML for them and notes that a text document can also
  be the format of a product, in which case the work is not MBSE.
- **Roles** perform the methods. The relationship tables in the
  source name an SME Administrator, an MBSE Methodologist, a
  Project Manager, a Requirements Engineer, a System Architect, and
  a System Tester.

The MBSE Methodology product itself is defined as a consistent set
of related processes, roles, methods, products, and tools. The
tools enable the effective implementation of the methods.

## Tailoring is a standard task

A predefined methodology such as SYSMOD does not fit an
organisation or a project one to one. Some steps need more
emphasis, others are superfluous and can be skipped, and some
engineering artefacts are not covered by the methodology at all and
have to be added.

The source is explicit that this is not a lack of methodology.
Tailoring is a standard task performed before the methodology is
applied to a project, and SYSMOD can be used on itself to elaborate
what a project needs, with the MBSE Methodology as the system of
interest.

## Deploying a methodology

Deployment is treated as a change process that needs time, set
against projects that have little of it. Four points carry over
usefully to a very small entity.

1. Do not introduce the methodology in one step. Define
   intermediate goals, for example the levels of the Model Purpose
   Model described on [[sysmod-model-purpose-levels]]. Think big
   and start small.
2. Watch the value against effort relation from three
   perspectives at once: the short-term project perspective, the
   long-term organisation perspective, and the human perspective of
   the engineers doing the work.
3. Integrate new methods as a mandatory part of the engineering
   process. The stated reason is blunt: projects discard optional
   parts as soon as the schedule gets tough, which is always the
   case.
4. Take the learning curve into account when the steps are applied
   productively in a project.

## Model elements as proxies for external artefacts

A convention recurs across several SYSMOD products. When the
authoritative artefact lives in another tool, the model still
carries an element for it, and that element is a proxy whose
purpose is to establish links and traceability inside the model.

The source applies this to requirements held in a requirements
management tool, to risks held in an external risk management tool,
and to the System Idea and System Objectives, which are typically
held in product management documentation.

## The initial model package structure

SYSMOD's package structure is based on a best practice described by
the MBSE Challenge Team SE^2 for Telescope Modeling in the MBSE
Cookbook. Its shape is as follows.

- The root package represents the complete system model.
- The next level separates the different modelling aspects, such as
  system context, requirements, and structure. The source states
  that the aspect list is not complete and that a project needs a
  customised version.
- The prefix of each package is the enclosing namespace, so that
  the model does not carry many packages of the same name. The
  prefix also shows the context of the package and supports
  orientation.
- Architecture packages hold the architectural elements. Every
  element with a detailed description gets its own package one
  level down, and that package is then treated exactly like the
  system root package, with the same structure created inside it.

The setup steps run: start from an empty model with no predefined
package structure, create a model element named after the system,
create the three top-level packages for core, configurations, and
variations plus auxiliary packages for issues and notes, create the
top-level packages for the products inside the core package, place
a system element named after the system's Base Architecture in its
own base-architecture package, and create an abstract system
element in the core package, optionally generalising the Base
Architecture element when strong coupling is wanted.

**Lineage note.** SYSMOD's package structure is based on the MBSE
Challenge Team SE2 telescope-modelling practice, per the source's
own citation. On the plugin side, methodology §8.3.4 declares its
package naming a match to the SYSMOD convention (PascalCase, a
project-name prefix, an underscore separator), and the
`{{sc}}_<Aspect>` naming on [[sysml2-canonical-model-layout]] cites
Douglass's Agile MBSE Cookbook. The prefix conventions rhyme
through §8.3.4's declared match rather than through one documented
common ancestor.

## Where the plugin diverges

- **Process backbone.** The plugin's backbone is the story-driven
  ISO/IEC 29110 flow of methodology §0 and §8, not the SYSMOD
  Processes. SYSMOD's logical ordering is read here as context, not
  as a stage sequence a project should adopt.
- **Tailoring mechanism.** Tailoring in the plugin is the
  methodology-override convention, that is, the project-local
  `methodology/` copy wins over the plugin-shipped one. It is not
  SMAP, and the plugin does not treat its own methodology as a
  system of interest to be modelled.
- **Package layout.** The canonical layout is methodology §8.3 and
  [[sysml2-canonical-model-layout]]. This page supplies the
  rationale behind the shared ancestry, and it does not replace
  either of them.

## See also

- [[methodology-overview]] for the plugin's own process.
- [[sysml2-canonical-model-layout]] for the canonical package
  layout and its AMBSE rationale.
- [[sysmod-model-purpose-levels]] for the deployment ladder the
  source recommends as intermediate goals.
- [[sysmod-iso15288-landscape]] for what the toolbox does and does
  not cover in process terms.
