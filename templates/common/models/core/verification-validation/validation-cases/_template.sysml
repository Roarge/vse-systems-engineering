// Validation cases (§4.3.6).
//
// A validation case binds to acceptance criteria of a stakeholder
// story. It exercises stakeholder intent rather than system
// internals. Answers are typically obtained by demonstration,
// walkthrough, or operational test rather than automated unit-level
// check.
//
// Identifier convention: VAL_<n>_<ShortName>.

package {{PROJECT_NAME}}_ValidationCases {

    private import {{PROJECT_NAME}}_Context::*;
    private import {{PROJECT_NAME}}_StakeholderStories::*;

    verification def VAL_001_Example {
        subject sys : {{PROJECT_NAME}}_System;

        objective {
            verify US_001_Example::acceptance;
        }

        action collectData { /* observed user task on representative hardware */ }
        action evaluate    { /* pass criterion in stakeholder vocabulary */ }
    }
}
