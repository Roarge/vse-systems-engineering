// Smart Sensor resolved variants (§6.3.5).
//
// Per methodology §6.3.5, once the trade study disposition is
// recorded, the selected variant is materialised here as the part
// the system actually uses. The decision narrative lives in an ADR
// under `docs/decisions/`.

package SmartSensor_Resolved {

    private import SmartSensor_DecisionPoints::*;

    // AlertHistoryStorageStrategy resolved on 2026-04-15 in favour of
    // cloudTimeSeries. ADR: docs/decisions/2026-04-15-alert-history.md.
    part alertHistory : AlertHistoryCloudStore;
}
