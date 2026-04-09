// {{PROJECT_NAME}} — Risk Register Package View
//
// Grid View exposing the risk register with severity, likelihood,
// and mitigation status.
// Addresses ISO 29110 PM.O5 risk management obligation.
//
// Authoring help: @sysml2-views

package {{PROJECT_SHORT_CODE}}_RisksView {
    private import {{PROJECT_SHORT_CODE}}_Risks::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_Risks.
           Renders a tabular listing of risk items with severity,
           likelihood, status, and mitigation references.
         */

    viewpoint def 'Risk Register Overview' {
        frame concern 'What are the project risks and what is their
                       current mitigation status?';
    }

    view def RisksPackageView :> GridView {
        satisfy viewpoint 'Risk Register Overview';
    }

    view riskTable : RisksPackageView {
        expose {{PROJECT_SHORT_CODE}}_Risks::**;
    }
}
