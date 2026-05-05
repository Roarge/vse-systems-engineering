// System story register (§5).
//
// Per methodology §5.4.1, system stories derive from stakeholder
// stories. Same role, restated capability in system-internal
// vocabulary, sharpened benefit (formalised as `require constraint`
// per §5.4.2 to feed §6 trade studies — the §0.3 connective
// mechanism).
//
// Identifier convention: SYS_<n>_<ShortName>.

package {{PROJECT_NAME}}_SystemStories {

    private import {{PROJECT_NAME}}_Stakeholders::*;
    private import {{PROJECT_NAME}}_Concerns::*;
    private import {{PROJECT_NAME}}_Context::*;
    private import {{PROJECT_NAME}}_StakeholderStories::*;
    private import VSE_Library::*;

    requirement def SYS_001_Example :> UserStory {
        @StoryMeta { points = 3; priority = high; status = backlog; }

        subject system : {{PROJECT_NAME}}_System;
        stakeholder :>> role : Operator;

        capability = "(system-internal restatement of US_<NNN> capability)";
        benefit    = "(value the role gains, sharpened toward measurable form)";

        // Inherits framed concerns from upstream stakeholder story.
        frame concern : OpsConcerns::FastIncidentResponse;

        // Derive link to upstream stakeholder story per §5.4.1.
        // Use the SysML 2.0 Derivation pattern from spec §9.6.
        // #derive
        // doc /* Derives from US_001_Example */

        // Formalised benefit constraint (§5.4.2). The connective
        // mechanism: this constraint is the trade-study criterion
        // when the architecture decision affects this story (§6.3.4).
        require constraint sla {
            doc /* The system shall <measurable predicate>. */
        }

        requirement acceptance[1] {
            doc /* Given <preconditions>,
                   when <action>,
                   then <observable outcome with measurable threshold>. */
        }
    }
}
