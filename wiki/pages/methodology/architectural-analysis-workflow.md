---
title: "Architectural Analysis and Trade Studies workflow (§6)"
slug: architectural-analysis-workflow
type: process
layer: methodology
tags: [trade-study, variation, variant, analysis-def, architecture, sr-3]
sources:
  - citation: "vse-systems-engineering plugin (2026). Methodology Specification §6 (Architectural Analysis and Trade Studies)."
    raw: methodology/06-architectural-analysis.md
related:
  - methodology-overview
  - benefit-as-criterion
  - system-stories-workflow
  - architectural-design-workflow
confidence: high
created: 2026-05-05
updated: 2026-05-05
bundled_by: [vse-companion-overview, architecture-design, story-orchestrator]
---

# Architectural Analysis and Trade Studies workflow (§6)

Section 6 of the methodology specifies how a System User Story set is turned into a *resolved architecture*: a specialisation of the system part def in which every architectural decision point has been collapsed onto a chosen variant, traceable to the trade-study analysis case that selected it. The stage adapts Harmony aMBSE Chapter 6 to a SysML v2 native form, with three substantive shifts. Candidate solutions are modelled as `variation` and `variant` (spec §7.6.7) rather than narrative descriptions. Trade-study criteria are sourced from the `benefit` constraints already formalised on system stories (per §0.3), not authored as a separate artefact. The trade study itself is an `analysis def` (spec §7.22), optionally specialising the standard library `TradeStudy` (spec §9.4.5), which makes the selection reproducible and the rationale a model element.

## Inputs

The stage consumes the System User Story register produced in [[system-stories-workflow]] with formalised `require constraint` clauses over value properties, the functional and behavioural elaborations from §5 (action defs, state defs, use cases), and the Base Architecture from §2 expressed as constraints any candidate must satisfy. See [[methodology-overview]] for how §6 is positioned across the methodology.

## Workflow

### §6.3.1 Identify key system functions and properties

Extract from the §5 set of `action def`, `use case def`, and `state def` declarations the behaviours and qualities that the architecture must realise. Two categories result: *functions*, which are behaviours the architecture must perform (alarm acknowledgement, weather data ingestion, fault recovery), and *properties*, which are qualities the architecture must exhibit (latency, throughput, mass, power consumption, cost). Each function and property is a candidate input to one or more architectural decisions. A function whose realisation is unambiguous (only one viable approach) is not a decision point and does not appear in the next sub-step.

### §6.3.2 Define candidate solutions as variations

For each architectural decision, declare a `variation` and its candidate `variant` features (spec §7.6.7). A `variation` is always abstract. Variants implicitly subset the variation and shall be specialisations substitutable for the variation wherever it appears.

```sysml
variation part def AlarmStorageStrategy {
    variant part inMemoryRingBuffer {
        attribute capacity      : Integer       = 10000;
        attribute writeLatency  : DurationValue = 1 [us];
    }
    variant part embeddedSQLite {
        attribute capacity      : Integer       = 1000000;
        attribute writeLatency  : DurationValue = 200 [us];
    }
    variant part externalTSDB {
        attribute capacity      : Integer       = 100000000;
        attribute writeLatency  : DurationValue = 5 [ms];
    }
}
```

### §6.3.3 Express cross-decision constraints

Where decisions are not independent, declare `assert constraint` clauses that relate the chosen variants. This is the SysML v2 native way to express "if A then B" architectural rules, that is, the cross-cutting decisions that `variation`/`variant` alone cannot enforce. The exact predicate form (equality, `implies`, comparison against `variation::variant` references) is project-determined, because expression operators over variants depend on tooling support and on whether variants are modelled as enumeration values, part defs, or both. Where the predicate cannot yet be evaluated by tooling, authoring the rule as a `doc` comment in the constraint body preserves the rationale and lets reviewers enforce it manually.

### §6.3.4 Source assessment criteria from story benefits

Trade-study criteria are not authored at this stage. They are extracted from the `require constraint` clauses already present in the system story register, per the connective mechanism described in [[benefit-as-criterion]]. For each candidate-bearing function or property, identify the stories whose benefit is sensitive to the choice. The constraints those stories declare are the criteria. If a candidate-bearing function or property has no sensitive story, either the decision does not need a trade study (one variant is sufficient), or a story is missing from §5 and the engineer returns to the story register before proceeding. This is the methodology pressure for completeness. §6 cannot run if §5 is under-specified.

### §6.3.5 Perform the trade study

Use the standard library `TradeStudy` analysis case (spec §9.4.5) to structure the comparison. The subject is the set of variants, the evaluation function maps each variant to a scalar score, and the objective is to maximise (or minimise) that score. The trade study itself is an `analysis def`, which makes selection and rationale first-class model elements. The sub-workflow has five steps.

1. Source criteria from story constraints (per §6.3.4).
2. Assign weights that normalise to 1.0 across criteria. Weighting may be informed by `StoryMeta.priority` from §1.5 or by concern severity from §4.
3. Define utility curves per criterion as calculations mapping value-property values to a normalised score (typically 0 to 10 or 0 to 1). Curves may be discrete (lookup tables) or continuous (linear, exponential, sigmoid).
4. Evaluate each variant by invoking the evaluation function and tabulate the results. The table is the trade study's output.
5. Determine the solution as the variant with the best score. The selection is the analysis case's result.

### §6.3.6 Resolve variations

The selected architecture is expressed as a *specialisation* of the configurable system part def in which every `variation` is redefined to its chosen `variant` (spec §7.6.7, Figure 35.6 pattern).

```sysml
part def Aiwell_OnlineSentral_v1 :> Aiwell_OnlineSentral_Configurable {
    part :>> alarmStorage = AlarmStorageStrategy::embeddedSQLite;
    part :>> commsFabric  = CommunicationFabric::modbusTCP;
}
```

The resolution is itself a model element. It is checked against the `assert constraint` clauses of the configurable part def. If the chosen combination violates an assertion, validation fails and the resolution is invalid. If multiple resolutions are kept (for example, for a product family), each is its own specialisation. The methodology does not assume one project to one resolution, but it does assume each resolution is fully resolved with no unresolved variations.

### §6.3.7 Merge across decisions

Where the trade study was repeated for multiple functions or properties, integrate the selected variants into a single resolved architecture. Where the integration surfaces conflicts that the `assert constraint` rules did not anticipate, run a meta trade study over the conflict, that is, add a new decision point whose variants are the conflicting combinations and trade-study it the same way.

## Output artefacts

The stage produces the function and property set under architectural decision, one `variation` per decision point with its `variant` candidates, the cross-decision constraints expressed as `assert constraint` clauses, one `analysis def` per trade study (or a single composite analysis), and the resolved architecture as a specialisation of the configurable system part def that redefines every variation to a chosen variant. The resolved architecture is the hand-off artefact for [[architectural-design-workflow]], where it is elaborated into the detailed structural and behavioural model.
