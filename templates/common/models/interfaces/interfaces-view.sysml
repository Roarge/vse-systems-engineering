// {{PROJECT_NAME}} — Interfaces Package View
//
// Interconnection View exposing logical interface definitions and
// data schema bindings.
//
// Authoring help: @sysml2-views

package {{PROJECT_SHORT_CODE}}_InterfacesView {
    private import {{PROJECT_SHORT_CODE}}_Interfaces::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_Interfaces.
           Renders logical interface definitions with data items,
           directions, and port bindings.
         */

    viewpoint def 'Interfaces Overview' {
        frame concern 'What are the logical interfaces and what data
                       flows across them?';
    }

    view def InterfacesPackageView :> InterconnectionView {
        satisfy viewpoint 'Interfaces Overview';
    }

    view interfacesDiagram : InterfacesPackageView {
        expose {{PROJECT_SHORT_CODE}}_Interfaces::**;
    }
}
