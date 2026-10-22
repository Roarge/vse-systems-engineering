package ExampleStories {
    private import VSE_Library::*;

    requirement US_901_Example : UserStory {
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
}
