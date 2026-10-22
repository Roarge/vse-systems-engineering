// Validation cases (§4.3.6).
//
// A validation case binds to acceptance criteria of a stakeholder
// story. It exercises stakeholder intent rather than system
// internals. Answers are typically obtained by demonstration,
// walkthrough, or operational test rather than automated unit-level
// check.
//
// `verify <story>.acceptance.<criterion>` reaches the one criterion
// that a scenario of the story's feature file states, and
// `verify <story>.acceptance` reaches every criterion (§11.3.3). The
// case must exist, as a stub at least, by the time the story reaches
// inProgress (§11.4). A stub holds the subject and the objective.
//
// Identifier convention: VAL_<n>_<ShortName>.

package {{PROJECT_NAME}}_ValidationCases {

    private import {{PROJECT_NAME}}_Context::*;
    private import {{PROJECT_NAME}}_StakeholderStories::*;

    verification def VAL_001_Example {
        subject sys : {{PROJECT_NAME}}_System;

        objective {
            verify US_001_Example.acceptance.exampleCriterion;
        }

        action collectData { doc /* observed user task on representative hardware */ }
        action evaluate    { doc /* pass criterion in stakeholder vocabulary */ }
    }
}
