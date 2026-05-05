# Risk Register

Per methodology §10.7 and ISO 29110 PM.O5. The Risk Management Approach prose lives in the Project Plan. This file is the live register.

Each entry has the columns below. Likelihood and impact are scored against a project-determined scale. Priority is the product. Status moves through `open`, `mitigating`, `monitoring`, `closed`. Where a risk's mitigation becomes engineering work, the mitigation is captured as a story rather than an action item here.

| ID | Description | Likelihood | Impact | Priority | Owner | Treatment | Status | Date opened | Date last reviewed |
|---|---|---|---|---|---|---|---|---|---|
| RSK-001 | (Example) Platform vendor delays critical firmware release | medium | high | high | {{PJM}} | mitigate, plan B | open | 2026-05-05 | 2026-05-05 |

## Conventions

- **ID** uses `RSK-` prefix with a zero-padded numeric tail.
- **Likelihood** and **Impact** are project-determined enums (for example, `low | medium | high | critical`).
- **Priority** is computed from likelihood and impact per the scale documented in the Project Plan's Risk Management Approach.
- **Treatment** is one of: `avoid`, `mitigate`, `transfer`, `accept`. Record per-risk action notes in a comment column or a separate per-risk file.
- **Status** transitions: `open` (newly identified), `mitigating` (treatment in flight, possibly as a story), `monitoring` (treatment complete, monitoring residual risk), `closed` (no longer applicable).

## Stale-risk threshold

Per `.iso-config.yaml` `risk_register.stale_threshold_days`, risks not reviewed within the threshold are flagged by the SessionStart hook and surfaced in `/vse-audit` reports.
