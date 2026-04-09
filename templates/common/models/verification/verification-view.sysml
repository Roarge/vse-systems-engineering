// {{PROJECT_NAME}} — Verification Package View
//
// Grid View exposing verification cases with their verify links
// back to system requirements.
// Addresses ISO 29110 SR.5 verification planning.
//
// Authoring help: @sysml2-views

package {{PROJECT_SHORT_CODE}}_VerificationView {
    private import {{PROJECT_SHORT_CODE}}_Verification::*;
    private import Views::*;
    private import StandardViewDefinitions::*;

    doc /* Package view for {{PROJECT_SHORT_CODE}}_Verification.
           Renders a tabular listing of verification cases with
           their verify links, methods, and pass/fail criteria.
         */

    viewpoint def 'Verification Overview' {
        frame concern 'What verification cases exist and which
                       requirements do they cover?';
    }

    view def VerificationPackageView :> GridView {
        satisfy 'Verification Overview';
    }

    view verificationTable : VerificationPackageView {
        expose {{PROJECT_SHORT_CODE}}_Verification::**;
    }
}
