// VSE Systems Engineering Library
//
// Reusable definitions for VSE projects using the AMBSE hybrid lifecycle
// with optional VAMOS variant modelling. This library is the single
// definition site for metadata, enumerations, and variant-aware tagging.
// User projects import from it rather than redeclaring definitions.
//
// Copied into user projects by @project-setup (Minimal and Canonical
// tiers). Lives at models/library/vse-library.sysml in greenfield
// projects and engineering/models/library/vse-library.sysml in
// brownfield projects.
//
// This file has no project-specific placeholders. It is
// project-independent by design.
//
// Sources:
//   Risk metadata: ISO/IEC TR 29110-5-6-2:2014 PM.O5, PM.1.11, PM.2.3.
//   CM metadata: ISO/IEC TR 29110-5-6-2:2014 PM.1.13, PM.2.5, SR.O6.
//   Variant-aware metadata: Weilkiens 2016 VAMOS Ch 3 (organisation),
//     SysML v2 Book Ch 35 (syntax), SysML v2 Book Ch 38 (metadata).
// Authoring help: @sysml2-metadata, @sysml2-model-structure,
//   @sysml2-variants

package VSE_Library {
    private import ScalarValues::*;

    // =================================================================
    // Enumerations
    // =================================================================

    enum def Severity {
        doc /* Five-level risk severity scale. Used by RiskInfo. */
        Low;
        Moderate;
        High;
        VeryHigh;
        Critical;
    }

    enum def Likelihood {
        doc /* Five-level risk likelihood scale. Used by RiskInfo. */
        Low;
        Moderate;
        High;
        VeryHigh;
        Critical;
    }

    enum def RiskStatus {
        doc /* Risk lifecycle states. Used by RiskInfo. */
        Open;
        Mitigating;
        Mitigated;
        Accepted;
        Closed;
    }

    enum def CIState {
        doc /* Configuration item lifecycle states. Used by ConfigItem. */
        Draft;
        Baselined;
        UnderChange;
        Superseded;
        Retired;
    }

    // =================================================================
    // Risk metadata (ISO 29110 PM.O5, PM.1.11, PM.2.3, PM.3.1)
    // =================================================================

    metadata def RiskInfo {
        doc /* Tags any model element with risk information.
               Apply with @RiskInfo on a requirement, architecture
               element, or standalone risk item def inside the
               project Risks package.
               See @sysml2-metadata for worked examples and the
               Automator query recipe.
             */
        attribute severity : Severity;
        attribute likelihood : Likelihood;
        attribute status : RiskStatus;
        attribute owner : String;
        attribute mitigatedBy : Anything[0..*];
    }

    // =================================================================
    // Configuration management metadata (ISO 29110 PM.1.13, PM.2.5)
    // =================================================================

    metadata def ConfigItem {
        doc /* Tags a model element as a configuration item under
               baseline control. The baselineId is a string reference
               to a Baseline item def declared in the project CM
               package.
               See @sysml2-metadata for worked examples and the
               Automator CI-by-baseline query recipe.
             */
        attribute ciId : String;
        attribute baselineId : String;
        attribute state : CIState;
        attribute owner : String;
    }

    metadata def Baseline {
        doc /* Applied to a Baseline item def inside the project CM
               package. Carries the scope (which CIs are frozen) and
               the supersession chain. A release tag on main names a
               baseline declared here.
             */
        attribute baselineId : String;
        attribute date : String;
        attribute scope : Anything[0..*];
        attribute supersedes : Anything[0..1];
    }

    // =================================================================
    // Variant-aware metadata (VAMOS organisation, SysML v2 Ch 35)
    // =================================================================

    metadata def VariantScope {
        doc /* Tags any element with the configuration(s) it applies to.
               Use on risks, requirements, or other elements that are
               specific to one or more variant configurations. Omit
               when the element applies to all configurations (shared).

               The configurations attribute holds configuration names
               as strings, matching the part def names in the project
               Configurations package.

               Example:
                   @VariantScope { configurations = ("HighCapacity", "Standard"); }
             */
        attribute configurations : String[1..*];
    }

    metadata def VerificationScope {
        doc /* Tags a verification case with the configuration(s) it
               targets. Omit when the verification case applies to all
               configurations.

               Used by traceability-guard Rule 6 (advisory: every
               configuration should have at least one verification case
               with a VerificationScope referencing it) and by SR.6
               per-configuration report export.

               Example:
                   @VerificationScope { configurations = ("HighCapacity",); }
             */
        attribute configurations : String[1..*];
    }
}
