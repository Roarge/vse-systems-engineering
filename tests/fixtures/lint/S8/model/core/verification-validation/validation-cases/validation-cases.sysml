package FixtureS8Cases {
    private import FixtureS8::*;

    verification def VAL_182_FirstReading {
        objective {
            verify US_182_OneCriterionUncovered.acceptance.firstReading;
        }
    }

    verification def VAL_183_ByName {
        objective {
            verify US_183_CoveredByName.acceptance.firstReading;
        }
    }

    verification def VAL_184_ByAcceptance {
        objective {
            verify US_184_CoveredByAcceptance.acceptance;
        }
    }

    verification def VAL_185_ByStory {
        objective {
            verify US_185_CoveredByStory;
        }
    }
}
