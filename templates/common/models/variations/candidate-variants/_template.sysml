// Candidate variants per decision point (§6.3.2).
//
// Each variant attaches the attributes the trade study needs to
// score it. Attributes typically include the value properties that
// the story benefit constraints range over (latency, throughput,
// capacity, mass, power, cost), plus any technology-specific values.

package {{PROJECT_NAME}}_CandidateVariants {

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SIPrefixes::*;
    private import MeasurementReferences::*;
    private import {{PROJECT_NAME}}_Domain::*;

    // The standard library declares no millisecond or microsecond unit,
    // so the package declares the two it uses.
    attribute <ms> millisecond : DurationUnit {
        :>> unitConversion : ConversionByPrefix { :>> prefix = milli; :>> referenceUnit = s; }
    }
    attribute <us> microsecond : DurationUnit {
        :>> unitConversion : ConversionByPrefix { :>> prefix = micro; :>> referenceUnit = s; }
    }

    // Example: detailed candidate attributes for AlarmStorageStrategy.
    // The variation in decision-points/ types its variant parts by
    // these part defs, so they carry no specialisation of their own.
    part def InMemoryRingBuffer {
        attribute capacity     : Integer       = 10000;
        attribute writeLatency : DurationValue = 1 [us];
    }
    part def EmbeddedSQLite {
        attribute capacity     : Integer       = 1000000;
        attribute writeLatency : DurationValue = 200 [us];
    }
    part def ExternalTSDB {
        attribute capacity     : Integer       = 100000000;
        attribute writeLatency : DurationValue = 5 [ms];
    }
}
