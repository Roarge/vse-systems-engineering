// Trade study analysis cases (§6.3.5).
//
// Each trade study is an `analysis def`. The study sources its
// criteria directly from the `require constraint` clauses on system
// stories per §0.3 and §6.3.4 (the connective mechanism). No
// separate criterion-authoring step.
//
// Sub-steps (§6.3.5):
//   1. Source criteria from story benefits (already done in §6.3.4).
//   2. Assign weights, normalising to 1.0.
//   3. Define utility curves per criterion.
//   4. Score variants via the vse-trade-study-runner subagent.
//   5. Determine the solution as the variant with the best total.

package {{PROJECT_NAME}}_TradeStudies {

    private import {{PROJECT_NAME}}_DecisionPoints::*;
    private import {{PROJECT_NAME}}_CandidateVariants::*;
    private import {{PROJECT_NAME}}_SystemStories::*;
    private import {{PROJECT_NAME}}_Domain::*;

    analysis def AlarmStorageTradeStudy {
        subject alternatives : AlarmStorageStrategy = (
            InMemoryRingBuffer,
            EmbeddedSQLite,
            ExternalTSDB
        );

        // Criteria sourced directly from story benefit constraints.
        attribute slaConstraint = SYS_001_Example::sla;
        attribute slaWeight     : Real = 0.5;
        // Add further criteria attributes here, weights normalising to 1.0.

        // Utility curves and the evaluation function go here.
        // calc def evaluation : EvaluationFunction { ... }

        // Objective drives the selection step.
        // objective : MaximiseObjective { ... }
    }
}
