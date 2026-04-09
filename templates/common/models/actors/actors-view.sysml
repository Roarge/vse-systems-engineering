// {{PROJECT_NAME}} — Actors Package View
//
// General View exposing actor definitions and their relationships.
// Co-located with the actors package for discoverability.
//
// Authoring help: @sysml2-views

package {{PROJECT_SHORT_CODE}}_ActorsView {
    private import {{PROJECT_SHORT_CODE}}_Actors::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_Actors.
           Renders actor part definitions and their relationships
           to the system of interest.
         */

    viewpoint def 'Actors Overview' {
        frame concern 'Who are the external actors and systems that
                       interact with {{PROJECT_NAME}}?';
    }

    view def ActorsPackageView :> GeneralView {
        satisfy viewpoint 'Actors Overview';
    }

    view actorsDiagram : ActorsPackageView {
        expose {{PROJECT_SHORT_CODE}}_Actors::**;
    }
}
