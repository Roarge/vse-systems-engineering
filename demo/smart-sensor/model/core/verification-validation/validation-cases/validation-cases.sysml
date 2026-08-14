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

    // VAL_003 validates US_002_AcknowledgeAlertsBatched.
    verification def VAL_003_OperatorBatchAcknowledgement {
        doc /* Subject of validation: the operator's ability to clear
               an alert queue during an incident storm using the
               batch acknowledgement action alone.

               Method: seed a representative alert storm at the demo
               deployment, sized as the operator judges typical of a
               real incident. Have the operator clear the queue with
               the "Acknowledge all" action and nothing else, with no
               per-alert follow-up permitted. Record the time from
               the action to the last seeded alert reaching the
               acknowledged state, and observe that every seeded
               alert transitions.

               Pass criterion: the queue clears in one action, every
               seeded alert reaches the acknowledged state within
               1 second of the action per the story acceptance, and
               the operator reports the mechanism as fast enough to
               keep up with an incident storm.
             */

        subject system : SmartSensor_System;

        objective {
            verify US_002_AcknowledgeAlertsBatched::acceptance;
        }
    }

    // VAL_004 validates US_004_RetainAlertHistory. The story is
    // Regulator-side, so the case validates the Regulator's
    // retention intent, with the operator executing the review on
    // the Regulator's behalf.
    verification def VAL_004_RegulatorRetentionEvidence {
        doc /* Subject of validation: the Regulator's retention
               intent, evidenced by whether the retained alert
               history is complete and reviewable once real alerts
               have accumulated across the documented retention
               window.

               Method: after the documented retention interval has
               accumulated real alerts at the demo deployment, have
               the operator review the alert history against the
               independently kept incident log. Check each logged
               incident for a corresponding retained alert, and run
               the tamper-evidence check on every record retrieved.

               Pass criterion: the history is complete across the
               retention window with no logged incident missing from
               the store, and every alert queried during the review
               is retrievable with its tamper-evidence check
               confirming the record is unmodified.
             */

        subject system : SmartSensor_System;

        objective {
            verify US_004_RetainAlertHistory::acceptance;
        }
    }
}
