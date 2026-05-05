// Logical Architecture context view (§8.3.1).
//
// Per methodology §8.3.1, the logical architecture has its own
// context view distinct from the system-level System Context that
// lives at `core/context/architecture-context.sysml` (§3).
//
// This file is the place to declare:
//   - the system part def as it appears at the LA scope, with its
//     subsystem-facing ports;
//   - inter-subsystem actors that appear at this scope but were not
//     externalised at §3 (for example, infrastructure subsystems
//     internal to the project but external to a particular
//     subsystem);
//   - the LA-scope composite that owns subsystems and their
//     inter-subsystem connections.
//
// This is a stub. Populate it during §7 architectural design.

package {{PROJECT_NAME}}_LA_Context {

    private import {{PROJECT_NAME}}_Context::*;
    // private import {{PROJECT_NAME}}_LogicalArchitecture::*;

    // The LA-scope composite goes here. Example shape:
    //
    // part def {{PROJECT_NAME}}_LogicalSystem :> {{PROJECT_NAME}}_System {
    //     part subsystemA : SubsystemA;
    //     part subsystemB : SubsystemB;
    //
    //     interface internalLink : InternalInterface
    //         connect subsystemA.outPort to subsystemB.inPort;
    // }
}
