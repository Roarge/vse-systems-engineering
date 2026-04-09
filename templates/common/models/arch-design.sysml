// {{PROJECT_NAME}} — Architectural Design
//
// The selected architecture. Holds the system of interest as a
// specialised part def, the system context wrapper, and one nested
// sub-package per subsystem. Imports logical interfaces from
// {{PROJECT_SHORT_CODE}}_Interfaces.
//
// When base-architecture reuse is activated, uncomment the
// BaseArchitecture import and the :> specialisation clause to inherit
// from {{PROJECT_SHORT_CODE}}_BaseArchitecture.
//
// Source: Douglass 2016 Agile Systems Engineering, Fig 3.13
// ArchDesignPkg; Douglass 2021 Agile MBSE Cookbook, Fig 1.35
// Architectural Design Package. Specialisation syntax from *The SysML
// v2 Book* Ch 14 (:> for definitions, :>> for usages).
// Authoring help: @architecture-design, @sysml2-allocations,
// @sysml2-model-structure

package {{PROJECT_SHORT_CODE}}_ArchDesign {
    // Uncomment and add one named import per interface that a part def
    // in this package actually uses:
    // private import {{PROJECT_SHORT_CODE}}_Interfaces::ExampleInterface;
    // Uncomment when base architecture is activated:
    // private import {{PROJECT_SHORT_CODE}}_BaseArchitecture::BaseSystem;

    doc /* Selected architecture for {{PROJECT_NAME}}.
           Convention: one nested sub-package per subsystem. The system
           of interest is a specialised part def at the top level of
           this package. The system context is a methodological wrapper
           around the system of interest; it lives here, not in a
           separate top-level package.
         */

    // Greenfield variant:
    part def SystemOfInterest {
        doc /* System of interest for {{PROJECT_NAME}}.
               When base architecture is activated, change this line to:
                   part def SystemOfInterest :> BaseSystem { ... }
               See @sysml2-model-structure Section 3 for the reuse
               pattern.
             */
    }

    // Add one nested sub-package per subsystem:
    // package Subsystem01 { ... }
}
