// As-Is current state (contingent subset).
//
// This package holds elements the brownfield as-is survey classified
// as CONTINGENT, meaning the project currently uses them but owns the
// choice and may revisit it. Contingent elements are NOT Base
// Architecture and shall not live in a `library package` (methodology
// §2.6 rule 1).
//
// Each part def below carries:
//
//     @ConfigItem {
//         :>> ciState = CIState::Proposed;
//         :>> baselineId = "BL-AS-IS-CURRENT-0.1";
//     }
//
// See as-is-current.sysml.tmpl in this directory for the
// survey-populated form, including the canonical part-def shape and
// the @ConfigItem application body. The bare package below is what
// /vse-setup writes when the survey is skipped or when the survey
// produced no contingent elements.
//
// Promotion of a contingent element to Base Architecture (the user
// learns the element is in fact externally constrained) is a change
// to a baselined artefact. It requires a Change Request per the
// project's .iso-config.yaml. The promotion path is:
//
//   1. Open a Change Request via /vse-cr.
//   2. Move the part def into {{PROJECT_NAME}}_BaseArchitecture.
//   3. Update the @ConfigItem application to ciState = Baselined and
//      to a new BL-BA-AS-IS-x.y baseline that supersedes the previous.
//   4. Update docs/as-is-classification.md to reflect the move.
//   5. Ship under elevated final-review criteria per §8.6.3.
//
// Stories are forward-going and are authored against {{PROJECT_NAME}}
// system part defs, not against contingent or mandated as-is
// elements (§2.6 rule 7).

package <{{PROJECT_SHORT_CODE}}_AsIs> {{PROJECT_NAME}}_AsIs {

    private import VSE_Library::ConfigItem;
    private import VSE_Library::CIState;
    private import {{PROJECT_NAME}}_BaseArchitecture::*;

    // The package is empty by default. /vse-setup populates it from
    // the as-is survey when the user accepts. See
    // as-is-current.sysml.tmpl for the part-def shape that the skill
    // emits per contingent row.
}
