// Smart Sensor verification cases (§5.4.6).
//
// Per methodology §5.4.6, a verification case targets a system-side
// requirement. Each case verifies one or more `acceptance` clauses
// from a system story and ties to the same trace as the originating
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

        // The verify clause references the system story's members
        // through SysML 2.0 namespace-qualifier notation. SySiDE may
        // emit a "use dot notation for nesting" warning; the
        // requirement def referenced is a classifier, not a feature
        // usage, so dot notation is not applicable here. The
        // methodology §5.4.6 example uses the same `::` form.
        objective {
            verify SYS_001_DashboardLatency::dashboardSla;
            verify SYS_001_DashboardLatency::acceptance;
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
            verify SYS_002_BatchAcknowledgement::batchAckSla;
            verify SYS_002_BatchAcknowledgement::acceptance;
        }
    }
}
