// {{PROJECT_NAME}} — Stakeholder Needs
//
// Stakeholder needs with subject pointing at the system of interest.
// Each need carries a unique id and a doc comment linking to its
// stakeholder source.
//
// Source: Douglass 2016 Agile Systems Engineering, Ch 3 Fig 3.13
// Requirements Package stakeholder half. ISO/IEC 29110 SR.2.1 output.
// Authoring help: @needs-and-requirements

package {{PROJECT_SHORT_CODE}}_StakeholderNeeds {
    doc /* Stakeholder needs for {{PROJECT_NAME}}.
           Each need is a SysML v2 requirement def with:
             - a unique id attribute
             - a stakeholder source (in doc)
             - a subject pointing at the system of interest
           The plugin traces every system requirement in
           {{PROJECT_SHORT_CODE}}_Requirements back to at least one need
           here via a satisfy link.
         */

    requirement def SN_ExampleNeed {
        doc /* Example stakeholder need.
               Stakeholder: (role).
               Source: (interview, workshop, document reference).
               Replace with a real need and update the id.
             */
        attribute id : String = "SN-0001";
    }
}
