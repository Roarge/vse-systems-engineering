package CleanValidationCases {
    private import CleanStakeholderStories::*;

    verification def VAL_101_FirstReading {
        objective {
            verify US_101_SeeFirstReading.acceptance.firstReading;
            verify US_101_SeeFirstReading.acceptance.readingUnit;
        }
    }

    verification def VAL_103_Export {
        objective {
            verify US_103_ExportReadings;
        }
    }
}
