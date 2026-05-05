// Smart Sensor domain glossary.
//
// Per methodology §8.3.1, the domain package holds project-wide
// vocabulary: item defs that flow across boundaries, value types,
// and enumerations.

package SmartSensor_Domain {

    private import ScalarValues::*;

    // Sensor reading reported from the device to the cloud.
    item def Reading {
        attribute timestamp : DateTime;
        attribute temperature : TemperatureCelsius;
        attribute humidity : RelativeHumidity;
    }

    // Alert raised when a reading crosses a configured threshold.
    item def Alert {
        attribute id : AlertId;
        attribute severity : AlertSeverity;
        attribute readingRef : Reading;
        attribute raised : DateTime;
    }

    // Acknowledgement command from operator back to the device or
    // dashboard, clearing an alert from the queue.
    item def AcknowledgementCommand {
        attribute alertId : AlertId;
        attribute operatorId : ScalarValues::String;
        attribute issued : DateTime;
    }

    // Severity of an alert, project-determined three-level scale.
    enum def AlertSeverity {
        info;
        warning;
        critical;
    }

    // Value types.
    //
    // The temperature, humidity, and timestamp wrappers mark the
    // domain meaning of a value and remain useful even though no
    // literal is assigned at definition time. The `AlertId` wrapper
    // restricts the value to a natural number.
    //
    // Time durations in story constraints are typed directly with
    // `ScalarValues::Rational` rather than wrapped, so that decimal
    // literals like `5.0` conform without an explicit cast. When the
    // SI library is adopted, these can migrate to `ISQ::TimeValue`.
    attribute def TemperatureCelsius :> ScalarValues::Real;
    attribute def RelativeHumidity   :> ScalarValues::Real;
    attribute def DateTime           :> ScalarValues::String;
    attribute def AlertId            :> ScalarValues::Natural;
}
