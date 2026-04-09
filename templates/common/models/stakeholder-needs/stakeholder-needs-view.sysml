// {{PROJECT_NAME}} — Stakeholder Needs Package View
//
// Grid View exposing stakeholder needs with their identifiers,
// rationale, and stakeholder source.
//
// Authoring help: @sysml2-views

package {{PROJECT_SHORT_CODE}}_StakeholderNeedsView {
    private import {{PROJECT_SHORT_CODE}}_StakeholderNeeds::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_StakeholderNeeds.
           Renders a tabular listing of all stakeholder needs with
           their identifiers and stakeholder sources.
         */

    viewpoint def 'Stakeholder Needs Overview' {
        frame concern 'What are the stakeholder needs and where do
                       they originate?';
    }

    view def StakeholderNeedsPackageView :> GridView {
        satisfy viewpoint 'Stakeholder Needs Overview';
    }

    view needsTable : StakeholderNeedsPackageView {
        expose {{PROJECT_SHORT_CODE}}_StakeholderNeeds::**;
    }
}
