# Risk Register — Smart Sensor

Per methodology §10.7. Risks live as `@RiskInfo` metadata on model elements where they apply, with this register acting as the human-readable index. Reviewed at every release boundary.

| ID | Description | Severity | Likelihood | Status | Owner | Mitigation | Last updated |
|---|---|---|---|---|---|---|---|
| R-001 | Operator dashboard latency exceeds 5 s P95 under nominal load | High | Moderate | Mitigating | PJM | Cloud-region selection; load-replay fixture in V&V (VC_001) | 2026-05-05 |
| R-002 | Alert storm exhausts batch-acknowledgement budget when N approaches 1000 | High | Low | Open | PJM | Batched API design; VC_002 stresses upper bound | 2026-05-05 |
| R-003 | Field calibration procedure not robust to outdoor conditions (dust, glare on probe) | Moderate | Moderate | Open | PJM | Two-site validation in VAL_002 (one outdoor, one indoor) | 2026-05-05 |
| R-004 | Regulatory retention requirement tightens after release | Moderate | Moderate | Mitigating | PJM | Cloud-time-series variant selected (capacity 10^6 records, 730-day retention) | 2026-05-05 |

## Notes

- The session-start hook surfaces stale risks (more than `stale_threshold_days` since last updated). The default threshold is 30 days; configured in `.iso-config.yaml`.
- Risks tied to specific configurations carry a `@VariantScope` tag in the model element; cross-reference to the configuration is implicit.
