// {{PROJECT_NAME}} — Architectural Design Package View
//
// Interconnection View exposing the physical architecture with parts,
// ports, and connectors.
// Addresses ISO 29110 SR.3 architecture documentation.
//
// Authoring help: @sysml2-views

package {{PROJECT_SHORT_CODE}}_ArchDesignView {
    private import {{PROJECT_SHORT_CODE}}_ArchDesign::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_ArchDesign.
           Renders the system of interest decomposition with
           subsystem parts, ports, and connectors.
         */

    viewpoint def 'Architecture Overview' {
        frame concern 'What is the physical decomposition of the system
                       and how do subsystems connect?';
    }

    view def ArchDesignPackageView :> InterconnectionView {
        satisfy viewpoint 'Architecture Overview';
    }

    view architectureDiagram : ArchDesignPackageView {
        expose {{PROJECT_SHORT_CODE}}_ArchDesign::**;
    }
}
