---
title: "The SYSMOD Model Purpose Model"
slug: sysmod-model-purpose-levels
type: concept
layer: sysmod
summary: Three modelling-purpose levels (communication, traceability, specification) for sizing how much MBSE a project needs
tags: [sysmod, model-purpose, msse, mbse-adoption, traceability, specification, simulation]
sources:
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §11.3 (Model Purpose Model)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §4.3 (Deploy the MBSE Methodology)"
    raw: sysmod.pdf
related:
  - sysmod-toolbox-anatomy
  - methodology-overview
  - sysmod-neg-why-mbe
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [project-setup]
---

# The SYSMOD Model Purpose Model

## Contents

- The three levels
- The two add-ons
- Effort and value across the levels
- Where the plugin diverges
- See also

The plugin's own answer to "how much modelling" is fixed by the
methodology, and [[methodology-overview]] states it. The plugin
assumes models are the primary engineering artefact from the first
commit. This page presents SYSMOD's three-level scale on its own
terms, because the scale gives a small team useful vocabulary for
deciding what to model in peripheral areas, and because it names
the position the plugin has already taken.

The model was called the SYSMOD Intensity Model in earlier versions
of SYSMOD. The source is explicit that it is not intended as a
maturity model, although the levels do represent increasing
modelling capability.

## The three levels

**SYSMOD1, purpose communication.** The objective is to improve
communication between stakeholders and other interested parties.
The model, and in particular the views on it, give clear
communication and a holistic view of the system. The primary focus
is on the views and the secondary focus on the repository.
Communication and understanding matter more than formalism and
completeness.

**SYSMOD2, purpose traceability.** Elements in the model are linked
in a predefined manner so that traceability queries return complete
and proper results, for example from a requirement to every
architectural element that satisfies it, or the reverse direction
for impact analysis. This requires a partly consistent structure of
the model data in the repository. The traceability capability is
independent of any graphical visualisation of the elements.

**SYSMOD3, purpose specification.** The models are the primary
source of the systems engineering data for the engineering
processes, and documents are only views on the model.

Only the third level is real MBSE in the source's terms. The first
two are named Model-Supported Systems Engineering (MSSE), because
the models support the engineering processes while the primary
source of the engineering data remains documents or other elements
outside the system models.

## The two add-ons

- **SYSMOD_LIB, libraries.** Common elements of the model are
  extracted and moved into model libraries for reuse in other
  projects.
- **SYSMOD_SIM, simulation.** The model is used to run a simulation
  or another automatic analysis, either to validate the model or to
  gain further insight, for example for trade-off studies.

## Effort and value across the levels

SYSMOD1 is described as the low-hanging fruit: high value for low
effort. SYSMOD2 requires more formalism and model queries, builds
on SYSMOD1, and has a balanced effort against value ratio. Reaching
SYSMOD3 from SYSMOD2 still takes high effort, and the return, for a
complex system, is the ability to master complexity with high
quality and a shortened time to market.

The levels double as deployment goals. The method for deploying an
MBSE methodology recommends against introducing it in one step and
names SYSMOD1 to SYSMOD3 as the example of intermediate goals, with
the summary "think big and start small". See
[[sysmod-toolbox-anatomy]] for the rest of that method.

## Where the plugin diverges

The plugin is SYSMOD3-native by design, and the divergence is
deliberate rather than incidental.

- Machine-readable traceability is design principle R3 of the
  plugin, so the linked structure SYSMOD2 describes as an
  achievement is a precondition here.
- Document export is defined as rendering views from the model, so
  the SYSMOD3 statement that documents are only views on the model
  is the plugin's starting assumption rather than its destination.

Two uses remain for the scale inside a plugin project. It is
vocabulary for explaining why the plugin insists on models as
primary artefacts, and it is a sizing aid for peripheral areas
where a very small entity may reasonably decide that a
communication-level or traceability-level treatment is enough.

## See also

- [[sysmod-toolbox-anatomy]] for the deployment method that uses
  these levels as intermediate goals.
- [[methodology-overview]] for the plugin's own position on models
  as the primary engineering artefact.
