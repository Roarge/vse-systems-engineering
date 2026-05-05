// Smart Sensor interface types (§7.3, §3.3.3).
//
// Per methodology §7.3, interface types are reusable definitions
// that the System Context binds at the system boundary and that
// internal subsystems redefine for component-to-component
// connections. Per §3.3.3, an interface type names the item types
// that cross the interface.
//
// In this demo the System Context (§3) declares the abstract
// interface defs (`OperatorUIInterface`, `CloudInterface`). This
// package adds the item-bearing specialisations that name the
// payloads. Concrete `flow` declarations live at the connection
// site inside `architecture-context.sysml`, where the actual port
// endpoints exist.

package SmartSensor_InterfaceTypes {

    private import SmartSensor_Domain::*;
    private import SmartSensor_Context::*;

    // Operator-facing interface delivering live readings to the
    // dashboard and accepting acknowledgements back.
    interface def OperatorDashboardInterface :> OperatorUIInterface {
        doc /* Items crossing the interface:
                 - Reading              system -> dashboard
                 - Alert                system -> dashboard
                 - AcknowledgementCommand dashboard -> system
             */
    }

    // Cloud ingest interface from the device into the cloud broker.
    interface def DeviceToCloudInterface :> CloudInterface {
        doc /* Items crossing the interface:
                 - Reading  device -> cloud broker
                 - Alert    device -> cloud broker
             */
    }
}
