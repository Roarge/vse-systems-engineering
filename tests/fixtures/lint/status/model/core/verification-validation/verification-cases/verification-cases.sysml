package FixtureStatusCases {
    private import FixtureStatus::*;

    verification def VC_514_FirstReading {
        objective {
            verify US_514_NoStatusNoRole.acceptance.firstReading;
        }
    }

    verification def VC_515_FirstReading {
        objective {
            verify US_515_Clean.acceptance.firstReading;
        }
    }
}
