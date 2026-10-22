package FixtureOutside {
    private import VSE_Library::*;

    // Stories outside a stories/ directory are not checked, with or
    // without a feature file beside them, and neither is a story
    // declaration in another form.
    requirement US_301_NoFeature : UserStory {
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

    requirement US_302_WithFeature : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::inProgress; }

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

    requirement def US_303_Legacy :> UserStory {
        doc /* A pre-4.0 story definition. */
    }
}
