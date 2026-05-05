// Smart Sensor §6.3 trade study for the alert-history storage
// decision.
//
// Per methodology §6.3 and §0.3, the trade study is an
// `analysis def` whose criteria are sourced from the system stories'
// `require constraint` clauses. Each variant from the variation
// point is scored against each weighted criterion. The selected
// variant is recorded in `variations/resolved/`.
//
// This file is illustrative. The numerical scores below are the
// engineer's working notes captured for review during §6.3.4
// disposition. Real projects revisit them with stakeholders.

package SmartSensor_AlertHistoryTrade {

    private import SmartSensor_DecisionPoints::*;
    private import SmartSensor_SystemStories::*;
    private import ScalarValues::*;

    analysis def AlertHistoryStorageTrade {
        doc /* Decision under study: AlertHistoryStorageStrategy.
               Candidates: deviceLocalRing, cloudTimeSeries.

               Criteria are sourced from system-story constraints
               per §0.3 (the connective mechanism):
                 - latency: SYS_001_DashboardLatency.dashboardSla
                 - regulatoryRetention: DataRetentionCompliance concern
                 - operatorWorkload: SYS_002.batchAckSla side-effect

               Scoring scale (1..5, higher is better):
                 deviceLocalRing  : latency 5, retention 1, workload 3
                 cloudTimeSeries  : latency 3, retention 5, workload 4

               Weights (sum to 1.0):
                 latency 0.30, retention 0.45, workload 0.25

               Weighted totals:
                 deviceLocalRing  = 5*0.30 + 1*0.45 + 3*0.25 = 2.70
                 cloudTimeSeries  = 3*0.30 + 5*0.45 + 4*0.25 = 4.15

               Recommendation: cloudTimeSeries.

               Sensitivity: regulatoryRetention dominates (weight
               0.45 and a 4-point spread). The recommendation holds
               unless the regulator's retention requirement is
               relaxed, in which case the trade should be rerun.
             */

        subject decision : AlertHistoryStorageStrategy;

        attribute latencyWeight              : Rational = 0.30;
        attribute regulatoryRetentionWeight  : Rational = 0.45;
        attribute operatorWorkloadWeight     : Rational = 0.25;

        attribute deviceLocalRingTotal       : Rational = 2.70;
        attribute cloudTimeSeriesTotal       : Rational = 4.15;
    }
}
