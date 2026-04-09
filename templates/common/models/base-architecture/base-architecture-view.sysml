// {{PROJECT_NAME}} — Base Architecture Package View
//
// Interconnection View exposing the inherited base architecture
// from a prior programme.
//
// Authoring help: @sysml2-views, @sysml2-model-structure

package {{PROJECT_SHORT_CODE}}_BaseArchitectureView {
    private import {{PROJECT_SHORT_CODE}}_BaseArchitecture::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_BaseArchitecture.
           Renders the inherited base system decomposition that
           {{PROJECT_SHORT_CODE}}_ArchDesign specialises via :>.
         */

    viewpoint def 'Base Architecture Overview' {
        frame concern 'What does the inherited base architecture
                       provide and what must be specialised?';
    }

    view def BaseArchitecturePackageView :> InterconnectionView {
        satisfy 'Base Architecture Overview';
    }

    view baseArchDiagram : BaseArchitecturePackageView {
        expose {{PROJECT_SHORT_CODE}}_BaseArchitecture::**;
    }
}
