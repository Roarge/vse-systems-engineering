---
title: "INCOSE CM, Risk Management, and VSE Scaling Guidance"
slug: incose-vse-cm-risk-and-scaling
type: concept
layer: incose-vse
tags: [incose, configuration-management, risk, scaling, maturity, vse, semp]
sources:
  - citation: "INCOSE (2015). Systems Engineering Handbook, 4th edition. Wiley. Chapters 5.5 and 8.6."
    raw: incose_handbook_4e.pdf
  - citation: "Galinier, M., et al. (2021). Systems Engineering Practices for Small and Medium Enterprises. INCOSE-TP-2021-005-01."
    raw: galinier_sme_practices.pdf
related:
  - iso29110-pm-process
  - iso29110-sr-process
  - iso29110-overview
  - vse-canonical-project-layout
  - ambse-iso29110-mapping
  - ambse-risk-and-metrics
  - sysml2-vse-library-metadata
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [iteration-orchestrator]
---

# INCOSE CM, Risk Management, and VSE Scaling Guidance

## Configuration management purpose

Manage and control system elements and their configurations
across the lifecycle so that the integrity of the product
baseline is maintained at all times. CM is mandatory in the
ISO/IEC 29110 Basic profile (see iso29110-pm-process).

## Three baselines

| Baseline | Established at | Contains |
|----------|---------------|----------|
| Functional baseline | SRR | Validated stakeholder and system requirements |
| Allocated baseline | PDR/CDR | Architecture, allocated requirements, interface specs |
| Product baseline | TRR/delivery | Verified and validated system, test results, manuals |

In a SysML 2.0 model the baselines are encoded as `Baseline`
metadata instances applied to the relevant package set
(see sysml2-vse-library-metadata for the `Baseline` and
`ConfigItem` metadata definitions shipped in the `vse-library`).
A baseline corresponds to a git tag on the model repository at
the iteration boundary where the gate review closes.

## CM activities scaled for VSEs

1. **Plan**: define the CM strategy in the SEMP. Identify what
   will be controlled, naming conventions, versioning scheme,
   and change authority.
2. **Identification**: assign unique identifiers to all
   configuration items (CIs). A CI is any artefact that must be
   managed independently (requirement spec, design document,
   source code module, test procedure, hardware drawing).
3. **Change control**: all changes to baselined CIs go through a
   formal change process. Use a Change Request (CR) form. In a
   VSE the Configuration Control Board (CCB) may be as small as
   the project manager and technical lead. Classify changes as
   Class I (major, affects form/fit/function, requires customer
   approval) or Class II (minor, internal approval sufficient).
4. **Status accounting**: maintain a log of all CIs, their
   current version, and the status of all CRs. A
   version-controlled repository (Git or equivalent) combined
   with a simple change log satisfies this requirement for most
   VSE projects.
5. **Configuration audit**: verify that the as-built product
   matches the as-designed documentation before delivery.
   Perform a functional configuration audit (does the product
   meet its requirements?) and a physical configuration audit
   (does the documentation match the product?).
6. **Release control**: control the packaging and delivery of
   baselined products to the acquirer.

The vse-canonical-project-layout page describes how the
canonical directory structure exposes CIs as files and folders,
making the audit a `git diff` against the baseline tag rather
than a manual reconciliation.

## Risk management

Four risk categories: technical, cost, schedule, programmatic.
For each identified risk, assign probability (0 to 1) and
consequence, then calculate criticality as probability times
consequence. Treatment options: avoid, accept, mitigate
(control), or transfer. In a VSE, maintain a simple risk
register (spreadsheet) reviewed at each project meeting. Also
track opportunities (reuse of components, supplier cost
reductions) that can offset risk costs.

The ambse-risk-and-metrics page describes how the AMBSE workflow
embeds risks as `Risk` metadata in the model, so the risk
register is a query against the model rather than a separate
artefact.

## VSE scaling guidance (INCOSE Section 8.6)

ISO/IEC 29110 defines four progressive profiles for VSEs (see
iso29110-overview). Each smaller profile is a subset of the next
larger one.

| Profile | Target | Scope |
|---------|--------|-------|
| Entry | Start-ups, projects under 6 person-months | Minimal PM and engineering discipline |
| Basic | Single project team, no special risk | PM + System Definition and Realisation (full) |
| Intermediate | Multiple concurrent projects | Adds acquisition management, business management |
| Advanced | Growing system development business | Adds system transition and disposal |

For non-critical systems, the Basic profile provides sufficient
rigour. The tailoring must be risk-driven: increase formality
for safety-critical or mission-critical systems regardless of
organisation size.

## Maturity levels (Galinier et al.)

| Level | Characteristic | Key processes |
|-------|---------------|---------------|
| 1 | SE process not defined, hero culture, unpredictable | None formalised |
| 2 | Each project performs an SE process, structured, reactive | PM planning, PM monitoring, supplier management, requirements management, quality assurance, CM |
| 3 | SE processes are corporate-managed, proactive | Add: requirements engineering, architecture, IVV, risk management, interface management, measurement |
| 4 | Quantitative indicators drive SE processes, performance-driven | Add: quantitative process control via indicators |

Progress from level 1 to level 2 typically requires 10 to 18
months. Improvement plans should target 2 to 3 action plans of
10 to 18 months each. One improvement per project at a time to
avoid overloading the team.

## Practical scaling rules for VSEs

- **Roles, not people**: in a VSE one person fills multiple roles
  (project manager and systems engineer, designer and developer).
  Document which person holds which role. The role separation
  remains important even when one person executes both.
- **Lightweight artefacts**: use spreadsheets for traceability
  matrices, risk registers, and CM logs. Upgrade to specialised
  tools only when project complexity demands it.
- **SEMP as the anchor**: the Systems Engineering Management Plan
  defines the lifecycle, processes, reviews, deliverables, and
  tools for the project. Reuse the SEMP across projects with
  domain-specific add-ons.
- **Process baseline with add-ons**: build a common SE process
  baseline for the organisation (based on ISO/IEC 29110), then
  add domain-specific customisations per business area. This
  reduces training overhead and enables staff mobility between
  projects.
- **MBSE readiness**: do not adopt MBSE without experienced
  coaching, an adapted tool, and stakeholder buy-in. The return
  on investment of MBSE is primarily in upstream phases and
  reuse. Start with textual requirements and functional
  architecture diagrams before moving to full MBSE.
- **Agile integration**: agile approaches complement SE when the
  system is software-intensive, stakeholders are available for
  frequent validation, and development is model-driven. The key
  difference from agile software is that SE agility produces
  specifications, not executable increments. Use agile for the
  exploratory phase and harden into baselined specifications
  before hardware commitment. The
  ambse-iso29110-mapping page describes how AMBSE iterations
  map onto ISO/IEC 29110 PM and SR task instances.
- **Measure to improve**: track a small set of indicators
  (requirements volatility, IVV rework cost, cost-time variance,
  risk criticality trend). Indicators should arise naturally
  from project activities and not require additional overhead.
  The first indicator to set up is cost of defect correction
  measured in working time.

## Common VSE pitfalls

- Skipping stakeholder analysis because we know the customer.
- Writing implementation-dependent requirements that constrain
  the solution space prematurely.
- Performing big-bang integration instead of incremental builds.
- Treating configuration management as optional until a defect
  is lost.
- Allowing excessive management margin to accumulate through the
  approval hierarchy, making proposals uncompetitive.
- Imposing too many process changes simultaneously. One
  improvement per project is the recommended pace.
