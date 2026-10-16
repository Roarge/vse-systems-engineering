package FixtureS3 {
    private import VSE_Library::*;

    requirement US_131_LegacyProse : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";

        requirement :>> acceptance {
            doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */
        }
    }

    requirement US_132_PreFourAcceptance : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";

        requirement acceptance[1] {
            doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */
        }
    }

    requirement US_133_ProseBesideCriterion : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";

        requirement :>> acceptance {
            doc /* The criteria below replace this text. */
            requirement firstReading {
                doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */
            }
        }
    }

    requirement US_134_Clean : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";

        requirement :>> acceptance {
            requirement firstReading {
                doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */
            }
        }
    }
}
