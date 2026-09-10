// System story register (§5).
//
// Per methodology §5.4.1, system stories derive from stakeholder
// stories. Same role, restated capability in system-internal
// vocabulary, sharpened benefit (formalised as a nested requirement
// carrying a `require constraint` per §5.4.2, which feeds the §6
// trade studies as the §0.3 connective mechanism).
//
// Identifier convention: SYS_<n>_<ShortName>.

package {{PROJECT_NAME}}_SystemStories {

    private import {{PROJECT_NAME}}_Stakeholders::*;
    private import {{PROJECT_NAME}}_Concerns::*;
    private import {{PROJECT_NAME}}_Context::*;
    private import {{PROJECT_NAME}}_StakeholderStories::*;
    private import VSE_Library::*;
    private import ScalarValues::*;
    private import RequirementDerivation::*;

    #derive
    requirement SYS_001_Example : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : {{PROJECT_NAME}}_System;
        stakeholder :>> role : Operator;

        attribute :>> capability = "(system-internal restatement of US_<NNN> capability)";
        attribute :>> benefit    = "(value the role gains, sharpened toward measurable form)";

        // Inherits framed concerns from upstream stakeholder story.
        frame concern : FastIncidentResponse;

        attribute maxLatency : Rational = 1.0;

        // Formalised benefit constraint (§5.4.2). The connective
        // mechanism: this requirement is the trade-study criterion
        // when the architecture decision affects this story (§6.3.4).
        // A `require constraint` is legal here because the enclosing
        // element is a requirement usage.
        requirement sla {
            doc /* The system shall <measurable predicate>. */
            require constraint { maxLatency <= 1.0 }
        }

        requirement :>> acceptance {
            doc /* Given <preconditions>,
                   when <action>,
                   then <observable outcome with measurable threshold>. */
        }
    }

    // Derive link to the upstream stakeholder story per §5.4.1. The
    // `#derive` prefix marks the derived story and the connection
    // names the original and the derived end.
    #derivation connection sys001Derives {
        end #original ::> US_001_Example;
        end #derive   ::> SYS_001_Example;
    }
}
