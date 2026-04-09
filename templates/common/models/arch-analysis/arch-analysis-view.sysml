// {{PROJECT_NAME}} — Architectural Analysis Package View
//
// Grid View exposing trade study comparisons: candidates, weighted
// criteria, and scoring.
//
// Authoring help: @sysml2-views

package {{PROJECT_SHORT_CODE}}_ArchAnalysisView {
    private import {{PROJECT_SHORT_CODE}}_ArchAnalysis::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_ArchAnalysis.
           Renders trade study matrices: candidates scored against
           weighted assessment criteria.
         */

    viewpoint def 'Trade Studies Overview' {
        frame concern 'What architectural trade studies have been
                       conducted and what were the outcomes?';
    }

    view def ArchAnalysisPackageView :> GridView {
        satisfy 'Trade Studies Overview';
    }

    view tradeStudyMatrix : ArchAnalysisPackageView {
        expose {{PROJECT_SHORT_CODE}}_ArchAnalysis::**;
    }
}
