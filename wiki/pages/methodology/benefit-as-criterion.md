---
title: "Benefit constraint as trade-study criterion"
slug: benefit-as-criterion
type: concept
layer: methodology
tags: [trade-study, user-stories, criteria, traceability, variation, benefit]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §0.3 (The Connective Mechanism — `benefit` as Trade-Study Criterion)."
    raw: methodology/00-methodology-overview.md
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §6.3.4 (Source assessment criteria from story benefits)."
    raw: methodology/06-architectural-analysis.md
related:
  - methodology-overview
  - user-story-canonical-artefact
  - architectural-analysis-workflow
  - system-stories-workflow
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, architecture-design, needs-and-requirements]
---

# Benefit constraint as trade-study criterion

The methodology's load-bearing structural property is that the `benefit` slot of a user story, when expressed as a `require constraint` over value properties of the system, *is* the same model element that supplies assessment criteria during architectural trade studies (§6). One element, two roles. There is no separate criterion-authoring artefact and no intermediate translation step.

## The principle

A story declares stakeholder intent in the form `as a <role>, I want <capability>, so that <benefit>`. When the benefit is left as informal prose, it carries intent but nothing more. When the benefit is sharpened into a `require constraint` over value properties (per §1.4.3), it becomes a machine-checkable predicate that any candidate architecture either satisfies or violates. That predicate is exactly the shape a trade-study criterion needs.

The architectural trade study in §6 therefore does not invent criteria. It reaches into the system story register, pulls the `require constraint` clauses from the stories whose benefits are sensitive to the decision under study, and uses those constraints directly inside its `analysis def`.

## Consequence: no drift from stakeholder intent

Because the criteria are the same model elements as the stakeholder intent, an architectural decision cannot drift from the intent that justifies it. The trace is structural, not narrative. If a story is amended, every trade study that sourced its benefit constraint is amended automatically because they reference the same element. If a story is retired, the criteria it supplied are retired with it.

This removes a class of failure familiar from informal practice: a trade study that scores well against criteria the team invented, while silently missing the constraint the stakeholder actually cares about.

## Pressure to formalise benefits

Stories that enter the model in the §1.7.1 minimal form, with benefit as a free-text string, cannot supply criteria. They still travel through the methodology and may receive a use case elaboration, an acceptance criterion, and a verification case, but they are inert at §6 entry.

This creates a deliberate methodology pressure: before a story's capability area enters architectural analysis, its benefit must be formalised. The pressure is local to the story, not global to the backlog. A story whose benefit is untouched by any architectural decision under study can stay informal indefinitely.

The pressure manifests at the §5 to §6 boundary. The [[architectural-analysis-workflow]] cannot run cleanly on a system story register whose decision-relevant benefits are still strings.

## What §6.3.4 does when no story matches

When a candidate-bearing function or property has no story whose benefit is sensitive to the decision, the methodology forces a binary judgement:

- **The decision needs no trade study.** One viable variant satisfies every relevant constraint already in the register. Pick it. Record the choice. Move on.
- **A story is missing.** The architecture is being asked to optimise for something the stakeholder register does not name. Stop the trade study, hand off to the needs-and-requirements skill, add the missing story to §4 or §5, then resume.

The methodology refuses to author criteria locally inside §6. There is no provision for "trade-study criteria that exist only in the trade study". Every criterion shall trace, through a `require constraint`, to a story whose `frame concern` connects it back to a stakeholder.

## SysML 2.0 worked example

A system story with a formalised benefit, then a trade-study analysis that sources its criterion directly from that benefit:

```sysml
// §5: a system story whose benefit is now a constraint, not a string
requirement def SYS_142_BatchAcknowledgement :> SystemUserStory {
    subject sentral : Aiwell_OnlineSentral;
    role     operator : Operator;
    capability : "acknowledge alarm batches in one action";
    benefit  : "operator workload during alarm storms remains tractable";

    require constraint sla {
        sentral.maxBatchAckLatency <= 1 [s]
    }
}

// §6.3.4: the trade study reaches into SYS_142.sla for its criterion
analysis def AlarmStorageTradeStudy :> TradeStudy {
    subject alternatives : AlarmStorageStrategy = (
        AlarmStorageStrategy::inMemoryRingBuffer,
        AlarmStorageStrategy::embeddedSQLite,
        AlarmStorageStrategy::externalTSDB
    );

    // Criterion sourced directly from the story constraint above
    attribute slaConstraint = SYS_142_BatchAcknowledgement::sla;
    attribute slaWeight     : Real = 0.5;

    calc def evaluation : EvaluationFunction {
        in alternative : AlarmStorageStrategy;
        return result : ScalarValue =
            slaWeight * latencyUtility(alternative.writeLatency);
    }

    objective : MaximizeObjective { best : ScalarValue; }
}
```

The `slaConstraint` attribute references the story's constraint as a model element. Editing the story edits the criterion. Retiring the story breaks the analysis until the project either retires the analysis with it or substitutes another story-sourced constraint.

## Why this matters

This single property is what makes the methodology's traceability claim machine-readable rather than aspirational. Stakeholder concern frames a story (§4). The story's benefit becomes a constraint (§5). The constraint becomes a trade-study criterion (§6). The trade study selects a variant. The variant is redefined into the resolved architecture (§6.3.6). Every link in the chain is a model relationship, not a spreadsheet row. See [[methodology-overview]] §0.3 for the principle in its source form, and [[user-story-canonical-artefact]] for the formalisation rules that make a benefit constraint trade-study-ready.
