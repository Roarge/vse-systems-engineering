// Stakeholder story register (§4).
//
// Per methodology §1.7.1, stories enter the model in minimal form
// (subject, role, capability, benefit, at least one acceptance,
// optional frame concern). Add typed bindings (use case, verification
// case) as the story progresses to elaborated form per §1.7.2.
//
// Behaviour comes first (§11.4). Write the story's feature file from
// _template.feature beside this file, then write the story here with
// one named criterion for each scenario, named after the scenario's
// @AC_ tag (§11.3.1).
//
// Identifier convention: US_<n>_<ShortName> per §1.6.
//
// One story per file. Replace this template with the actual story.

package {{PROJECT_NAME}}_StakeholderStories {

    private import {{PROJECT_NAME}}_Stakeholders::*;
    private import {{PROJECT_NAME}}_Concerns::*;
    private import {{PROJECT_NAME}}_Context::*;
    private import VSE_Library::*;

    requirement US_001_Example : UserStory {
        @StoryMeta { points = 5; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : {{PROJECT_NAME}}_System;
        stakeholder :>> role : Operator;

        attribute :>> capability = "(what the role wants to do)";
        attribute :>> benefit    = "(the value the role gains)";

        frame concern : FastIncidentResponse;

        requirement :>> acceptance {
            requirement exampleCriterion {
                doc /* Given <preconditions>,
                       when <action>,
                       then <expected outcome>. */
            }
        }
    }

    // Add additional stakeholder stories here, one requirement usage
    // per story. Recommended naming: US_<NNN>_<ShortName>.
}
