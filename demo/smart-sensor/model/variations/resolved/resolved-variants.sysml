// Smart Sensor resolved architecture (§6.3.5, §6.6 rule 5).
//
// Per methodology §6.3.5, once a trade-study disposition is recorded
// the resolved architecture is a specialisation of the system part
// def that redefines every variation to a chosen variant. §6.6
// rule 5 makes this the well-formedness criterion: a resolution
// that leaves a variation unresolved is not a closed architecture.
//
// Two specialisations carry the pattern:
//   - SmartSensor_System_Configurable     declares the variation slot.
//   - SmartSensor_System_v1               redefines it to a variant.
//
// The decision narrative lives in `docs/decisions/2026-04-15-alert-history.md`.

package SmartSensor_Resolved {

    private import SmartSensor_Context::*;
    private import SmartSensor_DecisionPoints::*;

    // The configurable specialisation of the system part def adds a
    // variation slot for every architectural decision the project
    // makes. Cross-decision rules (where they exist) are
    // `assert constraint` clauses on this part def.
    part def SmartSensor_System_Configurable :> SmartSensor_System {
        part alertHistory : AlertHistoryStorageStrategy;
    }

    // Resolved-architecture specialisation. Each `:>>` line redefines
    // a variation slot to a specific variant. Resolved on 2026-04-15;
    // ADR at docs/decisions/2026-04-15-alert-history.md.
    part def SmartSensor_System_v1 :> SmartSensor_System_Configurable {
        part :>> alertHistory = AlertHistoryStorageStrategy::cloudTimeSeries;
    }
}
