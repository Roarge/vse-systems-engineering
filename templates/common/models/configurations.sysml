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
           Each configuration is a specialised part def that redefines
           every variation declared in SystemOfInterest by binding it
           to a specific variant. See @sysml2-variants Section 6 for
           the pattern.
         */

    // Placeholder configuration. Replace with real configurations once
    // variations exist in {{PROJECT_SHORT_CODE}}_ArchDesign.
    //
    // part def DefaultConfiguration :> SystemOfInterest {
    //     // part :>> battery = battery::standardBattery;
    //     // part :>> engines = engines::fourEngines;
    // }
}
