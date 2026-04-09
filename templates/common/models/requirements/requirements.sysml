// {{PROJECT_NAME}} — System Requirements
//
// System requirements with satisfy links back to stakeholder needs.
// Every requirement here must trace upward to at least one need in
// {{PROJECT_SHORT_CODE}}_StakeholderNeeds and downward to at least one
// verification case in {{PROJECT_SHORT_CODE}}_Verification.
//
// Source: Douglass 2016 Agile Systems Engineering, Fig 3.13
// Requirements Package. ISO/IEC 29110 SR.2.4 output. Plugin traceability
// chain is enforced by @traceability-guard.
// Authoring help: @needs-and-requirements, @sysml2-cases

package {{PROJECT_SHORT_CODE}}_Requirements {
    private import {{PROJECT_SHORT_CODE}}_StakeholderNeeds::SN_ExampleNeed;

    doc /* System requirements for {{PROJECT_NAME}}.
           Each requirement carries:
             - a unique id
             - SMART criteria (Specific, Measurable, Achievable,
               Relevant, Time-bound)
             - at least one satisfy link to a stakeholder need
             - a verificationMethod attribute naming Test, Analysis,
               Inspection, or Demonstration
         */

    requirement def SR_ExampleRequirement {
        doc /* Example system requirement.
               SMART check: (fill in).
               Verification method: Test.
               Replace with a real requirement.
             */
        attribute id : String = "SR-0001";
        attribute verificationMethod : String = "Test";

        satisfy requirement SN_ExampleNeed;
    }
}
