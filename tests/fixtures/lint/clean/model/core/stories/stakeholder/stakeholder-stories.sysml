package CleanStakeholderStories {
    private import VSE_Library::*;

    requirement US_101_SeeFirstReading : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::inProgress; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";

        requirement :>> acceptance {
            requirement firstReading {
                doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */
            }
            requirement readingUnit {
                doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */
            }
        }
    }

    requirement US_102_KeepHistory : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "keep every reading";
        attribute :>> benefit    = "trends can be studied later";
    }

    requirement US_103_ExportReadings : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::done; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "export the readings as a file";
        attribute :>> benefit    = "the readings can be shared";

        requirement :>> acceptance {
            requirement exportFile {
                doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */
            }
        }
    }
}
