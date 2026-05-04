---
title: "AMBSE Trade Study Methodology"
slug: ambse-trade-studies
type: process
layer: ambse
tags: [trade-study, moe, weighted-criteria, sensitivity, justification-document]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapter 6 (architectural analysis)."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
related:
  - ambse-architecture-analysis
  - ambse-architectural-design
  - ambse-architecture-vv-and-iso29110
  - sysml2-domain-libraries-metadata-analysis
  - iso29110-pm-task-checklists
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [architecture-design]
---

# AMBSE Trade Study Methodology

Trade studies are the primary mechanism for making defensible
architectural decisions. The method ensures decisions are
**traceable, reproducible, and based on stakeholder-weighted
criteria** rather than personal preference. For the broader
architectural-analysis context see [[ambse-architecture-analysis]].

## Workflow steps

1. **Define assessment criteria** (measures of effectiveness,
   MOEs) derived from system requirements. Typical criteria:
   performance, cost, risk, schedule, weight, power consumption,
   maintainability, safety.
2. **Assign weights to criteria** reflecting stakeholder
   priorities (sum to 1.0).
3. **Define utility curves** for non-linear criteria (optional
   for VSEs, but important when a criterion has a threshold
   effect, such as "good enough" vs "unacceptable").
4. **Score each candidate** against each criterion (0.0 to
   1.0).
5. **Compute weighted scores** and rank candidates.
6. **Perform sensitivity analysis**: vary the weights by +/-
   10-20% and check whether the ranking changes. If the top
   candidate is sensitive to small weight changes, the decision
   needs more analysis.
7. **Document the rationale** in a Justification Document (or
   as a doc comment on the selected architecture element in
   SysML 2.0).

## VSE trade study guidance

- A simple weighted matrix in a markdown table or spreadsheet
  suffices.
- Always consider at least two alternatives (even "do nothing"
  counts).
- The process matters more than the precision: the discipline
  of explicitly stating criteria and weights surfaces hidden
  assumptions.
- Record the trade study rationale in the model or in a
  lightweight decision record (the `@architecture-design` skill
  carries an ADR template).

The Justification Document is also the ISO 29110 PM.3.3 output
(see [[iso29110-pm-task-checklists]]); a trade study is one of
the events that updates it.

## SysML 2.0 trade study documentation

The SysML 2.0 Analysis library provides a `TradeStudy`
construct (specialising AnalysisCase). For the full library
reference see [[sysml2-domain-libraries-metadata-analysis]].

```sysml
package TradeStudy_MotorControl {
    doc /* Trade study for motor control architecture.
           Candidates: (A) Direct PWM control, (B) FOC with encoder.
           Criteria: performance (0.4), cost (0.3), risk (0.2), schedule (0.1).
           Result: Candidate B selected (weighted score 0.78 vs 0.65).
           Sensitivity: Robust to +/- 15% weight variation. */

    // Selected architecture
    part def MotorControlSubsystem {
        doc /* FOC with encoder, selected per trade study above. */
        part controller : FOCController;
        part encoder : RotaryEncoder;
        part driver : MotorDriver;
    }
}
```

For VSE projects without the full Analysis library overhead, a
markdown table with the criteria, weights, scores, and selected
candidate is sufficient. The point is the **discipline of
explicit criteria**, not the formalism.

## Subagent dispatch

The plugin's `@architecture-design` skill dispatches the
`vse-trade-study-runner` subagent to score candidate options in
parallel against weighted criteria. The subagent returns a
suggestion-shaped trade-off matrix with sensitivity analysis;
the engineer edits the result before any artefact is committed.

## See also

- [[ambse-architecture-analysis]] for the broader analysis
  workflow that uses trade studies.
- [[ambse-architectural-design]] for the design workflow that
  follows.
- [[ambse-architecture-vv-and-iso29110]] for V&V and the ISO
  29110 mapping.
- [[sysml2-domain-libraries-metadata-analysis]] for the full
  TradeStudy SysML 2.0 library construct.
- [[iso29110-pm-task-checklists]] for PM.3.3 (Justification
  Document) and SR.3.2 (functional architecture trade-offs).
