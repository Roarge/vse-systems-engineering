# 6. Architectural Analysis and Trade Studies

## 6.1 Purpose

This section specifies the workflow for selecting an architecture
against criteria sourced from the system story register (§5). It
produces a *resolved architecture*: a specialisation of the system
part def in which every architectural decision point has been
collapsed onto a chosen variant, traceable to the trade-study analysis
case that selected it.

The stage adapts the activities of Harmony aMBSE Chapter 6 (Douglass,
2016) to a SysML v2 native form. Three substantive shifts:

- **Candidate solutions are `variation`/`variant`** (spec §7.6.7),
  not narrative descriptions to be compared informally.
- **Trade-study criteria are sourced from the `benefit` constraints
  of system stories** (§0.3), not authored as a separate artefact.
- **The trade study itself is a `analysis def`** (spec §7.22) — and
  may use the standard library `TradeStudy` (spec §9.4.5), making the
  selection reproducible and the rationale a model element.

## 6.2 Inputs and outputs

**Inputs:**

- System story register (§5) with formalised `require constraint`
  clauses over value properties.
- Functional and behavioural elaborations from §5 (action defs, state
  defs, use cases).
- Base Architecture (§2) — constraints that any candidate must
  satisfy.

**Outputs:**

- Function and property set under architectural decision.
- One `variation` per decision point with `variant` candidates.
- Cross-decision constraints as `assert constraint`.
- One `analysis def` per trade study (or one composite analysis), each
  reproducing the selection.
- Resolved architecture — a specialisation of the system part def
  that redefines every variation to a chosen variant.

## 6.3 Workflow

### 6.3.1 Identify key system functions and properties

Extract from §5's `action def`, `use case def`, and `state def` set the
behaviours and qualities that the architecture must realise. Two
categories:

- **Functions** — behaviours the architecture must perform (e.g.,
  alarm acknowledgement, weather data ingestion, fault recovery).
- **Properties** — qualities the architecture must exhibit (e.g.,
  latency, throughput, mass, power consumption, cost).

Each function and property is candidate input to one or more
architectural decisions. A function whose realisation is unambiguous
(only one viable approach) is *not* a decision point and does not
appear in §6.3.2.

### 6.3.2 Define candidate solutions as variations

For each architectural decision, declare a `variation` and its
candidate `variant`s (spec §7.6.7). A `variation` is always abstract —
the `abstract` keyword is not used.

```sysml
package <ARCH> Aiwell_ArchitecturalDecisions {
    private import Aiwell_OnlineSentralContext::*;
    private import Aiwell_BaseArchitecture::*;

    variation part def AlarmStorageStrategy {
        variant part inMemoryRingBuffer {
            attribute capacity : Integer = 10000;
            attribute writeLatency : DurationValue = 1 [us];
        }
        variant part embeddedSQLite {
            attribute capacity : Integer = 1000000;
            attribute writeLatency : DurationValue = 200 [us];
        }
        variant part externalTSDB {
            attribute capacity : Integer = 100000000;
            attribute writeLatency : DurationValue = 5 [ms];
        }
    }

    variation part def CommunicationFabric {
        variant part modbusTCP : ModbusTCP;
        variant part opcua     : OPCUA;
    }
}
```

Variants implicitly subset the variation; they shall be specialisations
substitutable for the variation wherever it appears.

### 6.3.3 Express cross-decision constraints

Where decisions are not independent, declare `assert constraint`
clauses that relate the chosen variants. This is the
SysML-v2-native way to express "if A then B" architectural rules.

```sysml
part def Aiwell_OnlineSentral_Configurable :> Aiwell_OnlineSentral {
    variation part :>> alarmStorage : AlarmStorageStrategy;
    variation part :>> commsFabric  : CommunicationFabric;

    assert constraint storageImpliesProtocol {
        doc /* If the external time-series DB is selected for alarm
               storage, then OPC UA shall be the communication
               fabric. Tooling-specific predicates over variant
               selection are project-determined; the constraint body
               below shall evaluate the implication accordingly. */
    }
}
```

The constraint expresses "if the external time-series DB is chosen
for alarm storage, then OPC UA is required for communication" — a
real cross-cutting decision that `variation`/`variant` alone cannot
enforce.

The exact predicate form (`==`, `implies`, comparison against
`variation::variant` references) is project-determined: SysML v2
expression operators over variants depend on tooling support and
on whether variants are modelled as enumeration values, part defs,
or both. Where the predicate cannot yet be evaluated by tooling,
authoring the rule as a `doc` comment in the constraint body
preserves the rationale and lets reviewers enforce it manually.

### 6.3.4 Source assessment criteria from story benefits

Trade-study criteria are *not authored* in this stage. They are
extracted from the `require constraint` clauses already present in
the system story register (per §0.3). For each candidate-bearing
function or property, identify the stories whose benefit is sensitive
to the choice; the constraints those stories declare *are* the
criteria.

```sysml
// From §5: SYS_142_BatchAcknowledgement.sla =
//          { maxBatchAckLatency <= 1 [s] }
//
// This is a criterion for any decision that affects latency.

// From §5: SYS_198_MaintenanceLockout.acceptance — already a constraint
//          on actuator behaviour.
```

If a candidate-bearing function or property has *no* sensitive story,
either:

- the decision does not need a trade study (one variant is fine), or
- a story is missing from §5 — return to §5 and add it before
  proceeding.

This is the methodology pressure for completeness of the story
register: §6 cannot run if §5 is under-specified.

### 6.3.5 Perform the trade study

Use the standard library `TradeStudy` analysis case (spec §9.4.5) to
structure the comparison. The subject is the set of variants; the
evaluation function maps each variant to a scalar score; the objective
is to maximise (or minimise) the score.

