// Smart Sensor variation points (§6.2).
//
// Per methodology §6.2, each architectural decision is captured as
// a variation point whose `variant` clauses enumerate the candidate
// alternatives. The variation point is the open question. The
// resolved variant is recorded in `variations/resolved/`.
//
// SysML 2.0 syntax: `variation` is a modifier on a part def or
// attribute def. The `variant` clauses inside enumerate alternatives.

package SmartSensor_DecisionPoints {

    private import SmartSensor_Context::*;

    // Decision: where the alert-history retention is implemented.
    // Two candidates currently in scope: device-side circular buffer
    // versus cloud-side time-series store. The §6 trade study scores
    // them against the criteria sourced from system-story constraints.
    variation part def AlertHistoryStorageStrategy {
        variant part deviceLocalRing : AlertHistoryDeviceRing;
        variant part cloudTimeSeries : AlertHistoryCloudStore;
    }

    // Candidate types referenced as variants. The trade study (in
    // `variations/trade-studies/`) assigns scores. The resolved
    // variant lives in `variations/resolved/` and is the part that
    // the system uses going forward.
    part def AlertHistoryDeviceRing {
        attribute capacityRecords : ScalarValues::Natural = 256;
        attribute retentionHours  : ScalarValues::Natural = 24;
    }

    part def AlertHistoryCloudStore {
        attribute capacityRecords : ScalarValues::Natural = 1000000;
        attribute retentionDays   : ScalarValues::Natural = 730;
    }

    private import ScalarValues::*;
}
