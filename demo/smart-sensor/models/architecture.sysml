package Architecture {
    doc /* Smart Temperature Sensor System
           Physical and functional architecture for indoor climate monitoring.
           The system reads ambient temperature, applies threshold logic,
           and sends alerts when temperature exceeds configurable bounds. */

    // ─── Port Definitions ──────────────────────────────────────

    port def TemperaturePort {
        doc /* Carries a temperature reading in degrees Celsius. */
        attribute tempValue : Real;
    }

    port def AlertPort {
        doc /* Carries an alert signal with severity level. */
        attribute alertActive : Boolean;
        attribute severity : String;
    }

    port def ConfigPort {
        doc /* Carries configuration parameters. */
        attribute upperThreshold : Real;
        attribute lowerThreshold : Real;
    }

    port def DisplayPort {
        doc /* Carries data for visual display. */
        attribute currentTemp : Real;
        attribute alertStatus : String;
    }

    // ─── Part Definitions (Functional Architecture) ────────────

    part def SensingUnit {
        doc /* Reads ambient temperature from a physical sensor. */
        port rawTempOut : TemperaturePort;
    }

    part def ProcessingUnit {
        doc /* Applies calibration, threshold comparison, and alert logic. */
        port tempIn : TemperaturePort;
        port configIn : ConfigPort;
        port alertOut : AlertPort;
        port displayOut : DisplayPort;
    }

    part def AlertUnit {
        doc /* Produces audible and visual alerts when thresholds are exceeded. */
        port alertIn : AlertPort;
    }

    part def DisplayUnit {
        doc /* Shows current temperature and alert status to the operator. */
        port displayIn : DisplayPort;
    }

    part def ConfigInterface {
        doc /* Allows the operator to set temperature thresholds. */
        port configOut : ConfigPort;
    }

    // ─── System Definition (Physical Architecture) ─────────────

    part def SmartTemperatureSensor {
        doc /* Top-level system: smart temperature sensor for indoor monitoring. */

        part sensor : SensingUnit;
        part processor : ProcessingUnit;
        part alerter : AlertUnit;
        part display : DisplayUnit;
        part config : ConfigInterface;

        // Internal connections
        connect sensor.rawTempOut to processor.tempIn;
        connect config.configOut to processor.configIn;
        connect processor.alertOut to alerter.alertIn;
        connect processor.displayOut to display.displayIn;
    }

    // ─── Behaviour (Actions) ───────────────────────────────────

    action def MonitorCycle {
        doc /* One monitoring cycle: read, process, alert if needed. */

        action readTemp {
            doc /* Read temperature from the sensing unit. */
            out item rawTemp : Real;
        }

        action checkThresholds {
            doc /* Compare reading against configured thresholds. */
            in item temp : Real;
            out item alert : Boolean;
        }

        action updateDisplay {
            doc /* Update the display with current reading and status. */
            in item temp : Real;
            in item alertActive : Boolean;
        }

        action triggerAlert {
            doc /* Activate the alert unit if threshold exceeded. */
            in item alertActive : Boolean;
        }

        succession readTemp then checkThresholds;
        succession checkThresholds then updateDisplay;
        succession checkThresholds then triggerAlert;
    }

    // ─── States ────────────────────────────────────────────────

    state def SensorStates {
        doc /* Operating states of the smart sensor system. */

        entry state idle {
            doc /* System powered on but not actively monitoring. */
        }

        state monitoring {
            doc /* System actively reading and processing temperature. */
        }

        state alerting {
            doc /* Threshold exceeded, alert active. */
        }

        state fault {
            doc /* Sensor malfunction detected. */
        }

        transition idle_to_monitoring
            first idle then monitoring;

        transition monitoring_to_alerting
            first monitoring then alerting;

        transition alerting_to_monitoring
            first alerting then monitoring;

        transition monitoring_to_fault
            first monitoring then fault;

        transition fault_to_idle
            first fault then idle;
    }
}
