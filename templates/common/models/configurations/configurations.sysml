// {{PROJECT_NAME}} — Variant Configurations (OPTIONAL)
//
// Optional top-level package holding concrete variant configurations.
// Scaffolded only when project-setup is run with the variants opt-in.
//
// Variation *definitions* stay inline inside the owning part def in
// {{PROJECT_SHORT_CODE}}_ArchDesign (and occasionally elsewhere) per
// *The SysML v2 Book* Ch 35. This package holds only the *concrete
// configurations* that specialise the owning part def and bind each
// variation to a specific variant with the :>> = name::variant syntax.
//
// Source: Weilkiens T (2016) *Variant Modeling with SysML* Ch 3.7
// (organisation only; v1 stereotype syntax is not reproduced) adapted
// to SysML 2.0. Chapter 35 of *The SysML v2 Book* is the syntax
// authority; see @sysml2-variants.
// Authoring help: @sysml2-variants for syntax, @sysml2-model-structure
// Section 6 for organisation.

package {{PROJECT_SHORT_CODE}}_Configurations {
    private import {{PROJECT_SHORT_CODE}}_ArchDesign::SystemOfInterest;

    doc /* Concrete variant configurations for {{PROJECT_NAME}}.

           VAMOS two-step pattern (SysML 2.0 Ch 35):

           Step 1 (in {{PROJECT_SHORT_CODE}}_ArchDesign). Declare
           variation points INLINE inside the owning part def using
           the `variation part` keyword. Each variation owns two or
           more `variant part` members:

               part def SystemOfInterest {
                   variation part commLink : CommOption {
                       variant part wiredComm { ... }
                       variant part wirelessComm { ... }
                   }
               }

           Step 2 (HERE). Specialise the owning part def and bind
           each variation to a specific variant using `:>>`:

               part def WiredConfig :> SystemOfInterest {
                   part :>> commLink = commLink::wiredComm;
               }

           IMPORTANT: the `:>>` target MUST be a part declared as
           `variation part` in the owning definition. If the target
           is a regular part, the redefinition compiles but loses
           variant semantics. See @sysml2-variants for the full
           pattern and validation checklist.
         */

    // Placeholder configuration. Replace with real configurations
    // once variation points exist in
    // {{PROJECT_SHORT_CODE}}_ArchDesign::SystemOfInterest.
    //
    // part def DefaultConfiguration :> SystemOfInterest {
    //     // Bind every variation declared in SystemOfInterest:
    //     // part :>> commLink = commLink::wiredComm;
    // }
}