```sysml
package <TS> Aiwell_TradeStudies {
    private import Analysis::TradeStudies::*;
    private import Aiwell_ArchitecturalDecisions::*;
    private import Aiwell_SystemStories::*;

    analysis def AlarmStorageTradeStudy :> TradeStudy {
        subject alternatives : AlarmStorageStrategy = (
            AlarmStorageStrategy::inMemoryRingBuffer,
            AlarmStorageStrategy::embeddedSQLite,
            AlarmStorageStrategy::externalTSDB
        );

        // Sourced from system story constraints (§6.3.4)
        attribute slaPenaltyWeight     : Real = 0.5;
        attribute capacityValueWeight  : Real = 0.3;
        attribute costWeight           : Real = 0.2;

        calc def evaluation : EvaluationFunction {
            in alternative : AlarmStorageStrategy;
            return result : ScalarValue =
                  slaPenaltyWeight    * latencyUtility(alternative.writeLatency)
                + capacityValueWeight * capacityUtility(alternative.capacity)
                + costWeight          * costUtility(alternative);
        }

        objective : MaximizeObjective {
            best : ScalarValue;
        }
    }
}
```

The trade-study sub-workflow:

1. **Source criteria** from story constraints (§6.3.4).
2. **Assign weights** that normalise to 1.0 across criteria.
   Weighting may be informed by `StoryMeta.priority` from §1.5 or by
   concern severity from §4.
3. **Define utility curves per criterion** as calculations mapping
   value-property values to a normalised score (typically 0–10 or
   0–1). Curves may be discrete (lookup tables) or continuous (linear,
   exponential, sigmoid).
4. **Evaluate each variant** by invoking the evaluation function.
   Tabulate results; the table is the trade-study's output.
5. **Determine the solution** as the variant with the best score.
   The selection is the analysis case's result.

### 6.3.6 Resolve variations

The selected architecture is expressed as a *specialisation* of the
configurable system part def in which every `variation` is redefined
to its chosen `variant` (spec §7.6.7, Figure 35.6 pattern).

```sysml
part def Aiwell_OnlineSentral_v1 :> Aiwell_OnlineSentral_Configurable {
    part :>> alarmStorage = AlarmStorageStrategy::embeddedSQLite;
    part :>> commsFabric  = CommunicationFabric::modbusTCP;
}
```

The resolution is *itself a model element*. It is checked against the
`assert constraint` clauses of the configurable part def: if the chosen
combination violates an assertion, validation fails and the resolution
is invalid.

If multiple resolutions are kept (e.g., for a product family), each is
its own specialisation. The methodology does not assume one project →
one resolution; it does assume each resolution is fully resolved (no
unresolved variations).

### 6.3.7 Merge across decisions

Where the trade study was repeated for multiple functions or
properties, integrate the selected variants into a single resolved
architecture. Where the integration surfaces conflicts that the
`assert constraint` rules did not anticipate, run a meta-trade-study
over the conflict — i.e., add a new decision point whose variants are
the conflicting combinations, and trade-study it the same way.

## 6.4 Recursive application at component level

Components identified in §7 may themselves be subjects of architectural
analysis at their own scope. §6 applies recursively with these
substitutions:

- "system" reads as "subsystem";
- variations are scoped to the subsystem and reside in the
  component's own `variations/` folder per §8.3.2;
- criteria are sourced from subsystem-level stories.

System-level and subsystem-level trade studies may reference each
other where decisions interact, but they are tracked as separate
analyses to keep the decision history per scope.

## 6.5 SysML v2 syntactic patterns

| Pattern | Form | Spec ref |
|---|---|---|
| Variation point | `variation part def Name { variant part v1; variant part v2; }` | §7.6.7 |
| Cross-decision rule | `assert constraint { v1 == v1::a implies v2 == v2::b }` | §7.6.7, §7.19 |
| Trade-study case | `analysis def Name :> TradeStudy { subject … ; calc def evaluation … ; objective … ; }` | §7.22, §9.4.5 |
| Maximise / minimise | `objective : MaximizeObjective { best : ScalarValue; }` | §9.4.5 |
| Resolution | `part def Selected :> Configurable { part :>> variation = variation::chosenVariant; }` | §7.6.7 |

## 6.6 Well-formedness rules

1. Every `variation` shall declare at least two `variant`s. A
   single-variant variation is a decision that has already been made
   and shall be modelled as a redefined feature, not a variation
   point.
2. Every trade-study `analysis def` shall reference at least one
   `require constraint` from the system story register (its criteria
   sources). An analysis with no story references is unrooted.
3. Weights across the criteria of one trade study shall sum to 1.0.
   CI may enforce this numerically.
4. Every utility curve shall declare its lower and upper bounds.
   Unbounded curves admit nonsense values from out-of-scope variants.
5. The resolved architecture shall redefine *every* variation in the
   configurable part def. A resolution leaving a variation unresolved
   is incomplete and shall not pass §8.6.3 final review.
6. The resolved architecture shall satisfy every `assert constraint`
   declared on the configurable part def. CI may evaluate the
   constraints against the resolved bindings.

## 6.7 Out of scope

- Specific weighting methodology. The four factors of §4.3.3 inform
  weights but the procedure is project-determined.
- Solver choice. The methodology specifies that trade-study analyses
  are reproducible; the actual solver (analytical, simulation,
  external) is project-determined.
- Sensitivity analysis. Useful but not specified here.
- Product-line feature-model integration. The variation/variant
  mechanism is the foundation; full feature modelling is a separate
  methodology layer (per §0.9).

---

*End of Section 6.*
