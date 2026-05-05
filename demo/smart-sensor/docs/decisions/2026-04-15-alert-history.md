# ADR 2026-04-15 — Alert history storage strategy

## Status

Accepted (2026-04-15). Resolves `SmartSensor_DecisionPoints::AlertHistoryStorageStrategy`.

## Context

Alert history needs to be retained long enough to satisfy the regulator's data-retention requirement (concern `DataRetentionCompliance`) and made accessible to the operator's dashboard within the latency budget set by `SYS_001_DashboardLatency.dashboardSla` and the operator workload constraint of `SYS_002_BatchAcknowledgement.batchAckSla`.

Two candidates were carried into the trade study:

- `deviceLocalRing` — a 256-record circular buffer in device flash, retaining roughly 24 hours of alerts.
- `cloudTimeSeries` — a managed cloud time-series store with capacity 10^6 records and a 730-day retention window.

## Decision

Adopt `cloudTimeSeries`.

## Trade study summary

Per `model/variations/trade-studies/alert-history-trade.sysml`:

| Criterion | Weight | deviceLocalRing | cloudTimeSeries |
|---|---|---|---|
| Latency (SYS_001 dashboardSla) | 0.30 | 5 | 3 |
| Regulatory retention (concern) | 0.45 | 1 | 5 |
| Operator workload (SYS_002 side-effect) | 0.25 | 3 | 4 |
| **Weighted total** | 1.00 | **2.70** | **4.15** |

The 1.45-point margin holds with regulatory-retention weight as low as 0.30. The recommendation is sensitive to the regulatory-retention weight.

## Consequences

- The cloud-side storage interface is in scope for §7 architectural design.
- The device firmware does not need a long-retention buffer; a small forward queue suffices.
- The cloud-side baseline cost is now part of the operating budget (R-004 in the risk register acknowledges the dependency on regulatory stability).

## Cross-references

- Variation point: `model/variations/decision-points/decision-points.sysml`
- Resolved variant: `model/variations/resolved/resolved-variants.sysml`
- Trade study: `model/variations/trade-studies/alert-history-trade.sysml`
- Risk: R-004 (`docs/risk-register.md`)
