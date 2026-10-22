package FixtureRegister {
    private import VSE_Library::*;

    requirement US_401_First : UserStory {
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

    requirement US_402_Second : UserStory {
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

    requirement US_403_Third : UserStory {
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

    requirement US_404_Fourth : UserStory {
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
