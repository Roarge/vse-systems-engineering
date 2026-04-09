// {{PROJECT_NAME}} — Base Architecture (OPTIONAL)
//
// Optional top-level package holding an inherited base architecture.
// Scaffolded only when project-setup is run with the base-architecture
// opt-in, or in brownfield mode against an existing SysML tree.
//
// The base architecture is the VAMOS "core model": it carries all
// structure, connections, and constraints that are INVARIANT across
// every configuration. It is not a catalogue of empty definitions.
// Every part usage, connection, and constraint declared here is
// inherited by {{PROJECT_SHORT_CODE}}_ArchDesign::SystemOfInterest
// when it specialises BaseSystem via :>.
//
// {{PROJECT_SHORT_CODE}}_ArchDesign imports and specialises the part
// defs declared here via the Ch 14 operators :> (definition
// specialisation) and :>> (usage redefinition).
//
// Source: *The SysML v2 Book* Ch 14.1-14.2 specialisation syntax;
// Douglass 2016 Agile Systems Engineering Ch 8 shared-repository
// pattern; Weilkiens 2016 VAMOS Chs 2-3 core model concept.
// Authoring help: @sysml2-model-structure Section 3

package {{PROJECT_SHORT_CODE}}_BaseArchitecture {
    private import {{PROJECT_SHORT_CODE}}_Interfaces::ExampleInterface;

    doc /* Inherited base architecture for {{PROJECT_NAME}}.
           This package holds the INVARIANT structure shared by every
           configuration: part usages, connections, ports, and
           constraints that apply regardless of variant selection.

           Volatile or configuration-specific content stays in
           {{PROJECT_SHORT_CODE}}_ArchDesign. When the base matures
           and is shared across programmes, migrate it into a peer
           shared model.
         */

    // ─── Base Subsystem Definitions ──────────────────────────────
    //
    // Define each base subsystem as a part def with ports. These
    // are the shared building blocks that all configurations
    // inherit. Projects specialise them in ArchDesign via :>.

    part def BaseSubsystemA {
        doc /* Base subsystem shared across all configurations.
               Declare ports for every interface this subsystem
               participates in. Projects specialise via :>.
             */
        port dataOut : ExampleInterface;
    }

    part def BaseSubsystemB {
        doc /* Base downstream subsystem. Replace with a real
               subsystem name and description.
             */
        port dataIn : ExampleInterface;
    }

    part def BaseOperator {
        doc /* Base operator role. Projects add operator-specific
               ports and attributes via :>.
             */
    }

    part def BaseEnvironment {
        doc /* Base environment definition. Redefine environmental
               parameters in ArchDesign via :>>.
             */
        attribute maxAmbientTemp : Real;
    }

    // ─── Base System ──────────────────────────────────────────────
    //
    // The base system composes subsystems as part usages, wires
    // them together, and declares constraints that every
    // configuration must satisfy. This is the VAMOS core model:
    // structure and rules that are invariant across all products.

    part def BaseSystem {
        doc /* Base system definition from the prior programme.
               {{PROJECT_SHORT_CODE}}_ArchDesign::SystemOfInterest
               specialises this via:
                   part def SystemOfInterest :> BaseSystem { ... }
               and redefines usages with :>> to add configuration-
               specific content.
             */

        // Part usages: compose base subsystems.
        part subsystemA : BaseSubsystemA;
        part subsystemB : BaseSubsystemB;

        // Connections: wiring shared by all configurations.
        connect subsystemA.dataOut to subsystemB.dataIn;

        // Constraints: invariants that every configuration must
        // satisfy. Projects inherit these and cannot weaken them
        // without an explicit redefinition.
        attribute totalMass : Real;
        assert constraint massLimit {
            doc /* Example: total mass must not exceed budget. */
            totalMass <= 50.0
        }
    }
}
