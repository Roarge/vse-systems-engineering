// ─── Verification Cases ────────────────────────────────────────
package Verification {
    import SystemRequirements::*;

    verification def VerifyTempAccuracy {
        doc /* Test: Apply known reference temperatures at -20, 0, 20, 40,
               and 60 degrees Celsius using a calibrated reference source.
               Record the system reading at each point. All readings must
               be within +/- 0.5 degrees Celsius of the reference value. */
        attribute id : String = "VER-001";
        attribute method : String = "test";
        attribute passCriteria : String = "All readings within +/- 0.5 C of reference";
        verify requirement MeasureTemperature;
    }

    verification def VerifySamplingRate {
        doc /* Test: Configure the system to output raw sample timestamps.
               Collect 60 seconds of data. Verify that at least 60 samples
               are recorded (one per second minimum). */
        attribute id : String = "VER-002";
        attribute method : String = "test";
        attribute passCriteria : String = "At least 60 samples in 60 seconds";
        verify requirement SamplingRate;
    }

    verification def VerifyAlertActivation {
        doc /* Test: Set upper threshold to 25 degrees Celsius. Apply a
               temperature step from 24 to 26 degrees Celsius. Measure
               time from threshold crossing to alert activation. Must be
               under 2 seconds. Repeat for lower threshold. */
        attribute id : String = "VER-003";
        attribute method : String = "test";
        attribute passCriteria : String = "Alert activates within 2 seconds of crossing";
        verify requirement ThresholdAlert;
    }

    verification def VerifyAlertClear {
        doc /* Test: With alert active due to upper threshold exceeded,
               reduce temperature to below threshold. Measure time from
               threshold re-entry to alert deactivation. Must be under
               5 seconds. */
        attribute id : String = "VER-004";
        attribute method : String = "test";
        attribute passCriteria : String = "Alert clears within 5 seconds";
        verify requirement AlertClear;
    }

    verification def VerifyThresholdConfig {
        doc /* Demonstration: Using the configuration interface, set the
               upper threshold to 50 degrees Celsius and the lower
               threshold to -10 degrees Celsius. Verify the system
               accepts both values. Set thresholds at 0.1 degree
               increments and verify resolution. */
        attribute id : String = "VER-005";
        attribute method : String = "demonstration";
        attribute passCriteria : String = "Thresholds configurable over full range at 0.1 C resolution";
        verify requirement ThresholdConfiguration;
    }

    verification def VerifyDisplayReadability {
        doc /* Inspection: Position an observer 2 metres from the display
               under standard indoor lighting (300-500 lux). Observer must
               read the displayed temperature and alert status without
               difficulty. Three independent observers must agree. */
        attribute id : String = "VER-006";
        attribute method : String = "inspection";
        attribute passCriteria : String = "3 of 3 observers read display correctly at 2 metres";
        verify requirement DisplayReadability;
    }

    verification def VerifyOperatingLife {
        doc /* Analysis: Review component datasheets for MTBF values.
               Calculate system-level reliability using series model.
               Projected MTBF must exceed 12 months of continuous
               operation at 25 degrees Celsius ambient. */
        attribute id : String = "VER-007";
        attribute method : String = "analysis";
        attribute passCriteria : String = "Calculated MTBF exceeds 8760 hours";
        verify requirement OperatingLife;
    }

    verification def VerifySelfDiagnostic {
        doc /* Test: Power on the system with a simulated sensor fault
               (disconnected probe). Verify that the system reports the
               malfunction on the display within 10 seconds of power-on.
               Repeat with a functioning probe and verify no false alarm. */
        attribute id : String = "VER-008";
        attribute method : String = "test";
        attribute passCriteria : String = "Fault reported within 10 seconds, no false alarm with good probe";
        verify requirement SelfDiagnostic;
    }
}
