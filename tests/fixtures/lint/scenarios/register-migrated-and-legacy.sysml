package ExampleStories {
    private import VSE_Library::*;

    requirement US_901_Example : UserStory {
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

    requirement US_902_Legacy : UserStory {
        @StoryMeta { points = 2; priority = Priority::medium; status = StoryStatus::ready; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the battery level";
        attribute :>> benefit    = "the battery is replaced in time";

        requirement :>> acceptance {
            doc /* Given a low battery, when the operator looks at the display, then a warning is shown. */
        }
    }
}
