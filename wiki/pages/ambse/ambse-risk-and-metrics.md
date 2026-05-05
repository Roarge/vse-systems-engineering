---
title: "AMBSE Risk Management and SE Metrics"
slug: ambse-risk-and-metrics
type: reference
layer: ambse
tags: [risk-management, spikes, metrics, velocity, defect-density, vse]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapters 1-2 (risk and metrics sections)."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
related:
  - ambse-principles
  - ambse-iso29110-mapping
  - sysml2-vse-library-metadata
  - sysml2-model-cm-and-risks
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [release-orchestrator]
---

# AMBSE Risk Management and SE Metrics

## Risk management in agile SE

Risk is the product of an event's likelihood of occurrence and
its severity. In agile SE, risks are managed as backlog items
alongside functional work.

### Risk types

| Type | Example |
|---|---|
| Technical | Selected bus architecture may lack sufficient bandwidth |
| Resource | Key team members unavailable for 6 months |
| Schedule | Customer schedule is optimistic |
| Business | Market conditions may change before delivery |

### Risk management workflow

1. **Identify** potential sources of risk (at project start
   and each iteration retrospective).
2. **Characterise** the risk: describe the negative outcome,
   estimate likelihood and severity.
3. **Prioritise**: risk magnitude = likelihood x severity;
   maintain a priority-ordered risk list.
4. **Create a spike**: a work item to reduce either the
   likelihood or severity of the risk.
5. **Allocate** the spike to an iteration plan.
6. **Perform** the spike and assess the outcome.
7. **Update** the risk list (mark as mitigated, escalate, or
   replan).

### VSE risk guidance

- Maintain the risk list as a view of the project backlog, not
  a separate artefact.
- Address highest-risk items in the earliest iterations.
- **Featurecide** (removing low-value features) is a valid
  strategy for schedule risk.
- Review the risk list at every iteration retrospective.

For the SysML 2.0 model-level risk register that supports this
workflow, see [[sysml2-model-cm-and-risks]] and
[[sysml2-vse-library-metadata]] (RiskInfo metadata).

## SE metrics

Metrics should be used for guidance, not as goals for strict
compliance. Good metrics are easy to measure, easy to automate,
and accurately capture the property of interest.

### Recommended SE metrics

| Metric | Measures | Category |
|---|---|---|
| SE velocity | Use cases specified per iteration | Productivity |
| SE fine-grained velocity | Story points per iteration | Productivity |
| Burn down rate | Work items remaining over time | Completeness |
| Requirements churn | Rate of change of requirements over time | Stability |
| Defect density | Defects per model element | Quality |
| Escaped defects | Defects found by stakeholders | Quality |
| Running tested features | Verified system features | Completeness |
| Open defect age | Average time from defect discovery to resolution | Responsiveness |
| Remaining risk | Sum of risk exposure values on the risk list | Risk |

### VSE metrics guidance

- Measure frequently (every iteration) and keep measurements
  low-effort.
- Use retrospectives (not post-mortems) to review metrics and
  adjust.
- Start with SE velocity and defect density; add others as
  needed.
- Automate metric collection where possible (SySiDE validation
  counts, Git statistics).

## See also

- [[ambse-principles]] for the SE-versus-software distinction.
- [[methodology-overview]] for the planning hierarchy that
  generates the work items risk and metrics consume.
- [[ambse-iso29110-mapping]] for the AMBSE-to-ISO 29110 table
  that maps risk and metric activities to PM.2 / PM.3.
- [[sysml2-model-cm-and-risks]] for the model-level risk
  register pattern.
- [[sysml2-vse-library-metadata]] for `RiskInfo`,
  `VariantScope`, and other VSE_Library metadata definitions.
