---
title: "SYSMOD in an ISO 15288 process landscape"
slug: sysmod-iso15288-landscape
type: reference
layer: sysmod
summary: Which ISO 15288 processes SYSMOD covers, where it stops, and how that sits beside the plugin's ISO 29110 story
tags: [sysmod, iso15288, iso29110, process-coverage, compliance, boundary]
sources:
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. Appendix A (Mapping ISO 15288 to SYSMOD)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §3 (SYSMOD Processes)"
    raw: sysmod.pdf
related:
  - iso-29110-compliance-mapping
  - ambse-iso29110-mapping
  - sysmod-toolbox-anatomy
  - sysmod-test-modelling
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [project-audit]
---

# SYSMOD in an ISO 15288 process landscape

## Contents

- The mapping's own caveat
- Technical processes SYSMOD covers
- Where SYSMOD stops
- Reading this for the plugin
- See also

The source closes its process chapter by noting that SYSMOD methods
and products can be used inside an ISO 15288 inspired process
landscape, and supplies an appendix mapping the ISO 15288 processes
to the SYSMOD methods. This page condenses that appendix and marks
its boundary.

## The mapping's own caveat

The appendix states that the mapping makes no distinction between
full and partial coverage. A row that names a SYSMOD method
therefore says only that some method touches that process, and
never says how much of it is addressed. Every reading below inherits
that caveat.

## Technical processes SYSMOD covers

| ISO 15288 technical process | SYSMOD methods named |
|---|---|
| Business Mission Analysis | Analyze the Problem, Describe the System Idea and the System Objectives, Describe the Base Architecture, Identify Stakeholders, Identify the System Context |
| Stakeholder Needs and Requirements Definition | Identify Stakeholders, Model Requirements, Identify the System Context, Identify System Use Cases, Identify System Processes, Model Use Case Activities, Model the Domain Knowledge, Define System States |
| System Requirements Definition | Model Requirements, Identify System Use Cases, Identify System Processes, Model Use Case Activities, Model the Domain Knowledge, Define System States |
| Architecture Definition | Identify the System Context, Model the Functional Architecture, Model the Logical Architecture, Revise an Architecture with Scenarios, Define System States |
| Design Definition | Model the Product Architecture, Revise an Architecture with Scenarios, Define System States |
| Verification | Specify Test Cases, Model the Test Architecture |
| Validation | Specify Test Cases, Model the Test Architecture |

Two observations follow from the shape of the table. The
front-loading is heavy: the analysis-side processes draw on most of
the toolbox. The verification and validation rows are the thinnest
in the technical block, and both are covered by the same two
methods, which are specification-level methods rather than
execution ones. See [[sysmod-test-modelling]].

## Where SYSMOD stops

The appendix records the following as not explicitly covered.

- **Technical processes**: System Analysis, Implementation,
  Integration, Transition, Operation, Maintenance, Disposal.
- **Technical management processes**: Project Planning, Project
  Assessment and Control, Decision Management, Configuration
  Management, Information Management, Measurement, Quality
  Assurance. The single exception is Risk Management, covered by
  Model Risks.
- **Agreement processes**: Acquisition and Supply, both uncovered.
- **Organisational project-enabling processes**: Life Cycle Model
  Management, Portfolio Management, Quality Management, and
  Knowledge Management are uncovered. Infrastructure Management is
  covered by the tailoring, SME, and deployment methods, and Human
  Resource Management by the training and coaching method.

## Reading this for the plugin

The two frames complement each other, and confusing them would be
the only real risk.

- The plugin's process backbone is ISO/IEC TR 29110-5-6-2. Its
  project management process and its system implementation
  activities cover precisely the management, implementation,
  integration, and delivery ground that the appendix above marks as
  not explicitly covered by SYSMOD.
- SYSMOD supplies modelling method inside the specification-side
  activities, which is the ground where the plugin's methodology
  drew on it (§2 Base Architecture and §3 System Context).

**Compliance claims in this plugin are made against ISO/IEC TR
29110-5-6-2 only**, as documented in methodology §9 and summarised
at [[iso-29110-compliance-mapping]]. Nothing on this page
constitutes an ISO 15288 compliance claim, and coverage in the
appendix above is the source's statement about its own methods, not
a statement about this plugin.

## See also

- [[iso-29110-compliance-mapping]] for the plugin's actual
  compliance position.
- [[ambse-iso29110-mapping]] for the AMBSE activity mapping onto
  the same standard.
- [[sysmod-toolbox-anatomy]] for the methods this appendix maps.
- [[sysmod-test-modelling]] for the two methods behind the
  Verification and Validation rows.
