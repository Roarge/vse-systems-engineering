// Smart Sensor verification cases (§5.4.6).
//
// Per methodology §5.4.6, a verification case targets a system-side
// requirement usage. Each case here takes one system story, verifying
// both the sharpened constraint that formalises its benefit and its
// `acceptance` clause, and ties to the same trace as the originating
// stakeholder story.
//
// Identifier convention: VC_<n>_<ShortName>.

package SmartSensor_VerificationCases {

    private import SmartSensor_Context::*;
    private import SmartSensor_SystemStories::*;

    // VC_001 verifies SYS_001_DashboardLatency.
    verification def VC_001_DashboardLatencyP95 {
        doc /* Method: instrument the cloud broker and the dashboard
               renderer with timestamp probes. Replay one hour of
               nominal device traffic at the standard cadence.
               Compute the 95th percentile end-to-end latency from
               device timestamp to render-complete event.

               Pass criterion: P95 latency <= 5.0 seconds.

               Equipment: timestamp probes, replay harness, P95
               aggregator.
             */

        subject system : SmartSensor_System;

        objective {
            verify SYS_001_DashboardLatency.dashboardSla;
            verify SYS_001_DashboardLatency.acceptance;
        }
    }

    // VC_002 verifies SYS_002_BatchAcknowledgement.
    verification def VC_002_BatchAckLatency {
        doc /* Method: stage 1000 unacknowledged alerts in the cloud
               store. Trigger "Acknowledge all" via the operator-side
               API. Measure wall-clock time from request to last
               alert state-transition.

               Pass criterion: total time <= 1.0 second.

               Equipment: alert-staging fixture, monotonic clock
               on cloud side, state-transition probe.
             */

        subject system : SmartSensor_System;

        objective {
            verify SYS_002_BatchAcknowledgement.batchAckSla;
            verify SYS_002_BatchAcknowledgement.acceptance;
        }
    }

    // VC_003 verifies SYS_003_CalibrationOffsetCommit.
    verification def VC_003_CalibrationCommitTime {
        doc /* Method: attach a reference probe simulator to the
               maintenance port. Issue a calibration command with a
               known reference value. Timestamp the command
               acceptance and the first published reading that
               carries the corrected value. Power-cycle the device
               and repeat the read.

               Pass criterion: commit time <= 2.0 seconds, and the
               offset survives the power cycle.

               Equipment: reference probe simulator, maintenance-port
               harness, switched supply, cloud-side reading capture.
             */

        subject system : SmartSensor_System;

        objective {
            verify SYS_003_CalibrationOffsetCommit.calibrationCommitSla;
            verify SYS_003_CalibrationOffsetCommit.acceptance;
        }
    }

    // VC_004 verifies SYS_004_AlertRetentionWindow.
    verification def VC_004_AlertRetentionWindow {
        doc /* Method: seed the alert store with dated records
               spanning the retention period, using an accelerated
               store clock. Run the audit query at the start, the
               middle, and the last day of the window. Recompute the
               integrity digest of every returned record and compare
               it with the digest recorded at write time.

               Pass criterion: every seeded alert is returned at
               every sample point with a matching digest, over a
               window of at least 1825 days.

               Equipment: dated-alert generator, accelerated store
               clock, audit-query client, digest recomputation tool.
             */

        subject system : SmartSensor_System;

        objective {
            verify SYS_004_AlertRetentionWindow.retentionWindowSla;
            verify SYS_004_AlertRetentionWindow.acceptance;
        }
    }
}
