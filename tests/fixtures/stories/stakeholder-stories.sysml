// Smart Sensor stakeholder story register (§4).
//
// Each story enters in §1.7.1 minimal form (subject, role,
// capability, benefit, at least one acceptance, frame concern).
// Identifier convention: US_<n>_<ShortName>.

package SmartSensor_StakeholderStories {

    private import SmartSensor_Stakeholders::*;
    private import SmartSensor_Concerns::*;
    private import SmartSensor_Context::*;
    private import VSE_Library::*;

    requirement US_001_SeeReadingsOnDashboard : UserStory {
        @StoryMeta { points = 5; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : SmartSensor_System;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see live temperature and humidity readings on a dashboard";
        attribute :>> benefit    = "deployment-site conditions are visible without on-site visits";

        frame concern : StableMonitoring;

        requirement :>> acceptance {
            doc /* Given the device is online and reporting,
                   when the operator opens the dashboard,
                   then the latest reading is displayed within 5 seconds
                   of arrival at the cloud broker. */
        }
    }

    requirement US_002_AcknowledgeAlertsBatched : UserStory {
        @StoryMeta { points = 8; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : SmartSensor_System;
        stakeholder :>> role : Operator;

        attribute :>> capability = "acknowledge a batch of unacknowledged alerts in one action";
        attribute :>> benefit    = "the alert queue clears quickly during incident storms";

        frame concern : AlertResponseTime;

        requirement :>> acceptance {
            doc /* Given N unacknowledged alerts shown,
                   when the operator selects "Acknowledge all",
                   then all N transition to acknowledged within 1 second. */
        }
    }

    requirement US_003_CalibrateInField : UserStory {
        @StoryMeta { points = 5; priority = Priority::medium; status = StoryStatus::ready; }

        subject :>> system : SmartSensor_System;
        stakeholder :>> role : MaintenanceTechnician;

        attribute :>> capability = "calibrate the sensor against a reference probe in the field";
        attribute :>> benefit    = "calibration drift is corrected without removing the device";

        frame concern : DeviceServiceability;

        requirement :>> acceptance {
            doc /* Given a portable reference probe at the deployment site,
                   when the technician runs the calibration command via the maintenance port,
                   then the device stores the calibration offset and reports it on the next reading. */
        }
    }

    requirement US_004_RetainAlertHistory : UserStory {
        @StoryMeta { points = 3; priority = Priority::medium; status = StoryStatus::ready; }

        doc /* Regulator-side story. The Regulator is a non-interacting
               stakeholder, so this story has no use case. The story
               exists to frame DataRetentionCompliance into the story
               register so trade-study criteria sourced from that
               concern (the §0.3 connective mechanism) trace back to
               stakeholder intent. */

        subject :>> system : SmartSensor_System;
        stakeholder :>> role : Regulator;

        attribute :>> capability = "retain every alert in a tamper-evident store for the regulator-mandated retention window";
        attribute :>> benefit    = "regulatory audits can reconstruct the full alert history of any deployment";

        frame concern : DataRetentionCompliance;

        requirement :>> acceptance {
            doc /* Given an alert raised at time t, when the regulator's
                   audit process queries the alert store at any time
                   within the mandated retention window, then the alert
                   is retrievable and a tamper-evidence check confirms
                   the record is unmodified. */
        }
    }
}
