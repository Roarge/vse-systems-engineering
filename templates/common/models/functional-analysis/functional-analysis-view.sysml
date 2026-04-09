// {{PROJECT_NAME}} — Functional Analysis Package View
//
// Action Flow View exposing functional decomposition: actions, flows,
// and state bodies that realise each use case.
//
// Authoring help: @sysml2-views

package {{PROJECT_SHORT_CODE}}_FunctionalAnalysisView {
    private import {{PROJECT_SHORT_CODE}}_FunctionalAnalysis::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_FunctionalAnalysis.
           Renders the functional decomposition as action flows,
           one sub-package per analysed use case.
         */

    viewpoint def 'Functional Analysis Overview' {
        frame concern 'How is the system behaviour decomposed into
                       functions for each use case?';
    }

    view def FunctionalAnalysisPackageView :> ActionFlowView {
        satisfy 'Functional Analysis Overview';
    }

    view functionalFlows : FunctionalAnalysisPackageView {
        expose {{PROJECT_SHORT_CODE}}_FunctionalAnalysis::**;
    }
}
