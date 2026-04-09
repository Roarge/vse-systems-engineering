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
    // Add one named import per interface that a part def in this
    // package actually uses. The example interface is imported here
    // because SubsystemA and SubsystemB reference it on their ports.
    // Replace with real interface names as they are identified.
    private import {{PROJECT_SHORT_CODE}}_Interfaces::ExampleInterface;
    // Uncomment when base architecture is activated:
    // private import {{PROJECT_SHORT_CODE}}_BaseArchitecture::BaseSystem;

    doc /* Selected architecture for {{PROJECT_NAME}}.
           Convention: one nested sub-package per subsystem. The system
           of interest is a specialised part def at the top level of
           this package. The system context is a methodological wrapper
           around the system of interest; it lives here, not in a
           separate top-level package.
         */

    // ─── Subsystem Part Definitions ──────────────────────────────
    //
    // Define each subsystem as a part def with ports that declare
    // its communication points. Replace these examples with real
    // subsystems as they are identified during SR.3.

    part def SubsystemA {
        doc /* Example subsystem. Replace with a real subsystem name
               and description. Each subsystem part def should declare
               the ports through which it communicates.
             */
        port dataOut : ExampleInterface;
    }

    part def SubsystemB {
        doc /* Example downstream subsystem that receives data from
               SubsystemA. Replace with real content.
             */
        port dataIn : ExampleInterface;
    }

    // ─── System of Interest ───────────────────────────────────────
    //
    // The system of interest composes subsystems as part usages and
    // wires them together with connect statements. This is where the
    // architecture lives: not in the definitions above, but in the
    // composition and connections below.

    // Greenfield variant:
    part def SystemOfInterest {
        doc /* System of interest for {{PROJECT_NAME}}.
               Architecture is expressed as:
                 1. Part usages that instantiate subsystem definitions.
                 2. Connect statements that wire ports together.
                 3. Variation points for product-line alternatives.
               When base architecture is activated, change this line to:
                   part def SystemOfInterest :> BaseSystem { ... }
               See @sysml2-model-structure Section 3 for the reuse
               pattern.
             */

        // Part usages: compose subsystems into the system.
        // Each usage instantiates a subsystem definition above.
        part subsystemA : SubsystemA;
        part subsystemB : SubsystemB;

        // Connections: wire ports between composed parts.
        // Without connections the subsystems are structurally isolated
        // and interface analysis cannot be performed.
        connect subsystemA.dataOut to subsystemB.dataIn;

        // Variation points: declare inline per VAMOS and SysML 2.0
        // Ch 35. Each variation owns two or more variant members.
        // Concrete configurations that bind these live in
        // {{PROJECT_SHORT_CODE}}_Configurations.
        //
        // Uncomment and adapt when the project has product-line
        // alternatives:
        //
        // variation part commLink : CommOption {
        //     variant part wiredComm {
        //         doc /* Wired communication option. */
        //     }
        //     variant part wirelessComm {
        //         doc /* Wireless communication option. */
        //     }
        // }
    }

    // ─── System Context ───────────────────────────────────────────

    part def SystemContext {
        doc /* Methodological wrapper. Places the system of interest
               alongside its external actors in a single composition.
               See @sysml2-model-structure for the context convention.
             */
        part system : SystemOfInterest;
        // part operator : {{PROJECT_SHORT_CODE}}_Actors::Operator;
    }
}
