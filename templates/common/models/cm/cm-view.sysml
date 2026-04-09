// {{PROJECT_NAME}} — Configuration Management Package View
//
// Grid View exposing model-level configuration items, baselines,
// and their lifecycle states.
//
// Authoring help: @sysml2-views, @sysml2-metadata

package {{PROJECT_SHORT_CODE}}_CMView {
    private import {{PROJECT_SHORT_CODE}}_CM::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_CM.
           Renders a tabular listing of baselines and configuration
           items with their lifecycle states and scope.
         */

    viewpoint def 'Configuration Management Overview' {
        frame concern 'What baselines exist and which configuration
                       items are frozen in each?';
    }

    view def CMPackageView :> GridView {
        satisfy 'Configuration Management Overview';
    }

    view cmTable : CMPackageView {
        expose {{PROJECT_SHORT_CODE}}_CM::**;
    }
}
