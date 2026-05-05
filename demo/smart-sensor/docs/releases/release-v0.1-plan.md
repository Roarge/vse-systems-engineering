# Release v0.1 plan — Smart Sensor

Per methodology §10.5. Tag: `release-v0.1` (planned, not yet cut).

## Scope

The first release covers the dashboard-monitoring path end to end. Stories included:

| Story ID | Title | Status target |
|---|---|---|
| US_001 | SeeReadingsOnDashboard | done |
| SYS_001 | DashboardLatency | done |

The alert-acknowledgement path (US_002, SYS_002) is targeted for v0.2 once the cloud-side alert store is integrated. The field-calibration story (US_003) is targeted for v0.3 alongside the maintenance procedure documentation.

## Verification and validation closure

Before tagging:

- [ ] VC_001 (DashboardLatencyP95) passes against the demo deployment.
- [ ] VAL_001 (OperatorSeeReadings) passes at the dogfood site.
- [ ] Traceability matrix has no orphan acceptance criteria for any included story.

## Configuration items frozen at this release

Per `.iso-config.yaml`:

- `methodology/` (project-local copy)
- `model/library/`
- `docs/project-plan.md`
- `docs/cm-strategy.md`
- `docs/risk-register.md`

Plus the model files realising the included stories.

## Supersession

This is the initial release. There is no superseded baseline.

## Open Change Requests carried forward

None at planning time.
