// {{PROJECT_NAME}} — Requirements Package View
//
// Grid View exposing system requirements with their satisfy traces
// back to stakeholder needs.
// Addresses ISO 29110 SR.2 traceability obligation.
//
// Authoring help: @sysml2-views

package {{PROJECT_SHORT_CODE}}_RequirementsView {
    private import {{PROJECT_SHORT_CODE}}_Requirements::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_Requirements.
           Renders a tabular listing of system requirements with
           their satisfy links and verification methods.
         */

    viewpoint def 'Requirements Overview' {
        frame concern 'What are the system requirements and how do
                       they trace to stakeholder needs?';
    }

    view def RequirementsPackageView :> GridView {
        satisfy viewpoint 'Requirements Overview';
    }

    view requirementsTable : RequirementsPackageView {
        expose {{PROJECT_SHORT_CODE}}_Requirements::**;
    }
}
