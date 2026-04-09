// {{PROJECT_NAME}} — Use Cases Package View
//
// General View exposing use case definitions with their actor
// associations and subject bindings.
//
// Authoring help: @sysml2-views

package {{PROJECT_SHORT_CODE}}_UseCasesView {
    private import {{PROJECT_SHORT_CODE}}_UseCases::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_UseCases.
           Renders use case definitions with actor associations
           and system-under-consideration subject bindings.
         */

    viewpoint def 'Use Cases Overview' {
        frame concern 'What are the system use cases and which actors
                       participate in each?';
    }

    view def UseCasesPackageView :> GeneralView {
        satisfy viewpoint 'Use Cases Overview';
    }

    view useCasesDiagram : UseCasesPackageView {
        expose {{PROJECT_SHORT_CODE}}_UseCases::**;
    }
}
