// ─── Stakeholder Needs ─────────────────────────────────────────
package StakeholderNeeds {
    doc /* Stakeholder requirements for the Smart Temperature Sensor.
           Source: Facility Manager (primary acquirer/user). */

    requirement def MonitorTemperature {
        doc /* The operator needs to monitor ambient temperature in the
               facility to ensure safe operating conditions. */
        attribute id : String = "STK-001";
        attribute priority : String = "essential";
        attribute source : String = "Facility Manager";
    }

    requirement def ReceiveAlerts {
        doc /* The operator needs to receive clear alerts when temperature
               goes outside acceptable bounds so corrective action can be
               taken promptly. */
        attribute id : String = "STK-002";
        attribute priority : String = "essential";
        attribute source : String = "Facility Manager";
    }

    requirement def ConfigureThresholds {
        doc /* The operator needs to set temperature thresholds appropriate
               to the specific facility and its contents. */
        attribute id : String = "STK-003";
        attribute priority : String = "essential";
        attribute source : String = "Facility Manager";
    }

    requirement def EasyToRead {
        doc /* The operator needs a display that can be read quickly at a
               glance from a distance of at least 2 metres. */
        attribute id : String = "STK-004";
        attribute priority : String = "desirable";
        attribute source : String = "Facility Manager";
    }

    requirement def ReliableOperation {
        doc /* The system must operate reliably for extended periods without
               requiring frequent maintenance or recalibration. */
        attribute id : String = "STK-005";
        attribute priority : String = "essential";
        attribute source : String = "Maintenance Technician";
    }
}
