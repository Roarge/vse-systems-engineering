// Verification cases (§5.4.6).
//
// A verification case binds to one or more acceptance criteria of a
// system story via `objective { verify ... }`. It exercises the
// system as modelled (model execution, simulation, automated check),
// distinct from validation cases that exercise stakeholder intent.
//
// `verify <story>.acceptance.<criterion>` reaches the one criterion
// that a scenario of the story's feature file states, and
// `verify <story>.acceptance` reaches every criterion (§11.3.3). A
// stub holding the subject and the objective is enough before the
// story moves to inProgress (§11.4).
//
// Identifier convention: VC_<n>_<ShortName>.

package {{PROJECT_NAME}}_VerificationCases {

    private import {{PROJECT_NAME}}_Context::*;
    private import {{PROJECT_NAME}}_SystemStories::*;

    verification def VC_001_Example {
        subject sys : {{PROJECT_NAME}}_System;

        objective {
            verify SYS_001_Example.sla;
            verify SYS_001_Example.acceptance.exampleCriterion;
        }

        action setup    { doc /* fixture preparation */ }
        action measure  { doc /* observation method */ }
        action evaluate { doc /* pass criterion in measurable form */ }
    }
}
