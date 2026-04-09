// {{PROJECT_NAME}} — Verification
//
// Verification cases with verify links back to system requirements.
// Every system requirement must have at least one verification case
// here. @traceability-guard enforces this at iteration-boundary
// closure.
//
// Source: plugin traceability chain, Douglass 2016 Agile Systems
// Engineering Ch 8.3 handoff. ISO/IEC 29110 SR.5 IVV activity.
// Authoring help: @verification-validation, @sysml2-cases

package {{PROJECT_SHORT_CODE}}_Verification {
    private import {{PROJECT_SHORT_CODE}}_Requirements::SR_ExampleRequirement;

    doc /* Verification cases for {{PROJECT_NAME}}.
           Each case carries:
             - a unique id
             - the verification method (Test, Analysis, Inspection,
               Demonstration)
             - at least one verify link to a system requirement
             - a pass/fail criterion and a reference to any test data
         */

    verification def VC_ExampleVerification {
        doc /* Example verification case.
               Method: Test.
               Criterion: (fill in the measurable criterion).
               Replace with a real verification case.
             */
        attribute id : String = "VC-0001";
        attribute method : String = "Test";

        objective {
            verify requirement SR_ExampleRequirement;
        }
    }
}
