// Smart Sensor system story register (§5).
//
// Per §5.4.1, system stories derive from stakeholder stories. Same
// role, restated capability in system-internal vocabulary, sharpened
// benefit (formalised as `require constraint` per §5.4.2 to feed §6
// trade studies, the §0.3 connective mechanism).
//
// Identifier convention: SYS_<n>_<ShortName>.

package SmartSensor_SystemStories {

    private import SmartSensor_Stakeholders::*;
    private import SmartSensor_Concerns::*;
    private import SmartSensor_Context::*;
    private import SmartSensor_Domain::*;
    private import SmartSensor_StakeholderStories::*;
    private import VSE_Library::*;
    private import ScalarValues::*;

    // SYS_001 derives from US_001_SeeReadingsOnDashboard.
    // Sharpens "within 5 seconds" to a constraint on the cloud
    // delivery latency that §6 trade studies can score against.
    requirement def SYS_001_DashboardLatency :> UserStory {
        doc /* StoryMeta: points=5, priority=high, status=ready.
               #derive from US_001_SeeReadingsOnDashboard. */

        subject system : SmartSensor_System;
        stakeholder role : Operator;

        attribute :>> capability =
            "deliver each reading from the device to the dashboard within a bounded latency";
        attribute :>> benefit    =
            "the operator's view of the deployment site is timely enough to act on changing conditions";

        frame concern : StableMonitoring;

        attribute maxDeliveryLatency : ScalarValues::Rational = 5.0;

        // The connective mechanism (§0.3): this require constraint
        // is the trade-study criterion when an architectural
        // decision affects this story (§6.3.4).
        require constraint dashboardSla {
            doc /* The system shall deliver each reading from the
                   device's measurement instant to the dashboard's
                   render path within maxDeliveryLatency seconds at
                   the 95th percentile under nominal load. */
        }

        requirement acceptance[1] {
            doc /* Given the device is online and reporting at the
                   nominal interval, when a reading is captured at
                   time t, then the dashboard renders that reading
                   no later than t + 5 seconds at the 95th percentile
                   over a 1-hour window. */
        }
    }

    // SYS_002 derives from US_002_AcknowledgeAlertsBatched.
    // Sharpens "within 1 second" to a system-internal latency
    // constraint that lives at the dashboard service.
    requirement def SYS_002_BatchAcknowledgement :> UserStory {
        doc /* StoryMeta: points=8, priority=high, status=ready.
               #derive from US_002_AcknowledgeAlertsBatched. */

        subject system : SmartSensor_System;
        stakeholder role : Operator;

        attribute :>> capability =
            "transition every unacknowledged alert in a selected batch to acknowledged in one operation";
        attribute :>> benefit    =
            "operator workload during alert storms remains tractable";

        frame concern : AlertResponseTime;

        attribute maxBatchAckLatency : ScalarValues::Rational = 1.0;
        attribute maxBatchSize       : Integer       = 1000;

        // Connective mechanism (§0.3) again: this constraint
        // becomes a trade-study criterion when the alert storage
        // strategy is being decided.
        require constraint batchAckSla {
            doc /* When N alerts up to maxBatchSize are selected, the
                   system shall transition all N to acknowledged
                   within maxBatchAckLatency seconds. */
        }

        requirement acceptance[1] {
            doc /* Given N unacknowledged alerts (N up to 1000) are
                   shown, when the operator selects "Acknowledge all",
                   then all N transition within 1 second. */
        }
    }
}
