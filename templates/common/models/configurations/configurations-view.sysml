// {{PROJECT_NAME}} — Variant Configurations Package View
//
// Grid View exposing concrete variant configurations and their
// variation bindings.
//
// Authoring help: @sysml2-views, @sysml2-variants

package {{PROJECT_SHORT_CODE}}_ConfigurationsView {
    private import {{PROJECT_SHORT_CODE}}_Configurations::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_Configurations.
           Renders a tabular listing of concrete variant configurations
           with their variation-to-variant bindings.
         */

    viewpoint def 'Variant Configurations Overview' {
        frame concern 'What concrete product configurations exist and
                       how are variation points bound?';
    }

    view def ConfigurationsPackageView :> GridView {
        satisfy 'Variant Configurations Overview';
    }

    view configurationsTable : ConfigurationsPackageView {
        expose {{PROJECT_SHORT_CODE}}_Configurations::**;
    }
}
