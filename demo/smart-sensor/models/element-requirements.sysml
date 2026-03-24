// ─── Element Requirements ──────────────────────────────────────
package ElementRequirements {
    import SystemRequirements::*;

    doc /* Requirements allocated to individual system elements. Each
           element requirement derives from a system requirement with
           tighter performance margins to provide design headroom. */

    // ─── SensingUnit ──────────────────────────────────────────

    requirement def SensingAccuracy {
        doc /* The SensingUnit shall measure ambient temperature with
               accuracy of +/- 0.3 degrees Celsius over the range -20
               to +60 degrees Celsius. This provides 0.2 degrees Celsius
               margin against the system-level +/- 0.5 degrees Celsius
               budget to accommodate calibration drift and processing
               rounding. */
        attribute id : String = "ELE-001";
        attribute priority : String = "essential";
        attribute verificationMethod : String = "test";
        attribute allocatedTo : String = "SensingUnit";
        satisfy requirement MeasureTemperature;
    }

    requirement def SensingSamplingCapability {
        doc /* The SensingUnit shall produce at least 2 temperature
               samples per second. This provides margin over the
               system-level 1 sample per second requirement to allow
               the ProcessingUnit to apply averaging or filtering
               without degrading effective update rate. */
        attribute id : String = "ELE-002";
        attribute priority : String = "essential";
        attribute verificationMethod : String = "test";
        attribute allocatedTo : String = "SensingUnit";
        satisfy requirement SamplingRate;
    }

    // ─── ProcessingUnit ───────────────────────────────────────

    requirement def ThresholdDetectionLatency {
        doc /* The ProcessingUnit shall detect a threshold crossing and
               generate an alert signal within 1 second of receiving the
               sample that exceeds the configured threshold. This
               provides 1 second margin against the system-level 2
               second alert activation requirement to account for
               AlertUnit response time. */
        attribute id : String = "ELE-003";
        attribute priority : String = "essential";
        attribute verificationMethod : String = "test";
        attribute allocatedTo : String = "ProcessingUnit";
        satisfy requirement ThresholdAlert;
    }

    requirement def AlertClearLatency {
        doc /* The ProcessingUnit shall clear the alert signal within 2
               seconds after receiving a sample that falls within the
               configured thresholds. This provides 3 seconds margin
               against the system-level 5 second requirement to account
               for AlertUnit deactivation time and display update. */
        attribute id : String = "ELE-004";
        attribute priority : String = "essential";
        attribute verificationMethod : String = "test";
        attribute allocatedTo : String = "ProcessingUnit";
        satisfy requirement AlertClear;
    }

    requirement def ProcessingReliability {
        doc /* The ProcessingUnit shall have a mean time between failures
               of at least 12000 hours. This provides margin over the
               system-level 8760 hours (12 months) requirement to
               account for the combined failure rates of other system
               elements in a series reliability model. */
        attribute id : String = "ELE-007";
        attribute priority : String = "essential";
        attribute verificationMethod : String = "analysis";
        attribute allocatedTo : String = "ProcessingUnit";
        satisfy requirement OperatingLife;
    }

    requirement def BootSelfDiagnostic {
        doc /* The ProcessingUnit shall execute a self-diagnostic
               sequence at power-on that checks sensor communication,
               memory integrity, and threshold configuration validity,
               completing within 5 seconds. This provides 5 seconds
               margin against the system-level 10 second requirement
               to allow for display initialisation and operator
               notification formatting. */
        attribute id : String = "ELE-008";
        attribute priority : String = "desirable";
        attribute verificationMethod : String = "test";
        attribute allocatedTo : String = "ProcessingUnit";
        satisfy requirement SelfDiagnostic;
    }

    // ─── ConfigInterface ──────────────────────────────────────

    requirement def ConfigParameterRange {
        doc /* The ConfigInterface shall accept upper and lower threshold
               parameters independently over the range -20 to +60
               degrees Celsius with a resolution of 0.1 degrees Celsius.
               The interface shall validate that the lower threshold is
               at least 1.0 degrees Celsius below the upper threshold
               and reject invalid configurations with a clear error
               message. */
        attribute id : String = "ELE-005";
        attribute priority : String = "essential";
        attribute verificationMethod : String = "demonstration";
        attribute allocatedTo : String = "ConfigInterface";
        satisfy requirement ThresholdConfiguration;
    }

    // ─── DisplayUnit ──────────────────────────────────────────

    requirement def DisplayLegibility {
        doc /* The DisplayUnit shall render current temperature and alert
               status using characters of at least 12 mm height with a
               contrast ratio of at least 4.5:1, ensuring legibility at
               2 metres under normal indoor lighting (300 to 500 lux).
               The display shall update within 1 second of receiving new
               data from the ProcessingUnit. */
        attribute id : String = "ELE-006";
        attribute priority : String = "desirable";
        attribute verificationMethod : String = "inspection";
        attribute allocatedTo : String = "DisplayUnit";
        satisfy requirement DisplayReadability;
    }
}
