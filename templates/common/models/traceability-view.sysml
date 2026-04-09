// {{PROJECT_NAME}} — Traceability View (Cross-Cutting)
//
// Grid View spanning requirements and verification packages to
// surface the requirement-to-verification trace chain.
// Addresses ISO 29110 SR.5 verification planning.
//
// This view lives at the models/ root because it crosses package
// boundaries. Per-package views live inside their package directories.
//
// Authoring help: @sysml2-views

package {{PROJECT_SHORT_CODE}}_TraceabilityView {
    private import {{PROJECT_SHORT_CODE}}_Requirements::*;
    private import {{PROJECT_SHORT_CODE}}_Verification::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Cross-cutting view: requirement-to-verification trace chain.
           Surfaces gaps in satisfy and verify coverage.
           Every system requirement should have at least one
           verification case; this view makes gaps visible.
         */

    viewpoint def 'Traceability Overview' {
        frame concern 'Does every system requirement have at least one
                       verification case?';
    }

    view def TraceabilityMatrix :> GridView {
        satisfy viewpoint 'Traceability Overview';
    }

    view traceTable : TraceabilityMatrix {
        expose {{PROJECT_SHORT_CODE}}_Requirements::**;
        expose {{PROJECT_SHORT_CODE}}_Verification::**;
    }
}
