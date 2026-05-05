// Domain glossary, item defs, and common value types.
//
// Per methodology §8.3.1, this package holds project-wide vocabulary:
// item defs that flow across boundaries, value types attached to
// model attributes, and enumerations. Inherited by every component
// when nesting recursively per §8.3.2.

package {{PROJECT_NAME}}_Domain {

    // Item types that cross the system boundary.
    item def AlarmEvent {
        attribute id : AlarmId;
        attribute severity : Severity;
        attribute timestamp : DateTime;
    }

    item def AcknowledgmentCommand;

    // Value types and enumerations.
    enum def Severity {
        info;
        warning;
        critical;
    }

    attribute def AlarmId :> Natural;
    attribute def DateTime :> ISO::ISO8601String;
    attribute def TemperatureValue :> Real;
    attribute def PrecipitationValue :> Real;
}
