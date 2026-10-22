package FixtureStatus {
    private import VSE_Library::*;

    requirement US_511_NoStatusNoScenario : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_512_NoStatusUncovered : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; }

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

    requirement US_513_UnrankedStatusUncovered : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::blocked; }

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

    requirement US_514_NoStatusNoRole : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; }

        subject :>> system : ExampleSystem;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";

        requirement :>> acceptance {
            requirement firstReading {
                doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */
            }
        }
    }

    requirement US_515_Clean : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::blocked; }

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
