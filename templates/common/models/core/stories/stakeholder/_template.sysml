// Stakeholder story register (§4).
//
// Per methodology §1.7.1, stories enter the model in minimal form
// (subject, role, capability, benefit, at least one acceptance,
// optional frame concern). Add typed bindings (use case, verification
// case) as the story progresses to elaborated form per §1.7.2.
//
// Identifier convention: US_<n>_<ShortName> per §1.6.
//
// One story per file. Replace this template with the actual story.

package {{PROJECT_NAME}}_StakeholderStories {

    private import {{PROJECT_NAME}}_Stakeholders::*;
    private import {{PROJECT_NAME}}_Concerns::*;
    private import {{PROJECT_NAME}}_Context::*;
    private import VSE_Library::*;

    requirement def US_001_Example :> UserStory {
        @StoryMeta { points = 5; priority = high; status = backlog; }

        subject system : {{PROJECT_NAME}}_System;
        stakeholder :>> role : Operator;

        capability = "(I want ...)";
        benefit    = "(so that ...)";

        frame concern : OpsConcerns::FastIncidentResponse;

        requirement acceptance[1] {
            doc /* Given <preconditions>,
                   when <action>,
                   then <expected outcome>. */
        }
    }

    // Add additional stakeholder stories here, one requirement def
    // per story. Recommended naming: US_<NNN>_<ShortName>.
}
