// Resolved architecture (§6.3.6).
//
// The selected architecture is a specialisation of the configurable
// system part def that redefines every variation to its chosen
// variant. Multiple resolutions may coexist for product families.
// Each resolution shall be fully resolved, with no unresolved
// variations.

package {{PROJECT_NAME}}_Resolved {

    private import {{PROJECT_NAME}}_Context::*;
    private import {{PROJECT_NAME}}_CandidateVariants::*;

    // Example: the resolution for v1.0 of the project.
    part def {{PROJECT_NAME}}_System_v1 :> {{PROJECT_NAME}}_System {
        // Redefine each variation point to a chosen variant.
        // part :>> alarmStorage = AlarmStorageStrategy::embeddedSQLite;
        // part :>> commsFabric  = CommunicationFabric::modbusTCP;
    }
}
