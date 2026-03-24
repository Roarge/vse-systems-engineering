// ─── Validation Cases ──────────────────────────────────────────
package Validation {
    import StakeholderNeeds::*;

    verification def ValidateMonitoring {
        doc /* Demonstration: Install the system in a representative
               facility room. Ask the Facility Manager to perform
               typical monitoring tasks for one hour. Confirm the system
               meets the operator's stated need for temperature
               monitoring. Record feedback. */
        attribute id : String = "VAL-001";
        attribute method : String = "demonstration";
        verify requirement MonitorTemperature;
    }

    verification def ValidateAlerts {
        doc /* Demonstration: With the system installed, artificially
               trigger a threshold crossing. Ask the Facility Manager
               whether the alert is sufficiently clear and prompt.
               Record whether the operator considers the alerting
               adequate for their operational needs. */
        attribute id : String = "VAL-002";
        attribute method : String = "demonstration";
        verify requirement ReceiveAlerts;
    }

    verification def ValidateConfiguration {
        doc /* Demonstration: Ask the Facility Manager to configure
               thresholds appropriate to their facility without
               assistance. Record time taken and any difficulties.
               The operator must complete configuration within
               5 minutes without help. */
        attribute id : String = "VAL-003";
        attribute method : String = "demonstration";
        verify requirement ConfigureThresholds;
    }

    verification def ValidateReadability {
        doc /* Demonstration: Ask the Facility Manager to read the
               display from their typical monitoring position. Record
               whether they can read temperature and status at a
               glance without moving closer. */
        attribute id : String = "VAL-004";
        attribute method : String = "demonstration";
        verify requirement EasyToRead;
    }

    verification def ValidateReliability {
        doc /* Review: Present the reliability analysis results and
               maintenance schedule to the Maintenance Technician.
               Confirm the 12-month maintenance interval is acceptable
               for their operational context. */
        attribute id : String = "VAL-005";
        attribute method : String = "inspection";
        verify requirement ReliableOperation;
    }
}
