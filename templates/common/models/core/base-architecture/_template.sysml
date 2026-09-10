// Base Architecture (§2).
//
// Per methodology §2.1 and §2.6, the Base Architecture captures the
// architectural and technical decisions that pre-exist the project
// and constrain its work from outside it. It is exogenous reference,
// not project specification.
//
// Key rules:
//   - Lives in a `library package` (§2.6 rule 1).
//   - Project's system specialises (`:>`) or is allocated to a Base
//     Architecture part def (§2.6 rule 3, exactly one relationship).
//   - Constraints are immutable. Every part typed by the platform or
//     by a specialisation of it keeps them satisfied (§2.6 rule 2).
//   - AI agents shall NOT synthesise context stories or
//     reverse-engineer Base Architecture justifications (§2.6 rule 7).

library package <{{PROJECT_SHORT_CODE}}_BA> {{PROJECT_NAME}}_BaseArchitecture {

    private import ScalarValues::*;

    // Example: a hardware platform the project must build on.
    part def AC5000_Platform {
        attribute modelRevision : String;
        attribute firmwareVersion : String;
        attribute maxIOChannels : Natural = 64;

        port modbusTCP : ModbusTCPPort;
        port digitalIO : DigitalIOPort[16];
    }

    // Immutable Base Architecture constraint (§2.6 rule 2), stated as a
    // requirement def whose subject is the platform. A `require constraint`
    // is only legal inside a requirement, concern, viewpoint or objective
    // body, never directly inside a part def.
    requirement def MaxChannelsConstraint {
        subject platform : AC5000_Platform;
        doc /* Configured I/O channel count shall not exceed platform.maxIOChannels. */
    }

    // Example: a communication protocol abstraction with variants.
    abstract part def CommunicationProtocol;
    part def ModbusTCP :> CommunicationProtocol;
    part def OPCUA    :> CommunicationProtocol;

    // Example port type (referenced in port declarations above).
    port def ModbusTCPPort;
    port def DigitalIOPort;
}
