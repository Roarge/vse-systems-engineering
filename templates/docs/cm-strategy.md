# Configuration Management Strategy

Per methodology §10.8 and ISO 29110 PM.O6. This file is the project's Configuration Management Strategy. It may be a section of `docs/project-plan.md` or a separate document referenced from the Plan, project-determined.

```yaml
# Configuration Management Strategy

substrate: git (origin + backup remote)

items_under_cm:
  - Project Plan                      # docs/project-plan.md
  - SEMP                              # docs/semp.md
  - Methodology specification         # methodology/
  - Stakeholder Story Register        # model/core/stories/stakeholder/
  - System Story Register             # model/core/stories/system/
  - Subsystem Story Registers         # model/core/logical-architecture/components/<comp>/stories/
  - Concern Register                  # model/core/concerns/
  - Base Architecture                 # model/core/base-architecture/
  - System Context                    # model/core/context/
  - Logical Architecture              # model/core/logical-architecture/
  - Trade Studies                     # model/variations/trade-studies/
  - Verification Cases                # model/core/verification-validation/verification-cases/
  - Validation Cases                  # model/core/verification-validation/validation-cases/
  - IVV Plan and Procedures           # rendered from cases (docs/generated/)
  - Risk Register                     # docs/risk-register.md
  - Justification Document            # rendered (docs/generated/)
  - Methodology Library               # model/library/

states:
  - draft         # In a feature branch only
  - inProgress    # PR open
  - readyForReview  # PR marked ready for review
  - baselined     # Merged to main and tagged

baseline_strategy:
  cadence: per release
  mechanism: annotated git tag (release-vN.M)
  retention: indefinite

plan_baseline_strategy:
  cadence: per Plan revision
  mechanism: annotated git tag (plan-baseline-vN.M)
  retention: indefinite

backup:
  primary: <github org>/<repo>
  mirror:  <gitlab org>/<repo>
  schedule: continuous (post-receive hook on canonical remote)
  recovery_test: monthly, automated

access_control:
  protected_branches: [main, release/*]
  force_push: disabled on protected branches
  required_reviews: 1 (CODEOWNERS-driven)
```

## Notes

- The CM substrate is git. The repository, branch model, and PR workflow are the configuration management mechanism. See `methodology/08-project-structure.md` for the binding rules.
- Baselined items are protected by the `pre-commit` hook (which blocks unreferenced edits) and the `commit-msg` hook (which requires a CR reference). Both are project-side hooks installed under `.githooks/`.
- The `post-receive` hook on the canonical remote performs the continuous mirror to the backup remote.
- The Recovery Test is a project-side script that pulls from the backup remote into a scratch clone monthly and verifies the working tree matches the canonical remote.
