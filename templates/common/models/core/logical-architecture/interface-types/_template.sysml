// Inter-subsystem interface types (§3.3.3, §7.3.4).
//
// Each `interface def` declares the ports at its ends and the items
// that flow across. Interface defs in this package are reusable by
// the System Context (§3) and by inter-subsystem connections inside
// the logical architecture (§7).

package {{PROJECT_NAME}}_InterfaceTypes {

    private import {{PROJECT_NAME}}_Domain::*;

    // Reusable interface example. Use in the System Context, in
    // inter-subsystem connect clauses, or wherever the same flow
    // pattern recurs.
    interface def AlarmFlowInterface {
        end producer : AlarmProducerPort;
        end consumer : AlarmConsumerPort;
        item alarms  : AlarmEvent[*];
    }

    port def AlarmProducerPort;
    port def AlarmConsumerPort;
}
