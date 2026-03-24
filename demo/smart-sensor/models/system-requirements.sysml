// ─── System Requirements ───────────────────────────────────────
package SystemRequirements {
    import StakeholderNeeds::*;

    requirement def MeasureTemperature {
        doc /* The system shall measure ambient temperature with accuracy
               of +/- 0.5 degrees Celsius over the range -20 to +60
               degrees Celsius. */
        attribute id : String = "REQ-001";
        attribute priority : String = "essential";
        attribute verificationMethod : String = "test";
        satisfy requirement MonitorTemperature;
    }

    requirement def SamplingRate {
        doc /* The system shall sample temperature at a rate of at least
               once per second. */
        attribute id : String = "REQ-002";
        attribute priority : String = "essential";
        attribute verificationMethod : String = "test";
        satisfy requirement MonitorTemperature;
    }

    requirement def ThresholdAlert {
        doc /* The system shall activate an audible and visual alert within
               2 seconds when the measured temperature exceeds the
               configured upper threshold or falls below the configured
               lower threshold. */
        attribute id : String = "REQ-003";
        attribute priority : String = "essential";
        attribute verificationMethod : String = "test";
        satisfy requirement ReceiveAlerts;
    }

    requirement def AlertClear {
        doc /* The system shall deactivate the alert within 5 seconds
               after the measured temperature returns within the
               configured thresholds. */
        attribute id : String = "REQ-004";
        attribute priority : String = "essential";
        attribute verificationMethod : String = "test";
        satisfy requirement ReceiveAlerts;
    }

    requirement def ThresholdConfiguration {
        doc /* The system shall allow the operator to configure upper and
               lower temperature thresholds independently, with a minimum
               range of -20 to +60 degrees Celsius and a resolution of
               0.1 degrees Celsius. */
        attribute id : String = "REQ-005";
        attribute priority : String = "essential";
        attribute verificationMethod : String = "demonstration";
        satisfy requirement ConfigureThresholds;
    }

    requirement def DisplayReadability {
        doc /* The system shall display current temperature and alert
               status on a screen readable from 2 metres distance under
               normal indoor lighting conditions. */
        attribute id : String = "REQ-006";
        attribute priority : String = "desirable";
        attribute verificationMethod : String = "inspection";
        satisfy requirement EasyToRead;
    }

    requirement def OperatingLife {
        doc /* The system shall operate continuously for a minimum of
               12 months between scheduled maintenance intervals. */
        attribute id : String = "REQ-007";
        attribute priority : String = "essential";
        attribute verificationMethod : String = "analysis";
        satisfy requirement ReliableOperation;
    }

    requirement def SelfDiagnostic {
        doc /* The system shall perform a self-diagnostic check at power-on
               and report any sensor malfunction to the operator within
               10 seconds. */
        attribute id : String = "REQ-008";
        attribute priority : String = "desirable";
        attribute verificationMethod : String = "test";
        satisfy requirement ReliableOperation;
    }
}
