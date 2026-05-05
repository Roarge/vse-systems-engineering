// Smart Sensor stakeholder story register (§4).
//
// Each story enters in §1.7.1 minimal form (subject, role,
// capability, benefit, at least one acceptance, frame concern).
// Identifier convention: US_<n>_<ShortName>.
//
// StoryMeta on each story is recorded as a doc comment because the
// `@StoryMeta { ... }` body-form invocation depends on the
// methodology library packaging forecast in §0.8, which has not yet
// shipped. Until that packaging lands, the renderer pipeline
// extracts StoryMeta from the doc comment below.

package SmartSensor_StakeholderStories {

    private import SmartSensor_Stakeholders::*;
    private import SmartSensor_Concerns::*;
    private import SmartSensor_Context::*;
    private import VSE_Library::*;

    requirement def US_001_SeeReadingsOnDashboard :> UserStory {
        doc /* StoryMeta: points=5, priority=high, status=ready. */

        subject system : SmartSensor_System;
        stakeholder role : Operator;

        attribute :>> capability = "see live temperature and humidity readings on a dashboard";
        attribute :>> benefit    = "deployment-site conditions are visible without on-site visits";

        frame concern : StableMonitoring;

        requirement acceptance[1] {
            doc /* Given the device is online and reporting,
                   when the operator opens the dashboard,
                   then the latest reading is displayed within 5 seconds
                   of arrival at the cloud broker. */
        }
    }

    requirement def US_002_AcknowledgeAlertsBatched :> UserStory {
        doc /* StoryMeta: points=8, priority=high, status=ready. */

        subject system : SmartSensor_System;
        stakeholder role : Operator;

        attribute :>> capability = "acknowledge a batch of unacknowledged alerts in one action";
        attribute :>> benefit    = "the alert queue clears quickly during incident storms";

        frame concern : AlertResponseTime;

        requirement acceptance[1] {
            doc /* Given N unacknowledged alerts shown,
                   when the operator selects "Acknowledge all",
                   then all N transition to acknowledged within 1 second. */
        }
    }

    requirement def US_003_CalibrateInField :> UserStory {
        doc /* StoryMeta: points=5, priority=medium, status=ready. */

        subject system : SmartSensor_System;
        stakeholder role : MaintenanceTechnician;

        attribute :>> capability = "calibrate the sensor against a reference probe in the field";
        attribute :>> benefit    = "calibration drift is corrected without removing the device";

        frame concern : DeviceServiceability;

        requirement acceptance[1] {
            doc /* Given a portable reference probe at the deployment site,
                   when the technician runs the calibration command via the maintenance port,
                   then the device stores the calibration offset and reports it on the next reading. */
        }
    }
}
