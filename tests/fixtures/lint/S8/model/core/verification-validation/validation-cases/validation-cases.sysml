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

    // Cases written on one line, as in the case table of methodology
    // section 4, and two cases on one line.
    verification def VAL_190_OneLine { subject s : ExampleSystem; objective { verify US_190_CoveredOnOneLine.acceptance.firstReading; } }

    verification def VAL_191_First { objective { verify US_191_TwoCasesOnOneLine.acceptance.firstReading; } } verification def VAL_191_Unit { objective { verify US_191_TwoCasesOnOneLine.acceptance.readingUnit; } }
}
