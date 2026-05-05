// Candidate variants per decision point (§6.3.2).
//
// Each variant attaches the attributes the trade study needs to
// score it. Attributes typically include the value properties that
// the story benefit constraints range over (latency, throughput,
// capacity, mass, power, cost), plus any technology-specific values.

package {{PROJECT_NAME}}_CandidateVariants {

    private import {{PROJECT_NAME}}_DecisionPoints::*;
    private import {{PROJECT_NAME}}_Domain::*;

    // Example: detailed candidate attributes for AlarmStorageStrategy.
    part def InMemoryRingBuffer :> AlarmStorageStrategy::inMemoryRingBuffer {
        attribute capacity     : Integer       = 10000;
        attribute writeLatency : DurationValue = 1 [us];
    }
    part def EmbeddedSQLite :> AlarmStorageStrategy::embeddedSQLite {
        attribute capacity     : Integer       = 1000000;
        attribute writeLatency : DurationValue = 200 [us];
    }
    part def ExternalTSDB :> AlarmStorageStrategy::externalTSDB {
        attribute capacity     : Integer       = 100000000;
        attribute writeLatency : DurationValue = 5 [ms];
    }

    // Placeholder type until the project's domain library declares it.
    attribute def DurationValue :> Real;
}
