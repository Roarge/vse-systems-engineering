// Smart Sensor system story register (§5).
//
// Per §5.4.1, system stories derive from stakeholder stories. Same
// role, restated capability in system-internal vocabulary, sharpened
// benefit (formalised per §5.4.2 as a nested requirement usage
// carrying a `require constraint`, so that §6 trade studies and
// verification cases can reference it, the §0.3 connective
// mechanism).
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
    private import RequirementDerivation::*;

    // SYS_001 derives from US_001_SeeReadingsOnDashboard.
    // Sharpens "within 5 seconds" to a constraint on the cloud
    // delivery latency that §6 trade studies can score against.
    #derive
    requirement SYS_001_DashboardLatency : UserStory {
        @StoryMeta { points = 5; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : SmartSensor_System;
        stakeholder :>> role : Operator;

        attribute :>> capability =
            "deliver each reading from the device to the dashboard within a bounded latency";
        attribute :>> benefit    =
            "the operator's view of the deployment site is timely enough to act on changing conditions";

        frame concern : StableMonitoring;

        attribute maxDeliveryLatency : ScalarValues::Rational = 5.0;

        // The connective mechanism (§0.3): this nested requirement
        // carries the constraint a §6 trade study scores against when
        // an architectural decision affects this story (§6.3.4). The
        // constraint sits inside a requirement usage so that a
        // verification case can name it (§5.4.2).
        requirement dashboardSla {
            doc /* The system shall deliver each reading from the
                   device's measurement instant to the dashboard's
                   render path within maxDeliveryLatency seconds at
                   the 95th percentile under nominal load. */
            require constraint { maxDeliveryLatency <= 5.0 }
        }

        requirement :>> acceptance {
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
    #derive
    requirement SYS_002_BatchAcknowledgement : UserStory {
        @StoryMeta { points = 8; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : SmartSensor_System;
        stakeholder :>> role : Operator;

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
        requirement batchAckSla {
            doc /* When N alerts up to maxBatchSize are selected, the
                   system shall transition all N to acknowledged
                   within maxBatchAckLatency seconds. */
            require constraint { maxBatchAckLatency <= 1.0 }
        }

        requirement :>> acceptance {
            doc /* Given N unacknowledged alerts (N up to 1000) are
                   shown, when the operator selects "Acknowledge all",
                   then all N transition within 1 second. */
        }
    }

    // SYS_003 derives from US_003_CalibrateInField.
    // Sharpens "stores the calibration offset and reports it on the
    // next reading" to a bounded commit time on the maintenance port.
    #derive
    requirement SYS_003_CalibrationOffsetCommit : UserStory {
        @StoryMeta { points = 5; priority = Priority::medium; status = StoryStatus::ready; }

        subject :>> system : SmartSensor_System;
        stakeholder :>> role : MaintenanceTechnician;

        attribute :>> capability =
            "accept a reference measurement on the maintenance port, derive a calibration offset, persist it across power cycles, and apply it to every subsequent reading";
        attribute :>> benefit    =
            "the technician confirms a corrected reading before leaving the deployment site";

        frame concern : DeviceServiceability;

        attribute maxCalibrationCommitTime : ScalarValues::Rational = 2.0;

        // Connective mechanism (§0.3): the commit time is the
        // trade-study criterion whenever a decision touches the
        // maintenance port or the non-volatile store.
        requirement calibrationCommitSla {
            doc /* From acceptance of a calibration command on the
                   maintenance port, the system shall persist the
                   offset and apply it to the reading path within
                   maxCalibrationCommitTime seconds. */
            require constraint { maxCalibrationCommitTime <= 2.0 }
        }

        requirement :>> acceptance {
            doc /* Given a calibration command carrying a reference
                   value, when the device accepts it on the
                   maintenance port, then the stored offset survives
                   a power cycle and the next reading published to
                   the cloud carries the corrected value. */
        }
    }

    // SYS_004 derives from US_004_RetainAlertHistory.
    // Sharpens "the regulator-mandated retention window" to a
    // minimum retention period on an append-only alert store.
    #derive
    requirement SYS_004_AlertRetentionWindow : UserStory {
        @StoryMeta { points = 3; priority = Priority::medium; status = StoryStatus::ready; }

        subject :>> system : SmartSensor_System;
        stakeholder :>> role : Regulator;

        attribute :>> capability =
            "write every raised alert to an append-only store with an integrity digest and keep the record queryable for the mandated retention period";
        attribute :>> benefit    =
            "an audit query at any instant inside the retention period returns the complete alert set together with its integrity evidence";

        frame concern : DataRetentionCompliance;

        attribute minRetentionPeriodDays : ScalarValues::Rational = 1825.0;

        // Connective mechanism (§0.3): the retention period is now a
        // story-sourced criterion for any §6 decision over the alert
        // store. The 2026-04-15 alert-history trade study predates
        // this story and had to source its retention criterion from
        // the DataRetentionCompliance concern directly. Its record
        // stands as taken (§6.3.4). A rerun would score against
        // retentionWindowSla.
        requirement retentionWindowSla {
            doc /* Every alert written to the store shall remain
                   queryable, with its integrity digest intact, for
                   at least minRetentionPeriodDays days after the
                   instant it was raised. */
            require constraint { minRetentionPeriodDays >= 1825.0 }
        }

        requirement :>> acceptance {
            doc /* Given an alert raised at time t, when an audit
                   query runs at any instant between t and t plus the
                   retention period, then the store returns that
                   alert with a digest that matches the value
                   recorded at t. */
        }
    }

    // Explicit derivation connections (spec §9.6.2, methodology §5.4.1).
    // `#derivation` tags the connection with the standard library's
    // DerivationMetadata, and the two ends are tagged `#original` and
    // `#derive` so the direction is explicit at the connection site.
    #derivation connection sys001Derives {
        end #original ::> US_001_SeeReadingsOnDashboard;
        end #derive   ::> SYS_001_DashboardLatency;
    }
    #derivation connection sys002Derives {
        end #original ::> US_002_AcknowledgeAlertsBatched;
        end #derive   ::> SYS_002_BatchAcknowledgement;
    }
    #derivation connection sys003Derives {
        end #original ::> US_003_CalibrateInField;
        end #derive   ::> SYS_003_CalibrationOffsetCommit;
    }
    #derivation connection sys004Derives {
        end #original ::> US_004_RetainAlertHistory;
        end #derive   ::> SYS_004_AlertRetentionWindow;
    }
}
