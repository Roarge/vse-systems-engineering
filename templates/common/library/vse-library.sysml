// VSE Systems Engineering Library
//
// Reusable definitions for VSE projects following the story-driven
// AMBSE methodology. This library is the single definition site for
// methodology constructs (UserStory, StoryMeta, StakeholderNeed),
// risk metadata, configuration metadata, and variant-aware tagging.
// User projects import from it rather than redeclaring definitions.
//
// Copied into user projects by @project-setup. Lives at
// model/library/vse-library.sysml.
//
// This file has no project-specific placeholders. It is
// project-independent by design.
//
// Sources:
//   Methodology constructs: vse-systems-engineering plugin,
//     methodology/01-user-stories.md (§1) and §0.8.
//   Risk metadata: ISO/IEC TR 29110-5-6-2:2014 PM.O5, PM.1.11, PM.2.3.
//   CM metadata: ISO/IEC TR 29110-5-6-2:2014 PM.1.13, PM.2.5, SR.O6.
//   Variant-aware metadata: Weilkiens 2016 VAMOS Ch 3 (organisation),
//     SysML v2 Book Ch 35 (syntax), SysML v2 Book Ch 38 (metadata).
// Authoring help: @sysml2-metadata, @sysml2-model-structure,
//   @sysml2-variants, @needs-and-requirements (for the §1 constructs).

package VSE_Library {
    private import ScalarValues::*;

    // =================================================================
    // Methodology constructs (§1 user stories, §0.8 forecast)
    // =================================================================
    //
    // Per methodology §0.8, these constructs will eventually ship as
    // a dedicated `MBSEMethodology` library imported by every project.
    // Until that work lands, projects import them from VSE_Library.

    enum def StoryStatus {
        doc /* The four valid values of StoryMeta.status per §1.5
               and §8.7. CI checks that StoryMeta.status is consistent
               with the branch and pull-request state. */
        backlog;
        ready;
        inProgress;
        done;
    }

    enum def Priority {
        doc /* Story prioritisation enum used in StoryMeta.priority. */
        low;
        medium;
        high;
        critical;
    }

    enum def InvestFlags {
        doc /* INVEST attribute flags (independent, negotiable,
               valuable, estimable, small, testable). Optional. */
        I; N; V; E; S; T;
    }

    abstract requirement def StakeholderNeed {
        doc /* Per §1.3, the abstract base type beneath UserStory.
               Concrete StakeholderNeed specialisations may include
               coarser-grained agile constructs such as Feature or
               Epic, all connecting down to UserStory through
               `derive` relationships. */
    }

    requirement def UserStory :> StakeholderNeed {
        doc /* Per §1.2, the canonical stakeholder-intent artefact.
               A UserStory:
                 - declares a primary stakeholder via `role`,
                 - describes a desired `capability` (narrative string),
                 - articulates a `benefit` (narrative string,
                   optionally formalised as a require constraint per
                   §1.4.3 to feed §6 trade studies, §0.3),
                 - carries one or more `acceptance` subrequirements,
                 - may `frame` one or more `concern def` instances
                   (per §1.4.6).
               §1.9 well-formedness rules apply: typed role, declared
               subject, at least one acceptance before `ready`,
               retained narrative capability and benefit.

               Concrete project stories specialise UserStory and
               redefine the role, subject, capability, benefit, and
               acceptance members. The base type leaves them open so
               specialisations can attach typed bindings. */
    }

    requirement def Feature :> StakeholderNeed {
        doc /* Coarser-grained intent above UserStory. Use `derive`
               to connect a Feature down to the UserStory set that
               realises it. */
    }

    requirement def Epic :> StakeholderNeed {
        doc /* Coarsest intent. Use `derive` down to Features or
               directly to UserStory specialisations. */
    }

    metadata def StoryMeta {
        doc /* Per §1.5, agile lifecycle and planning metadata applied
               to every UserStory via `@StoryMeta { ... }`. `status`
               is mandatory. The other attributes are optional and
               project-determined.

               Example:
                   @StoryMeta { points = 5; priority = high; status = ready; }
             */
        attribute points   : Integer[0..1];
        attribute priority : Priority[0..1];
        attribute status   : StoryStatus;
        attribute invest   : InvestFlags[0..1];
    }

    // =================================================================
    // Enumerations (risk and configuration management)
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

               Used by @traceability-guard Rule 6 (advisory: every
               configuration should have at least one verification case
               with a VerificationScope referencing it) and by SR.6
               per-configuration report export.

               Example:
                   @VerificationScope { configurations = ("HighCapacity",); }
             */
        attribute configurations : String[1..*];
    }
}
