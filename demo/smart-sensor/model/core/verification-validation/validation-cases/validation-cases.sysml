// Smart Sensor validation cases (§4.3.6).
//
// Per methodology §4.3.6, a validation case exercises a stakeholder
// story directly. It tests whether the system satisfies the
// stakeholder's intent, not whether the system meets its system-
// internal specification (that is what a verification case is for).
//
// Identifier convention: VAL_<n>_<ShortName>.

package SmartSensor_ValidationCases {

    private import SmartSensor_Context::*;
    private import SmartSensor_StakeholderStories::*;

    // VAL_001 validates US_001_SeeReadingsOnDashboard with the
    // operator stakeholder, in a representative deployment.
    verification def VAL_001_OperatorSeeReadings {
        doc /* Subject of validation: the operator's experience of
               seeing live readings on the dashboard at a real
               deployment site (not a lab replay).

               Method: deploy one device at the demo site for one
               full work shift. Have the operator describe readings
               observed at agreed times. Compare to independent
               reference instrument. Confirm the operator could act
               on conditions without travelling to the site.

               Pass criterion: operator self-reports the dashboard
               as "timely and accurate enough to make daily
               decisions" and reference-instrument deviation remains
               within calibration band.
             */

        subject system : SmartSensor_System;

        objective {
            verify US_001_SeeReadingsOnDashboard::acceptance;
        }
    }

    // VAL_002 validates US_003_CalibrateInField.
    verification def VAL_002_TechnicianFieldCalibration {
        doc /* Subject of validation: the maintenance technician's
               ability to calibrate the device against a portable
               reference probe in the field.

               Method: technician performs calibration unaccompanied
               at one outdoor and one indoor deployment site, using
               only the documented procedure and the supplied
               portable reference. Outcome is observed and the
               calibration offset stored is read back from the next
               reading.

               Pass criterion: both calibrations complete within
               documented time budget, calibration offset is
               recorded, and the next reading reflects it.
             */

        subject system : SmartSensor_System;

        objective {
            verify US_003_CalibrateInField::acceptance;
        }
    }
}
